program cassotis_dictionary_benchmark;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

uses
{$IFDEF UNIX}
    cwstring,
{$ENDIF}
    SysUtils,
    nc_dictionary_reader;

const
    c_default_iterations = 1000;
    c_queries: array[0..11] of string = (
        'nihao',
        'shijie',
        'zhongguo',
        'shurufa',
        'youxiangdizhi',
        'gengxinhaole',
        'kaishichifan',
        'pinduoduo',
        'weishenme',
        'zheshi',
        'quanzhong',
        'fo'
    );

var
    reader: TncDictionaryReader;
    entries: TncRawDictionaryEntries;
    iteration: Integer;
    query_index: Integer;
    entry_index: Integer;
    iterations: Integer;
    parse_error: Integer;
    query_count: QWord;
    checksum: QWord;
    started_at: QWord;
    elapsed_ms: QWord;
    queries_per_second: Double;
begin
    if (ParamCount < 1) or (ParamCount > 2) then
    begin
        WriteLn(StdErr,
            'Usage: cassotis-dictionary-benchmark DB_PATH [iterations]');
        Halt(2);
    end;
    iterations := c_default_iterations;
    if ParamCount = 2 then
    begin
        Val(ParamStr(2), iterations, parse_error);
        if parse_error <> 0 then
            iterations := 0;
    end;
    if iterations <= 0 then
    begin
        WriteLn(StdErr, 'iterations must be a positive integer');
        Halt(2);
    end;

    reader := TncDictionaryReader.Create(ParamStr(1));
    try
        if not reader.Open then
        begin
            WriteLn(StdErr, reader.ErrorMessage);
            Halt(1);
        end;
        checksum := 0;
        started_at := GetTickCount64;
        for iteration := 1 to iterations do
            for query_index := Low(c_queries) to High(c_queries) do
            begin
                if not reader.QueryExact(c_queries[query_index], 16, entries) then
                begin
                    WriteLn(StdErr, reader.ErrorMessage);
                    Halt(1);
                end;
                Inc(checksum, QWord(Length(entries)));
                for entry_index := 0 to High(entries) do
                    Inc(checksum, QWord(entries[entry_index].weight));
            end;
        elapsed_ms := GetTickCount64 - started_at;
    finally
        reader.Free;
    end;

    query_count := QWord(iterations) * QWord(Length(c_queries));
    if elapsed_ms = 0 then
        queries_per_second := 0
    else
        queries_per_second := query_count * 1000.0 / elapsed_ms;
    WriteLn('iterations=', iterations);
    WriteLn('queries=', query_count);
    WriteLn('elapsed_ms=', elapsed_ms);
    WriteLn('queries_per_second=', FormatFloat('0.00', queries_per_second));
    WriteLn('checksum=', checksum);
end.
