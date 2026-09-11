unit nc_short_compound_context_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_port_test_support, nc_platform_compat, fpcunit, testregistry, nc_types, nc_config, nc_engine_intf, nc_dictionary_sqlite, nc_sqlite;

type
    TncShortCompoundContextTests = class(TTestCase)
    private
        m_dir, m_query, m_pair, m_exact, m_context: string;
        m_engine: TncEngine;
        procedure sql(const statement: string);
        procedure word(const pinyin, text: string; weight: Integer);
        procedure ngram(const text: string; score: Integer);
        procedure seed(family: Integer = 0; cross_evidence: Boolean = True);
        procedure start(const context: string; deferred: Boolean = False);
        procedure feed(const query: string);
        procedure first_is(const text: string);
        function collect: string;
    public
        procedure setup; override;
        procedure teardown; override;
        procedure attested_context_promotes_existing_pair(family: Integer);
    published
        procedure attested_context_promotes_existing_pair_case_1;
        procedure attested_context_promotes_existing_pair_case_2;
        procedure attested_context_promotes_existing_pair_case_3;

        procedure selected_prefix_supplies_context;
        procedure no_context_preserves_dictionary_exact;
        procedure unique_dictionary_exact_is_protected;
        procedure missing_cross_boundary_observation_abstains;
        procedure shorter_context_observation_is_insufficient;
        procedure longest_context_observation_enables_pair;
        procedure weak_context_lead_abstains;
        procedure conflicting_context_keeps_exact;
        procedure context_free_advantage_is_not_enough;
        procedure head_context_conflict_abstains;
        procedure tied_pair_context_abstains;
        procedure oversized_exact_competition_abstains;
        procedure next_edit_after_context_removal_restores_exact_order;
        procedure lower_weight_exact_context_competitor_is_compared;
        procedure weak_transition_is_not_created;
        procedure user_exact_is_protected;
        procedure paging_backspace_and_reads_are_stable;
        procedure accepted_pair_does_not_become_user_word;
        procedure deferred_models_remain_deferred;
    end;

implementation

procedure TncShortCompoundContextTests.sql(const statement: string);
var connection: TncSqliteConnection;
begin
    connection := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(connection.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(connection.exec(statement), statement);
    finally
        connection.Free;
    end;
end;

procedure TncShortCompoundContextTests.word(const pinyin, text: string;
    weight: Integer);
begin
    sql(UnicodeFormat('INSERT INTO dict_base(pinyin,text,weight) VALUES(''%s'',''%s'',%d)',
        [pinyin, text, weight]));
end;

procedure TncShortCompoundContextTests.ngram(const text: string; score: Integer);
begin
    sql(UnicodeFormat('INSERT OR REPLACE INTO dict_base_char_lm VALUES(''%s'',%d,0)',
        [text, score]));
end;

procedure TncShortCompoundContextTests.setup;
var dictionary: TncSqliteDictionary;
begin
    m_dir := TPath.Combine(TPath.GetTempPath,
        'cassotis_compound_context_' + TPath.GetRandomFileName);
    ForceDirectories(m_dir);
    dictionary := TncSqliteDictionary.Create('', TPath.Combine(m_dir, 'base.db'), False);
    try
        Assert.IsTrue(dictionary.open);
    finally
        dictionary.Free;
    end;
    sql('CREATE TABLE IF NOT EXISTS dict_base_lm_transition (' +
        'query_pinyin TEXT,path_text TEXT,weight INTEGER,' +
        'PRIMARY KEY(query_pinyin,path_text))');
    sql('CREATE TABLE IF NOT EXISTS dict_base_char_lm (' +
        'ngram TEXT PRIMARY KEY,score INTEGER,backoff INTEGER)');
end;

procedure TncShortCompoundContextTests.teardown;
var resolved: string;
begin
    FreeAndNil(m_engine);
    resolved := TPath.GetFullPath(m_dir);
    Assert.IsTrue(UnicodeSameText(ExtractFilePath(resolved),
        IncludeTrailingPathDelimiter(TPath.GetFullPath(TPath.GetTempPath))));
    Assert.IsTrue(Pos('cassotis_compound_context_', ExtractFileName(resolved)) = 1);
    if TDirectory.Exists(resolved) then TDirectory.Delete(resolved, True);
end;

procedure TncShortCompoundContextTests.seed(family: Integer;
    cross_evidence: Boolean);
const
    heads: array[0..2] of string = ('bu', 'jin', 'xue');
    tails: array[0..2] of string = ('jin', 'lai', 'hui');
    pairs: array[0..2] of string = (#$4E0D#$8FDB, #$8FDB#$6765, #$5B66#$4F1A);
    exacts: array[0..2] of string = (#$4E0D#$4EC5, #$8FD1#$6765, #$534F#$4F1A);
    alternatives: array[0..2] of string = (#$4E0D#$5C3D, #$91D1#$6765, #$96EA#$6167);
    contexts: array[0..2] of string = (#$542C, #$8BF7, #$8981);
var idx: Integer;
begin
    m_query := heads[family] + tails[family];
    m_pair := pairs[family];
    m_exact := exacts[family];
    m_context := contexts[family];
    word(heads[family], m_pair[1], 800);
    word(tails[family], m_pair[2], 650);
    word(heads[family], m_exact[1], 700);
    word(tails[family], m_exact[2], 800);
    word(m_query, m_exact, 1000);
    word(m_query, alternatives[family], 100);
    sql(UnicodeFormat('INSERT INTO dict_base_lm_transition VALUES(''%s'',''%s'',468)',
        [m_query, m_pair[1] + #3 + m_pair[2]]));
    for idx := 1 to 2 do
    begin
        ngram(m_pair[idx], -7000);
        ngram(m_exact[idx], -7000);
    end;
    ngram(m_context, -7000);
    ngram(m_pair, -6000);
    ngram(m_exact, -1500);
    ngram(m_context + m_pair[1], -2200);
    ngram(m_context + m_exact[1], -2200);
    if cross_evidence then ngram(m_context + m_pair, -400);
    ngram(m_context + m_exact, -9000);
end;

procedure TncShortCompoundContextTests.start(const context: string;
    deferred: Boolean);
var dictionary: TncSqliteDictionary;
begin
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    if deferred then Assert.IsTrue(dictionary.open_deferred);
    m_engine := TncEngine.Create(nc_default_engine_config, deferred, False, False, dictionary);
    if context <> '' then m_engine.set_external_left_context(context);
end;

procedure TncShortCompoundContextTests.feed(const query: string);
var ch: Char; state: TncKeyState;
begin
    state := Default(TncKeyState);
    for ch in query do
    begin
        m_engine.process_key(Ord(UpCase(ch)), state);
        m_engine.get_candidates;
        m_engine.get_display_text;
    end;
end;

procedure TncShortCompoundContextTests.first_is(const text: string);
var items: TncCandidateList;
begin
    items := m_engine.get_candidates;
    Assert.IsTrue(Length(items) > 0);
    Assert.AreEqual(text, items[0].text, m_engine.get_lookup_debug_info);
    Assert.AreEqual('', items[0].comment);
end;

function TncShortCompoundContextTests.collect: string;
var item: TncCandidate; identity: string;
begin
    Result := '';
    while m_engine.prev_page do begin end;
    repeat
        for item in m_engine.get_candidates do
        begin
            identity := item.text + '/' + item.comment + #10;
            Assert.IsTrue(Pos(identity, Result) = 0, 'Duplicate ' + identity);
            Result := Result + identity;
        end;
    until not m_engine.next_page;
    while m_engine.prev_page do begin end;
end;

procedure TncShortCompoundContextTests.attested_context_promotes_existing_pair(
    family: Integer);
begin
    seed(family);
    start(m_context);
    feed(m_query);
    first_is(m_pair);
    Assert.AreEqual(Ord(cdk_lm_compound), Ord(m_engine.get_candidates[0].display_kind));
    Assert.IsTrue(Pos(m_exact + '/' + #10, collect) > 0);
end;

procedure TncShortCompoundContextTests.selected_prefix_supplies_context;
const bu_chars = #$6B65#$5E03#$90E8#$8865#$535C#$7C3F#$6355#$54FA#$57E0#$57D4#$6016;
var ch: Char; idx: Integer; items: TncCandidateList; state: TncKeyState;
    selected: Boolean;
begin
    seed;
    word('ting', m_context, 1200);
    for ch in bu_chars do word('bu', ch, 100);
    start('');
    feed('ting' + m_query);
    state := Default(TncKeyState);
    selected := False;
    repeat
        items := m_engine.get_candidates;
        for idx := 0 to High(items) do
            if (items[idx].text = m_context) and (items[idx].comment = m_query) then
            begin
                m_engine.process_key(Ord('1') + idx, state);
                selected := True;
                Break;
            end;
        if selected then Break;
    until not m_engine.next_page;
    Assert.IsTrue(selected, 'Missing selectable prefix');
    Assert.AreEqual(m_query, m_engine.get_composition_text);
    first_is(m_pair);
    Assert.AreEqual(m_context + m_pair, m_engine.get_display_text);
end;

procedure TncShortCompoundContextTests.no_context_preserves_dictionary_exact;
begin
    seed;
    start('');
    feed(m_query);
    first_is(m_exact);
    Assert.IsTrue(Pos(m_pair + '/' + #10, collect) > 0);
end;

procedure TncShortCompoundContextTests.missing_cross_boundary_observation_abstains;
begin
    seed(0, False);
    start(m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.unique_dictionary_exact_is_protected;
begin
    seed;
    sql(UnicodeFormat('DELETE FROM dict_base WHERE pinyin=''%s'' AND text<>''%s''',
        [m_query, m_exact]));
    start(m_context);
    feed(m_query);
    first_is(m_exact);
    Assert.IsTrue(Pos(m_pair + '/' + #10, collect) > 0);
end;

procedure TncShortCompoundContextTests.shorter_context_observation_is_insufficient;
begin
    seed;
    start(#$8BF7 + m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.longest_context_observation_enables_pair;
begin
    seed;
    ngram(#$8BF7 + m_context + m_pair, -400);
    ngram(#$8BF7 + m_context + m_exact, -9000);
    start(#$8BF7 + m_context);
    feed(m_query);
    first_is(m_pair);
end;

procedure TncShortCompoundContextTests.weak_context_lead_abstains;
begin
    seed;
    ngram(m_context + m_pair, -1000);
    ngram(m_context + m_exact, -1600);
    start(m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.conflicting_context_keeps_exact;
begin
    seed;
    ngram(m_context + m_pair, -9000);
    ngram(m_context + m_exact, -400);
    start(m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.lower_weight_exact_context_competitor_is_compared;
var competitor: string;
begin
    seed;
    competitor := #$4E0D#$7981;
    word(m_query, competitor, 700);
    ngram(competitor[2], -7000);
    ngram(competitor, -1700);
    ngram(m_context + competitor, -100);
    start(m_context);
    feed(m_query);
    Assert.AreNotEqual(m_pair, m_engine.get_candidates[0].text);
end;

procedure TncShortCompoundContextTests.context_free_advantage_is_not_enough;
begin
    seed;
    ngram(m_pair, -400);
    ngram(m_exact, -9000);
    start(m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.head_context_conflict_abstains;
begin
    seed(1);
    ngram(m_context + m_pair[1], -6000);
    ngram(m_context + m_exact[1], -1000);
    ngram(m_context + m_exact, -12000);
    start(m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.tied_pair_context_abstains;
var other: string;
begin
    seed;
    other := #$4E0D#$8FD1;
    word('jin', other[2], 650);
    sql(UnicodeFormat('INSERT INTO dict_base_lm_transition VALUES(''%s'',''%s'',468)',
        [m_query, other[1] + #3 + other[2]]));
    ngram(other[2], -7000);
    ngram(other, -6000);
    ngram(m_context + other, -400);
    start(m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.oversized_exact_competition_abstains;
const jin_chars = #$4ECA#$91D1#$65A4#$6D25#$9526#$664B#$52B2#$8C28#$7D27;
var ch: Char;
begin
    seed;
    for ch in jin_chars do word(m_query, m_pair[1] + ch, 1);
    start(m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.next_edit_after_context_removal_restores_exact_order;
var state: TncKeyState;
begin
    seed;
    start(m_context);
    feed(m_query);
    first_is(m_pair);
    m_engine.set_external_left_context('');
    // A context snapshot update does not silently reorder displayed choices.
    first_is(m_pair);
    state := Default(TncKeyState);
    m_engine.process_key(VK_BACK, state);
    m_engine.get_candidates;
    feed(Copy(m_query, Length(m_query), 1));
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.weak_transition_is_not_created;
begin
    seed;
    sql('UPDATE dict_base_lm_transition SET weight=200');
    start(m_context);
    feed(m_query);
    first_is(m_exact);
    Assert.IsTrue(Pos(m_pair + '/' + #10, collect) = 0);
end;

procedure TncShortCompoundContextTests.user_exact_is_protected;
var dictionary: TncSqliteDictionary;
begin
    seed;
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dictionary.open);
        dictionary.record_commit(m_query, m_exact, True);
    finally
        dictionary.Free;
    end;
    start(m_context);
    feed(m_query);
    first_is(m_exact);
end;

procedure TncShortCompoundContextTests.paging_backspace_and_reads_are_stable;
var expected: string; state: TncKeyState; config: TncEngineConfig; size: Integer;
begin
    seed;
    start(m_context);
    state := Default(TncKeyState);
    for size in [3, 9] do
    begin
        m_engine.reset;
        config := m_engine.config;
        config.candidate_page_size := size;
        m_engine.update_config(config);
        m_engine.set_external_left_context(m_context);
        feed(m_query);
        first_is(m_pair);
        expected := collect;
        Assert.AreEqual(expected, collect);
        m_engine.process_key(VK_BACK, state);
        m_engine.get_candidates;
        feed(Copy(m_query, Length(m_query), 1));
        first_is(m_pair);
        Assert.AreEqual(expected, collect);
    end;
end;

procedure TncShortCompoundContextTests.accepted_pair_does_not_become_user_word;
var state: TncKeyState; committed: string; dictionary: TncSqliteDictionary;
begin
    seed;
    start(m_context);
    feed(m_query);
    first_is(m_pair);
    state := Default(TncKeyState);
    m_engine.process_key(VK_SPACE, state);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(m_pair, committed);
    FreeAndNil(m_engine);
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dictionary.open);
        Assert.IsFalse(dictionary.is_user_entry(m_query, committed));
    finally
        dictionary.Free;
    end;
end;

procedure TncShortCompoundContextTests.deferred_models_remain_deferred;
begin
    seed;
    start(m_context, True);
    feed(m_query);
    first_is(m_exact);
    Assert.IsTrue(m_engine.dictionary_models_deferred);
end;

procedure TncShortCompoundContextTests.attested_context_promotes_existing_pair_case_1;
begin
    attested_context_promotes_existing_pair(0);
end;

procedure TncShortCompoundContextTests.attested_context_promotes_existing_pair_case_2;
begin
    attested_context_promotes_existing_pair(1);
end;

procedure TncShortCompoundContextTests.attested_context_promotes_existing_pair_case_3;
begin
    attested_context_promotes_existing_pair(2);
end;

initialization
    RegisterTest(TncShortCompoundContextTests);
end.
