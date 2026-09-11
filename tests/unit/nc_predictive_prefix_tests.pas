unit nc_predictive_prefix_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Classes, nc_port_test_support, Generics.Collections,
    nc_platform_compat, fpcunit, testregistry, nc_types, nc_config, nc_sqlite,
    nc_dictionary_sqlite, nc_engine_intf, nc_prefix_completion_policy;

type
    TncPredictivePrefixTests = class(TTestCase)
    private
        m_dir: string;
        m_dict: TncSqliteDictionary;
        m_engine: TncEngine;
        procedure reopen(const page_size: Integer = 9);
        procedure feed(const query: string);
        function collect: TncCandidateList;
        function find(const text, tail: string): Integer;
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure cold_names_do_not_fill_short_query_pages;
        procedure complete_cold_name_exact_is_not_filtered;
        procedure user_exact_is_never_a_prediction;
        procedure exact_text_anchor_survives_without_corpus;
        procedure bounded_probe_ranks_evidence_before_limit;
        procedure prefix_budget_does_not_depend_on_page_size;
        procedure backspace_and_repeated_reads_are_stable;
        procedure selecting_prefix_preserves_remaining_input;
        procedure selecting_prediction_does_not_learn;
        procedure document_counts_alone_are_not_usage_evidence;
        procedure multi_source_path_evidence_can_admit_extension;
        procedure vertical_weight_alone_cannot_admit_extension;
        procedure prior_free_dictionary_uses_bounded_legacy_fallback;
        procedure evidence_cache_returns_independent_arrays;
        procedure alternate_syllable_split_exact_is_not_a_prediction;
        procedure letter_completion_of_common_word_is_not_extra_word_prediction;
    end;

implementation

const
    c_exact = #$8FD1#$4E4E;
    c_name = #$91D1#$6167#$5CFB;
    c_common = #$91D1#$9EC4#$8272;
    c_anchored = c_exact + #$540C#$6B65;
    c_user = #$91D1#$6E56;
    c_first = #$91D1;
    c_name_heads: array[0..5] of string = (#$534E, #$6000, #$6167, #$60E0, #$6C47, #$8F89);
    c_name_pinyin: array[0..5] of string = ('hua', 'huai', 'hui', 'hui', 'hui', 'hui');
    c_name_tails = #$5CFB#$4FCA#$9A8F#$519B#$541B#$94A7;

procedure TncPredictivePrefixTests.setup;
var conn: TncSqliteConnection; dict: TncSqliteDictionary;
    i, j: Integer; key, name: string;
    procedure add(const pinyin, text: string; weight, corpus, document, sources: Integer);
    begin
        Assert.IsTrue(conn.exec(UnicodeFormat(
            'INSERT INTO dict_base(pinyin,text,weight) VALUES(''%s'',''%s'',%d)',
            [pinyin, text, weight])));
        Assert.IsTrue(conn.exec(UnicodeFormat('INSERT INTO dict_base_completion_prior ' +
            '(pinyin,text,popularity_prior,corpus_score,document_score,source_count) ' +
            'VALUES(''%s'',''%s'',300,%d,%d,%d)', [pinyin, text, corpus, document, sources])));
    end;
begin
    m_dir := TPath.Combine(TPath.GetTempPath, 'cassotis_predictive_' + TPath.GetRandomFileName);
    ForceDirectories(m_dir);
    dict := TncSqliteDictionary.Create('', TPath.Combine(m_dir, 'base.db'), False);
    try Assert.IsTrue(dict.open); finally dict.Free; end;
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        add('jinhu', c_exact, 1000, 600, 0, 3);
        add('jin', c_first, 900, 600, 0, 3);
        add('jin', #$8FDB, 800, 600, 0, 3);
        add('jin', #$8FD1, 700, 600, 0, 3);
        add('hu', #$4E4E, 700, 600, 0, 3);
        add('jinhuangse', c_common, 550, 350, 0, 2);
        add('jinhutongbu', c_anchored, 250, 0, 0, 0);
        add('jiegan', #$79F8#$79C6, 160, 300, 0, 1);
        add('jiegan', #$9965#$997F#$611F, 850, 0, 0, 0);
        for i := 0 to High(c_name_heads) do
            for j := 1 to Length(c_name_tails) do
            begin
                name := c_first + c_name_heads[i] + c_name_tails[j];
                key := 'jin' + c_name_pinyin[i] + 'jun';
                add(key, name, 5000 + i * 10 + j, 0, 800, 3);
            end;
    finally conn.Free; end;
    reopen;
end;

procedure TncPredictivePrefixTests.reopen(const page_size: Integer);
var config: TncEngineConfig;
begin
    FreeAndNil(m_engine);
    config := nc_default_engine_config;
    config.candidate_page_size := page_size;
    m_dict := TncSqliteDictionary.Create(TPath.Combine(m_dir, 'base.db'), TPath.Combine(m_dir, 'user.db'));
    m_engine := TncEngine.Create(config, False, True, False, m_dict);
end;

procedure TncPredictivePrefixTests.teardown;
var resolved: string;
begin
    FreeAndNil(m_engine);
    m_dict := nil;
    resolved := TPath.GetFullPath(m_dir);
    Assert.IsTrue(UnicodeSameText(ExtractFilePath(resolved),
        IncludeTrailingPathDelimiter(TPath.GetFullPath(TPath.GetTempPath))));
    Assert.IsTrue(Pos('cassotis_predictive_', ExtractFileName(resolved)) = 1);
    if TDirectory.Exists(resolved) then TDirectory.Delete(resolved, True);
end;

procedure TncPredictivePrefixTests.feed(const query: string);
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

function TncPredictivePrefixTests.collect: TncCandidateList;
var item: TncCandidate; seen: TDictionary<string, Boolean>; key: string;
begin
    Result := nil;
    seen := TDictionary<string, Boolean>.Create;
    try
        while m_engine.prev_page do begin end;
        repeat
            for item in m_engine.get_candidates do
            begin
                key := item.text + '/' + item.comment;
                Assert.IsFalse(seen.ContainsKey(key), 'Duplicate ' + key);
                seen.Add(key, True);
                SetLength(Result, Length(Result) + 1);
                Result[High(Result)] := item;
            end;
        until not m_engine.next_page;
        while m_engine.prev_page do begin end;
    finally seen.Free; end;
end;

function TncPredictivePrefixTests.find(const text, tail: string): Integer;
var items: TncCandidateList; idx: Integer;
begin
    items := collect;
    for idx := 0 to High(items) do
        if (items[idx].text = text) and (items[idx].comment = tail) then Exit(idx);
    Result := -1;
end;

procedure TncPredictivePrefixTests.cold_names_do_not_fill_short_query_pages;
begin
    feed('jinhu');
    Assert.AreEqual(0, find(c_exact, ''));
    Assert.AreEqual(-1, find(c_name, ''));
    Assert.IsTrue(find(c_common, '') > 0);
    Assert.IsTrue((find(c_first, 'hu') > 0) and (find(c_first, 'hu') < 18));
end;

procedure TncPredictivePrefixTests.complete_cold_name_exact_is_not_filtered;
var i, j: Integer;
begin
    feed('jinhuijun');
    for i := 2 to High(c_name_heads) do
        for j := 1 to Length(c_name_tails) do
            Assert.IsTrue(find(c_first + c_name_heads[i] + c_name_tails[j], '') >= 0);
end;

procedure TncPredictivePrefixTests.user_exact_is_never_a_prediction;
var items: TncCandidateList;
begin
    Assert.IsTrue(m_dict.record_literal_user_word('jinhu', c_user));
    feed('jinhu');
    items := collect;
    Assert.AreEqual(c_user, items[0].text);
    Assert.AreEqual(Integer(cs_user), Integer(items[0].source));
    Assert.IsTrue(find(c_exact, '') > 0);
end;

procedure TncPredictivePrefixTests.exact_text_anchor_survives_without_corpus;
begin
    feed('jinhu');
    Assert.IsTrue(find(c_anchored, '') > 0);
end;

procedure TncPredictivePrefixTests.bounded_probe_ranks_evidence_before_limit;
var conn: TncSqliteConnection; idx: Integer; items: TncOneKeyCompletionList; found: Boolean;
begin
    FreeAndNil(m_engine);
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        // Many low-evidence homographs with the same valid pinyin precede the
        // supported word alphabetically. They must not exhaust the SQL probe.
        for idx := 1 to 120 do
            Assert.IsTrue(conn.exec(UnicodeFormat(
                'INSERT INTO dict_base(pinyin,text,weight) VALUES(''jinhua'',''%s'',9000)',
                [c_first + Char($4E00 + idx)])));
    finally conn.Free; end;
    reopen;
    Assert.IsTrue(m_dict.lookup_candidate_prefix_completions('jinhu', items));
    Assert.IsTrue(Length(items) <= 97, '96 predictions plus the independent full exact');
    found := False;
    for idx := 0 to High(items) do found := found or (items[idx].text = c_common);
    Assert.IsTrue(found, 'Rank evidence before applying the probe limit');
end;

procedure TncPredictivePrefixTests.prefix_budget_does_not_depend_on_page_size;
var before, after: TncCandidateList; size, idx: Integer;
begin
    feed('jinhu');
    before := collect;
    for size := 3 to 9 do
    begin
        reopen(size);
        feed('jinhu');
        after := collect;
        Assert.AreEqual(Length(before), Length(after));
        for idx := 0 to High(before) do
            Assert.AreEqual(before[idx].text + '/' + before[idx].comment,
                after[idx].text + '/' + after[idx].comment);
    end;
end;

procedure TncPredictivePrefixTests.backspace_and_repeated_reads_are_stable;
var before, after: TncCandidateList; state: TncKeyState; idx: Integer;
begin
    feed('jinhu');
    before := collect;
    feed('i');
    state := Default(TncKeyState);
    m_engine.process_key(VK_BACK, state);
    after := collect;
    Assert.AreEqual(Length(before), Length(after));
    for idx := 0 to High(before) do
        Assert.AreEqual(before[idx].text + '/' + before[idx].comment,
            after[idx].text + '/' + after[idx].comment);
    Assert.AreEqual(Length(after), Length(collect));
end;

procedure TncPredictivePrefixTests.selecting_prefix_preserves_remaining_input;
var idx: Integer; state: TncKeyState;
begin
    feed('jinhu');
    idx := find(c_first, 'hu');
    Assert.IsTrue(idx >= 0);
    while idx >= 9 do begin Assert.IsTrue(m_engine.next_page); Dec(idx, 9); end;
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
    Assert.AreEqual('hu', m_engine.get_composition_text);
end;

procedure TncPredictivePrefixTests.selecting_prediction_does_not_learn;
var idx: Integer; state: TncKeyState; committed: string;
begin
    feed('jinhu');
    idx := find(c_common, '');
    Assert.IsTrue(idx > 0);
    while idx >= 9 do begin Assert.IsTrue(m_engine.next_page); Dec(idx, 9); end;
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(Ord('1') + idx, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(c_common, committed);
    Assert.IsFalse(m_dict.is_user_entry('jinhu', c_common));
    Assert.AreEqual(0, m_dict.get_candidate_penalty('jinhu', c_exact));
end;

procedure TncPredictivePrefixTests.document_counts_alone_are_not_usage_evidence;
var item: TncOneKeyCompletion; rank: Int64;
begin
    item := Default(TncOneKeyCompletion);
    item.text := c_name; item.source := okcs_base_exact; item.has_popularity_prior := True;
    item.weight := 10000; item.popularity_prior := 800; item.document_score := 800; item.source_count := 8;
    Assert.IsFalse(nc_prefix_completion_rank(item, 2, 3, False, False, rank));
end;

procedure TncPredictivePrefixTests.multi_source_path_evidence_can_admit_extension;
var item: TncOneKeyCompletion; rank: Int64;
begin
    item := Default(TncOneKeyCompletion);
    item.text := c_common; item.source := okcs_base_exact; item.has_popularity_prior := True;
    item.weight := 400; item.path_score := 300; item.source_count := 2;
    Assert.IsTrue(nc_prefix_completion_rank(item, 2, 3, False, False, rank));
    item.source_count := 1;
    Assert.IsFalse(nc_prefix_completion_rank(item, 2, 3, False, False, rank));
end;

procedure TncPredictivePrefixTests.vertical_weight_alone_cannot_admit_extension;
var item: TncOneKeyCompletion; rank: Int64;
begin
    item := Default(TncOneKeyCompletion);
    item.text := c_common; item.source := okcs_base_exact; item.has_popularity_prior := True;
    item.weight := 10000; item.vertical_layer_kind := 3;
    Assert.IsFalse(nc_prefix_completion_rank(item, 2, 3, True, False, rank));
    item.corpus_score := 500;
    Assert.IsTrue(nc_prefix_completion_rank(item, 2, 3, True, False, rank));
end;

procedure TncPredictivePrefixTests.prior_free_dictionary_uses_bounded_legacy_fallback;
var conn: TncSqliteConnection; items: TncCandidateList; item: TncCandidate; predicted: Integer;
begin
    FreeAndNil(m_engine);
    conn := TncSqliteConnection.Create(TPath.Combine(m_dir, 'base.db'));
    try
        Assert.IsTrue(conn.open(SQLITE_OPEN_READWRITE));
        Assert.IsTrue(conn.exec('DELETE FROM dict_base_completion_prior'));
    finally conn.Free; end;
    reopen;
    feed('jinhu');
    items := collect;
    predicted := 0;
    for item in items do
        if (item.comment = '') and (item.text <> c_exact) then Inc(predicted);
    Assert.IsTrue(predicted > 0);
    Assert.IsTrue(predicted <= c_short_prefix_completion_limit);
    Assert.AreEqual(0, find(c_exact, ''));
end;

procedure TncPredictivePrefixTests.evidence_cache_returns_independent_arrays;
var first, second: TncOneKeyCompletionList; original: string;
begin
    Assert.IsTrue(m_dict.lookup_candidate_prefix_completions('jinhu', first));
    original := first[0].text;
    first[0].text := 'changed';
    Assert.IsTrue(m_dict.lookup_candidate_prefix_completions('jinhu', second));
    Assert.AreEqual(original, second[0].text);
end;

procedure TncPredictivePrefixTests.alternate_syllable_split_exact_is_not_a_prediction;
var index: Integer; state: TncKeyState; committed: string;
begin
    feed('jiegan');
    index := find(#$9965#$997F#$611F, '');
    Assert.IsTrue((index >= 0) and (index < 9),
        'Full compact exact must survive even without corpus evidence or the primary syllable split');
    state := Default(TncKeyState);
    Assert.IsTrue(m_engine.process_key(Ord('1') + index, state));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(string(#$9965#$997F#$611F), committed);
end;

procedure TncPredictivePrefixTests.letter_completion_of_common_word_is_not_extra_word_prediction;
var item: TncOneKeyCompletion; rank: Int64;
begin
    item := Default(TncOneKeyCompletion);
    item.text := #$5C31#$5F97;
    item.source := okcs_base_exact; item.has_popularity_prior := True;
    item.popularity_prior := 530; item.source_count := 4;
    Assert.IsTrue(nc_prefix_completion_rank(item, 2, 2, False, False, rank));
    Assert.IsFalse(nc_prefix_completion_rank(item, 2, 3, False, False, rank));
end;


initialization
    RegisterTest(TncPredictivePrefixTests);
end.
