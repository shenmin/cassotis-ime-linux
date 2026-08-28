unit test_nc_ipc_dispatcher;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry;

type
    TncIpcDispatcherTests = class(TTestCase)
    published
        procedure ReplaysContextLifecycleAndKeyRequest;
        procedure RejectsMalformedPayloadAndStaleGeneration;
        procedure EchoesPingAndRejectsResponseFrames;
        procedure RoundTripsEngineStateRequests;
        procedure PollsAsynchronousEngineResult;
        procedure AcknowledgesShutdownAfterValidEmptyRequest;
    end;

implementation

uses
    SysUtils,
    nc_types,
    nc_engine_contract,
    nc_engine_service,
    nc_ipc_protocol,
    nc_ipc_payload,
    nc_ipc_dispatcher;

type
    TncPollingTestEngine = class(TncEngineCore)
    public
        last_context_id: QWord;
        last_generation_id: QWord;
        function CreateContext(const context_id: QWord): Boolean; override;
        function DestroyContext(const context_id: QWord): Boolean; override;
        function ResetContext(const context_id: QWord;
            const generation_id: QWord): Boolean; override;
        function SetActive(const context_id: QWord; const active: Boolean;
            const generation_id: QWord): Boolean; override;
        function SetSurrounding(const context_id: QWord; const text: string;
            const cursor_offset: Integer; const generation_id: QWord): Boolean;
            override;
        function GetState(out state: TncEngineState): Boolean; override;
        function SetState(const state: TncEngineState): Boolean; override;
        function ClearUserDictionary: Boolean; override;
        function ProcessKey(const context_id: QWord;
            const generation_id: QWord;
            const key_event: TncKeyEvent): TncEngineResult; override;
        function PollResult(const context_id: QWord;
            const generation_id: QWord): TncEngineResult; override;
    end;

function TncPollingTestEngine.CreateContext(
    const context_id: QWord): Boolean;
begin
    Result := True;
end;

function TncPollingTestEngine.DestroyContext(
    const context_id: QWord): Boolean;
begin
    Result := True;
end;

function TncPollingTestEngine.ResetContext(const context_id: QWord;
    const generation_id: QWord): Boolean;
begin
    Result := True;
end;

function TncPollingTestEngine.SetActive(const context_id: QWord;
    const active: Boolean; const generation_id: QWord): Boolean;
begin
    Result := True;
end;

function TncPollingTestEngine.SetSurrounding(const context_id: QWord;
    const text: string; const cursor_offset: Integer;
    const generation_id: QWord): Boolean;
begin
    Result := True;
end;

function TncPollingTestEngine.GetState(out state: TncEngineState): Boolean;
begin
    nc_initialize_engine_state(state);
    Result := True;
end;

function TncPollingTestEngine.SetState(
    const state: TncEngineState): Boolean;
begin
    Result := True;
end;

function TncPollingTestEngine.ClearUserDictionary: Boolean;
begin
    Result := True;
end;

function TncPollingTestEngine.ProcessKey(const context_id: QWord;
    const generation_id: QWord;
    const key_event: TncKeyEvent): TncEngineResult;
begin
    nc_initialize_engine_result(Result);
end;

function TncPollingTestEngine.PollResult(const context_id: QWord;
    const generation_id: QWord): TncEngineResult;
begin
    last_context_id := context_id;
    last_generation_id := generation_id;
    nc_initialize_engine_result(Result);
    Result.handled := True;
    Result.async_pending := False;
    Result.query_text := 'pianruo';
    Result.completion_text := #$7FE9#$82E5#$60CA#$9E3F;
end;

procedure InitializeRequest(out request: TncIpcEnvelope;
    const message_type: TncIpcMessageType; const request_id: QWord;
    const context_id: QWord; const generation_id: QWord);
begin
    request.message_type := message_type;
    request.flags := 0;
    request.request_id := request_id;
    request.context_id := context_id;
    request.generation_id := generation_id;
    request.payload := nil;
end;

procedure AssertSuccessfulResponse(const test: TTestCase;
    const request: TncIpcEnvelope; const response: TncIpcEnvelope);
begin
    test.AssertEquals(Int64(request.request_id), Int64(response.request_id));
    test.AssertEquals(Int64(request.context_id), Int64(response.context_id));
    test.AssertEquals(Int64(request.generation_id),
        Int64(response.generation_id));
    test.AssertEquals(Int64(c_ipc_flag_response), Int64(response.flags));
end;

procedure TncIpcDispatcherTests.ReplaysContextLifecycleAndKeyRequest;
var
    service: TncEngineService;
    dispatcher: TncIpcDispatcher;
    request: TncIpcEnvelope;
    response: TncIpcEnvelope;
    key_event: TncKeyEvent;
    engine_result: TncEngineResult;
    error_text: string;
begin
    service := TncEngineService.Create;
    dispatcher := TncIpcDispatcher.Create(service);
    try
        InitializeRequest(request, imt_create_context, 1, 42, 0);
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);
        AssertEquals(1, service.ContextCount);

        InitializeRequest(request, imt_set_active, 2, 42, 1);
        request.payload := nc_encode_set_active_payload(True);
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);

        InitializeRequest(request, imt_set_surrounding, 3, 42, 2);
        request.payload := nc_encode_surrounding_payload('前文', 2);
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);

        key_event.text := 'n';
        key_event.special_key := sk_none;
        key_event.modifiers := [];
        key_event.scan_code := 49;
        key_event.is_release := False;
        key_event.is_repeat := False;
        key_event.timestamp_ms := 100;
        InitializeRequest(request, imt_process_key, 4, 42, 3);
        request.payload := nc_encode_key_event_payload(key_event);
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);
        AssertEquals(Ord(imt_engine_result), Ord(response.message_type));
        AssertTrue(nc_try_decode_engine_result_payload(response.payload,
            engine_result, error_text));
        AssertEquals(Int64(c_engine_error_dictionary_unavailable),
            Int64(engine_result.error_code));

        InitializeRequest(request, imt_destroy_context, 5, 42, 3);
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);
        AssertEquals(0, service.ContextCount);
    finally
        dispatcher.Free;
        service.Free;
    end;
end;

procedure TncIpcDispatcherTests.RejectsMalformedPayloadAndStaleGeneration;
var
    service: TncEngineService;
    dispatcher: TncIpcDispatcher;
    request: TncIpcEnvelope;
    response: TncIpcEnvelope;
    error_code: Cardinal;
    error_message: string;
    decode_error: string;
begin
    service := TncEngineService.Create;
    dispatcher := TncIpcDispatcher.Create(service);
    try
        InitializeRequest(request, imt_create_context, 1, 7, 0);
        dispatcher.DispatchRequest(request, response);

        InitializeRequest(request, imt_set_active, 2, 7, 5);
        request.payload := nc_encode_set_active_payload(True);
        dispatcher.DispatchRequest(request, response);
        AssertEquals(Ord(imt_set_active), Ord(response.message_type));

        InitializeRequest(request, imt_set_active, 3, 7, 6);
        request.payload := nc_encode_set_active_payload(False);
        SetLength(request.payload, Length(request.payload) - 1);
        dispatcher.DispatchRequest(request, response);
        AssertEquals(Ord(imt_error), Ord(response.message_type));
        AssertTrue(nc_try_decode_error_payload(response.payload, error_code,
            error_message, decode_error));
        AssertEquals(Int64(c_ipc_dispatch_error_invalid_payload),
            Int64(error_code));

        InitializeRequest(request, imt_set_active, 4, 7, 4);
        request.payload := nc_encode_set_active_payload(False);
        dispatcher.DispatchRequest(request, response);
        AssertEquals(Ord(imt_error), Ord(response.message_type));
        AssertTrue(nc_try_decode_error_payload(response.payload, error_code,
            error_message, decode_error));
        AssertEquals(Int64(c_ipc_dispatch_error_operation_failed),
            Int64(error_code));
        AssertEquals(1, service.ContextCount);
    finally
        dispatcher.Free;
        service.Free;
    end;
end;

procedure TncIpcDispatcherTests.EchoesPingAndRejectsResponseFrames;
var
    service: TncEngineService;
    dispatcher: TncIpcDispatcher;
    request: TncIpcEnvelope;
    response: TncIpcEnvelope;
    error_code: Cardinal;
    error_message: string;
    decode_error: string;
begin
    service := TncEngineService.Create;
    dispatcher := TncIpcDispatcher.Create(service);
    try
        InitializeRequest(request, imt_ping, 99, 0, 0);
        request.payload := nc_utf8_payload('probe');
        dispatcher.DispatchRequest(request, response);
        AssertEquals(Ord(imt_pong), Ord(response.message_type));
        AssertEquals('probe', nc_payload_as_string(response.payload));

        request.flags := c_ipc_flag_response;
        dispatcher.DispatchRequest(request, response);
        AssertEquals(Ord(imt_error), Ord(response.message_type));
        AssertTrue(nc_try_decode_error_payload(response.payload, error_code,
            error_message, decode_error));
        AssertEquals(Int64(c_ipc_dispatch_error_invalid_request),
            Int64(error_code));
    finally
        dispatcher.Free;
        service.Free;
    end;
end;

procedure TncIpcDispatcherTests.RoundTripsEngineStateRequests;
var
    service: TncEngineService;
    dispatcher: TncIpcDispatcher;
    request: TncIpcEnvelope;
    response: TncIpcEnvelope;
    state: TncIpcEngineState;
    decoded_state: TncIpcEngineState;
    error_text: string;
begin
    service := TncEngineService.Create;
    dispatcher := TncIpcDispatcher.Create(service);
    try
        nc_initialize_engine_state(state);
        state.input_mode := im_english;
        state.pinyin_scheme := pis_xiaohe_shuangpin;
        state.full_width_mode := True;
        state.punctuation_full_width := False;
        InitializeRequest(request, imt_set_state, 20, 0, 0);
        request.payload := nc_encode_engine_state_payload(state);
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);

        InitializeRequest(request, imt_get_state, 21, 0, 0);
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);
        AssertTrue(nc_try_decode_engine_state_payload(response.payload,
            decoded_state, error_text));
        AssertTrue(nc_engine_states_equal(state, decoded_state));
    finally
        dispatcher.Free;
        service.Free;
    end;
end;

procedure TncIpcDispatcherTests.PollsAsynchronousEngineResult;
var
    engine: TncPollingTestEngine;
    dispatcher: TncIpcDispatcher;
    request: TncIpcEnvelope;
    response: TncIpcEnvelope;
    engine_result: TncEngineResult;
    error_text: string;
begin
    engine := TncPollingTestEngine.Create;
    dispatcher := TncIpcDispatcher.Create(engine);
    try
        InitializeRequest(request, imt_poll_result, 25, 77, 9);
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);
        AssertEquals(Ord(imt_engine_result), Ord(response.message_type));
        AssertEquals(Int64(77), Int64(engine.last_context_id));
        AssertEquals(Int64(9), Int64(engine.last_generation_id));
        AssertTrue(nc_try_decode_engine_result_payload(response.payload,
            engine_result, error_text));
        AssertTrue(engine_result.handled);
        AssertFalse(engine_result.async_pending);
        AssertEquals('pianruo', engine_result.query_text);
        AssertEquals(#$7FE9#$82E5#$60CA#$9E3F,
            engine_result.completion_text);

        request.payload := nc_utf8_payload('invalid');
        dispatcher.DispatchRequest(request, response);
        AssertEquals(Ord(imt_error), Ord(response.message_type));
    finally
        dispatcher.Free;
        engine.Free;
    end;
end;

procedure TncIpcDispatcherTests.AcknowledgesShutdownAfterValidEmptyRequest;
var
    service: TncEngineService;
    dispatcher: TncIpcDispatcher;
    request: TncIpcEnvelope;
    response: TncIpcEnvelope;
begin
    service := TncEngineService.Create;
    dispatcher := TncIpcDispatcher.Create(service);
    try
        InitializeRequest(request, imt_shutdown, 30, 0, 0);
        request.payload := nc_utf8_payload('invalid');
        dispatcher.DispatchRequest(request, response);
        AssertEquals(Ord(imt_error), Ord(response.message_type));
        AssertFalse(dispatcher.ShutdownRequested);

        request.payload := nil;
        dispatcher.DispatchRequest(request, response);
        AssertSuccessfulResponse(Self, request, response);
        AssertEquals(Ord(imt_shutdown), Ord(response.message_type));
        AssertTrue(dispatcher.ShutdownRequested);
    finally
        dispatcher.Free;
        service.Free;
    end;
end;

initialization
    RegisterTest(TncIpcDispatcherTests);

end.
