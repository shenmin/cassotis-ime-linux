unit nc_confirmed_suffix_prefix_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_io_compat, Generics.Collections, nc_platform_compat,
    fpcunit, testregistry, nc_port_test_support, nc_types, nc_config, nc_dictionary_sqlite,
    nc_engine_intf, nc_sqlite, nc_shuangpin_decoder;

type
    TncConfirmedSuffixPrefixTests = class(TTestCase)
    private
        m_dir: string;
        m_engine: TncEngine;
        procedure feed(const query: string);
        procedure choose(const text, tail: string; space: Boolean = False);
        function collect: string;
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure three_syllable_tail_retains_all_prefixes;
        procedure different_tail_lengths_retain_prefixes;
        procedure paged_single_selection_preserves_tail_and_commit;
        procedure space_selection_and_undo_keep_prefixes;
        procedure user_exact_remains_first;
        procedure explicit_boundaries_remain_selectable;
        procedure shuangpin_suffix_keeps_prefixes;
    end;

implementation

const
    c_hint = #$63D0#$793A;
    c_cover = #$8986#$76D6;
    c_rate = #$7387;
    c_ratio = #$6BD4#$4F8B;
    c_auto = #$81EA#$52A8;
    c_save = #$4FDD#$5B58;
    c_config = #$914D#$7F6E;
    c_file = #$6587#$4EF6;
    c_name = #$540D;
    c_probability = #$6982#$7387;
    c_user = #$8D1F#$6982#$7387;
    c_fu_singles = #$526F#$4ED8#$670D#$4F5B#$7236#$9644#$592B#$5E9C#$5E45 +
        #$8D1F#$590D#$5BCC#$6276#$798F#$6D6E#$5987#$5085#$4F0F#$7B26 +
        #$8150#$8179#$8986#$752B#$4FEF#$80A4#$5B5A#$91DC#$65A7;

procedure TncConfirmedSuffixPrefixTests.setup;
var
    dictionary: TncSqliteDictionary;
    connection: TncSqliteConnection;
    config: TncEngineConfig;
    idx: Integer;

    procedure add(const pinyin, text: string; weight: Integer);
    begin
        Assert.IsTrue(connection.exec(Format(
            'INSERT INTO dict_base(pinyin,text,weight) VALUES (''%s'',''%s'',%d)',
            [pinyin, text, weight])));
    end;
begin
    m_dir := TPath.Combine(TPath.GetTempPath,
        'cassotis_confirmed_suffix_' + TPath.GetRandomFileName);
    ForceDirectories(m_dir);
    dictionary := TncSqliteDictionary.Create('', TPath.Combine(m_dir, 'base.db'), False);
    try
        Assert.IsTrue(dictionary.open);
    finally
        dictionary.Free;
    end;
    connection := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(connection.open(SQLITE_OPEN_READWRITE));
        add('ti', #$63D0, 700);
        add('shi', #$793A, 500);
        add('tishi', c_hint, 900);
        add('fugailv', c_cover + c_rate, 800);
        add('fugai', c_cover, 700);
        add('gai', #$76D6, 600);
        add('gai', #$6982, 550);
        add('lv', c_rate, 600);
        add('lv', #$7EFF, 550);
        add('gailv', c_probability, 800);
        for idx := 1 to Length(c_fu_singles) do
            add('fu', c_fu_singles[idx], 700 - idx);
        add('bi', #$6BD4, 700);
        add('bi', #$5FC5, 600);
        add('li', #$4F8B, 600);
        add('bili', c_ratio, 800);
        add('zi', #$81EA, 700);
        add('dong', #$52A8, 600);
        add('bao', #$4FDD, 700);
        add('cun', #$5B58, 600);
        add('zidong', c_auto, 800);
        add('baocun', c_save, 800);
        add('zidongbaocun', c_auto + c_save, 900);
        add('pei', #$914D, 700);
        add('zhi', #$7F6E, 600);
        add('wen', #$6587, 700);
        add('jian', #$4EF6, 600);
        add('ming', c_name, 600);
        add('peizhi', c_config, 800);
        add('wenjian', c_file, 800);
        add('peizhiwenjian', c_config + c_file, 850);
        add('peizhiwenjianming', c_config + c_file + c_name, 900);
    finally
        connection.Free;
    end;
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    config := nc_default_engine_config;
    config.candidate_page_size := 3;
    m_engine := TncEngine.Create(config, False, False, False, dictionary);
end;

procedure TncConfirmedSuffixPrefixTests.teardown;
var resolved: string;
begin
    FreeAndNil(m_engine);
    resolved := TPath.GetFullPath(m_dir);
    Assert.IsTrue(SameText(ExtractFilePath(resolved),
        IncludeTrailingPathDelimiter(TPath.GetFullPath(TPath.GetTempPath))));
    Assert.IsTrue(Pos('cassotis_confirmed_suffix_', ExtractFileName(resolved)) = 1);
    if TDirectory.Exists(resolved) then TDirectory.Delete(resolved, True);
end;

procedure TncConfirmedSuffixPrefixTests.feed(const query: string);
var ch: Char; state: TncKeyState;
begin
    state := Default(TncKeyState);
    for ch in query do
    begin
        if ch = '''' then m_engine.process_key(VK_OEM_7, state)
        else m_engine.process_key(Ord(UpCase(ch)), state);
        m_engine.get_candidates;
    end;
end;

procedure TncConfirmedSuffixPrefixTests.choose(const text, tail: string;
    space: Boolean);
var candidates: TncCandidateList; idx: Integer; state: TncKeyState;
begin
    while m_engine.prev_page do begin end;
    state := Default(TncKeyState);
    repeat
        candidates := m_engine.get_candidates;
        for idx := 0 to High(candidates) do
            if (candidates[idx].text = text) and
                (candidates[idx].comment = tail) then
            begin
                if space then
                begin
                    while m_engine.get_selected_index <> idx do
                        Assert.IsTrue(m_engine.process_key(VK_DOWN, state));
                    Assert.IsTrue(m_engine.process_key(VK_SPACE, state));
                end
                else Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
                Exit;
            end;
    until not m_engine.next_page;
    Assert.Fail('Missing selectable candidate: ' + text + '/' + tail);
end;

function TncConfirmedSuffixPrefixTests.collect: string;
var candidate: TncCandidate; seen: TDictionary<string, Boolean>; key: string;
begin
    Result := '';
    seen := TDictionary<string, Boolean>.Create;
    try
        while m_engine.prev_page do begin end;
        repeat
            for candidate in m_engine.get_candidates do
            begin
                key := candidate.text + '/' + candidate.comment;
                Assert.IsFalse(seen.ContainsKey(key), 'Duplicate: ' + key);
                seen.Add(key, True);
                Result := Result + key + #10;
            end;
        until not m_engine.next_page;
        while m_engine.prev_page do begin end;
    finally
        seen.Free;
    end;
end;

procedure TncConfirmedSuffixPrefixTests.three_syllable_tail_retains_all_prefixes;
var after: string; ch: Char;
begin
    feed('tishifugailv');
    choose(c_hint, 'fugailv');
    Assert.AreEqual('fugailv', m_engine.get_composition_text);
    Assert.AreEqual(c_cover + c_rate, m_engine.get_candidates[0].text);
    after := collect;
    Assert.IsTrue(Pos(c_cover + '/lv', after) > 0);
    for ch in c_fu_singles do
        Assert.IsTrue(Pos(ch + '/gailv', after) > 0, 'Missing fu prefix ' + ch);
end;

procedure TncConfirmedSuffixPrefixTests.different_tail_lengths_retain_prefixes;
const
    queries: array[0..2] of string = ('bili', 'zidongbaocun', 'peizhiwenjianming');
    prefix_texts: array[0..2] of string = (#$6BD4, c_auto, c_config + c_file);
    tails: array[0..2] of string = ('li', 'baocun', 'ming');
var idx: Integer; all: string;
begin
    for idx := 0 to High(queries) do
    begin
        m_engine.reset;
        feed('tishi' + queries[idx]);
        choose(c_hint, queries[idx]);
        all := collect;
        Assert.IsTrue(Pos(prefix_texts[idx] + '/' + tails[idx], all) > 0,
            'Missing prefix for ' + queries[idx]);
    end;
end;

procedure TncConfirmedSuffixPrefixTests.paged_single_selection_preserves_tail_and_commit;
var committed: string;
begin
    feed('tishifugailv');
    choose(c_hint, 'fugailv');
    choose(#$65A7, 'gailv');
    Assert.AreEqual('gailv', m_engine.get_composition_text);
    choose(c_probability, '', True);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(c_hint + #$65A7 + c_probability, committed);
end;

procedure TncConfirmedSuffixPrefixTests.space_selection_and_undo_keep_prefixes;
var state: TncKeyState; first: string; committed: string;
begin
    feed('tishifugailv');
    choose(c_hint, 'fugailv', True);
    first := collect;
    Assert.IsTrue(Pos(#$4ED8 + '/gailv', first) > 0);
    state := Default(TncKeyState);
    m_engine.process_key(VK_BACK, state);
    Assert.AreEqual('tishifugailv', m_engine.get_composition_text);
    choose(c_hint, 'fugailv', True);
    Assert.AreEqual(first, collect);
    choose(c_cover, 'lv');
    Assert.AreEqual('lv', m_engine.get_composition_text);
    choose(c_rate, '', True);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(c_hint + c_cover + c_rate, committed);
end;

procedure TncConfirmedSuffixPrefixTests.user_exact_remains_first;
var dictionary: TncSqliteDictionary; config: TncEngineConfig;
begin
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dictionary.open);
        Assert.IsTrue(dictionary.record_literal_user_word('fugailv', c_user));
    finally
        dictionary.Free;
    end;
    config := m_engine.config;
    FreeAndNil(m_engine);
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    m_engine := TncEngine.Create(config, False, False, False, dictionary);
    feed('fugailv');
    Assert.AreEqual(c_user, m_engine.get_candidates[0].text);
    Assert.IsTrue(Pos(#$4ED8 + '/gailv', collect) > 0);
    m_engine.reset;
    feed('tishifugailv');
    choose(c_hint, 'fugailv');
    Assert.AreEqual(c_user, m_engine.get_candidates[0].text);
    Assert.IsTrue(Pos(#$4ED8 + '/gailv', collect) > 0);
end;

procedure TncConfirmedSuffixPrefixTests.explicit_boundaries_remain_selectable;
begin
    feed('ti''shi''fu''gai''lv');
    choose(c_hint, 'fugailv');
    Assert.IsTrue(Pos(#$4ED8 + '/gailv', collect) > 0);
end;

procedure TncConfirmedSuffixPrefixTests.shuangpin_suffix_keeps_prefixes;
const syllables: array[0..4] of string = ('ti', 'shi', 'fu', 'gai', 'lv');
var config: TncEngineConfig; syllable: string; codes: TArray<string>;
begin
    config := m_engine.config;
    config.pinyin_input_scheme := pis_xiaohe_shuangpin;
    m_engine.update_config(config);
    for syllable in syllables do
    begin
        codes := nc_get_shuangpin_codes(pis_xiaohe_shuangpin, syllable);
        feed(codes[0]);
    end;
    choose(c_hint, 'fugailv');
    Assert.IsTrue(Pos(#$4ED8 + '/gailv', collect) > 0);
end;

initialization
    RegisterTest(TncConfirmedSuffixPrefixTests);
end.
