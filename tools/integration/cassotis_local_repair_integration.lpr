program cassotis_local_repair_integration;
{$codepage utf8}
{$mode delphiunicode}
{$H+}
uses
    {$ifdef UNIX}cthreads, cwstring,{$endif}
    SysUtils, nc_platform_compat, nc_types, nc_config,
    nc_dictionary_intf, nc_dictionary_sqlite, nc_engine_intf,
    nc_document_context_model;

type
    TRepairDictionary = class(TncDictionaryProvider)
    public
        user_exact: Boolean;
        base_exact: Boolean;
        function lookup(const pinyin: string; out results: TncCandidateList): Boolean; override;
        function is_user_entry(const pinyin, text: string): Boolean; override;
        function is_base_entry(const pinyin, text: string): Boolean; override;
    end;
    TRepairMock = class(TInterfacedObject, IncLongNeuralReranker, IncLongLocalRepair)
    public
        calls: Integer;
        document, context: string;
        function should_generate(const query_text: string; const candidates: TncLongFinalCandidateDebugArray): Boolean;
        function try_generate(const query_text: string; out candidates: TncLongGeneratedCandidateArray): Boolean;
        function try_select(const query_text: string; const candidates: TncLongFinalCandidateDebugArray; out selected_index: Integer): Boolean;
        procedure set_document_context(const document_key, preceding_text: string);
        function try_repair(const query_text, draft_text: string;
            const document_key, preceding_text: string;
            out repaired_text, aligned_pinyin: string; out minimum_word_ratio: Double): Boolean;
    end;

function TRepairDictionary.lookup(const pinyin: string; out results: TncCandidateList): Boolean;
var text: string;
begin
    text := '';
    if pinyin = 'wo' then text := #$6211;
    if pinyin = 'men' then text := #$4EEC;
    if pinyin = 'women' then text := #$6211#$4EEC;
    if pinyin = 'jin' then text := #$4ECA;
    if pinyin = 'tian' then text := #$5929;
    if pinyin = 'jintian' then text := #$4ECA#$5929;
    if pinyin = 'fa' then text := #$53D1;
    if pinyin = 'xian' then text := #$73B0;
    if pinyin = 'faxian' then text := #$53D1#$73B0;
    if pinyin = 'hen' then text := #$5F88;
    if pinyin = 'hao' then text := #$597D;
    if pinyin = 'henhao' then text := #$5F88#$597D;
    if (user_exact or base_exact) and (pinyin = 'womenjintianfaxian') then
        text := #$6211#$4EEC#$4ECA#$5929#$53D1#$73B0;
    Result := text <> '';
    results := nil;
    if not Result then Exit;
    SetLength(results, 1);
    results[0].text := text;
    results[0].score := 1000 * Length(text);
    results[0].has_dict_weight := base_exact;
    results[0].dict_weight := 1000;
    if user_exact and (Length(text) = 6) then results[0].source := cs_user;
end;

function TRepairDictionary.is_base_entry(const pinyin, text: string): Boolean;
begin
    Result := base_exact and (pinyin = 'womenjintianfaxian') and
        (text = #$6211#$4EEC#$4ECA#$5929#$53D1#$73B0);
end;

function TRepairDictionary.is_user_entry(const pinyin, text: string): Boolean;
begin
    Result := user_exact and (pinyin = 'womenjintianfaxian') and
        (text = #$6211#$4EEC#$4ECA#$5929#$53D1#$73B0);
end;

function TRepairMock.should_generate(const query_text: string; const candidates: TncLongFinalCandidateDebugArray): Boolean;
begin Result := False; end;
function TRepairMock.try_generate(const query_text: string; out candidates: TncLongGeneratedCandidateArray): Boolean;
begin candidates := nil; Result := False; end;
function TRepairMock.try_select(const query_text: string; const candidates: TncLongFinalCandidateDebugArray; out selected_index: Integer): Boolean;
begin selected_index := 0; Result := False; end;
procedure TRepairMock.set_document_context(const document_key, preceding_text: string);
begin document := document_key; context := preceding_text; end;
function TRepairMock.try_repair(const query_text, draft_text: string;
    const document_key, preceding_text: string;
    out repaired_text, aligned_pinyin: string; out minimum_word_ratio: Double): Boolean;
begin
    Inc(calls);
    document := document_key;
    context := preceding_text;
    repaired_text := draft_text;
    aligned_pinyin := 'jiang'#3'ta'#3'de'#3'yan'#3'jiu'#3'jie'#3'guo'#3'gong'#3'zhi'#3'yu'#3'zhong';
    minimum_word_ratio := 0.01;
    if repaired_text <> '' then repaired_text[1] := #$6C5F;
    Result := repaired_text <> draft_text;
end;

procedure require(const condition: Boolean; const message: string);
begin if not condition then raise Exception.Create(UTF8Encode(message)); end;

var
    engine: TncEngine;
    dictionary: TRepairDictionary;
    sqlite: TncSqliteDictionary;
    mock: TRepairMock;
    model: IncLongNeuralReranker;
    config: TncEngineConfig;
    candidates: TncCandidateList;
    key_state: TncKeyState;
    committed, first, prefix: string;
    i, count: Integer;
begin
    try
        if ParamCount <> 1 then
            raise Exception.Create('Usage: runner frozen-dictionary.db');
        config := nc_default_engine_config;
        engine := TncEngine.create(config);
        try
            dictionary := TRepairDictionary.Create;
            engine.set_dictionary_provider(dictionary);
            mock := TRepairMock.Create;
            model := mock;
            engine.set_long_neural_reranker(model);
            prefix := UnicodeString(StringOfChar('a', 260)) + '. Previous sentence. Current sentence.';
            engine.set_external_left_context('Current sentence.', 'app/doc', prefix);
            require(Length(mock.context) = 256, 'context length');
            require(Pos('Previous sentence.', mock.context) > 0, 'cross-sentence context lost');
            engine.reset;
            require(mock.context = '', 'reset leaked document context');
            sqlite := TncSqliteDictionary.Create(ExpandFileName(ParamStr(1)), '', False);
            require(sqlite.open, 'frozen dictionary unavailable');
            engine.set_dictionary_provider(sqlite);
            engine.debug_set_search_budget_policy(sbm_deterministic, 100);
            mock.set_document_context('foreign-session/document', 'Must not leak into this engine.');
            engine.debug_set_composition_text('jiangtadeyanjiujieguogongzhiyuzhong');
            candidates := engine.get_candidates;
            require(Length(candidates) > 0, 'missing candidates');
            if mock.calls = 0 then
            begin
                WriteLn('first=', candidates[0].text, ' comment=', candidates[0].comment,
                    ' exact=', candidates[0].has_dict_weight, ' source=', Ord(candidates[0].source));
                WriteLn(engine.get_lookup_debug_info);
            end;
            require(mock.calls > 0, 'final repair callback not reached');
            require((mock.document = '') and (mock.context = ''), 'repair request used another session context');
            first := candidates[0].text;
            require(first[1] = #$6C5F, 'repair not first');
            count := mock.calls;
            candidates := engine.get_candidates;
            require(candidates[0].text = first, 'repeated display changed output');
            require(mock.calls = count, 'repeated display ran repair again');
            for i := 1 to High(candidates) do
                require(candidates[i].text <> first, 'duplicate repaired candidate');
            if engine.get_page_count > 1 then
            begin
                require(engine.next_page, 'next page failed');
                candidates := engine.get_candidates;
                require(Length(candidates) > 0, 'empty second page');
                require(engine.prev_page, 'previous page failed');
                candidates := engine.get_candidates;
                require(candidates[0].text = first, 'paging restored an uncorrected first candidate');
                require(mock.calls = count, 'paging repeated neural inference');
            end;
            key_state := Default(TncKeyState);
            engine.process_key(Ord('1'), key_state);
            require(engine.commit_text(committed), 'number confirmation did not commit');
            require(committed = first, 'display and committed text differ');
            engine.reset;
            count := mock.calls;
            engine.debug_set_composition_text('women');
            candidates := engine.get_candidates;
            require(mock.calls = count, 'short exact invoked repair');
            engine.reset;
            dictionary := TRepairDictionary.Create;
            engine.set_dictionary_provider(dictionary);
            dictionary.user_exact := True;
            count := mock.calls;
            engine.debug_set_composition_text('womenjintianfaxian');
            candidates := engine.get_candidates;
            require(mock.calls = count, 'user exact invoked repair');
            engine.reset;
            dictionary.user_exact := False;
            dictionary.base_exact := True;
            count := mock.calls;
            engine.debug_set_composition_text('womenjintianfaxian');
            candidates := engine.get_candidates;
            require(mock.calls = count, 'base exact invoked repair');
            WriteLn('local-repair integration: PASS');
        finally
            engine.Free;
            model := nil;
        end;
    except
        on error: Exception do
        begin
            WriteLn(error.ClassName, ': ', error.Message);
            ExitCode := 1;
        end;
    end;
end.
