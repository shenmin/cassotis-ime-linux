program cassotis_parser_benchmark;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

uses
{$IFDEF UNIX}
    cwstring,
{$ENDIF}
    SysUtils,
    nc_pinyin_parser;

const
    c_default_iterations = 20000;
    c_samples: array[0..11] of string = (
        'nihao',
        'zhuyianquan',
        'youyayuailisidedaodexiansuo',
        'youdiangenggengyuhuai',
        'feichang''e',
        'pingweneryueer',
        'anjingerxianghe',
        'yuanxianwaiwen',
        'quangao',
        'pinduoduo',
        'youxiangdizhi',
        'gengxinhaole'
    );

var
    parser: TncPinyinParser;
    result_data: TncPinyinParseResult;
    iteration: Integer;
    sample_index: Integer;
    token_index: Integer;
    iterations: Integer;
    parse_error: Integer;
    parse_count: QWord;
    checksum: QWord;
    started_at: QWord;
    elapsed_ms: QWord;
    parses_per_second: Double;
begin
    iterations := c_default_iterations;
    if ParamCount > 1 then
    begin
        WriteLn(StdErr, 'Usage: cassotis-parser-benchmark [iterations]');
        Halt(2);
    end;
    if ParamCount = 1 then
    begin
        Val(ParamStr(1), iterations, parse_error);
        if parse_error <> 0 then
            iterations := 0;
    end;
    if iterations <= 0 then
    begin
        WriteLn(StdErr, 'iterations must be a positive integer');
        Halt(2);
    end;
    checksum := 0;
    parser := TncPinyinParser.Create;
    try
        started_at := GetTickCount64;
        for iteration := 1 to iterations do
            for sample_index := Low(c_samples) to High(c_samples) do
            begin
                result_data := parser.Parse(c_samples[sample_index]);
                Inc(checksum, QWord(Length(result_data)));
                for token_index := 0 to High(result_data) do
                    Inc(checksum, QWord(result_data[token_index].length));
            end;
        elapsed_ms := GetTickCount64 - started_at;
    finally
        parser.Free;
    end;
    parse_count := QWord(iterations) * QWord(Length(c_samples));
    if elapsed_ms = 0 then
        parses_per_second := 0
    else
        parses_per_second := parse_count * 1000.0 / elapsed_ms;
    WriteLn('iterations=', iterations);
    WriteLn('parses=', parse_count);
    WriteLn('elapsed_ms=', elapsed_ms);
    WriteLn('parses_per_second=', FormatFloat('0.00', parses_per_second));
    WriteLn('checksum=', checksum);
end.
