program cassotis_shuangpin_benchmark;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

uses
{$IFDEF UNIX}
    cwstring,
{$ENDIF}
    SysUtils,
    nc_types,
    nc_shuangpin_decoder;

const
    c_default_iterations = 20000;
    c_schemes: array[0..5] of TncPinyinInputScheme = (
        pis_microsoft_shuangpin,
        pis_xiaohe_shuangpin,
        pis_ziranma_shuangpin,
        pis_sogou_shuangpin,
        pis_ziguang_shuangpin,
        pis_pinyinjiajia_shuangpin
    );
    c_samples: array[0..7] of string = (
        'nihk',
        'womf',
        'qkssuuru',
        'vs',
        'xian',
        'lo',
        'oo',
        'q;'
    );

var
    decoded: TncShuangpinDecodeResult;
    iteration: Integer;
    scheme_index: Integer;
    sample_index: Integer;
    iterations: Integer;
    parse_error: Integer;
    decode_count: QWord;
    checksum: QWord;
    started_at: QWord;
    elapsed_ms: QWord;
    decodes_per_second: Double;
begin
    iterations := c_default_iterations;
    if ParamCount > 1 then
    begin
        WriteLn(StdErr, 'Usage: cassotis-shuangpin-benchmark [iterations]');
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
    started_at := GetTickCount64;
    for iteration := 1 to iterations do
        for scheme_index := Low(c_schemes) to High(c_schemes) do
            for sample_index := Low(c_samples) to High(c_samples) do
            begin
                decoded := nc_decode_shuangpin(c_schemes[scheme_index],
                    c_samples[sample_index]);
                Inc(checksum, QWord(Length(decoded.units)));
                Inc(checksum, QWord(Length(decoded.compact_pinyin)));
                if decoded.valid then
                    Inc(checksum);
            end;
    elapsed_ms := GetTickCount64 - started_at;
    decode_count := QWord(iterations) * QWord(Length(c_schemes)) *
        QWord(Length(c_samples));
    if elapsed_ms = 0 then
        decodes_per_second := 0
    else
        decodes_per_second := decode_count * 1000.0 / elapsed_ms;

    WriteLn('schemes=', Length(c_schemes));
    WriteLn('iterations=', iterations);
    WriteLn('decodes=', decode_count);
    WriteLn('elapsed_ms=', elapsed_ms);
    WriteLn('decodes_per_second=', FormatFloat('0.00', decodes_per_second));
    WriteLn('checksum=', checksum);
end.
