unit test_nc_ipc_payload;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry;

type
    TncIpcPayloadTests = class(TTestCase)
    published
        procedure RoundTripsSetActiveAndSurrounding;
        procedure RoundTripsFrameworkNeutralKeyEvent;
        procedure RoundTripsCompleteEngineResult;
        procedure RoundTripsAllEngineStateFields;
        procedure DecodesLegacyEngineStateWithFuzzyDefaults;
        procedure RoundTripsStructuredError;
        procedure RejectsTruncationTrailingBytesAndNewerSchema;
        procedure RejectsInvalidUtf8AndEnums;
        procedure RejectsExcessiveCandidateCount;
        procedure MalformedPayloadCorpusNeverRaises;
    end;

implementation

uses
    SysUtils,
    nc_types,
    nc_ipc_payload;

procedure TncIpcPayloadTests.RoundTripsSetActiveAndSurrounding;
var
    payload: TBytes;
    active: Boolean;
    text: string;
    cursor_offset: Integer;
    error_text: string;
begin
    payload := nc_encode_set_active_payload(True);
    AssertTrue(nc_try_decode_set_active_payload(payload, active, error_text));
    AssertTrue(active);
    AssertEquals('', error_text);

    payload := nc_encode_surrounding_payload('前文 Cassotis 言泉', 7);
    AssertTrue(nc_try_decode_surrounding_payload(payload, text, cursor_offset,
        error_text));
    AssertEquals('前文 Cassotis 言泉', text);
    AssertEquals(7, cursor_offset);
end;

procedure TncIpcPayloadTests.RoundTripsFrameworkNeutralKeyEvent;
var
    source: TncKeyEvent;
    decoded: TncKeyEvent;
    payload: TBytes;
    error_text: string;
begin
    source.text := '你';
    source.special_key := sk_f24;
    source.modifiers := [km_shift, km_control, km_num_lock];
    source.scan_code := $12345678;
    source.is_release := True;
    source.is_repeat := True;
    source.timestamp_ms := 9876543210;

    payload := nc_encode_key_event_payload(source);
    AssertTrue(nc_try_decode_key_event_payload(payload, decoded, error_text));
    AssertEquals(source.text, decoded.text);
    AssertEquals(Ord(source.special_key), Ord(decoded.special_key));
    AssertTrue(decoded.modifiers = source.modifiers);
    AssertEquals(Int64(source.scan_code), Int64(decoded.scan_code));
    AssertTrue(decoded.is_release);
    AssertTrue(decoded.is_repeat);
    AssertEquals(Int64(source.timestamp_ms), Int64(decoded.timestamp_ms));
end;

procedure TncIpcPayloadTests.RoundTripsCompleteEngineResult;
var
    source: TncEngineResult;
    decoded: TncEngineResult;
    payload: TBytes;
    error_text: string;
begin
    nc_initialize_engine_result(source);
    source.handled := True;
    source.async_pending := True;
    source.commit_text := '提交';
    source.preedit_text := '言泉输入法';
    source.query_text := 'yanquanshurufa';
    source.selected_index := 1;
    source.page_index := 2;
    source.page_count := 4;
    source.completion_text := '言泉输入法项目';
    source.error_code := 17;
    source.error_text := 'diagnostic';
    SetLength(source.candidates, 2);
    source.candidates[0].text := '言泉输入法';
    source.candidates[0].comment := 'exact';
    source.candidates[0].score := 1234;
    source.candidates[0].source := cs_rule;
    source.candidates[0].has_dict_weight := True;
    source.candidates[0].dict_weight := 900;
    source.candidates[0].fuzzy_cost := 0;
    source.candidates[0].fuzzy_rules := [];
    source.candidates[0].display_kind := cdk_default;
    source.candidates[0].deletable := False;
    source.candidates[1].text := '言泉';
    source.candidates[1].comment := 'user';
    source.candidates[1].score := -27;
    source.candidates[1].source := cs_user;
    source.candidates[1].has_dict_weight := False;
    source.candidates[1].dict_weight := 0;
    source.candidates[1].fuzzy_cost := 2;
    source.candidates[1].fuzzy_rules := [fpr_z_zh, fpr_en_eng];
    source.candidates[1].display_kind := cdk_lm_compound;
    source.candidates[1].deletable := True;

    payload := nc_encode_engine_result_payload(source);
    AssertTrue(nc_try_decode_engine_result_payload(payload, decoded,
        error_text));
    AssertTrue(decoded.handled);
    AssertTrue(decoded.async_pending);
    AssertEquals(source.commit_text, decoded.commit_text);
    AssertEquals(source.preedit_text, decoded.preedit_text);
    AssertEquals(source.query_text, decoded.query_text);
    AssertEquals(source.completion_text, decoded.completion_text);
    AssertEquals(source.selected_index, decoded.selected_index);
    AssertEquals(source.page_index, decoded.page_index);
    AssertEquals(source.page_count, decoded.page_count);
    AssertEquals(Int64(source.error_code), Int64(decoded.error_code));
    AssertEquals(source.error_text, decoded.error_text);
    AssertEquals(2, Length(decoded.candidates));
    AssertEquals('言泉输入法', decoded.candidates[0].text);
    AssertEquals(1234, decoded.candidates[0].score);
    AssertEquals(Ord(cs_rule), Ord(decoded.candidates[0].source));
    AssertEquals(900, decoded.candidates[0].dict_weight);
    AssertEquals('言泉', decoded.candidates[1].text);
    AssertEquals(-27, decoded.candidates[1].score);
    AssertEquals(Ord(cs_user), Ord(decoded.candidates[1].source));
    AssertTrue(decoded.candidates[1].deletable);
    AssertTrue(decoded.candidates[1].fuzzy_rules =
        [fpr_z_zh, fpr_en_eng]);
    AssertEquals(Ord(cdk_lm_compound),
        Ord(decoded.candidates[1].display_kind));
end;

procedure TncIpcPayloadTests.RoundTripsAllEngineStateFields;
var
    source: TncIpcEngineState;
    decoded: TncIpcEngineState;
    payload: TBytes;
    error_text: string;
begin
    nc_initialize_engine_state(source);
    source.input_mode := im_english;
    source.dictionary_variant := dv_traditional;
    source.pinyin_scheme := pis_pinyinjiajia_shuangpin;
    source.fuzzy_pinyin_enabled := True;
    source.fuzzy_pinyin_rules := [fpr_z_zh, fpr_en_eng, fpr_in_ing];
    source.full_width_mode := True;
    source.punctuation_full_width := False;
    source.candidate_page_size := 5;
    source.candidate_page_key_scheme := cpks_shift_tab;
    source.one_key_completion_key := ock_backtick;
    source.debug_mode := True;
    source.shortcuts.input_mode_toggle.key_code := Ord('I');
    source.shortcuts.input_mode_toggle.shift_down := True;
    source.shortcuts.input_mode_toggle.ctrl_down := True;
    payload := nc_encode_engine_state_payload(source);
    AssertTrue(nc_try_decode_engine_state_payload(payload, decoded,
        error_text));
    AssertEquals(Ord(source.input_mode), Ord(decoded.input_mode));
    AssertEquals(Ord(source.dictionary_variant),
        Ord(decoded.dictionary_variant));
    AssertEquals(Ord(source.pinyin_scheme), Ord(decoded.pinyin_scheme));
    AssertTrue(decoded.fuzzy_pinyin_enabled);
    AssertTrue(decoded.fuzzy_pinyin_rules = source.fuzzy_pinyin_rules);
    AssertTrue(decoded.full_width_mode);
    AssertFalse(decoded.punctuation_full_width);
    AssertEquals(source.candidate_page_size, decoded.candidate_page_size);
    AssertEquals(Ord(source.candidate_page_key_scheme),
        Ord(decoded.candidate_page_key_scheme));
    AssertEquals(Ord(source.one_key_completion_key),
        Ord(decoded.one_key_completion_key));
    AssertTrue(decoded.debug_mode);
    AssertTrue(nc_engine_states_equal(source, decoded));
end;

procedure TncIpcPayloadTests.DecodesLegacyEngineStateWithFuzzyDefaults;
var
    source: TncIpcEngineState;
    decoded: TncIpcEngineState;
    payload: TBytes;
    error_text: string;
begin
    nc_initialize_engine_state(source);
    source.pinyin_scheme := pis_xiaohe_shuangpin;
    source.fuzzy_pinyin_enabled := True;
    source.fuzzy_pinyin_rules := [fpr_z_zh];
    payload := nc_encode_engine_state_payload(source);
    SetLength(payload, 8);
    payload[0] := c_ipc_payload_schema_version;
    payload[1] := 0;
    payload[7] := $02;
    AssertTrue(nc_try_decode_engine_state_payload(payload, decoded,
        error_text));
    AssertEquals(Ord(pis_xiaohe_shuangpin), Ord(decoded.pinyin_scheme));
    AssertFalse(decoded.fuzzy_pinyin_enabled);
    AssertTrue(decoded.fuzzy_pinyin_rules = []);
    AssertFalse(decoded.full_width_mode);
    AssertTrue(decoded.punctuation_full_width);
    AssertEquals(c_default_candidate_page_size,
        decoded.candidate_page_size);
    AssertEquals(Ord(cpks_minus_plus),
        Ord(decoded.candidate_page_key_scheme));
    AssertEquals(Ord(ock_tab), Ord(decoded.one_key_completion_key));
    AssertFalse(decoded.debug_mode);
    AssertEquals($10, decoded.shortcuts.input_mode_toggle.key_code);
end;

procedure TncIpcPayloadTests.RoundTripsStructuredError;
var
    payload: TBytes;
    error_code: Cardinal;
    error_message: string;
    decode_error: string;
begin
    payload := nc_encode_error_payload(42, '上下文已过期');
    AssertTrue(nc_try_decode_error_payload(payload, error_code, error_message,
        decode_error));
    AssertEquals(42, Int64(error_code));
    AssertEquals('上下文已过期', error_message);
end;

procedure TncIpcPayloadTests.RejectsTruncationTrailingBytesAndNewerSchema;
var
    payload: TBytes;
    active: Boolean;
    error_text: string;
begin
    payload := nc_encode_set_active_payload(True);
    SetLength(payload, Length(payload) - 1);
    AssertFalse(nc_try_decode_set_active_payload(payload, active, error_text));
    AssertEquals('IPC payload is truncated', error_text);

    payload := nc_encode_set_active_payload(True);
    SetLength(payload, Length(payload) + 1);
    payload[High(payload)] := 0;
    AssertFalse(nc_try_decode_set_active_payload(payload, active, error_text));
    AssertEquals('IPC payload contains trailing bytes', error_text);

    payload := nc_encode_set_active_payload(True);
    payload[0] := c_ipc_payload_schema_version + 1;
    AssertFalse(nc_try_decode_set_active_payload(payload, active, error_text));
    AssertEquals('Unsupported IPC payload schema version', error_text);
end;

procedure TncIpcPayloadTests.RejectsInvalidUtf8AndEnums;
var
    payload: TBytes;
    text: string;
    cursor_offset: Integer;
    state: TncIpcEngineState;
    error_text: string;
begin
    payload := nc_encode_surrounding_payload('a', 0);
    payload[12] := $C0;
    AssertFalse(nc_try_decode_surrounding_payload(payload, text, cursor_offset,
        error_text));
    AssertEquals('IPC text value is not valid UTF-8', error_text);

    nc_initialize_engine_state(state);
    state.input_mode := im_chinese;
    state.dictionary_variant := dv_simplified;
    state.pinyin_scheme := pis_full_pinyin;
    state.full_width_mode := False;
    state.punctuation_full_width := True;
    payload := nc_encode_engine_state_payload(state);
    payload[6] := $FF;
    AssertFalse(nc_try_decode_engine_state_payload(payload, state, error_text));
    AssertEquals('State payload contains an invalid pinyin scheme', error_text);
end;

procedure TncIpcPayloadTests.RejectsExcessiveCandidateCount;
var
    engine_result: TncEngineResult;
    raised_error: Boolean;
begin
    nc_initialize_engine_result(engine_result);
    SetLength(engine_result.candidates, c_ipc_payload_max_candidates + 1);
    raised_error := False;
    try
        nc_encode_engine_result_payload(engine_result);
    except
        on EncIpcPayloadError do
            raised_error := True;
    end;
    AssertTrue(raised_error);
end;

procedure TncIpcPayloadTests.MalformedPayloadCorpusNeverRaises;
var
    payload: TBytes;
    random_state: Cardinal;
    iteration: Integer;
    byte_index: Integer;
    active: Boolean;
    text: string;
    cursor_offset: Integer;
    key_event: TncKeyEvent;
    engine_result: TncEngineResult;
    engine_state: TncIpcEngineState;
    error_code: Cardinal;
    error_message: string;
    decode_error: string;
begin
    random_state := $C4550715;
    payload := nil;
    for iteration := 1 to 5000 do
    begin
        random_state := random_state * 1664525 + 1013904223;
        SetLength(payload, (random_state shr 24) mod 97);
        for byte_index := 0 to High(payload) do
        begin
            random_state := random_state * 1664525 + 1013904223;
            payload[byte_index] := Byte(random_state shr 24);
        end;
        nc_try_decode_set_active_payload(payload, active, decode_error);
        nc_try_decode_surrounding_payload(payload, text, cursor_offset,
            decode_error);
        nc_try_decode_key_event_payload(payload, key_event, decode_error);
        nc_try_decode_engine_result_payload(payload, engine_result,
            decode_error);
        nc_try_decode_engine_state_payload(payload, engine_state, decode_error);
        nc_try_decode_error_payload(payload, error_code, error_message,
            decode_error);
    end;
    AssertTrue(True);
end;

initialization
    RegisterTest(TncIpcPayloadTests);

end.
