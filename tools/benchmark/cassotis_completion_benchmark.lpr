program cassotis_completion_benchmark;

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
    nc_local_completion_host,
    nc_pinyin_parser,
    nc_pinyin_transformer_host,
    nc_types;

const
    c_runtime_timeout_ms = 30000;
    c_task_timeout_ms = 5000;
    // Match the production host and the Windows completion benchmark.
    c_default_result_timeout_ms = 40;
    c_fnv1a_offset_basis: QWord = 14695981039346656037;
    c_fnv1a_prime: QWord = 1099511628211;

type
    TncCompletionTotals = record
        cases: Integer;
        opportunities: Integer;
        prompts: Integer;
        hits: Integer;
        full_sentence_hits: Integer;
        wrong_prompts: Integer;
        saved_keys: Int64;
        stability_pairs: Integer;
        stable_pairs: Integer;
        neural_requests: Integer;
        neural_accepted: Integer;
        neural_applied: Integer;
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

function join_syllables(const syllables: TncPinyinParseResult;
    const count: Integer): string;
var
    index: Integer;
begin
    Result := '';
    for index := 0 to Min(count, Length(syllables)) - 1 do
        Result := Result + LowerCase(Trim(syllables[index].text));
end;

function wait_for_completion_host(const host: TncLocalCompletionHost): Boolean;
var
    deadline: QWord;
begin
    deadline := GetTickCount64 + c_runtime_timeout_ms;
    while (not host.LoadFinished) and (GetTickCount64 < deadline) do
        Sleep(5);
    Result := host.Ready;
end;

function wait_for_task(const host: TncLocalCompletionHost;
    const context_id: QWord;
    out finished: TncLocalCompletionFinished): Boolean;
var
    deadline: QWord;
begin
    deadline := GetTickCount64 + c_task_timeout_ms;
    repeat
        if host.TryPopFinishedFor(context_id, finished) then
            Exit(True);
        Sleep(1);
    until GetTickCount64 >= deadline;
    Result := False;
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

procedure resolve_completion(const engine: TncEngine;
    const completion_host: TncLocalCompletionHost;
    var generation: QWord; const latency_started_at: QWord;
    out completion: TncOneKeyCompletion; out visible_latency_ms: QWord;
    out has_neural_request, neural_accepted, neural_applied: Boolean);
var
    request: TncLongNeuralCompletionRequest;
    task: TncLocalCompletionTask;
    finished: TncLocalCompletionFinished;
begin
    completion := engine.get_one_key_completion;
    if latency_started_at <> 0 then
        visible_latency_ms := GetTickCount64 - latency_started_at
    else
        visible_latency_ms := 0;
    request := Default(TncLongNeuralCompletionRequest);
    has_neural_request := engine.get_long_neural_completion_request(request);
    neural_accepted := False;
    neural_applied := False;
    if (not has_neural_request) or (completion_host = nil) then
        Exit;

    Inc(generation);
    task := Default(TncLocalCompletionTask);
    task.context_id := 1;
    task.generation_id := generation;
    task.request := request;
    if not completion_host.Enqueue(task) then
        raise Exception.Create('local completion request was not queued');
    if not wait_for_task(completion_host, task.context_id, finished) then
        raise Exception.Create('local completion request timed out');
    if finished.task.generation_id <> generation then
        raise Exception.Create('local completion generation mismatch');
    neural_accepted := finished.accepted;
    if not neural_accepted then
        Exit;
    neural_applied := engine.apply_long_neural_completion(request,
        finished.completion_result);
    if neural_applied then
    begin
        completion := engine.get_one_key_completion;
        if latency_started_at <> 0 then
            visible_latency_ms := GetTickCount64 - latency_started_at;
    end;
end;

function is_target_completion(const suggestion, target_prefix,
    target_sentence: string): Boolean;
var
    value: string;
begin
    value := Trim(suggestion);
    Result := (value <> '') and (Length(value) > Length(target_prefix)) and
        value.StartsWith(target_prefix, True) and
        target_sentence.StartsWith(value, True);
end;

procedure evaluate_case(const engine, oracle_engine: TncEngine;
    const completion_host: TncLocalCompletionHost;
    const parser: TncPinyinParser; const sentence, full_pinyin: string;
    var generation: QWord; var totals: TncCompletionTotals;
    const latencies: TList<QWord>);
var
    syllables: TncPinyinParseResult;
    typed_units: Integer;
    previous_units: Integer;
    typed_prefix: string;
    previous_prefix: string;
    target_prefix: string;
    previous_completion: TncOneKeyCompletion;
    completion: TncOneKeyCompletion;
    previous_has_request: Boolean;
    previous_accepted: Boolean;
    previous_applied: Boolean;
    previous_visible_latency_ms: QWord;
    has_request: Boolean;
    accepted: Boolean;
    applied: Boolean;
    visible_latency_ms: QWord;
    compatible_previous: Boolean;
    prompted: Boolean;
    hit: Boolean;
    started_at: QWord;
    completion_pinyin: string;
    oracle_pool: TncOneKeyCompletionList;
begin
    oracle_pool := nil;
    syllables := parser.parse(LowerCase(Trim(full_pinyin)));
    if Length(syllables) < 5 then
        Exit;
    typed_units := Max(4, Length(syllables) - 4);
    if typed_units >= Length(syllables) then
        Exit;

    Inc(totals.opportunities);
    typed_prefix := join_syllables(syllables, typed_units);
    target_prefix := Copy(sentence, 1, typed_units);

    engine.reset;
    engine.set_external_left_context('');
    previous_completion := Default(TncOneKeyCompletion);
    previous_units := typed_units - 1;
    if previous_units >= 4 then
    begin
        previous_prefix := join_syllables(syllables, previous_units);
        engine.debug_set_composition_text(previous_prefix);
        resolve_completion(engine, completion_host, generation, 0,
            previous_completion, previous_visible_latency_ms,
            previous_has_request, previous_accepted, previous_applied);
    end;

    started_at := GetTickCount64;
    engine.debug_set_composition_text(typed_prefix);
    resolve_completion(engine, completion_host, generation, started_at,
        completion, visible_latency_ms, has_request, accepted, applied);
    latencies.Add(visible_latency_ms);

    // Match the Windows release benchmark: oracle instrumentation runs after
    // the timed sample and warms the shared model/runtime state for the next
    // case, but never changes the measured production result.
    SetLength(oracle_pool, 0);
    if oracle_engine <> nil then
    begin
        oracle_engine.reset;
        oracle_engine.set_external_left_context('');
        oracle_engine.debug_set_composition_text(typed_prefix);
        oracle_engine.get_one_key_completion;
        oracle_engine.debug_get_long_one_key_completion_pool(oracle_pool);
    end;

    if has_request then
        Inc(totals.neural_requests);
    if accepted then
        Inc(totals.neural_accepted);
    if applied then
        Inc(totals.neural_applied);

    prompted := Trim(completion.text) <> '';
    hit := prompted and is_target_completion(completion.text, target_prefix,
        sentence);
    if prompted then
    begin
        Inc(totals.prompts);
        if hit then
        begin
            Inc(totals.hits);
            completion_pinyin := StringReplace(completion.full_pinyin, '''',
                '', [rfReplaceAll]);
            Inc(totals.saved_keys, Max(0, Length(completion_pinyin) -
                Length(typed_prefix) - 1));
        end
        else
            Inc(totals.wrong_prompts);
        if SameText(Trim(completion.text), Trim(sentence)) then
            Inc(totals.full_sentence_hits);
    end;

    compatible_previous := (Trim(previous_completion.text) <> '') and
        previous_completion.full_pinyin.StartsWith(typed_prefix, True);
    if compatible_previous then
    begin
        Inc(totals.stability_pairs);
        if prompted and SameText(previous_completion.text, completion.text) and
            SameText(previous_completion.full_pinyin,
            completion.full_pinyin) then
            Inc(totals.stable_pairs);
    end;
    update_signature(totals.completion_signature,
        IntToStr(totals.opportunities) + #9 + completion.text + #9 +
        completion.full_pinyin + #9 + IntToStr(Ord(hit)) + #10);
end;

procedure write_summary(const totals: TncCompletionTotals;
    const latencies: TList<QWord>; const result_timeout_ms: QWord);
var
    latency: QWord;
    total_latency: QWord;
    p50_index: Integer;
    p95_index: Integer;
begin
    latencies.Sort;
    total_latency := 0;
    for latency in latencies do
        Inc(total_latency, latency);

    WriteLn('format=cassotis-completion-quality-v1');
    WriteLn('result_timeout_ms=', result_timeout_ms);
    WriteLn('cases=', totals.cases);
    WriteLn('opportunities=', totals.opportunities);
    WriteLn('prompts=', totals.prompts);
    WriteLn('hits=', totals.hits);
    WriteLn('full_sentence_hits=', totals.full_sentence_hits);
    WriteLn('wrong_prompts=', totals.wrong_prompts);
    WriteLn('saved_keys=', totals.saved_keys);
    WriteLn('stability_pairs=', totals.stability_pairs);
    WriteLn('stable_pairs=', totals.stable_pairs);
    WriteLn('neural_requests=', totals.neural_requests);
    WriteLn('neural_accepted=', totals.neural_accepted);
    WriteLn('neural_applied=', totals.neural_applied);
    WriteLn('completion_signature=', IntToHex(
        totals.completion_signature, 16));
    if latencies.Count > 0 then
    begin
        p50_index := EnsureRange(Ceil(latencies.Count * 0.50) - 1, 0,
            latencies.Count - 1);
        p95_index := EnsureRange(Ceil(latencies.Count * 0.95) - 1, 0,
            latencies.Count - 1);
        WriteLn('mean_ms=', FormatFloat('0.000',
            total_latency / latencies.Count));
        WriteLn('p50_ms=', latencies[p50_index]);
        WriteLn('p95_ms=', latencies[p95_index]);
        WriteLn('max_ms=', latencies[latencies.Count - 1]);
    end;
end;

procedure run;
var
    dictionary_path: string;
    cases_path: string;
    runtime_directory: string;
    case_limit: Integer;
    progress_every: Integer;
    result_timeout_ms: QWord;
    enable_neural_runtime: Boolean;
    runtime_mode: string;
    dictionary: TncSqliteDictionary;
    oracle_dictionary: TncSqliteDictionary;
    engine: TncEngine;
    oracle_engine: TncEngine;
    parser: TncPinyinParser;
    reranker: TncPinyinTransformerHostReranker;
    reranker_reference: IncLongNeuralReranker;
    completion_host: TncLocalCompletionHost;
    latencies: TList<QWord>;
    content: string;
    cursor: Integer;
    line: string;
    fields: TArray<string>;
    generation: QWord;
    totals: TncCompletionTotals;
begin
    if ParamCount < 2 then
    begin
        WriteLn(StdErr, 'Usage: cassotis-completion-benchmark DICTIONARY ' +
            'CASES [LIMIT] [RESULT_TIMEOUT_MS] [PROGRESS_EVERY] ' +
            '[neural|static]');
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
        result_timeout_ms := StrToQWordDef(ParamStr(4),
            c_default_result_timeout_ms)
    else
        result_timeout_ms := c_default_result_timeout_ms;
    if ParamCount >= 5 then
        progress_every := StrToIntDef(ParamStr(5), 500)
    else
        progress_every := 500;
    runtime_mode := 'neural';
    if ParamCount >= 6 then
        runtime_mode := LowerCase(Trim(ParamStr(6)));
    if (runtime_mode <> 'neural') and (runtime_mode <> 'static') then
        raise Exception.Create('completion runtime mode must be neural or static');
    enable_neural_runtime := runtime_mode = 'neural';
    runtime_directory := ExtractFileDir(ParamStr(0));

    dictionary := TncSqliteDictionary.Create(dictionary_path, '', False);
    oracle_dictionary := nil;
    parser := TncPinyinParser.Create;
    engine := TncEngine.Create(create_engine_config);
    oracle_engine := nil;
    reranker := nil;
    reranker_reference := nil;
    completion_host := nil;
    latencies := TList<QWord>.Create;
    try
        if not dictionary.Open then
            raise Exception.Create('dictionary could not be opened');
        engine.set_dictionary_provider(dictionary);
        dictionary := nil;
        engine.debug_set_search_budget_policy(sbm_deterministic, 100);
        engine.debug_enable_long_one_key_completion_pool_capture(False);
        if enable_neural_runtime then
        begin
            reranker := TncPinyinTransformerHostReranker.Create(
                runtime_directory, False);
            reranker_reference := reranker;
            if not reranker.Ready then
                raise Exception.Create('pinyin Transformer unavailable: ' +
                    reranker.last_error());
            engine.set_long_neural_reranker(reranker_reference);
            completion_host := TncLocalCompletionHost.Create(
                runtime_directory, result_timeout_ms);
            if not wait_for_completion_host(completion_host) then
                raise Exception.Create(
                    'local completion runtime unavailable: ' +
                    completion_host.LastError);
        end;

        oracle_dictionary := TncSqliteDictionary.Create(dictionary_path, '',
            False);
        if not oracle_dictionary.Open then
            raise Exception.Create('oracle dictionary could not be opened');
        oracle_engine := TncEngine.Create(create_engine_config);
        oracle_engine.set_dictionary_provider(oracle_dictionary);
        oracle_dictionary := nil;
        oracle_engine.debug_set_search_budget_policy(sbm_deterministic, 100);
        oracle_engine.debug_enable_long_one_key_completion_pool_capture(True);
        if reranker_reference <> nil then
            oracle_engine.set_long_neural_reranker(reranker_reference);

        totals := Default(TncCompletionTotals);
        totals.completion_signature := c_fnv1a_offset_basis;
        generation := 0;
        content := read_utf8_file(cases_path);
        cursor := 1;
        next_line(content, cursor, line);
        while next_line(content, cursor, line) and
            (totals.cases < case_limit) do
        begin
            if Trim(line) = '' then
                Continue;
            fields := line.Split([#9]);
            if Length(fields) < 5 then
                Continue;
            Inc(totals.cases);
            evaluate_case(engine, oracle_engine, completion_host, parser,
                fields[3],
                fields[4], generation, totals, latencies);
            if (progress_every > 0) and
                ((totals.cases mod progress_every) = 0) then
            begin
                WriteLn(StdErr, 'progress=', totals.cases);
                Flush(StdErr);
            end;
        end;
        write_summary(totals, latencies, result_timeout_ms);
    finally
        completion_host.Free;
        oracle_engine.Free;
        engine.Free;
        reranker_reference := nil;
        parser.Free;
        oracle_dictionary.Free;
        dictionary.Free;
        latencies.Free;
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
