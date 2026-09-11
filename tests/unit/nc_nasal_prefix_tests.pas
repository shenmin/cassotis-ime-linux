unit nc_nasal_prefix_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_io_compat, Generics.Collections, nc_platform_compat,
    fpcunit, testregistry, nc_port_test_support, nc_types, nc_config, nc_dictionary_sqlite,
    nc_engine_intf, nc_sqlite, nc_shuangpin_decoder;

type
    TncNasalPrefixTests = class(TTestCase)
    private
        m_dir: string;
        m_engine: TncEngine;
        procedure feed(const text: string);
        function find_in_two_pages(const text, tail: string): Integer;
        function collect: string;
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure alternatives_do_not_require_compound_entries;
        procedure numeric_selection_preserves_g_initial;
        procedure typing_backspace_and_paging_are_symmetric;
        procedure explicit_ng_boundary_is_not_moved;
        procedure real_ng_syllable_is_not_reinterpreted;
        procedure full_exact_remains_first;
        procedure small_pages_select_the_same_tail;
        procedure long_input_retains_alternate_prefix;
        procedure user_exact_keeps_priority;
        procedure shuangpin_boundaries_are_not_moved;
    end;

implementation

procedure TncNasalPrefixTests.setup;
var
    dictionary: TncSqliteDictionary;
    conn: TncSqliteConnection;
    config: TncEngineConfig;
    idx: Integer;
    chars: string;
begin
    m_dir := TPath.Combine(TPath.GetTempPath, 'cassotis_nasal_' + TPath.GetRandomFileName);
    ForceDirectories(m_dir);
    dictionary := TncSqliteDictionary.Create('', TPath.Combine(m_dir, 'base.db'), False);
    try
        Assert.IsTrue(dictionary.open);
    finally
        dictionary.Free;
    end;
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(conn.exec('INSERT INTO dict_base(pinyin,text,weight) VALUES ' +
            '(''jian'',''见'',700),(''jian'',''件'',600),(''jian'',''坚'',100),' +
            '(''qian'',''前'',700),(''qiang'',''强'',900),' +
            '(''xian'',''先'',700),(''xiang'',''想'',900),' +
            '(''wan'',''晚'',700),(''wang'',''王'',900),' +
            '(''ge'',''个'',900),(''gei'',''给'',900),(''gao'',''高'',900),' +
            '(''ga'',''嘎'',500),(''ei'',''诶'',900),(''e'',''饿'',900),' +
            '(''ao'',''熬'',900),(''ni'',''你'',900)'), 'Seed base entries');
        chars := '将江讲降蒋姜酱奖疆僵浆匠桨绛缰犟豇茳洚糨';
        for idx := 1 to Length(chars) do
            Assert.IsTrue(conn.exec(Format(
                'INSERT INTO dict_base(pinyin,text,weight) VALUES (''jiang'',''%s'',%d)',
                [chars[idx], 1000 - idx])), 'Seed ng character ' + IntToStr(idx));
    finally
        conn.Free;
    end;
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), TPath.Combine(m_dir, 'user.db'));
    config := nc_default_engine_config;
    config.candidate_page_size := 9;
    m_engine := TncEngine.Create(config, False, False, False, dictionary);
end;

procedure TncNasalPrefixTests.teardown;
begin
    m_engine.Free;
    if TDirectory.Exists(m_dir) then TDirectory.Delete(m_dir, True);
end;

procedure TncNasalPrefixTests.feed(const text: string);
var
    letter: Char;
    state: TncKeyState;
begin
    state := Default(TncKeyState);
    for letter in text do
        if letter = '''' then m_engine.process_key(VK_OEM_7, state)
        else m_engine.process_key(Ord(UpCase(letter)), state);
end;

function TncNasalPrefixTests.find_in_two_pages(const text, tail: string): Integer;
var
    page, idx: Integer;
    candidates: TncCandidateList;
begin
    for page := 0 to 1 do
    begin
        candidates := m_engine.get_candidates;
        for idx := 0 to High(candidates) do
            if (candidates[idx].text = text) and (candidates[idx].comment = tail) then Exit(idx);
        if (page = 0) and not m_engine.next_page then Break;
    end;
    Result := -1;
end;

function TncNasalPrefixTests.collect: string;
var
    candidate: TncCandidate;
    seen: TDictionary<string, Boolean>;
    key: string;
begin
    Result := '';
    seen := TDictionary<string, Boolean>.Create;
    try
        repeat
            for candidate in m_engine.get_candidates do
            begin
                key := candidate.text + '/' + candidate.comment;
                Assert.IsFalse(seen.ContainsKey(key), 'Duplicate prefix: ' + key);
                seen.Add(key, True);
                Result := Result + key + #10;
            end;
        until not m_engine.next_page;
    finally
        seen.Free;
    end;
end;

procedure TncNasalPrefixTests.alternatives_do_not_require_compound_entries;
const
    queries: array[0..4] of string = ('jiangei', 'qiange', 'xiangao', 'wangei', 'jiangeini');
    texts: array[0..4] of string = ('见', '前', '先', '晚', '见');
    tails: array[0..4] of string = ('gei', 'ge', 'gao', 'gei', 'geini');
var
    idx: Integer;
begin
    for idx := 0 to High(queries) do
    begin
        m_engine.reset;
        feed(queries[idx]);
        Assert.IsTrue(find_in_two_pages(texts[idx], tails[idx]) >= 0, queries[idx]);
    end;
end;

procedure TncNasalPrefixTests.numeric_selection_preserves_g_initial;
var
    idx: Integer;
    state: TncKeyState;
    committed: string;
begin
    feed('jiangei');
    idx := find_in_two_pages('见', 'gei');
    Assert.IsTrue(idx >= 0);
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
    Assert.AreEqual('gei', m_engine.get_composition_text);
    Assert.AreEqual('给', m_engine.get_candidates[0].text);
    m_engine.process_key(VK_SPACE, state);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual('见给', committed);
end;

procedure TncNasalPrefixTests.typing_backspace_and_paging_are_symmetric;
var
    before: string;
    state: TncKeyState;
begin
    feed('jiangei');
    before := collect;
    Assert.IsTrue(Pos('坚/gei', before) > 0, 'All alternative singles remain pageable');
    Assert.IsTrue(Pos('江/ei', before) > 0, 'Original ng reading stays available');
    m_engine.reset;
    feed('jiangein');
    state := Default(TncKeyState);
    m_engine.process_key(VK_BACK, state);
    Assert.AreEqual(before, collect);
end;

procedure TncNasalPrefixTests.explicit_ng_boundary_is_not_moved;
begin
    feed('jiang''ei');
    Assert.IsTrue(Pos('见/gei', collect) = 0);
    m_engine.reset;
    feed('jian''gei');
    Assert.IsTrue(find_in_two_pages('见', 'gei') >= 0);
end;

procedure TncNasalPrefixTests.real_ng_syllable_is_not_reinterpreted;
begin
    feed('jiang');
    Assert.IsTrue(Pos('见/g', collect) = 0);
    m_engine.reset;
    feed('jianggao');
    Assert.IsTrue(Pos('见/ggao', collect) = 0);
end;

procedure TncNasalPrefixTests.full_exact_remains_first;
var
    conn: TncSqliteConnection;
begin
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(conn.exec('INSERT INTO dict_base(pinyin,text,weight) VALUES (''xiangei'',''献给'',800)'));
    finally
        conn.Free;
    end;
    feed('xiangei');
    Assert.AreEqual('献给', m_engine.get_candidates[0].text);
    Assert.IsTrue(find_in_two_pages('先', 'gei') >= 0);
end;

procedure TncNasalPrefixTests.small_pages_select_the_same_tail;
var
    dictionary: TncSqliteDictionary;
    config: TncEngineConfig;
    idx: Integer;
    state: TncKeyState;
begin
    m_engine.Free;
    m_engine := nil;
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), TPath.Combine(m_dir, 'user.db'));
    config := nc_default_engine_config;
    config.candidate_page_size := 3;
    m_engine := TncEngine.Create(config, False, False, False, dictionary);
    feed('jiangei');
    idx := find_in_two_pages('见', 'gei');
    Assert.IsTrue(idx >= 0);
    state := Default(TncKeyState);
    m_engine.process_key(Ord('1') + idx, state);
    Assert.AreEqual('gei', m_engine.get_composition_text);
end;

procedure TncNasalPrefixTests.long_input_retains_alternate_prefix;
begin
    feed('jiangeinigeigaoge');
    Assert.IsTrue(Pos('见/geinigeigaoge', collect) > 0);
end;

procedure TncNasalPrefixTests.user_exact_keeps_priority;
var
    dictionary: TncSqliteDictionary;
begin
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dictionary.open);
        Assert.IsTrue(dictionary.record_literal_user_word('jiangei', '见给'));
    finally
        dictionary.Free;
    end;
    feed('jiangei');
    Assert.AreEqual('见给', m_engine.get_candidates[0].text);
    Assert.IsTrue(find_in_two_pages('见', 'gei') >= 0);
end;

procedure TncNasalPrefixTests.shuangpin_boundaries_are_not_moved;
var
    config: TncEngineConfig;
    codes: TArray<string>;
    query: string;
begin
    config := m_engine.config;
    config.pinyin_input_scheme := pis_xiaohe_shuangpin;
    m_engine.update_config(config);
    codes := nc_get_shuangpin_codes(pis_xiaohe_shuangpin, 'jiang');
    query := codes[0];
    codes := nc_get_shuangpin_codes(pis_xiaohe_shuangpin, 'ei');
    feed(query + codes[0]);
    Assert.IsTrue(Pos('见/', collect) = 0);
end;

initialization
    RegisterTest(TncNasalPrefixTests);
end.
