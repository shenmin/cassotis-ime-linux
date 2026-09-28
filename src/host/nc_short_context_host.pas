unit nc_short_context_host;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Classes, SyncObjs, Dynlibs, nc_short_context_ranker;

const
    // Linux scheduling budget; keep the frozen Windows model metadata intact.
    c_short_context_inference_limit_ms = 60;

type
    TncShortContextHost = class;
    TncShortContextLoader = class(TThread)
    private
        m_owner: TncShortContextHost;
    protected
        procedure Execute; override;
    public
        constructor Create(const owner: TncShortContextHost);
    end;

    TncShortContextHost = class(TInterfacedObject, IncShortContextReranker)
    private type
        TModelFormat = function: Integer; cdecl;
        TCreateModel = function(directory, error_text: PWideChar; capacity: Integer): Pointer; cdecl;
        TRunModel = function(handle: Pointer; context, query, first, second: PWideChar;
            values: PInteger; timeout_ms: Integer; audit: PDouble; audit_count: Integer;
            error_text: PWideChar; capacity: Integer): Integer; cdecl;
        TDestroyModel = procedure(handle: Pointer); cdecl;
    private
        m_directory, m_error: string;
        m_loader: TncShortContextLoader;
        m_signal: TEvent;
        m_lock: TCriticalSection;
        m_ready, m_stopping: LongInt;
        m_module: TLibHandle;
        m_handle: Pointer;
        m_run: TRunModel;
        m_destroy: TDestroyModel;
        m_cache_key: string;
        m_cache_switch: Boolean;
        procedure load;
    public
        constructor Create(const directory: string; background: Boolean);
        destructor Destroy; override;
        function short_context_ready: Boolean;
        function try_switch_short_context(const request: TncShortContextRequest): Boolean;
        property last_error: string read m_error;
    end;

implementation

uses fpjson, nc_model_assets;

constructor TncShortContextLoader.Create(const owner: TncShortContextHost);
begin
    inherited Create(True);
    FreeOnTerminate := False;
    m_owner := owner;
end;

procedure TncShortContextLoader.Execute;
begin
    m_owner.m_signal.WaitFor(INFINITE);
    if InterlockedCompareExchange(m_owner.m_stopping, 0, 0) = 0 then
        m_owner.load;
end;

constructor TncShortContextHost.Create(const directory: string; background: Boolean);
begin
    inherited Create;
    m_directory := ExpandFileName(directory);
    m_lock := TCriticalSection.Create;
    m_signal := TEvent.Create(nil, True, False, '');
    if background then
    begin
        // The first eligible request triggers loading and retains old ranking.
        m_loader := TncShortContextLoader.Create(Self);
        m_loader.Priority := tpLower;
        m_loader.Start;
    end
    else load;
end;

destructor TncShortContextHost.Destroy;
begin
    InterlockedExchange(m_stopping, 1);
    if m_signal <> nil then m_signal.SetEvent;
    if m_loader <> nil then begin m_loader.WaitFor; m_loader.Free; end;
    if Assigned(m_destroy) and (m_handle <> nil) then m_destroy(m_handle);
    if m_module <> NilHandle then UnloadLibrary(m_module);
    m_signal.Free;
    m_lock.Free;
    inherited;
end;

procedure TncShortContextHost.load;
const
    required_files: array[0..5] of string = ('exit0.int8.onnx',
        'exit1.int8.onnx', 'exit2.int8.onnx', 'exit3.int8.onnx',
        'tokenizer.bin', 'policy.bin');
var
    manifest, files: TJSONObject;
    folder, name: string;
    value: TJSONData;
    runtime_format: TModelFormat;
    create_model: TCreateModel;
    error_text: array[0..1023] of WideChar;
begin
    manifest := nil;
    try
      try
        folder := IncludeTrailingPathDelimiter(m_directory) + 'short_context';
        manifest := read_model_manifest(IncludeTrailingPathDelimiter(folder) + 'runtime_manifest.json');
        if (not manifest.Get('enabled', False)) or
            (manifest.Get('format', 0) <> 2) or
            (manifest.Get('context_characters', 0) <> 48) or
            // Validate the upstream contract, not the Linux scheduling budget.
            (manifest.Get('max_inference_ms', 0) <> 30) then
            raise Exception.Create('Unsupported short-context manifest');
        value := manifest.Find('files');
        if not (value is TJSONObject) then
            raise Exception.Create('Missing short-context assets');
        files := TJSONObject(value);
        if files.Count <> Length(required_files) then
            raise Exception.Create('Incomplete short-context manifest');
        for name in required_files do
        begin
            if InterlockedCompareExchange(m_stopping, 0, 0) <> 0 then Exit;
            value := files.Find(UTF8Encode(name));
            if not (value is TJSONString) then
                raise Exception.Create('Missing short-context asset hash');
            if not model_file_matches_hash(IncludeTrailingPathDelimiter(folder) + name,
                UTF8Decode(value.AsString)) then
                raise Exception.Create('Short-context asset hash mismatch: ' + UTF8Encode(name));
        end;
        m_module := LoadLibrary(UTF8Encode(IncludeTrailingPathDelimiter(m_directory) +
            'libcassotis_pinyin_transformer_ort.so'));
        if m_module = NilHandle then raise Exception.Create('Short-context runtime unavailable');
        runtime_format := TModelFormat(GetProcedureAddress(m_module, 'nc_sc_runtime_format'));
        if not Assigned(runtime_format) then raise Exception.Create('Short-context runtime must be rebuilt');
        if runtime_format() <> 2 then raise Exception.Create('Unsupported short-context runtime format');
        create_model := TCreateModel(GetProcedureAddress(m_module, 'nc_sc_create'));
        m_run := TRunModel(GetProcedureAddress(m_module, 'nc_sc_run'));
        m_destroy := TDestroyModel(GetProcedureAddress(m_module, 'nc_sc_destroy'));
        if not Assigned(create_model) or not Assigned(m_run) or not Assigned(m_destroy) then
            raise Exception.Create('Short-context runtime ABI unavailable');
        error_text[0] := #0;
        m_handle := create_model(PWideChar(folder), @error_text[0], Length(error_text));
        if m_handle = nil then raise Exception.Create(UTF8Encode(UnicodeString(PWideChar(@error_text[0]))));
        InterlockedExchange(m_ready, 1);
      except
        on E: Exception do m_error := UTF8Decode(E.Message);
      end;
    finally
        manifest.Free;
    end;
end;

function TncShortContextHost.short_context_ready: Boolean;
begin
    Result := InterlockedCompareExchange(m_ready, 0, 0) = 1;
    if not Result then m_signal.SetEvent;
end;

function TncShortContextHost.try_switch_short_context(const request: TncShortContextRequest): Boolean;
var key: string; value, decision: Integer; error_text: array[0..1023] of WideChar;
begin
    Result := False;
    if (Pos(#0, request.context) > 0) or (Pos(#0, request.query) > 0) or
        (Pos(#0, request.first) > 0) or (Pos(#0, request.second) > 0) then Exit;
    if not short_context_ready or not m_lock.TryEnter then Exit;
    try
        key := request.context + #0 + request.query + #0 + request.first + #0 + request.second;
        for value in request.values do key := key + #0 + UnicodeString(IntToStr(value));
        if key = m_cache_key then Exit(m_cache_switch);
        decision := m_run(m_handle, PWideChar(request.context), PWideChar(request.query),
            PWideChar(request.first), PWideChar(request.second), @request.values[0],
            c_short_context_inference_limit_ms,
            nil, 0, @error_text[0], Length(error_text));
        Result := decision = 1;
        if decision >= 0 then
        begin
            m_cache_key := key;
            m_cache_switch := Result;
        end;
    finally m_lock.Leave; end;
end;

end.
