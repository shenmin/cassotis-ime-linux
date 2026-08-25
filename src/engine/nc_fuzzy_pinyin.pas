unit nc_fuzzy_pinyin;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    nc_types,
    nc_pinyin_parser;

type
    TncFuzzyPinyinSyllableVariant = record
        original_text: string;
        text: string;
        cost: Integer;
        rules: TncFuzzyPinyinRules;
    end;
    TncFuzzyPinyinSyllableVariants = array of TncFuzzyPinyinSyllableVariant;

    TncFuzzyPinyinQueryVariant = record
        original_text: string;
        text: string;
        syllable_count: Integer;
        cost: Integer;
        rules: TncFuzzyPinyinRules;
    end;
    TncFuzzyPinyinQueryVariants = array of TncFuzzyPinyinQueryVariant;

function nc_all_fuzzy_pinyin_rules: TncFuzzyPinyinRules;
function nc_fuzzy_pinyin_rule_name(const rule: TncFuzzyPinyinRule): string;
function nc_try_parse_fuzzy_pinyin_rule_name(const value: string;
    out rule: TncFuzzyPinyinRule): Boolean;
function nc_build_fuzzy_syllable_variants(const syllable: string;
    const enabled_rules: TncFuzzyPinyinRules;
    const include_original: Boolean = False): TncFuzzyPinyinSyllableVariants;
function nc_build_fuzzy_query_variants(const input_text: string;
    const enabled_rules: TncFuzzyPinyinRules;
    const max_cost: Integer = 4;
    const max_variants: Integer = 16;
    const max_syllables: Integer = 4): TncFuzzyPinyinQueryVariants;

implementation

function nc_same_text(const left_value: string;
    const right_value: string): Boolean;
begin
    Result := LowerCase(left_value) = LowerCase(right_value);
end;

function nc_compare_text(const left_value: string;
    const right_value: string): Integer;
var
    normalized_left: string;
    normalized_right: string;
begin
    normalized_left := LowerCase(left_value);
    normalized_right := LowerCase(right_value);
    if normalized_left < normalized_right then
        Exit(-1);
    if normalized_left > normalized_right then
        Exit(1);
    Result := 0;
end;

function remove_apostrophes(const value: string): string;
var
    index: Integer;
begin
    Result := '';
    for index := 1 to Length(value) do
        if value[index] <> '''' then
            Result := Result + value[index];
end;

type
    TncFuzzyRulePair = record
        rule: TncFuzzyPinyinRule;
        left_value: string;
        right_value: string;
        initial_rule: Boolean;
    end;

const
    c_fuzzy_rule_pairs: array[0..10] of TncFuzzyRulePair = (
        (rule: fpr_z_zh; left_value: 'z'; right_value: 'zh'; initial_rule: True),
        (rule: fpr_c_ch; left_value: 'c'; right_value: 'ch'; initial_rule: True),
        (rule: fpr_s_sh; left_value: 's'; right_value: 'sh'; initial_rule: True),
        (rule: fpr_l_n; left_value: 'l'; right_value: 'n'; initial_rule: True),
        (rule: fpr_f_h; left_value: 'f'; right_value: 'h'; initial_rule: True),
        (rule: fpr_r_l; left_value: 'r'; right_value: 'l'; initial_rule: True),
        (rule: fpr_an_ang; left_value: 'an'; right_value: 'ang'; initial_rule: False),
        (rule: fpr_en_eng; left_value: 'en'; right_value: 'eng'; initial_rule: False),
        (rule: fpr_in_ing; left_value: 'in'; right_value: 'ing'; initial_rule: False),
        (rule: fpr_ian_iang; left_value: 'ian'; right_value: 'iang'; initial_rule: False),
        (rule: fpr_uan_uang; left_value: 'uan'; right_value: 'uang'; initial_rule: False)
    );

function nc_all_fuzzy_pinyin_rules: TncFuzzyPinyinRules;
var
    rule: TncFuzzyPinyinRule;
begin
    Result := [];
    for rule := Low(TncFuzzyPinyinRule) to High(TncFuzzyPinyinRule) do
    begin
        Include(Result, rule);
    end;
end;

function nc_fuzzy_pinyin_rule_name(const rule: TncFuzzyPinyinRule): string;
begin
    case rule of
        fpr_z_zh: Result := 'z-zh';
        fpr_c_ch: Result := 'c-ch';
        fpr_s_sh: Result := 's-sh';
        fpr_l_n: Result := 'l-n';
        fpr_f_h: Result := 'f-h';
        fpr_r_l: Result := 'r-l';
        fpr_an_ang: Result := 'an-ang';
        fpr_en_eng: Result := 'en-eng';
        fpr_in_ing: Result := 'in-ing';
        fpr_ian_iang: Result := 'ian-iang';
        fpr_uan_uang: Result := 'uan-uang';
    else
        Result := '';
    end;
end;

function nc_try_parse_fuzzy_pinyin_rule_name(const value: string;
    out rule: TncFuzzyPinyinRule): Boolean;
var
    candidate: TncFuzzyPinyinRule;
    normalized: string;
begin
    normalized := LowerCase(Trim(value));
    for candidate := Low(TncFuzzyPinyinRule) to High(TncFuzzyPinyinRule) do
    begin
        if normalized = LowerCase(nc_fuzzy_pinyin_rule_name(candidate)) then
        begin
            rule := candidate;
            Exit(True);
        end;
    end;
    rule := Low(TncFuzzyPinyinRule);
    Result := False;
end;

function split_syllable(const value: string; out initial_value: string;
    out final_value: string): Boolean;
const
    c_two_letter_initials: array[0..2] of string = ('zh', 'ch', 'sh');
    c_one_letter_initials = 'bpmfdtnlgkhjqxrzcsyw';
var
    candidate: string;
begin
    initial_value := '';
    final_value := LowerCase(Trim(value));
    if final_value = '' then
    begin
        Exit(False);
    end;

    for candidate in c_two_letter_initials do
    begin
        if Copy(final_value, 1, Length(candidate)) = candidate then
        begin
            initial_value := candidate;
            Delete(final_value, 1, Length(candidate));
            Exit(final_value <> '');
        end;
    end;

    if (Length(final_value) > 1) and
        (Pos(final_value[1], c_one_letter_initials) > 0) then
    begin
        initial_value := final_value[1];
        Delete(final_value, 1, 1);
    end;
    Result := final_value <> '';
end;

function is_single_canonical_syllable(const value: string): Boolean;
begin
    Result := nc_is_canonical_pinyin_syllable(value);
end;

function nc_build_fuzzy_syllable_variants(const syllable: string;
    const enabled_rules: TncFuzzyPinyinRules;
    const include_original: Boolean): TncFuzzyPinyinSyllableVariants;
var
    original_text: string;
    initial_value: string;
    final_value: string;
    pair: TncFuzzyRulePair;
    initial_alternatives: TncFuzzyPinyinSyllableVariants;
    final_alternatives: TncFuzzyPinyinSyllableVariants;
    initial_item: TncFuzzyPinyinSyllableVariant;
    final_item: TncFuzzyPinyinSyllableVariant;
    idx: Integer;
    sort_idx: Integer;
    sorted_item: TncFuzzyPinyinSyllableVariant;

    procedure append_unique(const text_value: string; const cost_value: Integer;
        const rules_value: TncFuzzyPinyinRules);
    var
        key: string;
        existing_index: Integer;
        current: TncFuzzyPinyinSyllableVariant;
    begin
        key := LowerCase(Trim(text_value));
        if (key = '') or (not is_single_canonical_syllable(key)) then
        begin
            Exit;
        end;
        for existing_index := 0 to High(Result) do
        begin
            if nc_same_text(Result[existing_index].text, key) then
            begin
                current := Result[existing_index];
                if cost_value < current.cost then
                begin
                    current.cost := cost_value;
                    current.rules := rules_value;
                    Result[existing_index] := current;
                end;
                Exit;
            end;
        end;
        existing_index := Length(Result);
        SetLength(Result, existing_index + 1);
        Result[existing_index].original_text := original_text;
        Result[existing_index].text := key;
        Result[existing_index].cost := cost_value;
        Result[existing_index].rules := rules_value;
    end;

    procedure append_part_variant(var target: TncFuzzyPinyinSyllableVariants;
        const text_value: string; const rule_value: TncFuzzyPinyinRule);
    var
        target_index: Integer;
    begin
        target_index := Length(target);
        SetLength(target, target_index + 1);
        target[target_index].original_text := original_text;
        target[target_index].text := text_value;
        target[target_index].cost := 1;
        target[target_index].rules := [rule_value];
    end;

begin
    Result := nil;
    initial_alternatives := nil;
    final_alternatives := nil;
    original_text := LowerCase(Trim(syllable));
    if (enabled_rules = []) or
        (not split_syllable(original_text, initial_value,
        final_value)) then
    begin
        Exit;
    end;

    SetLength(initial_alternatives, 1);
    initial_alternatives[0].original_text := original_text;
    initial_alternatives[0].text := initial_value;
    initial_alternatives[0].cost := 0;
    initial_alternatives[0].rules := [];
    SetLength(final_alternatives, 1);
    final_alternatives[0].original_text := original_text;
    final_alternatives[0].text := final_value;
    final_alternatives[0].cost := 0;
    final_alternatives[0].rules := [];

    for pair in c_fuzzy_rule_pairs do
    begin
        if not (pair.rule in enabled_rules) then
        begin
            Continue;
        end;
        if pair.initial_rule then
        begin
            if nc_same_text(initial_value, pair.left_value) then
            begin
                append_part_variant(initial_alternatives, pair.right_value,
                    pair.rule);
            end
            else if nc_same_text(initial_value, pair.right_value) then
            begin
                append_part_variant(initial_alternatives, pair.left_value,
                    pair.rule);
            end;
        end
        else
        begin
            if nc_same_text(final_value, pair.left_value) then
            begin
                append_part_variant(final_alternatives, pair.right_value,
                    pair.rule);
            end
            else if nc_same_text(final_value, pair.right_value) then
            begin
                append_part_variant(final_alternatives, pair.left_value,
                    pair.rule);
            end;
        end;
    end;

    for initial_item in initial_alternatives do
    begin
        for final_item in final_alternatives do
        begin
            if (not include_original) and (initial_item.cost = 0) and
                (final_item.cost = 0) then
            begin
                Continue;
            end;
            append_unique(initial_item.text + final_item.text,
                initial_item.cost + final_item.cost,
                initial_item.rules + final_item.rules);
        end;
    end;

    // The list has at most a handful of entries, so insertion sort avoids
    // allocating comparer/list objects on every syllable.
    for idx := 1 to High(Result) do
    begin
        sorted_item := Result[idx];
        sort_idx := idx - 1;
        while (sort_idx >= 0) and
            ((Result[sort_idx].cost > sorted_item.cost) or
            ((Result[sort_idx].cost = sorted_item.cost) and
            (nc_compare_text(Result[sort_idx].text, sorted_item.text) > 0))) do
        begin
            Result[sort_idx + 1] := Result[sort_idx];
            Dec(sort_idx);
        end;
        Result[sort_idx + 1] := sorted_item;
    end;
end;

function nc_build_fuzzy_query_variants(const input_text: string;
    const enabled_rules: TncFuzzyPinyinRules; const max_cost: Integer;
    const max_variants: Integer;
    const max_syllables: Integer): TncFuzzyPinyinQueryVariants;
type
    TncQueryBuildState = record
        text: string;
        cost: Integer;
        rules: TncFuzzyPinyinRules;
    end;
    TncQueryBuildStates = array of TncQueryBuildState;
var
    normalized: string;
    parser: TncPinyinParser;
    syllables: TncPinyinParseResult;
    states: TncQueryBuildStates;
    next_states: TncQueryBuildStates;
    syllable_variants: TncFuzzyPinyinSyllableVariants;
    state: TncQueryBuildState;
    next_state: TncQueryBuildState;
    variant: TncFuzzyPinyinSyllableVariant;
    idx: Integer;
    state_idx: Integer;
    boundary_before: Boolean;
    separator_text: string;
    reconstructed: string;
    output_item: TncFuzzyPinyinQueryVariant;
    output_count: Integer;

    procedure append_state_unique(var target: TncQueryBuildStates;
        const value: TncQueryBuildState);
    var
        target_idx: Integer;
    begin
        for target_idx := 0 to High(target) do
        begin
            if nc_same_text(target[target_idx].text, value.text) then
            begin
                Exit;
            end;
        end;
        target_idx := Length(target);
        SetLength(target, target_idx + 1);
        target[target_idx] := value;
    end;

    procedure sort_states(var values: TncQueryBuildStates);
    var
        value_idx: Integer;
        insert_idx: Integer;
        value: TncQueryBuildState;
    begin
        for value_idx := 1 to High(values) do
        begin
            value := values[value_idx];
            insert_idx := value_idx - 1;
            while (insert_idx >= 0) and
                ((values[insert_idx].cost > value.cost) or
                ((values[insert_idx].cost = value.cost) and
                (nc_compare_text(values[insert_idx].text, value.text) > 0))) do
            begin
                values[insert_idx + 1] := values[insert_idx];
                Dec(insert_idx);
            end;
            values[insert_idx + 1] := value;
        end;
    end;
begin
    Result := nil;
    states := nil;
    next_states := nil;
    normalized := LowerCase(Trim(input_text));
    if (normalized = '') or (enabled_rules = []) or (max_cost <= 0) or
        (max_variants <= 0) or (max_syllables <= 0) then
    begin
        Exit;
    end;
    if (normalized[1] = '''') or
        (normalized[Length(normalized)] = '''') or
        (Pos('''''', normalized) > 0) then
    begin
        Exit;
    end;

    parser := TncPinyinParser.Create;
    try
        syllables := parser.parse(normalized);
    finally
        parser.Free;
    end;
    if (Length(syllables) <= 0) or (Length(syllables) > max_syllables) then
    begin
        Exit;
    end;

    reconstructed := '';
    for idx := 0 to High(syllables) do
    begin
        reconstructed := reconstructed + syllables[idx].text;
    end;
    if not nc_same_text(reconstructed, remove_apostrophes(normalized)) then
    begin
        Exit;
    end;

    SetLength(states, 1);
    states[0].text := '';
    states[0].cost := 0;
    states[0].rules := [];

    for idx := 0 to High(syllables) do
    begin
        syllable_variants := nc_build_fuzzy_syllable_variants(
            syllables[idx].text, enabled_rules, True);
        if Length(syllable_variants) = 0 then
        begin
            SetLength(syllable_variants, 1);
            syllable_variants[0].original_text := syllables[idx].text;
            syllable_variants[0].text := syllables[idx].text;
            syllable_variants[0].cost := 0;
            syllable_variants[0].rules := [];
        end;

        boundary_before := (idx > 0) and
            (syllables[idx].start_index >
            syllables[idx - 1].start_index + syllables[idx - 1].length);
        if boundary_before then
        begin
            separator_text := '''';
        end
        else
        begin
            separator_text := '';
        end;

        SetLength(next_states, 0);
        for state_idx := 0 to High(states) do
        begin
            state := states[state_idx];
            for variant in syllable_variants do
            begin
                next_state.text := state.text + separator_text + variant.text;
                next_state.cost := state.cost + variant.cost;
                if next_state.cost > max_cost then
                begin
                    Continue;
                end;
                next_state.rules := state.rules + variant.rules;
                append_state_unique(next_states, next_state);
            end;
        end;
        sort_states(next_states);
        if Length(next_states) > max_variants + 1 then
        begin
            SetLength(next_states, max_variants + 1);
        end;
        states := next_states;
    end;

    output_count := 0;
    for state_idx := 0 to High(states) do
    begin
        state := states[state_idx];
        if state.cost <= 0 then
        begin
            Continue;
        end;
        output_item.original_text := normalized;
        output_item.text := state.text;
        output_item.syllable_count := Length(syllables);
        output_item.cost := state.cost;
        output_item.rules := state.rules;
        SetLength(Result, output_count + 1);
        Result[output_count] := output_item;
        Inc(output_count);
        if output_count >= max_variants then
        begin
            Break;
        end;
    end;
end;

end.
