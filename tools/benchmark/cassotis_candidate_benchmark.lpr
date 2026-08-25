program cassotis_candidate_benchmark;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

uses
{$IFDEF UNIX}
    cwstring,
{$ENDIF}
    SysUtils,
    nc_types,
    nc_engine_service;

const
    c_queries: array[0..11] of string = (
        'shi',
        'zhehui',
        'hha',
        'elm',
        'pinduoduo',
        'youxiangdizhi',
        'kaishichifan',
        'gengxinhaole',
        'womenzaichifan',
        'duidesshang',
        'jslksdfj',
        'youyayuailisidedaodexiansuo'
    );

type
    TLatencyList = array of QWord;

function positive_integer(const value: string;
    const fallback: Integer): Integer;
var
    parse_error: Integer;
begin
    Val(value, Result, parse_error);
    if (parse_error <> 0) or (Result <= 0) then
        Result := fallback;
end;

function letter_event(const value: WideChar;
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

procedure sort_latencies(var values: TLatencyList);
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

function percentile_index(const count: Integer;
    const numerator: Integer): Integer;
begin
    Result := ((count * numerator) + 99) div 100 - 1;
    if Result < 0 then
        Result := 0;
    if Result >= count then
        Result := count - 1;
end;

procedure run_benchmark(const database_path: string;
    const iterations: Integer);
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    latencies: TLatencyList;
    sorted_latencies: TLatencyList;
    iteration: Integer;
    query_index: Integer;
    input_index: Integer;
    sample_index: Integer;
    key_count: QWord;
    generation: QWord;
    started_at: QWord;
    elapsed: QWord;
    total_elapsed: QWord;
    checksum: QWord;
begin
    latencies := nil;
    sorted_latencies := nil;
    service := TncEngineService.Create(database_path);
    try
        if not service.DictionaryReady then
            raise Exception.Create(UTF8Encode('dictionary open failed: ' +
                service.DictionaryError));
        if not service.CreateContext(1) then
            raise Exception.Create('unable to create benchmark context');
        SetLength(latencies, iterations * Length(c_queries));
        generation := 0;
        key_count := 0;
        total_elapsed := 0;
        checksum := 0;
        sample_index := 0;
        for iteration := 1 to iterations do
            for query_index := Low(c_queries) to High(c_queries) do
            begin
                Inc(generation);
                if not service.ResetContext(1, generation) then
                    raise Exception.Create('unable to reset benchmark context');
                started_at := GetTickCount64;
                for input_index := 1 to Length(c_queries[query_index]) do
                begin
                    Inc(generation);
                    engine_result := service.ProcessKey(1, generation,
                        letter_event(c_queries[query_index][input_index],
                        generation));
                    if engine_result.error_code <> 0 then
                        raise Exception.CreateFmt('query %s failed: %s',
                            [c_queries[query_index], engine_result.error_text]);
                    Inc(key_count);
                end;
                elapsed := GetTickCount64 - started_at;
                latencies[sample_index] := elapsed;
                Inc(sample_index);
                Inc(total_elapsed, elapsed);
                if Length(engine_result.candidates) > 0 then
                    Inc(checksum, Length(engine_result.candidates[0].text));
            end;
        sorted_latencies := Copy(latencies, 0, Length(latencies));
        sort_latencies(sorted_latencies);
        WriteLn('queries=', Length(latencies));
        WriteLn('keys=', key_count);
        WriteLn('mean_query_ms=', total_elapsed / Length(latencies):0:3);
        WriteLn('mean_key_ms=', total_elapsed / key_count:0:3);
        WriteLn('p50_query_ms=', sorted_latencies[
            percentile_index(Length(sorted_latencies), 50)]);
        WriteLn('p95_query_ms=', sorted_latencies[
            percentile_index(Length(sorted_latencies), 95)]);
        WriteLn('max_query_ms=', sorted_latencies[High(sorted_latencies)]);
        WriteLn('checksum=', checksum);
    finally
        service.Free;
    end;
end;

var
    iterations: Integer;

begin
    if (ParamCount < 1) or (ParamCount > 2) then
    begin
        WriteLn(StdErr,
            'Usage: cassotis-candidate-benchmark DICTIONARY [ITERATIONS]');
        Halt(2);
    end;
    if ParamCount = 2 then
        iterations := positive_integer(ParamStr(2), 100)
    else
        iterations := 100;
    try
        run_benchmark(ParamStr(1), iterations);
    except
        on error: Exception do
        begin
            WriteLn(StdErr, error.Message);
            Halt(1);
        end;
    end;
end.
