unit nc_ipc_dispatcher;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_engine_contract,
    nc_ipc_protocol;

const
    c_ipc_dispatch_error_invalid_request = 1001;
    c_ipc_dispatch_error_invalid_payload = 1002;
    c_ipc_dispatch_error_operation_failed = 1003;
    c_ipc_dispatch_error_unsupported = 1004;

type
    TncIpcDispatcher = class
    private
        FEngine: TncEngineCore;
        FShutdownRequested: Boolean;
        procedure InitializeResponse(const request: TncIpcEnvelope;
            out response: TncIpcEnvelope);
        procedure SetErrorResponse(const request: TncIpcEnvelope;
            out response: TncIpcEnvelope; const error_code: Cardinal;
            const error_message: string);
        function RequireEmptyPayload(const request: TncIpcEnvelope;
            out response: TncIpcEnvelope): Boolean;
    public
        constructor Create(const engine: TncEngineCore);
        procedure DispatchRequest(const request: TncIpcEnvelope;
            out response: TncIpcEnvelope);
        property ShutdownRequested: Boolean read FShutdownRequested;
    end;

implementation

uses
    SysUtils,
    nc_types,
    nc_ipc_payload;

constructor TncIpcDispatcher.Create(const engine: TncEngineCore);
begin
    inherited Create;
    if engine = nil then
        raise EArgumentNilException.Create('engine');
    FEngine := engine;
    FShutdownRequested := False;
end;

procedure TncIpcDispatcher.InitializeResponse(const request: TncIpcEnvelope;
    out response: TncIpcEnvelope);
begin
    response.message_type := request.message_type;
    response.flags := c_ipc_flag_response;
    response.request_id := request.request_id;
    response.context_id := request.context_id;
    response.generation_id := request.generation_id;
    response.payload := nil;
end;

procedure TncIpcDispatcher.SetErrorResponse(const request: TncIpcEnvelope;
    out response: TncIpcEnvelope; const error_code: Cardinal;
    const error_message: string);
begin
    InitializeResponse(request, response);
    response.message_type := imt_error;
    response.flags := c_ipc_flag_response or c_ipc_flag_error;
    response.payload := nc_encode_error_payload(error_code, error_message);
end;

function TncIpcDispatcher.RequireEmptyPayload(const request: TncIpcEnvelope;
    out response: TncIpcEnvelope): Boolean;
begin
    Result := Length(request.payload) = 0;
    if not Result then
        SetErrorResponse(request, response,
            c_ipc_dispatch_error_invalid_payload,
            'This request requires an empty payload');
end;

procedure TncIpcDispatcher.DispatchRequest(const request: TncIpcEnvelope;
    out response: TncIpcEnvelope);
var
    active: Boolean;
    surrounding_text: string;
    cursor_offset: Integer;
    key_event: TncKeyEvent;
    engine_result: TncEngineResult;
    engine_state: TncEngineState;
    current_state: TncEngineState;
    payload_error: string;
    operation_succeeded: Boolean;
    import_path: string;
    import_entries, import_count: Integer;
    path_bytes: TBytes;
begin
    InitializeResponse(request, response);
    if (request.flags and c_ipc_known_flags) <> 0 then
    begin
        SetErrorResponse(request, response, c_ipc_dispatch_error_invalid_request,
            'Responses cannot be dispatched as requests');
        Exit;
    end;
    if (request.flags and not c_ipc_known_flags) <> 0 then
    begin
        SetErrorResponse(request, response, c_ipc_dispatch_error_invalid_request,
            'Request contains unknown flags');
        Exit;
    end;

    case request.message_type of
        imt_ping:
            begin
                response.message_type := imt_pong;
                response.payload := Copy(request.payload, 0,
                    Length(request.payload));
            end;
        imt_create_context:
            begin
                if not RequireEmptyPayload(request, response) then
                    Exit;
                operation_succeeded := FEngine.CreateContext(request.context_id);
                if not operation_succeeded then
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_operation_failed,
                        'Unable to create input context');
            end;
        imt_destroy_context:
            begin
                if not RequireEmptyPayload(request, response) then
                    Exit;
                operation_succeeded := FEngine.DestroyContext(request.context_id);
                if not operation_succeeded then
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_operation_failed,
                        'Unable to destroy input context');
            end;
        imt_reset_context:
            begin
                if not RequireEmptyPayload(request, response) then
                    Exit;
                operation_succeeded := FEngine.ResetContext(request.context_id,
                    request.generation_id);
                if not operation_succeeded then
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_operation_failed,
                        'Unable to reset input context');
            end;
        imt_set_active:
            begin
                if not nc_try_decode_set_active_payload(request.payload, active,
                    payload_error) then
                begin
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_invalid_payload, payload_error);
                    Exit;
                end;
                operation_succeeded := FEngine.SetActive(request.context_id,
                    active, request.generation_id);
                if not operation_succeeded then
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_operation_failed,
                        'Unable to update input context activation');
            end;
        imt_set_surrounding:
            begin
                if not nc_try_decode_surrounding_payload(request.payload,
                    surrounding_text, cursor_offset, payload_error) then
                begin
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_invalid_payload, payload_error);
                    Exit;
                end;
                operation_succeeded := FEngine.SetSurrounding(request.context_id,
                    surrounding_text, cursor_offset, request.generation_id);
                if not operation_succeeded then
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_operation_failed,
                        'Unable to update surrounding text');
            end;
        imt_process_key:
            begin
                if not nc_try_decode_key_event_payload(request.payload, key_event,
                    payload_error) then
                begin
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_invalid_payload, payload_error);
                    Exit;
                end;
                engine_result := FEngine.ProcessKey(request.context_id,
                    request.generation_id, key_event);
                response.message_type := imt_engine_result;
                response.payload := nc_encode_engine_result_payload(engine_result);
            end;
        imt_poll_result:
            begin
                if not RequireEmptyPayload(request, response) then
                    Exit;
                engine_result := FEngine.PollResult(request.context_id,
                    request.generation_id);
                response.message_type := imt_engine_result;
                response.payload := nc_encode_engine_result_payload(
                    engine_result);
            end;
        imt_get_state, imt_get_preferences:
            begin
                if not RequireEmptyPayload(request, response) then
                    Exit;
                operation_succeeded := FEngine.GetState(engine_state);
                if operation_succeeded then
                begin
                    if request.message_type = imt_get_preferences then
                        response.payload := nc_encode_preferences_payload(engine_state)
                    else
                        response.payload := nc_encode_engine_state_payload(engine_state);
                end
                else
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_operation_failed,
                        'Unable to read engine state');
            end;
        imt_set_state, imt_set_preferences:
            begin
                if request.message_type = imt_set_preferences then
                    operation_succeeded := nc_try_decode_preferences_payload(
                        request.payload, engine_state, payload_error)
                else
                begin
                    operation_succeeded := nc_try_decode_engine_state_payload(
                        request.payload, engine_state, payload_error);
                    // Framework toggles use the compact state and must not erase phrases.
                    if operation_succeeded then
                    begin
                        operation_succeeded := FEngine.GetState(current_state);
                        engine_state.custom_phrases := Copy(current_state.custom_phrases);
                        if not operation_succeeded then payload_error := 'Unable to read preferences';
                    end;
                end;
                if not operation_succeeded then
                begin
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_invalid_payload, payload_error);
                    Exit;
                end;
                operation_succeeded := FEngine.SetState(engine_state);
                if not operation_succeeded then
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_operation_failed,
                        'Unable to update engine state');
            end;
        imt_shutdown:
            begin
                if not RequireEmptyPayload(request, response) then
                    Exit;
                FShutdownRequested := True;
            end;
        imt_import_user_words:
            begin
                import_path := nc_payload_as_string(request.payload);
                path_bytes := nc_utf8_payload(import_path);
                if (Length(request.payload) = 0) or (Length(request.payload) > 4096) or
                    (Pos(#0, import_path) > 0) or (import_path[1] <> '/') or
                    (Length(path_bytes) <> Length(request.payload)) or
                    not CompareMem(@path_bytes[0], @request.payload[0], Length(path_bytes)) then
                begin
                    SetErrorResponse(request, response, c_ipc_dispatch_error_invalid_payload,
                        'Expected an absolute UTF-8 file path');
                    Exit;
                end;
                if FEngine.ImportUserWords(import_path, import_entries, import_count) then
                    response.payload := nc_utf8_payload(IntToStr(import_entries) + #9 + IntToStr(import_count))
                else
                    SetErrorResponse(request, response, c_ipc_dispatch_error_operation_failed,
                        'Unable to import word frequencies; check the file format and user database');
            end;
        imt_clear_user_dictionary:
            begin
                if not RequireEmptyPayload(request, response) then
                    Exit;
                operation_succeeded := FEngine.ClearUserDictionary;
                if not operation_succeeded then
                    SetErrorResponse(request, response,
                        c_ipc_dispatch_error_operation_failed,
                        'Unable to clear user dictionary');
            end;
    else
        SetErrorResponse(request, response, c_ipc_dispatch_error_unsupported,
            'IPC request type is not implemented');
    end;
end;

end.
