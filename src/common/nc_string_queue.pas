unit nc_string_queue;

{$mode delphiunicode}
{$H+}

interface

type
    // FPC 3.2 TQueue retains consumed slots until it is explicitly compacted.
    // Reuse slots so a bounded FIFO stays bounded through repeated evictions.
    TncStringQueue = class
    private
        FItems: array of string;
        FHead, FCount: SizeInt;
        procedure Grow;
        function GetCapacity: SizeInt;
    public
        procedure Enqueue(const value: string);
        function Dequeue: string;
        function Peek: string;
        procedure Clear;
        property Count: SizeInt read FCount;
        property Capacity: SizeInt read GetCapacity;
    end;

implementation

uses SysUtils;

procedure TncStringQueue.Grow;
var
    items: array of string;
    capacity, i: SizeInt;
begin
    if Length(FItems) > High(SizeInt) div 2 then
        raise EOutOfMemory.Create('String queue capacity exhausted');
    capacity := Length(FItems) * 2;
    if capacity < 4 then capacity := 4;
    SetLength(items, capacity);
    for i := 0 to FCount - 1 do
        items[i] := FItems[(FHead + i) and (Length(FItems) - 1)];
    FItems := items;
    FHead := 0;
end;

procedure TncStringQueue.Enqueue(const value: string);
begin
    if FCount = Length(FItems) then Grow;
    FItems[(FHead + FCount) and (Length(FItems) - 1)] := value;
    Inc(FCount);
end;

function TncStringQueue.Dequeue: string;
begin
    Result := Peek;
    FItems[FHead] := '';
    FHead := (FHead + 1) and (Length(FItems) - 1);
    Dec(FCount);
    if FCount = 0 then FHead := 0;
end;

function TncStringQueue.Peek: string;
begin
    if FCount = 0 then
        raise EArgumentOutOfRangeException.Create('String queue is empty');
    Result := FItems[FHead];
end;

procedure TncStringQueue.Clear;
begin
    FItems := nil;
    FHead := 0;
    FCount := 0;
end;

function TncStringQueue.GetCapacity: SizeInt;
begin
    Result := Length(FItems);
end;

end.
