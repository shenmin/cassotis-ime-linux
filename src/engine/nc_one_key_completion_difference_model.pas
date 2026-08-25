unit nc_one_key_completion_difference_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_types;

type
    TncOneKeyCompletionDifferenceCategory = (
        okdc_base_to_transition, okdc_transition_to_base,
        okdc_hot_exact, okdc_warm_exact,
        okdc_cold_vertical_exact, okdc_generic
    );

function one_key_completion_difference_score(
    const context_value, query_text: string;
    const challenger, incumbent: TncOneKeyCompletion;
    const challenger_char_lm, incumbent_char_lm: Integer;
    const typed_units: Integer): Double;
function one_key_completion_difference_category(
    const incumbent, challenger: TncOneKeyCompletion):
    TncOneKeyCompletionDifferenceCategory;
function one_key_completion_difference_threshold(
    const category: TncOneKeyCompletionDifferenceCategory): Double;
function one_key_completion_difference_self_test: Boolean;

implementation

uses
    Math;

const
    c_intercept: Single = -0.00241241767;
    c_thresholds: array[TncOneKeyCompletionDifferenceCategory] of Single = (
        1.0E30, 1.0E30, 1.0E30, 2.39085627, 0.775070786, 1.86310756);
    c_coefficients: array[0..23] of Single = (
        -3.1203413, 3.45943499, 0.899462223, 0.161676109, -0.18555069, 0.132481918, 0.487852633, 0.389713168,
        -0.625494301, 6.72288132, -5.01468086, -2.43739152, -0.46399489, 2.95810843, -2.95810843, 1.33088958,
        -0.106132381, -0.461070478, -1.86040747, 5.08769131, 6.73757029, -1.84994018, 0, -2.95810843
    );

function text_unit_count(const value: string): Integer; inline;
var
    idx: Integer;
begin
    Result := 0;
    idx := 1;
    while idx <= Length(value) do
    begin
        if (Ord(value[idx]) >= $D800) and (Ord(value[idx]) <= $DBFF) and
            (idx < Length(value)) and (Ord(value[idx + 1]) >= $DC00) and
            (Ord(value[idx + 1]) <= $DFFF) then
        begin
            Inc(idx, 2);
        end
        else
        begin
            Inc(idx);
        end;
        Inc(Result);
    end;
end;

procedure add_numeric(var score: Double; const index: Integer;
    const value: Double); inline;
begin
    score := score + c_coefficients[index] * EnsureRange(value, -8.0, 8.0);
end;

procedure add_candidate_features(var score: Double;
    const item: TncOneKeyCompletion; const char_lm_score, typed_units: Integer;
    const multiplier: Double);
var
    units, remaining: Integer;
    hot, warm, cold: Boolean;
begin
    units := Max(1, text_unit_count(item.text));
    remaining := units - Max(0, typed_units);
    hot := (item.source = okcs_base_exact) and
        (item.popularity_prior >= 700) and (item.source_count >= 2);
    warm := (item.source = okcs_base_exact) and
        (item.popularity_prior >= 480);
    cold := (item.source = okcs_base_exact) and
        (item.vertical_layer_kind > 0) and
        (item.popularity_prior >= 0) and (item.popularity_prior < 300);
    add_numeric(score, 0, multiplier * item.weight / 1000.0);
    add_numeric(score, 1, multiplier * Max(-1, item.popularity_prior) / 1000.0);
    add_numeric(score, 2, multiplier * item.corpus_score / 1000.0);
    add_numeric(score, 3, multiplier * item.document_score / 200.0);
    add_numeric(score, 4, multiplier * item.source_count / 4.0);
    add_numeric(score, 5, multiplier * item.path_score / 520.0);
    add_numeric(score, 6, multiplier * item.vertical_penalty / 340.0);
    add_numeric(score, 7, multiplier * item.vertical_layer_kind / 3.0);
    add_numeric(score, 8, multiplier * char_lm_score / (1000.0 * units));
    add_numeric(score, 9, multiplier * char_lm_score / 10000.0);
    add_numeric(score, 10, multiplier * remaining / 4.0);
    add_numeric(score, 11, multiplier * units / 8.0);
    add_numeric(score, 12, multiplier * Ord(item.prefix_anchored));
    add_numeric(score, 13, multiplier * Ord(item.source = okcs_base_exact));
    add_numeric(score, 14, multiplier * Ord(item.source = okcs_transition));
    add_numeric(score, 15, multiplier * Ord(hot));
    add_numeric(score, 16, multiplier * Ord(warm));
    add_numeric(score, 17, multiplier * Ord(cold));
    if item.source = okcs_transition then
        add_numeric(score, 18, multiplier * item.weight / 1000.0);
    add_numeric(score, 19, multiplier * Ord(remaining = 1));
    add_numeric(score, 20, multiplier * Ord(remaining = 2));
    add_numeric(score, 21, multiplier * Ord(remaining > 3));
    add_numeric(score, 22, multiplier * item.feedback_count / 4.0);
    add_numeric(score, 23, multiplier * Ord(item.path_text <> ''));
end;

function one_key_completion_difference_score(
    const context_value, query_text: string;
    const challenger, incumbent: TncOneKeyCompletion;
    const challenger_char_lm, incumbent_char_lm: Integer;
    const typed_units: Integer): Double;
begin
    Result := c_intercept;
    add_candidate_features(Result, challenger, challenger_char_lm, typed_units, 1.0);
    add_candidate_features(Result, incumbent, incumbent_char_lm, typed_units, -1.0);
end;

function one_key_completion_difference_category(
    const incumbent, challenger: TncOneKeyCompletion):
    TncOneKeyCompletionDifferenceCategory;
begin
    if (incumbent.source = okcs_base_exact) and
        (challenger.source = okcs_transition) then
        Exit(okdc_base_to_transition);
    if (incumbent.source = okcs_transition) and
        (challenger.source = okcs_base_exact) then
        Exit(okdc_transition_to_base);
    if incumbent.source = okcs_base_exact then
    begin
        if (incumbent.popularity_prior >= 700) and
            (incumbent.source_count >= 2) then Exit(okdc_hot_exact);
        if incumbent.popularity_prior >= 480 then Exit(okdc_warm_exact);
        if (incumbent.vertical_layer_kind > 0) and
            (incumbent.popularity_prior >= 0) and
            (incumbent.popularity_prior < 300) then
            Exit(okdc_cold_vertical_exact);
    end;
    Result := okdc_generic;
end;

function one_key_completion_difference_threshold(
    const category: TncOneKeyCompletionDifferenceCategory): Double;
begin
    Result := c_thresholds[category];
end;

function one_key_completion_difference_self_test: Boolean;
var
    left_value, right_value: TncOneKeyCompletion;
    forward_score, reverse_score: Double;
begin
    left_value := Default(TncOneKeyCompletion);
    right_value := Default(TncOneKeyCompletion);
    left_value.text := 'ABCD';
    left_value.full_pinyin := 'abcdefgh';
    left_value.source := okcs_transition;
    left_value.weight := 520;
    right_value.text := 'ABCDE';
    right_value.full_pinyin := 'abcdefghij';
    right_value.source := okcs_base_exact;
    right_value.weight := 700;
    forward_score := one_key_completion_difference_score('', 'abcd',
        left_value, right_value, -5000, -6000, 2);
    reverse_score := one_key_completion_difference_score('', 'abcd',
        right_value, left_value, -6000, -5000, 2);
    Result := (not IsNan(forward_score)) and
        (not IsInfinite(forward_score)) and
        (not IsNan(reverse_score)) and
        (not IsInfinite(reverse_score)) and
        (Abs(forward_score - reverse_score) > 0.000001);
end;

end.
