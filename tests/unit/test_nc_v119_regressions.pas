unit test_nc_v119_regressions;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry;

type
    TncV119RegressionTests = class(TTestCase)
    published
        procedure KeepsStrongFourSyllablePrefixWithControlledSuffix;
        procedure RejectsCompletionWithDivergentPrefixAndSharedTail;
        procedure ResolvesLongestExactTextPrefixPath;
        procedure ConditionalDecisionModelsAreDeterministic;
    end;

implementation

uses
    SysUtils,
    Math,
    nc_types,
    nc_sqlite,
    nc_dictionary_intf,
    nc_dictionary_sqlite,
    nc_engine_intf,
    nc_pinyin_conditional_fusion_model,
    nc_pinyin_conditional_runtime_gate_model;

type
    TncV119CompoundDictionary = class(TncDictionaryProvider)
    public
        function lookup(const pinyin: string;
            out results: TncCandidateList): Boolean; override;
        function get_exact_pair_path_evidence(const query_key: string;
            out results: TncPairPathEvidenceList): Boolean; override;
    end;

function TextFromCodepoints(const values: array of Word): string;
var
    index: Integer;
begin
    Result := '';
    for index := Low(values) to High(values) do
        Result := Result + WideChar(values[index]);
end;

procedure SetCandidate(out candidate: TncCandidate; const text: string;
    const score: Integer);
begin
    candidate := Default(TncCandidate);
    candidate.text := text;
    candidate.score := score;
    candidate.source := cs_rule;
    candidate.has_dict_weight := True;
    candidate.dict_weight := score;
end;

function TncV119CompoundDictionary.lookup(const pinyin: string;
    out results: TncCandidateList): Boolean;
var
    normalized_pinyin: string;
begin
    results := Default(TncCandidateList);
    normalized_pinyin := LowerCase(Trim(pinyin));
    if normalized_pinyin = 'keyi' then
    begin
        SetLength(results, 1);
        SetCandidate(results[0], TextFromCodepoints([$53EF, $4EE5]), 1200);
        Exit(True);
    end;
    if normalized_pinyin = 'qudai' then
    begin
        SetLength(results, 1);
        SetCandidate(results[0], TextFromCodepoints([$53D6, $4EE3]), 1000);
        Exit(True);
    end;
    if normalized_pinyin = 'de' then
    begin
        SetLength(results, 1);
        SetCandidate(results[0], TextFromCodepoints([$7684]), 1000);
        Exit(True);
    end;
    Result := False;
end;

function TncV119CompoundDictionary.get_exact_pair_path_evidence(
    const query_key: string; out results: TncPairPathEvidenceList): Boolean;
begin
    results := Default(TncPairPathEvidenceList);
    if LowerCase(Trim(query_key)) <> 'keyiqudai' then
        Exit(False);
    SetLength(results, 1);
    results[0].encoded_path := TextFromCodepoints([$53EF, $4EE5]) + #3 +
        TextFromCodepoints([$53D6, $4EE3]);
    results[0].query_path_weight := 0;
    results[0].lm_transition_weight := 520;
    Result := True;
end;

function BuildConfig: TncEngineConfig;
begin
    Result := Default(TncEngineConfig);
    Result.input_mode := im_chinese;
    Result.pinyin_input_scheme := pis_full_pinyin;
    Result.max_candidates := 9;
    Result.enable_segment_candidates := True;
    Result.segment_head_only_multi_syllable := True;
    Result.candidate_page_size := c_default_candidate_page_size;
    Result.candidate_page_key_scheme := cpks_minus_plus;
    Result.one_key_completion_key := ock_tab;
    Result.dictionary_variant := dv_simplified;
end;

function FeedText(const engine: TncEngine; const text: string): Boolean;
var
    index: Integer;
    key_state: TncKeyState;
begin
    Result := True;
    key_state := Default(TncKeyState);
    for index := 1 to Length(text) do
        if not engine.process_key(Ord(UpCase(text[index])), key_state) then
            Exit(False);
end;

function FindCandidate(const candidates: TncCandidateList; const text,
    comment: string): Integer;
var
    index: Integer;
begin
    Result := -1;
    for index := 0 to High(candidates) do
        if (candidates[index].text = text) and
            (candidates[index].comment = comment) then
            Exit(index);
end;

procedure TncV119RegressionTests.KeepsStrongFourSyllablePrefixWithControlledSuffix;
var
    engine: TncEngine;
    candidates: TncCandidateList;
    prefix_text: string;
    complete_text: string;
    prefix_index: Integer;
begin
    prefix_text := TextFromCodepoints([$53EF, $4EE5, $53D6, $4EE3]);
    complete_text := prefix_text + TextFromCodepoints([$7684]);
    engine := TncEngine.Create(BuildConfig);
    try
        engine.set_dictionary_provider(TncV119CompoundDictionary.Create);
        AssertTrue(FeedText(engine, 'keyiqudai'));
        candidates := engine.get_candidates;
        prefix_index := FindCandidate(candidates, prefix_text, '');
        AssertTrue('strong 2+2 prefix is missing', prefix_index >= 0);
        AssertEquals('strong 2+2 prefix has the wrong display kind',
            Ord(cdk_lm_compound), Ord(candidates[prefix_index].display_kind));

        AssertTrue(FeedText(engine, 'd'));
        candidates := engine.get_candidates;
        prefix_index := FindCandidate(candidates, prefix_text, 'd');
        AssertTrue('strong 2+2 prefix disappeared under a partial suffix',
            prefix_index >= 0);
        AssertEquals('partial suffix changed the compound display kind',
            Ord(cdk_lm_compound), Ord(candidates[prefix_index].display_kind));

        AssertTrue(FeedText(engine, 'e'));
        candidates := engine.get_candidates;
        AssertTrue('complete five-syllable candidate is missing',
            Length(candidates) > 0);
        AssertEquals('controlled suffix must preserve the coherent 2+2 path',
            complete_text, candidates[0].text);
        AssertEquals('complete candidate has the wrong display kind',
            Ord(cdk_default), Ord(candidates[0].display_kind));
        AssertEquals('complete candidate lost its exact 2+2+1 path',
            Copy(prefix_text, 1, 2) + #3 + Copy(prefix_text, 3, 2) + #3 +
            TextFromCodepoints([$7684]),
            engine.get_debug_candidate_segment_path(0));
        prefix_index := FindCandidate(candidates, prefix_text, 'de');
        AssertTrue('the strong prefix must remain selectable', prefix_index >= 0);
        AssertEquals('complete suffix changed the prefix display kind',
            Ord(cdk_lm_compound), Ord(candidates[prefix_index].display_kind));

        engine.reset;
        AssertTrue(FeedText(engine, 'keyiqudaide'));
        candidates := engine.get_candidates;
        AssertTrue('direct full input lost the complete candidate',
            Length(candidates) > 0);
        AssertEquals('direct full input changed the complete candidate',
            complete_text, candidates[0].text);
        prefix_index := FindCandidate(candidates, prefix_text, 'de');
        AssertTrue('direct full input lost the selectable compound prefix',
            prefix_index >= 0);
        AssertEquals('direct full input changed the prefix display kind',
            Ord(cdk_lm_compound), Ord(candidates[prefix_index].display_kind));
    finally
        engine.Free;
    end;
end;

procedure TncV119RegressionTests.RejectsCompletionWithDivergentPrefixAndSharedTail;
var
    base_path: string;
    user_path: string;
    connection: TncSqliteConnection;
    dictionary: TncSqliteDictionary;
    engine: TncEngine;
    statement: Psqlite3_stmt;
    candidates: TncCandidateList;
    completion: TncOneKeyCompletion;
    request: TncLongNeuralCompletionRequest;
    neural_result: TncLongNeuralCompletionResult;
    bad_prefix_text: string;
    good_prefix_text: string;
    shared_anchor_text: string;
    suffix_text: string;
    bad_text: string;
    good_text: string;
    bad_path: string;
    good_path: string;
    index: Integer;
    good_index: Integer;

    procedure DeleteDatabaseFiles(const path: string);
    begin
        if FileExists(path) then
            DeleteFile(path);
        if FileExists(path + '-wal') then
            DeleteFile(path + '-wal');
        if FileExists(path + '-shm') then
            DeleteFile(path + '-shm');
    end;

    procedure InsertBase(const pinyin_value, text_value: string;
        const weight_value: Integer);
    begin
        statement := nil;
        try
            AssertTrue(connection.Prepare(
                'INSERT INTO dict_base(pinyin, text, comment, weight) ' +
                'VALUES (?1, ?2, '''', ?3);', statement));
            AssertTrue(connection.BindText(statement, 1, pinyin_value));
            AssertTrue(connection.BindText(statement, 2, text_value));
            AssertTrue(connection.BindInt(statement, 3, weight_value));
            AssertEquals(SQLITE_DONE, connection.Step(statement));
        finally
            if statement <> nil then
                connection.Finalize(statement);
        end;
    end;

    procedure InsertQueryPath(const path_value: string;
        const weight_value: Integer);
    begin
        statement := nil;
        try
            AssertTrue(connection.Prepare(
                'INSERT INTO dict_base_query_path' +
                '(query_pinyin, path_text, weight) VALUES ' +
                '(''keyiqudaide'', ?1, ?2);', statement));
            AssertTrue(connection.BindText(statement, 1, path_value));
            AssertTrue(connection.BindInt(statement, 2, weight_value));
            AssertEquals(SQLITE_DONE, connection.Step(statement));
        finally
            if statement <> nil then
                connection.Finalize(statement);
        end;
    end;
begin
    base_path := IncludeTrailingPathDelimiter(UTF8Decode(GetTempDir(False))) +
        'cassotis-v119-divergent-base-' +
        UnicodeString(IntToStr(GetTickCount64)) + '-' +
        UnicodeString(IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2)) + '.db';
    user_path := ChangeFileExt(base_path, '.user.db');
    DeleteDatabaseFiles(base_path);
    DeleteDatabaseFiles(user_path);

    bad_prefix_text := TextFromCodepoints([$53EF, $6613, $8DA3]);
    good_prefix_text := TextFromCodepoints([$53EF, $4EE5, $53BB]);
    shared_anchor_text := TextFromCodepoints([$5446, $7684]);
    suffix_text := TextFromCodepoints([$65F6, $95F4]);
    bad_text := bad_prefix_text + shared_anchor_text;
    good_text := good_prefix_text + shared_anchor_text;
    bad_path := Copy(bad_prefix_text, 1, 1) + #3 +
        Copy(bad_prefix_text, 2, 2) + #3 + shared_anchor_text;
    good_path := Copy(good_prefix_text, 1, 2) + #3 +
        Copy(good_prefix_text, 3, 1) + #3 + shared_anchor_text;

    try
        // Create the complete schema first, then reopen this database as the
        // immutable base dictionary used by the production provider.
        dictionary := TncSqliteDictionary.Create('', base_path, False);
        try
            AssertTrue('base fixture schema creation failed', dictionary.Open);
        finally
            dictionary.Free;
        end;

        connection := TncSqliteConnection.Create(base_path);
        try
            AssertTrue(connection.Open);
            InsertBase('ke', Copy(bad_prefix_text, 1, 1), 1200);
            InsertBase('yiqu', Copy(bad_prefix_text, 2, 2), 1200);
            InsertBase('daide', shared_anchor_text, 1000);
            InsertBase('keyi', Copy(good_prefix_text, 1, 2), 1000);
            InsertBase('qu', Copy(good_prefix_text, 3, 1), 1000);
            InsertBase('shijian', suffix_text, 1000);
            InsertQueryPath(bad_path, 720);
            InsertQueryPath(good_path, 700);

            statement := nil;
            try
                AssertTrue(connection.Prepare(
                    'INSERT INTO dict_base_long_completion' +
                    '(anchor_path, suffix_pinyin, suffix_text, suffix_path, ' +
                    'evidence, source_count) VALUES ' +
                    '(?1, ''shijian'', ?2, ?2, 712, 17);', statement));
                AssertTrue(connection.BindText(statement, 1,
                    shared_anchor_text));
                AssertTrue(connection.BindText(statement, 2, suffix_text));
                AssertEquals(SQLITE_DONE, connection.Step(statement));
            finally
                if statement <> nil then
                    connection.Finalize(statement);
            end;
        finally
            connection.Free;
        end;

        dictionary := TncSqliteDictionary.Create(base_path, user_path, False);
        AssertTrue('base fixture failed to open', dictionary.Open);
        engine := TncEngine.Create(BuildConfig);
        try
            engine.set_dictionary_provider(dictionary);
            engine.debug_set_composition_text('keyiqudaide');
            candidates := engine.get_candidates;
            AssertTrue('fixture must expose competing complete paths',
                Length(candidates) >= 2);
            AssertEquals(
                'fixture requires the incoherent path to remain weak Top1',
                bad_text, candidates[0].text);

            good_index := -1;
            for index := 1 to High(candidates) do
                if candidates[index].text = good_text then
                begin
                    good_index := index;
                    Break;
                end;
            AssertTrue('coherent competing path must remain available',
                good_index >= 1);

            completion := engine.get_one_key_completion;
            AssertEquals(
                'shared exact tail must not validate divergent prefixes',
                '', completion.text);
            request := Default(TncLongNeuralCompletionRequest);
            AssertTrue(
                'phonetic repair must still receive an incorrectly decoded tail',
                engine.get_long_neural_completion_request(request));
            AssertTrue(
                'an unreliable prefix must disable ordinary text continuation',
                request.phonetic_only);
            AssertEquals('phonetic repair must retain the decoded anchor path',
                bad_path, request.top1_anchor_path);
            neural_result := Default(TncLongNeuralCompletionResult);
            neural_result.suffix_text := suffix_text;
            neural_result.suffix_pinyin_path := 'shijian';
            neural_result.suffix_path := suffix_text;
            neural_result.base_rank := 1;
            neural_result.confidence := 2.5;
            AssertFalse(
                'phonetic-only requests must reject ordinary suffix continuation',
                engine.apply_long_neural_completion(request, neural_result));
        finally
            engine.Free;
        end;
    finally
        DeleteDatabaseFiles(base_path);
        DeleteDatabaseFiles(user_path);
    end;
end;

procedure TncV119RegressionTests.ResolvesLongestExactTextPrefixPath;
var
    base_path: string;
    user_path: string;
    dictionary: TncSqliteDictionary;
    connection: TncSqliteConnection;
    statement: Psqlite3_stmt;
    resolved: TncExactTextPath;
    first_word: string;
    second_word: string;
    trailing_text: string;

    procedure DeleteDatabaseFiles(const path: string);
    begin
        if FileExists(path) then
            DeleteFile(path);
        if FileExists(path + '-wal') then
            DeleteFile(path + '-wal');
        if FileExists(path + '-shm') then
            DeleteFile(path + '-shm');
    end;

    procedure InsertBase(const pinyin_value, text_value: string;
        const weight_value: Integer);
    begin
        AssertTrue(connection.BindText(statement, 1, pinyin_value));
        AssertTrue(connection.BindText(statement, 2, text_value));
        AssertTrue(connection.BindInt(statement, 3, weight_value));
        AssertEquals(SQLITE_DONE, connection.Step(statement));
        AssertTrue(connection.Reset(statement));
        AssertTrue(connection.ClearBindings(statement));
    end;
begin
    base_path := IncludeTrailingPathDelimiter(UTF8Decode(GetTempDir(False))) +
        'cassotis-v121-exact-prefix-' +
        UnicodeString(IntToStr(GetTickCount64)) + '-' +
        UnicodeString(IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2)) + '.db';
    user_path := ChangeFileExt(base_path, '.user.db');
    DeleteDatabaseFiles(base_path);
    DeleteDatabaseFiles(user_path);
    first_word := TextFromCodepoints([$63D0, $9AD8]);
    second_word := TextFromCodepoints([$5F88, $591A]);
    trailing_text := TextFromCodepoints([$566A, $58F0]);

    try
        dictionary := TncSqliteDictionary.Create('', base_path, False);
        try
            AssertTrue('base fixture schema creation failed', dictionary.Open);
        finally
            dictionary.Free;
        end;

        connection := TncSqliteConnection.Create(base_path);
        try
            AssertTrue(connection.Open);
            statement := nil;
            try
                AssertTrue(connection.Prepare(
                    'INSERT INTO dict_base(pinyin, text, comment, weight) ' +
                    'VALUES (?1, ?2, '''', ?3);', statement));
                InsertBase('ti''gao', first_word, 800);
                InsertBase('hen''duo', second_word, 700);
            finally
                if statement <> nil then
                    connection.Finalize(statement);
            end;
        finally
            connection.Free;
        end;

        dictionary := TncSqliteDictionary.Create(base_path, user_path, False);
        try
            AssertTrue(dictionary.Open);
            AssertTrue(dictionary.resolve_exact_text_prefix(
                first_word + second_word + trailing_text, 3, 8, resolved));
            AssertEquals(first_word + second_word, resolved.text);
            AssertEquals('tigaohenduo', resolved.full_pinyin);
            AssertEquals(first_word + #3 + second_word, resolved.path_text);
            AssertEquals(2, resolved.segment_count);
            AssertEquals(4, resolved.unit_count);
        finally
            dictionary.Free;
        end;
    finally
        DeleteDatabaseFiles(base_path);
        DeleteDatabaseFiles(user_path);
    end;
end;

procedure TncV119RegressionTests.ConditionalDecisionModelsAreDeterministic;
var
    fusion_features: TncPinyinConditionalFusionFeatures;
    gate_features: TncPinyinConditionalGateFeatures;
    fusion_score: Double;
    gate_score: Double;
begin
    fusion_features := Default(TncPinyinConditionalFusionFeatures);
    gate_features := Default(TncPinyinConditionalGateFeatures);
    fusion_features[0] := 1.0;
    fusion_features[5] := -0.5;
    gate_features[0] := 1.0;
    gate_features[42] := -0.5;

    fusion_score := nc_pinyin_conditional_fusion_score(fusion_features);
    gate_score := nc_pinyin_conditional_gate_score(gate_features);
    AssertFalse('conditional fusion score is NaN or infinite',
        IsNan(fusion_score) or IsInfinite(fusion_score));
    AssertFalse('conditional gate score is NaN or infinite',
        IsNan(gate_score) or IsInfinite(gate_score));
    AssertEquals('conditional fusion model is not deterministic', fusion_score,
        nc_pinyin_conditional_fusion_score(fusion_features), 0.0);
    AssertEquals('conditional gate model is not deterministic', gate_score,
        nc_pinyin_conditional_gate_score(gate_features), 0.0);
end;

initialization
    RegisterTest(TncV119RegressionTests);

end.
