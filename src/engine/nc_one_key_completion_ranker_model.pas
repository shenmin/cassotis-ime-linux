unit nc_one_key_completion_ranker_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

function one_key_completion_calibrated_score(
    const corpus_score: Integer; const path_score: Integer;
    const vertical_penalty: Integer; const layer_kind: Integer;
    const char_lm_score: Integer; const text_units: Integer;
    const typed_units: Integer): Double;

implementation

uses
    Math;

function one_key_completion_calibrated_score(
    const corpus_score: Integer; const path_score: Integer;
    const vertical_penalty: Integer; const layer_kind: Integer;
    const char_lm_score: Integer; const text_units: Integer;
    const typed_units: Integer): Double;
const
    // Bounded pairwise calibration trained on benchmark-excluded novel and
    // chat completions. Evidence coefficients are non-negative by design.
    c_corpus = 0.3484;
    c_path = 0.5023;
    c_vertical_penalty = 0.3347;
    c_layer_penalty = 0.5678;
    c_char_lm = 1.1538;
    c_short_tail = 0.7201;
    c_single_tail = 0.9957;
    c_long_tail_penalty = 1.0466;
var
    normalized_units: Integer;
    remaining_units: Integer;
begin
    normalized_units := Max(1, text_units);
    remaining_units := normalized_units - Max(0, typed_units);
    Result :=
        c_corpus * (corpus_score / 1000.0) +
        c_path * (path_score / 520.0) -
        c_vertical_penalty * (vertical_penalty / 340.0) -
        c_layer_penalty * (layer_kind / 3.0) +
        c_char_lm * (char_lm_score / (1000.0 * normalized_units));
    if remaining_units <= 2 then
    begin
        Result := Result + c_short_tail;
    end;
    if remaining_units = 1 then
    begin
        Result := Result + c_single_tail;
    end;
    if remaining_units > 2 then
    begin
        Result := Result -
            c_long_tail_penalty * (remaining_units - 2);
    end;
end;

end.
