unit nc_short_compound_evidence_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_port_test_support, nc_platform_compat, fpcunit, testregistry, nc_types, nc_config, nc_engine_intf, nc_dictionary_sqlite, nc_sqlite;

type
    TncShortCompoundEvidenceTests = class(TTestCase)
    private
        m_dir: string;
        m_engine: TncEngine;
        procedure sql(const statement: string);
        procedure add_word(const pinyin, text: string; weight: Integer);
        procedure add_ngram(const text: string; score: Integer);
        procedure add_pair(const pinyin, head, tail: string; weight: Integer);
        procedure start;
        procedure feed(const query: string; incremental: Boolean = True);
        function collect: string;
        procedure assert_first(const text: string);
        procedure seed_shape(head_units, tail_units, family, prefix_weight,
            evidence_weight: Integer; out query, head, tail, tail_query: string);
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure supported_two_plus_two_beats_three_char_shortcut;
        procedure unsupported_two_plus_two_is_not_invented;
        procedure pair_result_is_stable_after_backspace_and_paging;
        procedure pair_keeps_selectable_prefixes_and_tail;
        procedure word_transition_survives_particle_fast_path;
        procedure word_transition_survives_one_plus_two_fast_path;
        procedure attested_trigram_admits_one_plus_two;
        procedure attested_particle_boundary_beats_head_weight;
        procedure conflicting_context_blocks_char_pair_promotion;
        procedure agreeing_context_keeps_char_pair;
        procedure missing_trigram_does_not_use_backoff_as_evidence;
        procedure tied_char_paths_abstain;
        procedure low_weight_component_does_not_generate;
        procedure full_exact_is_not_displaced_by_char_pair;
        procedure user_exact_is_not_displaced_by_pair;
        procedure explicit_boundary_does_not_enable_char_fallback;
        procedure char_pair_is_not_learned_as_user_word;
        procedure attested_api_distinguishes_missing_and_duplicate_entries;
        procedure deferred_models_do_not_force_char_loading;
        procedure missing_char_table_keeps_word_transition_fallback;
    public
        procedure evidence_survives_shape_and_typing_matrix(
            head_units, tail_units, prefix_weight: Integer);
    published
        procedure evidence_survives_shape_and_typing_matrix_case_1;
        procedure evidence_survives_shape_and_typing_matrix_case_2;
        procedure evidence_survives_shape_and_typing_matrix_case_3;
        procedure evidence_survives_shape_and_typing_matrix_case_4;
        procedure evidence_survives_shape_and_typing_matrix_case_5;
        procedure evidence_survives_shape_and_typing_matrix_case_6;
        procedure evidence_survives_shape_and_typing_matrix_case_7;
        procedure evidence_survives_shape_and_typing_matrix_case_8;

    public
        procedure weak_evidence_is_not_promoted_across_shapes(
            head_units, tail_units: Integer);
    published
        procedure weak_evidence_is_not_promoted_across_shapes_case_1;
        procedure weak_evidence_is_not_promoted_across_shapes_case_2;
        procedure weak_evidence_is_not_promoted_across_shapes_case_3;
        procedure weak_evidence_is_not_promoted_across_shapes_case_4;

    public
        procedure dictionary_exact_keeps_priority_across_shapes(
            head_units, tail_units: Integer);
    published
        procedure dictionary_exact_keeps_priority_across_shapes_case_1;
        procedure dictionary_exact_keeps_priority_across_shapes_case_2;
        procedure dictionary_exact_keeps_priority_across_shapes_case_3;
        procedure dictionary_exact_keeps_priority_across_shapes_case_4;

    public
        procedure user_exact_keeps_priority_across_shapes(
            head_units, tail_units: Integer);
    published
        procedure user_exact_keeps_priority_across_shapes_case_1;
        procedure user_exact_keeps_priority_across_shapes_case_2;
        procedure user_exact_keeps_priority_across_shapes_case_3;
        procedure user_exact_keeps_priority_across_shapes_case_4;

    public
        procedure accepted_compound_is_not_learned_across_shapes(
            head_units, tail_units: Integer);
    published
        procedure accepted_compound_is_not_learned_across_shapes_case_1;
        procedure accepted_compound_is_not_learned_across_shapes_case_2;
        procedure accepted_compound_is_not_learned_across_shapes_case_3;
        procedure accepted_compound_is_not_learned_across_shapes_case_4;

    end;

implementation

const
    c_try = #$8BD5#$8BD5;
    c_realtime = #$5B9E#$65F6;
    c_agent = #$65BD#$4E8B#$8005;
    c_this = #$8FD9#$4E2A;
    c_after = #$540E;
    c_wait = #$5019;
    c_two = #$4E24#$4E2A;
    c_liang = #$6881;
    c_regress = #$9000#$6B65;
    c_leg = #$817F#$90E8;
    c_le = #$4E86;

procedure TncShortCompoundEvidenceTests.sql(const statement: string);
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

procedure TncShortCompoundEvidenceTests.add_word(const pinyin, text: string;
    weight: Integer);
begin
    sql(UnicodeFormat('INSERT INTO dict_base(pinyin,text,weight) VALUES(''%s'',''%s'',%d)',
        [pinyin, text, weight]));
end;

procedure TncShortCompoundEvidenceTests.add_ngram(const text: string; score: Integer);
begin
    sql(UnicodeFormat('INSERT OR REPLACE INTO dict_base_char_lm VALUES(''%s'',%d,0)',
        [text, score]));
end;

procedure TncShortCompoundEvidenceTests.add_pair(const pinyin, head, tail: string;
    weight: Integer);
begin
    sql(UnicodeFormat('INSERT INTO dict_base_lm_transition VALUES(''%s'',''%s'',%d)',
        [pinyin, head + #3 + tail, weight]));
end;

procedure TncShortCompoundEvidenceTests.setup;
var dictionary: TncSqliteDictionary;
begin
    m_dir := TPath.Combine(TPath.GetTempPath,
        'cassotis_compound_evidence_' + TPath.GetRandomFileName);
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
    add_word('shi', #$662F, 1500);
    add_word('shi', #$8BD5, 1200);
    add_word('shishi', c_try, 900);
    add_word('shishi', c_realtime, 1100);
    add_word('shishizhe', c_agent, 5000);
    add_word('zhe', #$8FD9, 900);
    add_word('ge', #$4E2A, 900);
    add_word('zhege', c_this, 1000);
    add_word('hou', c_after, 700);
    add_word('hou', c_wait, 600);
    add_word('houliang', c_after + c_liang, 1000);
    add_word('liang', #$4E24, 800);
    add_word('liangge', c_two, 1100);
    add_word('tui', #$9000, 600);
    add_word('tui', #$817F, 500);
    add_word('bu', #$6B65, 500);
    add_word('bu', #$90E8, 500);
    add_word('tuibu', c_regress, 250);
    add_word('tuibu', c_leg, 600);
    add_word('le', c_le, 900);
    add_ngram(c_after, -6000);
    add_ngram(c_wait, -8000);
    add_ngram(#$4E24, -7000);
    add_ngram(#$4E2A, -4000);
    add_ngram(c_liang, -10000);
    add_ngram(c_after + #$4E24, -6000);
    add_ngram(c_wait + #$4E24, -9000);
    add_ngram(c_two, -1300);
    add_ngram(c_after + c_two, -1000);
    add_ngram(#$9000, -8500);
    add_ngram(#$817F, -9000);
    add_ngram(#$6B65, -7000);
    add_ngram(#$90E8, -6500);
    add_ngram(c_le, -3000);
    add_ngram(c_regress, -4000);
    add_ngram(c_leg, -3600);
    add_ngram(#$6B65 + c_le, -2000);
    add_ngram(#$90E8 + c_le, -8000);
end;

procedure TncShortCompoundEvidenceTests.teardown;
var resolved: string;
begin
    FreeAndNil(m_engine);
    resolved := TPath.GetFullPath(m_dir);
    Assert.IsTrue(UnicodeSameText(ExtractFilePath(resolved),
        IncludeTrailingPathDelimiter(TPath.GetFullPath(TPath.GetTempPath))));
    Assert.IsTrue(Pos('cassotis_compound_evidence_', ExtractFileName(resolved)) = 1);
    if TDirectory.Exists(resolved) then TDirectory.Delete(resolved, True);
end;

procedure TncShortCompoundEvidenceTests.start;
var dictionary: TncSqliteDictionary;
begin
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    m_engine := TncEngine.Create(nc_default_engine_config, False, False, False, dictionary);
end;

procedure TncShortCompoundEvidenceTests.feed(const query: string; incremental: Boolean);
var ch: Char; state: TncKeyState;
begin
    state := Default(TncKeyState);
    for ch in query do
    begin
        if ch = '''' then m_engine.process_key(VK_OEM_7, state)
        else m_engine.process_key(Ord(UpCase(ch)), state);
        if incremental then
        begin
            m_engine.get_candidates;
            m_engine.get_display_text;
            m_engine.get_one_key_completion;
        end;
    end;
end;

function TncShortCompoundEvidenceTests.collect: string;
var item: TncCandidate; key: string;
begin
    Result := '';
    while m_engine.prev_page do begin end;
    repeat
        for item in m_engine.get_candidates do
        begin
            key := item.text + '/' + item.comment + #10;
            Assert.IsTrue(Pos(key, Result) = 0, 'Duplicate ' + key);
            Result := Result + key;
        end;
    until not m_engine.next_page;
    while m_engine.prev_page do begin end;
end;

procedure TncShortCompoundEvidenceTests.assert_first(const text: string);
var items: TncCandidateList;
begin
    items := m_engine.get_candidates;
    Assert.IsTrue(Length(items) > 0);
    Assert.AreEqual(text, items[0].text, m_engine.get_composition_text + ' ' +
        m_engine.get_lookup_debug_info);
    Assert.AreEqual('', items[0].comment);
end;

procedure TncShortCompoundEvidenceTests.supported_two_plus_two_beats_three_char_shortcut;
begin
    add_pair('shishizhege', c_try, c_this, 436);
    start;
    feed('shishizhege');
    assert_first(c_try + c_this);
    Assert.AreEqual(Ord(cdk_lm_compound), Ord(m_engine.get_candidates[0].display_kind));
    Assert.IsTrue(Pos(c_agent + '/ge' + #10, collect) > 0);
end;

procedure TncShortCompoundEvidenceTests.unsupported_two_plus_two_is_not_invented;
begin
    add_pair('shishizhege', c_try, c_this, 200);
    start;
    feed('shishizhege');
    Assert.IsTrue(Pos(c_try + c_this + '/' + #10, collect) = 0);
end;

procedure TncShortCompoundEvidenceTests.pair_result_is_stable_after_backspace_and_paging;
var expected: string; state: TncKeyState; query: string; page_size: Integer;
    config: TncEngineConfig;
begin
    add_pair('shishizhege', c_try, c_this, 436);
    start;
    state := Default(TncKeyState);
    for query in ['shishizhege', 'houliangge', 'tuibule'] do
        for page_size in [3, 9] do
        begin
            m_engine.reset;
            config := m_engine.config;
            config.candidate_page_size := page_size;
            m_engine.update_config(config);
            feed(query, False);
            expected := collect;
            m_engine.reset;
            feed(query);
            Assert.AreEqual(expected, collect, query);
            m_engine.process_key(VK_BACK, state);
            m_engine.get_candidates;
            feed(Copy(query, Length(query), 1));
            Assert.AreEqual(expected, collect, query + ' backspace');
        end;
end;

procedure TncShortCompoundEvidenceTests.pair_keeps_selectable_prefixes_and_tail;
var state: TncKeyState; items: TncCandidateList; idx: Integer; found: Boolean;
begin
    add_pair('shishizhege', c_try, c_this, 436);
    start;
    feed('shishizhege');
    Assert.IsTrue(Pos(c_try + '/zhege' + #10, collect) > 0);
    Assert.IsTrue(Pos(#$662F + '/shizhege' + #10, collect) > 0);
    state := Default(TncKeyState);
    found := False;
    repeat
        items := m_engine.get_candidates;
        for idx := 0 to High(items) do
            if (items[idx].text = c_try) and (items[idx].comment = 'zhege') then
            begin
                m_engine.process_key(Ord('1') + idx, state);
                found := True;
                Break;
            end;
        if found then Break;
    until not m_engine.next_page;
    Assert.IsTrue(found);
    Assert.AreEqual('zhege', m_engine.get_composition_text);
    assert_first(c_this);
end;

procedure TncShortCompoundEvidenceTests.word_transition_survives_particle_fast_path;
begin
    sql('DELETE FROM dict_base_char_lm');
    add_pair('tuibule', c_regress, c_le, 436);
    start;
    feed('tuibule');
    assert_first(c_regress + c_le);
end;

procedure TncShortCompoundEvidenceTests.word_transition_survives_one_plus_two_fast_path;
begin
    sql('DELETE FROM dict_base_char_lm');
    add_pair('houliangge', c_after, c_two, 436);
    start;
    feed('houliangge');
    assert_first(c_after + c_two);
end;

procedure TncShortCompoundEvidenceTests.attested_trigram_admits_one_plus_two;
begin
    start;
    feed('houliangge');
    assert_first(c_after + c_two);
    Assert.AreEqual(Ord(cdk_lm_compound), Ord(m_engine.get_candidates[0].display_kind));
end;

procedure TncShortCompoundEvidenceTests.attested_particle_boundary_beats_head_weight;
begin
    start;
    feed('tuibule');
    assert_first(c_regress + c_le);
    Assert.IsTrue(Pos(c_leg + '/le' + #10, collect) > 0);
end;

procedure TncShortCompoundEvidenceTests.missing_trigram_does_not_use_backoff_as_evidence;
begin
    sql('DELETE FROM dict_base_char_lm WHERE length(ngram)=3');
    start;
    feed('houliangge');
    Assert.IsTrue(Pos(c_after + c_two + '/' + #10, collect) = 0);
end;

procedure TncShortCompoundEvidenceTests.conflicting_context_blocks_char_pair_promotion;
const c_context = #$7532;
begin
    add_ngram(c_context + c_after, -12000);
    add_ngram(c_context + c_after + #$4E24, -12000);
    add_ngram(c_context + c_wait, -1000);
    add_ngram(c_context + c_wait + #$4E24, -1000);
    start;
    m_engine.set_external_left_context(c_context);
    feed('houliangge');
    Assert.IsTrue(Pos(c_after + c_two + '/' + #10, collect) = 0);
end;

procedure TncShortCompoundEvidenceTests.agreeing_context_keeps_char_pair;
const c_context = #$7532;
begin
    add_ngram(c_context + c_after, -1000);
    add_ngram(c_context + c_after + #$4E24, -1000);
    add_ngram(c_context + c_wait, -12000);
    add_ngram(c_context + c_wait + #$4E24, -12000);
    start;
    m_engine.set_external_left_context(c_context);
    feed('houliangge');
    assert_first(c_after + c_two);
end;

procedure TncShortCompoundEvidenceTests.tied_char_paths_abstain;
begin
    add_ngram(c_wait, -6000);
    add_ngram(c_wait + #$4E24, -6000);
    add_ngram(c_wait + c_two, -1000);
    start;
    feed('houliangge');
    Assert.IsTrue(Pos(c_after + c_two + '/' + #10, collect) = 0);
    Assert.IsTrue(Pos(c_wait + c_two + '/' + #10, collect) = 0);
end;

procedure TncShortCompoundEvidenceTests.low_weight_component_does_not_generate;
begin
    sql('UPDATE dict_base SET weight=1 WHERE pinyin=''hou''');
    start;
    feed('houliangge');
    Assert.IsTrue(Pos(c_after + c_two + '/' + #10, collect) = 0);
end;

procedure TncShortCompoundEvidenceTests.full_exact_is_not_displaced_by_char_pair;
begin
    add_word('houliangge', c_wait + c_two, 100);
    start;
    feed('houliangge');
    assert_first(c_wait + c_two);
end;

procedure TncShortCompoundEvidenceTests.user_exact_is_not_displaced_by_pair;
var dictionary: TncSqliteDictionary;
begin
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dictionary.open);
        dictionary.record_commit('houliangge', c_wait + c_two, True);
    finally
        dictionary.Free;
    end;
    start;
    feed('houliangge');
    assert_first(c_wait + c_two);
end;

procedure TncShortCompoundEvidenceTests.explicit_boundary_does_not_enable_char_fallback;
begin
    start;
    feed('hou''liangge');
    Assert.IsTrue(Pos(c_after + c_two + '/' + #10, collect) = 0);
end;

procedure TncShortCompoundEvidenceTests.char_pair_is_not_learned_as_user_word;
var state: TncKeyState; committed: string; dictionary: TncSqliteDictionary;
begin
    start;
    feed('houliangge');
    assert_first(c_after + c_two);
    state := Default(TncKeyState);
    m_engine.process_key(VK_SPACE, state);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(c_after + c_two, committed);
    FreeAndNil(m_engine);
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dictionary.open);
        Assert.IsFalse(dictionary.is_user_entry('houliangge', committed));
    finally
        dictionary.Free;
    end;
end;

procedure TncShortCompoundEvidenceTests.attested_api_distinguishes_missing_and_duplicate_entries;
var dictionary: TncSqliteDictionary; scores: TArray<Integer>;
begin
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), '', False);
    try
        Assert.IsTrue(dictionary.get_char_lm_attested_scores(
            TArray<string>.Create(c_after + c_two, c_regress + c_le,
            c_after + c_two, ''), scores));
        Assert.AreEqual(4, Length(scores));
        Assert.AreEqual(-1000, scores[0]);
        Assert.AreEqual(Low(Integer), scores[1]);
        Assert.AreEqual(scores[0], scores[2]);
        Assert.AreEqual(Low(Integer), scores[3]);
        Assert.IsFalse(dictionary.get_char_lm_attested_scores(
            TArray<string>.Create(c_regress + c_le), scores));
        Assert.AreEqual(Low(Integer), scores[0]);
    finally
        dictionary.Free;
    end;
end;

procedure TncShortCompoundEvidenceTests.deferred_models_do_not_force_char_loading;
var dictionary: TncSqliteDictionary; scores: TArray<Integer>;
begin
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), '', False);
    try
        Assert.IsTrue(dictionary.open_deferred);
        Assert.IsFalse(dictionary.get_char_lm_attested_scores(
            TArray<string>.Create(c_after + c_two), scores));
        Assert.AreEqual(Low(Integer), scores[0]);
        Assert.IsTrue(dictionary.open);
        Assert.IsTrue(dictionary.get_char_lm_attested_scores(
            TArray<string>.Create(c_after + c_two), scores));
        Assert.AreEqual(-1000, scores[0]);
    finally
        dictionary.Free;
    end;
end;

procedure TncShortCompoundEvidenceTests.missing_char_table_keeps_word_transition_fallback;
begin
    sql('DROP TABLE dict_base_char_lm');
    add_pair('houliangge', c_after, c_two, 436);
    start;
    feed('houliangge');
    assert_first(c_after + c_two);
end;

procedure TncShortCompoundEvidenceTests.seed_shape(head_units, tail_units,
    family, prefix_weight, evidence_weight: Integer;
    out query, head, tail, tail_query: string);
const
    keys: array[0..2, 0..3] of string = (
        ('lan', 'tian', 'bai', 'yun'),
        ('qing', 'shan', 'liu', 'shui'),
        ('hong', 'hua', 'lv', 'ye'));
    texts: array[0..2] of string = (
        #$84DD#$5929#$767D#$4E91, #$9752#$5C71#$6D41#$6C34,
        #$7EA2#$82B1#$7EFF#$53F6);
    homophones: array[0..2] of string = (#$5170, #$6E05, #$6D2A);
var idx, units: Integer; head_query, prefix_query: string;
begin
    units := head_units + tail_units;
    query := '';
    tail_query := '';
    head_query := '';
    prefix_query := '';
    for idx := 0 to units - 1 do
    begin
        add_word(keys[family, idx], Copy(texts[family], idx + 1, 1), 600);
        query := query + keys[family, idx];
        if idx < head_units then head_query := head_query + keys[family, idx]
        else tail_query := tail_query + keys[family, idx];
        if idx < units - 1 then prefix_query := prefix_query + keys[family, idx];
    end;
    head := Copy(texts[family], 1, head_units);
    tail := Copy(texts[family], head_units + 1, tail_units);
    if head_units > 1 then add_word(head_query, head, 700);
    if tail_units > 1 then add_word(tail_query, tail, 700);
    add_word(prefix_query, homophones[family] +
        Copy(texts[family], 2, units - 2), prefix_weight);
    add_pair(query, head, tail, evidence_weight);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix(
    head_units, tail_units, prefix_weight: Integer);
var
    family, page_size, idx: Integer;
    query, head, tail, tail_query, expected: string;
    config: TncEngineConfig;
    state: TncKeyState;
    items: TncCandidateList;
    selected: Boolean;
begin
    state := Default(TncKeyState);
    for family := 0 to 2 do
    begin
        seed_shape(head_units, tail_units, family, prefix_weight, 436,
            query, head, tail, tail_query);
        start;
        for page_size in [3, 9] do
        begin
            m_engine.reset;
            config := m_engine.config;
            config.debug_mode := True;
            config.candidate_page_size := page_size;
            m_engine.update_config(config);
            feed(query, False);
            assert_first(head + tail);
            Assert.AreEqual(Ord(cdk_lm_compound),
                Ord(m_engine.get_candidates[0].display_kind), query + ' provenance');
            expected := collect;
            Assert.IsTrue(Pos('short-evidence-contract=',
                m_engine.get_lookup_debug_info) > 0, query + ' common exit');
            Assert.IsTrue(Pos(head + '/' + tail_query + #10, expected) > 0, query);
            m_engine.reset;
            config.debug_mode := False;
            m_engine.update_config(config);
            feed(query);
            assert_first(head + tail);
            Assert.AreEqual(Ord(cdk_lm_compound),
                Ord(m_engine.get_candidates[0].display_kind), query + ' incremental provenance');
            Assert.AreEqual(expected, collect, query + ' incremental');
            m_engine.process_key(VK_BACK, state);
            m_engine.get_candidates;
            feed(Copy(query, Length(query), 1));
            Assert.AreEqual(expected, collect, query + ' backspace');

            selected := False;
            repeat
                items := m_engine.get_candidates;
                for idx := 0 to High(items) do
                    if (items[idx].text = head) and (items[idx].comment = tail_query) then
                    begin
                        m_engine.process_key(Ord('1') + idx, state);
                        selected := True;
                        Break;
                    end;
                if selected then Break;
            until not m_engine.next_page;
            Assert.IsTrue(selected, query + ' selectable head');
            Assert.AreEqual(tail_query, m_engine.get_composition_text);
            assert_first(tail);
        end;
        FreeAndNil(m_engine);
    end;
end;

procedure TncShortCompoundEvidenceTests.weak_evidence_is_not_promoted_across_shapes(
    head_units, tail_units: Integer);
var query, head, tail, tail_query: string;
begin
    seed_shape(head_units, tail_units, 0, 5000, 200, query, head, tail, tail_query);
    start;
    feed(query);
    Assert.IsTrue(Pos(head + tail + '/' + #10, collect) = 0, query);
end;

procedure TncShortCompoundEvidenceTests.dictionary_exact_keeps_priority_across_shapes(
    head_units, tail_units: Integer);
var query, head, tail, tail_query, exact_text: string;
begin
    seed_shape(head_units, tail_units, 0, 5000, 436, query, head, tail, tail_query);
    exact_text := #$5170 + Copy(head + tail, 2, MaxInt);
    add_word(query, exact_text, 100);
    start;
    feed(query);
    assert_first(exact_text);
end;

procedure TncShortCompoundEvidenceTests.accepted_compound_is_not_learned_across_shapes(
    head_units, tail_units: Integer);
var query, head, tail, tail_query, committed: string; state: TncKeyState;
    dictionary: TncSqliteDictionary;
begin
    seed_shape(head_units, tail_units, 0, 5000, 436, query, head, tail, tail_query);
    start;
    feed(query);
    assert_first(head + tail);
    state := Default(TncKeyState);
    m_engine.process_key(VK_SPACE, state);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(head + tail, committed);
    FreeAndNil(m_engine);
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dictionary.open);
        Assert.IsFalse(dictionary.is_user_entry(query, committed));
    finally
        dictionary.Free;
    end;
end;

procedure TncShortCompoundEvidenceTests.user_exact_keeps_priority_across_shapes(
    head_units, tail_units: Integer);
var
    query, head, tail, tail_query, exact_text: string;
    dictionary: TncSqliteDictionary;
begin
    seed_shape(head_units, tail_units, 0, 5000, 436, query, head, tail, tail_query);
    exact_text := #$5170 + Copy(head + tail, 2, MaxInt);
    dictionary := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'),
        TPath.Combine(m_dir, 'user.db'));
    try
        Assert.IsTrue(dictionary.open);
        dictionary.record_commit(query, exact_text, True);
    finally
        dictionary.Free;
    end;
    start;
    feed(query);
    assert_first(exact_text);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix_case_1;
begin
    evidence_survives_shape_and_typing_matrix(1, 1, 300);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix_case_2;
begin
    evidence_survives_shape_and_typing_matrix(1, 1, 5000);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix_case_3;
begin
    evidence_survives_shape_and_typing_matrix(1, 2, 300);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix_case_4;
begin
    evidence_survives_shape_and_typing_matrix(1, 2, 5000);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix_case_5;
begin
    evidence_survives_shape_and_typing_matrix(2, 1, 300);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix_case_6;
begin
    evidence_survives_shape_and_typing_matrix(2, 1, 5000);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix_case_7;
begin
    evidence_survives_shape_and_typing_matrix(2, 2, 300);
end;

procedure TncShortCompoundEvidenceTests.evidence_survives_shape_and_typing_matrix_case_8;
begin
    evidence_survives_shape_and_typing_matrix(2, 2, 5000);
end;

procedure TncShortCompoundEvidenceTests.weak_evidence_is_not_promoted_across_shapes_case_1;
begin
    weak_evidence_is_not_promoted_across_shapes(1, 1);
end;

procedure TncShortCompoundEvidenceTests.weak_evidence_is_not_promoted_across_shapes_case_2;
begin
    weak_evidence_is_not_promoted_across_shapes(1, 2);
end;

procedure TncShortCompoundEvidenceTests.weak_evidence_is_not_promoted_across_shapes_case_3;
begin
    weak_evidence_is_not_promoted_across_shapes(2, 1);
end;

procedure TncShortCompoundEvidenceTests.weak_evidence_is_not_promoted_across_shapes_case_4;
begin
    weak_evidence_is_not_promoted_across_shapes(2, 2);
end;

procedure TncShortCompoundEvidenceTests.dictionary_exact_keeps_priority_across_shapes_case_1;
begin
    dictionary_exact_keeps_priority_across_shapes(1, 1);
end;

procedure TncShortCompoundEvidenceTests.dictionary_exact_keeps_priority_across_shapes_case_2;
begin
    dictionary_exact_keeps_priority_across_shapes(1, 2);
end;

procedure TncShortCompoundEvidenceTests.dictionary_exact_keeps_priority_across_shapes_case_3;
begin
    dictionary_exact_keeps_priority_across_shapes(2, 1);
end;

procedure TncShortCompoundEvidenceTests.dictionary_exact_keeps_priority_across_shapes_case_4;
begin
    dictionary_exact_keeps_priority_across_shapes(2, 2);
end;

procedure TncShortCompoundEvidenceTests.user_exact_keeps_priority_across_shapes_case_1;
begin
    user_exact_keeps_priority_across_shapes(1, 1);
end;

procedure TncShortCompoundEvidenceTests.user_exact_keeps_priority_across_shapes_case_2;
begin
    user_exact_keeps_priority_across_shapes(1, 2);
end;

procedure TncShortCompoundEvidenceTests.user_exact_keeps_priority_across_shapes_case_3;
begin
    user_exact_keeps_priority_across_shapes(2, 1);
end;

procedure TncShortCompoundEvidenceTests.user_exact_keeps_priority_across_shapes_case_4;
begin
    user_exact_keeps_priority_across_shapes(2, 2);
end;

procedure TncShortCompoundEvidenceTests.accepted_compound_is_not_learned_across_shapes_case_1;
begin
    accepted_compound_is_not_learned_across_shapes(1, 1);
end;

procedure TncShortCompoundEvidenceTests.accepted_compound_is_not_learned_across_shapes_case_2;
begin
    accepted_compound_is_not_learned_across_shapes(1, 2);
end;

procedure TncShortCompoundEvidenceTests.accepted_compound_is_not_learned_across_shapes_case_3;
begin
    accepted_compound_is_not_learned_across_shapes(2, 1);
end;

procedure TncShortCompoundEvidenceTests.accepted_compound_is_not_learned_across_shapes_case_4;
begin
    accepted_compound_is_not_learned_across_shapes(2, 2);
end;

initialization
    RegisterTest(TncShortCompoundEvidenceTests);
end.
