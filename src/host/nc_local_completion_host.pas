unit nc_local_completion_host;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    Classes,
    SyncObjs,
    Dynlibs,
    nc_engine_intf;

type
    TncLocalCompletionHost = class;

    TncLocalCompletionTask = record
        context_id: QWord;
        generation_id: QWord;
        request: TncLongNeuralCompletionRequest;
    end;

    TncLocalCompletionFinished = record
        task: TncLocalCompletionTask;
        accepted: Boolean;
        completion_result: TncLongNeuralCompletionResult;
    end;

    TncLocalCompletionWorker = class(TThread)
    private
        FOwner: TncLocalCompletionHost;
    protected
        procedure Execute; override;
    public
        constructor Create(const owner: TncLocalCompletionHost);
        procedure DetachOwner;
    end;

    TncLocalCompletionHost = class
    private type
        TncLcCreate = function(const model_path, index_path: PAnsiChar;
            const intra_threads: Integer; const error_text: PAnsiChar;
            const error_capacity: Integer): Pointer; cdecl;
        TncLcRun = function(const handle: Pointer;
            const context, query_syllables, top1_text, top1_path,
            top2_text, top2_path: PAnsiChar;
            const minimum_confidence: Single;
            const output_suffix_text: PAnsiChar;
            const output_suffix_text_capacity: Integer;
            const output_suffix_pinyin: PAnsiChar;
            const output_suffix_pinyin_capacity: Integer;
            const output_suffix_path: PAnsiChar;
            const output_suffix_path_capacity: Integer;
            const output_base_rank: PInteger;
            const output_confidence: PSingle;
            const error_text: PAnsiChar;
            const error_capacity: Integer): Integer; cdecl;
        TncLcDestroy = procedure(const handle: Pointer); cdecl;
    private
        FBaseDirectory: string;
        FLock: TCriticalSection;
        FWakeup: TEvent;
        FWorker: TncLocalCompletionWorker;
        FPendingTask: TncLocalCompletionTask;
        FHasPendingTask: Boolean;
        FFinished: TncLocalCompletionFinished;
        FHasFinished: Boolean;
        FModule: TLibHandle;
        FSession: Pointer;
        FRunFunction: TncLcRun;
        FDestroyFunction: TncLcDestroy;
        FMinimumConfidence: Single;
        FResultTimeoutMs: QWord;
        FModelThreads: Integer;
        FReady: Boolean;
        FLoadFinished: Boolean;
        FLastError: string;
        procedure WorkerExecute;
        procedure LoadRuntime;
        function PopTask(out task: TncLocalCompletionTask): Boolean;
        function RunTask(const task: TncLocalCompletionTask;
            out completion_result: TncLongNeuralCompletionResult): Boolean;
        procedure StoreFinished(const task: TncLocalCompletionTask;
            const accepted: Boolean;
            const completion_result: TncLongNeuralCompletionResult);
        procedure Disable(const error_text: string);
    public
        constructor Create(const base_directory: string;
            const result_timeout_ms: QWord = 40;
            const model_threads: Integer = 0);
        destructor Destroy; override;
        function Enqueue(const task: TncLocalCompletionTask): Boolean;
        function TryPopFinishedFor(const context_id: QWord;
            out finished: TncLocalCompletionFinished): Boolean;
        function Ready: Boolean;
        function LoadFinished: Boolean;
        function LastError: string;
    end;

implementation

uses
    Math,
    fpjson,
    jsonparser;

const
    c_model_threads = 4;

function join_path(const base_path, child_path: string): string;
begin
    Result := IncludeTrailingPathDelimiter(base_path) + child_path;
end;

function read_utf8_file(const file_name: string): UTF8String;
var
    stream: TFileStream;
    bytes: UTF8String;
begin
    stream := TFileStream.Create(file_name, fmOpenRead or fmShareDenyNone);
    try
        SetLength(bytes, stream.Size);
        if Length(bytes) > 0 then
            stream.ReadBuffer(bytes[1], Length(bytes));
    finally
        stream.Free;
    end;
    Result := bytes;
end;

function ansi_buffer_text(const buffer: array of AnsiChar): string;
begin
    if Length(buffer) = 0 then
        Exit('');
    Result := UTF8Decode(UTF8String(PAnsiChar(@buffer[0])));
end;

constructor TncLocalCompletionWorker.Create(
    const owner: TncLocalCompletionHost);
begin
    inherited Create(True);
    FreeOnTerminate := False;
    Priority := tpLower;
    FOwner := owner;
end;

procedure TncLocalCompletionWorker.DetachOwner;
begin
    FOwner := nil;
end;

procedure TncLocalCompletionWorker.Execute;
var
    owner: TncLocalCompletionHost;
begin
    owner := FOwner;
    if owner <> nil then
        owner.WorkerExecute;
end;

constructor TncLocalCompletionHost.Create(const base_directory: string;
    const result_timeout_ms: QWord; const model_threads: Integer);
begin
    inherited Create;
    FBaseDirectory := ExcludeTrailingPathDelimiter(
        ExpandFileName(base_directory));
    FLock := TCriticalSection.Create;
    FWakeup := TEvent.Create(nil, False, False, '');
    FPendingTask := Default(TncLocalCompletionTask);
    FHasPendingTask := False;
    FFinished := Default(TncLocalCompletionFinished);
    FHasFinished := False;
    FModule := 0;
    FSession := nil;
    FRunFunction := nil;
    FDestroyFunction := nil;
    FMinimumConfidence := 0.0;
    FResultTimeoutMs := result_timeout_ms;
    if model_threads > 0 then
        FModelThreads := model_threads
    else
        FModelThreads := c_model_threads;
    FReady := False;
    FLoadFinished := False;
    FLastError := '';
    FWorker := TncLocalCompletionWorker.Create(Self);
    FWorker.Start;
end;

destructor TncLocalCompletionHost.Destroy;
begin
    if FWorker <> nil then
    begin
        FWorker.Terminate;
        FWakeup.SetEvent;
        FWorker.WaitFor;
        FWorker.DetachOwner;
        FWorker.Free;
        FWorker := nil;
    end;
    if (FSession <> nil) and Assigned(FDestroyFunction) then
    begin
        FDestroyFunction(FSession);
        FSession := nil;
    end;
    if FModule <> 0 then
    begin
        FreeLibrary(FModule);
        FModule := 0;
    end;
    FWakeup.Free;
    FLock.Free;
    inherited Destroy;
end;

procedure TncLocalCompletionHost.Disable(const error_text: string);
begin
    FLock.Acquire;
    try
        FReady := False;
        FLoadFinished := True;
        FLastError := error_text;
        if FHasPendingTask then
        begin
            FFinished.task := FPendingTask;
            FFinished.accepted := False;
            FFinished.completion_result :=
                Default(TncLongNeuralCompletionResult);
            FHasFinished := True;
        end;
        FHasPendingTask := False;
    finally
        FLock.Release;
    end;
end;

procedure TncLocalCompletionHost.LoadRuntime;
var
    wrapper_path: string;
    model_directory: string;
    model_path: string;
    index_path: string;
    manifest_path: string;
    root_data: TJSONData;
    root_object: TJSONObject;
    gate_object: TJSONObject;
    dev_object: TJSONObject;
    index_object: TJSONObject;
    model_file: string;
    index_file: string;
    model_hash: string;
    vocab_hash: string;
    index_hash: string;
    index_vocab_hash: string;
    create_function: TncLcCreate;
    error_buffer: array[0..511] of AnsiChar;
    model_path_utf8: UTF8String;
    index_path_utf8: UTF8String;
begin
    wrapper_path := join_path(FBaseDirectory,
        'libcassotis_pinyin_transformer_ort.so');
    model_directory := join_path(FBaseDirectory, 'local_completion');
    model_path := join_path(model_directory,
        'local_completion_path_ranker_int8.onnx');
    index_path := join_path(model_directory, 'local_completion_index.bin');
    manifest_path := join_path(model_directory, 'model_manifest.json');
    if not FileExists(wrapper_path) then
        raise EInvalidOp.Create('missing runtime wrapper: ' + wrapper_path);
    if not FileExists(model_path) then
        raise EInvalidOp.Create('missing completion model: ' + model_path);
    if not FileExists(index_path) then
        raise EInvalidOp.Create('missing completion index: ' + index_path);
    if not FileExists(manifest_path) then
        raise EInvalidOp.Create('missing completion manifest: ' + manifest_path);

    root_data := GetJSON(read_utf8_file(manifest_path));
    try
        if not (root_data is TJSONObject) then
            raise EInvalidOp.Create('invalid local-completion manifest');
        root_object := TJSONObject(root_data);
        if root_object.Get('format', 0) <> 1 then
            raise EInvalidOp.Create('unsupported local-completion manifest');
        model_file := root_object.Get('model', '');
        if not SameText(model_file, ExtractFileName(model_path)) then
            raise EInvalidOp.Create('local-completion model identity mismatch');
        gate_object := root_object.Find('gate') as TJSONObject;
        if gate_object = nil then
            raise EInvalidOp.Create('local-completion gate is absent');
        dev_object := gate_object.Find('dev') as TJSONObject;
        if dev_object = nil then
            raise EInvalidOp.Create('local-completion development gate is absent');
        FMinimumConfidence := dev_object.Get('threshold', -1.0);
        if IsNan(FMinimumConfidence) or IsInfinite(FMinimumConfidence) or
            (FMinimumConfidence < 0.0) or (FMinimumConfidence > 1000.0) then
            raise EInvalidOp.Create('local-completion threshold is invalid');
        model_hash := LowerCase(root_object.Get('model_sha256', ''));
        vocab_hash := LowerCase(root_object.Get('vocab_sha256', ''));
        index_object := root_object.Find('runtime_index') as TJSONObject;
        if index_object = nil then
            raise EInvalidOp.Create('local-completion index identity is absent');
        index_file := index_object.Get('file', '');
        index_hash := LowerCase(index_object.Get('sha256', ''));
        index_vocab_hash := LowerCase(index_object.Get('vocab_sha256', ''));
        if (not SameText(index_file, ExtractFileName(index_path))) or
            (Length(model_hash) <> 64) or (Length(vocab_hash) <> 64) or
            (Length(index_hash) <> 64) or
            (not SameText(vocab_hash, index_vocab_hash)) then
            raise EInvalidOp.Create('local-completion asset identity is invalid');
    finally
        root_data.Free;
    end;

    FModule := LoadLibrary(UTF8Encode(wrapper_path));
    if FModule = 0 then
        raise EInvalidOp.CreateFmt('LoadLibrary failed: %s (%s)',
            [wrapper_path, GetLoadErrorStr]);
    create_function := TncLcCreate(GetProcedureAddress(FModule,
        'nc_lc_create'));
    FRunFunction := TncLcRun(GetProcedureAddress(FModule, 'nc_lc_run'));
    FDestroyFunction := TncLcDestroy(GetProcedureAddress(FModule,
        'nc_lc_destroy'));
    if (not Assigned(create_function)) or (not Assigned(FRunFunction)) or
        (not Assigned(FDestroyFunction)) then
        raise EInvalidOp.Create('invalid local-completion wrapper ABI');

    FillChar(error_buffer, SizeOf(error_buffer), 0);
    model_path_utf8 := UTF8Encode(model_path);
    index_path_utf8 := UTF8Encode(index_path);
    FSession := create_function(PAnsiChar(model_path_utf8),
        PAnsiChar(index_path_utf8), FModelThreads, @error_buffer[0],
        Length(error_buffer));
    if FSession = nil then
        raise EInvalidOp.Create(ansi_buffer_text(error_buffer));
    FLock.Acquire;
    try
        FReady := True;
        FLoadFinished := True;
        FLastError := '';
    finally
        FLock.Release;
    end;
end;

function TncLocalCompletionHost.PopTask(
    out task: TncLocalCompletionTask): Boolean;
begin
    task := Default(TncLocalCompletionTask);
    FLock.Acquire;
    try
        Result := FHasPendingTask;
        if Result then
        begin
            task := FPendingTask;
            FPendingTask := Default(TncLocalCompletionTask);
            FHasPendingTask := False;
        end;
    finally
        FLock.Release;
    end;
end;

function TncLocalCompletionHost.RunTask(
    const task: TncLocalCompletionTask;
    out completion_result: TncLongNeuralCompletionResult): Boolean;
var
    context_utf8: UTF8String;
    query_utf8: UTF8String;
    top1_text_utf8: UTF8String;
    top1_path_utf8: UTF8String;
    top2_text_utf8: UTF8String;
    top2_path_utf8: UTF8String;
    suffix_text: array[0..511] of AnsiChar;
    suffix_pinyin: array[0..1023] of AnsiChar;
    suffix_path: array[0..511] of AnsiChar;
    error_buffer: array[0..511] of AnsiChar;
    base_rank: Integer;
    confidence: Single;
    started_at: QWord;
    elapsed_ms: QWord;
begin
    completion_result := Default(TncLongNeuralCompletionResult);
    FillChar(suffix_text, SizeOf(suffix_text), 0);
    FillChar(suffix_pinyin, SizeOf(suffix_pinyin), 0);
    FillChar(suffix_path, SizeOf(suffix_path), 0);
    FillChar(error_buffer, SizeOf(error_buffer), 0);
    context_utf8 := UTF8Encode(task.request.context_text);
    query_utf8 := UTF8Encode(task.request.query_syllables);
    top1_text_utf8 := UTF8Encode(task.request.top1_text);
    top1_path_utf8 := UTF8Encode(task.request.top1_anchor_path);
    top2_text_utf8 := UTF8Encode(task.request.top2_text);
    top2_path_utf8 := UTF8Encode(task.request.top2_anchor_path);
    base_rank := 0;
    confidence := 0.0;
    started_at := GetTickCount64;
    Result := FRunFunction(FSession,
        PAnsiChar(context_utf8), PAnsiChar(query_utf8),
        PAnsiChar(top1_text_utf8), PAnsiChar(top1_path_utf8),
        PAnsiChar(top2_text_utf8), PAnsiChar(top2_path_utf8),
        FMinimumConfidence, @suffix_text[0], Length(suffix_text),
        @suffix_pinyin[0], Length(suffix_pinyin),
        @suffix_path[0], Length(suffix_path), @base_rank, @confidence,
        @error_buffer[0], Length(error_buffer)) <> 0;
    elapsed_ms := GetTickCount64 - started_at;
    if (not Result) and (error_buffer[0] <> #0) then
    begin
        Disable(ansi_buffer_text(error_buffer));
        Exit;
    end;
    if Result and (FResultTimeoutMs > 0) and
        (elapsed_ms > FResultTimeoutMs) then
        Exit(False);
    if Result then
    begin
        completion_result.suffix_text := ansi_buffer_text(suffix_text);
        completion_result.suffix_pinyin_path :=
            ansi_buffer_text(suffix_pinyin);
        completion_result.suffix_path := ansi_buffer_text(suffix_path);
        completion_result.base_rank := base_rank;
        completion_result.confidence := confidence;
    end;
end;

procedure TncLocalCompletionHost.StoreFinished(
    const task: TncLocalCompletionTask; const accepted: Boolean;
    const completion_result: TncLongNeuralCompletionResult);
begin
    FLock.Acquire;
    try
        FFinished.task := task;
        FFinished.accepted := accepted;
        FFinished.completion_result := completion_result;
        FHasFinished := True;
    finally
        FLock.Release;
    end;
end;

procedure TncLocalCompletionHost.WorkerExecute;
var
    task: TncLocalCompletionTask;
    completion_result: TncLongNeuralCompletionResult;
    accepted: Boolean;
begin
    try
        LoadRuntime;
    except
        on error: Exception do
        begin
            Disable(error.Message);
            Exit;
        end;
    end;
    while (FWorker <> nil) and (not FWorker.Terminated) do
    begin
        if not PopTask(task) then
        begin
            FWakeup.WaitFor(250);
            if FWorker.Terminated then
                Break;
            if not PopTask(task) then
                Continue;
        end;
        accepted := RunTask(task, completion_result);
        StoreFinished(task, accepted, completion_result);
        if not Ready then
            Break;
    end;
end;

function TncLocalCompletionHost.Enqueue(
    const task: TncLocalCompletionTask): Boolean;
begin
    Result := False;
    if (task.context_id = 0) or (task.request.query_prefix = '') or
        (task.request.top1_anchor_path = '') then
        Exit;
    FLock.Acquire;
    try
        if (not FReady) and FLoadFinished then
            Exit;
        FPendingTask := task;
        FHasPendingTask := True;
        FHasFinished := False;
        Result := True;
    finally
        FLock.Release;
    end;
    if Result then
        FWakeup.SetEvent;
end;

function TncLocalCompletionHost.TryPopFinishedFor(const context_id: QWord;
    out finished: TncLocalCompletionFinished): Boolean;
begin
    finished := Default(TncLocalCompletionFinished);
    FLock.Acquire;
    try
        Result := FHasFinished and
            (FFinished.task.context_id = context_id);
        if Result then
        begin
            finished := FFinished;
            FFinished := Default(TncLocalCompletionFinished);
            FHasFinished := False;
        end;
    finally
        FLock.Release;
    end;
end;

function TncLocalCompletionHost.Ready: Boolean;
begin
    FLock.Acquire;
    try
        Result := FReady;
    finally
        FLock.Release;
    end;
end;

function TncLocalCompletionHost.LoadFinished: Boolean;
begin
    FLock.Acquire;
    try
        Result := FLoadFinished;
    finally
        FLock.Release;
    end;
end;

function TncLocalCompletionHost.LastError: string;
begin
    FLock.Acquire;
    try
        Result := FLastError;
    finally
        FLock.Release;
    end;
end;

end.
