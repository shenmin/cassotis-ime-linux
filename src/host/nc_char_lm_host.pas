unit nc_char_lm_host;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Classes, SyncObjs, Dynlibs, nc_char_lm;

const
    c_nc_char_lm_background_timeout_ms = 120;

type
    TncCharLmHost = class;
    TncCharLmLoader = class(TThread)
    private
        FOwner: TncCharLmHost;
    protected
        procedure Execute; override;
    public
        constructor Create(const owner: TncCharLmHost);
    end;

    TncCharLmHost = class(TInterfacedObject, IncCharLm, IncCharLmNext)
    private type
        TCreateModel = function(directory: PWideChar; intra_threads: Integer;
            error_text: PWideChar; capacity: Integer): Pointer; cdecl;
        TScoreTexts = function(handle: Pointer; context: PWideChar; texts: PPWideChar;
            count, min_count, max_nodes: Integer; out_logp: PSingle; timeout_ms: Integer;
            error_text: PWideChar; capacity: Integer): Integer; cdecl;
        TScoreTextsNext = function(handle: Pointer; context: PWideChar; texts: PPWideChar;
            count, min_count, max_nodes: Integer; out_logp: PSingle; next_indices: PInteger;
            next_count, top_k: Integer; out_next_code_points: PCardinal; out_next_logp: PSingle;
            timeout_ms: Integer; error_text: PWideChar; capacity: Integer): Integer; cdecl;
        TDestroyModel = procedure(handle: Pointer); cdecl;
    private
        m_directory, m_error: string;
        m_threads, m_timeout_ms: Integer;
        m_loader: TncCharLmLoader;
        m_signal: TEvent;
        m_ready, m_stopping, m_foreground_waiting: LongInt;
        m_module: TLibHandle;
        m_handle: Pointer;
        m_score: TScoreTexts;
        m_score_next: TScoreTextsNext;
        m_destroy: TDestroyModel;
        m_gate: TCriticalSection;
        procedure load;
        function enter_gate(const background: Boolean): Boolean;
        function run_score(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
            const top_k, timeout_ms: Integer; out logp: TArray<Single>; out next_chars: TArray<string>;
            out next_logp: TArray<Single>): Integer;
    public
        constructor Create(const directory: string; background: Boolean;
            intra_threads: Integer = 4; timeout_ms: Integer = 100);
        destructor Destroy; override;
        function char_lm_ready: Boolean;
        function score_texts(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; out logp: TArray<Single>): Integer;
        function score_texts_next(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
            const top_k: Integer; out logp: TArray<Single>; out next_chars: TArray<string>;
            out next_logp: TArray<Single>): Integer;
        function score_texts_next_background(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
            const top_k, timeout_ms: Integer; out logp: TArray<Single>; out next_chars: TArray<string>;
            out next_logp: TArray<Single>): Integer;
        function background_view(
            const timeout_ms: Integer = c_nc_char_lm_background_timeout_ms): IncCharLm;
        property last_error: string read m_error;
    end;

implementation

uses fpjson, nc_model_assets;

const
    c_foreground_wait_ms = 60;

type
    TncCharLmBackgroundView = class(TInterfacedObject, IncCharLm, IncCharLmNext)
    private
        m_host: TncCharLmHost;
        m_keep: IncCharLm;
        m_timeout_ms: Integer;
    public
        constructor Create(const host: TncCharLmHost; const timeout_ms: Integer);
        function char_lm_ready: Boolean;
        function score_texts(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; out logp: TArray<Single>): Integer;
        function score_texts_next(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
            const top_k: Integer; out logp: TArray<Single>; out next_chars: TArray<string>;
            out next_logp: TArray<Single>): Integer;
    end;

constructor TncCharLmBackgroundView.Create(const host: TncCharLmHost;
    const timeout_ms: Integer);
begin
    inherited Create;
    m_host := host;
    m_keep := host;
    m_timeout_ms := timeout_ms;
end;

function TncCharLmBackgroundView.char_lm_ready: Boolean;
begin
    Result := m_host.char_lm_ready;
end;

function TncCharLmBackgroundView.score_texts(const context: string;
    const texts: TArray<string>; const min_count, max_nodes: Integer;
    out logp: TArray<Single>): Integer;
var next_chars: TArray<string>; next_logp: TArray<Single>;
begin
    Result := score_texts_next(context, texts, min_count, max_nodes, nil, 0,
        logp, next_chars, next_logp);
end;

function TncCharLmBackgroundView.score_texts_next(const context: string;
    const texts: TArray<string>; const min_count, max_nodes: Integer;
    const next_texts: TArray<Integer>; const top_k: Integer; out logp: TArray<Single>;
    out next_chars: TArray<string>; out next_logp: TArray<Single>): Integer;
begin
    Result := m_host.score_texts_next_background(context, texts, min_count, max_nodes,
        next_texts, top_k, m_timeout_ms, logp, next_chars, next_logp);
end;

constructor TncCharLmLoader.Create(const owner: TncCharLmHost);
begin
    inherited Create(True);
    FreeOnTerminate := False;
    FOwner := owner;
end;

procedure TncCharLmLoader.Execute;
begin
    FOwner.m_signal.WaitFor(INFINITE);
    if InterlockedCompareExchange(FOwner.m_stopping, 0, 0) = 0 then FOwner.load;
end;

constructor TncCharLmHost.Create(const directory: string; background: Boolean;
    intra_threads: Integer; timeout_ms: Integer);
begin
    inherited Create;
    m_directory := ExpandFileName(directory);
    m_threads := intra_threads;
    m_timeout_ms := timeout_ms;
    m_gate := TCriticalSection.Create;
    m_signal := TEvent.Create(nil, True, False, '');
    if background then
    begin
        // Do not load or hash model assets on the first key's foreground path.
        m_loader := TncCharLmLoader.Create(Self);
        m_loader.Priority := tpLower;
        m_loader.Start;
    end
    else load;
end;

destructor TncCharLmHost.Destroy;
begin
    InterlockedExchange(m_stopping, 1);
    if m_signal <> nil then m_signal.SetEvent;
    if m_loader <> nil then begin m_loader.WaitFor; m_loader.Free; end;
    if Assigned(m_destroy) and (m_handle <> nil) then m_destroy(m_handle);
    if m_module <> NilHandle then UnloadLibrary(m_module);
    m_signal.Free;
    m_gate.Free;
    inherited;
end;

procedure TncCharLmHost.load;
const required_files: array[0..1] of string = ('char_lm.onnx', 'char_lm_vocab.bin');
var
    manifest, files: TJSONObject;
    folder, name: string;
    value: TJSONData;
    create_model: TCreateModel;
    error_text: array[0..1023] of WideChar;
begin
    manifest := nil;
    try
      try
        folder := IncludeTrailingPathDelimiter(m_directory) + 'char_lm';
        manifest := read_model_manifest(IncludeTrailingPathDelimiter(folder) + 'runtime_manifest.json');
        if manifest.Get('format', 0) <> 1 then
            raise Exception.Create('Unsupported character LM manifest');
        value := manifest.Find('files');
        if not (value is TJSONObject) then raise Exception.Create('Missing character LM assets');
        files := TJSONObject(value);
        if files.Count <> Length(required_files) then
            raise Exception.Create('Incomplete character LM manifest');
        for name in required_files do
        begin
            if InterlockedCompareExchange(m_stopping, 0, 0) <> 0 then Exit;
            value := files.Find(UTF8Encode(name));
            if not (value is TJSONString) then raise Exception.Create('Missing character LM asset hash');
            if not model_file_matches_hash(IncludeTrailingPathDelimiter(folder) + name,
                UTF8Decode(value.AsString)) then
                raise Exception.Create(UTF8Encode('Character LM asset hash mismatch: ' + name));
        end;
        validate_external_model_files(folder, manifest, ['char_lm.onnx']);
        if InterlockedCompareExchange(m_stopping, 0, 0) <> 0 then Exit;
        m_module := LoadLibrary(UTF8Encode(IncludeTrailingPathDelimiter(m_directory) +
            'libcassotis_pinyin_transformer_ort.so'));
        if m_module = NilHandle then raise Exception.Create('Character LM runtime unavailable');
        create_model := TCreateModel(GetProcedureAddress(m_module, 'nc_lm_create'));
        m_score := TScoreTexts(GetProcedureAddress(m_module, 'nc_lm_score'));
        m_score_next := TScoreTextsNext(GetProcedureAddress(m_module, 'nc_lm_score_next'));
        m_destroy := TDestroyModel(GetProcedureAddress(m_module, 'nc_lm_destroy'));
        if not Assigned(create_model) or not Assigned(m_score) or
            not Assigned(m_score_next) or not Assigned(m_destroy) then
            raise Exception.Create('Character LM runtime must be rebuilt');
        error_text[0] := #0;
        m_handle := create_model(PWideChar(folder), m_threads, @error_text[0], Length(error_text));
        if m_handle = nil then raise Exception.Create(UTF8Encode(UnicodeString(PWideChar(@error_text[0]))));
        InterlockedExchange(m_ready, 1);
        WriteLn(StdErr, '[INFO] shared character LM loaded in host process');
      except
        on E: Exception do
        begin
            m_error := UTF8Decode(E.Message);
            WriteLn(StdErr, '[WARN] shared character LM unavailable: ', E.Message);
        end;
      end;
    finally
        manifest.Free;
    end;
end;

function TncCharLmHost.char_lm_ready: Boolean;
begin
    Result := InterlockedCompareExchange(m_ready, 0, 0) = 1;
    if not Result then m_signal.SetEvent;
end;

function TncCharLmHost.enter_gate(const background: Boolean): Boolean;
var started: QWord;
begin
    Result := False;
    started := GetTickCount64;
    if not background then InterlockedIncrement(m_foreground_waiting);
    try
        repeat
            if InterlockedCompareExchange(m_stopping, 0, 0) <> 0 then Exit;
            if (not background) or (InterlockedCompareExchange(m_foreground_waiting, 0, 0) = 0) then
                if m_gate.TryEnter then Exit(True);
            if (not background) and (GetTickCount64 - started >= c_foreground_wait_ms) then Exit;
            Sleep(1);
        until False;
    finally
        if not background then InterlockedDecrement(m_foreground_waiting);
    end;
end;

function TncCharLmHost.score_texts(const context: string; const texts: TArray<string>;
    const min_count, max_nodes: Integer; out logp: TArray<Single>): Integer;
var next_chars: TArray<string>; next_logp: TArray<Single>;
begin
    Result := score_texts_next(context, texts, min_count, max_nodes, nil, 0,
        logp, next_chars, next_logp);
end;

function TncCharLmHost.score_texts_next(const context: string; const texts: TArray<string>;
    const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
    const top_k: Integer; out logp: TArray<Single>; out next_chars: TArray<string>;
    out next_logp: TArray<Single>): Integer;
begin
    Result := -1;
    logp := nil;
    next_chars := nil;
    next_logp := nil;
    if not char_lm_ready then Exit;
    if not enter_gate(False) then Exit;
    try
        Result := run_score(context, texts, min_count, max_nodes, next_texts, top_k,
            m_timeout_ms, logp, next_chars, next_logp);
    finally m_gate.Leave; end;
end;

function TncCharLmHost.score_texts_next_background(const context: string;
    const texts: TArray<string>; const min_count, max_nodes: Integer;
    const next_texts: TArray<Integer>; const top_k, timeout_ms: Integer;
    out logp: TArray<Single>;
    out next_chars: TArray<string>; out next_logp: TArray<Single>): Integer;
begin
    Result := -1;
    logp := nil;
    next_chars := nil;
    next_logp := nil;
    if not char_lm_ready then Exit;
    if not enter_gate(True) then Exit;
    try
        Result := run_score(context, texts, min_count, max_nodes, next_texts, top_k,
            timeout_ms, logp, next_chars, next_logp);
    finally m_gate.Leave; end;
end;

function TncCharLmHost.background_view(const timeout_ms: Integer): IncCharLm;
begin
    // A view owns its deadline; background work must not change foreground scoring.
    Result := TncCharLmBackgroundView.Create(Self, timeout_ms);
end;

function TncCharLmHost.run_score(const context: string; const texts: TArray<string>;
    const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
    const top_k, timeout_ms: Integer; out logp: TArray<Single>; out next_chars: TArray<string>;
    out next_logp: TArray<Single>): Integer;
var
    pointers: TArray<PWideChar>;
    code_points: TArray<Cardinal>;
    code: Cardinal;
    idx: Integer;
    error_text: array[0..1023] of WideChar;
begin
    Result := -1;
    logp := nil;
    next_chars := nil;
    next_logp := nil;
    if (Length(texts) = 0) or (min_count < 1) or (min_count > Length(texts)) then Exit;
    if (Length(next_texts) > 0) and ((top_k < 1) or (top_k > 32) or
        (Length(next_texts) > Length(texts))) then Exit;
    if Pos(#0, context) > 0 then Exit;
    SetLength(pointers, Length(texts));
    for idx := 0 to High(texts) do
    begin
        if (texts[idx] = '') or (Pos(#0, texts[idx]) > 0) then Exit;
        pointers[idx] := PWideChar(texts[idx]);
    end;
    SetLength(logp, Length(texts));
    SetLength(next_chars, Length(next_texts) * top_k);
    SetLength(next_logp, Length(next_texts) * top_k);
    if Length(next_texts) > 0 then
    begin
        SetLength(code_points, Length(next_texts) * top_k);
        Result := m_score_next(m_handle, PWideChar(context), @pointers[0], Length(texts),
            min_count, max_nodes, @logp[0], @next_texts[0], Length(next_texts), top_k,
            @code_points[0], @next_logp[0], timeout_ms, @error_text[0], Length(error_text));
        for idx := 0 to High(code_points) do
        begin
            code := code_points[idx];
            if (code > 0) and (code < $D800) or ((code > $DFFF) and (code <= $FFFF)) then
                next_chars[idx] := WideChar(code)
            else if (code >= $10000) and (code <= $10FFFF) then
            begin
                code := code - $10000;
                next_chars[idx] := UnicodeString(WideChar($D800 + (code shr 10))) +
                    WideChar($DC00 + (code and $3FF));
            end;
        end;
    end
    else
        Result := m_score(m_handle, PWideChar(context), @pointers[0], Length(texts),
            min_count, max_nodes, @logp[0], timeout_ms, @error_text[0], Length(error_text));
    if Result < min_count then
    begin
        Result := -1;
        logp := nil;
        next_chars := nil;
        next_logp := nil;
    end
    else SetLength(logp, Result);
end;

end.
