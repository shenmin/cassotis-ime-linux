unit nc_prefix_tier_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_port_test_support, Generics.Collections, nc_platform_compat,
    fpcunit, testregistry, nc_types, nc_config, nc_dictionary_sqlite,
    nc_engine_intf, nc_sqlite, nc_shuangpin_decoder;

type
    TncPrefixTierTests = class(TTestCase)
    private
        m_dir: string;
        m_engine: TncEngine;
        procedure feed(const query: string; incremental: Boolean = True);
        function collect: string;
        procedure assert_prefix_tiers;
        procedure choose(const text, tail: string);
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure all_phrase_prefix_lengths_precede_singles;
        procedure every_homophone_remains_pageable;
        procedure paging_and_backspace_match_fresh_input;
        procedure selecting_reordered_prefix_preserves_tail;
        procedure full_dictionary_exact_remains_first;
        procedure full_user_exact_remains_first;
        procedure explicit_and_shuangpin_boundaries_remain_selectable;
        procedure page_size_does_not_change_candidate_pool;
        procedure repeated_host_reads_are_observational;
        procedure every_displayed_prefix_selects_its_own_tail;
        procedure invalid_last_page_digit_does_not_select;
        procedure strong_short_prefixes_precede_rare_longer_words;
        procedure strong_longer_prefix_is_still_preferred;
    end;

implementation

const
    c_realtime = #$5B9E#$65F6;
    c_try = #$8BD5#$8BD5;
    c_agent = #$65BD#$4E8B#$8005;
    c_this = #$8FD9#$4E2A;
    c_fact = #$4E8B#$5B9E;
    c_homophones: array[0..14] of string = (c_realtime, c_try, c_fact,
        #$5B9E#$65BD, #$5931#$4E8B, #$5B9E#$4E8B, #$65F6#$4E8B,
        #$9002#$65F6, #$901D#$4E16, #$5931#$5B9E, #$65F6#$52BF,
        #$53F2#$8BD7, #$77F3#$72EE, #$65F6#$65F6, #$4E16#$4E8B);
    c_singles = #$662F#$5931#$5341#$65F6#$77F3#$4E8B#$4F7F#$8BD5#$5B9E +
        #$5E02#$5BA4#$5F0F#$89C6#$58EB#$8BC6#$98DF#$5E08#$53F2#$65BD +
        #$8BD7#$5C38#$59CB#$9002#$52BF#$6C0F#$62FE#$901D#$9970#$8A93;

procedure TncPrefixTierTests.setup;
var
    dict: TncSqliteDictionary;
    conn: TncSqliteConnection;
    config: TncEngineConfig;
    idx: Integer;

    procedure add(const pinyin, text: string; weight: Integer);
    begin
        Assert.IsTrue(conn.exec(UnicodeFormat(
            'INSERT INTO dict_base(pinyin,text,weight) VALUES(''%s'',''%s'',%d)',
            [pinyin, text, weight])));
    end;
begin
    m_dir := TPath.Combine(TPath.GetTempPath,
        'cassotis_prefix_tier_' + TPath.GetRandomFileName);
    ForceDirectories(m_dir);
    dict := TncSqliteDictionary.Create('', TPath.Combine(m_dir, 'base.db'), False);
    try
        Assert.IsTrue(dict.open);
    finally
        dict.Free;
    end;
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        for idx := 1 to Length(c_singles) do add('shi', c_singles[idx], 1600 - idx);
        for idx := 0 to High(c_homophones) do add('shishi', c_homophones[idx], 1000 - idx);
        add('shishizhe', c_agent, 900);
        add('zhe', #$8FD9, 900);
        add('zhe', #$8005, 700);
        add('ge', #$4E2A, 900);
        add('ge', #$683C, 700);
        add('zhege', c_this, 900);
    finally
        conn.Free;
    end;
    config := nc_default_engine_config;
    config.candidate_page_size := 9;
    dict := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    m_engine := TncEngine.Create(config, False, False, False, dict);
end;

procedure TncPrefixTierTests.teardown;
var resolved: string;
begin
    FreeAndNil(m_engine);
    resolved := TPath.GetFullPath(m_dir);
    Assert.IsTrue(UnicodeSameText(ExtractFilePath(resolved),
        IncludeTrailingPathDelimiter(TPath.GetFullPath(TPath.GetTempPath))));
    Assert.IsTrue(Pos('cassotis_prefix_tier_', ExtractFileName(resolved)) = 1);
    if TDirectory.Exists(resolved) then TDirectory.Delete(resolved, True);
end;

procedure TncPrefixTierTests.feed(const query: string; incremental: Boolean);
var ch: Char; state: TncKeyState;
begin
    state := Default(TncKeyState);
    for ch in query do
    begin
        if ch = '''' then m_engine.process_key(VK_OEM_7, state)
        else m_engine.process_key(Ord(UpCase(ch)), state);
        if incremental then m_engine.get_candidates;
    end;
end;

function TncPrefixTierTests.collect: string;
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
                Assert.IsFalse(seen.ContainsKey(key), 'Duplicate ' + key);
                seen.Add(key, True);
                Result := Result + key + #10;
            end;
        until not m_engine.next_page;
        while m_engine.prev_page do begin end;
    finally
        seen.Free;
    end;
end;

procedure TncPrefixTierTests.assert_prefix_tiers;
var item: TncCandidate; saw_single: Boolean;
begin
    while m_engine.prev_page do begin end;
    saw_single := False;
    repeat
        for item in m_engine.get_candidates do
        begin
            if item.comment = '' then Continue;
            if Length(item.text) = 1 then saw_single := True
            else Assert.IsFalse(saw_single,
                'Word prefix stranded behind singles: ' + item.text + '/' + item.comment);
        end;
    until not m_engine.next_page;
    while m_engine.prev_page do begin end;
end;

procedure TncPrefixTierTests.choose(const text, tail: string);
var candidates: TncCandidateList; idx: Integer; state: TncKeyState;
begin
    state := Default(TncKeyState);
    while m_engine.prev_page do begin end;
    repeat
        candidates := m_engine.get_candidates;
        for idx := 0 to High(candidates) do
            if (candidates[idx].text = text) and (candidates[idx].comment = tail) then
            begin
                Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
                Exit;
            end;
    until not m_engine.next_page;
    Assert.Fail('Missing selectable prefix: ' + text + '/' + tail);
end;

procedure TncPrefixTierTests.all_phrase_prefix_lengths_precede_singles;
var item: TncCandidate; found_try, found_realtime: Boolean;
begin
    feed('shishizhege');
    assert_prefix_tiers;
    found_try := False;
    found_realtime := False;
    for item in m_engine.get_candidates do
    begin
        found_try := found_try or ((item.text = c_try) and (item.comment = 'zhege'));
        found_realtime := found_realtime or ((item.text = c_realtime) and (item.comment = 'zhege'));
    end;
    Assert.IsTrue(found_try, 'Two-character prefix must not be stranded after singles');
    Assert.IsTrue(found_realtime);
end;

procedure TncPrefixTierTests.every_homophone_remains_pageable;
var all, word: string; ch: Char;
begin
    feed('shishizhege');
    all := collect;
    for word in c_homophones do Assert.IsTrue(Pos(word + '/zhege' + #10, all) > 0, word);
    for ch in c_singles do Assert.IsTrue(Pos(ch + '/shizhege' + #10, all) > 0, ch);
end;

procedure TncPrefixTierTests.paging_and_backspace_match_fresh_input;
var config: TncEngineConfig; page_size: Integer; before: string; state: TncKeyState;
begin
    for page_size in [3, 5, 9] do
    begin
        m_engine.reset;
        config := m_engine.config;
        config.candidate_page_size := page_size;
        m_engine.update_config(config);
        feed('shishizhege', False);
        assert_prefix_tiers;
        before := collect;
        m_engine.reset;
        feed('shishizhege');
        Assert.AreEqual(before, collect);
        state := Default(TncKeyState);
        m_engine.process_key(VK_BACK, state);
        m_engine.get_candidates;
        feed('e');
        Assert.AreEqual(before, collect);
        Assert.IsTrue(m_engine.next_page);
        Assert.IsTrue(m_engine.prev_page);
        Assert.AreEqual(before, collect);
    end;
end;

procedure TncPrefixTierTests.selecting_reordered_prefix_preserves_tail;
var state: TncKeyState; committed: string;
begin
    feed('shishizhege');
    choose(c_try, 'zhege');
    Assert.AreEqual('zhege', m_engine.get_composition_text);
    Assert.AreEqual(c_this, m_engine.get_candidates[0].text);
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(VK_SPACE, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(c_try + c_this, committed);
end;

procedure TncPrefixTierTests.full_dictionary_exact_remains_first;
var conn: TncSqliteConnection;
begin
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(conn.exec('INSERT INTO dict_base(pinyin,text,weight) VALUES ' +
            '(''shishizhege'',''' + c_try + c_this + ''',1900)'));
    finally
        conn.Free;
    end;
    feed('shishizhege');
    Assert.AreEqual(c_try + c_this, m_engine.get_candidates[0].text);
    assert_prefix_tiers;
end;

procedure TncPrefixTierTests.full_user_exact_remains_first;
var dict: TncSqliteDictionary; config: TncEngineConfig;
begin
    config := m_engine.config;
    FreeAndNil(m_engine);
    dict := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dict.open);
        Assert.IsTrue(dict.record_literal_user_word('shishizhege', c_try + c_this));
    finally
        dict.Free;
    end;
    dict := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    m_engine := TncEngine.Create(config, False, False, False, dict);
    feed('shishizhege');
    Assert.AreEqual(c_try + c_this, m_engine.get_candidates[0].text);
    assert_prefix_tiers;
end;

procedure TncPrefixTierTests.explicit_and_shuangpin_boundaries_remain_selectable;
var config: TncEngineConfig; syllable: string; codes: TArray<string>;
begin
    feed('shi''shi''zhe''ge');
    assert_prefix_tiers;
    choose(c_try, 'zhege');
    Assert.AreEqual('zhe''ge', m_engine.get_composition_text);
    m_engine.reset;
    config := m_engine.config;
    config.pinyin_input_scheme := pis_xiaohe_shuangpin;
    m_engine.update_config(config);
    for syllable in ['shi', 'shi', 'zhe', 'ge'] do
    begin
        codes := nc_get_shuangpin_codes(pis_xiaohe_shuangpin, syllable);
        feed(codes[0]);
    end;
    assert_prefix_tiers;
    choose(c_try, 'zhege');
end;

procedure TncPrefixTierTests.page_size_does_not_change_candidate_pool;
var config: TncEngineConfig; size: Integer; reference, actual: string;
begin
    reference := '';
    for size := 3 to 9 do
    begin
        m_engine.reset;
        config := m_engine.config;
        config.candidate_page_size := size;
        m_engine.update_config(config);
        feed('shishizhege');
        actual := collect;
        if size = 3 then reference := actual
        else Assert.AreEqual(reference, actual, 'Page size ' + string(IntToStr(size)));
    end;
end;

procedure TncPrefixTierTests.repeated_host_reads_are_observational;
var before, after: TncCandidateList; page, idx, attempt: Integer;
begin
    feed('shishizhege');
    repeat
        before := m_engine.get_candidates;
        page := m_engine.get_page_index;
        for attempt := 1 to 3 do
        begin
            // Same read sequence used while the host publishes candidate UI state.
            m_engine.get_display_text;
            m_engine.get_one_key_completion;
            m_engine.get_page_count;
            m_engine.get_selected_index;
            after := m_engine.get_candidates;
            Assert.AreEqual(page, m_engine.get_page_index);
            Assert.AreEqual(Length(before), Length(after));
            for idx := 0 to High(before) do
            begin
                Assert.AreEqual(before[idx].text, after[idx].text);
                Assert.AreEqual(before[idx].comment, after[idx].comment);
                Assert.AreEqual(before[idx].score, after[idx].score);
                Assert.AreEqual(Ord(before[idx].display_kind), Ord(after[idx].display_kind));
                Assert.AreEqual(Ord(before[idx].source), Ord(after[idx].source));
            end;
        end;
    until not m_engine.next_page;
end;

procedure TncPrefixTierTests.every_displayed_prefix_selects_its_own_tail;
var rows: TArray<string>; row, text, tail: string; separator: Integer;
begin
    feed('shishizhege');
    rows := collect.Split([#10]);
    for row in rows do
    begin
        separator := Pos('/', row);
        if separator <= 0 then Continue;
        text := Copy(row, 1, separator - 1);
        tail := Copy(row, separator + 1, MaxInt);
        m_engine.reset;
        feed('shishizhege');
        choose(text, tail);
        Assert.AreEqual(tail, m_engine.get_composition_text, row);
    end;
end;

procedure TncPrefixTierTests.invalid_last_page_digit_does_not_select;
var rows: TncCandidateList; state: TncKeyState; before: string; config: TncEngineConfig;
begin
    config := m_engine.config;
    config.candidate_page_size := 8;
    m_engine.update_config(config);
    feed('shishizhege');
    while m_engine.next_page do m_engine.get_candidates;
    rows := m_engine.get_candidates;
    Assert.IsTrue(Length(rows) < 8, 'Fixture needs a partial last page');
    before := m_engine.get_composition_text;
    state := Default(TncKeyState);
    m_engine.process_key(Ord('9'), state);
    Assert.AreEqual(before, m_engine.get_composition_text);
end;

procedure TncPrefixTierTests.strong_short_prefixes_precede_rare_longer_words;
var rows: TncCandidateList; conn: TncSqliteConnection;
begin
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(conn.exec('UPDATE dict_base SET weight=2680 WHERE text=''' + c_realtime + ''''));
        Assert.IsTrue(conn.exec('UPDATE dict_base SET weight=1960 WHERE text=''' + c_try + ''''));
    finally
        conn.Free;
    end;
    feed('shishizhege');
    rows := m_engine.get_candidates;
    Assert.IsTrue(Length(rows) >= 3);
    Assert.AreEqual(c_realtime, rows[0].text);
    Assert.AreEqual(c_try, rows[1].text);
    Assert.IsTrue(Pos(c_agent + '/ge' + #10, collect) > 0);
    choose(c_try, 'zhege');
    Assert.AreEqual('zhege', m_engine.get_composition_text);
end;

procedure TncPrefixTierTests.strong_longer_prefix_is_still_preferred;
var conn: TncSqliteConnection;
begin
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(conn.exec('UPDATE dict_base SET weight=8000 WHERE pinyin=''shishizhe'''));
    finally
        conn.Free;
    end;
    feed('shishizhege');
    Assert.AreEqual(c_agent, m_engine.get_candidates[0].text);
end;


initialization
    RegisterTest(TncPrefixTierTests);
end.
