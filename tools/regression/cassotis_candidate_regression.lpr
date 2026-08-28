program cassotis_candidate_regression;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

uses
{$IFDEF UNIX}
    cthreads,
    cwstring,
{$ENDIF}
    Classes,
    SysUtils,
    nc_types,
    nc_dictionary_reader,
    nc_engine_service;

type
    TncRegressionCase = record
        line_number: Integer;
        query: string;
        expected_text: string;
        maximum_rank: Integer;
        category: string;
    end;
    TncRegressionCases = array of TncRegressionCase;
    TncLatencyList = array of QWord;

function nc_read_utf8_file(const file_path: string): string;
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
    if (Length(bytes) >= 3) and (Byte(bytes[1]) = $EF) and
        (Byte(bytes[2]) = $BB) and (Byte(bytes[3]) = $BF) then
        Delete(bytes, 1, 3);
    Result := UTF8Decode(bytes);
end;

function nc_next_line(const content: string; var cursor: Integer;
    out line: string): Boolean;
var
    line_start: Integer;
begin
    line := '';
    if cursor > Length(content) then
        Exit(False);
    line_start := cursor;
    while (cursor <= Length(content)) and
        (content[cursor] <> #10) and (content[cursor] <> #13) do
        Inc(cursor);
    line := Copy(content, line_start, cursor - line_start);
    if (cursor <= Length(content)) and (content[cursor] = #13) then
        Inc(cursor);
    if (cursor <= Length(content)) and (content[cursor] = #10) then
        Inc(cursor);
    Result := True;
end;

function nc_split_tab_fields(const line: string;
    out fields: array of string): Integer;
var
    field_index: Integer;
    start_index: Integer;
    scan_index: Integer;
begin
    for field_index := Low(fields) to High(fields) do
        fields[field_index] := '';
    field_index := 0;
    start_index := 1;
    for scan_index := 1 to Length(line) + 1 do
        if (scan_index > Length(line)) or (line[scan_index] = #9) then
        begin
            if field_index <= High(fields) then
                fields[field_index] := Copy(line, start_index,
                    scan_index - start_index);
            Inc(field_index);
            start_index := scan_index + 1;
        end;
    Result := field_index;
end;

function nc_load_cases(const file_path: string;
    out cases: TncRegressionCases; out error_text: string): Boolean;
var
    content: string;
    fields: array[0..3] of string;
    line: string;
    line_number: Integer;
    cursor: Integer;
    field_count: Integer;
    parse_error: Integer;
    item: TncRegressionCase;
begin
    cases := nil;
    error_text := '';
    if not FileExists(file_path) then
    begin
        error_text := 'case file does not exist: ' + file_path;
        Exit(False);
    end;
    try
        content := nc_read_utf8_file(file_path);
    except
        on error: Exception do
        begin
            error_text := 'unable to read case file: ' +
                UTF8Decode(error.Message);
            Exit(False);
        end;
    end;

    cursor := 1;
    line_number := 0;
    while nc_next_line(content, cursor, line) do
    begin
        Inc(line_number);
        line := TrimRight(line);
        if (Trim(line) = '') or (line[1] = '#') then
            Continue;
        field_count := nc_split_tab_fields(line, fields);
        if field_count <> Length(fields) then
        begin
            error_text := 'invalid field count at line ' +
                UnicodeString(IntToStr(line_number));
            Exit(False);
        end;
        item.line_number := line_number;
        item.query := LowerCase(Trim(fields[0]));
        item.expected_text := Trim(fields[1]);
        Val(Trim(fields[2]), item.maximum_rank, parse_error);
        item.category := Trim(fields[3]);
        if (item.query = '') or (item.expected_text = '') or
            (item.category = '') or (parse_error <> 0) or
            (item.maximum_rank <= 0) then
        begin
            error_text := 'invalid case at line ' +
                UnicodeString(IntToStr(line_number));
            Exit(False);
        end;
        SetLength(cases, Length(cases) + 1);
        cases[High(cases)] := item;
    end;
    if Length(cases) = 0 then
    begin
        error_text := 'case file contains no regression cases';
        Exit(False);
    end;
    Result := True;
end;

function nc_letter_event(const value: WideChar;
    const timestamp_ms: QWord): TncKeyEvent;
begin
    Result.text := value;
    Result.special_key := sk_none;
    Result.modifiers := [];
    Result.scan_code := 0;
    Result.is_release := False;
    Result.is_repeat := False;
    Result.timestamp_ms := timestamp_ms;
end;

procedure nc_sort_latencies(var values: TncLatencyList);
var
    index: Integer;
    scan_index: Integer;
    current_value: QWord;
begin
    for index := 1 to High(values) do
    begin
        current_value := values[index];
        scan_index := index - 1;
        while (scan_index >= 0) and
            (current_value < values[scan_index]) do
        begin
            values[scan_index + 1] := values[scan_index];
            Dec(scan_index);
        end;
        values[scan_index + 1] := current_value;
    end;
end;

function nc_percentile_index(const count: Integer;
    const numerator: Integer): Integer;
begin
    Result := ((count * numerator) + 99) div 100 - 1;
    if Result < 0 then
        Result := 0;
    if Result >= count then
        Result := count - 1;
end;

procedure nc_run(const database_path: string; const case_path: string;
    const print_candidates: Boolean);
var
    cases: TncRegressionCases;
    error_text: string;
    service: TncEngineService;
    engine_result: TncEngineResult;
    latencies: TncLatencyList;
    sorted_latencies: TncLatencyList;
    generation: QWord;
    started_at: QWord;
    elapsed: QWord;
    total_elapsed: QWord;
    case_index: Integer;
    input_index: Integer;
    candidate_index: Integer;
    found_rank: Integer;
    passed_count: Integer;
    top1_count: Integer;
    top_text: string;
    diagnostic_reader: TncDictionaryReader;
    diagnostic_texts: TncDictionaryTexts;
    diagnostic_scores: TncDictionaryScores;
begin
    if not nc_load_cases(case_path, cases, error_text) then
        raise Exception.Create(UTF8Encode(error_text));
    diagnostic_texts := nil;
    diagnostic_scores := nil;
    service := TncEngineService.Create(database_path);
    diagnostic_reader := nil;
    try
        if not service.DictionaryReady then
            raise Exception.Create(UTF8Encode('dictionary open failed: ' +
                service.DictionaryError));
        if not service.CreateContext(1) then
            raise Exception.Create('unable to create regression context');
        latencies := nil;
        SetLength(latencies, Length(cases));
        generation := 0;
        total_elapsed := 0;
        passed_count := 0;
        top1_count := 0;
        for case_index := 0 to High(cases) do
        begin
            Inc(generation);
            if not service.ResetContext(1, generation) then
                raise Exception.Create('unable to reset regression context');
            started_at := GetTickCount64;
            for input_index := 1 to Length(cases[case_index].query) do
            begin
                Inc(generation);
                engine_result := service.ProcessKey(1, generation,
                    nc_letter_event(cases[case_index].query[input_index],
                    generation));
                if engine_result.error_code <> 0 then
                    raise Exception.CreateFmt('query %s failed: %s',
                        [cases[case_index].query, engine_result.error_text]);
            end;
            elapsed := GetTickCount64 - started_at;
            latencies[case_index] := elapsed;
            Inc(total_elapsed, elapsed);
            found_rank := 0;
            top_text := '';
            if Length(engine_result.candidates) > 0 then
                top_text := engine_result.candidates[0].text;
            for candidate_index := 0 to High(engine_result.candidates) do
                if engine_result.candidates[candidate_index].text =
                    cases[case_index].expected_text then
                begin
                    found_rank := candidate_index + 1;
                    Break;
                end;
            if found_rank = 1 then
                Inc(top1_count);
            if (found_rank > 0) and
                (found_rank <= cases[case_index].maximum_rank) then
            begin
                Inc(passed_count);
                WriteLn('PASS', #9, cases[case_index].category, #9,
                    cases[case_index].query, #9, 'rank=', found_rank, '/',
                    cases[case_index].maximum_rank, #9, 'ms=', elapsed);
            end
            else
                WriteLn('FAIL', #9, cases[case_index].category, #9,
                    cases[case_index].query, #9, 'expected=',
                    cases[case_index].expected_text, #9, 'rank=', found_rank,
                    '/', cases[case_index].maximum_rank, #9, 'top1=',
                    top_text, #9, 'line=', cases[case_index].line_number,
                    #9, 'ms=', elapsed);
            if print_candidates then
            begin
                if diagnostic_reader = nil then
                begin
                    diagnostic_reader := TncDictionaryReader.Create(
                        database_path);
                    if not diagnostic_reader.Open then
                        raise Exception.Create(UTF8Encode(
                            'diagnostic dictionary open failed: ' +
                            diagnostic_reader.ErrorMessage));
                end;
                SetLength(diagnostic_texts,
                    Length(engine_result.candidates));
                for candidate_index := 0 to
                    High(engine_result.candidates) do
                    diagnostic_texts[candidate_index] :=
                        engine_result.candidates[candidate_index].text;
                if not diagnostic_reader.QueryCharLmTextScores(
                    diagnostic_texts, diagnostic_scores) then
                begin
                    SetLength(diagnostic_scores,
                        Length(engine_result.candidates));
                    for candidate_index := 0 to
                        High(diagnostic_scores) do
                        diagnostic_scores[candidate_index] := 0;
                end;
                for candidate_index := 0 to High(engine_result.candidates) do
                begin
                    WriteLn('CAND', #9, cases[case_index].query, #9,
                        'rank=', candidate_index + 1, #9, 'text=',
                        engine_result.candidates[candidate_index].text, #9,
                        'score=', engine_result.candidates[candidate_index].score,
                        #9, 'dict_weight=',
                        engine_result.candidates[candidate_index].dict_weight,
                        #9, 'source=',
                        Ord(engine_result.candidates[candidate_index].source),
                        #9, 'display=', Ord(engine_result.candidates[
                        candidate_index].display_kind), #9, 'lm_score=',
                        diagnostic_scores[candidate_index]);
                end;
            end;
        end;
        sorted_latencies := Copy(latencies, 0, Length(latencies));
        nc_sort_latencies(sorted_latencies);
        WriteLn('summary.total=', Length(cases));
        WriteLn('summary.passed=', passed_count);
        WriteLn('summary.failed=', Length(cases) - passed_count);
        WriteLn('summary.top1=', top1_count);
        WriteLn('latency.mean_ms=', total_elapsed / Length(cases):0:3);
        WriteLn('latency.p50_ms=', sorted_latencies[
            nc_percentile_index(Length(sorted_latencies), 50)]);
        WriteLn('latency.p95_ms=', sorted_latencies[
            nc_percentile_index(Length(sorted_latencies), 95)]);
        WriteLn('latency.max_ms=', sorted_latencies[High(sorted_latencies)]);
        if passed_count <> Length(cases) then
            Halt(1);
    finally
        diagnostic_reader.Free;
        service.Free;
    end;
end;

begin
    if (ParamCount < 2) or (ParamCount > 3) or
        ((ParamCount = 3) and (ParamStr(3) <> '--candidates')) then
    begin
        WriteLn(StdErr,
            'Usage: cassotis-candidate-regression DICTIONARY CASES_TSV ' +
            '[--candidates]');
        Halt(2);
    end;
    try
        nc_run(ParamStr(1), ParamStr(2), ParamCount = 3);
    except
        on error: Exception do
        begin
            WriteLn(StdErr, error.Message);
            Halt(1);
        end;
    end;
end.
