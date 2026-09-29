unit nc_compact_string_map;

{$mode delphiunicode}
{$H+}

interface

type
    // Append/update/clear map for immutable model tables. UTF-16 keys share one
    // character pool instead of a separate managed allocation for every key.
    TncCompactStringIntMap = class
    private type
        TEntry = record
            Hash, Offset, KeyLength: Cardinal;
            Value: Integer;
        end;
    private
        FEntries: array of TEntry;
        FSlots: array of Cardinal;
        FData: array of WideChar;
        FCount, FUsed: SizeInt;
        class function HashKey(const key: string): Cardinal; static;
        function FindSlot(const key: string; const hash: Cardinal): SizeInt;
        procedure GrowSlots;
    public
        procedure Clear;
        procedure AddOrSetValue(const key: string; const value: Integer);
        function TryGetValue(const key: string; out value: Integer): Boolean;
        procedure TrimExcess;
        function AllocatedBytes: SizeUInt;
        property Count: SizeInt read FCount;
    end;

implementation

uses SysUtils;

{$PUSH}{$Q-}
class function TncCompactStringIntMap.HashKey(const key: string): Cardinal;
var i: SizeInt;
begin
    Result := 2166136261;
    for i := 1 to Length(key) do
        Result := (Result xor Ord(key[i])) * Cardinal(16777619);
end;
{$POP}

function TncCompactStringIntMap.FindSlot(const key: string;
    const hash: Cardinal): SizeInt;
var index: SizeInt;
begin
    Result := hash and (Length(FSlots) - 1);
    while FSlots[Result] <> 0 do
    begin
        index := FSlots[Result] - 1;
        if (FEntries[index].Hash = hash) and
            (FEntries[index].KeyLength = Cardinal(Length(key))) then
        begin
            if key = '' then Exit;
            if CompareByte(FData[FEntries[index].Offset], key[1],
                Length(key) * SizeOf(WideChar)) = 0 then Exit;
        end;
        Result := (Result + 1) and (Length(FSlots) - 1);
    end;
end;

procedure TncCompactStringIntMap.GrowSlots;
var size, i, slot: SizeInt;
begin
    size := Length(FSlots) * 2;
    if size < 16 then size := 16;
    SetLength(FSlots, size);
    FillChar(FSlots[0], size * SizeOf(Cardinal), 0);
    for i := 0 to FCount - 1 do
    begin
        slot := FEntries[i].Hash and (size - 1);
        while FSlots[slot] <> 0 do slot := (slot + 1) and (size - 1);
        FSlots[slot] := Cardinal(i + 1);
    end;
end;

procedure TncCompactStringIntMap.Clear;
begin
    FCount := 0;
    FUsed := 0;
    SetLength(FEntries, 0);
    SetLength(FSlots, 0);
    SetLength(FData, 0);
end;

procedure TncCompactStringIntMap.AddOrSetValue(const key: string;
    const value: Integer);
var hash: Cardinal; slot, capacity, required: SizeInt;
begin
    if (QWord(Length(key)) > High(Cardinal)) or
        (QWord(FUsed) + QWord(Length(key)) > High(Cardinal)) or
        (QWord(FCount) >= High(Cardinal) - 1) then
        raise ERangeError.Create('Compact model table exceeds index capacity');
    hash := HashKey(key);
    if Length(FSlots) = 0 then GrowSlots;
    slot := FindSlot(key, hash);
    if FSlots[slot] <> 0 then
    begin
        FEntries[FSlots[slot] - 1].Value := value;
        Exit;
    end;
    if (FCount + 1) * 3 >= Length(FSlots) * 2 then
    begin
        GrowSlots;
        slot := FindSlot(key, hash);
    end;
    if FCount = Length(FEntries) then
    begin
        capacity := FCount * 2;
        if capacity < 16 then capacity := 16;
        SetLength(FEntries, capacity);
    end;
    required := FUsed + Length(key);
    if required > Length(FData) then
    begin
        capacity := Length(FData) * 2;
        if capacity < 1024 then capacity := 1024;
        if capacity < required then capacity := required;
        SetLength(FData, capacity);
    end;
    FEntries[FCount].Hash := hash;
    FEntries[FCount].Offset := Cardinal(FUsed);
    FEntries[FCount].KeyLength := Cardinal(Length(key));
    FEntries[FCount].Value := value;
    if key <> '' then Move(key[1], FData[FUsed], Length(key) * SizeOf(WideChar));
    FUsed := required;
    FSlots[slot] := Cardinal(FCount + 1);
    Inc(FCount);
end;

function TncCompactStringIntMap.TryGetValue(const key: string;
    out value: Integer): Boolean;
var slot: SizeInt;
begin
    value := 0;
    if Length(FSlots) = 0 then Exit(False);
    slot := FindSlot(key, HashKey(key));
    Result := FSlots[slot] <> 0;
    if Result then value := FEntries[FSlots[slot] - 1].Value;
end;

procedure TncCompactStringIntMap.TrimExcess;
begin
    SetLength(FEntries, FCount);
    SetLength(FData, FUsed);
end;

function TncCompactStringIntMap.AllocatedBytes: SizeUInt;
begin
    Result := SizeUInt(Length(FEntries)) * SizeOf(TEntry) +
        SizeUInt(Length(FSlots)) * SizeOf(Cardinal) +
        SizeUInt(Length(FData)) * SizeOf(WideChar);
end;

end.
