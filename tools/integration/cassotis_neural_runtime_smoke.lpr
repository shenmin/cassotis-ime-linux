program cassotis_neural_runtime_smoke;

{$codepage utf8}
{$mode delphiunicode}
{$H+}
{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

uses
    {$ifdef UNIX}
    cthreads,
    {$endif}
    SysUtils,
    Classes,
    nc_pinyin_transformer_host,
    nc_local_completion_host;

const
    c_runtime_timeout_ms = 30000;

var
    base_directory: string;
    deadline: QWord;
    reranker: TncPinyinTransformerHostReranker;
    completion_host: TncLocalCompletionHost;

begin
    if ParamCount > 0 then
        base_directory := ExpandFileName(ParamStr(1))
    else
        base_directory := ExtractFileDir(ParamStr(0));

    reranker := TncPinyinTransformerHostReranker.Create(base_directory, True);
    try
        if not reranker.wait_until_ready(c_runtime_timeout_ms) then
            raise Exception.Create('pinyin Transformer runtime unavailable: ' +
                reranker.last_error);
        WriteLn('pinyin_transformer=ready');
    finally
        reranker.Free;
    end;

    completion_host := TncLocalCompletionHost.Create(base_directory);
    try
        deadline := GetTickCount64 + c_runtime_timeout_ms;
        while (not completion_host.LoadFinished) and
            (GetTickCount64 < deadline) do
            Sleep(10);
        if not completion_host.Ready then
            raise Exception.Create('local completion runtime unavailable: ' +
                completion_host.LastError);
        WriteLn('local_completion=ready');
    finally
        completion_host.Free;
    end;
end.
