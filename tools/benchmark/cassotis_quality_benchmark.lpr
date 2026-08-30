program cassotis_quality_benchmark;

{$codepage utf8}
{$mode delphiunicode}
{$H+}
{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

uses
{$IFDEF UNIX}
    cthreads,
    cwstring,
{$ENDIF}
    Classes,
    StrUtils,
    SysUtils,
    nc_config,
    nc_dictionary_sqlite,
    nc_engine_intf,
    nc_pinyin_transformer_host,
    nc_types,
    nc_platform_compat;

type
    TLatencyArray = array of QWord;

    TUTF8LineWriter = class
    private
        FStream: TFileStream;
    public
        constructor Create(const file_path: string);
        destructor Destroy; override;
        procedure WriteLine(const value: string);
    end;

    TTrackTotals = record
        total: Integer;
        top1: Integer;
        top2: Integer;
        top5: Integer;
        top9: Integer;
        contested_total: Integer;
        contested_top1: Integer;
        contested_top2: Integer;
        elapsed_ms: QWord;
        latencies: TLatencyArray;
        peak_rss_kb: QWord;
        peak_hwm_kb: QWord;
    end;

    TLongAccuracyResult = record
        case_index: string;
        expected_text: string;
        pinyin: string;
        rank: Integer;
        top1_text: string;
    end;

    TLongAccuracyResultArray = array of TLongAccuracyResult;

    TOptions = record
        dictionary_path: string;
        long_cases_path: string;
        short_cases_path: string;
        neural_runtime_path: string;
        report_directory: string;
        long_limit: Integer;
        short_limit: Integer;
        progress_every: Integer;
    end;

var
    current_track: string = '';
    current_case: string = '';
    current_query: string = '';
    resource_events: TUTF8LineWriter = nil;
    process_peak_rss_kb: QWord = 0;
    process_peak_hwm_kb: QWord = 0;
    process_peak_track: string = '';
    process_peak_case: string = '';
    last_reported_hwm_kb: QWord = 0;

constructor TUTF8LineWriter.Create(const file_path: string);
begin
    inherited Create;
    FStream := TFileStream.Create(UTF8Encode(file_path), fmCreate);
end;

destructor TUTF8LineWriter.Destroy;
begin
    FStream.Free;
    inherited Destroy;
end;

procedure TUTF8LineWriter.WriteLine(const value: string);
var
    bytes: RawByteString;
begin
    bytes := UTF8Encode(value + LineEnding);
    if Length(bytes) > 0 then
        FStream.WriteBuffer(bytes[1], Length(bytes));
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

function split_tabs(const line: string; out fields: array of string): Integer;
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

function positive_integer(const value: string; const fallback: Integer): Integer;
var
    parse_error: Integer;
begin
    Val(value, Result, parse_error);
    if (parse_error <> 0) or (Result < 0) then
        Result := fallback;
end;

procedure usage;
begin
    WriteLn('Usage: cassotis-quality-benchmark --dictionary DB [OPTIONS]');
    WriteLn('  --long-cases FILE    Windows long_sentence_16300.tsv');
    WriteLn('  --short-cases FILE   Windows word_input_yhwd_context.tsv');
    WriteLn('  --neural-runtime DIR Enable the v1.19 conditional ONNX scorer');
    WriteLn('  --report-dir DIR     Summary/failure output directory');
    WriteLn('  --long-limit N       Limit long cases (0 means all)');
    WriteLn('  --short-limit N      Limit short cases (0 means all)');
    WriteLn('  --progress-every N   Progress interval (default: 1000)');
end;

function parse_options: TOptions;
var
    index: Integer;
    argument: string;
begin
    Result := Default(TOptions);
    Result.progress_every := 1000;
    index := 1;
    while index <= ParamCount do
    begin
        argument := ParamStr(index);
        if (argument = '--help') or (argument = '-h') then
        begin
            usage;
            Halt(0);
        end;
        if index = ParamCount then
            raise Exception.Create('missing value for ' + UTF8Encode(argument));
        Inc(index);
        if argument = '--dictionary' then
            Result.dictionary_path := ParamStr(index)
        else if argument = '--long-cases' then
            Result.long_cases_path := ParamStr(index)
        else if argument = '--short-cases' then
            Result.short_cases_path := ParamStr(index)
        else if argument = '--neural-runtime' then
            Result.neural_runtime_path := ParamStr(index)
        else if argument = '--report-dir' then
            Result.report_directory := ParamStr(index)
        else if argument = '--long-limit' then
            Result.long_limit := positive_integer(ParamStr(index), -1)
        else if argument = '--short-limit' then
            Result.short_limit := positive_integer(ParamStr(index), -1)
        else if argument = '--progress-every' then
            Result.progress_every := positive_integer(ParamStr(index), -1)
        else
            raise Exception.Create('unknown option: ' + UTF8Encode(argument));
        Inc(index);
    end;
    if Result.dictionary_path = '' then
        raise Exception.Create('--dictionary is required');
    if (Result.long_cases_path = '') and (Result.short_cases_path = '') then
        raise Exception.Create('at least one case file is required');
    if (Result.long_limit < 0) or (Result.short_limit < 0) or
        (Result.progress_every <= 0) then
        raise Exception.Create('limits must be non-negative and progress positive');
    if Result.report_directory = '' then
        Result.report_directory := GetCurrentDir;
end;

function canonicalize_benchmark_text(const value: string): string;
var
    index: Integer;
begin
    Result := value;
    for index := 1 to Length(Result) do
        if Result[index] = WideChar($5979) then
            Result[index] := WideChar($4ed6);
end;

function benchmark_texts_equivalent(const left_text, right_text: string): Boolean;
begin
    Result := canonicalize_benchmark_text(left_text) =
        canonicalize_benchmark_text(right_text);
end;

function parse_proc_status_kb(const line, field_name: string;
    out value: QWord): Boolean;
var
    payload: string;
    separator_index: Integer;
    end_index: Integer;
    parse_error: Integer;
begin
    value := 0;
    Result := False;
    if Pos(field_name + ':', line) <> 1 then
        Exit;
    separator_index := Pos(':', line);
    if separator_index <= 0 then
        Exit;
    payload := Trim(Copy(line, separator_index + 1, MaxInt));
    end_index := 1;
    while (end_index <= Length(payload)) and
        (payload[end_index] >= '0') and (payload[end_index] <= '9') do
        Inc(end_index);
    payload := Copy(payload, 1, end_index - 1);
    if payload = '' then
        Exit;
    Val(payload, value, parse_error);
    Result := parse_error = 0;
end;

function read_process_memory_kb(out rss_kb, hwm_kb: QWord): Boolean;
{$IFDEF LINUX}
var
    status_file: TextFile;
    line: string;
    parsed_value: QWord;
    have_rss: Boolean;
    have_hwm: Boolean;
{$ENDIF}
begin
    rss_kb := 0;
    hwm_kb := 0;
{$IFDEF LINUX}
    have_rss := False;
    have_hwm := False;
    AssignFile(status_file, '/proc/self/status');
    {$I-}
    Reset(status_file);
    {$I+}
    if IOResult <> 0 then
        Exit(False);
    try
        while not Eof(status_file) do
        begin
            ReadLn(status_file, line);
            if (not have_rss) and
                parse_proc_status_kb(line, 'VmRSS', parsed_value) then
            begin
                rss_kb := parsed_value;
                have_rss := True;
            end
            else if (not have_hwm) and
                parse_proc_status_kb(line, 'VmHWM', parsed_value) then
            begin
                hwm_kb := parsed_value;
                have_hwm := True;
            end;
            if have_rss and have_hwm then
                Break;
        end;
    finally
        CloseFile(status_file);
    end;
    Result := have_rss and have_hwm;
{$ELSE}
    Result := False;
{$ENDIF}
end;

procedure sample_process_memory(const track_name, case_name: string;
    var totals: TTrackTotals);
const
    c_resource_event_step_kb = 16 * 1024;
var
    rss_kb: QWord;
    hwm_kb: QWord;
begin
    if not read_process_memory_kb(rss_kb, hwm_kb) then
        Exit;
    if rss_kb > totals.peak_rss_kb then
        totals.peak_rss_kb := rss_kb;
    if hwm_kb > totals.peak_hwm_kb then
        totals.peak_hwm_kb := hwm_kb;
    if rss_kb > process_peak_rss_kb then
        process_peak_rss_kb := rss_kb;
    if hwm_kb > process_peak_hwm_kb then
    begin
        process_peak_hwm_kb := hwm_kb;
        process_peak_track := track_name;
        process_peak_case := case_name;
    end;
    if (resource_events <> nil) and
        ((last_reported_hwm_kb = 0) or
        (hwm_kb >= last_reported_hwm_kb + c_resource_event_step_kb)) then
    begin
        resource_events.WriteLine(track_name + #9 + case_name + #9 +
            UIntToStr(rss_kb) + #9 + UIntToStr(hwm_kb));
        last_reported_hwm_kb := hwm_kb;
    end;
end;

procedure append_latency(var totals: TTrackTotals; const value: QWord);
var
    new_capacity: Integer;
begin
    if totals.total >= Length(totals.latencies) then
    begin
        new_capacity := Length(totals.latencies) * 2;
        if new_capacity < 1024 then
            new_capacity := 1024;
        SetLength(totals.latencies, new_capacity);
    end;
    totals.latencies[totals.total] := value;
end;

procedure record_rank(var totals: TTrackTotals; const rank: Integer;
    const contested: Boolean; const elapsed_ms: QWord);
begin
    append_latency(totals, elapsed_ms);
    Inc(totals.total);
    Inc(totals.elapsed_ms, elapsed_ms);
    if rank = 1 then
        Inc(totals.top1);
    if (rank > 0) and (rank <= 2) then
        Inc(totals.top2);
    if (rank > 0) and (rank <= 5) then
        Inc(totals.top5);
    if (rank > 0) and (rank <= 9) then
        Inc(totals.top9);
    if contested then
    begin
        Inc(totals.contested_total);
        if rank = 1 then
            Inc(totals.contested_top1);
        if (rank > 0) and (rank <= 2) then
            Inc(totals.contested_top2);
    end;
end;

function candidate_rank(const candidates: TncCandidateList;
    const expected_text: string): Integer;
var
    index: Integer;
begin
    Result := 0;
    for index := 0 to High(candidates) do
        if (candidates[index].comment = '') and
            benchmark_texts_equivalent(Trim(candidates[index].text),
            expected_text) then
            Exit(index + 1);
end;

function create_benchmark_engine(const dictionary_path: string;
    const neural_runtime_path: string = '';
    const neural_result_timeout_ms: QWord =
    c_nc_pinyin_transformer_result_timeout_ms): TncEngine;
var
    config: TncEngineConfig;
    provider: TncSqliteDictionary;
    reranker: IncLongNeuralReranker;
    reranker_instance: TncPinyinTransformerHostReranker;
begin
    config := nc_default_engine_config;
    Result := TncEngine.Create(config, False, True, False);
    reranker := nil;
    reranker_instance := nil;
    provider := TncSqliteDictionary.Create(dictionary_path, '', False);
    try
        if not provider.open or not provider.base_ready then
            raise Exception.Create('dictionary open failed: ' + dictionary_path);
        Result.configure_dictionary_paths(dictionary_path, '', '');
        Result.adopt_ready_dictionary_provider(provider);
        provider := nil;
        if neural_runtime_path <> '' then
        begin
            reranker_instance := TncPinyinTransformerHostReranker.Create(
                neural_runtime_path, False, neural_result_timeout_ms);
            reranker := reranker_instance;
            if not reranker_instance.Ready then
                raise Exception.Create('neural runtime failed: ' +
                    reranker_instance.last_error);
            Result.set_long_neural_reranker(reranker);
        end;
    except
        reranker := nil;
        provider.Free;
        Result.Free;
        Result := nil;
        raise;
    end;
end;

function run_query(const engine: TncEngine; const query: string;
    const left_context: string; out candidates: TncCandidateList): QWord;
var
    started_at: QWord;
begin
    engine.reset;
    engine.set_external_left_context(left_context);
    started_at := nc_monotonic_tick_ms;
    engine.debug_set_composition_text(query);
    candidates := engine.get_candidates;
    Result := nc_monotonic_tick_ms - started_at;
end;

procedure quicksort_latencies(var values: TLatencyArray;
    const left_index, right_index: Integer);
var
    left_cursor: Integer;
    right_cursor: Integer;
    pivot: QWord;
    temporary: QWord;
begin
    left_cursor := left_index;
    right_cursor := right_index;
    pivot := values[left_index + ((right_index - left_index) div 2)];
    repeat
        while values[left_cursor] < pivot do
            Inc(left_cursor);
        while values[right_cursor] > pivot do
            Dec(right_cursor);
        if left_cursor <= right_cursor then
        begin
            temporary := values[left_cursor];
            values[left_cursor] := values[right_cursor];
            values[right_cursor] := temporary;
            Inc(left_cursor);
            Dec(right_cursor);
        end;
    until left_cursor > right_cursor;
    if left_index < right_cursor then
        quicksort_latencies(values, left_index, right_cursor);
    if left_cursor < right_index then
        quicksort_latencies(values, left_cursor, right_index);
end;

procedure sort_latencies(var values: TLatencyArray);
begin
    if Length(values) > 1 then
        quicksort_latencies(values, 0, High(values));
end;

function percentile(const totals: TTrackTotals; const percent: Integer): QWord;
var
    values: TLatencyArray;
    index: Integer;
begin
    if totals.total = 0 then
        Exit(0);
    values := Copy(totals.latencies, 0, totals.total);
    sort_latencies(values);
    index := ((Length(values) * percent) + 99) div 100 - 1;
    if index < 0 then
        index := 0;
    if index > High(values) then
        index := High(values);
    Result := values[index];
end;

procedure write_metric(const writer: TUTF8LineWriter; const key: string;
    const value: string);
begin
    writer.WriteLine(key + '=' + value);
    WriteLn(UTF8Encode(key), '=', UTF8Encode(value));
end;

procedure write_totals(const writer: TUTF8LineWriter; const prefix: string;
    const totals: TTrackTotals);
begin
    write_metric(writer, prefix + '.total', IntToStr(totals.total));
    write_metric(writer, prefix + '.top1', IntToStr(totals.top1));
    write_metric(writer, prefix + '.top2', IntToStr(totals.top2));
    write_metric(writer, prefix + '.top5', IntToStr(totals.top5));
    write_metric(writer, prefix + '.top9', IntToStr(totals.top9));
    if totals.contested_total > 0 then
    begin
        write_metric(writer, prefix + '.contested_total',
            IntToStr(totals.contested_total));
        write_metric(writer, prefix + '.contested_top1',
            IntToStr(totals.contested_top1));
        write_metric(writer, prefix + '.contested_top2',
            IntToStr(totals.contested_top2));
    end;
    if totals.total > 0 then
        write_metric(writer, prefix + '.mean_ms',
            FormatFloat('0.000', totals.elapsed_ms / totals.total));
    write_metric(writer, prefix + '.p50_ms', IntToStr(percentile(totals, 50)));
    write_metric(writer, prefix + '.p95_ms', IntToStr(percentile(totals, 95)));
    write_metric(writer, prefix + '.max_ms', IntToStr(percentile(totals, 100)));
    write_metric(writer, prefix + '.peak_rss_kb', UIntToStr(totals.peak_rss_kb));
    write_metric(writer, prefix + '.peak_hwm_kb', UIntToStr(totals.peak_hwm_kb));
end;

procedure run_long_suite(const options: TOptions; const writer: TUTF8LineWriter);
var
    content: string;
    cursor: Integer;
    line_number: Integer;
    fields: array[0..4] of string;
    line: string;
    accuracy_engine: TncEngine;
    latency_engine: TncEngine;
    candidates: TncCandidateList;
    elapsed_ms: QWord;
    rank: Integer;
    result_index: Integer;
    accuracy_results: TLongAccuracyResultArray;
    totals: TTrackTotals;
    failures: TUTF8LineWriter;
    latencies: TUTF8LineWriter;
begin
    content := read_utf8_file(options.long_cases_path);
    accuracy_results := nil;
    accuracy_engine := create_benchmark_engine(options.dictionary_path,
        options.neural_runtime_path, 0);
    accuracy_engine.debug_set_search_budget_policy(sbm_deterministic, 100);
    failures := TUTF8LineWriter.Create(
        IncludeTrailingPathDelimiter(options.report_directory) +
        'long-failures.tsv');
    latencies := TUTF8LineWriter.Create(
        IncludeTrailingPathDelimiter(options.report_directory) +
        'long-latencies.tsv');
    try
        failures.WriteLine('index'#9'expected'#9'pinyin'#9'rank'#9'top1'#9'latency_ms');
        latencies.WriteLine('index'#9'expected'#9'pinyin'#9'rank'#9'top1'#9'latency_ms');
        totals := Default(TTrackTotals);
        SetLength(accuracy_results, 0);
        cursor := 1;
        line_number := 0;
        while next_line(content, cursor, line) do
        begin
            Inc(line_number);
            if (line_number = 1) or (Trim(line) = '') then
                Continue;
            if split_tabs(line, fields) < 5 then
                raise Exception.CreateFmt('invalid long case at line %d',
                    [line_number]);
            current_track := 'long.accuracy';
            current_case := fields[0];
            current_query := fields[4];
            run_query(accuracy_engine, LowerCase(Trim(fields[4])), '',
                candidates);
            sample_process_memory(current_track, current_case, totals);
            rank := candidate_rank(candidates, Trim(fields[3]));
            record_rank(totals, rank, False, 0);
            result_index := Length(accuracy_results);
            SetLength(accuracy_results, result_index + 1);
            accuracy_results[result_index].case_index := fields[0];
            accuracy_results[result_index].expected_text := fields[3];
            accuracy_results[result_index].pinyin := fields[4];
            accuracy_results[result_index].rank := rank;
            accuracy_results[result_index].top1_text :=
                IfThen(Length(candidates) > 0, candidates[0].text, '');
            if (totals.total mod options.progress_every) = 0 then
                WriteLn('progress.long.accuracy=', totals.total);
            if (options.long_limit > 0) and
                (totals.total >= options.long_limit) then
                Break;
        end;
        accuracy_engine.Free;
        accuracy_engine := nil;

        latency_engine := create_benchmark_engine(options.dictionary_path,
            options.neural_runtime_path);
        try
            latency_engine.debug_set_search_budget_policy(sbm_production, 100);
            for result_index := 0 to High(accuracy_results) do
            begin
                current_track := 'long.latency';
                current_case := accuracy_results[result_index].case_index;
                current_query := accuracy_results[result_index].pinyin;
                elapsed_ms := run_query(latency_engine,
                    LowerCase(Trim(current_query)), '', candidates);
                sample_process_memory(current_track, current_case, totals);
                totals.latencies[result_index] := elapsed_ms;
                Inc(totals.elapsed_ms, elapsed_ms);
                latencies.WriteLine(accuracy_results[result_index].case_index +
                    #9 + accuracy_results[result_index].expected_text + #9 +
                    accuracy_results[result_index].pinyin + #9 +
                    IntToStr(accuracy_results[result_index].rank) + #9 +
                    accuracy_results[result_index].top1_text + #9 +
                    IntToStr(elapsed_ms));
                if accuracy_results[result_index].rank <> 1 then
                    failures.WriteLine(
                        accuracy_results[result_index].case_index + #9 +
                        accuracy_results[result_index].expected_text + #9 +
                        accuracy_results[result_index].pinyin + #9 +
                        IntToStr(accuracy_results[result_index].rank) + #9 +
                        accuracy_results[result_index].top1_text + #9 +
                        IntToStr(elapsed_ms));
                if ((result_index + 1) mod options.progress_every) = 0 then
                    WriteLn('progress.long.latency=', result_index + 1);
            end;
        finally
            latency_engine.Free;
        end;
        write_metric(writer, 'long.accuracy_mode', 'deterministic');
        write_metric(writer, 'long.accuracy_neural_timeout_ms', '0');
        write_metric(writer, 'long.latency_mode', 'production');
        write_metric(writer, 'long.latency_neural_timeout_ms',
            IntToStr(c_nc_pinyin_transformer_result_timeout_ms));
        write_totals(writer, 'long', totals);
    finally
        latencies.Free;
        failures.Free;
        accuracy_engine.Free;
    end;
end;

procedure run_short_suite(const options: TOptions; const writer: TUTF8LineWriter);
var
    content: string;
    cursor: Integer;
    line_number: Integer;
    fields: array[0..16] of string;
    line: string;
    engine_off: TncEngine;
    engine_on: TncEngine;
    candidates_off: TncCandidateList;
    candidates_on: TncCandidateList;
    elapsed_ms: QWord;
    rank_off: Integer;
    rank_on: Integer;
    ambiguity: Integer;
    contested: Boolean;
    totals_off: TTrackTotals;
    totals_on: TTrackTotals;
    failures: TUTF8LineWriter;
begin
    content := read_utf8_file(options.short_cases_path);
    engine_off := create_benchmark_engine(options.dictionary_path);
    engine_on := create_benchmark_engine(options.dictionary_path);
    failures := TUTF8LineWriter.Create(
        IncludeTrailingPathDelimiter(options.report_directory) +
        'short-failures.tsv');
    try
        failures.WriteLine('index'#9'mode'#9'expected'#9'pinyin'#9'rank'#9'top1'#9'latency_ms');
        totals_off := Default(TTrackTotals);
        totals_on := Default(TTrackTotals);
        cursor := 1;
        line_number := 0;
        while next_line(content, cursor, line) do
        begin
            Inc(line_number);
            if (line_number = 1) or (Trim(line) = '') then
                Continue;
            if split_tabs(line, fields) < 17 then
                raise Exception.CreateFmt('invalid short case at line %d',
                    [line_number]);
            ambiguity := positive_integer(fields[12], 1);
            contested := ambiguity > 1;
            current_track := 'short.off';
            current_case := fields[0];
            current_query := fields[5];
            elapsed_ms := run_query(engine_off, LowerCase(Trim(fields[5])), '',
                candidates_off);
            sample_process_memory(current_track, current_case, totals_off);
            rank_off := candidate_rank(candidates_off, Trim(fields[3]));
            record_rank(totals_off, rank_off, contested, elapsed_ms);
            if rank_off <> 1 then
                failures.WriteLine(fields[0] + #9 + 'off' + #9 +
                    fields[3] + #9 + fields[5] + #9 + IntToStr(rank_off) + #9 +
                    IfThen(Length(candidates_off) > 0,
                        candidates_off[0].text, '') + #9 +
                    IntToStr(elapsed_ms));

            current_track := 'short.on';
            elapsed_ms := run_query(engine_on, LowerCase(Trim(fields[5])),
                Trim(fields[14]), candidates_on);
            sample_process_memory(current_track, current_case, totals_on);
            rank_on := candidate_rank(candidates_on, Trim(fields[3]));
            record_rank(totals_on, rank_on, contested, elapsed_ms);
            if rank_on <> 1 then
                failures.WriteLine(fields[0] + #9 + 'on' + #9 +
                    fields[3] + #9 + fields[5] + #9 + IntToStr(rank_on) + #9 +
                    IfThen(Length(candidates_on) > 0,
                        candidates_on[0].text, '') + #9 +
                    IntToStr(elapsed_ms));
            if (totals_off.total mod options.progress_every) = 0 then
                WriteLn('progress.short=', totals_off.total);
            if (options.short_limit > 0) and
                (totals_off.total >= options.short_limit) then
                Break;
        end;
        write_totals(writer, 'short.off', totals_off);
        write_totals(writer, 'short.on', totals_on);
    finally
        failures.Free;
        engine_on.Free;
        engine_off.Free;
    end;
end;

var
    options: TOptions;
    summary_writer: TUTF8LineWriter;
    summary_path: string;
    resource_events_path: string;

begin
    try
        options := parse_options;
        if not DirectoryExists(options.report_directory) and
            not ForceDirectories(options.report_directory) then
            raise Exception.Create('unable to create report directory');
        summary_path := IncludeTrailingPathDelimiter(options.report_directory) +
            'quality-summary.txt';
        summary_writer := TUTF8LineWriter.Create(summary_path);
        try
            resource_events_path := IncludeTrailingPathDelimiter(
                options.report_directory) + 'resource-events.tsv';
                resource_events := TUTF8LineWriter.Create(resource_events_path);
            try
                resource_events.WriteLine(
                    'track'#9'case'#9'vm_rss_kb'#9'vm_hwm_kb');
                write_metric(summary_writer, 'format', 'cassotis-quality-v1');
                if options.neural_runtime_path = '' then
                    write_metric(summary_writer, 'long.neural_runtime',
                        'disabled')
                else
                    write_metric(summary_writer, 'long.neural_runtime',
                        'enabled');
                if options.long_cases_path <> '' then
                    run_long_suite(options, summary_writer);
                if options.short_cases_path <> '' then
                    run_short_suite(options, summary_writer);
                write_metric(summary_writer, 'process.max_rss_kb',
                    UIntToStr(process_peak_rss_kb));
                write_metric(summary_writer, 'process.max_hwm_kb',
                    UIntToStr(process_peak_hwm_kb));
                write_metric(summary_writer, 'process.peak_track',
                    process_peak_track);
                write_metric(summary_writer, 'process.peak_case',
                    process_peak_case);
            finally
                resource_events.Free;
                resource_events := nil;
            end;
        finally
            summary_writer.Free;
        end;
        WriteLn('report=', UTF8Encode(summary_path));
    except
        on error: Exception do
        begin
            WriteLn(StdErr, error.Message);
            WriteLn(StdErr, 'benchmark.track=', UTF8Encode(current_track));
            WriteLn(StdErr, 'benchmark.case=', UTF8Encode(current_case));
            WriteLn(StdErr, 'benchmark.query=', UTF8Encode(current_query));
            DumpExceptionBackTrace(StdErr);
            Halt(1);
        end;
    end;
end.
