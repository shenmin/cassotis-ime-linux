program cassotis_neural_engine_smoke;

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
    Math,
    SysUtils,
    nc_config,
    nc_dictionary_sqlite,
    nc_engine_intf,
    nc_local_completion_host,
    nc_pinyin_parser,
    nc_pinyin_transformer_host,
    nc_types;

const
    c_default_case_limit = 500;
    c_default_result_timeout_ms = 40;
    c_runtime_timeout_ms = 30000;
    c_task_timeout_ms = 5000;
    c_fnv1a_offset_basis: QWord = 14695981039346656037;
    c_fnv1a_prime: QWord = 1099511628211;

type
    TncSmokeTotals = record
        cases: Integer;
        opportunities: Integer;
        requests: Integer;
        accepted: Integer;
        applied: Integer;
        visible: Integer;
        hits: Integer;
        wrong_prompts: Integer;
        saved_keys: Int64;
        completion_signature: QWord;
    end;

procedure update_signature(var signature: QWord; const value: string);
var
    bytes: UTF8String;
    index: Integer;
begin
    bytes := UTF8Encode(value);
    for index := 1 to Length(bytes) do
    begin
        signature := (signature xor Byte(bytes[index])) * c_fnv1a_prime;
    end;
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
    Result := nc_default_engine_config;
    Result.input_mode := im_chinese;
    Result.pinyin_input_scheme := pis_full_pinyin;
    Result.one_key_completion_key := ock_tab;
end;

procedure evaluate_case(const engine: TncEngine;
    const completion_host: TncLocalCompletionHost;
    const parser: TncPinyinParser; const sentence, full_pinyin: string;
    const generation: QWord; var totals: TncSmokeTotals);
var
    syllables: TncPinyinParseResult;
    typed_units: Integer;
    typed_prefix: string;
    target_prefix_text: string;
    request: TncLongNeuralCompletionRequest;
    task: TncLocalCompletionTask;
    finished: TncLocalCompletionFinished;
    completion: TncOneKeyCompletion;
    completion_pinyin: string;
    saved_keys: Integer;
    hit: Boolean;
begin
    syllables := parser.parse(LowerCase(Trim(full_pinyin)));
    if Length(syllables) < 5 then
        Exit;
    typed_units := Max(4, Length(syllables) - 4);
    if typed_units >= Length(syllables) then
        Exit;

    Inc(totals.opportunities);
    typed_prefix := join_syllables(syllables, typed_units);
    target_prefix_text := Copy(sentence, 1, typed_units);
    engine.reset;
    engine.set_external_left_context('');
    engine.debug_set_composition_text(typed_prefix);
    if not engine.get_long_neural_completion_request(request) then
        Exit;

    Inc(totals.requests);
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
    if not finished.accepted then
        Exit;

    Inc(totals.accepted);
    if not engine.apply_long_neural_completion(request,
        finished.completion_result) then
        Exit;
    Inc(totals.applied);
    completion := engine.get_one_key_completion;
    if (completion.source <> okcs_long_neural) or
        (Trim(completion.text) = '') then
        raise Exception.Create('applied neural completion is not visible');
    Inc(totals.visible);
    completion_pinyin := StringReplace(completion.full_pinyin, '''', '',
        [rfReplaceAll]);
    hit := (Length(completion.text) > Length(target_prefix_text)) and
        (Length(completion_pinyin) > Length(typed_prefix)) and
        SameText(Copy(completion.text, 1, Length(target_prefix_text)),
        target_prefix_text) and
        SameText(Copy(sentence, 1, Length(completion.text)),
        completion.text);
    if hit then
    begin
        Inc(totals.hits);
        saved_keys := Max(0, Length(completion_pinyin) -
            Length(typed_prefix) - 1);
        Inc(totals.saved_keys, saved_keys);
    end
    else
        Inc(totals.wrong_prompts);
    update_signature(totals.completion_signature, IntToStr(generation) + #9 +
        completion.text + #9 + completion.full_pinyin + #9 +
        IntToStr(Ord(hit)) + #10);
    if totals.visible = 1 then
    begin
        WriteLn('sample.query=', UTF8Encode(typed_prefix));
        WriteLn('sample.sentence=', UTF8Encode(sentence));
        WriteLn('sample.completion=', UTF8Encode(completion.text));
    end;
end;

procedure run;
var
    dictionary_path: string;
    cases_path: string;
    runtime_directory: string;
    case_limit: Integer;
    result_timeout_ms: QWord;
    dictionary: TncSqliteDictionary;
    engine: TncEngine;
    parser: TncPinyinParser;
    reranker: TncPinyinTransformerHostReranker;
    reranker_reference: IncLongNeuralReranker;
    completion_host: TncLocalCompletionHost;
    content: string;
    cursor: Integer;
    line: string;
    fields: TArray<string>;
    totals: TncSmokeTotals;
begin
    if ParamCount < 2 then
    begin
        WriteLn(StdErr, 'Usage: cassotis-neural-engine-smoke DICTIONARY CASES ' +
            '[LIMIT] [RESULT_TIMEOUT_MS]');
        Halt(2);
    end;
    dictionary_path := ExpandFileName(ParamStr(1));
    cases_path := ExpandFileName(ParamStr(2));
    if ParamCount >= 3 then
        case_limit := StrToIntDef(ParamStr(3), c_default_case_limit)
    else
        case_limit := c_default_case_limit;
    if case_limit <= 0 then
        case_limit := c_default_case_limit;
    if ParamCount >= 4 then
        result_timeout_ms := StrToQWordDef(ParamStr(4),
            c_default_result_timeout_ms)
    else
        result_timeout_ms := c_default_result_timeout_ms;
    runtime_directory := ExtractFileDir(ParamStr(0));

    dictionary := nil;
    engine := nil;
    parser := nil;
    reranker := nil;
    reranker_reference := nil;
    completion_host := nil;
    try
        dictionary := TncSqliteDictionary.Create(dictionary_path, '', False);
        if not dictionary.Open then
            raise Exception.Create('dictionary open failed: ' + dictionary_path);
        engine := TncEngine.Create(create_engine_config);
        parser := TncPinyinParser.Create;
        reranker := TncPinyinTransformerHostReranker.Create(
            runtime_directory, False);
        reranker_reference := reranker;
        completion_host := TncLocalCompletionHost.Create(runtime_directory,
            result_timeout_ms);
        if not reranker.Ready then
            raise Exception.Create('pinyin Transformer unavailable: ' +
                reranker.last_error());
        if not wait_for_completion_host(completion_host) then
            raise Exception.Create('local completion unavailable: ' +
                completion_host.LastError());
        engine.set_dictionary_provider(dictionary);
        dictionary := nil;
        engine.set_long_neural_reranker(reranker_reference);
        engine.debug_set_search_budget_policy(sbm_deterministic, 100);

        totals := Default(TncSmokeTotals);
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
            if Length(fields) < 5 then
                Continue;
            Inc(totals.cases);
            evaluate_case(engine, completion_host, parser, fields[3],
                fields[4], totals.cases, totals);
        end;
        WriteLn('cases=', totals.cases);
        WriteLn('result_timeout_ms=', result_timeout_ms);
        WriteLn('opportunities=', totals.opportunities);
        WriteLn('requests=', totals.requests);
        WriteLn('accepted=', totals.accepted);
        WriteLn('applied=', totals.applied);
        WriteLn('visible=', totals.visible);
        WriteLn('hits=', totals.hits);
        WriteLn('wrong_prompts=', totals.wrong_prompts);
        WriteLn('saved_keys=', totals.saved_keys);
        WriteLn('completion_signature=', IntToHex(
            totals.completion_signature, 16));
        if (totals.requests = 0) or (totals.accepted = 0) or
            (totals.applied = 0) or (totals.visible = 0) then
            raise Exception.Create('neural engine path was not exercised');
    finally
        completion_host.Free;
        engine.Free;
        reranker_reference := nil;
        parser.Free;
        dictionary.Free;
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
