unit nc_types;

{$codepage utf8}
{$mode delphiunicode}
{$modeswitch typehelpers}
{$H+}

interface

uses
    SysUtils;

const
    c_nc_shortcut_config_signature = $4E435348;
    c_default_candidate_font_name = 'Noto Sans CJK SC';
    c_min_candidate_font_size = 7;
    c_default_candidate_font_size = 12;
    c_max_candidate_font_size = 18;
    c_candidate_font_layout_reference_size = 10;
    c_candidate_font_size_level_count = 11;
    c_default_candidate_font_size_level = 5;
    c_candidate_font_size_levels: array[0..c_candidate_font_size_level_count - 1]
        of Integer = (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18);
    c_invalid_context_id: QWord = 0;
    c_default_candidate_page_size = 9;
    c_min_candidate_page_size = 3;
    c_max_candidate_page_size = 9;
    c_default_candidate_color_scheme = 0;
    c_min_candidate_color_scheme = 0;
    c_max_candidate_color_scheme = 5;

type
    TncStringHelper = type helper for UnicodeString
    public
        function StartsWith(const prefix: string;
            const ignore_case: Boolean = False): Boolean;
        function Split(const separators: array of Char): TArray<string>;
            overload;
        function Split(const separators: array of Char;
            const options: TStringSplitOptions): TArray<string>; overload;
    end;

    TncFuzzyPinyinRule = (
        fpr_z_zh,
        fpr_c_ch,
        fpr_s_sh,
        fpr_l_n,
        fpr_f_h,
        fpr_r_l,
        fpr_an_ang,
        fpr_en_eng,
        fpr_in_ing,
        fpr_ian_iang,
        fpr_uan_uang
    );
    TncFuzzyPinyinRules = set of TncFuzzyPinyinRule;

    TncCandidateSource = (cs_rule, cs_user);
    TncCandidateDisplayKind = (cdk_default, cdk_lm_compound);
    TncInputMode = (im_chinese, im_english);
    TncDictionaryVariant = (dv_simplified, dv_traditional);
    TncPinyinInputScheme = (
        pis_full_pinyin,
        pis_microsoft_shuangpin,
        pis_xiaohe_shuangpin,
        pis_ziranma_shuangpin,
        pis_sogou_shuangpin,
        pis_ziguang_shuangpin,
        pis_pinyinjiajia_shuangpin
    );
    TncCandidatePageKeyScheme = (
        cpks_minus_plus,
        cpks_brackets,
        cpks_comma_period,
        cpks_shift_tab
    );
    TncOneKeyCompletionKey = (ock_tab, ock_backtick);
    TncShortcutAction = (
        sa_input_mode_toggle,
        sa_punctuation_toggle,
        sa_dictionary_variant_toggle,
        sa_full_width_toggle,
        sa_open_settings
    );

    TncShortcut = record
        key_code: Word;
        shift_down: Boolean;
        ctrl_down: Boolean;
        alt_down: Boolean;
    end;

    TncShortcutConfig = record
        signature: Cardinal;
        input_mode_toggle: TncShortcut;
        punctuation_toggle: TncShortcut;
        dictionary_variant_toggle: TncShortcut;
        full_width_toggle: TncShortcut;
        open_settings: TncShortcut;
    end;

    TncEngineState = record
        input_mode: TncInputMode;
        dictionary_variant: TncDictionaryVariant;
        pinyin_scheme: TncPinyinInputScheme;
        fuzzy_pinyin_enabled: Boolean;
        fuzzy_pinyin_rules: TncFuzzyPinyinRules;
        full_width_mode: Boolean;
        punctuation_full_width: Boolean;
        candidate_page_size: Integer;
        candidate_page_key_scheme: TncCandidatePageKeyScheme;
        one_key_completion_key: TncOneKeyCompletionKey;
        debug_mode: Boolean;
        shortcuts: TncShortcutConfig;
    end;

    TncEngineConfig = record
        input_mode: TncInputMode;
        pinyin_input_scheme: TncPinyinInputScheme;
        fuzzy_pinyin_enabled: Boolean;
        fuzzy_pinyin_rules: TncFuzzyPinyinRules;
        max_candidates: Integer;
        enable_ctrl_space_toggle: Boolean;
        enable_shift_space_full_width_toggle: Boolean;
        enable_ctrl_period_punct_toggle: Boolean;
        full_width_mode: Boolean;
        punctuation_full_width: Boolean;
        enable_segment_candidates: Boolean;
        segment_head_only_multi_syllable: Boolean;
        candidate_font_name: string;
        candidate_font_size: Integer;
        candidate_page_size: Integer;
        candidate_page_key_scheme: TncCandidatePageKeyScheme;
        one_key_completion_key: TncOneKeyCompletionKey;
        candidate_color_scheme: Integer;
        debug_mode: Boolean;
        dictionary_variant: TncDictionaryVariant;
        shortcuts: TncShortcutConfig;
    end;

    TncCandidate = record
        text: string;
        comment: string;
        score: Integer;
        source: TncCandidateSource;
        has_dict_weight: Boolean;
        dict_weight: Integer;
        fuzzy_cost: Integer;
        fuzzy_rules: TncFuzzyPinyinRules;
        display_kind: TncCandidateDisplayKind;
        deletable: Boolean;
    end;
    TncCandidateList = array of TncCandidate;

    TncOneKeyCompletionSource = (
        okcs_none,
        okcs_user_exact,
        okcs_base_exact,
        okcs_transition,
        okcs_long_transition,
        okcs_long_neural,
        okcs_document_copy
    );

    TncOneKeyCompletion = record
        text: string;
        full_pinyin: string;
        path_text: string;
        weight: Integer;
        popularity_prior: Integer;
        corpus_score: Integer;
        document_score: Integer;
        source_count: Integer;
        path_score: Integer;
        vertical_penalty: Integer;
        vertical_layer_kind: Integer;
        has_popularity_prior: Boolean;
        feedback_count: Integer;
        feedback_reject_count: Integer;
        prefix_anchored: Boolean;
        anchor_text: string;
        suffix_text: string;
        anchor_path: string;
        source: TncOneKeyCompletionSource;
    end;
    TncOneKeyCompletionList = array of TncOneKeyCompletion;

    TncLongOneKeyCompletion = record
        anchor_text: string;
        anchor_path: string;
        suffix_pinyin: string;
        suffix_text: string;
        suffix_path: string;
        evidence: Integer;
        source_count: Integer;
        feedback_count: Integer;
        feedback_reject_count: Integer;
    end;
    TncLongOneKeyCompletionList = array of TncLongOneKeyCompletion;

    TncExactTextPath = record
        valid: Boolean;
        text: string;
        full_pinyin: string;
        path_text: string;
        weight: Integer;
        segment_count: Integer;
        unit_count: Integer;
    end;

    TncOneKeyCompletionCompetitionEvidence = record
        context_width: Integer;
        text: string;
        full_pinyin: string;
        evidence_score: Integer;
        occurrence_count: Integer;
        source_count: Integer;
    end;
    TncOneKeyCompletionCompetitionEvidenceList =
        array of TncOneKeyCompletionCompetitionEvidence;

    TncOneKeyCompletionPairAudit = record
        available: Boolean;
        context_width: Integer;
        decision: Integer;
        keep_count: Integer;
        switch_count: Integer;
        confidence_milli: Integer;
    end;

    TncPairPathEvidence = record
        encoded_path: string;
        query_path_weight: Integer;
        lm_transition_weight: Integer;
    end;
    TncPairPathEvidenceList = array of TncPairPathEvidence;

    TncKeyState = record
        shift_down: Boolean;
        ctrl_down: Boolean;
        alt_down: Boolean;
        caps_lock: Boolean;
    end;

    TncKeyModifier = (
        km_shift,
        km_control,
        km_alt,
        km_super,
        km_caps_lock,
        km_num_lock
    );
    TncKeyModifiers = set of TncKeyModifier;

    TncSpecialKey = (
        sk_none,
        sk_backspace,
        sk_delete,
        sk_enter,
        sk_escape,
        sk_space,
        sk_tab,
        sk_left,
        sk_right,
        sk_up,
        sk_down,
        sk_home,
        sk_end,
        sk_page_up,
        sk_page_down,
        sk_numpad_multiply,
        sk_numpad_add,
        sk_numpad_subtract,
        sk_numpad_decimal,
        sk_numpad_divide,
        sk_shift,
        sk_control,
        sk_alt,
        sk_super,
        sk_f1,
        sk_f2,
        sk_f3,
        sk_f4,
        sk_f5,
        sk_f6,
        sk_f7,
        sk_f8,
        sk_f9,
        sk_f10,
        sk_f11,
        sk_f12,
        sk_f13,
        sk_f14,
        sk_f15,
        sk_f16,
        sk_f17,
        sk_f18,
        sk_f19,
        sk_f20,
        sk_f21,
        sk_f22,
        sk_f23,
        sk_f24
    );

    TncKeyEvent = record
        text: string;
        special_key: TncSpecialKey;
        modifiers: TncKeyModifiers;
        scan_code: Cardinal;
        is_release: Boolean;
        is_repeat: Boolean;
        timestamp_ms: QWord;
    end;

    TncEngineResult = record
        handled: Boolean;
        async_pending: Boolean;
        commit_text: string;
        preedit_text: string;
        query_text: string;
        candidates: TncCandidateList;
        selected_index: Integer;
        page_index: Integer;
        page_count: Integer;
        completion_text: string;
        error_code: Cardinal;
        error_text: string;
    end;

procedure nc_initialize_engine_result(out value: TncEngineResult);
procedure nc_initialize_engine_state(out value: TncEngineState);
function nc_fuzzy_pinyin_rules_to_mask(
    const rules: TncFuzzyPinyinRules): Cardinal;
function nc_fuzzy_pinyin_rules_from_mask(
    const mask: Cardinal): TncFuzzyPinyinRules;
function nc_fuzzy_pinyin_rules_mask_is_valid(const mask: Cardinal): Boolean;
function nc_engine_states_equal(const left_value: TncEngineState;
    const right_value: TncEngineState): Boolean;
function nc_join_strings(const separator: string;
    const values: array of string): string;

implementation

function TncStringHelper.StartsWith(const prefix: string;
    const ignore_case: Boolean): Boolean;
begin
    if Length(prefix) > Length(Self) then
    begin
        Exit(False);
    end;
    if ignore_case then
    begin
        Result := CompareText(Copy(Self, 1, Length(prefix)), prefix) = 0;
    end
    else
    begin
        Result := Copy(Self, 1, Length(prefix)) = prefix;
    end;
end;

function TncStringHelper.Split(
    const separators: array of Char): TArray<string>;
begin
    Result := Split(separators, TStringSplitOptions.None);
end;

function TncStringHelper.Split(const separators: array of Char;
    const options: TStringSplitOptions): TArray<string>;
var
    character_index: Integer;
    separator_index: Integer;
    token_start: Integer;
    token_length: Integer;
    result_count: Integer;
    is_separator: Boolean;

    procedure AppendToken(const start_index: Integer;
        const length_value: Integer);
    begin
        if (length_value = 0) and
            (options = TStringSplitOptions.ExcludeEmpty) then
        begin
            Exit;
        end;
        result_count := Length(Result);
        SetLength(Result, result_count + 1);
        Result[result_count] := Copy(Self, start_index, length_value);
    end;

begin
    Result := nil;
    token_start := 1;
    for character_index := 1 to Length(Self) do
    begin
        is_separator := False;
        for separator_index := Low(separators) to High(separators) do
        begin
            if Self[character_index] = separators[separator_index] then
            begin
                is_separator := True;
                Break;
            end;
        end;
        if not is_separator then
        begin
            Continue;
        end;
        token_length := character_index - token_start;
        AppendToken(token_start, token_length);
        token_start := character_index + 1;
    end;
    AppendToken(token_start, Length(Self) - token_start + 1);
end;

procedure nc_initialize_engine_result(out value: TncEngineResult);
begin
    value.handled := False;
    value.async_pending := False;
    value.commit_text := '';
    value.preedit_text := '';
    value.query_text := '';
    SetLength(value.candidates, 0);
    value.selected_index := -1;
    value.page_index := 0;
    value.page_count := 0;
    value.completion_text := '';
    value.error_code := 0;
    value.error_text := '';
end;

procedure nc_initialize_engine_state(out value: TncEngineState);
begin
    value.input_mode := im_chinese;
    value.dictionary_variant := dv_simplified;
    value.pinyin_scheme := pis_full_pinyin;
    value.fuzzy_pinyin_enabled := False;
    value.fuzzy_pinyin_rules := [];
    value.full_width_mode := False;
    value.punctuation_full_width := True;
    value.candidate_page_size := c_default_candidate_page_size;
    value.candidate_page_key_scheme := cpks_minus_plus;
    value.one_key_completion_key := ock_tab;
    value.debug_mode := False;
    value.shortcuts.signature := c_nc_shortcut_config_signature;
    value.shortcuts.input_mode_toggle.key_code := $10;
    value.shortcuts.input_mode_toggle.shift_down := False;
    value.shortcuts.input_mode_toggle.ctrl_down := False;
    value.shortcuts.input_mode_toggle.alt_down := False;
    value.shortcuts.punctuation_toggle.key_code := $BE;
    value.shortcuts.punctuation_toggle.shift_down := False;
    value.shortcuts.punctuation_toggle.ctrl_down := True;
    value.shortcuts.punctuation_toggle.alt_down := False;
    value.shortcuts.dictionary_variant_toggle.key_code := Ord('T');
    value.shortcuts.dictionary_variant_toggle.shift_down := True;
    value.shortcuts.dictionary_variant_toggle.ctrl_down := True;
    value.shortcuts.dictionary_variant_toggle.alt_down := False;
    value.shortcuts.full_width_toggle.key_code := $20;
    value.shortcuts.full_width_toggle.shift_down := True;
    value.shortcuts.full_width_toggle.ctrl_down := False;
    value.shortcuts.full_width_toggle.alt_down := False;
    value.shortcuts.open_settings.key_code := $79;
    value.shortcuts.open_settings.shift_down := True;
    value.shortcuts.open_settings.ctrl_down := True;
    value.shortcuts.open_settings.alt_down := False;
end;

function nc_fuzzy_pinyin_rules_to_mask(
    const rules: TncFuzzyPinyinRules): Cardinal;
var
    rule: TncFuzzyPinyinRule;
begin
    Result := 0;
    for rule := Low(TncFuzzyPinyinRule) to High(TncFuzzyPinyinRule) do
        if rule in rules then
            Result := Result or (Cardinal(1) shl Ord(rule));
end;

function nc_fuzzy_pinyin_rules_from_mask(
    const mask: Cardinal): TncFuzzyPinyinRules;
var
    rule: TncFuzzyPinyinRule;
begin
    Result := [];
    for rule := Low(TncFuzzyPinyinRule) to High(TncFuzzyPinyinRule) do
        if (mask and (Cardinal(1) shl Ord(rule))) <> 0 then
            Include(Result, rule);
end;

function nc_fuzzy_pinyin_rules_mask_is_valid(
    const mask: Cardinal): Boolean;
const
    c_known_mask = (Cardinal(1) shl
        (Ord(High(TncFuzzyPinyinRule)) + 1)) - 1;
begin
    Result := (mask and not c_known_mask) = 0;
end;

function nc_engine_states_equal(const left_value: TncEngineState;
    const right_value: TncEngineState): Boolean;
    function ShortcutEqual(const left_shortcut: TncShortcut;
        const right_shortcut: TncShortcut): Boolean;
    begin
        Result := (left_shortcut.key_code = right_shortcut.key_code) and
            (left_shortcut.shift_down = right_shortcut.shift_down) and
            (left_shortcut.ctrl_down = right_shortcut.ctrl_down) and
            (left_shortcut.alt_down = right_shortcut.alt_down);
    end;
begin
    Result := (left_value.input_mode = right_value.input_mode) and
        (left_value.dictionary_variant = right_value.dictionary_variant) and
        (left_value.pinyin_scheme = right_value.pinyin_scheme) and
        (left_value.fuzzy_pinyin_enabled =
        right_value.fuzzy_pinyin_enabled) and
        (left_value.fuzzy_pinyin_rules = right_value.fuzzy_pinyin_rules) and
        (left_value.full_width_mode = right_value.full_width_mode) and
        (left_value.punctuation_full_width =
        right_value.punctuation_full_width) and
        (left_value.candidate_page_size =
        right_value.candidate_page_size) and
        (left_value.candidate_page_key_scheme =
        right_value.candidate_page_key_scheme) and
        (left_value.one_key_completion_key =
        right_value.one_key_completion_key) and
        (left_value.debug_mode = right_value.debug_mode) and
        (left_value.shortcuts.signature = right_value.shortcuts.signature) and
        ShortcutEqual(left_value.shortcuts.input_mode_toggle,
        right_value.shortcuts.input_mode_toggle) and
        ShortcutEqual(left_value.shortcuts.punctuation_toggle,
        right_value.shortcuts.punctuation_toggle) and
        ShortcutEqual(left_value.shortcuts.dictionary_variant_toggle,
        right_value.shortcuts.dictionary_variant_toggle) and
        ShortcutEqual(left_value.shortcuts.full_width_toggle,
        right_value.shortcuts.full_width_toggle) and
        ShortcutEqual(left_value.shortcuts.open_settings,
        right_value.shortcuts.open_settings);
end;

function nc_join_strings(const separator: string;
    const values: array of string): string;
var
    index: Integer;
begin
    Result := '';
    for index := Low(values) to High(values) do
    begin
        if index > Low(values) then
        begin
            Result := Result + separator;
        end;
        Result := Result + values[index];
    end;
end;

end.
