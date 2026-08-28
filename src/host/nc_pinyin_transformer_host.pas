unit nc_pinyin_transformer_host;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    Classes,
    SyncObjs,
    Generics.Collections,
    Dynlibs,
    nc_engine_intf;

const
    c_nc_pinyin_transformer_result_timeout_ms = 30;

type
    TncPinyinTransformerHostReranker = class;

    TncPinyinTransformerLoadThread = class(TThread)
    private
        m_owner: TncPinyinTransformerHostReranker;
    protected
        procedure Execute; override;
    public
        constructor create(const owner: TncPinyinTransformerHostReranker);
        procedure detach_owner;
    end;

    TncPinyinTransformerHostReranker = class(TInterfacedObject,
        IncLongNeuralReranker)
    private type
        TncPtCreate = function(const model_path: PAnsiChar;
            const intra_threads: Integer; const error_text: PAnsiChar;
            const error_capacity: Integer): Pointer; cdecl;
        TncPtRun = function(const handle: Pointer;
            const char_ids: PInt64; const pinyin_ids: PInt64;
            const boundary_ids: PInt64; const numeric_features: PSingle;
            const candidate_mask: PByte; const output_scores: PSingle;
            const output_score_count: Integer; const error_text: PAnsiChar;
            const error_capacity: Integer): Integer; cdecl;
        TncPtDestroy = procedure(const handle: Pointer); cdecl;
    private
        m_base_directory: string;
        m_state_lock: TCriticalSection;
        m_run_lock: TCriticalSection;
        m_loader: TncPinyinTransformerLoadThread;
        m_module: TLibHandle;
        m_session: Pointer;
        m_create_function: TncPtCreate;
        m_run_function: TncPtRun;
        m_destroy_function: TncPtDestroy;
        m_char_vocab: TDictionary<string, Integer>;
        m_pinyin_vocab: TDictionary<string, Integer>;
        m_ready: Boolean;
        m_load_finished: Boolean;
        m_last_error: string;
        m_result_timeout_ms: QWord;
        m_profile_enabled: Boolean;
        m_profile_frequency: Int64;
        m_profile_calls: Int64;
        m_profile_gate_passes: Int64;
        m_profile_cache_hits: Int64;
        m_profile_build_ticks: Int64;
        m_profile_gate_ticks: Int64;
        m_profile_inference_ticks: Int64;
        m_cache_valid: Boolean;
        m_cache_result: Boolean;
        m_cache_selected_index: Integer;
        m_cache_char_ids: TArray<Int64>;
        m_cache_pinyin_ids: TArray<Int64>;
        m_cache_boundary_ids: TArray<Int64>;
        m_cache_numeric_features: TArray<Single>;
        m_cache_candidate_mask: TArray<Byte>;
        m_cache_gate_features: TArray<Double>;
        procedure load_model;
        procedure disable_after_inference_error(const error_text: string);
        function load_vocab(const vocab_path: string): Boolean;
        function build_inputs(const query_text: string;
            const candidates: TncLongFinalCandidateDebugArray;
            out char_ids: TArray<Int64>; out pinyin_ids: TArray<Int64>;
            out boundary_ids: TArray<Int64>;
            out numeric_features: TArray<Single>;
            out candidate_mask: TArray<Byte>;
            out gate_features: TArray<Double>): Boolean;
        function should_invoke(const gate_features: TArray<Double>): Boolean;
        function try_cached_decision(const char_ids: TArray<Int64>;
            const pinyin_ids: TArray<Int64>;
            const boundary_ids: TArray<Int64>;
            const numeric_features: TArray<Single>;
            const candidate_mask: TArray<Byte>;
            const gate_features: TArray<Double>;
            out cached_result: Boolean;
            out cached_selected_index: Integer): Boolean;
        procedure cache_decision(const char_ids: TArray<Int64>;
            const pinyin_ids: TArray<Int64>;
            const boundary_ids: TArray<Int64>;
            const numeric_features: TArray<Single>;
            const candidate_mask: TArray<Byte>;
            const gate_features: TArray<Double>;
            const decision_result: Boolean;
            const decision_selected_index: Integer);
        procedure log_message(const level_text: string;
            const message_text: string);
    public
        constructor create(const base_directory: string;
            const background_load: Boolean = True;
            const result_timeout_ms: QWord =
            c_nc_pinyin_transformer_result_timeout_ms);
        destructor Destroy; override;
        function try_select(const query_text: string;
            const candidates: TncLongFinalCandidateDebugArray;
            out selected_index: Integer): Boolean;
        function ready: Boolean;
        function wait_until_ready(const timeout_ms: Cardinal): Boolean;
        function last_error: string;
    end;

implementation

uses
    Math,
    fpjson,
    jsonparser,
    nc_pinyin_parser,
    nc_pinyin_transformer_ambiguity_gate_model;

const
    c_model_candidate_count = 12;
    c_gate_candidate_count = 16;
    c_sequence_length = 41;
    c_numeric_feature_count = 88;
    c_unknown_id = 1;
    c_cls_id = 3;
    c_boundary_cls_id = 4;
    c_model_score_threshold = 0.6640625;
    c_model_margin_threshold = 0.0615234375;
    c_model_threads = 8;

type
    TncNumericFeatureRow = array[0..c_numeric_feature_count - 1] of Single;

function join_path(const base_path, child_path: string): string;
begin
    Result := IncludeTrailingPathDelimiter(base_path) + child_path;
end;

function read_utf8_file(const file_name: string): UTF8String;
var
    stream: TFileStream;
    bytes: UTF8String;
begin
    stream := TFileStream.Create(file_name, fmOpenRead or fmShareDenyNone);
    try
        SetLength(bytes, stream.Size);
        if Length(bytes) > 0 then
            stream.ReadBuffer(bytes[1], Length(bytes));
    finally
        stream.Free;
    end;
    Result := bytes;
end;

function split_segment_path(const value: string): TArray<string>;
var
    index: Integer;
    start_index: Integer;
    count: Integer;
begin
    SetLength(Result, 0);
    start_index := 1;
    count := 0;
    for index := 1 to Length(value) + 1 do
    begin
        if (index <= Length(value)) and (value[index] <> #3) then
            Continue;
        SetLength(Result, count + 1);
        Result[count] := Copy(value, start_index, index - start_index);
        Inc(count);
        start_index := index + 1;
    end;
end;

function ansi_error_text(const buffer: array of AnsiChar): string;
begin
    if Length(buffer) = 0 then
        Exit('');
    Result := UTF8Decode(UTF8String(PAnsiChar(@buffer[0])));
end;

function profile_counter: Int64;
begin
    Result := GetTickCount64;
end;

function signed_log_value(const value: Double): Double;
begin
    if value > 0.0 then
    begin
        Result := Ln(1.0 + value);
    end
    else if value < 0.0 then
    begin
        Result := -Ln(1.0 - value);
    end
    else
    begin
        Result := 0.0;
    end;
end;

function same_int64_array(const first_value: TArray<Int64>;
    const second_value: TArray<Int64>): Boolean;
begin
    Result := Length(first_value) = Length(second_value);
    if Result and (Length(first_value) > 0) then
    begin
        Result := CompareMem(@first_value[0], @second_value[0],
            Length(first_value) * SizeOf(Int64));
    end;
end;

function same_single_array(const first_value: TArray<Single>;
    const second_value: TArray<Single>): Boolean;
begin
    Result := Length(first_value) = Length(second_value);
    if Result and (Length(first_value) > 0) then
    begin
        Result := CompareMem(@first_value[0], @second_value[0],
            Length(first_value) * SizeOf(Single));
    end;
end;

function same_byte_array(const first_value: TArray<Byte>;
    const second_value: TArray<Byte>): Boolean;
begin
    Result := Length(first_value) = Length(second_value);
    if Result and (Length(first_value) > 0) then
    begin
        Result := CompareMem(@first_value[0], @second_value[0],
            Length(first_value) * SizeOf(Byte));
    end;
end;

function same_double_array(const first_value: TArray<Double>;
    const second_value: TArray<Double>): Boolean;
begin
    Result := Length(first_value) = Length(second_value);
    if Result and (Length(first_value) > 0) then
    begin
        Result := CompareMem(@first_value[0], @second_value[0],
            Length(first_value) * SizeOf(Double));
    end;
end;

function unicode_units(const value: string): TArray<string>;
var
    index: Integer;
    count: Integer;
    code_unit: Word;
begin
    SetLength(Result, Length(value));
    count := 0;
    index := 1;
    while index <= Length(value) do
    begin
        code_unit := Ord(value[index]);
        if (code_unit >= $D800) and (code_unit <= $DBFF) and
            (index < Length(value)) and (Ord(value[index + 1]) >= $DC00) and
            (Ord(value[index + 1]) <= $DFFF) then
        begin
            Result[count] := Copy(value, index, 2);
            Inc(index, 2);
        end
        else
        begin
            Result[count] := value[index];
            Inc(index);
        end;
        Inc(count);
    end;
    SetLength(Result, count);
end;

procedure build_numeric_feature_row(const candidate:
    TncLongFinalCandidateDebug; const pool_rank: Integer;
    const baseline_score: Integer; out row: TncNumericFeatureRow);
var
    cursor: Integer;
    ranks: array[0..7] of Integer;

    procedure append_boolean(const value: Boolean);
    begin
        if value then
        begin
            row[cursor] := 1.0;
        end
        else
        begin
            row[cursor] := 0.0;
        end;
        Inc(cursor);
    end;

    procedure append_signed(const value: Double);
    begin
        row[cursor] := signed_log_value(value);
        Inc(cursor);
    end;

var
    rank_index: Integer;
begin
    FillChar(row, SizeOf(row), 0);
    cursor := 0;
    ranks[0] := pool_rank;
    ranks[1] := candidate.legacy_rank;
    ranks[2] := pool_rank;
    ranks[3] := candidate.chain_rank;
    ranks[4] := candidate.path_confidence_tier;
    ranks[5] := candidate.complete_pool_rank;
    ranks[6] := candidate.complete_pool_seed_rank;
    ranks[7] := candidate.complete_pool_anchor_exact_rank;
    for rank_index := Low(ranks) to High(ranks) do
    begin
        if ranks[rank_index] > 0 then
        begin
            row[cursor] := 1.0 / ranks[rank_index];
        end;
        Inc(cursor);
    end;
    for rank_index := Low(ranks) to High(ranks) do
    begin
        row[cursor] := Ln(1.0 + Max(0, ranks[rank_index]));
        Inc(cursor);
    end;

    append_boolean(candidate.has_dict_weight);
    append_boolean(candidate.source_user);
    append_boolean(candidate.source_chain);
    append_boolean(candidate.source_pattern);
    append_boolean(candidate.source_redup);
    append_boolean(candidate.source_local_rerank);
    append_boolean(candidate.source_rule_fallback);
    append_boolean(candidate.chain_present);
    append_boolean(candidate.complete_dictionary);
    append_boolean(candidate.complete_chain);
    append_boolean(candidate.complete_pool_original);
    append_boolean(candidate.complete_pool_anchor_present);
    append_boolean(candidate.ranker_applied);

    append_signed(candidate.candidate_score);
    append_signed(candidate.dict_weight);
    append_signed(candidate.chain_first_stage_score);
    append_signed(candidate.chain_second_stage_score);
    append_signed(candidate.chain_score_gap);
    append_signed(candidate.text_units);
    append_signed(candidate.unit_delta);
    append_signed(candidate.path_confidence_score);
    append_signed(candidate.path_segments);
    append_signed(candidate.path_single_segments);
    append_signed(candidate.path_max_segment_units);
    append_signed(candidate.char_lm_score);
    append_signed(candidate.char_lm_suffix_score);
    append_signed(candidate.char_lm_context_score);
    append_signed(candidate.char_lm_context_gain);
    append_signed(candidate.query_choice_bonus);
    append_signed(candidate.query_path_bonus);
    append_signed(candidate.query_path_penalty);
    append_signed(candidate.word_lm_bonus);
    append_signed(candidate.word_lm_boundary_count);
    append_signed(candidate.word_lm_boundary_min);
    append_signed(candidate.word_lm_boundary_max);
    append_signed(candidate.word_lm_supported_ratio);
    append_signed(candidate.word_lm_strong_ratio);
    append_signed(candidate.word_lm_trigram_ratio);
    append_signed(candidate.word_lm_zero_count);
    append_signed(candidate.score_per_unit);
    append_signed(candidate.dict_weight_per_unit);
    append_signed(candidate.complete_pool_substitutions);
    append_signed(candidate.complete_pool_changed_position);
    append_signed(candidate.complete_pool_anchor_units);
    append_signed(candidate.complete_pool_anchor_source_weight);
    append_signed(candidate.complete_pool_anchor_replacement_weight);
    append_signed(candidate.complete_pool_anchor_top_weight);
    append_signed(candidate.complete_pool_anchor_weight_gain);
    append_signed(candidate.complete_pool_pair_evidence);
    append_signed(candidate.complete_pool_proper_name_confidence);
    append_signed(candidate.complete_pool_signature_support);
    append_signed(candidate.complete_pool_consensus_support);
    append_signed(candidate.complete_pool_consensus_seed_count);
    append_signed(candidate.complete_pool_consensus_support_mean);
    append_signed(candidate.complete_pool_consensus_support_min);
    append_signed(candidate.complete_pool_local_pairwise_score);
    append_signed(candidate.complete_pool_edge_model_anchor_count);
    append_signed(candidate.complete_pool_edge_model_score_total);
    append_signed(candidate.complete_pool_edge_model_score_max);
    append_signed(candidate.complete_pool_edge_model_word_count);
    append_signed(candidate.complete_pool_edge_model_word_score_total);
    append_signed(candidate.complete_pool_edge_model_word_score_min);
    append_signed(candidate.complete_pool_edge_model_word_score_max);
    append_signed(candidate.complete_pool_edge_model_word_score_mean);
    append_signed(candidate.exact_edge_shadow_rank);
    append_signed(candidate.exact_edge_auditor_score);
    append_signed(candidate.exact_edge_auditor_threshold);
    append_signed(candidate.exact_edge_auditor_decision);
    append_signed(candidate.ranker_score);
    append_signed(candidate.abstain_score);
    append_signed(candidate.candidate_score - baseline_score);
    append_boolean(pool_rank = 1);

    if cursor <> c_numeric_feature_count then
    begin
        raise EInvalidOp.CreateFmt('Transformer feature width %d <> %d',
            [cursor, c_numeric_feature_count]);
    end;
end;

function common_prefix_units(const first_ids: TArray<Int64>;
    const first_offset: Integer; const second_ids: TArray<Int64>;
    const second_offset: Integer): Integer;
var
    position: Integer;
begin
    Result := 0;
    for position := 1 to c_sequence_length - 1 do
    begin
        if (first_ids[first_offset + position] = 0) or
            (second_ids[second_offset + position] = 0) or
            (first_ids[first_offset + position] <>
            second_ids[second_offset + position]) then
        begin
            Break;
        end;
        Inc(Result);
    end;
end;

function common_suffix_units(const first_ids: TArray<Int64>;
    const first_offset: Integer; const second_ids: TArray<Int64>;
    const second_offset: Integer): Integer;
var
    first_length: Integer;
    second_length: Integer;
begin
    first_length := 0;
    while (first_length < c_sequence_length - 1) and
        (first_ids[first_offset + first_length + 1] <> 0) do
    begin
        Inc(first_length);
    end;
    second_length := 0;
    while (second_length < c_sequence_length - 1) and
        (second_ids[second_offset + second_length + 1] <> 0) do
    begin
        Inc(second_length);
    end;
    Result := 0;
    while (Result < first_length) and (Result < second_length) and
        (first_ids[first_offset + first_length - Result] =
        second_ids[second_offset + second_length - Result]) do
    begin
        Inc(Result);
    end;
end;

constructor TncPinyinTransformerLoadThread.create(
    const owner: TncPinyinTransformerHostReranker);
begin
    inherited create(True);
    FreeOnTerminate := False;
    Priority := tpLower;
    m_owner := owner;
end;

procedure TncPinyinTransformerLoadThread.detach_owner;
begin
    m_owner := nil;
end;

procedure TncPinyinTransformerLoadThread.Execute;
var
    owner: TncPinyinTransformerHostReranker;
begin
    owner := m_owner;
    if (owner <> nil) and (not Terminated) then
    begin
        owner.load_model;
    end;
end;

constructor TncPinyinTransformerHostReranker.create(
    const base_directory: string; const background_load: Boolean = True;
    const result_timeout_ms: QWord =
    c_nc_pinyin_transformer_result_timeout_ms);
begin
    inherited create;
    m_base_directory := ExcludeTrailingPathDelimiter(
        ExpandFileName(base_directory));
    m_state_lock := TCriticalSection.Create;
    m_run_lock := TCriticalSection.Create;
    m_loader := nil;
    m_module := 0;
    m_session := nil;
    m_create_function := nil;
    m_run_function := nil;
    m_destroy_function := nil;
    m_char_vocab := TDictionary<string, Integer>.Create;
    m_pinyin_vocab := TDictionary<string, Integer>.Create;
    m_ready := False;
    m_load_finished := False;
    m_last_error := '';
    m_result_timeout_ms := result_timeout_ms;
    m_profile_enabled := SameText(GetEnvironmentVariable(
        'CASSOTIS_PINYIN_TRANSFORMER_PROFILE'), '1');
    m_profile_frequency := 0;
    m_profile_calls := 0;
    m_profile_gate_passes := 0;
    m_profile_cache_hits := 0;
    m_profile_build_ticks := 0;
    m_profile_gate_ticks := 0;
    m_profile_inference_ticks := 0;
    m_cache_valid := False;
    m_cache_result := False;
    m_cache_selected_index := 0;
    if m_profile_enabled then
    begin
        m_profile_frequency := 1000;
    end;
    if background_load then
    begin
        m_loader := TncPinyinTransformerLoadThread.create(Self);
        m_loader.Start;
    end
    else
    begin
        load_model;
    end;
end;

destructor TncPinyinTransformerHostReranker.Destroy;
begin
    if m_loader <> nil then
    begin
        m_loader.detach_owner;
        m_loader.Terminate;
        m_loader.WaitFor;
        m_loader.Free;
        m_loader := nil;
    end;
    m_run_lock.Acquire;
    try
        if (m_session <> nil) and Assigned(m_destroy_function) then
        begin
            m_destroy_function(m_session);
            m_session := nil;
        end;
        if m_module <> 0 then
        begin
            FreeLibrary(m_module);
            m_module := 0;
        end;
    finally
        m_run_lock.Release;
    end;
    m_char_vocab.Free;
    m_pinyin_vocab.Free;
    if m_profile_enabled and (m_profile_frequency > 0) and
        (m_profile_calls > 0) then
    begin
        log_message('INFO', Format(
            'profile calls=%d gate_passes=%d cache_hits=%d build_mean_ms=%.3f ' +
            'gate_mean_ms=%.3f inference_mean_ms=%.3f',
            [m_profile_calls, m_profile_gate_passes, m_profile_cache_hits,
            (m_profile_build_ticks * 1000.0 / m_profile_frequency) /
                m_profile_calls,
            (m_profile_gate_ticks * 1000.0 / m_profile_frequency) /
                m_profile_calls,
            (m_profile_inference_ticks * 1000.0 / m_profile_frequency) /
                Max(1, m_profile_gate_passes)]));
    end;
    m_run_lock.Free;
    m_state_lock.Free;
    inherited Destroy;
end;

procedure TncPinyinTransformerHostReranker.log_message(
    const level_text: string; const message_text: string);
begin
    if m_profile_enabled then
        WriteLn(StdErr, '[', level_text, '] pinyin-transformer ', message_text);
end;

function TncPinyinTransformerHostReranker.load_vocab(
    const vocab_path: string): Boolean;
var
    root_value: TJSONData;
    vocab_object: TJSONObject;
    index: Integer;
    item_index: Integer;
begin
    Result := False;
    root_value := GetJSON(read_utf8_file(vocab_path));
    try
        if not (root_value is TJSONObject) then
            Exit;
        vocab_object := TJSONObject(root_value).Find('char') as TJSONObject;
        if vocab_object = nil then
            Exit;
        for item_index := 0 to vocab_object.Count - 1 do
        begin
            index := vocab_object.Items[item_index].AsInteger;
            m_char_vocab.AddOrSetValue(
                vocab_object.Names[item_index], index);
        end;
        vocab_object := TJSONObject(root_value).Find('pinyin') as TJSONObject;
        if vocab_object = nil then
            Exit;
        for item_index := 0 to vocab_object.Count - 1 do
        begin
            index := vocab_object.Items[item_index].AsInteger;
            m_pinyin_vocab.AddOrSetValue(
                vocab_object.Names[item_index], index);
        end;
        Result := (m_char_vocab.Count > 1000) and
            (m_pinyin_vocab.Count > 100);
    finally
        root_value.Free;
    end;
end;

procedure TncPinyinTransformerHostReranker.load_model;
var
    wrapper_path: string;
    model_path: string;
    vocab_path: string;
    model_path_utf8: UTF8String;
    module_local: TLibHandle;
    session_local: Pointer;
    create_local: TncPtCreate;
    run_local: TncPtRun;
    destroy_local: TncPtDestroy;
    error_buffer: array[0..511] of AnsiChar;
    char_ids: TArray<Int64>;
    pinyin_ids: TArray<Int64>;
    boundary_ids: TArray<Int64>;
    numeric_features: TArray<Single>;
    candidate_mask: TArray<Byte>;
    scores: TArray<Single>;
    warmup_index: Integer;
begin
    module_local := 0;
    session_local := nil;
    destroy_local := nil;
    try
        wrapper_path := join_path(m_base_directory,
            'libcassotis_pinyin_transformer_ort.so');
        model_path := join_path(join_path(m_base_directory,
            'pinyin_transformer'), 'pinyin_difference_reranker_int8.onnx');
        vocab_path := join_path(join_path(m_base_directory,
            'pinyin_transformer'), 'vocab.json');
        if not FileExists(wrapper_path) then
        begin
            raise EFileNotFoundException.Create(wrapper_path);
        end;
        if not FileExists(model_path) then
        begin
            raise EFileNotFoundException.Create(model_path);
        end;
        if not FileExists(vocab_path) then
        begin
            raise EFileNotFoundException.Create(vocab_path);
        end;
        if not load_vocab(vocab_path) then
        begin
            raise EInvalidOp.Create('invalid pinyin Transformer vocabulary');
        end;

        module_local := LoadLibrary(UTF8Encode(wrapper_path));
        if module_local = 0 then
        begin
            raise EInvalidOp.CreateFmt('LoadLibrary failed: %s (%s)',
                [wrapper_path, GetLoadErrorStr]);
        end;
        create_local := TncPtCreate(GetProcedureAddress(module_local,
            'nc_pt_create'));
        run_local := TncPtRun(GetProcedureAddress(module_local,
            'nc_pt_run'));
        destroy_local := TncPtDestroy(GetProcedureAddress(module_local,
            'nc_pt_destroy'));
        if (not Assigned(create_local)) or (not Assigned(run_local)) or
            (not Assigned(destroy_local)) then
        begin
            raise EInvalidOp.Create('invalid pinyin Transformer wrapper ABI');
        end;
        FillChar(error_buffer, SizeOf(error_buffer), 0);
        model_path_utf8 := UTF8Encode(model_path);
        session_local := create_local(PAnsiChar(model_path_utf8),
            c_model_threads,
            @error_buffer[0], Length(error_buffer));
        if session_local = nil then
        begin
            raise EInvalidOp.Create(ansi_error_text(error_buffer));
        end;

        SetLength(char_ids, c_model_candidate_count * c_sequence_length);
        SetLength(pinyin_ids, c_sequence_length);
        SetLength(boundary_ids,
            c_model_candidate_count * c_sequence_length);
        SetLength(numeric_features,
            c_model_candidate_count * c_numeric_feature_count);
        SetLength(candidate_mask, c_model_candidate_count);
        SetLength(scores, c_model_candidate_count);
        pinyin_ids[0] := c_cls_id;
        for warmup_index := 0 to 1 do
        begin
            char_ids[warmup_index * c_sequence_length] := c_cls_id;
            boundary_ids[warmup_index * c_sequence_length] :=
                c_boundary_cls_id;
            candidate_mask[warmup_index] := 1;
        end;
        for warmup_index := 0 to 1 do
        begin
            FillChar(error_buffer, SizeOf(error_buffer), 0);
            if run_local(session_local, @char_ids[0], @pinyin_ids[0],
                @boundary_ids[0], @numeric_features[0], @candidate_mask[0],
                @scores[0], Length(scores), @error_buffer[0],
                Length(error_buffer)) = 0 then
            begin
                raise EInvalidOp.Create(ansi_error_text(error_buffer));
            end;
        end;

        m_state_lock.Acquire;
        try
            m_module := module_local;
            module_local := 0;
            m_session := session_local;
            session_local := nil;
            m_create_function := create_local;
            m_run_function := run_local;
            m_destroy_function := destroy_local;
            m_ready := True;
            m_load_finished := True;
            m_last_error := '';
        finally
            m_state_lock.Release;
        end;
        log_message('INFO', 'INT8 model loaded and warmed in host process');
    except
        on e: Exception do
        begin
            if (session_local <> nil) and Assigned(destroy_local) then
            begin
                destroy_local(session_local);
            end;
            if module_local <> 0 then
            begin
                FreeLibrary(module_local);
            end;
            m_state_lock.Acquire;
            try
                m_ready := False;
                m_load_finished := True;
                m_last_error := e.Message;
            finally
                m_state_lock.Release;
            end;
            log_message('WARN', 'disabled: ' + e.Message);
        end;
    end;
end;

procedure TncPinyinTransformerHostReranker.disable_after_inference_error(
    const error_text: string);
begin
    m_state_lock.Acquire;
    try
        m_ready := False;
        m_last_error := error_text;
    finally
        m_state_lock.Release;
    end;
    log_message('WARN', 'inference disabled: ' + error_text);
end;

function TncPinyinTransformerHostReranker.build_inputs(
    const query_text: string;
    const candidates: TncLongFinalCandidateDebugArray;
    out char_ids: TArray<Int64>; out pinyin_ids: TArray<Int64>;
    out boundary_ids: TArray<Int64>;
    out numeric_features: TArray<Single>;
    out candidate_mask: TArray<Byte>;
    out gate_features: TArray<Double>): Boolean;
var
    parser: TncPinyinParser;
    syllables: TncPinyinParseResult;
    candidate_index: Integer;
    position: Integer;
    vocab_id: Integer;
    text_parts: TArray<string>;
    path_parts: TArray<string>;
    path_part_units: TArray<string>;
    joined_path: string;
    path_part: string;
    path_cursor: Integer;
    width: Integer;
    row: TncNumericFeatureRow;
    rows: array[0..c_gate_candidate_count - 1] of TncNumericFeatureRow;
    candidate_count_local: Integer;
    baseline_score: Integer;
    gate_cursor: Integer;
    feature_index: Integer;
    challenger_index: Integer;
    rank_index: Integer;
    aggregate_value: Double;
    aggregate_count: Integer;
    char_offset: Integer;
    other_offset: Integer;
    units: Integer;
    prefix_units: Integer;
    suffix_units: Integer;
    char_differences: Integer;
    boundary_differences: Integer;
    valid_position: Boolean;

    procedure append_gate(const value: Double);
    begin
        gate_features[gate_cursor] := value;
        Inc(gate_cursor);
    end;

begin
    Result := False;
    candidate_count_local := Min(Length(candidates),
        c_gate_candidate_count);
    if candidate_count_local < 2 then
    begin
        Exit;
    end;
    parser := TncPinyinParser.Create;
    try
        syllables := parser.parse(query_text);
    finally
        parser.Free;
    end;
    if (Length(syllables) < 6) or
        (Length(syllables) > c_sequence_length - 1) then
    begin
        Exit;
    end;

    SetLength(char_ids, c_model_candidate_count * c_sequence_length);
    SetLength(pinyin_ids, c_sequence_length);
    SetLength(boundary_ids, c_model_candidate_count * c_sequence_length);
    SetLength(numeric_features,
        c_model_candidate_count * c_numeric_feature_count);
    SetLength(candidate_mask, c_model_candidate_count);
    SetLength(gate_features,
        c_nc_pinyin_transformer_gate_feature_count);

    pinyin_ids[0] := c_cls_id;
    for position := 0 to High(syllables) do
    begin
        if not m_pinyin_vocab.TryGetValue(
            LowerCase(Trim(syllables[position].text)), vocab_id) then
        begin
            vocab_id := c_unknown_id;
        end;
        pinyin_ids[position + 1] := vocab_id;
    end;

    baseline_score := candidates[0].candidate_score;
    for candidate_index := 0 to candidate_count_local - 1 do
    begin
        build_numeric_feature_row(candidates[candidate_index],
            candidate_index + 1, baseline_score, row);
        rows[candidate_index] := row;
        if candidate_index >= c_model_candidate_count then
        begin
            Continue;
        end;
        text_parts := unicode_units(Trim(candidates[candidate_index].text));
        if Length(text_parts) <> Length(syllables) then
        begin
            Exit;
        end;
        char_offset := candidate_index * c_sequence_length;
        char_ids[char_offset] := c_cls_id;
        boundary_ids[char_offset] := c_boundary_cls_id;
        for position := 0 to High(text_parts) do
        begin
            if not m_char_vocab.TryGetValue(text_parts[position], vocab_id) then
            begin
                vocab_id := c_unknown_id;
            end;
            char_ids[char_offset + position + 1] := vocab_id;
        end;

        path_parts := split_segment_path(
            candidates[candidate_index].segment_path);
        joined_path := '';
        for path_part in path_parts do
        begin
            if path_part <> '' then
            begin
                joined_path := joined_path + path_part;
            end;
        end;
        if (Length(path_parts) = 0) or
            (not SameText(joined_path, Trim(candidates[candidate_index].text))) then
        begin
            SetLength(path_parts, 1);
            path_parts[0] := Trim(candidates[candidate_index].text);
        end;
        path_cursor := 1;
        for path_part in path_parts do
        begin
            if path_part = '' then
            begin
                Continue;
            end;
            path_part_units := unicode_units(path_part);
            width := Min(Length(path_part_units),
                c_sequence_length - path_cursor);
            if width <= 0 then
            begin
                Break;
            end;
            if width = 1 then
            begin
                boundary_ids[char_offset + path_cursor] := 3;
            end
            else
            begin
                boundary_ids[char_offset + path_cursor] := 1;
                boundary_ids[char_offset + path_cursor + width - 1] := 2;
            end;
            Inc(path_cursor, width);
        end;

        for feature_index := 0 to c_numeric_feature_count - 1 do
        begin
            numeric_features[candidate_index * c_numeric_feature_count +
                feature_index] := row[feature_index];
        end;
        candidate_mask[candidate_index] := 1;
    end;

    gate_cursor := 0;
    append_gate(candidate_count_local);
    append_gate(Length(syllables));
    for feature_index := 0 to c_numeric_feature_count - 1 do
    begin
        append_gate(rows[0][feature_index]);
    end;
    for rank_index := 1 to 3 do
    begin
        if rank_index < candidate_count_local then
        begin
            append_gate(1.0);
            for feature_index := 0 to c_numeric_feature_count - 1 do
            begin
                append_gate(rows[rank_index][feature_index] -
                    rows[0][feature_index]);
            end;
        end
        else
        begin
            append_gate(0.0);
            for feature_index := 0 to c_numeric_feature_count - 1 do
            begin
                append_gate(0.0);
            end;
        end;
    end;

    for rank_index := 0 to 2 do
    begin
        for feature_index := 0 to c_numeric_feature_count - 1 do
        begin
            aggregate_count := 0;
            if rank_index = 0 then
            begin
                aggregate_value := -MaxDouble;
            end
            else if rank_index = 1 then
            begin
                aggregate_value := MaxDouble;
            end
            else
            begin
                aggregate_value := 0.0;
            end;
            for challenger_index := 1 to candidate_count_local - 1 do
            begin
                if rank_index = 0 then
                begin
                    aggregate_value := Max(aggregate_value,
                        rows[challenger_index][feature_index] -
                        rows[0][feature_index]);
                end
                else if rank_index = 1 then
                begin
                    aggregate_value := Min(aggregate_value,
                        rows[challenger_index][feature_index] -
                        rows[0][feature_index]);
                end
                else
                begin
                    aggregate_value := aggregate_value +
                        rows[challenger_index][feature_index] -
                        rows[0][feature_index];
                end;
                Inc(aggregate_count);
            end;
            if (rank_index = 2) and (aggregate_count > 0) then
            begin
                aggregate_value := aggregate_value / aggregate_count;
            end;
            append_gate(aggregate_value);
        end;
    end;

    char_offset := 0;
    for rank_index := 1 to 5 do
    begin
        if rank_index < candidate_count_local then
        begin
            other_offset := rank_index * c_sequence_length;
            units := 0;
            char_differences := 0;
            boundary_differences := 0;
            for position := 1 to c_sequence_length - 1 do
            begin
                if char_ids[other_offset + position] <> 0 then
                begin
                    Inc(units);
                end;
                valid_position := (char_ids[char_offset + position] <> 0) or
                    (char_ids[other_offset + position] <> 0);
                if valid_position and
                    (char_ids[char_offset + position] <>
                    char_ids[other_offset + position]) then
                begin
                    Inc(char_differences);
                end;
                if valid_position and
                    (boundary_ids[char_offset + position] <>
                    boundary_ids[other_offset + position]) then
                begin
                    Inc(boundary_differences);
                end;
            end;
            prefix_units := common_prefix_units(char_ids, char_offset,
                char_ids, other_offset);
            suffix_units := common_suffix_units(char_ids, char_offset,
                char_ids, other_offset);
            append_gate(1.0);
            append_gate(units);
            append_gate(prefix_units);
            append_gate(suffix_units);
            append_gate(char_differences);
            append_gate(boundary_differences);
            append_gate(candidates[rank_index].complete_pool_source_kind);
        end
        else
        begin
            for feature_index := 0 to 6 do
            begin
                append_gate(0.0);
            end;
        end;
    end;

    if gate_cursor <> c_nc_pinyin_transformer_gate_feature_count then
    begin
        raise EInvalidOp.CreateFmt('Gate feature width %d <> %d',
            [gate_cursor, c_nc_pinyin_transformer_gate_feature_count]);
    end;
    Result := True;
end;

function TncPinyinTransformerHostReranker.should_invoke(
    const gate_features: TArray<Double>): Boolean;
var
    fixed_features: TncPinyinTransformerGateFeatures;
begin
    Result := False;
    if Length(gate_features) <> Length(fixed_features) then
    begin
        Exit;
    end;
    Move(gate_features[0], fixed_features[0], SizeOf(fixed_features));
    Result := nc_pinyin_transformer_gate_score(fixed_features) >=
        c_nc_pinyin_transformer_gate_threshold;
end;

function TncPinyinTransformerHostReranker.try_cached_decision(
    const char_ids: TArray<Int64>; const pinyin_ids: TArray<Int64>;
    const boundary_ids: TArray<Int64>;
    const numeric_features: TArray<Single>;
    const candidate_mask: TArray<Byte>;
    const gate_features: TArray<Double>; out cached_result: Boolean;
    out cached_selected_index: Integer): Boolean;
begin
    cached_result := False;
    cached_selected_index := 0;
    m_run_lock.Acquire;
    try
        Result := m_cache_valid and
            same_int64_array(char_ids, m_cache_char_ids) and
            same_int64_array(pinyin_ids, m_cache_pinyin_ids) and
            same_int64_array(boundary_ids, m_cache_boundary_ids) and
            same_single_array(numeric_features,
            m_cache_numeric_features) and
            same_byte_array(candidate_mask, m_cache_candidate_mask) and
            same_double_array(gate_features, m_cache_gate_features);
        if Result then
        begin
            cached_result := m_cache_result;
            cached_selected_index := m_cache_selected_index;
        end;
    finally
        m_run_lock.Release;
    end;
end;

procedure TncPinyinTransformerHostReranker.cache_decision(
    const char_ids: TArray<Int64>; const pinyin_ids: TArray<Int64>;
    const boundary_ids: TArray<Int64>;
    const numeric_features: TArray<Single>;
    const candidate_mask: TArray<Byte>;
    const gate_features: TArray<Double>; const decision_result: Boolean;
    const decision_selected_index: Integer);
begin
    m_run_lock.Acquire;
    try
        m_cache_char_ids := Copy(char_ids);
        m_cache_pinyin_ids := Copy(pinyin_ids);
        m_cache_boundary_ids := Copy(boundary_ids);
        m_cache_numeric_features := Copy(numeric_features);
        m_cache_candidate_mask := Copy(candidate_mask);
        m_cache_gate_features := Copy(gate_features);
        m_cache_result := decision_result;
        m_cache_selected_index := decision_selected_index;
        m_cache_valid := True;
    finally
        m_run_lock.Release;
    end;
end;

function TncPinyinTransformerHostReranker.try_select(
    const query_text: string;
    const candidates: TncLongFinalCandidateDebugArray;
    out selected_index: Integer): Boolean;
var
    char_ids: TArray<Int64>;
    pinyin_ids: TArray<Int64>;
    boundary_ids: TArray<Int64>;
    numeric_features: TArray<Single>;
    candidate_mask: TArray<Byte>;
    gate_features: TArray<Double>;
    scores: TArray<Single>;
    error_buffer: array[0..511] of AnsiChar;
    run_function_local: TncPtRun;
    session_local: Pointer;
    candidate_index: Integer;
    best_index: Integer;
    second_index: Integer;
    best_score: Single;
    second_score: Single;
    started_tick: UInt64;
    elapsed_ms: UInt64;
    inference_ok: Boolean;
    profile_tick: Int64;
    profile_end_tick: Int64;
    cached_result: Boolean;
    cached_selected_index: Integer;
begin
    Result := False;
    selected_index := 0;
    m_state_lock.Acquire;
    try
        if not m_ready then
        begin
            Exit;
        end;
        run_function_local := m_run_function;
        session_local := m_session;
    finally
        m_state_lock.Release;
    end;
    if (session_local = nil) or (not Assigned(run_function_local)) then
    begin
        Exit;
    end;
    if m_profile_enabled then
    begin
        profile_tick := profile_counter;
    end;
    if not build_inputs(query_text, candidates, char_ids, pinyin_ids,
        boundary_ids, numeric_features, candidate_mask, gate_features) then
    begin
        Exit;
    end;
    if m_profile_enabled then
    begin
        profile_end_tick := profile_counter;
        Inc(m_profile_calls);
        Inc(m_profile_build_ticks, profile_end_tick - profile_tick);
        profile_tick := profile_end_tick;
    end;
    if try_cached_decision(char_ids, pinyin_ids, boundary_ids,
        numeric_features, candidate_mask, gate_features, cached_result,
        cached_selected_index) then
    begin
        if m_profile_enabled then
        begin
            Inc(m_profile_cache_hits);
        end;
        selected_index := cached_selected_index;
        Result := cached_result;
        Exit;
    end;
    if not should_invoke(gate_features) then
    begin
        if m_profile_enabled then
        begin
            profile_end_tick := profile_counter;
            Inc(m_profile_gate_ticks, profile_end_tick - profile_tick);
        end;
        cache_decision(char_ids, pinyin_ids, boundary_ids,
            numeric_features, candidate_mask, gate_features, False, 0);
        Exit;
    end;
    if m_profile_enabled then
    begin
        profile_end_tick := profile_counter;
        Inc(m_profile_gate_ticks, profile_end_tick - profile_tick);
        Inc(m_profile_gate_passes);
    end;

    SetLength(scores, c_model_candidate_count);
    FillChar(error_buffer, SizeOf(error_buffer), 0);
    started_tick := GetTickCount64;
    m_run_lock.Acquire;
    try
        if m_profile_enabled then
        begin
            profile_tick := profile_counter;
        end;
        inference_ok := run_function_local(session_local, @char_ids[0],
            @pinyin_ids[0], @boundary_ids[0], @numeric_features[0],
            @candidate_mask[0], @scores[0], Length(scores),
            @error_buffer[0], Length(error_buffer)) <> 0;
        if m_profile_enabled then
        begin
            profile_end_tick := profile_counter;
            Inc(m_profile_inference_ticks, profile_end_tick - profile_tick);
        end;
    finally
        m_run_lock.Release;
    end;
    elapsed_ms := GetTickCount64 - started_tick;
    if not inference_ok then
    begin
        disable_after_inference_error(ansi_error_text(error_buffer));
        Exit;
    end;
    if (m_result_timeout_ms > 0) and
        (elapsed_ms > m_result_timeout_ms) then
    begin
        Exit;
    end;

    best_index := -1;
    second_index := -1;
    best_score := -MaxSingle;
    second_score := -MaxSingle;
    for candidate_index := 0 to Min(Length(candidates),
        c_model_candidate_count) - 1 do
    begin
        if candidate_mask[candidate_index] = 0 then
        begin
            Continue;
        end;
        if scores[candidate_index] > best_score then
        begin
            second_score := best_score;
            second_index := best_index;
            best_score := scores[candidate_index];
            best_index := candidate_index;
        end
        else if scores[candidate_index] > second_score then
        begin
            second_score := scores[candidate_index];
            second_index := candidate_index;
        end;
    end;
    if (best_index <= 0) or (second_index < 0) or
        ((best_score - scores[0]) < c_model_score_threshold) or
        ((best_score - second_score) < c_model_margin_threshold) then
    begin
        cache_decision(char_ids, pinyin_ids, boundary_ids,
            numeric_features, candidate_mask, gate_features, False, 0);
        Exit;
    end;
    selected_index := best_index;
    Result := True;
    cache_decision(char_ids, pinyin_ids, boundary_ids,
        numeric_features, candidate_mask, gate_features, True,
        selected_index);
end;

function TncPinyinTransformerHostReranker.ready: Boolean;
begin
    m_state_lock.Acquire;
    try
        Result := m_ready;
    finally
        m_state_lock.Release;
    end;
end;

function TncPinyinTransformerHostReranker.wait_until_ready(
    const timeout_ms: Cardinal): Boolean;
var
    started_tick: UInt64;
    finished: Boolean;
begin
    started_tick := GetTickCount64;
    repeat
        m_state_lock.Acquire;
        try
            Result := m_ready;
            finished := m_load_finished;
        finally
            m_state_lock.Release;
        end;
        if Result or finished then
        begin
            Exit;
        end;
        Sleep(5);
    until (GetTickCount64 - started_tick) >= timeout_ms;
    Result := ready;
end;

function TncPinyinTransformerHostReranker.last_error: string;
begin
    m_state_lock.Acquire;
    try
        Result := m_last_error;
    finally
        m_state_lock.Release;
    end;
end;

end.
