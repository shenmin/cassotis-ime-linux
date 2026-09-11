unit nc_jqx_umlaut_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_port_test_support, nc_platform_compat, fpcunit, testregistry, nc_types, nc_config, nc_pinyin_parser, nc_engine_intf,
    nc_dictionary_sqlite, nc_sqlite;

type
    TncJqxUmlautTests = class(TTestCase)
    private
        m_dir: string;
        m_dictionary: TncSqliteDictionary;
        m_engine: TncEngine;
        procedure feed(const query: string);
        function find_candidate(const text, tail: string): Integer;
        function candidate_summary: string;
    public
        procedure setup; override;
        procedure teardown; override;
        procedure aliases_share_exact_candidates(const alias_text,
            canonical, expected: string);
    published
        procedure aliases_share_exact_candidates_case_1;
        procedure aliases_share_exact_candidates_case_2;
        procedure aliases_share_exact_candidates_case_3;
        procedure aliases_share_exact_candidates_case_4;
        procedure aliases_share_exact_candidates_case_5;
        procedure aliases_share_exact_candidates_case_6;
        procedure aliases_share_exact_candidates_case_7;
        procedure aliases_share_exact_candidates_case_8;
        procedure aliases_share_exact_candidates_case_9;
        procedure aliases_share_exact_candidates_case_10;
        procedure aliases_share_exact_candidates_case_11;
        procedure aliases_share_exact_candidates_case_12;

        procedure explicit_boundaries_and_n_l_remain_distinct;
        procedure prefix_selection_keeps_unconsumed_alias_spelling;
        procedure editing_and_enter_keep_raw_keys;
        procedure tab_completion_matches_canonical_input;
        procedure learning_uses_one_canonical_query;
        procedure long_input_preserves_alias_offsets;
        procedure local_repair_receives_canonical_syllables_and_boundaries;
    end;

implementation

type
    TRepairQueryProbe = class(TInterfacedObject, IncLongNeuralReranker, IncLongLocalRepair)
    public
        query: string;
        function should_generate(const query_text: string;
            const candidates: TncLongFinalCandidateDebugArray): Boolean;
        function try_generate(const query_text: string;
            out candidates: TncLongGeneratedCandidateArray): Boolean;
        function try_select(const query_text: string;
            const candidates: TncLongFinalCandidateDebugArray;
            out selected_index: Integer): Boolean;
        procedure set_document_context(const document_key, preceding_text: string);
        function try_repair(const query_text, draft_text, document_key, preceding_text: string;
            out repaired_text, aligned_pinyin: string; out minimum_word_ratio: Double): Boolean;
    end;

function TRepairQueryProbe.should_generate(const query_text: string;
    const candidates: TncLongFinalCandidateDebugArray): Boolean;
begin
    Result := False;
end;

function TRepairQueryProbe.try_generate(const query_text: string;
    out candidates: TncLongGeneratedCandidateArray): Boolean;
begin
    candidates := nil;
    Result := False;
end;

function TRepairQueryProbe.try_select(const query_text: string;
    const candidates: TncLongFinalCandidateDebugArray; out selected_index: Integer): Boolean;
begin
    selected_index := 0;
    Result := False;
end;

procedure TRepairQueryProbe.set_document_context(const document_key, preceding_text: string);
begin
end;

function TRepairQueryProbe.try_repair(const query_text, draft_text, document_key, preceding_text: string;
    out repaired_text, aligned_pinyin: string; out minimum_word_ratio: Double): Boolean;
begin
    query := query_text;
    repaired_text := '';
    aligned_pinyin := '';
    minimum_word_ratio := 1;
    Result := False;
end;

procedure TncJqxUmlautTests.setup;
var
    connection: TncSqliteConnection;
begin
    m_dir := TPath.Combine(TPath.GetTempPath,
        'cassotis_jqx_' + TPath.GetRandomFileName);
    ForceDirectories(m_dir);
    m_dictionary := TncSqliteDictionary.Create('', TPath.Combine(m_dir, 'base.db'), False);
    Assert.IsTrue(m_dictionary.open, 'Create temporary seed dictionary');
    FreeAndNil(m_dictionary);
    connection := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(connection.open(SQLITE_OPEN_READWRITE), 'Open temporary seed connection');
        Assert.IsTrue(connection.exec('INSERT INTO dict_base(pinyin,text,weight) VALUES ' +
            '(''ju'',''居'',800),(''ju'',''局'',700),(''qu'',''区'',800),' +
            '(''xu'',''需'',800),(''jue'',''决'',800),(''que'',''却'',800),' +
            '(''xue'',''学'',800),(''juan'',''卷'',800),(''quan'',''全'',800),' +
            '(''xuan'',''选'',800),(''jun'',''军'',800),(''qun'',''群'',800),' +
            '(''xun'',''寻'',800),(''jia'',''家'',800),(''ma'',''吗'',800),' +
            '(''sheng'',''生'',800),(''huo'',''活'',800),(''xi'',''习'',800),' +
            '(''e'',''饿'',800),(''nv'',''女'',800),(''nu'',''怒'',800),' +
            '(''lv'',''绿'',800),(''lu'',''路'',800),(''nve'',''虐'',800),' +
            '(''lve'',''略'',800),(''jujia'',''居家'',800),' +
            '(''jujiashenghuo'',''居家生活'',800),(''xuexi'',''学习'',800),' +
            '(''jujiashenghuoxuexi'',''居家生活学习'',800)'), 'Seed canonical fixture words');
        Assert.IsTrue(connection.exec('INSERT INTO dict_base_completion_lookup ' +
            '(typed_prefix,full_pinyin,text,weight,popularity_prior,corpus_score,' +
            'document_score,source_count,path_score,vertical_penalty,layer_kind,' +
            'prefix_anchored,rank_order) VALUES ' +
            '(''jujia'',''jujiashenghuo'',''居家生活'',800,900,800,700,5,500,0,0,1,0)'),
            'Seed one reliable canonical completion plan');
    finally
        connection.Free;
    end;
    m_dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    Assert.IsTrue(m_dictionary.open, 'Reopen seeded temporary dictionary');
    m_engine := TncEngine.Create(nc_default_engine_config, False, True, False, m_dictionary);
end;

procedure TncJqxUmlautTests.teardown;
var resolved: string;
begin
    m_engine.Free;
    m_engine := nil;
    m_dictionary := nil;
    resolved := TPath.GetFullPath(m_dir);
    Assert.IsTrue(ExtractFilePath(resolved) =
        IncludeTrailingPathDelimiter(TPath.GetFullPath(TPath.GetTempPath)));
    Assert.IsTrue(Pos('cassotis_jqx_', ExtractFileName(resolved)) = 1);
    if TDirectory.Exists(resolved) then TDirectory.Delete(resolved, True);
end;

procedure TncJqxUmlautTests.feed(const query: string);
var letter: Char; state: TncKeyState;
begin
    state := Default(TncKeyState);
    for letter in query do
        if letter = '''' then m_engine.process_key(VK_OEM_7, state)
        else m_engine.process_key(Ord(UpCase(letter)), state);
end;

function TncJqxUmlautTests.find_candidate(const text, tail: string): Integer;
var candidates: TncCandidateList; idx: Integer;
begin
    candidates := m_engine.get_candidates;
    for idx := 0 to High(candidates) do
        if (candidates[idx].text = text) and (candidates[idx].comment = tail) then
            Exit(idx);
    Result := -1;
end;

function TncJqxUmlautTests.candidate_summary: string;
var item: TncCandidate;
begin
    Result := m_engine.get_composition_text + ': ';
    for item in m_engine.get_candidates do
        Result := Result + item.text + '/' + item.comment + '; ';
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates(const alias_text,
    canonical, expected: string);
var alias_candidates, canonical_candidates: TncCandidateList; idx: Integer;
begin
    Assert.AreEqual(canonical, nc_normalize_umlaut_spelling(alias_text));
    Assert.AreEqual(canonical, nc_normalize_umlaut_spelling(canonical));
    Assert.IsTrue(m_dictionary.lookup_exact_full_pinyin(alias_text, alias_candidates));
    Assert.IsTrue(m_dictionary.lookup_exact_full_pinyin(canonical, canonical_candidates));
    Assert.AreEqual(Length(canonical_candidates), Length(alias_candidates));
    for idx := 0 to High(alias_candidates) do
    begin
        Assert.AreEqual(canonical_candidates[idx].text, alias_candidates[idx].text);
        Assert.AreEqual(canonical_candidates[idx].score, alias_candidates[idx].score);
    end;
    m_engine.debug_set_composition_text(canonical);
    canonical_candidates := m_engine.get_candidates;
    m_engine.reset;
    feed(alias_text);
    Assert.AreEqual(alias_text, m_engine.get_composition_text);
    Assert.IsTrue(find_candidate(expected, '') >= 0, 'Exact visible for ' + alias_text);
    alias_candidates := m_engine.get_candidates;
    Assert.AreEqual(canonical_candidates[0].text, alias_candidates[0].text);
    Assert.AreEqual(Ord(canonical_candidates[0].display_kind),
        Ord(alias_candidates[0].display_kind));
end;

procedure TncJqxUmlautTests.explicit_boundaries_and_n_l_remain_distinct;
const
    distinct_queries: array[0..8] of string =
        ('nu', 'nv', 'lu', 'lv', 'j''v', 'q''v', 'x''v', 'yu', 'yv');
    nl_queries: array[0..3] of string = ('nu', 'nv', 'lu', 'lv');
var query, canonical: string; candidates: TncCandidateList; item: TncCandidate;
begin
    for query in distinct_queries do
        Assert.AreEqual(query, nc_normalize_umlaut_spelling(query));
    Assert.AreEqual('Jujia', nc_normalize_umlaut_spelling('JVjia'));
    Assert.AreEqual('hulvequ', nc_normalize_umlaut_spelling('hulueqv'));
    Assert.AreEqual('ju''e', nc_normalize_umlaut_spelling('jv''e'));
    Assert.AreEqual('qu''an', nc_normalize_umlaut_spelling('qv''an'));
    Assert.AreEqual('xu''n', nc_normalize_umlaut_spelling('xv''n'));
    for query in nl_queries do
    begin
        m_engine.reset;
        feed(query);
        candidates := m_engine.get_candidates;
        case query[1] of
            'n': if query[2] = 'u' then canonical := '怒' else canonical := '女';
            'l': if query[2] = 'u' then canonical := '路' else canonical := '绿';
        end;
        Assert.AreEqual(canonical, candidates[0].text, query);
    end;
    m_dictionary.lookup('jv''e', candidates);
    for item in candidates do
        Assert.IsFalse((item.text = '决') and (item.comment = ''), 'Do not join ju/e');
    m_dictionary.lookup('qv''an', candidates);
    for item in candidates do
        Assert.IsFalse((item.text = '全') and (item.comment = ''), 'Do not join qu/an');
    m_engine.reset;
    m_engine.debug_set_composition_text('jv''e');
    Assert.AreEqual(-1, find_candidate('决', ''), 'Engine preserves explicit ju/e');
end;

procedure TncJqxUmlautTests.prefix_selection_keeps_unconsumed_alias_spelling;
var idx: Integer; state: TncKeyState;
begin
    state := Default(TncKeyState);
    feed('jvjiaxve');
    idx := find_candidate('居家', 'xue');
    Assert.IsTrue((idx >= 0) and (idx < 9), candidate_summary);
    Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
    Assert.AreEqual('xve', m_engine.get_composition_text);
    Assert.IsTrue(find_candidate('学', '') >= 0);
end;

procedure TncJqxUmlautTests.editing_and_enter_keep_raw_keys;
var state: TncKeyState; committed: string;
begin
    state := Default(TncKeyState);
    feed('xve');
    Assert.IsTrue(find_candidate('学', '') >= 0);
    m_engine.process_key(VK_BACK, state);
    Assert.AreEqual('xv', m_engine.get_composition_text);
    Assert.IsTrue(find_candidate('需', '') >= 0);
    feed('e');
    Assert.IsTrue(find_candidate('学', '') >= 0);
    m_engine.process_key(VK_RETURN, state);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual('xve', committed);
end;

procedure TncJqxUmlautTests.tab_completion_matches_canonical_input;
var canonical, alias_completion: TncOneKeyCompletion; state: TncKeyState;
    committed: string;
begin
    canonical := m_engine.debug_query_one_key_completion('jujias', '');
    Assert.AreEqual('居家生活', canonical.text, 'Canonical completion baseline');
    m_engine.reset;
    feed('jvjias');
    alias_completion := m_engine.get_one_key_completion;
    Assert.AreEqual(canonical.text, alias_completion.text, candidate_summary);
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(VK_TAB, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(canonical.text, committed);
end;

procedure TncJqxUmlautTests.learning_uses_one_canonical_query;
var first_bonus, idx: Integer; state: TncKeyState; committed: string;
begin
    state := Default(TncKeyState);
    feed('jv');
    idx := find_candidate('局', '');
    Assert.IsTrue(idx >= 0);
    Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual('局', committed);
    first_bonus := m_dictionary.get_query_choice_bonus('ju', '局');
    Assert.IsTrue(first_bonus > 0, 'Alias choice is available via canonical query');
    m_engine.reset;
    feed('ju');
    idx := find_candidate('局', '');
    Assert.AreEqual(0, idx, 'Canonical spelling shares the previous alias choice');
    Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.IsTrue(m_dictionary.get_query_choice_bonus('ju', '局') > first_bonus);
    m_engine.reset;
    feed('jv');
    Assert.AreEqual(0, find_candidate('局', ''), 'Alias shares canonical learning');
end;

procedure TncJqxUmlautTests.long_input_preserves_alias_offsets;
var candidates: TncCandidateList;
begin
    m_engine.debug_set_composition_text('jujiashenghuoxuexi');
    candidates := m_engine.get_candidates;
    Assert.AreEqual('居家生活学习', candidates[0].text);
    m_engine.reset;
    feed('jvjiashenghuoxvexi');
    Assert.AreEqual('jvjiashenghuoxvexi', m_engine.get_composition_text);
    candidates := m_engine.get_candidates;
    Assert.AreEqual('居家生活学习', candidates[0].text);
end;

procedure TncJqxUmlautTests.local_repair_receives_canonical_syllables_and_boundaries;
var
    connection: TncSqliteConnection;
    probe: TRepairQueryProbe;
    model: IncLongNeuralReranker;
    candidates: TncCandidateList;
begin
    // Leave the component words, but remove the full-query exact that bypasses repair.
    connection := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(connection.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(connection.exec(
            'DELETE FROM dict_base WHERE pinyin=''jujiashenghuoxuexi'''));
    finally
        connection.Free;
    end;
    probe := TRepairQueryProbe.Create;
    model := probe;
    m_engine.set_long_neural_reranker(model);
    m_engine.debug_set_composition_text('jvjia''shenghuoxvexi');
    candidates := m_engine.get_candidates;
    Assert.IsTrue(Length(candidates) > 0);
    Assert.AreEqual('jujia''shenghuoxuexi', probe.query,
        'Repair must see canonical pinyin without dropping explicit boundaries');
    Assert.AreEqual('jvjia''shenghuoxvexi', m_engine.get_composition_text);
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_1;
begin
    aliases_share_exact_candidates('jv', 'ju', '居');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_2;
begin
    aliases_share_exact_candidates('qv', 'qu', '区');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_3;
begin
    aliases_share_exact_candidates('xv', 'xu', '需');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_4;
begin
    aliases_share_exact_candidates('jve', 'jue', '决');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_5;
begin
    aliases_share_exact_candidates('qve', 'que', '却');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_6;
begin
    aliases_share_exact_candidates('xve', 'xue', '学');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_7;
begin
    aliases_share_exact_candidates('jvan', 'juan', '卷');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_8;
begin
    aliases_share_exact_candidates('qvan', 'quan', '全');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_9;
begin
    aliases_share_exact_candidates('xvan', 'xuan', '选');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_10;
begin
    aliases_share_exact_candidates('jvn', 'jun', '军');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_11;
begin
    aliases_share_exact_candidates('qvn', 'qun', '群');
end;

procedure TncJqxUmlautTests.aliases_share_exact_candidates_case_12;
begin
    aliases_share_exact_candidates('xvn', 'xun', '寻');
end;

initialization
    RegisterTest(TncJqxUmlautTests);
end.
