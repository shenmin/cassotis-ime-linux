unit nc_short_prefix_length_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_io_compat, nc_platform_compat, fpcunit, testregistry, nc_port_test_support,
    nc_types, nc_config, nc_dictionary_sqlite, nc_engine_intf, nc_sqlite;

type
    TncShortPrefixLengthTests = class(TTestCase)
    private
        m_dir: string;
        m_engine: TncEngine;
        m_dict: TncSqliteDictionary;
        procedure feed(const value: string);
        function find_any_page(const value: string): Integer;
        procedure assert_short_candidates;
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure short_exact_prefix_does_not_expand_to_long_titles;
        procedure short_prefixes_and_exact_order_remain_available;
        procedure incomplete_initial_does_not_expand_to_long_titles;
        procedure editing_across_long_boundary_drops_stale_completions;
        procedure long_exact_and_long_prefix_remain_available;
        procedure tab_and_dictionary_recall_are_not_length_filtered;
        procedure paging_selection_commits_the_displayed_short_completion;
        procedure user_exact_is_not_treated_as_predictive_extension;
        procedure short_query_keeps_only_two_supported_long_completions;
        procedure popular_vertical_completion_requires_general_evidence;
        procedure long_completion_selection_and_backspace_remain_consistent;
    end;

implementation

const
    c_xiangei = #$732E#$7ED9;
    c_xianggei = #$60F3#$7ED9;
    c_title = #$732E#$7ED9#$851A#$84DD#$4E4B#$6D77#$7684#$65B0#$5A18;
    c_other_title = #$732E#$7ED9#$795E#$660E#$822C#$7684#$4F60;
    c_chenqing = #$9648#$60C5;
    c_chenqingbiao = #$9648#$60C5#$8868;
    c_chushi = #$51FA#$5E08;
    c_chushibiao = #$51FA#$5E08#$8868;
    c_chushiweijie = #$51FA#$5E08#$672A#$6377;
    c_huiyitongzhi = #$4F1A#$8BAE#$901A#$77E5;
    c_huiyitongzhishu = #$4F1A#$8BAE#$901A#$77E5#$4E66;
    c_renmindahuitang = #$4EBA#$6C11#$5927#$4F1A#$5802;
    c_renmindahuitangbinguan = #$4EBA#$6C11#$5927#$4F1A#$5802#$5BBE#$9986;
    c_luoxia = #$843D#$971E;
    c_luoxiahui = #$843D#$4E0B#$7070;
    c_luoxiayuguwuqifei = #$843D#$971E#$4E0E#$5B64#$9E5C#$9F50#$98DE;
    c_luoxia_second = #$843D#$971E#$6EE1#$5929#$6620#$6C5F#$7EA2;
    c_luoxia_third = #$843D#$971E#$6EE1#$5929#$6620#$6C5F#$6C34;
    c_luoxia_medical = #$7F57#$590F#$514B#$58A8#$8FF9#$6D4B#$8BD5#$56FE;
    c_yixue = #$533B#$5B66;
    c_yixue_long = #$533B#$5B66#$5F71#$50CF#$8BCA#$65AD#$5B66;

procedure TncShortPrefixLengthTests.setup;
var
    connection: TncSqliteConnection;
    config: TncEngineConfig;

    procedure add(const pinyin, text: string; weight: Integer);
    var
        statement: Psqlite3_stmt;
    begin
        statement := nil;
        try
            Assert.IsTrue(connection.prepare(
                'INSERT INTO dict_base(pinyin,text,comment,weight) VALUES(?1,?2,'''',?3)', statement));
            Assert.IsTrue(connection.BindText(statement, 1, pinyin));
            Assert.IsTrue(connection.BindText(statement, 2, text));
            Assert.IsTrue(connection.BindInt(statement, 3, weight));
            Assert.AreEqual(SQLITE_DONE, connection.step(statement));
        finally
            if statement <> nil then connection.finalize(statement);
        end;
    end;

    procedure prior(const pinyin, text: string;
        popularity, corpus, sources, layer: Integer);
    var
        statement: Psqlite3_stmt;
    begin
        statement := nil;
        try
            Assert.IsTrue(connection.prepare(
                'INSERT INTO dict_base_completion_prior' +
                '(pinyin,text,popularity_prior,corpus_score,source_count,layer_kind) ' +
                'VALUES(?1,?2,?3,?4,?5,?6)', statement));
            Assert.IsTrue(connection.BindText(statement, 1, pinyin));
            Assert.IsTrue(connection.BindText(statement, 2, text));
            Assert.IsTrue(connection.BindInt(statement, 3, popularity));
            Assert.IsTrue(connection.BindInt(statement, 4, corpus));
            Assert.IsTrue(connection.BindInt(statement, 5, sources));
            Assert.IsTrue(connection.BindInt(statement, 6, layer));
            Assert.AreEqual(SQLITE_DONE, connection.step(statement));
        finally
            if statement <> nil then connection.finalize(statement);
        end;
    end;
begin
    m_dir := TPath.Combine(TPath.GetTempPath, 'cassotis_short_prefix_' + TPath.GetRandomFileName);
    ForceDirectories(m_dir);
    m_dict := TncSqliteDictionary.Create('', TPath.Combine(m_dir, 'base.db'), False);
    Assert.IsTrue(m_dict.open);
    FreeAndNil(m_dict);
    connection := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(connection.open(SQLITE_OPEN_READWRITE));
        add('xian', #$5148, 950);
        add('xian', #$732E, 600);
        add('gei', #$7ED9, 900);
        add('xiang', #$60F3, 900);
        add('wei', #$851A, 300);
        add('lan', #$84DD, 500);
        add('zhi', #$4E4B, 700);
        add('xiangei', c_xiangei, 800);
        add('xianggei', c_xianggei, 600);
        add('xiangeiweilanzhihaidexinniang', c_title, 1500);
        add('xiangeishenmingbandeni', c_other_title, 1400);
        add('chenqing', c_chenqing, 500);
        add('chenqingbiao', c_chenqingbiao, 600);
        add('chenqingbiaoyuanwen', c_chenqingbiao + #$539F#$6587, 1200);
        add('chen', #$9648, 650);
        add('chushi', c_chushi, 700);
        add('chushibiao', c_chushibiao, 600);
        add('chushiweijie', c_chushiweijie, 500);
        add('chushidajie', c_chushi + #$5927#$6377, 650);
        add('chushibuli', c_chushi + #$4E0D#$5229, 620);
        add('chushigaojie', c_chushi + #$544A#$6377, 610);
        add('chu', #$51FA, 800);
        add('huiyitongzhi', c_huiyitongzhi, 800);
        add('huiyitongzhishu', c_huiyitongzhishu, 900);
        add('renmindahuitang', c_renmindahuitang, 800);
        add('renmindahuitangbinguan', c_renmindahuitangbinguan, 900);
        add('luo', #$843D, 800);
        add('xia', #$971E, 700);
        add('luoxia', c_luoxia, 1000);
        add('luoxiahui', c_luoxiahui, 500);
        add('luoxiayuguwuqifei', c_luoxiayuguwuqifei, 445);
        add('luoxiamantianyingjianghong', c_luoxia_second, 400);
        add('luoxiamantianyingjiangshui', c_luoxia_third, 1300);
        add('luoxiakemojiceshitu', c_luoxia_medical, 1700);
        add('yixue', c_yixue, 800);
        add('yixueyingxiangzhenduanxue', c_yixue_long, 600);
        // Include both a general low-count quotation and a genuinely popular
        // technical term; layer membership must not be a blanket exclusion.
        prior('luoxiayuguwuqifei', c_luoxiayuguwuqifei, 141, 50, 1, 0);
        prior('luoxiamantianyingjianghong', c_luoxia_second, 130, 50, 1, 0);
        prior('luoxiamantianyingjiangshui', c_luoxia_third, 120, 40, 1, 0);
        prior('luoxiakemojiceshitu', c_luoxia_medical, 102, 0, 2, 3);
        prior('xiangeiweilanzhihaidexinniang', c_title, 93, 0, 1, 1);
        prior('xiangeishenmingbandeni', c_other_title, 93, 0, 1, 1);
        prior('yixueyingxiangzhenduanxue', c_yixue_long, 780, 600, 5, 3);
    finally
        connection.Free;
    end;
    config := nc_default_engine_config;
    config.candidate_page_size := 3;
    m_dict := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), TPath.Combine(m_dir, 'user.db'));
    m_engine := TncEngine.Create(config, False, True, False, m_dict);
end;

procedure TncShortPrefixLengthTests.teardown;
var
    resolved, temporary_root: string;
begin
    FreeAndNil(m_engine);
    m_dict := nil;
    resolved := TPath.GetFullPath(m_dir);
    temporary_root := IncludeTrailingPathDelimiter(TPath.GetFullPath(TPath.GetTempPath));
    Assert.IsTrue(SameText(ExtractFilePath(resolved), temporary_root));
    Assert.IsTrue(Pos('cassotis_short_prefix_', ExtractFileName(resolved)) = 1);
    if TDirectory.Exists(resolved) then TDirectory.Delete(resolved, True);
end;

procedure TncShortPrefixLengthTests.feed(const value: string);
var
    letter: Char;
    state: TncKeyState;
begin
    state := Default(TncKeyState);
    for letter in value do
    begin
        if letter = '''' then m_engine.process_key(VK_OEM_7, state)
        else m_engine.process_key(Ord(UpCase(letter)), state);
        m_engine.get_candidates;
    end;
end;

function TncShortPrefixLengthTests.find_any_page(const value: string): Integer;
var
    candidates: TncCandidateList;
    idx, offset: Integer;
begin
    while m_engine.prev_page do begin end;
    offset := 0;
    repeat
        candidates := m_engine.get_candidates;
        for idx := 0 to High(candidates) do
            if (candidates[idx].text = value) and (candidates[idx].comment = '') then
                Exit(offset + idx);
        Inc(offset, Length(candidates));
    until not m_engine.next_page;
    Result := -1;
end;

procedure TncShortPrefixLengthTests.assert_short_candidates;
var
    candidate: TncCandidate;
begin
    while m_engine.prev_page do begin end;
    repeat
        for candidate in m_engine.get_candidates do
            Assert.IsTrue(Length(candidate.text) <= 4,
                m_engine.get_composition_text + ': long predictive candidate ' + candidate.text);
    until not m_engine.next_page;
end;

procedure TncShortPrefixLengthTests.short_exact_prefix_does_not_expand_to_long_titles;
begin
    feed('xiangei');
    Assert.AreEqual(0, find_any_page(c_xiangei));
    assert_short_candidates;
    m_engine.reset;
    feed('huiyitongzhi');
    Assert.AreEqual(0, find_any_page(c_huiyitongzhi));
    assert_short_candidates;
end;

procedure TncShortPrefixLengthTests.short_prefixes_and_exact_order_remain_available;
begin
    feed('chenqing');
    Assert.AreEqual(0, find_any_page(c_chenqing));
    Assert.IsTrue(find_any_page(c_chenqingbiao) > 0);
    m_engine.reset;
    feed('chushi');
    Assert.AreEqual(0, find_any_page(c_chushi));
    Assert.IsTrue(find_any_page(c_chushibiao) > 0);
    Assert.IsTrue(find_any_page(c_chushiweijie) > 0);
end;

procedure TncShortPrefixLengthTests.incomplete_initial_does_not_expand_to_long_titles;
begin
    feed('xiangeiw');
    assert_short_candidates;
    m_engine.reset;
    feed('ch');
    assert_short_candidates;
end;

procedure TncShortPrefixLengthTests.editing_across_long_boundary_drops_stale_completions;
var
    state: TncKeyState;
begin
    feed('huiyitongzhishu');
    Assert.AreEqual(0, find_any_page(c_huiyitongzhishu));
    state := Default(TncKeyState);
    m_engine.process_key(VK_BACK, state);
    m_engine.process_key(VK_BACK, state);
    m_engine.process_key(VK_BACK, state);
    Assert.AreEqual('huiyitongzhi', m_engine.get_composition_text);
    assert_short_candidates;
    feed('shu');
    Assert.AreEqual(0, find_any_page(c_huiyitongzhishu));
end;

procedure TncShortPrefixLengthTests.long_exact_and_long_prefix_remain_available;
begin
    m_engine.debug_set_composition_text('xiangeiweilanzhihaidexinniang');
    Assert.IsTrue(find_any_page(c_title) >= 0);
    m_engine.reset;
    feed('renmindahuitang');
    Assert.IsTrue(find_any_page(c_renmindahuitang) >= 0);
    Assert.IsTrue(find_any_page(c_renmindahuitangbinguan) >= 0);
end;

procedure TncShortPrefixLengthTests.tab_and_dictionary_recall_are_not_length_filtered;
var
    candidates: TncCandidateList;
    candidate: TncCandidate;
    found: Boolean;
    completion: TncOneKeyCompletion;
begin
    Assert.IsTrue(m_dict.lookup_full_pinyin_prefix('xiangei', candidates));
    found := False;
    for candidate in candidates do
        if candidate.text = c_title then found := True;
    Assert.IsTrue(found, 'Do not remove long entries from shared dictionary queries');
    completion := m_engine.debug_query_one_key_completion('huiyitongzhi', '');
    Assert.AreEqual(c_huiyitongzhishu, completion.text, 'The five-character extension remains available to Tab');
end;

procedure TncShortPrefixLengthTests.paging_selection_commits_the_displayed_short_completion;
var
    index: Integer;
    committed: string;
    state: TncKeyState;
begin
    feed('chushi');
    index := find_any_page(c_chushiweijie);
    Assert.IsTrue(index >= 3, 'Exercise a completion beyond the first page');
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(Ord('1') + index mod 3, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(c_chushiweijie, committed);
    Assert.AreEqual('', m_engine.get_composition_text);
    Assert.IsFalse(m_dict.is_user_entry('chushi', c_chushiweijie));
end;

procedure TncShortPrefixLengthTests.user_exact_is_not_treated_as_predictive_extension;
var
    candidates: TncCandidateList;
begin
    Assert.IsTrue(m_dict.record_literal_user_word('chushibiao', c_chushibiao));
    feed('csb');
    candidates := m_engine.get_candidates;
    Assert.IsTrue(Length(candidates) > 0);
    Assert.AreEqual(c_chushibiao, candidates[0].text);
    Assert.AreEqual(Integer(cs_user), Integer(candidates[0].source));
end;

procedure TncShortPrefixLengthTests.short_query_keeps_only_two_supported_long_completions;
var
    count: Integer;
    candidate: TncCandidate;
begin
    feed('luoxia');
    Assert.AreEqual(0, find_any_page(c_luoxia));
    Assert.IsTrue(find_any_page(c_luoxiahui) > 0);
    Assert.IsTrue(find_any_page(c_luoxiayuguwuqifei) > find_any_page(c_luoxiahui));
    Assert.IsTrue(find_any_page(c_luoxia_second) > find_any_page(c_luoxiayuguwuqifei));
    Assert.AreEqual(-1, find_any_page(c_luoxia_third), 'Lower-evidence third title must not survive on a later page');
    Assert.AreEqual(-1, find_any_page(c_luoxia_medical), 'High vertical weight is not general popularity');
    count := 0;
    while m_engine.prev_page do begin end;
    repeat
        for candidate in m_engine.get_candidates do
            if Length(candidate.text) >= 5 then Inc(count);
    until not m_engine.next_page;
    Assert.AreEqual(2, count);
end;

procedure TncShortPrefixLengthTests.popular_vertical_completion_requires_general_evidence;
begin
    feed('yixue');
    Assert.AreEqual(0, find_any_page(c_yixue));
    Assert.IsTrue(find_any_page(c_yixue_long) > 0);
end;

procedure TncShortPrefixLengthTests.long_completion_selection_and_backspace_remain_consistent;
var
    state: TncKeyState;
    index: Integer;
    committed: string;
begin
    feed('luoxiay');
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(VK_BACK, state));
    Assert.AreEqual('luoxia', m_engine.get_composition_text);
    index := find_any_page(c_luoxiayuguwuqifei);
    Assert.IsTrue(index > 0);
    Assert.AreEqual(-1, find_any_page(c_luoxia_medical));
    index := find_any_page(c_luoxiayuguwuqifei);
    Assert.IsTrue(m_engine.process_key(Ord('1') + index mod 3, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(c_luoxiayuguwuqifei, committed);
    Assert.AreEqual('', m_engine.get_composition_text);
    Assert.IsFalse(m_dict.is_user_entry('luoxia', c_luoxiayuguwuqifei));
end;

initialization
    RegisterTest(TncShortPrefixLengthTests);
end.
