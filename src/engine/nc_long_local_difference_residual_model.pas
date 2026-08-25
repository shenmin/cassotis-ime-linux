unit nc_long_local_difference_residual_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_long_final_ranker_model;

type
    TncLongLocalDifferenceResidualFeatures = record
        candidate_candidate_score: Double;
        candidate_dict_weight: Double;
        candidate_has_dict_weight: Double;
        candidate_source_user: Double;
        candidate_source_chain: Double;
        candidate_source_pattern: Double;
        candidate_source_redup: Double;
        candidate_source_local_rerank: Double;
        candidate_source_rule_fallback: Double;
        candidate_legacy_rank: Double;
        candidate_legacy_top: Double;
        candidate_chain_rank: Double;
        candidate_chain_present: Double;
        candidate_chain_first_stage_score: Double;
        candidate_chain_second_stage_score: Double;
        candidate_chain_score_gap: Double;
        candidate_complete_match: Double;
        candidate_partial_match: Double;
        candidate_text_units: Double;
        candidate_comment_length: Double;
        candidate_unit_delta: Double;
        candidate_path_available: Double;
        candidate_path_confidence_score: Double;
        candidate_path_confidence_tier: Double;
        candidate_path_segments: Double;
        candidate_path_single_segments: Double;
        candidate_path_max_segment_units: Double;
        candidate_char_lm_score: Double;
        candidate_char_lm_suffix_score: Double;
        candidate_char_lm_context_score: Double;
        candidate_char_lm_context_gain: Double;
        candidate_has_left_context: Double;
        candidate_query_choice_bonus: Double;
        candidate_latest_query_choice: Double;
        candidate_query_path_bonus: Double;
        candidate_query_path_penalty: Double;
        candidate_word_lm_bonus: Double;
        candidate_word_lm_boundary_count: Double;
        candidate_word_lm_boundary_min: Double;
        candidate_word_lm_boundary_max: Double;
        candidate_word_lm_boundary_first: Double;
        candidate_word_lm_boundary_last: Double;
        candidate_word_lm_supported_ratio: Double;
        candidate_word_lm_strong_ratio: Double;
        candidate_word_lm_trigram_ratio: Double;
        candidate_word_lm_zero_count: Double;
        candidate_input_syllable_count: Double;
        candidate_score_per_unit: Double;
        candidate_dict_weight_per_unit: Double;
        candidate_complete_user: Double;
        candidate_complete_dictionary: Double;
        candidate_complete_chain: Double;
        delta_candidate_score: Double;
        delta_dict_weight: Double;
        delta_has_dict_weight: Double;
        delta_source_user: Double;
        delta_source_chain: Double;
        delta_source_pattern: Double;
        delta_source_redup: Double;
        delta_source_local_rerank: Double;
        delta_source_rule_fallback: Double;
        delta_legacy_rank: Double;
        delta_legacy_top: Double;
        delta_chain_rank: Double;
        delta_chain_present: Double;
        delta_chain_first_stage_score: Double;
        delta_chain_second_stage_score: Double;
        delta_chain_score_gap: Double;
        delta_complete_match: Double;
        delta_partial_match: Double;
        delta_text_units: Double;
        delta_comment_length: Double;
        delta_unit_delta: Double;
        delta_path_available: Double;
        delta_path_confidence_score: Double;
        delta_path_confidence_tier: Double;
        delta_path_segments: Double;
        delta_path_single_segments: Double;
        delta_path_max_segment_units: Double;
        delta_char_lm_score: Double;
        delta_char_lm_suffix_score: Double;
        delta_char_lm_context_score: Double;
        delta_char_lm_context_gain: Double;
        delta_has_left_context: Double;
        delta_query_choice_bonus: Double;
        delta_latest_query_choice: Double;
        delta_query_path_bonus: Double;
        delta_query_path_penalty: Double;
        delta_word_lm_bonus: Double;
        delta_word_lm_boundary_count: Double;
        delta_word_lm_boundary_min: Double;
        delta_word_lm_boundary_max: Double;
        delta_word_lm_boundary_first: Double;
        delta_word_lm_boundary_last: Double;
        delta_word_lm_supported_ratio: Double;
        delta_word_lm_strong_ratio: Double;
        delta_word_lm_trigram_ratio: Double;
        delta_word_lm_zero_count: Double;
        delta_input_syllable_count: Double;
        delta_score_per_unit: Double;
        delta_dict_weight_per_unit: Double;
        delta_complete_user: Double;
        delta_complete_dictionary: Double;
        delta_complete_chain: Double;
        candidate_current_rank: Double;
        candidate_ranker_score: Double;
        candidate_ranker_score_gap: Double;
        baseline_ranker_applied: Double;
        baseline_abstain_score: Double;
        different_units: Double;
        different_runs: Double;
        max_different_run: Double;
        same_prefix_units: Double;
        same_suffix_units: Double;
        difference_span_units: Double;
        top_local_lm_r0: Double;
        candidate_local_lm_r0: Double;
        delta_local_lm_r0: Double;
        top_local_lm_r1: Double;
        candidate_local_lm_r1: Double;
        delta_local_lm_r1: Double;
        top_local_lm_r2: Double;
        candidate_local_lm_r2: Double;
        delta_local_lm_r2: Double;
        top_local_lm_r3: Double;
        candidate_local_lm_r3: Double;
        delta_local_lm_r3: Double;
        delta_char_lm_per_difference: Double;
        delta_char_suffix_lm_per_difference: Double;
        delta_word_lm_per_boundary: Double;
    end;

const
    c_long_local_difference_residual_feature_count: Integer = 130;
    c_long_local_difference_residual_tree_count: Integer = 192;
    c_long_local_difference_residual_max_challenger_rank: Integer = 5;
    c_long_local_difference_residual_score_scale: Double = 100000000.0;
    c_long_local_difference_residual_promotion_threshold: Int64 = 69071884;
    c_long_local_difference_residual_reference_score: Int64 = 48331503;
    c_long_local_difference_residual_reference_score_low: Int64 = -241677695;
    c_long_local_difference_residual_reference_score_high: Int64 = -28302769;
    c_long_local_difference_residual_reference_score_mixed: Int64 = -218979315;

procedure build_long_local_difference_residual_features(
    const candidate_features: TncLongFinalRankerFeatures;
    const top_features: TncLongFinalRankerFeatures;
    const candidate_rank: Integer;
    const candidate_ranker_score: Int64;
    const top_ranker_score: Int64;
    const baseline_ranker_applied: Boolean;
    const baseline_abstain_score: Int64;
    const different_units: Integer;
    const different_runs: Integer;
    const max_different_run: Integer;
    const same_prefix_units: Integer;
    const same_suffix_units: Integer;
    const difference_span_units: Integer;
    const top_local_lm_scores: array of Integer;
    const candidate_local_lm_scores: array of Integer;
    out features: TncLongLocalDifferenceResidualFeatures);
function long_local_difference_residual_score(
    const features: TncLongLocalDifferenceResidualFeatures): Int64;
function long_local_difference_residual_self_test: Boolean;

implementation

{ Local-difference residual. It uses numeric LM evidence only and may
  promote at most one complete long candidate.
  Training report SHA-256: A6E4B4E65A089EFF5B01F6EDEACF33AFA5079B5DA1AE67DDE714DB192DEF2E78
  LightGBM model SHA-256: 684ECB279A8A9020F11E905B621781A345D5D96768F622E14D7CAE3A052496EB }

procedure build_long_local_difference_residual_features(
    const candidate_features: TncLongFinalRankerFeatures;
    const top_features: TncLongFinalRankerFeatures;
    const candidate_rank: Integer;
    const candidate_ranker_score: Int64;
    const top_ranker_score: Int64;
    const baseline_ranker_applied: Boolean;
    const baseline_abstain_score: Int64;
    const different_units: Integer;
    const different_runs: Integer;
    const max_different_run: Integer;
    const same_prefix_units: Integer;
    const same_suffix_units: Integer;
    const difference_span_units: Integer;
    const top_local_lm_scores: array of Integer;
    const candidate_local_lm_scores: array of Integer;
    out features: TncLongLocalDifferenceResidualFeatures);
var
    safe_difference_count: Integer;
    safe_boundary_count: Integer;
begin
    FillChar(features, SizeOf(features), 0);
    features.candidate_candidate_score := candidate_features.candidate_score;
    features.candidate_dict_weight := candidate_features.dict_weight;
    features.candidate_has_dict_weight := Ord(candidate_features.has_dict_weight);
    features.candidate_source_user := Ord(candidate_features.source_user);
    features.candidate_source_chain := Ord(candidate_features.source_chain);
    features.candidate_source_pattern := Ord(candidate_features.source_pattern);
    features.candidate_source_redup := Ord(candidate_features.source_redup);
    features.candidate_source_local_rerank := Ord(candidate_features.source_local_rerank);
    features.candidate_source_rule_fallback := Ord(candidate_features.source_rule_fallback);
    features.candidate_legacy_rank := candidate_features.legacy_rank;
    features.candidate_legacy_top := Ord(candidate_features.legacy_top);
    features.candidate_chain_rank := candidate_features.chain_rank;
    features.candidate_chain_present := Ord(candidate_features.chain_present);
    features.candidate_chain_first_stage_score := candidate_features.chain_first_stage_score;
    features.candidate_chain_second_stage_score := candidate_features.chain_second_stage_score;
    features.candidate_chain_score_gap := candidate_features.chain_score_gap;
    features.candidate_complete_match := Ord(candidate_features.complete_match);
    features.candidate_partial_match := Ord(candidate_features.partial_match);
    features.candidate_text_units := candidate_features.text_units;
    features.candidate_comment_length := candidate_features.comment_length;
    features.candidate_unit_delta := candidate_features.unit_delta;
    features.candidate_path_available := Ord(candidate_features.path_available);
    features.candidate_path_confidence_score := candidate_features.path_confidence_score;
    features.candidate_path_confidence_tier := candidate_features.path_confidence_tier;
    features.candidate_path_segments := candidate_features.path_segments;
    features.candidate_path_single_segments := candidate_features.path_single_segments;
    features.candidate_path_max_segment_units := candidate_features.path_max_segment_units;
    features.candidate_char_lm_score := candidate_features.char_lm_score;
    features.candidate_char_lm_suffix_score := candidate_features.char_lm_suffix_score;
    features.candidate_char_lm_context_score := candidate_features.char_lm_context_score;
    features.candidate_char_lm_context_gain := candidate_features.char_lm_context_gain;
    features.candidate_has_left_context := Ord(candidate_features.has_left_context);
    features.candidate_query_choice_bonus := candidate_features.query_choice_bonus;
    features.candidate_latest_query_choice := Ord(candidate_features.latest_query_choice);
    features.candidate_query_path_bonus := candidate_features.query_path_bonus;
    features.candidate_query_path_penalty := candidate_features.query_path_penalty;
    features.candidate_word_lm_bonus := candidate_features.word_lm_bonus;
    features.candidate_word_lm_boundary_count := candidate_features.word_lm_boundary_count;
    features.candidate_word_lm_boundary_min := candidate_features.word_lm_boundary_min;
    features.candidate_word_lm_boundary_max := candidate_features.word_lm_boundary_max;
    features.candidate_word_lm_boundary_first := candidate_features.word_lm_boundary_first;
    features.candidate_word_lm_boundary_last := candidate_features.word_lm_boundary_last;
    features.candidate_word_lm_supported_ratio := candidate_features.word_lm_supported_ratio;
    features.candidate_word_lm_strong_ratio := candidate_features.word_lm_strong_ratio;
    features.candidate_word_lm_trigram_ratio := candidate_features.word_lm_trigram_ratio;
    features.candidate_word_lm_zero_count := candidate_features.word_lm_zero_count;
    features.candidate_input_syllable_count := candidate_features.input_syllable_count;
    features.candidate_score_per_unit := candidate_features.score_per_unit;
    features.candidate_dict_weight_per_unit := candidate_features.dict_weight_per_unit;
    features.candidate_complete_user := Ord(candidate_features.complete_user);
    features.candidate_complete_dictionary := Ord(candidate_features.complete_dictionary);
    features.candidate_complete_chain := Ord(candidate_features.complete_chain);
    features.delta_candidate_score := candidate_features.candidate_score - top_features.candidate_score;
    features.delta_dict_weight := candidate_features.dict_weight - top_features.dict_weight;
    features.delta_has_dict_weight := Ord(candidate_features.has_dict_weight) - Ord(top_features.has_dict_weight);
    features.delta_source_user := Ord(candidate_features.source_user) - Ord(top_features.source_user);
    features.delta_source_chain := Ord(candidate_features.source_chain) - Ord(top_features.source_chain);
    features.delta_source_pattern := Ord(candidate_features.source_pattern) - Ord(top_features.source_pattern);
    features.delta_source_redup := Ord(candidate_features.source_redup) - Ord(top_features.source_redup);
    features.delta_source_local_rerank := Ord(candidate_features.source_local_rerank) - Ord(top_features.source_local_rerank);
    features.delta_source_rule_fallback := Ord(candidate_features.source_rule_fallback) - Ord(top_features.source_rule_fallback);
    features.delta_legacy_rank := candidate_features.legacy_rank - top_features.legacy_rank;
    features.delta_legacy_top := Ord(candidate_features.legacy_top) - Ord(top_features.legacy_top);
    features.delta_chain_rank := candidate_features.chain_rank - top_features.chain_rank;
    features.delta_chain_present := Ord(candidate_features.chain_present) - Ord(top_features.chain_present);
    features.delta_chain_first_stage_score := candidate_features.chain_first_stage_score - top_features.chain_first_stage_score;
    features.delta_chain_second_stage_score := candidate_features.chain_second_stage_score - top_features.chain_second_stage_score;
    features.delta_chain_score_gap := candidate_features.chain_score_gap - top_features.chain_score_gap;
    features.delta_complete_match := Ord(candidate_features.complete_match) - Ord(top_features.complete_match);
    features.delta_partial_match := Ord(candidate_features.partial_match) - Ord(top_features.partial_match);
    features.delta_text_units := candidate_features.text_units - top_features.text_units;
    features.delta_comment_length := candidate_features.comment_length - top_features.comment_length;
    features.delta_unit_delta := candidate_features.unit_delta - top_features.unit_delta;
    features.delta_path_available := Ord(candidate_features.path_available) - Ord(top_features.path_available);
    features.delta_path_confidence_score := candidate_features.path_confidence_score - top_features.path_confidence_score;
    features.delta_path_confidence_tier := candidate_features.path_confidence_tier - top_features.path_confidence_tier;
    features.delta_path_segments := candidate_features.path_segments - top_features.path_segments;
    features.delta_path_single_segments := candidate_features.path_single_segments - top_features.path_single_segments;
    features.delta_path_max_segment_units := candidate_features.path_max_segment_units - top_features.path_max_segment_units;
    features.delta_char_lm_score := candidate_features.char_lm_score - top_features.char_lm_score;
    features.delta_char_lm_suffix_score := candidate_features.char_lm_suffix_score - top_features.char_lm_suffix_score;
    features.delta_char_lm_context_score := candidate_features.char_lm_context_score - top_features.char_lm_context_score;
    features.delta_char_lm_context_gain := candidate_features.char_lm_context_gain - top_features.char_lm_context_gain;
    features.delta_has_left_context := Ord(candidate_features.has_left_context) - Ord(top_features.has_left_context);
    features.delta_query_choice_bonus := candidate_features.query_choice_bonus - top_features.query_choice_bonus;
    features.delta_latest_query_choice := Ord(candidate_features.latest_query_choice) - Ord(top_features.latest_query_choice);
    features.delta_query_path_bonus := candidate_features.query_path_bonus - top_features.query_path_bonus;
    features.delta_query_path_penalty := candidate_features.query_path_penalty - top_features.query_path_penalty;
    features.delta_word_lm_bonus := candidate_features.word_lm_bonus - top_features.word_lm_bonus;
    features.delta_word_lm_boundary_count := candidate_features.word_lm_boundary_count - top_features.word_lm_boundary_count;
    features.delta_word_lm_boundary_min := candidate_features.word_lm_boundary_min - top_features.word_lm_boundary_min;
    features.delta_word_lm_boundary_max := candidate_features.word_lm_boundary_max - top_features.word_lm_boundary_max;
    features.delta_word_lm_boundary_first := candidate_features.word_lm_boundary_first - top_features.word_lm_boundary_first;
    features.delta_word_lm_boundary_last := candidate_features.word_lm_boundary_last - top_features.word_lm_boundary_last;
    features.delta_word_lm_supported_ratio := candidate_features.word_lm_supported_ratio - top_features.word_lm_supported_ratio;
    features.delta_word_lm_strong_ratio := candidate_features.word_lm_strong_ratio - top_features.word_lm_strong_ratio;
    features.delta_word_lm_trigram_ratio := candidate_features.word_lm_trigram_ratio - top_features.word_lm_trigram_ratio;
    features.delta_word_lm_zero_count := candidate_features.word_lm_zero_count - top_features.word_lm_zero_count;
    features.delta_input_syllable_count := candidate_features.input_syllable_count - top_features.input_syllable_count;
    features.delta_score_per_unit := candidate_features.score_per_unit - top_features.score_per_unit;
    features.delta_dict_weight_per_unit := candidate_features.dict_weight_per_unit - top_features.dict_weight_per_unit;
    features.delta_complete_user := Ord(candidate_features.complete_user) - Ord(top_features.complete_user);
    features.delta_complete_dictionary := Ord(candidate_features.complete_dictionary) - Ord(top_features.complete_dictionary);
    features.delta_complete_chain := Ord(candidate_features.complete_chain) - Ord(top_features.complete_chain);
    features.candidate_current_rank := candidate_rank;
    features.candidate_ranker_score := candidate_ranker_score;
    features.candidate_ranker_score_gap := candidate_ranker_score - top_ranker_score;
    features.baseline_ranker_applied := Ord(baseline_ranker_applied);
    features.baseline_abstain_score := baseline_abstain_score;
    features.different_units := different_units;
    features.different_runs := different_runs;
    features.max_different_run := max_different_run;
    features.same_prefix_units := same_prefix_units;
    features.same_suffix_units := same_suffix_units;
    features.difference_span_units := difference_span_units;
    if Length(top_local_lm_scores) > 0 then
        features.top_local_lm_r0 := top_local_lm_scores[0];
    if Length(candidate_local_lm_scores) > 0 then
        features.candidate_local_lm_r0 := candidate_local_lm_scores[0];
    features.delta_local_lm_r0 := features.candidate_local_lm_r0 - features.top_local_lm_r0;
    if Length(top_local_lm_scores) > 1 then
        features.top_local_lm_r1 := top_local_lm_scores[1];
    if Length(candidate_local_lm_scores) > 1 then
        features.candidate_local_lm_r1 := candidate_local_lm_scores[1];
    features.delta_local_lm_r1 := features.candidate_local_lm_r1 - features.top_local_lm_r1;
    if Length(top_local_lm_scores) > 2 then
        features.top_local_lm_r2 := top_local_lm_scores[2];
    if Length(candidate_local_lm_scores) > 2 then
        features.candidate_local_lm_r2 := candidate_local_lm_scores[2];
    features.delta_local_lm_r2 := features.candidate_local_lm_r2 - features.top_local_lm_r2;
    if Length(top_local_lm_scores) > 3 then
        features.top_local_lm_r3 := top_local_lm_scores[3];
    if Length(candidate_local_lm_scores) > 3 then
        features.candidate_local_lm_r3 := candidate_local_lm_scores[3];
    features.delta_local_lm_r3 := features.candidate_local_lm_r3 - features.top_local_lm_r3;
    safe_difference_count := different_units;
    if safe_difference_count <= 0 then safe_difference_count := 1;
    safe_boundary_count := candidate_features.word_lm_boundary_count;
    if safe_boundary_count <= 0 then safe_boundary_count := 1;
    features.delta_char_lm_per_difference :=
        features.delta_char_lm_score / safe_difference_count;
    features.delta_char_suffix_lm_per_difference :=
        features.delta_char_lm_suffix_score / safe_difference_count;
    features.delta_word_lm_per_boundary :=
        features.delta_word_lm_bonus / safe_boundary_count;
end;

function local_difference_tree_0(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -752.49999999999989 then
    begin
        if features.candidate_ranker_score_gap <= -32359049.999999996 then
        begin
            if features.candidate_ranker_score_gap <= -42037349.999999993 then
            begin
                Result := -1.7924765835959633;
            end
            else
            begin
                if features.top_local_lm_r2 <= -6568.4999999999991 then
                begin
                    if features.delta_candidate_score <= -1.0000000180025095E-35 then
                    begin
                        Result := -1.7756733025191909;
                    end
                    else
                    begin
                        Result := -1.6783868475711867;
                    end;
                end
                else
                begin
                    Result := -1.7799295218753728;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -1397.4999999999998 then
            begin
                if features.top_local_lm_r2 <= -6043.4999999999991 then
                begin
                    Result := -1.7018657314730281;
                end
                else
                begin
                    Result := -1.7742981857153701;
                end;
            end
            else
            begin
                if features.candidate_word_lm_boundary_count <= 4.5000000000000009 then
                begin
                    if features.top_local_lm_r1 <= -5468.4999999999991 then
                    begin
                        Result := -1.6559600640282761;
                    end
                    else
                    begin
                        Result := -1.7250876395559631;
                    end;
                end
                else
                begin
                    Result := -1.7263944412997811;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -143728.49999999997 then
        begin
            if features.delta_dict_weight <= -4077.4999999999995 then
            begin
                if features.delta_local_lm_r3 <= -118.49999999999999 then
                begin
                    Result := -1.7664262108879496;
                end
                else
                begin
                    Result := -1.7121985763715619;
                end;
            end
            else
            begin
                if features.delta_char_suffix_lm_per_difference <= -7.7499999999999991 then
                begin
                    Result := -1.7115848439200436;
                end
                else
                begin
                    Result := -1.6487536719999267;
                end;
            end;
        end
        else
        begin
            if features.delta_dict_weight <= -12166.499999999998 then
            begin
                Result := -1.6827618455209927;
            end
            else
            begin
                Result := -1.6369102862008109;
            end;
        end;
    end;
end;

function local_difference_tree_1(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -33957341.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1004.4999999999999 then
        begin
            Result := -0.041040451140719497;
        end
        else
        begin
            if features.delta_dict_weight <= -191.49999999999997 then
            begin
                if features.delta_char_suffix_lm_per_difference <= -45.374999999999993 then
                begin
                    Result := -0.022576325045049948;
                end
                else
                begin
                    Result := 0.027942967876437859;
                end;
            end
            else
            begin
                if features.delta_local_lm_r2 <= -730.49999999999989 then
                begin
                    Result := 0.006285521828777914;
                end
                else
                begin
                    Result := 0.06233057890889257;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -1096.4999999999998 then
        begin
            if features.top_local_lm_r1 <= -5323.4999999999991 then
            begin
                if features.delta_local_lm_r1 <= -945.49999999999989 then
                begin
                    if features.candidate_local_lm_r2 <= -8094.4999999999991 then
                    begin
                        Result := 0.048837081382265349;
                    end
                    else
                    begin
                        Result := -0.0079607121756070497;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r2 <= -6345.4999999999991 then
                    begin
                        Result := 0.097050521021598141;
                    end
                    else
                    begin
                        Result := -0.014801436635487114;
                    end;
                end;
            end
            else
            begin
                Result := -0.025148674612833394;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_local_lm_r2 <= -617.49999999999989 then
                begin
                    Result := 0.0015600511255383746;
                end
                else
                begin
                    Result := 0.05404624464239613;
                end;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    Result := 0.096947227021718554;
                end
                else
                begin
                    if features.candidate_ranker_score_gap <= -21245034.999999996 then
                    begin
                        Result := 0.029310739499091156;
                    end
                    else
                    begin
                        Result := 0.08214903612171813;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_2(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -775.49999999999989 then
    begin
        if features.candidate_ranker_score_gap <= -38716327.999999993 then
        begin
            Result := -0.041450507253212907;
        end
        else
        begin
            if features.top_local_lm_r1 <= -5381.4999999999991 then
            begin
                if features.delta_candidate_score <= -226.49999999999997 then
                begin
                    Result := -0.027653580898315169;
                end
                else
                begin
                    if features.candidate_path_segments <= 5.5000000000000009 then
                    begin
                        if features.top_local_lm_r0 <= -5890.4999999999991 then
                        begin
                            Result := 0.11075765378226474;
                        end
                        else
                        begin
                            Result := 0.035342689240805421;
                        end;
                    end
                    else
                    begin
                        Result := 0.0070502475461974232;
                    end;
                end;
            end
            else
            begin
                if features.delta_local_lm_r2 <= -1630.4999999999998 then
                begin
                    Result := -0.038608580788878653;
                end
                else
                begin
                    Result := 0.0023987941909990392;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= 274528.50000000006 then
        begin
            if features.candidate_ranker_score_gap <= -43128483.999999993 then
            begin
                if features.delta_char_lm_suffix_score <= -80.499999999999986 then
                begin
                    Result := -0.024312822219972108;
                end
                else
                begin
                    Result := 0.038421328197469927;
                end;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    if features.delta_local_lm_r3 <= -329.49999999999994 then
                    begin
                        Result := 0.024204966711024661;
                    end
                    else
                    begin
                        Result := 0.06784717047950109;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -5556.4999999999991 then
                    begin
                        Result := -0.0089187711057750734;
                    end
                    else
                    begin
                        Result := 0.06032967763725558;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_chain_first_stage_score <= -104373.49999999999 then
            begin
                Result := 0.014375073220511167;
            end
            else
            begin
                Result := 0.086085004153479056;
            end;
        end;
    end;
end;

function local_difference_tree_3(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -33509481.999999996 then
    begin
        if features.delta_char_lm_score <= -487.49999999999994 then
        begin
            if features.top_local_lm_r1 <= -6648.4999999999991 then
            begin
                Result := -0.015213574065842466;
            end
            else
            begin
                Result := -0.041384339563354432;
            end;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
            begin
                Result := -0.020885452023379832;
            end
            else
            begin
                if features.delta_dict_weight_per_unit <= -22.499999999999996 then
                begin
                    if features.delta_char_suffix_lm_per_difference <= -45.374999999999993 then
                    begin
                        Result := -0.010721221278021349;
                    end
                    else
                    begin
                        Result := 0.042750528948279562;
                    end;
                end
                else
                begin
                    Result := 0.04813414642224223;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1033.4999999999998 then
        begin
            if features.top_local_lm_r1 <= -4525.4999999999991 then
            begin
                if features.delta_char_lm_score <= -557.49999999999989 then
                begin
                    if features.top_local_lm_r2 <= -6393.4999999999991 then
                    begin
                        Result := 0.038566262264594461;
                    end
                    else
                    begin
                        Result := -0.0089966534467837058;
                    end;
                end
                else
                begin
                    if features.delta_chain_score_gap <= -35876057.999999993 then
                    begin
                        Result := 0.0087640823714814318;
                    end
                    else
                    begin
                        Result := 0.073533217638036386;
                    end;
                end;
            end
            else
            begin
                Result := -0.034587636735482902;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_char_lm_score <= -336.49999999999994 then
                begin
                    Result := -0.0019233878386028475;
                end
                else
                begin
                    Result := 0.046121147248787589;
                end;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    Result := 0.083790819160966298;
                end
                else
                begin
                    Result := 0.041446332330271875;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_4(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -33957341.999999993 then
    begin
        if features.delta_local_lm_r3 <= -887.49999999999989 then
        begin
            Result := -0.040613370245890741;
        end
        else
        begin
            if features.delta_dict_weight <= -191.49999999999997 then
            begin
                if features.delta_char_suffix_lm_per_difference <= -45.374999999999993 then
                begin
                    Result := -0.021462477085660531;
                end
                else
                begin
                    if features.delta_chain_first_stage_score <= -14471.999999999998 then
                    begin
                        Result := -0.0019420311592539567;
                    end
                    else
                    begin
                        Result := 0.053203238892866905;
                    end;
                end;
            end
            else
            begin
                Result := 0.030565675866941776;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -1208.4999999999998 then
        begin
            if features.delta_local_lm_r1 <= -890.49999999999989 then
            begin
                if features.top_local_lm_r3 <= -6141.4999999999991 then
                begin
                    Result := 0.019012737008031619;
                end
                else
                begin
                    Result := -0.024079461620957719;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r3 <= -5983.4999999999991 then
                begin
                    Result := 0.076192416025932061;
                end
                else
                begin
                    Result := -0.031759771150006708;
                end;
            end;
        end
        else
        begin
            if features.candidate_ranker_score_gap <= -30212257.999999996 then
            begin
                if features.delta_local_lm_r2 <= -617.49999999999989 then
                begin
                    Result := -0.0067438031086242212;
                end
                else
                begin
                    Result := 0.044772477803331004;
                end;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    Result := 0.070885829131328112;
                end
                else
                begin
                    if features.candidate_ranker_score_gap <= -13198492.499999998 then
                    begin
                        if features.candidate_local_lm_r1 <= -5743.4999999999991 then
                        begin
                            Result := 0.012994842691653186;
                        end
                        else
                        begin
                            Result := 0.065065588764054563;
                        end;
                    end
                    else
                    begin
                        Result := 0.081999535771735188;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_5(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -887.49999999999989 then
    begin
        if features.candidate_ranker_score_gap <= -31994064.999999996 then
        begin
            Result := -0.039254812494515963;
        end
        else
        begin
            if features.top_local_lm_r2 <= -5188.4999999999991 then
            begin
                if features.delta_local_lm_r1 <= -1784.4999999999998 then
                begin
                    Result := -0.0075344074268223924;
                end
                else
                begin
                    Result := 0.046625780870425959;
                end;
            end
            else
            begin
                Result := -0.024518271647219671;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score_gap <= -39594865.999999993 then
        begin
            if features.delta_char_lm_suffix_score <= -48.499999999999993 then
            begin
                if features.delta_dict_weight <= -196.49999999999997 then
                begin
                    Result := -0.029033686897523947;
                end
                else
                begin
                    Result := 0.01252971122741805;
                end;
            end
            else
            begin
                Result := 0.032056421390589909;
            end;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= -67387571.999999985 then
            begin
                if features.delta_score_per_unit <= -254.99999999999997 then
                begin
                    if features.candidate_local_lm_r0 <= -5162.4999999999991 then
                    begin
                        Result := -0.016293928018174215;
                    end
                    else
                    begin
                        Result := 0.031093013276269867;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r3 <= -464.49999999999994 then
                    begin
                        Result := 0.0080370397299440715;
                    end
                    else
                    begin
                        Result := 0.058156058585283277;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -5138.4999999999991 then
                begin
                    if features.same_prefix_units <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.032761987901706299;
                    end
                    else
                    begin
                        Result := 0.067704534549657275;
                    end;
                end
                else
                begin
                    if features.delta_chain_first_stage_score <= 283.00000000000006 then
                    begin
                        Result := 0.051326910215506762;
                    end
                    else
                    begin
                        Result := -0.0025360844145561248;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_6(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1052.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -31994064.999999996 then
        begin
            Result := -0.038896767330753416;
        end
        else
        begin
            if features.delta_local_lm_r1 <= -890.49999999999989 then
            begin
                if features.top_local_lm_r2 <= -5561.4999999999991 then
                begin
                    Result := 0.016855202033182647;
                end
                else
                begin
                    Result := -0.023620222634958724;
                end;
            end
            else
            begin
                Result := 0.054258951573024738;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score_gap <= -39594865.999999993 then
        begin
            if features.delta_local_lm_r2 <= -111.49999999999999 then
            begin
                if features.candidate_dict_weight_per_unit <= 14565.000000000002 then
                begin
                    Result := -0.023433265742071982;
                end
                else
                begin
                    Result := 0.059330217535844491;
                end;
            end
            else
            begin
                Result := 0.025019810664727141;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 654398.50000000012 then
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    if features.delta_local_lm_r2 <= -617.49999999999989 then
                    begin
                        if features.top_local_lm_r3 <= -7864.9999999999991 then
                        begin
                            Result := 0.12324653866076819;
                        end
                        else
                        begin
                            Result := 0.0075156755958224169;
                        end;
                    end
                    else
                    begin
                        Result := 0.047886420396717554;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -5556.4999999999991 then
                    begin
                        Result := -0.009091406859428346;
                    end
                    else
                    begin
                        Result := 0.050173001457007649;
                    end;
                end;
            end
            else
            begin
                if features.delta_chain_first_stage_score <= -106544.49999999999 then
                begin
                    Result := 0.0088189052062762549;
                end
                else
                begin
                    if features.delta_local_lm_r2 <= -687.49999999999989 then
                    begin
                        Result := 0.041329581987569503;
                    end
                    else
                    begin
                        Result := 0.066462224026267863;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_7(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -38716327.999999993 then
    begin
        if features.delta_char_lm_suffix_score <= -80.499999999999986 then
        begin
            if features.candidate_ranker_score <= -16719468.499999998 then
            begin
                Result := -0.03956243470990245;
            end
            else
            begin
                if features.delta_local_lm_r1 <= -1646.4999999999998 then
                begin
                    Result := -0.034127886409245502;
                end
                else
                begin
                    if features.delta_score_per_unit <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.018510254749826264;
                    end
                    else
                    begin
                        if features.top_local_lm_r3 <= -5531.4999999999991 then
                        begin
                            if features.same_prefix_units <= 1.5000000000000002 then
                            begin
                                Result := -0.019999186404390842;
                            end
                            else
                            begin
                                Result := 0.079990959486914315;
                            end;
                        end
                        else
                        begin
                            Result := -0.026419269860852374;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.034474881917669821;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1297.4999999999998 then
        begin
            if features.top_local_lm_r1 <= -4525.4999999999991 then
            begin
                if features.candidate_path_segments <= 5.5000000000000009 then
                begin
                    if features.top_local_lm_r0 <= -5890.4999999999991 then
                    begin
                        if features.delta_candidate_score <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0014144039967732434;
                        end
                        else
                        begin
                            Result := 0.10248208412396848;
                        end;
                    end
                    else
                    begin
                        Result := 0.0075221522203208534;
                    end;
                end
                else
                begin
                    Result := -0.013056298683029308;
                end;
            end
            else
            begin
                Result := -0.032803783687126206;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                Result := 0.022449903585063026;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    Result := 0.059486723122939414;
                end
                else
                begin
                    Result := 0.031915802293682058;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_8(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -887.49999999999989 then
    begin
        if features.candidate_ranker_score <= -2789148.9999999995 then
        begin
            Result := -0.038275461439440613;
        end
        else
        begin
            if features.top_local_lm_r2 <= -5188.4999999999991 then
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    Result := 0.03195606043505627;
                end
                else
                begin
                    Result := -0.010756630400462226;
                end;
            end
            else
            begin
                Result := -0.024904971800756685;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -3027574.9999999995 then
        begin
            if features.candidate_ranker_score <= -25449907.999999996 then
            begin
                Result := -0.032934704384595032;
            end
            else
            begin
                if features.delta_chain_second_stage_score <= -64648005.999999993 then
                begin
                    Result := -0.0046560170078060788;
                end
                else
                begin
                    if features.delta_char_suffix_lm_per_difference <= -45.374999999999993 then
                    begin
                        if features.delta_candidate_score <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.010807321521943691;
                        end
                        else
                        begin
                            if features.delta_chain_first_stage_score <= 210.50000000000003 then
                            begin
                                if features.delta_char_lm_per_difference <= -447.24999999999994 then
                                begin
                                    Result := 0.0165657402444216;
                                end
                                else
                                begin
                                    Result := 0.084317013219246492;
                                end;
                            end
                            else
                            begin
                                Result := -0.022171715538825309;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.051426780959829367;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= -47910029.999999993 then
            begin
                if features.delta_local_lm_r3 <= -354.49999999999994 then
                begin
                    Result := 0.0081316192318048406;
                end
                else
                begin
                    if features.delta_dict_weight_per_unit <= -538.49999999999989 then
                    begin
                        Result := 0.022764799465829336;
                    end
                    else
                    begin
                        Result := 0.056738116434414038;
                    end;
                end;
            end
            else
            begin
                Result := 0.054184574385752235;
            end;
        end;
    end;
end;

function local_difference_tree_9(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1096.4999999999998 then
    begin
        if features.candidate_ranker_score <= -8652176.4999999981 then
        begin
            Result := -0.040495582252664503;
        end
        else
        begin
            if features.delta_local_lm_r1 <= -890.49999999999989 then
            begin
                if features.top_local_lm_r2 <= -6841.4999999999991 then
                begin
                    Result := 0.05087319820166275;
                end
                else
                begin
                    Result := -0.01949280795271751;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -6345.4999999999991 then
                begin
                    Result := 0.06764629226033872;
                end
                else
                begin
                    Result := -0.011657711738862193;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= 274528.50000000006 then
        begin
            if features.candidate_ranker_score_gap <= -42037349.999999993 then
            begin
                if features.delta_char_lm_suffix_score <= -96.499999999999986 then
                begin
                    if features.delta_dict_weight_per_unit <= 19729.500000000004 then
                    begin
                        Result := -0.025021280188207859;
                    end
                    else
                    begin
                        Result := 0.087830693092761591;
                    end;
                end
                else
                begin
                    Result := 0.023082473941695256;
                end;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    if features.delta_local_lm_r2 <= -542.49999999999989 then
                    begin
                        Result := 0.012666135597477151;
                    end
                    else
                    begin
                        Result := 0.040270263444384773;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -5556.4999999999991 then
                    begin
                        Result := -0.015210405489984417;
                    end
                    else
                    begin
                        Result := 0.038448445736615121;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -209.49999999999997 then
            begin
                Result := 0.010569792742464697;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -4210.9999999999991 then
                begin
                    Result := 0.045567947294173169;
                end
                else
                begin
                    Result := 0.071966141222371174;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_10(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1096.4999999999998 then
    begin
        if features.delta_dict_weight <= 151.50000000000003 then
        begin
            Result := -0.038860052804488759;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -1872.4999999999998 then
            begin
                Result := -0.031857988471921589;
            end
            else
            begin
                if features.delta_local_lm_r1 <= -776.49999999999989 then
                begin
                    if features.top_local_lm_r3 <= -6363.4999999999991 then
                    begin
                        Result := 0.03308450409255187;
                    end
                    else
                    begin
                        Result := -0.010378329070713326;
                    end;
                end
                else
                begin
                    Result := 0.042076793698532129;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_dict_weight <= -6985.9999999999991 then
        begin
            if features.delta_local_lm_r2 <= -491.49999999999994 then
            begin
                Result := -0.024104411847289106;
            end
            else
            begin
                if features.candidate_local_lm_r1 <= -6543.4999999999991 then
                begin
                    Result := 0.0011724234860121157;
                end
                else
                begin
                    if features.delta_word_lm_supported_ratio <= -53.499999999999993 then
                    begin
                        Result := 0.0041615887515782553;
                    end
                    else
                    begin
                        if features.delta_char_lm_score <= -281.49999999999994 then
                        begin
                            Result := -0.024346468422763591;
                        end
                        else
                        begin
                            Result := 0.059386459622820721;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -666.49999999999989 then
            begin
                if features.delta_chain_second_stage_score <= -41894299.999999993 then
                begin
                    Result := -0.0031004937020296087;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -6762.4999999999991 then
                    begin
                        Result := 0.05106608633907217;
                    end
                    else
                    begin
                        Result := 0.0078301523923984245;
                    end;
                end;
            end
            else
            begin
                if features.delta_word_lm_bonus <= -231.49999999999997 then
                begin
                    Result := 0.012943355627602239;
                end
                else
                begin
                    Result := 0.049227004631138611;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_11(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -887.49999999999989 then
    begin
        if features.delta_dict_weight <= 151.50000000000003 then
        begin
            Result := -0.038571100327158991;
        end
        else
        begin
            if features.delta_local_lm_r1 <= -1646.4999999999998 then
            begin
                if features.top_local_lm_r2 <= -6448.4999999999991 then
                begin
                    if features.delta_dict_weight_per_unit <= 1373.0000000000002 then
                    begin
                        Result := 0.085119089290979777;
                    end
                    else
                    begin
                        Result := -0.013162669462522383;
                    end;
                end
                else
                begin
                    Result := -0.034651879889282027;
                end;
            end
            else
            begin
                if features.top_local_lm_r2 <= -4572.4999999999991 then
                begin
                    if features.difference_span_units <= 2.5000000000000004 then
                    begin
                        if features.candidate_local_lm_r3 <= -6199.4999999999991 then
                        begin
                            Result := 0.052584848300021338;
                        end
                        else
                        begin
                            Result := -0.0045672752069020311;
                        end;
                    end
                    else
                    begin
                        Result := -0.023293607423698494;
                    end;
                end
                else
                begin
                    Result := -0.029161750678931866;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_chain_score_gap <= -100578879.99999999 then
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                Result := 0.012408855951458414;
            end
            else
            begin
                Result := -0.01599388516968259;
            end;
        end
        else
        begin
            if features.delta_path_segments <= -1.4999999999999998 then
            begin
                if features.delta_char_lm_score <= -281.49999999999994 then
                begin
                    Result := -0.025397466978672831;
                end
                else
                begin
                    Result := 0.023414786037753328;
                end;
            end
            else
            begin
                if features.candidate_chain_score_gap <= -49871783.999999993 then
                begin
                    if features.delta_path_max_segment_units <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.038742549587732322;
                    end
                    else
                    begin
                        Result := 0.026637998011841156;
                    end;
                end
                else
                begin
                    Result := 0.042547760582799771;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_12(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -887.49999999999989 then
    begin
        if features.candidate_ranker_score_gap <= -38716327.999999993 then
        begin
            Result := -0.03893144270445164;
        end
        else
        begin
            if features.top_local_lm_r1 <= -4740.4999999999991 then
            begin
                if features.candidate_path_segments <= 3.5000000000000004 then
                begin
                    Result := 0.046322847700817744;
                end
                else
                begin
                    if features.top_local_lm_r2 <= -5814.4999999999991 then
                    begin
                        if features.delta_candidate_score <= -199.49999999999997 then
                        begin
                            Result := -0.026971820402401672;
                        end
                        else
                        begin
                            if features.candidate_word_lm_zero_count <= 3.5000000000000004 then
                            begin
                                Result := 0.056443467400005283;
                            end
                            else
                            begin
                                Result := 0.00046705249927064384;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.014525222325781458;
                    end;
                end;
            end
            else
            begin
                Result := -0.033636634472210714;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score_gap <= -39594865.999999993 then
        begin
            if features.delta_word_lm_per_boundary <= -1.0000000180025095E-35 then
            begin
                Result := -0.02692075698272962;
            end
            else
            begin
                Result := 0.0032188050838592754;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r1 <= -5262.4999999999991 then
                begin
                    Result := 0.042864537144613364;
                end
                else
                begin
                    if features.delta_char_lm_score <= -129.49999999999997 then
                    begin
                        Result := 0.0039984063827841546;
                    end
                    else
                    begin
                        Result := 0.045301977694221417;
                    end;
                end;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -20610524.999999996 then
                begin
                    if features.candidate_local_lm_r1 <= -5858.4999999999991 then
                    begin
                        Result := -0.010458760003214369;
                    end
                    else
                    begin
                        Result := 0.035790803194491808;
                    end;
                end
                else
                begin
                    Result := 0.040710090261868184;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_13(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -39199623.999999993 then
    begin
        if features.delta_local_lm_r2 <= -868.49999999999989 then
        begin
            Result := -0.038085866794910599;
        end
        else
        begin
            if features.delta_char_lm_suffix_score <= -35.499999999999993 then
            begin
                if features.delta_dict_weight <= -207.49999999999997 then
                begin
                    Result := -0.022499588750982676;
                end
                else
                begin
                    Result := 0.023862599813324895;
                end;
            end
            else
            begin
                Result := 0.026669524356823182;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -1327.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -5910.4999999999991 then
            begin
                Result := 0.018867747941085419;
            end
            else
            begin
                if features.delta_local_lm_r1 <= -919.49999999999989 then
                begin
                    Result := -0.02826517658567362;
                end
                else
                begin
                    if features.candidate_local_lm_r3 <= -5983.4999999999991 then
                    begin
                        Result := 0.064518440905930036;
                    end
                    else
                    begin
                        Result := -0.033131403208595214;
                    end;
                end;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_chain_first_stage_score <= 645.50000000000011 then
                begin
                    Result := 0.020476685615747083;
                end
                else
                begin
                    Result := -0.016280520098100108;
                end;
            end
            else
            begin
                if features.delta_chain_second_stage_score <= -36020725.999999993 then
                begin
                    if features.delta_local_lm_r2 <= -491.49999999999994 then
                    begin
                        Result := 0.0076685303666890374;
                    end
                    else
                    begin
                        Result := 0.0356876338785539;
                    end;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -5041.4999999999991 then
                    begin
                        if features.delta_char_lm_per_difference <= 341.50000000000006 then
                        begin
                            Result := 0.05175235117433892;
                        end
                        else
                        begin
                            Result := -0.010325502257582898;
                        end;
                    end
                    else
                    begin
                        Result := 0.019945521233933821;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_14(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -38716327.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1004.4999999999999 then
        begin
            Result := -0.037813911888598201;
        end
        else
        begin
            if features.delta_char_lm_context_score <= -48.499999999999993 then
            begin
                if features.delta_dict_weight <= -196.49999999999997 then
                begin
                    Result := -0.022503861020844989;
                end
                else
                begin
                    Result := 0.015303324144335053;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -6310.4999999999991 then
                begin
                    Result := 0.0050939144692637274;
                end
                else
                begin
                    Result := 0.062623358363118276;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1646.4999999999998 then
        begin
            if features.top_local_lm_r0 <= -5670.4999999999991 then
            begin
                Result := 0.016597435447455809;
            end
            else
            begin
                Result := -0.021488860365944721;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.delta_local_lm_r1 <= -890.49999999999989 then
                begin
                    if features.candidate_local_lm_r1 <= -6260.4999999999991 then
                    begin
                        if features.delta_path_max_segment_units <= -1.4999999999999998 then
                        begin
                            Result := 0.076667260399852402;
                        end
                        else
                        begin
                            Result := 0.022822299971460295;
                        end;
                    end
                    else
                    begin
                        Result := -0.017951683792202456;
                    end;
                end
                else
                begin
                    Result := 0.038384156284587537;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -5162.4999999999991 then
                begin
                    if features.candidate_ranker_score <= 8958131.5000000019 then
                    begin
                        Result := -0.016932671941271946;
                    end
                    else
                    begin
                        Result := 0.028508262404465814;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_score <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.014749336705695846;
                    end
                    else
                    begin
                        Result := 0.062980320818869617;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_15(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -39594865.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1074.4999999999998 then
        begin
            Result := -0.03960169754537847;
        end
        else
        begin
            if features.delta_dict_weight <= -196.49999999999997 then
            begin
                if features.delta_char_lm_suffix_score <= -96.499999999999986 then
                begin
                    Result := -0.025439982396838406;
                end
                else
                begin
                    Result := 0.0091579370731199455;
                end;
            end
            else
            begin
                Result := 0.017667985119726545;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1646.4999999999998 then
        begin
            if features.delta_local_lm_r3 <= -1372.4999999999998 then
            begin
                if features.top_local_lm_r2 <= -6067.4999999999991 then
                begin
                    Result := 0.017089437233562529;
                end
                else
                begin
                    Result := -0.036096687516338405;
                end;
            end
            else
            begin
                Result := 0.0029495126461983583;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_local_lm_r3 <= -464.49999999999994 then
                begin
                    if features.top_local_lm_r0 <= -6540.4999999999991 then
                    begin
                        Result := 0.045928902537998972;
                    end
                    else
                    begin
                        Result := -0.0081819940162283396;
                    end;
                end
                else
                begin
                    Result := 0.023383712092484316;
                end;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    if features.top_local_lm_r1 <= -5409.4999999999991 then
                    begin
                        Result := 0.042045814631221971;
                    end
                    else
                    begin
                        if features.delta_char_lm_per_difference <= -155.70833587646482 then
                        begin
                            Result := 0.00054519452550236269;
                        end
                        else
                        begin
                            Result := 0.041789202415079267;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r2 <= -687.49999999999989 then
                    begin
                        Result := -0.0048060929396833429;
                    end
                    else
                    begin
                        Result := 0.029779066756711391;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_16(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -39594865.999999993 then
    begin
        if features.delta_local_lm_r2 <= -730.49999999999989 then
        begin
            if features.top_local_lm_r1 <= -6648.4999999999991 then
            begin
                if features.candidate_score_per_unit <= 20277.000000000004 then
                begin
                    Result := -0.025469945624517067;
                end
                else
                begin
                    Result := 0.045501963630968714;
                end;
            end
            else
            begin
                Result := -0.03886963813016369;
            end;
        end
        else
        begin
            if features.delta_candidate_score <= -4782.4999999999991 then
            begin
                Result := -0.023384423850013152;
            end
            else
            begin
                Result := 0.010847192783563133;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1646.4999999999998 then
        begin
            if features.delta_local_lm_r2 <= -2062.4999999999995 then
            begin
                Result := -0.033551874629228616;
            end
            else
            begin
                Result := -0.0051277881252496113;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_local_lm_r2 <= -617.49999999999989 then
                begin
                    if features.top_local_lm_r0 <= -5958.4999999999991 then
                    begin
                        Result := 0.031199416560234932;
                    end
                    else
                    begin
                        Result := -0.012632078239921114;
                    end;
                end
                else
                begin
                    if features.delta_score_per_unit <= -560.49999999999989 then
                    begin
                        Result := 0.0042326232620505892;
                    end
                    else
                    begin
                        if features.delta_chain_first_stage_score <= 645.50000000000011 then
                        begin
                            Result := 0.038788826537628947;
                        end
                        else
                        begin
                            Result := -0.0076882771497455296;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    if features.candidate_local_lm_r2 <= -6983.4999999999991 then
                    begin
                        Result := 0.045835800267956472;
                    end
                    else
                    begin
                        Result := 0.028148457422873412;
                    end;
                end
                else
                begin
                    Result := 0.017258726346242519;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_17(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -39594865.999999993 then
    begin
        if features.delta_local_lm_r2 <= -868.49999999999989 then
        begin
            Result := -0.036942260623106439;
        end
        else
        begin
            if features.delta_dict_weight <= -207.49999999999997 then
            begin
                if features.delta_char_lm_suffix_score <= -80.499999999999986 then
                begin
                    Result := -0.023447378013919811;
                end
                else
                begin
                    Result := 0.013026134526820167;
                end;
            end
            else
            begin
                Result := 0.031387696624859372;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1815.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -6448.4999999999991 then
            begin
                if features.candidate_local_lm_r1 <= -8421.4999999999982 then
                begin
                    Result := 0.066221237983445994;
                end
                else
                begin
                    Result := -0.0095115303543263849;
                end;
            end
            else
            begin
                Result := -0.026096723520540339;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_local_lm_r2 <= -617.49999999999989 then
                begin
                    if features.candidate_local_lm_r2 <= -7865.4999999999991 then
                    begin
                        Result := 0.033265449793550943;
                    end
                    else
                    begin
                        Result := -0.011752460401126852;
                    end;
                end
                else
                begin
                    if features.delta_score_per_unit <= -85.499999999999986 then
                    begin
                        Result := 0.005721084779529209;
                    end
                    else
                    begin
                        Result := 0.029961306283991122;
                    end;
                end;
            end
            else
            begin
                if features.delta_local_lm_r1 <= -890.49999999999989 then
                begin
                    if features.candidate_local_lm_r1 <= -6331.4999999999991 then
                    begin
                        if features.candidate_word_lm_boundary_count <= 5.5000000000000009 then
                        begin
                            Result := 0.038492509983746807;
                        end
                        else
                        begin
                            Result := 0.00060430016491647923;
                        end;
                    end
                    else
                    begin
                        Result := -0.01516888951182069;
                    end;
                end
                else
                begin
                    Result := 0.034408454649756892;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_18(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1139.4999999999998 then
    begin
        if features.candidate_ranker_score <= -8353014.4999999991 then
        begin
            Result := -0.03740655679729029;
        end
        else
        begin
            if features.top_local_lm_r2 <= -5910.4999999999991 then
            begin
                if features.candidate_path_segments <= 5.5000000000000009 then
                begin
                    Result := 0.041102333141496687;
                end
                else
                begin
                    Result := -0.0060516219213280747;
                end;
            end
            else
            begin
                if features.delta_local_lm_r1 <= -919.49999999999989 then
                begin
                    Result := -0.023977666235423314;
                end
                else
                begin
                    if features.candidate_local_lm_r2 <= -6345.4999999999991 then
                    begin
                        Result := 0.040012087226882244;
                    end
                    else
                    begin
                        Result := -0.020974657901238015;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -12161763.499999998 then
        begin
            if features.delta_char_lm_suffix_score <= -80.499999999999986 then
            begin
                Result := -0.020600348124623205;
            end
            else
            begin
                Result := 0.021774554259613135;
            end;
        end
        else
        begin
            if features.candidate_chain_score_gap <= -62682389.999999993 then
            begin
                if features.delta_score_per_unit <= -560.49999999999989 then
                begin
                    if features.candidate_local_lm_r0 <= -4853.4999999999991 then
                    begin
                        Result := -0.016894001111492123;
                    end
                    else
                    begin
                        Result := 0.021636880449792086;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_per_difference <= -108.41666793823241 then
                    begin
                        Result := 0.006450427895324796;
                    end
                    else
                    begin
                        Result := 0.033050210193582431;
                    end;
                end;
            end
            else
            begin
                if features.same_prefix_units <= 1.0000000180025095E-35 then
                begin
                    Result := 0.010083006420197545;
                end
                else
                begin
                    if features.delta_word_lm_bonus <= -221.49999999999997 then
                    begin
                        Result := 0.0011391842028843021;
                    end
                    else
                    begin
                        Result := 0.034115907608305539;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_19(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -39594865.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1074.4999999999998 then
        begin
            Result := -0.03794814000039242;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
            begin
                Result := -0.023825519885138008;
            end
            else
            begin
                Result := 0.003610930976530838;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1646.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -6393.4999999999991 then
            begin
                if features.candidate_word_lm_zero_count <= 2.5000000000000004 then
                begin
                    Result := 0.044267715864450462;
                end
                else
                begin
                    Result := -0.018287834379334404;
                end;
            end
            else
            begin
                if features.delta_char_lm_score <= -885.49999999999989 then
                begin
                    Result := -0.032415829086699897;
                end
                else
                begin
                    if features.delta_path_max_segment_units <= -3.4999999999999996 then
                    begin
                        Result := 0.07266232246421421;
                    end
                    else
                    begin
                        Result := -0.011560991812104031;
                    end;
                end;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 3663511.5000000005 then
            begin
                if features.delta_local_lm_r2 <= -542.49999999999989 then
                begin
                    if features.candidate_local_lm_r3 <= -7373.4999999999991 then
                    begin
                        if features.delta_candidate_score <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0049438203223630909;
                        end
                        else
                        begin
                            Result := 0.052480212139107689;
                        end;
                    end
                    else
                    begin
                        Result := -0.0075626968817713008;
                    end;
                end
                else
                begin
                    if features.candidate_chain_first_stage_score <= 56172.500000000007 then
                    begin
                        Result := 0.033599460389257658;
                    end
                    else
                    begin
                        Result := 0.010440187014876888;
                    end;
                end;
            end
            else
            begin
                if features.delta_word_lm_bonus <= -221.49999999999997 then
                begin
                    Result := -0.011256534040949678;
                end
                else
                begin
                    Result := 0.031429827835260264;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_20(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1208.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -38716327.999999993 then
        begin
            Result := -0.037346136486449202;
        end
        else
        begin
            if features.top_local_lm_r0 <= -5855.4999999999991 then
            begin
                if features.candidate_path_single_segments <= 1.0000000180025095E-35 then
                begin
                    Result := 0.071234108660032811;
                end
                else
                begin
                    Result := 0.0069841931181702137;
                end;
            end
            else
            begin
                Result := -0.015149373868422435;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score_gap <= -43128483.999999993 then
        begin
            if features.delta_local_lm_r2 <= -23.499999999999996 then
            begin
                Result := -0.020823949885773362;
            end
            else
            begin
                Result := 0.025505854945880736;
            end;
        end
        else
        begin
            if features.candidate_chain_score_gap <= -62682389.999999993 then
            begin
                if features.candidate_local_lm_r0 <= -5397.4999999999991 then
                begin
                    if features.candidate_local_lm_r1 <= -5408.4999999999991 then
                    begin
                        if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                        begin
                            if features.delta_local_lm_r0 <= -698.49999999999989 then
                            begin
                                Result := -0.01396286306270028;
                            end
                            else
                            begin
                                Result := 0.02677474437206746;
                            end;
                        end
                        else
                        begin
                            Result := -0.029150913245370988;
                        end;
                    end
                    else
                    begin
                        Result := 0.037052736579489258;
                    end;
                end
                else
                begin
                    if features.delta_chain_first_stage_score <= 156.50000000000003 then
                    begin
                        if features.candidate_chain_second_stage_score <= 308414368.00000006 then
                        begin
                            Result := 0.02966376854136258;
                        end
                        else
                        begin
                            Result := -0.022713297832008247;
                        end;
                    end
                    else
                    begin
                        Result := -0.021704628743058358;
                    end;
                end;
            end
            else
            begin
                if features.delta_local_lm_r2 <= -687.49999999999989 then
                begin
                    Result := 0.015657141783044379;
                end
                else
                begin
                    Result := 0.030395355253665813;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_21(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1208.4999999999998 then
    begin
        if features.candidate_ranker_score <= -8353014.4999999991 then
        begin
            Result := -0.037379093184997152;
        end
        else
        begin
            if features.top_local_lm_r2 <= -5814.4999999999991 then
            begin
                if features.candidate_word_lm_boundary_count <= 4.5000000000000009 then
                begin
                    Result := 0.033142632210789988;
                end
                else
                begin
                    Result := -0.017614109635732983;
                end;
            end
            else
            begin
                Result := -0.018574833130654674;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -12161763.499999998 then
        begin
            if features.delta_char_suffix_lm_per_difference <= -35.833333969116204 then
            begin
                if features.delta_dict_weight_per_unit <= 19729.500000000004 then
                begin
                    Result := -0.019868826135195597;
                end
                else
                begin
                    Result := 0.068200362015616356;
                end;
            end
            else
            begin
                Result := 0.020775609602352318;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r1 <= -4915.4999999999991 then
                begin
                    if features.same_prefix_units <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0077017232036791219;
                    end
                    else
                    begin
                        Result := 0.029449660590570852;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r1 <= -720.49999999999989 then
                    begin
                        Result := -0.013181124111241361;
                    end
                    else
                    begin
                        Result := 0.022328600209354912;
                    end;
                end;
            end
            else
            begin
                if features.candidate_ranker_score <= 7979596.5000000009 then
                begin
                    if features.candidate_local_lm_r1 <= -5631.4999999999991 then
                    begin
                        Result := -0.012498265067556903;
                    end
                    else
                    begin
                        Result := 0.030347489220898194;
                    end;
                end
                else
                begin
                    if features.candidate_word_lm_boundary_last <= 1258.5000000000002 then
                    begin
                        Result := 0.044142716158780397;
                    end
                    else
                    begin
                        Result := -0.011215567749820755;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_22(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_char_suffix_lm_per_difference <= -45.374999999999993 then
        begin
            Result := -0.034505143811955734;
        end
        else
        begin
            Result := 0.017761789050780821;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -1714.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -5910.4999999999991 then
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    Result := 0.0014251073795449203;
                end
                else
                begin
                    Result := 0.13075396594014305;
                end;
            end
            else
            begin
                Result := -0.029920681450487808;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_chain_first_stage_score <= 283.00000000000006 then
                begin
                    if features.delta_score_per_unit <= 3348.0000000000005 then
                    begin
                        if features.delta_dict_weight <= -4077.4999999999995 then
                        begin
                            if features.delta_local_lm_r1 <= -566.49999999999989 then
                            begin
                                Result := -0.027008887870574712;
                            end
                            else
                            begin
                                if features.delta_dict_weight_per_unit <= -6690.9999999999991 then
                                begin
                                    Result := 0.031375690046812836;
                                end
                                else
                                begin
                                    Result := -0.0040265389889030659;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.top_local_lm_r2 <= -6477.4999999999991 then
                            begin
                                if features.same_suffix_units <= 6.5000000000000009 then
                                begin
                                    Result := 0.042613078191311646;
                                end
                                else
                                begin
                                    Result := 0.0012206326484787181;
                                end;
                            end
                            else
                            begin
                                Result := 0.0080350261603399139;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.086618884716891581;
                    end;
                end
                else
                begin
                    Result := -0.016735806659364309;
                end;
            end
            else
            begin
                if features.delta_chain_first_stage_score <= -106544.49999999999 then
                begin
                    Result := -0.01540439503169347;
                end
                else
                begin
                    Result := 0.024621657676626704;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_23(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.039205375419620672;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
            begin
                Result := -0.028266071751848521;
            end
            else
            begin
                Result := 0.0052084753770615094;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1646.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -5137.4999999999991 then
            begin
                Result := -0.0043746446098839875;
            end
            else
            begin
                Result := -0.031469260018123307;
            end;
        end
        else
        begin
            if features.delta_candidate_score <= -7391.4999999999991 then
            begin
                if features.candidate_local_lm_r2 <= -7216.4999999999991 then
                begin
                    Result := -0.019428046383698962;
                end
                else
                begin
                    Result := 0.0099906849128335862;
                end;
            end
            else
            begin
                if features.top_local_lm_r2 <= -5660.4999999999991 then
                begin
                    if features.candidate_word_lm_zero_count <= 1.5000000000000002 then
                    begin
                        if features.delta_char_lm_per_difference <= 341.50000000000006 then
                        begin
                            Result := 0.048924134984213205;
                        end
                        else
                        begin
                            Result := -0.0081957771005411566;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r0 <= -1576.4999999999998 then
                        begin
                            if features.different_units <= 1.5000000000000002 then
                            begin
                                Result := 0.031256676091342819;
                            end
                            else
                            begin
                                Result := -0.028864907142129144;
                            end;
                        end
                        else
                        begin
                            Result := 0.024109263817403258;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_score <= -79.499999999999986 then
                    begin
                        if features.delta_local_lm_r0 <= -385.49999999999994 then
                        begin
                            Result := -0.013865711952096715;
                        end
                        else
                        begin
                            Result := 0.012414736144896847;
                        end;
                    end
                    else
                    begin
                        Result := 0.040342781687727411;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_24(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.038977546587446316;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
            begin
                Result := -0.024465490563258575;
            end
            else
            begin
                Result := 0.0072671261411366619;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -1372.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -5910.4999999999991 then
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    Result := 0.0043427198341300446;
                end
                else
                begin
                    Result := 0.10698027893388395;
                end;
            end
            else
            begin
                Result := -0.027621471071714178;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.delta_local_lm_r1 <= -1033.4999999999998 then
                begin
                    if features.candidate_local_lm_r2 <= -8122.4999999999991 then
                    begin
                        Result := 0.037435586212602859;
                    end
                    else
                    begin
                        if features.delta_chain_second_stage_score <= -18530434.999999996 then
                        begin
                            Result := -0.013995001500233663;
                        end
                        else
                        begin
                            Result := 0.013150039853157096;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.022210947251098383;
                end;
            end
            else
            begin
                if features.candidate_ranker_score <= 7979596.5000000009 then
                begin
                    if features.candidate_local_lm_r1 <= -5556.4999999999991 then
                    begin
                        Result := -0.013462860547881102;
                    end
                    else
                    begin
                        if features.delta_local_lm_r2 <= -434.49999999999994 then
                        begin
                            Result := -0.023123383320246813;
                        end
                        else
                        begin
                            Result := 0.041111952455373982;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_per_difference <= -447.24999999999994 then
                    begin
                        Result := -0.0042062143654609642;
                    end
                    else
                    begin
                        Result := 0.036634924372507011;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_25(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -943.49999999999989 then
    begin
        if features.candidate_ranker_score <= -16719468.499999998 then
        begin
            Result := -0.038702955456321401;
        end
        else
        begin
            if features.top_local_lm_r2 <= -5137.4999999999991 then
            begin
                if features.candidate_path_segments <= 5.5000000000000009 then
                begin
                    if features.delta_candidate_score <= -1.0000000180025095E-35 then
                    begin
                        if features.candidate_word_lm_bonus <= 434.50000000000006 then
                        begin
                            Result := -0.018550028436589986;
                        end
                        else
                        begin
                            Result := 0.10299821439825191;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r1 <= -5528.4999999999991 then
                        begin
                            if features.same_prefix_units <= 1.5000000000000002 then
                            begin
                                Result := -0.018966024534974039;
                            end
                            else
                            begin
                                if features.same_suffix_units <= 1.5000000000000002 then
                                begin
                                    if features.candidate_path_single_segments <= 1.0000000180025095E-35 then
                                    begin
                                        Result := 0.1489686563033876;
                                    end
                                    else
                                    begin
                                        Result := 0.046004429766663933;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.034567908600683442;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.0059719157989545461;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.012154689531449134;
                end;
            end
            else
            begin
                Result := -0.027630692617336416;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= 274528.50000000006 then
        begin
            if features.candidate_ranker_score <= -25449907.999999996 then
            begin
                Result := -0.027951729045632218;
            end
            else
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    Result := 0.01076490018683394;
                end
                else
                begin
                    if features.delta_char_lm_per_difference <= 62.166666030883796 then
                    begin
                        Result := -0.017082492023255569;
                    end
                    else
                    begin
                        Result := 0.023625550747709084;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.021544778433245121;
        end;
    end;
end;

function local_difference_tree_26(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.038698439699739885;
        end
        else
        begin
            if features.delta_dict_weight <= -109457.49999999999 then
            begin
                Result := -0.029077677539478493;
            end
            else
            begin
                if features.candidate_score_per_unit <= 14243.500000000002 then
                begin
                    Result := -0.0043944936709806922;
                end
                else
                begin
                    Result := 0.053639941881927299;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1815.4999999999998 then
        begin
            Result := -0.018241740472448198;
        end
        else
        begin
            if features.delta_score_per_unit <= -451.49999999999994 then
            begin
                if features.candidate_ranker_score_gap <= -30212257.999999996 then
                begin
                    if features.delta_char_lm_per_difference <= 62.166666030883796 then
                    begin
                        Result := -0.014927975433401105;
                    end
                    else
                    begin
                        Result := 0.033900503435051646;
                    end;
                end
                else
                begin
                    Result := 0.014013083895978527;
                end;
            end
            else
            begin
                if features.top_local_lm_r2 <= -5164.4999999999991 then
                begin
                    if features.candidate_word_lm_boundary_count <= 1.0000000180025095E-35 then
                    begin
                        if features.same_prefix_units <= 1.5000000000000002 then
                        begin
                            if features.candidate_dict_weight_per_unit <= 29415.000000000004 then
                            begin
                                Result := -0.0021261020612978847;
                            end
                            else
                            begin
                                Result := 0.07683141814038788;
                            end;
                        end
                        else
                        begin
                            Result := 0.044917488649634685;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r0 <= -1622.4999999999998 then
                        begin
                            if features.different_units <= 1.5000000000000002 then
                            begin
                                Result := 0.022514666757208607;
                            end
                            else
                            begin
                                Result := -0.02744733378943812;
                            end;
                        end
                        else
                        begin
                            Result := 0.019310847990373449;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.00090028594504630859;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_27(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.038091854494092227;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
            begin
                Result := -0.024725401234892971;
            end
            else
            begin
                Result := 0.0068331474579790153;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -1794.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -5910.4999999999991 then
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    Result := 0.0084402906402768901;
                end
                else
                begin
                    Result := 0.12375064476628028;
                end;
            end
            else
            begin
                Result := -0.030762588652991703;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_char_suffix_lm_per_difference <= -7.7499999999999991 then
                begin
                    if features.delta_candidate_score <= -8645.4999999999982 then
                    begin
                        Result := -0.017972752291455701;
                    end
                    else
                    begin
                        if features.top_local_lm_r2 <= -6448.4999999999991 then
                        begin
                            if features.candidate_score_per_unit <= 17418.500000000004 then
                            begin
                                Result := 0.010714372865645144;
                            end
                            else
                            begin
                                Result := 0.051105143660715488;
                            end;
                        end
                        else
                        begin
                            if features.delta_local_lm_r2 <= -377.49999999999994 then
                            begin
                                Result := -0.011150517738437627;
                            end
                            else
                            begin
                                Result := 0.022210476316563175;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -6516.4999999999991 then
                    begin
                        Result := 0.0033187198798299926;
                    end
                    else
                    begin
                        if features.candidate_chain_first_stage_score <= 30224.000000000004 then
                        begin
                            Result := 0.078872776672588046;
                        end
                        else
                        begin
                            Result := 0.024727258247714282;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.019342424424560425;
            end;
        end;
    end;
end;

function local_difference_tree_28(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r3 <= -599.49999999999989 then
        begin
            Result := -0.035652669468047717;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= -33143027.999999996 then
            begin
                Result := -0.023752544349596904;
            end
            else
            begin
                Result := 0.018604302329953887;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -1372.4999999999998 then
        begin
            if features.top_local_lm_r1 <= -5350.4999999999991 then
            begin
                if features.same_suffix_units <= 1.5000000000000002 then
                begin
                    if features.delta_candidate_score <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.019506647999052964;
                    end
                    else
                    begin
                        if features.candidate_path_single_segments <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.11659972195355485;
                        end
                        else
                        begin
                            Result := 0.02216174588322161;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.016590810683608882;
                end;
            end
            else
            begin
                Result := -0.033449148644034241;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r1 <= -4740.4999999999991 then
                begin
                    if features.candidate_source_local_rerank <= 1.0000000180025095E-35 then
                    begin
                        if features.candidate_ranker_score <= 3716149.5000000005 then
                        begin
                            Result := 0.015153805231780096;
                        end
                        else
                        begin
                            Result := 0.027684372496173719;
                        end;
                    end
                    else
                    begin
                        Result := -0.020459031306441573;
                    end;
                end
                else
                begin
                    Result := -0.0018480493655536592;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r1 <= -5408.4999999999991 then
                begin
                    if features.candidate_ranker_score_gap <= -22190821.999999996 then
                    begin
                        Result := -0.015991377644861384;
                    end
                    else
                    begin
                        Result := 0.015009131364732618;
                    end;
                end
                else
                begin
                    Result := 0.026546937784639801;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_29(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.038013220468793511;
        end
        else
        begin
            Result := -0.0071419123129538463;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -2031.4999999999998 then
        begin
            if features.delta_candidate_score <= 42869.000000000007 then
            begin
                Result := -0.031843503202819076;
            end
            else
            begin
                if features.candidate_dict_weight <= 104256.50000000001 then
                begin
                    Result := 0.10070138948013378;
                end
                else
                begin
                    Result := -0.032514895618056802;
                end;
            end;
        end
        else
        begin
            if features.delta_candidate_score <= -8645.4999999999982 then
            begin
                if features.candidate_local_lm_r2 <= -7412.4999999999991 then
                begin
                    if features.top_local_lm_r0 <= -3971.4999999999995 then
                    begin
                        Result := -0.030856398751077541;
                    end
                    else
                    begin
                        Result := 0.06836829625251975;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_per_difference <= -87.833332061767564 then
                    begin
                        Result := -0.0078320346604913282;
                    end
                    else
                    begin
                        Result := 0.019539775844396055;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -4740.4999999999991 then
                begin
                    if features.candidate_dict_weight_per_unit <= 14331.000000000002 then
                    begin
                        if features.delta_char_lm_score <= -265.49999999999994 then
                        begin
                            if features.candidate_word_lm_zero_count <= 3.5000000000000004 then
                            begin
                                Result := 0.015497254114600402;
                            end
                            else
                            begin
                                Result := -0.0047359833560661306;
                            end;
                        end
                        else
                        begin
                            Result := 0.022647468449207845;
                        end;
                    end
                    else
                    begin
                        Result := 0.034962372623996457;
                    end;
                end
                else
                begin
                    if features.delta_char_suffix_lm_per_difference <= -45.374999999999993 then
                    begin
                        Result := -0.013088928933527942;
                    end
                    else
                    begin
                        Result := 0.026939372364868021;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_30(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -1052.4999999999998 then
        begin
            Result := -0.037506921324531692;
        end
        else
        begin
            if features.delta_dict_weight <= -109457.49999999999 then
            begin
                Result := -0.029550910146425746;
            end
            else
            begin
                if features.candidate_score_per_unit <= 20277.000000000004 then
                begin
                    Result := -0.0015598531888714824;
                end
                else
                begin
                    Result := 0.074398041631059175;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -2062.4999999999995 then
        begin
            if features.top_local_lm_r3 <= -6521.4999999999991 then
            begin
                Result := 0.043842202344629426;
            end
            else
            begin
                Result := -0.030324275593787843;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_char_suffix_lm_per_difference <= -7.7499999999999991 then
                begin
                    if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                    begin
                        if features.top_local_lm_r1 <= -5291.4999999999991 then
                        begin
                            if features.delta_score_per_unit <= -46.499999999999993 then
                            begin
                                Result := -0.0065987525204513446;
                            end
                            else
                            begin
                                if features.candidate_local_lm_r3 <= -7424.4999999999991 then
                                begin
                                    if features.delta_local_lm_r2 <= -434.49999999999994 then
                                    begin
                                        if features.delta_score_per_unit <= 686.00000000000011 then
                                        begin
                                            Result := 0.02551233460121043;
                                        end
                                        else
                                        begin
                                            Result := 0.07838533863685343;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := -0.026796200873576356;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.0080599238168474266;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.012239970187208913;
                        end;
                    end
                    else
                    begin
                        Result := -0.019544087185464087;
                    end;
                end
                else
                begin
                    Result := 0.019087829745688175;
                end;
            end
            else
            begin
                Result := 0.016391634242633089;
            end;
        end;
    end;
end;

function local_difference_tree_31(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -47895667.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1052.4999999999998 then
        begin
            Result := -0.038478512784911385;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
            begin
                Result := -0.028088752195989483;
            end
            else
            begin
                Result := 0.0011667045174541099;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -1208.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -6220.4999999999991 then
            begin
                if features.delta_path_single_segments <= -1.0000000180025095E-35 then
                begin
                    Result := 0.051480577453113664;
                end
                else
                begin
                    if features.delta_path_max_segment_units <= 5.5000000000000009 then
                    begin
                        Result := -0.0024155107977082346;
                    end
                    else
                    begin
                        Result := 0.085380405231928511;
                    end;
                end;
            end
            else
            begin
                if features.delta_word_lm_per_boundary <= 105.2333335876465 then
                begin
                    Result := -0.020751785012427991;
                end
                else
                begin
                    Result := 0.043754313554650884;
                end;
            end;
        end
        else
        begin
            if features.delta_chain_score_gap <= -49850527.999999993 then
            begin
                if features.candidate_local_lm_r0 <= -6696.4999999999991 then
                begin
                    Result := -0.018279298115900237;
                end
                else
                begin
                    if features.delta_char_lm_score <= -114.49999999999999 then
                    begin
                        if features.same_prefix_units <= 8.5000000000000018 then
                        begin
                            Result := 0.0030423227028386489;
                        end
                        else
                        begin
                            Result := -0.029451158686716029;
                        end;
                    end
                    else
                    begin
                        if features.delta_path_max_segment_units <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.03452895703268976;
                        end
                        else
                        begin
                            if features.delta_score_per_unit <= 84.500000000000014 then
                            begin
                                Result := 0.017067831847399947;
                            end
                            else
                            begin
                                Result := 0.062651187514162224;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.018164270222636544;
            end;
        end;
    end;
end;

function local_difference_tree_32(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1560.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -38716327.999999993 then
        begin
            Result := -0.036511526172896908;
        end
        else
        begin
            if features.top_local_lm_r0 <= -5279.4999999999991 then
            begin
                if features.delta_local_lm_r1 <= -1325.4999999999998 then
                begin
                    Result := -0.0016489344531122805;
                end
                else
                begin
                    Result := 0.072938359816138221;
                end;
            end
            else
            begin
                Result := -0.025096630118344836;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -24348361.999999996 then
        begin
            Result := -0.03022330475811736;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_local_lm_r2 <= -641.49999999999989 then
                begin
                    if features.delta_dict_weight_per_unit <= -22.499999999999996 then
                    begin
                        if features.delta_score_per_unit <= 6046.5000000000009 then
                        begin
                            Result := -0.025309299177378921;
                        end
                        else
                        begin
                            Result := 0.099154339713514741;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -5958.4999999999991 then
                        begin
                            Result := 0.034600264082442642;
                        end
                        else
                        begin
                            Result := -0.0059248248979613142;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_candidate_score <= -4782.4999999999991 then
                    begin
                        Result := -0.0029866436758250025;
                    end
                    else
                    begin
                        Result := 0.016984497183590734;
                    end;
                end;
            end
            else
            begin
                if features.delta_chain_first_stage_score <= -106544.49999999999 then
                begin
                    Result := -0.021315307526031044;
                end
                else
                begin
                    if features.candidate_chain_first_stage_score <= 47200.500000000007 then
                    begin
                        Result := 0.026989860420185394;
                    end
                    else
                    begin
                        if features.delta_char_lm_score <= -265.49999999999994 then
                        begin
                            Result := 0.00074662752225437086;
                        end
                        else
                        begin
                            Result := 0.018612720382073813;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_33(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -46796905.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.037333829949036716;
        end
        else
        begin
            if features.delta_word_lm_supported_ratio <= -1.0000000180025095E-35 then
            begin
                Result := -0.02287336219875296;
            end
            else
            begin
                Result := 0.0074986924481100867;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -752.49999999999989 then
        begin
            if features.top_local_lm_r2 <= -4783.4999999999991 then
            begin
                if features.delta_score_per_unit <= -161.49999999999997 then
                begin
                    if features.candidate_chain_score_gap <= -200889495.99999997 then
                    begin
                        Result := 0.06477061473045774;
                    end
                    else
                    begin
                        Result := -0.022581187396087832;
                    end;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -5381.4999999999991 then
                    begin
                        if features.same_suffix_units <= 1.5000000000000002 then
                        begin
                            if features.delta_char_suffix_lm_per_difference <= -449.83332824707026 then
                            begin
                                Result := 0.061997762225486794;
                            end
                            else
                            begin
                                Result := 0.012438050343772059;
                            end;
                        end
                        else
                        begin
                            if features.delta_chain_second_stage_score <= -107579795.99999999 then
                            begin
                                Result := -0.018457588024683686;
                            end
                            else
                            begin
                                Result := 0.011651887137049226;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.010184806170800743;
                    end;
                end;
            end
            else
            begin
                Result := -0.023784298839624882;
            end;
        end
        else
        begin
            if features.delta_dict_weight_per_unit <= 9572.5000000000018 then
            begin
                if features.delta_char_lm_per_difference <= -473.41667175292963 then
                begin
                    Result := -0.028224266415336739;
                end
                else
                begin
                    Result := 0.013372858002343125;
                end;
            end
            else
            begin
                if features.delta_score_per_unit <= -5318.4999999999991 then
                begin
                    Result := -0.027587947931563175;
                end
                else
                begin
                    Result := 0.037495509142361313;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_34(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -1052.4999999999998 then
        begin
            Result := -0.036849387750028897;
        end
        else
        begin
            Result := -0.007792089163380771;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1784.4999999999998 then
        begin
            if features.top_local_lm_r3 <= -6621.4999999999991 then
            begin
                Result := 0.021789954621536527;
            end
            else
            begin
                if features.delta_local_lm_r3 <= -1372.4999999999998 then
                begin
                    if features.delta_candidate_score <= 46623.000000000007 then
                    begin
                        Result := -0.035413940545616737;
                    end
                    else
                    begin
                        if features.candidate_char_lm_suffix_score <= -7041.4999999999991 then
                        begin
                            Result := 0.10524773705169546;
                        end
                        else
                        begin
                            Result := -0.018847063925602463;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0021026121704272233;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r1 <= -5230.4999999999991 then
                begin
                    Result := 0.016262991924999054;
                end
                else
                begin
                    if features.candidate_ranker_score <= 6173916.5000000009 then
                    begin
                        Result := -0.0041268114377765088;
                    end
                    else
                    begin
                        Result := 0.034796654263179981;
                    end;
                end;
            end
            else
            begin
                if features.delta_local_lm_r3 <= -464.49999999999994 then
                begin
                    if features.delta_word_lm_per_boundary <= 105.2333335876465 then
                    begin
                        Result := -0.020728560854666348;
                    end
                    else
                    begin
                        Result := 0.034889062571839866;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r0 <= -5180.4999999999991 then
                    begin
                        if features.delta_dict_weight <= -207.49999999999997 then
                        begin
                            Result := -0.021964163811331594;
                        end
                        else
                        begin
                            Result := 0.01809139359157429;
                        end;
                    end
                    else
                    begin
                        Result := 0.021844849384581567;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_35(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -666.49999999999989 then
        begin
            Result := -0.033110892662257425;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= -33143027.999999996 then
            begin
                Result := -0.021212149255429549;
            end
            else
            begin
                if features.top_local_lm_r0 <= -4452.4999999999991 then
                begin
                    Result := 0.0030512333773573294;
                end
                else
                begin
                    Result := 0.064608876591067496;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1646.4999999999998 then
        begin
            if features.delta_local_lm_r2 <= -1560.4999999999998 then
            begin
                Result := -0.022816331968046329;
            end
            else
            begin
                if features.candidate_word_lm_zero_count <= 3.5000000000000004 then
                begin
                    Result := 0.020068503076657834;
                end
                else
                begin
                    Result := -0.021687610048023026;
                end;
            end;
        end
        else
        begin
            if features.delta_candidate_score <= -8645.4999999999982 then
            begin
                if features.candidate_local_lm_r0 <= -3773.9999999999995 then
                begin
                    if features.candidate_local_lm_r2 <= -7216.4999999999991 then
                    begin
                        if features.candidate_dict_weight <= -52017.999999999993 then
                        begin
                            Result := 0.043315576499450795;
                        end
                        else
                        begin
                            Result := -0.029589151140969144;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_lm_per_difference <= -87.833332061767564 then
                        begin
                            Result := -0.014238672835597035;
                        end
                        else
                        begin
                            Result := 0.01537251296055645;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.054461452467051051;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -7028.4999999999991 then
                begin
                    Result := 0.02227727630936728;
                end
                else
                begin
                    if features.delta_local_lm_r3 <= -354.49999999999994 then
                    begin
                        Result := -0.00096902585832552793;
                    end
                    else
                    begin
                        Result := 0.016348485116683131;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_36(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -43128483.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.034118707054868781;
        end
        else
        begin
            Result := -0.005250780952363066;
        end;
    end
    else
    begin
        if features.top_local_lm_r1 <= -4740.4999999999991 then
        begin
            if features.delta_candidate_score <= -8277.4999999999982 then
            begin
                if features.candidate_local_lm_r2 <= -6851.4999999999991 then
                begin
                    if features.candidate_dict_weight_per_unit <= 2459.5000000000005 then
                    begin
                        Result := 0.015455263386973034;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -3888.4999999999995 then
                        begin
                            Result := -0.028813275324373937;
                        end
                        else
                        begin
                            Result := 0.040790892280125182;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.010980544007406811;
                end;
            end
            else
            begin
                if features.same_prefix_units <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0058126255549692338;
                end
                else
                begin
                    if features.candidate_score_per_unit <= 14663.000000000002 then
                    begin
                        if features.delta_candidate_score <= 26060.500000000004 then
                        begin
                            if features.delta_char_lm_score <= -1496.4999999999998 then
                            begin
                                Result := -0.041705832147689671;
                            end
                            else
                            begin
                                Result := 0.016701366606786668;
                            end;
                        end
                        else
                        begin
                            Result := -0.0032695843039043282;
                        end;
                    end
                    else
                    begin
                        if features.delta_candidate_score <= 42869.000000000007 then
                        begin
                            if features.delta_local_lm_r3 <= -694.49999999999989 then
                            begin
                                Result := 0.011847598068326351;
                            end
                            else
                            begin
                                Result := 0.039955670661076262;
                            end;
                        end
                        else
                        begin
                            Result := 0.11700118728595937;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_score <= -585.49999999999989 then
            begin
                Result := -0.031753304915336872;
            end
            else
            begin
                Result := 0.0015426996252389912;
            end;
        end;
    end;
end;

function local_difference_tree_37(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -47895667.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1004.4999999999999 then
        begin
            Result := -0.037130116287747657;
        end
        else
        begin
            if features.delta_dict_weight <= -109457.49999999999 then
            begin
                Result := -0.025344224347549422;
            end
            else
            begin
                Result := 0.0055613662520522808;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -2062.4999999999995 then
        begin
            if features.delta_candidate_score <= 42869.000000000007 then
            begin
                Result := -0.030300752744267894;
            end
            else
            begin
                Result := 0.041769116093464446;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.delta_local_lm_r0 <= -647.49999999999989 then
                begin
                    if features.candidate_local_lm_r2 <= -8003.4999999999991 then
                    begin
                        if features.candidate_word_lm_boundary_count <= 4.5000000000000009 then
                        begin
                            Result := 0.043673184935120006;
                        end
                        else
                        begin
                            Result := -0.0044293376775101194;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r2 <= -463.49999999999994 then
                        begin
                            Result := -0.010555536469571752;
                        end
                        else
                        begin
                            if features.delta_char_lm_per_difference <= 341.50000000000006 then
                            begin
                                Result := 0.014577288658034411;
                            end
                            else
                            begin
                                Result := -0.041073215643848283;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.015206723663492421;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r1 <= -5408.4999999999991 then
                begin
                    if features.candidate_ranker_score_gap <= -24032013.999999996 then
                    begin
                        if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.054954944364866198;
                        end
                        else
                        begin
                            Result := -0.020530104503883723;
                        end;
                    end
                    else
                    begin
                        Result := 0.0082839152816694597;
                    end;
                end
                else
                begin
                    Result := 0.023848899995505286;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_38(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1327.4999999999998 then
    begin
        if features.candidate_ranker_score <= -16719468.499999998 then
        begin
            Result := -0.037646201849075876;
        end
        else
        begin
            if features.top_local_lm_r2 <= -4783.4999999999991 then
            begin
                if features.same_suffix_units <= 1.5000000000000002 then
                begin
                    if features.delta_score_per_unit <= -161.49999999999997 then
                    begin
                        if features.delta_dict_weight_per_unit <= -2454.4999999999995 then
                        begin
                            Result := 0.062882154109515864;
                        end
                        else
                        begin
                            Result := -0.034263412465606581;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r1 <= -5437.4999999999991 then
                        begin
                            Result := 0.061523781621622205;
                        end
                        else
                        begin
                            Result := -0.004784835911386026;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r1 <= -1728.4999999999998 then
                    begin
                        Result := -0.02918983117152759;
                    end
                    else
                    begin
                        Result := 0.0060180971800247217;
                    end;
                end;
            end
            else
            begin
                Result := -0.027751755821899572;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -25449907.999999996 then
        begin
            Result := -0.028566645160458492;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= -33143027.999999996 then
            begin
                if features.delta_local_lm_r2 <= -542.49999999999989 then
                begin
                    if features.candidate_word_lm_boundary_count <= 5.5000000000000009 then
                    begin
                        Result := 0.0011582004298540585;
                    end
                    else
                    begin
                        Result := -0.020017370848108583;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -5950.4999999999991 then
                    begin
                        if features.candidate_word_lm_boundary_last <= 1558.5000000000002 then
                        begin
                            Result := -0.0016155060146337322;
                        end
                        else
                        begin
                            Result := 0.030026829882892993;
                        end;
                    end
                    else
                    begin
                        Result := 0.021312543483891271;
                    end;
                end;
            end
            else
            begin
                Result := 0.014895712368706385;
            end;
        end;
    end;
end;

function local_difference_tree_39(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -21988119.999999996 then
    begin
        if features.delta_char_lm_score <= -363.49999999999994 then
        begin
            Result := -0.03643570063161089;
        end
        else
        begin
            if features.delta_dict_weight <= -47211.499999999993 then
            begin
                Result := -0.022257332768128288;
            end
            else
            begin
                if features.delta_candidate_score <= -196.49999999999997 then
                begin
                    Result := -0.015047381481090655;
                end
                else
                begin
                    Result := 0.079644742609054617;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -1694.4999999999998 then
        begin
            Result := -0.034133607819852529;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r1 <= -4740.4999999999991 then
                begin
                    Result := 0.011832262653346803;
                end
                else
                begin
                    if features.delta_local_lm_r1 <= -720.49999999999989 then
                    begin
                        Result := -0.017882489178953881;
                    end
                    else
                    begin
                        Result := 0.010903181995602126;
                    end;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -4300.4999999999991 then
                begin
                    if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.033664495895408438;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r1 <= -5485.4999999999991 then
                        begin
                            if features.candidate_ranker_score_gap <= -25475428.999999996 then
                            begin
                                Result := -0.025390504571115177;
                            end
                            else
                            begin
                                Result := -0.004650673066688182;
                            end;
                        end
                        else
                        begin
                            if features.delta_chain_first_stage_score <= -13263.499999999998 then
                            begin
                                Result := 0.040982642132330591;
                            end
                            else
                            begin
                                Result := -0.0086492109331149352;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r0 <= -4192.4999999999991 then
                    begin
                        Result := 0.051567000580165438;
                    end
                    else
                    begin
                        Result := 0.0040386980037286496;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_40(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r1 <= -1784.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -46796905.999999993 then
        begin
            Result := -0.037848661209400516;
        end
        else
        begin
            if features.top_local_lm_r3 <= -5995.4999999999991 then
            begin
                if features.candidate_local_lm_r2 <= -6576.4999999999991 then
                begin
                    Result := -0.00062758731594494304;
                end
                else
                begin
                    Result := 0.078085589720537196;
                end;
            end
            else
            begin
                Result := -0.022715263490477734;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -22297768.999999996 then
        begin
            if features.delta_char_lm_per_difference <= -182.83333587646482 then
            begin
                Result := -0.030842178542548733;
            end
            else
            begin
                if features.candidate_local_lm_r3 <= -5925.4999999999991 then
                begin
                    Result := -0.019513472467382467;
                end
                else
                begin
                    Result := 0.057362194380386394;
                end;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.candidate_path_segments <= 3.5000000000000004 then
                begin
                    if features.delta_char_lm_per_difference <= -861.41665649414051 then
                    begin
                        Result := -0.027057016230305365;
                    end
                    else
                    begin
                        if features.delta_path_segments <= -1.0000000180025095E-35 then
                        begin
                            if features.candidate_local_lm_r1 <= -4441.4999999999991 then
                            begin
                                Result := 0.0038046387154781476;
                            end
                            else
                            begin
                                Result := 0.083795967541797606;
                            end;
                        end
                        else
                        begin
                            Result := 0.04754976858354331;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_score <= 126.50000000000001 then
                    begin
                        Result := -0.0050159613993773014;
                    end
                    else
                    begin
                        Result := 0.018641482441480534;
                    end;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -4210.9999999999991 then
                begin
                    Result := 0.0096900912326563452;
                end
                else
                begin
                    Result := 0.025205550163982609;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_41(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r1 <= -1784.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -46796905.999999993 then
        begin
            Result := -0.038113493561759859;
        end
        else
        begin
            if features.candidate_local_lm_r2 <= -8652.4999999999982 then
            begin
                if features.top_local_lm_r1 <= -5528.4999999999991 then
                begin
                    if features.candidate_path_segments <= 2.5000000000000004 then
                    begin
                        Result := 0.10529469297344671;
                    end
                    else
                    begin
                        Result := 0.01885072684813692;
                    end;
                end
                else
                begin
                    Result := -0.03084195396650001;
                end;
            end
            else
            begin
                if features.delta_local_lm_r2 <= -1606.4999999999998 then
                begin
                    Result := -0.028632629909471383;
                end
                else
                begin
                    Result := 0.0011467582485275064;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -24348361.999999996 then
        begin
            Result := -0.027373497996520828;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= -47910029.999999993 then
            begin
                if features.delta_local_lm_r2 <= -542.49999999999989 then
                begin
                    Result := -0.0085700115452327138;
                end
                else
                begin
                    if features.candidate_word_lm_boundary_last <= 1552.5000000000002 then
                    begin
                        if features.candidate_local_lm_r1 <= -5950.4999999999991 then
                        begin
                            Result := -0.0030829652126047264;
                        end
                        else
                        begin
                            Result := 0.016594849046903691;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r0 <= -1020.9999999999999 then
                        begin
                            Result := -0.024099956579973717;
                        end
                        else
                        begin
                            Result := 0.037142494421238854;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r2 <= -5137.4999999999991 then
                begin
                    Result := 0.014672762662338539;
                end
                else
                begin
                    if features.candidate_local_lm_r3 <= -4484.4999999999991 then
                    begin
                        Result := -0.0066893447510188954;
                    end
                    else
                    begin
                        Result := 0.033983408951352226;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_42(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -704.49999999999989 then
    begin
        if features.delta_dict_weight_per_unit <= 693.50000000000011 then
        begin
            if features.delta_score_per_unit <= 6046.5000000000009 then
            begin
                if features.top_local_lm_r3 <= -6621.4999999999991 then
                begin
                    if features.candidate_dict_weight_per_unit <= 19823.500000000004 then
                    begin
                        Result := -0.018555913629385301;
                    end
                    else
                    begin
                        Result := 0.050247564728120635;
                    end;
                end
                else
                begin
                    Result := -0.037128247789593616;
                end;
            end
            else
            begin
                if features.candidate_ranker_score <= -16719468.499999998 then
                begin
                    Result := -0.022383270294597763;
                end
                else
                begin
                    Result := 0.13700620427098667;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r3 <= -1832.4999999999998 then
            begin
                Result := -0.029634861607347882;
            end
            else
            begin
                if features.candidate_text_units <= 7.5000000000000009 then
                begin
                    if features.top_local_lm_r0 <= -3853.4999999999995 then
                    begin
                        Result := 0.024244860373493823;
                    end
                    else
                    begin
                        Result := -0.033446923389329565;
                    end;
                end
                else
                begin
                    Result := -0.011330396735182607;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
        begin
            if features.candidate_local_lm_r3 <= -5684.4999999999991 then
            begin
                if features.candidate_ranker_score_gap <= -46542489.999999993 then
                begin
                    Result := -0.035565402494116598;
                end
                else
                begin
                    Result := -0.0079900200303747847;
                end;
            end
            else
            begin
                Result := 0.012513852954114286;
            end;
        end
        else
        begin
            if features.delta_local_lm_r0 <= -647.49999999999989 then
            begin
                if features.delta_path_max_segment_units <= -3.4999999999999996 then
                begin
                    Result := 0.037638001142481857;
                end
                else
                begin
                    Result := -0.003334667527538593;
                end;
            end
            else
            begin
                Result := 0.014475238053204347;
            end;
        end;
    end;
end;

function local_difference_tree_43(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -1143.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -34553647.999999993 then
        begin
            Result := -0.03086926554762089;
        end
        else
        begin
            Result := -0.0037727916776988703;
        end;
    end
    else
    begin
        if features.delta_dict_weight <= -6985.9999999999991 then
        begin
            if features.delta_local_lm_r1 <= -566.49999999999989 then
            begin
                if features.delta_score_per_unit <= 5414.5000000000009 then
                begin
                    if features.candidate_score_per_unit <= 228.50000000000003 then
                    begin
                        if features.delta_chain_first_stage_score <= -106544.49999999999 then
                        begin
                            Result := -0.032845317994349317;
                        end
                        else
                        begin
                            Result := 0.056208033107706425;
                        end;
                    end
                    else
                    begin
                        Result := -0.026530716674657062;
                    end;
                end
                else
                begin
                    Result := 0.083388906727045561;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -6149.4999999999991 then
                begin
                    Result := -0.0025072729460489311;
                end
                else
                begin
                    if features.candidate_chain_first_stage_score <= 56172.500000000007 then
                    begin
                        if features.delta_local_lm_r3 <= -503.49999999999994 then
                        begin
                            Result := -0.023687886483455007;
                        end
                        else
                        begin
                            Result := 0.044049361387921204;
                        end;
                    end
                    else
                    begin
                        Result := -0.011829285973815433;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_dict_weight_per_unit <= 12309.500000000002 then
            begin
                if features.delta_char_lm_score <= -800.49999999999989 then
                begin
                    Result := -0.019885380717520312;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= -914.49999999999989 then
                    begin
                        Result := -0.00039012039680705562;
                    end
                    else
                    begin
                        Result := 0.013072220137339108;
                    end;
                end;
            end
            else
            begin
                if features.delta_candidate_score <= -33565.999999999993 then
                begin
                    Result := -0.019653291111080627;
                end
                else
                begin
                    Result := 0.030450677120913063;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_44(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r1 <= -1815.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -46796905.999999993 then
        begin
            Result := -0.037035045314699734;
        end
        else
        begin
            if features.top_local_lm_r3 <= -5362.4999999999991 then
            begin
                Result := 0.00020902320118617714;
            end
            else
            begin
                Result := -0.026494066719260637;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -25449907.999999996 then
        begin
            Result := -0.027666191657810812;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= -51105641.999999993 then
            begin
                if features.delta_local_lm_r2 <= -981.49999999999989 then
                begin
                    Result := -0.016661321588752095;
                end
                else
                begin
                    if features.candidate_local_lm_r0 <= -4430.4999999999991 then
                    begin
                        if features.candidate_chain_score_gap <= -191376175.99999997 then
                        begin
                            if features.delta_score_per_unit <= -1499.4999999999998 then
                            begin
                                Result := -0.02218486581190365;
                            end
                            else
                            begin
                                Result := 0.056114063671506675;
                            end;
                        end
                        else
                        begin
                            if features.same_suffix_units <= 1.5000000000000002 then
                            begin
                                Result := -0.021462957677727375;
                            end
                            else
                            begin
                                Result := 0.0011234266455130422;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.candidate_char_lm_score <= -3635.4999999999995 then
                        begin
                            if features.candidate_candidate_score <= 209151.00000000003 then
                            begin
                                if features.candidate_local_lm_r3 <= -5828.4999999999991 then
                                begin
                                    Result := 0.011094039637426154;
                                end
                                else
                                begin
                                    Result := 0.044338438307201251;
                                end;
                            end
                            else
                            begin
                                Result := -0.046223864858633432;
                            end;
                        end
                        else
                        begin
                            Result := -0.033161879340724364;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_chain_score_gap <= 79774416.000000015 then
                begin
                    Result := 0.011533069186711119;
                end
                else
                begin
                    Result := -0.039728278364490346;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_45(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -1560.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -38716327.999999993 then
        begin
            Result := -0.033759528170864951;
        end
        else
        begin
            if features.top_local_lm_r0 <= -5033.4999999999991 then
            begin
                if features.delta_local_lm_r1 <= -1134.4999999999998 then
                begin
                    if features.candidate_path_single_segments <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.040417663215910962;
                    end
                    else
                    begin
                        Result := -0.013857034569682892;
                    end;
                end
                else
                begin
                    Result := 0.06604102588363478;
                end;
            end
            else
            begin
                Result := -0.024073815642215141;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -25449907.999999996 then
        begin
            Result := -0.029468594797349892;
        end
        else
        begin
            if features.delta_local_lm_r1 <= 37.500000000000007 then
            begin
                if features.delta_dict_weight_per_unit <= 12309.500000000002 then
                begin
                    if features.delta_char_lm_score <= -704.49999999999989 then
                    begin
                        Result := -0.013924598009250631;
                    end
                    else
                    begin
                        if features.candidate_word_lm_boundary_count <= 5.5000000000000009 then
                        begin
                            if features.delta_chain_first_stage_score <= 60168.500000000007 then
                            begin
                                Result := 0.0047967800967065695;
                            end
                            else
                            begin
                                Result := 0.029737980744868223;
                            end;
                        end
                        else
                        begin
                            if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
                            begin
                                if features.candidate_local_lm_r3 <= -4904.4999999999991 then
                                begin
                                    Result := -0.024711534979772493;
                                end
                                else
                                begin
                                    Result := 0.036237331724808683;
                                end;
                            end
                            else
                            begin
                                Result := 0.00023782312373637763;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.018053641745321848;
                end;
            end
            else
            begin
                if features.delta_candidate_score <= -204.49999999999997 then
                begin
                    Result := 0.0048662915647186477;
                end
                else
                begin
                    Result := 0.023747270071448723;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_46(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -16719468.499999998 then
    begin
        if features.delta_local_lm_r2 <= -1074.4999999999998 then
        begin
            Result := -0.033599316465485675;
        end
        else
        begin
            if features.delta_dict_weight <= -34705.999999999993 then
            begin
                Result := -0.018212453528712324;
            end
            else
            begin
                Result := 0.015312902273949136;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1134.4999999999998 then
        begin
            if features.top_local_lm_r3 <= -5362.4999999999991 then
            begin
                if features.delta_path_max_segment_units <= 5.5000000000000009 then
                begin
                    if features.delta_score_per_unit <= -254.99999999999997 then
                    begin
                        Result := -0.023948589464695937;
                    end
                    else
                    begin
                        if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.036542848465562806;
                        end
                        else
                        begin
                            Result := 0.0011816558862739401;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= -1788.4999999999998 then
                    begin
                        Result := 0.13346475338962113;
                    end
                    else
                    begin
                        Result := 0.011831323434579901;
                    end;
                end;
            end
            else
            begin
                if features.delta_local_lm_r0 <= -73.499999999999986 then
                begin
                    Result := -0.02686512283985942;
                end
                else
                begin
                    if features.delta_dict_weight <= 149697.00000000003 then
                    begin
                        Result := -0.0089493272201631897;
                    end
                    else
                    begin
                        if features.delta_local_lm_r2 <= -1488.4999999999998 then
                        begin
                            Result := -0.014358193189413424;
                        end
                        else
                        begin
                            Result := 0.090168726519183895;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -209.49999999999997 then
            begin
                Result := -0.0089092451361423956;
            end
            else
            begin
                if features.candidate_ranker_score <= 3663511.5000000005 then
                begin
                    Result := 0.0048558770609974456;
                end
                else
                begin
                    Result := 0.014630115651001053;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_47(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -21988119.999999996 then
    begin
        if features.delta_local_lm_r2 <= -820.49999999999989 then
        begin
            Result := -0.035152483571710288;
        end
        else
        begin
            if features.delta_dict_weight_per_unit <= -225.49999999999997 then
            begin
                Result := -0.018622625196649919;
            end
            else
            begin
                Result := 0.040507925910164978;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1934.4999999999998 then
        begin
            if features.top_local_lm_r3 <= -6553.4999999999991 then
            begin
                Result := 0.019731627825720962;
            end
            else
            begin
                Result := -0.022697614971832675;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r2 <= -5054.4999999999991 then
                begin
                    if features.same_prefix_units <= 1.5000000000000002 then
                    begin
                        Result := 3.2919153561955403E-05;
                    end
                    else
                    begin
                        if features.delta_score_per_unit <= -22.499999999999996 then
                        begin
                            Result := 0.0036766300458612711;
                        end
                        else
                        begin
                            if features.delta_chain_first_stage_score <= 283.00000000000006 then
                            begin
                                Result := 0.020791327368876039;
                            end
                            else
                            begin
                                Result := 0.0025208565461673311;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0044620286118103869;
                end;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -19627000.999999996 then
                begin
                    if features.candidate_local_lm_r3 <= -5225.4999999999991 then
                    begin
                        if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.04432157296616504;
                        end
                        else
                        begin
                            Result := -0.01818899536761228;
                        end;
                    end
                    else
                    begin
                        Result := 0.013586061004678898;
                    end;
                end
                else
                begin
                    if features.candidate_word_lm_boundary_last <= 1252.5000000000002 then
                    begin
                        Result := 0.018204719901644399;
                    end
                    else
                    begin
                        Result := -0.021177780279817173;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_48(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -1653.4999999999998 then
    begin
        if features.top_local_lm_r1 <= -6968.4999999999991 then
        begin
            Result := 0.043641336867680292;
        end
        else
        begin
            Result := -0.030204296394354728;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -25449907.999999996 then
        begin
            Result := -0.026970067760627658;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.delta_char_suffix_lm_per_difference <= -7.7499999999999991 then
                begin
                    if features.delta_dict_weight <= -4077.4999999999995 then
                    begin
                        if features.delta_chain_second_stage_score <= 27341884.000000004 then
                        begin
                            Result := -0.014748331224309666;
                        end
                        else
                        begin
                            Result := 0.047428008196783118;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -4112.4999999999991 then
                        begin
                            if features.candidate_text_units <= 12.500000000000002 then
                            begin
                                if features.delta_chain_first_stage_score <= 283.00000000000006 then
                                begin
                                    Result := 0.016780352456293442;
                                end
                                else
                                begin
                                    if features.candidate_dict_weight <= 141400.00000000003 then
                                    begin
                                        Result := -0.020324027862253787;
                                    end
                                    else
                                    begin
                                        Result := 0.053169510350928595;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.010927517201409116;
                            end;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r2 <= -7919.4999999999991 then
                            begin
                                Result := 0.044164832023328257;
                            end
                            else
                            begin
                                if features.candidate_word_lm_boundary_first <= 1315.5000000000002 then
                                begin
                                    Result := -0.032865696199136013;
                                end
                                else
                                begin
                                    Result := 0.020315014926032712;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -5556.4999999999991 then
                    begin
                        Result := 0.0059470040426820902;
                    end
                    else
                    begin
                        Result := 0.032133435885966032;
                    end;
                end;
            end
            else
            begin
                Result := 0.0095743759786549552;
            end;
        end;
    end;
end;

function local_difference_tree_49(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -47895667.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1074.4999999999998 then
        begin
            Result := -0.033914121885026731;
        end
        else
        begin
            if features.delta_dict_weight_per_unit <= -340.49999999999994 then
            begin
                Result := -0.01529279000832879;
            end
            else
            begin
                Result := 0.019474017127370437;
            end;
        end;
    end
    else
    begin
        if features.top_local_lm_r1 <= -4740.4999999999991 then
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.same_prefix_units <= 1.0000000180025095E-35 then
                begin
                    if features.delta_char_lm_score <= -251.49999999999997 then
                    begin
                        Result := -0.023209539214030444;
                    end
                    else
                    begin
                        if features.candidate_char_lm_score <= -5466.4999999999991 then
                        begin
                            Result := 0.041191628702373695;
                        end
                        else
                        begin
                            if features.top_local_lm_r1 <= -6830.4999999999991 then
                            begin
                                Result := -0.042544162221515761;
                            end
                            else
                            begin
                                Result := 0.016932783571037599;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_path_single_segments <= -1.4999999999999998 then
                    begin
                        if features.top_local_lm_r1 <= -5656.4999999999991 then
                        begin
                            Result := 0.03574602261681413;
                        end
                        else
                        begin
                            Result := -0.011301727973572906;
                        end;
                    end
                    else
                    begin
                        Result := 0.0086284849892879611;
                    end;
                end;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -19627000.999999996 then
                begin
                    if features.candidate_local_lm_r1 <= -5950.4999999999991 then
                    begin
                        Result := -0.016102003334641173;
                    end
                    else
                    begin
                        Result := 0.013448993853815131;
                    end;
                end
                else
                begin
                    Result := 0.010123800874190363;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -1739.4999999999998 then
            begin
                Result := -0.034305201907564246;
            end
            else
            begin
                Result := -0.0047347430534945131;
            end;
        end;
    end;
end;

function local_difference_tree_50(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -47895667.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1052.4999999999998 then
        begin
            Result := -0.034660779753838689;
        end
        else
        begin
            if features.delta_dict_weight <= -34705.999999999993 then
            begin
                Result := -0.017672884728757207;
            end
            else
            begin
                Result := 0.014742468845000559;
            end;
        end;
    end
    else
    begin
        if features.top_local_lm_r1 <= -4879.4999999999991 then
        begin
            if features.candidate_local_lm_r1 <= -5950.4999999999991 then
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    if features.candidate_source_local_rerank <= 1.0000000180025095E-35 then
                    begin
                        if features.candidate_ranker_score <= 3663511.5000000005 then
                        begin
                            if features.top_local_lm_r1 <= -6204.4999999999991 then
                            begin
                                if features.delta_candidate_score <= -1.0000000180025095E-35 then
                                begin
                                    Result := -0.0013090419211576401;
                                end
                                else
                                begin
                                    Result := 0.019840974333777236;
                                end;
                            end
                            else
                            begin
                                Result := -0.0066518072698085445;
                            end;
                        end
                        else
                        begin
                            Result := 0.015170597243317168;
                        end;
                    end
                    else
                    begin
                        Result := -0.032042567349987262;
                    end;
                end
                else
                begin
                    if features.candidate_ranker_score_gap <= -20610524.999999996 then
                    begin
                        Result := -0.015597343072240071;
                    end
                    else
                    begin
                        Result := 0.0093596365411473832;
                    end;
                end;
            end
            else
            begin
                if features.candidate_word_lm_supported_ratio <= 392.00000000000006 then
                begin
                    if features.delta_local_lm_r2 <= -666.49999999999989 then
                    begin
                        Result := -0.0069271385238875603;
                    end
                    else
                    begin
                        Result := 0.030566269609762525;
                    end;
                end
                else
                begin
                    Result := -0.0068694709334522139;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -1739.4999999999998 then
            begin
                Result := -0.034538215334609206;
            end
            else
            begin
                Result := -0.0038002678412634946;
            end;
        end;
    end;
end;

function local_difference_tree_51(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r1 <= -1815.4999999999998 then
    begin
        if features.candidate_ranker_score_gap <= -46796905.999999993 then
        begin
            Result := -0.035175758825921111;
        end
        else
        begin
            if features.top_local_lm_r1 <= -4455.4999999999991 then
            begin
                if features.same_suffix_units <= 1.0000000180025095E-35 then
                begin
                    if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                    begin
                        if features.candidate_dict_weight <= 136076.00000000003 then
                        begin
                            Result := 0.073672950906533988;
                        end
                        else
                        begin
                            Result := -0.01531823722124641;
                        end;
                    end
                    else
                    begin
                        Result := -0.0065580520011985256;
                    end;
                end
                else
                begin
                    Result := -0.0098765946496463027;
                end;
            end
            else
            begin
                Result := -0.027562592318836773;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score_gap <= -56569927.999999993 then
        begin
            Result := -0.026035474714969364;
        end
        else
        begin
            if features.delta_local_lm_r0 <= -647.49999999999989 then
            begin
                if features.candidate_local_lm_r2 <= -8158.4999999999991 then
                begin
                    Result := 0.02129896993471761;
                end
                else
                begin
                    if features.different_units <= 1.5000000000000002 then
                    begin
                        if features.top_local_lm_r2 <= -5085.4999999999991 then
                        begin
                            if features.top_local_lm_r0 <= -4659.4999999999991 then
                            begin
                                Result := -0.010896004152301814;
                            end
                            else
                            begin
                                if features.top_local_lm_r1 <= -7331.4999999999991 then
                                begin
                                    Result := -0.020995129061971877;
                                end
                                else
                                begin
                                    if features.candidate_local_lm_r0 <= -6051.4999999999991 then
                                    begin
                                        Result := 0.046972410687130366;
                                    end
                                    else
                                    begin
                                        Result := 0.012151297000502354;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.019503655553770122;
                        end;
                    end
                    else
                    begin
                        Result := -0.011527427741842922;
                    end;
                end;
            end
            else
            begin
                Result := 0.0074492831986382457;
            end;
        end;
    end;
end;

function local_difference_tree_52(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -52186323.999999993 then
    begin
        if features.delta_char_lm_score <= -363.49999999999994 then
        begin
            Result := -0.0347930444727838;
        end
        else
        begin
            if features.candidate_local_lm_r2 <= -6210.4999999999991 then
            begin
                Result := -0.019020687496990825;
            end
            else
            begin
                if features.delta_word_lm_boundary_max <= -1.0000000180025095E-35 then
                begin
                    Result := -0.032796116452643347;
                end
                else
                begin
                    Result := 0.066816682145873343;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -1772.4999999999998 then
        begin
            if features.delta_score_per_unit <= 6046.5000000000009 then
            begin
                Result := -0.034457307872345529;
            end
            else
            begin
                Result := 0.053872236726359123;
            end;
        end
        else
        begin
            if features.delta_char_lm_score <= -473.49999999999994 then
            begin
                if features.top_local_lm_r1 <= -6372.4999999999991 then
                begin
                    if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                    begin
                        if features.candidate_chain_second_stage_score <= -192711479.99999997 then
                        begin
                            Result := -0.024455444466817831;
                        end
                        else
                        begin
                            if features.same_suffix_units <= 1.5000000000000002 then
                            begin
                                Result := 0.05756562656500596;
                            end
                            else
                            begin
                                Result := 0.016113790396774373;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0067976903385589026;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight_per_unit <= 693.50000000000011 then
                    begin
                        Result := -0.021762663434106867;
                    end
                    else
                    begin
                        Result := -0.00074173565971172035;
                    end;
                end;
            end
            else
            begin
                if features.delta_path_segments <= 2.5000000000000004 then
                begin
                    if features.delta_local_lm_r0 <= -2146.4999999999995 then
                    begin
                        Result := -0.017289901110735667;
                    end
                    else
                    begin
                        Result := 0.0069102697029562142;
                    end;
                end
                else
                begin
                    Result := 0.02489095146793071;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_53(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -47895667.999999993 then
    begin
        if features.delta_local_lm_r3 <= -887.49999999999989 then
        begin
            Result := -0.033509698760721573;
        end
        else
        begin
            if features.delta_dict_weight <= -109457.49999999999 then
            begin
                Result := -0.026798162492387072;
            end
            else
            begin
                if features.same_suffix_units <= 1.5000000000000002 then
                begin
                    if features.candidate_char_lm_suffix_score <= -6303.4999999999991 then
                    begin
                        Result := 0.086413642146595693;
                    end
                    else
                    begin
                        Result := -0.0021658639479112418;
                    end;
                end
                else
                begin
                    Result := -0.0049083270478744176;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -2447.4999999999995 then
        begin
            Result := -0.029228884736530576;
        end
        else
        begin
            if features.top_local_lm_r0 <= -4070.9999999999995 then
            begin
                if features.candidate_chain_score_gap <= -194178975.99999997 then
                begin
                    Result := 0.046519321744240942;
                end
                else
                begin
                    if features.delta_dict_weight_per_unit <= 11348.500000000002 then
                    begin
                        if features.delta_char_lm_score <= -251.49999999999997 then
                        begin
                            if features.candidate_local_lm_r3 <= -7276.4999999999991 then
                            begin
                                if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                                begin
                                    Result := 0.019189531085442805;
                                end
                                else
                                begin
                                    Result := -0.0087536312981716068;
                                end;
                            end
                            else
                            begin
                                Result := -0.0095197783991817896;
                            end;
                        end
                        else
                        begin
                            Result := 0.0088581766585548553;
                        end;
                    end
                    else
                    begin
                        if features.delta_score_per_unit <= -4874.4999999999991 then
                        begin
                            Result := -0.022548736406932664;
                        end
                        else
                        begin
                            Result := 0.022426864526915034;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_per_difference <= 86.750000000000014 then
                begin
                    Result := -0.010353638232179774;
                end
                else
                begin
                    Result := 0.041051869086212146;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_54(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -690.49999999999989 then
    begin
        if features.delta_dict_weight <= -196.49999999999997 then
        begin
            if features.delta_candidate_score <= 46623.000000000007 then
            begin
                Result := -0.033720448767625193;
            end
            else
            begin
                if features.delta_candidate_score <= 50362.500000000007 then
                begin
                    Result := 0.13823954774561409;
                end
                else
                begin
                    Result := -0.018485261272198062;
                end;
            end;
        end
        else
        begin
            if features.top_local_lm_r0 <= -4136.4999999999991 then
            begin
                if features.same_prefix_units <= 1.5000000000000002 then
                begin
                    Result := -0.0162809759000365;
                end
                else
                begin
                    if features.top_local_lm_r3 <= -5163.4999999999991 then
                    begin
                        if features.candidate_path_segments <= 5.5000000000000009 then
                        begin
                            if features.candidate_char_lm_score <= -6593.4999999999991 then
                            begin
                                Result := -0.021015745110145478;
                            end
                            else
                            begin
                                Result := 0.037580537796146868;
                            end;
                        end
                        else
                        begin
                            Result := -0.012507057177525106;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r2 <= -4847.4999999999991 then
                        begin
                            Result := -0.017181106684147237;
                        end
                        else
                        begin
                            Result := 0.091577623840340489;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.030225572458983434;
            end;
        end;
    end
    else
    begin
        if features.delta_chain_second_stage_score <= -33143027.999999996 then
        begin
            if features.delta_local_lm_r2 <= -491.49999999999994 then
            begin
                if features.delta_chain_first_stage_score <= 38884.500000000007 then
                begin
                    Result := -0.012895691280288777;
                end
                else
                begin
                    if features.top_local_lm_r3 <= -6690.4999999999991 then
                    begin
                        Result := 0.051350848467949198;
                    end
                    else
                    begin
                        Result := -0.0027566502575799836;
                    end;
                end;
            end
            else
            begin
                Result := 0.0057109111282834394;
            end;
        end
        else
        begin
            Result := 0.01051996015664486;
        end;
    end;
end;

function local_difference_tree_55(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -21988119.999999996 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.035984480129431902;
        end
        else
        begin
            Result := -0.0072209085363688433;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -2059.4999999999995 then
        begin
            Result := -0.034936046390854208;
        end
        else
        begin
            if features.delta_local_lm_r3 <= -464.49999999999994 then
            begin
                if features.candidate_word_lm_zero_count <= 3.5000000000000004 then
                begin
                    if features.delta_candidate_score <= 46623.000000000007 then
                    begin
                        if features.delta_dict_weight <= -8993.9999999999982 then
                        begin
                            if features.delta_score_per_unit <= -4874.4999999999991 then
                            begin
                                Result := 0.039773228358286887;
                            end
                            else
                            begin
                                Result := -0.028952962881215027;
                            end;
                        end
                        else
                        begin
                            if features.top_local_lm_r0 <= -3997.4999999999995 then
                            begin
                                Result := 0.012221354788933223;
                            end
                            else
                            begin
                                Result := -0.016270926148851637;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_candidate_score <= 50362.500000000007 then
                        begin
                            Result := 0.11470646087140046;
                        end
                        else
                        begin
                            if features.top_local_lm_r1 <= -5686.4999999999991 then
                            begin
                                Result := 0.039736814884944023;
                            end
                            else
                            begin
                                Result := -0.033725431014210557;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.011855107302410038;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -5935.4999999999991 then
                begin
                    Result := 0.0034532028882767098;
                end
                else
                begin
                    if features.delta_char_lm_per_difference <= -376.83332824707026 then
                    begin
                        Result := -0.035086695079921619;
                    end
                    else
                    begin
                        if features.candidate_word_lm_strong_ratio <= 577.00000000000011 then
                        begin
                            Result := 0.021296264899511825;
                        end
                        else
                        begin
                            Result := -0.037214576317135671;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_56(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r1 <= -1784.4999999999998 then
    begin
        if features.delta_dict_weight <= -6985.9999999999991 then
        begin
            if features.delta_candidate_score <= 46623.000000000007 then
            begin
                Result := -0.038459514583610528;
            end
            else
            begin
                if features.delta_candidate_score <= 50362.500000000007 then
                begin
                    Result := 0.12210024881507037;
                end
                else
                begin
                    Result := -0.028638455159297967;
                end;
            end;
        end
        else
        begin
            if features.top_local_lm_r3 <= -5410.4999999999991 then
            begin
                Result := 0.0063893004626281646;
            end
            else
            begin
                Result := -0.025187702241129623;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -25449907.999999996 then
        begin
            Result := -0.02534458015476888;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                Result := 0.0067546235638301731;
            end
            else
            begin
                if features.candidate_local_lm_r3 <= -5684.4999999999991 then
                begin
                    if features.candidate_ranker_score <= 7979596.5000000009 then
                    begin
                        if features.delta_char_suffix_lm_per_difference <= 185.50000000000003 then
                        begin
                            Result := -0.019149213183433295;
                        end
                        else
                        begin
                            if features.candidate_word_lm_boundary_max <= 1483.5000000000002 then
                            begin
                                Result := -0.014007998181601486;
                            end
                            else
                            begin
                                Result := 0.054080637916102924;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r2 <= -5479.4999999999991 then
                        begin
                            if features.candidate_local_lm_r2 <= -6550.4999999999991 then
                            begin
                                Result := 0.00865312033949589;
                            end
                            else
                            begin
                                Result := 0.059325459410654355;
                            end;
                        end
                        else
                        begin
                            Result := -0.023876737534237677;
                        end;
                    end;
                end
                else
                begin
                    if features.top_local_lm_r0 <= -4205.4999999999991 then
                    begin
                        Result := 0.016953941801885714;
                    end
                    else
                    begin
                        Result := -0.017705095018836096;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_57(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -47895667.999999993 then
    begin
        if features.delta_local_lm_r3 <= -887.49999999999989 then
        begin
            Result := -0.033651047355804681;
        end
        else
        begin
            if features.same_suffix_units <= 1.5000000000000002 then
            begin
                if features.delta_dict_weight <= -109457.49999999999 then
                begin
                    Result := -0.024837186978211689;
                end
                else
                begin
                    Result := 0.058105589555971754;
                end;
            end
            else
            begin
                Result := -0.012554741580387413;
            end;
        end;
    end
    else
    begin
        if features.top_local_lm_r1 <= -4740.4999999999991 then
        begin
            if features.delta_candidate_score <= -8277.4999999999982 then
            begin
                if features.candidate_local_lm_r0 <= -4883.4999999999991 then
                begin
                    Result := -0.011284827579979865;
                end
                else
                begin
                    if features.candidate_local_lm_r3 <= -4999.4999999999991 then
                    begin
                        Result := 0.0055992545077462067;
                    end
                    else
                    begin
                        Result := 0.052064242470770086;
                    end;
                end;
            end
            else
            begin
                if features.delta_dict_weight_per_unit <= 11348.500000000002 then
                begin
                    if features.same_prefix_units <= 1.5000000000000002 then
                    begin
                        Result := -0.0054637318910122079;
                    end
                    else
                    begin
                        if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                        begin
                            if features.candidate_word_lm_zero_count <= 1.5000000000000002 then
                            begin
                                if features.delta_path_segments <= -1.4999999999999998 then
                                begin
                                    Result := 0.0074093738688268988;
                                end
                                else
                                begin
                                    Result := 0.040255625400746869;
                                end;
                            end
                            else
                            begin
                                Result := 0.0081423325936174924;
                            end;
                        end
                        else
                        begin
                            Result := -0.0037373324761259354;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.022431358597119068;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -1739.4999999999998 then
            begin
                Result := -0.035979264502195712;
            end
            else
            begin
                Result := -0.002793632292705225;
            end;
        end;
    end;
end;

function local_difference_tree_58(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -21218919.999999996 then
    begin
        if features.delta_local_lm_r3 <= -735.49999999999989 then
        begin
            Result := -0.03438923149526308;
        end
        else
        begin
            if features.delta_chain_first_stage_score <= -94998.499999999985 then
            begin
                Result := -0.037993644578982973;
            end
            else
            begin
                Result := 0.0087902001441164113;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -1772.4999999999998 then
        begin
            if features.delta_score_per_unit <= 6046.5000000000009 then
            begin
                Result := -0.034102635684747092;
            end
            else
            begin
                Result := 0.053207527922279681;
            end;
        end
        else
        begin
            if features.top_local_lm_r1 <= -4740.4999999999991 then
            begin
                if features.delta_dict_weight_per_unit <= 12309.500000000002 then
                begin
                    if features.delta_char_lm_score <= -704.49999999999989 then
                    begin
                        if features.candidate_local_lm_r0 <= -8513.4999999999982 then
                        begin
                            Result := 0.050596406779975095;
                        end
                        else
                        begin
                            if features.candidate_word_lm_boundary_first <= 1405.5000000000002 then
                            begin
                                Result := -0.01585282606315994;
                            end
                            else
                            begin
                                Result := 0.044335817610130633;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0066976135536886607;
                    end;
                end
                else
                begin
                    if features.delta_score_per_unit <= -254.99999999999997 then
                    begin
                        Result := -0.013510253409173587;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -4070.9999999999995 then
                        begin
                            Result := 0.031011216436551345;
                        end
                        else
                        begin
                            Result := -0.012675027982064808;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_local_lm_r1 <= -865.49999999999989 then
                begin
                    Result := -0.015356267827589145;
                end
                else
                begin
                    if features.candidate_path_single_segments <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.034986671276004966;
                    end
                    else
                    begin
                        Result := -0.0011796872606896799;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_59(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -2031.4999999999998 then
    begin
        if features.delta_candidate_score <= 42869.000000000007 then
        begin
            Result := -0.031209886590507638;
        end
        else
        begin
            if features.candidate_local_lm_r1 <= -8768.4999999999982 then
            begin
                Result := 0.082667275103926269;
            end
            else
            begin
                Result := -0.014515301775386702;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= -22297768.999999996 then
        begin
            if features.delta_char_lm_score <= -363.49999999999994 then
            begin
                Result := -0.030965779547148627;
            end
            else
            begin
                if features.delta_dict_weight <= -191.49999999999997 then
                begin
                    Result := -0.007363015736408015;
                end
                else
                begin
                    Result := 0.071786694970868162;
                end;
            end;
        end
        else
        begin
            if features.top_local_lm_r0 <= -4070.9999999999995 then
            begin
                if features.same_prefix_units <= 1.0000000180025095E-35 then
                begin
                    Result := -0.006083194908891215;
                end
                else
                begin
                    if features.delta_candidate_score <= -8645.4999999999982 then
                    begin
                        if features.candidate_local_lm_r2 <= -7412.4999999999991 then
                        begin
                            Result := -0.024005291208005094;
                        end
                        else
                        begin
                            Result := 0.0050343932627430719;
                        end;
                    end
                    else
                    begin
                        if features.delta_chain_first_stage_score <= 283.00000000000006 then
                        begin
                            Result := 0.013577673260182239;
                        end
                        else
                        begin
                            if features.candidate_ranker_score_gap <= -21523774.999999996 then
                            begin
                                if features.delta_word_lm_boundary_count <= -1.0000000180025095E-35 then
                                begin
                                    Result := 0.015299183842683176;
                                end
                                else
                                begin
                                    Result := -0.018988752545395206;
                                end;
                            end
                            else
                            begin
                                Result := 0.015646861044144464;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_per_difference <= 86.750000000000014 then
                begin
                    Result := -0.010484834688321083;
                end
                else
                begin
                    Result := 0.039011605697915973;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_60(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -23763997.999999996 then
    begin
        Result := -0.027473390787013618;
    end
    else
    begin
        if features.delta_char_lm_score <= -1772.4999999999998 then
        begin
            Result := -0.026884488477130725;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r1 <= -4740.4999999999991 then
                begin
                    if features.candidate_local_lm_r0 <= -8513.4999999999982 then
                    begin
                        if features.delta_char_lm_score <= -406.49999999999994 then
                        begin
                            Result := 0.064485474303837442;
                        end
                        else
                        begin
                            Result := -0.0144100548172437;
                        end;
                    end
                    else
                    begin
                        if features.same_prefix_units <= 1.0000000180025095E-35 then
                        begin
                            if features.delta_char_lm_score <= -406.49999999999994 then
                            begin
                                Result := -0.030724463618163288;
                            end
                            else
                            begin
                                if features.delta_dict_weight_per_unit <= -6690.9999999999991 then
                                begin
                                    Result := -0.036305021240074259;
                                end
                                else
                                begin
                                    Result := 0.013247768003994664;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r0 <= -7331.4999999999991 then
                            begin
                                Result := -0.0098716638517780692;
                            end
                            else
                            begin
                                Result := 0.010544225354383032;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0067223035564492536;
                end;
            end
            else
            begin
                if features.delta_local_lm_r3 <= -464.49999999999994 then
                begin
                    if features.candidate_path_segments <= 6.5000000000000009 then
                    begin
                        Result := -5.0428252298640834E-05;
                    end
                    else
                    begin
                        Result := -0.025460772296197778;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r2 <= -7432.4999999999991 then
                    begin
                        Result := -0.024083724767404672;
                    end
                    else
                    begin
                        if features.same_prefix_units <= 4.5000000000000009 then
                        begin
                            Result := 0.018985874496493412;
                        end
                        else
                        begin
                            Result := -0.0043342511057482252;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_61(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -53324801.999999993 then
    begin
        if features.delta_char_lm_per_difference <= -173.90000152587888 then
        begin
            Result := -0.033780987042661123;
        end
        else
        begin
            if features.top_local_lm_r3 <= -5118.4999999999991 then
            begin
                Result := -0.0070066425159014548;
            end
            else
            begin
                Result := 0.07892230204294215;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -1772.4999999999998 then
        begin
            Result := -0.027301551922937716;
        end
        else
        begin
            if features.delta_local_lm_r1 <= 37.500000000000007 then
            begin
                if features.candidate_local_lm_r0 <= -8513.4999999999982 then
                begin
                    if features.candidate_path_segments <= 5.5000000000000009 then
                    begin
                        Result := 0.067079468645665385;
                    end
                    else
                    begin
                        Result := -0.032575782027662259;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight <= -6985.9999999999991 then
                    begin
                        if features.delta_candidate_score <= 19920.500000000004 then
                        begin
                            if features.candidate_candidate_score <= 47626.000000000007 then
                            begin
                                if features.candidate_local_lm_r1 <= -7429.4999999999991 then
                                begin
                                    Result := -0.01657348567832511;
                                end
                                else
                                begin
                                    Result := 0.01893409185116247;
                                end;
                            end
                            else
                            begin
                                Result := -0.022090903541710238;
                            end;
                        end
                        else
                        begin
                            Result := 0.0344062245592534;
                        end;
                    end
                    else
                    begin
                        if features.delta_candidate_score <= 204.50000000000003 then
                        begin
                            if features.delta_local_lm_r2 <= -666.49999999999989 then
                            begin
                                Result := -0.0011081407280410201;
                            end
                            else
                            begin
                                Result := 0.01320345288001798;
                            end;
                        end
                        else
                        begin
                            Result := -0.0055652105405805978;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_score_per_unit <= -16.499999999999996 then
                begin
                    Result := 0.0030447134980004136;
                end
                else
                begin
                    Result := 0.020365831274493981;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_62(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -23763997.999999996 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.036217729774157714;
        end
        else
        begin
            Result := -0.0074493960398075657;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -1694.4999999999998 then
        begin
            if features.delta_candidate_score <= 42869.000000000007 then
            begin
                Result := -0.031430041498392659;
            end
            else
            begin
                Result := 0.044785275748919863;
            end;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -231.49999999999997 then
            begin
                Result := -0.010920528208083931;
            end
            else
            begin
                if features.delta_local_lm_r0 <= -647.49999999999989 then
                begin
                    if features.candidate_local_lm_r2 <= -8158.4999999999991 then
                    begin
                        if features.delta_path_max_segment_units <= 1.5000000000000002 then
                        begin
                            Result := 0.0068832238643063226;
                        end
                        else
                        begin
                            Result := 0.057928512937029809;
                        end;
                    end
                    else
                    begin
                        Result := -0.0046805868275141436;
                    end;
                end
                else
                begin
                    if features.max_different_run <= 2.5000000000000004 then
                    begin
                        if features.delta_char_lm_per_difference <= -511.83332824707026 then
                        begin
                            if features.candidate_word_lm_zero_count <= 3.5000000000000004 then
                            begin
                                if features.delta_dict_weight_per_unit <= -340.49999999999994 then
                                begin
                                    Result := -0.022785859507367445;
                                end
                                else
                                begin
                                    if features.delta_local_lm_r3 <= -1038.4999999999998 then
                                    begin
                                        if features.top_local_lm_r0 <= -5072.4999999999991 then
                                        begin
                                            Result := 0.047006263080898752;
                                        end
                                        else
                                        begin
                                            Result := -0.00057085512381461177;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := 9.3603921299278395E-05;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.028335842781239951;
                            end;
                        end
                        else
                        begin
                            Result := 0.010597071349891317;
                        end;
                    end
                    else
                    begin
                        Result := -0.013864581464441861;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_63(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -53324801.999999993 then
    begin
        if features.delta_char_lm_per_difference <= -191.90000152587888 then
        begin
            Result := -0.031730406318652343;
        end
        else
        begin
            if features.candidate_local_lm_r3 <= -5925.4999999999991 then
            begin
                Result := -0.017839442871431705;
            end
            else
            begin
                Result := 0.051884629944678524;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -2617.4999999999995 then
        begin
            Result := -0.036671620541651226;
        end
        else
        begin
            if features.candidate_ranker_score <= 1834059.0000000002 then
            begin
                if features.delta_path_max_segment_units <= 6.5000000000000009 then
                begin
                    if features.delta_chain_first_stage_score <= 645.50000000000011 then
                    begin
                        if features.delta_score_per_unit <= 6046.5000000000009 then
                        begin
                            if features.delta_dict_weight <= -112271.99999999999 then
                            begin
                                Result := -0.019076724290278988;
                            end
                            else
                            begin
                                if features.delta_dict_weight_per_unit <= -6690.9999999999991 then
                                begin
                                    Result := 0.029376650771639964;
                                end
                                else
                                begin
                                    if features.delta_candidate_score <= -38256.499999999993 then
                                    begin
                                        Result := -0.023722876959323905;
                                    end
                                    else
                                    begin
                                        if features.top_local_lm_r0 <= -6217.4999999999991 then
                                        begin
                                            if features.delta_path_max_segment_units <= -1.0000000180025095E-35 then
                                            begin
                                                Result := -0.023035308721820705;
                                            end
                                            else
                                            begin
                                                if features.top_local_lm_r1 <= -6120.4999999999991 then
                                                begin
                                                    Result := 0.041986461471632847;
                                                end
                                                else
                                                begin
                                                    Result := -0.010883877939103136;
                                                end;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := -0.0022283778850767551;
                                        end;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.069302763886819357;
                        end;
                    end
                    else
                    begin
                        Result := -0.018735683595190667;
                    end;
                end
                else
                begin
                    Result := 0.019352011686448324;
                end;
            end
            else
            begin
                Result := 0.006147964010488313;
            end;
        end;
    end;
end;

function local_difference_tree_64(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -1694.4999999999998 then
    begin
        Result := -0.029169040889604696;
    end
    else
    begin
        if features.candidate_ranker_score <= -24348361.999999996 then
        begin
            Result := -0.024276117073885696;
        end
        else
        begin
            if features.top_local_lm_r1 <= -4740.4999999999991 then
            begin
                if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                begin
                    if features.delta_candidate_score <= 7555.0000000000009 then
                    begin
                        if features.candidate_chain_score_gap <= -236078847.99999997 then
                        begin
                            if features.candidate_text_units <= 9.5000000000000018 then
                            begin
                                Result := 0.11174016784072505;
                            end
                            else
                            begin
                                Result := -0.023783691000584944;
                            end;
                        end
                        else
                        begin
                            if features.delta_dict_weight_per_unit <= 21614.500000000004 then
                            begin
                                Result := 0.002323495172873087;
                            end
                            else
                            begin
                                Result := 0.023211885816615235;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_dict_weight <= 9015.0000000000018 then
                        begin
                            if features.top_local_lm_r3 <= -6758.4999999999991 then
                            begin
                                Result := 0.06566154018469883;
                            end
                            else
                            begin
                                Result := 0.024897173628916497;
                            end;
                        end
                        else
                        begin
                            if features.candidate_chain_first_stage_score <= 74469.000000000015 then
                            begin
                                Result := -0.02807503013403841;
                            end
                            else
                            begin
                                Result := 0.008950175021329769;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.033665206423699474;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r0 <= -4239.9999999999991 then
                        begin
                            if features.candidate_local_lm_r1 <= -5485.4999999999991 then
                            begin
                                Result := -0.01302662062371931;
                            end
                            else
                            begin
                                Result := 0.022712598196874847;
                            end;
                        end
                        else
                        begin
                            Result := 0.014281710609621766;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0078178167881565522;
            end;
        end;
    end;
end;

function local_difference_tree_65(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -690.49999999999989 then
    begin
        if features.delta_candidate_score <= -1.0000000180025095E-35 then
        begin
            Result := -0.027311925020753386;
        end
        else
        begin
            if features.top_local_lm_r2 <= -4783.4999999999991 then
            begin
                if features.delta_word_lm_bonus <= -260.49999999999994 then
                begin
                    Result := -0.036589665189601467;
                end
                else
                begin
                    if features.delta_local_lm_r3 <= -1536.4999999999998 then
                    begin
                        if features.candidate_path_single_segments <= 1.0000000180025095E-35 then
                        begin
                            if features.delta_candidate_score <= 46623.000000000007 then
                            begin
                                if features.candidate_path_segments <= 1.5000000000000002 then
                                begin
                                    Result := -0.011675741780778955;
                                end
                                else
                                begin
                                    Result := 0.073192288947422898;
                                end;
                            end
                            else
                            begin
                                Result := 0.12813200961222887;
                            end;
                        end
                        else
                        begin
                            Result := 0.0076166952764578988;
                        end;
                    end
                    else
                    begin
                        if features.delta_dict_weight_per_unit <= 24912.000000000004 then
                        begin
                            Result := -0.005584548539047377;
                        end
                        else
                        begin
                            if features.candidate_char_lm_suffix_score <= -6817.4999999999991 then
                            begin
                                Result := -0.010812585028421378;
                            end
                            else
                            begin
                                Result := 0.052857712137528268;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.02578699193843904;
            end;
        end;
    end
    else
    begin
        if features.delta_word_lm_bonus <= -273.49999999999994 then
        begin
            Result := -0.010817556099972188;
        end
        else
        begin
            if features.candidate_ranker_score <= 4267242.5000000009 then
            begin
                if features.candidate_chain_first_stage_score <= 79691.500000000015 then
                begin
                    Result := 0.0067378873493102818;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= -1063.9999999999998 then
                    begin
                        Result := -0.017032994535490939;
                    end
                    else
                    begin
                        Result := 0.00045294483747029623;
                    end;
                end;
            end
            else
            begin
                Result := 0.010311406371933299;
            end;
        end;
    end;
end;

function local_difference_tree_66(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -690.49999999999989 then
    begin
        if features.top_local_lm_r1 <= -6228.4999999999991 then
        begin
            if features.delta_dict_weight_per_unit <= 11348.500000000002 then
            begin
                if features.candidate_local_lm_r2 <= -7813.4999999999991 then
                begin
                    if features.candidate_text_units <= 8.5000000000000018 then
                    begin
                        Result := 0.030379556525652902;
                    end
                    else
                    begin
                        Result := -0.010591876436132668;
                    end;
                end
                else
                begin
                    Result := -0.01970464475993217;
                end;
            end
            else
            begin
                Result := 0.02211579221844933;
            end;
        end
        else
        begin
            if features.delta_dict_weight_per_unit <= 693.50000000000011 then
            begin
                if features.candidate_chain_score_gap <= 6220573.0000000009 then
                begin
                    Result := -0.032168882289684897;
                end
                else
                begin
                    Result := 0.06878056205287042;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -4847.4999999999991 then
                begin
                    Result := -0.012597343467247224;
                end
                else
                begin
                    Result := 0.062351111646263731;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_text_units <= 9.5000000000000018 then
        begin
            if features.candidate_word_lm_bonus <= 559.50000000000011 then
            begin
                Result := 0.012016563794055092;
            end
            else
            begin
                Result := -0.020119738526478314;
            end;
        end
        else
        begin
            if features.delta_local_lm_r0 <= -1867.4999999999998 then
            begin
                if features.different_units <= 1.5000000000000002 then
                begin
                    Result := 0.0047181415432236088;
                end
                else
                begin
                    if features.delta_word_lm_boundary_count <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.016523880851208296;
                    end
                    else
                    begin
                        Result := -0.038660704191628106;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_suffix_lm_per_difference <= -520.37499999999989 then
                begin
                    Result := -0.022346750496872455;
                end
                else
                begin
                    Result := 0.0028994469129733388;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_67(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -53324801.999999993 then
    begin
        if features.delta_local_lm_r3 <= -735.49999999999989 then
        begin
            Result := -0.033553239129925687;
        end
        else
        begin
            if features.delta_dict_weight_per_unit <= -25.499999999999996 then
            begin
                Result := -0.015223487183620448;
            end
            else
            begin
                Result := 0.041076222493276908;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -2181.4999999999995 then
        begin
            Result := -0.03427906097917479;
        end
        else
        begin
            if features.delta_local_lm_r1 <= 37.500000000000007 then
            begin
                if features.candidate_path_segments <= 9.5000000000000018 then
                begin
                    if features.top_local_lm_r1 <= -4488.4999999999991 then
                    begin
                        if features.candidate_source_local_rerank <= 1.0000000180025095E-35 then
                        begin
                            if features.candidate_ranker_score <= -1438049.4999999998 then
                            begin
                                Result := -0.0023308135650652595;
                            end
                            else
                            begin
                                if features.delta_candidate_score <= -58227.499999999993 then
                                begin
                                    if features.delta_chain_first_stage_score <= -89456.999999999985 then
                                    begin
                                        Result := -0.010050627348662664;
                                    end
                                    else
                                    begin
                                        Result := 0.055943432867864927;
                                    end;
                                end
                                else
                                begin
                                    if features.candidate_local_lm_r2 <= -8030.4999999999991 then
                                    begin
                                        if features.candidate_chain_second_stage_score <= -120291951.99999999 then
                                        begin
                                            Result := -0.0027259517055250012;
                                        end
                                        else
                                        begin
                                            Result := 0.035075899057998794;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := 0.0041263019481897791;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.036065251155287824;
                        end;
                    end
                    else
                    begin
                        Result := -0.011898139463077573;
                    end;
                end
                else
                begin
                    Result := -0.018273555054656086;
                end;
            end
            else
            begin
                if features.delta_candidate_score <= -204.49999999999997 then
                begin
                    Result := 0.00056379836006076605;
                end
                else
                begin
                    Result := 0.019257562873822968;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_68(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -53324801.999999993 then
    begin
        if features.delta_char_lm_per_difference <= -191.90000152587888 then
        begin
            Result := -0.030485742360987472;
        end
        else
        begin
            if features.top_local_lm_r1 <= -6093.4999999999991 then
            begin
                Result := -0.025904646407862844;
            end
            else
            begin
                if features.delta_word_lm_boundary_max <= -1.0000000180025095E-35 then
                begin
                    Result := -0.033775775472882956;
                end
                else
                begin
                    Result := 0.067116738782722105;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -1628.4999999999998 then
        begin
            if features.delta_score_per_unit <= 6046.5000000000009 then
            begin
                Result := -0.029014829398831703;
            end
            else
            begin
                Result := 0.051950005221473854;
            end;
        end
        else
        begin
            if features.different_units <= 3.5000000000000004 then
            begin
                if features.candidate_path_segments <= 4.5000000000000009 then
                begin
                    if features.candidate_local_lm_r0 <= -8281.4999999999982 then
                    begin
                        Result := 0.056989485833869404;
                    end
                    else
                    begin
                        Result := 0.0070699058661182826;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= -1622.4999999999998 then
                    begin
                        if features.different_units <= 1.5000000000000002 then
                        begin
                            if features.candidate_char_lm_suffix_score <= -6540.4999999999991 then
                            begin
                                Result := 0.030691265738612476;
                            end
                            else
                            begin
                                Result := -0.013842972925948722;
                            end;
                        end
                        else
                        begin
                            if features.delta_local_lm_r1 <= 585.50000000000011 then
                            begin
                                Result := -0.028301541814526765;
                            end
                            else
                            begin
                                Result := 0.051632306227237294;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_lm_per_difference <= -343.83332824707026 then
                        begin
                            Result := -0.005242797564516101;
                        end
                        else
                        begin
                            Result := 0.0058153761832645057;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.025362292769414232;
            end;
        end;
    end;
end;

function local_difference_tree_69(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -53324801.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1027.4999999999998 then
        begin
            Result := -0.036496041181947922;
        end
        else
        begin
            Result := -0.0069237754844576407;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -2181.4999999999995 then
        begin
            Result := -0.031772297531537722;
        end
        else
        begin
            if features.candidate_ranker_score <= 274528.50000000006 then
            begin
                if features.top_local_lm_r2 <= -6599.4999999999991 then
                begin
                    if features.delta_candidate_score <= -1.0000000180025095E-35 then
                    begin
                        if features.candidate_local_lm_r2 <= -7412.4999999999991 then
                        begin
                            if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                            begin
                                Result := -0.0040007863407883785;
                            end
                            else
                            begin
                                Result := -0.035303791897736164;
                            end;
                        end
                        else
                        begin
                            if features.candidate_chain_first_stage_score <= 86535.500000000015 then
                            begin
                                Result := 0.035727239786886716;
                            end
                            else
                            begin
                                Result := -0.007280372135599943;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -198.58333587646482 then
                        begin
                            Result := 0.034536458961673684;
                        end
                        else
                        begin
                            Result := -0.00024678077769775346;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_score <= -79.499999999999986 then
                    begin
                        if features.top_local_lm_r0 <= -4112.4999999999991 then
                        begin
                            Result := -0.0066875675057662476;
                        end
                        else
                        begin
                            Result := -0.026117712809558422;
                        end;
                    end
                    else
                    begin
                        if features.candidate_word_lm_bonus <= 567.50000000000011 then
                        begin
                            if features.delta_local_lm_r0 <= -1537.4999999999998 then
                            begin
                                Result := -0.035214679005058973;
                            end
                            else
                            begin
                                Result := 0.02244477831010798;
                            end;
                        end
                        else
                        begin
                            Result := -0.020968645515711412;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.0054829215951275054;
            end;
        end;
    end;
end;

function local_difference_tree_70(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -25449907.999999996 then
    begin
        Result := -0.025878327424324232;
    end
    else
    begin
        if features.delta_char_lm_score <= -1694.4999999999998 then
        begin
            if features.delta_score_per_unit <= 6046.5000000000009 then
            begin
                Result := -0.029241904568720944;
            end
            else
            begin
                Result := 0.04850236670531758;
            end;
        end
        else
        begin
            if features.delta_dict_weight <= -8585.4999999999982 then
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    if features.delta_local_lm_r1 <= -539.49999999999989 then
                    begin
                        if features.delta_chain_score_gap <= 5423999.5000000009 then
                        begin
                            if features.delta_path_single_segments <= -1.4999999999999998 then
                            begin
                                Result := 0.0097821038644539202;
                            end
                            else
                            begin
                                Result := -0.025397091077003553;
                            end;
                        end
                        else
                        begin
                            Result := 0.064151850185146658;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r1 <= -6149.4999999999991 then
                        begin
                            Result := -0.004790901504851364;
                        end
                        else
                        begin
                            if features.candidate_chain_first_stage_score <= 56172.500000000007 then
                            begin
                                Result := 0.029669699527150782;
                            end
                            else
                            begin
                                Result := -0.012958009805714413;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.082691156401164451;
                end;
            end
            else
            begin
                if features.top_local_lm_r0 <= -3997.4999999999995 then
                begin
                    if features.candidate_text_units <= 10.500000000000002 then
                    begin
                        if features.delta_candidate_score <= -43159.499999999993 then
                        begin
                            Result := -0.023275802553146367;
                        end
                        else
                        begin
                            Result := 0.01295634257708585;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_lm_score <= -265.49999999999994 then
                        begin
                            Result := -0.0083788570671898474;
                        end
                        else
                        begin
                            Result := 0.0078094373426494928;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.008871860485734042;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_71(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -25449907.999999996 then
    begin
        Result := -0.026997621251256168;
    end
    else
    begin
        if features.delta_char_lm_score <= -1694.4999999999998 then
        begin
            Result := -0.02468428628550972;
        end
        else
        begin
            if features.different_units <= 3.5000000000000004 then
            begin
                if features.delta_chain_second_stage_score <= -338456735.99999994 then
                begin
                    Result := -0.037947767424993804;
                end
                else
                begin
                    if features.delta_chain_score_gap <= 79774416.000000015 then
                    begin
                        if features.delta_word_lm_zero_count <= -5.4999999999999991 then
                        begin
                            Result := 0.032994588942376897;
                        end
                        else
                        begin
                            if features.delta_dict_weight <= -6985.9999999999991 then
                            begin
                                if features.delta_score_per_unit <= 5001.5000000000009 then
                                begin
                                    if features.delta_local_lm_r2 <= -617.49999999999989 then
                                    begin
                                        if features.delta_path_single_segments <= -1.4999999999999998 then
                                        begin
                                            if features.candidate_path_max_segment_units <= 6.5000000000000009 then
                                            begin
                                                Result := 0.048973249843534766;
                                            end
                                            else
                                            begin
                                                Result := -0.029013057266671981;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := -0.025853656318830628;
                                        end;
                                    end
                                    else
                                    begin
                                        if features.candidate_local_lm_r1 <= -6543.4999999999991 then
                                        begin
                                            Result := -0.0085944554811783098;
                                        end
                                        else
                                        begin
                                            if features.candidate_dict_weight_per_unit <= 3883.5000000000005 then
                                            begin
                                                Result := 0.022785062441971978;
                                            end
                                            else
                                            begin
                                                Result := -0.0044919729538609897;
                                            end;
                                        end;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.081355194465546565;
                                end;
                            end
                            else
                            begin
                                if features.candidate_local_lm_r2 <= -7155.4999999999991 then
                                begin
                                    Result := 0.011166128582890266;
                                end
                                else
                                begin
                                    Result := 0.0013476005930445119;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.038339122004528381;
                    end;
                end;
            end
            else
            begin
                Result := -0.026669086970607561;
            end;
        end;
    end;
end;

function local_difference_tree_72(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -331050399.99999994 then
    begin
        Result := -0.040367305046114056;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1815.4999999999998 then
        begin
            if features.top_local_lm_r1 <= -6505.4999999999991 then
            begin
                if features.top_local_lm_r2 <= -7054.4999999999991 then
                begin
                    Result := 0.063894625186638576;
                end
                else
                begin
                    Result := -0.0046014469006770749;
                end;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -26806882.999999996 then
                begin
                    Result := -0.022000365737320032;
                end
                else
                begin
                    if features.top_local_lm_r3 <= -5558.4999999999991 then
                    begin
                        Result := 0.035035860292245931;
                    end
                    else
                    begin
                        Result := -0.019149626210357675;
                    end;
                end;
            end;
        end
        else
        begin
            if features.same_prefix_units <= 1.0000000180025095E-35 then
            begin
                if features.delta_char_lm_per_difference <= -208.41666412353513 then
                begin
                    Result := -0.021754570704582723;
                end
                else
                begin
                    Result := 0.0019379421434491996;
                end;
            end
            else
            begin
                if features.delta_word_lm_bonus <= -273.49999999999994 then
                begin
                    Result := -0.010810972168324063;
                end
                else
                begin
                    if features.candidate_local_lm_r0 <= -4210.9999999999991 then
                    begin
                        if features.top_local_lm_r2 <= -4783.4999999999991 then
                        begin
                            if features.delta_local_lm_r3 <= -1281.4999999999998 then
                            begin
                                if features.delta_local_lm_r0 <= -312.49999999999994 then
                                begin
                                    Result := 0.0067192324553258563;
                                end
                                else
                                begin
                                    Result := 0.070153705116928672;
                                end;
                            end
                            else
                            begin
                                Result := 0.0034644394338090279;
                            end;
                        end
                        else
                        begin
                            Result := -0.013933745799818563;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r3 <= -5795.4999999999991 then
                        begin
                            Result := 0.0048997170882368836;
                        end
                        else
                        begin
                            Result := 0.028705826868180857;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_73(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -704.49999999999989 then
    begin
        if features.top_local_lm_r1 <= -6345.4999999999991 then
        begin
            if features.candidate_local_lm_r2 <= -6454.4999999999991 then
            begin
                if features.delta_local_lm_r1 <= -539.49999999999989 then
                begin
                    if features.candidate_local_lm_r0 <= -8513.4999999999982 then
                    begin
                        Result := 0.038258166017074026;
                    end
                    else
                    begin
                        Result := -0.0045597791705815757;
                    end;
                end
                else
                begin
                    Result := 0.037489550202755184;
                end;
            end
            else
            begin
                Result := -0.040945458016465659;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 2979102.5000000005 then
            begin
                Result := -0.023807879057289351;
            end
            else
            begin
                if features.candidate_word_lm_zero_count <= 3.5000000000000004 then
                begin
                    if features.top_local_lm_r0 <= -4160.4999999999991 then
                    begin
                        if features.delta_local_lm_r2 <= -891.49999999999989 then
                        begin
                            Result := 0.033524008998280959;
                        end
                        else
                        begin
                            Result := -0.041685020159156559;
                        end;
                    end
                    else
                    begin
                        Result := -0.033002371527830886;
                    end;
                end
                else
                begin
                    Result := -0.030740932038548552;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_chain_first_stage_score <= -115127.99999999999 then
        begin
            if features.delta_local_lm_r1 <= -309.49999999999994 then
            begin
                Result := -0.028022440520617493;
            end
            else
            begin
                Result := 0.00098531787210020118;
            end;
        end
        else
        begin
            if features.candidate_score_per_unit <= 228.50000000000003 then
            begin
                Result := 0.031139037881274305;
            end
            else
            begin
                if features.delta_path_max_segment_units <= -3.4999999999999996 then
                begin
                    if features.delta_score_per_unit <= -5318.4999999999991 then
                    begin
                        Result := -0.027545255846734066;
                    end
                    else
                    begin
                        Result := 0.030079424258656659;
                    end;
                end
                else
                begin
                    Result := 0.0025353943927568872;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_74(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.041608132454392467;
    end
    else
    begin
        if features.delta_char_lm_score <= -487.49999999999994 then
        begin
            if features.delta_candidate_score <= -1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r3 <= -8047.4999999999991 then
                begin
                    Result := 0.043157426934135386;
                end
                else
                begin
                    Result := -0.020198157374956321;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -4915.4999999999991 then
                begin
                    if features.delta_chain_first_stage_score <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.027090550384203761;
                    end
                    else
                    begin
                        if features.same_suffix_units <= 1.5000000000000002 then
                        begin
                            if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.044110125379084042;
                            end
                            else
                            begin
                                Result := 0.0008287737490711676;
                            end;
                        end
                        else
                        begin
                            Result := 0.0032661293660757079;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.022762383363462362;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r0 <= -2146.4999999999995 then
            begin
                Result := -0.019236552001035089;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -4239.9999999999991 then
                begin
                    if features.same_suffix_units <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.011330637798402874;
                    end
                    else
                    begin
                        if features.delta_local_lm_r0 <= -2028.4999999999998 then
                        begin
                            if features.candidate_word_lm_boundary_max <= 1357.5000000000002 then
                            begin
                                Result := 0.059544010931998348;
                            end
                            else
                            begin
                                Result := -0.015561624896610568;
                            end;
                        end
                        else
                        begin
                            Result := 0.0038224483109451923;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_word_lm_bonus <= 753.50000000000011 then
                    begin
                        Result := 0.017431506326731291;
                    end
                    else
                    begin
                        Result := -0.026927560960720274;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_75(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -23763997.999999996 then
    begin
        if features.candidate_local_lm_r0 <= -9084.9999999999982 then
        begin
            Result := 0.075703462661832033;
        end
        else
        begin
            if features.candidate_dict_weight_per_unit <= 11087.500000000002 then
            begin
                Result := -0.03244599488430934;
            end
            else
            begin
                Result := 0.021341023496585981;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -2617.4999999999995 then
        begin
            Result := -0.035141304008885037;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.candidate_chain_score_gap <= -197497767.99999997 then
                begin
                    if features.delta_word_lm_boundary_max <= -1093.4999999999998 then
                    begin
                        Result := -0.022520938993931993;
                    end
                    else
                    begin
                        Result := 0.057951526810717864;
                    end;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -4236.4999999999991 then
                    begin
                        if features.same_prefix_units <= 1.0000000180025095E-35 then
                        begin
                            if features.candidate_char_lm_suffix_score <= -5312.4999999999991 then
                            begin
                                Result := -0.00033010273224545847;
                            end
                            else
                            begin
                                Result := -0.034124108283684278;
                            end;
                        end
                        else
                        begin
                            if features.delta_path_single_segments <= -1.4999999999999998 then
                            begin
                                if features.same_suffix_units <= 1.0000000180025095E-35 then
                                begin
                                    Result := 0.06915928661214174;
                                end
                                else
                                begin
                                    Result := 0.013545799413721931;
                                end;
                            end
                            else
                            begin
                                Result := 0.0039467851314194469;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_lm_suffix_score <= -48.499999999999993 then
                        begin
                            Result := -0.0205309008747659;
                        end
                        else
                        begin
                            if features.candidate_word_lm_supported_ratio <= 207.00000000000003 then
                            begin
                                Result := 0.048066919282437413;
                            end
                            else
                            begin
                                Result := -0.04217189613193198;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0051345525237936505;
            end;
        end;
    end;
end;

function local_difference_tree_76(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -1694.4999999999998 then
    begin
        if features.delta_score_per_unit <= 6046.5000000000009 then
        begin
            Result := -0.032098034017920156;
        end
        else
        begin
            Result := 0.035391725577774695;
        end;
    end
    else
    begin
        if features.delta_word_lm_bonus <= -266.49999999999994 then
        begin
            if features.delta_local_lm_r3 <= -868.49999999999989 then
            begin
                Result := -0.038079846161022224;
            end
            else
            begin
                Result := -0.0060158086109854724;
            end;
        end
        else
        begin
            if features.delta_word_lm_boundary_count <= -1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r1 <= -5770.4999999999991 then
                begin
                    Result := 0.023110667763652289;
                end
                else
                begin
                    Result := -0.0067175160904389851;
                end;
            end
            else
            begin
                if features.delta_dict_weight <= -8585.4999999999982 then
                begin
                    if features.delta_candidate_score <= 46623.000000000007 then
                    begin
                        if features.delta_local_lm_r1 <= -566.49999999999989 then
                        begin
                            if features.candidate_chain_score_gap <= 6220573.0000000009 then
                            begin
                                Result := -0.023041515505431081;
                            end
                            else
                            begin
                                Result := 0.074220061088197245;
                            end;
                        end
                        else
                        begin
                            Result := 0.00092174977488895847;
                        end;
                    end
                    else
                    begin
                        Result := 0.098093133490263912;
                    end;
                end
                else
                begin
                    if features.delta_candidate_score <= 28464.000000000004 then
                    begin
                        if features.candidate_chain_score_gap <= -197497767.99999997 then
                        begin
                            if features.top_local_lm_r1 <= -4050.4999999999995 then
                            begin
                                if features.candidate_chain_first_stage_score <= 68644.500000000015 then
                                begin
                                    Result := 0.070701250558242418;
                                end
                                else
                                begin
                                    Result := -0.011202685655339438;
                                end;
                            end
                            else
                            begin
                                Result := 0.098284907333749949;
                            end;
                        end
                        else
                        begin
                            Result := 0.0042800810520549166;
                        end;
                    end
                    else
                    begin
                        Result := -0.015976432020378212;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_77(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -39594865.999999993 then
    begin
        if features.delta_local_lm_r2 <= -1686.4999999999998 then
        begin
            if features.delta_candidate_score <= 42869.000000000007 then
            begin
                Result := -0.033714976059105721;
            end
            else
            begin
                if features.delta_chain_second_stage_score <= -120491055.99999999 then
                begin
                    Result := -0.030369055027508085;
                end
                else
                begin
                    Result := 0.075261596257782989;
                end;
            end;
        end
        else
        begin
            if features.candidate_text_units <= 12.500000000000002 then
            begin
                if features.delta_candidate_score <= 8999.5000000000018 then
                begin
                    if features.candidate_local_lm_r3 <= -6632.4999999999991 then
                    begin
                        Result := -0.014999727948355057;
                    end
                    else
                    begin
                        Result := 0.0080295953259761684;
                    end;
                end
                else
                begin
                    Result := 0.025993943683984458;
                end;
            end
            else
            begin
                Result := -0.022499048086854719;
            end;
        end;
    end
    else
    begin
        if features.candidate_char_lm_score <= -3164.4999999999995 then
        begin
            if features.top_local_lm_r1 <= -4879.4999999999991 then
            begin
                if features.delta_word_lm_zero_count <= -2.4999999999999996 then
                begin
                    if features.delta_chain_first_stage_score <= 60168.500000000007 then
                    begin
                        Result := 0.010180478148661057;
                    end
                    else
                    begin
                        Result := 0.061400169852070904;
                    end;
                end
                else
                begin
                    if features.delta_word_lm_bonus <= -231.49999999999997 then
                    begin
                        Result := -0.01799982592312236;
                    end
                    else
                    begin
                        Result := 0.0031046101251380308;
                    end;
                end;
            end
            else
            begin
                Result := -0.0094752555682610824;
            end;
        end
        else
        begin
            if features.delta_score_per_unit <= -1.0000000180025095E-35 then
            begin
                if features.candidate_chain_second_stage_score <= 438528064.00000006 then
                begin
                    Result := 0.056316028010586328;
                end
                else
                begin
                    Result := -0.0065083637109543966;
                end;
            end
            else
            begin
                Result := -0.0083817822770014122;
            end;
        end;
    end;
end;

function local_difference_tree_78(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -2062.4999999999995 then
    begin
        if features.top_local_lm_r2 <= -5910.4999999999991 then
        begin
            Result := 0.016231439445831865;
        end
        else
        begin
            Result := -0.028817982386373734;
        end;
    end
    else
    begin
        if features.delta_chain_second_stage_score <= -331050399.99999994 then
        begin
            Result := -0.037974298749108057;
        end
        else
        begin
            if features.candidate_text_units <= 10.500000000000002 then
            begin
                if features.candidate_ranker_score <= 3716149.5000000005 then
                begin
                    Result := 0.0015452796513969989;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -7277.4999999999991 then
                    begin
                        if features.delta_char_lm_score <= 168.50000000000003 then
                        begin
                            Result := 0.0073083852355941151;
                        end
                        else
                        begin
                            Result := -0.039388187329670171;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r3 <= -6564.4999999999991 then
                        begin
                            Result := 0.027306690423352348;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r0 <= -4210.9999999999991 then
                            begin
                                Result := 0.0;
                            end
                            else
                            begin
                                Result := 0.033044423098774332;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_local_lm_r0 <= -2321.4999999999995 then
                begin
                    Result := -0.03203004450075677;
                end
                else
                begin
                    if features.delta_local_lm_r3 <= -226.49999999999997 then
                    begin
                        if features.candidate_local_lm_r1 <= -6461.4999999999991 then
                        begin
                            Result := 0.00024499198308037504;
                        end
                        else
                        begin
                            Result := -0.01685216571613532;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r3 <= -5995.4999999999991 then
                        begin
                            if features.candidate_chain_second_stage_score <= 166404144.00000003 then
                            begin
                                Result := 0.0021616947797951382;
                            end
                            else
                            begin
                                Result := -0.031085386074128619;
                            end;
                        end
                        else
                        begin
                            Result := 0.015189267831171751;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_79(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -25449907.999999996 then
    begin
        if features.candidate_local_lm_r0 <= -9084.9999999999982 then
        begin
            Result := 0.059868208125789933;
        end
        else
        begin
            if features.candidate_chain_first_stage_score <= 123310.00000000001 then
            begin
                Result := -0.032084044903162232;
            end
            else
            begin
                if features.top_local_lm_r1 <= -6687.4999999999991 then
                begin
                    Result := 0.12358114394500107;
                end
                else
                begin
                    Result := -0.026170547133593899;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -2181.4999999999995 then
        begin
            Result := -0.030463356227813529;
        end
        else
        begin
            if features.delta_candidate_score <= -8645.4999999999982 then
            begin
                if features.candidate_dict_weight <= 79476.000000000015 then
                begin
                    if features.candidate_local_lm_r3 <= -4782.4999999999991 then
                    begin
                        if features.delta_candidate_score <= -11149.499999999998 then
                        begin
                            if features.delta_chain_first_stage_score <= -101723.99999999999 then
                            begin
                                if features.delta_local_lm_r2 <= 320.50000000000006 then
                                begin
                                    Result := -0.029284686577158339;
                                end
                                else
                                begin
                                    Result := 0.011575842481180137;
                                end;
                            end
                            else
                            begin
                                Result := 0.017482030712992678;
                            end;
                        end
                        else
                        begin
                            Result := -0.025287105744869857;
                        end;
                    end
                    else
                    begin
                        Result := 0.047593158425642934;
                    end;
                end
                else
                begin
                    Result := -0.015580941380245565;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -8094.4999999999991 then
                begin
                    if features.same_suffix_units <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.048638588105855148;
                    end
                    else
                    begin
                        Result := 0.0064064814607990026;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_score <= -834.49999999999989 then
                    begin
                        Result := -0.010042284108713615;
                    end
                    else
                    begin
                        Result := 0.0036882117111617452;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_80(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -295795519.99999994 then
    begin
        Result := -0.031138356821852713;
    end
    else
    begin
        if features.delta_char_lm_score <= -1694.4999999999998 then
        begin
            if features.delta_score_per_unit <= 6046.5000000000009 then
            begin
                Result := -0.028602662233452786;
            end
            else
            begin
                Result := 0.04187422152766989;
            end;
        end
        else
        begin
            if features.candidate_text_units <= 10.500000000000002 then
            begin
                if features.top_local_lm_r0 <= -4072.4999999999995 then
                begin
                    if features.delta_dict_weight_per_unit <= -748.49999999999989 then
                    begin
                        if features.candidate_local_lm_r1 <= -6543.4999999999991 then
                        begin
                            if features.delta_candidate_score <= 46623.000000000007 then
                            begin
                                if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                                begin
                                    Result := -0.0056016007825906624;
                                end
                                else
                                begin
                                    Result := -0.031626604089515439;
                                end;
                            end
                            else
                            begin
                                Result := 0.088127379678085219;
                            end;
                        end
                        else
                        begin
                            if features.delta_char_lm_score <= -295.49999999999994 then
                            begin
                                Result := -0.011721680316147922;
                            end
                            else
                            begin
                                if features.baseline_abstain_score <= 141826712.00000003 then
                                begin
                                    Result := 0.03166064029934855;
                                end
                                else
                                begin
                                    Result := -0.029614616357368072;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.010754036273626089;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_per_difference <= 11.125000000000002 then
                    begin
                        Result := -0.014773708113461133;
                    end
                    else
                    begin
                        Result := 0.032903159275971455;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_score <= -79.499999999999986 then
                begin
                    if features.same_suffix_units <= 2.5000000000000004 then
                    begin
                        Result := -0.02084023987114084;
                    end
                    else
                    begin
                        Result := -0.0036348283869470717;
                    end;
                end
                else
                begin
                    Result := 0.0069002827676280078;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_81(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -26652957.999999996 then
    begin
        Result := -0.029584648672376052;
    end
    else
    begin
        if features.delta_char_lm_per_difference <= -481.83332824707026 then
        begin
            if features.delta_dict_weight <= -8585.4999999999982 then
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    Result := -0.026978484204192528;
                end
                else
                begin
                    Result := 0.071949785706448471;
                end;
            end
            else
            begin
                if features.same_prefix_units <= 1.0000000180025095E-35 then
                begin
                    Result := -0.028227865740349571;
                end
                else
                begin
                    if features.top_local_lm_r0 <= -3673.4999999999995 then
                    begin
                        if features.top_local_lm_r2 <= -7054.4999999999991 then
                        begin
                            Result := 0.029250839927498013;
                        end
                        else
                        begin
                            Result := 0.00032495805616761421;
                        end;
                    end
                    else
                    begin
                        Result := -0.03992914335100841;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= -5.4999999999999991 then
            begin
                Result := 0.035248600714583009;
            end
            else
            begin
                if features.delta_chain_first_stage_score <= -115127.99999999999 then
                begin
                    if features.top_local_lm_r0 <= -6217.4999999999991 then
                    begin
                        Result := 0.022660632090168095;
                    end
                    else
                    begin
                        Result := -0.024127972640063344;
                    end;
                end
                else
                begin
                    if features.candidate_candidate_score <= 55537.500000000007 then
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -466.16667175292963 then
                        begin
                            Result := 0.092457464779247656;
                        end
                        else
                        begin
                            if features.top_local_lm_r1 <= -7164.4999999999991 then
                            begin
                                if features.delta_char_lm_suffix_score <= -476.49999999999994 then
                                begin
                                    Result := 0.043367868690789617;
                                end
                                else
                                begin
                                    Result := -0.018322626165376103;
                                end;
                            end
                            else
                            begin
                                Result := 0.019657241561636986;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0020678839898802905;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_82(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -273.49999999999994 then
    begin
        if features.delta_local_lm_r2 <= -491.49999999999994 then
        begin
            Result := -0.028636455577606367;
        end
        else
        begin
            if features.delta_char_lm_score <= -14.499999999999998 then
            begin
                if features.same_prefix_units <= 5.5000000000000009 then
                begin
                    Result := 0.031806601944209985;
                end
                else
                begin
                    Result := -0.016400119285244895;
                end;
            end
            else
            begin
                if features.delta_word_lm_bonus <= -530.49999999999989 then
                begin
                    Result := 0.0096178900696701364;
                end
                else
                begin
                    Result := -0.042709526899832796;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -2181.4999999999995 then
        begin
            Result := -0.034182507008846459;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -9084.9999999999982 then
            begin
                Result := 0.044454845315415624;
            end
            else
            begin
                if features.candidate_ranker_score <= 3663511.5000000005 then
                begin
                    if features.difference_span_units <= 6.5000000000000009 then
                    begin
                        if features.delta_candidate_score <= 8999.5000000000018 then
                        begin
                            Result := -0.0019088854214584924;
                        end
                        else
                        begin
                            Result := 0.0099115712002594523;
                        end;
                    end
                    else
                    begin
                        Result := -0.035550923017419619;
                    end;
                end
                else
                begin
                    if features.candidate_dict_weight <= 133458.00000000003 then
                    begin
                        if features.candidate_local_lm_r2 <= -8158.4999999999991 then
                        begin
                            Result := 0.024105655765269504;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r2 <= -7664.4999999999991 then
                            begin
                                Result := -0.027654368703173515;
                            end
                            else
                            begin
                                if features.delta_word_lm_boundary_first <= 1390.5000000000002 then
                                begin
                                    Result := 0.00080474498467297015;
                                end
                                else
                                begin
                                    Result := 0.041438121497243782;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.01269862581653868;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_83(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -331050399.99999994 then
    begin
        Result := -0.038696478749446921;
    end
    else
    begin
        if features.candidate_ranker_score_gap <= -22190821.999999996 then
        begin
            if features.delta_chain_first_stage_score <= 283.00000000000006 then
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    if features.delta_dict_weight <= -112271.99999999999 then
                    begin
                        if features.delta_local_lm_r3 <= -197.49999999999997 then
                        begin
                            Result := -0.032926894686625276;
                        end
                        else
                        begin
                            if features.delta_chain_second_stage_score <= -61981971.999999993 then
                            begin
                                Result := -0.018753376021754642;
                            end
                            else
                            begin
                                Result := 0.020890799667648025;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_lm_suffix_score <= -1756.4999999999998 then
                        begin
                            Result := -0.032491980244232131;
                        end
                        else
                        begin
                            if features.delta_dict_weight_per_unit <= -10272.999999999998 then
                            begin
                                if features.candidate_char_lm_score <= -6079.4999999999991 then
                                begin
                                    Result := -0.025597161427159083;
                                end
                                else
                                begin
                                    Result := 0.054071920807600135;
                                end;
                            end
                            else
                            begin
                                if features.delta_dict_weight <= -8585.4999999999982 then
                                begin
                                    Result := -0.0073785398131944726;
                                end
                                else
                                begin
                                    Result := 0.0042380529869777079;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.064690737327664977;
                end;
            end
            else
            begin
                if features.delta_word_lm_boundary_count <= -4.4999999999999991 then
                begin
                    Result := 0.038280824418957256;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -6486.4999999999991 then
                    begin
                        if features.candidate_candidate_score <= -17760.499999999996 then
                        begin
                            Result := 0.068316923825621975;
                        end
                        else
                        begin
                            Result := -0.0088839300365947376;
                        end;
                    end
                    else
                    begin
                        Result := -0.031826284913001129;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.0087656991558149305;
        end;
    end;
end;

function local_difference_tree_84(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -290.49999999999994 then
    begin
        Result := -0.016344883912042515;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -4210.9999999999991 then
        begin
            if features.top_local_lm_r2 <= -4783.4999999999991 then
            begin
                if features.candidate_chain_score_gap <= -197497767.99999997 then
                begin
                    if features.candidate_char_lm_suffix_score <= -4981.4999999999991 then
                    begin
                        if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                        begin
                            if features.same_prefix_units <= 4.5000000000000009 then
                            begin
                                Result := 0.0038504684895914903;
                            end
                            else
                            begin
                                if features.top_local_lm_r3 <= -6553.4999999999991 then
                                begin
                                    Result := 0.17126724824981843;
                                end
                                else
                                begin
                                    Result := 0.039167143185879251;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.023954258893703253;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r2 <= -6477.4999999999991 then
                        begin
                            Result := 0.0031310465848399288;
                        end
                        else
                        begin
                            Result := 0.15550491350060061;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_candidate_score <= 7555.0000000000009 then
                    begin
                        Result := -0.0020274288735366002;
                    end
                    else
                    begin
                        if features.delta_dict_weight <= 9015.0000000000018 then
                        begin
                            if features.candidate_local_lm_r3 <= -7300.4999999999991 then
                            begin
                                Result := 0.059484037773782562;
                            end
                            else
                            begin
                                Result := 0.0098039255684292236;
                            end;
                        end
                        else
                        begin
                            Result := -0.0030164275724414856;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.same_suffix_units <= 7.5000000000000009 then
                begin
                    Result := -0.022468913310919887;
                end
                else
                begin
                    if features.candidate_char_lm_score <= -6107.4999999999991 then
                    begin
                        Result := 0.096423339781124121;
                    end
                    else
                    begin
                        Result := 0.00068056401730853106;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.010566797459097655;
        end;
    end;
end;

function local_difference_tree_85(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -26652957.999999996 then
    begin
        if features.delta_char_suffix_lm_per_difference <= -165.90000152587888 then
        begin
            Result := -0.035686969793912733;
        end
        else
        begin
            Result := 0.014294697170673257;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -1694.4999999999998 then
        begin
            Result := -0.020055560560814884;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
            begin
                if features.delta_chain_score_gap <= -196976087.99999997 then
                begin
                    if features.candidate_local_lm_r1 <= -6890.4999999999991 then
                    begin
                        Result := 0.060448788054852501;
                    end
                    else
                    begin
                        Result := 0.0015457545897018558;
                    end;
                end
                else
                begin
                    Result := 0.0022414209967037595;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -7432.4999999999991 then
                begin
                    if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.040769868203220025;
                    end
                    else
                    begin
                        Result := -0.025266671039429089;
                    end;
                end
                else
                begin
                    if features.candidate_text_units <= 7.5000000000000009 then
                    begin
                        if features.delta_chain_score_gap <= -138741999.99999997 then
                        begin
                            Result := -0.016339606229620825;
                        end
                        else
                        begin
                            Result := 0.0452873231450086;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r3 <= -377.49999999999994 then
                        begin
                            Result := -0.013010545549177006;
                        end
                        else
                        begin
                            if features.same_prefix_units <= 4.5000000000000009 then
                            begin
                                Result := 0.015796422018516627;
                            end
                            else
                            begin
                                if features.top_local_lm_r2 <= -7344.4999999999991 then
                                begin
                                    Result := 0.027519474369036252;
                                end
                                else
                                begin
                                    if features.delta_dict_weight_per_unit <= -20.499999999999996 then
                                    begin
                                        Result := -0.025999024538412852;
                                    end
                                    else
                                    begin
                                        Result := 0.0060855549983615973;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_86(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.03776425930413984;
    end
    else
    begin
        if features.delta_char_lm_score <= -2181.4999999999995 then
        begin
            Result := -0.031080824372847156;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -8513.4999999999982 then
            begin
                if features.candidate_path_segments <= 5.5000000000000009 then
                begin
                    Result := 0.043028059591673488;
                end
                else
                begin
                    Result := -0.023985889183174947;
                end;
            end
            else
            begin
                if features.delta_local_lm_r1 <= 37.500000000000007 then
                begin
                    if features.delta_path_segments <= -1.4999999999999998 then
                    begin
                        Result := -0.014615528814853687;
                    end
                    else
                    begin
                        if features.candidate_path_segments <= 9.5000000000000018 then
                        begin
                            if features.top_local_lm_r1 <= -4488.4999999999991 then
                            begin
                                Result := 0.0024396210162124922;
                            end
                            else
                            begin
                                if features.delta_chain_second_stage_score <= -194309687.99999997 then
                                begin
                                    Result := 0.031620664394306809;
                                end
                                else
                                begin
                                    Result := -0.015610103890618484;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.delta_dict_weight_per_unit <= -14.499999999999998 then
                            begin
                                Result := -0.039907436318572145;
                            end
                            else
                            begin
                                if features.delta_dict_weight <= 8903.0000000000018 then
                                begin
                                    Result := 0.009725965430223759;
                                end
                                else
                                begin
                                    Result := -0.02487264355188017;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -5560.4999999999991 then
                    begin
                        if features.candidate_text_units <= 15.500000000000002 then
                        begin
                            Result := -0.00026050883364245824;
                        end
                        else
                        begin
                            Result := 0.020472958965044193;
                        end;
                    end
                    else
                    begin
                        if features.candidate_has_dict_weight <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.062149285299515231;
                        end
                        else
                        begin
                            Result := 0.013692838142329727;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_87(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -309088975.99999994 then
    begin
        Result := -0.033973815243052083;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -2617.4999999999995 then
        begin
            Result := -0.034469837908415027;
        end
        else
        begin
            if features.delta_word_lm_bonus <= -221.49999999999997 then
            begin
                if features.candidate_local_lm_r3 <= -5569.4999999999991 then
                begin
                    if features.candidate_dict_weight_per_unit <= 12646.500000000002 then
                    begin
                        Result := -0.021580326535643266;
                    end
                    else
                    begin
                        Result := 0.019082002140234765;
                    end;
                end
                else
                begin
                    if features.candidate_char_lm_score <= -4576.4999999999991 then
                    begin
                        if features.candidate_path_single_segments <= 2.5000000000000004 then
                        begin
                            Result := 0.049427257197645319;
                        end
                        else
                        begin
                            Result := -0.021465977094625249;
                        end;
                    end
                    else
                    begin
                        Result := -0.0045329416893940397;
                    end;
                end;
            end
            else
            begin
                if features.delta_word_lm_boundary_count <= -5.4999999999999991 then
                begin
                    Result := 0.040580148548339169;
                end
                else
                begin
                    if features.same_prefix_units <= 1.0000000180025095E-35 then
                    begin
                        if features.delta_char_lm_score <= -473.49999999999994 then
                        begin
                            Result := -0.022624726157699535;
                        end
                        else
                        begin
                            if features.candidate_word_lm_boundary_count <= 4.5000000000000009 then
                            begin
                                if features.top_local_lm_r1 <= -6830.4999999999991 then
                                begin
                                    Result := -0.0091979687621736635;
                                end
                                else
                                begin
                                    Result := 0.03692856972784804;
                                end;
                            end
                            else
                            begin
                                Result := -0.011135541853434874;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_path_single_segments <= -1.4999999999999998 then
                        begin
                            if features.same_suffix_units <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.05694144623415822;
                            end
                            else
                            begin
                                Result := 0.011110248590589034;
                            end;
                        end
                        else
                        begin
                            Result := 0.0018765074400827204;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_88(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -2447.4999999999995 then
    begin
        Result := -0.027925147117426771;
    end
    else
    begin
        if features.delta_chain_second_stage_score <= -331050399.99999994 then
        begin
            Result := -0.036728296259093816;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -9084.9999999999982 then
            begin
                if features.delta_dict_weight <= 711.50000000000011 then
                begin
                    Result := 0.083324986598725725;
                end
                else
                begin
                    Result := -0.0004913465720095912;
                end;
            end
            else
            begin
                if features.candidate_ranker_score <= -21988119.999999996 then
                begin
                    if features.candidate_local_lm_r1 <= -6201.4999999999991 then
                    begin
                        Result := -0.024023691443887479;
                    end
                    else
                    begin
                        if features.delta_chain_second_stage_score <= -33143027.999999996 then
                        begin
                            Result := -0.015791249511765488;
                        end
                        else
                        begin
                            Result := 0.042040088825487952;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_chain_score_gap <= -197497767.99999997 then
                    begin
                        if features.candidate_ranker_score_gap <= -46508689.999999993 then
                        begin
                            Result := -0.0049926140208131796;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r0 <= -4669.4999999999991 then
                            begin
                                Result := 0.081961372652595024;
                            end
                            else
                            begin
                                Result := -0.012582642251706511;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_chain_score_gap <= 79774416.000000015 then
                        begin
                            if features.delta_path_single_segments <= -1.4999999999999998 then
                            begin
                                if features.same_suffix_units <= 1.0000000180025095E-35 then
                                begin
                                    Result := 0.062184564719499895;
                                end
                                else
                                begin
                                    Result := 0.0062679584905829117;
                                end;
                            end
                            else
                            begin
                                if features.delta_char_lm_score <= -473.49999999999994 then
                                begin
                                    Result := -0.0061028937285118254;
                                end
                                else
                                begin
                                    Result := 0.0030833644846390397;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.035191330869303136;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_89(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -290.49999999999994 then
    begin
        if features.delta_local_lm_r2 <= -491.49999999999994 then
        begin
            Result := -0.027855095248493916;
        end
        else
        begin
            if features.delta_path_max_segment_units <= 1.0000000180025095E-35 then
            begin
                Result := -0.016430067046267715;
            end
            else
            begin
                Result := 0.020816369517035551;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -2181.4999999999995 then
        begin
            Result := -0.031672227022023582;
        end
        else
        begin
            if features.delta_chain_first_stage_score <= -115127.99999999999 then
            begin
                if features.delta_local_lm_r0 <= 745.50000000000011 then
                begin
                    if features.delta_word_lm_boundary_count <= -5.4999999999999991 then
                    begin
                        Result := 0.019411979261641649;
                    end
                    else
                    begin
                        Result := -0.034516429658606275;
                    end;
                end
                else
                begin
                    if features.candidate_ranker_score_gap <= -36943189.999999993 then
                    begin
                        Result := -0.024317497622975456;
                    end
                    else
                    begin
                        Result := 0.031595455568773058;
                    end;
                end;
            end
            else
            begin
                if features.candidate_score_per_unit <= 228.50000000000003 then
                begin
                    if features.delta_dict_weight <= -148183.99999999997 then
                    begin
                        Result := 0.091986473314165096;
                    end
                    else
                    begin
                        if features.delta_chain_second_stage_score <= -120491055.99999999 then
                        begin
                            Result := -0.019658289806155201;
                        end
                        else
                        begin
                            Result := 0.032824244630645934;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_word_lm_boundary_count <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.013573203889319712;
                    end
                    else
                    begin
                        if features.delta_chain_first_stage_score <= 645.50000000000011 then
                        begin
                            if features.delta_score_per_unit <= 6046.5000000000009 then
                            begin
                                Result := 0.0017201889245715004;
                            end
                            else
                            begin
                                Result := 0.074340503579835529;
                            end;
                        end
                        else
                        begin
                            Result := -0.0075463517280671645;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_90(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -53324801.999999993 then
    begin
        if features.delta_local_lm_r2 <= -800.49999999999989 then
        begin
            Result := -0.035685725634808166;
        end
        else
        begin
            if features.candidate_local_lm_r3 <= -5983.4999999999991 then
            begin
                Result := -0.01908333207659536;
            end
            else
            begin
                if features.delta_dict_weight <= -19656.499999999996 then
                begin
                    Result := 0.0;
                end
                else
                begin
                    Result := 0.072642273055374754;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -2617.4999999999995 then
        begin
            Result := -0.032952884591811039;
        end
        else
        begin
            if features.candidate_word_lm_boundary_count <= 8.5000000000000018 then
            begin
                if features.delta_word_lm_boundary_count <= 6.5000000000000009 then
                begin
                    if features.candidate_ranker_score_gap <= -22190821.999999996 then
                    begin
                        if features.delta_chain_first_stage_score <= 645.50000000000011 then
                        begin
                            if features.delta_score_per_unit <= 6046.5000000000009 then
                            begin
                                Result := 0.0025036231534860628;
                            end
                            else
                            begin
                                Result := 0.064483364649540145;
                            end;
                        end
                        else
                        begin
                            Result := -0.0085523286564604378;
                        end;
                    end
                    else
                    begin
                        Result := 0.010291916387555243;
                    end;
                end
                else
                begin
                    Result := -0.023974309492610063;
                end;
            end
            else
            begin
                if features.delta_local_lm_r1 <= 84.500000000000014 then
                begin
                    if features.delta_dict_weight_per_unit <= -14.499999999999998 then
                    begin
                        Result := -0.042418671822097472;
                    end
                    else
                    begin
                        if features.delta_dict_weight <= 8903.0000000000018 then
                        begin
                            Result := 0.0065878638610139904;
                        end
                        else
                        begin
                            Result := -0.029450695106619202;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_ranker_score_gap <= -28582971.999999996 then
                    begin
                        Result := -0.020668444284161383;
                    end
                    else
                    begin
                        Result := 0.021379644343183714;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_91(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -221.49999999999997 then
    begin
        if features.candidate_local_lm_r3 <= -5569.4999999999991 then
        begin
            Result := -0.020535791813999373;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -4192.4999999999991 then
            begin
                if features.delta_word_lm_boundary_first <= -1216.4999999999998 then
                begin
                    Result := -0.025403998325643523;
                end
                else
                begin
                    if features.candidate_char_lm_score <= -4576.4999999999991 then
                    begin
                        Result := 0.061246532924223669;
                    end
                    else
                    begin
                        Result := 0.0082284546151554089;
                    end;
                end;
            end
            else
            begin
                Result := -0.02651640952138409;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -2181.4999999999995 then
        begin
            Result := -0.03118768166253081;
        end
        else
        begin
            if features.delta_word_lm_boundary_count <= -1.0000000180025095E-35 then
            begin
                if features.same_prefix_units <= 1.0000000180025095E-35 then
                begin
                    Result := -0.025452700811126508;
                end
                else
                begin
                    if features.max_different_run <= 1.5000000000000002 then
                    begin
                        Result := 0.0049180032028525045;
                    end
                    else
                    begin
                        Result := 0.032401832781630238;
                    end;
                end;
            end
            else
            begin
                if features.delta_legacy_rank <= 1.5000000000000002 then
                begin
                    if features.different_units <= 2.5000000000000004 then
                    begin
                        Result := 0.0010691800550979567;
                    end
                    else
                    begin
                        if features.delta_dict_weight <= -576.49999999999989 then
                        begin
                            Result := 0.00075972754934553691;
                        end
                        else
                        begin
                            Result := -0.031863209284625479;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_text_units <= 8.5000000000000018 then
                    begin
                        Result := 0.044467445182688616;
                    end
                    else
                    begin
                        if features.delta_char_lm_score <= -251.49999999999997 then
                        begin
                            Result := -0.011122183456299345;
                        end
                        else
                        begin
                            Result := 0.026425577153234348;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_92(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.037045714395006341;
    end
    else
    begin
        if features.different_units <= 3.5000000000000004 then
        begin
            if features.delta_dict_weight_per_unit <= -538.49999999999989 then
            begin
                if features.delta_candidate_score <= 46623.000000000007 then
                begin
                    if features.delta_local_lm_r2 <= -1004.4999999999999 then
                    begin
                        if features.candidate_chain_score_gap <= 6220573.0000000009 then
                        begin
                            Result := -0.028491261675163797;
                        end
                        else
                        begin
                            Result := 0.088099056474912493;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r2 <= -7412.4999999999991 then
                        begin
                            if features.delta_local_lm_r3 <= -811.49999999999989 then
                            begin
                                Result := 0.065475240641408694;
                            end
                            else
                            begin
                                if features.top_local_lm_r0 <= -3673.4999999999995 then
                                begin
                                    Result := -0.024746851451105195;
                                end
                                else
                                begin
                                    Result := 0.056467543260490818;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r0 <= -4558.4999999999991 then
                            begin
                                if features.candidate_char_lm_score <= -5489.4999999999991 then
                                begin
                                    Result := 0.012868447730471444;
                                end
                                else
                                begin
                                    Result := -0.010539746172580246;
                                end;
                            end
                            else
                            begin
                                if features.candidate_dict_weight_per_unit <= 5864.5000000000009 then
                                begin
                                    Result := 0.021995389385832054;
                                end
                                else
                                begin
                                    Result := -0.0099803573947652244;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.055591799001423317;
                end;
            end
            else
            begin
                if features.top_local_lm_r0 <= -3997.4999999999995 then
                begin
                    Result := 0.0045799041460865518;
                end
                else
                begin
                    if features.delta_char_suffix_lm_per_difference <= -7.7499999999999991 then
                    begin
                        Result := -0.016669457427773381;
                    end
                    else
                    begin
                        Result := 0.019945061469333229;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.021603594000147681;
        end;
    end;
end;

function local_difference_tree_93(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -24348361.999999996 then
    begin
        Result := -0.022853620828116764;
    end
    else
    begin
        if features.delta_char_lm_per_difference <= -481.83332824707026 then
        begin
            if features.candidate_local_lm_r0 <= -5774.9999999999991 then
            begin
                if features.top_local_lm_r2 <= -7009.4999999999991 then
                begin
                    Result := 0.038342548004162161;
                end
                else
                begin
                    if features.candidate_ranker_score <= -2736807.4999999995 then
                    begin
                        Result := -0.014169185680161882;
                    end
                    else
                    begin
                        Result := 0.011267418345443961;
                    end;
                end;
            end
            else
            begin
                if features.delta_dict_weight_per_unit <= 21614.500000000004 then
                begin
                    Result := -0.016686518246723063;
                end
                else
                begin
                    if features.top_local_lm_r0 <= -4828.4999999999991 then
                    begin
                        Result := 0.041210989197307688;
                    end
                    else
                    begin
                        Result := -0.018977247580004249;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_path_max_segment_units <= 1.0000000180025095E-35 then
            begin
                if features.max_different_run <= 3.5000000000000004 then
                begin
                    if features.delta_local_lm_r0 <= -1737.4999999999998 then
                    begin
                        Result := -0.010752815599977705;
                    end
                    else
                    begin
                        Result := 0.0026829395422468365;
                    end;
                end
                else
                begin
                    Result := -0.035201733283097676;
                end;
            end
            else
            begin
                if features.delta_chain_second_stage_score <= -107579795.99999999 then
                begin
                    Result := -0.01581430003261735;
                end
                else
                begin
                    if features.top_local_lm_r2 <= -5814.4999999999991 then
                    begin
                        if features.delta_candidate_score <= -1.0000000180025095E-35 then
                        begin
                            if features.delta_char_lm_per_difference <= -208.41666412353513 then
                            begin
                                Result := -0.017528128359299833;
                            end
                            else
                            begin
                                Result := 0.020448281431841735;
                            end;
                        end
                        else
                        begin
                            Result := 0.038182655048329774;
                        end;
                    end
                    else
                    begin
                        Result := -0.0021880810027334577;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_94(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -2944185.9999999995 then
    begin
        if features.delta_char_lm_score <= -800.49999999999989 then
        begin
            if features.top_local_lm_r1 <= -6404.4999999999991 then
            begin
                if features.delta_char_suffix_lm_per_difference <= -423.91667175292963 then
                begin
                    if features.top_local_lm_r0 <= -5397.4999999999991 then
                    begin
                        if features.delta_local_lm_r0 <= 19.500000000000004 then
                        begin
                            if features.delta_candidate_score <= 445.50000000000006 then
                            begin
                                Result := -0.023037585598023897;
                            end
                            else
                            begin
                                Result := 0.069181189997816514;
                            end;
                        end
                        else
                        begin
                            if features.top_local_lm_r0 <= -7100.4999999999991 then
                            begin
                                Result := -0.005508961989565732;
                            end
                            else
                            begin
                                Result := 0.10564271287503896;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.013888687408060296;
                    end;
                end
                else
                begin
                    Result := -0.027438586729112494;
                end;
            end
            else
            begin
                Result := -0.025701314226849528;
            end;
        end
        else
        begin
            if features.candidate_text_units <= 11.500000000000002 then
            begin
                if features.delta_dict_weight <= -112271.99999999999 then
                begin
                    Result := -0.016512783657806455;
                end
                else
                begin
                    if features.delta_score_per_unit <= -748.49999999999989 then
                    begin
                        Result := -0.0067677597429065045;
                    end
                    else
                    begin
                        Result := 0.016121922334635372;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_score <= 92.500000000000014 then
                begin
                    Result := -0.013245661468471712;
                end
                else
                begin
                    Result := 0.01628572636480332;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -4239.9999999999991 then
        begin
            if features.top_local_lm_r1 <= -4455.4999999999991 then
            begin
                Result := 0.00251868101951906;
            end
            else
            begin
                Result := -0.015198684022001615;
            end;
        end
        else
        begin
            Result := 0.012718463406923061;
        end;
    end;
end;

function local_difference_tree_95(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -290.49999999999994 then
    begin
        if features.delta_char_lm_suffix_score <= -476.49999999999994 then
        begin
            Result := -0.032832411729405521;
        end
        else
        begin
            if features.delta_word_lm_per_boundary <= -62.325000762939446 then
            begin
                if features.delta_chain_first_stage_score <= 60168.500000000007 then
                begin
                    Result := -0.0058597900573579753;
                end
                else
                begin
                    Result := 0.043225153842440481;
                end;
            end
            else
            begin
                Result := -0.040749989624706273;
            end;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -4210.9999999999991 then
        begin
            if features.delta_char_lm_score <= -2239.4999999999995 then
            begin
                Result := -0.03207741016084651;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -9084.9999999999982 then
                begin
                    Result := 0.040877881918777642;
                end
                else
                begin
                    if features.delta_dict_weight <= -221.49999999999997 then
                    begin
                        if features.delta_candidate_score <= 46623.000000000007 then
                        begin
                            Result := -0.0058605961145724583;
                        end
                        else
                        begin
                            Result := 0.042812126252258248;
                        end;
                    end
                    else
                    begin
                        Result := 0.0022490558461245014;
                    end;
                end;
            end;
        end
        else
        begin
            if features.same_suffix_units <= 7.5000000000000009 then
            begin
                if features.candidate_ranker_score_gap <= -23551411.999999996 then
                begin
                    if features.delta_score_per_unit <= 37.500000000000007 then
                    begin
                        if features.delta_char_lm_score <= -613.49999999999989 then
                        begin
                            Result := -0.013036608089243324;
                        end
                        else
                        begin
                            Result := 0.020544285875636514;
                        end;
                    end
                    else
                    begin
                        if features.delta_path_segments <= -1.4999999999999998 then
                        begin
                            Result := 0.045608229790203847;
                        end
                        else
                        begin
                            Result := -0.028268509294009272;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.033686912978557769;
                end;
            end
            else
            begin
                Result := -0.010693545630100625;
            end;
        end;
    end;
end;

function local_difference_tree_96(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -25449907.999999996 then
    begin
        if features.candidate_local_lm_r0 <= -9084.9999999999982 then
        begin
            Result := 0.06142386884475861;
        end
        else
        begin
            if features.candidate_chain_first_stage_score <= 123310.00000000001 then
            begin
                Result := -0.032237692456595676;
            end
            else
            begin
                if features.top_local_lm_r1 <= -6687.4999999999991 then
                begin
                    Result := 0.088636092945954814;
                end
                else
                begin
                    Result := -0.013709705462970337;
                end;
            end;
        end;
    end
    else
    begin
        if features.different_units <= 3.5000000000000004 then
        begin
            if features.top_local_lm_r2 <= -5054.4999999999991 then
            begin
                if features.delta_char_suffix_lm_per_difference <= -925.24999999999989 then
                begin
                    if features.same_suffix_units <= 1.5000000000000002 then
                    begin
                        Result := 0.050451283980303643;
                    end
                    else
                    begin
                        Result := 0.0094626937339860745;
                    end;
                end
                else
                begin
                    Result := 0.0019556566509401226;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -3909.4999999999995 then
                begin
                    if features.delta_char_lm_score <= -63.499999999999993 then
                    begin
                        Result := -0.01425633927049288;
                    end
                    else
                    begin
                        if features.delta_local_lm_r2 <= -111.49999999999999 then
                        begin
                            Result := 0.053929960786871498;
                        end
                        else
                        begin
                            if features.candidate_char_lm_context_score <= -4515.4999999999991 then
                            begin
                                Result := -0.020372221387155824;
                            end
                            else
                            begin
                                Result := 0.037891098801322201;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.top_local_lm_r3 <= -4168.4999999999991 then
                    begin
                        Result := -0.00031705107874403896;
                    end
                    else
                    begin
                        Result := 0.051442038732769473;
                    end;
                end;
            end;
        end
        else
        begin
            if features.candidate_dict_weight_per_unit <= 3706.5000000000005 then
            begin
                Result := 0.015367269007572409;
            end
            else
            begin
                Result := -0.035310443100107003;
            end;
        end;
    end;
end;

function local_difference_tree_97(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.036110449929594585;
    end
    else
    begin
        if features.same_prefix_units <= 12.500000000000002 then
        begin
            if features.delta_char_lm_score <= -2181.4999999999995 then
            begin
                Result := -0.027155737878755005;
            end
            else
            begin
                if features.delta_dict_weight_per_unit <= 12309.500000000002 then
                begin
                    if features.delta_char_lm_score <= -281.49999999999994 then
                    begin
                        if features.candidate_local_lm_r3 <= -7276.4999999999991 then
                        begin
                            if features.delta_candidate_score <= 8999.5000000000018 then
                            begin
                                if features.candidate_chain_score_gap <= -207607511.99999997 then
                                begin
                                    if features.candidate_text_units <= 9.5000000000000018 then
                                    begin
                                        Result := 0.10174863417737594;
                                    end
                                    else
                                    begin
                                        Result := -0.003506689009888092;
                                    end;
                                end
                                else
                                begin
                                    if features.candidate_ranker_score <= -5397486.4999999991 then
                                    begin
                                        Result := -0.019321229232367204;
                                    end
                                    else
                                    begin
                                        Result := 0.0054047938717248336;
                                    end;
                                end;
                            end
                            else
                            begin
                                if features.delta_dict_weight <= 13207.000000000002 then
                                begin
                                    Result := 0.047015268897414968;
                                end
                                else
                                begin
                                    Result := -0.002244900227418526;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.0085868098979981575;
                        end;
                    end
                    else
                    begin
                        Result := 0.00325934074174052;
                    end;
                end
                else
                begin
                    if features.delta_candidate_score <= -33565.999999999993 then
                    begin
                        Result := -0.028209086102663136;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -3853.4999999999995 then
                        begin
                            Result := 0.015645805218899255;
                        end
                        else
                        begin
                            Result := -0.02487394686166185;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_per_difference <= 86.750000000000014 then
            begin
                Result := -0.024530378803989585;
            end
            else
            begin
                Result := 0.030399970822011829;
            end;
        end;
    end;
end;

function local_difference_tree_98(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -331050399.99999994 then
    begin
        Result := -0.03668390442469139;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -2617.4999999999995 then
        begin
            Result := -0.032735856577872431;
        end
        else
        begin
            if features.same_prefix_units <= 12.500000000000002 then
            begin
                if features.candidate_ranker_score <= -26652957.999999996 then
                begin
                    if features.candidate_local_lm_r1 <= -8968.4999999999982 then
                    begin
                        if features.delta_score_per_unit <= 871.00000000000011 then
                        begin
                            Result := -0.015455715422412782;
                        end
                        else
                        begin
                            Result := 0.12601483573103761;
                        end;
                    end
                    else
                    begin
                        Result := -0.028993077618573438;
                    end;
                end
                else
                begin
                    if features.delta_word_lm_zero_count <= -5.4999999999999991 then
                    begin
                        Result := 0.026108068948115532;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -3997.4999999999995 then
                        begin
                            if features.delta_dict_weight_per_unit <= -748.49999999999989 then
                            begin
                                if features.delta_score_per_unit <= 5414.5000000000009 then
                                begin
                                    if features.candidate_local_lm_r1 <= -6543.4999999999991 then
                                    begin
                                        Result := -0.011999804153826937;
                                    end
                                    else
                                    begin
                                        if features.candidate_chain_first_stage_score <= 62153.000000000007 then
                                        begin
                                            Result := 0.012979648922041894;
                                        end
                                        else
                                        begin
                                            Result := -0.0156245837533455;
                                        end;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.058475194520534242;
                                end;
                            end
                            else
                            begin
                                Result := 0.004348429206383419;
                            end;
                        end
                        else
                        begin
                            if features.delta_char_lm_per_difference <= 62.166666030883796 then
                            begin
                                Result := -0.011828804049748579;
                            end
                            else
                            begin
                                Result := 0.03188383957518709;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_per_difference <= 86.750000000000014 then
                begin
                    Result := -0.020873919666726387;
                end
                else
                begin
                    Result := 0.034539587160242656;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_99(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -2411.4999999999995 then
    begin
        if features.top_local_lm_r3 <= -6844.4999999999991 then
        begin
            Result := 0.048238392625595365;
        end
        else
        begin
            Result := -0.028537358848362015;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -9084.9999999999982 then
        begin
            if features.delta_local_lm_r1 <= -2525.4999999999995 then
            begin
                Result := 0.090847398217404812;
            end
            else
            begin
                if features.top_local_lm_r0 <= -7715.4999999999991 then
                begin
                    Result := 0.040939427975819891;
                end
                else
                begin
                    Result := -0.034838654551043076;
                end;
            end;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= -331050399.99999994 then
            begin
                Result := -0.035139403989771098;
            end
            else
            begin
                if features.delta_chain_score_gap <= 79774416.000000015 then
                begin
                    if features.candidate_ranker_score <= -27474067.999999996 then
                    begin
                        Result := -0.025073086003665195;
                    end
                    else
                    begin
                        if features.delta_word_lm_zero_count <= -5.4999999999999991 then
                        begin
                            if features.delta_char_lm_suffix_score <= -489.49999999999994 then
                            begin
                                Result := -0.021270732368423445;
                            end
                            else
                            begin
                                Result := 0.038002041832538129;
                            end;
                        end
                        else
                        begin
                            if features.candidate_text_units <= 7.5000000000000009 then
                            begin
                                if features.delta_word_lm_per_boundary <= 95.549999237060561 then
                                begin
                                    Result := 0.0050432011932761657;
                                end
                                else
                                begin
                                    Result := 0.053667415852464838;
                                end;
                            end
                            else
                            begin
                                if features.delta_local_lm_r0 <= -2321.4999999999995 then
                                begin
                                    Result := -0.017059773764054757;
                                end
                                else
                                begin
                                    if features.delta_dict_weight_per_unit <= -11666.499999999998 then
                                    begin
                                        Result := -0.015604754507558145;
                                    end
                                    else
                                    begin
                                        Result := 0.0011377058633623561;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.034628664230863991;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_100(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.035481967316954022;
    end
    else
    begin
        if features.candidate_char_lm_score <= -3164.4999999999995 then
        begin
            if features.top_local_lm_r1 <= -4879.4999999999991 then
            begin
                if features.candidate_local_lm_r1 <= -5485.4999999999991 then
                begin
                    if features.delta_dict_weight_per_unit <= 4370.0000000000009 then
                    begin
                        if features.delta_path_max_segment_units <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.019401109696262877;
                        end
                        else
                        begin
                            if features.delta_dict_weight <= 28061.500000000004 then
                            begin
                                if features.delta_candidate_score <= 7555.0000000000009 then
                                begin
                                    Result := -0.0015261692045264632;
                                end
                                else
                                begin
                                    if features.candidate_score_per_unit <= 15641.500000000002 then
                                    begin
                                        Result := 0.013156478875175761;
                                    end
                                    else
                                    begin
                                        Result := 0.048931515415301573;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.024814422135646681;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.difference_span_units <= 2.5000000000000004 then
                        begin
                            if features.candidate_legacy_rank <= 2.5000000000000004 then
                            begin
                                if features.candidate_ranker_score <= -2231798.4999999995 then
                                begin
                                    Result := -0.011169429582233751;
                                end
                                else
                                begin
                                    Result := 0.013633280136301716;
                                end;
                            end
                            else
                            begin
                                Result := 0.047279636980033422;
                            end;
                        end
                        else
                        begin
                            Result := -0.016756146640800797;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_score <= -406.49999999999994 then
                    begin
                        Result := -0.026604193611748761;
                    end
                    else
                    begin
                        Result := 0.020976471457660552;
                    end;
                end;
            end
            else
            begin
                if features.delta_word_lm_boundary_max <= -328.49999999999994 then
                begin
                    Result := -0.040406733554061443;
                end
                else
                begin
                    Result := -0.006305454097550213;
                end;
            end;
        end
        else
        begin
            Result := 0.019715339907088583;
        end;
    end;
end;

function local_difference_tree_101(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -26652957.999999996 then
    begin
        if features.candidate_char_lm_score <= -7541.4999999999991 then
        begin
            Result := 0.039169250884704236;
        end
        else
        begin
            Result := -0.030912217545990116;
        end;
    end
    else
    begin
        if features.delta_chain_second_stage_score <= -331050399.99999994 then
        begin
            Result := -0.033991427955467383;
        end
        else
        begin
            if features.delta_path_single_segments <= -1.4999999999999998 then
            begin
                if features.same_suffix_units <= 1.0000000180025095E-35 then
                begin
                    if features.candidate_char_lm_suffix_score <= -7068.4999999999991 then
                    begin
                        Result := 0.082925599291838237;
                    end
                    else
                    begin
                        Result := 0.0039402115357496503;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight <= -120805.99999999999 then
                    begin
                        Result := -0.022487453596935159;
                    end
                    else
                    begin
                        if features.delta_local_lm_r1 <= 37.500000000000007 then
                        begin
                            Result := 0.0030624591898505884;
                        end
                        else
                        begin
                            Result := 0.035582887210766322;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_score <= -251.49999999999997 then
                begin
                    if features.candidate_text_units <= 12.500000000000002 then
                    begin
                        if features.delta_dict_weight <= -4077.4999999999995 then
                        begin
                            Result := -0.015806802533132939;
                        end
                        else
                        begin
                            if features.candidate_chain_score_gap <= -194178975.99999997 then
                            begin
                                Result := 0.043808693479625342;
                            end
                            else
                            begin
                                Result := 0.00060496749781520245;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.018284187627681425;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r3 <= -8157.4999999999991 then
                    begin
                        Result := -0.028338429850620947;
                    end
                    else
                    begin
                        if features.candidate_ranker_score <= 7979596.5000000009 then
                        begin
                            Result := 0.00092192660671037616;
                        end
                        else
                        begin
                            Result := 0.019063432956604801;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_102(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -27474067.999999996 then
    begin
        Result := -0.027394889982328918;
    end
    else
    begin
        if features.top_local_lm_r2 <= -3889.4999999999995 then
        begin
            if features.delta_word_lm_zero_count <= -4.4999999999999991 then
            begin
                Result := 0.018979008733496356;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -26438993.999999996 then
                begin
                    Result := -0.0022122312759939294;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -7462.4999999999991 then
                    begin
                        if features.top_local_lm_r2 <= -7501.4999999999991 then
                        begin
                            if features.candidate_word_lm_bonus <= 306.50000000000006 then
                            begin
                                if features.delta_char_lm_suffix_score <= -171.49999999999997 then
                                begin
                                    Result := 0.040289674025421544;
                                end
                                else
                                begin
                                    Result := -0.01429610078951609;
                                end;
                            end
                            else
                            begin
                                Result := 0.042326177031166645;
                            end;
                        end
                        else
                        begin
                            if features.candidate_char_lm_suffix_score <= -6457.4999999999991 then
                            begin
                                if features.candidate_char_lm_suffix_score <= -7123.4999999999991 then
                                begin
                                    Result := -0.039946645452005589;
                                end
                                else
                                begin
                                    Result := 0.018198848808355896;
                                end;
                            end
                            else
                            begin
                                Result := -0.034294470934856311;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_chain_first_stage_score <= -158030.49999999997 then
                        begin
                            Result := -0.03702127626448469;
                        end
                        else
                        begin
                            Result := 0.0071650399253378409;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r0 <= -253.49999999999997 then
            begin
                Result := -0.037983136483180302;
            end
            else
            begin
                if features.candidate_word_lm_boundary_first <= 1231.5000000000002 then
                begin
                    if features.top_local_lm_r0 <= -4452.4999999999991 then
                    begin
                        Result := -0.029527253889160852;
                    end
                    else
                    begin
                        Result := 0.017844014931432884;
                    end;
                end
                else
                begin
                    Result := 0.077598111705760572;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_103(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.top_local_lm_r2 <= -6448.4999999999991 then
    begin
        if features.delta_candidate_score <= -1.0000000180025095E-35 then
        begin
            if features.candidate_local_lm_r0 <= -4430.4999999999991 then
            begin
                if features.candidate_word_lm_boundary_last <= 1558.5000000000002 then
                begin
                    if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                    begin
                        if features.delta_chain_score_gap <= -199966127.99999997 then
                        begin
                            Result := 0.060267726750251001;
                        end
                        else
                        begin
                            Result := -0.0039764891375525628;
                        end;
                    end
                    else
                    begin
                        Result := -0.02345197979245707;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r1 <= 308.50000000000006 then
                    begin
                        Result := 0.0021751249562929546;
                    end
                    else
                    begin
                        Result := 0.05681617716018697;
                    end;
                end;
            end
            else
            begin
                if features.candidate_score_per_unit <= 10772.500000000002 then
                begin
                    Result := 0.029824888308138592;
                end
                else
                begin
                    Result := -0.0066656493622961133;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_per_difference <= -217.41666412353513 then
            begin
                Result := 0.020279725686418643;
            end
            else
            begin
                Result := -0.0001842037637446724;
            end;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -3909.4999999999995 then
        begin
            if features.delta_word_lm_boundary_first <= -1237.4999999999998 then
            begin
                Result := -0.035208837701953655;
            end
            else
            begin
                if features.delta_char_lm_per_difference <= 62.166666030883796 then
                begin
                    if features.top_local_lm_r0 <= -4038.4999999999995 then
                    begin
                        Result := -0.0029896035858611443;
                    end
                    else
                    begin
                        Result := -0.019118977394519704;
                    end;
                end
                else
                begin
                    if features.candidate_word_lm_zero_count <= 2.5000000000000004 then
                    begin
                        Result := -0.0079621021025493236;
                    end
                    else
                    begin
                        Result := 0.028771766435909105;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.013244027422666416;
        end;
    end;
end;

function local_difference_tree_104(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.difference_span_units <= 8.5000000000000018 then
    begin
        if features.delta_char_lm_score <= -690.49999999999989 then
        begin
            if features.top_local_lm_r0 <= -4090.4999999999995 then
            begin
                if features.same_suffix_units <= 1.5000000000000002 then
                begin
                    if features.candidate_ranker_score <= -9568708.4999999981 then
                    begin
                        if features.delta_path_segments <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.03083299019796849;
                        end
                        else
                        begin
                            Result := 0.013360744353126095;
                        end;
                    end
                    else
                    begin
                        if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.040677424530626727;
                        end
                        else
                        begin
                            if features.delta_path_single_segments <= 2.5000000000000004 then
                            begin
                                Result := -0.016726377914395286;
                            end
                            else
                            begin
                                Result := 0.041806229023542744;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight_per_unit <= 11348.500000000002 then
                    begin
                        Result := -0.015739018388495181;
                    end
                    else
                    begin
                        if features.same_prefix_units <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.031163130491387431;
                        end
                        else
                        begin
                            if features.top_local_lm_r0 <= -5734.4999999999991 then
                            begin
                                Result := 0.042431170943188816;
                            end
                            else
                            begin
                                Result := 0.0034822190118816276;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.029925635726484691;
            end;
        end
        else
        begin
            if features.delta_chain_score_gap <= 79774416.000000015 then
            begin
                if features.delta_chain_first_stage_score <= -115127.99999999999 then
                begin
                    Result := -0.010894045313645587;
                end
                else
                begin
                    if features.candidate_candidate_score <= 10511.500000000002 then
                    begin
                        Result := 0.025159457084537599;
                    end
                    else
                    begin
                        Result := 0.0020806970313627655;
                    end;
                end;
            end
            else
            begin
                Result := -0.037792524659215149;
            end;
        end;
    end
    else
    begin
        Result := -0.036841114023775767;
    end;
end;

function local_difference_tree_105(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -2447.4999999999995 then
    begin
        Result := -0.023027185135964877;
    end
    else
    begin
        if features.delta_chain_second_stage_score <= -338456735.99999994 then
        begin
            Result := -0.033146499238784446;
        end
        else
        begin
            if features.candidate_char_lm_score <= -3164.4999999999995 then
            begin
                if features.top_local_lm_r3 <= -4902.4999999999991 then
                begin
                    Result := 0.0016701051812678281;
                end
                else
                begin
                    if features.candidate_chain_score_gap <= -153285775.99999997 then
                    begin
                        if features.top_local_lm_r0 <= -4893.4999999999991 then
                        begin
                            Result := -0.025083734421182717;
                        end
                        else
                        begin
                            if features.candidate_ranker_score <= -15863820.499999998 then
                            begin
                                if features.delta_local_lm_r2 <= -800.49999999999989 then
                                begin
                                    Result := -0.033995095277305841;
                                end
                                else
                                begin
                                    if features.delta_candidate_score <= -204.49999999999997 then
                                    begin
                                        Result := -0.025422347255369574;
                                    end
                                    else
                                    begin
                                        Result := 0.105637321433803;
                                    end;
                                end;
                            end
                            else
                            begin
                                if features.top_local_lm_r0 <= -4090.4999999999995 then
                                begin
                                    Result := 0.098769318732852732;
                                end
                                else
                                begin
                                    Result := -0.0027545957954033785;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r1 <= -384.49999999999994 then
                        begin
                            Result := -0.021646477831712155;
                        end
                        else
                        begin
                            if features.delta_local_lm_r0 <= 89.000000000000014 then
                            begin
                                Result := 0.015272211801918666;
                            end
                            else
                            begin
                                Result := -0.017189079924764046;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_score <= -800.49999999999989 then
                begin
                    Result := -0.035355028009246427;
                end
                else
                begin
                    if features.candidate_chain_second_stage_score <= 393522960.00000006 then
                    begin
                        Result := 0.042877147486679652;
                    end
                    else
                    begin
                        Result := 0.0019532503487067793;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_106(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.03886105146794791;
    end
    else
    begin
        if features.delta_char_lm_score <= -690.49999999999989 then
        begin
            if features.top_local_lm_r0 <= -4090.4999999999995 then
            begin
                if features.delta_dict_weight <= -4077.4999999999995 then
                begin
                    if features.delta_candidate_score <= 46623.000000000007 then
                    begin
                        Result := -0.024987964579711829;
                    end
                    else
                    begin
                        Result := 0.034550838028930539;
                    end;
                end
                else
                begin
                    if features.same_suffix_units <= 1.5000000000000002 then
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -357.83332824707026 then
                        begin
                            if features.candidate_dict_weight <= 151949.50000000003 then
                            begin
                                Result := 0.03343604069858206;
                            end
                            else
                            begin
                                Result := -0.010607956286228539;
                            end;
                        end
                        else
                        begin
                            Result := -0.024440850015222986;
                        end;
                    end
                    else
                    begin
                        if features.candidate_ranker_score_gap <= -47704113.999999993 then
                        begin
                            if features.candidate_candidate_score <= 112598.50000000001 then
                            begin
                                Result := -0.019585023714958679;
                            end
                            else
                            begin
                                if features.same_prefix_units <= 1.5000000000000002 then
                                begin
                                    Result := -0.013704196418990868;
                                end
                                else
                                begin
                                    Result := 0.092342821180597737;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.candidate_dict_weight_per_unit <= 29415.000000000004 then
                            begin
                                if features.delta_char_suffix_lm_per_difference <= -616.58334350585926 then
                                begin
                                    Result := -0.0031328948395421721;
                                end
                                else
                                begin
                                    Result := -0.026564837082780745;
                                end;
                            end
                            else
                            begin
                                Result := 0.026468498014304141;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.027245125884659955;
            end;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= -5.4999999999999991 then
            begin
                Result := 0.028442270745633946;
            end
            else
            begin
                Result := 0.0015332326306965547;
            end;
        end;
    end;
end;

function local_difference_tree_107(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -27474067.999999996 then
    begin
        if features.candidate_local_lm_r0 <= -9084.9999999999982 then
        begin
            Result := 0.063559738401437887;
        end
        else
        begin
            Result := -0.033595850083956873;
        end;
    end
    else
    begin
        if features.top_local_lm_r1 <= -4740.4999999999991 then
        begin
            if features.candidate_local_lm_r1 <= -5485.4999999999991 then
            begin
                if features.delta_char_lm_per_difference <= 341.50000000000006 then
                begin
                    if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                    begin
                        if features.candidate_chain_score_gap <= -194178975.99999997 then
                        begin
                            Result := 0.035384550116756709;
                        end
                        else
                        begin
                            Result := 0.0019390559637638759;
                        end;
                    end
                    else
                    begin
                        if features.candidate_word_lm_boundary_count <= 6.5000000000000009 then
                        begin
                            Result := 0.0010996077182388844;
                        end
                        else
                        begin
                            Result := -0.018409496652333737;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.024472723813764016;
                end;
            end
            else
            begin
                if features.delta_char_lm_per_difference <= -481.83332824707026 then
                begin
                    Result := -0.027801760341058003;
                end
                else
                begin
                    Result := 0.017461310851291097;
                end;
            end;
        end
        else
        begin
            if features.delta_candidate_score <= -127.49999999999999 then
            begin
                if features.delta_dict_weight <= -254.49999999999997 then
                begin
                    Result := -0.017234484176474;
                end
                else
                begin
                    Result := 0.016916277570687574;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -5706.4999999999991 then
                begin
                    if features.top_local_lm_r3 <= -6222.4999999999991 then
                    begin
                        Result := 0.073611639182751487;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r0 <= -6051.4999999999991 then
                        begin
                            Result := -0.032250999573878898;
                        end
                        else
                        begin
                            Result := 0.021539389016764311;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.024635493268422133;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_108(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.039164338015234362;
    end
    else
    begin
        if features.delta_chain_score_gap <= 79774416.000000015 then
        begin
            if features.delta_char_lm_score <= -2059.4999999999995 then
            begin
                Result := -0.025119654424153381;
            end
            else
            begin
                if features.candidate_local_lm_r1 <= -5194.4999999999991 then
                begin
                    if features.delta_path_segments <= -1.4999999999999998 then
                    begin
                        if features.candidate_score_per_unit <= 3118.5000000000005 then
                        begin
                            Result := 0.032006332308620954;
                        end
                        else
                        begin
                            if features.delta_score_per_unit <= 18.500000000000004 then
                            begin
                                Result := -0.020995197019768076;
                            end
                            else
                            begin
                                if features.delta_chain_second_stage_score <= -85100019.999999985 then
                                begin
                                    Result := -0.031641601547447003;
                                end
                                else
                                begin
                                    Result := 0.016339306383099862;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.candidate_dict_weight_per_unit <= 29415.000000000004 then
                        begin
                            Result := 0.00075024322355030375;
                        end
                        else
                        begin
                            Result := 0.02338388711851391;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight_per_unit <= 1.0000000180025095E-35 then
                    begin
                        if features.delta_candidate_score <= -253.49999999999997 then
                        begin
                            if features.same_prefix_units <= 5.5000000000000009 then
                            begin
                                if features.candidate_local_lm_r3 <= -5160.4999999999991 then
                                begin
                                    Result := -0.0052333426484468103;
                                end
                                else
                                begin
                                    Result := 0.043128023082950454;
                                end;
                            end
                            else
                            begin
                                Result := -0.017518503644957016;
                            end;
                        end
                        else
                        begin
                            Result := 0.028801553382081128;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -5279.4999999999991 then
                        begin
                            Result := 0.024934737136929907;
                        end
                        else
                        begin
                            Result := -0.012759930341158939;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.036734523898980152;
        end;
    end;
end;

function local_difference_tree_109(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -331050399.99999994 then
    begin
        Result := -0.034597973774645047;
    end
    else
    begin
        if features.top_local_lm_r2 <= -5054.4999999999991 then
        begin
            if features.candidate_local_lm_r1 <= -5485.4999999999991 then
            begin
                if features.top_local_lm_r1 <= -4272.4999999999991 then
                begin
                    if features.delta_dict_weight_per_unit <= 11348.500000000002 then
                    begin
                        if features.candidate_local_lm_r0 <= -8652.4999999999982 then
                        begin
                            if features.candidate_chain_first_stage_score <= 124561.50000000001 then
                            begin
                                Result := 0.040311972046324966;
                            end
                            else
                            begin
                                Result := -0.038939791182687443;
                            end;
                        end
                        else
                        begin
                            Result := -0.00079400243709368344;
                        end;
                    end
                    else
                    begin
                        if features.delta_candidate_score <= -33565.999999999993 then
                        begin
                            Result := -0.033694685423331032;
                        end
                        else
                        begin
                            Result := 0.016299055173553151;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.03394750957926948;
                end;
            end
            else
            begin
                if features.delta_char_lm_per_difference <= -360.83332824707026 then
                begin
                    Result := -0.01827871798247209;
                end
                else
                begin
                    Result := 0.015755580443703374;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -1794.4999999999998 then
            begin
                Result := -0.027495084910760071;
            end
            else
            begin
                if features.candidate_candidate_score <= 40106.500000000007 then
                begin
                    Result := 0.027359358712480967;
                end
                else
                begin
                    if features.candidate_candidate_score <= 120566.50000000001 then
                    begin
                        Result := -0.016963188401084635;
                    end
                    else
                    begin
                        if features.delta_local_lm_r0 <= -620.49999999999989 then
                        begin
                            Result := -0.023362483520551286;
                        end
                        else
                        begin
                            if features.delta_candidate_score <= 17999.500000000004 then
                            begin
                                Result := 0.018261056520831195;
                            end
                            else
                            begin
                                Result := -0.045095334162723585;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_110(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -316139807.99999994 then
    begin
        Result := -0.029675473771619672;
    end
    else
    begin
        if features.delta_word_lm_trigram_ratio <= -73.499999999999986 then
        begin
            Result := -0.037600254996072689;
        end
        else
        begin
            if features.candidate_chain_rank <= 2.5000000000000004 then
            begin
                if features.different_units <= 3.5000000000000004 then
                begin
                    if features.candidate_dict_weight_per_unit <= 12646.500000000002 then
                    begin
                        if features.delta_char_lm_score <= -996.49999999999989 then
                        begin
                            if features.delta_candidate_score <= 8999.5000000000018 then
                            begin
                                Result := -0.026074911529241622;
                            end
                            else
                            begin
                                if features.delta_char_lm_suffix_score <= -1299.4999999999998 then
                                begin
                                    Result := 0.043292224330750501;
                                end
                                else
                                begin
                                    Result := -0.013124727424732899;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.00024463899586453833;
                        end;
                    end
                    else
                    begin
                        Result := 0.0056283222630823231;
                    end;
                end
                else
                begin
                    Result := -0.018420119748968469;
                end;
            end
            else
            begin
                if features.candidate_chain_rank <= 4.5000000000000009 then
                begin
                    if features.candidate_candidate_score <= 188910.50000000003 then
                    begin
                        if features.candidate_chain_first_stage_score <= 133429.00000000003 then
                        begin
                            if features.delta_char_lm_suffix_score <= -464.49999999999994 then
                            begin
                                Result := -0.026625475200353372;
                            end
                            else
                            begin
                                if features.delta_char_lm_suffix_score <= -319.49999999999994 then
                                begin
                                    Result := 0.084250817697444233;
                                end
                                else
                                begin
                                    if features.delta_dict_weight_per_unit <= -9505.4999999999982 then
                                    begin
                                        Result := 0.047088294928495797;
                                    end
                                    else
                                    begin
                                        Result := -0.0097739998167508078;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.067121978533624144;
                        end;
                    end
                    else
                    begin
                        Result := -0.038385352323142045;
                    end;
                end
                else
                begin
                    Result := -0.02663663493103904;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_111(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -613.49999999999989 then
    begin
        if features.top_local_lm_r0 <= -4072.4999999999995 then
        begin
            if features.candidate_text_units <= 12.500000000000002 then
            begin
                if features.candidate_word_lm_boundary_first <= 1222.5000000000002 then
                begin
                    if features.candidate_local_lm_r3 <= -8079.4999999999991 then
                    begin
                        Result := 0.016820967102475333;
                    end
                    else
                    begin
                        Result := -0.0051008378379437036;
                    end;
                end
                else
                begin
                    Result := 0.03185160435532354;
                end;
            end
            else
            begin
                Result := -0.02561716688082152;
            end;
        end
        else
        begin
            Result := -0.029262108571072757;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -4210.9999999999991 then
        begin
            if features.delta_dict_weight <= -381.99999999999994 then
            begin
                if features.candidate_char_lm_score <= -7009.4999999999991 then
                begin
                    Result := 0.027789208145093891;
                end
                else
                begin
                    if features.candidate_local_lm_r2 <= -6916.4999999999991 then
                    begin
                        Result := -0.018630636573767782;
                    end
                    else
                    begin
                        Result := -0.0003346145482579834;
                    end;
                end;
            end
            else
            begin
                if features.same_suffix_units <= 1.0000000180025095E-35 then
                begin
                    if features.delta_chain_score_gap <= -181858599.99999997 then
                    begin
                        Result := 0.057248790494018362;
                    end
                    else
                    begin
                        Result := -0.016282093167403869;
                    end;
                end
                else
                begin
                    Result := 0.0051866884840472572;
                end;
            end;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -4192.4999999999991 then
            begin
                Result := 0.037754605063074681;
            end
            else
            begin
                if features.candidate_chain_second_stage_score <= 220710528.00000003 then
                begin
                    if features.candidate_char_lm_score <= -4196.4999999999991 then
                    begin
                        Result := 0.0045673709231945228;
                    end
                    else
                    begin
                        Result := 0.03695713880115873;
                    end;
                end
                else
                begin
                    Result := -0.017467501995977647;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_112(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -2617.4999999999995 then
    begin
        Result := -0.037096552437910789;
    end
    else
    begin
        if features.delta_chain_first_stage_score <= -115127.99999999999 then
        begin
            if features.top_local_lm_r3 <= -7193.4999999999991 then
            begin
                Result := 0.015228122274423668;
            end
            else
            begin
                Result := -0.017846558191069881;
            end;
        end
        else
        begin
            if features.delta_score_per_unit <= -7339.4999999999991 then
            begin
                if features.top_local_lm_r1 <= -7164.4999999999991 then
                begin
                    Result := -0.0096743703836265332;
                end
                else
                begin
                    if features.candidate_ranker_score_gap <= -31560789.999999996 then
                    begin
                        Result := 0.0054497244836538821;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r1 <= -5990.4999999999991 then
                        begin
                            Result := 0.073228249725441605;
                        end
                        else
                        begin
                            Result := 0.0089505467354879867;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_legacy_rank <= 1.5000000000000002 then
                begin
                    Result := -0.00041261798126020969;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -6830.4999999999991 then
                    begin
                        if features.top_local_lm_r0 <= -4922.4999999999991 then
                        begin
                            if features.candidate_local_lm_r2 <= -7178.4999999999991 then
                            begin
                                if features.candidate_local_lm_r2 <= -7813.4999999999991 then
                                begin
                                    Result := 0.044649846651502595;
                                end
                                else
                                begin
                                    Result := -0.028774649675049543;
                                end;
                            end
                            else
                            begin
                                Result := 0.089584262748925725;
                            end;
                        end
                        else
                        begin
                            Result := -0.017241073726615052;
                        end;
                    end
                    else
                    begin
                        if features.candidate_candidate_score <= 66890.500000000015 then
                        begin
                            if features.top_local_lm_r0 <= -4708.4999999999991 then
                            begin
                                Result := 0.0058656124436161161;
                            end
                            else
                            begin
                                Result := 0.07002256404150782;
                            end;
                        end
                        else
                        begin
                            Result := -0.0075592775242333543;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_113(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -290.49999999999994 then
    begin
        if features.delta_chain_first_stage_score <= 60168.500000000007 then
        begin
            Result := -0.016063787520337235;
        end
        else
        begin
            if features.delta_word_lm_zero_count <= -2.4999999999999996 then
            begin
                Result := 0.051737460475768673;
            end
            else
            begin
                if features.delta_local_lm_r2 <= -347.49999999999994 then
                begin
                    Result := -0.040471463300055292;
                end
                else
                begin
                    Result := 0.02580679849690623;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -2181.4999999999995 then
        begin
            Result := -0.029086560464534048;
        end
        else
        begin
            if features.candidate_char_lm_score <= -4196.4999999999991 then
            begin
                if features.candidate_chain_second_stage_score <= 182694728.00000003 then
                begin
                    if features.top_local_lm_r0 <= -5890.4999999999991 then
                    begin
                        if features.delta_path_max_segment_units <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.021451784874691723;
                        end
                        else
                        begin
                            Result := 0.011203137423296662;
                        end;
                    end
                    else
                    begin
                        if features.delta_path_max_segment_units <= 7.5000000000000009 then
                        begin
                            Result := -0.0019990574922528598;
                        end
                        else
                        begin
                            Result := 0.025891203701591148;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_suffix_score <= -1070.4999999999998 then
                    begin
                        Result := 0.052105641155478846;
                    end
                    else
                    begin
                        Result := -0.018795925705346429;
                    end;
                end;
            end
            else
            begin
                if features.candidate_chain_score_gap <= -197497767.99999997 then
                begin
                    if features.candidate_chain_second_stage_score <= 240141784.00000003 then
                    begin
                        Result := -0.0063370232491070291;
                    end
                    else
                    begin
                        Result := 0.10409862503694862;
                    end;
                end
                else
                begin
                    if features.delta_char_lm_score <= -571.49999999999989 then
                    begin
                        Result := -0.014225734975770786;
                    end
                    else
                    begin
                        Result := 0.010822363436095321;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_114(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.same_prefix_units <= 12.500000000000002 then
    begin
        if features.delta_local_lm_r3 <= -2617.4999999999995 then
        begin
            Result := -0.036881110506922457;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -9084.9999999999982 then
            begin
                Result := 0.034972796826869247;
            end
            else
            begin
                if features.candidate_ranker_score <= -26652957.999999996 then
                begin
                    Result := -0.025437903974321174;
                end
                else
                begin
                    if features.same_prefix_units <= 1.0000000180025095E-35 then
                    begin
                        if features.same_suffix_units <= 11.500000000000002 then
                        begin
                            if features.delta_char_lm_score <= -473.49999999999994 then
                            begin
                                Result := -0.020765980138795517;
                            end
                            else
                            begin
                                if features.delta_word_lm_zero_count <= 1.5000000000000002 then
                                begin
                                    Result := 0.0024973666329192717;
                                end
                                else
                                begin
                                    Result := 0.05856993136380071;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.029937142945801444;
                        end;
                    end
                    else
                    begin
                        if features.delta_path_single_segments <= -1.4999999999999998 then
                        begin
                            Result := 0.013070447696614947;
                        end
                        else
                        begin
                            if features.different_units <= 1.5000000000000002 then
                            begin
                                if features.candidate_local_lm_r0 <= -6051.4999999999991 then
                                begin
                                    Result := 0.019358496553469696;
                                end
                                else
                                begin
                                    Result := 0.00052824191167968036;
                                end;
                            end
                            else
                            begin
                                if features.delta_local_lm_r0 <= -385.49999999999994 then
                                begin
                                    Result := -0.013373205407702034;
                                end
                                else
                                begin
                                    if features.delta_path_segments <= -1.0000000180025095E-35 then
                                    begin
                                        Result := -0.022768730591111015;
                                    end
                                    else
                                    begin
                                        Result := 0.0089609987628453489;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_suffix_lm_per_difference <= 141.25000000000003 then
        begin
            Result := -0.023931174977870069;
        end
        else
        begin
            Result := 0.028988179238527895;
        end;
    end;
end;

function local_difference_tree_115(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -266.49999999999994 then
    begin
        if features.candidate_chain_first_stage_score <= -11099.499999999998 then
        begin
            Result := 0.02596456627175641;
        end
        else
        begin
            if features.delta_local_lm_r0 <= 2806.5000000000005 then
            begin
                if features.delta_dict_weight_per_unit <= -2982.4999999999995 then
                begin
                    Result := -0.035912282717408428;
                end
                else
                begin
                    if features.delta_word_lm_per_boundary <= -62.325000762939446 then
                    begin
                        if features.delta_local_lm_r3 <= -280.49999999999994 then
                        begin
                            Result := -0.014313493283813686;
                        end
                        else
                        begin
                            if features.candidate_path_segments <= 5.5000000000000009 then
                            begin
                                Result := -0.0086984836366137165;
                            end
                            else
                            begin
                                Result := 0.039438577099800233;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.037478419503404754;
                    end;
                end;
            end
            else
            begin
                Result := 0.061018162631652911;
            end;
        end;
    end
    else
    begin
        if features.candidate_ranker_score <= 6173916.5000000009 then
        begin
            if features.candidate_score_per_unit <= 2857.0000000000005 then
            begin
                if features.delta_chain_first_stage_score <= -89456.999999999985 then
                begin
                    Result := -0.0072884557386577202;
                end
                else
                begin
                    Result := 0.028741154734518552;
                end;
            end
            else
            begin
                if features.delta_chain_score_gap <= -196976087.99999997 then
                begin
                    if features.candidate_chain_second_stage_score <= 240141784.00000003 then
                    begin
                        Result := 0.0069678146281438912;
                    end
                    else
                    begin
                        Result := 0.10198227257634736;
                    end;
                end
                else
                begin
                    if features.delta_score_per_unit <= -682.49999999999989 then
                    begin
                        Result := -0.011588320867872882;
                    end
                    else
                    begin
                        Result := -0.00063652028497018884;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_boundary_last <= 1270.5000000000002 then
            begin
                Result := 0.0093514814060997146;
            end
            else
            begin
                Result := -0.017918727158204327;
            end;
        end;
    end;
end;

function local_difference_tree_116(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -2059.4999999999995 then
    begin
        Result := -0.028385768826224608;
    end
    else
    begin
        if features.delta_word_lm_bonus <= -216.49999999999997 then
        begin
            if features.candidate_local_lm_r3 <= -5531.4999999999991 then
            begin
                if features.candidate_local_lm_r2 <= -8272.4999999999982 then
                begin
                    if features.top_local_lm_r0 <= -6306.4999999999991 then
                    begin
                        Result := -0.030686351865090958;
                    end
                    else
                    begin
                        Result := 0.052546086580759925;
                    end;
                end
                else
                begin
                    if features.delta_char_suffix_lm_per_difference <= -205.83333587646482 then
                    begin
                        Result := -0.035361439852358484;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r1 <= -7219.4999999999991 then
                        begin
                            Result := -0.037575606079921518;
                        end
                        else
                        begin
                            if features.delta_chain_second_stage_score <= -33143027.999999996 then
                            begin
                                if features.delta_chain_score_gap <= -170667407.99999997 then
                                begin
                                    if features.delta_chain_score_gap <= -193406367.99999997 then
                                    begin
                                        Result := -0.015572280951003301;
                                    end
                                    else
                                    begin
                                        Result := 0.05702583164467722;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.026798347824096336;
                                end;
                            end
                            else
                            begin
                                Result := 0.031695884128916135;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.candidate_path_segments <= 6.5000000000000009 then
                begin
                    if features.delta_word_lm_bonus <= -273.49999999999994 then
                    begin
                        Result := 0.0049798737466297694;
                    end
                    else
                    begin
                        Result := 0.063388417416997106;
                    end;
                end
                else
                begin
                    Result := -0.027890816659458768;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_per_boundary <= -173.29166412353513 then
            begin
                if features.candidate_dict_weight <= 121360.50000000001 then
                begin
                    Result := -0.0025778038196711275;
                end
                else
                begin
                    Result := 0.09170005042062479;
                end;
            end
            else
            begin
                Result := 0.00079165462950008978;
            end;
        end;
    end;
end;

function local_difference_tree_117(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_dict_weight_per_unit <= -538.49999999999989 then
    begin
        if features.delta_score_per_unit <= 5414.5000000000009 then
        begin
            if features.delta_local_lm_r2 <= -1004.4999999999999 then
            begin
                Result := -0.026104932563437624;
            end
            else
            begin
                if features.candidate_local_lm_r3 <= -5283.4999999999991 then
                begin
                    if features.candidate_char_lm_suffix_score <= -5783.4999999999991 then
                    begin
                        if features.candidate_word_lm_supported_ratio <= 240.00000000000003 then
                        begin
                            Result := -0.004294788302580144;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r2 <= -7412.4999999999991 then
                            begin
                                Result := -0.015314035489139509;
                            end
                            else
                            begin
                                Result := 0.03035559768176254;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.01778979461945443;
                    end;
                end
                else
                begin
                    Result := 0.012720212012035229;
                end;
            end;
        end
        else
        begin
            Result := 0.044576694427515627;
        end;
    end
    else
    begin
        if features.different_units <= 3.5000000000000004 then
        begin
            if features.top_local_lm_r0 <= -5670.4999999999991 then
            begin
                if features.candidate_ranker_score <= 18707849.000000004 then
                begin
                    if features.candidate_local_lm_r1 <= -6434.4999999999991 then
                    begin
                        Result := 0.014704859465338411;
                    end
                    else
                    begin
                        if features.candidate_score_per_unit <= 12154.500000000002 then
                        begin
                            Result := -0.01362186788759257;
                        end
                        else
                        begin
                            if features.delta_char_lm_score <= -393.49999999999994 then
                            begin
                                Result := -0.0098894576275034528;
                            end
                            else
                            begin
                                Result := 0.045387018189365254;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.042751965943632515;
                end;
            end
            else
            begin
                if features.top_local_lm_r0 <= -5632.4999999999991 then
                begin
                    Result := -0.034125339477962278;
                end
                else
                begin
                    Result := 0.00048562078444857416;
                end;
            end;
        end
        else
        begin
            Result := -0.027703435095581215;
        end;
    end;
end;

function local_difference_tree_118(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -273.49999999999994 then
    begin
        Result := -0.011678870973556139;
    end
    else
    begin
        if features.delta_word_lm_boundary_count <= -5.4999999999999991 then
        begin
            if features.same_prefix_units <= 3.5000000000000004 then
            begin
                Result := -0.011270429108072197;
            end
            else
            begin
                Result := 0.039893697225020536;
            end;
        end
        else
        begin
            if features.delta_path_segments <= -1.4999999999999998 then
            begin
                if features.candidate_candidate_score <= 20380.000000000004 then
                begin
                    Result := 0.073399704351936434;
                end
                else
                begin
                    if features.delta_candidate_score <= 46623.000000000007 then
                    begin
                        if features.candidate_local_lm_r1 <= -6092.4999999999991 then
                        begin
                            if features.candidate_local_lm_r0 <= -4135.9999999999991 then
                            begin
                                Result := -0.03259819259168454;
                            end
                            else
                            begin
                                if features.delta_char_lm_score <= -295.49999999999994 then
                                begin
                                    Result := -0.028563841794020363;
                                end
                                else
                                begin
                                    Result := 0.05161776446186777;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.top_local_lm_r2 <= -6276.4999999999991 then
                            begin
                                Result := 0.036097517932832099;
                            end
                            else
                            begin
                                Result := -0.010733172579674202;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.051569752558155595;
                    end;
                end;
            end
            else
            begin
                if features.candidate_char_lm_score <= -4230.9999999999991 then
                begin
                    if features.candidate_char_lm_score <= -4576.4999999999991 then
                    begin
                        if features.delta_path_max_segment_units <= 7.5000000000000009 then
                        begin
                            Result := 0.001056042076084349;
                        end
                        else
                        begin
                            Result := 0.035213056207101516;
                        end;
                    end
                    else
                    begin
                        if features.delta_word_lm_boundary_count <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.0053611930582027432;
                        end
                        else
                        begin
                            Result := -0.033653686273894569;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0084539526256956973;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_119(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -331050399.99999994 then
    begin
        Result := -0.033275270565858377;
    end
    else
    begin
        if features.same_suffix_units <= 16.500000000000004 then
        begin
            if features.delta_char_lm_per_difference <= -481.83332824707026 then
            begin
                if features.candidate_local_lm_r0 <= -5774.9999999999991 then
                begin
                    if features.top_local_lm_r2 <= -7054.4999999999991 then
                    begin
                        Result := 0.040475323995429656;
                    end
                    else
                    begin
                        Result := 0.00015057022641367835;
                    end;
                end
                else
                begin
                    if features.delta_word_lm_zero_count <= -1.0000000180025095E-35 then
                    begin
                        if features.candidate_chain_first_stage_score <= 9755.5000000000018 then
                        begin
                            Result := -0.033759019669862361;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r1 <= -6029.4999999999991 then
                            begin
                                Result := 0.053446193322809088;
                            end
                            else
                            begin
                                Result := -0.019644473174409233;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.012013228169455312;
                    end;
                end;
            end
            else
            begin
                if features.delta_path_segments <= 2.5000000000000004 then
                begin
                    if features.delta_local_lm_r1 <= -1186.4999999999998 then
                    begin
                        if features.candidate_ranker_score_gap <= -3996883.9999999995 then
                        begin
                            Result := -0.010816551420333387;
                        end
                        else
                        begin
                            Result := 0.066481476587003319;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -449.83332824707026 then
                        begin
                            Result := 0.036552780549463211;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r0 <= -6812.4999999999991 then
                            begin
                                Result := -0.0092428197004207624;
                            end
                            else
                            begin
                                Result := 0.0034949573580947413;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_path_segments <= 4.5000000000000009 then
                    begin
                        Result := 0.036028605273429659;
                    end
                    else
                    begin
                        Result := 0.0030639522833774213;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.024038912822296355;
        end;
    end;
end;

function local_difference_tree_120(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_dict_weight_per_unit <= -748.49999999999989 then
    begin
        if features.delta_candidate_score <= 46623.000000000007 then
        begin
            if features.delta_local_lm_r3 <= -1372.4999999999998 then
            begin
                Result := -0.034761197275486475;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -7412.4999999999991 then
                begin
                    if features.top_local_lm_r0 <= -3673.4999999999995 then
                    begin
                        Result := -0.019422324565887258;
                    end
                    else
                    begin
                        Result := 0.056118722211592531;
                    end;
                end
                else
                begin
                    if features.candidate_char_lm_suffix_score <= -6888.4999999999991 then
                    begin
                        Result := 0.023001502196709808;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r0 <= -5809.4999999999991 then
                        begin
                            Result := -0.017137939051219086;
                        end
                        else
                        begin
                            Result := 0.0017086209987876673;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_boundary_max <= -1285.4999999999998 then
            begin
                Result := -0.019040649307708379;
            end
            else
            begin
                Result := 0.065990006337475843;
            end;
        end;
    end
    else
    begin
        if features.top_local_lm_r0 <= -3997.4999999999995 then
        begin
            if features.delta_chain_first_stage_score <= 210.50000000000003 then
            begin
                Result := 0.0067091274018097804;
            end
            else
            begin
                if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                begin
                    Result := 0.040745583331621794;
                end
                else
                begin
                    if features.candidate_ranker_score_gap <= -21523774.999999996 then
                    begin
                        if features.candidate_local_lm_r3 <= -7276.4999999999991 then
                        begin
                            if features.top_local_lm_r0 <= -4340.4999999999991 then
                            begin
                                Result := -0.004235260755228557;
                            end
                            else
                            begin
                                Result := 0.052096222101337866;
                            end;
                        end
                        else
                        begin
                            Result := -0.018177865283889611;
                        end;
                    end
                    else
                    begin
                        Result := 0.0071589167756979941;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.0094009904085987344;
        end;
    end;
end;

function local_difference_tree_121(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -2617.4999999999995 then
    begin
        Result := -0.036607526481582664;
    end
    else
    begin
        if features.candidate_text_units <= 10.500000000000002 then
        begin
            Result := 0.0032721867067631773;
        end
        else
        begin
            if features.delta_char_lm_score <= -79.499999999999986 then
            begin
                if features.baseline_abstain_score <= 111126088.00000001 then
                begin
                    if features.delta_dict_weight <= -381.99999999999994 then
                    begin
                        if features.candidate_chain_score_gap <= 34211640.000000007 then
                        begin
                            if features.top_local_lm_r1 <= -7608.4999999999991 then
                            begin
                                if features.candidate_local_lm_r1 <= -8381.4999999999982 then
                                begin
                                    Result := -0.027315920726862963;
                                end
                                else
                                begin
                                    Result := 0.062548144334424002;
                                end;
                            end
                            else
                            begin
                                Result := -0.021439693200846124;
                            end;
                        end
                        else
                        begin
                            Result := 0.066668572624817207;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -5670.4999999999991 then
                        begin
                            if features.candidate_ranker_score_gap <= -27639646.999999996 then
                            begin
                                Result := 0.032080751979892692;
                            end
                            else
                            begin
                                Result := -0.0059312287510818141;
                            end;
                        end
                        else
                        begin
                            if features.top_local_lm_r3 <= -3628.4999999999995 then
                            begin
                                Result := -0.0070727754934513743;
                            end
                            else
                            begin
                                if features.same_suffix_units <= 7.5000000000000009 then
                                begin
                                    Result := -0.010871697879872777;
                                end
                                else
                                begin
                                    Result := 0.11954902189000795;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.037817010786302813;
                end;
            end
            else
            begin
                if features.delta_char_suffix_lm_per_difference <= -64.833332061767564 then
                begin
                    Result := 0.035111550959442808;
                end
                else
                begin
                    if features.candidate_char_lm_score <= -7009.4999999999991 then
                    begin
                        Result := 0.044129856319447665;
                    end
                    else
                    begin
                        Result := 0.00031267301197039285;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_122(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -2617.4999999999995 then
    begin
        Result := -0.036395897314327436;
    end
    else
    begin
        if features.delta_word_lm_boundary_count <= 6.5000000000000009 then
        begin
            if features.delta_local_lm_r2 <= -2969.4999999999995 then
            begin
                if features.delta_local_lm_r1 <= -3398.4999999999995 then
                begin
                    if features.top_local_lm_r1 <= -3907.4999999999995 then
                    begin
                        Result := 0.12541206601962571;
                    end
                    else
                    begin
                        Result := -0.011285229876068075;
                    end;
                end
                else
                begin
                    Result := -0.021323603891834325;
                end;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -22190821.999999996 then
                begin
                    Result := -0.00071971407986610547;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -7164.4999999999991 then
                    begin
                        if features.top_local_lm_r0 <= -5162.4999999999991 then
                        begin
                            if features.candidate_ranker_score <= 18707849.000000004 then
                            begin
                                if features.delta_chain_second_stage_score <= -76721275.999999985 then
                                begin
                                    Result := -0.019247591299576781;
                                end
                                else
                                begin
                                    if features.delta_chain_second_stage_score <= 1.0000000180025095E-35 then
                                    begin
                                        Result := 0.043880516983176687;
                                    end
                                    else
                                    begin
                                        Result := -0.0061147121048188138;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.030312489161161527;
                            end;
                        end
                        else
                        begin
                            Result := -0.030349092268826316;
                        end;
                    end
                    else
                    begin
                        if features.candidate_candidate_score <= 104757.50000000001 then
                        begin
                            if features.top_local_lm_r0 <= -4922.4999999999991 then
                            begin
                                Result := 0.0070290498814985806;
                            end
                            else
                            begin
                                Result := 0.036455801288039824;
                            end;
                        end
                        else
                        begin
                            Result := 0.0010532235557258909;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_score <= -295.49999999999994 then
            begin
                Result := -0.032995286521681759;
            end
            else
            begin
                Result := 0.011749620290555342;
            end;
        end;
    end;
end;

function local_difference_tree_123(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -309088975.99999994 then
    begin
        Result := -0.027521459617343071;
    end
    else
    begin
        if features.same_suffix_units <= 16.500000000000004 then
        begin
            if features.candidate_local_lm_r0 <= -8652.4999999999982 then
            begin
                if features.candidate_dict_weight <= 123348.50000000001 then
                begin
                    if features.candidate_word_lm_zero_count <= 4.5000000000000009 then
                    begin
                        Result := 0.046769901455838696;
                    end
                    else
                    begin
                        Result := -0.032275526302638309;
                    end;
                end
                else
                begin
                    Result := -0.021960867995141044;
                end;
            end
            else
            begin
                if features.difference_span_units <= 7.5000000000000009 then
                begin
                    if features.delta_local_lm_r1 <= -2417.4999999999995 then
                    begin
                        if features.delta_char_lm_suffix_score <= -502.49999999999994 then
                        begin
                            Result := -0.019822384074533805;
                        end
                        else
                        begin
                            if features.delta_chain_first_stage_score <= -1.0000000180025095E-35 then
                            begin
                                Result := -0.026896458635618015;
                            end
                            else
                            begin
                                Result := 0.093697031990444657;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_path_single_segments <= -1.4999999999999998 then
                        begin
                            if features.delta_dict_weight <= -120805.99999999999 then
                            begin
                                Result := -0.017172374587693221;
                            end
                            else
                            begin
                                if features.candidate_local_lm_r2 <= -7865.4999999999991 then
                                begin
                                    if features.delta_word_lm_bonus <= 38.500000000000007 then
                                    begin
                                        Result := 0.057099321266346523;
                                    end
                                    else
                                    begin
                                        Result := -0.013580855050856502;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.0091150523625742677;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.delta_path_max_segment_units <= 11.500000000000002 then
                            begin
                                Result := 0.00023623068680011397;
                            end
                            else
                            begin
                                Result := 0.057717291672854769;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.025414985281728121;
                end;
            end;
        end
        else
        begin
            Result := -0.024090026929370966;
        end;
    end;
end;

function local_difference_tree_124(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -2181.4999999999995 then
    begin
        Result := -0.032622460626763869;
    end
    else
    begin
        if features.delta_word_lm_boundary_count <= 6.5000000000000009 then
        begin
            if features.candidate_local_lm_r0 <= -8513.4999999999982 then
            begin
                if features.delta_char_lm_suffix_score <= -412.49999999999994 then
                begin
                    if features.candidate_chain_first_stage_score <= 68644.500000000015 then
                    begin
                        Result := 0.046256428411583443;
                    end
                    else
                    begin
                        Result := -0.010129151263953707;
                    end;
                end
                else
                begin
                    Result := -0.031163222624557819;
                end;
            end
            else
            begin
                if features.same_suffix_units <= 16.500000000000004 then
                begin
                    if features.same_prefix_units <= 11.500000000000002 then
                    begin
                        if features.candidate_chain_first_stage_score <= 126094.50000000001 then
                        begin
                            if features.top_local_lm_r1 <= -7164.4999999999991 then
                            begin
                                Result := -0.0078067625801121207;
                            end
                            else
                            begin
                                if features.delta_char_lm_score <= -192.49999999999997 then
                                begin
                                    Result := -0.0021656173551606482;
                                end
                                else
                                begin
                                    Result := 0.008778986792466659;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.candidate_ranker_score <= 3663511.5000000005 then
                            begin
                                Result := -0.00155442356495004;
                            end
                            else
                            begin
                                Result := 0.013915075996585535;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.candidate_chain_first_stage_score <= 139947.50000000003 then
                        begin
                            Result := -0.038940552286174934;
                        end
                        else
                        begin
                            if features.candidate_char_lm_suffix_score <= -4932.4999999999991 then
                            begin
                                Result := -0.0085221382093318507;
                            end
                            else
                            begin
                                Result := 0.035576309360208697;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.025604860968173604;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_score <= -295.49999999999994 then
            begin
                Result := -0.03321037157241357;
            end
            else
            begin
                Result := 0.0074531418234458418;
            end;
        end;
    end;
end;

function local_difference_tree_125(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r2 <= -3083.4999999999995 then
    begin
        Result := -0.035954766034423394;
    end
    else
    begin
        if features.delta_word_lm_bonus <= -815.49999999999989 then
        begin
            Result := -0.040210042760478355;
        end
        else
        begin
            if features.baseline_abstain_score <= 112986832.00000001 then
            begin
                if features.top_local_lm_r1 <= -7950.4999999999991 then
                begin
                    if features.candidate_word_lm_boundary_last <= 1558.5000000000002 then
                    begin
                        Result := -0.016377692626790268;
                    end
                    else
                    begin
                        Result := 0.040267705989917031;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight <= -112271.99999999999 then
                    begin
                        if features.delta_candidate_score <= 19920.500000000004 then
                        begin
                            if features.candidate_local_lm_r1 <= -4441.4999999999991 then
                            begin
                                Result := -0.017603355336584827;
                            end
                            else
                            begin
                                Result := 0.043456995877184601;
                            end;
                        end
                        else
                        begin
                            Result := 0.025222231755708494;
                        end;
                    end
                    else
                    begin
                        if features.delta_dict_weight_per_unit <= -6199.9999999999991 then
                        begin
                            if features.candidate_dict_weight_per_unit <= 5038.0000000000009 then
                            begin
                                Result := 0.029359597096316605;
                            end
                            else
                            begin
                                Result := -0.023424717254109245;
                            end;
                        end
                        else
                        begin
                            if features.delta_dict_weight_per_unit <= -538.49999999999989 then
                            begin
                                if features.delta_chain_score_gap <= 5423999.5000000009 then
                                begin
                                    Result := -0.010042860698941485;
                                end
                                else
                                begin
                                    Result := 0.042434829333118519;
                                end;
                            end
                            else
                            begin
                                Result := 0.0030480961679764207;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_score_per_unit <= 9.5000000000000018 then
                begin
                    Result := 6.8951255404032976E-05;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -7608.4999999999991 then
                    begin
                        Result := 0.0075669420897591577;
                    end
                    else
                    begin
                        Result := -0.038416873023388323;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_126(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.different_units <= 4.5000000000000009 then
    begin
        if features.candidate_local_lm_r0 <= -8513.4999999999982 then
        begin
            if features.delta_char_suffix_lm_per_difference <= -64.833332061767564 then
            begin
                if features.candidate_text_units <= 13.500000000000002 then
                begin
                    Result := 0.038641021570813755;
                end
                else
                begin
                    Result := -0.034010899607961324;
                end;
            end
            else
            begin
                Result := -0.045119484576846232;
            end;
        end
        else
        begin
            if features.delta_char_lm_score <= -487.49999999999994 then
            begin
                if features.delta_dict_weight_per_unit <= 693.50000000000011 then
                begin
                    if features.delta_candidate_score <= 46623.000000000007 then
                    begin
                        Result := -0.017690971146399587;
                    end
                    else
                    begin
                        if features.delta_candidate_score <= 50362.500000000007 then
                        begin
                            Result := 0.074997900714617011;
                        end
                        else
                        begin
                            Result := -0.021629536819488326;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_word_lm_zero_count <= 3.5000000000000004 then
                    begin
                        if features.candidate_local_lm_r2 <= -4847.4999999999991 then
                        begin
                            if features.top_local_lm_r1 <= -4419.4999999999991 then
                            begin
                                Result := 0.0075480650979950275;
                            end
                            else
                            begin
                                Result := -0.026227387957908403;
                            end;
                        end
                        else
                        begin
                            Result := 0.063079168465513313;
                        end;
                    end
                    else
                    begin
                        if features.candidate_dict_weight <= 58199.000000000007 then
                        begin
                            if features.delta_local_lm_r0 <= 123.50000000000001 then
                            begin
                                Result := 0.054669264700408782;
                            end
                            else
                            begin
                                Result := -0.034762780850432419;
                            end;
                        end
                        else
                        begin
                            Result := -0.031791078951737266;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r3 <= -8362.4999999999982 then
                begin
                    Result := -0.023199959164880404;
                end
                else
                begin
                    Result := 0.0029230811550206037;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.036721104308687039;
    end;
end;

function local_difference_tree_127(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -363226175.99999994 then
    begin
        Result := -0.036530085796227803;
    end
    else
    begin
        if features.delta_char_lm_score <= -2059.4999999999995 then
        begin
            Result := -0.022040163175931951;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -8513.4999999999982 then
            begin
                if features.candidate_path_segments <= 5.5000000000000009 then
                begin
                    Result := 0.036078196265015419;
                end
                else
                begin
                    Result := -0.025767668651813676;
                end;
            end
            else
            begin
                if features.different_units <= 3.5000000000000004 then
                begin
                    if features.delta_char_lm_per_difference <= -325.91667175292963 then
                    begin
                        if features.candidate_word_lm_boundary_last <= 1540.5000000000002 then
                        begin
                            if features.delta_dict_weight_per_unit <= -34.499999999999993 then
                            begin
                                if features.candidate_chain_second_stage_score <= 182694728.00000003 then
                                begin
                                    Result := -0.018339741243771458;
                                end
                                else
                                begin
                                    if features.candidate_score_per_unit <= 4712.5000000000009 then
                                    begin
                                        Result := 0.071824537938813604;
                                    end
                                    else
                                    begin
                                        Result := -0.015301386341158678;
                                    end;
                                end;
                            end
                            else
                            begin
                                if features.top_local_lm_r0 <= -3778.4999999999995 then
                                begin
                                    if features.candidate_local_lm_r2 <= -7155.4999999999991 then
                                    begin
                                        if features.delta_char_suffix_lm_per_difference <= -925.24999999999989 then
                                        begin
                                            Result := 0.033361977300597451;
                                        end
                                        else
                                        begin
                                            Result := 0.006287979051547995;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := -0.0016548870871045257;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.027724727088758314;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.029698499229676118;
                        end;
                    end
                    else
                    begin
                        Result := 0.0031962149135248002;
                    end;
                end
                else
                begin
                    if features.delta_chain_first_stage_score <= -227638.99999999997 then
                    begin
                        Result := 0.043656245016866844;
                    end
                    else
                    begin
                        Result := -0.027999220022642327;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_128(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_score_gap <= 79774416.000000015 then
    begin
        if features.candidate_ranker_score <= 3663511.5000000005 then
        begin
            Result := -0.0018580800124295047;
        end
        else
        begin
            if features.candidate_dict_weight <= 133458.00000000003 then
            begin
                if features.candidate_chain_first_stage_score <= 135099.50000000003 then
                begin
                    if features.candidate_path_segments <= 5.5000000000000009 then
                    begin
                        if features.top_local_lm_r1 <= -6372.4999999999991 then
                        begin
                            if features.candidate_chain_score_gap <= 6220573.0000000009 then
                            begin
                                if features.delta_char_lm_score <= -29.499999999999996 then
                                begin
                                    if features.delta_char_lm_score <= -800.49999999999989 then
                                    begin
                                        Result := -0.04550957550222906;
                                    end
                                    else
                                    begin
                                        Result := 0.018988320080405727;
                                    end;
                                end
                                else
                                begin
                                    if features.delta_char_suffix_lm_per_difference <= 141.25000000000003 then
                                    begin
                                        Result := -0.037805244833639062;
                                    end
                                    else
                                    begin
                                        Result := 0.009031125188646379;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.051778948209732355;
                            end;
                        end
                        else
                        begin
                            if features.delta_local_lm_r2 <= -1349.4999999999998 then
                            begin
                                Result := 0.040681934368146558;
                            end
                            else
                            begin
                                Result := 0.007723335651314933;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_score_per_unit <= 1516.0000000000002 then
                        begin
                            Result := -0.0069171874319583736;
                        end
                        else
                        begin
                            Result := -0.032238980047188733;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.021635473046251363;
                end;
            end
            else
            begin
                if features.top_local_lm_r0 <= -3971.4999999999995 then
                begin
                    if features.delta_score_per_unit <= -560.49999999999989 then
                    begin
                        Result := -0.010116401974198696;
                    end
                    else
                    begin
                        Result := 0.016126589367244325;
                    end;
                end
                else
                begin
                    Result := -0.01745748412817821;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.033269768634613305;
    end;
end;

function local_difference_tree_129(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r0 <= -647.49999999999989 then
    begin
        if features.candidate_char_lm_score <= -5033.4999999999991 then
        begin
            if features.top_local_lm_r3 <= -4843.4999999999991 then
            begin
                Result := 0.0028951970434037892;
            end
            else
            begin
                Result := -0.02537471903112179;
            end;
        end
        else
        begin
            if features.candidate_char_lm_score <= -4737.4999999999991 then
            begin
                if features.candidate_chain_second_stage_score <= 79065016.000000015 then
                begin
                    Result := -0.036414850191961126;
                end
                else
                begin
                    if features.delta_char_suffix_lm_per_difference <= -432.89999389648432 then
                    begin
                        Result := 0.042175301081210863;
                    end
                    else
                    begin
                        Result := -0.01635250596414866;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -7462.4999999999991 then
                begin
                    Result := -0.037696078114535778;
                end
                else
                begin
                    if features.top_local_lm_r2 <= -6448.4999999999991 then
                    begin
                        if features.delta_candidate_score <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0023273054889122245;
                        end
                        else
                        begin
                            Result := 0.043596227611147176;
                        end;
                    end
                    else
                    begin
                        if features.candidate_candidate_score <= 40106.500000000007 then
                        begin
                            if features.top_local_lm_r2 <= -5454.4999999999991 then
                            begin
                                Result := -0.016105372127700412;
                            end
                            else
                            begin
                                Result := 0.040311178599895844;
                            end;
                        end
                        else
                        begin
                            if features.candidate_char_lm_suffix_score <= -6416.4999999999991 then
                            begin
                                Result := 0.055801389651499056;
                            end
                            else
                            begin
                                Result := -0.016704919873604233;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r0 <= -562.49999999999989 then
        begin
            if features.top_local_lm_r0 <= -5483.4999999999991 then
            begin
                Result := -0.015459427479701084;
            end
            else
            begin
                Result := 0.033158823417276745;
            end;
        end
        else
        begin
            Result := 0.00095435038058918188;
        end;
    end;
end;

function local_difference_tree_130(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -2181.4999999999995 then
    begin
        Result := -0.030697448836669285;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -8513.4999999999982 then
        begin
            if features.candidate_chain_first_stage_score <= 68644.500000000015 then
            begin
                Result := 0.03694264826990435;
            end
            else
            begin
                Result := -0.015815970098650128;
            end;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -687.49999999999989 then
            begin
                if features.delta_dict_weight <= -2020.9999999999998 then
                begin
                    if features.delta_candidate_score <= 46623.000000000007 then
                    begin
                        if features.delta_score_per_unit <= -2128.4999999999995 then
                        begin
                            if features.delta_path_segments <= -1.0000000180025095E-35 then
                            begin
                                Result := 0.055976517302703657;
                            end
                            else
                            begin
                                Result := -0.008864382170410065;
                            end;
                        end
                        else
                        begin
                            Result := -0.026788956343812634;
                        end;
                    end
                    else
                    begin
                        if features.delta_candidate_score <= 50362.500000000007 then
                        begin
                            Result := 0.073148299190894384;
                        end
                        else
                        begin
                            Result := -0.021180610828525952;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r3 <= -580.49999999999989 then
                    begin
                        if features.candidate_word_lm_boundary_count <= 6.5000000000000009 then
                        begin
                            if features.top_local_lm_r0 <= -5890.4999999999991 then
                            begin
                                if features.candidate_dict_weight <= 111960.00000000001 then
                                begin
                                    Result := -0.0022695189885666551;
                                end
                                else
                                begin
                                    Result := 0.03541043017468655;
                                end;
                            end
                            else
                            begin
                                Result := -0.00018806085827409455;
                            end;
                        end
                        else
                        begin
                            Result := -0.014396616205575686;
                        end;
                    end
                    else
                    begin
                        Result := -0.033235838877222167;
                    end;
                end;
            end
            else
            begin
                if features.candidate_dict_weight_per_unit <= 29415.000000000004 then
                begin
                    Result := 0.0014746052337987728;
                end
                else
                begin
                    Result := 0.038077562600916923;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_131(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_boundary_last <= -1474.4999999999998 then
    begin
        Result := -0.020158602177802742;
    end
    else
    begin
        if features.different_units <= 4.5000000000000009 then
        begin
            if features.delta_word_lm_boundary_count <= -1.0000000180025095E-35 then
            begin
                if features.candidate_chain_first_stage_score <= 90035.000000000015 then
                begin
                    if features.candidate_chain_second_stage_score <= 156229560.00000003 then
                    begin
                        if features.delta_word_lm_zero_count <= -3.4999999999999996 then
                        begin
                            if features.delta_char_lm_per_difference <= -173.90000152587888 then
                            begin
                                if features.candidate_local_lm_r1 <= -8968.4999999999982 then
                                begin
                                    Result := 0.045221712759982283;
                                end
                                else
                                begin
                                    if features.top_local_lm_r1 <= -7462.4999999999991 then
                                    begin
                                        Result := 0.047407648507940423;
                                    end
                                    else
                                    begin
                                        Result := -0.032374877595007533;
                                    end;
                                end;
                            end
                            else
                            begin
                                if features.candidate_char_lm_suffix_score <= -6131.4999999999991 then
                                begin
                                    if features.delta_word_lm_boundary_count <= -8.4999999999999982 then
                                    begin
                                        Result := -0.0014504220561943864;
                                    end
                                    else
                                    begin
                                        Result := 0.065855186323945075;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.011278807753440943;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.021798155552466426;
                        end;
                    end
                    else
                    begin
                        Result := 0.040658725978361378;
                    end;
                end
                else
                begin
                    if features.top_local_lm_r1 <= -6372.4999999999991 then
                    begin
                        if features.top_local_lm_r1 <= -6794.4999999999991 then
                        begin
                            Result := 0.015707587003100255;
                        end
                        else
                        begin
                            Result := 0.057847663009693961;
                        end;
                    end
                    else
                    begin
                        if features.candidate_char_lm_suffix_score <= -6416.4999999999991 then
                        begin
                            Result := 0.035574543339140986;
                        end
                        else
                        begin
                            Result := -0.013423591734931652;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 1.4556683408345379E-05;
            end;
        end
        else
        begin
            Result := -0.034692829206608593;
        end;
    end;
end;

function local_difference_tree_132(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.037478595524121937;
    end
    else
    begin
        if features.candidate_ranker_score <= 7979596.5000000009 then
        begin
            if features.delta_chain_first_stage_score <= 156.50000000000003 then
            begin
                if features.delta_candidate_score <= 46623.000000000007 then
                begin
                    if features.delta_dict_weight <= -112271.99999999999 then
                    begin
                        if features.delta_local_lm_r3 <= -197.49999999999997 then
                        begin
                            Result := -0.029181285495301145;
                        end
                        else
                        begin
                            if features.delta_path_max_segment_units <= 5.5000000000000009 then
                            begin
                                Result := -0.0084597176461889308;
                            end
                            else
                            begin
                                Result := 0.032980317581644922;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_dict_weight_per_unit <= -6199.9999999999991 then
                        begin
                            if features.candidate_local_lm_r0 <= -4704.4999999999991 then
                            begin
                                if features.candidate_char_lm_score <= -3889.4999999999995 then
                                begin
                                    Result := -0.0052183932793241584;
                                end
                                else
                                begin
                                    Result := 0.064217603016956865;
                                end;
                            end
                            else
                            begin
                                Result := 0.043140504387859047;
                            end;
                        end
                        else
                        begin
                            Result := 0.0013111860684407242;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.034052491481127073;
                end;
            end
            else
            begin
                if features.candidate_dict_weight <= -9283.9999999999982 then
                begin
                    Result := 0.05758532284791068;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -5813.4999999999991 then
                    begin
                        if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.055279358640056966;
                        end
                        else
                        begin
                            if features.delta_word_lm_bonus <= -612.49999999999989 then
                            begin
                                Result := 0.047100485127794842;
                            end
                            else
                            begin
                                Result := -0.0081731967507001086;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.028084580561933602;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.0074149322904780912;
        end;
    end;
end;

function local_difference_tree_133(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -273.49999999999994 then
    begin
        if features.delta_word_lm_per_boundary <= -62.325000762939446 then
        begin
            if features.delta_local_lm_r3 <= -848.49999999999989 then
            begin
                Result := -0.031373976826730508;
            end
            else
            begin
                Result := 0.0;
            end;
        end
        else
        begin
            Result := -0.045335663770584914;
        end;
    end
    else
    begin
        if features.candidate_chain_score_gap <= -197497767.99999997 then
        begin
            if features.delta_dict_weight <= -94218.499999999985 then
            begin
                Result := -0.027715337173699322;
            end
            else
            begin
                if features.candidate_input_syllable_count <= 11.500000000000002 then
                begin
                    if features.delta_local_lm_r3 <= -486.49999999999994 then
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -287.63333129882807 then
                        begin
                            if features.candidate_dict_weight <= 116175.00000000001 then
                            begin
                                if features.delta_score_per_unit <= -2341.4999999999995 then
                                begin
                                    Result := 0.047439569765397128;
                                end
                                else
                                begin
                                    Result := -0.029091195718479922;
                                end;
                            end
                            else
                            begin
                                Result := 0.080004669129868464;
                            end;
                        end
                        else
                        begin
                            Result := 0.1043975944894954;
                        end;
                    end
                    else
                    begin
                        Result := -0.0065197477444826424;
                    end;
                end
                else
                begin
                    if features.candidate_score_per_unit <= 7123.5000000000009 then
                    begin
                        Result := 0.052420803723058643;
                    end
                    else
                    begin
                        Result := -0.021668431665405937;
                    end;
                end;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= 3663511.5000000005 then
            begin
                Result := -0.0028177944472384188;
            end
            else
            begin
                if features.candidate_dict_weight <= 133458.00000000003 then
                begin
                    if features.candidate_chain_first_stage_score <= 136365.50000000003 then
                    begin
                        Result := -0.0035802067291067947;
                    end
                    else
                    begin
                        Result := 0.020447342825454209;
                    end;
                end
                else
                begin
                    Result := 0.010082731523909731;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_134(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= 26133565.000000004 then
    begin
        if features.candidate_ranker_score_gap <= -22190821.999999996 then
        begin
            if features.delta_chain_first_stage_score <= 645.50000000000011 then
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    if features.delta_dict_weight <= -112271.99999999999 then
                    begin
                        if features.delta_local_lm_r3 <= -377.49999999999994 then
                        begin
                            Result := -0.030990537305408745;
                        end
                        else
                        begin
                            Result := 0.0015024557004722522;
                        end;
                    end
                    else
                    begin
                        if features.delta_dict_weight_per_unit <= -7155.4999999999991 then
                        begin
                            Result := 0.023639095774880298;
                        end
                        else
                        begin
                            Result := 0.00069247450378346611;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_score_per_unit <= 8363.5000000000018 then
                    begin
                        Result := 0.065271878092680896;
                    end
                    else
                    begin
                        Result := -0.022160452693343276;
                    end;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r1 <= -6486.4999999999991 then
                begin
                    if features.candidate_word_lm_zero_count <= 3.5000000000000004 then
                    begin
                        if features.candidate_local_lm_r2 <= -6784.4999999999991 then
                        begin
                            Result := 0.0038781342495174355;
                        end
                        else
                        begin
                            Result := 0.043397031622219279;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r1 <= -4972.4999999999991 then
                        begin
                            Result := -0.013600504231359887;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r1 <= -6867.4999999999991 then
                            begin
                                if features.delta_char_lm_score <= -868.49999999999989 then
                                begin
                                    Result := -0.018832274884930573;
                                end
                                else
                                begin
                                    Result := 0.16801204365127906;
                                end;
                            end
                            else
                            begin
                                Result := -0.026359803277731877;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.030126492631616306;
                end;
            end;
        end
        else
        begin
            Result := 0.0073410393919475722;
        end;
    end
    else
    begin
        Result := -0.031463818197341217;
    end;
end;

function local_difference_tree_135(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.difference_span_units <= 7.5000000000000009 then
    begin
        if features.delta_path_single_segments <= -1.4999999999999998 then
        begin
            if features.same_suffix_units <= 1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r0 <= -4179.4999999999991 then
                begin
                    Result := 0.059186700901050021;
                end
                else
                begin
                    Result := -0.030691187477432446;
                end;
            end
            else
            begin
                if features.delta_dict_weight <= -120805.99999999999 then
                begin
                    if features.top_local_lm_r0 <= -3812.4999999999995 then
                    begin
                        Result := -0.026728120365185865;
                    end
                    else
                    begin
                        Result := 0.048866101443424792;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r1 <= -1267.4999999999998 then
                    begin
                        if features.candidate_local_lm_r2 <= -6599.4999999999991 then
                        begin
                            Result := -0.020117900308932245;
                        end
                        else
                        begin
                            Result := 0.037098059709147375;
                        end;
                    end
                    else
                    begin
                        if features.candidate_char_lm_suffix_score <= -5208.4999999999991 then
                        begin
                            if features.candidate_chain_score_gap <= -97719983.999999985 then
                            begin
                                Result := -0.012057269953303069;
                            end
                            else
                            begin
                                if features.candidate_word_lm_boundary_first <= 1369.5000000000002 then
                                begin
                                    Result := 0.03043783448091452;
                                end
                                else
                                begin
                                    Result := -0.020480789707274495;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.011746840304769973;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_trigram_ratio <= -83.499999999999986 then
            begin
                Result := -0.042851862268871679;
            end
            else
            begin
                if features.delta_path_max_segment_units <= 11.500000000000002 then
                begin
                    Result := -0.00085823188127046274;
                end
                else
                begin
                    if features.candidate_score_per_unit <= 10179.500000000002 then
                    begin
                        Result := -0.018891025289093279;
                    end
                    else
                    begin
                        Result := 0.089623773765274847;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.02579262124512181;
    end;
end;

function local_difference_tree_136(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_score_gap <= 79774416.000000015 then
    begin
        if features.delta_word_lm_supported_ratio <= -516.49999999999989 then
        begin
            Result := -0.034233276098603563;
        end
        else
        begin
            if features.delta_chain_score_gap <= -187927871.99999997 then
            begin
                if features.candidate_ranker_score_gap <= -46508689.999999993 then
                begin
                    if features.candidate_local_lm_r2 <= -6210.4999999999991 then
                    begin
                        if features.candidate_local_lm_r3 <= -7424.4999999999991 then
                        begin
                            if features.same_suffix_units <= 6.5000000000000009 then
                            begin
                                Result := 0.061160211545426828;
                            end
                            else
                            begin
                                Result := -0.023260363639211627;
                            end;
                        end
                        else
                        begin
                            Result := -0.031510981284304282;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -317.83332824707026 then
                        begin
                            Result := -0.021172183588209183;
                        end
                        else
                        begin
                            if features.delta_local_lm_r1 <= -234.49999999999997 then
                            begin
                                Result := 0.075362706262589285;
                            end
                            else
                            begin
                                Result := -0.027722398455302812;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r3 <= -6540.4999999999991 then
                    begin
                        if features.candidate_text_units <= 7.5000000000000009 then
                        begin
                            Result := 0.030669366896060465;
                        end
                        else
                        begin
                            Result := -0.037567994780908706;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r0 <= -4112.4999999999991 then
                        begin
                            if features.candidate_score_per_unit <= 11354.500000000002 then
                            begin
                                Result := 0.10139031576161114;
                            end
                            else
                            begin
                                Result := 0.016251547111826654;
                            end;
                        end
                        else
                        begin
                            Result := -0.017271822410960119;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -22190821.999999996 then
                begin
                    Result := -0.0011296697927312327;
                end
                else
                begin
                    Result := 0.0060030326451673138;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.031835151711345197;
    end;
end;

function local_difference_tree_137(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.top_local_lm_r1 <= -4915.4999999999991 then
    begin
        if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
        begin
            if features.candidate_chain_score_gap <= -194178975.99999997 then
            begin
                if features.candidate_local_lm_r0 <= -5000.4999999999991 then
                begin
                    Result := 0.04570252470336713;
                end
                else
                begin
                    Result := -0.020957766264129925;
                end;
            end
            else
            begin
                if features.delta_path_max_segment_units <= -7.4999999999999991 then
                begin
                    Result := -0.029613501350479722;
                end
                else
                begin
                    Result := 0.002585742801304134;
                end;
            end;
        end
        else
        begin
            if features.delta_path_max_segment_units <= -3.4999999999999996 then
            begin
                Result := 0.029351983328356816;
            end
            else
            begin
                if features.delta_char_lm_score <= -487.49999999999994 then
                begin
                    Result := -0.018996088071287425;
                end
                else
                begin
                    if features.same_prefix_units <= 3.5000000000000004 then
                    begin
                        if features.candidate_chain_first_stage_score <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.040923355893752976;
                        end
                        else
                        begin
                            if features.top_local_lm_r2 <= -7695.4999999999991 then
                            begin
                                Result := -0.040537474181832324;
                            end
                            else
                            begin
                                Result := 0.0088260445810489415;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r0 <= -4979.4999999999991 then
                        begin
                            Result := -0.020370642791789656;
                        end
                        else
                        begin
                            if features.top_local_lm_r0 <= -5162.4999999999991 then
                            begin
                                if features.delta_local_lm_r1 <= 738.50000000000011 then
                                begin
                                    Result := -0.036039568241239966;
                                end
                                else
                                begin
                                    Result := 0.01552675320499367;
                                end;
                            end
                            else
                            begin
                                Result := 0.016734476801919921;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= 1.0000000180025095E-35 then
        begin
            Result := -0.0090726087487176168;
        end
        else
        begin
            Result := 0.012820954557580033;
        end;
    end;
end;

function local_difference_tree_138(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.same_prefix_units <= 12.500000000000002 then
    begin
        if features.candidate_chain_rank <= 2.5000000000000004 then
        begin
            if features.delta_word_lm_bonus <= -745.49999999999989 then
            begin
                Result := -0.039211957746391052;
            end
            else
            begin
                if features.delta_chain_score_gap <= 79774416.000000015 then
                begin
                    if features.candidate_char_lm_score <= -4230.9999999999991 then
                    begin
                        if features.candidate_word_lm_bonus <= 910.50000000000011 then
                        begin
                            Result := -0.0004006341428370172;
                        end
                        else
                        begin
                            Result := -0.029187122848257148;
                        end;
                    end
                    else
                    begin
                        if features.delta_chain_score_gap <= -117468951.99999999 then
                        begin
                            if features.candidate_chain_first_stage_score <= 143139.00000000003 then
                            begin
                                Result := 0.028298928702202537;
                            end
                            else
                            begin
                                Result := -0.01250499669753799;
                            end;
                        end
                        else
                        begin
                            Result := 0.0021940131876575972;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.029584497447153697;
                end;
            end;
        end
        else
        begin
            if features.top_local_lm_r1 <= -5230.4999999999991 then
            begin
                if features.candidate_chain_rank <= 4.5000000000000009 then
                begin
                    Result := 0.032586220083833661;
                end
                else
                begin
                    Result := -0.021780713376400227;
                end;
            end
            else
            begin
                Result := -0.035528550341808345;
            end;
        end;
    end
    else
    begin
        if features.delta_char_suffix_lm_per_difference <= 38.250000000000007 then
        begin
            if features.candidate_word_lm_zero_count <= 10.500000000000002 then
            begin
                if features.delta_chain_score_gap <= -93631183.999999985 then
                begin
                    if features.candidate_chain_score_gap <= -108981183.99999999 then
                    begin
                        Result := -0.025506533553581373;
                    end
                    else
                    begin
                        Result := 0.031387577962532977;
                    end;
                end
                else
                begin
                    Result := -0.036033051041711311;
                end;
            end
            else
            begin
                Result := 0.035481823382812985;
            end;
        end
        else
        begin
            Result := 0.014056192439160545;
        end;
    end;
end;

function local_difference_tree_139(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_first_stage_score <= -115127.99999999999 then
    begin
        if features.delta_local_lm_r1 <= -309.49999999999994 then
        begin
            Result := -0.026201543788645379;
        end
        else
        begin
            if features.same_suffix_units <= 3.5000000000000004 then
            begin
                Result := -0.024225235656480045;
            end
            else
            begin
                Result := 0.014056213891114023;
            end;
        end;
    end
    else
    begin
        if features.delta_score_per_unit <= -6710.4999999999991 then
        begin
            if features.delta_path_max_segment_units <= -1.0000000180025095E-35 then
            begin
                if features.top_local_lm_r3 <= -5463.4999999999991 then
                begin
                    Result := -0.043294599899672825;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= -193.49999999999997 then
                    begin
                        Result := -0.029705318021312856;
                    end
                    else
                    begin
                        Result := 0.056419788519873663;
                    end;
                end;
            end
            else
            begin
                Result := 0.024905672021637418;
            end;
        end
        else
        begin
            if features.delta_dict_weight <= -221.49999999999997 then
            begin
                Result := -0.0042924685454465497;
            end
            else
            begin
                if features.different_units <= 2.5000000000000004 then
                begin
                    if features.top_local_lm_r2 <= -6422.4999999999991 then
                    begin
                        if features.different_units <= 1.5000000000000002 then
                        begin
                            Result := 0.014003924779372099;
                        end
                        else
                        begin
                            Result := -0.00085759953183327643;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r3 <= -8253.4999999999982 then
                        begin
                            Result := 0.037087654011749904;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r0 <= -3909.4999999999995 then
                            begin
                                if features.delta_candidate_score <= -127.49999999999999 then
                                begin
                                    Result := 0.0068196905575268309;
                                end
                                else
                                begin
                                    Result := -0.0060263298853761331;
                                end;
                            end
                            else
                            begin
                                Result := 0.014321725201956011;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.013621951935975086;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_140(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.same_prefix_units <= 18.500000000000004 then
    begin
        if features.delta_word_lm_boundary_count <= 6.5000000000000009 then
        begin
            if features.delta_char_lm_score <= -2181.4999999999995 then
            begin
                Result := -0.02699670719983021;
            end
            else
            begin
                if features.delta_legacy_rank <= 1.5000000000000002 then
                begin
                    Result := -0.00024819741991995105;
                end
                else
                begin
                    if features.candidate_text_units <= 8.5000000000000018 then
                    begin
                        if features.top_local_lm_r0 <= -4112.4999999999991 then
                        begin
                            if features.candidate_char_lm_context_score <= -5938.4999999999991 then
                            begin
                                if features.delta_char_suffix_lm_per_difference <= -165.90000152587888 then
                                begin
                                    Result := 0.053287182608612885;
                                end
                                else
                                begin
                                    Result := -0.015909816041174748;
                                end;
                            end
                            else
                            begin
                                Result := -0.032368412667380567;
                            end;
                        end
                        else
                        begin
                            Result := -0.034044228173380937;
                        end;
                    end
                    else
                    begin
                        if features.delta_char_lm_suffix_score <= -502.49999999999994 then
                        begin
                            if features.candidate_local_lm_r0 <= -9084.9999999999982 then
                            begin
                                Result := 0.043462211289134862;
                            end
                            else
                            begin
                                if features.candidate_chain_score_gap <= -188516335.99999997 then
                                begin
                                    Result := 0.033645424876802055;
                                end
                                else
                                begin
                                    Result := -0.030135952903293645;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.candidate_dict_weight_per_unit <= 9623.0000000000018 then
                            begin
                                Result := 0.026653764453724849;
                            end
                            else
                            begin
                                Result := -0.0089290702005011807;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_score <= -295.49999999999994 then
            begin
                Result := -0.034045967053720066;
            end
            else
            begin
                if features.delta_path_segments <= 8.5000000000000018 then
                begin
                    Result := -0.025531308840662428;
                end
                else
                begin
                    Result := 0.033871676749385064;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.040323046884800269;
    end;
end;

function local_difference_tree_141(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_local_lm_r3 <= -4782.4999999999991 then
    begin
        if features.top_local_lm_r3 <= -4902.4999999999991 then
        begin
            Result := 0.00053547137567398848;
        end
        else
        begin
            if features.delta_char_suffix_lm_per_difference <= -26.749999999999996 then
            begin
                if features.delta_char_suffix_lm_per_difference <= -148.87499999999997 then
                begin
                    if features.top_local_lm_r2 <= -5584.4999999999991 then
                    begin
                        Result := -0.027628032529177306;
                    end
                    else
                    begin
                        if features.top_local_lm_r2 <= -4783.4999999999991 then
                        begin
                            if features.candidate_char_lm_suffix_score <= -4515.4999999999991 then
                            begin
                                Result := 0.02108525002826896;
                            end
                            else
                            begin
                                Result := -0.028353770483524467;
                            end;
                        end
                        else
                        begin
                            if features.delta_word_lm_boundary_first <= 1183.5000000000002 then
                            begin
                                Result := -0.022487573149344124;
                            end
                            else
                            begin
                                Result := 0.06761079492321255;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.04821208276158033;
                end;
            end
            else
            begin
                Result := 0.043979421788560062;
            end;
        end;
    end
    else
    begin
        if features.delta_chain_score_gap <= -109729091.99999999 then
        begin
            if features.candidate_local_lm_r1 <= -4441.4999999999991 then
            begin
                Result := 0.058898545674935743;
            end
            else
            begin
                Result := -0.00035094568340496063;
            end;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -3909.4999999999995 then
            begin
                if features.delta_local_lm_r0 <= 376.50000000000006 then
                begin
                    if features.candidate_word_lm_supported_ratio <= 147.50000000000003 then
                    begin
                        Result := 0.019863777116609912;
                    end
                    else
                    begin
                        if features.candidate_word_lm_boundary_max <= 1534.5000000000002 then
                        begin
                            Result := -0.045729117564113173;
                        end
                        else
                        begin
                            Result := 0.0036987230905423996;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.045933431248201213;
                end;
            end
            else
            begin
                Result := 0.036231450250363596;
            end;
        end;
    end;
end;

function local_difference_tree_142(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_rank <= 3.5000000000000004 then
    begin
        if features.candidate_chain_rank <= 2.5000000000000004 then
        begin
            if features.delta_word_lm_boundary_first <= -1396.4999999999998 then
            begin
                Result := -0.029078244827971736;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -4210.9999999999991 then
                begin
                    if features.delta_chain_score_gap <= -187927871.99999997 then
                    begin
                        if features.candidate_ranker_score <= -15863820.499999998 then
                        begin
                            Result := -0.0023596888085906185;
                        end
                        else
                        begin
                            Result := 0.042291532338201536;
                        end;
                    end
                    else
                    begin
                        Result := -0.0013976248338761483;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r0 <= -4192.4999999999991 then
                    begin
                        Result := 0.029712782551961241;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r3 <= -6540.4999999999991 then
                        begin
                            if features.delta_chain_score_gap <= 1.0000000180025095E-35 then
                            begin
                                if features.candidate_local_lm_r3 <= -7276.4999999999991 then
                                begin
                                    Result := 0.0024401912681453457;
                                end
                                else
                                begin
                                    Result := -0.030756328088316544;
                                end;
                            end
                            else
                            begin
                                Result := 0.028385704382653948;
                            end;
                        end
                        else
                        begin
                            if features.delta_word_lm_bonus <= -173.49999999999997 then
                            begin
                                if features.candidate_char_lm_suffix_score <= -5719.4999999999991 then
                                begin
                                    Result := 0.028769278364490971;
                                end
                                else
                                begin
                                    Result := -0.049658588197126027;
                                end;
                            end
                            else
                            begin
                                if features.delta_score_per_unit <= 16.500000000000004 then
                                begin
                                    Result := 0.018378392653500757;
                                end
                                else
                                begin
                                    Result := -0.0065885012134695702;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.top_local_lm_r1 <= -5230.4999999999991 then
            begin
                Result := 0.027524339016610697;
            end
            else
            begin
                Result := -0.034042545231200129;
            end;
        end;
    end
    else
    begin
        Result := -0.034968208494039053;
    end;
end;

function local_difference_tree_143(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= 7979596.5000000009 then
    begin
        if features.delta_chain_first_stage_score <= 645.50000000000011 then
        begin
            if features.delta_score_per_unit <= 6046.5000000000009 then
            begin
                Result := 0.00076188665584497298;
            end
            else
            begin
                Result := 0.041665876698075616;
            end;
        end
        else
        begin
            if features.candidate_local_lm_r1 <= -6762.4999999999991 then
            begin
                if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                begin
                    Result := 0.065562744682342383;
                end
                else
                begin
                    if features.candidate_chain_first_stage_score <= 116190.50000000001 then
                    begin
                        if features.same_prefix_units <= 7.5000000000000009 then
                        begin
                            Result := -0.023378002049567633;
                        end
                        else
                        begin
                            Result := 0.029472961045804026;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r0 <= -5909.9999999999991 then
                        begin
                            Result := -0.011197347530903687;
                        end
                        else
                        begin
                            if features.top_local_lm_r2 <= -5996.4999999999991 then
                            begin
                                Result := 0.0075412019442511868;
                            end
                            else
                            begin
                                if features.candidate_word_lm_boundary_count <= 5.5000000000000009 then
                                begin
                                    Result := 0.091533056580983582;
                                end
                                else
                                begin
                                    if features.top_local_lm_r2 <= -5479.4999999999991 then
                                    begin
                                        Result := 0.051694584677283911;
                                    end
                                    else
                                    begin
                                        Result := -0.025661757282711521;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r0 <= -7027.9999999999991 then
                begin
                    Result := 0.029827606988328727;
                end
                else
                begin
                    Result := -0.023157927886681993;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_chain_first_stage_score <= -212.49999999999997 then
        begin
            if features.top_local_lm_r0 <= -5632.4999999999991 then
            begin
                Result := 0.016486890575149356;
            end
            else
            begin
                Result := -0.03335851566157972;
            end;
        end
        else
        begin
            Result := 0.010790172843762238;
        end;
    end;
end;

function local_difference_tree_144(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_text_units <= 10.500000000000002 then
    begin
        Result := 0.0011837671962689148;
    end
    else
    begin
        if features.delta_local_lm_r0 <= -1867.4999999999998 then
        begin
            if features.delta_local_lm_r3 <= -1985.4999999999998 then
            begin
                Result := 0.036568651873818234;
            end
            else
            begin
                Result := -0.023221188544557361;
            end;
        end
        else
        begin
            if features.delta_char_lm_per_difference <= -118.16666793823241 then
            begin
                if features.candidate_local_lm_r1 <= -6461.4999999999991 then
                begin
                    if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.038329267765571252;
                    end
                    else
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -511.63333129882807 then
                        begin
                            if features.candidate_chain_score_gap <= -244148495.99999997 then
                            begin
                                Result := 0.071611743655317625;
                            end
                            else
                            begin
                                Result := -0.034211662052151995;
                            end;
                        end
                        else
                        begin
                            if features.top_local_lm_r1 <= -4972.4999999999991 then
                            begin
                                if features.candidate_local_lm_r0 <= -3590.9999999999995 then
                                begin
                                    if features.delta_dict_weight <= -191.49999999999997 then
                                    begin
                                        if features.delta_candidate_score <= -58227.499999999993 then
                                        begin
                                            Result := 0.026086102028413275;
                                        end
                                        else
                                        begin
                                            Result := -0.02702179513708616;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := 0.0023591607218064834;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.037695627613505873;
                                end;
                            end
                            else
                            begin
                                if features.delta_dict_weight <= -233.49999999999997 then
                                begin
                                    Result := -0.023897766320281372;
                                end
                                else
                                begin
                                    Result := 0.085490678366163933;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_char_lm_suffix_score <= -5809.4999999999991 then
                    begin
                        Result := -0.032309070851875663;
                    end
                    else
                    begin
                        Result := -0.0064860028386820702;
                    end;
                end;
            end
            else
            begin
                Result := 0.0021470282428071746;
            end;
        end;
    end;
end;

function local_difference_tree_145(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -815.49999999999989 then
    begin
        Result := -0.038432276759141987;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -2617.4999999999995 then
        begin
            Result := -0.028750942055278436;
        end
        else
        begin
            if features.same_prefix_units <= 18.500000000000004 then
            begin
                if features.delta_word_lm_boundary_count <= 6.5000000000000009 then
                begin
                    if features.baseline_abstain_score <= 93487884.000000015 then
                    begin
                        if features.delta_candidate_score <= 7555.0000000000009 then
                        begin
                            if features.delta_candidate_score <= 4095.5000000000005 then
                            begin
                                Result := 0.0016000142234631057;
                            end
                            else
                            begin
                                Result := -0.025837992658980072;
                            end;
                        end
                        else
                        begin
                            if features.delta_dict_weight <= 9015.0000000000018 then
                            begin
                                if features.candidate_local_lm_r3 <= -7300.4999999999991 then
                                begin
                                    Result := 0.042106168400693249;
                                end
                                else
                                begin
                                    Result := 0.010414271356404492;
                                end;
                            end
                            else
                            begin
                                Result := -0.0019987338513156767;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.candidate_word_lm_boundary_last <= 1477.5000000000002 then
                        begin
                            Result := -0.011667715907364295;
                        end
                        else
                        begin
                            if features.delta_chain_second_stage_score <= -36020725.999999993 then
                            begin
                                Result := 0.049301444118493791;
                            end
                            else
                            begin
                                Result := -0.012963643899621994;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_chain_second_stage_score <= 41579734.000000007 then
                    begin
                        Result := -0.029403700762438711;
                    end
                    else
                    begin
                        if features.candidate_char_lm_suffix_score <= -5434.4999999999991 then
                        begin
                            Result := 0.045577657675707997;
                        end
                        else
                        begin
                            if features.delta_char_lm_score <= -221.49999999999997 then
                            begin
                                Result := -0.045000210464883707;
                            end
                            else
                            begin
                                Result := 0.031672154063796649;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.035586513309477999;
            end;
        end;
    end;
end;

function local_difference_tree_146(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_char_lm_score <= -3164.4999999999995 then
    begin
        if features.top_local_lm_r2 <= -4572.4999999999991 then
        begin
            if features.delta_char_suffix_lm_per_difference <= -925.24999999999989 then
            begin
                if features.same_suffix_units <= 1.5000000000000002 then
                begin
                    Result := 0.039756861557367622;
                end
                else
                begin
                    Result := 0.0049770386639924977;
                end;
            end
            else
            begin
                Result := 0.00013142665592921627;
            end;
        end
        else
        begin
            if features.candidate_local_lm_r2 <= -4997.4999999999991 then
            begin
                if features.same_suffix_units <= 6.5000000000000009 then
                begin
                    Result := -0.029916624539801304;
                end
                else
                begin
                    if features.delta_local_lm_r1 <= -2026.4999999999998 then
                    begin
                        if features.top_local_lm_r0 <= -4313.4999999999991 then
                        begin
                            Result := -0.021224140931656432;
                        end
                        else
                        begin
                            Result := 0.15171538234619913;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r3 <= -4636.9999999999991 then
                        begin
                            Result := -0.035722626877195775;
                        end
                        else
                        begin
                            Result := 0.061015416971640674;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -3590.9999999999995 then
                begin
                    if features.candidate_char_lm_score <= -5082.4999999999991 then
                    begin
                        Result := 0.027061719756366495;
                    end
                    else
                    begin
                        Result := -0.014235083016173124;
                    end;
                end
                else
                begin
                    Result := 0.042931847998348344;
                end;
            end;
        end;
    end
    else
    begin
        if features.top_local_lm_r1 <= -5906.4999999999991 then
        begin
            Result := -0.020222540046682013;
        end
        else
        begin
            if features.top_local_lm_r3 <= -3903.4999999999995 then
            begin
                Result := 0.036164418669420544;
            end
            else
            begin
                if features.delta_char_lm_score <= 1.0000000180025095E-35 then
                begin
                    Result := -0.030327249598000025;
                end
                else
                begin
                    Result := 0.046883683634783666;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_147(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= 7979596.5000000009 then
    begin
        if features.delta_chain_first_stage_score <= 645.50000000000011 then
        begin
            if features.delta_score_per_unit <= 686.00000000000011 then
            begin
                if features.delta_char_lm_score <= -487.49999999999994 then
                begin
                    if features.delta_dict_weight_per_unit <= 21614.500000000004 then
                    begin
                        Result := -0.011733080513974236;
                    end
                    else
                    begin
                        Result := 0.01088826696190261;
                    end;
                end
                else
                begin
                    Result := 0.0012925411105005158;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r3 <= -7300.4999999999991 then
                begin
                    if features.delta_dict_weight <= 13207.000000000002 then
                    begin
                        Result := 0.044263695828508011;
                    end
                    else
                    begin
                        Result := -0.033348282606317205;
                    end;
                end
                else
                begin
                    Result := 0.0035993205728039744;
                end;
            end;
        end
        else
        begin
            if features.candidate_dict_weight <= -52017.999999999993 then
            begin
                Result := 0.059622410003983162;
            end
            else
            begin
                if features.candidate_chain_first_stage_score <= 74469.000000000015 then
                begin
                    Result := -0.031200350896181447;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -6762.4999999999991 then
                    begin
                        if features.top_local_lm_r1 <= -5005.4999999999991 then
                        begin
                            if features.candidate_word_lm_zero_count <= 3.5000000000000004 then
                            begin
                                Result := 0.025337751248157812;
                            end
                            else
                            begin
                                Result := -0.0089160678405453588;
                            end;
                        end
                        else
                        begin
                            if features.candidate_text_units <= 12.500000000000002 then
                            begin
                                Result := -0.026107113157154811;
                            end
                            else
                            begin
                                Result := 0.13533764531745671;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_candidate_score <= 119779.50000000001 then
                        begin
                            Result := -0.023135704563393828;
                        end
                        else
                        begin
                            Result := 0.038687763948956046;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.0062484179238116487;
    end;
end;

function local_difference_tree_148(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -2617.4999999999995 then
    begin
        Result := -0.035381220675661788;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -2969.4999999999995 then
        begin
            if features.delta_local_lm_r1 <= -3398.4999999999995 then
            begin
                Result := 0.087194008772292497;
            end
            else
            begin
                Result := -0.019848740069760604;
            end;
        end
        else
        begin
            if features.candidate_char_lm_score <= -3164.4999999999995 then
            begin
                if features.delta_dict_weight_per_unit <= -748.49999999999989 then
                begin
                    if features.delta_chain_score_gap <= 19683805.000000004 then
                    begin
                        if features.delta_local_lm_r1 <= -566.49999999999989 then
                        begin
                            Result := -0.015498726530724026;
                        end
                        else
                        begin
                            if features.delta_path_max_segment_units <= -1.0000000180025095E-35 then
                            begin
                                if features.candidate_local_lm_r3 <= -5342.4999999999991 then
                                begin
                                    Result := -0.034388321030095641;
                                end
                                else
                                begin
                                    Result := 0.0162316978371797;
                                end;
                            end
                            else
                            begin
                                if features.candidate_char_lm_context_score <= -5783.4999999999991 then
                                begin
                                    if features.candidate_word_lm_supported_ratio <= 240.00000000000003 then
                                    begin
                                        Result := 0.003893122795548824;
                                    end
                                    else
                                    begin
                                        Result := 0.032032371078049668;
                                    end;
                                end
                                else
                                begin
                                    if features.delta_dict_weight_per_unit <= -5462.4999999999991 then
                                    begin
                                        Result := 0.0038072610838109852;
                                    end
                                    else
                                    begin
                                        Result := -0.029973909637852118;
                                    end;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.040652662714822423;
                    end;
                end
                else
                begin
                    if features.delta_candidate_score <= 28464.000000000004 then
                    begin
                        if features.delta_local_lm_r0 <= 2332.5000000000005 then
                        begin
                            Result := 0.0021542321057427785;
                        end
                        else
                        begin
                            Result := 0.036457627982438116;
                        end;
                    end
                    else
                    begin
                        Result := -0.009958266031277526;
                    end;
                end;
            end
            else
            begin
                Result := 0.015705630294769835;
            end;
        end;
    end;
end;

function local_difference_tree_149(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_trigram_ratio <= -83.499999999999986 then
    begin
        Result := -0.041034335167679112;
    end
    else
    begin
        if features.delta_path_single_segments <= -1.4999999999999998 then
        begin
            if features.delta_dict_weight <= -112271.99999999999 then
            begin
                Result := -0.018580789348703355;
            end
            else
            begin
                if features.delta_candidate_score <= 11742.000000000002 then
                begin
                    if features.same_prefix_units <= 1.5000000000000002 then
                    begin
                        if features.top_local_lm_r2 <= -8147.4999999999991 then
                        begin
                            Result := 0.063291926632009082;
                        end
                        else
                        begin
                            if features.delta_dict_weight_per_unit <= -11859.499999999998 then
                            begin
                                Result := 0.046165917771085925;
                            end
                            else
                            begin
                                Result := -0.023678974284828985;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r1 <= -2349.4999999999995 then
                        begin
                            Result := -0.0285583511032515;
                        end
                        else
                        begin
                            Result := 0.034138394460739907;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_chain_first_stage_score <= 76311.500000000015 then
                    begin
                        Result := -0.021907526429898572;
                    end
                    else
                    begin
                        Result := 0.010249232209684362;
                    end;
                end;
            end;
        end
        else
        begin
            if features.difference_span_units <= 1.5000000000000002 then
            begin
                if features.delta_local_lm_r0 <= -1173.4999999999998 then
                begin
                    if features.candidate_local_lm_r2 <= -7476.4999999999991 then
                    begin
                        Result := 0.033904918231790711;
                    end
                    else
                    begin
                        if features.delta_char_lm_per_difference <= -325.91667175292963 then
                        begin
                            Result := -0.013241945267293821;
                        end
                        else
                        begin
                            if features.top_local_lm_r0 <= -4284.4999999999991 then
                            begin
                                Result := 0.033012919506596738;
                            end
                            else
                            begin
                                Result := -0.0026338111571339628;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0005077114183183152;
                end;
            end
            else
            begin
                Result := -0.0038297596636574648;
            end;
        end;
    end;
end;

function local_difference_tree_150(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_first_stage_score <= -115127.99999999999 then
    begin
        if features.delta_char_suffix_lm_per_difference <= -777.87499999999989 then
        begin
            if features.candidate_dict_weight <= 2051.0000000000005 then
            begin
                Result := -0.022340517495753612;
            end
            else
            begin
                Result := 0.10406025391404854;
            end;
        end
        else
        begin
            if features.delta_char_lm_per_difference <= -173.90000152587888 then
            begin
                Result := -0.031721735997004667;
            end
            else
            begin
                if features.delta_candidate_score <= -4095.4999999999995 then
                begin
                    if features.same_suffix_units <= 8.5000000000000018 then
                    begin
                        Result := -0.028838449542618085;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r0 <= -4769.4999999999991 then
                        begin
                            Result := 0.042994070245293559;
                        end
                        else
                        begin
                            Result := -0.01900142907483927;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.024509993046447822;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_candidate_score <= -122419.49999999999 then
        begin
            Result := 0.030292428436526398;
        end
        else
        begin
            if features.delta_char_lm_score <= -1694.4999999999998 then
            begin
                Result := -0.017162403725317504;
            end
            else
            begin
                if features.delta_legacy_rank <= 1.5000000000000002 then
                begin
                    Result := 0.00047283649670321678;
                end
                else
                begin
                    if features.candidate_candidate_score <= 66890.500000000015 then
                    begin
                        Result := 0.040009744950087078;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r1 <= -7571.4999999999991 then
                        begin
                            if features.delta_char_lm_suffix_score <= -1276.4999999999998 then
                            begin
                                Result := 0.069415753646467751;
                            end
                            else
                            begin
                                if features.delta_local_lm_r2 <= -1052.4999999999998 then
                                begin
                                    Result := -0.017335791082005513;
                                end
                                else
                                begin
                                    Result := 0.025855877049066455;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.011676210571333483;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_151(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_boundary_count <= 6.5000000000000009 then
    begin
        if features.delta_word_lm_bonus <= -290.49999999999994 then
        begin
            if features.candidate_chain_first_stage_score <= -11099.499999999998 then
            begin
                Result := 0.022413906502310108;
            end
            else
            begin
                if features.delta_word_lm_boundary_max <= -1333.4999999999998 then
                begin
                    if features.delta_dict_weight_per_unit <= -8892.4999999999982 then
                    begin
                        if features.delta_chain_second_stage_score <= 41991966.000000007 then
                        begin
                            Result := -0.042795647524135533;
                        end
                        else
                        begin
                            Result := 0.020661030309770321;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r2 <= -6307.4999999999991 then
                        begin
                            if features.candidate_char_lm_score <= -5363.4999999999991 then
                            begin
                                Result := -0.0072695169586539455;
                            end
                            else
                            begin
                                if features.same_prefix_units <= 4.5000000000000009 then
                                begin
                                    Result := 0.085704120595591904;
                                end
                                else
                                begin
                                    Result := 0.010239262620720935;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.candidate_score_per_unit <= 13440.500000000002 then
                            begin
                                if features.delta_char_suffix_lm_per_difference <= -94.874999999999986 then
                                begin
                                    Result := -0.038682770403800727;
                                end
                                else
                                begin
                                    Result := 0.008554561138415696;
                                end;
                            end
                            else
                            begin
                                Result := 0.0439990609029874;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.027509895901632112;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_boundary_max <= -1393.4999999999998 then
            begin
                Result := -0.024498536275765204;
            end
            else
            begin
                if features.delta_word_lm_boundary_count <= -5.4999999999999991 then
                begin
                    Result := 0.03167378672698043;
                end
                else
                begin
                    Result := 0.00094425493080660774;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_word_lm_boundary_first <= 1558.5000000000002 then
        begin
            Result := -0.026816301641044347;
        end
        else
        begin
            Result := 0.021827450516257202;
        end;
    end;
end;

function local_difference_tree_152(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= -25449907.999999996 then
    begin
        if features.candidate_chain_first_stage_score <= 123310.00000000001 then
        begin
            if features.candidate_local_lm_r0 <= -9084.9999999999982 then
            begin
                Result := 0.047429586113709496;
            end
            else
            begin
                Result := -0.029679878273309347;
            end;
        end
        else
        begin
            if features.top_local_lm_r1 <= -6687.4999999999991 then
            begin
                Result := 0.078862681859068737;
            end
            else
            begin
                Result := -0.018963322042289014;
            end;
        end;
    end
    else
    begin
        if features.candidate_chain_score_gap <= -197497767.99999997 then
        begin
            if features.top_local_lm_r1 <= -4050.4999999999995 then
            begin
                if features.candidate_local_lm_r0 <= -4940.9999999999991 then
                begin
                    if features.candidate_ranker_score_gap <= -46508689.999999993 then
                    begin
                        Result := -0.0036641143158709722;
                    end
                    else
                    begin
                        Result := 0.045749372849042673;
                    end;
                end
                else
                begin
                    Result := -0.02742239435396027;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -3511.4999999999995 then
                begin
                    Result := 0.089171077836783463;
                end
                else
                begin
                    Result := -0.022070951389021886;
                end;
            end;
        end
        else
        begin
            if features.delta_path_max_segment_units <= 7.5000000000000009 then
            begin
                Result := -0.00017800383217711079;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -53324801.999999993 then
                begin
                    if features.candidate_local_lm_r0 <= -4824.4999999999991 then
                    begin
                        Result := -0.039118953158382416;
                    end
                    else
                    begin
                        Result := 0.014241271963484304;
                    end;
                end
                else
                begin
                    if features.candidate_char_lm_score <= -4077.4999999999995 then
                    begin
                        if features.candidate_chain_score_gap <= -97719983.999999985 then
                        begin
                            Result := -0.019306615722085609;
                        end
                        else
                        begin
                            Result := 0.03750632199009804;
                        end;
                    end
                    else
                    begin
                        Result := -0.035540761566145107;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_153(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_local_lm_r0 <= -4300.4999999999991 then
    begin
        Result := -0.0012283411022819078;
    end
    else
    begin
        if features.candidate_word_lm_bonus <= 839.50000000000011 then
        begin
            if features.delta_local_lm_r0 <= 856.50000000000011 then
            begin
                if features.delta_local_lm_r0 <= 267.50000000000006 then
                begin
                    if features.candidate_local_lm_r1 <= -7697.4999999999991 then
                    begin
                        Result := 0.050224232318113793;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r3 <= -5795.4999999999991 then
                        begin
                            Result := -0.018603651897668723;
                        end
                        else
                        begin
                            if features.top_local_lm_r3 <= -4816.4999999999991 then
                            begin
                                Result := 0.03814583109715794;
                            end
                            else
                            begin
                                Result := -0.005983746500119326;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight <= -201.49999999999997 then
                    begin
                        Result := 0.00068133605215183618;
                    end
                    else
                    begin
                        Result := -0.036967884518487225;
                    end;
                end;
            end
            else
            begin
                if features.candidate_ranker_score_gap <= -26175754.999999996 then
                begin
                    if features.candidate_local_lm_r3 <= -4782.4999999999991 then
                    begin
                        if features.top_local_lm_r2 <= -5814.4999999999991 then
                        begin
                            if features.candidate_local_lm_r0 <= -4192.4999999999991 then
                            begin
                                Result := 0.049341669538230201;
                            end
                            else
                            begin
                                if features.candidate_local_lm_r3 <= -6517.4999999999991 then
                                begin
                                    Result := -0.013865985085813609;
                                end
                                else
                                begin
                                    if features.top_local_lm_r1 <= -6281.4999999999991 then
                                    begin
                                        Result := 0.049114416982495024;
                                    end
                                    else
                                    begin
                                        Result := -0.0049711309581483634;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.023761738036331189;
                        end;
                    end
                    else
                    begin
                        Result := 0.047917541652346921;
                    end;
                end
                else
                begin
                    Result := 0.025290006981013899;
                end;
            end;
        end
        else
        begin
            Result := -0.039614169886008077;
        end;
    end;
end;

function local_difference_tree_154(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_trigram_ratio <= -83.499999999999986 then
    begin
        Result := -0.035402476697317317;
    end
    else
    begin
        if features.candidate_ranker_score <= 654398.50000000012 then
        begin
            if features.candidate_path_segments <= 9.5000000000000018 then
            begin
                if features.delta_char_lm_per_difference <= 62.166666030883796 then
                begin
                    if features.delta_candidate_score <= -120214.99999999999 then
                    begin
                        Result := -0.035944847546009115;
                    end
                    else
                    begin
                        if features.delta_char_lm_per_difference <= -473.41667175292963 then
                        begin
                            Result := -0.0078557322577598697;
                        end
                        else
                        begin
                            Result := 0.0012797838280803422;
                        end;
                    end;
                end
                else
                begin
                    if features.same_suffix_units <= 9.5000000000000018 then
                    begin
                        if features.top_local_lm_r1 <= -5906.4999999999991 then
                        begin
                            if features.delta_chain_score_gap <= -93631183.999999985 then
                            begin
                                if features.candidate_chain_score_gap <= -135685823.99999997 then
                                begin
                                    Result := -0.029616405951389712;
                                end
                                else
                                begin
                                    Result := 0.037613371268876414;
                                end;
                            end
                            else
                            begin
                                Result := -0.017801644646465303;
                            end;
                        end
                        else
                        begin
                            Result := 0.033817773809458003;
                        end;
                    end
                    else
                    begin
                        Result := 0.056577713384246997;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -7608.4999999999991 then
                begin
                    if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.043286998213558227;
                    end
                    else
                    begin
                        Result := -0.024520763009974286;
                    end;
                end
                else
                begin
                    Result := -0.028702876038415912;
                end;
            end;
        end
        else
        begin
            if features.delta_chain_first_stage_score <= -146166.99999999997 then
            begin
                Result := -0.027862532880791675;
            end
            else
            begin
                if features.candidate_candidate_score <= -17760.499999999996 then
                begin
                    Result := 0.03686001660731162;
                end
                else
                begin
                    Result := 0.0026854294161388539;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_155(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.different_units <= 4.5000000000000009 then
    begin
        if features.delta_word_lm_trigram_ratio <= -30.999999999999996 then
        begin
            Result := -0.031582925134547399;
        end
        else
        begin
            if features.candidate_word_lm_trigram_ratio <= 173.50000000000003 then
            begin
                if features.candidate_word_lm_supported_ratio <= 639.00000000000011 then
                begin
                    if features.candidate_char_lm_score <= -3164.4999999999995 then
                    begin
                        if features.top_local_lm_r3 <= -4902.4999999999991 then
                        begin
                            if features.delta_char_suffix_lm_per_difference <= -925.24999999999989 then
                            begin
                                Result := 0.017291236806415918;
                            end
                            else
                            begin
                                if features.delta_char_lm_per_difference <= -481.83332824707026 then
                                begin
                                    if features.delta_local_lm_r1 <= -1456.4999999999998 then
                                    begin
                                        if features.delta_local_lm_r2 <= -1397.4999999999998 then
                                        begin
                                            Result := -0.0085372259915088775;
                                        end
                                        else
                                        begin
                                            Result := 0.020064181716210019;
                                        end;
                                    end
                                    else
                                    begin
                                        if features.delta_local_lm_r0 <= -1737.4999999999998 then
                                        begin
                                            Result := 0.018310042295581662;
                                        end
                                        else
                                        begin
                                            Result := -0.018771700185414544;
                                        end;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.0019393285954912665;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.0074982590928302289;
                        end;
                    end
                    else
                    begin
                        Result := 0.01552791081183862;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight_per_unit <= 9572.5000000000018 then
                    begin
                        Result := -0.030763696022978709;
                    end
                    else
                    begin
                        Result := 0.034065020078285567;
                    end;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -6009.4999999999991 then
                begin
                    if features.candidate_local_lm_r3 <= -6657.4999999999991 then
                    begin
                        Result := -0.0044605864364375622;
                    end
                    else
                    begin
                        Result := 0.06033418764392369;
                    end;
                end
                else
                begin
                    Result := -0.018783568973053475;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.032061322632994813;
    end;
end;

function local_difference_tree_156(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.different_units <= 4.5000000000000009 then
    begin
        if features.candidate_local_lm_r0 <= -8652.4999999999982 then
        begin
            if features.candidate_chain_first_stage_score <= 88530.000000000015 then
            begin
                Result := 0.032915174812699698;
            end
            else
            begin
                Result := -0.020443104115563934;
            end;
        end
        else
        begin
            if features.candidate_local_lm_r1 <= -8542.4999999999982 then
            begin
                if features.candidate_score_per_unit <= 10986.500000000002 then
                begin
                    if features.delta_path_single_segments <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0066170237390518619;
                    end
                    else
                    begin
                        Result := -0.035149513913393375;
                    end;
                end
                else
                begin
                    if features.candidate_score_per_unit <= 11408.000000000002 then
                    begin
                        Result := 0.039765889587017787;
                    end
                    else
                    begin
                        if features.top_local_lm_r1 <= -7950.4999999999991 then
                        begin
                            Result := -0.032969403687179197;
                        end
                        else
                        begin
                            if features.candidate_candidate_score <= 118360.00000000001 then
                            begin
                                Result := -0.037664882893890937;
                            end
                            else
                            begin
                                if features.same_prefix_units <= 3.5000000000000004 then
                                begin
                                    Result := -0.0014803010181320562;
                                end
                                else
                                begin
                                    Result := 0.039651704904450739;
                                end;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r1 <= -8421.4999999999982 then
                begin
                    if features.candidate_chain_score_gap <= -35894415.999999993 then
                    begin
                        Result := -0.017763345609098372;
                    end
                    else
                    begin
                        if features.candidate_dict_weight_per_unit <= 7814.0000000000009 then
                        begin
                            Result := -0.011679709204269719;
                        end
                        else
                        begin
                            Result := 0.053045598709487697;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r2 <= -8868.4999999999982 then
                    begin
                        Result := -0.030146158612405306;
                    end
                    else
                    begin
                        Result := -5.5584593708815287E-05;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.03334339509441106;
    end;
end;

function local_difference_tree_157(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_trigram_ratio <= -83.499999999999986 then
    begin
        Result := -0.040948093330916369;
    end
    else
    begin
        if features.delta_path_single_segments <= -1.4999999999999998 then
        begin
            if features.same_suffix_units <= 1.0000000180025095E-35 then
            begin
                if features.candidate_char_lm_suffix_score <= -7068.4999999999991 then
                begin
                    Result := 0.073266972214439147;
                end
                else
                begin
                    Result := 0.0045755281654707193;
                end;
            end
            else
            begin
                if features.delta_dict_weight_per_unit <= -11359.499999999998 then
                begin
                    Result := -0.019824513113293786;
                end
                else
                begin
                    if features.delta_char_lm_score <= -754.49999999999989 then
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -835.41665649414051 then
                        begin
                            if features.top_local_lm_r1 <= -5714.4999999999991 then
                            begin
                                Result := 0.054799158069067821;
                            end
                            else
                            begin
                                Result := -0.0177646896489576;
                            end;
                        end
                        else
                        begin
                            Result := -0.025806747291932886;
                        end;
                    end
                    else
                    begin
                        if features.candidate_word_lm_boundary_first <= 1411.5000000000002 then
                        begin
                            Result := 0.016830709689581187;
                        end
                        else
                        begin
                            Result := -0.039820319275653188;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.candidate_char_lm_score <= -4196.4999999999991 then
            begin
                if features.candidate_char_lm_score <= -4520.4999999999991 then
                begin
                    Result := -0.00051946628418958138;
                end
                else
                begin
                    Result := -0.011658240090301744;
                end;
            end
            else
            begin
                if features.delta_chain_score_gap <= -134281639.99999997 then
                begin
                    if features.delta_chain_first_stage_score <= -229.49999999999997 then
                    begin
                        if features.delta_char_suffix_lm_per_difference <= -174.83333587646482 then
                        begin
                            Result := 0.047432781388933691;
                        end
                        else
                        begin
                            Result := 0.0058224081747687275;
                        end;
                    end
                    else
                    begin
                        Result := -0.036074499818745227;
                    end;
                end
                else
                begin
                    Result := 0.0022842308352454782;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_158(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.same_prefix_units <= 12.500000000000002 then
    begin
        if features.delta_candidate_score <= 7555.0000000000009 then
        begin
            if features.candidate_local_lm_r1 <= -6092.4999999999991 then
            begin
                Result := -0.0024969788975111339;
            end
            else
            begin
                Result := 0.0050455686360806893;
            end;
        end
        else
        begin
            if features.delta_candidate_score <= 28927.500000000004 then
            begin
                if features.candidate_score_per_unit <= 9971.5000000000018 then
                begin
                    Result := 0.00016944365836243615;
                end
                else
                begin
                    Result := 0.023971417532722625;
                end;
            end
            else
            begin
                if features.candidate_path_single_segments <= 1.0000000180025095E-35 then
                begin
                    if features.delta_chain_second_stage_score <= -123561891.99999999 then
                    begin
                        Result := -0.037988676734586779;
                    end
                    else
                    begin
                        Result := 0.026950601618560135;
                    end;
                end
                else
                begin
                    if features.candidate_chain_first_stage_score <= 90035.000000000015 then
                    begin
                        if features.delta_path_segments <= 3.5000000000000004 then
                        begin
                            Result := -0.038314986582624784;
                        end
                        else
                        begin
                            Result := 0.032273039419853086;
                        end;
                    end
                    else
                    begin
                        Result := -0.0013735618309591291;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -5180.4999999999991 then
        begin
            if features.candidate_char_lm_score <= -6107.4999999999991 then
            begin
                Result := 0.0039267450170070873;
            end
            else
            begin
                Result := -0.045615311194242371;
            end;
        end
        else
        begin
            if features.candidate_chain_first_stage_score <= 144683.00000000003 then
            begin
                Result := -0.02987367267652544;
            end
            else
            begin
                if features.candidate_candidate_score <= 154355.50000000003 then
                begin
                    Result := 0.052506910863659918;
                end
                else
                begin
                    if features.candidate_word_lm_boundary_first <= 1087.5000000000002 then
                    begin
                        Result := 0.014158655056513541;
                    end
                    else
                    begin
                        Result := -0.038495375628020481;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_159(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.036516491886032093;
    end
    else
    begin
        if features.candidate_dict_weight_per_unit <= 29415.000000000004 then
        begin
            if features.candidate_local_lm_r1 <= -5485.4999999999991 then
            begin
                if features.top_local_lm_r1 <= -4272.4999999999991 then
                begin
                    Result := -0.00063555939564831148;
                end
                else
                begin
                    Result := -0.026803146542083392;
                end;
            end
            else
            begin
                if features.top_local_lm_r2 <= -6144.4999999999991 then
                begin
                    Result := 0.019584613070466664;
                end
                else
                begin
                    if features.delta_dict_weight_per_unit <= 12.500000000000002 then
                    begin
                        if features.candidate_local_lm_r3 <= -6328.4999999999991 then
                        begin
                            Result := -0.03472427263372569;
                        end
                        else
                        begin
                            if features.candidate_candidate_score <= 120566.50000000001 then
                            begin
                                Result := -0.0016265701546837278;
                            end
                            else
                            begin
                                if features.candidate_candidate_score <= 209151.00000000003 then
                                begin
                                    Result := 0.029935709629357165;
                                end
                                else
                                begin
                                    Result := -0.033457469492706018;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.01347750298647501;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_score_per_unit <= -4290.9999999999991 then
            begin
                Result := -0.032983273354949064;
            end
            else
            begin
                if features.delta_local_lm_r3 <= -541.49999999999989 then
                begin
                    if features.delta_char_suffix_lm_per_difference <= -628.24999999999989 then
                    begin
                        if features.candidate_local_lm_r3 <= -7683.4999999999991 then
                        begin
                            Result := -0.032892456667583322;
                        end
                        else
                        begin
                            if features.top_local_lm_r1 <= -4309.4999999999991 then
                            begin
                                Result := 0.065693338167560955;
                            end
                            else
                            begin
                                Result := -0.026026906483930592;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.030443615874019364;
                    end;
                end
                else
                begin
                    Result := 0.049028282763662841;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_160(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_local_lm_r3 <= -2617.4999999999995 then
    begin
        Result := -0.034554231249685492;
    end
    else
    begin
        if features.delta_local_lm_r2 <= -2969.4999999999995 then
        begin
            if features.delta_local_lm_r1 <= -3398.4999999999995 then
            begin
                Result := 0.083938262245545042;
            end
            else
            begin
                Result := -0.019069911058692587;
            end;
        end
        else
        begin
            if features.candidate_candidate_score <= 303251.50000000006 then
            begin
                if features.delta_path_single_segments <= -1.4999999999999998 then
                begin
                    if features.delta_dict_weight_per_unit <= -11359.499999999998 then
                    begin
                        if features.candidate_local_lm_r1 <= -5485.4999999999991 then
                        begin
                            Result := -0.038324067621269164;
                        end
                        else
                        begin
                            Result := 0.029814613807940975;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r2 <= -7865.4999999999991 then
                        begin
                            Result := 0.030808099489473301;
                        end
                        else
                        begin
                            if features.delta_local_lm_r1 <= 37.500000000000007 then
                            begin
                                if features.delta_local_lm_r2 <= -592.49999999999989 then
                                begin
                                    if features.candidate_ranker_score <= -19322053.999999996 then
                                    begin
                                        Result := -0.03436245893732711;
                                    end
                                    else
                                    begin
                                        Result := 0.012734180389037375;
                                    end;
                                end
                                else
                                begin
                                    if features.candidate_ranker_score_gap <= -35838083.999999993 then
                                    begin
                                        Result := 0.022540325937936711;
                                    end
                                    else
                                    begin
                                        Result := -0.032747867550782427;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.030301128150920911;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0010479334590465137;
                end;
            end
            else
            begin
                if features.delta_path_max_segment_units <= 1.5000000000000002 then
                begin
                    Result := -0.0033009989931943986;
                end
                else
                begin
                    if features.max_different_run <= 1.5000000000000002 then
                    begin
                        Result := 0.012305123347731284;
                    end
                    else
                    begin
                        Result := 0.068435927801525215;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_161(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_per_difference <= 341.50000000000006 then
    begin
        if features.delta_char_suffix_lm_per_difference <= 274.50000000000006 then
        begin
            if features.candidate_local_lm_r0 <= -3909.4999999999995 then
            begin
                if features.delta_path_single_segments <= 1.0000000180025095E-35 then
                begin
                    Result := 0.0011702184038317636;
                end
                else
                begin
                    if features.same_prefix_units <= 3.5000000000000004 then
                    begin
                        Result := 0.0038686631582308287;
                    end
                    else
                    begin
                        Result := -0.012341136032318107;
                    end;
                end;
            end
            else
            begin
                if features.same_prefix_units <= 2.5000000000000004 then
                begin
                    if features.delta_dict_weight_per_unit <= 4370.0000000000009 then
                    begin
                        Result := -0.0301101822895034;
                    end
                    else
                    begin
                        Result := 0.013256036400347081;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= 856.50000000000011 then
                    begin
                        if features.candidate_word_lm_bonus <= 397.50000000000006 then
                        begin
                            if features.candidate_char_lm_score <= -6161.4999999999991 then
                            begin
                                Result := 0.024293332532492624;
                            end
                            else
                            begin
                                Result := -0.043548128201008479;
                            end;
                        end
                        else
                        begin
                            if features.delta_local_lm_r3 <= -170.49999999999997 then
                            begin
                                Result := 0.045530528481018843;
                            end
                            else
                            begin
                                Result := -0.017283612146918457;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.candidate_dict_weight <= 123348.50000000001 then
                        begin
                            Result := 0.038158017370482772;
                        end
                        else
                        begin
                            if features.candidate_chain_score_gap <= -8314648.4999999991 then
                            begin
                                Result := -0.03378233067545363;
                            end
                            else
                            begin
                                Result := 0.032630294250811875;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.021891070609478896;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -4478.4999999999991 then
        begin
            Result := -0.031329244661534521;
        end
        else
        begin
            Result := 0.012092614934070794;
        end;
    end;
end;

function local_difference_tree_162(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score_gap <= -22190821.999999996 then
    begin
        if features.delta_chain_first_stage_score <= 283.00000000000006 then
        begin
            if features.top_local_lm_r0 <= -4072.4999999999995 then
            begin
                Result := 0.0020860190153652522;
            end
            else
            begin
                if features.delta_char_lm_score <= 15.500000000000002 then
                begin
                    if features.candidate_local_lm_r0 <= -5180.4999999999991 then
                    begin
                        Result := -0.028643519371999097;
                    end
                    else
                    begin
                        if features.top_local_lm_r1 <= -5624.4999999999991 then
                        begin
                            Result := 0.0073163844667824413;
                        end
                        else
                        begin
                            Result := -0.024208196670167964;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.022031221156591743;
                end;
            end;
        end
        else
        begin
            if features.candidate_local_lm_r1 <= -6486.4999999999991 then
            begin
                if features.candidate_dict_weight <= -21232.999999999996 then
                begin
                    Result := 0.055342329668202322;
                end
                else
                begin
                    if features.candidate_dict_weight_per_unit <= 10986.500000000002 then
                    begin
                        if features.candidate_text_units <= 7.5000000000000009 then
                        begin
                            Result := 0.026980191071490918;
                        end
                        else
                        begin
                            if features.delta_word_lm_boundary_count <= -1.0000000180025095E-35 then
                            begin
                                Result := 0.0049003596404288445;
                            end
                            else
                            begin
                                Result := -0.026065851625759077;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_score_per_unit <= 2847.5000000000005 then
                        begin
                            if features.delta_word_lm_per_boundary <= -8.6515154838561994 then
                            begin
                                Result := 0.061468742185460244;
                            end
                            else
                            begin
                                if features.delta_word_lm_supported_ratio <= 47.000000000000007 then
                                begin
                                    Result := -0.0095050710638030014;
                                end
                                else
                                begin
                                    Result := 0.051119361628971072;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.010893581708975917;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.024763538417535993;
            end;
        end;
    end
    else
    begin
        Result := 0.005703398944212801;
    end;
end;

function local_difference_tree_163(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.same_prefix_units <= 1.0000000180025095E-35 then
    begin
        if features.top_local_lm_r0 <= -4136.4999999999991 then
        begin
            if features.delta_char_lm_per_difference <= -539.83334350585926 then
            begin
                Result := -0.035147436451890064;
            end
            else
            begin
                if features.delta_char_suffix_lm_per_difference <= -302.83332824707026 then
                begin
                    if features.candidate_dict_weight_per_unit <= 11034.000000000002 then
                    begin
                        Result := 0.059205534728701069;
                    end
                    else
                    begin
                        Result := -0.010829909808140688;
                    end;
                end
                else
                begin
                    Result := -0.011525142915634296;
                end;
            end;
        end
        else
        begin
            if features.delta_chain_first_stage_score <= 38884.500000000007 then
            begin
                Result := -0.00023710582127146589;
            end
            else
            begin
                Result := 0.090262945802410663;
            end;
        end;
    end
    else
    begin
        if features.different_units <= 2.5000000000000004 then
        begin
            if features.delta_path_single_segments <= -1.4999999999999998 then
            begin
                Result := 0.010981821571925539;
            end
            else
            begin
                Result := 0.00076277608862158907;
            end;
        end
        else
        begin
            if features.delta_dict_weight <= 28061.500000000004 then
            begin
                if features.delta_path_max_segment_units <= -1.0000000180025095E-35 then
                begin
                    Result := -0.041596422744009723;
                end
                else
                begin
                    if features.delta_word_lm_supported_ratio <= -214.49999999999997 then
                    begin
                        Result := -0.030387574173118787;
                    end
                    else
                    begin
                        if features.top_local_lm_r2 <= -6695.4999999999991 then
                        begin
                            if features.top_local_lm_r3 <= -6337.4999999999991 then
                            begin
                                if features.candidate_local_lm_r0 <= -8189.9999999999991 then
                                begin
                                    Result := 0.045462234718233636;
                                end
                                else
                                begin
                                    Result := 0.0029823124076646997;
                                end;
                            end
                            else
                            begin
                                Result := 0.077697995124113212;
                            end;
                        end
                        else
                        begin
                            Result := -0.0046326378250343735;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.029686661701400722;
            end;
        end;
    end;
end;

function local_difference_tree_164(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_per_difference <= 341.50000000000006 then
    begin
        if features.delta_path_single_segments <= 1.0000000180025095E-35 then
        begin
            Result := 0.0021836868519613554;
        end
        else
        begin
            if features.delta_path_max_segment_units <= -5.4999999999999991 then
            begin
                Result := 0.022307962821515516;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -3997.4999999999995 then
                begin
                    if features.same_prefix_units <= 3.5000000000000004 then
                    begin
                        if features.delta_word_lm_boundary_first <= 1405.5000000000002 then
                        begin
                            if features.candidate_dict_weight_per_unit <= 29415.000000000004 then
                            begin
                                if features.delta_char_lm_per_difference <= -108.41666793823241 then
                                begin
                                    if features.candidate_local_lm_r2 <= -5685.4999999999991 then
                                    begin
                                        Result := -0.0067062688941141495;
                                    end
                                    else
                                    begin
                                        Result := -0.042535534468950788;
                                    end;
                                end
                                else
                                begin
                                    if features.candidate_local_lm_r2 <= -7197.4999999999991 then
                                    begin
                                        Result := -0.030674411480122465;
                                    end
                                    else
                                    begin
                                        if features.delta_chain_second_stage_score <= -54008995.999999993 then
                                        begin
                                            if features.candidate_char_lm_suffix_score <= -5648.4999999999991 then
                                            begin
                                                Result := 0.059619600156041175;
                                            end
                                            else
                                            begin
                                                Result := -0.001660630869479445;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := -0.0093280474313607708;
                                        end;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.029502063397620969;
                            end;
                        end
                        else
                        begin
                            Result := 0.053939381500452743;
                        end;
                    end
                    else
                    begin
                        Result := -0.013678082498419666;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r3 <= -6492.4999999999991 then
                    begin
                        Result := -0.014626820461161974;
                    end
                    else
                    begin
                        if features.candidate_char_lm_suffix_score <= -4932.4999999999991 then
                        begin
                            Result := 0.050226450264303731;
                        end
                        else
                        begin
                            Result := -0.0096681302252172151;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.017005964967267587;
    end;
end;

function local_difference_tree_165(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.different_units <= 3.5000000000000004 then
    begin
        if features.delta_dict_weight_per_unit <= -22.499999999999996 then
        begin
            if features.delta_score_per_unit <= 84.500000000000014 then
            begin
                if features.delta_char_lm_per_difference <= -325.91667175292963 then
                begin
                    if features.candidate_candidate_score <= 103749.00000000001 then
                    begin
                        if features.delta_path_segments <= 1.0000000180025095E-35 then
                        begin
                            if features.same_suffix_units <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.067295379570431094;
                            end
                            else
                            begin
                                Result := -0.00088306299337293653;
                            end;
                        end
                        else
                        begin
                            Result := -0.032985750795670433;
                        end;
                    end
                    else
                    begin
                        Result := -0.033232300740859283;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= -2072.4999999999995 then
                    begin
                        Result := -0.026505392091376995;
                    end
                    else
                    begin
                        if features.delta_word_lm_per_boundary <= -24.816666603088375 then
                        begin
                            if features.delta_chain_first_stage_score <= 60168.500000000007 then
                            begin
                                Result := -0.020761259602662615;
                            end
                            else
                            begin
                                Result := 0.04164930433879676;
                            end;
                        end
                        else
                        begin
                            Result := 0.0027226119737712583;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.016364398506352046;
            end;
        end
        else
        begin
            if features.candidate_ranker_score <= -19021329.999999996 then
            begin
                if features.delta_local_lm_r0 <= 1150.5000000000002 then
                begin
                    if features.candidate_local_lm_r3 <= -5531.4999999999991 then
                    begin
                        Result := -0.00058087639668337769;
                    end
                    else
                    begin
                        if features.same_prefix_units <= 8.5000000000000018 then
                        begin
                            Result := 0.085212376159348902;
                        end
                        else
                        begin
                            Result := -0.021685211272319746;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.071283987300555546;
                end;
            end
            else
            begin
                Result := 0.001699264892426885;
            end;
        end;
    end
    else
    begin
        Result := -0.017363072630281817;
    end;
end;

function local_difference_tree_166(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.top_local_lm_r0 <= -4090.4999999999995 then
    begin
        if features.candidate_text_units <= 10.500000000000002 then
        begin
            if features.delta_char_lm_per_difference <= 11.125000000000002 then
            begin
                if features.candidate_chain_first_stage_score <= 112080.00000000001 then
                begin
                    Result := 0.0037418474974977699;
                end
                else
                begin
                    if features.candidate_local_lm_r2 <= -5685.4999999999991 then
                    begin
                        Result := 0.027253159414493539;
                    end
                    else
                    begin
                        Result := -0.0092072129718608498;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r1 <= -6228.4999999999991 then
                begin
                    Result := -0.018613853716259177;
                end
                else
                begin
                    Result := 0.0098390502475965164;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_score <= -265.49999999999994 then
            begin
                Result := -0.0095990401491442695;
            end
            else
            begin
                if features.candidate_word_lm_boundary_last <= 1552.5000000000002 then
                begin
                    if features.candidate_path_single_segments <= 4.5000000000000009 then
                    begin
                        if features.candidate_chain_first_stage_score <= -1.0000000180025095E-35 then
                        begin
                            if features.same_suffix_units <= 9.5000000000000018 then
                            begin
                                Result := 0.0043559511537906706;
                            end
                            else
                            begin
                                Result := 0.059007412050109141;
                            end;
                        end
                        else
                        begin
                            if features.candidate_word_lm_boundary_last <= 1291.5000000000002 then
                            begin
                                Result := -0.0043391192908479072;
                            end
                            else
                            begin
                                Result := -0.03032344093836576;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.019460580127127182;
                    end;
                end
                else
                begin
                    Result := 0.018145462757828502;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -783.49999999999989 then
        begin
            Result := -0.032177052052121888;
        end
        else
        begin
            if features.candidate_ranker_score <= -1861963.9999999998 then
            begin
                Result := -0.012529891153739653;
            end
            else
            begin
                Result := 0.0057350317832798739;
            end;
        end;
    end;
end;

function local_difference_tree_167(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_legacy_rank <= 1.5000000000000002 then
    begin
        Result := -0.00032496186221839799;
    end
    else
    begin
        if features.top_local_lm_r1 <= -6613.4999999999991 then
        begin
            if features.top_local_lm_r3 <= -5654.4999999999991 then
            begin
                if features.delta_chain_first_stage_score <= -55958.499999999993 then
                begin
                    Result := -0.027403195826552023;
                end
                else
                begin
                    if features.candidate_dict_weight <= 151949.50000000003 then
                    begin
                        if features.delta_chain_first_stage_score <= -2936.9999999999995 then
                        begin
                            Result := 0.069387309515679896;
                        end
                        else
                        begin
                            Result := 0.020581921470987967;
                        end;
                    end
                    else
                    begin
                        Result := -0.027077919838512005;
                    end;
                end;
            end
            else
            begin
                if features.candidate_word_lm_boundary_max <= 1330.5000000000002 then
                begin
                    Result := 0.10777178720666214;
                end
                else
                begin
                    Result := -0.0073963431017819541;
                end;
            end;
        end
        else
        begin
            if features.candidate_candidate_score <= 66890.500000000015 then
            begin
                if features.delta_candidate_score <= -94638.499999999985 then
                begin
                    Result := -0.028790445927791512;
                end
                else
                begin
                    if features.candidate_char_lm_suffix_score <= -6565.4999999999991 then
                    begin
                        Result := -0.010436041419775409;
                    end
                    else
                    begin
                        Result := 0.05388292062898236;
                    end;
                end;
            end
            else
            begin
                if features.delta_path_max_segment_units <= -7.4999999999999991 then
                begin
                    Result := 0.045378080258518909;
                end
                else
                begin
                    if features.candidate_char_lm_suffix_score <= -8206.4999999999982 then
                    begin
                        if features.candidate_char_lm_suffix_score <= -8306.4999999999982 then
                        begin
                            Result := -0.0058398578463695876;
                        end
                        else
                        begin
                            Result := 0.10993069351502689;
                        end;
                    end
                    else
                    begin
                        if features.candidate_chain_first_stage_score <= 150876.00000000003 then
                        begin
                            Result := -0.025004376673439067;
                        end
                        else
                        begin
                            Result := 0.013459764216985175;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_168(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.top_local_lm_r1 <= -4740.4999999999991 then
    begin
        if features.same_suffix_units <= 16.500000000000004 then
        begin
            if features.candidate_local_lm_r1 <= -5099.4999999999991 then
            begin
                if features.delta_dict_weight_per_unit <= 11348.500000000002 then
                begin
                    Result := -0.0006905270640483051;
                end
                else
                begin
                    Result := 0.0084912081103696718;
                end;
            end
            else
            begin
                if features.candidate_dict_weight <= 141400.00000000003 then
                begin
                    Result := 0.025494479699001597;
                end
                else
                begin
                    Result := -0.017756767791555206;
                end;
            end;
        end
        else
        begin
            Result := -0.024234584505496246;
        end;
    end
    else
    begin
        if features.delta_candidate_score <= -127.49999999999999 then
        begin
            if features.delta_dict_weight_per_unit <= -18.499999999999996 then
            begin
                if features.top_local_lm_r0 <= -5199.4999999999991 then
                begin
                    if features.delta_char_lm_score <= 126.50000000000001 then
                    begin
                        Result := -0.046418426950859175;
                    end
                    else
                    begin
                        Result := 0.012518555747073253;
                    end;
                end
                else
                begin
                    if features.candidate_path_single_segments <= 1.5000000000000002 then
                    begin
                        if features.top_local_lm_r3 <= -4460.4999999999991 then
                        begin
                            if features.delta_candidate_score <= -425.49999999999994 then
                            begin
                                Result := -0.040486146462137072;
                            end
                            else
                            begin
                                Result := 0.037532668464895849;
                            end;
                        end
                        else
                        begin
                            Result := 0.064375879731178129;
                        end;
                    end
                    else
                    begin
                        Result := -0.015160045388686221;
                    end;
                end;
            end
            else
            begin
                Result := 0.015093126051839153;
            end;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -5706.4999999999991 then
            begin
                if features.candidate_local_lm_r2 <= -6322.4999999999991 then
                begin
                    Result := -0.018709375372472407;
                end
                else
                begin
                    Result := 0.037314076137154456;
                end;
            end
            else
            begin
                Result := -0.021090617469527558;
            end;
        end;
    end;
end;

function local_difference_tree_169(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_ranker_score <= 274528.50000000006 then
    begin
        if features.top_local_lm_r2 <= -4683.4999999999991 then
        begin
            if features.candidate_local_lm_r3 <= -5488.4999999999991 then
            begin
                if features.delta_local_lm_r3 <= -2095.4999999999995 then
                begin
                    if features.delta_candidate_score <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.011270917044848915;
                    end
                    else
                    begin
                        Result := 0.048495534830633118;
                    end;
                end
                else
                begin
                    Result := -0.0034175736136762241;
                end;
            end
            else
            begin
                if features.delta_word_lm_strong_ratio <= 96.000000000000014 then
                begin
                    if features.candidate_ranker_score <= -18849153.999999996 then
                    begin
                        if features.same_prefix_units <= 2.5000000000000004 then
                        begin
                            Result := 0.071266720593525887;
                        end
                        else
                        begin
                            Result := 0.00071238962089886586;
                        end;
                    end
                    else
                    begin
                        if features.candidate_ranker_score_gap <= -35838083.999999993 then
                        begin
                            Result := -0.0092691539119385997;
                        end
                        else
                        begin
                            if features.top_local_lm_r3 <= -4690.4999999999991 then
                            begin
                                Result := 0.02672123374148009;
                            end
                            else
                            begin
                                Result := -0.0063880578238337598;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.037394552279929098;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_suffix_score <= -697.49999999999989 then
            begin
                Result := -0.036255996293935;
            end
            else
            begin
                if features.delta_path_max_segment_units <= -1.4999999999999998 then
                begin
                    Result := 0.042555270976462972;
                end
                else
                begin
                    if features.candidate_dict_weight <= 35425.500000000007 then
                    begin
                        Result := 0.013459392664221531;
                    end
                    else
                    begin
                        if features.delta_word_lm_per_boundary <= -43.309522628784173 then
                        begin
                            Result := 0.0079700477696182902;
                        end
                        else
                        begin
                            Result := -0.033586964625923678;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.0021722406033605384;
    end;
end;

function local_difference_tree_170(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_trigram_ratio <= -83.499999999999986 then
    begin
        Result := -0.033969266233982019;
    end
    else
    begin
        if features.candidate_chain_second_stage_score <= 79065016.000000015 then
        begin
            Result := -0.0011381892403618183;
        end
        else
        begin
            if features.delta_local_lm_r0 <= -1737.4999999999998 then
            begin
                if features.delta_word_lm_boundary_max <= -1165.4999999999998 then
                begin
                    Result := 0.032262557598270132;
                end
                else
                begin
                    Result := -0.026041954576307442;
                end;
            end
            else
            begin
                if features.delta_local_lm_r2 <= 68.500000000000014 then
                begin
                    if features.candidate_char_lm_suffix_score <= -6152.4999999999991 then
                    begin
                        Result := 0.046637464906894917;
                    end
                    else
                    begin
                        if features.delta_candidate_score <= 119779.50000000001 then
                        begin
                            if features.delta_word_lm_per_boundary <= 54.699998855590827 then
                            begin
                                if features.delta_char_suffix_lm_per_difference <= -432.89999389648432 then
                                begin
                                    Result := 0.028430416208383092;
                                end
                                else
                                begin
                                    if features.candidate_local_lm_r0 <= -5162.4999999999991 then
                                    begin
                                        if features.delta_local_lm_r0 <= -765.49999999999989 then
                                        begin
                                            Result := -0.022237166126996284;
                                        end
                                        else
                                        begin
                                            if features.delta_local_lm_r1 <= -57.499999999999993 then
                                            begin
                                                Result := -0.0033475510268081844;
                                            end
                                            else
                                            begin
                                                Result := 0.029797819516290156;
                                            end;
                                        end;
                                    end
                                    else
                                    begin
                                        if features.baseline_abstain_score <= 85067096.000000015 then
                                        begin
                                            Result := 0.01603042183055145;
                                        end
                                        else
                                        begin
                                            Result := -0.022919132415590932;
                                        end;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.010526101925787956;
                            end;
                        end
                        else
                        begin
                            Result := 0.046840454836388344;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= -979.49999999999989 then
                    begin
                        Result := 0.026259527924260815;
                    end
                    else
                    begin
                        Result := -0.018985660223565477;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_171(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_chain_rank <= 4.5000000000000009 then
    begin
        if features.delta_word_lm_boundary_first <= -1141.4999999999998 then
        begin
            if features.top_local_lm_r2 <= -6921.4999999999991 then
            begin
                if features.candidate_local_lm_r1 <= -6603.4999999999991 then
                begin
                    if features.candidate_char_lm_suffix_score <= -6656.4999999999991 then
                    begin
                        Result := -0.012111941538735642;
                    end
                    else
                    begin
                        Result := 0.07127281985733229;
                    end;
                end
                else
                begin
                    Result := -0.017492588595671356;
                end;
            end
            else
            begin
                if features.delta_word_lm_supported_ratio <= -92.999999999999986 then
                begin
                    Result := -0.035061320379898515;
                end
                else
                begin
                    Result := 0.042458539930235954;
                end;
            end;
        end
        else
        begin
            if features.delta_word_lm_boundary_first <= -1114.4999999999998 then
            begin
                Result := 0.053744661185289262;
            end
            else
            begin
                if features.candidate_word_lm_boundary_count <= 15.500000000000002 then
                begin
                    if features.same_suffix_units <= 16.500000000000004 then
                    begin
                        if features.candidate_text_units <= 15.500000000000002 then
                        begin
                            Result := 0.00021690459986992467;
                        end
                        else
                        begin
                            if features.candidate_local_lm_r0 <= -7439.4999999999991 then
                            begin
                                Result := -0.037177928462787037;
                            end
                            else
                            begin
                                if features.top_local_lm_r1 <= -6830.4999999999991 then
                                begin
                                    if features.top_local_lm_r0 <= -5670.4999999999991 then
                                    begin
                                        Result := 0.047281317046628323;
                                    end
                                    else
                                    begin
                                        Result := 0.0060056507588584062;
                                    end;
                                end
                                else
                                begin
                                    if features.delta_char_lm_score <= -501.49999999999994 then
                                    begin
                                        Result := -0.037329204914243477;
                                    end
                                    else
                                    begin
                                        Result := 0.0057437528126511664;
                                    end;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.025470823142047735;
                    end;
                end
                else
                begin
                    Result := 0.040312310489565233;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.035401516737737761;
    end;
end;

function local_difference_tree_172(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_rank <= 3.5000000000000004 then
    begin
        if features.delta_chain_score_gap <= -187927871.99999997 then
        begin
            if features.candidate_local_lm_r2 <= -6210.4999999999991 then
            begin
                if features.delta_word_lm_bonus <= -1.0000000180025095E-35 then
                begin
                    Result := -0.027145407967047147;
                end
                else
                begin
                    if features.candidate_chain_first_stage_score <= 68644.500000000015 then
                    begin
                        if features.candidate_chain_score_gap <= -197497767.99999997 then
                        begin
                            if features.candidate_word_lm_supported_ratio <= 240.00000000000003 then
                            begin
                                Result := 0.022537571890601144;
                            end
                            else
                            begin
                                Result := 0.090359419106047612;
                            end;
                        end
                        else
                        begin
                            Result := -0.029511065165148606;
                        end;
                    end
                    else
                    begin
                        if features.candidate_chain_first_stage_score <= 117408.00000000001 then
                        begin
                            Result := -0.036649452780597898;
                        end
                        else
                        begin
                            if features.candidate_score_per_unit <= 10509.500000000002 then
                            begin
                                Result := 0.081603335546367117;
                            end
                            else
                            begin
                                Result := -0.013076234296926188;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_per_difference <= -208.41666412353513 then
                begin
                    Result := -0.0032247812238495872;
                end
                else
                begin
                    if features.candidate_word_lm_bonus <= 250.50000000000003 then
                    begin
                        Result := 0.0044972923541907192;
                    end
                    else
                    begin
                        Result := 0.077093454754980514;
                    end;
                end;
            end;
        end
        else
        begin
            if features.top_local_lm_r1 <= -4385.4999999999991 then
            begin
                Result := 0.00063580395277249295;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -4847.4999999999991 then
                begin
                    Result := -0.0162535520535547;
                end
                else
                begin
                    if features.delta_char_lm_per_difference <= -455.16667175292963 then
                    begin
                        Result := 0.076405289121156475;
                    end
                    else
                    begin
                        Result := 0.0;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.032952530540636613;
    end;
end;

function local_difference_tree_173(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -2059.4999999999995 then
    begin
        Result := -0.024724327768383597;
    end
    else
    begin
        if features.delta_chain_first_stage_score <= 645.50000000000011 then
        begin
            if features.delta_score_per_unit <= 686.00000000000011 then
            begin
                if features.candidate_local_lm_r1 <= -5408.4999999999991 then
                begin
                    if features.candidate_word_lm_boundary_last <= 1558.5000000000002 then
                    begin
                        Result := -0.0021233240613864972;
                    end
                    else
                    begin
                        if features.delta_char_lm_per_difference <= -261.41667175292963 then
                        begin
                            Result := -0.025789543755000408;
                        end
                        else
                        begin
                            if features.candidate_dict_weight <= 175165.50000000003 then
                            begin
                                if features.candidate_word_lm_bonus <= 553.50000000000011 then
                                begin
                                    Result := 0.041398847980450154;
                                end
                                else
                                begin
                                    Result := 0.0089583433952705981;
                                end;
                            end
                            else
                            begin
                                Result := -0.0090619735783000685;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_word_lm_per_boundary <= 26.071428298950199 then
                    begin
                        Result := 0.0096639132481261443;
                    end
                    else
                    begin
                        Result := -0.0394754781227106;
                    end;
                end;
            end
            else
            begin
                if features.candidate_char_lm_suffix_score <= -7160.4999999999991 then
                begin
                    Result := 0.03290992646644357;
                end
                else
                begin
                    if features.candidate_score_per_unit <= 10241.500000000002 then
                    begin
                        Result := -0.020644397152280135;
                    end
                    else
                    begin
                        Result := 0.016152555757011435;
                    end;
                end;
            end;
        end
        else
        begin
            if features.candidate_ranker_score_gap <= -24032013.999999996 then
            begin
                if features.candidate_local_lm_r1 <= -6486.4999999999991 then
                begin
                    if features.delta_source_rule_fallback <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.047869104167638073;
                    end
                    else
                    begin
                        Result := -0.0071617256286105315;
                    end;
                end
                else
                begin
                    Result := -0.029141162741774296;
                end;
            end
            else
            begin
                Result := 0.0036092368077556241;
            end;
        end;
    end;
end;

function local_difference_tree_174(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_boundary_count <= 6.5000000000000009 then
    begin
        if features.delta_chain_first_stage_score <= 81816.000000000015 then
        begin
            if features.candidate_path_segments <= 9.5000000000000018 then
            begin
                Result := 0.00016869876346414428;
            end
            else
            begin
                if features.top_local_lm_r1 <= -7608.4999999999991 then
                begin
                    Result := 0.018989174185481749;
                end
                else
                begin
                    Result := -0.016883675317428654;
                end;
            end;
        end
        else
        begin
            if features.candidate_char_lm_score <= -6513.9999999999991 then
            begin
                Result := -0.039821693739351342;
            end
            else
            begin
                if features.top_local_lm_r3 <= -5238.4999999999991 then
                begin
                    if features.delta_chain_score_gap <= 59252326.000000007 then
                    begin
                        if features.candidate_chain_first_stage_score <= 129010.50000000001 then
                        begin
                            if features.candidate_score_per_unit <= 7818.5000000000009 then
                            begin
                                Result := 0.034176951464393389;
                            end
                            else
                            begin
                                if features.delta_dict_weight_per_unit <= 9572.5000000000018 then
                                begin
                                    Result := -0.021132124108636196;
                                end
                                else
                                begin
                                    Result := 0.013940779178535678;
                                end;
                            end;
                        end
                        else
                        begin
                            if features.candidate_word_lm_boundary_count <= 4.5000000000000009 then
                            begin
                                Result := 0.065907103728759839;
                            end
                            else
                            begin
                                if features.candidate_ranker_score <= 274528.50000000006 then
                                begin
                                    Result := -0.018580109449823821;
                                end
                                else
                                begin
                                    Result := 0.031393607675283784;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.035187967577528685;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r0 <= -4072.4999999999995 then
                    begin
                        Result := -0.021871774006022058;
                    end
                    else
                    begin
                        Result := 0.037600749841961212;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_local_lm_r3 <= -503.49999999999994 then
        begin
            Result := -0.030851127748051065;
        end
        else
        begin
            Result := 0.0085046614378668627;
        end;
    end;
end;

function local_difference_tree_175(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.top_local_lm_r2 <= -3832.4999999999995 then
    begin
        if features.same_suffix_units <= 16.500000000000004 then
        begin
            if features.candidate_candidate_score <= 181501.50000000003 then
            begin
                Result := -0.0005021306079820519;
            end
            else
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    if features.delta_local_lm_r1 <= -2245.4999999999995 then
                    begin
                        Result := -0.03107475582412772;
                    end
                    else
                    begin
                        if features.delta_score_per_unit <= -28.499999999999996 then
                        begin
                            if features.delta_local_lm_r0 <= 490.00000000000006 then
                            begin
                                Result := -0.024031231630749442;
                            end
                            else
                            begin
                                Result := 0.016902332000431682;
                            end;
                        end
                        else
                        begin
                            if features.candidate_dict_weight_per_unit <= 16751.500000000004 then
                            begin
                                if features.delta_char_lm_score <= -265.49999999999994 then
                                begin
                                    Result := -0.011129122988524523;
                                end
                                else
                                begin
                                    if features.delta_local_lm_r1 <= -599.49999999999989 then
                                    begin
                                        Result := 0.040549946301220351;
                                    end
                                    else
                                    begin
                                        if features.candidate_dict_weight <= 210253.50000000003 then
                                        begin
                                            if features.delta_char_lm_per_difference <= 120.50000000000001 then
                                            begin
                                                Result := 0.025633058018925303;
                                            end
                                            else
                                            begin
                                                Result := -0.016467938735738485;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := -0.018892082267318377;
                                        end;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.026106499230624733;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.048313965335808284;
                end;
            end;
        end
        else
        begin
            Result := -0.022012854155863872;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -3590.9999999999995 then
        begin
            if features.candidate_chain_first_stage_score <= 214566.00000000003 then
            begin
                Result := -0.030185483832078287;
            end
            else
            begin
                Result := 0.027120120987361752;
            end;
        end
        else
        begin
            Result := 0.05152075522154146;
        end;
    end;
end;

function local_difference_tree_176(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -761.49999999999989 then
    begin
        Result := -0.034089699947432307;
    end
    else
    begin
        if features.delta_word_lm_boundary_count <= 6.5000000000000009 then
        begin
            if features.candidate_local_lm_r0 <= -8513.4999999999982 then
            begin
                if features.delta_char_lm_suffix_score <= -464.49999999999994 then
                begin
                    Result := 0.026939987892787429;
                end
                else
                begin
                    Result := -0.020865039042810084;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r0 <= -7559.4999999999991 then
                begin
                    if features.candidate_local_lm_r3 <= -7300.4999999999991 then
                    begin
                        if features.delta_candidate_score <= 8999.5000000000018 then
                        begin
                            if features.delta_dict_weight_per_unit <= -2454.4999999999995 then
                            begin
                                if features.delta_dict_weight <= -34705.999999999993 then
                                begin
                                    Result := -0.008505643093974332;
                                end
                                else
                                begin
                                    Result := 0.10356582696045388;
                                end;
                            end
                            else
                            begin
                                Result := -0.025464282473462063;
                            end;
                        end
                        else
                        begin
                            if features.delta_chain_second_stage_score <= 6043288.0000000009 then
                            begin
                                Result := 0.036303086188710081;
                            end
                            else
                            begin
                                Result := -0.033093156984247404;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.035747280017236073;
                    end;
                end
                else
                begin
                    if features.delta_dict_weight_per_unit <= 4370.0000000000009 then
                    begin
                        Result := -0.00087468548177384764;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r3 <= -7999.4999999999991 then
                        begin
                            Result := 0.029688452933737404;
                        end
                        else
                        begin
                            Result := 0.0028955211498170887;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features.candidate_chain_second_stage_score <= 41579734.000000007 then
            begin
                Result := -0.032647616998173541;
            end
            else
            begin
                if features.candidate_char_lm_suffix_score <= -5521.4999999999991 then
                begin
                    Result := 0.044468574717204945;
                end
                else
                begin
                    Result := -0.017179401629744309;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_177(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -2239.4999999999995 then
    begin
        Result := -0.029455809873617626;
    end
    else
    begin
        if features.delta_legacy_rank <= 1.5000000000000002 then
        begin
            if features.top_local_lm_r0 <= -4622.4999999999991 then
            begin
                if features.top_local_lm_r0 <= -5140.4999999999991 then
                begin
                    if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0026283580822887734;
                    end
                    else
                    begin
                        Result := -0.0098685564779713852;
                    end;
                end
                else
                begin
                    Result := -0.0092675363144283009;
                end;
            end
            else
            begin
                Result := 0.00276805014004812;
            end;
        end
        else
        begin
            if features.delta_chain_first_stage_score <= -94998.499999999985 then
            begin
                Result := -0.025810215413360586;
            end
            else
            begin
                if features.top_local_lm_r1 <= -6149.4999999999991 then
                begin
                    if features.top_local_lm_r3 <= -5778.4999999999991 then
                    begin
                        if features.candidate_chain_score_gap <= -221364535.99999997 then
                        begin
                            Result := 0.098082190360978622;
                        end
                        else
                        begin
                            if features.candidate_text_units <= 6.5000000000000009 then
                            begin
                                Result := 0.046593517908850045;
                            end
                            else
                            begin
                                if features.delta_score_per_unit <= 1699.0000000000002 then
                                begin
                                    if features.delta_char_lm_score <= -393.49999999999994 then
                                    begin
                                        if features.top_local_lm_r2 <= -7957.4999999999991 then
                                        begin
                                            Result := 0.041250926010462576;
                                        end
                                        else
                                        begin
                                            Result := -0.036414892891866786;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := 0.014725589111737219;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.033299589524252493;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.candidate_word_lm_boundary_max <= 1285.5000000000002 then
                        begin
                            Result := 0.086593581633878064;
                        end
                        else
                        begin
                            Result := 0.0;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.002089738944125685;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_178(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_char_lm_score <= -4262.4999999999991 then
    begin
        if features.candidate_char_lm_score <= -4520.4999999999991 then
        begin
            if features.candidate_word_lm_supported_ratio <= 639.00000000000011 then
            begin
                Result := 0.00068641829511275026;
            end
            else
            begin
                Result := -0.031804676202229459;
            end;
        end
        else
        begin
            Result := -0.012402567465597323;
        end;
    end
    else
    begin
        if features.top_local_lm_r0 <= -5993.4999999999991 then
        begin
            if features.same_suffix_units <= 8.5000000000000018 then
            begin
                Result := -0.029069141004861448;
            end
            else
            begin
                Result := 0.030124455585717521;
            end;
        end
        else
        begin
            if features.same_suffix_units <= 8.5000000000000018 then
            begin
                if features.delta_local_lm_r0 <= -914.49999999999989 then
                begin
                    Result := -0.0038256039560832567;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= -898.49999999999989 then
                    begin
                        Result := 0.06646725749723259;
                    end
                    else
                    begin
                        if features.delta_chain_first_stage_score <= 1.0000000180025095E-35 then
                        begin
                            if features.candidate_char_lm_score <= -3773.4999999999995 then
                            begin
                                if features.delta_local_lm_r0 <= -647.49999999999989 then
                                begin
                                    Result := -0.026596752007639321;
                                end
                                else
                                begin
                                    Result := 0.021713698455325666;
                                end;
                            end
                            else
                            begin
                                if features.delta_local_lm_r1 <= -1623.4999999999998 then
                                begin
                                    if features.delta_local_lm_r2 <= -1606.4999999999998 then
                                    begin
                                        Result := -0.020575212461201971;
                                    end
                                    else
                                    begin
                                        Result := 0.077380914617850599;
                                    end;
                                end
                                else
                                begin
                                    if features.delta_local_lm_r3 <= -17.499999999999996 then
                                    begin
                                        Result := -0.025118992526076248;
                                    end
                                    else
                                    begin
                                        Result := 0.0097772586192895541;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.027208492551296381;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.012295185793523138;
            end;
        end;
    end;
end;

function local_difference_tree_179(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_score <= -690.49999999999989 then
    begin
        if features.delta_word_lm_per_boundary <= 31.633333206176761 then
        begin
            if features.delta_char_suffix_lm_per_difference <= -640.58334350585926 then
            begin
                if features.top_local_lm_r2 <= -4210.4999999999991 then
                begin
                    if features.delta_dict_weight <= 303524.50000000006 then
                    begin
                        if features.candidate_path_segments <= 5.5000000000000009 then
                        begin
                            if features.delta_path_max_segment_units <= 10.500000000000002 then
                            begin
                                Result := 0.0038237601029154902;
                            end
                            else
                            begin
                                Result := 0.080688398227507618;
                            end;
                        end
                        else
                        begin
                            Result := -0.025443082290646638;
                        end;
                    end
                    else
                    begin
                        Result := 0.055011640312228674;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r2 <= -4847.4999999999991 then
                    begin
                        Result := -0.039490818396096208;
                    end
                    else
                    begin
                        Result := 0.034660461253232924;
                    end;
                end;
            end
            else
            begin
                if features.top_local_lm_r2 <= -6507.4999999999991 then
                begin
                    if features.delta_local_lm_r1 <= -414.49999999999994 then
                    begin
                        if features.delta_local_lm_r2 <= -1815.4999999999998 then
                        begin
                            Result := 0.03990293543927742;
                        end
                        else
                        begin
                            if features.candidate_word_lm_bonus <= 259.50000000000006 then
                            begin
                                Result := -0.026574428792630413;
                            end
                            else
                            begin
                                Result := 0.032501582570121625;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.038476357899097979;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r3 <= -9023.4999999999982 then
                    begin
                        Result := 0.055781135943060389;
                    end
                    else
                    begin
                        Result := -0.027493873449640285;
                    end;
                end;
            end;
        end
        else
        begin
            if features.delta_char_lm_suffix_score <= -786.49999999999989 then
            begin
                Result := 0.041358633082753553;
            end
            else
            begin
                Result := -0.0165450905790707;
            end;
        end;
    end
    else
    begin
        Result := 0.0014568779934201793;
    end;
end;

function local_difference_tree_180(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_candidate_score <= 303251.50000000006 then
    begin
        if features.delta_chain_score_gap <= -187927871.99999997 then
        begin
            if features.candidate_chain_second_stage_score <= 225689624.00000003 then
            begin
                if features.candidate_chain_second_stage_score <= 133788108.00000001 then
                begin
                    if features.candidate_local_lm_r2 <= -5643.4999999999991 then
                    begin
                        if features.delta_word_lm_zero_count <= 1.0000000180025095E-35 then
                        begin
                            if features.candidate_local_lm_r0 <= -5334.4999999999991 then
                            begin
                                Result := 0.040478878877219168;
                            end
                            else
                            begin
                                Result := -0.016950764919127996;
                            end;
                        end
                        else
                        begin
                            Result := -0.025647675816342402;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r2 <= -641.49999999999989 then
                        begin
                            Result := -0.026009795576728265;
                        end
                        else
                        begin
                            Result := 0.072013491075550828;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.028736414497679622;
                end;
            end
            else
            begin
                if features.delta_word_lm_per_boundary <= -66.674999237060533 then
                begin
                    Result := -0.02677671394671835;
                end
                else
                begin
                    if features.candidate_char_lm_suffix_score <= -4394.4999999999991 then
                    begin
                        Result := 0.075369032292692859;
                    end
                    else
                    begin
                        Result := -0.020343158778349957;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.00062490838862417817;
        end;
    end
    else
    begin
        if features.delta_local_lm_r1 <= -1325.4999999999998 then
        begin
            if features.delta_local_lm_r0 <= -73.499999999999986 then
            begin
                Result := 0.006834450760794605;
            end
            else
            begin
                Result := 0.066890470528178966;
            end;
        end
        else
        begin
            if features.delta_local_lm_r2 <= -377.49999999999994 then
            begin
                if features.candidate_ranker_score_gap <= -25761292.999999996 then
                begin
                    Result := -0.033261441533977774;
                end
                else
                begin
                    Result := 0.030469564276382078;
                end;
            end
            else
            begin
                Result := 0.025299779281275137;
            end;
        end;
    end;
end;

function local_difference_tree_181(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.baseline_abstain_score <= 93487884.000000015 then
    begin
        if features.candidate_local_lm_r0 <= -4300.4999999999991 then
        begin
            if features.delta_path_segments <= -1.4999999999999998 then
            begin
                if features.candidate_local_lm_r3 <= -8853.4999999999982 then
                begin
                    Result := 0.040988991877096183;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -4632.4999999999991 then
                    begin
                        Result := -0.016864127404940702;
                    end
                    else
                    begin
                        Result := 0.035449524360914988;
                    end;
                end;
            end
            else
            begin
                Result := 0.00048214351385208933;
            end;
        end
        else
        begin
            if features.candidate_local_lm_r0 <= -4192.4999999999991 then
            begin
                if features.candidate_candidate_score <= 195137.50000000003 then
                begin
                    if features.top_local_lm_r1 <= -6204.4999999999991 then
                    begin
                        Result := 0.048445843969436346;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r0 <= -4210.9999999999991 then
                        begin
                            if features.top_local_lm_r0 <= -5245.4999999999991 then
                            begin
                                Result := 0.028158783963953646;
                            end
                            else
                            begin
                                Result := -0.041436789094497037;
                            end;
                        end
                        else
                        begin
                            Result := 0.035055643698097813;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.027474848575681988;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r3 <= -6517.4999999999991 then
                begin
                    Result := -0.011378575964470243;
                end
                else
                begin
                    if features.delta_word_lm_bonus <= -170.49999999999997 then
                    begin
                        Result := -0.020128803343942559;
                    end
                    else
                    begin
                        Result := 0.012951594887229738;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_chain_first_stage_score <= -91584.999999999985 then
        begin
            if features.candidate_word_lm_boundary_max <= 1483.5000000000002 then
            begin
                Result := -0.0083366503523811392;
            end
            else
            begin
                Result := 0.043713118897054259;
            end;
        end
        else
        begin
            Result := -0.015279026170840194;
        end;
    end;
end;

function local_difference_tree_182(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_input_syllable_count <= 7.5000000000000009 then
    begin
        if features.delta_word_lm_per_boundary <= 86.690475463867202 then
        begin
            Result := 0.0039277710989116003;
        end
        else
        begin
            Result := 0.041627051808973622;
        end;
    end
    else
    begin
        if features.delta_char_lm_per_difference <= -325.91667175292963 then
        begin
            if features.candidate_word_lm_boundary_last <= 1540.5000000000002 then
            begin
                if features.top_local_lm_r2 <= -6422.4999999999991 then
                begin
                    Result := 0.0085875186073613094;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -4441.4999999999991 then
                    begin
                        Result := -0.010920408855916393;
                    end
                    else
                    begin
                        Result := 0.030061757901465938;
                    end;
                end;
            end
            else
            begin
                Result := -0.036119179623924476;
            end;
        end
        else
        begin
            if features.delta_char_lm_score <= -770.49999999999989 then
            begin
                Result := -0.033800390134513927;
            end
            else
            begin
                if features.delta_local_lm_r3 <= -1178.4999999999998 then
                begin
                    if features.candidate_score_per_unit <= 9675.5000000000018 then
                    begin
                        Result := 0.10330872328321059;
                    end
                    else
                    begin
                        Result := -0.005292039856967635;
                    end;
                end
                else
                begin
                    if features.delta_chain_first_stage_score <= 81816.000000000015 then
                    begin
                        if features.delta_chain_first_stage_score <= 193.50000000000003 then
                        begin
                            Result := 0.0020212844680123003;
                        end
                        else
                        begin
                            if features.delta_chain_score_gap <= -33621857.999999993 then
                            begin
                                Result := -0.025864629680054069;
                            end
                            else
                            begin
                                if features.delta_local_lm_r3 <= -775.49999999999989 then
                                begin
                                    Result := 0.031987984922508712;
                                end
                                else
                                begin
                                    if features.candidate_local_lm_r2 <= -7387.4999999999991 then
                                    begin
                                        Result := 0.014150882776638276;
                                    end
                                    else
                                    begin
                                        Result := -0.01078541811884777;
                                    end;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.015493682880711797;
                    end;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_183(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_bonus <= -815.49999999999989 then
    begin
        Result := -0.037136826584324864;
    end
    else
    begin
        if features.candidate_ranker_score_gap <= -22190821.999999996 then
        begin
            if features.delta_chain_first_stage_score <= 645.50000000000011 then
            begin
                if features.delta_score_per_unit <= 6046.5000000000009 then
                begin
                    Result := 0.00028498127962461758;
                end
                else
                begin
                    if features.candidate_candidate_score <= 137132.50000000003 then
                    begin
                        Result := -0.026676631632502092;
                    end
                    else
                    begin
                        Result := 0.051738769245148329;
                    end;
                end;
            end
            else
            begin
                if features.delta_word_lm_boundary_count <= -4.4999999999999991 then
                begin
                    if features.candidate_chain_first_stage_score <= 102731.00000000001 then
                    begin
                        Result := -0.0092997156508637709;
                    end
                    else
                    begin
                        Result := 0.059517400480321586;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r1 <= -6516.4999999999991 then
                    begin
                        if features.candidate_dict_weight <= -21232.999999999996 then
                        begin
                            Result := 0.058477586421741758;
                        end
                        else
                        begin
                            if features.delta_word_lm_bonus <= 60.500000000000007 then
                            begin
                                Result := -0.010508950916957343;
                            end
                            else
                            begin
                                if features.candidate_local_lm_r0 <= -6235.9999999999991 then
                                begin
                                    Result := -0.011529500441922746;
                                end
                                else
                                begin
                                    if features.candidate_ranker_score <= 3236758.5000000005 then
                                    begin
                                        Result := 0.062552563688477877;
                                    end
                                    else
                                    begin
                                        Result := 0.0031127707824150658;
                                    end;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r3 <= -4690.4999999999991 then
                        begin
                            Result := -0.03607835027924805;
                        end
                        else
                        begin
                            if features.top_local_lm_r1 <= -4811.4999999999991 then
                            begin
                                Result := 0.042657157365882784;
                            end
                            else
                            begin
                                Result := -0.020098089216352946;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.0050296113234703024;
        end;
    end;
end;

function local_difference_tree_184(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_per_difference <= 341.50000000000006 then
    begin
        if features.delta_path_single_segments <= -1.4999999999999998 then
        begin
            if features.top_local_lm_r0 <= -5855.4999999999991 then
            begin
                if features.top_local_lm_r1 <= -5714.4999999999991 then
                begin
                    if features.difference_span_units <= 4.5000000000000009 then
                    begin
                        Result := 0.030668220605780207;
                    end
                    else
                    begin
                        Result := -0.019308839043348867;
                    end;
                end
                else
                begin
                    Result := -0.027874087949614622;
                end;
            end
            else
            begin
                if features.top_local_lm_r0 <= -5632.4999999999991 then
                begin
                    Result := -0.031756230836911412;
                end
                else
                begin
                    Result := 0.0066749002255594922;
                end;
            end;
        end
        else
        begin
            if features.delta_path_max_segment_units <= 11.500000000000002 then
            begin
                if features.candidate_path_max_segment_units <= 9.5000000000000018 then
                begin
                    if features.delta_path_max_segment_units <= 7.5000000000000009 then
                    begin
                        Result := -0.00079177196986887329;
                    end
                    else
                    begin
                        if features.same_prefix_units <= 4.5000000000000009 then
                        begin
                            if features.delta_local_lm_r3 <= -39.499999999999993 then
                            begin
                                Result := -0.017690338686642732;
                            end
                            else
                            begin
                                Result := 0.048898569871015055;
                            end;
                        end
                        else
                        begin
                            Result := 0.068445062876448123;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.027221225437639194;
                end;
            end
            else
            begin
                if features.candidate_score_per_unit <= 9812.5000000000018 then
                begin
                    Result := -0.018675621339434872;
                end
                else
                begin
                    if features.candidate_local_lm_r0 <= -6501.4999999999991 then
                    begin
                        Result := -0.015937804757190789;
                    end
                    else
                    begin
                        Result := 0.09133119790305011;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -4769.4999999999991 then
        begin
            Result := -0.031595373522752226;
        end
        else
        begin
            Result := 0.0086586876781835128;
        end;
    end;
end;

function local_difference_tree_185(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_char_lm_per_difference <= 341.50000000000006 then
    begin
        if features.delta_char_suffix_lm_per_difference <= 274.50000000000006 then
        begin
            if features.delta_legacy_rank <= 1.5000000000000002 then
            begin
                Result := -0.00050066425578087256;
            end
            else
            begin
                if features.delta_chain_first_stage_score <= -89456.999999999985 then
                begin
                    Result := -0.02153492140775087;
                end
                else
                begin
                    if features.top_local_lm_r0 <= -5607.4999999999991 then
                    begin
                        if features.candidate_local_lm_r0 <= -6089.4999999999991 then
                        begin
                            if features.candidate_chain_first_stage_score <= -5851.9999999999991 then
                            begin
                                Result := 0.068696156461196436;
                            end
                            else
                            begin
                                Result := 0.0042563484695002304;
                            end;
                        end
                        else
                        begin
                            if features.candidate_ranker_score <= -9944406.9999999981 then
                            begin
                                if features.candidate_candidate_score <= 64878.500000000007 then
                                begin
                                    Result := -0.0211587374951476;
                                end
                                else
                                begin
                                    if features.delta_dict_weight_per_unit <= -10595.499999999998 then
                                    begin
                                        Result := -0.01448048680044383;
                                    end
                                    else
                                    begin
                                        Result := 0.11972625000967355;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.014023614598755611;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_local_lm_r3 <= -329.49999999999994 then
                        begin
                            if features.delta_char_suffix_lm_per_difference <= -984.74999999999989 then
                            begin
                                Result := 0.043033722399901296;
                            end
                            else
                            begin
                                if features.candidate_candidate_score <= 43800.500000000007 then
                                begin
                                    Result := 0.028328362759597808;
                                end
                                else
                                begin
                                    Result := -0.02768261303044291;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.027538743849602938;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.0232946205821505;
        end;
    end
    else
    begin
        if features.candidate_chain_second_stage_score <= -146039263.99999997 then
        begin
            Result := 0.02290845796666615;
        end
        else
        begin
            Result := -0.028253144241749087;
        end;
    end;
end;

function local_difference_tree_186(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.different_units <= 4.5000000000000009 then
    begin
        if features.candidate_local_lm_r1 <= -5408.4999999999991 then
        begin
            if features.top_local_lm_r1 <= -4385.4999999999991 then
            begin
                if features.delta_dict_weight_per_unit <= 4370.0000000000009 then
                begin
                    if features.delta_chain_first_stage_score <= 81816.000000000015 then
                    begin
                        if features.delta_score_per_unit <= 6046.5000000000009 then
                        begin
                            Result := -0.0031870159896657171;
                        end
                        else
                        begin
                            Result := 0.039064109454141897;
                        end;
                    end
                    else
                    begin
                        if features.candidate_chain_first_stage_score <= 129010.50000000001 then
                        begin
                            if features.delta_score_per_unit <= -1000.4999999999999 then
                            begin
                                Result := 0.035594162807829795;
                            end
                            else
                            begin
                                Result := -0.040514103902763082;
                            end;
                        end
                        else
                        begin
                            Result := 0.045631579291608403;
                        end;
                    end;
                end
                else
                begin
                    if features.delta_local_lm_r0 <= 1695.5000000000002 then
                    begin
                        Result := 0.0075041468251670299;
                    end
                    else
                    begin
                        Result := -0.027902853223942127;
                    end;
                end;
            end
            else
            begin
                if features.candidate_local_lm_r2 <= -5843.4999999999991 then
                begin
                    Result := -0.028438245022669617;
                end
                else
                begin
                    Result := 0.019478805954524909;
                end;
            end;
        end
        else
        begin
            if features.top_local_lm_r0 <= -4160.4999999999991 then
            begin
                if features.candidate_chain_score_gap <= -148986551.99999997 then
                begin
                    Result := 0.035127017563023291;
                end
                else
                begin
                    if features.candidate_word_lm_boundary_last <= 1126.5000000000002 then
                    begin
                        Result := 0.010064511017268258;
                    end
                    else
                    begin
                        Result := -0.018621855080454441;
                    end;
                end;
            end
            else
            begin
                if features.delta_char_lm_score <= -295.49999999999994 then
                begin
                    Result := -0.036143974336291448;
                end
                else
                begin
                    Result := 0.0012053095168802781;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.033010547488075123;
    end;
end;

function local_difference_tree_187(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_second_stage_score <= -338456735.99999994 then
    begin
        Result := -0.035871614570812171;
    end
    else
    begin
        if features.candidate_word_lm_supported_ratio <= 418.50000000000006 then
        begin
            Result := 0.0011452207456954294;
        end
        else
        begin
            if features.delta_chain_second_stage_score <= 6043288.0000000009 then
            begin
                if features.candidate_chain_second_stage_score <= -29359527.999999996 then
                begin
                    if features.candidate_ranker_score_gap <= -25761292.999999996 then
                    begin
                        if features.candidate_char_lm_suffix_score <= -6540.4999999999991 then
                        begin
                            Result := -0.024023442235881213;
                        end
                        else
                        begin
                            Result := 0.04471062414575646;
                        end;
                    end
                    else
                    begin
                        Result := -0.021603788776788643;
                    end;
                end
                else
                begin
                    if features.candidate_local_lm_r3 <= -5443.4999999999991 then
                    begin
                        if features.candidate_word_lm_trigram_ratio <= 173.50000000000003 then
                        begin
                            Result := -0.024602110462867789;
                        end
                        else
                        begin
                            Result := 0.016788287389004359;
                        end;
                    end
                    else
                    begin
                        if features.top_local_lm_r1 <= -6541.4999999999991 then
                        begin
                            Result := 0.050513420625686201;
                        end
                        else
                        begin
                            if features.top_local_lm_r1 <= -3907.4999999999995 then
                            begin
                                if features.candidate_local_lm_r3 <= -5342.4999999999991 then
                                begin
                                    Result := 0.035676210360230033;
                                end
                                else
                                begin
                                    Result := -0.041073568544046007;
                                end;
                            end
                            else
                            begin
                                Result := 0.028406021275960553;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.candidate_chain_second_stage_score <= 377952800.00000006 then
                begin
                    if features.delta_char_lm_score <= -308.49999999999994 then
                    begin
                        Result := -0.030418785939865543;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r3 <= -6038.4999999999991 then
                        begin
                            Result := 0.031056392325274667;
                        end
                        else
                        begin
                            Result := -0.02029802691971614;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.040294398321545459;
                end;
            end;
        end;
    end;
end;

function local_difference_tree_188(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_word_lm_trigram_ratio <= -83.499999999999986 then
    begin
        Result := -0.031438576095218683;
    end
    else
    begin
        if features.delta_char_lm_per_difference <= -481.83332824707026 then
        begin
            if features.delta_candidate_score <= 4096.5000000000009 then
            begin
                if features.same_suffix_units <= 1.5000000000000002 then
                begin
                    if features.top_local_lm_r1 <= -4419.4999999999991 then
                    begin
                        if features.delta_char_lm_per_difference <= -830.41665649414051 then
                        begin
                            Result := 0.035469842417541912;
                        end
                        else
                        begin
                            Result := 0.00094846522102497654;
                        end;
                    end
                    else
                    begin
                        if features.candidate_local_lm_r0 <= -3358.4999999999995 then
                        begin
                            Result := -0.039509919001202924;
                        end
                        else
                        begin
                            Result := 0.068975638746518686;
                        end;
                    end;
                end
                else
                begin
                    if features.candidate_char_lm_suffix_score <= -6501.4999999999991 then
                    begin
                        if features.candidate_char_lm_score <= -5405.4999999999991 then
                        begin
                            Result := -0.0092469170822440036;
                        end
                        else
                        begin
                            if features.candidate_char_lm_score <= -5271.4999999999991 then
                            begin
                                Result := 0.058730560749601902;
                            end
                            else
                            begin
                                Result := 0.0016802708356982027;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.delta_dict_weight_per_unit <= 24912.000000000004 then
                        begin
                            if features.delta_word_lm_per_boundary <= 123.51666641235353 then
                            begin
                                if features.top_local_lm_r1 <= -3950.4999999999995 then
                                begin
                                    Result := -0.030017701450093401;
                                end
                                else
                                begin
                                    Result := 0.018340517379319597;
                                end;
                            end
                            else
                            begin
                                Result := 0.018744900419707007;
                            end;
                        end
                        else
                        begin
                            Result := 0.012407915839136769;
                        end;
                    end;
                end;
            end
            else
            begin
                if features.delta_word_lm_bonus <= 149.50000000000003 then
                begin
                    Result := 0.0052642322328267455;
                end
                else
                begin
                    Result := 0.047729438418638692;
                end;
            end;
        end
        else
        begin
            Result := 0.0016335279391128672;
        end;
    end;
end;

function local_difference_tree_189(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.delta_chain_first_stage_score <= -115127.99999999999 then
    begin
        if features.delta_local_lm_r0 <= 1664.5000000000002 then
        begin
            if features.same_suffix_units <= 8.5000000000000018 then
            begin
                if features.candidate_text_units <= 19.500000000000004 then
                begin
                    if features.delta_char_lm_per_difference <= -830.41665649414051 then
                    begin
                        if features.delta_char_lm_per_difference <= -974.49999999999989 then
                        begin
                            Result := -0.022727863476268408;
                        end
                        else
                        begin
                            Result := 0.074606966572876923;
                        end;
                    end
                    else
                    begin
                        Result := -0.030127889042281208;
                    end;
                end
                else
                begin
                    Result := 0.02819011300561073;
                end;
            end
            else
            begin
                if features.delta_char_lm_score <= -46.499999999999993 then
                begin
                    Result := -0.017145379563124161;
                end
                else
                begin
                    Result := 0.031427405715334124;
                end;
            end;
        end
        else
        begin
            if features.delta_local_lm_r1 <= 308.50000000000006 then
            begin
                Result := -0.010449300256805658;
            end
            else
            begin
                Result := 0.043874421242145516;
            end;
        end;
    end
    else
    begin
        if features.candidate_score_per_unit <= 228.50000000000003 then
        begin
            if features.candidate_local_lm_r0 <= -6545.4999999999991 then
            begin
                if features.candidate_local_lm_r0 <= -7559.4999999999991 then
                begin
                    Result := -0.0073296013187613401;
                end
                else
                begin
                    Result := 0.07019005398614972;
                end;
            end
            else
            begin
                if features.same_prefix_units <= 1.5000000000000002 then
                begin
                    Result := -0.036602698949101661;
                end
                else
                begin
                    if features.candidate_char_lm_suffix_score <= -6196.4999999999991 then
                    begin
                        if features.delta_local_lm_r0 <= 490.00000000000006 then
                        begin
                            Result := -0.041113753907361404;
                        end
                        else
                        begin
                            Result := 0.019887046189125141;
                        end;
                    end
                    else
                    begin
                        Result := 0.029001389404548474;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.00013921517765491873;
        end;
    end;
end;

function local_difference_tree_190(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.top_local_lm_r1 <= -7820.9999999999991 then
    begin
        if features.candidate_word_lm_boundary_max <= 1375.5000000000002 then
        begin
            if features.delta_dict_weight_per_unit <= -156.49999999999997 then
            begin
                if features.candidate_char_lm_score <= -7009.4999999999991 then
                begin
                    Result := 0.035685161219459076;
                end
                else
                begin
                    if features.delta_char_suffix_lm_per_difference <= 141.25000000000003 then
                    begin
                        if features.candidate_local_lm_r2 <= -7155.4999999999991 then
                        begin
                            if features.delta_candidate_score <= -8277.4999999999982 then
                            begin
                                Result := -0.037430660526518271;
                            end
                            else
                            begin
                                Result := 0.011566604609715767;
                            end;
                        end
                        else
                        begin
                            if features.delta_candidate_score <= -27805.999999999996 then
                            begin
                                Result := 0.058393129007647405;
                            end
                            else
                            begin
                                Result := -0.013705042682956371;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.03482796906716245;
                    end;
                end;
            end
            else
            begin
                Result := -0.032944803814779815;
            end;
        end
        else
        begin
            if features.baseline_abstain_score <= 117482584.00000001 then
            begin
                if features.delta_char_lm_per_difference <= -10.416666507720945 then
                begin
                    if features.candidate_word_lm_supported_ratio <= 465.50000000000006 then
                    begin
                        Result := 0.028810379604124924;
                    end
                    else
                    begin
                        Result := -0.028130620180151698;
                    end;
                end
                else
                begin
                    if features.candidate_word_lm_supported_ratio <= 449.00000000000006 then
                    begin
                        Result := -0.04008948254886658;
                    end
                    else
                    begin
                        Result := 0.0091437323357221097;
                    end;
                end;
            end
            else
            begin
                if features.candidate_score_per_unit <= 8837.5000000000018 then
                begin
                    Result := 0.056966436511597281;
                end
                else
                begin
                    Result := -0.0054990245905139311;
                end;
            end;
        end;
    end
    else
    begin
        if features.delta_char_lm_score <= -1772.4999999999998 then
        begin
            Result := -0.016052892679517757;
        end
        else
        begin
            Result := 0.001546213107616026;
        end;
    end;
end;

function local_difference_tree_191(
    const features: TncLongLocalDifferenceResidualFeatures): Double;
begin
    if features.candidate_local_lm_r0 <= -8513.4999999999982 then
    begin
        if features.delta_char_lm_suffix_score <= -464.49999999999994 then
        begin
            if features.candidate_chain_first_stage_score <= 117408.00000000001 then
            begin
                if features.top_local_lm_r2 <= -5888.4999999999991 then
                begin
                    Result := 0.036463137048729666;
                end
                else
                begin
                    Result := -0.025187845034731333;
                end;
            end
            else
            begin
                Result := -0.025630657358254458;
            end;
        end
        else
        begin
            Result := -0.026668035184427268;
        end;
    end
    else
    begin
        if features.candidate_local_lm_r0 <= -7559.4999999999991 then
        begin
            if features.candidate_local_lm_r3 <= -7326.4999999999991 then
            begin
                if features.delta_local_lm_r0 <= -44.499999999999993 then
                begin
                    if features.candidate_ranker_score_gap <= -34427925.999999993 then
                    begin
                        if features.delta_path_max_segment_units <= 2.5000000000000004 then
                        begin
                            Result := -0.038528228689161219;
                        end
                        else
                        begin
                            Result := 0.017906258342267417;
                        end;
                    end
                    else
                    begin
                        if features.delta_chain_second_stage_score <= -18530434.999999996 then
                        begin
                            if features.difference_span_units <= 3.5000000000000004 then
                            begin
                                Result := 0.014448373928500504;
                            end
                            else
                            begin
                                Result := 0.069030116236849376;
                            end;
                        end
                        else
                        begin
                            if features.delta_dict_weight_per_unit <= 1373.0000000000002 then
                            begin
                                Result := 0.022317801075392513;
                            end
                            else
                            begin
                                Result := -0.031778648892676967;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.044153893843508908;
                end;
            end
            else
            begin
                Result := -0.033883352751854182;
            end;
        end
        else
        begin
            if features.difference_span_units <= 6.5000000000000009 then
            begin
                Result := 0.00012878043769476219;
            end
            else
            begin
                if features.delta_char_lm_score <= -350.49999999999994 then
                begin
                    Result := -0.040998614998468068;
                end
                else
                begin
                    Result := 0.0055087703471347425;
                end;
            end;
        end;
    end;
end;
function long_local_difference_residual_score(
    const features: TncLongLocalDifferenceResidualFeatures): Int64;
var
    score: Double;
begin
    score := 0.0;
    score := score + local_difference_tree_0(features);
    score := score + local_difference_tree_1(features);
    score := score + local_difference_tree_2(features);
    score := score + local_difference_tree_3(features);
    score := score + local_difference_tree_4(features);
    score := score + local_difference_tree_5(features);
    score := score + local_difference_tree_6(features);
    score := score + local_difference_tree_7(features);
    score := score + local_difference_tree_8(features);
    score := score + local_difference_tree_9(features);
    score := score + local_difference_tree_10(features);
    score := score + local_difference_tree_11(features);
    score := score + local_difference_tree_12(features);
    score := score + local_difference_tree_13(features);
    score := score + local_difference_tree_14(features);
    score := score + local_difference_tree_15(features);
    score := score + local_difference_tree_16(features);
    score := score + local_difference_tree_17(features);
    score := score + local_difference_tree_18(features);
    score := score + local_difference_tree_19(features);
    score := score + local_difference_tree_20(features);
    score := score + local_difference_tree_21(features);
    score := score + local_difference_tree_22(features);
    score := score + local_difference_tree_23(features);
    score := score + local_difference_tree_24(features);
    score := score + local_difference_tree_25(features);
    score := score + local_difference_tree_26(features);
    score := score + local_difference_tree_27(features);
    score := score + local_difference_tree_28(features);
    score := score + local_difference_tree_29(features);
    score := score + local_difference_tree_30(features);
    score := score + local_difference_tree_31(features);
    score := score + local_difference_tree_32(features);
    score := score + local_difference_tree_33(features);
    score := score + local_difference_tree_34(features);
    score := score + local_difference_tree_35(features);
    score := score + local_difference_tree_36(features);
    score := score + local_difference_tree_37(features);
    score := score + local_difference_tree_38(features);
    score := score + local_difference_tree_39(features);
    score := score + local_difference_tree_40(features);
    score := score + local_difference_tree_41(features);
    score := score + local_difference_tree_42(features);
    score := score + local_difference_tree_43(features);
    score := score + local_difference_tree_44(features);
    score := score + local_difference_tree_45(features);
    score := score + local_difference_tree_46(features);
    score := score + local_difference_tree_47(features);
    score := score + local_difference_tree_48(features);
    score := score + local_difference_tree_49(features);
    score := score + local_difference_tree_50(features);
    score := score + local_difference_tree_51(features);
    score := score + local_difference_tree_52(features);
    score := score + local_difference_tree_53(features);
    score := score + local_difference_tree_54(features);
    score := score + local_difference_tree_55(features);
    score := score + local_difference_tree_56(features);
    score := score + local_difference_tree_57(features);
    score := score + local_difference_tree_58(features);
    score := score + local_difference_tree_59(features);
    score := score + local_difference_tree_60(features);
    score := score + local_difference_tree_61(features);
    score := score + local_difference_tree_62(features);
    score := score + local_difference_tree_63(features);
    score := score + local_difference_tree_64(features);
    score := score + local_difference_tree_65(features);
    score := score + local_difference_tree_66(features);
    score := score + local_difference_tree_67(features);
    score := score + local_difference_tree_68(features);
    score := score + local_difference_tree_69(features);
    score := score + local_difference_tree_70(features);
    score := score + local_difference_tree_71(features);
    score := score + local_difference_tree_72(features);
    score := score + local_difference_tree_73(features);
    score := score + local_difference_tree_74(features);
    score := score + local_difference_tree_75(features);
    score := score + local_difference_tree_76(features);
    score := score + local_difference_tree_77(features);
    score := score + local_difference_tree_78(features);
    score := score + local_difference_tree_79(features);
    score := score + local_difference_tree_80(features);
    score := score + local_difference_tree_81(features);
    score := score + local_difference_tree_82(features);
    score := score + local_difference_tree_83(features);
    score := score + local_difference_tree_84(features);
    score := score + local_difference_tree_85(features);
    score := score + local_difference_tree_86(features);
    score := score + local_difference_tree_87(features);
    score := score + local_difference_tree_88(features);
    score := score + local_difference_tree_89(features);
    score := score + local_difference_tree_90(features);
    score := score + local_difference_tree_91(features);
    score := score + local_difference_tree_92(features);
    score := score + local_difference_tree_93(features);
    score := score + local_difference_tree_94(features);
    score := score + local_difference_tree_95(features);
    score := score + local_difference_tree_96(features);
    score := score + local_difference_tree_97(features);
    score := score + local_difference_tree_98(features);
    score := score + local_difference_tree_99(features);
    score := score + local_difference_tree_100(features);
    score := score + local_difference_tree_101(features);
    score := score + local_difference_tree_102(features);
    score := score + local_difference_tree_103(features);
    score := score + local_difference_tree_104(features);
    score := score + local_difference_tree_105(features);
    score := score + local_difference_tree_106(features);
    score := score + local_difference_tree_107(features);
    score := score + local_difference_tree_108(features);
    score := score + local_difference_tree_109(features);
    score := score + local_difference_tree_110(features);
    score := score + local_difference_tree_111(features);
    score := score + local_difference_tree_112(features);
    score := score + local_difference_tree_113(features);
    score := score + local_difference_tree_114(features);
    score := score + local_difference_tree_115(features);
    score := score + local_difference_tree_116(features);
    score := score + local_difference_tree_117(features);
    score := score + local_difference_tree_118(features);
    score := score + local_difference_tree_119(features);
    score := score + local_difference_tree_120(features);
    score := score + local_difference_tree_121(features);
    score := score + local_difference_tree_122(features);
    score := score + local_difference_tree_123(features);
    score := score + local_difference_tree_124(features);
    score := score + local_difference_tree_125(features);
    score := score + local_difference_tree_126(features);
    score := score + local_difference_tree_127(features);
    score := score + local_difference_tree_128(features);
    score := score + local_difference_tree_129(features);
    score := score + local_difference_tree_130(features);
    score := score + local_difference_tree_131(features);
    score := score + local_difference_tree_132(features);
    score := score + local_difference_tree_133(features);
    score := score + local_difference_tree_134(features);
    score := score + local_difference_tree_135(features);
    score := score + local_difference_tree_136(features);
    score := score + local_difference_tree_137(features);
    score := score + local_difference_tree_138(features);
    score := score + local_difference_tree_139(features);
    score := score + local_difference_tree_140(features);
    score := score + local_difference_tree_141(features);
    score := score + local_difference_tree_142(features);
    score := score + local_difference_tree_143(features);
    score := score + local_difference_tree_144(features);
    score := score + local_difference_tree_145(features);
    score := score + local_difference_tree_146(features);
    score := score + local_difference_tree_147(features);
    score := score + local_difference_tree_148(features);
    score := score + local_difference_tree_149(features);
    score := score + local_difference_tree_150(features);
    score := score + local_difference_tree_151(features);
    score := score + local_difference_tree_152(features);
    score := score + local_difference_tree_153(features);
    score := score + local_difference_tree_154(features);
    score := score + local_difference_tree_155(features);
    score := score + local_difference_tree_156(features);
    score := score + local_difference_tree_157(features);
    score := score + local_difference_tree_158(features);
    score := score + local_difference_tree_159(features);
    score := score + local_difference_tree_160(features);
    score := score + local_difference_tree_161(features);
    score := score + local_difference_tree_162(features);
    score := score + local_difference_tree_163(features);
    score := score + local_difference_tree_164(features);
    score := score + local_difference_tree_165(features);
    score := score + local_difference_tree_166(features);
    score := score + local_difference_tree_167(features);
    score := score + local_difference_tree_168(features);
    score := score + local_difference_tree_169(features);
    score := score + local_difference_tree_170(features);
    score := score + local_difference_tree_171(features);
    score := score + local_difference_tree_172(features);
    score := score + local_difference_tree_173(features);
    score := score + local_difference_tree_174(features);
    score := score + local_difference_tree_175(features);
    score := score + local_difference_tree_176(features);
    score := score + local_difference_tree_177(features);
    score := score + local_difference_tree_178(features);
    score := score + local_difference_tree_179(features);
    score := score + local_difference_tree_180(features);
    score := score + local_difference_tree_181(features);
    score := score + local_difference_tree_182(features);
    score := score + local_difference_tree_183(features);
    score := score + local_difference_tree_184(features);
    score := score + local_difference_tree_185(features);
    score := score + local_difference_tree_186(features);
    score := score + local_difference_tree_187(features);
    score := score + local_difference_tree_188(features);
    score := score + local_difference_tree_189(features);
    score := score + local_difference_tree_190(features);
    score := score + local_difference_tree_191(features);
    Result := Trunc(score * c_long_local_difference_residual_score_scale);
end;

function long_local_difference_residual_self_test: Boolean;
var
    features: TncLongLocalDifferenceResidualFeatures;
begin
    FillChar(features, SizeOf(features), 0);
    if long_local_difference_residual_score(features) <>
        c_long_local_difference_residual_reference_score then Exit(False);
    features.candidate_candidate_score := -1000000.0;
    features.candidate_dict_weight := -1000000.0;
    features.candidate_has_dict_weight := -1000000.0;
    features.candidate_source_user := -1000000.0;
    features.candidate_source_chain := -1000000.0;
    features.candidate_source_pattern := -1000000.0;
    features.candidate_source_redup := -1000000.0;
    features.candidate_source_local_rerank := -1000000.0;
    features.candidate_source_rule_fallback := -1000000.0;
    features.candidate_legacy_rank := -1000000.0;
    features.candidate_legacy_top := -1000000.0;
    features.candidate_chain_rank := -1000000.0;
    features.candidate_chain_present := -1000000.0;
    features.candidate_chain_first_stage_score := -1000000.0;
    features.candidate_chain_second_stage_score := -1000000.0;
    features.candidate_chain_score_gap := -1000000.0;
    features.candidate_complete_match := -1000000.0;
    features.candidate_partial_match := -1000000.0;
    features.candidate_text_units := -1000000.0;
    features.candidate_comment_length := -1000000.0;
    features.candidate_unit_delta := -1000000.0;
    features.candidate_path_available := -1000000.0;
    features.candidate_path_confidence_score := -1000000.0;
    features.candidate_path_confidence_tier := -1000000.0;
    features.candidate_path_segments := -1000000.0;
    features.candidate_path_single_segments := -1000000.0;
    features.candidate_path_max_segment_units := -1000000.0;
    features.candidate_char_lm_score := -1000000.0;
    features.candidate_char_lm_suffix_score := -1000000.0;
    features.candidate_char_lm_context_score := -1000000.0;
    features.candidate_char_lm_context_gain := -1000000.0;
    features.candidate_has_left_context := -1000000.0;
    features.candidate_query_choice_bonus := -1000000.0;
    features.candidate_latest_query_choice := -1000000.0;
    features.candidate_query_path_bonus := -1000000.0;
    features.candidate_query_path_penalty := -1000000.0;
    features.candidate_word_lm_bonus := -1000000.0;
    features.candidate_word_lm_boundary_count := -1000000.0;
    features.candidate_word_lm_boundary_min := -1000000.0;
    features.candidate_word_lm_boundary_max := -1000000.0;
    features.candidate_word_lm_boundary_first := -1000000.0;
    features.candidate_word_lm_boundary_last := -1000000.0;
    features.candidate_word_lm_supported_ratio := -1000000.0;
    features.candidate_word_lm_strong_ratio := -1000000.0;
    features.candidate_word_lm_trigram_ratio := -1000000.0;
    features.candidate_word_lm_zero_count := -1000000.0;
    features.candidate_input_syllable_count := -1000000.0;
    features.candidate_score_per_unit := -1000000.0;
    features.candidate_dict_weight_per_unit := -1000000.0;
    features.candidate_complete_user := -1000000.0;
    features.candidate_complete_dictionary := -1000000.0;
    features.candidate_complete_chain := -1000000.0;
    features.delta_candidate_score := -1000000.0;
    features.delta_dict_weight := -1000000.0;
    features.delta_has_dict_weight := -1000000.0;
    features.delta_source_user := -1000000.0;
    features.delta_source_chain := -1000000.0;
    features.delta_source_pattern := -1000000.0;
    features.delta_source_redup := -1000000.0;
    features.delta_source_local_rerank := -1000000.0;
    features.delta_source_rule_fallback := -1000000.0;
    features.delta_legacy_rank := -1000000.0;
    features.delta_legacy_top := -1000000.0;
    features.delta_chain_rank := -1000000.0;
    features.delta_chain_present := -1000000.0;
    features.delta_chain_first_stage_score := -1000000.0;
    features.delta_chain_second_stage_score := -1000000.0;
    features.delta_chain_score_gap := -1000000.0;
    features.delta_complete_match := -1000000.0;
    features.delta_partial_match := -1000000.0;
    features.delta_text_units := -1000000.0;
    features.delta_comment_length := -1000000.0;
    features.delta_unit_delta := -1000000.0;
    features.delta_path_available := -1000000.0;
    features.delta_path_confidence_score := -1000000.0;
    features.delta_path_confidence_tier := -1000000.0;
    features.delta_path_segments := -1000000.0;
    features.delta_path_single_segments := -1000000.0;
    features.delta_path_max_segment_units := -1000000.0;
    features.delta_char_lm_score := -1000000.0;
    features.delta_char_lm_suffix_score := -1000000.0;
    features.delta_char_lm_context_score := -1000000.0;
    features.delta_char_lm_context_gain := -1000000.0;
    features.delta_has_left_context := -1000000.0;
    features.delta_query_choice_bonus := -1000000.0;
    features.delta_latest_query_choice := -1000000.0;
    features.delta_query_path_bonus := -1000000.0;
    features.delta_query_path_penalty := -1000000.0;
    features.delta_word_lm_bonus := -1000000.0;
    features.delta_word_lm_boundary_count := -1000000.0;
    features.delta_word_lm_boundary_min := -1000000.0;
    features.delta_word_lm_boundary_max := -1000000.0;
    features.delta_word_lm_boundary_first := -1000000.0;
    features.delta_word_lm_boundary_last := -1000000.0;
    features.delta_word_lm_supported_ratio := -1000000.0;
    features.delta_word_lm_strong_ratio := -1000000.0;
    features.delta_word_lm_trigram_ratio := -1000000.0;
    features.delta_word_lm_zero_count := -1000000.0;
    features.delta_input_syllable_count := -1000000.0;
    features.delta_score_per_unit := -1000000.0;
    features.delta_dict_weight_per_unit := -1000000.0;
    features.delta_complete_user := -1000000.0;
    features.delta_complete_dictionary := -1000000.0;
    features.delta_complete_chain := -1000000.0;
    features.candidate_current_rank := -1000000.0;
    features.candidate_ranker_score := -1000000.0;
    features.candidate_ranker_score_gap := -1000000.0;
    features.baseline_ranker_applied := -1000000.0;
    features.baseline_abstain_score := -1000000.0;
    features.different_units := -1000000.0;
    features.different_runs := -1000000.0;
    features.max_different_run := -1000000.0;
    features.same_prefix_units := -1000000.0;
    features.same_suffix_units := -1000000.0;
    features.difference_span_units := -1000000.0;
    features.top_local_lm_r0 := -1000000.0;
    features.candidate_local_lm_r0 := -1000000.0;
    features.delta_local_lm_r0 := -1000000.0;
    features.top_local_lm_r1 := -1000000.0;
    features.candidate_local_lm_r1 := -1000000.0;
    features.delta_local_lm_r1 := -1000000.0;
    features.top_local_lm_r2 := -1000000.0;
    features.candidate_local_lm_r2 := -1000000.0;
    features.delta_local_lm_r2 := -1000000.0;
    features.top_local_lm_r3 := -1000000.0;
    features.candidate_local_lm_r3 := -1000000.0;
    features.delta_local_lm_r3 := -1000000.0;
    features.delta_char_lm_per_difference := -1000000.0;
    features.delta_char_suffix_lm_per_difference := -1000000.0;
    features.delta_word_lm_per_boundary := -1000000.0;
    if long_local_difference_residual_score(features) <>
        c_long_local_difference_residual_reference_score_low then Exit(False);
    features.candidate_candidate_score := 1000000.0;
    features.candidate_dict_weight := 1000000.0;
    features.candidate_has_dict_weight := 1000000.0;
    features.candidate_source_user := 1000000.0;
    features.candidate_source_chain := 1000000.0;
    features.candidate_source_pattern := 1000000.0;
    features.candidate_source_redup := 1000000.0;
    features.candidate_source_local_rerank := 1000000.0;
    features.candidate_source_rule_fallback := 1000000.0;
    features.candidate_legacy_rank := 1000000.0;
    features.candidate_legacy_top := 1000000.0;
    features.candidate_chain_rank := 1000000.0;
    features.candidate_chain_present := 1000000.0;
    features.candidate_chain_first_stage_score := 1000000.0;
    features.candidate_chain_second_stage_score := 1000000.0;
    features.candidate_chain_score_gap := 1000000.0;
    features.candidate_complete_match := 1000000.0;
    features.candidate_partial_match := 1000000.0;
    features.candidate_text_units := 1000000.0;
    features.candidate_comment_length := 1000000.0;
    features.candidate_unit_delta := 1000000.0;
    features.candidate_path_available := 1000000.0;
    features.candidate_path_confidence_score := 1000000.0;
    features.candidate_path_confidence_tier := 1000000.0;
    features.candidate_path_segments := 1000000.0;
    features.candidate_path_single_segments := 1000000.0;
    features.candidate_path_max_segment_units := 1000000.0;
    features.candidate_char_lm_score := 1000000.0;
    features.candidate_char_lm_suffix_score := 1000000.0;
    features.candidate_char_lm_context_score := 1000000.0;
    features.candidate_char_lm_context_gain := 1000000.0;
    features.candidate_has_left_context := 1000000.0;
    features.candidate_query_choice_bonus := 1000000.0;
    features.candidate_latest_query_choice := 1000000.0;
    features.candidate_query_path_bonus := 1000000.0;
    features.candidate_query_path_penalty := 1000000.0;
    features.candidate_word_lm_bonus := 1000000.0;
    features.candidate_word_lm_boundary_count := 1000000.0;
    features.candidate_word_lm_boundary_min := 1000000.0;
    features.candidate_word_lm_boundary_max := 1000000.0;
    features.candidate_word_lm_boundary_first := 1000000.0;
    features.candidate_word_lm_boundary_last := 1000000.0;
    features.candidate_word_lm_supported_ratio := 1000000.0;
    features.candidate_word_lm_strong_ratio := 1000000.0;
    features.candidate_word_lm_trigram_ratio := 1000000.0;
    features.candidate_word_lm_zero_count := 1000000.0;
    features.candidate_input_syllable_count := 1000000.0;
    features.candidate_score_per_unit := 1000000.0;
    features.candidate_dict_weight_per_unit := 1000000.0;
    features.candidate_complete_user := 1000000.0;
    features.candidate_complete_dictionary := 1000000.0;
    features.candidate_complete_chain := 1000000.0;
    features.delta_candidate_score := 1000000.0;
    features.delta_dict_weight := 1000000.0;
    features.delta_has_dict_weight := 1000000.0;
    features.delta_source_user := 1000000.0;
    features.delta_source_chain := 1000000.0;
    features.delta_source_pattern := 1000000.0;
    features.delta_source_redup := 1000000.0;
    features.delta_source_local_rerank := 1000000.0;
    features.delta_source_rule_fallback := 1000000.0;
    features.delta_legacy_rank := 1000000.0;
    features.delta_legacy_top := 1000000.0;
    features.delta_chain_rank := 1000000.0;
    features.delta_chain_present := 1000000.0;
    features.delta_chain_first_stage_score := 1000000.0;
    features.delta_chain_second_stage_score := 1000000.0;
    features.delta_chain_score_gap := 1000000.0;
    features.delta_complete_match := 1000000.0;
    features.delta_partial_match := 1000000.0;
    features.delta_text_units := 1000000.0;
    features.delta_comment_length := 1000000.0;
    features.delta_unit_delta := 1000000.0;
    features.delta_path_available := 1000000.0;
    features.delta_path_confidence_score := 1000000.0;
    features.delta_path_confidence_tier := 1000000.0;
    features.delta_path_segments := 1000000.0;
    features.delta_path_single_segments := 1000000.0;
    features.delta_path_max_segment_units := 1000000.0;
    features.delta_char_lm_score := 1000000.0;
    features.delta_char_lm_suffix_score := 1000000.0;
    features.delta_char_lm_context_score := 1000000.0;
    features.delta_char_lm_context_gain := 1000000.0;
    features.delta_has_left_context := 1000000.0;
    features.delta_query_choice_bonus := 1000000.0;
    features.delta_latest_query_choice := 1000000.0;
    features.delta_query_path_bonus := 1000000.0;
    features.delta_query_path_penalty := 1000000.0;
    features.delta_word_lm_bonus := 1000000.0;
    features.delta_word_lm_boundary_count := 1000000.0;
    features.delta_word_lm_boundary_min := 1000000.0;
    features.delta_word_lm_boundary_max := 1000000.0;
    features.delta_word_lm_boundary_first := 1000000.0;
    features.delta_word_lm_boundary_last := 1000000.0;
    features.delta_word_lm_supported_ratio := 1000000.0;
    features.delta_word_lm_strong_ratio := 1000000.0;
    features.delta_word_lm_trigram_ratio := 1000000.0;
    features.delta_word_lm_zero_count := 1000000.0;
    features.delta_input_syllable_count := 1000000.0;
    features.delta_score_per_unit := 1000000.0;
    features.delta_dict_weight_per_unit := 1000000.0;
    features.delta_complete_user := 1000000.0;
    features.delta_complete_dictionary := 1000000.0;
    features.delta_complete_chain := 1000000.0;
    features.candidate_current_rank := 1000000.0;
    features.candidate_ranker_score := 1000000.0;
    features.candidate_ranker_score_gap := 1000000.0;
    features.baseline_ranker_applied := 1000000.0;
    features.baseline_abstain_score := 1000000.0;
    features.different_units := 1000000.0;
    features.different_runs := 1000000.0;
    features.max_different_run := 1000000.0;
    features.same_prefix_units := 1000000.0;
    features.same_suffix_units := 1000000.0;
    features.difference_span_units := 1000000.0;
    features.top_local_lm_r0 := 1000000.0;
    features.candidate_local_lm_r0 := 1000000.0;
    features.delta_local_lm_r0 := 1000000.0;
    features.top_local_lm_r1 := 1000000.0;
    features.candidate_local_lm_r1 := 1000000.0;
    features.delta_local_lm_r1 := 1000000.0;
    features.top_local_lm_r2 := 1000000.0;
    features.candidate_local_lm_r2 := 1000000.0;
    features.delta_local_lm_r2 := 1000000.0;
    features.top_local_lm_r3 := 1000000.0;
    features.candidate_local_lm_r3 := 1000000.0;
    features.delta_local_lm_r3 := 1000000.0;
    features.delta_char_lm_per_difference := 1000000.0;
    features.delta_char_suffix_lm_per_difference := 1000000.0;
    features.delta_word_lm_per_boundary := 1000000.0;
    if long_local_difference_residual_score(features) <>
        c_long_local_difference_residual_reference_score_high then Exit(False);
    features.candidate_candidate_score := 137.0;
    features.candidate_dict_weight := -274.0;
    features.candidate_has_dict_weight := 411.0;
    features.candidate_source_user := -548.0;
    features.candidate_source_chain := 685.0;
    features.candidate_source_pattern := -822.0;
    features.candidate_source_redup := 959.0;
    features.candidate_source_local_rerank := -1096.0;
    features.candidate_source_rule_fallback := 1233.0;
    features.candidate_legacy_rank := -1370.0;
    features.candidate_legacy_top := 1507.0;
    features.candidate_chain_rank := -1644.0;
    features.candidate_chain_present := 1781.0;
    features.candidate_chain_first_stage_score := -1918.0;
    features.candidate_chain_second_stage_score := 2055.0;
    features.candidate_chain_score_gap := -2192.0;
    features.candidate_complete_match := 2329.0;
    features.candidate_partial_match := -2466.0;
    features.candidate_text_units := 2603.0;
    features.candidate_comment_length := -2740.0;
    features.candidate_unit_delta := 2877.0;
    features.candidate_path_available := -3014.0;
    features.candidate_path_confidence_score := 3151.0;
    features.candidate_path_confidence_tier := -3288.0;
    features.candidate_path_segments := 3425.0;
    features.candidate_path_single_segments := -3562.0;
    features.candidate_path_max_segment_units := 3699.0;
    features.candidate_char_lm_score := -3836.0;
    features.candidate_char_lm_suffix_score := 3973.0;
    features.candidate_char_lm_context_score := -4110.0;
    features.candidate_char_lm_context_gain := 4247.0;
    features.candidate_has_left_context := -4384.0;
    features.candidate_query_choice_bonus := 4521.0;
    features.candidate_latest_query_choice := -4658.0;
    features.candidate_query_path_bonus := 4795.0;
    features.candidate_query_path_penalty := -4932.0;
    features.candidate_word_lm_bonus := 5069.0;
    features.candidate_word_lm_boundary_count := -5206.0;
    features.candidate_word_lm_boundary_min := 5343.0;
    features.candidate_word_lm_boundary_max := -5480.0;
    features.candidate_word_lm_boundary_first := 5617.0;
    features.candidate_word_lm_boundary_last := -5754.0;
    features.candidate_word_lm_supported_ratio := 5891.0;
    features.candidate_word_lm_strong_ratio := -6028.0;
    features.candidate_word_lm_trigram_ratio := 6165.0;
    features.candidate_word_lm_zero_count := -6302.0;
    features.candidate_input_syllable_count := 6439.0;
    features.candidate_score_per_unit := -6576.0;
    features.candidate_dict_weight_per_unit := 6713.0;
    features.candidate_complete_user := -6850.0;
    features.candidate_complete_dictionary := 6987.0;
    features.candidate_complete_chain := -7124.0;
    features.delta_candidate_score := 7261.0;
    features.delta_dict_weight := -7398.0;
    features.delta_has_dict_weight := 7535.0;
    features.delta_source_user := -7672.0;
    features.delta_source_chain := 7809.0;
    features.delta_source_pattern := -7946.0;
    features.delta_source_redup := 8083.0;
    features.delta_source_local_rerank := -8220.0;
    features.delta_source_rule_fallback := 8357.0;
    features.delta_legacy_rank := -8494.0;
    features.delta_legacy_top := 8631.0;
    features.delta_chain_rank := -8768.0;
    features.delta_chain_present := 8905.0;
    features.delta_chain_first_stage_score := -9042.0;
    features.delta_chain_second_stage_score := 9179.0;
    features.delta_chain_score_gap := -9316.0;
    features.delta_complete_match := 9453.0;
    features.delta_partial_match := -9590.0;
    features.delta_text_units := 9727.0;
    features.delta_comment_length := -9864.0;
    features.delta_unit_delta := 10001.0;
    features.delta_path_available := -10138.0;
    features.delta_path_confidence_score := 10275.0;
    features.delta_path_confidence_tier := -10412.0;
    features.delta_path_segments := 10549.0;
    features.delta_path_single_segments := -10686.0;
    features.delta_path_max_segment_units := 10823.0;
    features.delta_char_lm_score := -10960.0;
    features.delta_char_lm_suffix_score := 11097.0;
    features.delta_char_lm_context_score := -11234.0;
    features.delta_char_lm_context_gain := 11371.0;
    features.delta_has_left_context := -11508.0;
    features.delta_query_choice_bonus := 11645.0;
    features.delta_latest_query_choice := -11782.0;
    features.delta_query_path_bonus := 11919.0;
    features.delta_query_path_penalty := -12056.0;
    features.delta_word_lm_bonus := 12193.0;
    features.delta_word_lm_boundary_count := -12330.0;
    features.delta_word_lm_boundary_min := 12467.0;
    features.delta_word_lm_boundary_max := -12604.0;
    features.delta_word_lm_boundary_first := 12741.0;
    features.delta_word_lm_boundary_last := -12878.0;
    features.delta_word_lm_supported_ratio := 13015.0;
    features.delta_word_lm_strong_ratio := -13152.0;
    features.delta_word_lm_trigram_ratio := 13289.0;
    features.delta_word_lm_zero_count := -13426.0;
    features.delta_input_syllable_count := 13563.0;
    features.delta_score_per_unit := -13700.0;
    features.delta_dict_weight_per_unit := 13837.0;
    features.delta_complete_user := -13974.0;
    features.delta_complete_dictionary := 14111.0;
    features.delta_complete_chain := -14248.0;
    features.candidate_current_rank := 14385.0;
    features.candidate_ranker_score := -14522.0;
    features.candidate_ranker_score_gap := 14659.0;
    features.baseline_ranker_applied := -14796.0;
    features.baseline_abstain_score := 14933.0;
    features.different_units := -15070.0;
    features.different_runs := 15207.0;
    features.max_different_run := -15344.0;
    features.same_prefix_units := 15481.0;
    features.same_suffix_units := -15618.0;
    features.difference_span_units := 15755.0;
    features.top_local_lm_r0 := -15892.0;
    features.candidate_local_lm_r0 := 16029.0;
    features.delta_local_lm_r0 := -16166.0;
    features.top_local_lm_r1 := 16303.0;
    features.candidate_local_lm_r1 := -16440.0;
    features.delta_local_lm_r1 := 16577.0;
    features.top_local_lm_r2 := -16714.0;
    features.candidate_local_lm_r2 := 16851.0;
    features.delta_local_lm_r2 := -16988.0;
    features.top_local_lm_r3 := 17125.0;
    features.candidate_local_lm_r3 := -17262.0;
    features.delta_local_lm_r3 := 17399.0;
    features.delta_char_lm_per_difference := -17536.0;
    features.delta_char_suffix_lm_per_difference := 17673.0;
    features.delta_word_lm_per_boundary := -17810.0;
    Result := long_local_difference_residual_score(features) =
        c_long_local_difference_residual_reference_score_mixed;
end;

end.
