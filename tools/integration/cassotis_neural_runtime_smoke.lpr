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
    nc_engine_intf,
    nc_pinyin_transformer_host,
    nc_local_completion_host;

const
    c_runtime_timeout_ms = 30000;

var
    base_directory: string;
    deadline: QWord;
    reranker: TncPinyinTransformerHostReranker;
    completion_host: TncLocalCompletionHost;
    generated_candidates: TncLongGeneratedCandidateArray;
    candidate_index: Integer;

begin
    if ParamCount > 0 then
        base_directory := ExpandFileName(ParamStr(1))
    else
        base_directory := ExtractFileDir(ParamStr(0));

    { Runtime availability must not depend on the production wall-clock budget;
      latency is release-gated by the separate corpus benchmarks. }
    reranker := TncPinyinTransformerHostReranker.Create(
        base_directory, True, 0);
    try
        if not reranker.wait_until_ready(c_runtime_timeout_ms) then
            raise Exception.Create('pinyin Transformer runtime unavailable: ' +
                reranker.last_error);
        WriteLn('pinyin_transformer=ready');
        if not reranker.try_generate(
            'wo''xiang''liao''jie''yi''xia', generated_candidates) then
            raise Exception.Create('pinyin parallel generator returned no candidates');
        if (Length(generated_candidates) < 1) or
            (Length(generated_candidates) > 4) then
            raise Exception.Create('pinyin parallel generator returned an invalid count');
        for candidate_index := 0 to High(generated_candidates) do
        begin
            if Length(UTF8Decode(UTF8String(
                generated_candidates[candidate_index].text))) <> 6 then
                raise Exception.CreateFmt(
                    'pinyin parallel generator returned an invalid length: ' +
                    'candidate=%d codepoints=%d bytes=%d text=%s',
                    [candidate_index + 1,
                    Length(UTF8Decode(UTF8String(
                        generated_candidates[candidate_index].text))),
                    Length(generated_candidates[candidate_index].text),
                    generated_candidates[candidate_index].text]);
            if generated_candidates[candidate_index].rank <> candidate_index + 1 then
                raise Exception.Create('pinyin parallel generator returned an invalid rank');
        end;
        WriteLn('pinyin_generator=ready candidates=',
            Length(generated_candidates));
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
        if not completion_host.GeneratorReady then
            raise Exception.Create('local completion generator unavailable');
        WriteLn('local_completion_generator=ready');
    finally
        completion_host.Free;
    end;
end.
