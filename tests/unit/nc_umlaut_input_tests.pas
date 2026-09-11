unit nc_umlaut_input_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_io_compat, nc_platform_compat, fpcunit, testregistry, nc_port_test_support,
    nc_types, nc_config, nc_dictionary_sqlite, nc_engine_intf, nc_sqlite;

type
    TncUmlautInputTests = class(TTestCase)
    private
        m_dir: string;
        m_dict: TncSqliteDictionary;
        m_engine: TncEngine;
        procedure expect_candidate(const query, expected: string);
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure exact_aliases_and_apostrophe_boundaries;
        procedure incremental_aliases_preserve_composition_and_tail;
        procedure enter_keeps_raw_spelling;
        procedure aliases_preserve_raw_prefix_candidates;
        procedure raw_alias_prefixes_survive_editing_and_paging;
    end;

implementation

procedure TncUmlautInputTests.setup;
var
    conn: TncSqliteConnection;
    config: TncEngineConfig;
begin
    m_dir := TPath.Combine(TPath.GetTempPath, 'cassotis_umlaut_' + TPath.GetRandomFileName);
    ForceDirectories(m_dir);
    m_dict := TncSqliteDictionary.Create('', TPath.Combine(m_dir, 'base.db'), False);
    Assert.IsTrue(m_dict.open, 'create fixture dictionary');
    m_dict.Free;
    m_dict := nil;
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(conn.exec('INSERT INTO dict_base(pinyin,text,comment,weight) VALUES ' +
            '(''hu'',''忽'','''',400),(''lve'',''略'','''',500),' +
            '(''nve'',''虐'','''',300),(''dai'',''待'','''',600),' +
            '(''zhan'',''战'','''',600),(''ce'',''策'','''',600),' +
            '(''ma'',''吗'','''',800),(''wo'',''我'','''',900),' +
            '(''lu'',''路'','''',800),(''nu'',''努'','''',500),' +
            '(''e'',''饿'','''',700),(''hua'',''话'','''',700),' +
            '(''hulu'',''葫芦'','''',950),(''hulu'',''呼噜'','''',850),' +
            '(''hulu'',''胡卢'','''',750),(''hulu'',''呼卢'','''',650),' +
            '(''hulve'',''忽略'','''',700),(''nvedai'',''虐待'','''',500),' +
            '(''zhanlve'',''战略'','''',750),(''celve'',''策略'','''',780)'));
    finally
        conn.Free;
    end;
    m_dict := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), TPath.Combine(m_dir, 'user.db'));
    Assert.IsTrue(m_dict.open, 'reopen fixture dictionary');
    config := nc_default_engine_config;
    m_engine := TncEngine.Create(config, False, False, False, m_dict);
end;

procedure TncUmlautInputTests.teardown;
begin
    m_engine.Free;
    m_engine := nil;
    m_dict := nil; // Engine owns the injected provider.
    if TDirectory.Exists(m_dir) then TDirectory.Delete(m_dir, True);
end;

procedure TncUmlautInputTests.expect_candidate(const query, expected: string);
var
    candidates: TncCandidateList;
    item: TncCandidate;
begin
    m_engine.reset;
    m_engine.debug_set_composition_text(query);
    candidates := m_engine.get_candidates;
    for item in candidates do
        if (item.text = expected) and (item.comment = '') then Exit;
    Assert.Fail(query + ': missing exact ' + expected);
end;

procedure TncUmlautInputTests.exact_aliases_and_apostrophe_boundaries;
var
    candidates: TncCandidateList;
    item: TncCandidate;
begin
    Assert.IsTrue(m_dict.lookup_exact_full_pinyin('lue', candidates), 'exact lue');
    Assert.AreEqual('略', candidates[0].text);
    Assert.IsTrue(m_dict.lookup_exact_full_pinyin('hu''lue', candidates), 'exact hu/lue');
    Assert.AreEqual('忽略', candidates[0].text);
    Assert.IsTrue(m_dict.lookup_exact_full_pinyin('NUEDAI', candidates), 'exact nue/dai');
    Assert.AreEqual('虐待', candidates[0].text);
    m_dict.lookup_exact_full_pinyin('lu''e', candidates);
    for item in candidates do Assert.AreNotEqual('略', item.text);
    m_dict.lookup_exact_full_pinyin('hu''lu''e', candidates);
    for item in candidates do Assert.AreNotEqual('忽略', item.text);
    expect_candidate('lue', '略');
    expect_candidate('hulue', '忽略');
    expect_candidate('hu''lue', '忽略');
    expect_candidate('hulve', '忽略');
    expect_candidate('nuedai', '虐待');
    expect_candidate('zhanlue', '战略');
    expect_candidate('celue', '策略');
    m_engine.reset;
    m_engine.debug_set_composition_text('lu''e');
    for item in m_engine.get_candidates do
        Assert.IsFalse((item.text = '略') and (item.comment = ''), 'Do not join explicit lu/e');
    m_engine.reset;
    m_engine.debug_set_composition_text('hu''lu''e');
    for item in m_engine.get_candidates do
        Assert.IsFalse((item.text = '忽略') and (item.comment = ''), 'Do not join explicit hu/lu/e');
end;

procedure TncUmlautInputTests.incremental_aliases_preserve_composition_and_tail;
var
    state: TncKeyState;
    letter: Char;
    candidates: TncCandidateList;
    idx: Integer;
begin
    state := Default(TncKeyState);
    for letter in 'hulue' do m_engine.process_key(Ord(UpCase(letter)), state);
    Assert.AreEqual('hulue', m_engine.get_composition_text);
    candidates := m_engine.get_candidates;
    Assert.IsTrue(Length(candidates) > 0);
    Assert.AreEqual('忽略', candidates[0].text);
    for letter in 'ma' do m_engine.process_key(Ord(UpCase(letter)), state);
    candidates := m_engine.get_candidates;
    idx := 0;
    while (idx < Length(candidates)) and (candidates[idx].text <> '忽略') do Inc(idx);
    Assert.IsTrue(idx < 9, 'The exact prefix must remain selectable');
    Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
    Assert.AreEqual('ma', m_engine.get_composition_text);
    Assert.AreEqual('吗', m_engine.get_candidates[0].text);
    m_engine.reset;
    for letter in 'hulue' do m_engine.process_key(Ord(UpCase(letter)), state);
    m_engine.process_key(VK_BACK, state);
    Assert.AreEqual('hulu', m_engine.get_composition_text);
    m_engine.process_key(Ord('E'), state);
    Assert.AreEqual('忽略', m_engine.get_candidates[0].text);
end;

procedure TncUmlautInputTests.enter_keeps_raw_spelling;
var
    state: TncKeyState;
    letter: Char;
    committed: string;
begin
    state := Default(TncKeyState);
    for letter in 'hulue' do m_engine.process_key(Ord(UpCase(letter)), state);
    m_engine.process_key(VK_RETURN, state);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual('hulue', committed);
end;

procedure TncUmlautInputTests.aliases_preserve_raw_prefix_candidates;
var
    state: TncKeyState;
    candidates: TncCandidateList;
    idx: Integer;

    function find_candidate(const text_value, tail_value: string): Integer;
    var
        candidate_idx: Integer;
    begin
        for candidate_idx := 0 to High(candidates) do
            if (candidates[candidate_idx].text = text_value) and
                (candidates[candidate_idx].comment = tail_value) then Exit(candidate_idx);
        Result := -1;
    end;
begin
    state := Default(TncKeyState);
    m_engine.debug_set_composition_text('hulue');
    candidates := m_engine.get_candidates;
    Assert.AreEqual('忽略', candidates[0].text, 'Full alias match precedes partial matches');
    idx := find_candidate('葫芦', 'e');
    Assert.IsTrue((idx > 0) and (idx < 9), 'hulue must retain hulu/e');
    Assert.IsTrue(find_candidate('呼噜', 'e') > 0, 'All hulu words remain selectable');
    Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
    Assert.AreEqual('e', m_engine.get_composition_text, 'Do not consume the unmatched raw tail');
    candidates := m_engine.get_candidates;
    Assert.IsTrue(find_candidate('饿', '') >= 0, 'Remaining e must decode independently');

    m_engine.reset;
    m_engine.debug_set_composition_text('nue');
    candidates := m_engine.get_candidates;
    Assert.IsTrue(find_candidate('虐', '') >= 0);
    Assert.IsTrue(find_candidate('努', 'e') >= 0, 'nue must retain nu/e');

    m_engine.reset;
    m_engine.debug_set_composition_text('hulve');
    candidates := m_engine.get_candidates;
    Assert.AreEqual(-1, find_candidate('葫芦', 'e'), 'Canonical v input does not imply u/e');
end;

procedure TncUmlautInputTests.raw_alias_prefixes_survive_editing_and_paging;
const
    c_queries: array[0..1] of string = ('huluehua', 'hu''luehua');
var
    config: TncEngineConfig;
    state: TncKeyState;
    letter: Char;
    query: string;
    candidates: TncCandidateList;
    idx: Integer;
    chosen_text: string;
    seen: string;
    page_count: Integer;
    candidate_idx: Integer;
begin
    state := Default(TncKeyState);
    for query in c_queries do
    begin
        m_engine.reset;
        m_engine.debug_set_composition_text(query);
        candidates := m_engine.get_candidates;
        idx := 0;
        while (idx < Length(candidates)) and (candidates[idx].text <> '葫芦') do Inc(idx);
        Assert.IsTrue(idx < Length(candidates), query + ' raw exact prefix');
        Assert.AreEqual('ehua', candidates[idx].comment);
        Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
        Assert.AreEqual('ehua', m_engine.get_composition_text);
    end;

    m_engine.reset;
    for letter in 'hulue' do m_engine.process_key(Ord(UpCase(letter)), state);
    m_engine.process_key(VK_BACK, state);
    Assert.AreEqual('hulu', m_engine.get_composition_text);
    m_engine.process_key(Ord('E'), state);
    candidates := m_engine.get_candidates;
    Assert.AreEqual('忽略', candidates[0].text);
    Assert.AreEqual('葫芦', candidates[1].text);
    Assert.AreEqual('e', candidates[1].comment);

    config := nc_default_engine_config;
    config.candidate_page_size := 3;
    m_engine.update_config(config);
    m_engine.reset;
    m_engine.debug_set_composition_text('hulue');
    candidates := m_engine.get_candidates;
    Assert.AreEqual('忽略', candidates[0].text);
    seen := '';
    page_count := m_engine.get_page_count;
    Assert.IsTrue(page_count >= 2);
    for idx := 0 to page_count - 1 do
    begin
        candidates := m_engine.get_candidates;
        for chosen_text in ['葫芦', '呼噜', '胡卢', '呼卢'] do
            for candidate_idx := 0 to High(candidates) do
                if candidates[candidate_idx].text = chosen_text then
                begin
                    Assert.IsTrue(Pos('|' + chosen_text + '|', seen) = 0, 'No duplicate across pages');
                    seen := seen + '|' + chosen_text + '|';
                end;
        if idx + 1 < page_count then m_engine.process_key(VK_OEM_PLUS, state);
    end;
    for chosen_text in ['葫芦', '呼噜', '胡卢', '呼卢'] do
        Assert.IsTrue(Pos('|' + chosen_text + '|', seen) > 0, 'Raw prefix stays pageable: ' + chosen_text);
    while m_engine.get_page_index > 0 do m_engine.process_key(VK_OEM_MINUS, state);
    m_engine.process_key(VK_OEM_PLUS, state);
    candidates := m_engine.get_candidates;
    Assert.AreEqual('e', candidates[0].comment);
    Assert.IsTrue(m_engine.process_key(Ord('1'), state));
    Assert.AreEqual('e', m_engine.get_composition_text, 'Page-two digit uses the same candidate mapping');
end;

initialization
    RegisterTest(TncUmlautInputTests);
end.
