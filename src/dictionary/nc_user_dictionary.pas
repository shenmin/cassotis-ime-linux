unit nc_user_dictionary;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_types,
    nc_sqlite;

type
    TncRawUserEntry = record
        pinyin: string;
        text: string;
        weight: Integer;
        last_used: Int64;
    end;
    TncRawUserEntries = array of TncRawUserEntry;

    TncUserPreference = record
        text: string;
        commit_count: Integer;
        last_used: Int64;
        latest: Boolean;
    end;
    TncUserPreferences = array of TncUserPreference;

    TncUserDictionary = class
    private
        FConnection: TncSqliteConnection;
        FOpened: Boolean;
        FErrorMessage: string;
        function CreateSchema: Boolean;
        function ExecutePairStatement(const sql: string;
            const pinyin: string; const text: string): Boolean;
    public
        constructor Create(const db_path: string;
            const sqlite_library_override: string = '');
        destructor Destroy; override;
        function Open: Boolean;
        procedure Close;
        function QueryUserWords(const pinyin: string;
            const maximum_count: Integer;
            out entries: TncRawUserEntries): Boolean;
        function QueryPreferences(const pinyin: string;
            out preferences: TncUserPreferences): Boolean;
        function RecordCommit(const pinyin: string; const text: string;
            const store_user_word: Boolean): Boolean;
        function RemoveUserWord(const pinyin: string;
            const text: string): Boolean;
        function LoadEngineState(out state: TncEngineState): Boolean;
        function SaveEngineState(const state: TncEngineState): Boolean;
        property Opened: Boolean read FOpened;
        property ErrorMessage: string read FErrorMessage;
    end;

implementation

uses
    SysUtils,
    nc_shortcut;

function ShortcutModifierMask(const shortcut: TncShortcut): Integer;
begin
    Result := 0;
    if shortcut.shift_down then
        Result := Result or 1;
    if shortcut.ctrl_down then
        Result := Result or 2;
    if shortcut.alt_down then
        Result := Result or 4;
end;

procedure SetShortcutModifierMask(var shortcut: TncShortcut;
    const mask: Integer);
begin
    if (mask < 0) or ((mask and not 7) <> 0) then
        Exit;
    shortcut.shift_down := (mask and 1) <> 0;
    shortcut.ctrl_down := (mask and 2) <> 0;
    shortcut.alt_down := (mask and 4) <> 0;
end;

procedure SetShortcutKeyCode(var shortcut: TncShortcut;
    const key_code: Integer);
begin
    if (key_code < Low(Word)) or (key_code > High(Word)) then
        Exit;
    shortcut.key_code := Word(key_code);
end;

constructor TncUserDictionary.Create(const db_path: string;
    const sqlite_library_override: string);
begin
    inherited Create;
    FConnection := TncSqliteConnection.Create(db_path,
        sqlite_library_override);
    FOpened := False;
    FErrorMessage := '';
end;

destructor TncUserDictionary.Destroy;
begin
    Close;
    FConnection.Free;
    inherited Destroy;
end;

function TncUserDictionary.CreateSchema: Boolean;
begin
    Result := FConnection.Exec('CREATE TABLE IF NOT EXISTS meta (' +
        'key TEXT PRIMARY KEY, value TEXT NOT NULL);') and
        FConnection.Exec('INSERT OR IGNORE INTO meta(key, value) ' +
        'VALUES (''schema_version'', ''18'');') and
        FConnection.Exec('CREATE TABLE IF NOT EXISTS dict_user (' +
        'id INTEGER PRIMARY KEY AUTOINCREMENT, pinyin TEXT NOT NULL, ' +
        'text TEXT NOT NULL, weight INTEGER DEFAULT 0, ' +
        'last_used INTEGER DEFAULT 0, UNIQUE(pinyin, text));') and
        FConnection.Exec('CREATE INDEX IF NOT EXISTS idx_dict_user_pinyin ' +
        'ON dict_user(pinyin);') and
        FConnection.Exec('CREATE TABLE IF NOT EXISTS dict_user_stats (' +
        'pinyin TEXT NOT NULL, text TEXT NOT NULL, ' +
        'commit_count INTEGER DEFAULT 0, last_used INTEGER DEFAULT 0, ' +
        'PRIMARY KEY(pinyin, text));') and
        FConnection.Exec('CREATE INDEX IF NOT EXISTS ' +
        'idx_dict_user_stats_pinyin ON dict_user_stats(pinyin);') and
        FConnection.Exec('CREATE TABLE IF NOT EXISTS dict_user_query_latest (' +
        'query_pinyin TEXT NOT NULL PRIMARY KEY, text TEXT NOT NULL, ' +
        'last_used INTEGER DEFAULT 0);');
    if not Result then
        FErrorMessage := FConnection.Errmsg;
end;

function TncUserDictionary.Open: Boolean;
var
    parent_directory: string;
begin
    if FOpened then
        Exit(True);
    FErrorMessage := '';
    parent_directory := ExtractFileDir(FConnection.DbPath);
    if (parent_directory <> '') and (not DirectoryExists(parent_directory)) and
        (not ForceDirectories(parent_directory)) then
    begin
        FErrorMessage := 'unable to create user dictionary directory: ' +
            parent_directory;
        Exit(False);
    end;
    if not FConnection.Open(SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    if not CreateSchema then
    begin
        FConnection.Close;
        Exit(False);
    end;
    if not FConnection.Exec('PRAGMA journal_mode=WAL;') or
        not FConnection.Exec('PRAGMA synchronous=NORMAL;') or
        not FConnection.Exec('PRAGMA busy_timeout=1500;') then
    begin
        FErrorMessage := FConnection.Errmsg;
        FConnection.Close;
        Exit(False);
    end;
    FOpened := True;
    Result := True;
end;

procedure TncUserDictionary.Close;
begin
    FConnection.Close;
    FOpened := False;
end;

function TncUserDictionary.ExecutePairStatement(const sql: string;
    const pinyin: string; const text: string): Boolean;
var
    statement: Psqlite3_stmt;
    step_result: Integer;
begin
    statement := nil;
    if not FConnection.Prepare(sql, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if (not FConnection.BindText(statement, 1, pinyin)) or
            (not FConnection.BindText(statement, 2, text)) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;
        step_result := FConnection.Step(statement);
        Result := step_result = SQLITE_DONE;
        if not Result then
            FErrorMessage := FConnection.Errmsg;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncUserDictionary.QueryUserWords(const pinyin: string;
    const maximum_count: Integer; out entries: TncRawUserEntries): Boolean;
const
    c_query = 'SELECT pinyin, text, weight, last_used FROM dict_user ' +
        'WHERE pinyin = ?1 ORDER BY weight DESC, last_used DESC, text ASC ' +
        'LIMIT ?2;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    entry_count: Integer;
begin
    entries := nil;
    if not FOpened then
    begin
        FErrorMessage := 'user dictionary is not open';
        Exit(False);
    end;
    if maximum_count <= 0 then
    begin
        FErrorMessage := 'maximum candidate count must be positive';
        Exit(False);
    end;
    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if (not FConnection.BindText(statement, 1,
            LowerCase(Trim(pinyin)))) or
            (not FConnection.BindInt(statement, 2, maximum_count)) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;
        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            entry_count := Length(entries);
            SetLength(entries, entry_count + 1);
            entries[entry_count].pinyin := FConnection.ColumnText(statement, 0);
            entries[entry_count].text := FConnection.ColumnText(statement, 1);
            entries[entry_count].weight := FConnection.ColumnInt(statement, 2);
            entries[entry_count].last_used :=
                FConnection.ColumnInt64(statement, 3);
        end;
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncUserDictionary.QueryPreferences(const pinyin: string;
    out preferences: TncUserPreferences): Boolean;
const
    c_query = 'SELECT s.text, s.commit_count, s.last_used, ' +
        'CASE WHEN l.text = s.text THEN 1 ELSE 0 END ' +
        'FROM dict_user_stats s LEFT JOIN dict_user_query_latest l ' +
        'ON l.query_pinyin = s.pinyin WHERE s.pinyin = ?1 ' +
        'ORDER BY 4 DESC, s.commit_count DESC, s.last_used DESC, s.text ASC;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    preference_count: Integer;
begin
    preferences := nil;
    if not FOpened then
    begin
        FErrorMessage := 'user dictionary is not open';
        Exit(False);
    end;
    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if not FConnection.BindText(statement, 1,
            LowerCase(Trim(pinyin))) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;
        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            preference_count := Length(preferences);
            SetLength(preferences, preference_count + 1);
            preferences[preference_count].text :=
                FConnection.ColumnText(statement, 0);
            preferences[preference_count].commit_count :=
                FConnection.ColumnInt(statement, 1);
            preferences[preference_count].last_used :=
                FConnection.ColumnInt64(statement, 2);
            preferences[preference_count].latest :=
                FConnection.ColumnInt(statement, 3) <> 0;
        end;
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncUserDictionary.RecordCommit(const pinyin: string;
    const text: string; const store_user_word: Boolean): Boolean;
const
    c_upsert_stats = 'INSERT INTO dict_user_stats ' +
        '(pinyin, text, commit_count, last_used) ' +
        'VALUES (?1, ?2, 1, strftime(''%s'',''now'')) ' +
        'ON CONFLICT(pinyin, text) DO UPDATE SET ' +
        'commit_count = commit_count + 1, ' +
        'last_used = excluded.last_used;';
    c_upsert_latest = 'INSERT INTO dict_user_query_latest ' +
        '(query_pinyin, text, last_used) ' +
        'VALUES (?1, ?2, strftime(''%s'',''now'')) ' +
        'ON CONFLICT(query_pinyin) DO UPDATE SET text = excluded.text, ' +
        'last_used = excluded.last_used;';
    c_upsert_word = 'INSERT INTO dict_user ' +
        '(pinyin, text, weight, last_used) ' +
        'VALUES (?1, ?2, 1, strftime(''%s'',''now'')) ' +
        'ON CONFLICT(pinyin, text) DO UPDATE SET weight = weight + 1, ' +
        'last_used = excluded.last_used;';
    c_delete_word = 'DELETE FROM dict_user WHERE pinyin = ?1 AND text = ?2;';
var
    normalized_pinyin: string;
begin
    normalized_pinyin := LowerCase(Trim(pinyin));
    if (not FOpened) or (normalized_pinyin = '') or (Trim(text) = '') then
    begin
        FErrorMessage := 'invalid user dictionary commit';
        Exit(False);
    end;
    if not FConnection.Exec('BEGIN IMMEDIATE;') then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    Result := ExecutePairStatement(c_upsert_stats, normalized_pinyin, text) and
        ExecutePairStatement(c_upsert_latest, normalized_pinyin, text);
    if Result and store_user_word then
        Result := ExecutePairStatement(c_upsert_word, normalized_pinyin, text)
    else if Result then
        Result := ExecutePairStatement(c_delete_word, normalized_pinyin, text);
    if Result then
        Result := FConnection.Exec('COMMIT;');
    if not Result then
    begin
        FConnection.Exec('ROLLBACK;');
        if FErrorMessage = '' then
            FErrorMessage := FConnection.Errmsg;
    end
    else
        FErrorMessage := '';
end;

function TncUserDictionary.RemoveUserWord(const pinyin: string;
    const text: string): Boolean;
const
    c_delete_word = 'DELETE FROM dict_user WHERE pinyin = ?1 AND text = ?2;';
    c_delete_stats = 'DELETE FROM dict_user_stats WHERE pinyin = ?1 AND text = ?2;';
    c_delete_latest = 'DELETE FROM dict_user_query_latest ' +
        'WHERE query_pinyin = ?1 AND text = ?2;';
var
    normalized_pinyin: string;
begin
    normalized_pinyin := LowerCase(Trim(pinyin));
    if not FOpened then
    begin
        FErrorMessage := 'user dictionary is not open';
        Exit(False);
    end;
    if not FConnection.Exec('BEGIN IMMEDIATE;') then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    Result := ExecutePairStatement(c_delete_word, normalized_pinyin, text) and
        ExecutePairStatement(c_delete_stats, normalized_pinyin, text) and
        ExecutePairStatement(c_delete_latest, normalized_pinyin, text);
    if Result then
        Result := FConnection.Exec('COMMIT;');
    if not Result then
    begin
        FConnection.Exec('ROLLBACK;');
        if FErrorMessage = '' then
            FErrorMessage := FConnection.Errmsg;
    end
    else
        FErrorMessage := '';
end;

function TncUserDictionary.LoadEngineState(out state: TncEngineState): Boolean;
const
    c_query = 'SELECT key, value FROM meta WHERE key IN (' +
        '''setting.pinyin_scheme'', ''setting.dictionary_variant'', ' +
        '''setting.full_width_mode'', ' +
        '''setting.punctuation_full_width'', ' +
        '''setting.fuzzy_pinyin_enabled'', ' +
        '''setting.fuzzy_pinyin_rules'', ' +
        '''setting.candidate_page_size'', ' +
        '''setting.candidate_page_key_scheme'', ' +
        '''setting.one_key_completion_key'', ' +
        '''setting.debug_mode'', ' +
        '''setting.shortcut.input_mode.key'', ' +
        '''setting.shortcut.input_mode.modifiers'', ' +
        '''setting.shortcut.punctuation.key'', ' +
        '''setting.shortcut.punctuation.modifiers'', ' +
        '''setting.shortcut.dictionary.key'', ' +
        '''setting.shortcut.dictionary.modifiers'', ' +
        '''setting.shortcut.full_width.key'', ' +
        '''setting.shortcut.full_width.modifiers'', ' +
        '''setting.shortcut.settings.key'', ' +
        '''setting.shortcut.settings.modifiers'');';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    key_name: string;
    setting_value: Integer;
begin
    nc_initialize_engine_state(state);
    if not FOpened then
    begin
        FErrorMessage := 'user dictionary is not open';
        Exit(False);
    end;
    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            key_name := FConnection.ColumnText(statement, 0);
            if not TryStrToInt(UTF8Encode(
                FConnection.ColumnText(statement, 1)), setting_value) then
                Continue;
            if (key_name = 'setting.pinyin_scheme') and
                (setting_value >= Ord(Low(TncPinyinInputScheme))) and
                (setting_value <= Ord(High(TncPinyinInputScheme))) then
                state.pinyin_scheme := TncPinyinInputScheme(setting_value)
            else if (key_name = 'setting.dictionary_variant') and
                (setting_value >= Ord(Low(TncDictionaryVariant))) and
                (setting_value <= Ord(High(TncDictionaryVariant))) then
                state.dictionary_variant := TncDictionaryVariant(setting_value)
            else if key_name = 'setting.fuzzy_pinyin_enabled' then
                state.fuzzy_pinyin_enabled := setting_value <> 0
            else if (key_name = 'setting.fuzzy_pinyin_rules') and
                (setting_value >= 0) and
                nc_fuzzy_pinyin_rules_mask_is_valid(
                Cardinal(setting_value)) then
                state.fuzzy_pinyin_rules :=
                    nc_fuzzy_pinyin_rules_from_mask(Cardinal(setting_value))
            else if key_name = 'setting.full_width_mode' then
                state.full_width_mode := setting_value <> 0
            else if key_name = 'setting.punctuation_full_width' then
                state.punctuation_full_width := setting_value <> 0
            else if (key_name = 'setting.candidate_page_size') and
                (setting_value >= c_min_candidate_page_size) and
                (setting_value <= c_max_candidate_page_size) then
                state.candidate_page_size := setting_value
            else if (key_name = 'setting.candidate_page_key_scheme') and
                (setting_value >= Ord(Low(TncCandidatePageKeyScheme))) and
                (setting_value <= Ord(High(TncCandidatePageKeyScheme))) then
                state.candidate_page_key_scheme :=
                    TncCandidatePageKeyScheme(setting_value)
            else if (key_name = 'setting.one_key_completion_key') and
                (setting_value >= Ord(Low(TncOneKeyCompletionKey))) and
                (setting_value <= Ord(High(TncOneKeyCompletionKey))) then
                state.one_key_completion_key :=
                    TncOneKeyCompletionKey(setting_value)
            else if key_name = 'setting.debug_mode' then
                state.debug_mode := setting_value <> 0
            else if key_name = 'setting.shortcut.input_mode.key' then
                SetShortcutKeyCode(state.shortcuts.input_mode_toggle,
                    setting_value)
            else if key_name = 'setting.shortcut.input_mode.modifiers' then
                SetShortcutModifierMask(state.shortcuts.input_mode_toggle,
                    setting_value)
            else if key_name = 'setting.shortcut.punctuation.key' then
                SetShortcutKeyCode(state.shortcuts.punctuation_toggle,
                    setting_value)
            else if key_name = 'setting.shortcut.punctuation.modifiers' then
                SetShortcutModifierMask(state.shortcuts.punctuation_toggle,
                    setting_value)
            else if key_name = 'setting.shortcut.dictionary.key' then
                SetShortcutKeyCode(
                    state.shortcuts.dictionary_variant_toggle, setting_value)
            else if key_name = 'setting.shortcut.dictionary.modifiers' then
                SetShortcutModifierMask(
                    state.shortcuts.dictionary_variant_toggle, setting_value)
            else if key_name = 'setting.shortcut.full_width.key' then
                SetShortcutKeyCode(state.shortcuts.full_width_toggle,
                    setting_value)
            else if key_name = 'setting.shortcut.full_width.modifiers' then
                SetShortcutModifierMask(state.shortcuts.full_width_toggle,
                    setting_value)
            else if key_name = 'setting.shortcut.settings.key' then
                SetShortcutKeyCode(state.shortcuts.open_settings,
                    setting_value)
            else if key_name = 'setting.shortcut.settings.modifiers' then
                SetShortcutModifierMask(state.shortcuts.open_settings,
                    setting_value);
        end;
        state.candidate_page_key_scheme :=
            nc_resolve_candidate_page_key_scheme(
            state.candidate_page_key_scheme, state.one_key_completion_key);
        nc_normalize_shortcut_config(state.shortcuts);
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncUserDictionary.SaveEngineState(
    const state: TncEngineState): Boolean;
const
    c_upsert_setting = 'INSERT INTO meta(key, value) VALUES (?1, ?2) ' +
        'ON CONFLICT(key) DO UPDATE SET value = excluded.value;';
begin
    if not FOpened then
    begin
        FErrorMessage := 'user dictionary is not open';
        Exit(False);
    end;
    if not FConnection.Exec('BEGIN IMMEDIATE;') then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    Result := ExecutePairStatement(c_upsert_setting,
        'setting.pinyin_scheme', UTF8Decode(IntToStr(
        Ord(state.pinyin_scheme)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.dictionary_variant', UTF8Decode(IntToStr(
        Ord(state.dictionary_variant)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.fuzzy_pinyin_enabled', UTF8Decode(IntToStr(
        Ord(state.fuzzy_pinyin_enabled)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.fuzzy_pinyin_rules', UTF8Decode(IntToStr(
        nc_fuzzy_pinyin_rules_to_mask(state.fuzzy_pinyin_rules)))) and
        ExecutePairStatement(c_upsert_setting, 'setting.full_width_mode',
        UTF8Decode(IntToStr(Ord(state.full_width_mode)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.punctuation_full_width',
        UTF8Decode(IntToStr(Ord(state.punctuation_full_width)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.candidate_page_size', UTF8Decode(IntToStr(
        state.candidate_page_size))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.candidate_page_key_scheme', UTF8Decode(IntToStr(
        Ord(state.candidate_page_key_scheme)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.one_key_completion_key', UTF8Decode(IntToStr(
        Ord(state.one_key_completion_key)))) and
        ExecutePairStatement(c_upsert_setting, 'setting.debug_mode',
        UTF8Decode(IntToStr(Ord(state.debug_mode)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.input_mode.key', UTF8Decode(IntToStr(
        state.shortcuts.input_mode_toggle.key_code))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.input_mode.modifiers', UTF8Decode(IntToStr(
        ShortcutModifierMask(state.shortcuts.input_mode_toggle)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.punctuation.key', UTF8Decode(IntToStr(
        state.shortcuts.punctuation_toggle.key_code))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.punctuation.modifiers', UTF8Decode(IntToStr(
        ShortcutModifierMask(state.shortcuts.punctuation_toggle)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.dictionary.key', UTF8Decode(IntToStr(
        state.shortcuts.dictionary_variant_toggle.key_code))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.dictionary.modifiers', UTF8Decode(IntToStr(
        ShortcutModifierMask(
        state.shortcuts.dictionary_variant_toggle)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.full_width.key', UTF8Decode(IntToStr(
        state.shortcuts.full_width_toggle.key_code))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.full_width.modifiers', UTF8Decode(IntToStr(
        ShortcutModifierMask(state.shortcuts.full_width_toggle)))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.settings.key', UTF8Decode(IntToStr(
        state.shortcuts.open_settings.key_code))) and
        ExecutePairStatement(c_upsert_setting,
        'setting.shortcut.settings.modifiers', UTF8Decode(IntToStr(
        ShortcutModifierMask(state.shortcuts.open_settings))));
    if Result then
        Result := FConnection.Exec('COMMIT;');
    if not Result then
    begin
        FConnection.Exec('ROLLBACK;');
        if FErrorMessage = '' then
            FErrorMessage := FConnection.Errmsg;
    end
    else
        FErrorMessage := '';
end;

end.
