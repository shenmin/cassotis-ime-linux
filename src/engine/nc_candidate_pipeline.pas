unit nc_candidate_pipeline;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_types,
    nc_dictionary_reader,
    nc_user_dictionary,
    nc_pinyin_parser,
    nc_fuzzy_pinyin;

type
    TncCandidatePipeline = class
    private
        FDictionary: TncDictionaryReader;
        FUserDictionary: TncUserDictionary;
        FParser: TncPinyinParser;
        FErrorMessage: string;
    public
        constructor Create(const dictionary: TncDictionaryReader;
            const parser: TncPinyinParser;
            const user_dictionary: TncUserDictionary = nil);
        function Build(const raw_composition: string;
            const compact_query: string;
            const fuzzy_pinyin_enabled: Boolean;
            const fuzzy_pinyin_rules: TncFuzzyPinyinRules;
            out candidates: TncCandidateList): Boolean;
        property ErrorMessage: string read FErrorMessage;
    end;

implementation

uses
    SysUtils;

const
    c_maximum_candidates = 54;
    c_query_limit = 72;
    c_segment_query_limit = 5;
    c_path_beam_width = 12;
    c_maximum_segment_syllables = 6;
    c_mixed_jianpin_query_limit = c_query_limit * 4;
    c_char_lm_minimum_syllables = 6;
    c_char_lm_score_multiplier = 2;
    c_char_lm_path_score_multiplier = 5;
    c_char_lm_minimum_advantage = 1300;
    c_char_lm_high_confidence_score = -3000;
    c_char_lm_high_confidence_advantage = 800;

    c_tier_fixed_single = 1000;
    c_tier_exact = 600;
    c_tier_alias = 590;
    c_tier_fuzzy_exact = 575;
    c_tier_direct_path = 500;
    c_tier_jianpin = 450;
    c_tier_prefix = 400;
    c_tier_mixed_jianpin = 390;
    c_tier_mixed_initial = 360;
    c_tier_segmented_path = 350;
    c_tier_user_word = 700;
    c_tier_user_preference = 760;
    c_tier_latest_choice = 800;
    c_fuzzy_penalty_per_cost = 480;

type
    TncRankedCandidate = record
        candidate: TncCandidate;
        tier: Integer;
        ranking_score: Integer;
        sequence: Integer;
    end;
    TncRankedCandidateList = array of TncRankedCandidate;

    TncPathState = record
        text: string;
        score: Integer;
        segment_count: Integer;
    end;
    TncPathStateList = array of TncPathState;
    TncPathStateMatrix = array of TncPathStateList;

    TncMixedPinyinUnit = record
        text: string;
        abbreviated: Boolean;
    end;
    TncMixedPinyinUnits = array of TncMixedPinyinUnit;

function nc_bounded_weight(const value: Integer): Integer;
begin
    if value < -50000 then
        Exit(-50000);
    if value > 50000 then
        Exit(50000);
    Result := value;
end;

function nc_compare_ranked(const left_value: TncRankedCandidate;
    const right_value: TncRankedCandidate): Integer;
begin
    if left_value.tier <> right_value.tier then
        Exit(right_value.tier - left_value.tier);
    if left_value.ranking_score <> right_value.ranking_score then
        Exit(right_value.ranking_score - left_value.ranking_score);
    if left_value.sequence <> right_value.sequence then
        Exit(left_value.sequence - right_value.sequence);
    if left_value.candidate.text < right_value.candidate.text then
        Exit(-1);
    if left_value.candidate.text > right_value.candidate.text then
        Exit(1);
    Result := 0;
end;

procedure nc_sort_ranked(var values: TncRankedCandidateList);
var
    index: Integer;
    scan_index: Integer;
    current_value: TncRankedCandidate;
begin
    for index := 1 to High(values) do
    begin
        current_value := values[index];
        scan_index := index - 1;
        while (scan_index >= 0) and
            (nc_compare_ranked(current_value, values[scan_index]) < 0) do
        begin
            values[scan_index + 1] := values[scan_index];
            Dec(scan_index);
        end;
        values[scan_index + 1] := current_value;
    end;
end;

procedure nc_add_ranked_candidate(var values: TncRankedCandidateList;
    const entry: TncRawDictionaryEntry; const tier: Integer;
    const ranking_score: Integer; const display_kind: TncCandidateDisplayKind;
    var sequence: Integer);
var
    index: Integer;
    item: TncRankedCandidate;
begin
    if Trim(entry.text) = '' then
        Exit;

    item.candidate.text := entry.text;
    item.candidate.comment := entry.comment;
    item.candidate.score := ranking_score;
    item.candidate.source := cs_rule;
    item.candidate.has_dict_weight := True;
    item.candidate.dict_weight := entry.weight;
    item.candidate.fuzzy_cost := 0;
    item.candidate.fuzzy_rules := [];
    item.candidate.display_kind := display_kind;
    item.candidate.deletable := False;
    item.tier := tier;
    item.ranking_score := ranking_score;
    item.sequence := sequence;
    Inc(sequence);

    for index := 0 to High(values) do
    begin
        if values[index].candidate.text <> item.candidate.text then
            Continue;
        if nc_compare_ranked(item, values[index]) < 0 then
            values[index] := item;
        Exit;
    end;
    SetLength(values, Length(values) + 1);
    values[High(values)] := item;
end;

procedure nc_add_entries(var values: TncRankedCandidateList;
    const entries: TncRawDictionaryEntries; const tier: Integer;
    const display_kind: TncCandidateDisplayKind; var sequence: Integer);
var
    index: Integer;
begin
    for index := 0 to High(entries) do
        nc_add_ranked_candidate(values, entries[index], tier,
            nc_bounded_weight(entries[index].weight), display_kind, sequence);
end;

procedure nc_add_fuzzy_entries(var values: TncRankedCandidateList;
    const entries: TncRawDictionaryEntries;
    const fuzzy_cost: Integer;
    const fuzzy_rules: TncFuzzyPinyinRules;
    var sequence: Integer);
var
    index: Integer;
    item: TncRankedCandidate;
    existing_index: Integer;
begin
    for index := 0 to High(entries) do
    begin
        if Trim(entries[index].text) = '' then
            Continue;
        item.candidate.text := entries[index].text;
        item.candidate.comment := entries[index].comment;
        item.ranking_score := nc_bounded_weight(entries[index].weight -
            fuzzy_cost * c_fuzzy_penalty_per_cost);
        item.candidate.score := item.ranking_score;
        item.candidate.source := cs_rule;
        item.candidate.has_dict_weight := True;
        item.candidate.dict_weight := entries[index].weight;
        item.candidate.fuzzy_cost := fuzzy_cost;
        item.candidate.fuzzy_rules := fuzzy_rules;
        item.candidate.display_kind := cdk_default;
        item.candidate.deletable := False;
        item.tier := c_tier_fuzzy_exact;
        item.sequence := sequence;
        Inc(sequence);

        existing_index := 0;
        while existing_index < Length(values) do
        begin
            if values[existing_index].candidate.text = item.candidate.text then
            begin
                // Exact and alias candidates have a higher tier and must never
                // be replaced by a fuzzy reading of the same text.
                if nc_compare_ranked(item, values[existing_index]) < 0 then
                    values[existing_index] := item;
                Break;
            end;
            Inc(existing_index);
        end;
        if existing_index < Length(values) then
            Continue;
        SetLength(values, Length(values) + 1);
        values[High(values)] := item;
    end;
end;

procedure nc_add_user_entries(var values: TncRankedCandidateList;
    const entries: TncRawUserEntries; var sequence: Integer);
var
    index: Integer;
    scan_index: Integer;
    item: TncRankedCandidate;
begin
    for index := 0 to High(entries) do
    begin
        item.candidate.text := entries[index].text;
        item.candidate.comment := '';
        item.candidate.score := entries[index].weight;
        item.candidate.source := cs_user;
        item.candidate.has_dict_weight := False;
        item.candidate.dict_weight := 0;
        item.candidate.fuzzy_cost := 0;
        item.candidate.fuzzy_rules := [];
        item.candidate.display_kind := cdk_default;
        item.candidate.deletable := True;
        item.tier := c_tier_user_word;
        item.ranking_score := entries[index].weight;
        item.sequence := sequence;
        Inc(sequence);
        for scan_index := 0 to High(values) do
        begin
            if values[scan_index].candidate.text <> item.candidate.text then
                Continue;
            values[scan_index] := item;
            item.sequence := -1;
            Break;
        end;
        if item.sequence < 0 then
            Continue;
        SetLength(values, Length(values) + 1);
        values[High(values)] := item;
    end;
end;

procedure nc_apply_user_preferences(var values: TncRankedCandidateList;
    const preferences: TncUserPreferences);
var
    preference_index: Integer;
    candidate_index: Integer;
    bonus: Integer;
begin
    for preference_index := 0 to High(preferences) do
    begin
        for candidate_index := 0 to High(values) do
        begin
            if values[candidate_index].candidate.text <>
                preferences[preference_index].text then
                Continue;
            if preferences[preference_index].latest then
                values[candidate_index].tier := c_tier_latest_choice
            else if values[candidate_index].tier < c_tier_user_preference then
                values[candidate_index].tier := c_tier_user_preference;
            bonus := preferences[preference_index].commit_count * 1000;
            if bonus > 50000 then
                bonus := 50000;
            values[candidate_index].ranking_score :=
                values[candidate_index].ranking_score + bonus;
            values[candidate_index].candidate.score :=
                values[candidate_index].ranking_score;
            Break;
        end;
    end;
end;

function nc_is_initial_abbreviation(const value: string): Boolean;
const
    c_initial_letters = 'bpmfdtnlgkhjqxrzcsyw';
begin
    Result := ((Length(value) = 1) and
        (Pos(value[1], c_initial_letters) > 0)) or
        (value = 'zh') or (value = 'ch') or (value = 'sh');
end;

function nc_is_jianpin_query(const value: string): Boolean;
var
    index: Integer;
begin
    Result := (Length(value) >= 2) and (Length(value) <= 12);
    if not Result then
        Exit;
    for index := 1 to Length(value) do
        if not nc_is_initial_abbreviation(value[index]) then
            Exit(False);
end;

function nc_build_mixed_jianpin_units(
    const syllables: TncPinyinParseResult;
    out units: TncMixedPinyinUnits; out jianpin: string): Boolean;
var
    source_index: Integer;
    unit_count: Integer;
    unit_text: string;
    abbreviated_count: Integer;
    complete_count: Integer;
begin
    units := nil;
    jianpin := '';
    abbreviated_count := 0;
    complete_count := 0;
    if (Length(syllables) < 2) or (Length(syllables) > 12) then
        Exit(False);

    source_index := 0;
    while source_index < Length(syllables) do
    begin
        unit_text := syllables[source_index].text;
        if (Length(unit_text) = 1) and
            ((unit_text = 'z') or (unit_text = 'c') or
            (unit_text = 's')) and
            (source_index < High(syllables)) and
            (syllables[source_index + 1].text = 'h') and
            (syllables[source_index].start_index +
            syllables[source_index].length =
            syllables[source_index + 1].start_index) then
        begin
            unit_text := unit_text + 'h';
            Inc(source_index);
        end;

        unit_count := Length(units);
        SetLength(units, unit_count + 1);
        units[unit_count].text := unit_text;
        units[unit_count].abbreviated :=
            nc_is_initial_abbreviation(unit_text);
        if units[unit_count].abbreviated then
            Inc(abbreviated_count)
        else if nc_is_canonical_pinyin_syllable(unit_text) then
            Inc(complete_count)
        else
        begin
            units := nil;
            jianpin := '';
            Exit(False);
        end;
        jianpin := jianpin + unit_text[1];
        Inc(source_index);
    end;

    Result := (abbreviated_count > 0) and (complete_count > 0) and
        (Length(units) >= 2);
    if not Result then
    begin
        units := nil;
        jianpin := '';
    end;
end;

function nc_mixed_jianpin_entry_matches(const parser: TncPinyinParser;
    const units: TncMixedPinyinUnits;
    const entry: TncRawDictionaryEntry): Boolean;
var
    candidate_syllables: TncPinyinParseResult;
    index: Integer;
begin
    candidate_syllables := parser.Parse(entry.pinyin);
    if Length(candidate_syllables) <> Length(units) then
        Exit(False);
    for index := 0 to High(units) do
    begin
        if units[index].abbreviated then
        begin
            if Copy(candidate_syllables[index].text, 1,
                Length(units[index].text)) <> units[index].text then
                Exit(False);
        end
        else if candidate_syllables[index].text <> units[index].text then
            Exit(False);
    end;
    Result := True;
end;

procedure nc_filter_mixed_jianpin_entries(const parser: TncPinyinParser;
    const units: TncMixedPinyinUnits;
    const source: TncRawDictionaryEntries;
    out destination: TncRawDictionaryEntries);
var
    source_index: Integer;
    destination_count: Integer;
begin
    destination := nil;
    for source_index := 0 to High(source) do
    begin
        if not nc_mixed_jianpin_entry_matches(parser, units,
            source[source_index]) then
            Continue;
        destination_count := Length(destination);
        SetLength(destination, destination_count + 1);
        destination[destination_count] := source[source_index];
    end;
end;

function nc_fixed_single_text(const compact_query: string): string;
begin
    Result := '';
    if compact_query = 'en' then
        Result := UnicodeString(WideChar($55EF))
    else if compact_query = 'ba' then
        Result := UnicodeString(WideChar($5427))
    else if compact_query = 'e' then
        Result := UnicodeString(WideChar($5443))
    else if compact_query = 'o' then
        Result := UnicodeString(WideChar($54E6))
    else if compact_query = 'ai' then
        Result := UnicodeString(WideChar($5509))
    else if compact_query = 'ha' then
        Result := UnicodeString(WideChar($54C8))
    else if compact_query = 'xi' then
        Result := UnicodeString(WideChar($563B))
    else if compact_query = 'xing' then
        Result := UnicodeString(WideChar($884C))
    else if compact_query = 'hao' then
        Result := UnicodeString(WideChar($597D))
    else if compact_query = 'bang' then
        Result := UnicodeString(WideChar($68D2))
    else if compact_query = 'ya' then
        Result := UnicodeString(WideChar($5440))
    else if compact_query = 'qie' then
        Result := UnicodeString(WideChar($5207))
    else if compact_query = 'ca' then
        Result := UnicodeString(WideChar($64E6))
    else if compact_query = 'gun' then
        Result := UnicodeString(WideChar($6EDA))
    else if compact_query = 'hei' then
        Result := UnicodeString(WideChar($563F))
    else if compact_query = 'pi' then
        Result := UnicodeString(WideChar($5C41))
    else if compact_query = 'de' then
        Result := UnicodeString(WideChar($7684))
    else if compact_query = 'zhe' then
        Result := UnicodeString(WideChar($8FD9))
    else if compact_query = 'er' then
        Result := UnicodeString(WideChar($800C))
    else if compact_query = 'he' then
        Result := UnicodeString(WideChar($548C))
    else if compact_query = 'you' then
        Result := UnicodeString(WideChar($6709))
    else if compact_query = 'shi' then
        Result := UnicodeString(WideChar($662F))
    else if compact_query = 'qing' then
        Result := UnicodeString(WideChar($8BF7));
end;

procedure nc_promote_fixed_single(var values: TncRankedCandidateList;
    const text: string; var sequence: Integer);
var
    index: Integer;
    item: TncRankedCandidate;
begin
    if text = '' then
        Exit;
    for index := 0 to High(values) do
    begin
        if values[index].candidate.text <> text then
            Continue;
        values[index].tier := c_tier_fixed_single;
        Exit;
    end;

    item.candidate.text := text;
    item.candidate.comment := '';
    item.candidate.score := 0;
    item.candidate.source := cs_rule;
    item.candidate.has_dict_weight := False;
    item.candidate.dict_weight := 0;
    item.candidate.fuzzy_cost := 0;
    item.candidate.fuzzy_rules := [];
    item.candidate.display_kind := cdk_default;
    item.candidate.deletable := False;
    item.tier := c_tier_fixed_single;
    item.ranking_score := 0;
    item.sequence := sequence;
    Inc(sequence);
    SetLength(values, Length(values) + 1);
    values[High(values)] := item;
end;

function nc_is_complete_parse(const syllables: TncPinyinParseResult;
    const compact_query: string): Boolean;
var
    index: Integer;
    rebuilt_query: string;
begin
    rebuilt_query := '';
    if Length(syllables) = 0 then
        Exit(False);
    for index := 0 to High(syllables) do
    begin
        if not nc_is_canonical_pinyin_syllable(syllables[index].text) then
            Exit(False);
        rebuilt_query := rebuilt_query + syllables[index].text;
    end;
    Result := rebuilt_query = compact_query;
end;

procedure nc_merge_raw_entries(var destination: TncRawDictionaryEntries;
    const source: TncRawDictionaryEntries);
var
    source_index: Integer;
    destination_index: Integer;
    duplicate_index: Integer;
begin
    for source_index := 0 to High(source) do
    begin
        duplicate_index := -1;
        for destination_index := 0 to High(destination) do
            if destination[destination_index].text = source[source_index].text then
            begin
                duplicate_index := destination_index;
                Break;
            end;
        if duplicate_index >= 0 then
        begin
            if source[source_index].weight >
                destination[duplicate_index].weight then
                destination[duplicate_index] := source[source_index];
            Continue;
        end;
        SetLength(destination, Length(destination) + 1);
        destination[High(destination)] := source[source_index];
    end;
end;

procedure nc_sort_path_states(var states: TncPathStateList);
var
    index: Integer;
    scan_index: Integer;
    current_value: TncPathState;
begin
    for index := 1 to High(states) do
    begin
        current_value := states[index];
        scan_index := index - 1;
        while (scan_index >= 0) and
            ((current_value.score > states[scan_index].score) or
            ((current_value.score = states[scan_index].score) and
            (current_value.segment_count < states[scan_index].segment_count))) do
        begin
            states[scan_index + 1] := states[scan_index];
            Dec(scan_index);
        end;
        states[scan_index + 1] := current_value;
    end;
end;

procedure nc_add_path_state(var states: TncPathStateList;
    const value: TncPathState);
var
    index: Integer;
begin
    for index := 0 to High(states) do
    begin
        if states[index].text <> value.text then
            Continue;
        if value.score > states[index].score then
            states[index] := value;
        nc_sort_path_states(states);
        Exit;
    end;
    SetLength(states, Length(states) + 1);
    states[High(states)] := value;
    nc_sort_path_states(states);
    if Length(states) > c_path_beam_width then
        SetLength(states, c_path_beam_width);
end;

constructor TncCandidatePipeline.Create(const dictionary: TncDictionaryReader;
    const parser: TncPinyinParser;
    const user_dictionary: TncUserDictionary);
begin
    inherited Create;
    if dictionary = nil then
        raise EArgumentNilException.Create('dictionary');
    if parser = nil then
        raise EArgumentNilException.Create('parser');
    FDictionary := dictionary;
    FUserDictionary := user_dictionary;
    FParser := parser;
    FErrorMessage := '';
end;

function TncCandidatePipeline.Build(const raw_composition: string;
    const compact_query: string; const fuzzy_pinyin_enabled: Boolean;
    const fuzzy_pinyin_rules: TncFuzzyPinyinRules;
    out candidates: TncCandidateList): Boolean;
var
    ranked: TncRankedCandidateList;
    exact_entries: TncRawDictionaryEntries;
    alias_entries: TncRawDictionaryEntries;
    entries: TncRawDictionaryEntries;
    segment_entries: TncRawDictionaryEntries;
    segment_aliases: TncRawDictionaryEntries;
    syllables: TncPinyinParseResult;
    states: TncPathStateMatrix;
    current_state: TncPathState;
    next_state: TncPathState;
    segment_key: string;
    sequence: Integer;
    index: Integer;
    output_count: Integer;
    start_index: Integer;
    end_index: Integer;
    state_index: Integer;
    entry_index: Integer;
    segment_span: Integer;
    segment_weight: Integer;
    maximum_end: Integer;
    exact_count: Integer;
    user_entries: TncRawUserEntries;
    user_preferences: TncUserPreferences;
    fuzzy_variants: TncFuzzyPinyinQueryVariants;
    fuzzy_variant: TncFuzzyPinyinQueryVariant;
    fuzzy_query: string;
    fuzzy_index: Integer;
    mixed_units: TncMixedPinyinUnits;
    mixed_jianpin: string;
    mixed_entries: TncRawDictionaryEntries;
    fixed_single_text: string;
    path_texts: TncDictionaryTexts;
    path_lm_scores: TncDictionaryScores;
    path_original_scores: TncDictionaryScores;
    path_model_scores: TncDictionaryScores;
    path_lm_enabled: Boolean;
    path_rank: Integer;
    path_best_index: Integer;
    path_best_score: Integer;
    path_ranking_score: Integer;

    function QueryFailed: Boolean;
    begin
        FErrorMessage := FDictionary.ErrorMessage;
        Result := False;
    end;

begin
    candidates := nil;
    ranked := nil;
    states := nil;
    path_texts := nil;
    path_lm_scores := nil;
    path_original_scores := nil;
    path_model_scores := nil;
    sequence := 0;
    FErrorMessage := '';
    if compact_query = '' then
        Exit(True);

    if not FDictionary.QueryExact(compact_query, c_query_limit,
        exact_entries) then
        Exit(QueryFailed);
    if not FDictionary.QueryAlias(compact_query, c_query_limit,
        alias_entries) then
        Exit(QueryFailed);
    nc_add_entries(ranked, exact_entries, c_tier_exact, cdk_default, sequence);
    nc_add_entries(ranked, alias_entries, c_tier_alias, cdk_default, sequence);
    exact_count := Length(ranked);

    if fuzzy_pinyin_enabled and (fuzzy_pinyin_rules <> []) then
    begin
        fuzzy_variants := nc_build_fuzzy_query_variants(raw_composition,
            fuzzy_pinyin_rules, 1, 6, 4);
        for fuzzy_variant in fuzzy_variants do
        begin
            fuzzy_query := '';
            for fuzzy_index := 1 to Length(fuzzy_variant.text) do
                if fuzzy_variant.text[fuzzy_index] <> '''' then
                    fuzzy_query := fuzzy_query + fuzzy_variant.text[fuzzy_index];
            if (fuzzy_query = '') or (fuzzy_query = compact_query) then
                Continue;
            if not FDictionary.QueryExact(fuzzy_query, c_query_limit,
                entries) then
                Exit(QueryFailed);
            nc_add_fuzzy_entries(ranked, entries, fuzzy_variant.cost,
                fuzzy_variant.rules, sequence);
        end;
    end;

    if FUserDictionary <> nil then
    begin
        if not FUserDictionary.QueryUserWords(compact_query, c_query_limit,
            user_entries) then
        begin
            FErrorMessage := FUserDictionary.ErrorMessage;
            Exit(False);
        end;
        nc_add_user_entries(ranked, user_entries, sequence);
    end;

    if not FDictionary.QueryPath(compact_query, c_query_limit, entries) then
        Exit(QueryFailed);
    nc_add_entries(ranked, entries, c_tier_direct_path,
        cdk_lm_compound, sequence);

    syllables := FParser.Parse(raw_composition);

    if nc_is_jianpin_query(compact_query) then
    begin
        if not FDictionary.QueryJianpin(compact_query, c_query_limit,
            entries) then
            Exit(QueryFailed);
        nc_add_entries(ranked, entries, c_tier_jianpin, cdk_default, sequence);
    end;

    if exact_count = 0 then
    begin
        if Length(syllables) > 0 then
        begin
            if not FDictionary.QueryPrefix(compact_query, Length(syllables),
                c_query_limit * 2, entries) then
                Exit(QueryFailed);
            nc_add_entries(ranked, entries, c_tier_prefix,
                cdk_default, sequence);
        end;
    end;

    if nc_build_mixed_jianpin_units(syllables, mixed_units,
        mixed_jianpin) then
    begin
        if not FDictionary.QueryJianpin(mixed_jianpin,
            c_mixed_jianpin_query_limit, entries) then
            Exit(QueryFailed);
        nc_filter_mixed_jianpin_entries(FParser, mixed_units, entries,
            mixed_entries);
        nc_add_entries(ranked, mixed_entries, c_tier_mixed_jianpin,
            cdk_default, sequence);

        if mixed_units[0].abbreviated then
        begin
            if not FDictionary.QueryPrefix(mixed_units[0].text, 1,
                c_query_limit, entries) then
                Exit(QueryFailed);
            nc_add_entries(ranked, entries, c_tier_mixed_initial,
                cdk_default, sequence);
        end;
    end;

    if (Length(syllables) >= 2) and
        nc_is_complete_parse(syllables, compact_query) then
    begin
        SetLength(states, Length(syllables) + 1);
        SetLength(states[0], 1);
        states[0][0].text := '';
        states[0][0].score := 0;
        states[0][0].segment_count := 0;

        for start_index := 0 to High(syllables) do
        begin
            if Length(states[start_index]) = 0 then
                Continue;
            maximum_end := start_index + c_maximum_segment_syllables;
            if maximum_end > Length(syllables) then
                maximum_end := Length(syllables);
            segment_key := '';
            for end_index := start_index + 1 to maximum_end do
            begin
                segment_key := segment_key + syllables[end_index - 1].text;
                segment_entries := nil;
                segment_aliases := nil;
                if not FDictionary.QueryExact(segment_key,
                    c_segment_query_limit, segment_entries) then
                    Exit(QueryFailed);
                if not FDictionary.QueryAlias(segment_key,
                    c_segment_query_limit, segment_aliases) then
                    Exit(QueryFailed);
                nc_merge_raw_entries(segment_entries, segment_aliases);
                segment_span := end_index - start_index;
                for state_index := 0 to High(states[start_index]) do
                begin
                    current_state := states[start_index][state_index];
                    for entry_index := 0 to High(segment_entries) do
                    begin
                        segment_weight := segment_entries[entry_index].weight;
                        if segment_weight < 0 then
                            segment_weight := 0;
                        if segment_weight > 800 then
                            segment_weight := 800;
                        next_state.text := current_state.text +
                            segment_entries[entry_index].text;
                        next_state.score := current_state.score + segment_weight +
                            (segment_span - 1) * 1000;
                        next_state.segment_count :=
                            current_state.segment_count + 1;
                        nc_add_path_state(states[end_index], next_state);
                    end;
                end;
            end;
        end;

        for state_index := 0 to High(states[Length(syllables)]) do
        begin
            current_state := states[Length(syllables)][state_index];
            if current_state.segment_count < 2 then
                Continue;
            SetLength(path_texts, Length(path_texts) + 1);
            path_texts[High(path_texts)] := current_state.text;
            SetLength(path_original_scores,
                Length(path_original_scores) + 1);
            path_original_scores[High(path_original_scores)] :=
                current_state.score;
        end;
        path_lm_enabled := (Length(syllables) >=
            c_char_lm_minimum_syllables) and (Length(path_texts) >= 2) and
            FDictionary.QueryCharLmTextScores(path_texts, path_lm_scores) and
            (Length(path_lm_scores) = Length(path_texts));
        if path_lm_enabled then
        begin
            SetLength(path_model_scores, Length(path_lm_scores));
            path_best_index := 0;
            path_best_score := Low(Integer);
            for path_rank := 0 to High(path_lm_scores) do
            begin
                path_model_scores[path_rank] :=
                    path_lm_scores[path_rank] * c_char_lm_score_multiplier +
                    path_original_scores[path_rank] *
                    c_char_lm_path_score_multiplier;
                if path_model_scores[path_rank] > path_best_score then
                begin
                    path_best_score := path_model_scores[path_rank];
                    path_best_index := path_rank;
                end;
            end;
            // Preserve the proven path winner unless the character model has
            // enough evidence to justify changing it. When both models agree,
            // the language model may still improve the lower candidates.
            if (path_best_index <> 0) and
                (path_best_score - path_model_scores[0] <
                c_char_lm_minimum_advantage) and
                ((path_lm_scores[path_best_index] <
                c_char_lm_high_confidence_score) or
                (path_best_score - path_model_scores[0] <
                c_char_lm_high_confidence_advantage)) then
                path_lm_enabled := False;
        end;

        path_rank := 0;
        for state_index := 0 to High(states[Length(syllables)]) do
        begin
            current_state := states[Length(syllables)][state_index];
            if current_state.segment_count < 2 then
                Continue;
            path_ranking_score := current_state.score;
            if path_lm_enabled then
                path_ranking_score := path_model_scores[path_rank];
            entries := nil;
            SetLength(entries, 1);
            entries[0].pinyin := compact_query;
            entries[0].text := current_state.text;
            entries[0].comment := '';
            entries[0].weight := current_state.score;
            nc_add_ranked_candidate(ranked, entries[0],
                c_tier_segmented_path, path_ranking_score,
                cdk_lm_compound, sequence);
            Inc(path_rank);
        end;
    end;

    if FUserDictionary <> nil then
    begin
        if not FUserDictionary.QueryPreferences(compact_query,
            user_preferences) then
        begin
            FErrorMessage := FUserDictionary.ErrorMessage;
            Exit(False);
        end;
        nc_apply_user_preferences(ranked, user_preferences);
    end;

    fixed_single_text := '';
    if (Length(syllables) = 1) and
        nc_is_complete_parse(syllables, compact_query) then
        fixed_single_text := nc_fixed_single_text(compact_query);
    nc_promote_fixed_single(ranked, fixed_single_text, sequence);

    nc_sort_ranked(ranked);
    output_count := Length(ranked);
    if output_count > c_maximum_candidates then
        output_count := c_maximum_candidates;
    SetLength(candidates, output_count);
    for index := 0 to output_count - 1 do
        candidates[index] := ranked[index].candidate;
    Result := True;
end;

end.
