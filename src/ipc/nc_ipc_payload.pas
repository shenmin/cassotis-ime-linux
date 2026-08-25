unit nc_ipc_payload;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    nc_types;

const
    c_ipc_payload_schema_version = 1;
    c_ipc_engine_state_fuzzy_schema_version = 2;
    c_ipc_engine_state_shortcuts_schema_version = 3;
    c_ipc_engine_state_schema_version = 4;
    c_ipc_payload_max_text_bytes = 1024 * 1024;
    c_ipc_payload_max_candidates = 256;

type
    EncIpcPayloadError = class(Exception);

    TncIpcEngineState = TncEngineState;

function nc_encode_set_active_payload(const active: Boolean): TBytes;
function nc_try_decode_set_active_payload(const payload: TBytes;
    out active: Boolean; out error_text: string): Boolean;

function nc_encode_surrounding_payload(const text: string;
    const cursor_offset: Integer): TBytes;
function nc_try_decode_surrounding_payload(const payload: TBytes;
    out text: string; out cursor_offset: Integer;
    out error_text: string): Boolean;

function nc_encode_key_event_payload(const key_event: TncKeyEvent): TBytes;
function nc_try_decode_key_event_payload(const payload: TBytes;
    out key_event: TncKeyEvent; out error_text: string): Boolean;

function nc_encode_engine_result_payload(const engine_result: TncEngineResult):
    TBytes;
function nc_try_decode_engine_result_payload(const payload: TBytes;
    out engine_result: TncEngineResult; out error_text: string): Boolean;

function nc_encode_engine_state_payload(const state: TncIpcEngineState): TBytes;
function nc_try_decode_engine_state_payload(const payload: TBytes;
    out state: TncIpcEngineState; out error_text: string): Boolean;

function nc_encode_error_payload(const error_code: Cardinal;
    const error_message: string): TBytes;
function nc_try_decode_error_payload(const payload: TBytes;
    out error_code: Cardinal; out error_message: string;
    out decode_error: string): Boolean;

implementation

uses
    nc_shortcut;

const
    c_key_flag_release = $00000001;
    c_key_flag_repeat = $00000002;
    c_key_known_flags = c_key_flag_release or c_key_flag_repeat;
    c_state_flag_full_width = $01;
    c_state_flag_punctuation_full_width = $02;
    c_state_flag_fuzzy_pinyin_enabled = $04;
    c_state_flag_debug_mode = $08;
    c_state_known_flags = c_state_flag_full_width or
        c_state_flag_punctuation_full_width or
        c_state_flag_fuzzy_pinyin_enabled or c_state_flag_debug_mode;
    c_shortcut_flag_shift = $01;
    c_shortcut_flag_control = $02;
    c_shortcut_flag_alt = $04;
    c_shortcut_known_flags = c_shortcut_flag_shift or
        c_shortcut_flag_control or c_shortcut_flag_alt;

type
    TncIpcPayloadWriter = class
    private
        FData: TBytes;
    public
        procedure AppendByte(const value: Byte);
        procedure WriteByte(const value: Byte);
        procedure WriteBoolean(const value: Boolean);
        procedure WriteUInt16(const value: Word);
        procedure WriteUInt32(const value: Cardinal);
        procedure WriteInt32(const value: Integer);
        procedure WriteUInt64(const value: QWord);
        procedure WriteString(const value: string);
        function Finish: TBytes;
    end;

    TncIpcPayloadReader = class
    private
        FData: TBytes;
        FPosition: SizeInt;
        FErrorText: string;
        function Require(const byte_count: SizeInt): Boolean;
        procedure SetError(const value: string);
    public
        constructor Create(const data: TBytes);
        function ReadByte(out value: Byte): Boolean;
        function ReadBoolean(out value: Boolean): Boolean;
        function ReadUInt16(out value: Word): Boolean;
        function ReadUInt32(out value: Cardinal): Boolean;
        function ReadInt32(out value: Integer): Boolean;
        function ReadUInt64(out value: QWord): Boolean;
        function ReadString(out value: string): Boolean;
        function Finish(out error_text: string): Boolean;
    end;

procedure WriteShortcut(const writer: TncIpcPayloadWriter;
    const shortcut: TncShortcut);
var
    flags: Byte;
begin
    flags := 0;
    if shortcut.shift_down then
        flags := flags or c_shortcut_flag_shift;
    if shortcut.ctrl_down then
        flags := flags or c_shortcut_flag_control;
    if shortcut.alt_down then
        flags := flags or c_shortcut_flag_alt;
    writer.WriteUInt16(shortcut.key_code);
    writer.WriteByte(flags);
    writer.WriteByte(0);
end;

function ReadShortcut(const reader: TncIpcPayloadReader;
    out shortcut: TncShortcut): Boolean;
var
    flags: Byte;
    reserved: Byte;
begin
    shortcut := Default(TncShortcut);
    Result := reader.ReadUInt16(shortcut.key_code) and
        reader.ReadByte(flags) and reader.ReadByte(reserved);
    if not Result then
        Exit;
    if (reserved <> 0) or ((flags and not c_shortcut_known_flags) <> 0) then
    begin
        reader.SetError('State payload contains invalid shortcut flags');
        Exit(False);
    end;
    shortcut.shift_down := (flags and c_shortcut_flag_shift) <> 0;
    shortcut.ctrl_down := (flags and c_shortcut_flag_control) <> 0;
    shortcut.alt_down := (flags and c_shortcut_flag_alt) <> 0;
end;

function ShortcutConfigIsValid(const config: TncShortcutConfig): Boolean;
var
    action: TncShortcutAction;
begin
    if config.signature <> c_nc_shortcut_config_signature then
        Exit(False);
    for action := Low(TncShortcutAction) to High(TncShortcutAction) do
        if not nc_shortcut_is_valid(nc_shortcut_for_action(config,
            action)) then
            Exit(False);
    Result := not nc_shortcut_config_has_duplicates(config);
end;

procedure TncIpcPayloadWriter.AppendByte(const value: Byte);
var
    count: SizeInt;
begin
    count := Length(FData);
    SetLength(FData, count + 1);
    FData[count] := value;
end;

procedure TncIpcPayloadWriter.WriteBoolean(const value: Boolean);
begin
    if value then
        AppendByte(1)
    else
        AppendByte(0);
end;

procedure TncIpcPayloadWriter.WriteByte(const value: Byte);
begin
    AppendByte(value);
end;

procedure TncIpcPayloadWriter.WriteUInt16(const value: Word);
begin
    AppendByte(Byte(value and $FF));
    AppendByte(Byte((value shr 8) and $FF));
end;

procedure TncIpcPayloadWriter.WriteUInt32(const value: Cardinal);
var
    index: Integer;
begin
    for index := 0 to 3 do
        AppendByte(Byte((value shr (index * 8)) and $FF));
end;

procedure TncIpcPayloadWriter.WriteInt32(const value: Integer);
begin
    WriteUInt32(Cardinal(value));
end;

procedure TncIpcPayloadWriter.WriteUInt64(const value: QWord);
var
    index: Integer;
begin
    for index := 0 to 7 do
        AppendByte(Byte((value shr (index * 8)) and $FF));
end;

procedure TncIpcPayloadWriter.WriteString(const value: string);
var
    encoded: UTF8String;
    old_count: SizeInt;
begin
    encoded := UTF8Encode(value);
    if Length(encoded) > c_ipc_payload_max_text_bytes then
        raise EncIpcPayloadError.Create('IPC text value exceeds the byte limit');
    WriteUInt32(Cardinal(Length(encoded)));
    if Length(encoded) = 0 then
        Exit;
    old_count := Length(FData);
    SetLength(FData, old_count + Length(encoded));
    Move(encoded[1], FData[old_count], Length(encoded));
end;

function TncIpcPayloadWriter.Finish: TBytes;
begin
    Result := Copy(FData, 0, Length(FData));
end;

constructor TncIpcPayloadReader.Create(const data: TBytes);
begin
    inherited Create;
    FData := data;
    FPosition := 0;
    FErrorText := '';
end;

procedure TncIpcPayloadReader.SetError(const value: string);
begin
    if FErrorText = '' then
        FErrorText := value;
end;

function TncIpcPayloadReader.Require(const byte_count: SizeInt): Boolean;
begin
    Result := (byte_count >= 0) and
        (QWord(FPosition) + QWord(byte_count) <= QWord(Length(FData)));
    if not Result then
        SetError('IPC payload is truncated');
end;

function TncIpcPayloadReader.ReadByte(out value: Byte): Boolean;
begin
    value := 0;
    if not Require(1) then
        Exit(False);
    value := FData[FPosition];
    Inc(FPosition);
    Result := True;
end;

function TncIpcPayloadReader.ReadBoolean(out value: Boolean): Boolean;
var
    encoded: Byte;
begin
    value := False;
    if not ReadByte(encoded) then
        Exit(False);
    if encoded > 1 then
    begin
        SetError('IPC payload contains an invalid boolean');
        Exit(False);
    end;
    value := encoded = 1;
    Result := True;
end;

function TncIpcPayloadReader.ReadUInt16(out value: Word): Boolean;
begin
    value := 0;
    if not Require(2) then
        Exit(False);
    value := Word(FData[FPosition]) or
        (Word(FData[FPosition + 1]) shl 8);
    Inc(FPosition, 2);
    Result := True;
end;

function TncIpcPayloadReader.ReadUInt32(out value: Cardinal): Boolean;
var
    index: Integer;
begin
    value := 0;
    if not Require(4) then
        Exit(False);
    for index := 0 to 3 do
        value := value or (Cardinal(FData[FPosition + index]) shl
            (index * 8));
    Inc(FPosition, 4);
    Result := True;
end;

function TncIpcPayloadReader.ReadInt32(out value: Integer): Boolean;
var
    encoded: Cardinal;
begin
    value := 0;
    Result := ReadUInt32(encoded);
    if Result then
        value := Integer(encoded);
end;

function TncIpcPayloadReader.ReadUInt64(out value: QWord): Boolean;
var
    index: Integer;
begin
    value := 0;
    if not Require(8) then
        Exit(False);
    for index := 0 to 7 do
        value := value or (QWord(FData[FPosition + index]) shl
            (index * 8));
    Inc(FPosition, 8);
    Result := True;
end;

function IsValidUtf8(const data: TBytes; const offset: SizeInt;
    const byte_count: SizeInt): Boolean;
var
    index: SizeInt;
    last: SizeInt;
    first: Byte;
    second: Byte;

    function IsContinuation(const value: Byte): Boolean;
    begin
        Result := (value and $C0) = $80;
    end;

begin
    index := offset;
    last := offset + byte_count;
    while index < last do
    begin
        first := data[index];
        if first <= $7F then
        begin
            Inc(index);
            Continue;
        end;
        if (first >= $C2) and (first <= $DF) then
        begin
            if (index + 1 >= last) or
                (not IsContinuation(data[index + 1])) then
                Exit(False);
            Inc(index, 2);
            Continue;
        end;
        if (first >= $E0) and (first <= $EF) then
        begin
            if (index + 2 >= last) or
                (not IsContinuation(data[index + 1])) or
                (not IsContinuation(data[index + 2])) then
                Exit(False);
            second := data[index + 1];
            if ((first = $E0) and (second < $A0)) or
                ((first = $ED) and (second > $9F)) then
                Exit(False);
            Inc(index, 3);
            Continue;
        end;
        if (first >= $F0) and (first <= $F4) then
        begin
            if (index + 3 >= last) or
                (not IsContinuation(data[index + 1])) or
                (not IsContinuation(data[index + 2])) or
                (not IsContinuation(data[index + 3])) then
                Exit(False);
            second := data[index + 1];
            if ((first = $F0) and (second < $90)) or
                ((first = $F4) and (second > $8F)) then
                Exit(False);
            Inc(index, 4);
            Continue;
        end;
        Exit(False);
    end;
    Result := True;
end;

function TncIpcPayloadReader.ReadString(out value: string): Boolean;
var
    byte_count: Cardinal;
    encoded: UTF8String;
begin
    encoded := '';
    value := '';
    if not ReadUInt32(byte_count) then
        Exit(False);
    if byte_count > c_ipc_payload_max_text_bytes then
    begin
        SetError('IPC text value exceeds the byte limit');
        Exit(False);
    end;
    if not Require(byte_count) then
        Exit(False);
    if not IsValidUtf8(FData, FPosition, byte_count) then
    begin
        SetError('IPC text value is not valid UTF-8');
        Exit(False);
    end;
    if byte_count > 0 then
    begin
        SetLength(encoded, byte_count);
        Move(FData[FPosition], encoded[1], byte_count);
        value := UTF8Decode(encoded);
    end;
    Inc(FPosition, byte_count);
    Result := True;
end;

function TncIpcPayloadReader.Finish(out error_text: string): Boolean;
begin
    if (FErrorText = '') and (FPosition <> Length(FData)) then
        SetError('IPC payload contains trailing bytes');
    error_text := FErrorText;
    Result := FErrorText = '';
end;

procedure WritePayloadHeader(const writer: TncIpcPayloadWriter);
begin
    writer.WriteUInt16(c_ipc_payload_schema_version);
    writer.WriteUInt16(0);
end;

procedure WritePayloadHeaderVersion(const writer: TncIpcPayloadWriter;
    const version: Word);
begin
    writer.WriteUInt16(version);
    writer.WriteUInt16(0);
end;

function ReadPayloadHeaderVersion(const reader: TncIpcPayloadReader;
    out version: Word): Boolean;
var
    reserved: Word;
begin
    version := 0;
    Result := reader.ReadUInt16(version) and reader.ReadUInt16(reserved);
    if not Result then
        Exit;
    if (version < c_ipc_payload_schema_version) or
        (version > c_ipc_engine_state_schema_version) then
    begin
        reader.SetError('Unsupported IPC payload schema version');
        Exit(False);
    end;
    if reserved <> 0 then
    begin
        reader.SetError('IPC payload reserved field must be zero');
        Exit(False);
    end;
end;

function ReadPayloadHeader(const reader: TncIpcPayloadReader): Boolean;
var
    version: Word;
begin
    Result := ReadPayloadHeaderVersion(reader, version);
    if Result and (version <> c_ipc_payload_schema_version) then
    begin
        reader.SetError('Unsupported IPC payload schema version');
        Result := False;
    end;
end;

function KeyModifiersToMask(const modifiers: TncKeyModifiers): Cardinal;
var
    modifier: TncKeyModifier;
begin
    Result := 0;
    for modifier := Low(TncKeyModifier) to High(TncKeyModifier) do
        if modifier in modifiers then
            Result := Result or (Cardinal(1) shl Ord(modifier));
end;

function KnownMask(const highest_ordinal: Integer): Cardinal;
begin
    if highest_ordinal >= 31 then
        Result := High(Cardinal)
    else
        Result := (Cardinal(1) shl (highest_ordinal + 1)) - 1;
end;

function nc_encode_set_active_payload(const active: Boolean): TBytes;
var
    writer: TncIpcPayloadWriter;
begin
    writer := TncIpcPayloadWriter.Create;
    try
        WritePayloadHeader(writer);
        writer.WriteBoolean(active);
        Result := writer.Finish;
    finally
        writer.Free;
    end;
end;

function nc_try_decode_set_active_payload(const payload: TBytes;
    out active: Boolean; out error_text: string): Boolean;
var
    reader: TncIpcPayloadReader;
begin
    active := False;
    reader := TncIpcPayloadReader.Create(payload);
    try
        Result := ReadPayloadHeader(reader) and reader.ReadBoolean(active) and
            reader.Finish(error_text);
        if not Result then
            reader.Finish(error_text);
    finally
        reader.Free;
    end;
end;

function nc_encode_surrounding_payload(const text: string;
    const cursor_offset: Integer): TBytes;
var
    writer: TncIpcPayloadWriter;
begin
    if cursor_offset < 0 then
        raise EncIpcPayloadError.Create('Surrounding cursor offset is negative');
    writer := TncIpcPayloadWriter.Create;
    try
        WritePayloadHeader(writer);
        writer.WriteInt32(cursor_offset);
        writer.WriteString(text);
        Result := writer.Finish;
    finally
        writer.Free;
    end;
end;

function nc_try_decode_surrounding_payload(const payload: TBytes;
    out text: string; out cursor_offset: Integer;
    out error_text: string): Boolean;
var
    reader: TncIpcPayloadReader;
begin
    text := '';
    cursor_offset := 0;
    reader := TncIpcPayloadReader.Create(payload);
    try
        Result := ReadPayloadHeader(reader) and
            reader.ReadInt32(cursor_offset) and reader.ReadString(text);
        if Result and (cursor_offset < 0) then
        begin
            reader.SetError('Surrounding cursor offset is negative');
            Result := False;
        end;
        Result := Result and reader.Finish(error_text);
        if not Result then
            reader.Finish(error_text);
    finally
        reader.Free;
    end;
end;

function nc_encode_key_event_payload(const key_event: TncKeyEvent): TBytes;
var
    writer: TncIpcPayloadWriter;
    flags: Cardinal;
begin
    writer := TncIpcPayloadWriter.Create;
    try
        WritePayloadHeader(writer);
        writer.WriteUInt16(Ord(key_event.special_key));
        writer.WriteUInt16(0);
        writer.WriteUInt32(KeyModifiersToMask(key_event.modifiers));
        writer.WriteUInt32(key_event.scan_code);
        flags := 0;
        if key_event.is_release then
            flags := flags or c_key_flag_release;
        if key_event.is_repeat then
            flags := flags or c_key_flag_repeat;
        writer.WriteUInt32(flags);
        writer.WriteUInt64(key_event.timestamp_ms);
        writer.WriteString(key_event.text);
        Result := writer.Finish;
    finally
        writer.Free;
    end;
end;

function nc_try_decode_key_event_payload(const payload: TBytes;
    out key_event: TncKeyEvent; out error_text: string): Boolean;
var
    reader: TncIpcPayloadReader;
    special_key: Word;
    reserved: Word;
    modifier_mask: Cardinal;
    flags: Cardinal;
    modifier: TncKeyModifier;
begin
    key_event.text := '';
    key_event.special_key := sk_none;
    key_event.modifiers := [];
    key_event.scan_code := 0;
    key_event.is_release := False;
    key_event.is_repeat := False;
    key_event.timestamp_ms := 0;
    reader := TncIpcPayloadReader.Create(payload);
    try
        Result := ReadPayloadHeader(reader) and
            reader.ReadUInt16(special_key) and reader.ReadUInt16(reserved) and
            reader.ReadUInt32(modifier_mask) and
            reader.ReadUInt32(key_event.scan_code) and
            reader.ReadUInt32(flags) and
            reader.ReadUInt64(key_event.timestamp_ms) and
            reader.ReadString(key_event.text);
        if Result and (reserved <> 0) then
        begin
            reader.SetError('Key payload reserved field must be zero');
            Result := False;
        end;
        if Result and (special_key > Ord(High(TncSpecialKey))) then
        begin
            reader.SetError('Key payload contains an invalid special key');
            Result := False;
        end;
        if Result and ((modifier_mask and not KnownMask(
            Ord(High(TncKeyModifier)))) <> 0) then
        begin
            reader.SetError('Key payload contains invalid modifiers');
            Result := False;
        end;
        if Result and ((flags and not c_key_known_flags) <> 0) then
        begin
            reader.SetError('Key payload contains invalid flags');
            Result := False;
        end;
        if Result then
        begin
            key_event.special_key := TncSpecialKey(special_key);
            for modifier := Low(TncKeyModifier) to High(TncKeyModifier) do
                if (modifier_mask and (Cardinal(1) shl Ord(modifier))) <> 0 then
                    Include(key_event.modifiers, modifier);
            key_event.is_release := (flags and c_key_flag_release) <> 0;
            key_event.is_repeat := (flags and c_key_flag_repeat) <> 0;
        end;
        Result := Result and reader.Finish(error_text);
        if not Result then
            reader.Finish(error_text);
    finally
        reader.Free;
    end;
end;

function nc_encode_engine_result_payload(const engine_result: TncEngineResult):
    TBytes;
var
    writer: TncIpcPayloadWriter;
    candidate: TncCandidate;
begin
    if Length(engine_result.candidates) > c_ipc_payload_max_candidates then
        raise EncIpcPayloadError.Create('Engine result has too many candidates');
    writer := TncIpcPayloadWriter.Create;
    try
        WritePayloadHeader(writer);
        writer.WriteBoolean(engine_result.handled);
        writer.WriteUInt16(0);
        writer.WriteByte(0);
        writer.WriteInt32(engine_result.selected_index);
        writer.WriteInt32(engine_result.page_index);
        writer.WriteInt32(engine_result.page_count);
        writer.WriteUInt32(engine_result.error_code);
        writer.WriteString(engine_result.commit_text);
        writer.WriteString(engine_result.preedit_text);
        writer.WriteString(engine_result.query_text);
        writer.WriteString(engine_result.completion_text);
        writer.WriteString(engine_result.error_text);
        writer.WriteUInt32(Length(engine_result.candidates));
        for candidate in engine_result.candidates do
        begin
            writer.WriteByte(Ord(candidate.source));
            writer.WriteByte(Ord(candidate.display_kind));
            writer.WriteBoolean(candidate.has_dict_weight);
            writer.WriteBoolean(candidate.deletable);
            writer.WriteInt32(candidate.score);
            writer.WriteInt32(candidate.dict_weight);
            writer.WriteInt32(candidate.fuzzy_cost);
            writer.WriteUInt32(nc_fuzzy_pinyin_rules_to_mask(
                candidate.fuzzy_rules));
            writer.WriteString(candidate.text);
            writer.WriteString(candidate.comment);
        end;
        Result := writer.Finish;
    finally
        writer.Free;
    end;
end;

function nc_try_decode_engine_result_payload(const payload: TBytes;
    out engine_result: TncEngineResult; out error_text: string): Boolean;
var
    reader: TncIpcPayloadReader;
    reserved16: Word;
    reserved8: Byte;
    candidate_count: Cardinal;
    candidate_index: Integer;
    source: Byte;
    display_kind: Byte;
    fuzzy_mask: Cardinal;
    rule: TncFuzzyPinyinRule;
begin
    nc_initialize_engine_result(engine_result);
    candidate_count := 0;
    reader := TncIpcPayloadReader.Create(payload);
    try
        Result := ReadPayloadHeader(reader) and
            reader.ReadBoolean(engine_result.handled) and
            reader.ReadUInt16(reserved16) and reader.ReadByte(reserved8) and
            reader.ReadInt32(engine_result.selected_index) and
            reader.ReadInt32(engine_result.page_index) and
            reader.ReadInt32(engine_result.page_count) and
            reader.ReadUInt32(engine_result.error_code) and
            reader.ReadString(engine_result.commit_text) and
            reader.ReadString(engine_result.preedit_text) and
            reader.ReadString(engine_result.query_text) and
            reader.ReadString(engine_result.completion_text) and
            reader.ReadString(engine_result.error_text) and
            reader.ReadUInt32(candidate_count);
        if Result and ((reserved16 <> 0) or (reserved8 <> 0)) then
        begin
            reader.SetError('Engine result reserved fields must be zero');
            Result := False;
        end;
        if Result and (candidate_count > c_ipc_payload_max_candidates) then
        begin
            reader.SetError('Engine result has too many candidates');
            Result := False;
        end;
        if Result and ((engine_result.selected_index < -1) or
            (engine_result.page_index < 0) or (engine_result.page_count < 0)) then
        begin
            reader.SetError('Engine result contains invalid paging values');
            Result := False;
        end;
        if Result then
            SetLength(engine_result.candidates, candidate_count);
        for candidate_index := 0 to Integer(candidate_count) - 1 do
        begin
            if not Result then
                Break;
            Result := reader.ReadByte(source) and reader.ReadByte(display_kind) and
                reader.ReadBoolean(engine_result.candidates[candidate_index].has_dict_weight) and
                reader.ReadBoolean(engine_result.candidates[candidate_index].deletable) and
                reader.ReadInt32(engine_result.candidates[candidate_index].score) and
                reader.ReadInt32(engine_result.candidates[candidate_index].dict_weight) and
                reader.ReadInt32(engine_result.candidates[candidate_index].fuzzy_cost) and
                reader.ReadUInt32(fuzzy_mask) and
                reader.ReadString(engine_result.candidates[candidate_index].text) and
                reader.ReadString(engine_result.candidates[candidate_index].comment);
            if Result and (source > Ord(High(TncCandidateSource))) then
            begin
                reader.SetError('Engine result contains an invalid candidate source');
                Result := False;
            end;
            if Result and (display_kind > Ord(High(TncCandidateDisplayKind))) then
            begin
                reader.SetError('Engine result contains an invalid display kind');
                Result := False;
            end;
            if Result and ((fuzzy_mask and not KnownMask(
                Ord(High(TncFuzzyPinyinRule)))) <> 0) then
            begin
                reader.SetError('Engine result contains invalid fuzzy rules');
                Result := False;
            end;
            if Result then
            begin
                engine_result.candidates[candidate_index].source :=
                    TncCandidateSource(source);
                engine_result.candidates[candidate_index].display_kind :=
                    TncCandidateDisplayKind(display_kind);
                engine_result.candidates[candidate_index].fuzzy_rules := [];
                for rule := Low(TncFuzzyPinyinRule) to
                    High(TncFuzzyPinyinRule) do
                    if (fuzzy_mask and (Cardinal(1) shl Ord(rule))) <> 0 then
                        Include(engine_result.candidates[candidate_index].fuzzy_rules,
                            rule);
            end;
        end;
        Result := Result and reader.Finish(error_text);
        if not Result then
        begin
            reader.Finish(error_text);
            nc_initialize_engine_result(engine_result);
        end;
    finally
        reader.Free;
    end;
end;

function nc_encode_engine_state_payload(const state: TncIpcEngineState): TBytes;
var
    writer: TncIpcPayloadWriter;
    flags: Byte;
begin
    writer := TncIpcPayloadWriter.Create;
    try
        WritePayloadHeaderVersion(writer, c_ipc_engine_state_schema_version);
        writer.WriteByte(Ord(state.input_mode));
        writer.WriteByte(Ord(state.dictionary_variant));
        writer.WriteByte(Ord(state.pinyin_scheme));
        flags := 0;
        if state.full_width_mode then
            flags := flags or c_state_flag_full_width;
        if state.punctuation_full_width then
            flags := flags or c_state_flag_punctuation_full_width;
        if state.fuzzy_pinyin_enabled then
            flags := flags or c_state_flag_fuzzy_pinyin_enabled;
        if state.debug_mode then
            flags := flags or c_state_flag_debug_mode;
        writer.WriteByte(flags);
        writer.WriteUInt32(nc_fuzzy_pinyin_rules_to_mask(
            state.fuzzy_pinyin_rules));
        writer.WriteByte(Ord(state.candidate_page_key_scheme));
        writer.WriteByte(Ord(state.one_key_completion_key));
        writer.WriteByte(Byte(state.candidate_page_size));
        writer.WriteByte(0);
        WriteShortcut(writer, state.shortcuts.input_mode_toggle);
        WriteShortcut(writer, state.shortcuts.punctuation_toggle);
        WriteShortcut(writer, state.shortcuts.dictionary_variant_toggle);
        WriteShortcut(writer, state.shortcuts.full_width_toggle);
        WriteShortcut(writer, state.shortcuts.open_settings);
        Result := writer.Finish;
    finally
        writer.Free;
    end;
end;

function nc_try_decode_engine_state_payload(const payload: TBytes;
    out state: TncIpcEngineState; out error_text: string): Boolean;
var
    reader: TncIpcPayloadReader;
    input_mode: Byte;
    dictionary_variant: Byte;
    pinyin_scheme: Byte;
    flags: Byte;
    version: Word;
    fuzzy_rules_mask: Cardinal;
    candidate_page_key_scheme: Byte;
    one_key_completion_key: Byte;
    candidate_page_size: Byte;
    reserved: Word;
    reserved_byte: Byte;
begin
    nc_initialize_engine_state(state);
    reader := TncIpcPayloadReader.Create(payload);
    try
        fuzzy_rules_mask := 0;
        candidate_page_key_scheme := Ord(state.candidate_page_key_scheme);
        one_key_completion_key := Ord(state.one_key_completion_key);
        candidate_page_size := Byte(state.candidate_page_size);
        reserved := 0;
        reserved_byte := 0;
        Result := ReadPayloadHeaderVersion(reader, version) and
            reader.ReadByte(input_mode) and
            reader.ReadByte(dictionary_variant) and
            reader.ReadByte(pinyin_scheme) and reader.ReadByte(flags);
        if Result and (version >= c_ipc_engine_state_fuzzy_schema_version) then
            Result := reader.ReadUInt32(fuzzy_rules_mask);
        if Result and
            (version >= c_ipc_engine_state_shortcuts_schema_version) then
        begin
            state.shortcuts.signature := c_nc_shortcut_config_signature;
            Result := reader.ReadByte(candidate_page_key_scheme) and
                reader.ReadByte(one_key_completion_key);
            if Result and (version >= c_ipc_engine_state_schema_version) then
                Result := reader.ReadByte(candidate_page_size) and
                    reader.ReadByte(reserved_byte)
            else if Result then
                Result := reader.ReadUInt16(reserved);
            Result := Result and
                ReadShortcut(reader, state.shortcuts.input_mode_toggle) and
                ReadShortcut(reader, state.shortcuts.punctuation_toggle) and
                ReadShortcut(reader,
                state.shortcuts.dictionary_variant_toggle) and
                ReadShortcut(reader, state.shortcuts.full_width_toggle) and
                ReadShortcut(reader, state.shortcuts.open_settings);
        end;
        if Result and (input_mode > Ord(High(TncInputMode))) then
        begin
            reader.SetError('State payload contains an invalid input mode');
            Result := False;
        end;
        if Result and (dictionary_variant > Ord(High(TncDictionaryVariant))) then
        begin
            reader.SetError('State payload contains an invalid dictionary variant');
            Result := False;
        end;
        if Result and (pinyin_scheme > Ord(High(TncPinyinInputScheme))) then
        begin
            reader.SetError('State payload contains an invalid pinyin scheme');
            Result := False;
        end;
        if Result and ((flags and not c_state_known_flags) <> 0) then
        begin
            reader.SetError('State payload contains invalid flags');
            Result := False;
        end;
        if Result and (version = c_ipc_payload_schema_version) and
            ((flags and c_state_flag_fuzzy_pinyin_enabled) <> 0) then
        begin
            reader.SetError('State payload v1 contains invalid flags');
            Result := False;
        end;
        if Result and (version < c_ipc_engine_state_schema_version) and
            ((flags and c_state_flag_debug_mode) <> 0) then
        begin
            reader.SetError('State payload contains flags unsupported by its schema');
            Result := False;
        end;
        if Result and
            (not nc_fuzzy_pinyin_rules_mask_is_valid(fuzzy_rules_mask)) then
        begin
            reader.SetError('State payload contains invalid fuzzy rules');
            Result := False;
        end;
        if Result and
            (candidate_page_key_scheme >
            Ord(High(TncCandidatePageKeyScheme))) then
        begin
            reader.SetError('State payload contains invalid candidate page keys');
            Result := False;
        end;
        if Result and
            (one_key_completion_key > Ord(High(TncOneKeyCompletionKey))) then
        begin
            reader.SetError('State payload contains invalid completion key');
            Result := False;
        end;
        if Result and ((reserved <> 0) or (reserved_byte <> 0)) then
        begin
            reader.SetError('State payload contains invalid reserved data');
            Result := False;
        end;
        if Result and ((candidate_page_size < c_min_candidate_page_size) or
            (candidate_page_size > c_max_candidate_page_size)) then
        begin
            reader.SetError('State payload contains an invalid candidate page size');
            Result := False;
        end;
        if Result then
        begin
            state.input_mode := TncInputMode(input_mode);
            state.dictionary_variant := TncDictionaryVariant(dictionary_variant);
            state.pinyin_scheme := TncPinyinInputScheme(pinyin_scheme);
            state.full_width_mode := (flags and c_state_flag_full_width) <> 0;
            state.punctuation_full_width :=
                (flags and c_state_flag_punctuation_full_width) <> 0;
            state.fuzzy_pinyin_enabled :=
                (flags and c_state_flag_fuzzy_pinyin_enabled) <> 0;
            state.fuzzy_pinyin_rules :=
                nc_fuzzy_pinyin_rules_from_mask(fuzzy_rules_mask);
            state.candidate_page_size := candidate_page_size;
            state.candidate_page_key_scheme :=
                TncCandidatePageKeyScheme(candidate_page_key_scheme);
            state.one_key_completion_key :=
                TncOneKeyCompletionKey(one_key_completion_key);
            state.debug_mode := (flags and c_state_flag_debug_mode) <> 0;
            if nc_candidate_page_key_conflicts_with_one_key_completion(
                state.candidate_page_key_scheme,
                state.one_key_completion_key) then
            begin
                reader.SetError('State payload contains conflicting page and completion keys');
                Result := False;
            end
            else if not ShortcutConfigIsValid(state.shortcuts) then
            begin
                reader.SetError('State payload contains invalid shortcuts');
                Result := False;
            end;
        end;
        Result := Result and reader.Finish(error_text);
        if not Result then
            reader.Finish(error_text);
    finally
        reader.Free;
    end;
end;

function nc_encode_error_payload(const error_code: Cardinal;
    const error_message: string): TBytes;
var
    writer: TncIpcPayloadWriter;
begin
    writer := TncIpcPayloadWriter.Create;
    try
        WritePayloadHeader(writer);
        writer.WriteUInt32(error_code);
        writer.WriteString(error_message);
        Result := writer.Finish;
    finally
        writer.Free;
    end;
end;

function nc_try_decode_error_payload(const payload: TBytes;
    out error_code: Cardinal; out error_message: string;
    out decode_error: string): Boolean;
var
    reader: TncIpcPayloadReader;
begin
    error_code := 0;
    error_message := '';
    reader := TncIpcPayloadReader.Create(payload);
    try
        Result := ReadPayloadHeader(reader) and reader.ReadUInt32(error_code) and
            reader.ReadString(error_message) and reader.Finish(decode_error);
        if not Result then
            reader.Finish(decode_error);
    finally
        reader.Free;
    end;
end;

end.
