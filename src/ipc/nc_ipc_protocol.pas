unit nc_ipc_protocol;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    nc_version;

const
    c_ipc_header_size = 44;
    c_ipc_max_payload_size = 8 * 1024 * 1024;
    c_ipc_flag_response = $00000001;
    c_ipc_flag_error = $00000002;
    c_ipc_known_flags = c_ipc_flag_response or c_ipc_flag_error;

type
    TncIpcMessageType = (
        imt_invalid,
        imt_hello,
        imt_hello_ack,
        imt_ping,
        imt_pong,
        imt_create_context,
        imt_destroy_context,
        imt_reset_context,
        imt_set_active,
        imt_set_surrounding,
        imt_process_key,
        imt_engine_result,
        imt_get_state,
        imt_set_state,
        imt_shutdown,
        imt_error,
        imt_clear_user_dictionary
    );

    TncIpcEnvelope = record
        message_type: TncIpcMessageType;
        flags: Cardinal;
        request_id: QWord;
        context_id: QWord;
        generation_id: QWord;
        payload: TBytes;
    end;

    EncIpcProtocolError = class(Exception);

function nc_encode_ipc_frame(const envelope: TncIpcEnvelope): TBytes;
function nc_try_decode_ipc_frame(const buffer: TBytes;
    out envelope: TncIpcEnvelope; out consumed: SizeInt;
    out error_text: string): Boolean;
function nc_utf8_payload(const value: string): TBytes;
function nc_payload_as_string(const payload: TBytes): string;

implementation

procedure write_uint16_le(var target: TBytes; const offset: SizeInt;
    const value: Word);
begin
    target[offset] := Byte(value and $FF);
    target[offset + 1] := Byte((value shr 8) and $FF);
end;

procedure write_uint32_le(var target: TBytes; const offset: SizeInt;
    const value: Cardinal);
var
    index: Integer;
begin
    for index := 0 to 3 do
        target[offset + index] := Byte((value shr (index * 8)) and $FF);
end;

procedure write_uint64_le(var target: TBytes; const offset: SizeInt;
    const value: QWord);
var
    index: Integer;
begin
    for index := 0 to 7 do
        target[offset + index] := Byte((value shr (index * 8)) and $FF);
end;

function read_uint16_le(const source: TBytes; const offset: SizeInt): Word;
begin
    Result := Word(source[offset]) or (Word(source[offset + 1]) shl 8);
end;

function read_uint32_le(const source: TBytes;
    const offset: SizeInt): Cardinal;
var
    index: Integer;
begin
    Result := 0;
    for index := 0 to 3 do
        Result := Result or (Cardinal(source[offset + index]) shl (index * 8));
end;

function read_uint64_le(const source: TBytes; const offset: SizeInt): QWord;
var
    index: Integer;
begin
    Result := 0;
    for index := 0 to 7 do
        Result := Result or (QWord(source[offset + index]) shl (index * 8));
end;

function message_type_is_valid(const value: Word): Boolean;
begin
    Result := (value <= Ord(High(TncIpcMessageType))) and
        (value <> Ord(imt_invalid));
end;

procedure initialize_envelope(out envelope: TncIpcEnvelope);
begin
    envelope.message_type := imt_invalid;
    envelope.flags := 0;
    envelope.request_id := 0;
    envelope.context_id := 0;
    envelope.generation_id := 0;
    SetLength(envelope.payload, 0);
end;

function nc_encode_ipc_frame(const envelope: TncIpcEnvelope): TBytes;
var
    payload_length: SizeInt;
begin
    Result := nil;
    if envelope.message_type = imt_invalid then
        raise EncIpcProtocolError.Create('Cannot encode an invalid message type');
    if (envelope.flags and not c_ipc_known_flags) <> 0 then
        raise EncIpcProtocolError.Create('Cannot encode unknown IPC frame flags');
    if ((envelope.flags and c_ipc_flag_error) <> 0) and
        ((envelope.flags and c_ipc_flag_response) = 0) then
        raise EncIpcProtocolError.Create(
            'Cannot encode an IPC error without the response flag');

    payload_length := Length(envelope.payload);
    if payload_length > c_ipc_max_payload_size then
        raise EncIpcProtocolError.CreateFmt('IPC payload exceeds %d bytes',
            [c_ipc_max_payload_size]);

    SetLength(Result, c_ipc_header_size + payload_length);
    Result[0] := Ord('C');
    Result[1] := Ord('S');
    Result[2] := Ord('I');
    Result[3] := Ord('M');
    write_uint16_le(Result, 4, c_ipc_protocol_major);
    write_uint16_le(Result, 6, c_ipc_protocol_minor);
    write_uint16_le(Result, 8, Ord(envelope.message_type));
    write_uint16_le(Result, 10, 0);
    write_uint32_le(Result, 12, envelope.flags);
    write_uint64_le(Result, 16, envelope.request_id);
    write_uint64_le(Result, 24, envelope.context_id);
    write_uint64_le(Result, 32, envelope.generation_id);
    write_uint32_le(Result, 40, Cardinal(payload_length));

    if payload_length > 0 then
        Move(envelope.payload[0], Result[c_ipc_header_size], payload_length);
end;

function nc_try_decode_ipc_frame(const buffer: TBytes;
    out envelope: TncIpcEnvelope; out consumed: SizeInt;
    out error_text: string): Boolean;
var
    message_type_value: Word;
    payload_length: Cardinal;
    frame_length: QWord;
begin
    initialize_envelope(envelope);
    consumed := 0;
    error_text := '';
    Result := False;

    if Length(buffer) < 4 then
        Exit;

    if (buffer[0] <> Ord('C')) or (buffer[1] <> Ord('S')) or
        (buffer[2] <> Ord('I')) or (buffer[3] <> Ord('M')) then
    begin
        error_text := 'Invalid IPC frame magic';
        Exit;
    end;

    if Length(buffer) < c_ipc_header_size then
        Exit;

    if read_uint16_le(buffer, 4) <> c_ipc_protocol_major then
    begin
        error_text := 'Unsupported IPC protocol major version';
        Exit;
    end;

    if read_uint16_le(buffer, 6) > c_ipc_protocol_minor then
    begin
        error_text := 'Unsupported IPC protocol minor version';
        Exit;
    end;

    if read_uint16_le(buffer, 10) <> 0 then
    begin
        error_text := 'IPC frame reserved field must be zero';
        Exit;
    end;

    envelope.flags := read_uint32_le(buffer, 12);
    if (envelope.flags and not c_ipc_known_flags) <> 0 then
    begin
        error_text := 'IPC frame contains unknown flags';
        Exit;
    end;
    if ((envelope.flags and c_ipc_flag_error) <> 0) and
        ((envelope.flags and c_ipc_flag_response) = 0) then
    begin
        error_text := 'IPC error frame is missing the response flag';
        Exit;
    end;

    message_type_value := read_uint16_le(buffer, 8);
    if not message_type_is_valid(message_type_value) then
    begin
        error_text := 'Invalid IPC message type';
        Exit;
    end;

    payload_length := read_uint32_le(buffer, 40);
    if payload_length > c_ipc_max_payload_size then
    begin
        error_text := 'IPC payload exceeds the configured limit';
        Exit;
    end;

    frame_length := QWord(c_ipc_header_size) + payload_length;
    if QWord(Length(buffer)) < frame_length then
        Exit;

    envelope.message_type := TncIpcMessageType(message_type_value);
    envelope.request_id := read_uint64_le(buffer, 16);
    envelope.context_id := read_uint64_le(buffer, 24);
    envelope.generation_id := read_uint64_le(buffer, 32);
    SetLength(envelope.payload, payload_length);
    if payload_length > 0 then
        Move(buffer[c_ipc_header_size], envelope.payload[0], payload_length);

    consumed := SizeInt(frame_length);
    Result := True;
end;

function nc_utf8_payload(const value: string): TBytes;
var
    encoded: UTF8String;
begin
    Result := nil;
    encoded := UTF8Encode(value);
    SetLength(Result, Length(encoded));
    if Length(encoded) > 0 then
        Move(encoded[1], Result[0], Length(encoded));
end;

function nc_payload_as_string(const payload: TBytes): string;
var
    encoded: UTF8String;
begin
    encoded := '';
    SetLength(encoded, Length(payload));
    if Length(payload) > 0 then
        Move(payload[0], encoded[1], Length(payload));
    Result := UTF8Decode(encoded);
end;

end.
