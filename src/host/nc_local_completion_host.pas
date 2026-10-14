unit nc_local_completion_host;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Classes, SyncObjs, nc_engine_intf, nc_char_lm;

const c_nc_local_completion_result_timeout_ms = 120;

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
    private
        FLock: TCriticalSection;
        FWakeup: TEvent;
        FWorker: TncLocalCompletionWorker;
        FPendingTask: TncLocalCompletionTask;
        FHasPendingTask: Boolean;
        FFinished: TncLocalCompletionFinished;
        FHasFinished: Boolean;
        FResultTimeoutMs: QWord;
        FCharLm: IncCharLm;
        procedure WorkerExecute;
        function PopTask(out task: TncLocalCompletionTask): Boolean;
        function RunTask(const task: TncLocalCompletionTask;
            out completion_result: TncLongNeuralCompletionResult): Boolean;
        procedure StoreFinished(const task: TncLocalCompletionTask;
            const accepted: Boolean;
            const completion_result: TncLongNeuralCompletionResult);
    public
        constructor Create(const result_timeout_ms: QWord = c_nc_local_completion_result_timeout_ms);
        destructor Destroy; override;
        function Enqueue(const task: TncLocalCompletionTask): Boolean;
        function TryPopFinishedFor(const context_id: QWord;
            out finished: TncLocalCompletionFinished): Boolean;
        function Ready: Boolean;
        procedure set_char_lm(const model: IncCharLm);
    end;

implementation

uses nc_pinyin_parser, nc_types;

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

constructor TncLocalCompletionHost.Create(const result_timeout_ms: QWord);
begin
    inherited Create;
    FLock := TCriticalSection.Create;
    FWakeup := TEvent.Create(nil, False, False, '');
    FResultTimeoutMs := result_timeout_ms;
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
    end;
    FWakeup.Free;
    FLock.Free;
    inherited Destroy;
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

function TncLocalCompletionHost.RunTask(const task: TncLocalCompletionTask;
    out completion_result: TncLongNeuralCompletionResult): Boolean;
var
    started_at: UInt64;
    char_lm: IncCharLm;
    candidates: TArray<TncCharLmContinuation>;
    sources: TArray<Integer>;
    item, chosen: TncCharLmContinuation;
    base, next_char: string;
    idx, best: Integer;
    probability: Double;
begin
    Result := False;
    completion_result := Default(TncLongNeuralCompletionResult);
    FLock.Acquire;
    try
        char_lm := FCharLm;
    finally
        FLock.Release;
    end;
    if char_lm = nil then
        Exit;
    started_at := GetTickCount64;
    // The engine's tail and next words stay on the result, so reports see
    // them and the chosen one can be returned with its reading.
    completion_result.candidates := Copy(task.request.tail_candidates);
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
        item.tail_rank := completion_result.candidates[idx].tail_rank;
        item.exact_reread := tail_reread_is_exact(task.request.query_syllables,
            completion_result.candidates[idx].suffix_pinyin_path,
            item.suffix_text, item.replace_units);
        candidates := candidates + [item];
        sources := sources + [idx];
    end;
    if ((Length(candidates) = 0) and (task.request.top1_text = '')) or
        not nc_char_lm_choose_continuation(char_lm, task.request.context_text,
        candidates, task.request.phonetic_only,
        [task.request.top1_text, task.request.top2_text], chosen, best, probability) then
        Exit;
    completion_result.confidence := probability;
    if probability < c_char_lm_tab_min_probability then
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
    else
    begin
        idx := sources[best];
        completion_result.suffix_text := completion_result.candidates[idx].suffix_text;
        completion_result.suffix_pinyin_path := completion_result.candidates[idx].suffix_pinyin_path;
        completion_result.suffix_path := completion_result.candidates[idx].suffix_path;
        completion_result.base_rank := completion_result.candidates[idx].base_rank;
        completion_result.replace_units := completion_result.candidates[idx].replace_units;
    end;
    // The LM's confident continuation follows, so that a word is not cut after
    // its first character; the engine reads it from the dictionary.
    if chosen.lm_next then
        completion_result.extension := nc_char_lm_extend_continuation(char_lm,
            task.request.context_text, chosen.base_text + chosen.suffix_text,
            c_char_lm_tab_extend_lm_next_probability)
    else
        completion_result.extension := nc_char_lm_extend_continuation(char_lm,
            task.request.context_text, chosen.base_text + chosen.suffix_text,
            c_char_lm_tab_extend_word_probability);
    Result := (FResultTimeoutMs = 0) or
        (GetTickCount64 - started_at <= FResultTimeoutMs);
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
var task: TncLocalCompletionTask; result: TncLongNeuralCompletionResult; accepted: Boolean;
begin
    while not FWorker.Terminated do
    begin
        if not PopTask(task) then
        begin
            FWakeup.WaitFor(250);
            Continue;
        end;
        if FWorker.Terminated then Break;
        try
            accepted := RunTask(task, result);
        except
            on E: Exception do
            begin
                accepted := False;
                result := Default(TncLongNeuralCompletionResult);
                WriteLn(StdErr, '[WARN] Tab continuation: ', E.Message);
            end;
        end;
        StoreFinished(task, accepted, result);
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
        if FCharLm = nil then
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

procedure TncLocalCompletionHost.set_char_lm(const model: IncCharLm);
begin
    FLock.Acquire;
    try
        FCharLm := model;
    finally FLock.Release; end;
end;

function TncLocalCompletionHost.Ready: Boolean;
var model: IncCharLm;
begin
    FLock.Acquire;
    try model := FCharLm; finally FLock.Release; end;
    Result := (model <> nil) and model.char_lm_ready;
end;

end.
