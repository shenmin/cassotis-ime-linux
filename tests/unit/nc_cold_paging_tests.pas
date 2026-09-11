unit nc_cold_paging_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, nc_platform_compat, fpcunit, testregistry, nc_port_test_support, nc_types,
    nc_config, nc_dictionary_intf, nc_engine_intf;

type
    TncColdPagingTests = class(TTestCase)
    private
        m_engine: TncEngine;
        m_ready: TncEngine;
        procedure create_session(const page_size: Integer = 9;
            const cold_count: Integer = 30);
        procedure feed(const text: string);
        function publish: TncCandidateList;
        procedure press(const key: Word; const shift: Boolean = False);
        procedure assert_upgrade_waits;
    public
        procedure setup; override;
        procedure teardown; override;
    published
        procedure first_composition_pages_before_models_are_ready;
        procedure upgrade_cannot_reset_page_or_selection;
        procedure returning_to_first_page_still_protects_browsing;
        procedure arrow_selection_is_protected;
        procedure escape_releases_upgrade_and_retype_pages;
        procedure editing_releases_upgrade_without_cancel;
        procedure idle_first_page_can_upgrade_and_then_page;
        procedure supported_page_keys_work_in_cold_composition;
        procedure unmovable_initial_page_does_not_block_model_upgrade;
        procedure handoff_replaces_stale_first_page;
        procedure handoff_first_page_matches_new_candidate_count;
        procedure handoff_exact_word_keeps_prefix_pages;
    end;

implementation

uses nc_shortcut;

const
    c_shi = #$662F#$65F6#$5341#$4E8B#$5E02#$5E08#$8BD7#$53F2#$5F0F#$8BD5 +
        #$77F3#$5BA4#$8BC6#$4E16#$59CB#$58EB#$89C6#$4F7F#$52BF#$98DF +
        #$5B9E#$91CA#$9970#$901D#$6E7F#$793A#$9002#$5931#$6C0F#$4F3C;

type
    TncPagingDictionary = class(TncDictionaryProvider)
    private
        m_reverse: Boolean;
        m_count: Integer;
    public
        constructor Create(const reverse: Boolean; const count: Integer = 30);
        function lookup(const pinyin: string; out results: TncCandidateList): Boolean; override;
        function is_base_entry(const pinyin, text: string): Boolean; override;
    end;

constructor TncPagingDictionary.Create(const reverse: Boolean; const count: Integer);
begin
    inherited Create;
    m_reverse := reverse;
    m_count := count;
end;

function TncPagingDictionary.lookup(const pinyin: string;
    out results: TncCandidateList): Boolean;
var i, text_index: Integer;
begin
    results := nil;
    if (pinyin = 'shihao') or (pinyin = 'hao') then
    begin
        SetLength(results, 1);
        results[0] := Default(TncCandidate);
        results[0].text := #$597D;
        if pinyin = 'shihao' then results[0].text := #$793A#$597D;
        results[0].score := 2500;
        results[0].source := cs_rule;
        results[0].has_dict_weight := True;
        results[0].dict_weight := 2500;
        Exit(True);
    end;
    Result := pinyin = 'shi';
    if not Result then Exit;
    SetLength(results, m_count);
    for i := 0 to High(results) do
    begin
        text_index := i + 1;
        if m_reverse then text_index := Length(c_shi) - i;
        results[i] := Default(TncCandidate);
        results[i].text := c_shi[text_index];
        results[i].source := cs_rule;
        results[i].score := 2000 - i * 20;
        results[i].has_dict_weight := True;
        results[i].dict_weight := results[i].score;
    end;
end;

function TncPagingDictionary.is_base_entry(const pinyin, text: string): Boolean;
begin
    Result := ((pinyin = 'shi') and (Length(text) = 1) and (Pos(text, c_shi) > 0)) or
        ((pinyin = 'shihao') and (text = #$793A#$597D)) or
        ((pinyin = 'hao') and (text = #$597D));
end;

procedure TncColdPagingTests.create_session(const page_size, cold_count: Integer);
var config: TncEngineConfig; engine: TncEngine;
begin
    FreeAndNil(m_engine);
    FreeAndNil(m_ready);
    config := nc_default_engine_config;
    config.candidate_page_size := page_size;
    engine := TncEngine.Create(config, True, False, False, TncPagingDictionary.Create(False, cold_count));
    m_engine := engine;
    m_ready := TncEngine.Create(config, False, False, False, TncPagingDictionary.Create(True));
end;

procedure TncColdPagingTests.setup;
begin
    create_session;
end;

procedure TncColdPagingTests.teardown;
begin
    FreeAndNil(m_engine);
    FreeAndNil(m_ready);
end;

function TncColdPagingTests.publish: TncCandidateList;
begin
    Result := m_engine.get_candidates;
    m_engine.get_one_key_completion;
    m_engine.get_display_text;
end;

procedure TncColdPagingTests.press(const key: Word; const shift: Boolean);
var state: TncKeyState;
begin
    state := Default(TncKeyState);
    state.shift_down := shift;
    Assert.IsTrue(m_engine.should_handle_key(key, state));
    Assert.IsTrue(m_engine.process_key(key, state));
    publish;
end;

procedure TncColdPagingTests.feed(const text: string);
var ch: Char;
begin
    for ch in text do press(Ord(UpCase(ch)));
end;

procedure TncColdPagingTests.assert_upgrade_waits;
var rebuilt: Boolean; before, after: TncCandidateList;
    page, selected, i: Integer;
begin
    before := publish;
    page := m_engine.get_page_index;
    selected := m_engine.get_selected_index;
    Assert.IsFalse(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt),
        'Background model handoff must wait while the user browses this composition');
    Assert.IsFalse(rebuilt);
    Assert.IsTrue(m_engine.dictionary_models_deferred);
    after := publish;
    Assert.AreEqual(page, m_engine.get_page_index);
    Assert.AreEqual(selected, m_engine.get_selected_index);
    Assert.AreEqual(Length(before), Length(after));
    for i := 0 to High(before) do Assert.AreEqual(before[i].text, after[i].text);
end;

procedure TncColdPagingTests.first_composition_pages_before_models_are_ready;
var size, page, total: Integer;
begin
    for size := 3 to 9 do
    begin
        create_session(size);
        feed('shi');
        total := m_engine.get_page_count;
        Assert.IsTrue(total >= 4);
        for page := 1 to total - 1 do
        begin
            press(VK_OEM_PLUS);
            Assert.AreEqual(page, m_engine.get_page_index);
        end;
        press(VK_OEM_PLUS);
        Assert.AreEqual(total - 1, m_engine.get_page_index);
        for page := total - 2 downto 0 do
        begin
            press(VK_OEM_MINUS);
            Assert.AreEqual(page, m_engine.get_page_index);
        end;
    end;
end;

procedure TncColdPagingTests.upgrade_cannot_reset_page_or_selection;
var selected, committed: string; items: TncCandidateList;
begin
    feed('shi');
    press(VK_OEM_PLUS);
    assert_upgrade_waits;
    press(VK_OEM_PLUS);
    assert_upgrade_waits;
    items := publish;
    selected := items[1].text;
    press(Ord('2'));
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(selected, committed, 'Digit must commit the item visible on this page');
end;

procedure TncColdPagingTests.returning_to_first_page_still_protects_browsing;
begin
    feed('shi');
    press(VK_NEXT);
    press(VK_PRIOR);
    Assert.AreEqual(0, m_engine.get_page_index);
    assert_upgrade_waits;
end;

procedure TncColdPagingTests.arrow_selection_is_protected;
var items: TncCandidateList; selected, committed: string;
begin
    feed('shi');
    press(VK_DOWN);
    assert_upgrade_waits;
    items := publish;
    selected := items[m_engine.get_selected_index].text;
    press(VK_SPACE);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(selected, committed);
end;

procedure TncColdPagingTests.escape_releases_upgrade_and_retype_pages;
var rebuilt: Boolean;
begin
    feed('shi');
    press(VK_NEXT);
    assert_upgrade_waits;
    press(VK_ESCAPE);
    Assert.IsTrue(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt));
    Assert.IsFalse(rebuilt);
    feed('shi');
    press(VK_NEXT);
    Assert.AreEqual(1, m_engine.get_page_index);
    Assert.IsFalse(m_engine.dictionary_models_deferred);
end;

procedure TncColdPagingTests.editing_releases_upgrade_without_cancel;
var rebuilt: Boolean;
begin
    feed('shi');
    press(VK_NEXT);
    assert_upgrade_waits;
    press(VK_BACK);
    feed('i');
    Assert.IsTrue(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt));
    Assert.IsTrue(rebuilt);
    Assert.AreEqual('shi', m_engine.get_composition_text);
    press(VK_NEXT);
    Assert.AreEqual(1, m_engine.get_page_index);
end;

procedure TncColdPagingTests.idle_first_page_can_upgrade_and_then_page;
var rebuilt: Boolean; after: TncCandidateList;
begin
    feed('shi');
    Assert.IsTrue(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt));
    Assert.IsTrue(rebuilt);
    after := publish;
    Assert.IsTrue(Length(after) > 0);
    Assert.AreEqual('shi', m_engine.get_composition_text);
    Assert.IsFalse(m_engine.dictionary_models_deferred);
    press(VK_NEXT);
    Assert.AreEqual(1, m_engine.get_page_index);
    Assert.IsFalse(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt),
        'A consumed standby provider must never be adopted again');
end;

procedure TncColdPagingTests.supported_page_keys_work_in_cold_composition;
var config: TncEngineConfig; scheme: TncCandidatePageKeyScheme;
    previous_key, next_key: Word; previous_shift: Boolean;
begin
    for scheme := Low(TncCandidatePageKeyScheme) to High(TncCandidatePageKeyScheme) do
    begin
        create_session;
        config := m_engine.config;
        config.one_key_completion_key := ock_backtick;
        config.candidate_page_key_scheme := scheme;
        m_engine.update_config(config);
        case scheme of
            cpks_minus_plus: begin previous_key := VK_OEM_MINUS; next_key := VK_OEM_PLUS; end;
            cpks_brackets: begin previous_key := VK_OEM_4; next_key := VK_OEM_6; end;
            cpks_comma_period: begin previous_key := VK_OEM_COMMA; next_key := VK_OEM_PERIOD; end;
        else
            previous_key := VK_TAB; next_key := VK_TAB;
        end;
        previous_shift := previous_key = VK_TAB;
        feed('shi');
        press(next_key);
        Assert.AreEqual(1, m_engine.get_page_index);
        press(previous_key, previous_shift);
        Assert.AreEqual(0, m_engine.get_page_index);
    end;
end;

procedure TncColdPagingTests.unmovable_initial_page_does_not_block_model_upgrade;
const keys: array[0..7] of Word = (VK_PRIOR, VK_NEXT, VK_LEFT, VK_RIGHT,
    VK_UP, VK_DOWN, VK_OEM_MINUS, VK_OEM_PLUS);
var key: Word; rebuilt: Boolean;
begin
    for key in keys do
    begin
        create_session(9, 1);
        feed('shi');
        Assert.AreEqual(1, m_engine.get_page_count);
        press(key);
        Assert.IsTrue(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt),
            'An unsuccessful page/selection request must not lock an incomplete cold pool');
        Assert.IsTrue(rebuilt);
        publish;
        Assert.IsTrue(m_engine.get_page_count > 1);
        press(VK_NEXT);
        Assert.AreEqual(1, m_engine.get_page_index);
    end;
end;

procedure TncColdPagingTests.handoff_replaces_stale_first_page;
var rebuilt: Boolean; expected, actual: TncCandidateList;
    state: TncKeyState; ch: Char; idx: Integer;
begin
    feed('shi');
    state := Default(TncKeyState);
    for ch in 'shi' do m_ready.process_key(Ord(UpCase(ch)), state);
    expected := m_ready.get_candidates;
    Assert.IsTrue(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt));
    Assert.IsTrue(rebuilt);
    actual := publish;
    Assert.AreEqual(Length(expected), Length(actual));
    for idx := 0 to High(expected) do
        Assert.AreEqual(expected[idx].text, actual[idx].text,
            'The unchanged pinyin must not reuse the deferred first-page snapshot');
end;

procedure TncColdPagingTests.handoff_first_page_matches_new_candidate_count;
var rebuilt: Boolean; expected, actual: TncCandidateList; committed: string;
    state: TncKeyState; ch: Char; idx: Integer;
begin
    feed('shi');
    FreeAndNil(m_ready);
    m_ready := TncEngine.Create(nc_default_engine_config, False, False, False, TncPagingDictionary.Create(True, 1));
    state := Default(TncKeyState);
    for ch in 'shi' do m_ready.process_key(Ord(UpCase(ch)), state);
    expected := m_ready.get_candidates;
    Assert.IsTrue(Length(expected) < 9);
    Assert.IsTrue(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt));
    actual := publish;
    Assert.AreEqual(1, m_engine.get_page_count);
    Assert.AreEqual(Length(expected), Length(actual),
        'Visible items and page count must describe the same regenerated candidates');
    for idx := 0 to High(expected) do
        Assert.AreEqual(expected[idx].text, actual[idx].text);
    press(VK_SPACE);
    Assert.IsTrue(m_engine.commit_text(committed));
    Assert.AreEqual(actual[0].text, committed);
end;

procedure TncColdPagingTests.handoff_exact_word_keeps_prefix_pages;
var rebuilt: Boolean; items: TncCandidateList; expected, tail: string;
    size, pages: Integer;
begin
    for size := 3 to 9 do
    begin
        create_session(size);
        feed('shihao');
        Assert.IsTrue(m_engine.get_page_count > 1);
        Assert.IsTrue(m_engine.try_upgrade_dictionary_from(m_ready, rebuilt));
        publish;
        pages := m_engine.get_page_count;
        Assert.IsTrue(pages > 1,
            'An exact head must not leave a cached first page with a one-page raw pool');
        press(VK_OEM_PLUS);
        Assert.AreEqual(1, m_engine.get_page_index);
        items := publish;
        expected := items[0].text;
        press(VK_OEM_MINUS);
        Assert.AreEqual(0, m_engine.get_page_index);
        press(VK_OEM_PLUS);
        items := publish;
        Assert.AreEqual(expected, items[0].text);
        Assert.AreEqual(pages, m_engine.get_page_count);
        tail := items[0].comment;
        Assert.AreEqual('hao', tail);
        press(Ord('1'));
        Assert.AreEqual(tail, m_engine.get_composition_text,
            'Selecting the displayed prefix must consume exactly that prefix');
    end;
end;


initialization
    RegisterTest(TncColdPagingTests);
end.
