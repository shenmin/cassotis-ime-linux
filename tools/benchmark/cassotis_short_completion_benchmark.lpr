program cassotis_short_completion_benchmark;

{$codepage utf8}
{$mode delphiunicode}
{$H+}
{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

uses
    {$ifdef UNIX}
    cthreads,
    cwstring,
    {$endif}
    Classes,
    Generics.Collections,
    Math,
    SysUtils,
    nc_dictionary_sqlite,
    nc_engine_intf,
    nc_types;

const
    c_fnv1a_offset_basis: QWord = 14695981039346656037;
    c_fnv1a_prime: QWord = 1099511628211;

type
    TncShortCompletionTotals = record
        cases: Integer;
        opportunities: Integer;
        prompts: Integer;
        hits: Integer;
        wrong_prompts: Integer;
        saved_keys: Int64;
        stability_pairs: Integer;
        stable_pairs: Integer;
        completion_signature: QWord;
    end;

procedure update_signature(var signature: QWord; const value: string);
var
    bytes: UTF8String;
    index: Integer;
begin
    bytes := UTF8Encode(value);
    for index := 1 to Length(bytes) do
        signature := (signature xor Byte(bytes[index])) * c_fnv1a_prime;
end;

function read_utf8_file(const file_path: string): string;
var
    stream: TFileStream;
    bytes: RawByteString;
begin
    bytes := '';
    stream := TFileStream.Create(UTF8Encode(file_path),
        fmOpenRead or fmShareDenyWrite);
    try
        SetLength(bytes, stream.Size);
        if Length(bytes) > 0 then
            stream.ReadBuffer(bytes[1], Length(bytes));
    finally
        stream.Free;
    end;
    if (Length(bytes) >= 3) and (Byte(bytes[1]) = $ef) and
        (Byte(bytes[2]) = $bb) and (Byte(bytes[3]) = $bf) then
        Delete(bytes, 1, 3);
    Result := UTF8Decode(bytes);
end;

function next_line(const content: string; var cursor: Integer;
    out line: string): Boolean;
var
    line_start: Integer;
begin
    line := '';
    if cursor > Length(content) then
        Exit(False);
    line_start := cursor;
    while (cursor <= Length(content)) and (content[cursor] <> #10) and
        (content[cursor] <> #13) do
        Inc(cursor);
    line := Copy(content, line_start, cursor - line_start);
    if (cursor <= Length(content)) and (content[cursor] = #13) then
        Inc(cursor);
    if (cursor <= Length(content)) and (content[cursor] = #10) then
        Inc(cursor);
    Result := True;
end;

function create_engine_config: TncEngineConfig;
begin
    Result := Default(TncEngineConfig);
    Result.input_mode := im_chinese;
    Result.pinyin_input_scheme := pis_full_pinyin;
    Result.max_candidates := 9;
    Result.candidate_page_size := 9;
    Result.one_key_completion_key := ock_tab;
    Result.enable_segment_candidates := True;
    Result.segment_head_only_multi_syllable := True;
    Result.dictionary_variant := dv_simplified;
end;

function percentile_ms(const values: TList<QWord>;
    const percentile: Double): QWord;
var
    index: Integer;
begin
    if values.Count = 0 then
        Exit(0);
    index := EnsureRange(Ceil(values.Count * percentile) - 1, 0,
        values.Count - 1);
    Result := values[index];
end;

procedure evaluate_case(const engine: TncEngine; const target,
    full_pinyin, context_prefix: string; var totals: TncShortCompletionTotals;
    const latencies_ms: TList<QWord>);
var
    syllables: TArray<string>;
    prefix_units: Integer;
    typed_prefix: string;
    previous_completion: TncOneKeyCompletion;
    completion: TncOneKeyCompletion;
    oracle_completions: TncOneKeyCompletionList;
    oracle_char_lm_scores: TArray<Integer>;
    oracle_reverse_char_lm_scores: TArray<Integer>;
    oracle_prefix1_lm_scores: TArray<Integer>;
    oracle_prefix2_lm_scores: TArray<Integer>;
    started_at: QWord;
    elapsed_ms: QWord;
    prompted: Boolean;
    hit: Boolean;
    compatible_previous: Boolean;
begin
    oracle_completions := nil;
    syllables := full_pinyin.Split([''''],
        TStringSplitOptions.ExcludeEmpty);
    if Length(syllables) < 3 then
        Exit;

    engine.reset;
    previous_completion := Default(TncOneKeyCompletion);
    typed_prefix := '';
    for prefix_units := 1 to Length(syllables) - 1 do
    begin
        typed_prefix := typed_prefix + LowerCase(Trim(
            syllables[prefix_units - 1]));
        if prefix_units < 2 then
            Continue;

        started_at := GetTickCount64;
        completion := engine.debug_query_one_key_completion(typed_prefix,
            context_prefix);
        elapsed_ms := GetTickCount64 - started_at;

        // Match the official Windows runner's post-query diagnostic pass.
        SetLength(oracle_completions, 0);
        engine.debug_score_one_key_completion_candidates(typed_prefix,
            context_prefix, oracle_completions, oracle_char_lm_scores,
            oracle_reverse_char_lm_scores, oracle_prefix1_lm_scores,
            oracle_prefix2_lm_scores);

        Inc(totals.opportunities);
        latencies_ms.Add(elapsed_ms);
        prompted := Trim(completion.text) <> '';
        hit := prompted and SameText(Trim(completion.text), Trim(target));
        if prompted then
        begin
            Inc(totals.prompts);
            if hit then
            begin
                Inc(totals.hits);
                Inc(totals.saved_keys, Max(0,
                    Length(StringReplace(full_pinyin, '''', '',
                    [rfReplaceAll])) - Length(typed_prefix) - 1));
            end
            else
                Inc(totals.wrong_prompts);
        end;

        compatible_previous :=
            (Trim(previous_completion.text) <> '') and
            previous_completion.full_pinyin.StartsWith(typed_prefix, True);
        if compatible_previous then
        begin
            Inc(totals.stability_pairs);
            if prompted and SameText(previous_completion.text,
                completion.text) and SameText(
                previous_completion.full_pinyin,
                completion.full_pinyin) then
                Inc(totals.stable_pairs);
        end;

        update_signature(totals.completion_signature,
            IntToStr(totals.opportunities) + #9 + completion.text + #9 +
            IntToStr(Ord(hit)) + #10);
        previous_completion := completion;
    end;
end;

procedure write_summary(const totals: TncShortCompletionTotals;
    const latencies_ms: TList<QWord>);
var
    latency: QWord;
    total_latency: QWord;
    average_saved: Double;
begin
    latencies_ms.Sort;
    total_latency := 0;
    for latency in latencies_ms do
        Inc(total_latency, latency);
    if totals.hits > 0 then
        average_saved := totals.saved_keys / totals.hits
    else
        average_saved := 0;

    WriteLn('format=cassotis-short-completion-quality-v1');
    WriteLn('cases=', totals.cases);
    WriteLn('opportunities=', totals.opportunities);
    WriteLn('prompts=', totals.prompts);
    WriteLn('hits=', totals.hits);
    WriteLn('wrong_prompts=', totals.wrong_prompts);
    WriteLn('saved_keys=', totals.saved_keys);
    WriteLn('average_saved_keys=', FormatFloat('0.000', average_saved));
    WriteLn('stability_pairs=', totals.stability_pairs);
    WriteLn('stable_pairs=', totals.stable_pairs);
    WriteLn('completion_signature=', IntToHex(
        totals.completion_signature, 16));
    if latencies_ms.Count > 0 then
    begin
        WriteLn('mean_ms=', FormatFloat('0.000',
            total_latency / latencies_ms.Count));
        WriteLn('p50_ms=', percentile_ms(latencies_ms, 0.50));
        WriteLn('p95_ms=', percentile_ms(latencies_ms, 0.95));
        WriteLn('max_ms=', latencies_ms[latencies_ms.Count - 1]);
    end;
end;

procedure run;
var
    dictionary_path: string;
    cases_path: string;
    case_limit: Integer;
    progress_every: Integer;
    dictionary: TncSqliteDictionary;
    engine: TncEngine;
    content: string;
    cursor: Integer;
    line: string;
    fields: TArray<string>;
    totals: TncShortCompletionTotals;
    latencies_ms: TList<QWord>;
begin
    if ParamCount < 2 then
    begin
        WriteLn(StdErr, 'Usage: cassotis-short-completion-benchmark ' +
            'DICTIONARY CASES [LIMIT] [PROGRESS_EVERY]');
        Halt(2);
    end;
    dictionary_path := ExpandFileName(ParamStr(1));
    cases_path := ExpandFileName(ParamStr(2));
    if ParamCount >= 3 then
        case_limit := StrToIntDef(ParamStr(3), MaxInt)
    else
        case_limit := MaxInt;
    if case_limit <= 0 then
        case_limit := MaxInt;
    if ParamCount >= 4 then
        progress_every := StrToIntDef(ParamStr(4), 2000)
    else
        progress_every := 2000;

    dictionary := TncSqliteDictionary.Create(dictionary_path, '', False);
    engine := TncEngine.Create(create_engine_config);
    latencies_ms := TList<QWord>.Create;
    try
        if not dictionary.Open then
            raise Exception.Create('dictionary could not be opened');
        engine.set_dictionary_provider(dictionary);
        dictionary := nil;
        engine.debug_set_search_budget_policy(sbm_deterministic, 100);

        totals := Default(TncShortCompletionTotals);
        totals.completion_signature := c_fnv1a_offset_basis;
        content := read_utf8_file(cases_path);
        cursor := 1;
        next_line(content, cursor, line);
        while next_line(content, cursor, line) and
            (totals.cases < case_limit) do
        begin
            if Trim(line) = '' then
                Continue;
            fields := line.Split([#9]);
            if Length(fields) < 15 then
                Continue;
            Inc(totals.cases);
            evaluate_case(engine, fields[3], fields[4], fields[14], totals,
                latencies_ms);
            if (progress_every > 0) and
                ((totals.cases mod progress_every) = 0) then
            begin
                WriteLn(StdErr, 'progress=', totals.cases);
                Flush(StdErr);
            end;
        end;
        write_summary(totals, latencies_ms);
    finally
        engine.Free;
        dictionary.Free;
        latencies_ms.Free;
    end;
end;

begin
    try
        run;
    except
        on error: Exception do
        begin
            WriteLn(StdErr, error.ClassName + ': ' + error.Message);
            ExitCode := 1;
        end;
    end;
end.
