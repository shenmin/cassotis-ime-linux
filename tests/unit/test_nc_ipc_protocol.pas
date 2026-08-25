unit test_nc_ipc_protocol;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    fpcunit,
    testregistry,
    nc_ipc_protocol;

type
    TncIpcProtocolTests = class(TTestCase)
    published
        procedure RoundTripsEnvelopeAndUnicodePayload;
        procedure WaitsForCompleteFrame;
        procedure RejectsInvalidMagic;
        procedure RejectsUnsupportedProtocolMajor;
        procedure RejectsReservedHeaderAndInvalidFlags;
        procedure RejectsInvalidOutboundFlags;
        procedure RejectsOversizedPayload;
        procedure ReportsBytesConsumedForFirstFrame;
    end;

implementation

procedure TncIpcProtocolTests.RoundTripsEnvelopeAndUnicodePayload;
var
    source: TncIpcEnvelope;
    decoded: TncIpcEnvelope;
    frame: TBytes;
    consumed: SizeInt;
    error_text: string;
begin
    source.message_type := imt_pong;
    source.flags := c_ipc_flag_response;
    source.request_id := 101;
    source.context_id := 202;
    source.generation_id := 303;
    source.payload := nc_utf8_payload('言泉输入法');

    frame := nc_encode_ipc_frame(source);
    AssertTrue(nc_try_decode_ipc_frame(frame, decoded, consumed, error_text));
    AssertEquals('', error_text);
    AssertEquals(Length(frame), consumed);
    AssertEquals(Ord(source.message_type), Ord(decoded.message_type));
    AssertEquals(Int64(source.flags), Int64(decoded.flags));
    AssertEquals(Int64(source.request_id), Int64(decoded.request_id));
    AssertEquals(Int64(source.context_id), Int64(decoded.context_id));
    AssertEquals(Int64(source.generation_id), Int64(decoded.generation_id));
    AssertEquals('言泉输入法', nc_payload_as_string(decoded.payload));
end;

procedure TncIpcProtocolTests.RejectsReservedHeaderAndInvalidFlags;
var
    source: TncIpcEnvelope;
    decoded: TncIpcEnvelope;
    frame: TBytes;
    consumed: SizeInt;
    error_text: string;
begin
    source.message_type := imt_ping;
    source.flags := 0;
    source.request_id := 1;
    source.context_id := 0;
    source.generation_id := 0;
    source.payload := nil;

    frame := nc_encode_ipc_frame(source);
    frame[10] := 1;
    AssertFalse(nc_try_decode_ipc_frame(frame, decoded, consumed, error_text));
    AssertEquals('IPC frame reserved field must be zero', error_text);

    frame := nc_encode_ipc_frame(source);
    frame[12] := $04;
    AssertFalse(nc_try_decode_ipc_frame(frame, decoded, consumed, error_text));
    AssertEquals('IPC frame contains unknown flags', error_text);

    frame := nc_encode_ipc_frame(source);
    frame[12] := c_ipc_flag_error;
    AssertFalse(nc_try_decode_ipc_frame(frame, decoded, consumed, error_text));
    AssertEquals('IPC error frame is missing the response flag', error_text);
end;

procedure TncIpcProtocolTests.RejectsInvalidOutboundFlags;
var
    source: TncIpcEnvelope;
begin
    source.message_type := imt_error;
    source.flags := c_ipc_flag_error;
    source.request_id := 1;
    source.context_id := 0;
    source.generation_id := 0;
    source.payload := nil;

    try
        nc_encode_ipc_frame(source);
        Fail('Expected an invalid outbound flag error');
    except
        on error: EncIpcProtocolError do
            AssertEquals('Cannot encode an IPC error without the response flag',
                error.Message);
    end;

    source.flags := $04;
    try
        nc_encode_ipc_frame(source);
        Fail('Expected an unknown outbound flag error');
    except
        on error: EncIpcProtocolError do
            AssertEquals('Cannot encode unknown IPC frame flags', error.Message);
    end;
end;

procedure TncIpcProtocolTests.WaitsForCompleteFrame;
var
    source: TncIpcEnvelope;
    decoded: TncIpcEnvelope;
    frame: TBytes;
    partial: TBytes;
    consumed: SizeInt;
    error_text: string;
begin
    source.message_type := imt_ping;
    source.flags := 0;
    source.request_id := 1;
    source.context_id := 0;
    source.generation_id := 0;
    source.payload := nc_utf8_payload('ping');
    frame := nc_encode_ipc_frame(source);
    partial := Copy(frame, 0, Length(frame) - 1);

    AssertFalse(nc_try_decode_ipc_frame(partial, decoded, consumed, error_text));
    AssertEquals('', error_text);
    AssertEquals(0, consumed);
end;

procedure TncIpcProtocolTests.RejectsInvalidMagic;
var
    source: TncIpcEnvelope;
    decoded: TncIpcEnvelope;
    frame: TBytes;
    consumed: SizeInt;
    error_text: string;
begin
    source.message_type := imt_ping;
    source.flags := 0;
    source.request_id := 1;
    source.context_id := 0;
    source.generation_id := 0;
    SetLength(source.payload, 0);
    frame := nc_encode_ipc_frame(source);
    frame[0] := 0;

    AssertFalse(nc_try_decode_ipc_frame(frame, decoded, consumed, error_text));
    AssertEquals('Invalid IPC frame magic', error_text);
    AssertEquals(0, consumed);
end;

procedure TncIpcProtocolTests.RejectsUnsupportedProtocolMajor;
var
    source: TncIpcEnvelope;
    decoded: TncIpcEnvelope;
    frame: TBytes;
    consumed: SizeInt;
    error_text: string;
begin
    source.message_type := imt_ping;
    source.flags := 0;
    source.request_id := 1;
    source.context_id := 0;
    source.generation_id := 0;
    SetLength(source.payload, 0);
    frame := nc_encode_ipc_frame(source);
    frame[4] := frame[4] + 1;

    AssertFalse(nc_try_decode_ipc_frame(frame, decoded, consumed, error_text));
    AssertEquals('Unsupported IPC protocol major version', error_text);
    AssertEquals(0, consumed);
end;

procedure TncIpcProtocolTests.RejectsOversizedPayload;
var
    source: TncIpcEnvelope;
    raised_error: Boolean;
begin
    source.message_type := imt_ping;
    source.flags := 0;
    source.request_id := 1;
    source.context_id := 0;
    source.generation_id := 0;
    SetLength(source.payload, c_ipc_max_payload_size + 1);

    raised_error := False;
    try
        nc_encode_ipc_frame(source);
    except
        on EncIpcProtocolError do
            raised_error := True;
    end;
    AssertTrue(raised_error);
end;

procedure TncIpcProtocolTests.ReportsBytesConsumedForFirstFrame;
var
    first: TncIpcEnvelope;
    second: TncIpcEnvelope;
    decoded: TncIpcEnvelope;
    first_frame: TBytes;
    second_frame: TBytes;
    combined: TBytes;
    consumed: SizeInt;
    error_text: string;
begin
    first.message_type := imt_ping;
    first.flags := 0;
    first.request_id := 10;
    first.context_id := 0;
    first.generation_id := 0;
    SetLength(first.payload, 0);
    second := first;
    second.message_type := imt_pong;
    second.request_id := 11;

    first_frame := nc_encode_ipc_frame(first);
    second_frame := nc_encode_ipc_frame(second);
    combined := Concat(first_frame, second_frame);

    AssertTrue(nc_try_decode_ipc_frame(combined, decoded, consumed, error_text));
    AssertEquals(Length(first_frame), consumed);
    AssertEquals(10, Int64(decoded.request_id));
end;

initialization
    RegisterTest(TncIpcProtocolTests);

end.
