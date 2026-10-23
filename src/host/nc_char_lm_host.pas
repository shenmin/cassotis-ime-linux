unit nc_char_lm_host;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Classes, SyncObjs, Dynlibs, Generics.Collections, Character, nc_char_lm;

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

    TncCharLmHost = class(TInterfacedObject, IncCharLm, IncCharLmNext, IncCharLmQuery,
        IncCharLmContinue)
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
        TScoreTextsQuery = function(handle: Pointer; context: PWideChar; texts: PPWideChar;
            count, min_count, max_nodes: Integer; out_logp: PSingle; next_indices: PInteger;
            next_count, query_count: Integer; query_code_points: PCardinal;
            out_query_logp: PSingle; timeout_ms: Integer; error_text: PWideChar;
            capacity: Integer): Integer; cdecl;
        TContinueText = function(handle: Pointer; context, prefix: PWideChar;
            max_chars: Integer; out_text: PWideChar; out_capacity: Integer; out_logp: PSingle;
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
        m_score_query: TScoreTextsQuery;
        m_destroy: TDestroyModel;
        m_continue: TContinueText;
        m_cache_lock: TCriticalSection;
        m_gate: TCriticalSection;
        m_plain_cache: TDictionary<string, TArray<Single>>;
        function plain_cache_key(const context: string; const texts: TArray<string>;
            const min_count: Integer; const next_texts: TArray<Integer>): string;
        function plain_cache_get(const key: string; out logp: TArray<Single>): Boolean;
        procedure plain_cache_put(const key: string; const logp: TArray<Single>);

        function run_continue(const context, text: string; const max_chars, timeout_ms: Integer;
            out chars: TArray<string>; out logp: TArray<Single>): Integer;
        procedure load;
        function enter_gate(const background: Boolean): Boolean;
        function score(const background: Boolean; const context: string;
            const texts: TArray<string>; const min_count, max_nodes: Integer;
            const next_texts: TArray<Integer>; const top_k, timeout_ms: Integer;
            const query_chars: TArray<string>; const query_count: Integer;
            out logp: TArray<Single>; out next_chars: TArray<string>;
            out next_logp, query_logp: TArray<Single>): Integer;
        function run_score(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
            const top_k, timeout_ms: Integer; const query_chars: TArray<string>;
            const query_count: Integer; out logp: TArray<Single>;
            out next_chars: TArray<string>; out next_logp, query_logp: TArray<Single>): Integer;
    public
        constructor Create(const directory: string; background: Boolean;
            intra_threads: Integer = 0; timeout_ms: Integer = 100);
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
        function score_texts_query(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
            const query_chars: TArray<string>; const query_count: Integer;
            out logp: TArray<Single>; out query_logp: TArray<Single>): Integer;
        function score_texts_query_background(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
            const query_chars: TArray<string>; const query_count, timeout_ms: Integer;
            out logp: TArray<Single>; out query_logp: TArray<Single>): Integer;
        function continue_text(const context, text: string; const max_chars: Integer;
            out chars: TArray<string>; out logp: TArray<Single>): Integer;
        function continue_text_background(const context, text: string; const max_chars, timeout_ms: Integer;
            out chars: TArray<string>; out logp: TArray<Single>): Integer;
        function background_view(
            const timeout_ms: Integer = c_nc_char_lm_background_timeout_ms): IncCharLm;
        property last_error: string read m_error;
    end;

function nc_shared_lm_threads: Integer;

implementation

uses fpjson, nc_model_assets, nc_types, nc_platform_compat;

function nc_shared_lm_threads: Integer;
const
{$IF DEFINED(CPUX86_64) OR DEFINED(CPUI386)}
    c_max_threads = 6;
{$ELSE}
    c_max_threads = 8;
{$ENDIF}
begin
    Result := nc_available_cpu_count;
    if Result < 1 then Result := 1;
    // Bound x86 worker synchronization without starving the shared 150M model.
    // Explicit diagnostic thread counts still bypass this production default.
    if Result > c_max_threads then Result := c_max_threads;
end;

const
    c_foreground_wait_ms = 60;

type
    TncCharLmBackgroundView = class(TInterfacedObject, IncCharLm, IncCharLmNext, IncCharLmQuery,
        IncCharLmContinue)
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
        function score_texts_query(const context: string; const texts: TArray<string>;
            const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
            const query_chars: TArray<string>; const query_count: Integer;
            out logp: TArray<Single>; out query_logp: TArray<Single>): Integer;
        function continue_text(const context, text: string; const max_chars: Integer;
            out chars: TArray<string>; out logp: TArray<Single>): Integer;

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

function TncCharLmBackgroundView.score_texts_query(const context: string;
    const texts: TArray<string>; const min_count, max_nodes: Integer;
    const next_texts: TArray<Integer>; const query_chars: TArray<string>;
    const query_count: Integer; out logp: TArray<Single>; out query_logp: TArray<Single>): Integer;
begin
    Result := m_host.score_texts_query_background(context, texts, min_count, max_nodes,
        next_texts, query_chars, query_count, m_timeout_ms, logp, query_logp);
end;

function TncCharLmBackgroundView.continue_text(const context, text: string;
    const max_chars: Integer; out chars: TArray<string>; out logp: TArray<Single>): Integer;
begin
    Result := m_host.continue_text_background(context, text, max_chars, m_timeout_ms, chars, logp);
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
    if m_threads <= 0 then m_threads := nc_shared_lm_threads;
    m_timeout_ms := timeout_ms;
    m_gate := TCriticalSection.Create;
    m_cache_lock := TCriticalSection.Create;
    m_plain_cache := TDictionary<string, TArray<Single>>.Create;
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
    m_plain_cache.Free;
    m_cache_lock.Free;
    inherited;
end;

function TncCharLmHost.plain_cache_key(const context: string; const texts: TArray<string>;
    const min_count: Integer; const next_texts: TArray<Integer>): string;
const
    // A short-word candidate group: at most eight words, each with its first
    // one and two characters.
    c_texts = 24;
    c_length = 160;
begin
    Result := '';
    if (context <> '') or (Length(next_texts) > 0) or (Length(texts) = 0) or
        (Length(texts) > c_texts) or (min_count < Length(texts)) then
        Exit;
    Result := nc_join_strings(#1, texts);
    if Length(Result) > c_length then
        Result := '';
end;

function TncCharLmHost.plain_cache_get(const key: string; out logp: TArray<Single>): Boolean;
begin
    m_cache_lock.Enter;
    try
        Result := m_plain_cache.TryGetValue(key, logp);
        if Result then
            logp := Copy(logp);
    finally
        m_cache_lock.Leave;
    end;
end;

procedure TncCharLmHost.plain_cache_put(const key: string; const logp: TArray<Single>);
const
    c_entries = 16384;
begin
    m_cache_lock.Enter;
    try
        if m_plain_cache.Count >= c_entries then
            m_plain_cache.Clear;
        m_plain_cache.AddOrSetValue(key, Copy(logp));
    finally
        m_cache_lock.Leave;
    end;
end;

procedure TncCharLmHost.load;
const required_files: array[0..2] of string = ('char_lm.onnx', 'char_lm_vocab.bin', 'pinyin_readings.json');
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
        m_score_query := TScoreTextsQuery(GetProcedureAddress(m_module, 'nc_lm_score_next_query'));
        m_continue := TContinueText(GetProcedureAddress(m_module, 'nc_lm_continue'));
        m_destroy := TDestroyModel(GetProcedureAddress(m_module, 'nc_lm_destroy'));
        if not Assigned(create_model) or not Assigned(m_score) or
            not Assigned(m_score_next) or not Assigned(m_continue) or not Assigned(m_destroy) then
            raise Exception.Create('Character LM runtime must be rebuilt');
        error_text[0] := #0;
        m_handle := create_model(PWideChar(folder), m_threads, @error_text[0], Length(error_text));
        if m_handle = nil then raise Exception.Create(UTF8Encode(UnicodeString(PWideChar(@error_text[0]))));
        InterlockedExchange(m_ready, 1);
        model_runtime_log('[INFO] shared character LM loaded in host process threads=' +
            IntToStr(m_threads));
      except
        on E: Exception do
        begin
            m_error := UTF8Decode(E.Message);
            model_runtime_log('[WARN] shared character LM unavailable: ' + UTF8Decode(E.Message));
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

function TncCharLmHost.score(const background: Boolean; const context: string;
    const texts: TArray<string>; const min_count, max_nodes: Integer;
    const next_texts: TArray<Integer>; const top_k, timeout_ms: Integer;
    const query_chars: TArray<string>; const query_count: Integer;
    out logp: TArray<Single>; out next_chars: TArray<string>;
    out next_logp, query_logp: TArray<Single>): Integer;
var key: string;
begin
    Result := -1;
    logp := nil;
    next_chars := nil;
    next_logp := nil;
    query_logp := nil;
    if not char_lm_ready then Exit;
    key := '';
    if query_count = 0 then key := plain_cache_key(context, texts, min_count, next_texts);
    if (key <> '') and plain_cache_get(key, logp) then Exit(Length(logp));
    if not enter_gate(background) then Exit;
    try
        Result := run_score(context, texts, min_count, max_nodes, next_texts, top_k,
            timeout_ms, query_chars, query_count, logp, next_chars, next_logp, query_logp);
    finally m_gate.Leave; end;
    if (key <> '') and (Result = Length(texts)) then plain_cache_put(key, logp);
end;

function TncCharLmHost.score_texts_next(const context: string; const texts: TArray<string>;
    const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
    const top_k: Integer; out logp: TArray<Single>; out next_chars: TArray<string>;
    out next_logp: TArray<Single>): Integer;
var query_logp: TArray<Single>;
begin
    Result := score(False, context, texts, min_count, max_nodes, next_texts, top_k,
        m_timeout_ms, nil, 0, logp, next_chars, next_logp, query_logp);
end;

function TncCharLmHost.score_texts_next_background(const context: string;
    const texts: TArray<string>; const min_count, max_nodes: Integer;
    const next_texts: TArray<Integer>; const top_k, timeout_ms: Integer;
    out logp: TArray<Single>;
    out next_chars: TArray<string>; out next_logp: TArray<Single>): Integer;
var query_logp: TArray<Single>;
begin
    Result := score(True, context, texts, min_count, max_nodes, next_texts, top_k,
        timeout_ms, nil, 0, logp, next_chars, next_logp, query_logp);
end;

function TncCharLmHost.score_texts_query(const context: string; const texts: TArray<string>;
    const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
    const query_chars: TArray<string>; const query_count: Integer;
    out logp: TArray<Single>; out query_logp: TArray<Single>): Integer;
var next_chars: TArray<string>; next_logp: TArray<Single>;
begin
    Result := score(False, context, texts, min_count, max_nodes, next_texts, 0,
        m_timeout_ms, query_chars, query_count, logp, next_chars, next_logp, query_logp);
end;

function TncCharLmHost.score_texts_query_background(const context: string; const texts: TArray<string>;
    const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
    const query_chars: TArray<string>; const query_count, timeout_ms: Integer;
    out logp: TArray<Single>; out query_logp: TArray<Single>): Integer;
var next_chars: TArray<string>; next_logp: TArray<Single>;
begin
    Result := score(True, context, texts, min_count, max_nodes, next_texts, 0,
        timeout_ms, query_chars, query_count, logp, next_chars, next_logp, query_logp);
end;

function TncCharLmHost.background_view(const timeout_ms: Integer): IncCharLm;
begin
    // A view owns its deadline; background work must not change foreground scoring.
    Result := TncCharLmBackgroundView.Create(Self, timeout_ms);
end;

function TncCharLmHost.run_score(const context: string; const texts: TArray<string>;
    const min_count, max_nodes: Integer; const next_texts: TArray<Integer>;
    const top_k, timeout_ms: Integer; const query_chars: TArray<string>;
    const query_count: Integer; out logp: TArray<Single>;
    out next_chars: TArray<string>; out next_logp, query_logp: TArray<Single>): Integer;
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
    query_logp := nil;
    if (Length(texts) = 0) or (min_count < 1) or (min_count > Length(texts)) then Exit;
    if (query_count < 0) or (Length(next_texts) > Length(texts)) then Exit;
    if query_count > 0 then
    begin
        if (top_k > 0) or (query_count > 64) or (Length(next_texts) = 0) or
            (Length(query_chars) <> Length(next_texts) * query_count) then Exit;
    end
    else if (Length(next_texts) > 0) and ((top_k < 1) or (top_k > 32)) then Exit;
    if Pos(#0, context) > 0 then Exit;
    SetLength(pointers, Length(texts));
    for idx := 0 to High(texts) do
    begin
        if (texts[idx] = '') or (Pos(#0, texts[idx]) > 0) then Exit;
        pointers[idx] := PWideChar(texts[idx]);
    end;
    SetLength(logp, Length(texts));
    error_text[0] := #0;
    if query_count > 0 then
    begin
        SetLength(query_logp, Length(query_chars));
        if not Assigned(m_score_query) then
        begin
            for idx := 0 to High(query_logp) do query_logp[idx] := c_char_lm_no_logp;
            Result := m_score(m_handle, PWideChar(context), @pointers[0], Length(texts),
                min_count, max_nodes, @logp[0], timeout_ms, @error_text[0], Length(error_text));
        end
        else
        begin
            SetLength(code_points, Length(query_chars));
            for idx := 0 to High(query_chars) do
                if query_chars[idx] <> '' then
                begin
                    code := Ord(query_chars[idx][1]);
                    if (code >= $D800) and (code <= $DBFF) and
                        (Length(query_chars[idx]) = 2) and
                        TCharacter.IsLowSurrogate(query_chars[idx][2]) then
                        code := $10000 + ((code - $D800) shl 10) +
                            Ord(query_chars[idx][2]) - $DC00;
                    code_points[idx] := code;
                end;
            Result := m_score_query(m_handle, PWideChar(context), @pointers[0], Length(texts),
                min_count, max_nodes, @logp[0], @next_texts[0], Length(next_texts), query_count,
                @code_points[0], @query_logp[0], timeout_ms, @error_text[0], Length(error_text));
        end;
    end
    else
    begin
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
    end;
    if Result < min_count then
    begin
        Result := -1;
        logp := nil;
        next_chars := nil;
        next_logp := nil;
        query_logp := nil;
    end
    else SetLength(logp, Result);
end;

function TncCharLmHost.run_continue(const context, text: string; const max_chars, timeout_ms: Integer;
    out chars: TArray<string>; out logp: TArray<Single>): Integer;
var
    buffer: TArray<WideChar>;
    error_text: array[0..1023] of WideChar;
    value: string;
    produced, idx, position: Integer;
begin
    Result := -1;
    SetLength(chars, 0);
    SetLength(logp, 0);
    if (not Assigned(m_continue)) or (text = '') or (max_chars < 1) or (max_chars > 32) or
        (Pos(#0, context) > 0) or (Pos(#0, text) > 0) then Exit;
    SetLength(buffer, 2 * max_chars + 1);
    SetLength(logp, max_chars);
    produced := m_continue(m_handle, PWideChar(context), PWideChar(text), max_chars,
        @buffer[0], Length(buffer), @logp[0], timeout_ms, @error_text[0], Length(error_text));
    if produced < 0 then
    begin
        SetLength(logp, 0);
        Exit;
    end;
    // One element per character; a supplementary character is a surrogate pair.
    value := PWideChar(@buffer[0]);
    position := 1;
    for idx := 0 to produced - 1 do
    begin
        if position > Length(value) then Break;
        if (position < Length(value)) and TCharacter.IsHighSurrogate(value[position]) then
        begin
            chars := chars + [Copy(value, position, 2)];
            Inc(position, 2);
        end
        else
        begin
            chars := chars + [value[position]];
            Inc(position);
        end;
    end;
    SetLength(logp, Length(chars));
    Result := Length(chars);
end;

function TncCharLmHost.continue_text(const context, text: string; const max_chars: Integer;
    out chars: TArray<string>; out logp: TArray<Single>): Integer;
begin
    Result := -1;
    chars := nil;
    logp := nil;
    if not char_lm_ready or not enter_gate(False) then Exit;
    try
        Result := run_continue(context, text, max_chars, m_timeout_ms, chars, logp);
    finally m_gate.Leave; end;
end;

function TncCharLmHost.continue_text_background(const context, text: string;
    const max_chars, timeout_ms: Integer; out chars: TArray<string>;
    out logp: TArray<Single>): Integer;
begin
    Result := -1;
    chars := nil;
    logp := nil;
    if not char_lm_ready or not enter_gate(True) then Exit;
    try
        Result := run_continue(context, text, max_chars, timeout_ms, chars, logp);
    finally m_gate.Leave; end;
end;

end.
