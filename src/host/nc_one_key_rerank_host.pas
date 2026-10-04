unit nc_one_key_rerank_host;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Classes, SyncObjs, nc_char_lm, nc_engine_intf;

type
    TncOneKeyRerankTask = record
        context_id, generation_id: QWord;
        request: TncOneKeyRerankRequest;
    end;

    TncOneKeyRerankFinished = record
        task: TncOneKeyRerankTask;
        chosen: Integer;
    end;

    TncOneKeyRerankHost = class;
    TncOneKeyRerankWorker = class(TThread)
    private
        FOwner: TncOneKeyRerankHost;
    protected
        procedure Execute; override;
    public
        constructor Create(const owner: TncOneKeyRerankHost);
    end;

    TncOneKeyRerankHost = class
    private
        FLock: TCriticalSection;
        FWakeup: TEvent;
        FWorker: TncOneKeyRerankWorker;
        FPending: TncOneKeyRerankTask;
        FFinished: TncOneKeyRerankFinished;
        FHasPending, FHasFinished, FStopping: Boolean;
        FCharLm: IncCharLm;
        procedure Execute;
        function Pop(out task: TncOneKeyRerankTask; out model: IncCharLm): Boolean;
    public
        constructor Create;
        destructor Destroy; override;
        procedure set_char_lm(const model: IncCharLm);
        function Enqueue(const task: TncOneKeyRerankTask): Boolean;
        function TryPopFinishedFor(const context_id: QWord;
            out finished: TncOneKeyRerankFinished): Boolean;
    end;

implementation

constructor TncOneKeyRerankWorker.Create(const owner: TncOneKeyRerankHost);
begin
    inherited Create(True);
    FreeOnTerminate := False;
    FOwner := owner;
end;

procedure TncOneKeyRerankWorker.Execute;
begin
    FOwner.Execute;
end;

constructor TncOneKeyRerankHost.Create;
begin
    inherited Create;
    FLock := TCriticalSection.Create;
    FWakeup := TEvent.Create(nil, False, False, '');
    FWorker := TncOneKeyRerankWorker.Create(Self);
    FWorker.Priority := tpLower;
    FWorker.Start;
end;

destructor TncOneKeyRerankHost.Destroy;
begin
    FLock.Acquire;
    try
        FStopping := True;
        FHasPending := False;
    finally FLock.Release; end;
    FWorker.Terminate;
    FWakeup.SetEvent;
    FWorker.WaitFor;
    FWorker.Free;
    FCharLm := nil;
    FWakeup.Free;
    FLock.Free;
    inherited;
end;

procedure TncOneKeyRerankHost.set_char_lm(const model: IncCharLm);
begin
    FLock.Acquire;
    try FCharLm := model; finally FLock.Release; end;
end;

function TncOneKeyRerankHost.Enqueue(const task: TncOneKeyRerankTask): Boolean;
begin
    Result := False;
    if (task.context_id = 0) or (Length(task.request.candidates) < 2) then Exit;
    FLock.Acquire;
    try
        if FStopping then Exit;
        // Bound queued work and retained candidate strings to one snapshot.
        FPending := task;
        FHasPending := True;
        FFinished := Default(TncOneKeyRerankFinished);
        FHasFinished := False;
        Result := True;
    finally FLock.Release; end;
    FWakeup.SetEvent;
end;

function TncOneKeyRerankHost.Pop(out task: TncOneKeyRerankTask;
    out model: IncCharLm): Boolean;
begin
    task := Default(TncOneKeyRerankTask);
    model := nil;
    FLock.Acquire;
    try
        Result := FHasPending and not FStopping;
        if Result then
        begin
            task := FPending;
            model := FCharLm;
            FPending := Default(TncOneKeyRerankTask);
            FHasPending := False;
        end;
    finally FLock.Release; end;
end;

function TncOneKeyRerankHost.TryPopFinishedFor(const context_id: QWord;
    out finished: TncOneKeyRerankFinished): Boolean;
begin
    finished := Default(TncOneKeyRerankFinished);
    FLock.Acquire;
    try
        Result := FHasFinished and (FFinished.task.context_id = context_id);
        if Result then
        begin
            finished := FFinished;
            FFinished := Default(TncOneKeyRerankFinished);
            FHasFinished := False;
        end;
    finally FLock.Release; end;
end;

procedure TncOneKeyRerankHost.Execute;
var task: TncOneKeyRerankTask; model: IncCharLm; chosen: Integer;
begin
    while not FWorker.Terminated do
    begin
        FWakeup.WaitFor(INFINITE);
        while Pop(task, model) do
        begin
            chosen := -1;
            try
                if (model = nil) or not nc_char_lm_choose_completion(model,
                    task.request.context, task.request.candidates,
                    task.request.incumbent, task.request.typed_units, chosen) then
                    chosen := -1;
            except
                // A failed optional rerank must not terminate the service.
                chosen := -1;
            end;
            FLock.Acquire;
            try
                if not FStopping and not FHasPending then
                begin
                    FFinished.task := task;
                    FFinished.chosen := chosen;
                    FHasFinished := True;
                end;
            finally FLock.Release; end;
            task := Default(TncOneKeyRerankTask);
            model := nil;
        end;
    end;
end;

end.
