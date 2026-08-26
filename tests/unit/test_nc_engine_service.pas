unit test_nc_engine_service;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry,
    nc_types;

type
    TncEngineServiceTests = class(TTestCase)
    private
        FDatabasePath: string;
        FTraditionalDatabasePath: string;
        FUserDatabasePath: string;
        procedure CreateFixture(const database_path: string;
            const traditional: Boolean = False);
        procedure SeedUserWord(const pinyin, text: string);
        function LetterEvent(const value: string): TncKeyEvent;
        function SpecialEvent(const value: TncSpecialKey): TncKeyEvent;
    protected
        procedure SetUp; override;
        procedure TearDown; override;
    published
        procedure TypesExactCandidateAndCommitsSelection;
        procedure ShowsIncrementalPrefixCandidates;
        procedure RecallsAliasesJianpinAndDirectPaths;
        procedure PinsStableSingleSyllableCandidatesAboveUserHistory;
        procedure RecallsAndFiltersMixedJianpinCandidates;
        procedure BuildsSegmentedSentencePathWithoutLosingSyllables;
        procedure ReranksLongSegmentedPathsWithoutCrossingDirectTier;
        procedure PersistsExplicitUserWordsAcrossContextsAndRestart;
        procedure DeletesOnlySelectedUserCandidateWithControlDelete;
        procedure ClearsUserDictionaryWithoutResettingSettings;
        procedure ProvidesAndAcceptsExactOneKeyCompletion;
        procedure AppliesControlledFuzzyExactRecall;
        procedure SupportsAllShuangpinSchemes;
        procedure LearnsShuangpinSelectionWithCanonicalQuery;
        procedure TogglesInputModeAndConvertsPunctuation;
        procedure DefersAndCancelsModifierOnlyShortcuts;
        procedure SupportsFunctionKeyModeShortcuts;
        procedure SupportsDefaultModeShortcuts;
        procedure SupportsNumpadModeShortcuts;
        procedure SwitchesAndPersistsDictionaryVariant;
        procedure RejectsUnavailableDictionaryVariantWithoutLosingState;
        procedure AppliesGlobalWidthAndPunctuationState;
        procedure PersistsSchemeAndWidthPreferences;
        procedure SupportsNumberSelectionBackspaceAndRawEnter;
        procedure PassesThroughUnsupportedKeysAndRejectsStaleRequests;
    end;

implementation

uses
    SysUtils,
    nc_sqlite,
    nc_dictionary_reader,
    nc_platform_compat,
    nc_shortcut,
    nc_engine_service;

procedure TncEngineServiceTests.SetUp;
begin
    inherited SetUp;
    FDatabasePath := IncludeTrailingPathDelimiter(
        UTF8Decode(GetTempDir(False))) + 'cassotis-engine-' +
        UnicodeString(IntToStr(GetTickCount64)) + '-' +
        UnicodeString(IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2)) + '.db';
    FUserDatabasePath := FDatabasePath + '.user.db';
    FTraditionalDatabasePath := FDatabasePath + '.tc.db';
    if FileExists(FDatabasePath) then
        DeleteFile(FDatabasePath);
    if FileExists(FTraditionalDatabasePath) then
        DeleteFile(FTraditionalDatabasePath);
    if FileExists(FUserDatabasePath) then
        DeleteFile(FUserDatabasePath);
    if FileExists(FUserDatabasePath + '-wal') then
        DeleteFile(FUserDatabasePath + '-wal');
    if FileExists(FUserDatabasePath + '-shm') then
        DeleteFile(FUserDatabasePath + '-shm');
    CreateFixture(FDatabasePath);
    CreateFixture(FTraditionalDatabasePath, True);
end;

procedure TncEngineServiceTests.ClearsUserDictionaryWithoutResettingSettings;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    input_index: Integer;
    candidate_index: Integer;
    learned_text: string;
    found_user_candidate: Boolean;
begin
    learned_text := UnicodeString(WideChar($5D4C)) + WideChar($5957);
    SeedUserWord('qiantao', learned_text);
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.GetState(state));
        state.candidate_page_size := 5;
        state.debug_mode := True;
        AssertTrue(service.SetState(state));
        AssertTrue(service.ClearUserDictionary);

        AssertTrue(service.GetState(state));
        AssertEquals(5, state.candidate_page_size);
        AssertTrue(state.debug_mode);

        AssertTrue(service.CreateContext(18));
        for input_index := 1 to Length('qiantao') do
            engine_result := service.ProcessKey(18, input_index,
                LetterEvent('qiantao'[input_index]));
        found_user_candidate := False;
        for candidate_index := 0 to High(engine_result.candidates) do
            if (engine_result.candidates[candidate_index].text = learned_text) and
                (engine_result.candidates[candidate_index].source = cs_user) then
                found_user_candidate := True;
        AssertFalse('cleared user word must not remain in candidate results',
            found_user_candidate);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.SeedUserWord(const pinyin, text: string);
var
    initializer: TncEngineService;
    connection: TncSqliteConnection;
    statement: Psqlite3_stmt;
begin
    initializer := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(initializer.UserDictionaryReady);
    finally
        initializer.Free;
    end;

    connection := TncSqliteConnection.Create(FUserDatabasePath);
    statement := nil;
    try
        AssertTrue(connection.Open);
        AssertTrue(connection.Prepare(
            'INSERT OR REPLACE INTO dict_user' +
            '(pinyin, text, weight, last_used) ' +
            'VALUES(?1, ?2, 8, strftime(''%s'',''now''));', statement));
        AssertTrue(connection.BindText(statement, 1, pinyin));
        AssertTrue(connection.BindText(statement, 2, text));
        AssertEquals(SQLITE_DONE, connection.Step(statement));
    finally
        if statement <> nil then
            connection.Finalize(statement);
        connection.Free;
    end;
end;

procedure TncEngineServiceTests.PersistsExplicitUserWordsAcrossContextsAndRestart;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    input_text: string;
    generation: QWord;
    learned_text: string;

    procedure TypeInput(const context_id: QWord; const value: string);
    var
        input_index: Integer;
    begin
        input_text := value;
        for input_index := 1 to Length(input_text) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(context_id, generation,
                LetterEvent(input_text[input_index]));
        end;
    end;

begin
    learned_text := UnicodeString(WideChar($5D4C)) + WideChar($5957);
    SeedUserWord('qiantao', learned_text);
    generation := 0;
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.UserDictionaryReady);
        AssertTrue(service.CreateContext(7));
        TypeInput(7, 'qiantao');
        AssertEquals(learned_text, engine_result.candidates[0].text);
        AssertEquals(Ord(cs_user), Ord(engine_result.candidates[0].source));
        AssertTrue(engine_result.candidates[0].deletable);

        AssertTrue(service.CreateContext(8));
        TypeInput(8, 'qiantao');
        AssertEquals(learned_text, engine_result.candidates[0].text);
        AssertEquals(Ord(cs_user), Ord(engine_result.candidates[0].source));
        AssertTrue(engine_result.candidates[0].deletable);
    finally
        service.Free;
    end;

    generation := 0;
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(9));
        TypeInput(9, 'qiantao');
        AssertEquals(learned_text, engine_result.candidates[0].text);
        AssertEquals(Ord(cs_user), Ord(engine_result.candidates[0].source));
        AssertTrue(engine_result.candidates[0].deletable);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.DeletesOnlySelectedUserCandidateWithControlDelete;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    delete_event: TncKeyEvent;
    generation: QWord;
    learned_text: string;

    procedure TypeInput(const value: string);
    var
        input_index: Integer;
    begin
        for input_index := 1 to Length(value) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(16, generation,
                LetterEvent(value[input_index]));
        end;
    end;

    function FindCandidate(const value: string): Integer;
    var
        candidate_index: Integer;
    begin
        for candidate_index := 0 to High(engine_result.candidates) do
            if engine_result.candidates[candidate_index].text = value then
                Exit(candidate_index);
        Result := -1;
    end;

begin
    learned_text := UnicodeString(WideChar($5D4C)) + WideChar($5957);
    SeedUserWord('qiantao', learned_text);
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        generation := 0;
        AssertTrue(service.CreateContext(16));
        TypeInput('qiantao');
        AssertEquals(learned_text, engine_result.candidates[0].text);
        AssertEquals(Ord(cs_user), Ord(engine_result.candidates[0].source));
        AssertTrue(engine_result.candidates[0].deletable);
        delete_event := SpecialEvent(sk_delete);
        Include(delete_event.modifiers, km_control);
        Inc(generation);
        engine_result := service.ProcessKey(16, generation, delete_event);
        AssertTrue('Ctrl+Delete should remove the selected user candidate',
            engine_result.handled);
        AssertTrue('base candidates should remain after user-word removal',
            Length(engine_result.candidates) > 0);
        AssertEquals('removed user candidate should disappear immediately',
            -1, FindCandidate(learned_text));
        AssertFalse('remaining base candidate must not be deletable',
            engine_result.candidates[0].deletable);

        Inc(generation);
        engine_result := service.ProcessKey(16, generation, delete_event);
        AssertFalse('Ctrl+Delete on a base candidate should pass through',
            engine_result.handled);
        AssertEquals('passing through Ctrl+Delete should not report an error',
            0, Int64(engine_result.error_code));
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.TearDown;
begin
    if FileExists(FDatabasePath) then
        DeleteFile(FDatabasePath);
    if FileExists(FTraditionalDatabasePath) then
        DeleteFile(FTraditionalDatabasePath);
    if FileExists(FUserDatabasePath) then
        DeleteFile(FUserDatabasePath);
    if FileExists(FUserDatabasePath + '-wal') then
        DeleteFile(FUserDatabasePath + '-wal');
    if FileExists(FUserDatabasePath + '-shm') then
        DeleteFile(FUserDatabasePath + '-shm');
    inherited TearDown;
end;

procedure TncEngineServiceTests.CreateFixture(const database_path: string;
    const traditional: Boolean);
var
    connection: TncSqliteConnection;
begin
    connection := TncSqliteConnection.Create(database_path);
    try
        AssertTrue(connection.Open);
        AssertTrue(connection.Exec('CREATE TABLE meta (' +
            'key TEXT PRIMARY KEY, value TEXT NOT NULL);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base (' +
            'id INTEGER PRIMARY KEY AUTOINCREMENT, pinyin TEXT NOT NULL, ' +
            'text TEXT NOT NULL, weight INTEGER DEFAULT 0, ' +
            'comment TEXT DEFAULT '''');'));
        AssertTrue(connection.Exec('CREATE INDEX idx_dict_base_pinyin_weight ' +
            'ON dict_base(pinyin, weight);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_pinyin_alias (' +
            'id INTEGER PRIMARY KEY AUTOINCREMENT, compact_pinyin TEXT NOT NULL, ' +
            'word_id INTEGER NOT NULL);'));
        AssertTrue(connection.Exec('CREATE INDEX idx_alias_compact ON ' +
            'dict_base_pinyin_alias(compact_pinyin);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_jianpin (' +
            'id INTEGER PRIMARY KEY AUTOINCREMENT, word_id INTEGER NOT NULL, ' +
            'jianpin TEXT NOT NULL, weight INTEGER DEFAULT 0);'));
        AssertTrue(connection.Exec('CREATE INDEX idx_jianpin_key_weight ON ' +
            'dict_jianpin(jianpin, weight DESC, word_id);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_query_path (' +
            'query_pinyin TEXT NOT NULL, path_text TEXT NOT NULL, ' +
            'weight INTEGER DEFAULT 0);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_lm_transition (' +
            'query_pinyin TEXT NOT NULL, path_text TEXT NOT NULL, ' +
            'weight INTEGER DEFAULT 0);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_completion_lookup (' +
            'typed_prefix TEXT NOT NULL, full_pinyin TEXT NOT NULL, ' +
            'text TEXT NOT NULL, weight INTEGER NOT NULL DEFAULT 0, ' +
            'popularity_prior INTEGER NOT NULL DEFAULT 0, ' +
            'corpus_score INTEGER NOT NULL DEFAULT 0, ' +
            'document_score INTEGER NOT NULL DEFAULT 0, ' +
            'source_count INTEGER NOT NULL DEFAULT 0, ' +
            'path_score INTEGER NOT NULL DEFAULT 0, ' +
            'vertical_penalty INTEGER NOT NULL DEFAULT 0, ' +
            'layer_kind INTEGER NOT NULL DEFAULT 0, ' +
            'prefix_anchored INTEGER NOT NULL DEFAULT 0, ' +
            'rank_order INTEGER NOT NULL DEFAULT 0, ' +
            'PRIMARY KEY(typed_prefix, full_pinyin, text)' +
            ') WITHOUT ROWID;'));
        AssertTrue(connection.Exec('CREATE INDEX idx_completion_prefix ON ' +
            'dict_base_completion_lookup(typed_prefix, rank_order);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_char_lm (' +
            'ngram TEXT NOT NULL PRIMARY KEY, score INTEGER NOT NULL DEFAULT 0, ' +
            'backoff INTEGER NOT NULL DEFAULT 0) WITHOUT ROWID;'));
        AssertTrue(connection.Exec('INSERT INTO meta(key, value) VALUES (' +
            '''schema_version'', ''' +
            UnicodeString(IntToStr(c_minimum_dictionary_schema_version)) +
            ''');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base ' +
            '(pinyin, text, weight, comment) VALUES ' +
            '(''nihao'', char(20320, 22909), 900, ''''), ' +
            '(''nihao'', char(25311, 22909), 500, '''');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base ' +
            '(pinyin, text, weight, comment) VALUES ' +
            '(''wo'', char(25105), 950, ''''), ' +
            '(''wei'', char(20026), 800, ''''), ' +
            '(''nihou'', char(20320, 22909), 850, ''duplicate reading''), ' +
            '(''nihai'', char(20320, 36824), 700, ''''), ' +
            '(''nihaoma'', char(20320, 22909, 21527), 1000, '''');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base ' +
            '(pinyin, text, weight, comment) VALUES ' +
            '(''shui'', char(35841), 900, ''''), ' +
            '(''shei'', char(35841), 900, ''''), ' +
            '(''a''''erba'', char(38463, 23572, 24052), 600, ''''), ' +
            '(''zhongguo'', char(20013, 22269), 990, ''''), ' +
            '(''zhonghe'', char(20013, 21644), 900, ''''), ' +
            '(''zonghe'', char(32508, 21512), 950, ''''), ' +
            '(''rengongzhineng'', char(20154, 24037, 26234, 33021), 300, ''''), ' +
            '(''kaishi'', char(24320, 22987), 850, ''''), ' +
            '(''chifan'', char(21507, 39277), 820, ''''), ' +
            '(''qian'', char(23884), 600, ''''), ' +
            '(''tao'', char(22871), 650, ''''), ' +
            '(''youxiang'', char(37038, 31665), 880, ''''), ' +
            '(''dizhi'', char(22320, 22336), 860, ''''), ' +
            '(''women'', char(25105, 20204), 900, ''''), ' +
            '(''zai'', char(22312), 900, ''''), ' +
            '(''le'', char(20102), 100, ''''), ' +
            '(''le'', char(20048), 700, '''');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base ' +
            '(pinyin, text, weight, comment) VALUES ' +
            '(''shi'', char(26102), 999, ''''), ' +
            '(''shi'', char(26159), 100, ''''), ' +
            '(''de'', char(22320), 999, ''''), ' +
            '(''de'', char(30340), 100, ''''), ' +
            '(''you'', char(30001), 999, ''''), ' +
            '(''you'', char(26377), 100, ''''), ' +
            '(''shijie'', char(19990, 30028), 900, '''');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base ' +
            '(pinyin, text, weight, comment) VALUES ' +
            '(''haha'', char(21704, 21704), 900, ''''), ' +
            '(''hengha'', char(21756, 21704), 700, ''''), ' +
            '(''henhao'', char(24456, 22909), 1000, ''''), ' +
            '(''elema'', char(39295, 20102, 21527), 850, ''''), ' +
            '(''eleme'', char(39295, 20102, 20040), 800, ''''), ' +
            '(''pashan'', char(29228, 23665), 700, ''''), ' +
            '(''paisheng'', char(27966, 29983), 1000, ''''), ' +
            '(''hen'', char(24456), 696, '''');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base_pinyin_alias ' +
            '(compact_pinyin, word_id) SELECT ''aerba'', id FROM dict_base ' +
            'WHERE pinyin = ''a''''erba'' AND ' +
            'text = char(38463, 23572, 24052);'));
        AssertTrue(connection.Exec('INSERT INTO dict_jianpin ' +
            '(word_id, jianpin, weight) SELECT id, ''rgzn'', 780 ' +
            'FROM dict_base WHERE pinyin = ''rengongzhineng'';'));
        AssertTrue(connection.Exec('INSERT INTO dict_jianpin ' +
            '(word_id, jianpin, weight) SELECT id, ''hh'', weight ' +
            'FROM dict_base WHERE pinyin IN (''haha'', ''hengha'', ' +
            '''henhao'');'));
        AssertTrue(connection.Exec('INSERT INTO dict_jianpin ' +
            '(word_id, jianpin, weight) SELECT id, ''elm'', weight ' +
            'FROM dict_base WHERE pinyin IN (''elema'', ''eleme'');'));
        AssertTrue(connection.Exec('INSERT INTO dict_jianpin ' +
            '(word_id, jianpin, weight) SELECT id, ''ps'', weight ' +
            'FROM dict_base WHERE pinyin IN (''pashan'', ''paisheng'');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base_query_path ' +
            '(query_pinyin, path_text, weight) VALUES ' +
            '(''youxiangdizhi'', char(37038, 31665) || char(3) || ' +
            'char(22320, 22336), 440), ' +
            '(''kaishichifan'', char(24320, 22987) || char(3) || ' +
            'char(21507, 39277), 430), ' +
            '(''qiantao'', char(23884) || char(3) || char(22871), 420);'));
        AssertTrue(connection.Exec('INSERT INTO dict_base_completion_lookup ' +
            '(typed_prefix, full_pinyin, text, weight, popularity_prior, ' +
            'corpus_score, document_score, source_count, path_score, ' +
            'vertical_penalty, layer_kind, prefix_anchored, rank_order) ' +
            'VALUES ' +
            '(''pianruo'', ''pianruojinghong'', ' +
            'char(32745, 33509, 24778, 40511), 619, 185, 50, 0, 1, ' +
            '0, 91, 1, 0, 0);'));
        if traditional then
            AssertTrue(connection.Exec('UPDATE dict_base SET ' +
                'text = char(24744, 22909) WHERE pinyin = ''nihao'' ' +
                'AND weight = 900;'));
    finally
        connection.Free;
    end;
end;

procedure TncEngineServiceTests.PinsStableSingleSyllableCandidatesAboveUserHistory;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    generation: QWord;
    candidate_index: Integer;

    procedure TypeInput(const value: string);
    var
        input_index: Integer;
    begin
        for input_index := 1 to Length(value) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(20, generation,
                LetterEvent(value[input_index]));
        end;
    end;

    function FindCandidate(const text: string): Integer;
    var
        index: Integer;
    begin
        for index := 0 to High(engine_result.candidates) do
            if engine_result.candidates[index].text = text then
                Exit(index);
        Result := -1;
    end;

begin
    generation := 0;
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(20));
        TypeInput('shi');
        AssertEquals(UnicodeString(WideChar($662F)),
            engine_result.candidates[0].text);
        candidate_index := FindCandidate(UnicodeString(WideChar($65F6)));
        AssertTrue(candidate_index >= 1);
        Inc(generation);
        engine_result := service.ProcessKey(20, generation,
            LetterEvent(UnicodeString(IntToStr(candidate_index + 1))));
        AssertEquals(UnicodeString(WideChar($65F6)),
            engine_result.commit_text);

        TypeInput('shi');
        AssertEquals(UnicodeString(WideChar($662F)),
            engine_result.candidates[0].text);
        candidate_index := FindCandidate(UnicodeString(WideChar($65F6)));
        AssertTrue(candidate_index >= 1);
        AssertEquals(1, candidate_index);

        Inc(generation);
        AssertTrue(service.ResetContext(20, generation));
        TypeInput('de');
        AssertEquals(UnicodeString(WideChar($7684)),
            engine_result.candidates[0].text);
        Inc(generation);
        AssertTrue(service.ResetContext(20, generation));
        TypeInput('you');
        AssertEquals(UnicodeString(WideChar($6709)),
            engine_result.candidates[0].text);
        Inc(generation);
        AssertTrue(service.ResetContext(20, generation));
        TypeInput('qing');
        AssertEquals(UnicodeString(WideChar($8BF7)),
            engine_result.candidates[0].text);

        Inc(generation);
        AssertTrue(service.ResetContext(20, generation));
        TypeInput('shijie');
        AssertEquals(UnicodeString(WideChar($4E16)) + WideChar($754C),
            engine_result.candidates[0].text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.RecallsAndFiltersMixedJianpinCandidates;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    generation: QWord;

    procedure TypeInput(const value: string);
    var
        input_index: Integer;
    begin
        for input_index := 1 to Length(value) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(21, generation,
                LetterEvent(value[input_index]));
        end;
    end;

    function FindCandidate(const text: string): Integer;
    var
        index: Integer;
    begin
        for index := 0 to High(engine_result.candidates) do
            if engine_result.candidates[index].text = text then
                Exit(index);
        Result := -1;
    end;

    procedure ResetInput;
    begin
        Inc(generation);
        AssertTrue(service.ResetContext(21, generation));
    end;

begin
    generation := 0;
    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(21));
        TypeInput('hha');
        if FindCandidate(UnicodeString(WideChar($54C8)) +
            WideChar($54C8)) < 0 then
            Fail('hha did not recall haha');
        if FindCandidate(UnicodeString(WideChar($54FC)) +
            WideChar($54C8)) < 0 then
            Fail('hha did not recall hengha');
        AssertEquals(-1, FindCandidate(UnicodeString(WideChar($5F88)) +
            WideChar($597D)));
        if FindCandidate(UnicodeString(WideChar($5F88))) < 0 then
            Fail('hha did not retain the abbreviated head character');

        ResetInput;
        TypeInput('elm');
        if FindCandidate(UnicodeString(WideChar($997F)) +
            WideChar($4E86) + WideChar($5417)) < 0 then
            Fail('elm did not recall elema');
        if FindCandidate(UnicodeString(WideChar($997F)) +
            WideChar($4E86) + WideChar($4E48)) < 0 then
            Fail('elm did not recall eleme');

        ResetInput;
        TypeInput('pas');
        AssertEquals(UnicodeString(WideChar($722C)) + WideChar($5C71),
            engine_result.candidates[0].text);
        AssertEquals(-1, FindCandidate(UnicodeString(WideChar($6D3E)) +
            WideChar($751F)));

        ResetInput;
        TypeInput('haha');
        AssertEquals(UnicodeString(WideChar($54C8)) + WideChar($54C8),
            engine_result.candidates[0].text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.AppliesControlledFuzzyExactRecall;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    generation: QWord;
    expected_china: string;
    expected_exact: string;
    expected_fuzzy: string;

    procedure TypeInput(const value: string);
    var
        input_index: Integer;
    begin
        for input_index := 1 to Length(value) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(18, generation,
                LetterEvent(value[input_index]));
        end;
    end;

    function FindCandidate(const value: string): Integer;
    var
        candidate_index: Integer;
    begin
        for candidate_index := 0 to High(engine_result.candidates) do
            if engine_result.candidates[candidate_index].text = value then
                Exit(candidate_index);
        Result := -1;
    end;

begin
    expected_china := UnicodeString(WideChar(20013)) + WideChar(22269);
    expected_exact := UnicodeString(WideChar(20013)) + WideChar(21644);
    expected_fuzzy := UnicodeString(WideChar(32508)) + WideChar(21512);
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        generation := 0;
        AssertTrue(service.CreateContext(18));
        TypeInput('zongguo');
        AssertEquals(-1, FindCandidate(expected_china));

        AssertTrue(service.GetState(state));
        AssertFalse(state.fuzzy_pinyin_enabled);
        state.fuzzy_pinyin_enabled := True;
        state.fuzzy_pinyin_rules := [fpr_z_zh];
        AssertTrue(service.SetState(state));
        TypeInput('zongguo');
        AssertTrue(Length(engine_result.candidates) > 0);
        AssertEquals(expected_china, engine_result.candidates[0].text);
        AssertEquals(1, engine_result.candidates[0].fuzzy_cost);
        AssertTrue(engine_result.candidates[0].fuzzy_rules = [fpr_z_zh]);

        Inc(generation);
        AssertTrue(service.ResetContext(18, generation));
        TypeInput('zhonghe');
        AssertTrue(Length(engine_result.candidates) >= 2);
        AssertEquals(expected_exact, engine_result.candidates[0].text);
        AssertEquals(0, engine_result.candidates[0].fuzzy_cost);
        AssertEquals(expected_fuzzy, engine_result.candidates[1].text);
        AssertEquals(1, engine_result.candidates[1].fuzzy_cost);
    finally
        service.Free;
    end;

    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.GetState(state));
        AssertTrue(state.fuzzy_pinyin_enabled);
        AssertTrue(state.fuzzy_pinyin_rules = [fpr_z_zh]);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.ProvidesAndAcceptsExactOneKeyCompletion;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    generation: QWord;
    input_index: Integer;
    expected_text: string;
    input_text: string;
    shift_tab_event: TncKeyEvent;
begin
    expected_text := UnicodeString(WideChar(32745)) + WideChar(33509) +
        WideChar(24778) + WideChar(40511);
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(17));
        generation := 0;
        input_text := 'pian';
        for input_index := 1 to Length(input_text) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(17, generation,
                LetterEvent(input_text[input_index]));
        end;
        AssertEquals('', engine_result.completion_text);
        input_text := 'ruo';
        for input_index := 1 to Length(input_text) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(17, generation,
                LetterEvent(input_text[input_index]));
        end;
        AssertEquals('pianruo', engine_result.query_text);
        AssertEquals(expected_text, engine_result.completion_text);
        shift_tab_event := SpecialEvent(sk_tab);
        Include(shift_tab_event.modifiers, km_shift);
        Inc(generation);
        engine_result := service.ProcessKey(17, generation,
            shift_tab_event);
        AssertFalse(engine_result.handled);
        Inc(generation);
        engine_result := service.ProcessKey(17, generation,
            SpecialEvent(sk_tab));
        AssertTrue(engine_result.handled);
        AssertEquals(expected_text, engine_result.commit_text);
        AssertEquals('', engine_result.preedit_text);
        AssertEquals('', engine_result.completion_text);

        Inc(generation);
        engine_result := service.ProcessKey(17, generation,
            SpecialEvent(sk_tab));
        AssertFalse(engine_result.handled);

        AssertTrue(service.GetState(state));
        state.pinyin_scheme := pis_xiaohe_shuangpin;
        AssertTrue(service.SetState(state));
        input_text := 'pmro';
        for input_index := 1 to Length(input_text) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(17, generation,
                LetterEvent(input_text[input_index]));
        end;
        AssertEquals('pianruo', engine_result.query_text);
        AssertEquals(expected_text, engine_result.completion_text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.RecallsAliasesJianpinAndDirectPaths;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    generation: QWord;

    procedure TypeInput(const value: string);
    var
        input_index: Integer;
    begin
        for input_index := 1 to Length(value) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(5, generation,
                LetterEvent(value[input_index]));
        end;
    end;

begin
    service := TncEngineService.Create(FDatabasePath);
    try
        generation := 0;
        AssertTrue(service.CreateContext(5));
        TypeInput('shei');
        AssertTrue(Length(engine_result.candidates) > 0);
        AssertEquals(UnicodeString(WideChar($8C01)),
            engine_result.candidates[0].text);

        Inc(generation);
        AssertTrue(service.ResetContext(5, generation));
        TypeInput('aerba');
        AssertTrue(Length(engine_result.candidates) > 0);
        AssertEquals(UnicodeString(WideChar($963F)) + WideChar($5C14) +
            WideChar($5DF4), engine_result.candidates[0].text);

        Inc(generation);
        AssertTrue(service.ResetContext(5, generation));
        TypeInput('rgzn');
        AssertTrue(Length(engine_result.candidates) > 0);
        AssertEquals(UnicodeString(WideChar($4EBA)) + WideChar($5DE5) +
            WideChar($667A) + WideChar($80FD),
            engine_result.candidates[0].text);

        Inc(generation);
        AssertTrue(service.ResetContext(5, generation));
        TypeInput('youxiangdizhi');
        AssertTrue(Length(engine_result.candidates) > 0);
        AssertEquals(UnicodeString(WideChar($90AE)) + WideChar($7BB1) +
            WideChar($5730) + WideChar($5740),
            engine_result.candidates[0].text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.BuildsSegmentedSentencePathWithoutLosingSyllables;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    input_text: string;
    index: Integer;
begin
    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(6));
        input_text := 'kaishichifan';
        for index := 1 to Length(input_text) do
            engine_result := service.ProcessKey(6, index,
                LetterEvent(input_text[index]));
        AssertTrue(Length(engine_result.candidates) > 0);
        AssertEquals(UnicodeString(WideChar($5F00)) + WideChar($59CB) +
            WideChar($5403) + WideChar($996D),
            engine_result.candidates[0].text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.ReranksLongSegmentedPathsWithoutCrossingDirectTier;
var
    service: TncEngineService;
    connection: TncSqliteConnection;
    engine_result: TncEngineResult;
    generation: QWord;
    expected_text: string;
    input_text: string;

    procedure TypeInput(const value: string);
    var
        input_index: Integer;
    begin
        for input_index := 1 to Length(value) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(23, generation,
                LetterEvent(value[input_index]));
        end;
    end;

begin
    generation := 0;
    input_text := 'womenzaichifanle';
    expected_text := UnicodeString(WideChar(25105)) + WideChar(20204) +
        WideChar(22312) + WideChar(21507) + WideChar(39277) + WideChar(20102);

    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(23));
        TypeInput(input_text);
        AssertEquals(expected_text, engine_result.candidates[0].text);
    finally
        service.Free;
    end;

    connection := TncSqliteConnection.Create(FDatabasePath);
    try
        AssertTrue(connection.Open);
        AssertTrue(connection.Exec('INSERT INTO dict_base_char_lm ' +
            '(ngram, score, backoff) VALUES ' +
            '(char(2, 2, 2, 25105), -100, 0), ' +
            '(char(2, 2, 25105, 20204), -100, 0), ' +
            '(char(2, 25105, 20204, 22312), -100, 0), ' +
            '(char(25105, 20204, 22312, 21507), -100, 0), ' +
            '(char(20204, 22312, 21507, 39277), -100, 0), ' +
            '(char(22312, 21507, 39277, 20102), -100, 0), ' +
            '(char(21507, 39277, 20102, 3), -100, 0), ' +
            '(char(22312, 21507, 39277, 20048), -10000, 0), ' +
            '(char(21507, 39277, 20048, 3), -10000, 0);'));
    finally
        connection.Free;
    end;

    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(23));
        TypeInput(input_text);
        AssertEquals(expected_text, engine_result.candidates[0].text);

        Inc(generation);
        AssertTrue(service.ResetContext(23, generation));
        TypeInput('youxiangdizhi');
        AssertEquals(UnicodeString(WideChar($90AE)) + WideChar($7BB1) +
            WideChar($5730) + WideChar($5740),
            engine_result.candidates[0].text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.SupportsAllShuangpinSchemes;
const
    c_schemes: array[0..5] of TncPinyinInputScheme = (
        pis_microsoft_shuangpin,
        pis_xiaohe_shuangpin,
        pis_ziranma_shuangpin,
        pis_sogou_shuangpin,
        pis_ziguang_shuangpin,
        pis_pinyinjiajia_shuangpin
    );
    c_codes: array[0..5] of string = (
        'nihk', 'nihc', 'nihk', 'nihk', 'nihq', 'nihd'
    );
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    scheme_index: Integer;
    input_index: Integer;
    generation: QWord;
begin
    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(10));
        generation := 0;
        for scheme_index := 0 to High(c_schemes) do
        begin
            AssertTrue(service.GetState(state));
            state.pinyin_scheme := c_schemes[scheme_index];
            AssertTrue(service.SetState(state));
            for input_index := 1 to Length(c_codes[scheme_index]) do
            begin
                Inc(generation);
                engine_result := service.ProcessKey(10, generation,
                    LetterEvent(c_codes[scheme_index][input_index]));
            end;
            AssertEquals(c_codes[scheme_index], engine_result.preedit_text);
            AssertEquals('nihao', engine_result.query_text);
            AssertTrue(Length(engine_result.candidates) > 0);
            AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
                engine_result.candidates[0].text);
        end;
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.LearnsShuangpinSelectionWithCanonicalQuery;
var
    service: TncEngineService;
    connection: TncSqliteConnection;
    statement: Psqlite3_stmt;
    engine_result: TncEngineResult;
    state: TncEngineState;
    generation: QWord;
    input_index: Integer;
    input_text: string;
    expected_text: string;

    function FindCandidate(const value: string): Integer;
    var
        candidate_index: Integer;
    begin
        for candidate_index := 0 to High(engine_result.candidates) do
            if engine_result.candidates[candidate_index].text = value then
                Exit(candidate_index);
        Result := -1;
    end;
begin
    expected_text := UnicodeString(WideChar($62DF)) + WideChar($597D);
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(12));
        AssertTrue(service.CreateContext(13));
        AssertTrue(service.GetState(state));
        state.pinyin_scheme := pis_xiaohe_shuangpin;
        AssertTrue(service.SetState(state));
        generation := 0;
        input_text := 'nihc';
        for input_index := 1 to Length(input_text) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(12, generation,
                LetterEvent(input_text[input_index]));
        end;
        AssertEquals('nihao', engine_result.query_text);
        Inc(generation);
        engine_result := service.ProcessKey(12, generation,
            LetterEvent('2'));
        AssertEquals(expected_text, engine_result.commit_text);

        generation := 0;
        for input_index := 1 to Length(input_text) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(13, generation,
                LetterEvent(input_text[input_index]));
        end;
        AssertEquals('nihao', engine_result.query_text);
        AssertTrue(FindCandidate(expected_text) >= 0);
    finally
        service.Free;
    end;

    connection := TncSqliteConnection.Create(FUserDatabasePath);
    statement := nil;
    try
        AssertTrue(connection.Open);
        AssertTrue(connection.Prepare(
            'SELECT text FROM dict_user_query_latest ' +
            'WHERE query_pinyin = ?1;', statement));
        AssertTrue(connection.BindText(statement, 1, 'nihao'));
        AssertEquals(SQLITE_ROW, connection.Step(statement));
        AssertEquals(expected_text, connection.ColumnText(statement, 0));
    finally
        if statement <> nil then
            connection.Finalize(statement);
        connection.Free;
    end;
end;

procedure TncEngineServiceTests.TogglesInputModeAndConvertsPunctuation;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    shift_event: TncKeyEvent;
    generation: QWord;
    input_index: Integer;
    input_text: string;
begin
    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(11));
        generation := 0;
        shift_event := SpecialEvent(sk_shift);
        shift_event.modifiers := [km_shift];
        Inc(generation);
        engine_result := service.ProcessKey(11, generation, shift_event);
        AssertFalse(engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(im_chinese), Ord(state.input_mode));
        shift_event.is_release := True;
        Inc(generation);
        engine_result := service.ProcessKey(11, generation, shift_event);
        AssertTrue(engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(im_english), Ord(state.input_mode));

        Inc(generation);
        engine_result := service.ProcessKey(11, generation, LetterEvent('n'));
        AssertFalse(engine_result.handled);
        shift_event.is_release := False;
        Inc(generation);
        engine_result := service.ProcessKey(11, generation, shift_event);
        AssertFalse(engine_result.handled);
        shift_event.is_release := True;
        Inc(generation);
        engine_result := service.ProcessKey(11, generation, shift_event);
        AssertTrue(engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(im_chinese), Ord(state.input_mode));

        input_text := 'nihao';
        for input_index := 1 to Length(input_text) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(11, generation,
                LetterEvent(input_text[input_index]));
        end;
        Inc(generation);
        engine_result := service.ProcessKey(11, generation, LetterEvent('.'));
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D) +
            WideChar($3002), engine_result.commit_text);
        Inc(generation);
        engine_result := service.ProcessKey(11, generation, LetterEvent(','));
        AssertTrue(engine_result.handled);
        AssertEquals(UnicodeString(WideChar($FF0C)), engine_result.commit_text);

        for input_index := 1 to Length(input_text) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(11, generation,
                LetterEvent(input_text[input_index]));
        end;
        shift_event.is_release := False;
        Inc(generation);
        engine_result := service.ProcessKey(11, generation, shift_event);
        AssertFalse(engine_result.handled);
        shift_event.is_release := True;
        Inc(generation);
        engine_result := service.ProcessKey(11, generation, shift_event);
        AssertTrue(engine_result.handled);
        AssertEquals('nihao', engine_result.commit_text);
        AssertEquals('', engine_result.preedit_text);
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(im_english), Ord(state.input_mode));
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.DefersAndCancelsModifierOnlyShortcuts;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    shortcut_event: TncKeyEvent;
    generation: QWord;

    procedure VerifyIgnored(const expected_mode: TncInputMode);
    begin
        Inc(generation);
        engine_result := service.ProcessKey(18, generation, shortcut_event);
        AssertFalse(engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(expected_mode), Ord(state.input_mode));
    end;

begin
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(18));
        generation := 0;

        shortcut_event := SpecialEvent(sk_shift);
        shortcut_event.modifiers := [km_shift];
        shortcut_event.is_repeat := True;
        VerifyIgnored(im_chinese);
        shortcut_event.is_repeat := False;
        shortcut_event.is_release := True;
        VerifyIgnored(im_chinese);

        shortcut_event.is_release := False;
        VerifyIgnored(im_chinese);
        shortcut_event := SpecialEvent(sk_control);
        shortcut_event.modifiers := [km_shift, km_control];
        VerifyIgnored(im_chinese);
        shortcut_event := SpecialEvent(sk_shift);
        shortcut_event.modifiers := [km_shift];
        shortcut_event.is_release := True;
        VerifyIgnored(im_chinese);

        shortcut_event := LetterEvent('.');
        shortcut_event.modifiers := [km_control];
        shortcut_event.is_repeat := True;
        VerifyIgnored(im_chinese);
        shortcut_event.is_repeat := False;
        shortcut_event.is_release := True;
        VerifyIgnored(im_chinese);

        shortcut_event := SpecialEvent(sk_space);
        shortcut_event.modifiers := [km_shift];
        shortcut_event.is_repeat := True;
        VerifyIgnored(im_chinese);
        shortcut_event.is_repeat := False;
        shortcut_event.is_release := True;
        VerifyIgnored(im_chinese);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.SupportsFunctionKeyModeShortcuts;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    generation: QWord;
begin
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(19));
        AssertTrue(service.GetState(state));
        state.shortcuts.punctuation_toggle := nc_make_shortcut(VK_F1);
        state.shortcuts.full_width_toggle := nc_make_shortcut(VK_F24);
        AssertTrue(service.SetState(state));
        generation := 0;

        Inc(generation);
        engine_result := service.ProcessKey(19, generation,
            SpecialEvent(sk_f1));
        AssertTrue(engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertFalse(state.punctuation_full_width);

        Inc(generation);
        engine_result := service.ProcessKey(19, generation,
            SpecialEvent(sk_f24));
        AssertTrue(engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertTrue(state.full_width_mode);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.SupportsDefaultModeShortcuts;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    shortcut_event: TncKeyEvent;
    generation: QWord;
begin
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(17));
        generation := 0;

        shortcut_event := LetterEvent('.');
        Include(shortcut_event.modifiers, km_control);
        Inc(generation);
        engine_result := service.ProcessKey(17, generation, shortcut_event);
        AssertTrue('Ctrl+. should toggle punctuation mode',
            engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertFalse('first Ctrl+. should select ASCII punctuation',
            state.punctuation_full_width);
        Inc(generation);
        engine_result := service.ProcessKey(17, generation, LetterEvent('.'));
        AssertFalse('ASCII punctuation should pass through',
            engine_result.handled);

        Inc(generation);
        engine_result := service.ProcessKey(17, generation, shortcut_event);
        AssertTrue('second Ctrl+. should toggle punctuation mode',
            engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertTrue('second Ctrl+. should restore Chinese punctuation',
            state.punctuation_full_width);
        Inc(generation);
        engine_result := service.ProcessKey(17, generation, LetterEvent('.'));
        AssertTrue('Chinese punctuation should be handled',
            engine_result.handled);
        AssertEquals('period should become the Chinese full stop',
            UnicodeString(WideChar($3002)), engine_result.commit_text);

        shortcut_event := SpecialEvent(sk_space);
        Include(shortcut_event.modifiers, km_shift);
        Inc(generation);
        engine_result := service.ProcessKey(17, generation, shortcut_event);
        AssertTrue('Shift+Space should toggle character width',
            engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertTrue('first Shift+Space should enable full width',
            state.full_width_mode);
        state.input_mode := im_english;
        AssertTrue(service.SetState(state));
        Inc(generation);
        engine_result := service.ProcessKey(17, generation,
            SpecialEvent(sk_space));
        AssertEquals('full-width English space should be U+3000',
            UnicodeString(WideChar($3000)), engine_result.commit_text);

        Inc(generation);
        engine_result := service.ProcessKey(17, generation, shortcut_event);
        AssertTrue('second Shift+Space should toggle character width',
            engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertFalse('second Shift+Space should restore half width',
            state.full_width_mode);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.SupportsNumpadModeShortcuts;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    shortcut_event: TncKeyEvent;
begin
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(27));
        AssertTrue(service.GetState(state));
        state.shortcuts.punctuation_toggle.key_code := VK_ADD;
        state.shortcuts.punctuation_toggle.shift_down := True;
        state.shortcuts.punctuation_toggle.ctrl_down := True;
        state.shortcuts.punctuation_toggle.alt_down := True;
        AssertTrue(service.SetState(state));

        shortcut_event := SpecialEvent(sk_numpad_add);
        shortcut_event.modifiers := [km_shift, km_control, km_alt];
        engine_result := service.ProcessKey(27, 1, shortcut_event);
        AssertTrue('Ctrl+Shift+Alt+NumpadPlus should toggle punctuation',
            engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertFalse(state.punctuation_full_width);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.AppliesGlobalWidthAndPunctuationState;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    state: TncEngineState;
    letter_event: TncKeyEvent;
begin
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(14));
        AssertTrue(service.CreateContext(15));
        AssertTrue(service.GetState(state));
        state.punctuation_full_width := False;
        state.full_width_mode := False;
        AssertTrue(service.SetState(state));
        engine_result := service.ProcessKey(14, 1, LetterEvent('.'));
        AssertFalse(engine_result.handled);

        state.full_width_mode := True;
        AssertTrue(service.SetState(state));
        engine_result := service.ProcessKey(15, 1, LetterEvent('.'));
        AssertTrue(engine_result.handled);
        AssertEquals(UnicodeString(WideChar($FF0E)),
            engine_result.commit_text);
        state.input_mode := im_english;
        AssertTrue(service.SetState(state));
        letter_event := LetterEvent('A');
        Include(letter_event.modifiers, km_shift);
        engine_result := service.ProcessKey(14, 2, letter_event);
        AssertTrue(engine_result.handled);
        AssertEquals(UnicodeString(WideChar($FF21)),
            engine_result.commit_text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.PersistsSchemeAndWidthPreferences;
var
    service: TncEngineService;
    state: TncEngineState;
begin
    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.GetState(state));
        state.input_mode := im_english;
        state.pinyin_scheme := pis_sogou_shuangpin;
        state.full_width_mode := True;
        state.punctuation_full_width := False;
        AssertTrue(service.SetState(state));
    finally
        service.Free;
    end;

    service := TncEngineService.Create(FDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(im_chinese), Ord(state.input_mode));
        AssertEquals(Ord(pis_sogou_shuangpin), Ord(state.pinyin_scheme));
        AssertTrue(state.full_width_mode);
        AssertFalse(state.punctuation_full_width);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.SwitchesAndPersistsDictionaryVariant;
var
    service: TncEngineService;
    state: TncEngineState;
    engine_result: TncEngineResult;
    shortcut_event: TncKeyEvent;
    generation: QWord;

    procedure TypeNihao(const context_id: QWord);
    const
        c_input = 'nihao';
    var
        input_index: Integer;
    begin
        for input_index := 1 to Length(c_input) do
        begin
            Inc(generation);
            engine_result := service.ProcessKey(context_id, generation,
                LetterEvent(c_input[input_index]));
        end;
    end;

begin
    generation := 0;
    service := TncEngineService.Create(FDatabasePath,
        FTraditionalDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.CreateContext(22));
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(dv_simplified), Ord(state.dictionary_variant));

        state.dictionary_variant := dv_traditional;
        AssertTrue('direct traditional switch should succeed',
            service.SetState(state));
        TypeNihao(22);
        AssertEquals(UnicodeString(WideChar($60A8)) + WideChar($597D),
            engine_result.candidates[0].text);

        shortcut_event := LetterEvent('t');
        shortcut_event.modifiers := [km_shift, km_control];
        Inc(generation);
        engine_result := service.ProcessKey(22, generation, shortcut_event);
        AssertTrue('Ctrl+Shift+T should switch to simplified',
            engine_result.handled);
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(dv_simplified), Ord(state.dictionary_variant));
        TypeNihao(22);
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
            engine_result.candidates[0].text);

        Inc(generation);
        engine_result := service.ProcessKey(22, generation, shortcut_event);
        AssertTrue('Ctrl+Shift+T should switch back to traditional',
            engine_result.handled);
    finally
        service.Free;
    end;

    generation := 0;
    service := TncEngineService.Create(FDatabasePath,
        FTraditionalDatabasePath, FUserDatabasePath);
    try
        AssertTrue(service.GetState(state));
        AssertEquals('dictionary variant should survive restart',
            Ord(dv_traditional), Ord(state.dictionary_variant));
        AssertTrue(service.CreateContext(23));
        TypeNihao(23);
        AssertEquals(UnicodeString(WideChar($60A8)) + WideChar($597D),
            engine_result.candidates[0].text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.RejectsUnavailableDictionaryVariantWithoutLosingState;
var
    service: TncEngineService;
    state: TncEngineState;
    engine_result: TncEngineResult;
    input_index: Integer;
    missing_path: string;
begin
    missing_path := FTraditionalDatabasePath + '.missing';
    if FileExists(missing_path) then
        DeleteFile(missing_path);
    service := TncEngineService.Create(FDatabasePath, missing_path,
        FUserDatabasePath);
    try
        AssertTrue(service.GetState(state));
        state.dictionary_variant := dv_traditional;
        AssertFalse('missing traditional dictionary must reject the switch',
            service.SetState(state));
        AssertTrue(service.GetState(state));
        AssertEquals(Ord(dv_simplified), Ord(state.dictionary_variant));
        AssertTrue('simplified dictionary must remain usable',
            service.DictionaryReady);
        AssertTrue(service.CreateContext(24));
        for input_index := 1 to Length('nihao') do
            engine_result := service.ProcessKey(24, input_index,
                LetterEvent('nihao'[input_index]));
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
            engine_result.candidates[0].text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.ShowsIncrementalPrefixCandidates;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
begin
    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(4));
        engine_result := service.ProcessKey(4, 1, LetterEvent('w'));
        AssertTrue(engine_result.handled);
        AssertEquals(UnicodeString('w'), engine_result.preedit_text);
        AssertEquals(2, Length(engine_result.candidates));
        AssertEquals(UnicodeString(WideChar($6211)),
            engine_result.candidates[0].text);
        AssertEquals(UnicodeString(WideChar($4E3A)),
            engine_result.candidates[1].text);

        AssertTrue(service.ResetContext(4, 2));
        engine_result := service.ProcessKey(4, 3, LetterEvent('n'));
        engine_result := service.ProcessKey(4, 4, LetterEvent('i'));
        engine_result := service.ProcessKey(4, 5, LetterEvent('h'));
        AssertEquals('nih', engine_result.preedit_text);
        AssertTrue(Length(engine_result.candidates) >= 3);
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
            engine_result.candidates[0].text);
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($8FD8),
            engine_result.candidates[1].text);
        AssertEquals(UnicodeString(WideChar($62DF)) + WideChar($597D),
            engine_result.candidates[2].text);

        engine_result := service.ProcessKey(4, 6, LetterEvent('a'));
        AssertEquals('niha', engine_result.preedit_text);
        AssertTrue(Length(engine_result.candidates) >= 3);
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
            engine_result.candidates[0].text);

        engine_result := service.ProcessKey(4, 7, LetterEvent('o'));
        AssertEquals('nihao', engine_result.preedit_text);
        AssertEquals(2, Length(engine_result.candidates));
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
            engine_result.candidates[0].text);
        AssertEquals(UnicodeString(WideChar($62DF)) + WideChar($597D),
            engine_result.candidates[1].text);
    finally
        service.Free;
    end;
end;

function TncEngineServiceTests.LetterEvent(const value: string): TncKeyEvent;
begin
    Result.text := value;
    Result.special_key := sk_none;
    Result.modifiers := [];
    Result.scan_code := 0;
    Result.is_release := False;
    Result.is_repeat := False;
    Result.timestamp_ms := 1;
end;

function TncEngineServiceTests.SpecialEvent(
    const value: TncSpecialKey): TncKeyEvent;
begin
    Result := LetterEvent('');
    Result.special_key := value;
end;

procedure TncEngineServiceTests.TypesExactCandidateAndCommitsSelection;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    input_text: string;
    index: Integer;
begin
    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(1));
        AssertTrue(service.SetActive(1, True, 1));
        input_text := 'nihao';
        for index := 1 to Length(input_text) do
            engine_result := service.ProcessKey(1, index + 1,
                LetterEvent(input_text[index]));
        AssertTrue(engine_result.handled);
        AssertEquals('nihao', engine_result.preedit_text);
        AssertEquals(2, Length(engine_result.candidates));
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
            engine_result.candidates[0].text);
        AssertEquals(0, engine_result.selected_index);

        engine_result := service.ProcessKey(1, 10, SpecialEvent(sk_space));
        AssertTrue(engine_result.handled);
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
            engine_result.commit_text);
        AssertEquals('', engine_result.preedit_text);
        AssertEquals(0, Length(engine_result.candidates));
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.SupportsNumberSelectionBackspaceAndRawEnter;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
begin
    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(2));
        engine_result := service.ProcessKey(2, 1, LetterEvent('n'));
        engine_result := service.ProcessKey(2, 2, LetterEvent('i'));
        engine_result := service.ProcessKey(2, 3, LetterEvent('h'));
        engine_result := service.ProcessKey(2, 4, LetterEvent('a'));
        engine_result := service.ProcessKey(2, 5, LetterEvent('o'));
        engine_result := service.ProcessKey(2, 6, LetterEvent('2'));
        AssertEquals(UnicodeString(WideChar($62DF)) + WideChar($597D),
            engine_result.commit_text);

        engine_result := service.ProcessKey(2, 7, LetterEvent('x'));
        engine_result := service.ProcessKey(2, 8, LetterEvent('y'));
        engine_result := service.ProcessKey(2, 9, SpecialEvent(sk_backspace));
        AssertEquals(UnicodeString('x'), engine_result.preedit_text);
        engine_result := service.ProcessKey(2, 10, SpecialEvent(sk_enter));
        AssertEquals(UnicodeString('x'), engine_result.commit_text);
    finally
        service.Free;
    end;
end;

procedure TncEngineServiceTests.PassesThroughUnsupportedKeysAndRejectsStaleRequests;
var
    service: TncEngineService;
    engine_result: TncEngineResult;
    event_data: TncKeyEvent;
begin
    service := TncEngineService.Create(FDatabasePath);
    try
        AssertTrue(service.CreateContext(3));
        event_data := LetterEvent('a');
        Include(event_data.modifiers, km_control);
        engine_result := service.ProcessKey(3, 5, event_data);
        AssertFalse(engine_result.handled);
        engine_result := service.ProcessKey(3, 4, LetterEvent('n'));
        AssertEquals(Int64(c_engine_error_stale_generation),
            Int64(engine_result.error_code));
    finally
        service.Free;
    end;
end;

initialization
    RegisterTest(TncEngineServiceTests);

end.
