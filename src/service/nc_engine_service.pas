unit nc_engine_service;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_types,
    nc_engine_contract,
    nc_engine_context,
    nc_engine_intf,
    nc_dictionary_sqlite,
    nc_user_dictionary,
    nc_pinyin_transformer_host,
    nc_local_completion_host;

const
    c_engine_error_unknown_context = 1;
    c_engine_error_stale_generation = 2;
    c_engine_error_not_implemented = 3;
    c_engine_error_dictionary_unavailable = 4;
    c_engine_error_dictionary_query = 5;

type
    TncEngineService = class(TncEngineCore)
    private
        FContexts: TncEngineContextRegistry;
        FEngine: TncEngine;
        FStateStore: TncUserDictionary;
        FState: TncEngineState;
        FConfig: TncEngineConfig;
        FLongNeuralReranker: IncLongNeuralReranker;
        FLocalCompletionHost: TncLocalCompletionHost;
        FLoadedContextId: QWord;
        FDictionaryError: string;
        procedure Initialize(const dictionary_path: string;
            const traditional_dictionary_path: string;
            const user_dictionary_path: string);
        function PrepareContext(const context_id: QWord;
            const generation_id: QWord; out context: TncEngineContext): Cardinal;
        procedure ApplyStateToConfig(const state: TncEngineState;
            var config: TncEngineConfig);
        function PersistentStateChanged(const old_state: TncEngineState;
            const new_state: TncEngineState): Boolean;
        function SavePersistentState(const state: TncEngineState): Boolean;
        procedure SyncStateFromEngine;
        procedure SetEngineLeftContext(const context: TncEngineContext);
        function ActivateContext(const context: TncEngineContext): Boolean;
        function KeyEventToVirtualKey(const key_event: TncKeyEvent;
            out key_code: Word; out key_state: TncKeyState): Boolean;
        procedure SyncContext(const context: TncEngineContext);
        procedure PopulateResult(const context: TncEngineContext;
            var engine_result: TncEngineResult);
        function QueueLongNeuralCompletion(
            const context: TncEngineContext): Boolean;
        function RemoveCandidate(const context: TncEngineContext;
            const candidate_index: Integer): Boolean;
    public
        constructor Create; overload;
        constructor Create(const dictionary_path: string); overload;
        constructor Create(const dictionary_path: string;
            const user_dictionary_path: string); overload;
        constructor Create(const dictionary_path: string;
            const traditional_dictionary_path: string;
            const user_dictionary_path: string); overload;
        destructor Destroy; override;
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
        function ProcessKey(const context_id: QWord; const generation_id: QWord;
            const key_event: TncKeyEvent): TncEngineResult; override;
        function PollResult(const context_id: QWord;
            const generation_id: QWord): TncEngineResult; override;
        function ContextCount: Integer;
        procedure ClearContexts;
        function DictionaryReady: Boolean;
        function UserDictionaryReady: Boolean;
        function RemoveUserCandidate(const context_id: QWord;
            const generation_id: QWord;
            const candidate_index: Integer): Boolean;
        property DictionaryError: string read FDictionaryError;
    end;

implementation

uses
    SysUtils,
    nc_config,
    nc_platform_compat,
    nc_shortcut;

constructor TncEngineService.Create;
begin
    inherited Create;
    Initialize('', '', '');
end;

constructor TncEngineService.Create(const dictionary_path: string);
begin
    inherited Create;
    Initialize(dictionary_path, get_default_dictionary_path_traditional, '');
end;

constructor TncEngineService.Create(const dictionary_path: string;
    const user_dictionary_path: string);
begin
    inherited Create;
    Initialize(dictionary_path, get_default_dictionary_path_traditional,
        user_dictionary_path);
end;

constructor TncEngineService.Create(const dictionary_path: string;
    const traditional_dictionary_path: string;
    const user_dictionary_path: string);
begin
    inherited Create;
    Initialize(dictionary_path, traditional_dictionary_path,
        user_dictionary_path);
end;

procedure TncEngineService.Initialize(const dictionary_path: string;
    const traditional_dictionary_path: string;
    const user_dictionary_path: string);
var
    provider: TncSqliteDictionary;
    active_dictionary_path: string;
    runtime_directory: string;
begin
    FContexts := TncEngineContextRegistry.Create;
    FEngine := nil;
    FStateStore := nil;
    FLongNeuralReranker := nil;
    FLocalCompletionHost := nil;
    FLoadedContextId := c_invalid_context_id;
    FDictionaryError := '';
    nc_initialize_engine_state(FState);

    if user_dictionary_path <> '' then
    begin
        FStateStore := TncUserDictionary.Create(user_dictionary_path);
        if not FStateStore.Open then
        begin
            FDictionaryError := 'user dictionary open failed: ' +
                FStateStore.ErrorMessage;
            FreeAndNil(FStateStore);
        end
        else if not FStateStore.LoadEngineState(FState) then
            FDictionaryError := 'user state load failed: ' +
                FStateStore.ErrorMessage;
    end;

    FConfig := nc_default_engine_config;
    ApplyStateToConfig(FState, FConfig);
    FEngine := TncEngine.Create(FConfig, False, True, False);
    FEngine.configure_dictionary_paths(dictionary_path,
        traditional_dictionary_path, user_dictionary_path);

    if (dictionary_path = '') and (traditional_dictionary_path = '') and
        (user_dictionary_path = '') then
        Exit;

    if FState.dictionary_variant = dv_traditional then
        active_dictionary_path := traditional_dictionary_path
    else
        active_dictionary_path := dictionary_path;

    provider := TncSqliteDictionary.Create(active_dictionary_path,
        user_dictionary_path);
    if not provider.Open then
    begin
        provider.Free;
        if FDictionaryError = '' then
            FDictionaryError := 'unable to open dictionary database';
        Exit;
    end;
    if (active_dictionary_path <> '') and not provider.base_ready then
    begin
        provider.Free;
        if FDictionaryError = '' then
            FDictionaryError := 'unable to open base dictionary: ' +
                active_dictionary_path;
        Exit;
    end;

    FEngine.set_dictionary_provider(provider);
    FEngine.prewarm_dictionary_caches;
    runtime_directory := ExtractFileDir(ParamStr(0));
    FLongNeuralReranker := TncPinyinTransformerHostReranker.Create(
        runtime_directory, True);
    FEngine.set_long_neural_reranker(FLongNeuralReranker);
    FLocalCompletionHost := TncLocalCompletionHost.Create(
        runtime_directory);
end;

destructor TncEngineService.Destroy;
begin
    FLocalCompletionHost.Free;
    FEngine.Free;
    FLongNeuralReranker := nil;
    FStateStore.Free;
    FContexts.Free;
    inherited Destroy;
end;

procedure TncEngineService.ApplyStateToConfig(const state: TncEngineState;
    var config: TncEngineConfig);
begin
    config.input_mode := state.input_mode;
    config.dictionary_variant := state.dictionary_variant;
    config.pinyin_input_scheme := state.pinyin_scheme;
    config.fuzzy_pinyin_enabled := state.fuzzy_pinyin_enabled;
    config.fuzzy_pinyin_rules := state.fuzzy_pinyin_rules;
    config.full_width_mode := state.full_width_mode;
    config.punctuation_full_width := state.punctuation_full_width;
    config.candidate_page_size := state.candidate_page_size;
    config.candidate_page_key_scheme :=
        state.candidate_page_key_scheme;
    config.one_key_completion_key := state.one_key_completion_key;
    config.debug_mode := state.debug_mode;
    config.shortcuts := state.shortcuts;
end;

function TncEngineService.PersistentStateChanged(
    const old_state: TncEngineState;
    const new_state: TncEngineState): Boolean;
begin
    Result :=
        (old_state.dictionary_variant <> new_state.dictionary_variant) or
        (old_state.pinyin_scheme <> new_state.pinyin_scheme) or
        (old_state.fuzzy_pinyin_enabled <>
        new_state.fuzzy_pinyin_enabled) or
        (old_state.fuzzy_pinyin_rules <> new_state.fuzzy_pinyin_rules) or
        (old_state.full_width_mode <> new_state.full_width_mode) or
        (old_state.punctuation_full_width <>
        new_state.punctuation_full_width) or
        (old_state.candidate_page_size <>
        new_state.candidate_page_size) or
        (old_state.candidate_page_key_scheme <>
        new_state.candidate_page_key_scheme) or
        (old_state.one_key_completion_key <>
        new_state.one_key_completion_key) or
        (old_state.debug_mode <> new_state.debug_mode) or
        (not nc_shortcut_equal(old_state.shortcuts.input_mode_toggle,
        new_state.shortcuts.input_mode_toggle)) or
        (not nc_shortcut_equal(old_state.shortcuts.punctuation_toggle,
        new_state.shortcuts.punctuation_toggle)) or
        (not nc_shortcut_equal(
        old_state.shortcuts.dictionary_variant_toggle,
        new_state.shortcuts.dictionary_variant_toggle)) or
        (not nc_shortcut_equal(old_state.shortcuts.full_width_toggle,
        new_state.shortcuts.full_width_toggle)) or
        (not nc_shortcut_equal(old_state.shortcuts.open_settings,
        new_state.shortcuts.open_settings));
end;

function TncEngineService.SavePersistentState(
    const state: TncEngineState): Boolean;
begin
    Result := True;
    if FStateStore = nil then
        Exit;
    Result := FStateStore.SaveEngineState(state);
    if not Result then
        FDictionaryError := FStateStore.ErrorMessage;
end;

procedure TncEngineService.SyncStateFromEngine;
var
    next_state: TncEngineState;
    engine_config: TncEngineConfig;
begin
    if FEngine = nil then
        Exit;
    engine_config := FEngine.Config;
    next_state := FState;
    next_state.input_mode := engine_config.input_mode;
    next_state.dictionary_variant := engine_config.dictionary_variant;
    next_state.pinyin_scheme := engine_config.pinyin_input_scheme;
    next_state.fuzzy_pinyin_enabled := engine_config.fuzzy_pinyin_enabled;
    next_state.fuzzy_pinyin_rules := engine_config.fuzzy_pinyin_rules;
    next_state.full_width_mode := engine_config.full_width_mode;
    next_state.punctuation_full_width :=
        engine_config.punctuation_full_width;
    next_state.candidate_page_size := engine_config.candidate_page_size;
    next_state.candidate_page_key_scheme :=
        engine_config.candidate_page_key_scheme;
    next_state.one_key_completion_key :=
        engine_config.one_key_completion_key;
    next_state.debug_mode := engine_config.debug_mode;
    next_state.shortcuts := engine_config.shortcuts;
    if PersistentStateChanged(FState, next_state) then
        SavePersistentState(next_state);
    FState := next_state;
    FConfig := engine_config;
end;

function TncEngineService.PrepareContext(const context_id: QWord;
    const generation_id: QWord; out context: TncEngineContext): Cardinal;
begin
    context := FContexts.Find(context_id);
    if context = nil then
        Exit(c_engine_error_unknown_context);
    if not context.AdvanceGeneration(generation_id) then
        Exit(c_engine_error_stale_generation);
    Result := 0;
end;

procedure TncEngineService.SetEngineLeftContext(
    const context: TncEngineContext);
var
    left_context: string;
begin
    if (FEngine = nil) or (context = nil) then
        Exit;
    left_context := Copy(context.SurroundingText, 1,
        context.CursorOffset);
    FEngine.set_external_left_context(left_context,
        IntToHex(context.Id, 16), left_context);
end;

function TncEngineService.KeyEventToVirtualKey(
    const key_event: TncKeyEvent; out key_code: Word;
    out key_state: TncKeyState): Boolean;
var
    value: WideChar;
begin
    key_code := 0;
    key_state.shift_down := km_shift in key_event.modifiers;
    key_state.ctrl_down := km_control in key_event.modifiers;
    key_state.alt_down := km_alt in key_event.modifiers;
    key_state.caps_lock := km_caps_lock in key_event.modifiers;

    if (key_event.special_key >= sk_f1) and
        (key_event.special_key <= sk_f24) then
    begin
        key_code := VK_F1 + Ord(key_event.special_key) - Ord(sk_f1);
        Exit(True);
    end;

    case key_event.special_key of
        sk_backspace: key_code := VK_BACK;
        sk_delete: key_code := VK_DELETE;
        sk_enter: key_code := VK_RETURN;
        sk_escape: key_code := VK_ESCAPE;
        sk_space: key_code := VK_SPACE;
        sk_tab: key_code := VK_TAB;
        sk_left: key_code := VK_LEFT;
        sk_right: key_code := VK_RIGHT;
        sk_up: key_code := VK_UP;
        sk_down: key_code := VK_DOWN;
        sk_home: key_code := VK_HOME;
        sk_end: key_code := VK_END;
        sk_page_up: key_code := VK_PRIOR;
        sk_page_down: key_code := VK_NEXT;
        sk_numpad_multiply: key_code := VK_MULTIPLY;
        sk_numpad_add: key_code := VK_ADD;
        sk_numpad_subtract: key_code := VK_SUBTRACT;
        sk_numpad_decimal: key_code := VK_DECIMAL;
        sk_numpad_divide: key_code := VK_DIVIDE;
        sk_shift: key_code := VK_SHIFT;
        sk_control: key_code := VK_CONTROL;
        sk_alt: key_code := VK_MENU;
        sk_super: key_code := VK_LWIN;
    end;
    if key_code <> 0 then
        Exit(True);

    if key_event.special_key <> sk_none then
        Exit(False);
    if key_event.text = '' then
    begin
        if km_shift in key_event.modifiers then
            key_code := VK_SHIFT
        else if km_control in key_event.modifiers then
            key_code := VK_CONTROL
        else if km_alt in key_event.modifiers then
            key_code := VK_MENU;
        Exit(key_code <> 0);
    end;
    if Length(key_event.text) <> 1 then
        Exit(False);

    value := key_event.text[1];
    if ((value >= 'a') and (value <= 'z')) then
        key_code := Ord(value) - Ord('a') + Ord('A')
    else if ((value >= 'A') and (value <= 'Z')) or
        ((value >= '0') and (value <= '9')) then
        key_code := Ord(value)
    else
        case value of
            ';', ':': key_code := VK_OEM_1;
            '=', '+': key_code := VK_OEM_PLUS;
            ',', '<': key_code := VK_OEM_COMMA;
            '-', '_': key_code := VK_OEM_MINUS;
            '.', '>': key_code := VK_OEM_PERIOD;
            '/', '?': key_code := VK_OEM_2;
            '`', '~': key_code := VK_OEM_3;
            '[', '{': key_code := VK_OEM_4;
            '\', '|': key_code := VK_OEM_5;
            ']', '}': key_code := VK_OEM_6;
            '''', '"': key_code := VK_OEM_7;
        end;
    Result := key_code <> 0;
end;

function TncEngineService.ActivateContext(
    const context: TncEngineContext): Boolean;
var
    key_event: TncKeyEvent;
    key_state: TncKeyState;
    key_code: Word;
    index: Integer;
begin
    Result := (context <> nil) and (FEngine <> nil);
    if not Result then
        Exit;
    if FLoadedContextId = context.Id then
        Exit(True);

    FEngine.Reset;
    SetEngineLeftContext(context);
    key_event := Default(TncKeyEvent);
    for index := 1 to Length(context.Composition) do
    begin
        key_event.text := context.Composition[index];
        if (not KeyEventToVirtualKey(key_event, key_code, key_state)) or
            (not FEngine.should_handle_key(key_code, key_state)) or
            (not FEngine.process_key(key_code, key_state)) then
        begin
            FEngine.Reset;
            context.ClearComposition;
            Break;
        end;
    end;
    FLoadedContextId := context.Id;
    SyncContext(context);
end;

procedure TncEngineService.SyncContext(const context: TncEngineContext);
var
    candidates: TncCandidateList;
    completion: TncOneKeyCompletion;
    query: string;
    index: Integer;
begin
    if (context = nil) or (FEngine = nil) then
        Exit;
    candidates := FEngine.get_candidates;
    query := FEngine.get_last_lookup_key;
    for index := 0 to High(candidates) do
    begin
        // Older candidate construction paths do not initialize metadata that
        // was appended to TncCandidate later. Keep valid metadata intact and
        // normalize only out-of-range values at the service boundary.
        if Ord(candidates[index].source) > Ord(High(TncCandidateSource)) then
            candidates[index].source := cs_rule;
        if Ord(candidates[index].display_kind) >
            Ord(High(TncCandidateDisplayKind)) then
            candidates[index].display_kind := cdk_default;
        candidates[index].deletable := False;
        if candidates[index].source = cs_user then
            candidates[index].deletable :=
                FEngine.is_user_or_literal_entry(query,
                candidates[index].text);
    end;
    context.SetComposition(FEngine.get_composition_text);
    context.SetCandidates(candidates);
    context.SelectCandidate(FEngine.get_selected_index);
    completion := FEngine.get_one_key_completion;
    context.SetCompletion(completion.full_pinyin, completion.text);
end;

procedure TncEngineService.PopulateResult(const context: TncEngineContext;
    var engine_result: TncEngineResult);
begin
    if (context = nil) or (FEngine = nil) then
        Exit;
    SyncContext(context);
    engine_result.preedit_text := context.Composition;
    engine_result.query_text := FEngine.get_last_lookup_key;
    engine_result.candidates := Copy(context.Candidates, 0,
        Length(context.Candidates));
    engine_result.selected_index := context.SelectedIndex;
    engine_result.page_index := FEngine.get_page_index;
    engine_result.page_count := FEngine.get_page_count;
    engine_result.completion_text := context.CompletionText;
end;

function TncEngineService.QueueLongNeuralCompletion(
    const context: TncEngineContext): Boolean;
var
    task: TncLocalCompletionTask;
begin
    Result := False;
    if (context = nil) or (FEngine = nil) or
        (FLocalCompletionHost = nil) or (not context.Active) or
        (context.Composition = '') or (context.CompletionText <> '') then
        Exit;
    task := Default(TncLocalCompletionTask);
    if not FEngine.get_long_neural_completion_request(task.request) then
        Exit;
    task.context_id := context.Id;
    task.generation_id := context.Generation;
    Result := FLocalCompletionHost.Enqueue(task);
end;

function TncEngineService.RemoveCandidate(const context: TncEngineContext;
    const candidate_index: Integer): Boolean;
var
    candidate: TncCandidate;
    preserve_candidate: TncCandidate;
    preserve_index: Integer;
    has_preserve_candidate: Boolean;
    query: string;
begin
    Result := False;
    if (context = nil) or (FEngine = nil) or
        (candidate_index < 0) or
        (candidate_index >= Length(context.Candidates)) then
        Exit;
    candidate := context.Candidates[candidate_index];
    if not candidate.deletable then
        Exit;

    preserve_candidate := Default(TncCandidate);
    preserve_index := context.SelectedIndex;
    if (preserve_index < 0) or
        (preserve_index >= Length(context.Candidates)) then
        preserve_index := 0;
    has_preserve_candidate :=
        (preserve_index >= 0) and
        (preserve_index < Length(context.Candidates)) and
        (preserve_index <> candidate_index) and
        (Trim(context.Candidates[preserve_index].text) <> '') and
        (Trim(context.Candidates[preserve_index].text) <>
        Trim(candidate.text));
    if has_preserve_candidate then
        preserve_candidate := context.Candidates[preserve_index];

    query := FEngine.get_last_lookup_key;
    if query = '' then
        query := context.Composition;
    Result := FEngine.remove_user_candidate(query, candidate.text,
        preserve_candidate, has_preserve_candidate);
    if Result then
        SyncContext(context);
end;

function TncEngineService.CreateContext(const context_id: QWord): Boolean;
begin
    Result := FContexts.Add(context_id);
end;

function TncEngineService.DestroyContext(const context_id: QWord): Boolean;
begin
    if FLoadedContextId = context_id then
    begin
        FEngine.Reset;
        FLoadedContextId := c_invalid_context_id;
    end;
    Result := FContexts.Remove(context_id);
end;

function TncEngineService.ResetContext(const context_id: QWord;
    const generation_id: QWord): Boolean;
var
    context: TncEngineContext;
begin
    Result := PrepareContext(context_id, generation_id, context) = 0;
    if not Result then
        Exit;
    context.Reset;
    if FLoadedContextId = context_id then
    begin
        FEngine.Reset;
        FLoadedContextId := c_invalid_context_id;
    end;
end;

function TncEngineService.SetActive(const context_id: QWord;
    const active: Boolean; const generation_id: QWord): Boolean;
var
    context: TncEngineContext;
begin
    Result := PrepareContext(context_id, generation_id, context) = 0;
    if not Result then
        Exit;
    context.Active := active;
    if active then
        Result := ActivateContext(context)
    else
    begin
        context.ClearModifierShortcut;
        context.ClearComposition;
        if FLoadedContextId = context_id then
        begin
            FEngine.Reset;
            FLoadedContextId := c_invalid_context_id;
        end;
    end;
end;

function TncEngineService.SetSurrounding(const context_id: QWord;
    const text: string; const cursor_offset: Integer;
    const generation_id: QWord): Boolean;
var
    context: TncEngineContext;
begin
    Result := PrepareContext(context_id, generation_id, context) = 0;
    if not Result then
        Exit;
    context.SetSurrounding(text, cursor_offset);
    if FLoadedContextId = context_id then
        SetEngineLeftContext(context);
end;

function TncEngineService.GetState(out state: TncEngineState): Boolean;
begin
    SyncStateFromEngine;
    state := FState;
    Result := True;
end;

function TncEngineService.SetState(const state: TncEngineState): Boolean;
var
    action: TncShortcutAction;
    clear_compositions: Boolean;
    next_config: TncEngineConfig;
    previous_config: TncEngineConfig;
    previous_state: TncEngineState;
    dictionary_changed: Boolean;
begin
    if (state.candidate_page_size < c_min_candidate_page_size) or
        (state.candidate_page_size > c_max_candidate_page_size) then
        Exit(False);
    if nc_candidate_page_key_conflicts_with_one_key_completion(
        state.candidate_page_key_scheme, state.one_key_completion_key) or
        (state.shortcuts.signature <> c_nc_shortcut_config_signature) or
        nc_shortcut_config_has_duplicates(state.shortcuts) then
        Exit(False);
    for action := Low(TncShortcutAction) to High(TncShortcutAction) do
        if not nc_shortcut_is_valid(nc_shortcut_for_action(
            state.shortcuts, action)) then
            Exit(False);
    clear_compositions :=
        (state.input_mode <> FState.input_mode) or
        (state.dictionary_variant <> FState.dictionary_variant) or
        (state.pinyin_scheme <> FState.pinyin_scheme) or
        (state.fuzzy_pinyin_enabled <> FState.fuzzy_pinyin_enabled) or
        (state.fuzzy_pinyin_rules <> FState.fuzzy_pinyin_rules);
    previous_state := FState;
    previous_config := FEngine.Config;
    dictionary_changed := state.dictionary_variant <>
        previous_state.dictionary_variant;
    next_config := FEngine.Config;
    ApplyStateToConfig(state, next_config);
    try
        FEngine.update_config(next_config);
    except
        on exception_value: Exception do
        begin
            FDictionaryError := UnicodeString(exception_value.Message);
            FEngine.update_config(previous_config);
            Exit(False);
        end;
    end;
    if dictionary_changed and not FEngine.dictionary_base_ready then
    begin
        FEngine.update_config(previous_config);
        FDictionaryError := 'requested dictionary variant is unavailable';
        Exit(False);
    end;
    if PersistentStateChanged(previous_state, state) and
        not SavePersistentState(state) then
    begin
        FEngine.update_config(previous_config);
        Exit(False);
    end;
    FConfig := FEngine.Config;
    FState := state;
    if clear_compositions then
    begin
        FContexts.ClearCompositions;
        FLoadedContextId := c_invalid_context_id;
    end;
    Result := True;
end;

function TncEngineService.ClearUserDictionary: Boolean;
begin
    Result := (FEngine <> nil) and FEngine.clear_user_dictionary;
    if not Result then
        Exit;
    FContexts.ClearCompositions;
    FLoadedContextId := c_invalid_context_id;
    FEngine.Reset;
end;

function TncEngineService.ProcessKey(const context_id: QWord;
    const generation_id: QWord;
    const key_event: TncKeyEvent): TncEngineResult;
var
    context: TncEngineContext;
    key_code: Word;
    key_state: TncKeyState;
    shortcut_action: TncShortcutAction;
    shortcut_value: TncShortcut;
    shortcut_matched: Boolean;
    normalized_key_code: Word;
    execute_modifier_shortcut: Boolean;
    modifier_release: Boolean;
    next_state: TncEngineState;
    raw_key_state: TncKeyState;
    raw_commit_text: string;
    engine_commit_text: string;
begin
    nc_initialize_engine_result(Result);
    Result.error_code := PrepareContext(context_id, generation_id, context);
    case Result.error_code of
        c_engine_error_unknown_context:
            Result.error_text := 'Unknown input context';
        c_engine_error_stale_generation:
            Result.error_text := 'Stale input generation';
    end;
    if Result.error_code <> 0 then
        Exit;
    if not KeyEventToVirtualKey(key_event, key_code, key_state) then
    begin
        if not key_event.is_release then
            context.CancelModifierShortcut;
        Exit;
    end;

    normalized_key_code := nc_normalize_shortcut_key_code(key_code);
    modifier_release := False;
    shortcut_matched := False;
    if key_event.is_release then
    begin
        if not context.FinishModifierShortcut(normalized_key_code,
            shortcut_action, execute_modifier_shortcut) then
            Exit;
        if not execute_modifier_shortcut then
            Exit;
        modifier_release := True;
        shortcut_matched := True;
    end
    else
    begin
        if context.ModifierShortcutPending and
            (normalized_key_code <> context.ModifierShortcutKeyCode) then
            context.CancelModifierShortcut;
        if km_super in key_event.modifiers then
            Exit;
        shortcut_matched := nc_find_shortcut_action(FEngine.Config.shortcuts,
            key_code, key_state, shortcut_action);
        if shortcut_matched then
        begin
            shortcut_value := nc_shortcut_for_action(FEngine.Config.shortcuts,
                shortcut_action);
            if nc_shortcut_is_modifier_only(shortcut_value) then
            begin
                if key_event.is_repeat then
                    Exit;
                if not context.ModifierShortcutPending then
                    context.BeginModifierShortcut(shortcut_action,
                        normalized_key_code);
                Exit;
            end;
        end;
    end;

    if shortcut_matched then
    begin
        if key_event.is_repeat then
            Exit;
        if shortcut_action = sa_dictionary_variant_toggle then
        begin
            next_state := FState;
            if next_state.dictionary_variant = dv_traditional then
                next_state.dictionary_variant := dv_simplified
            else
                next_state.dictionary_variant := dv_traditional;
            Result.handled := SetState(next_state);
            if not Result.handled then
            begin
                Result.error_code := c_engine_error_dictionary_unavailable;
                Result.error_text := FDictionaryError;
            end;
            Exit;
        end;
    end;

    if not DictionaryReady then
    begin
        Result.error_code := c_engine_error_dictionary_unavailable;
        Result.error_text := 'Input dictionary is unavailable';
        Exit;
    end;
    if not ActivateContext(context) then
    begin
        Result.error_code := c_engine_error_dictionary_unavailable;
        Result.error_text := 'Input engine is unavailable';
        Exit;
    end;

    if (key_event.special_key = sk_delete) and key_state.ctrl_down and
        (not key_state.alt_down) then
    begin
        if (context.SelectedIndex >= 0) and
            (context.SelectedIndex < Length(context.Candidates)) and
            context.Candidates[context.SelectedIndex].deletable then
        begin
            Result.handled := RemoveCandidate(context, context.SelectedIndex);
            PopulateResult(context, Result);
        end;
        Exit;
    end;

    try
        raw_commit_text := '';
        if modifier_release and (shortcut_action = sa_input_mode_toggle) and
            (FState.input_mode = im_chinese) and
            (context.Composition <> '') then
        begin
            raw_key_state := Default(TncKeyState);
            if FEngine.should_handle_key(VK_RETURN, raw_key_state) and
                FEngine.process_key(VK_RETURN, raw_key_state) then
                FEngine.commit_text(raw_commit_text);
        end;

        if not FEngine.should_handle_key(key_code, key_state) then
        begin
            if raw_commit_text <> '' then
            begin
                Result.handled := True;
                Result.commit_text := raw_commit_text;
                SyncStateFromEngine;
                PopulateResult(context, Result);
            end;
            Exit;
        end;

        Result.handled := FEngine.process_key(key_code, key_state);
        if Result.handled then
        begin
            engine_commit_text := '';
            FEngine.commit_text(engine_commit_text);
            if raw_commit_text <> '' then
                Result.commit_text := raw_commit_text
            else
                Result.commit_text := engine_commit_text;
        end;
        SyncStateFromEngine;
        PopulateResult(context, Result);
        Result.async_pending := QueueLongNeuralCompletion(context);
    except
        on exception_value: Exception do
        begin
            Result.handled := False;
            Result.error_code := c_engine_error_dictionary_query;
            Result.error_text := UnicodeString(exception_value.Message);
            FDictionaryError := UnicodeString(exception_value.Message);
        end;
    end;
end;

function TncEngineService.PollResult(const context_id: QWord;
    const generation_id: QWord): TncEngineResult;
var
    context: TncEngineContext;
    finished: TncLocalCompletionFinished;
begin
    nc_initialize_engine_result(Result);
    context := FContexts.Find(context_id);
    if (context = nil) or (FLocalCompletionHost = nil) or
        (context.Generation <> generation_id) then
        Exit;
    if not FLocalCompletionHost.TryPopFinishedFor(context_id, finished) then
        Exit;
    if (finished.task.generation_id <> generation_id) or
        (not context.Active) or (not ActivateContext(context)) then
        Exit;

    if finished.accepted then
        FEngine.apply_long_neural_completion(finished.task.request,
            finished.completion_result);
    Result.handled := True;
    PopulateResult(context, Result);
end;

function TncEngineService.ContextCount: Integer;
begin
    Result := FContexts.Count;
end;

procedure TncEngineService.ClearContexts;
begin
    FContexts.Clear;
    FEngine.Reset;
    FLoadedContextId := c_invalid_context_id;
end;

function TncEngineService.DictionaryReady: Boolean;
begin
    Result := (FEngine <> nil) and FEngine.dictionary_base_ready;
end;

function TncEngineService.UserDictionaryReady: Boolean;
begin
    Result := (FEngine <> nil) and FEngine.dictionary_user_ready;
end;

function TncEngineService.RemoveUserCandidate(const context_id: QWord;
    const generation_id: QWord; const candidate_index: Integer): Boolean;
var
    context: TncEngineContext;
begin
    Result := PrepareContext(context_id, generation_id, context) = 0;
    if not Result then
        Exit;
    Result := ActivateContext(context) and
        RemoveCandidate(context, candidate_index);
end;

end.
