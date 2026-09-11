unit nc_ambiguous_prefix_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_io_compat, Generics.Collections, nc_platform_compat,
    fpcunit, testregistry, nc_port_test_support, nc_types, nc_config, nc_dictionary_sqlite,
    nc_engine_intf, nc_sqlite;

type
    TncAmbiguousPrefixTests = class(TTestCase)
    private
        m_dir: string;
        m_engine: TncEngine;
        procedure feed(const text: string);
        function find_prefix(const text, tail: string): Integer;
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure alternate_exact_prefix_does_not_need_compound_evidence;
        procedure explicit_boundaries_are_not_moved;
        procedure whole_word_recovery_respects_explicit_boundaries;
        procedure prefix_selection_preserves_unconsumed_input;
        procedure editing_and_paging_keep_prefixes_unique;
    end;

implementation

procedure TncAmbiguousPrefixTests.setup;
var
    dictionary: TncSqliteDictionary;
    conn: TncSqliteConnection;
    config: TncEngineConfig;
begin
    m_dir := TPath.Combine(TPath.GetTempPath, 'cassotis_boundary_' + TPath.GetRandomFileName);
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
        Assert.IsTrue(conn.exec('INSERT INTO dict_base(pinyin,text,comment,weight) VALUES ' +
            '(''xiao'',''小'','''',724),(''xiao'',''消'','''',475),' +
            '(''xi'',''西'','''',500),(''xin'',''心'','''',600),' +
            '(''nan'',''南'','''',500),(''an'',''安'','''',600),' +
            '(''quan'',''全'','''',650),(''shang'',''商'','''',500),' +
            '(''pi'',''皮'','''',300),(''pin'',''品'','''',500),' +
            '(''xiaoxi'',''消息'','''',1000),(''xiaoxi'',''小溪'','''',280),' +
            '(''xiaoxin'',''小心'','''',470),(''xiaoxin'',''孝心'','''',1),' +
            '(''shangpi'',''上批'','''',300),(''shangpin'',''商品'','''',700),' +
            '(''anquan'',''安全'','''',834),(''nanquan'',''南拳'','''',50)'));
    finally
        conn.Free;
    end;
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), TPath.Combine(m_dir, 'user.db'));
    config := nc_default_engine_config;
    config.candidate_page_size := 3;
    m_engine := TncEngine.Create(config, False, False, False, dictionary);
end;

procedure TncAmbiguousPrefixTests.teardown;
begin
    m_engine.Free;
    m_engine := nil;
    if TDirectory.Exists(m_dir) then TDirectory.Delete(m_dir, True);
end;

procedure TncAmbiguousPrefixTests.feed(const text: string);
var
    letter: Char;
    state: TncKeyState;
begin
    state := Default(TncKeyState);
    for letter in text do
        if letter = '''' then m_engine.process_key(VK_OEM_7, state)
        else m_engine.process_key(Ord(UpCase(letter)), state);
end;

function TncAmbiguousPrefixTests.find_prefix(const text, tail: string): Integer;
var
    candidates: TncCandidateList;
    idx: Integer;
begin
    candidates := m_engine.get_candidates;
    for idx := 0 to High(candidates) do
        if (candidates[idx].text = text) and (candidates[idx].comment = tail) then Exit(idx);
    Result := -1;
end;

procedure TncAmbiguousPrefixTests.alternate_exact_prefix_does_not_need_compound_evidence;
var
    candidate: TncCandidate;
begin
    feed('xiaoxinanquan');
    Assert.IsTrue(find_prefix('小心', 'anquan') >= 0, 'Recover xin/an beside xi/nan');
    for candidate in m_engine.get_candidates do
        Assert.AreNotEqual('小心安全', candidate.text, 'Do not invent an unsupported 2+2 compound');
    m_engine.reset;
    feed('shangpinanquan');
    Assert.IsTrue(find_prefix('商品', 'anquan') >= 0, 'Recover pin/an beside pi/nan');
end;

procedure TncAmbiguousPrefixTests.explicit_boundaries_are_not_moved;
var
    candidate: TncCandidate;
begin
    feed('xiao''xi''nan''quan');
    for candidate in m_engine.get_candidates do
        Assert.AreNotEqual('小心', candidate.text, 'Explicit xi/nan must not become xin/an');
    m_engine.reset;
    feed('xiao''xin''an''quan');
    Assert.IsTrue(find_prefix('小心', 'anquan') >= 0);
end;

procedure TncAmbiguousPrefixTests.whole_word_recovery_respects_explicit_boundaries;
var
    conn: TncSqliteConnection;
    candidate: TncCandidate;
begin
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(conn.exec('INSERT INTO dict_base(pinyin,text,comment,weight) VALUES ' +
            '(''xiaoxinanquan'',''小心安全'','''',320)'));
    finally
        conn.Free;
    end;
    feed('xiaoxinanquan');
    Assert.AreEqual('小心安全', m_engine.get_candidates[0].text);
    m_engine.reset;
    feed('xiao''xi''nan''quan');
    repeat
        for candidate in m_engine.get_candidates do
            Assert.AreNotEqual('小心安全', candidate.text, 'A compact exact row cannot override explicit xi/nan');
    until not m_engine.next_page;
    m_engine.reset;
    feed('xiao''xin''an''quan');
    Assert.IsTrue(find_prefix('小心安全', '') >= 0, 'The matching explicit reading stays visible');
end;

procedure TncAmbiguousPrefixTests.prefix_selection_preserves_unconsumed_input;
var
    state: TncKeyState;
    index: Integer;
    committed: string;
begin
    feed('xiaoxinanquan');
    index := find_prefix('小心', 'anquan');
    Assert.IsTrue(index >= 0);
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(Ord('1') + index, state));
    Assert.AreEqual('anquan', m_engine.get_composition_text);
    Assert.AreEqual('安全', m_engine.get_candidates[0].text);
    Assert.IsTrue(m_engine.process_key(VK_SPACE, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual('小心安全', committed);
end;

procedure TncAmbiguousPrefixTests.editing_and_paging_keep_prefixes_unique;
var
    state: TncKeyState;
    before: TncCandidateList;
    candidate: TncCandidate;
    seen: TDictionary<string, Boolean>;
    index, page: Integer;
begin
    feed('xiaoxinanquan');
    before := m_engine.get_candidates;
    state := Default(TncKeyState);
    m_engine.process_key(VK_BACK, state);
    feed('n');
    Assert.AreEqual(Length(before), Length(m_engine.get_candidates));
    for index := 0 to High(before) do
    begin
        Assert.AreEqual(before[index].text, m_engine.get_candidates[index].text);
        Assert.AreEqual(before[index].comment, m_engine.get_candidates[index].comment);
    end;
    seen := TDictionary<string, Boolean>.Create;
    try
        for page := 0 to 30 do
        begin
            for candidate in m_engine.get_candidates do
            begin
                Assert.IsFalse(seen.ContainsKey(candidate.text + #9 + candidate.comment));
                seen.Add(candidate.text + #9 + candidate.comment, True);
            end;
            if not m_engine.next_page then Break;
        end;
        Assert.IsTrue(seen.ContainsKey('小心' + #9 + 'anquan'));
    finally
        seen.Free;
    end;
end;

initialization
    RegisterTest(TncAmbiguousPrefixTests);
end.
