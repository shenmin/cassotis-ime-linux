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
    nc_engine_intf,
    nc_char_lm;

const
    // Completed background results beyond this deadline are discarded.
    c_nc_local_completion_result_timeout_ms = 120;

type
    TncLocalCompletionHost = class;

    TncLocalCompletionTask = record
        context_id: QWord;
        generation_id: QWord;
        prefetch_only: Boolean;
        request: TncLongNeuralCompletionRequest;
    end;

    TncLocalCompletionModelOutput = record
        accepted, use_pool, generated, failed: Boolean;
        elapsed_ms: QWord;
        result: TncLongNeuralCompletionResult;
        suffix_text, suffix_pinyin, suffix_path: string;
        base_rank, replace_units: Integer;
        confidence: Single;
    end;

    TncLocalCompletionPrefetchCache = record
    private
        FValid: Boolean;
        FTask: TncLocalCompletionTask;
        FOutput: TncLocalCompletionModelOutput;
    public
        procedure Clear;
        procedure Remember(const task: TncLocalCompletionTask;
            const output: TncLocalCompletionModelOutput);
        function Take(const task: TncLocalCompletionTask;
            out output: TncLocalCompletionModelOutput): Boolean;
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
            const phonetic_only: Integer;
            const minimum_confidence: Single;
            const output_suffix_text: PAnsiChar;
            const output_suffix_text_capacity: Integer;
            const output_suffix_pinyin: PAnsiChar;
            const output_suffix_pinyin_capacity: Integer;
            const output_suffix_path: PAnsiChar;
            const output_suffix_path_capacity: Integer;
            const output_base_rank: PInteger;
            const output_replace_units: PInteger;
            const output_confidence: PSingle;
            const error_text: PAnsiChar;
            const error_capacity: Integer): Integer; cdecl;
        TncLcRunPool = function(const handle: Pointer;
            const context, query_syllables, top1_text, top1_path,
            top2_text, top2_path: PAnsiChar;
            const phonetic_only: Integer;
            const output_suffix_texts: PAnsiChar;
            const output_suffix_text_stride: Integer;
            const output_suffix_pinyins: PAnsiChar;
            const output_suffix_pinyin_stride: Integer;
            const output_suffix_paths: PAnsiChar;
            const output_suffix_path_stride: Integer;
            const output_base_ranks: PInteger;
            const output_replace_units: PInteger;
            const output_scores: PSingle;
            const output_capacity: Integer;
            const output_abstain_score: PSingle;
            const output_candidate_count: PInteger;
            const error_text: PAnsiChar;
            const error_capacity: Integer): Integer; cdecl;
        TncLcDestroy = procedure(const handle: Pointer); cdecl;
        TncLcgCreate = function(const model_path, index_path: PAnsiChar;
            const intra_threads: Integer; const error_text: PAnsiChar;
            const error_capacity: Integer): Pointer; cdecl;
        TncLcgRun = function(const handle: Pointer;
            const context, query_syllables, top1_text, top2_text: PAnsiChar;
            const minimum_confidence: Single;
            const output_suffix_text: PAnsiChar;
            const output_suffix_text_capacity: Integer;
            const output_suffix_pinyin: PAnsiChar;
            const output_suffix_pinyin_capacity: Integer;
            const output_suffix_path: PAnsiChar;
            const output_suffix_path_capacity: Integer;
            const output_confidence: PSingle;
            const error_text: PAnsiChar;
            const error_capacity: Integer): Integer; cdecl;
        TncLcgDestroy = procedure(const handle: Pointer); cdecl;
        TncReleaseIdlePages = procedure; cdecl;
    private
        FBaseDirectory: string;
        FLock: TCriticalSection;
        FWakeup: TEvent;
        FWorker: TncLocalCompletionWorker;
        FPendingTask: TncLocalCompletionTask;
        FHasPendingTask: Boolean;
        FPrefetchCache: TncLocalCompletionPrefetchCache;
        FFinished: TncLocalCompletionFinished;
        FHasFinished: Boolean;
        FModule: TLibHandle;
        FSession: Pointer;
        FGeneratorSession: Pointer;
        FRunFunction: TncLcRun;
        FRunPoolFunction: TncLcRunPool;
        FDestroyFunction: TncLcDestroy;
        FGeneratorRunFunction: TncLcgRun;
        FGeneratorDestroyFunction: TncLcgDestroy;
        FReleaseIdlePages: TncReleaseIdlePages;
        FMinimumConfidence: Single;
        FResultTimeoutMs: QWord;
        FModelThreads: Integer;
        FCaptureCandidatePool: Boolean;
        FCharLm: IncCharLm;
        FReady: Boolean;
        FLoadFinished: Boolean;
        FLastError: string;
        procedure WorkerExecute;
        procedure LoadRuntime;
        function PopTask(out task: TncLocalCompletionTask): Boolean;
        function RunModel(const task: TncLocalCompletionTask;
            out output: TncLocalCompletionModelOutput): Boolean;
        function FinishTask(const task: TncLocalCompletionTask;
            const output: TncLocalCompletionModelOutput;
            out completion_result: TncLongNeuralCompletionResult): Boolean;
        procedure StoreFinished(const task: TncLocalCompletionTask;
            const accepted: Boolean;
            const completion_result: TncLongNeuralCompletionResult);
        procedure Disable(const error_text: string);
    public
        constructor Create(const base_directory: string;
            const result_timeout_ms: QWord = c_nc_local_completion_result_timeout_ms;
            const model_threads: Integer = 0;
            const capture_candidate_pool: Boolean = False);
        destructor Destroy; override;
        function Enqueue(const task: TncLocalCompletionTask): Boolean;
        function TryPopFinishedFor(const context_id: QWord;
            out finished: TncLocalCompletionFinished): Boolean;
        function Ready: Boolean;
        function GeneratorReady: Boolean;
        function LoadFinished: Boolean;
        function LastError: string;
        procedure ReleaseIdlePages;
        procedure set_char_lm(const model: IncCharLm);
    end;

implementation

uses
    Math,
    fpjson,
    jsonparser,
    nc_pinyin_parser,
    nc_types;

const
    c_model_threads = 4;
    c_generator_minimum_confidence: Single = -2.8333864;
    c_completion_pool_capacity = 32;
    c_completion_text_stride = 512;
    c_completion_pinyin_stride = 1024;
    c_completion_path_stride = 512;

function join_path(const base_path, child_path: string): string;
begin
    Result := IncludeTrailingPathDelimiter(base_path) + child_path;
end;

procedure TncLocalCompletionPrefetchCache.Clear;
begin
    FValid := False;
    FTask := Default(TncLocalCompletionTask);
    FOutput := Default(TncLocalCompletionModelOutput);
end;

procedure TncLocalCompletionPrefetchCache.Remember(const task: TncLocalCompletionTask;
    const output: TncLocalCompletionModelOutput);
begin
    Clear;
    if not task.prefetch_only then Exit;
    FTask := task;
    FOutput := output;
    FValid := True;
end;

function TncLocalCompletionPrefetchCache.Take(const task: TncLocalCompletionTask;
    out output: TncLocalCompletionModelOutput): Boolean;
begin
    Result := FValid and not task.prefetch_only and
        (task.context_id = FTask.context_id) and
        (task.generation_id = FTask.generation_id) and
        (task.request.query_prefix = FTask.request.query_prefix) and
        (task.request.query_syllables = FTask.request.query_syllables) and
        (task.request.context_text = FTask.request.context_text) and
        (task.request.phonetic_only = FTask.request.phonetic_only) and
        (task.request.top1_text = FTask.request.top1_text) and
        (task.request.top1_path = FTask.request.top1_path) and
        (task.request.top1_anchor_path = FTask.request.top1_anchor_path) and
        (task.request.top2_text = FTask.request.top2_text) and
        (task.request.top2_path = FTask.request.top2_path) and
        (task.request.top2_anchor_path = FTask.request.top2_anchor_path);
    output := Default(TncLocalCompletionModelOutput);
    if Result then
    begin
        output := FOutput;
    end;
    // One worker-owned slot, consumed at most once by the matching real request.
    Clear;
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
    const result_timeout_ms: QWord; const model_threads: Integer;
    const capture_candidate_pool: Boolean);
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
    FGeneratorSession := nil;
    FRunFunction := nil;
    FRunPoolFunction := nil;
    FDestroyFunction := nil;
    FGeneratorRunFunction := nil;
    FGeneratorDestroyFunction := nil;
    FMinimumConfidence := 0.0;
    FResultTimeoutMs := result_timeout_ms;
    FCaptureCandidatePool := capture_candidate_pool;
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
    if (FGeneratorSession <> nil) and
        Assigned(FGeneratorDestroyFunction) then
    begin
        FGeneratorDestroyFunction(FGeneratorSession);
        FGeneratorSession := nil;
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
    generator_model_path: string;
    index_path: string;
    manifest_path: string;
    root_data: TJSONData;
    root_object: TJSONObject;
    gate_object: TJSONObject;
    dev_object: TJSONObject;
    index_object: TJSONObject;
    generator_object: TJSONObject;
    model_file: string;
    index_file: string;
    model_hash: string;
    vocab_hash: string;
    index_hash: string;
    index_vocab_hash: string;
    generator_hash: string;
    create_function: TncLcCreate;
    generator_create_function: TncLcgCreate;
    error_buffer: array[0..511] of AnsiChar;
    model_path_utf8: UTF8String;
    generator_model_path_utf8: UTF8String;
    index_path_utf8: UTF8String;
begin
    wrapper_path := join_path(FBaseDirectory,
        'libcassotis_pinyin_transformer_ort.so');
    model_directory := join_path(FBaseDirectory, 'local_completion');
    model_path := join_path(model_directory,
        'local_completion_path_ranker_int8.onnx');
    generator_model_path := join_path(model_directory,
        'local_completion_generator_int8.onnx');
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
            (FMinimumConfidence < -1000.0) or
            (FMinimumConfidence > 1000.0) then
            raise EInvalidOp.Create('local-completion threshold is invalid');
        model_hash := LowerCase(root_object.Get('model_sha256', ''));
        vocab_hash := LowerCase(root_object.Get('vocab_sha256', ''));
        index_object := root_object.Find('runtime_index') as TJSONObject;
        if index_object = nil then
            raise EInvalidOp.Create('local-completion index identity is absent');
        index_file := index_object.Get('file', '');
        index_hash := LowerCase(index_object.Get('sha256', ''));
        index_vocab_hash := LowerCase(index_object.Get('vocab_sha256', ''));
        generator_object := root_object.Find(
            'fallback_generator') as TJSONObject;
        generator_hash := '';
        if generator_object <> nil then
            generator_hash := LowerCase(generator_object.Get(
                'model_sha256', ''));
        if (not SameText(index_file, ExtractFileName(index_path))) or
            (Length(model_hash) <> 64) or (Length(vocab_hash) <> 64) or
            (Length(index_hash) <> 64) or
            (not SameText(vocab_hash, index_vocab_hash)) then
            raise EInvalidOp.Create('local-completion asset identity is invalid');
        if FileExists(generator_model_path) and
            (Length(generator_hash) <> 64) then
            raise EInvalidOp.Create(
                'local-completion generator identity is invalid');
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
    FRunPoolFunction := TncLcRunPool(GetProcedureAddress(FModule,
        'nc_lc_run_pool'));
    FDestroyFunction := TncLcDestroy(GetProcedureAddress(FModule,
        'nc_lc_destroy'));
    generator_create_function := TncLcgCreate(GetProcedureAddress(FModule,
        'nc_lcg_create'));
    FGeneratorRunFunction := TncLcgRun(GetProcedureAddress(FModule,
        'nc_lcg_run'));
    FGeneratorDestroyFunction := TncLcgDestroy(GetProcedureAddress(FModule,
        'nc_lcg_destroy'));
    FReleaseIdlePages := TncReleaseIdlePages(GetProcedureAddress(FModule,
        'nc_release_idle_index_pages'));
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
    if FileExists(generator_model_path) and
        Assigned(generator_create_function) and
        Assigned(FGeneratorRunFunction) and
        Assigned(FGeneratorDestroyFunction) then
    begin
        FillChar(error_buffer, SizeOf(error_buffer), 0);
        generator_model_path_utf8 := UTF8Encode(generator_model_path);
        FGeneratorSession := generator_create_function(
            PAnsiChar(generator_model_path_utf8), PAnsiChar(index_path_utf8),
            FModelThreads, @error_buffer[0], Length(error_buffer));
    end;
    FLock.Acquire;
    try
        FReady := True;
        FLoadFinished := True;
        FLastError := '';
    finally
        FLock.Release;
    end;
    if GetEnvironmentVariable('CASSOTIS_LOCAL_COMPLETION_PROFILE') = '1' then
    begin
        WriteLn(StdErr, '[INFO] local-completion INT8 models loaded in background');
        Flush(StdErr);
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

function TncLocalCompletionHost.RunModel(
    const task: TncLocalCompletionTask;
    out output: TncLocalCompletionModelOutput): Boolean;
var
    completion_result: TncLongNeuralCompletionResult;
    char_lm: IncCharLm;
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
    replace_units: Integer;
    confidence: Single;
    pool_suffix_texts: array[0..
        c_completion_pool_capacity * c_completion_text_stride - 1] of AnsiChar;
    pool_suffix_pinyins: array[0..
        c_completion_pool_capacity * c_completion_pinyin_stride - 1] of AnsiChar;
    pool_suffix_paths: array[0..
        c_completion_pool_capacity * c_completion_path_stride - 1] of AnsiChar;
    pool_base_ranks: array[0..c_completion_pool_capacity - 1] of Integer;
    pool_replace_units: array[0..c_completion_pool_capacity - 1] of Integer;
    pool_scores: array[0..c_completion_pool_capacity - 1] of Single;
    pool_abstain_score: Single;
    pool_candidate_count: Integer;
    pool_idx: Integer;
    second_score: Single;
    started_at: QWord;
begin
    output := Default(TncLocalCompletionModelOutput);
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
    replace_units := 0;
    confidence := 0.0;
    pool_abstain_score := 0.0;
    pool_candidate_count := 0;
    started_at := GetTickCount64;
    FLock.Acquire;
    try
        char_lm := FCharLm;
    finally FLock.Release; end;
    output.use_pool := (FCaptureCandidatePool or (char_lm <> nil)) and
        Assigned(FRunPoolFunction);
    if output.use_pool then
    begin
        FillChar(pool_suffix_texts, SizeOf(pool_suffix_texts), 0);
        FillChar(pool_suffix_pinyins, SizeOf(pool_suffix_pinyins), 0);
        FillChar(pool_suffix_paths, SizeOf(pool_suffix_paths), 0);
        FillChar(pool_base_ranks, SizeOf(pool_base_ranks), 0);
        FillChar(pool_replace_units, SizeOf(pool_replace_units), 0);
        FillChar(pool_scores, SizeOf(pool_scores), 0);
        if FRunPoolFunction(FSession,
            PAnsiChar(context_utf8), PAnsiChar(query_utf8),
            PAnsiChar(top1_text_utf8), PAnsiChar(top1_path_utf8),
            PAnsiChar(top2_text_utf8), PAnsiChar(top2_path_utf8),
            Ord(task.request.phonetic_only),
            @pool_suffix_texts[0], c_completion_text_stride,
            @pool_suffix_pinyins[0], c_completion_pinyin_stride,
            @pool_suffix_paths[0], c_completion_path_stride,
            @pool_base_ranks[0], @pool_replace_units[0], @pool_scores[0],
            c_completion_pool_capacity, @pool_abstain_score,
            @pool_candidate_count, @error_buffer[0],
            Length(error_buffer)) <> 0 then
        begin
            pool_candidate_count := EnsureRange(pool_candidate_count, 0,
                c_completion_pool_capacity);
            completion_result.abstain_score := pool_abstain_score;
            SetLength(completion_result.candidates, pool_candidate_count);
            for pool_idx := 0 to pool_candidate_count - 1 do
            begin
                completion_result.candidates[pool_idx].suffix_text :=
                    UTF8Decode(UTF8String(PAnsiChar(@pool_suffix_texts[
                    pool_idx * c_completion_text_stride])));
                completion_result.candidates[pool_idx].suffix_pinyin_path :=
                    UTF8Decode(UTF8String(PAnsiChar(@pool_suffix_pinyins[
                    pool_idx * c_completion_pinyin_stride])));
                completion_result.candidates[pool_idx].suffix_path :=
                    UTF8Decode(UTF8String(PAnsiChar(@pool_suffix_paths[
                    pool_idx * c_completion_path_stride])));
                completion_result.candidates[pool_idx].base_rank :=
                    pool_base_ranks[pool_idx];
                completion_result.candidates[pool_idx].replace_units :=
                    pool_replace_units[pool_idx];
                completion_result.candidates[pool_idx].score :=
                    pool_scores[pool_idx];
            end;
            Result := pool_candidate_count > 0;
            if Result then
            begin
                second_score := pool_abstain_score;
                if pool_candidate_count > 1 then
                    second_score := Max(second_score, pool_scores[1]);
                confidence := pool_scores[0] - second_score;
                Result := confidence >= FMinimumConfidence;
                if Result then
                begin
                    completion_result.suffix_text :=
                        completion_result.candidates[0].suffix_text;
                    completion_result.suffix_pinyin_path :=
                        completion_result.candidates[0].suffix_pinyin_path;
                    completion_result.suffix_path :=
                        completion_result.candidates[0].suffix_path;
                    completion_result.base_rank :=
                        completion_result.candidates[0].base_rank;
                    completion_result.replace_units :=
                        completion_result.candidates[0].replace_units;
                    completion_result.confidence := confidence;
                end;
            end;
        end
        else
            Result := False;
    end
    else
    begin
        Result := FRunFunction(FSession,
            PAnsiChar(context_utf8), PAnsiChar(query_utf8),
            PAnsiChar(top1_text_utf8), PAnsiChar(top1_path_utf8),
            PAnsiChar(top2_text_utf8), PAnsiChar(top2_path_utf8),
            Ord(task.request.phonetic_only), FMinimumConfidence,
            @suffix_text[0], Length(suffix_text),
            @suffix_pinyin[0], Length(suffix_pinyin),
            @suffix_path[0], Length(suffix_path), @base_rank,
            @replace_units, @confidence, @error_buffer[0],
            Length(error_buffer)) <> 0;
    end;
    if (not Result) and (not task.request.phonetic_only) and
        (error_buffer[0] = #0) and
        (FGeneratorSession <> nil) and
        Assigned(FGeneratorRunFunction) then
    begin
        FillChar(suffix_text, SizeOf(suffix_text), 0);
        FillChar(suffix_pinyin, SizeOf(suffix_pinyin), 0);
        FillChar(suffix_path, SizeOf(suffix_path), 0);
        confidence := 0.0;
        Result := FGeneratorRunFunction(FGeneratorSession,
            PAnsiChar(context_utf8), PAnsiChar(query_utf8),
            PAnsiChar(top1_text_utf8), PAnsiChar(top2_text_utf8),
            c_generator_minimum_confidence,
            @suffix_text[0], Length(suffix_text),
            @suffix_pinyin[0], Length(suffix_pinyin),
            @suffix_path[0], Length(suffix_path),
            @confidence, @error_buffer[0], Length(error_buffer)) <> 0;
        if Result then
        begin
            base_rank := 1;
            replace_units := 0;
            output.generated := True;
        end;
    end;
    output.elapsed_ms := GetTickCount64 - started_at;
    if (not Result) and (error_buffer[0] <> #0) then
    begin
        output.failed := True;
        Disable(ansi_buffer_text(error_buffer));
        Exit;
    end;
    output.accepted := Result;
    output.result := completion_result;
    output.suffix_text := ansi_buffer_text(suffix_text);
    output.suffix_pinyin := ansi_buffer_text(suffix_pinyin);
    output.suffix_path := ansi_buffer_text(suffix_path);
    output.base_rank := base_rank;
    output.replace_units := replace_units;
    output.confidence := confidence;
end;

// A tail word's first replace_units syllables are exactly the last typed
// syllables (the word does not lengthen a syllable that may still be typed).
function tail_reread_is_exact(const query_syllables, word_pinyin, word_text: string;
    const replace_units: Integer): Boolean;
var
    typed: TArray<string>;
    parsed: TncPinyinParseResult;
    parser: TncPinyinParser;
    idx: Integer;
begin
    Result := False;
    typed := query_syllables.Split([''''], TStringSplitOptions.ExcludeEmpty);
    if (replace_units < 1) or (replace_units > Length(typed)) then
        Exit;
    parser := TncPinyinParser.create;
    try
        parsed := parser.parse(LowerCase(StringReplace(StringReplace(word_pinyin,
            #3, '', [rfReplaceAll]), '''', '', [rfReplaceAll])));
    finally
        parser.Free;
    end;
    if Length(parsed) <> nc_char_lm_code_point_count(word_text) then
        Exit;
    for idx := 0 to replace_units - 1 do
        if not SameText(parsed[idx].text, typed[Length(typed) - replace_units + idx]) then
            Exit;
    Result := True;
end;

function TncLocalCompletionHost.FinishTask(const task: TncLocalCompletionTask;
    const output: TncLocalCompletionModelOutput;
    out completion_result: TncLongNeuralCompletionResult): Boolean;
var
    started_at: UInt64;
    char_lm: IncCharLm;

    // Replaces the ranker/generator decision with the character LM policy.
    // Leaves the decision untouched when the LM cannot score (busy, not ready).
    procedure apply_char_lm_policy;
    var
        candidates: TArray<TncCharLmContinuation>;
        sources: TArray<Integer>;
        item, chosen: TncCharLmContinuation;
        base, next_char: string;
        idx, other, best: Integer;
        probability: Double;
    begin
        // Tail words from the engine join the pool after the model's ranked
        // candidates, so reports see them and results can refer to them.
        for idx := 0 to High(task.request.tail_candidates) do
        begin
            other := 0;
            while (other < Length(completion_result.candidates)) and
                ((completion_result.candidates[other].replace_units <>
                task.request.tail_candidates[idx].replace_units) or
                (completion_result.candidates[other].base_rank <> 1) or
                (completion_result.candidates[other].suffix_text <>
                task.request.tail_candidates[idx].suffix_text)) do
                Inc(other);
            if other = Length(completion_result.candidates) then
            begin
                SetLength(completion_result.candidates, other + 1);
                completion_result.candidates[other] := task.request.tail_candidates[idx];
            end;
        end;
        for idx := 0 to High(completion_result.candidates) do
        begin
            case completion_result.candidates[idx].base_rank of
                1: base := task.request.top1_text;
                2: base := task.request.top2_text;
            else
                Continue;
            end;
            if (base = '') or (completion_result.candidates[idx].suffix_text = '') or
                (completion_result.candidates[idx].replace_units < 0) or
                (completion_result.candidates[idx].replace_units >= Length(base)) then
                Continue;
            item := Default(TncCharLmContinuation);
            item.base_text := Copy(base, 1, Length(base) -
                completion_result.candidates[idx].replace_units);
            item.suffix_text := completion_result.candidates[idx].suffix_text;
            item.full_base_text := base;
            item.base_rank := completion_result.candidates[idx].base_rank;
            item.replace_units := completion_result.candidates[idx].replace_units;
            if completion_result.candidates[idx].tail_word then
            begin
                item.tail_word := True;
                item.tail_rank := completion_result.candidates[idx].tail_rank;
                item.exact_reread := tail_reread_is_exact(task.request.query_syllables,
                    completion_result.candidates[idx].suffix_pinyin_path,
                    item.suffix_text, item.replace_units);
            end
            else
            begin
                item.rank := idx + 1;
                item.score := completion_result.candidates[idx].score;
                item.abstain_score := completion_result.abstain_score;
            end;
            SetLength(candidates, Length(candidates) + 1);
            candidates[High(candidates)] := item;
            SetLength(sources, Length(sources) + 1);
            sources[High(sources)] := idx;
        end;
        if output.generated and (task.request.top1_text <> '') and (output.suffix_text <> '') then
        begin
            item := Default(TncCharLmContinuation);
            item.base_text := task.request.top1_text;
            item.suffix_text := output.suffix_text;
            item.full_base_text := task.request.top1_text;
            item.base_rank := 1;
            item.generator := True;
            idx := 0;
            while (idx < Length(candidates)) and (candidates[idx].base_text +
                candidates[idx].suffix_text <> item.base_text + item.suffix_text) do
                Inc(idx);
            if idx = Length(candidates) then
            begin
                SetLength(candidates, Length(candidates) + 1);
            candidates[High(candidates)] := item;
                SetLength(sources, Length(sources) + 1);
            sources[High(sources)] := -1;
            end;
        end;
        if (Length(candidates) = 0) or not nc_char_lm_choose_continuation(char_lm,
            task.request.context_text, candidates, task.request.phonetic_only, chosen, best,
            probability) then
            Exit;
        completion_result.suffix_text := '';
        completion_result.suffix_pinyin_path := '';
        completion_result.suffix_path := '';
        completion_result.base_rank := 0;
        completion_result.replace_units := 0;
        completion_result.lm_next := False;
        completion_result.confidence := probability;
        Result := probability >= c_char_lm_tab_min_probability;
        if not Result then
            Exit;
        if best < 0 then
        begin
            // An LM next character: the engine reads it and checks the re-read
            // typed tail before showing it.
            next_char := Copy(chosen.suffix_text, chosen.replace_units + 1, MaxInt);
            completion_result.suffix_text := chosen.suffix_text;
            completion_result.suffix_path := next_char;
            if chosen.replace_units > 0 then
                completion_result.suffix_path := Copy(chosen.suffix_text, 1,
                    chosen.replace_units) + #3 + next_char;
            completion_result.base_rank := chosen.base_rank;
            completion_result.replace_units := chosen.replace_units;
            completion_result.lm_next := True;
        end
        else if sources[best] >= 0 then
        begin
            completion_result.suffix_text := completion_result.candidates[sources[best]].suffix_text;
            completion_result.suffix_pinyin_path :=
                completion_result.candidates[sources[best]].suffix_pinyin_path;
            completion_result.suffix_path := completion_result.candidates[sources[best]].suffix_path;
            completion_result.base_rank := completion_result.candidates[sources[best]].base_rank;
            completion_result.replace_units := completion_result.candidates[sources[best]].replace_units;
        end
        else
        begin
            completion_result.suffix_text := output.suffix_text;
            completion_result.suffix_pinyin_path := output.suffix_pinyin;
            completion_result.suffix_path := output.suffix_path;
            completion_result.base_rank := 1;
        end;
    end;

begin
    Result := output.accepted;
    completion_result := output.result;
    if output.failed then
        Exit(False);
    started_at := GetTickCount64;
    FLock.Acquire;
    try
        char_lm := FCharLm;
    finally
        FLock.Release;
    end;
    if output.use_pool and (char_lm <> nil) then
    begin
        apply_char_lm_policy;
    end;
    // The deadline covers the model and the policy, prefetched or not.
    if Result and (FResultTimeoutMs > 0) and
        (output.elapsed_ms + (GetTickCount64 - started_at) > FResultTimeoutMs) then
    begin
        Result := False;
        Exit;
    end;
    if Result and (completion_result.suffix_text = '') then
    begin
        completion_result.suffix_text := output.suffix_text;
        completion_result.suffix_pinyin_path := output.suffix_pinyin;
        completion_result.suffix_path := output.suffix_path;
        completion_result.base_rank := output.base_rank;
        completion_result.replace_units := output.replace_units;
        completion_result.confidence := output.confidence;
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
    output: TncLocalCompletionModelOutput;
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
        if task.prefetch_only then
        begin
            RunModel(task, output);
            FPrefetchCache.Remember(task, output);
            if not Ready then Break;
            Continue;
        end;
        if not FPrefetchCache.Take(task, output) then RunModel(task, output);
        accepted := FinishTask(task, output, completion_result);
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

procedure TncLocalCompletionHost.ReleaseIdlePages;
begin
    // Never wait for loading or start a runtime merely to reclaim memory.
    // This owner keeps the native module alive until the service stops.
    if not FLock.TryEnter then Exit;
    try
        if FReady and Assigned(FReleaseIdlePages) then FReleaseIdlePages();
    finally
        FLock.Leave;
    end;
end;

procedure TncLocalCompletionHost.set_char_lm(const model: IncCharLm);
begin
    FLock.Acquire;
    try
        FCharLm := model;
    finally FLock.Release; end;
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

function TncLocalCompletionHost.GeneratorReady: Boolean;
begin
    FLock.Acquire;
    try
        Result := FGeneratorSession <> nil;
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
