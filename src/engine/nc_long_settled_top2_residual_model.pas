unit nc_long_settled_top2_residual_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_long_complete_pool_difference_model;

type
    TncLongSettledTop2ResidualFeatures =
        array[0..202] of Double;

const
    c_long_settled_top2_residual_base_feature_count: Integer = 188;
    c_long_settled_top2_residual_reverse_radius_count: Integer = 5;
    c_long_settled_top2_residual_feature_count: Integer = 203;
    c_long_settled_top2_residual_tree_count: Integer = 256;
    c_long_settled_top2_residual_max_challenger_rank: Integer = 2;
    c_long_settled_top2_residual_threshold: Double = 0.35665201666595175;
    c_long_settled_top2_residual_reference_zero: Double = -0.51153629644382137;
    c_long_settled_top2_residual_reference_low: Double = -3.3563528441199404;
    c_long_settled_top2_residual_reference_high: Double = -0.17678426451434356;
    c_long_settled_top2_residual_reference_mixed: Double = -2.8790714716382766;

procedure build_long_settled_top2_residual_features(
    const base_features: TncLongCompletePoolDifferenceFeatures;
    const top_reverse_scores: array of Integer;
    const candidate_reverse_scores: array of Integer;
    out features: TncLongSettledTop2ResidualFeatures);
function long_settled_top2_residual_score(
    const features: TncLongSettledTop2ResidualFeatures): Double;
function long_settled_top2_residual_self_test: Boolean;

implementation

uses
    Math;

{ Settled long Top1/Top2 bidirectional residual. It compares only existing
  complete long candidates and adds right-context evidence from the reverse
  character LM. One batched runtime query supplies every reverse window.
  Training report SHA-256: 841A8410EE3C422CBFA165123E93AABDF67ADA00A094F32E0B6D3A1E61AED307
  LightGBM model SHA-256: 5618F08CDAD9F708C35A8DECD1C929E6714670B5D10A9EBB7B87A1FA60F97F43 }

procedure build_long_settled_top2_residual_features(
    const base_features: TncLongCompletePoolDifferenceFeatures;
    const top_reverse_scores: array of Integer;
    const candidate_reverse_scores: array of Integer;
    out features: TncLongSettledTop2ResidualFeatures);
var
    idx: Integer;
    offset: Integer;
begin
    FillChar(features, SizeOf(features), 0);
    features[0] := base_features.candidate_candidate_score;
    features[1] := base_features.candidate_dict_weight;
    features[2] := base_features.candidate_has_dict_weight;
    features[3] := base_features.candidate_source_user;
    features[4] := base_features.candidate_source_chain;
    features[5] := base_features.candidate_source_pattern;
    features[6] := base_features.candidate_source_redup;
    features[7] := base_features.candidate_source_local_rerank;
    features[8] := base_features.candidate_source_rule_fallback;
    features[9] := base_features.candidate_legacy_rank;
    features[10] := base_features.candidate_legacy_top;
    features[11] := base_features.candidate_chain_rank;
    features[12] := base_features.candidate_chain_present;
    features[13] := base_features.candidate_chain_first_stage_score;
    features[14] := base_features.candidate_chain_second_stage_score;
    features[15] := base_features.candidate_chain_score_gap;
    features[16] := base_features.candidate_complete_match;
    features[17] := base_features.candidate_partial_match;
    features[18] := base_features.candidate_text_units;
    features[19] := base_features.candidate_comment_length;
    features[20] := base_features.candidate_unit_delta;
    features[21] := base_features.candidate_path_available;
    features[22] := base_features.candidate_path_confidence_score;
    features[23] := base_features.candidate_path_confidence_tier;
    features[24] := base_features.candidate_path_segments;
    features[25] := base_features.candidate_path_single_segments;
    features[26] := base_features.candidate_path_max_segment_units;
    features[27] := base_features.candidate_char_lm_score;
    features[28] := base_features.candidate_char_lm_suffix_score;
    features[29] := base_features.candidate_char_lm_context_score;
    features[30] := base_features.candidate_char_lm_context_gain;
    features[31] := base_features.candidate_has_left_context;
    features[32] := base_features.candidate_query_choice_bonus;
    features[33] := base_features.candidate_latest_query_choice;
    features[34] := base_features.candidate_query_path_bonus;
    features[35] := base_features.candidate_query_path_penalty;
    features[36] := base_features.candidate_word_lm_bonus;
    features[37] := base_features.candidate_word_lm_boundary_count;
    features[38] := base_features.candidate_word_lm_boundary_min;
    features[39] := base_features.candidate_word_lm_boundary_max;
    features[40] := base_features.candidate_word_lm_boundary_first;
    features[41] := base_features.candidate_word_lm_boundary_last;
    features[42] := base_features.candidate_word_lm_supported_ratio;
    features[43] := base_features.candidate_word_lm_strong_ratio;
    features[44] := base_features.candidate_word_lm_trigram_ratio;
    features[45] := base_features.candidate_word_lm_zero_count;
    features[46] := base_features.candidate_input_syllable_count;
    features[47] := base_features.candidate_score_per_unit;
    features[48] := base_features.candidate_dict_weight_per_unit;
    features[49] := base_features.candidate_complete_user;
    features[50] := base_features.candidate_complete_dictionary;
    features[51] := base_features.candidate_complete_chain;
    features[52] := base_features.candidate_complete_pool_present;
    features[53] := base_features.candidate_complete_pool_source_kind;
    features[54] := base_features.candidate_complete_pool_rank;
    features[55] := base_features.candidate_complete_pool_seed_rank;
    features[56] := base_features.candidate_complete_pool_original;
    features[57] := base_features.candidate_complete_pool_substitutions;
    features[58] := base_features.candidate_complete_pool_changed_position;
    features[59] := base_features.candidate_complete_pool_anchor_present;
    features[60] := base_features.candidate_complete_pool_anchor_start;
    features[61] := base_features.candidate_complete_pool_anchor_units;
    features[62] := base_features.candidate_complete_pool_anchor_exact_rank;
    features[63] := base_features.candidate_complete_pool_anchor_source_weight;
    features[64] := base_features.candidate_complete_pool_anchor_replacement_weight;
    features[65] := base_features.candidate_complete_pool_anchor_top_weight;
    features[66] := base_features.candidate_complete_pool_anchor_weight_gain;
    features[67] := base_features.candidate_complete_pool_pair_evidence;
    features[68] := base_features.candidate_complete_pool_proper_name_confidence;
    features[69] := base_features.candidate_complete_pool_signature_support;
    features[70] := base_features.candidate_complete_pool_consensus_support;
    features[71] := base_features.candidate_complete_pool_consensus_seed_count;
    features[72] := base_features.candidate_complete_pool_consensus_support_mean;
    features[73] := base_features.candidate_complete_pool_consensus_support_min;
    features[74] := base_features.candidate_complete_pool_consensus_majority_units;
    features[75] := base_features.candidate_complete_pool_consensus_unanimous_units;
    features[76] := base_features.candidate_complete_pool_consensus_nearest_distance;
    features[77] := base_features.candidate_complete_pool_consensus_mean_distance;
    features[78] := base_features.candidate_complete_pool_consensus_changed_support;
    features[79] := base_features.candidate_complete_pool_consensus_changed_top_match;
    features[80] := base_features.candidate_complete_pool_local_pairwise_score;
    features[81] := base_features.delta_candidate_score;
    features[82] := base_features.delta_dict_weight;
    features[83] := base_features.delta_has_dict_weight;
    features[84] := base_features.delta_source_user;
    features[85] := base_features.delta_source_chain;
    features[86] := base_features.delta_source_pattern;
    features[87] := base_features.delta_source_redup;
    features[88] := base_features.delta_source_local_rerank;
    features[89] := base_features.delta_source_rule_fallback;
    features[90] := base_features.delta_legacy_rank;
    features[91] := base_features.delta_legacy_top;
    features[92] := base_features.delta_chain_rank;
    features[93] := base_features.delta_chain_present;
    features[94] := base_features.delta_chain_first_stage_score;
    features[95] := base_features.delta_chain_second_stage_score;
    features[96] := base_features.delta_chain_score_gap;
    features[97] := base_features.delta_complete_match;
    features[98] := base_features.delta_partial_match;
    features[99] := base_features.delta_text_units;
    features[100] := base_features.delta_comment_length;
    features[101] := base_features.delta_unit_delta;
    features[102] := base_features.delta_path_available;
    features[103] := base_features.delta_path_confidence_score;
    features[104] := base_features.delta_path_confidence_tier;
    features[105] := base_features.delta_path_segments;
    features[106] := base_features.delta_path_single_segments;
    features[107] := base_features.delta_path_max_segment_units;
    features[108] := base_features.delta_char_lm_score;
    features[109] := base_features.delta_char_lm_suffix_score;
    features[110] := base_features.delta_char_lm_context_score;
    features[111] := base_features.delta_char_lm_context_gain;
    features[112] := base_features.delta_has_left_context;
    features[113] := base_features.delta_query_choice_bonus;
    features[114] := base_features.delta_latest_query_choice;
    features[115] := base_features.delta_query_path_bonus;
    features[116] := base_features.delta_query_path_penalty;
    features[117] := base_features.delta_word_lm_bonus;
    features[118] := base_features.delta_word_lm_boundary_count;
    features[119] := base_features.delta_word_lm_boundary_min;
    features[120] := base_features.delta_word_lm_boundary_max;
    features[121] := base_features.delta_word_lm_boundary_first;
    features[122] := base_features.delta_word_lm_boundary_last;
    features[123] := base_features.delta_word_lm_supported_ratio;
    features[124] := base_features.delta_word_lm_strong_ratio;
    features[125] := base_features.delta_word_lm_trigram_ratio;
    features[126] := base_features.delta_word_lm_zero_count;
    features[127] := base_features.delta_input_syllable_count;
    features[128] := base_features.delta_score_per_unit;
    features[129] := base_features.delta_dict_weight_per_unit;
    features[130] := base_features.delta_complete_user;
    features[131] := base_features.delta_complete_dictionary;
    features[132] := base_features.delta_complete_chain;
    features[133] := base_features.delta_complete_pool_present;
    features[134] := base_features.delta_complete_pool_source_kind;
    features[135] := base_features.delta_complete_pool_rank;
    features[136] := base_features.delta_complete_pool_seed_rank;
    features[137] := base_features.delta_complete_pool_original;
    features[138] := base_features.delta_complete_pool_substitutions;
    features[139] := base_features.delta_complete_pool_changed_position;
    features[140] := base_features.delta_complete_pool_anchor_present;
    features[141] := base_features.delta_complete_pool_anchor_start;
    features[142] := base_features.delta_complete_pool_anchor_units;
    features[143] := base_features.delta_complete_pool_anchor_exact_rank;
    features[144] := base_features.delta_complete_pool_anchor_source_weight;
    features[145] := base_features.delta_complete_pool_anchor_replacement_weight;
    features[146] := base_features.delta_complete_pool_anchor_top_weight;
    features[147] := base_features.delta_complete_pool_anchor_weight_gain;
    features[148] := base_features.delta_complete_pool_pair_evidence;
    features[149] := base_features.delta_complete_pool_proper_name_confidence;
    features[150] := base_features.delta_complete_pool_signature_support;
    features[151] := base_features.delta_complete_pool_consensus_support;
    features[152] := base_features.delta_complete_pool_consensus_seed_count;
    features[153] := base_features.delta_complete_pool_consensus_support_mean;
    features[154] := base_features.delta_complete_pool_consensus_support_min;
    features[155] := base_features.delta_complete_pool_consensus_majority_units;
    features[156] := base_features.delta_complete_pool_consensus_unanimous_units;
    features[157] := base_features.delta_complete_pool_consensus_nearest_distance;
    features[158] := base_features.delta_complete_pool_consensus_mean_distance;
    features[159] := base_features.delta_complete_pool_consensus_changed_support;
    features[160] := base_features.delta_complete_pool_consensus_changed_top_match;
    features[161] := base_features.delta_complete_pool_local_pairwise_score;
    features[162] := base_features.candidate_current_rank;
    features[163] := base_features.candidate_ranker_score;
    features[164] := base_features.candidate_ranker_score_gap;
    features[165] := base_features.baseline_ranker_applied;
    features[166] := base_features.baseline_abstain_score;
    features[167] := base_features.different_units;
    features[168] := base_features.different_runs;
    features[169] := base_features.max_different_run;
    features[170] := base_features.same_prefix_units;
    features[171] := base_features.same_suffix_units;
    features[172] := base_features.difference_span_units;
    features[173] := base_features.top_local_lm_r0;
    features[174] := base_features.candidate_local_lm_r0;
    features[175] := base_features.delta_local_lm_r0;
    features[176] := base_features.top_local_lm_r1;
    features[177] := base_features.candidate_local_lm_r1;
    features[178] := base_features.delta_local_lm_r1;
    features[179] := base_features.top_local_lm_r2;
    features[180] := base_features.candidate_local_lm_r2;
    features[181] := base_features.delta_local_lm_r2;
    features[182] := base_features.top_local_lm_r3;
    features[183] := base_features.candidate_local_lm_r3;
    features[184] := base_features.delta_local_lm_r3;
    features[185] := base_features.delta_char_lm_per_difference;
    features[186] := base_features.delta_char_suffix_lm_per_difference;
    features[187] := base_features.delta_word_lm_per_boundary;
    offset := c_long_settled_top2_residual_base_feature_count;
    for idx := 0 to c_long_settled_top2_residual_reverse_radius_count - 1 do
    begin
        if idx < Length(top_reverse_scores) then
            features[offset + idx * 3] := top_reverse_scores[idx];
        if idx < Length(candidate_reverse_scores) then
            features[offset + idx * 3 + 1] := candidate_reverse_scores[idx];
        features[offset + idx * 3 + 2] :=
            features[offset + idx * 3 + 1] - features[offset + idx * 3];
    end;
end;

function settled_top2_residual_tree_0(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -77.499999999999986 then
    begin
        if features[164] <= -181291495.99999997 then
        begin
            if features[199] <= -422.49999999999994 then
            begin
                Result := -2.1499177949683372;
            end
            else
            begin
                Result := -2.1376592757423603;
            end;
        end
        else
        begin
            if features[199] <= -524.49999999999989 then
            begin
                Result := -2.1394263561234892;
            end
            else
            begin
                Result := -2.1170660465070603;
            end;
        end;
    end
    else
    begin
        if features[164] <= -168846951.99999997 then
        begin
            if features[202] <= 163.50000000000003 then
            begin
                Result := -2.1212767666808756;
            end
            else
            begin
                if features[191] <= -6583.4999999999991 then
                begin
                    Result := -2.1243549568791487;
                end
                else
                begin
                    if features[199] <= 484.50000000000006 then
                    begin
                        Result := -2.0862233507342611;
                    end
                    else
                    begin
                        Result := -2.0236071748932316;
                    end;
                end;
            end;
        end
        else
        begin
            if features[9] <= 2.5000000000000004 then
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    if features[151] <= 39.500000000000007 then
                    begin
                        Result := -2.0758642787488371;
                    end
                    else
                    begin
                        Result := -2.1058695100508582;
                    end;
                end
                else
                begin
                    if features[190] <= 132.50000000000003 then
                    begin
                        Result := -2.1403649036325785;
                    end
                    else
                    begin
                        Result := -2.0850253546143507;
                    end;
                end;
            end
            else
            begin
                if features[202] <= 145.50000000000003 then
                begin
                    Result := -2.0767815926073654;
                end
                else
                begin
                    if features[190] <= 2732.0000000000005 then
                    begin
                        Result := -2.0268354259895269;
                    end
                    else
                    begin
                        Result := -2.1242625319991739;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_1(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -88.499999999999986 then
    begin
        if features[164] <= -178293111.99999997 then
        begin
            if features[199] <= -422.49999999999994 then
            begin
                Result := -0.024205864143262742;
            end
            else
            begin
                Result := -0.011883515804035452;
            end;
        end
        else
        begin
            if features[199] <= -510.49999999999994 then
            begin
                Result := -0.0136143442738559;
            end
            else
            begin
                Result := 0.0084803648674883093;
            end;
        end;
    end
    else
    begin
        if features[164] <= -168846951.99999997 then
        begin
            if features[199] <= 201.50000000000003 then
            begin
                Result := 0.0039844933718458323;
            end
            else
            begin
                if features[191] <= -6583.4999999999991 then
                begin
                    Result := 8.5361964665311334E-05;
                end
                else
                begin
                    if features[202] <= 466.50000000000006 then
                    begin
                        Result := 0.042505755696386469;
                    end
                    else
                    begin
                        Result := 0.1066312487122044;
                    end;
                end;
            end;
        end
        else
        begin
            if features[158] <= 2062.5000000000005 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.021865978988887719;
                    end
                    else
                    begin
                        Result := 0.048212163004596457;
                    end;
                end
                else
                begin
                    if features[190] <= -463.49999999999994 then
                    begin
                        Result := 0.061338297262231514;
                    end
                    else
                    begin
                        Result := -0.013005726536271262;
                    end;
                end;
            end
            else
            begin
                if features[202] <= 145.50000000000003 then
                begin
                    Result := 0.044868268749984397;
                end
                else
                begin
                    if features[188] <= -7079.4999999999991 then
                    begin
                        Result := 0.026274437282603494;
                    end
                    else
                    begin
                        Result := 0.091325848157136097;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_2(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -77.499999999999986 then
    begin
        if features[164] <= -181291495.99999997 then
        begin
            if features[199] <= -422.49999999999994 then
            begin
                Result := -0.024036132419666074;
            end
            else
            begin
                Result := -0.011852497376728294;
            end;
        end
        else
        begin
            if features[199] <= -510.49999999999994 then
            begin
                Result := -0.013224259732710814;
            end
            else
            begin
                if features[173] <= -5203.4999999999991 then
                begin
                    Result := 0.01231376313829642;
                end
                else
                begin
                    Result := -0.0062279976064599134;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -168846951.99999997 then
        begin
            if features[202] <= 163.50000000000003 then
            begin
                Result := 0.0043337803130186403;
            end
            else
            begin
                if features[191] <= -6583.4999999999991 then
                begin
                    Result := 0.0016723117628997801;
                end
                else
                begin
                    if features[199] <= 369.50000000000006 then
                    begin
                        Result := 0.026808084629011478;
                    end
                    else
                    begin
                        Result := 0.076998093820580538;
                    end;
                end;
            end;
        end
        else
        begin
            if features[9] <= 2.5000000000000004 then
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    Result := 0.037236718020939044;
                end
                else
                begin
                    Result := 0.0095931630131062314;
                end;
            end
            else
            begin
                if features[199] <= 25.500000000000004 then
                begin
                    Result := 0.027966004176971527;
                end
                else
                begin
                    if features[190] <= 2732.0000000000005 then
                    begin
                        if features[199] <= 304.50000000000006 then
                        begin
                            Result := 0.055816751044218585;
                        end
                        else
                        begin
                            Result := 0.09177694272725874;
                        end;
                    end
                    else
                    begin
                        Result := 0.0024964712742192702;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_3(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -117.49999999999999 then
    begin
        if features[164] <= -194546647.99999997 then
        begin
            Result := -0.021433297228944631;
        end
        else
        begin
            if features[199] <= -510.49999999999994 then
            begin
                Result := -0.013164592837920368;
            end
            else
            begin
                if features[188] <= -3964.9999999999995 then
                begin
                    Result := 0.010314072985205132;
                end
                else
                begin
                    Result := -0.0075030323798004591;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -165715791.99999997 then
        begin
            if features[199] <= 201.50000000000003 then
            begin
                Result := 0.0030869971852975709;
            end
            else
            begin
                if features[188] <= -6553.4999999999991 then
                begin
                    Result := -0.0065871261300315459;
                end
                else
                begin
                    if features[199] <= 484.50000000000006 then
                    begin
                        Result := 0.031481688329373168;
                    end
                    else
                    begin
                        Result := 0.083115419577477645;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    Result := 0.027257275168416278;
                end
                else
                begin
                    if features[199] <= 223.50000000000003 then
                    begin
                        if features[189] <= -4389.4999999999991 then
                        begin
                            Result := 0.032600505085836923;
                        end
                        else
                        begin
                            Result := 0.069872178134330193;
                        end;
                    end
                    else
                    begin
                        if features[154] <= 371.50000000000006 then
                        begin
                            Result := 0.081808679485722055;
                        end
                        else
                        begin
                            Result := 0.020273672401289987;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -366.49999999999994 then
                begin
                    Result := 0.054732720818640258;
                end
                else
                begin
                    Result := -0.007871713163329656;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_4(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -136.49999999999997 then
    begin
        if features[164] <= -175048263.99999997 then
        begin
            Result := -0.02076071019360496;
        end
        else
        begin
            if features[199] <= -524.49999999999989 then
            begin
                Result := -0.01296700756185833;
            end
            else
            begin
                Result := 0.0062929030090302781;
            end;
        end;
    end
    else
    begin
        if features[164] <= -184720071.99999997 then
        begin
            if features[199] <= 223.50000000000003 then
            begin
                Result := -0.00066437196401713291;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := -0.0095350529636579352;
                end
                else
                begin
                    if features[198] <= -5355.4999999999991 then
                    begin
                        Result := 0.014221802268393507;
                    end
                    else
                    begin
                        if features[199] <= 484.50000000000006 then
                        begin
                            Result := 0.038856649382184326;
                        end
                        else
                        begin
                            Result := 0.087713492629490658;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[76] <= 1.5000000000000002 then
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    Result := 0.030772085207276579;
                end
                else
                begin
                    if features[157] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.046046368954807633;
                    end
                    else
                    begin
                        Result := -0.014595486293185534;
                    end;
                end;
            end
            else
            begin
                if features[202] <= 64.500000000000014 then
                begin
                    Result := 0.030496437413775886;
                end
                else
                begin
                    if features[188] <= -7079.4999999999991 then
                    begin
                        Result := 0.017805501946354097;
                    end
                    else
                    begin
                        if features[199] <= 675.50000000000011 then
                        begin
                            Result := 0.058075385815811703;
                        end
                        else
                        begin
                            Result := 0.10927336969770947;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_5(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -136.49999999999997 then
    begin
        if features[164] <= -194546647.99999997 then
        begin
            Result := -0.021405902135314878;
        end
        else
        begin
            if features[199] <= -537.49999999999989 then
            begin
                Result := -0.013774091279527875;
            end
            else
            begin
                Result := 0.0045463888927294843;
            end;
        end;
    end
    else
    begin
        if features[164] <= -184720071.99999997 then
        begin
            if features[199] <= 124.50000000000001 then
            begin
                Result := -0.001928940203624802;
            end
            else
            begin
                if features[191] <= -6623.4999999999991 then
                begin
                    Result := 0.0011514305674365708;
                end
                else
                begin
                    if features[199] <= 369.50000000000006 then
                    begin
                        Result := 0.018799446007474213;
                    end
                    else
                    begin
                        if features[177] <= -6815.4999999999991 then
                        begin
                            Result := 0.08187183719605666;
                        end
                        else
                        begin
                            Result := 0.026584733278513357;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[76] <= 1.5000000000000002 then
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    if features[151] <= 39.500000000000007 then
                    begin
                        Result := 0.03442643929331881;
                    end
                    else
                    begin
                        Result := 0.011881760358091659;
                    end;
                end
                else
                begin
                    if features[190] <= 132.50000000000003 then
                    begin
                        Result := -0.019673366190157932;
                    end
                    else
                    begin
                        Result := 0.029035245186838272;
                    end;
                end;
            end
            else
            begin
                if features[202] <= 64.500000000000014 then
                begin
                    Result := 0.028505633191787984;
                end
                else
                begin
                    if features[190] <= 2732.0000000000005 then
                    begin
                        Result := 0.057491332679192403;
                    end
                    else
                    begin
                        Result := 0.00039913379590768842;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_6(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -136.49999999999997 then
    begin
        if features[164] <= -172095327.99999997 then
        begin
            if features[199] <= -498.49999999999994 then
            begin
                Result := -0.023839902556548744;
            end
            else
            begin
                Result := -0.013009820355869417;
            end;
        end
        else
        begin
            if features[199] <= -510.49999999999994 then
            begin
                Result := -0.012266585050383392;
            end
            else
            begin
                Result := 0.0066814990395586901;
            end;
        end;
    end
    else
    begin
        if features[164] <= -168846951.99999997 then
        begin
            if features[199] <= 124.50000000000001 then
            begin
                Result := -0.00053422999174713916;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := -0.0098460429605098515;
                end
                else
                begin
                    if features[90] <= 10.500000000000002 then
                    begin
                        Result := 0.025580457702354321;
                    end
                    else
                    begin
                        Result := 0.07343683533773751;
                    end;
                end;
            end;
        end
        else
        begin
            if features[202] <= 145.50000000000003 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    Result := 0.028843565115169729;
                end
                else
                begin
                    if features[188] <= -3812.4999999999995 then
                    begin
                        if features[90] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.069206727823882749;
                        end
                        else
                        begin
                            Result := -0.013893219627922632;
                        end;
                    end
                    else
                    begin
                        Result := 0.041917974365150261;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := 0.0079707468986718998;
                end
                else
                begin
                    if features[9] <= 2.5000000000000004 then
                    begin
                        Result := 0.03681688524583708;
                    end
                    else
                    begin
                        Result := 0.064910333958556152;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_7(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -118.49999999999999 then
    begin
        if features[164] <= -204367687.99999997 then
        begin
            Result := -0.021498483207547825;
        end
        else
        begin
            if features[202] <= -460.49999999999994 then
            begin
                Result := -0.014146050240591799;
            end
            else
            begin
                Result := 0.0018333012732935153;
            end;
        end;
    end
    else
    begin
        if features[202] <= 31.500000000000004 then
        begin
            if features[164] <= -197851207.99999997 then
            begin
                Result := -0.0059261577337598667;
            end
            else
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    Result := 0.022445098944527293;
                end
                else
                begin
                    if features[190] <= -109.49999999999999 then
                    begin
                        Result := -0.023274732672018884;
                    end
                    else
                    begin
                        Result := 0.025403918588911962;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[190] <= 1353.5000000000002 then
                begin
                    if features[186] <= -329.83332824707026 then
                    begin
                        Result := -0.0020211956425827625;
                    end
                    else
                    begin
                        Result := 0.034922924535717596;
                    end;
                end
                else
                begin
                    Result := -0.0070963956372933085;
                end;
            end
            else
            begin
                if features[202] <= 295.50000000000006 then
                begin
                    Result := 0.031702814956079649;
                end
                else
                begin
                    if features[191] <= -6583.4999999999991 then
                    begin
                        if features[176] <= -7878.4999999999991 then
                        begin
                            Result := 0.048191102155172146;
                        end
                        else
                        begin
                            Result := -0.0051175796510476443;
                        end;
                    end
                    else
                    begin
                        if features[27] <= -3891.4999999999995 then
                        begin
                            Result := 0.076672602020255262;
                        end
                        else
                        begin
                            Result := 0.029745868578240353;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_8(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -136.49999999999997 then
    begin
        if features[164] <= -172095327.99999997 then
        begin
            if features[202] <= -483.49999999999994 then
            begin
                Result := -0.024614650245041191;
            end
            else
            begin
                Result := -0.013845276761492307;
            end;
        end
        else
        begin
            if features[199] <= -524.49999999999989 then
            begin
                Result := -0.012136523142082068;
            end
            else
            begin
                Result := 0.0059099920735400414;
            end;
        end;
    end
    else
    begin
        if features[164] <= -110756839.99999999 then
        begin
            if features[202] <= 130.50000000000003 then
            begin
                if features[106] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.013014187977871579;
                end
                else
                begin
                    Result := -0.0054256509545006076;
                end;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := -0.007633394569703307;
                end
                else
                begin
                    if features[199] <= 484.50000000000006 then
                    begin
                        if features[18] <= 8.5000000000000018 then
                        begin
                            Result := 0.011213212606567182;
                        end
                        else
                        begin
                            Result := 0.038692309562091916;
                        end;
                    end
                    else
                    begin
                        Result := 0.055374518298860899;
                    end;
                end;
            end;
        end
        else
        begin
            if features[76] <= 1.5000000000000002 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[9] <= 1.5000000000000002 then
                    begin
                        Result := 0.01356311070924268;
                    end
                    else
                    begin
                        Result := 0.038391064795210934;
                    end;
                end
                else
                begin
                    Result := 1.6253745930461671E-05;
                end;
            end
            else
            begin
                if features[166] <= 14076829.500000002 then
                begin
                    Result := 0.051572810794187497;
                end
                else
                begin
                    Result := 0.019700255885070107;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_9(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -118.49999999999999 then
    begin
        if features[202] <= -449.49999999999994 then
        begin
            Result := -0.020233230418347452;
        end
        else
        begin
            if features[82] <= -233.49999999999997 then
            begin
                Result := -0.0088341922443922766;
            end
            else
            begin
                Result := 0.0017954794970546093;
            end;
        end;
    end
    else
    begin
        if features[186] <= -329.83332824707026 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                Result := -0.0099175746257588911;
            end
            else
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.032810206696671312;
                end
                else
                begin
                    Result := 0.006216163156873393;
                end;
            end;
        end
        else
        begin
            if features[202] <= 64.500000000000014 then
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.01868122342361498;
                end
                else
                begin
                    if features[188] <= -3812.4999999999995 then
                    begin
                        Result := -0.016714898542515649;
                    end
                    else
                    begin
                        Result := 0.030962497136415652;
                    end;
                end;
            end
            else
            begin
                if features[18] <= 11.500000000000002 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        if features[188] <= -3966.4999999999995 then
                        begin
                            Result := 0.038381456695731002;
                        end
                        else
                        begin
                            Result := 0.0056715178724836557;
                        end;
                    end
                    else
                    begin
                        Result := 0.014396658492269388;
                    end;
                end
                else
                begin
                    if features[188] <= -7079.4999999999991 then
                    begin
                        Result := -0.0023888310409042024;
                    end
                    else
                    begin
                        if features[202] <= 181.50000000000003 then
                        begin
                            Result := 0.042257536308687227;
                        end
                        else
                        begin
                            Result := 0.068813603522313069;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_10(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -156.49999999999997 then
    begin
        if features[202] <= -438.49999999999994 then
        begin
            Result := -0.019993806494017725;
        end
        else
        begin
            if features[82] <= -233.49999999999997 then
            begin
                Result := -0.0088768859601505469;
            end
            else
            begin
                Result := 0.0019333704272829644;
            end;
        end;
    end
    else
    begin
        if features[202] <= 31.500000000000004 then
        begin
            if features[105] <= 1.0000000180025095E-35 then
            begin
                if features[186] <= -538.24999999999989 then
                begin
                    Result := -0.0071103313459691363;
                end
                else
                begin
                    Result := 0.017506202283191961;
                end;
            end
            else
            begin
                Result := -0.0004185091060943596;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[190] <= 1353.5000000000002 then
                begin
                    if features[186] <= -339.74999999999994 then
                    begin
                        Result := -0.0026196176876910021;
                    end
                    else
                    begin
                        Result := 0.02956810341799139;
                    end;
                end
                else
                begin
                    Result := -0.0081708524963577493;
                end;
            end
            else
            begin
                if features[90] <= 3.5000000000000004 then
                begin
                    if features[176] <= -5314.4999999999991 then
                    begin
                        if features[199] <= 406.50000000000006 then
                        begin
                            Result := 0.02457726950139924;
                        end
                        else
                        begin
                            Result := 0.045133501136352762;
                        end;
                    end
                    else
                    begin
                        Result := 0.0020009718079548751;
                    end;
                end
                else
                begin
                    if features[199] <= 304.50000000000006 then
                    begin
                        Result := 0.034862490334049673;
                    end
                    else
                    begin
                        if features[149] <= -819.99999999999989 then
                        begin
                            Result := -0.026096903326107663;
                        end
                        else
                        begin
                            Result := 0.066348989957960375;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_11(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -187.49999999999997 then
    begin
        if features[164] <= -141296575.99999997 then
        begin
            if features[199] <= -524.49999999999989 then
            begin
                Result := -0.023086417626841341;
            end
            else
            begin
                Result := -0.011942543054865876;
            end;
        end
        else
        begin
            if features[202] <= -544.49999999999989 then
            begin
                Result := -0.013339582844503581;
            end
            else
            begin
                Result := 0.004268596441704047;
            end;
        end;
    end
    else
    begin
        if features[164] <= -194546647.99999997 then
        begin
            if features[202] <= 163.50000000000003 then
            begin
                Result := -0.0035122146619022648;
            end
            else
            begin
                if features[191] <= -6583.4999999999991 then
                begin
                    Result := -0.0025192176629597815;
                end
                else
                begin
                    Result := 0.0326958794959381;
                end;
            end;
        end
        else
        begin
            if features[202] <= 115.50000000000001 then
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    Result := 0.02147324387159999;
                end
                else
                begin
                    if features[189] <= -3965.4999999999995 then
                    begin
                        Result := -0.022529159483614988;
                    end
                    else
                    begin
                        if features[176] <= -7289.4999999999991 then
                        begin
                            Result := 0.051603875602327744;
                        end
                        else
                        begin
                            Result := 0.0047193157033040764;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[190] <= 1353.5000000000002 then
                    begin
                        Result := 0.030347252022715984;
                    end
                    else
                    begin
                        Result := -0.0028411500820113389;
                    end;
                end
                else
                begin
                    if features[179] <= -5225.4999999999991 then
                    begin
                        Result := 0.044858812253638504;
                    end
                    else
                    begin
                        Result := 0.005614778382933892;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_12(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -176.49999999999997 then
    begin
        if features[164] <= -156440759.99999997 then
        begin
            if features[199] <= -524.49999999999989 then
            begin
                Result := -0.023235018946231437;
            end
            else
            begin
                Result := -0.012193842597684058;
            end;
        end
        else
        begin
            if features[199] <= -815.49999999999989 then
            begin
                Result := -0.016107490278882041;
            end
            else
            begin
                Result := 0.0026781223426748158;
            end;
        end;
    end
    else
    begin
        if features[164] <= -184720071.99999997 then
        begin
            if features[199] <= 124.50000000000001 then
            begin
                Result := -0.0039158619854134571;
            end
            else
            begin
                if features[188] <= -6553.4999999999991 then
                begin
                    Result := -0.0049609075427502862;
                end
                else
                begin
                    if features[199] <= 484.50000000000006 then
                    begin
                        Result := 0.016736269890038791;
                    end
                    else
                    begin
                        Result := 0.054372389593110637;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[54] <= 1.5000000000000002 then
                begin
                    Result := 0.0098945331607047833;
                end
                else
                begin
                    if features[164] <= -57023309.999999993 then
                    begin
                        if features[198] <= -4971.4999999999991 then
                        begin
                            Result := 0.020053562616092629;
                        end
                        else
                        begin
                            Result := 0.036477940652842121;
                        end;
                    end
                    else
                    begin
                        Result := 0.043306843320413763;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -366.49999999999994 then
                begin
                    Result := 0.035740129444661248;
                end
                else
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        Result := -0.017866173269315156;
                    end
                    else
                    begin
                        Result := 0.029290098844483005;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_13(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.022451771863168241;
        end
        else
        begin
            if features[199] <= -873.49999999999989 then
            begin
                Result := -0.017714686564916159;
            end
            else
            begin
                Result := -0.0033181260747803427;
            end;
        end;
    end
    else
    begin
        if features[202] <= 31.500000000000004 then
        begin
            if features[164] <= -197851207.99999997 then
            begin
                Result := -0.0079815132760267804;
            end
            else
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.017008049882799962;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0099709540456655102;
                    end
                    else
                    begin
                        Result := -0.023088989310613848;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -7079.4999999999991 then
            begin
                Result := -8.7836308600775133E-05;
            end
            else
            begin
                if features[199] <= 484.50000000000006 then
                begin
                    if features[18] <= 12.500000000000002 then
                    begin
                        if features[179] <= -5225.4999999999991 then
                        begin
                            if features[126] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.0272830237279338;
                            end
                            else
                            begin
                                Result := 0.0076350182666153248;
                            end;
                        end
                        else
                        begin
                            Result := -0.005581302420008742;
                        end;
                    end
                    else
                    begin
                        Result := 0.040160617661152441;
                    end;
                end
                else
                begin
                    if features[182] <= -5070.4999999999991 then
                    begin
                        if features[201] <= -4669.4999999999991 then
                        begin
                            Result := 0.036491305473272756;
                        end
                        else
                        begin
                            Result := 0.07111793494343753;
                        end;
                    end
                    else
                    begin
                        Result := 0.010260078110428353;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_14(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.022339557931400175;
        end
        else
        begin
            if features[202] <= -719.49999999999989 then
            begin
                Result := -0.018415853562321772;
            end
            else
            begin
                Result := -0.0035052176958476179;
            end;
        end;
    end
    else
    begin
        if features[202] <= 31.500000000000004 then
        begin
            if features[164] <= -204367687.99999997 then
            begin
                Result := -0.0086825683353600417;
            end
            else
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.015149192202055765;
                end
                else
                begin
                    if features[188] <= -3833.4999999999995 then
                    begin
                        Result := -0.021550822519247267;
                    end
                    else
                    begin
                        Result := 0.013392651605392115;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -7079.4999999999991 then
            begin
                Result := 0.0010522511187149055;
            end
            else
            begin
                if features[202] <= 353.50000000000006 then
                begin
                    if features[176] <= -5889.4999999999991 then
                    begin
                        if features[18] <= 12.500000000000002 then
                        begin
                            if features[164] <= -297087183.99999994 then
                            begin
                                Result := -0.0080444353550767692;
                            end
                            else
                            begin
                                if features[90] <= 3.5000000000000004 then
                                begin
                                    Result := 0.018755571910249291;
                                end
                                else
                                begin
                                    Result := 0.040010097478904494;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.043133771582464731;
                        end;
                    end
                    else
                    begin
                        Result := 0.0040174810195996091;
                    end;
                end
                else
                begin
                    if features[179] <= -5994.4999999999991 then
                    begin
                        Result := 0.051916210834650534;
                    end
                    else
                    begin
                        Result := 0.019841582746367482;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_15(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -204367687.99999997 then
        begin
            Result := -0.022191203325008985;
        end
        else
        begin
            if features[199] <= -873.49999999999989 then
            begin
                Result := -0.017535539314308995;
            end
            else
            begin
                Result := -0.0034090335567859005;
            end;
        end;
    end
    else
    begin
        if features[164] <= -135192759.99999997 then
        begin
            if features[202] <= 31.500000000000004 then
            begin
                if features[164] <= -260459519.99999997 then
                begin
                    Result := -0.012205378497378558;
                end
                else
                begin
                    Result := 0.0016775613808959562;
                end;
            end
            else
            begin
                if features[191] <= -6623.4999999999991 then
                begin
                    Result := -0.0013647142615923246;
                end
                else
                begin
                    if features[199] <= 369.50000000000006 then
                    begin
                        Result := 0.01309622645013523;
                    end
                    else
                    begin
                        Result := 0.040734533401896929;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[9] <= 1.5000000000000002 then
                begin
                    Result := 0.0085143859467395593;
                end
                else
                begin
                    if features[164] <= -57023309.999999993 then
                    begin
                        if features[202] <= 145.50000000000003 then
                        begin
                            Result := 0.017595434082635884;
                        end
                        else
                        begin
                            Result := 0.03352441954954187;
                        end;
                    end
                    else
                    begin
                        Result := 0.038737274779640667;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -306.49999999999994 then
                begin
                    Result := 0.026499017394216413;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.058127160701507891;
                    end
                    else
                    begin
                        Result := -0.018146100611974792;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_16(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -156440759.99999997 then
        begin
            Result := -0.020645691891346941;
        end
        else
        begin
            if features[200] <= -4733.4999999999991 then
            begin
                Result := 0.0037997727158217451;
            end
            else
            begin
                Result := -0.010994639685556305;
            end;
        end;
    end
    else
    begin
        if features[199] <= 1.0000000180025095E-35 then
        begin
            if features[164] <= -234501855.99999997 then
            begin
                Result := -0.010572856651521891;
            end
            else
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.012277293652591498;
                end
                else
                begin
                    if features[188] <= -3833.4999999999995 then
                    begin
                        Result := -0.021655836441945967;
                    end
                    else
                    begin
                        Result := 0.01170351053605405;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[190] <= 1353.5000000000002 then
                begin
                    if features[186] <= -200.83333587646482 then
                    begin
                        Result := 0.0014621963358202115;
                    end
                    else
                    begin
                        Result := 0.025606488725410888;
                    end;
                end
                else
                begin
                    Result := -0.0089858302369913295;
                end;
            end
            else
            begin
                if features[9] <= 2.5000000000000004 then
                begin
                    if features[164] <= -217627575.99999997 then
                    begin
                        Result := -0.0041668096975895474;
                    end
                    else
                    begin
                        Result := 0.020315529334645314;
                    end;
                end
                else
                begin
                    if features[199] <= 335.50000000000006 then
                    begin
                        Result := 0.024116980335387242;
                    end
                    else
                    begin
                        if features[187] <= -21.522727012634274 then
                        begin
                            Result := 0.018713532700679738;
                        end
                        else
                        begin
                            Result := 0.051479810148172815;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_17(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -141.49999999999997 then
    begin
        if features[164] <= -156440759.99999997 then
        begin
            if features[202] <= -483.49999999999994 then
            begin
                Result := -0.02335554844658165;
            end
            else
            begin
                Result := -0.012456795662769877;
            end;
        end
        else
        begin
            if features[202] <= -544.49999999999989 then
            begin
                Result := -0.013308653293136491;
            end
            else
            begin
                Result := 0.003660429694086273;
            end;
        end;
    end
    else
    begin
        if features[164] <= -135192759.99999997 then
        begin
            if features[202] <= 76.500000000000014 then
            begin
                Result := -0.00020833848066263407;
            end
            else
            begin
                if features[191] <= -6623.4999999999991 then
                begin
                    Result := -0.0011128464839668002;
                end
                else
                begin
                    if features[165] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0048710862555223665;
                    end
                    else
                    begin
                        if features[202] <= 353.50000000000006 then
                        begin
                            Result := 0.021286141470835865;
                        end
                        else
                        begin
                            Result := 0.045157732336259422;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[9] <= 1.5000000000000002 then
                begin
                    Result := 0.0072957804210256536;
                end
                else
                begin
                    Result := 0.028009557387751301;
                end;
            end
            else
            begin
                if features[190] <= -366.49999999999994 then
                begin
                    Result := 0.032903322475201432;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.044880164899987002;
                    end
                    else
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := -0.023230470025831784;
                        end
                        else
                        begin
                            Result := 0.029043290564391686;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_18(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.022369174325347421;
        end
        else
        begin
            if features[202] <= -719.49999999999989 then
            begin
                Result := -0.018774867394438184;
            end
            else
            begin
                Result := -0.0046180435925392387;
            end;
        end;
    end
    else
    begin
        if features[164] <= -135192759.99999997 then
        begin
            if features[199] <= 95.500000000000014 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.0015894909707047681;
                end
                else
                begin
                    Result := -0.013144353957471745;
                end;
            end
            else
            begin
                if features[191] <= -6623.4999999999991 then
                begin
                    Result := -0.0018554552079705279;
                end
                else
                begin
                    if features[199] <= 369.50000000000006 then
                    begin
                        if features[185] <= -220.74999999999997 then
                        begin
                            Result := -0.00063612488967851647;
                        end
                        else
                        begin
                            Result := 0.021709013756969382;
                        end;
                    end
                    else
                    begin
                        if features[163] <= -191021951.99999997 then
                        begin
                            Result := 0.069535655188015341;
                        end
                        else
                        begin
                            Result := 0.027928200501799977;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[199] <= 25.500000000000004 then
            begin
                if features[173] <= -5203.4999999999991 then
                begin
                    Result := 0.01561354097614989;
                end
                else
                begin
                    if features[173] <= -5202.4999999999991 then
                    begin
                        Result := -0.021879303186419223;
                    end
                    else
                    begin
                        Result := 0.013257083981009775;
                    end;
                end;
            end
            else
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := 0.02116125709940803;
                end
                else
                begin
                    Result := 0.038020274524215719;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_19(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -156440759.99999997 then
        begin
            Result := -0.020009490012578887;
        end
        else
        begin
            if features[202] <= -719.49999999999989 then
            begin
                Result := -0.016566401290512827;
            end
            else
            begin
                Result := -0.0013490408540584281;
            end;
        end;
    end
    else
    begin
        if features[202] <= 31.500000000000004 then
        begin
            if features[164] <= -204367687.99999997 then
            begin
                Result := -0.0074633176714767038;
            end
            else
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.013010196444524828;
                end
                else
                begin
                    if features[188] <= -3833.4999999999995 then
                    begin
                        Result := -0.021092744253086465;
                    end
                    else
                    begin
                        Result := 0.011312056931536241;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -7079.4999999999991 then
            begin
                Result := -0.00013990243210460751;
            end
            else
            begin
                if features[176] <= -5255.4999999999991 then
                begin
                    if features[90] <= 2.5000000000000004 then
                    begin
                        if features[143] <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.052341352071853975;
                        end
                        else
                        begin
                            if features[74] <= 11.500000000000002 then
                            begin
                                Result := 0.014972656028712642;
                            end
                            else
                            begin
                                Result := 0.034241291695591945;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[27] <= -5594.4999999999991 then
                        begin
                            Result := 0.050633681821861266;
                        end
                        else
                        begin
                            if features[105] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.036371437836093826;
                            end
                            else
                            begin
                                Result := 0.012933745595039967;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.00050855870898292455;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_20(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[196] <= -91.499999999999986 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.01897999642731138;
        end
        else
        begin
            if features[196] <= -819.49999999999989 then
            begin
                Result := -0.013115144532280075;
            end
            else
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.0048285967317399578;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 2.9459333174572299E-05;
                    end
                    else
                    begin
                        Result := -0.023512429441840933;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[186] <= -329.83332824707026 then
        begin
            if features[177] <= -6686.4999999999991 then
            begin
                if features[164] <= -200968455.99999997 then
                begin
                    Result := -0.0033155194032244446;
                end
                else
                begin
                    Result := 0.019249030402958341;
                end;
            end
            else
            begin
                Result := -0.017557636010790776;
            end;
        end
        else
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[189] <= -4389.4999999999991 then
                    begin
                        Result := 0.021769091639117881;
                    end
                    else
                    begin
                        if features[171] <= 1.5000000000000002 then
                        begin
                            Result := 0.0089156084761501924;
                        end
                        else
                        begin
                            Result := 0.048752610075820747;
                        end;
                    end;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[174] <= -6719.4999999999991 then
                        begin
                            Result := 0.018867063261371969;
                        end
                        else
                        begin
                            Result := -0.022199194708621806;
                        end;
                    end
                    else
                    begin
                        Result := 0.031574603432281086;
                    end;
                end;
            end
            else
            begin
                Result := 0.0079482738363346097;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_21(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.021593119411655398;
        end
        else
        begin
            if features[199] <= -1032.4999999999998 then
            begin
                Result := -0.020052373582713931;
            end
            else
            begin
                Result := -0.0041322699129240741;
            end;
        end;
    end
    else
    begin
        if features[164] <= -172095327.99999997 then
        begin
            if features[199] <= 52.500000000000007 then
            begin
                Result := -0.0053200759991217667;
            end
            else
            begin
                if features[90] <= 10.500000000000002 then
                begin
                    Result := 0.0065721338761253788;
                end
                else
                begin
                    Result := 0.033922417479843259;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[199] <= -39.499999999999993 then
                begin
                    Result := 0.011515520763764109;
                end
                else
                begin
                    if features[191] <= -6254.4999999999991 then
                    begin
                        Result := 0.015423667128407637;
                    end
                    else
                    begin
                        if features[177] <= -7814.4999999999991 then
                        begin
                            Result := 0.04094865975181556;
                        end
                        else
                        begin
                            if features[108] <= -100.49999999999999 then
                            begin
                                Result := 0.011418156070327486;
                            end
                            else
                            begin
                                Result := 0.030768976792689924;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -310.49999999999994 then
                begin
                    Result := 0.019431352099454929;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.049260955570854061;
                    end
                    else
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := -0.022812026524177322;
                        end
                        else
                        begin
                            Result := 0.026104527838026376;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_22(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -138339743.99999997 then
        begin
            Result := -0.019510688938790308;
        end
        else
        begin
            if features[200] <= -4614.4999999999991 then
            begin
                Result := 0.0046328713840511375;
            end
            else
            begin
                Result := -0.0096809144868056415;
            end;
        end;
    end
    else
    begin
        if features[202] <= 145.50000000000003 then
        begin
            if features[164] <= -204367687.99999997 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0011283339508813938;
                end
                else
                begin
                    Result := -0.017217370451317018;
                end;
            end
            else
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.015533060298892202;
                    end
                    else
                    begin
                        Result := 0.004253315035507986;
                    end;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.011232615025068414;
                    end
                    else
                    begin
                        if features[90] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.058220166902970397;
                        end
                        else
                        begin
                            Result := -0.022409586973645382;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -7079.4999999999991 then
            begin
                Result := -0.0023496216637992999;
            end
            else
            begin
                if features[18] <= 10.500000000000002 then
                begin
                    if features[176] <= -5801.4999999999991 then
                    begin
                        if features[201] <= -6060.4999999999991 then
                        begin
                            Result := -0.004866712577363673;
                        end
                        else
                        begin
                            Result := 0.025275667527590182;
                        end;
                    end
                    else
                    begin
                        Result := 0.00061856812147700934;
                    end;
                end
                else
                begin
                    Result := 0.038364179877835976;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_23(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -258.49999999999994 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.021207415974554809;
        end
        else
        begin
            if features[200] <= -4733.4999999999991 then
            begin
                Result := 0.0017338270004468642;
            end
            else
            begin
                Result := -0.01168107793382088;
            end;
        end;
    end
    else
    begin
        if features[164] <= -227728639.99999997 then
        begin
            if features[202] <= 181.50000000000003 then
            begin
                Result := -0.0077939757484430383;
            end
            else
            begin
                if features[191] <= -6371.4999999999991 then
                begin
                    Result := -0.0038152759089792772;
                end
                else
                begin
                    Result := 0.023868224255300552;
                end;
            end;
        end
        else
        begin
            if features[202] <= 130.50000000000003 then
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        if features[169] <= 1.5000000000000002 then
                        begin
                            Result := 0.01140804392776747;
                        end
                        else
                        begin
                            Result := 0.02361202974365036;
                        end;
                    end
                    else
                    begin
                        if features[191] <= -4156.4999999999991 then
                        begin
                            Result := 0.0011135295629594755;
                        end
                        else
                        begin
                            Result := 0.040756053444172269;
                        end;
                    end;
                end
                else
                begin
                    if features[188] <= -3833.4999999999995 then
                    begin
                        Result := -0.019619034787017198;
                    end
                    else
                    begin
                        Result := 0.011128833544317283;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := 0.00030381471885184449;
                end
                else
                begin
                    if features[9] <= 2.5000000000000004 then
                    begin
                        Result := 0.017489003594753805;
                    end
                    else
                    begin
                        Result := 0.033110840753482668;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_24(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -221021911.99999997 then
        begin
            Result := -0.021519473040348888;
        end
        else
        begin
            if features[199] <= -894.49999999999989 then
            begin
                Result := -0.017539488277473831;
            end
            else
            begin
                Result := -0.0034559470360746147;
            end;
        end;
    end
    else
    begin
        if features[199] <= -28.499999999999996 then
        begin
            if features[164] <= -256588463.99999997 then
            begin
                Result := -0.010654374621930529;
            end
            else
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.0088353781833735694;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0043737892548549135;
                    end
                    else
                    begin
                        Result := -0.022986072129339064;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[186] <= -221.83333587646482 then
                begin
                    Result := -0.0077349438743739563;
                end
                else
                begin
                    if features[176] <= -10424.499999999998 then
                    begin
                        Result := -0.013934851056967663;
                    end
                    else
                    begin
                        Result := 0.017702817450922531;
                    end;
                end;
            end
            else
            begin
                if features[199] <= 335.50000000000006 then
                begin
                    if features[164] <= -187995415.99999997 then
                    begin
                        Result := 0.003958354075609182;
                    end
                    else
                    begin
                        Result := 0.018657252915291987;
                    end;
                end
                else
                begin
                    if features[149] <= -819.99999999999989 then
                    begin
                        Result := -0.028213387897005046;
                    end
                    else
                    begin
                        if features[9] <= 3.5000000000000004 then
                        begin
                            Result := 0.021531719130812484;
                        end
                        else
                        begin
                            Result := 0.0397731633061294;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_25(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[199] <= -663.49999999999989 then
        begin
            Result := -0.019279068456535643;
        end
        else
        begin
            Result := -0.006981604732425992;
        end;
    end
    else
    begin
        if features[199] <= -28.499999999999996 then
        begin
            if features[106] <= 1.0000000180025095E-35 then
            begin
                if features[124] <= -167.99999999999997 then
                begin
                    Result := -0.0098289749988082001;
                end
                else
                begin
                    Result := 0.0073306624155476249;
                end;
            end
            else
            begin
                Result := -0.0046738518361540589;
            end;
        end
        else
        begin
            if features[18] <= 12.500000000000002 then
            begin
                if features[179] <= -5129.4999999999991 then
                begin
                    if features[188] <= -6199.9999999999991 then
                    begin
                        Result := 0.0019651236370939319;
                    end
                    else
                    begin
                        if features[202] <= 466.50000000000006 then
                        begin
                            if features[173] <= -9027.4999999999982 then
                            begin
                                Result := -0.002644039749447671;
                            end
                            else
                            begin
                                if features[148] <= 1147.0000000000002 then
                                begin
                                    if features[28] <= -7865.4999999999991 then
                                    begin
                                        Result := 0.046554644724155221;
                                    end
                                    else
                                    begin
                                        Result := 0.012858223401281347;
                                    end;
                                end
                                else
                                begin
                                    if features[177] <= -6772.4999999999991 then
                                    begin
                                        Result := 0.040783143054188606;
                                    end
                                    else
                                    begin
                                        Result := 0.0062391057922429171;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.045393632919400295;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.005938583076167534;
                end;
            end
            else
            begin
                if features[189] <= -3832.4999999999995 then
                begin
                    Result := 0.024625618603864186;
                end
                else
                begin
                    Result := 0.057292795693823985;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_26(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -141296575.99999997 then
        begin
            Result := -0.01909570880347734;
        end
        else
        begin
            if features[202] <= -832.49999999999989 then
            begin
                Result := -0.017744047206756607;
            end
            else
            begin
                Result := -0.00046162345400313796;
            end;
        end;
    end
    else
    begin
        if features[202] <= -28.499999999999996 then
        begin
            if features[164] <= -60625469.999999993 then
            begin
                Result := -0.0014474457133956703;
            end
            else
            begin
                Result := 0.013862986984263581;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[190] <= -533.49999999999989 then
                    begin
                        Result := 0.030831426887292596;
                    end
                    else
                    begin
                        Result := -0.0019242370821829589;
                    end;
                end
                else
                begin
                    Result := 0.043944559186035709;
                end;
            end
            else
            begin
                if features[199] <= 406.50000000000006 then
                begin
                    if features[164] <= -284306271.99999994 then
                    begin
                        Result := -0.0040650187974987364;
                    end
                    else
                    begin
                        if features[173] <= -4956.9999999999991 then
                        begin
                            if features[188] <= -4382.4999999999991 then
                            begin
                                if features[189] <= -4389.4999999999991 then
                                begin
                                    Result := 0.014822474810197462;
                                end
                                else
                                begin
                                    Result := 0.03640151621274286;
                                end;
                            end
                            else
                            begin
                                Result := 0.0018826659035603651;
                            end;
                        end
                        else
                        begin
                            Result := 0.032151534470854823;
                        end;
                    end;
                end
                else
                begin
                    if features[149] <= -819.99999999999989 then
                    begin
                        Result := -0.027757062722515859;
                    end
                    else
                    begin
                        Result := 0.031459461220863717;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_27(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -138339743.99999997 then
        begin
            Result := -0.018814258373933086;
        end
        else
        begin
            if features[197] <= -5706.4999999999991 then
            begin
                Result := 0.016290654159951009;
            end
            else
            begin
                if features[176] <= -7371.4999999999991 then
                begin
                    Result := -0.013175457445451143;
                end
                else
                begin
                    Result := 0.00038663880911852535;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[199] <= 530.50000000000011 then
            begin
                Result := -0.0085952373504055313;
            end
            else
            begin
                if features[193] <= 808.50000000000011 then
                begin
                    Result := 0.051713560076558578;
                end
                else
                begin
                    Result := 0.001265330201902595;
                end;
            end;
        end
        else
        begin
            if features[199] <= -48.499999999999993 then
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.0076161179715693765;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0072211496693667795;
                    end
                    else
                    begin
                        Result := -0.023417654105486605;
                    end;
                end;
            end
            else
            begin
                if features[90] <= 3.5000000000000004 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0040131209026025945;
                    end
                    else
                    begin
                        if features[188] <= -3966.4999999999995 then
                        begin
                            Result := 0.017581051249675326;
                        end
                        else
                        begin
                            Result := 7.3098864823891493E-05;
                        end;
                    end;
                end
                else
                begin
                    if features[27] <= -4891.4999999999991 then
                    begin
                        Result := 0.032500623987537329;
                    end
                    else
                    begin
                        Result := 0.013879109048421517;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_28(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.021117172333683567;
        end
        else
        begin
            if features[199] <= -873.49999999999989 then
            begin
                Result := -0.016270152272464117;
            end
            else
            begin
                Result := -0.0028764519328048034;
            end;
        end;
    end
    else
    begin
        if features[164] <= -135192759.99999997 then
        begin
            if features[199] <= 95.500000000000014 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.00046997308268461463;
                end
                else
                begin
                    Result := -0.013025484347530869;
                end;
            end
            else
            begin
                if features[90] <= 10.500000000000002 then
                begin
                    if features[188] <= -5791.4999999999991 then
                    begin
                        Result := -0.0046815882435965964;
                    end
                    else
                    begin
                        Result := 0.012299921465679804;
                    end;
                end
                else
                begin
                    Result := 0.032118227692243609;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[54] <= 1.5000000000000002 then
                begin
                    Result := 0.003777807625743887;
                end
                else
                begin
                    if features[164] <= -29647121.999999996 then
                    begin
                        Result := 0.016033550880426812;
                    end
                    else
                    begin
                        Result := 0.031914395193833961;
                    end;
                end;
            end
            else
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    Result := 0.014936225833852831;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[189] <= -3832.4999999999995 then
                        begin
                            Result := 0.10761246123493096;
                        end
                        else
                        begin
                            Result := 0.0013043559614664114;
                        end;
                    end
                    else
                    begin
                        Result := -0.019750458126169962;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_29(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.020436442871439892;
        end
        else
        begin
            if features[199] <= -873.49999999999989 then
            begin
                Result := -0.015797926285201942;
            end
            else
            begin
                Result := -0.0021085471653770789;
            end;
        end;
    end
    else
    begin
        if features[164] <= -172095327.99999997 then
        begin
            if features[199] <= 124.50000000000001 then
            begin
                Result := -0.004490028061866126;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := -0.0099168961126485811;
                end
                else
                begin
                    if features[27] <= -5475.4999999999991 then
                    begin
                        if features[198] <= -5338.4999999999991 then
                        begin
                            Result := 0.01041541357446361;
                        end
                        else
                        begin
                            Result := 0.048634361939117965;
                        end;
                    end
                    else
                    begin
                        Result := 0.0076192725121040326;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[77] <= 3268.0000000000005 then
                begin
                    Result := 0.0087400475067678403;
                end
                else
                begin
                    if features[164] <= -41699193.999999993 then
                    begin
                        Result := 0.015560477290307776;
                    end
                    else
                    begin
                        Result := 0.029412376770554791;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -310.49999999999994 then
                begin
                    Result := 0.015060893248066379;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[9] <= 1.5000000000000002 then
                        begin
                            Result := 0.063563556744862942;
                        end
                        else
                        begin
                            Result := -0.020732894872387359;
                        end;
                    end
                    else
                    begin
                        Result := 0.017258084086593128;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_30(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[199] <= -873.49999999999989 then
        begin
            Result := -0.020955885487022232;
        end
        else
        begin
            if features[186] <= -366.74999999999994 then
            begin
                Result := -0.014202597198387446;
            end
            else
            begin
                Result := -0.0045626458651554409;
            end;
        end;
    end
    else
    begin
        if features[199] <= 1.0000000180025095E-35 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[169] <= 1.5000000000000002 then
                begin
                    Result := 0.0025017509002790927;
                end
                else
                begin
                    if features[175] <= -706.49999999999989 then
                    begin
                        Result := 0.003535652125517123;
                    end
                    else
                    begin
                        Result := 0.026710157222223946;
                    end;
                end;
            end
            else
            begin
                Result := -0.0051331036444873853;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[172] <= 4.5000000000000009 then
                begin
                    if features[190] <= -676.49999999999989 then
                    begin
                        Result := 0.035463778370048903;
                    end
                    else
                    begin
                        Result := -0.00089993627106518196;
                    end;
                end
                else
                begin
                    Result := 0.053167629658404741;
                end;
            end
            else
            begin
                if features[199] <= 406.50000000000006 then
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        if features[176] <= -5801.4999999999991 then
                        begin
                            if features[190] <= 663.50000000000011 then
                            begin
                                Result := 0.01588611065613562;
                            end
                            else
                            begin
                                Result := 0.031971766444318574;
                            end;
                        end
                        else
                        begin
                            Result := 0.0;
                        end;
                    end
                    else
                    begin
                        Result := 0.0045323049907898677;
                    end;
                end
                else
                begin
                    Result := 0.026759255490623957;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_31(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.020570284891899434;
        end
        else
        begin
            if features[199] <= -894.49999999999989 then
            begin
                Result := -0.016028564195495639;
            end
            else
            begin
                Result := -0.0026588982640334152;
            end;
        end;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[202] <= 380.50000000000006 then
            begin
                Result := -0.0081167609622441114;
            end
            else
            begin
                if features[188] <= -6553.4999999999991 then
                begin
                    Result := -0.0063501961213376524;
                end
                else
                begin
                    Result := 0.03113963933294327;
                end;
            end;
        end
        else
        begin
            if features[199] <= -48.499999999999993 then
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.0065509810877749184;
                end
                else
                begin
                    if features[188] <= -3833.4999999999995 then
                    begin
                        Result := -0.019506399870108923;
                    end
                    else
                    begin
                        Result := 0.0070713216799098482;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -5314.4999999999991 then
                begin
                    if features[188] <= -6199.9999999999991 then
                    begin
                        Result := 0.0050205353828408055;
                    end
                    else
                    begin
                        if features[202] <= 353.50000000000006 then
                        begin
                            if features[27] <= -5955.4999999999991 then
                            begin
                                Result := 0.028739401725451391;
                            end
                            else
                            begin
                                if features[173] <= -9123.4999999999982 then
                                begin
                                    Result := -0.0054033158627962716;
                                end
                                else
                                begin
                                    Result := 0.014285327331305653;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.035395240319862617;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0017676533565010146;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_32(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -294.49999999999994 then
    begin
        if features[202] <= -719.49999999999989 then
        begin
            Result := -0.020642391903891884;
        end
        else
        begin
            if features[187] <= -1.0000000180025095E-35 then
            begin
                Result := -0.014800772221169526;
            end
            else
            begin
                Result := -0.0053007357698969535;
            end;
        end;
    end
    else
    begin
        if features[202] <= 31.500000000000004 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[169] <= 1.5000000000000002 then
                begin
                    Result := 0.0022978119888268176;
                end
                else
                begin
                    if features[175] <= -673.99999999999989 then
                    begin
                        Result := 0.0034496967746895516;
                    end
                    else
                    begin
                        Result := 0.023775973169786128;
                    end;
                end;
            end
            else
            begin
                Result := -0.0051919569398767833;
            end;
        end
        else
        begin
            if features[18] <= 12.500000000000002 then
            begin
                if features[176] <= -6219.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        if features[188] <= -7389.4999999999991 then
                        begin
                            if features[171] <= 1.0000000180025095E-35 then
                            begin
                                Result := -0.0089425570148224491;
                            end
                            else
                            begin
                                Result := 0.037893346725042881;
                            end;
                        end
                        else
                        begin
                            if features[90] <= 8.5000000000000018 then
                            begin
                                Result := 0.017337463769624757;
                            end
                            else
                            begin
                                Result := 0.038052019454796721;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[188] <= -4798.4999999999991 then
                        begin
                            Result := -0.0024351526066966316;
                        end
                        else
                        begin
                            Result := 0.02152794124279854;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.00013115825087746356;
                end;
            end
            else
            begin
                Result := 0.024536148083387888;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_33(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -378.49999999999994 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.021580001344791957;
        end
        else
        begin
            if features[200] <= -4733.4999999999991 then
            begin
                Result := 0.0027526214789512964;
            end
            else
            begin
                Result := -0.012822802858599661;
            end;
        end;
    end
    else
    begin
        if features[164] <= -135192759.99999997 then
        begin
            if features[202] <= 53.500000000000007 then
            begin
                if features[164] <= -264356407.99999997 then
                begin
                    Result := -0.01158580281781898;
                end
                else
                begin
                    Result := -0.00080365714281896417;
                end;
            end
            else
            begin
                if features[191] <= -6403.4999999999991 then
                begin
                    Result := -0.0015456347501426057;
                end
                else
                begin
                    if features[27] <= -5563.4999999999991 then
                    begin
                        Result := 0.030733433421308434;
                    end
                    else
                    begin
                        Result := 0.0093133982798187347;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[54] <= 1.5000000000000002 then
                begin
                    Result := 0.0021146066683770588;
                end
                else
                begin
                    if features[164] <= -57023309.999999993 then
                    begin
                        Result := 0.011986873722482416;
                    end
                    else
                    begin
                        Result := 0.022938873844677361;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -306.49999999999994 then
                begin
                    Result := 0.013003619666142587;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[174] <= -5202.4999999999991 then
                        begin
                            Result := 0.072275735779764233;
                        end
                        else
                        begin
                            Result := -0.0046540771051895493;
                        end;
                    end
                    else
                    begin
                        Result := -0.017949816627631506;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_34(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -156440759.99999997 then
        begin
            Result := -0.018185979680642766;
        end
        else
        begin
            if features[200] <= -4415.4999999999991 then
            begin
                Result := 0.0034318111509454591;
            end
            else
            begin
                Result := -0.010472874610113208;
            end;
        end;
    end
    else
    begin
        if features[164] <= -227728639.99999997 then
        begin
            if features[201] <= -4568.4999999999991 then
            begin
                Result := -0.0093481736855287947;
            end
            else
            begin
                Result := 0.0057921415251527032;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[195] <= -5359.4999999999991 then
                begin
                    if features[154] <= 83.500000000000014 then
                    begin
                        if features[164] <= -60625469.999999993 then
                        begin
                            Result := 0.0061290930187655399;
                        end
                        else
                        begin
                            Result := 0.021598490994691438;
                        end;
                    end
                    else
                    begin
                        Result := -0.0056092010254095714;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.0077570550784081607;
                    end
                    else
                    begin
                        if features[199] <= 223.50000000000003 then
                        begin
                            Result := 0.014580941366934282;
                        end
                        else
                        begin
                            Result := 0.031055088008015791;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[175] <= -890.49999999999989 then
                begin
                    Result := 0.013150908098446485;
                end
                else
                begin
                    if features[175] <= -772.49999999999989 then
                    begin
                        Result := -0.026008940053520779;
                    end
                    else
                    begin
                        if features[175] <= 719.50000000000011 then
                        begin
                            Result := 0.018124731339160993;
                        end
                        else
                        begin
                            Result := -0.013023944123594861;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_35(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -138339743.99999997 then
        begin
            if features[199] <= -663.49999999999989 then
            begin
                Result := -0.02146187530508737;
            end
            else
            begin
                Result := -0.011598566548090643;
            end;
        end
        else
        begin
            if features[189] <= -7048.4999999999991 then
            begin
                Result := 0.03137458608944356;
            end
            else
            begin
                if features[202] <= -832.49999999999989 then
                begin
                    Result := -0.018527067855155101;
                end
                else
                begin
                    Result := -0.00084346977020074;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -88461003.999999985 then
        begin
            if features[105] <= 1.0000000180025095E-35 then
            begin
                if features[202] <= 145.50000000000003 then
                begin
                    Result := 0.0030957584820456088;
                end
                else
                begin
                    if features[188] <= -7079.4999999999991 then
                    begin
                        Result := -0.0056877072929826496;
                    end
                    else
                    begin
                        if features[76] <= 2.5000000000000004 then
                        begin
                            Result := 0.007893409836298838;
                        end
                        else
                        begin
                            Result := 0.027650640499066827;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0040820051765359713;
            end;
        end
        else
        begin
            if features[90] <= 3.5000000000000004 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[54] <= 1.5000000000000002 then
                    begin
                        Result := 0.0034768195948002636;
                    end
                    else
                    begin
                        Result := 0.017010318649362602;
                    end;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.019502505636199083;
                    end
                    else
                    begin
                        Result := -0.0093978964166150231;
                    end;
                end;
            end
            else
            begin
                Result := 0.027517420308327784;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_36(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.022135843494843668;
        end
        else
        begin
            if features[200] <= -4733.4999999999991 then
            begin
                Result := 0.0019703128671925496;
            end
            else
            begin
                Result := -0.012942443046843114;
            end;
        end;
    end
    else
    begin
        if features[164] <= -135192759.99999997 then
        begin
            if features[199] <= 95.500000000000014 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0014540993359432302;
                end
                else
                begin
                    Result := -0.014246845549516799;
                end;
            end
            else
            begin
                if features[191] <= -6623.4999999999991 then
                begin
                    Result := -0.0040509455651686543;
                end
                else
                begin
                    if features[176] <= -5255.4999999999991 then
                    begin
                        Result := 0.016342877925863971;
                    end
                    else
                    begin
                        Result := -0.0058542462425787943;
                    end;
                end;
            end;
        end
        else
        begin
            if features[90] <= 3.5000000000000004 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[54] <= 1.5000000000000002 then
                    begin
                        Result := 0.002385378394398134;
                    end
                    else
                    begin
                        Result := 0.013029047477424671;
                    end;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0083514591705127015;
                    end
                    else
                    begin
                        if features[90] <= 1.0000000180025095E-35 then
                        begin
                            if features[174] <= -5202.4999999999991 then
                            begin
                                Result := 0.10605881282369289;
                            end
                            else
                            begin
                                Result := -0.0037807215234407568;
                            end;
                        end
                        else
                        begin
                            Result := -0.022165362577411654;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.01971262487260389;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_37(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -138339743.99999997 then
        begin
            if features[199] <= -663.49999999999989 then
            begin
                Result := -0.021542447872226676;
            end
            else
            begin
                Result := -0.011538164013756305;
            end;
        end
        else
        begin
            if features[197] <= -5678.4999999999991 then
            begin
                Result := 0.015753157020284497;
            end
            else
            begin
                if features[176] <= -7214.4999999999991 then
                begin
                    Result := -0.012011814503018445;
                end
                else
                begin
                    Result := 0.00074071444933137306;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -88461003.999999985 then
        begin
            if features[105] <= 1.0000000180025095E-35 then
            begin
                if features[202] <= 145.50000000000003 then
                begin
                    if features[164] <= -306327583.99999994 then
                    begin
                        Result := -0.0088907264215393467;
                    end
                    else
                    begin
                        Result := 0.0049498041217997486;
                    end;
                end
                else
                begin
                    if features[191] <= -6826.4999999999991 then
                    begin
                        Result := -0.0030153060140434194;
                    end
                    else
                    begin
                        if features[177] <= -5941.4999999999991 then
                        begin
                            if features[77] <= 5268.0000000000009 then
                            begin
                                Result := 0.013532176843434857;
                            end
                            else
                            begin
                                Result := 0.031427115226058205;
                            end;
                        end
                        else
                        begin
                            Result := -0.0018196909551838744;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -320634399.99999994 then
                begin
                    Result := -0.017889103048779151;
                end
                else
                begin
                    Result := -0.0012278771882215222;
                end;
            end;
        end
        else
        begin
            if features[135] <= 2.5000000000000004 then
            begin
                Result := 0.010779684560787452;
            end
            else
            begin
                Result := 0.022951719801889005;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_38(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.020004764350609557;
        end
        else
        begin
            if features[202] <= -832.49999999999989 then
            begin
                Result := -0.018094522651005494;
            end
            else
            begin
                if features[189] <= -7048.4999999999991 then
                begin
                    Result := 0.026736265018012764;
                end
                else
                begin
                    Result := -0.0035686052042999683;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -297087183.99999994 then
        begin
            if features[202] <= 380.50000000000006 then
            begin
                Result := -0.010475681188474043;
            end
            else
            begin
                Result := 0.013551266545708238;
            end;
        end
        else
        begin
            if features[202] <= -28.499999999999996 then
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.005123058322580018;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0039340694150755817;
                    end
                    else
                    begin
                        Result := -0.022279140755631293;
                    end;
                end;
            end
            else
            begin
                if features[135] <= 2.5000000000000004 then
                begin
                    if features[141] <= -1.4999999999999998 then
                    begin
                        Result := 0.029738612512761189;
                    end
                    else
                    begin
                        if features[175] <= -62.499999999999993 then
                        begin
                            Result := 0.012114176134299631;
                        end
                        else
                        begin
                            Result := 0.0029077666310185712;
                        end;
                    end;
                end
                else
                begin
                    if features[188] <= -7389.4999999999991 then
                    begin
                        Result := -0.0052086227504072125;
                    end
                    else
                    begin
                        if features[176] <= -6138.4999999999991 then
                        begin
                            Result := 0.022762152396987104;
                        end
                        else
                        begin
                            Result := 0.0039344250382713454;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_39(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.0217987367355537;
        end
        else
        begin
            if features[189] <= -7048.4999999999991 then
            begin
                Result := 0.02284978014310252;
            end
            else
            begin
                Result := -0.0090022878549267018;
            end;
        end;
    end
    else
    begin
        if features[164] <= -172095327.99999997 then
        begin
            if features[202] <= 31.500000000000004 then
            begin
                Result := -0.0066392308366806877;
            end
            else
            begin
                if features[90] <= 10.500000000000002 then
                begin
                    Result := 0.0020574420774242441;
                end
                else
                begin
                    Result := 0.022921844090908292;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[199] <= -39.499999999999993 then
                begin
                    Result := 0.0061018318378931709;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.0062047749774232375;
                    end
                    else
                    begin
                        if features[189] <= -4389.4999999999991 then
                        begin
                            Result := 0.013582503220850077;
                        end
                        else
                        begin
                            Result := 0.03159858313596868;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.0077686072275078262;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[189] <= -3832.4999999999995 then
                        begin
                            Result := 0.09606235258659028;
                        end
                        else
                        begin
                            Result := -0.0041784223335167891;
                        end;
                    end
                    else
                    begin
                        if features[189] <= -3832.4999999999995 then
                        begin
                            Result := -0.02596972256252893;
                        end
                        else
                        begin
                            Result := 0.029472200736161875;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_40(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -473.49999999999994 then
    begin
        if features[164] <= -138339743.99999997 then
        begin
            Result := -0.018861914213799468;
        end
        else
        begin
            if features[200] <= -4733.4999999999991 then
            begin
                Result := 0.00623074667556631;
            end
            else
            begin
                if features[176] <= -7214.4999999999991 then
                begin
                    Result := -0.017818083653370828;
                end
                else
                begin
                    Result := -0.0014207365820638838;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[199] <= 530.50000000000011 then
            begin
                Result := -0.0084525079713003541;
            end
            else
            begin
                if features[188] <= -6553.4999999999991 then
                begin
                    Result := -0.0083265873219383561;
                end
                else
                begin
                    Result := 0.031170457808903818;
                end;
            end;
        end
        else
        begin
            if features[199] <= -48.499999999999993 then
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    Result := 0.0040531818718603533;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0032257820294117872;
                    end
                    else
                    begin
                        Result := -0.021435155996484882;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[190] <= -533.49999999999989 then
                    begin
                        Result := 0.028337218395961934;
                    end
                    else
                    begin
                        if features[172] <= 4.5000000000000009 then
                        begin
                            Result := -0.001907214789062698;
                        end
                        else
                        begin
                            Result := 0.038320787403789462;
                        end;
                    end;
                end
                else
                begin
                    if features[199] <= 406.50000000000006 then
                    begin
                        Result := 0.010783421802733409;
                    end
                    else
                    begin
                        Result := 0.022230422426283217;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_41(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.02142500801448281;
        end
        else
        begin
            if features[200] <= -4713.4999999999991 then
            begin
                Result := 0.0026798764796000909;
            end
            else
            begin
                Result := -0.012204643542308886;
            end;
        end;
    end
    else
    begin
        if features[199] <= -39.499999999999993 then
        begin
            if features[164] <= -67832959.999999985 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.000865684752610155;
                end
                else
                begin
                    Result := -0.01167448235394411;
                end;
            end
            else
            begin
                Result := 0.0073882269643891678;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[190] <= -533.49999999999989 then
                begin
                    Result := 0.025303457706336515;
                end
                else
                begin
                    if features[172] <= 4.5000000000000009 then
                    begin
                        Result := -0.004011104887373303;
                    end
                    else
                    begin
                        Result := 0.039639591544138431;
                    end;
                end;
            end
            else
            begin
                if features[166] <= 107081328.00000001 then
                begin
                    if features[199] <= 335.50000000000006 then
                    begin
                        if features[173] <= -4911.4999999999991 then
                        begin
                            Result := 0.0076402077781164719;
                        end
                        else
                        begin
                            Result := 0.023477414507042157;
                        end;
                    end
                    else
                    begin
                        if features[182] <= -5070.4999999999991 then
                        begin
                            if features[201] <= -4669.4999999999991 then
                            begin
                                Result := 0.015732538477694288;
                            end
                            else
                            begin
                                Result := 0.031995513720120654;
                            end;
                        end
                        else
                        begin
                            Result := -0.0023756491491372933;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0073090012803957776;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_42(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[199] <= -873.49999999999989 then
        begin
            Result := -0.019589322826114156;
        end
        else
        begin
            Result := -0.0092145949247677827;
        end;
    end
    else
    begin
        if features[199] <= -48.499999999999993 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6066.4999999999991 then
                begin
                    Result := 0.0062713580659435348;
                end
                else
                begin
                    Result := -0.0030542333204230062;
                end;
            end
            else
            begin
                Result := -0.0068182150326683748;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[185] <= -331.83332824707026 then
                begin
                    Result := -0.011172354564111309;
                end
                else
                begin
                    if features[176] <= -9722.4999999999982 then
                    begin
                        Result := -0.0097841970249994293;
                    end
                    else
                    begin
                        if features[109] <= 13.500000000000002 then
                        begin
                            Result := 0.0040877316776771998;
                        end
                        else
                        begin
                            Result := 0.023156037868206192;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[105] <= 1.0000000180025095E-35 then
                begin
                    if features[176] <= -5314.4999999999991 then
                    begin
                        if features[198] <= -5005.4999999999991 then
                        begin
                            if features[126] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.014963153254585302;
                            end
                            else
                            begin
                                Result := -0.0032256304998378258;
                            end;
                        end
                        else
                        begin
                            if features[179] <= -6096.4999999999991 then
                            begin
                                Result := 0.028539432339634185;
                            end
                            else
                            begin
                                Result := 0.01116322216853714;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0035087916173421243;
                    end;
                end
                else
                begin
                    Result := 0.0044384363051455577;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_43(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.019462451026601022;
        end
        else
        begin
            if features[199] <= -1032.4999999999998 then
            begin
                Result := -0.017450791228925872;
            end
            else
            begin
                if features[189] <= -7048.4999999999991 then
                begin
                    Result := 0.027088484321202807;
                end
                else
                begin
                    Result := -0.0029601136913398052;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[195] <= -5342.4999999999991 then
            begin
                Result := -0.012485923097755657;
            end
            else
            begin
                Result := 0.002528779248126516;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[189] <= -4389.4999999999991 then
                begin
                    if features[166] <= 109196768.00000001 then
                    begin
                        Result := 0.0086210241516145852;
                    end
                    else
                    begin
                        Result := -0.0077851436264485332;
                    end;
                end
                else
                begin
                    if features[190] <= 3421.5000000000005 then
                    begin
                        if features[177] <= -8039.4999999999991 then
                        begin
                            Result := 0.035822932429354977;
                        end
                        else
                        begin
                            Result := 0.012915952981180926;
                        end;
                    end
                    else
                    begin
                        Result := -0.013288305221285338;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.0096930787395608786;
                end
                else
                begin
                    if features[135] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.037962435573055446;
                    end
                    else
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := -0.026895299321194097;
                        end
                        else
                        begin
                            Result := 0.019747493487909853;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_44(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.021104151790406228;
        end
        else
        begin
            if features[189] <= -6876.4999999999991 then
            begin
                Result := 0.02017258494472015;
            end
            else
            begin
                Result := -0.009258301658238011;
            end;
        end;
    end
    else
    begin
        if features[164] <= -197851207.99999997 then
        begin
            if features[199] <= 369.50000000000006 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0021481552369331694;
                end
                else
                begin
                    Result := -0.015499693173019259;
                end;
            end
            else
            begin
                if features[193] <= 638.50000000000011 then
                begin
                    Result := 0.031799507839121811;
                end
                else
                begin
                    Result := 0.00063164977787990575;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[54] <= 1.5000000000000002 then
                begin
                    Result := 0.00026602578520182666;
                end
                else
                begin
                    if features[164] <= -57023309.999999993 then
                    begin
                        Result := 0.0072993207147627782;
                    end
                    else
                    begin
                        Result := 0.018069598127166426;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.0063318557556389437;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[189] <= -3832.4999999999995 then
                        begin
                            Result := 0.091475147951620983;
                        end
                        else
                        begin
                            Result := -0.0062804160232980723;
                        end;
                    end
                    else
                    begin
                        if features[172] <= 1.5000000000000002 then
                        begin
                            Result := -0.02683974689261398;
                        end
                        else
                        begin
                            Result := 0.017098152731833578;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_45(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -438.49999999999994 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.021353326467669992;
        end
        else
        begin
            if features[197] <= -5973.4999999999991 then
            begin
                Result := 0.025346833884526881;
            end
            else
            begin
                Result := -0.0089836681083086053;
            end;
        end;
    end
    else
    begin
        if features[164] <= -110756839.99999999 then
        begin
            if features[202] <= -96.499999999999986 then
            begin
                Result := -0.0060687701194714651;
            end
            else
            begin
                if features[195] <= -5886.4999999999991 then
                begin
                    Result := -0.0055790187679868319;
                end
                else
                begin
                    if features[27] <= -5720.4999999999991 then
                    begin
                        if features[198] <= -5671.4999999999991 then
                        begin
                            Result := 0.0040208131509121775;
                        end
                        else
                        begin
                            Result := 0.028112587128146023;
                        end;
                    end
                    else
                    begin
                        if features[105] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.0077300290831256342;
                        end
                        else
                        begin
                            Result := -0.0033888789692165626;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[202] <= 181.50000000000003 then
            begin
                Result := 0.0068093458320391768;
            end
            else
            begin
                if features[188] <= -6130.4999999999991 then
                begin
                    if features[158] <= 708.50000000000011 then
                    begin
                        Result := -0.012981351626712599;
                    end
                    else
                    begin
                        Result := 0.015865362157355747;
                    end;
                end
                else
                begin
                    if features[163] <= 303080096.00000006 then
                    begin
                        if features[201] <= -4603.4999999999991 then
                        begin
                            Result := 0.019286182425553841;
                        end
                        else
                        begin
                            Result := 0.041279882707583121;
                        end;
                    end
                    else
                    begin
                        Result := 0.0036960867197548064;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_46(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -485.49999999999994 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.020693097746129013;
        end
        else
        begin
            if features[200] <= -4614.4999999999991 then
            begin
                Result := 0.0010829046134559195;
            end
            else
            begin
                if features[176] <= -7289.4999999999991 then
                begin
                    Result := -0.019924594784659612;
                end
                else
                begin
                    Result := -0.0062474228056785359;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[199] <= 530.50000000000011 then
            begin
                Result := -0.0083469188696988755;
            end
            else
            begin
                if features[193] <= 749.50000000000011 then
                begin
                    Result := 0.040676434472607742;
                end
                else
                begin
                    Result := 0.0028634896617705445;
                end;
            end;
        end
        else
        begin
            if features[199] <= -57.499999999999993 then
            begin
                if features[164] <= -41699193.999999993 then
                begin
                    Result := -0.00016680678293708656;
                end
                else
                begin
                    Result := 0.0089282924293121787;
                end;
            end
            else
            begin
                if features[166] <= 84788892.000000015 then
                begin
                    if features[9] <= 10.500000000000002 then
                    begin
                        if features[18] <= 14.500000000000002 then
                        begin
                            if features[190] <= 2732.0000000000005 then
                            begin
                                Result := 0.0085597749876173274;
                            end
                            else
                            begin
                                Result := -0.0081819926343607765;
                            end;
                        end
                        else
                        begin
                            Result := 0.020357583056271753;
                        end;
                    end
                    else
                    begin
                        if features[64] <= 800.50000000000011 then
                        begin
                            Result := 0.027353431213149183;
                        end
                        else
                        begin
                            Result := -0.0013869814216974222;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0050269990694021393;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_47(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -214584903.99999997 then
        begin
            Result := -0.02102904487224103;
        end
        else
        begin
            if features[197] <= -5973.4999999999991 then
            begin
                Result := 0.021404658744592714;
            end
            else
            begin
                Result := -0.0083040329443919182;
            end;
        end;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[202] <= 380.50000000000006 then
            begin
                Result := -0.0084677674941497638;
            end
            else
            begin
                if features[193] <= 749.50000000000011 then
                begin
                    Result := 0.037867603439179894;
                end
                else
                begin
                    Result := 0.00033893940325363829;
                end;
            end;
        end
        else
        begin
            if features[199] <= 95.500000000000014 then
            begin
                if features[164] <= -57023309.999999993 then
                begin
                    Result := 0.00044736656983859047;
                end
                else
                begin
                    if features[90] <= 8.5000000000000018 then
                    begin
                        Result := 0.0077604072478124749;
                    end
                    else
                    begin
                        Result := 0.035113465439230704;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := -0.0027433455942550704;
                end
                else
                begin
                    if features[176] <= -5255.4999999999991 then
                    begin
                        if features[198] <= -6358.4999999999991 then
                        begin
                            Result := -0.0040934366834746759;
                        end
                        else
                        begin
                            if features[199] <= 530.50000000000011 then
                            begin
                                if features[173] <= -9123.4999999999982 then
                                begin
                                    Result := 0.00053585289953250335;
                                end
                                else
                                begin
                                    Result := 0.015504946031673579;
                                end;
                            end
                            else
                            begin
                                Result := 0.028130586812020488;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0037457036447515121;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_48(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -510.49999999999994 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.020254967628103322;
        end
        else
        begin
            if features[200] <= -4614.4999999999991 then
            begin
                if features[47] <= 12984.000000000002 then
                begin
                    Result := -0.003283619990399464;
                end
                else
                begin
                    Result := 0.018395917550954443;
                end;
            end
            else
            begin
                Result := -0.011722185524522319;
            end;
        end;
    end
    else
    begin
        if features[164] <= -91709047.999999985 then
        begin
            if features[199] <= -106.49999999999999 then
            begin
                Result := -0.0049159088552596002;
            end
            else
            begin
                if features[195] <= -5886.4999999999991 then
                begin
                    if features[186] <= -112.41666793823241 then
                    begin
                        Result := -0.013105941283915538;
                    end
                    else
                    begin
                        Result := 0.0033757689612546626;
                    end;
                end
                else
                begin
                    if features[27] <= -5365.4999999999991 then
                    begin
                        if features[198] <= -5671.4999999999991 then
                        begin
                            Result := 0.0023235153791263349;
                        end
                        else
                        begin
                            Result := 0.023612960343996146;
                        end;
                    end
                    else
                    begin
                        if features[201] <= -4618.4999999999991 then
                        begin
                            Result := -0.0022003682498998476;
                        end
                        else
                        begin
                            Result := 0.0082824029953852095;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[90] <= 3.5000000000000004 then
            begin
                if features[142] <= -1.4999999999999998 then
                begin
                    Result := 0.021068030195243954;
                end
                else
                begin
                    if features[158] <= -2464.4999999999995 then
                    begin
                        Result := -0.0046546283473774108;
                    end
                    else
                    begin
                        Result := 0.0083550485429778679;
                    end;
                end;
            end
            else
            begin
                Result := 0.020214917317851744;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_49(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -449.49999999999994 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.02088824995197424;
        end
        else
        begin
            if features[197] <= -5765.4999999999991 then
            begin
                Result := 0.018041289931660081;
            end
            else
            begin
                Result := -0.0089720454581779067;
            end;
        end;
    end
    else
    begin
        if features[164] <= -110756839.99999999 then
        begin
            if features[202] <= -96.499999999999986 then
            begin
                if features[164] <= -245435391.99999997 then
                begin
                    Result := -0.011912437402940439;
                end
                else
                begin
                    Result := -0.0021758606521352416;
                end;
            end
            else
            begin
                if features[195] <= -5886.4999999999991 then
                begin
                    if features[186] <= -112.41666793823241 then
                    begin
                        Result := -0.013527541342036735;
                    end
                    else
                    begin
                        Result := 0.0020839825967032587;
                    end;
                end
                else
                begin
                    if features[18] <= 12.500000000000002 then
                    begin
                        if features[174] <= -8825.4999999999982 then
                        begin
                            if features[184] <= -347.49999999999994 then
                            begin
                                Result := 0.034681251051863184;
                            end
                            else
                            begin
                                Result := 0.00079643903592668082;
                            end;
                        end
                        else
                        begin
                            Result := 0.0019017760150324221;
                        end;
                    end
                    else
                    begin
                        Result := 0.016870534555411102;
                    end;
                end;
            end;
        end
        else
        begin
            if features[202] <= 181.50000000000003 then
            begin
                Result := 0.0060540658673936256;
            end
            else
            begin
                if features[154] <= 371.50000000000006 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.0074059602488839166;
                    end
                    else
                    begin
                        Result := 0.024009024150806507;
                    end;
                end
                else
                begin
                    Result := -0.0041106102077446737;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_50(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -214584903.99999997 then
        begin
            Result := -0.020437696774244809;
        end
        else
        begin
            if features[189] <= -6876.4999999999991 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    Result := 0.048822143609023823;
                end
                else
                begin
                    Result := -0.0014057597659952713;
                end;
            end
            else
            begin
                Result := -0.0081529884478532769;
            end;
        end;
    end
    else
    begin
        if features[199] <= -18.499999999999996 then
        begin
            if features[164] <= -245435391.99999997 then
            begin
                Result := -0.0096610230061127608;
            end
            else
            begin
                if features[188] <= -3911.4999999999995 then
                begin
                    if features[179] <= -7309.4999999999991 then
                    begin
                        Result := -0.00078909818942934646;
                    end
                    else
                    begin
                        Result := 0.0075499791351404172;
                    end;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0018172519432870082;
                    end
                    else
                    begin
                        Result := -0.020911131094814954;
                    end;
                end;
            end;
        end
        else
        begin
            if features[18] <= 12.500000000000002 then
            begin
                if features[135] <= 10.500000000000002 then
                begin
                    if features[164] <= -156440759.99999997 then
                    begin
                        if features[201] <= -4652.4999999999991 then
                        begin
                            Result := -0.0075864816389296114;
                        end
                        else
                        begin
                            Result := 0.0061103641048335785;
                        end;
                    end
                    else
                    begin
                        Result := 0.0075461003661798087;
                    end;
                end
                else
                begin
                    Result := 0.022805059008400838;
                end;
            end
            else
            begin
                if features[189] <= -3832.4999999999995 then
                begin
                    Result := 0.013898393352887454;
                end
                else
                begin
                    Result := 0.042616798726867702;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_51(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.020312911098784334;
        end
        else
        begin
            if features[189] <= -6747.4999999999991 then
            begin
                Result := 0.015683891207336875;
            end
            else
            begin
                if features[176] <= -7331.4999999999991 then
                begin
                    Result := -0.015742307835770877;
                end
                else
                begin
                    if features[199] <= -1058.4999999999998 then
                    begin
                        Result := -0.017412071127733412;
                    end
                    else
                    begin
                        Result := 0.0031921733315819082;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[199] <= -39.499999999999993 then
        begin
            if features[164] <= -234501855.99999997 then
            begin
                Result := -0.0092181532419739216;
            end
            else
            begin
                if features[188] <= -3928.4999999999995 then
                begin
                    Result := 0.0037888323710798403;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0011321683781914808;
                    end
                    else
                    begin
                        Result := -0.021666312576893876;
                    end;
                end;
            end;
        end
        else
        begin
            if features[191] <= -6342.4999999999991 then
            begin
                if features[164] <= -94912271.999999985 then
                begin
                    Result := -0.0030420158841134928;
                end
                else
                begin
                    Result := 0.0089942609216320732;
                end;
            end
            else
            begin
                if features[177] <= -7127.4999999999991 then
                begin
                    if features[199] <= 277.50000000000006 then
                    begin
                        Result := 0.011336812861667132;
                    end
                    else
                    begin
                        Result := 0.028337556886517335;
                    end;
                end
                else
                begin
                    if features[185] <= -41.833333969116204 then
                    begin
                        Result := -0.002227149971345945;
                    end
                    else
                    begin
                        Result := 0.011417935754063763;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_52(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -374.49999999999994 then
    begin
        if features[164] <= -221021911.99999997 then
        begin
            Result := -0.018664175717373006;
        end
        else
        begin
            if features[202] <= -832.49999999999989 then
            begin
                Result := -0.017292069307897843;
            end
            else
            begin
                if features[189] <= -6241.4999999999991 then
                begin
                    Result := 0.012427495408113037;
                end
                else
                begin
                    if features[176] <= -7607.4999999999991 then
                    begin
                        Result := -0.011793995774858288;
                    end
                    else
                    begin
                        if features[164] <= -53279485.999999993 then
                        begin
                            Result := -0.0046298030507524899;
                        end
                        else
                        begin
                            Result := 0.0105889670578288;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -297087183.99999994 then
        begin
            if features[198] <= -4919.4999999999991 then
            begin
                Result := -0.013444375496097755;
            end
            else
            begin
                if features[71] <= 7.5000000000000009 then
                begin
                    Result := -0.0073694855286707888;
                end
                else
                begin
                    Result := 0.015960849877833867;
                end;
            end;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[164] <= -156440759.99999997 then
                begin
                    Result := -0.0040464402979005221;
                end
                else
                begin
                    Result := 0.0049500333890918971;
                end;
            end
            else
            begin
                if features[202] <= 31.500000000000004 then
                begin
                    Result := 0.0043548442329463836;
                end
                else
                begin
                    if features[193] <= -702.49999999999989 then
                    begin
                        Result := 0.052614819109440804;
                    end
                    else
                    begin
                        if features[190] <= 3421.5000000000005 then
                        begin
                            Result := 0.013892055618295304;
                        end
                        else
                        begin
                            Result := -0.011731127037922491;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_53(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -649.49999999999989 then
    begin
        if features[164] <= -138339743.99999997 then
        begin
            Result := -0.019295975747498417;
        end
        else
        begin
            Result := -0.0062324791801006522;
        end;
    end
    else
    begin
        if features[164] <= -315822463.99999994 then
        begin
            if features[202] <= 200.50000000000003 then
            begin
                Result := -0.014284077544282299;
            end
            else
            begin
                Result := 0.0041753486778500415;
            end;
        end
        else
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6091.4999999999991 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[175] <= -423.49999999999994 then
                        begin
                            Result := 0.014404329578443009;
                        end
                        else
                        begin
                            if features[186] <= -100.83333206176756 then
                            begin
                                Result := -0.0020595643434982119;
                            end
                            else
                            begin
                                if features[191] <= -4022.4999999999995 then
                                begin
                                    Result := 0.006965961497595808;
                                end
                                else
                                begin
                                    Result := 0.04734548570737062;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[175] <= -772.49999999999989 then
                        begin
                            Result := 0.0072736086239846582;
                        end
                        else
                        begin
                            if features[108] <= -557.49999999999989 then
                            begin
                                Result := 0.047016679426860331;
                            end
                            else
                            begin
                                Result := 0.018920555067965673;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0011277504557443997;
                end;
            end
            else
            begin
                if features[192] <= -6019.4999999999991 then
                begin
                    if features[173] <= -4832.4999999999991 then
                    begin
                        Result := -0.0097797968383255204;
                    end
                    else
                    begin
                        Result := 0.015562325021847812;
                    end;
                end
                else
                begin
                    Result := 0.0030946540029794661;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_54(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -633.49999999999989 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.02079478893599036;
        end
        else
        begin
            if features[200] <= -4652.4999999999991 then
            begin
                Result := 0.0027450783553668663;
            end
            else
            begin
                Result := -0.012560417127524785;
            end;
        end;
    end
    else
    begin
        if features[164] <= -284306271.99999994 then
        begin
            if features[199] <= 530.50000000000011 then
            begin
                Result := -0.0099577072768988872;
            end
            else
            begin
                Result := 0.013361830031429798;
            end;
        end
        else
        begin
            if features[199] <= -39.499999999999993 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    if features[189] <= -5084.4999999999991 then
                    begin
                        Result := 0.014101521875776863;
                    end
                    else
                    begin
                        Result := 0.00089614323657183316;
                    end;
                end
                else
                begin
                    Result := -0.0013309849157428111;
                end;
            end
            else
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    if features[175] <= 1.0000000180025095E-35 then
                    begin
                        if features[197] <= -6582.4999999999991 then
                        begin
                            Result := -0.0084904995365778068;
                        end
                        else
                        begin
                            Result := 0.011280631012699643;
                        end;
                    end
                    else
                    begin
                        if features[171] <= 1.5000000000000002 then
                        begin
                            Result := -0.0081113140540749456;
                        end
                        else
                        begin
                            if features[188] <= -3966.4999999999995 then
                            begin
                                if features[189] <= -4389.4999999999991 then
                                begin
                                    Result := 0.0025165243798578266;
                                end
                                else
                                begin
                                    Result := 0.019676689544783646;
                                end;
                            end
                            else
                            begin
                                Result := -0.015597603663887797;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.011939848572047175;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_55(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -483.49999999999994 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.020893878796638163;
        end
        else
        begin
            if features[201] <= -6209.4999999999991 then
            begin
                Result := 0.016374627646131096;
            end
            else
            begin
                Result := -0.0090127391495904829;
            end;
        end;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[176] <= -5933.4999999999991 then
            begin
                if features[202] <= 11.500000000000002 then
                begin
                    Result := 0.0028024950768184725;
                end
                else
                begin
                    if features[190] <= 2732.0000000000005 then
                    begin
                        if features[27] <= -5865.4999999999991 then
                        begin
                            Result := 0.023507160752417905;
                        end
                        else
                        begin
                            if features[201] <= -4586.4999999999991 then
                            begin
                                Result := 0.0066443822231018693;
                            end
                            else
                            begin
                                if features[180] <= -6402.4999999999991 then
                                begin
                                    Result := 0.023996165628622484;
                                end
                                else
                                begin
                                    Result := 0.004693232802205757;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.007746962682058065;
                    end;
                end;
            end
            else
            begin
                if features[186] <= -284.74999999999994 then
                begin
                    Result := -0.011020707583723937;
                end
                else
                begin
                    if features[193] <= -579.49999999999989 then
                    begin
                        Result := 0.024676979701562657;
                    end
                    else
                    begin
                        Result := 0.00010217538449641194;
                    end;
                end;
            end;
        end
        else
        begin
            if features[164] <= -178293111.99999997 then
            begin
                if features[198] <= -5177.4999999999991 then
                begin
                    Result := -0.016112934154632951;
                end
                else
                begin
                    Result := -0.0024579003752670022;
                end;
            end
            else
            begin
                Result := 0.0012533159017295967;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_56(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -649.49999999999989 then
    begin
        if features[164] <= -129461379.99999999 then
        begin
            Result := -0.018666524631175713;
        end
        else
        begin
            if features[200] <= -5492.4999999999991 then
            begin
                Result := 0.021709018350788423;
            end
            else
            begin
                Result := -0.0072697422149676956;
            end;
        end;
    end
    else
    begin
        if features[164] <= -288500527.99999994 then
        begin
            if features[199] <= 530.50000000000011 then
            begin
                Result := -0.010343621072601436;
            end
            else
            begin
                Result := 0.010492595355642171;
            end;
        end
        else
        begin
            if features[199] <= 95.500000000000014 then
            begin
                if features[164] <= -57023309.999999993 then
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0013715929666304981;
                    end
                    else
                    begin
                        Result := -0.0064405137241280129;
                    end;
                end
                else
                begin
                    if features[54] <= 4.5000000000000009 then
                    begin
                        Result := 0.0044916514759590171;
                    end
                    else
                    begin
                        Result := 0.018957500798562801;
                    end;
                end;
            end
            else
            begin
                if features[18] <= 11.500000000000002 then
                begin
                    if features[166] <= 49956732.000000007 then
                    begin
                        if features[180] <= -6865.4999999999991 then
                        begin
                            if features[191] <= -5988.4999999999991 then
                            begin
                                Result := 0.0063005814239915307;
                            end
                            else
                            begin
                                Result := 0.020917700407414756;
                            end;
                        end
                        else
                        begin
                            Result := 0.00068861372420940233;
                        end;
                    end
                    else
                    begin
                        Result := -0.0064539190238725869;
                    end;
                end
                else
                begin
                    if features[195] <= -4695.4999999999991 then
                    begin
                        Result := 0.011338871325388482;
                    end
                    else
                    begin
                        Result := 0.027715202256895995;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_57(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -633.49999999999989 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.020448592284027182;
        end
        else
        begin
            if features[200] <= -4652.4999999999991 then
            begin
                Result := 0.0031492102799270841;
            end
            else
            begin
                Result := -0.01226035791669248;
            end;
        end;
    end
    else
    begin
        if features[164] <= -120155935.99999999 then
        begin
            if features[105] <= 1.0000000180025095E-35 then
            begin
                if features[199] <= -176.49999999999997 then
                begin
                    Result := -0.0041445090676800979;
                end
                else
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        if features[174] <= -6743.9999999999991 then
                        begin
                            if features[189] <= -4079.4999999999995 then
                            begin
                                Result := 0.0045686567993009327;
                            end
                            else
                            begin
                                Result := 0.042078777368893469;
                            end;
                        end
                        else
                        begin
                            if features[109] <= -328.49999999999994 then
                            begin
                                Result := -0.016739257514749469;
                            end
                            else
                            begin
                                Result := 0.0013547995739260955;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[163] <= -275028911.99999994 then
                        begin
                            Result := 0.04170015046896005;
                        end
                        else
                        begin
                            if features[201] <= -5086.4999999999991 then
                            begin
                                Result := -0.0029458914048001699;
                            end
                            else
                            begin
                                Result := 0.018071294548344028;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -384867039.99999994 then
                begin
                    Result := -0.022420850301844122;
                end
                else
                begin
                    Result := -0.0054150876634815846;
                end;
            end;
        end
        else
        begin
            if features[90] <= 3.5000000000000004 then
            begin
                Result := 0.0049582964935348693;
            end
            else
            begin
                Result := 0.014614890553886395;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_58(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -483.49999999999994 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.020411245116162144;
        end
        else
        begin
            if features[197] <= -5897.4999999999991 then
            begin
                Result := 0.024034511029975784;
            end
            else
            begin
                Result := -0.0087191107167014035;
            end;
        end;
    end
    else
    begin
        if features[164] <= -284306271.99999994 then
        begin
            if features[198] <= -4562.4999999999991 then
            begin
                Result := -0.011638895603359513;
            end
            else
            begin
                if features[197] <= -4649.4999999999991 then
                begin
                    Result := 0.028301482976296029;
                end
                else
                begin
                    Result := -0.0020717169395435219;
                end;
            end;
        end
        else
        begin
            if features[202] <= 145.50000000000003 then
            begin
                if features[164] <= -53279485.999999993 then
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0019471048318292052;
                    end
                    else
                    begin
                        if features[173] <= -4869.4999999999991 then
                        begin
                            Result := -0.007444919940914986;
                        end
                        else
                        begin
                            Result := 0.015654994338136545;
                        end;
                    end;
                end
                else
                begin
                    if features[90] <= 6.5000000000000009 then
                    begin
                        Result := 0.0055756662384055626;
                    end
                    else
                    begin
                        Result := 0.022477976489389661;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -6809.9999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.012778894007764425;
                    end
                    else
                    begin
                        Result := 0.0070519825189577657;
                    end;
                end
                else
                begin
                    if features[18] <= 10.500000000000002 then
                    begin
                        Result := 0.0078086779469747312;
                    end
                    else
                    begin
                        Result := 0.020105274714373438;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_59(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -633.49999999999989 then
    begin
        if features[164] <= -129461379.99999999 then
        begin
            Result := -0.018522293191003066;
        end
        else
        begin
            if features[189] <= -6876.4999999999991 then
            begin
                Result := 0.023411278108772637;
            end
            else
            begin
                Result := -0.007124257846402542;
            end;
        end;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[202] <= 321.50000000000006 then
            begin
                Result := -0.0086462723549015612;
            end
            else
            begin
                Result := 0.0091863399620086446;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[166] <= 121207976.00000001 then
                begin
                    if features[195] <= -4812.4999999999991 then
                    begin
                        if features[166] <= -16113090.499999998 then
                        begin
                            Result := 0.019954128750232551;
                        end
                        else
                        begin
                            Result := 0.0039803959084373812;
                        end;
                    end
                    else
                    begin
                        if features[184] <= 527.50000000000011 then
                        begin
                            if features[199] <= 223.50000000000003 then
                            begin
                                Result := 0.0097630991674347075;
                            end
                            else
                            begin
                                Result := 0.023810799662512004;
                            end;
                        end
                        else
                        begin
                            Result := -0.003062266631633755;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.007322453349728095;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.0039421708646544462;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[90] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.094648981837905363;
                        end
                        else
                        begin
                            Result := -0.026983136781957462;
                        end;
                    end
                    else
                    begin
                        Result := 0.011925007188639258;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_60(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -544.49999999999989 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.020609815871180891;
        end
        else
        begin
            Result := -0.0077326075867535805;
        end;
    end
    else
    begin
        if features[164] <= -120155935.99999999 then
        begin
            if features[199] <= -126.49999999999999 then
            begin
                Result := -0.0063847368480655963;
            end
            else
            begin
                if features[105] <= 1.0000000180025095E-35 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[177] <= -6686.4999999999991 then
                        begin
                            if features[195] <= -5359.4999999999991 then
                            begin
                                Result := -0.0017126724139584029;
                            end
                            else
                            begin
                                if features[191] <= -6718.4999999999991 then
                                begin
                                    Result := -0.0073050756741309042;
                                end
                                else
                                begin
                                    Result := 0.016211428365573443;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.0077036661957999315;
                        end;
                    end
                    else
                    begin
                        Result := 0.014736995452234293;
                    end;
                end
                else
                begin
                    Result := -0.0045676742982813431;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[10] <= 1.0000000180025095E-35 then
                begin
                    if features[166] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.022363134409367696;
                    end
                    else
                    begin
                        Result := 0.0087449960292028603;
                    end;
                end
                else
                begin
                    if features[176] <= -7412.4999999999991 then
                    begin
                        Result := -0.0070113482154698682;
                    end
                    else
                    begin
                        Result := 0.0065311310927319097;
                    end;
                end;
            end
            else
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    Result := 0.0047692670803097907;
                end
                else
                begin
                    Result := -0.010542758940385298;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_61(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -649.49999999999989 then
    begin
        if features[164] <= -129461379.99999999 then
        begin
            Result := -0.018038571319990891;
        end
        else
        begin
            Result := -0.0044381063960638317;
        end;
    end
    else
    begin
        if features[164] <= -284306271.99999994 then
        begin
            if features[199] <= 530.50000000000011 then
            begin
                Result := -0.0095464184059053988;
            end
            else
            begin
                if features[193] <= 808.50000000000011 then
                begin
                    Result := 0.033854221563321886;
                end
                else
                begin
                    Result := -0.0021818862590183927;
                end;
            end;
        end
        else
        begin
            if features[199] <= -98.499999999999986 then
            begin
                if features[164] <= -49570567.999999993 then
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        if features[179] <= -6685.4999999999991 then
                        begin
                            Result := -0.0040604579174709984;
                        end
                        else
                        begin
                            Result := 0.0044031277820401902;
                        end;
                    end
                    else
                    begin
                        if features[189] <= -3924.4999999999995 then
                        begin
                            Result := -0.024333564134353818;
                        end
                        else
                        begin
                            Result := 0.00055032003546419709;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0067309467896018785;
                end;
            end
            else
            begin
                if features[201] <= -4669.4999999999991 then
                begin
                    if features[27] <= -5865.4999999999991 then
                    begin
                        Result := 0.011557895321432879;
                    end
                    else
                    begin
                        if features[166] <= 109196768.00000001 then
                        begin
                            Result := 0.0020006064139647239;
                        end
                        else
                        begin
                            Result := -0.016962850547530849;
                        end;
                    end;
                end
                else
                begin
                    if features[27] <= -4870.4999999999991 then
                    begin
                        Result := 0.020624937960507315;
                    end
                    else
                    begin
                        Result := 0.0069044818406261673;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_62(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -544.49999999999989 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.020548148175913314;
        end
        else
        begin
            Result := -0.0073411736342788416;
        end;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[198] <= -4808.4999999999991 then
            begin
                Result := -0.010684058189227385;
            end
            else
            begin
                Result := 0.0021739061494582242;
            end;
        end
        else
        begin
            if features[202] <= 130.50000000000003 then
            begin
                if features[188] <= -3834.4999999999995 then
                begin
                    if features[164] <= -67832959.999999985 then
                    begin
                        Result := 0.00090449626899494814;
                    end
                    else
                    begin
                        Result := 0.0071428197441053779;
                    end;
                end
                else
                begin
                    if features[188] <= -3833.4999999999995 then
                    begin
                        if features[174] <= -6091.4999999999991 then
                        begin
                            Result := 0.00075345685554528816;
                        end
                        else
                        begin
                            Result := -0.025717870627358305;
                        end;
                    end
                    else
                    begin
                        if features[190] <= -676.49999999999989 then
                        begin
                            Result := -0.0045017871065966639;
                        end
                        else
                        begin
                            Result := 0.016226863413788688;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := -0.0050951519390346166;
                end
                else
                begin
                    if features[198] <= -6322.4999999999991 then
                    begin
                        Result := -0.0074742356352731926;
                    end
                    else
                    begin
                        if features[183] <= -6592.4999999999991 then
                        begin
                            if features[199] <= 784.50000000000011 then
                            begin
                                Result := 0.014922513621678344;
                            end
                            else
                            begin
                                Result := 0.04343688324801534;
                            end;
                        end
                        else
                        begin
                            Result := 0.006708580918875242;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_63(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -374.49999999999994 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.017242069771150777;
        end
        else
        begin
            if features[200] <= -4733.4999999999991 then
            begin
                Result := 0.003925313931156805;
            end
            else
            begin
                Result := -0.007854476275352051;
            end;
        end;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[176] <= -5933.4999999999991 then
            begin
                if features[9] <= 11.500000000000002 then
                begin
                    if features[173] <= -6091.4999999999991 then
                    begin
                        if features[190] <= 2732.0000000000005 then
                        begin
                            if features[199] <= 277.50000000000006 then
                            begin
                                Result := 0.0072305540835695143;
                            end
                            else
                            begin
                                if features[201] <= -4586.4999999999991 then
                                begin
                                    Result := 0.012031617918630557;
                                end
                                else
                                begin
                                    Result := 0.031662683151999695;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.0090319212254629643;
                        end;
                    end
                    else
                    begin
                        Result := 0.0011501335623041195;
                    end;
                end
                else
                begin
                    Result := 0.019717138410176631;
                end;
            end
            else
            begin
                Result := -0.0027615895805491487;
            end;
        end
        else
        begin
            if features[174] <= -6022.4999999999991 then
            begin
                if features[192] <= -6019.4999999999991 then
                begin
                    Result := -0.010334999481138141;
                end
                else
                begin
                    Result := -1.6882940818322488E-05;
                end;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    Result := -0.0091484474440869726;
                end
                else
                begin
                    if features[180] <= -4878.4999999999991 then
                    begin
                        Result := 0.010036024375380544;
                    end
                    else
                    begin
                        Result := 0.055511933907371594;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_64(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -649.49999999999989 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.019553331801792098;
        end
        else
        begin
            if features[200] <= -6056.4999999999991 then
            begin
                Result := 0.037514361460149324;
            end
            else
            begin
                Result := -0.0077367026632342243;
            end;
        end;
    end
    else
    begin
        if features[164] <= -297087183.99999994 then
        begin
            if features[202] <= 353.50000000000006 then
            begin
                Result := -0.010466533695543562;
            end
            else
            begin
                Result := 0.0077091379321524919;
            end;
        end
        else
        begin
            if features[199] <= 95.500000000000014 then
            begin
                if features[164] <= -57023309.999999993 then
                begin
                    if features[37] <= 1.5000000000000002 then
                    begin
                        Result := 0.050789201067670632;
                    end
                    else
                    begin
                        Result := -0.0007603775660738497;
                    end;
                end
                else
                begin
                    if features[90] <= 3.5000000000000004 then
                    begin
                        Result := 0.0046047157120638685;
                    end
                    else
                    begin
                        Result := 0.01953864260955698;
                    end;
                end;
            end
            else
            begin
                if features[201] <= -4603.4999999999991 then
                begin
                    if features[163] <= -85013479.999999985 then
                    begin
                        if features[54] <= 10.500000000000002 then
                        begin
                            Result := 0.0073937037537422845;
                        end
                        else
                        begin
                            Result := 0.027769023677588107;
                        end;
                    end
                    else
                    begin
                        Result := 0.000593716465075268;
                    end;
                end
                else
                begin
                    if features[27] <= -4629.4999999999991 then
                    begin
                        Result := 0.022936015195568173;
                    end
                    else
                    begin
                        if features[193] <= -666.49999999999989 then
                        begin
                            Result := 0.051722574656687607;
                        end
                        else
                        begin
                            Result := 0.0061695175463851604;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_65(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -544.49999999999989 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.019936483668003893;
        end
        else
        begin
            if features[201] <= -6209.4999999999991 then
            begin
                Result := 0.016921773997768973;
            end
            else
            begin
                Result := -0.0096158128443366853;
            end;
        end;
    end
    else
    begin
        if features[164] <= -315822463.99999994 then
        begin
            if features[202] <= 200.50000000000003 then
            begin
                Result := -0.012900113725761261;
            end
            else
            begin
                Result := 0.0037228949365234517;
            end;
        end
        else
        begin
            if features[202] <= 145.50000000000003 then
            begin
                if features[176] <= -9075.4999999999982 then
                begin
                    Result := -0.0052224028298790415;
                end
                else
                begin
                    if features[164] <= -20456594.999999996 then
                    begin
                        if features[190] <= -143.49999999999997 then
                        begin
                            if features[199] <= -187.49999999999997 then
                            begin
                                Result := -4.0844587585507686E-05;
                            end
                            else
                            begin
                                Result := 0.0087103435133256742;
                            end;
                        end
                        else
                        begin
                            if features[190] <= -131.49999999999997 then
                            begin
                                Result := -0.023989731410408336;
                            end
                            else
                            begin
                                Result := 0.00085927401532465305;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0091344525453528266;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -6267.4999999999991 then
                begin
                    Result := -0.0012294352636482871;
                end
                else
                begin
                    if features[18] <= 10.500000000000002 then
                    begin
                        if features[199] <= 675.50000000000011 then
                        begin
                            Result := 0.0044133032961670661;
                        end
                        else
                        begin
                            Result := 0.026348702858009804;
                        end;
                    end
                    else
                    begin
                        Result := 0.019135041376118139;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_66(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -249149359.99999997 then
        begin
            Result := -0.019987708755758383;
        end
        else
        begin
            if features[200] <= -4733.4999999999991 then
            begin
                Result := 0.0035118520366299727;
            end
            else
            begin
                Result := -0.0094796183207176699;
            end;
        end;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[173] <= -6091.4999999999991 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[175] <= -423.49999999999994 then
                    begin
                        Result := 0.012106040277420335;
                    end
                    else
                    begin
                        if features[171] <= 1.5000000000000002 then
                        begin
                            Result := -0.0070326575410726358;
                        end
                        else
                        begin
                            if features[202] <= 269.50000000000006 then
                            begin
                                Result := 0.0021887289445363277;
                            end
                            else
                            begin
                                Result := 0.019629505388882688;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[175] <= -1322.9999999999998 then
                    begin
                        Result := 0.00049228476414390034;
                    end
                    else
                    begin
                        if features[184] <= -362.49999999999994 then
                        begin
                            Result := 0.029656174885443854;
                        end
                        else
                        begin
                            Result := 0.013229807131372371;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[18] <= 13.500000000000002 then
                begin
                    Result := -0.001874223929865442;
                end
                else
                begin
                    Result := 0.01060742427495766;
                end;
            end;
        end
        else
        begin
            if features[192] <= -5921.4999999999991 then
            begin
                if features[173] <= -4831.4999999999991 then
                begin
                    Result := -0.010286311749184965;
                end
                else
                begin
                    Result := 0.010497064400989924;
                end;
            end
            else
            begin
                Result := 0.0017479507758778965;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_67(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -649.49999999999989 then
    begin
        if features[164] <= -207553103.99999997 then
        begin
            Result := -0.019193598192545465;
        end
        else
        begin
            Result := -0.0062791515835968897;
        end;
    end
    else
    begin
        if features[164] <= -320634399.99999994 then
        begin
            if features[198] <= -4153.4999999999991 then
            begin
                Result := -0.012093152693832787;
            end
            else
            begin
                Result := 0.011284372291313289;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[189] <= -4389.4999999999991 then
                begin
                    if features[198] <= -3806.4999999999995 then
                    begin
                        if features[126] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.0042266559835457008;
                        end
                        else
                        begin
                            if features[167] <= 1.5000000000000002 then
                            begin
                                if features[175] <= -423.49999999999994 then
                                begin
                                    Result := 0.0071417578641648112;
                                end
                                else
                                begin
                                    Result := -0.0057423644180684859;
                                end;
                            end
                            else
                            begin
                                Result := -0.011835230435152918;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.021916346999139736;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.00502937551645595;
                    end
                    else
                    begin
                        Result := 0.016799033260321596;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.003256711590771514;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[90] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.087679488721689347;
                        end
                        else
                        begin
                            Result := -0.02717216359237324;
                        end;
                    end
                    else
                    begin
                        Result := 0.0090771541749734199;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_68(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -873.49999999999989 then
    begin
        Result := -0.015735084154452347;
    end
    else
    begin
        if features[164] <= -310909967.99999994 then
        begin
            if features[198] <= -4153.4999999999991 then
            begin
                Result := -0.012354043617333221;
            end
            else
            begin
                Result := 0.0075046326099877997;
            end;
        end
        else
        begin
            if features[199] <= -98.499999999999986 then
            begin
                if features[173] <= -5561.4999999999991 then
                begin
                    if features[177] <= -4914.9999999999991 then
                    begin
                        if features[118] <= 1.0000000180025095E-35 then
                        begin
                            if features[189] <= -6241.4999999999991 then
                            begin
                                if features[174] <= -7273.4999999999991 then
                                begin
                                    Result := 0.011629276161510998;
                                end
                                else
                                begin
                                    Result := 0.070651566095237747;
                                end;
                            end
                            else
                            begin
                                Result := 0.0015265023866705826;
                            end;
                        end
                        else
                        begin
                            Result := -0.0066773576027497304;
                        end;
                    end
                    else
                    begin
                        Result := 0.024413481380171489;
                    end;
                end
                else
                begin
                    if features[173] <= -4869.4999999999991 then
                    begin
                        Result := -0.011372372628481999;
                    end
                    else
                    begin
                        if features[173] <= -4748.9999999999991 then
                        begin
                            Result := 0.015174119436356982;
                        end
                        else
                        begin
                            Result := -0.0044474667457236041;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[46] <= 12.500000000000002 then
                begin
                    if features[90] <= 8.5000000000000018 then
                    begin
                        Result := 0.0023909077679443295;
                    end
                    else
                    begin
                        if features[95] <= -16015753.499999998 then
                        begin
                            Result := -0.00051852864165378727;
                        end
                        else
                        begin
                            Result := 0.021068352174692943;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.011935920686983313;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_69(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -569.49999999999989 then
    begin
        if features[164] <= -204367687.99999997 then
        begin
            Result := -0.020286418669714121;
        end
        else
        begin
            Result := -0.0067680086537722436;
        end;
    end
    else
    begin
        if features[202] <= -118.49999999999999 then
        begin
            if features[164] <= -60625469.999999993 then
            begin
                Result := -0.004980250762789731;
            end
            else
            begin
                if features[189] <= -6747.4999999999991 then
                begin
                    Result := 0.039894445892190745;
                end
                else
                begin
                    Result := 0.0037948873279840933;
                end;
            end;
        end
        else
        begin
            if features[54] <= 11.500000000000002 then
            begin
                if features[176] <= -5255.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        if features[0] <= -119012.99999999999 then
                        begin
                            Result := 0.024066501948273547;
                        end
                        else
                        begin
                            Result := 0.0058439525585062217;
                        end;
                    end
                    else
                    begin
                        if features[192] <= -6068.4999999999991 then
                        begin
                            if features[188] <= -4752.4999999999991 then
                            begin
                                Result := -0.012547735419526222;
                            end
                            else
                            begin
                                Result := 0.008487058478446349;
                            end;
                        end
                        else
                        begin
                            Result := 0.003762011273752898;
                        end;
                    end;
                end
                else
                begin
                    if features[109] <= -277.49999999999994 then
                    begin
                        Result := -0.016024652653698658;
                    end
                    else
                    begin
                        if features[189] <= -4048.9999999999995 then
                        begin
                            Result := 0.0086338963734124384;
                        end
                        else
                        begin
                            Result := -0.014561907273498804;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[66] <= 1218.0000000000002 then
                begin
                    Result := 0.017962298683880006;
                end
                else
                begin
                    Result := -0.018430412542254103;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_70(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -815.49999999999989 then
    begin
        Result := -0.014707167444278786;
    end
    else
    begin
        if features[164] <= -325222047.99999994 then
        begin
            Result := -0.0094670030084320535;
        end
        else
        begin
            if features[166] <= 118461356.00000001 then
            begin
                if features[202] <= 321.50000000000006 then
                begin
                    if features[166] <= -9481247.4999999981 then
                    begin
                        if features[184] <= -540.49999999999989 then
                        begin
                            Result := 0.049223583513859179;
                        end
                        else
                        begin
                            Result := 0.0096488302577739712;
                        end;
                    end
                    else
                    begin
                        if features[188] <= -3966.4999999999995 then
                        begin
                            if features[176] <= -9527.4999999999982 then
                            begin
                                Result := -0.0048521804601307826;
                            end
                            else
                            begin
                                if features[164] <= -197851207.99999997 then
                                begin
                                    Result := -0.0013759440475023138;
                                end
                                else
                                begin
                                    Result := 0.0054644413449682089;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[190] <= -143.49999999999997 then
                            begin
                                Result := 0.0024417528586877699;
                            end
                            else
                            begin
                                if features[90] <= 1.0000000180025095E-35 then
                                begin
                                    if features[167] <= 1.5000000000000002 then
                                    begin
                                        Result := 0.081842774948696517;
                                    end
                                    else
                                    begin
                                        Result := -0.0074361583726979211;
                                    end;
                                end
                                else
                                begin
                                    if features[189] <= -3832.4999999999995 then
                                    begin
                                        Result := -0.025653533073161525;
                                    end
                                    else
                                    begin
                                        Result := 0.01733453476378349;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[188] <= -6199.9999999999991 then
                    begin
                        Result := 0.0020340355262371368;
                    end
                    else
                    begin
                        Result := 0.017129037859740463;
                    end;
                end;
            end
            else
            begin
                Result := -0.0087010999424281324;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_71(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -663.49999999999989 then
    begin
        if features[164] <= -129461379.99999999 then
        begin
            Result := -0.017272808483238034;
        end
        else
        begin
            Result := -0.0025682132971146837;
        end;
    end
    else
    begin
        if features[186] <= -329.83332824707026 then
        begin
            if features[174] <= -8119.4999999999991 then
            begin
                if features[195] <= -6151.4999999999991 then
                begin
                    Result := -0.006625582467826254;
                end
                else
                begin
                    Result := 0.012815718052280076;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.01919819224618451;
                end
                else
                begin
                    Result := -0.003645992675090793;
                end;
            end;
        end
        else
        begin
            if features[202] <= 181.50000000000003 then
            begin
                if features[184] <= -509.49999999999994 then
                begin
                    Result := 0.0088636039066636394;
                end
                else
                begin
                    if features[173] <= -4832.4999999999991 then
                    begin
                        if features[173] <= -5591.4999999999991 then
                        begin
                            if features[191] <= -4433.4999999999991 then
                            begin
                                Result := 0.00038367697173117562;
                            end
                            else
                            begin
                                Result := 0.015132780770436545;
                            end;
                        end
                        else
                        begin
                            Result := -0.010706808945631282;
                        end;
                    end
                    else
                    begin
                        if features[25] <= 2.5000000000000004 then
                        begin
                            Result := 0.0014637610594870742;
                        end
                        else
                        begin
                            Result := 0.022798920261440175;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[191] <= -6342.4999999999991 then
                begin
                    Result := 0.0019553299885979622;
                end
                else
                begin
                    if features[183] <= -5320.4999999999991 then
                    begin
                        Result := 0.017097099802289028;
                    end
                    else
                    begin
                        Result := -0.0019348264622838279;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_72(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -438.49999999999994 then
    begin
        if features[199] <= -1032.4999999999998 then
        begin
            Result := -0.017932742894820757;
        end
        else
        begin
            if features[189] <= -6747.4999999999991 then
            begin
                Result := 0.016460521987737516;
            end
            else
            begin
                Result := -0.0078416527940461458;
            end;
        end;
    end
    else
    begin
        if features[202] <= 145.50000000000003 then
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[166] <= -5634314.4999999991 then
                begin
                    Result := 0.017756849755358742;
                end
                else
                begin
                    if features[15] <= -5959789.4999999991 then
                    begin
                        Result := 0.0083299952245001248;
                    end
                    else
                    begin
                        if features[122] <= -1039.4999999999998 then
                        begin
                            Result := -0.014740867220755977;
                        end
                        else
                        begin
                            Result := 0.00058765342720320862;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.011608751754812584;
                end
                else
                begin
                    Result := 0.0011937773025372609;
                end;
            end;
        end
        else
        begin
            if features[18] <= 15.500000000000002 then
            begin
                if features[193] <= -394.49999999999994 then
                begin
                    Result := 0.030497819992628392;
                end
                else
                begin
                    if features[188] <= -7079.4999999999991 then
                    begin
                        Result := -0.0055649437927087998;
                    end
                    else
                    begin
                        if features[176] <= -5759.4999999999991 then
                        begin
                            Result := 0.0082560469761639443;
                        end
                        else
                        begin
                            if features[201] <= -3901.4999999999995 then
                            begin
                                Result := -0.014248639148465274;
                            end
                            else
                            begin
                                Result := 0.013702878822328632;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.023878750493159347;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_73(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -873.49999999999989 then
    begin
        Result := -0.014895530921407656;
    end
    else
    begin
        if features[164] <= -288500527.99999994 then
        begin
            if features[202] <= 380.50000000000006 then
            begin
                Result := -0.010194353384393817;
            end
            else
            begin
                Result := 0.0097737830003698737;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[195] <= -4812.4999999999991 then
                begin
                    if features[164] <= -57023309.999999993 then
                    begin
                        if features[154] <= 83.500000000000014 then
                        begin
                            if features[81] <= -233.49999999999997 then
                            begin
                                Result := -0.0020575617855311426;
                            end
                            else
                            begin
                                Result := 0.0054090182548191482;
                            end;
                        end
                        else
                        begin
                            Result := -0.011290255699464402;
                        end;
                    end
                    else
                    begin
                        if features[158] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.00031918640634972975;
                        end
                        else
                        begin
                            Result := 0.012364214570898376;
                        end;
                    end;
                end
                else
                begin
                    if features[181] <= 731.50000000000011 then
                    begin
                        Result := 0.010702936942740916;
                    end
                    else
                    begin
                        Result := -0.0060732009149790907;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.0017646791672701848;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := 0.076766661901338754;
                        end
                        else
                        begin
                            Result := -2.9427891944277431E-05;
                        end;
                    end
                    else
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := -0.026831929688311801;
                        end
                        else
                        begin
                            Result := 0.012700127383045127;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_74(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -873.49999999999989 then
    begin
        Result := -0.014741399156907612;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[202] <= 466.50000000000006 then
            begin
                Result := -0.007949943624861882;
            end
            else
            begin
                Result := 0.012797116151325665;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[154] <= 40.500000000000007 then
                begin
                    if features[164] <= -57023309.999999993 then
                    begin
                        if features[81] <= -233.49999999999997 then
                        begin
                            if features[189] <= -4389.4999999999991 then
                            begin
                                if features[105] <= 1.0000000180025095E-35 then
                                begin
                                    Result := 0.0015816532746522991;
                                end
                                else
                                begin
                                    Result := -0.0082379636517373508;
                                end;
                            end
                            else
                            begin
                                Result := 0.011003475959604953;
                            end;
                        end
                        else
                        begin
                            Result := 0.008071718857073017;
                        end;
                    end
                    else
                    begin
                        Result := 0.011186665529703854;
                    end;
                end
                else
                begin
                    if features[194] <= -5958.4999999999991 then
                    begin
                        Result := -0.011539362943015972;
                    end
                    else
                    begin
                        Result := 0.0021470578360686127;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.0014475696049396525;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := 0.075083935475552754;
                        end
                        else
                        begin
                            Result := -0.0061086949524096698;
                        end;
                    end
                    else
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := -0.026663112998004529;
                        end
                        else
                        begin
                            Result := 0.014584913669221659;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_75(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -873.49999999999989 then
    begin
        if features[189] <= -6241.4999999999991 then
        begin
            if features[175] <= 719.50000000000011 then
            begin
                Result := -0.0047385480314273481;
            end
            else
            begin
                if features[183] <= -7076.4999999999991 then
                begin
                    Result := 0.0030911716318246909;
                end
                else
                begin
                    Result := 0.14121598179692724;
                end;
            end;
        end
        else
        begin
            Result := -0.017834549887073215;
        end;
    end
    else
    begin
        if features[164] <= -141296575.99999997 then
        begin
            if features[199] <= -126.49999999999999 then
            begin
                Result := -0.0065189410341033108;
            end
            else
            begin
                if features[195] <= -5359.4999999999991 then
                begin
                    if features[179] <= -6597.4999999999991 then
                    begin
                        if features[191] <= -5834.4999999999991 then
                        begin
                            Result := -0.0055355597521229219;
                        end
                        else
                        begin
                            Result := 0.010370955790672641;
                        end;
                    end
                    else
                    begin
                        Result := -0.015449772541172916;
                    end;
                end
                else
                begin
                    if features[27] <= -5594.4999999999991 then
                    begin
                        Result := 0.019169493178369232;
                    end
                    else
                    begin
                        if features[193] <= -1181.4999999999998 then
                        begin
                            Result := 0.061860418322745137;
                        end
                        else
                        begin
                            Result := 0.0022935856447422252;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[166] <= 72871844.000000015 then
            begin
                if features[181] <= -570.49999999999989 then
                begin
                    if features[109] <= -101.49999999999999 then
                    begin
                        Result := 0.0088612726029591721;
                    end
                    else
                    begin
                        Result := 0.061181582414973984;
                    end;
                end
                else
                begin
                    Result := 0.003694680500895556;
                end;
            end
            else
            begin
                Result := -0.0045582435666084459;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_76(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -894.49999999999989 then
    begin
        if features[189] <= -6155.4999999999991 then
        begin
            if features[174] <= -8246.4999999999982 then
            begin
                Result := -0.0097725015743752325;
            end
            else
            begin
                if features[195] <= -5214.4999999999991 then
                begin
                    Result := 0.012976117608179058;
                end
                else
                begin
                    Result := 0.12188054123878833;
                end;
            end;
        end
        else
        begin
            Result := -0.018430739523432819;
        end;
    end
    else
    begin
        if features[164] <= -315822463.99999994 then
        begin
            if features[198] <= -4153.4999999999991 then
            begin
                Result := -0.012394372253991526;
            end
            else
            begin
                Result := 0.0076768745320675126;
            end;
        end
        else
        begin
            if features[202] <= -36.499999999999993 then
            begin
                if features[188] <= -3964.9999999999995 then
                begin
                    Result := 0.0006416437607574784;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := -0.0021991144841889908;
                    end
                    else
                    begin
                        Result := -0.019323979708183975;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -5151.4999999999991 then
                begin
                    if features[191] <= -6310.4999999999991 then
                    begin
                        if features[166] <= 89095740.000000015 then
                        begin
                            Result := 0.0022501058358026893;
                        end
                        else
                        begin
                            Result := -0.016381089587166213;
                        end;
                    end
                    else
                    begin
                        if features[202] <= 528.50000000000011 then
                        begin
                            if features[180] <= -7512.4999999999991 then
                            begin
                                Result := 0.013167827867071699;
                            end
                            else
                            begin
                                Result := 0.0041964812374774693;
                            end;
                        end
                        else
                        begin
                            Result := 0.030304796061096734;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0074645930282275065;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_77(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -524.49999999999989 then
    begin
        if features[164] <= -249149359.99999997 then
        begin
            Result := -0.018681450337451937;
        end
        else
        begin
            if features[189] <= -6876.4999999999991 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    Result := 0.04533914884126191;
                end
                else
                begin
                    Result := 0.00075240301748073963;
                end;
            end
            else
            begin
                if features[199] <= -1244.4999999999998 then
                begin
                    Result := -0.020222670751084994;
                end
                else
                begin
                    if features[177] <= -6367.4999999999991 then
                    begin
                        Result := -0.0072235191174733404;
                    end
                    else
                    begin
                        if features[188] <= -3964.9999999999995 then
                        begin
                            if features[185] <= -286.74999999999994 then
                            begin
                                Result := -0.0086126173385381224;
                            end
                            else
                            begin
                                if features[196] <= -1059.4999999999998 then
                                begin
                                    Result := 0.082300988542782158;
                                end
                                else
                                begin
                                    Result := 0.016475775577021564;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.017795110525996433;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[164] <= -315822463.99999994 then
            begin
                Result := -0.0080396570925559841;
            end
            else
            begin
                if features[92] <= 1.5000000000000002 then
                begin
                    if features[190] <= 2732.0000000000005 then
                    begin
                        if features[199] <= 335.50000000000006 then
                        begin
                            Result := 0.0010944476787171401;
                        end
                        else
                        begin
                            Result := 0.0081881026668711009;
                        end;
                    end
                    else
                    begin
                        Result := -0.012329460138319865;
                    end;
                end
                else
                begin
                    Result := 0.012579753880009753;
                end;
            end;
        end
        else
        begin
            Result := 0.022054643789508766;
        end;
    end;
end;

function settled_top2_residual_tree_78(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -663.49999999999989 then
    begin
        if features[164] <= -159512847.99999997 then
        begin
            Result := -0.016938947579391392;
        end
        else
        begin
            if features[189] <= -6876.4999999999991 then
            begin
                Result := 0.024146506408379911;
            end
            else
            begin
                Result := -0.0063554509301663956;
            end;
        end;
    end
    else
    begin
        if features[164] <= -141296575.99999997 then
        begin
            if features[199] <= 335.50000000000006 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0010519986445959024;
                end
                else
                begin
                    Result := -0.010576067136794005;
                end;
            end
            else
            begin
                if features[188] <= -7079.4999999999991 then
                begin
                    Result := -0.010042125224981081;
                end
                else
                begin
                    Result := 0.011397696182906624;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[9] <= 1.5000000000000002 then
                begin
                    Result := -0.0018032645863280264;
                end
                else
                begin
                    if features[166] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.017824334561702172;
                    end
                    else
                    begin
                        Result := 0.0058095643344579194;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -6847.4999999999991 then
                begin
                    Result := 0.0086399565126497584;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[135] <= 1.0000000180025095E-35 then
                        begin
                            if features[189] <= -4016.4999999999995 then
                            begin
                                Result := -0.014001138783466894;
                            end
                            else
                            begin
                                Result := 0.070255662876858235;
                            end;
                        end
                        else
                        begin
                            Result := -0.023464377684914162;
                        end;
                    end
                    else
                    begin
                        Result := -0.00051268560202138221;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_79(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -245435391.99999997 then
        begin
            Result := -0.01522563142011709;
        end
        else
        begin
            if features[199] <= -1426.4999999999998 then
            begin
                Result := -0.021918995960745574;
            end
            else
            begin
                if features[189] <= -7048.4999999999991 then
                begin
                    Result := 0.020659684853262181;
                end
                else
                begin
                    if features[176] <= -7607.4999999999991 then
                    begin
                        Result := -0.008780176073007441;
                    end
                    else
                    begin
                        if features[185] <= 166.25000000000003 then
                        begin
                            if features[164] <= -15719408.499999998 then
                            begin
                                Result := -0.0029757483222431365;
                            end
                            else
                            begin
                                Result := 0.012221782232169819;
                            end;
                        end
                        else
                        begin
                            if features[194] <= -4968.4999999999991 then
                            begin
                                if features[188] <= -4752.4999999999991 then
                                begin
                                    Result := 0.032627093367301269;
                                end
                                else
                                begin
                                    Result := 0.12691140612328064;
                                end;
                            end
                            else
                            begin
                                Result := 0.0073363051551039371;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[9] <= 11.500000000000002 then
        begin
            if features[92] <= 1.5000000000000002 then
            begin
                if features[164] <= -156440759.99999997 then
                begin
                    if features[201] <= -4669.4999999999991 then
                    begin
                        Result := -0.0069308966183106793;
                    end
                    else
                    begin
                        Result := 0.0014895702940676523;
                    end;
                end
                else
                begin
                    Result := 0.0030548850815046037;
                end;
            end
            else
            begin
                if features[201] <= -4104.4999999999991 then
                begin
                    Result := 0.0082090451498522399;
                end
                else
                begin
                    Result := 0.032749804349810438;
                end;
            end;
        end
        else
        begin
            Result := 0.012360235026299604;
        end;
    end;
end;

function settled_top2_residual_tree_80(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.016668508896975805;
    end
    else
    begin
        if features[164] <= -325222047.99999994 then
        begin
            if features[195] <= -4595.4999999999991 then
            begin
                Result := -0.013515879112436594;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.016080440547680007;
                end
                else
                begin
                    Result := 0.013191698726504815;
                end;
            end;
        end
        else
        begin
            if features[92] <= 1.5000000000000002 then
            begin
                if features[166] <= 118461356.00000001 then
                begin
                    if features[188] <= -3966.4999999999995 then
                    begin
                        if features[166] <= -13612611.999999998 then
                        begin
                            if features[184] <= -540.49999999999989 then
                            begin
                                Result := 0.048356397146071733;
                            end
                            else
                            begin
                                Result := 0.011559677893031466;
                            end;
                        end
                        else
                        begin
                            if features[195] <= -4812.4999999999991 then
                            begin
                                Result := 0.0013087224336471555;
                            end
                            else
                            begin
                                Result := 0.0068271093495220134;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[190] <= -143.49999999999997 then
                        begin
                            if features[171] <= 3.5000000000000004 then
                            begin
                                Result := 0.010664142085787476;
                            end
                            else
                            begin
                                Result := -0.0037960447162016797;
                            end;
                        end
                        else
                        begin
                            if features[172] <= 1.5000000000000002 then
                            begin
                                if features[9] <= 1.5000000000000002 then
                                begin
                                    Result := 0.069258236227634079;
                                end
                                else
                                begin
                                    Result := -0.025396248892203044;
                                end;
                            end
                            else
                            begin
                                Result := 0.007840999376726469;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0091939650545580648;
                end;
            end
            else
            begin
                Result := 0.012905808451292293;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_81(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.016382323926040082;
    end
    else
    begin
        if features[164] <= -224280343.99999997 then
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[185] <= -399.74999999999994 then
                begin
                    Result := -0.0074767395704117808;
                end
                else
                begin
                    if features[11] <= 2.5000000000000004 then
                    begin
                        Result := 0.0021994211549208093;
                    end
                    else
                    begin
                        Result := 0.027978548733595274;
                    end;
                end;
            end
            else
            begin
                Result := -0.013682015411812505;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[90] <= -1.4999999999999998 then
                begin
                    if features[140] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.010814425340787436;
                    end
                    else
                    begin
                        Result := -0.0092348722844573673;
                    end;
                end
                else
                begin
                    if features[191] <= -4433.4999999999991 then
                    begin
                        if features[166] <= -16113090.499999998 then
                        begin
                            Result := 0.01810041432664649;
                        end
                        else
                        begin
                            Result := 0.0033488782906453359;
                        end;
                    end
                    else
                    begin
                        Result := 0.01463774820197588;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.00017128302696860757;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[189] <= -3832.4999999999995 then
                        begin
                            Result := 0.063917069242959881;
                        end
                        else
                        begin
                            Result := -0.0047415495161364576;
                        end;
                    end
                    else
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := -0.026305602432052086;
                        end
                        else
                        begin
                            Result := 0.012985276707853325;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_82(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -663.49999999999989 then
    begin
        if features[189] <= -6876.4999999999991 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                Result := 0.044872499126621633;
            end
            else
            begin
                Result := 0.0017820130816603556;
            end;
        end
        else
        begin
            if features[164] <= -204367687.99999997 then
            begin
                Result := -0.018582548541176771;
            end
            else
            begin
                Result := -0.0068419948961930465;
            end;
        end;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[173] <= -6126.4999999999991 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[175] <= -423.49999999999994 then
                    begin
                        Result := 0.010760801473439295;
                    end
                    else
                    begin
                        if features[171] <= 1.5000000000000002 then
                        begin
                            Result := -0.0070333210835402844;
                        end
                        else
                        begin
                            if features[202] <= 181.50000000000003 then
                            begin
                                Result := -0.0004573714001441332;
                            end
                            else
                            begin
                                Result := 0.014180274808154869;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[189] <= -5326.4999999999991 then
                    begin
                        Result := 0.0053720418752302088;
                    end
                    else
                    begin
                        Result := 0.019547085308289688;
                    end;
                end;
            end
            else
            begin
                Result := -0.0011811052676133716;
            end;
        end
        else
        begin
            if features[81] <= -233.49999999999997 then
            begin
                Result := -0.0087779061371855809;
            end
            else
            begin
                if features[175] <= -890.49999999999989 then
                begin
                    Result := 0.0069481772506587661;
                end
                else
                begin
                    if features[175] <= -863.49999999999989 then
                    begin
                        Result := -0.025399231261110211;
                    end
                    else
                    begin
                        Result := -0.00093877418553820033;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_83(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -894.49999999999989 then
    begin
        if features[164] <= -101450115.99999999 then
        begin
            Result := -0.018133038244741988;
        end
        else
        begin
            Result := -0.0034150386599672519;
        end;
    end
    else
    begin
        if features[202] <= -28.499999999999996 then
        begin
            if features[164] <= -231151343.99999997 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0048724673531649098;
                end
                else
                begin
                    Result := -0.017606347485465076;
                end;
            end
            else
            begin
                if features[188] <= -3964.9999999999995 then
                begin
                    if features[135] <= -1.4999999999999998 then
                    begin
                        Result := -0.00725560946514323;
                    end
                    else
                    begin
                        Result := 0.0028708513459758879;
                    end;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := -0.0015945709419279957;
                    end
                    else
                    begin
                        Result := -0.018234896518868626;
                    end;
                end;
            end;
        end
        else
        begin
            if features[27] <= -5865.4999999999991 then
            begin
                if features[188] <= -5611.4999999999991 then
                begin
                    if features[54] <= 10.500000000000002 then
                    begin
                        Result := 0.00028109208815524058;
                    end
                    else
                    begin
                        Result := 0.028300256366173032;
                    end;
                end
                else
                begin
                    Result := 0.017226617452021458;
                end;
            end
            else
            begin
                if features[198] <= -4971.4999999999991 then
                begin
                    Result := -0.0013842087526181716;
                end
                else
                begin
                    if features[177] <= -6641.4999999999991 then
                    begin
                        Result := 0.011149052793547528;
                    end
                    else
                    begin
                        if features[108] <= 32.500000000000007 then
                        begin
                            Result := -0.0047669790926435284;
                        end
                        else
                        begin
                            Result := 0.010856676451887643;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_84(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.016340834697426129;
    end
    else
    begin
        if features[164] <= -325222047.99999994 then
        begin
            if features[198] <= -3884.4999999999995 then
            begin
                Result := -0.011654286889093549;
            end
            else
            begin
                Result := 0.013365261415941848;
            end;
        end
        else
        begin
            if features[164] <= -91709047.999999985 then
            begin
                if features[11] <= 2.5000000000000004 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        if features[9] <= 12.500000000000002 then
                        begin
                            if features[190] <= 3421.5000000000005 then
                            begin
                                if features[173] <= -6206.4999999999991 then
                                begin
                                    if features[195] <= -5521.4999999999991 then
                                    begin
                                        Result := -0.0012475169572703088;
                                    end
                                    else
                                    begin
                                        if features[184] <= -1020.4999999999999 then
                                        begin
                                            Result := 0.026808054508621587;
                                        end
                                        else
                                        begin
                                            Result := 0.0055695166840874777;
                                        end;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.0035962857418321593;
                                end;
                            end
                            else
                            begin
                                Result := -0.018220770666660804;
                            end;
                        end
                        else
                        begin
                            Result := 0.011989371574061145;
                        end;
                    end
                    else
                    begin
                        if features[148] <= 1147.0000000000002 then
                        begin
                            if features[198] <= -5057.4999999999991 then
                            begin
                                Result := -0.010829624681459704;
                            end
                            else
                            begin
                                Result := -0.0012697247795126596;
                            end;
                        end
                        else
                        begin
                            Result := 0.024642876172896171;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.013436361946549064;
                end;
            end
            else
            begin
                if features[90] <= 8.5000000000000018 then
                begin
                    Result := 0.0039205226158548776;
                end
                else
                begin
                    Result := 0.017179577930904546;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_85(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -873.49999999999989 then
    begin
        Result := -0.01331622861124529;
    end
    else
    begin
        if features[164] <= -88461003.999999985 then
        begin
            if features[105] <= 1.0000000180025095E-35 then
            begin
                if features[117] <= -293.49999999999994 then
                begin
                    Result := -0.0082075691291558627;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[174] <= -6743.9999999999991 then
                        begin
                            Result := 0.002091393402380399;
                        end
                        else
                        begin
                            if features[188] <= -4079.4999999999995 then
                            begin
                                Result := -0.0023763839621052992;
                            end
                            else
                            begin
                                Result := -0.022875633173458376;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[175] <= -706.49999999999989 then
                        begin
                            Result := 0.0005984356822219968;
                        end
                        else
                        begin
                            Result := 0.015781912526015157;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -384867039.99999994 then
                begin
                    Result := -0.021275968092943524;
                end
                else
                begin
                    Result := -0.0047522508380139078;
                end;
            end;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    Result := 0.0094813092058562403;
                end
                else
                begin
                    if features[174] <= -6743.9999999999991 then
                    begin
                        Result := 0.013198855985824591;
                    end
                    else
                    begin
                        Result := -0.013485342345485049;
                    end;
                end;
            end
            else
            begin
                if features[140] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.012156041219580849;
                end
                else
                begin
                    if features[158] <= -2464.4999999999995 then
                    begin
                        Result := -0.0072252267258856723;
                    end
                    else
                    begin
                        Result := 0.0029399326245560385;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_86(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -719.49999999999989 then
    begin
        Result := -0.013619037854591481;
    end
    else
    begin
        if features[164] <= -315822463.99999994 then
        begin
            if features[198] <= -3884.4999999999995 then
            begin
                Result := -0.010464907498005362;
            end
            else
            begin
                Result := 0.015520788363047875;
            end;
        end
        else
        begin
            if features[166] <= 76625984.000000015 then
            begin
                if features[202] <= -36.499999999999993 then
                begin
                    if features[188] <= -3964.9999999999995 then
                    begin
                        if features[179] <= -6570.4999999999991 then
                        begin
                            Result := -0.001301732452522762;
                        end
                        else
                        begin
                            if features[186] <= -193.74999999999997 then
                            begin
                                Result := -7.0420554384789479E-05;
                            end
                            else
                            begin
                                if features[191] <= -4279.4999999999991 then
                                begin
                                    Result := 0.010699973716235213;
                                end
                                else
                                begin
                                    Result := 0.034076589156978927;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[190] <= -143.49999999999997 then
                        begin
                            Result := -0.0011517119921337323;
                        end
                        else
                        begin
                            Result := -0.018963267986257547;
                        end;
                    end;
                end
                else
                begin
                    if features[177] <= -6815.4999999999991 then
                    begin
                        if features[192] <= -6037.4999999999991 then
                        begin
                            if features[181] <= 320.50000000000006 then
                            begin
                                Result := 0.0051538644886683499;
                            end
                            else
                            begin
                                Result := -0.0060670783481850043;
                            end;
                        end
                        else
                        begin
                            Result := 0.010913818848337529;
                        end;
                    end
                    else
                    begin
                        if features[185] <= -148.83333587646482 then
                        begin
                            Result := -0.0097281393338448478;
                        end
                        else
                        begin
                            Result := 0.0041074775135052782;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0054716580583506714;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_87(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -224280343.99999997 then
        begin
            Result := -0.013538854548432695;
        end
        else
        begin
            if features[189] <= -6241.4999999999991 then
            begin
                if features[175] <= 855.00000000000011 then
                begin
                    Result := 0.0054262533418737635;
                end
                else
                begin
                    if features[179] <= -7681.4999999999991 then
                    begin
                        Result := 0.0001452513756753119;
                    end
                    else
                    begin
                        Result := 0.10136771392162558;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -7607.4999999999991 then
                begin
                    Result := -0.010371028555334812;
                end
                else
                begin
                    if features[185] <= 166.25000000000003 then
                    begin
                        Result := -0.0015421013720623336;
                    end
                    else
                    begin
                        if features[195] <= -5503.4999999999991 then
                        begin
                            if features[188] <= -4752.4999999999991 then
                            begin
                                Result := 0.02011802505017854;
                            end
                            else
                            begin
                                Result := 0.13747087005718472;
                            end;
                        end
                        else
                        begin
                            Result := 0.0031663963832636657;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[9] <= 11.500000000000002 then
        begin
            if features[92] <= 1.5000000000000002 then
            begin
                if features[164] <= -107473627.99999999 then
                begin
                    Result := -0.0018648836867034158;
                end
                else
                begin
                    Result := 0.0035860347521843015;
                end;
            end
            else
            begin
                Result := 0.011595107451888229;
            end;
        end
        else
        begin
            if features[66] <= 1100.5000000000002 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.028475850374399848;
                end
                else
                begin
                    Result := 0.0091141384890340103;
                end;
            end
            else
            begin
                Result := -0.015176730523934652;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_88(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[202] <= -954.49999999999989 then
        begin
            Result := -0.01844850528819578;
        end
        else
        begin
            if features[117] <= -28.499999999999996 then
            begin
                Result := -0.010496328438534021;
            end
            else
            begin
                if features[47] <= 14210.500000000002 then
                begin
                    Result := -0.0029875374943556885;
                end
                else
                begin
                    Result := 0.0098979124150093429;
                end;
            end;
        end;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[175] <= -890.49999999999989 then
                    begin
                        Result := 0.0056557976271273966;
                    end
                    else
                    begin
                        if features[188] <= -3966.4999999999995 then
                        begin
                            if features[191] <= -5217.4999999999991 then
                            begin
                                if features[175] <= -423.49999999999994 then
                                begin
                                    Result := 0.0083675018805753516;
                                end
                                else
                                begin
                                    Result := -0.0044567390067664202;
                                end;
                            end
                            else
                            begin
                                Result := 0.0087917276668715207;
                            end;
                        end
                        else
                        begin
                            if features[90] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.018853783290950932;
                            end
                            else
                            begin
                                Result := -0.023652936589630861;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[175] <= -706.49999999999989 then
                    begin
                        Result := -8.2812093127485276E-06;
                    end
                    else
                    begin
                        Result := 0.014232078366467138;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -5468.4999999999991 then
                begin
                    Result := -0.0087197193944984885;
                end
                else
                begin
                    Result := 0.0014174379546293143;
                end;
            end;
        end
        else
        begin
            Result := 0.0206368392242295;
        end;
    end;
end;

function settled_top2_residual_tree_89(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.015937829399042976;
    end
    else
    begin
        if features[164] <= -352383311.99999994 then
        begin
            Result := -0.010604392190896476;
        end
        else
        begin
            if features[202] <= 353.50000000000006 then
            begin
                if features[176] <= -9527.4999999999982 then
                begin
                    Result := -0.0063625223389827653;
                end
                else
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        if features[173] <= -6091.4999999999991 then
                        begin
                            if features[117] <= -167.49999999999997 then
                            begin
                                Result := -0.0031591295083106272;
                            end
                            else
                            begin
                                if features[167] <= 1.5000000000000002 then
                                begin
                                    if features[175] <= -423.49999999999994 then
                                    begin
                                        Result := 0.011555044838208208;
                                    end
                                    else
                                    begin
                                        Result := 0.00018543643909032297;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.014585767918407797;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[108] <= 98.500000000000014 then
                            begin
                                if features[92] <= 2.5000000000000004 then
                                begin
                                    Result := -0.0034947840710030037;
                                end
                                else
                                begin
                                    Result := 0.029212310774807373;
                                end;
                            end
                            else
                            begin
                                if features[176] <= -8420.4999999999982 then
                                begin
                                    Result := -0.01013007921634889;
                                end
                                else
                                begin
                                    Result := 0.02175438281535896;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[81] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0089874682372837779;
                        end
                        else
                        begin
                            Result := 0.0032922309372828001;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -6267.4999999999991 then
                begin
                    Result := -0.0018260301182687977;
                end
                else
                begin
                    Result := 0.016089106190901935;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_90(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -315822463.99999994 then
    begin
        if features[199] <= -524.49999999999989 then
        begin
            Result := -0.019662543012023127;
        end
        else
        begin
            Result := -0.0055600545009470183;
        end;
    end
    else
    begin
        if features[202] <= -1043.4999999999998 then
        begin
            Result := -0.01866278661288678;
        end
        else
        begin
            if features[166] <= 118461356.00000001 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[176] <= -9527.4999999999982 then
                    begin
                        if features[189] <= -4792.4999999999991 then
                        begin
                            Result := -0.0060948754072175414;
                        end
                        else
                        begin
                            if features[41] <= 1288.5000000000002 then
                            begin
                                Result := 0.0038609063192804639;
                            end
                            else
                            begin
                                Result := 0.046251782398401081;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[9] <= 5.5000000000000009 then
                        begin
                            if features[47] <= 9300.5000000000018 then
                            begin
                                Result := 0.00051661183315688142;
                            end
                            else
                            begin
                                Result := 0.005774151645010525;
                            end;
                        end
                        else
                        begin
                            if features[172] <= 3.5000000000000004 then
                            begin
                                Result := 0.0073195732064938405;
                            end
                            else
                            begin
                                Result := 0.030761154609626709;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.0014644066849696432;
                    end
                    else
                    begin
                        if features[172] <= 1.5000000000000002 then
                        begin
                            if features[90] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.067544560297216297;
                            end
                            else
                            begin
                                Result := -0.026331626775889544;
                            end;
                        end
                        else
                        begin
                            Result := 0.0084751683786001755;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0076047375689862751;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_91(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -332.49999999999994 then
    begin
        if features[164] <= -231151343.99999997 then
        begin
            Result := -0.013877434434273235;
        end
        else
        begin
            if features[74] <= 9.5000000000000018 then
            begin
                Result := 0.00046820334298024858;
            end
            else
            begin
                Result := -0.0083055621777244695;
            end;
        end;
    end
    else
    begin
        if features[9] <= 11.500000000000002 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[185] <= 19.250000000000004 then
                begin
                    Result := -0.006644732361450279;
                end
                else
                begin
                    if features[193] <= -299.49999999999994 then
                    begin
                        Result := 0.032553593953098779;
                    end
                    else
                    begin
                        Result := 0.0037121750211043638;
                    end;
                end;
            end
            else
            begin
                if features[199] <= 406.50000000000006 then
                begin
                    if features[173] <= -3968.9999999999995 then
                    begin
                        if features[190] <= 663.50000000000011 then
                        begin
                            Result := -0.00016883724805360321;
                        end
                        else
                        begin
                            if features[188] <= -5468.4999999999991 then
                            begin
                                Result := 0.0014304041585525623;
                            end
                            else
                            begin
                                Result := 0.01741075549598807;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.01863617315072201;
                    end;
                end
                else
                begin
                    if features[163] <= 303080096.00000006 then
                    begin
                        if features[107] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0029552918406067488;
                        end
                        else
                        begin
                            Result := 0.017427861396103542;
                        end;
                    end
                    else
                    begin
                        Result := -0.0064464029505722723;
                    end;
                end;
            end;
        end
        else
        begin
            if features[66] <= 1218.0000000000002 then
            begin
                Result := 0.012586762959439023;
            end
            else
            begin
                Result := -0.017467975546419979;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_92(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.015315361550298376;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[173] <= -6126.4999999999991 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[173] <= -7695.4999999999991 then
                    begin
                        if features[173] <= -7705.9999999999991 then
                        begin
                            Result := 0.00015276971608379092;
                        end
                        else
                        begin
                            Result := -0.020915040350400781;
                        end;
                    end
                    else
                    begin
                        if features[174] <= -9070.4999999999982 then
                        begin
                            if features[181] <= -2574.4999999999995 then
                            begin
                                Result := 0.083197134411265;
                            end
                            else
                            begin
                                Result := 0.018937736101101992;
                            end;
                        end
                        else
                        begin
                            if features[202] <= -28.499999999999996 then
                            begin
                                Result := -0.0015360317495124824;
                            end
                            else
                            begin
                                Result := 0.010984859126137165;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[181] <= 247.50000000000003 then
                    begin
                        Result := 0.014547884163791805;
                    end
                    else
                    begin
                        Result := 0.0019289278658360409;
                    end;
                end;
            end
            else
            begin
                Result := -0.002068284448579;
            end;
        end
        else
        begin
            if features[81] <= -233.49999999999997 then
            begin
                if features[192] <= -5469.4999999999991 then
                begin
                    Result := -0.01375072937518982;
                end
                else
                begin
                    Result := -0.00014305706189239798;
                end;
            end
            else
            begin
                if features[148] <= -1138.4999999999998 then
                begin
                    Result := -0.0041205455064430027;
                end
                else
                begin
                    if features[173] <= -4832.4999999999991 then
                    begin
                        Result := 0.0027303183962520943;
                    end
                    else
                    begin
                        Result := 0.022890816774534254;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_93(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -315822463.99999994 then
    begin
        if features[198] <= -3884.4999999999995 then
        begin
            Result := -0.012953879024526506;
        end
        else
        begin
            Result := 0.013812227083393858;
        end;
    end
    else
    begin
        if features[202] <= -1043.4999999999998 then
        begin
            Result := -0.019184984715783088;
        end
        else
        begin
            if features[166] <= 82885308.000000015 then
            begin
                if features[92] <= 1.5000000000000002 then
                begin
                    if features[202] <= -118.49999999999999 then
                    begin
                        if features[189] <= -6876.4999999999991 then
                        begin
                            if features[171] <= 1.0000000180025095E-35 then
                            begin
                                if features[174] <= -9525.9999999999982 then
                                begin
                                    Result := 0.017821307093133829;
                                end
                                else
                                begin
                                    Result := 0.10229070951596363;
                                end;
                            end
                            else
                            begin
                                Result := 0.0031238586214641963;
                            end;
                        end
                        else
                        begin
                            if features[176] <= -7607.4999999999991 then
                            begin
                                Result := -0.0059207961630849508;
                            end
                            else
                            begin
                                if features[185] <= 166.25000000000003 then
                                begin
                                    if features[164] <= -15719408.499999998 then
                                    begin
                                        Result := -0.0024781718084574463;
                                    end
                                    else
                                    begin
                                        Result := 0.0096845137299529024;
                                    end;
                                end
                                else
                                begin
                                    if features[190] <= 472.50000000000006 then
                                    begin
                                        Result := 0.037160406485197715;
                                    end
                                    else
                                    begin
                                        Result := -0.012802933015133706;
                                    end;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[9] <= 10.500000000000002 then
                        begin
                            Result := 0.0021968738375501718;
                        end
                        else
                        begin
                            Result := 0.011839883950290099;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.011079504602332313;
                end;
            end
            else
            begin
                Result := -0.0059636947966333932;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_94(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -903.49999999999989 then
    begin
        Result := -0.017073972213627386;
    end
    else
    begin
        if features[164] <= -315822463.99999994 then
        begin
            if features[202] <= 200.50000000000003 then
            begin
                Result := -0.011307279196018099;
            end
            else
            begin
                Result := 0.0045672642979917672;
            end;
        end
        else
        begin
            if features[164] <= -74905723.999999985 then
            begin
                if features[176] <= -9527.4999999999982 then
                begin
                    Result := -0.0077053346877909131;
                end
                else
                begin
                    if features[199] <= -332.49999999999994 then
                    begin
                        Result := -0.0043865210941428394;
                    end
                    else
                    begin
                        Result := 0.0021143662642504114;
                    end;
                end;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        if features[178] <= -1153.4999999999998 then
                        begin
                            if features[164] <= -24976078.999999996 then
                            begin
                                Result := 0.013810343421041649;
                            end
                            else
                            begin
                                Result := 0.045600447278487027;
                            end;
                        end
                        else
                        begin
                            if features[197] <= -5491.4999999999991 then
                            begin
                                Result := 0.013310168578792917;
                            end
                            else
                            begin
                                Result := 0.0033219862003732456;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[188] <= -4114.4999999999991 then
                        begin
                            Result := 0.0089558898838705513;
                        end
                        else
                        begin
                            Result := -0.018523436682149765;
                        end;
                    end;
                end
                else
                begin
                    if features[143] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.010928750847950874;
                    end
                    else
                    begin
                        if features[158] <= -2464.4999999999995 then
                        begin
                            Result := -0.0075065777376093733;
                        end
                        else
                        begin
                            Result := 0.0022934095403097277;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_95(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.014717900642076587;
    end
    else
    begin
        if features[124] <= -1.0000000180025095E-35 then
        begin
            if features[195] <= -4478.4999999999991 then
            begin
                if features[192] <= -5596.4999999999991 then
                begin
                    Result := -0.0087802658684528554;
                end
                else
                begin
                    if features[185] <= -269.58332824707026 then
                    begin
                        Result := -0.010116477077577254;
                    end
                    else
                    begin
                        Result := 0.0045355273490937089;
                    end;
                end;
            end
            else
            begin
                Result := 0.0043904076627843914;
            end;
        end
        else
        begin
            if features[173] <= -6126.4999999999991 then
            begin
                if features[175] <= -423.49999999999994 then
                begin
                    if features[105] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.01736704410739098;
                    end
                    else
                    begin
                        Result := 0.005995607533620057;
                    end;
                end
                else
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        if features[191] <= -4235.4999999999991 then
                        begin
                            if features[186] <= -125.90000152587889 then
                            begin
                                Result := -0.0054387826633118886;
                            end
                            else
                            begin
                                Result := 0.002518094234915641;
                            end;
                        end
                        else
                        begin
                            Result := 0.016294900818524329;
                        end;
                    end
                    else
                    begin
                        if features[105] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.015573920202450277;
                        end
                        else
                        begin
                            Result := -0.0020386960456077342;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[185] <= -261.74999999999994 then
                begin
                    if features[188] <= -3482.4999999999995 then
                    begin
                        Result := -0.0080909765661086337;
                    end
                    else
                    begin
                        Result := 0.021864638762473618;
                    end;
                end
                else
                begin
                    Result := 0.00073492545801809165;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_96(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1007.4999999999999 then
    begin
        if features[189] <= -7048.4999999999991 then
        begin
            Result := 0.012987336006978427;
        end
        else
        begin
            Result := -0.016364456825459818;
        end;
    end
    else
    begin
        if features[164] <= -141296575.99999997 then
        begin
            if features[199] <= -176.49999999999997 then
            begin
                if features[170] <= 4.5000000000000009 then
                begin
                    Result := -0.0023563681234563508;
                end
                else
                begin
                    Result := -0.010763930201600257;
                end;
            end
            else
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    if features[194] <= -5644.4999999999991 then
                    begin
                        Result := -0.010252209254001526;
                    end
                    else
                    begin
                        Result := 0.00041409243114639855;
                    end;
                end
                else
                begin
                    if features[193] <= -685.49999999999989 then
                    begin
                        Result := 0.030319978936323669;
                    end
                    else
                    begin
                        if features[176] <= -6260.4999999999991 then
                        begin
                            if features[189] <= -4389.4999999999991 then
                            begin
                                Result := 0.0028736643005094105;
                            end
                            else
                            begin
                                Result := 0.016373053090896674;
                            end;
                        end
                        else
                        begin
                            Result := -0.0048195283546786823;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[166] <= 25508058.000000004 then
            begin
                if features[9] <= 4.5000000000000009 then
                begin
                    if features[194] <= -3104.4999999999995 then
                    begin
                        Result := 0.0025570871093987396;
                    end
                    else
                    begin
                        Result := 0.037892209876383476;
                    end;
                end
                else
                begin
                    if features[155] <= -2.4999999999999996 then
                    begin
                        Result := 0.033124344735037087;
                    end
                    else
                    begin
                        Result := 0.008275597149063221;
                    end;
                end;
            end
            else
            begin
                Result := -0.0019212938648436155;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_97(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -438.49999999999994 then
    begin
        if features[164] <= -211178855.99999997 then
        begin
            Result := -0.01579519871907446;
        end
        else
        begin
            if features[189] <= -6747.4999999999991 then
            begin
                Result := 0.017732257101553271;
            end
            else
            begin
                if features[176] <= -7607.4999999999991 then
                begin
                    Result := -0.013487979619057653;
                end
                else
                begin
                    Result := 0.00072646218281343983;
                end;
            end;
        end;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        Result := 0.001533642225479854;
                    end
                    else
                    begin
                        if features[188] <= -4049.4999999999995 then
                        begin
                            Result := 0.00083882200149810538;
                        end
                        else
                        begin
                            if features[90] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.062308212567620064;
                            end
                            else
                            begin
                                Result := -0.027364341640951934;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[175] <= -706.49999999999989 then
                    begin
                        Result := -0.00092130192253594566;
                    end
                    else
                    begin
                        if features[15] <= -68092443.999999985 then
                        begin
                            Result := 0.025517689801853094;
                        end
                        else
                        begin
                            Result := 0.0097766644354241594;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -172095327.99999997 then
                begin
                    Result := -0.0095577865388486241;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.00366984370692713;
                    end
                    else
                    begin
                        Result := -0.0074952136601314631;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.019557964165229407;
        end;
    end;
end;

function settled_top2_residual_tree_98(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.014141037129793775;
    end
    else
    begin
        if features[118] <= 1.0000000180025095E-35 then
        begin
            if features[122] <= -1090.4999999999998 then
            begin
                Result := -0.0095487892528629895;
            end
            else
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        if features[191] <= -4356.4999999999991 then
                        begin
                            if features[175] <= -423.49999999999994 then
                            begin
                                if features[47] <= 9757.5000000000018 then
                                begin
                                    Result := 0.001527481885602508;
                                end
                                else
                                begin
                                    Result := 0.010912971452974894;
                                end;
                            end
                            else
                            begin
                                Result := -0.002794606928257145;
                            end;
                        end
                        else
                        begin
                            Result := 0.01007267018690015;
                        end;
                    end
                    else
                    begin
                        if features[188] <= -4049.4999999999995 then
                        begin
                            if features[171] <= 6.5000000000000009 then
                            begin
                                Result := -0.005406629686587971;
                            end
                            else
                            begin
                                Result := 0.032605009773474719;
                            end;
                        end
                        else
                        begin
                            if features[90] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.066275548140278653;
                            end
                            else
                            begin
                                Result := -0.027226315919572877;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[175] <= -772.49999999999989 then
                    begin
                        Result := -0.00076762427409869606;
                    end
                    else
                    begin
                        Result := 0.01168783071890986;
                    end;
                end;
            end;
        end
        else
        begin
            if features[81] <= -1.0000000180025095E-35 then
            begin
                if features[202] <= 353.50000000000006 then
                begin
                    Result := -0.01042432195073336;
                end
                else
                begin
                    Result := 0.0053542276207444242;
                end;
            end
            else
            begin
                Result := 0.0011799275882748619;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_99(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -352383311.99999994 then
    begin
        Result := -0.012200056415763209;
    end
    else
    begin
        if features[199] <= -187.49999999999997 then
        begin
            if features[189] <= -6876.4999999999991 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[40] <= 1075.5000000000002 then
                    begin
                        Result := 0.055572008873086311;
                    end
                    else
                    begin
                        Result := 0.0055880625492479479;
                    end;
                end
                else
                begin
                    Result := -0.00062546897338906131;
                end;
            end
            else
            begin
                if features[199] <= -1174.4999999999998 then
                begin
                    Result := -0.017108252497398363;
                end
                else
                begin
                    if features[176] <= -7607.4999999999991 then
                    begin
                        Result := -0.0064797174800682511;
                    end
                    else
                    begin
                        if features[186] <= -311.24999999999994 then
                        begin
                            if features[170] <= 4.5000000000000009 then
                            begin
                                Result := 0.00085296775256340238;
                            end
                            else
                            begin
                                Result := -0.012869885011888335;
                            end;
                        end
                        else
                        begin
                            if features[184] <= -1302.4999999999998 then
                            begin
                                Result := 0.056809585563938739;
                            end
                            else
                            begin
                                Result := 0.0034756293378384057;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[201] <= -4669.4999999999991 then
            begin
                if features[27] <= -5908.4999999999991 then
                begin
                    Result := 0.0067174115261365852;
                end
                else
                begin
                    Result := -0.0014431528865826984;
                end;
            end
            else
            begin
                if features[27] <= -4870.4999999999991 then
                begin
                    if features[183] <= -7721.4999999999991 then
                    begin
                        Result := 0.026409789687246485;
                    end
                    else
                    begin
                        Result := 0.010045886558905927;
                    end;
                end
                else
                begin
                    Result := 0.0037409281832245533;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_100(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -352383311.99999994 then
    begin
        Result := -0.011711285285563743;
    end
    else
    begin
        if features[199] <= -1426.4999999999998 then
        begin
            Result := -0.019987087829404653;
        end
        else
        begin
            if features[92] <= 1.5000000000000002 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[173] <= -6126.4999999999991 then
                    begin
                        if features[190] <= 2732.0000000000005 then
                        begin
                            if features[199] <= 335.50000000000006 then
                            begin
                                Result := 0.0036230201887577848;
                            end
                            else
                            begin
                                if features[193] <= 158.50000000000003 then
                                begin
                                    Result := 0.035210091632349734;
                                end
                                else
                                begin
                                    Result := 0.010019421707155949;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[170] <= 3.5000000000000004 then
                            begin
                                Result := 0.034098937192877037;
                            end
                            else
                            begin
                                Result := -0.014785945794828226;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0020173656347420295;
                    end;
                end
                else
                begin
                    if features[81] <= -233.49999999999997 then
                    begin
                        Result := -0.0087824374003213686;
                    end
                    else
                    begin
                        if features[175] <= -890.49999999999989 then
                        begin
                            if features[167] <= 1.5000000000000002 then
                            begin
                                Result := 0.01108209723020024;
                            end
                            else
                            begin
                                Result := -0.010500774913298235;
                            end;
                        end
                        else
                        begin
                            if features[175] <= -819.49999999999989 then
                            begin
                                Result := -0.024726242258888916;
                            end
                            else
                            begin
                                if features[177] <= -5877.4999999999991 then
                                begin
                                    Result := -0.0050955414914140885;
                                end
                                else
                                begin
                                    Result := 0.012950245055253138;
                                end;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.010177926175815581;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_101(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -873.49999999999989 then
    begin
        if features[189] <= -6155.4999999999991 then
        begin
            if features[174] <= -8246.4999999999982 then
            begin
                Result := -0.0054809090571496469;
            end
            else
            begin
                if features[179] <= -7065.4999999999991 then
                begin
                    Result := -0.0047977724307746369;
                end
                else
                begin
                    if features[199] <= -1426.4999999999998 then
                    begin
                        Result := -0.0032733629931523062;
                    end
                    else
                    begin
                        if features[67] <= 2548.5000000000005 then
                        begin
                            Result := 0.12874874396504907;
                        end
                        else
                        begin
                            Result := 0.0070787018404688947;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.015121576112741437;
        end;
    end
    else
    begin
        if features[164] <= -88461003.999999985 then
        begin
            if features[198] <= -5005.4999999999991 then
            begin
                if features[117] <= -15.499999999999998 then
                begin
                    Result := -0.0089799150373757394;
                end
                else
                begin
                    Result := -0.0011782227351251797;
                end;
            end
            else
            begin
                if features[183] <= -7658.4999999999991 then
                begin
                    if features[199] <= 223.50000000000003 then
                    begin
                        Result := 0.0035532359100375697;
                    end
                    else
                    begin
                        Result := 0.036517329796765766;
                    end;
                end
                else
                begin
                    if features[182] <= -4456.4999999999991 then
                    begin
                        Result := 0.0027975223382917386;
                    end
                    else
                    begin
                        Result := -0.0085734628515300015;
                    end;
                end;
            end;
        end
        else
        begin
            if features[158] <= -2464.4999999999995 then
            begin
                if features[143] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.010516834370079158;
                end
                else
                begin
                    Result := -0.0072867323703407335;
                end;
            end
            else
            begin
                Result := 0.0052434052352368929;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_102(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -352383311.99999994 then
    begin
        Result := -0.012194355979835203;
    end
    else
    begin
        if features[202] <= -1043.4999999999998 then
        begin
            Result := -0.018213367681482726;
        end
        else
        begin
            if features[202] <= -118.49999999999999 then
            begin
                if features[189] <= -6571.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        if features[179] <= -7006.4999999999991 then
                        begin
                            Result := 0.016354148218243974;
                        end
                        else
                        begin
                            Result := 0.078468536336069233;
                        end;
                    end
                    else
                    begin
                        Result := 0.0029884164520158295;
                    end;
                end
                else
                begin
                    if features[176] <= -7607.4999999999991 then
                    begin
                        Result := -0.0071883201731331881;
                    end
                    else
                    begin
                        if features[108] <= 86.500000000000014 then
                        begin
                            Result := -0.0011857881195752136;
                        end
                        else
                        begin
                            if features[190] <= 195.50000000000003 then
                            begin
                                if features[195] <= -6035.4999999999991 then
                                begin
                                    Result := 0.068962411605656235;
                                end
                                else
                                begin
                                    Result := 0.01570625387995218;
                                end;
                            end
                            else
                            begin
                                Result := -0.0073256066415305745;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[201] <= -4669.4999999999991 then
                begin
                    if features[179] <= -5129.4999999999991 then
                    begin
                        Result := 0.0010328478677512952;
                    end
                    else
                    begin
                        Result := -0.016623115986563543;
                    end;
                end
                else
                begin
                    if features[27] <= -4870.4999999999991 then
                    begin
                        if features[202] <= 622.50000000000011 then
                        begin
                            Result := 0.011296086397852536;
                        end
                        else
                        begin
                            Result := 0.041166913042106817;
                        end;
                    end
                    else
                    begin
                        Result := 0.0034609612414918203;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_103(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -663.49999999999989 then
    begin
        if features[189] <= -6876.4999999999991 then
        begin
            Result := 0.016047197331692145;
        end
        else
        begin
            Result := -0.010203416304439855;
        end;
    end
    else
    begin
        if features[199] <= 484.50000000000006 then
        begin
            if features[105] <= 1.0000000180025095E-35 then
            begin
                if features[15] <= -5959789.4999999991 then
                begin
                    if features[73] <= 121.50000000000001 then
                    begin
                        Result := 0.029184260295006367;
                    end
                    else
                    begin
                        Result := 0.0054130171035135658;
                    end;
                end
                else
                begin
                    if features[109] <= 129.50000000000003 then
                    begin
                        if features[195] <= -5886.4999999999991 then
                        begin
                            Result := -0.0052801322528983931;
                        end
                        else
                        begin
                            if features[173] <= -6206.4999999999991 then
                            begin
                                Result := 0.0045160820585200172;
                            end
                            else
                            begin
                                Result := -0.0031598466677382579;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[181] <= 247.50000000000003 then
                        begin
                            Result := 0.035673817269803947;
                        end
                        else
                        begin
                            Result := 0.0046024604559912795;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[173] <= -4832.4999999999991 then
                begin
                    Result := -0.004586598848035194;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.015724468517994077;
                    end
                    else
                    begin
                        Result := 0.015589863346572794;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -6199.9999999999991 then
            begin
                if features[173] <= -7968.4999999999991 then
                begin
                    Result := 0.0053114133424780113;
                end
                else
                begin
                    Result := -0.014498340190395568;
                end;
            end
            else
            begin
                Result := 0.015620385994068725;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_104(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.013893213592180671;
    end
    else
    begin
        if features[164] <= -315822463.99999994 then
        begin
            if features[201] <= -4568.4999999999991 then
            begin
                Result := -0.013669698195614758;
            end
            else
            begin
                if features[174] <= -8151.9999999999991 then
                begin
                    Result := 0.017038513378967206;
                end
                else
                begin
                    Result := -0.0053960949259042705;
                end;
            end;
        end
        else
        begin
            if features[166] <= 118461356.00000001 then
            begin
                if features[199] <= 335.50000000000006 then
                begin
                    if features[176] <= -9527.4999999999982 then
                    begin
                        Result := -0.0056782665150229821;
                    end
                    else
                    begin
                        if features[184] <= -526.49999999999989 then
                        begin
                            if features[176] <= -5933.4999999999991 then
                            begin
                                if features[0] <= 18462.500000000004 then
                                begin
                                    Result := 0.028671514142314908;
                                end
                                else
                                begin
                                    Result := 0.0063652292891874422;
                                end;
                            end
                            else
                            begin
                                Result := -0.0026086206161220061;
                            end;
                        end
                        else
                        begin
                            if features[108] <= -125.49999999999999 then
                            begin
                                Result := -0.0042186904108308942;
                            end
                            else
                            begin
                                Result := 0.002392796688256673;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[188] <= -6267.4999999999991 then
                    begin
                        if features[109] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0087672322782107338;
                        end
                        else
                        begin
                            Result := 0.0083695062895124232;
                        end;
                    end
                    else
                    begin
                        if features[180] <= -6963.4999999999991 then
                        begin
                            Result := 0.017904359817625889;
                        end
                        else
                        begin
                            Result := 0.003575604789899497;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0072752071885177072;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_105(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -315822463.99999994 then
    begin
        if features[202] <= 200.50000000000003 then
        begin
            Result := -0.0124005094621767;
        end
        else
        begin
            Result := 0.0068559443855473181;
        end;
    end
    else
    begin
        if features[199] <= -1426.4999999999998 then
        begin
            Result := -0.019368676284738304;
        end
        else
        begin
            if features[166] <= 118461356.00000001 then
            begin
                if features[9] <= 3.5000000000000004 then
                begin
                    if features[81] <= -233.49999999999997 then
                    begin
                        Result := -0.0037167222029800707;
                    end
                    else
                    begin
                        if features[175] <= -890.49999999999989 then
                        begin
                            Result := 0.0074430099258643136;
                        end
                        else
                        begin
                            if features[175] <= -863.49999999999989 then
                            begin
                                Result := -0.023714707169411129;
                            end
                            else
                            begin
                                if features[191] <= -4433.4999999999991 then
                                begin
                                    Result := -0.0010546130943301457;
                                end
                                else
                                begin
                                    if features[67] <= 1351.5000000000002 then
                                    begin
                                        Result := 0.028049317270076146;
                                    end
                                    else
                                    begin
                                        Result := 0.0030849453685719338;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[109] <= 42.500000000000007 then
                    begin
                        if features[126] <= -1.0000000180025095E-35 then
                        begin
                            if features[177] <= -7051.4999999999991 then
                            begin
                                Result := 0.012441671048244654;
                            end
                            else
                            begin
                                Result := -0.0041951899769387974;
                            end;
                        end
                        else
                        begin
                            Result := -0.0011474171405973627;
                        end;
                    end
                    else
                    begin
                        if features[177] <= -5062.4999999999991 then
                        begin
                            Result := 0.0089342471759341468;
                        end
                        else
                        begin
                            Result := 0.043715404040086829;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0077111005157939755;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_106(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -374.49999999999994 then
    begin
        if features[199] <= -1426.4999999999998 then
        begin
            Result := -0.020724106084956326;
        end
        else
        begin
            if features[189] <= -7048.4999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[177] <= -10980.499999999998 then
                    begin
                        Result := -0.011349326288163515;
                    end
                    else
                    begin
                        Result := 0.067949428442094076;
                    end;
                end
                else
                begin
                    Result := 0.0022393284645060808;
                end;
            end
            else
            begin
                if features[117] <= -11.499999999999998 then
                begin
                    Result := -0.010620231768851119;
                end
                else
                begin
                    if features[47] <= 17332.500000000004 then
                    begin
                        Result := -0.0037887982503669484;
                    end
                    else
                    begin
                        Result := 0.011937110754289592;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[201] <= -4669.4999999999991 then
        begin
            if features[179] <= -5129.4999999999991 then
            begin
                if features[150] <= -15.499999999999998 then
                begin
                    Result := 0.0079789146526285156;
                end
                else
                begin
                    Result := -0.0005462420169801836;
                end;
            end
            else
            begin
                Result := -0.015679451186931339;
            end;
        end
        else
        begin
            if features[27] <= -5339.4999999999991 then
            begin
                if features[202] <= 321.50000000000006 then
                begin
                    Result := 0.0087677440213409143;
                end
                else
                begin
                    Result := 0.034122090626995095;
                end;
            end
            else
            begin
                if features[175] <= -933.49999999999989 then
                begin
                    Result := 0.0073285102664833587;
                end
                else
                begin
                    if features[175] <= -863.49999999999989 then
                    begin
                        Result := -0.020224090660945888;
                    end
                    else
                    begin
                        Result := 0.0014205083363720108;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_107(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1032.4999999999998 then
    begin
        Result := -0.013551644989971285;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[173] <= -6126.4999999999991 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[175] <= -423.49999999999994 then
                    begin
                        if features[192] <= -4768.4999999999991 then
                        begin
                            if features[179] <= -7342.4999999999991 then
                            begin
                                Result := 0.0043466785491347963;
                            end
                            else
                            begin
                                Result := 0.015844987286218203;
                            end;
                        end
                        else
                        begin
                            Result := -0.0091660880861271377;
                        end;
                    end
                    else
                    begin
                        Result := -0.00064761803272220426;
                    end;
                end
                else
                begin
                    Result := 0.0090722824712971013;
                end;
            end
            else
            begin
                if features[69] <= 22.500000000000004 then
                begin
                    Result := -0.0028237511391235736;
                end
                else
                begin
                    Result := 0.012464926968795875;
                end;
            end;
        end
        else
        begin
            if features[81] <= -233.49999999999997 then
            begin
                if features[192] <= -5469.4999999999991 then
                begin
                    Result := -0.012391707523772305;
                end
                else
                begin
                    Result := -0.00028995316790903267;
                end;
            end
            else
            begin
                if features[175] <= -890.49999999999989 then
                begin
                    Result := 0.005631306562559682;
                end
                else
                begin
                    if features[175] <= -863.49999999999989 then
                    begin
                        Result := -0.024995194550868897;
                    end
                    else
                    begin
                        if features[191] <= -4156.4999999999991 then
                        begin
                            Result := -0.0036438696645828442;
                        end
                        else
                        begin
                            if features[109] <= -199.49999999999997 then
                            begin
                                Result := -0.0091835883999158881;
                            end
                            else
                            begin
                                Result := 0.03736848589644972;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_108(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -297087183.99999994 then
    begin
        if features[199] <= -524.49999999999989 then
        begin
            Result := -0.018902455421325987;
        end
        else
        begin
            if features[13] <= 111959.50000000001 then
            begin
                Result := -0.004250075098894259;
            end
            else
            begin
                Result := 0.0271795386733318;
            end;
        end;
    end
    else
    begin
        if features[199] <= -1426.4999999999998 then
        begin
            Result := -0.01908331005986276;
        end
        else
        begin
            if features[145] <= -1428.9999999999998 then
            begin
                Result := 0.031561892665226104;
            end
            else
            begin
                if features[90] <= -1.4999999999999998 then
                begin
                    if features[142] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0058323973768840314;
                    end
                    else
                    begin
                        Result := -0.0082436513045597258;
                    end;
                end
                else
                begin
                    if features[164] <= -57023309.999999993 then
                    begin
                        if features[199] <= -176.49999999999997 then
                        begin
                            Result := -0.0024580184189609082;
                        end
                        else
                        begin
                            if features[201] <= -5068.4999999999991 then
                            begin
                                Result := -0.0012914341368850447;
                            end
                            else
                            begin
                                if features[105] <= 1.0000000180025095E-35 then
                                begin
                                    Result := 0.0070898893022988243;
                                end
                                else
                                begin
                                    Result := -0.00074363443513653148;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[183] <= -8861.4999999999982 then
                        begin
                            Result := 0.020262225309811671;
                        end
                        else
                        begin
                            if features[196] <= -1059.4999999999998 then
                            begin
                                if features[183] <= -6056.4999999999991 then
                                begin
                                    Result := 0.011020345687844525;
                                end
                                else
                                begin
                                    Result := 0.090125179145596257;
                                end;
                            end
                            else
                            begin
                                Result := 0.0038473145290429736;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_109(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -954.49999999999989 then
    begin
        Result := -0.017030818880131502;
    end
    else
    begin
        if features[186] <= -538.24999999999989 then
        begin
            if features[174] <= -8119.4999999999991 then
            begin
                if features[195] <= -5521.4999999999991 then
                begin
                    Result := -0.0018832819550971417;
                end
                else
                begin
                    if features[134] <= 4.5000000000000009 then
                    begin
                        Result := 0.029508083937575775;
                    end
                    else
                    begin
                        Result := -5.6822325731618672E-05;
                    end;
                end;
            end
            else
            begin
                Result := -0.012143271681569678;
            end;
        end
        else
        begin
            if features[202] <= 353.50000000000006 then
            begin
                if features[176] <= -9527.4999999999982 then
                begin
                    if features[189] <= -4923.4999999999991 then
                    begin
                        Result := -0.010387172468615861;
                    end
                    else
                    begin
                        Result := 0.005324801607727761;
                    end;
                end
                else
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        if features[173] <= -6091.4999999999991 then
                        begin
                            Result := 0.0046555787992668988;
                        end
                        else
                        begin
                            Result := -0.00080076480213645744;
                        end;
                    end
                    else
                    begin
                        if features[169] <= 1.5000000000000002 then
                        begin
                            if features[188] <= -3833.4999999999995 then
                            begin
                                Result := -0.00050594418611714408;
                            end
                            else
                            begin
                                Result := 0.034865995248125753;
                            end;
                        end
                        else
                        begin
                            Result := -0.012155590438184908;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[191] <= -6583.4999999999991 then
                begin
                    if features[176] <= -7716.4999999999991 then
                    begin
                        Result := 0.0047481653020263097;
                    end
                    else
                    begin
                        Result := -0.0201953202166902;
                    end;
                end
                else
                begin
                    Result := 0.015044129897120007;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_110(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[185] <= -304.41667175292963 then
    begin
        if features[174] <= -8119.4999999999991 then
        begin
            if features[176] <= -5847.4999999999991 then
            begin
                if features[198] <= -4712.4999999999991 then
                begin
                    Result := 0.003972365349123738;
                end
                else
                begin
                    Result := 0.024023305691701854;
                end;
            end
            else
            begin
                Result := -0.010841011563751573;
            end;
        end
        else
        begin
            if features[170] <= 4.5000000000000009 then
            begin
                Result := -0.0024539008722015139;
            end
            else
            begin
                Result := -0.014193765689800004;
            end;
        end;
    end
    else
    begin
        if features[184] <= -1244.4999999999998 then
        begin
            Result := 0.033010315809489189;
        end
        else
        begin
            if features[199] <= 95.500000000000014 then
            begin
                if features[176] <= -7525.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0011659342977884766;
                    end
                    else
                    begin
                        Result := -0.009794409448591208;
                    end;
                end
                else
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        if features[108] <= -82.499999999999986 then
                        begin
                            Result := -0.0001067232358965931;
                        end
                        else
                        begin
                            Result := 0.010418619781099399;
                        end;
                    end
                    else
                    begin
                        if features[175] <= -733.49999999999989 then
                        begin
                            Result := -0.021017083706012074;
                        end
                        else
                        begin
                            Result := 0.0028920966408608815;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[178] <= -1.0000000180025095E-35 then
                begin
                    if features[201] <= -5161.4999999999991 then
                    begin
                        Result := 0.00052859376867227497;
                    end
                    else
                    begin
                        Result := 0.012779056182010551;
                    end;
                end
                else
                begin
                    Result := 0.0013834879881459404;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_111(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.021296198423034922;
    end
    else
    begin
        if features[164] <= -297087183.99999994 then
        begin
            if features[199] <= -524.49999999999989 then
            begin
                Result := -0.016646500725285788;
            end
            else
            begin
                if features[201] <= -4499.4999999999991 then
                begin
                    Result := -0.010018269325238019;
                end
                else
                begin
                    Result := 0.0051040049946200362;
                end;
            end;
        end
        else
        begin
            if features[166] <= 72871844.000000015 then
            begin
                if features[184] <= -2330.4999999999995 then
                begin
                    Result := 0.047908476384371457;
                end
                else
                begin
                    if features[143] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.011798403075988541;
                    end
                    else
                    begin
                        if features[147] <= 1164.5000000000002 then
                        begin
                            if features[90] <= 3.5000000000000004 then
                            begin
                                if features[178] <= -128.49999999999997 then
                                begin
                                    Result := 0.0022365846980648561;
                                end
                                else
                                begin
                                    Result := -0.0019065096577442131;
                                end;
                            end
                            else
                            begin
                                if features[109] <= 53.500000000000007 then
                                begin
                                    Result := 0.0027313620132419845;
                                end
                                else
                                begin
                                    if features[179] <= -6881.4999999999991 then
                                    begin
                                        if features[194] <= -5644.4999999999991 then
                                        begin
                                            Result := 0.017051403836588493;
                                        end
                                        else
                                        begin
                                            Result := -0.0052506311352941669;
                                        end;
                                    end
                                    else
                                    begin
                                        if features[70] <= 733.50000000000011 then
                                        begin
                                            Result := -0.0052033598789521041;
                                        end
                                        else
                                        begin
                                            Result := 0.039313572547969078;
                                        end;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.01665796183105751;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0046133687372420405;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_112(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -116754263.99999999 then
    begin
        if features[199] <= -422.49999999999994 then
        begin
            Result := -0.0094829075357079889;
        end
        else
        begin
            if features[195] <= -5359.4999999999991 then
            begin
                Result := -0.0037368778476951159;
            end
            else
            begin
                if features[177] <= -6855.4999999999991 then
                begin
                    if features[191] <= -4633.4999999999991 then
                    begin
                        if features[105] <= -1.0000000180025095E-35 then
                        begin
                            if features[173] <= -6206.4999999999991 then
                            begin
                                Result := 0.025253637940158193;
                            end
                            else
                            begin
                                Result := 0.0030890241181067272;
                            end;
                        end
                        else
                        begin
                            if features[189] <= -3924.4999999999995 then
                            begin
                                Result := -0.00015448785612260694;
                            end
                            else
                            begin
                                Result := 0.022870173848244156;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.02986998467008686;
                    end;
                end
                else
                begin
                    Result := -0.0032332864030872547;
                end;
            end;
        end;
    end
    else
    begin
        if features[90] <= -1.4999999999999998 then
        begin
            if features[147] <= -199.49999999999997 then
            begin
                if features[195] <= -5591.4999999999991 then
                begin
                    Result := -0.0060730320848569235;
                end
                else
                begin
                    Result := 0.032866065594626286;
                end;
            end
            else
            begin
                Result := -0.0062489132117588215;
            end;
        end
        else
        begin
            if features[199] <= 277.50000000000006 then
            begin
                if features[189] <= -6646.4999999999991 then
                begin
                    Result := 0.01901929624937802;
                end
                else
                begin
                    Result := 0.0020281149506458525;
                end;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    Result := 0.00020083434306157537;
                end
                else
                begin
                    Result := 0.015316515321975758;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_113(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1043.4999999999998 then
    begin
        Result := -0.019241537655602069;
    end
    else
    begin
        if features[124] <= -1.0000000180025095E-35 then
        begin
            if features[202] <= -438.49999999999994 then
            begin
                Result := -0.012144971454204033;
            end
            else
            begin
                if features[188] <= -5392.4999999999991 then
                begin
                    Result := -0.0073360004421372058;
                end
                else
                begin
                    if features[0] <= 116768.00000000001 then
                    begin
                        Result := -0.0023342044281108097;
                    end
                    else
                    begin
                        if features[124] <= -333.49999999999994 then
                        begin
                            Result := -0.0079864464333355267;
                        end
                        else
                        begin
                            Result := 0.010884513976394061;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[179] <= -5129.4999999999991 then
            begin
                if features[90] <= 10.500000000000002 then
                begin
                    if features[173] <= -6091.4999999999991 then
                    begin
                        if features[147] <= -92.499999999999986 then
                        begin
                            Result := 0.017136963947558294;
                        end
                        else
                        begin
                            if features[195] <= -4261.4999999999991 then
                            begin
                                if features[150] <= -14.499999999999998 then
                                begin
                                    Result := 0.0093702839861806771;
                                end
                                else
                                begin
                                    Result := 0.0013074785848565269;
                                end;
                            end
                            else
                            begin
                                Result := 0.015906755819637734;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[175] <= -733.49999999999989 then
                        begin
                            if features[148] <= 2713.5000000000005 then
                            begin
                                Result := -0.0047209161092440629;
                            end
                            else
                            begin
                                Result := 0.020145632671704328;
                            end;
                        end
                        else
                        begin
                            Result := 0.0039112682936297558;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.011928393058198282;
                end;
            end
            else
            begin
                Result := -0.0064526936146499002;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_114(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1043.4999999999998 then
    begin
        Result := -0.018661570027706808;
    end
    else
    begin
        if features[186] <= -329.83332824707026 then
        begin
            if features[174] <= -8119.4999999999991 then
            begin
                if features[195] <= -6128.4999999999991 then
                begin
                    Result := -0.0058545336812509969;
                end
                else
                begin
                    if features[173] <= -6206.4999999999991 then
                    begin
                        Result := 0.013628812768626692;
                    end
                    else
                    begin
                        Result := -0.005768973892143793;
                    end;
                end;
            end
            else
            begin
                if features[170] <= 4.5000000000000009 then
                begin
                    Result := -0.00083557624418581608;
                end
                else
                begin
                    Result := -0.013982523906758575;
                end;
            end;
        end
        else
        begin
            if features[184] <= -1244.4999999999998 then
            begin
                Result := 0.026352128255927712;
            end
            else
            begin
                if features[192] <= -5886.4999999999991 then
                begin
                    if features[157] <= -1.4999999999999998 then
                    begin
                        Result := -0.009856635707514572;
                    end
                    else
                    begin
                        if features[47] <= 9300.5000000000018 then
                        begin
                            Result := -0.0020936475890362899;
                        end
                        else
                        begin
                            if features[173] <= -3390.4999999999995 then
                            begin
                                Result := 0.0055873776987070108;
                            end
                            else
                            begin
                                if features[39] <= 1438.5000000000002 then
                                begin
                                    Result := 0.078215549125449632;
                                end
                                else
                                begin
                                    Result := -0.0026427489973574942;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[183] <= -8861.4999999999982 then
                    begin
                        Result := 0.01982476754715428;
                    end
                    else
                    begin
                        if features[15] <= -285012047.99999994 then
                        begin
                            Result := 0.052632773943856917;
                        end
                        else
                        begin
                            Result := 0.0028138940908580233;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_115(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -878.49999999999989 then
    begin
        Result := -0.014144562472012224;
    end
    else
    begin
        if features[186] <= -538.24999999999989 then
        begin
            if features[174] <= -8119.4999999999991 then
            begin
                Result := 0.0052190554505141228;
            end
            else
            begin
                Result := -0.011276456912657244;
            end;
        end
        else
        begin
            if features[66] <= 1165.0000000000002 then
            begin
                if features[202] <= 528.50000000000011 then
                begin
                    if features[184] <= -509.49999999999994 then
                    begin
                        if features[109] <= -182.49999999999997 then
                        begin
                            if features[195] <= -5993.4999999999991 then
                            begin
                                Result := -0.0049123510612795566;
                            end
                            else
                            begin
                                if features[202] <= -81.499999999999986 then
                                begin
                                    Result := 0.00068420786773288255;
                                end
                                else
                                begin
                                    Result := 0.011494001549387829;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.031657657263595242;
                        end;
                    end
                    else
                    begin
                        if features[108] <= -125.49999999999999 then
                        begin
                            Result := -0.0038582473636544971;
                        end
                        else
                        begin
                            if features[176] <= -7643.4999999999991 then
                            begin
                                Result := -0.0012344392466935611;
                            end
                            else
                            begin
                                if features[188] <= -3966.4999999999995 then
                                begin
                                    Result := 0.0072769749907929566;
                                end
                                else
                                begin
                                    if features[190] <= -143.49999999999997 then
                                    begin
                                        Result := 0.0091775090763836376;
                                    end
                                    else
                                    begin
                                        Result := -0.016553232463199081;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[188] <= -6199.9999999999991 then
                    begin
                        Result := 0.0020778566244526258;
                    end
                    else
                    begin
                        Result := 0.023384081622135691;
                    end;
                end;
            end
            else
            begin
                Result := -0.016097529057126039;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_116(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -384867039.99999994 then
    begin
        Result := -0.012410955587134389;
    end
    else
    begin
        if features[199] <= -1426.4999999999998 then
        begin
            Result := -0.019498226871131636;
        end
        else
        begin
            if features[90] <= 4.5000000000000009 then
            begin
                if features[164] <= -184720071.99999997 then
                begin
                    if features[47] <= 11613.500000000002 then
                    begin
                        Result := -0.0066074473607339052;
                    end
                    else
                    begin
                        if features[174] <= -8465.4999999999982 then
                        begin
                            if features[195] <= -6254.4999999999991 then
                            begin
                                Result := -0.010463724637578272;
                            end
                            else
                            begin
                                Result := 0.035783119749367751;
                            end;
                        end
                        else
                        begin
                            Result := -0.00070135249192644026;
                        end;
                    end;
                end
                else
                begin
                    if features[181] <= -591.49999999999989 then
                    begin
                        if features[109] <= -182.49999999999997 then
                        begin
                            if features[176] <= -5363.4999999999991 then
                            begin
                                if features[195] <= -5521.4999999999991 then
                                begin
                                    Result := -0.00064956712312340848;
                                end
                                else
                                begin
                                    Result := 0.010302086500452761;
                                end;
                            end
                            else
                            begin
                                Result := -0.0078376296167304692;
                            end;
                        end
                        else
                        begin
                            Result := 0.026675951224705164;
                        end;
                    end
                    else
                    begin
                        if features[109] <= -347.49999999999994 then
                        begin
                            Result := -0.016469557038861896;
                        end
                        else
                        begin
                            Result := 0.0001856546457620416;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[155] <= -2.4999999999999996 then
                begin
                    Result := 0.024264916180598714;
                end
                else
                begin
                    if features[13] <= 93438.000000000015 then
                    begin
                        Result := 0.0026770721770946306;
                    end
                    else
                    begin
                        Result := 0.01943264919437928;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_117(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.020126766736002735;
    end
    else
    begin
        if features[164] <= -256588463.99999997 then
        begin
            if features[199] <= -524.49999999999989 then
            begin
                Result := -0.014560455106708137;
            end
            else
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.0090860776676585757;
                end
                else
                begin
                    Result := 0.0031190874083768878;
                end;
            end;
        end
        else
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[191] <= -4235.4999999999991 then
                begin
                    if features[154] <= 40.500000000000007 then
                    begin
                        if features[164] <= -53279485.999999993 then
                        begin
                            if features[128] <= -30.499999999999996 then
                            begin
                                Result := -0.0012266985599186956;
                            end
                            else
                            begin
                                Result := 0.004300941348475841;
                            end;
                        end
                        else
                        begin
                            Result := 0.0069487232489309344;
                        end;
                    end
                    else
                    begin
                        Result := -0.0032685457870851409;
                    end;
                end
                else
                begin
                    if features[109] <= -216.49999999999997 then
                    begin
                        Result := -0.00095871799302438732;
                    end
                    else
                    begin
                        Result := 0.018290633732166189;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := -0.00051409745081182465;
                end
                else
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := 0.061564120146071301;
                        end
                        else
                        begin
                            Result := -0.0029990145955294859;
                        end;
                    end
                    else
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := -0.026300408190383637;
                        end
                        else
                        begin
                            Result := 0.0094879824080954106;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_118(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -352383311.99999994 then
    begin
        Result := -0.010010532289605986;
    end
    else
    begin
        if features[166] <= 118461356.00000001 then
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[189] <= -4389.4999999999991 then
                begin
                    if features[164] <= -71344279.999999985 then
                    begin
                        if features[128] <= -30.499999999999996 then
                        begin
                            Result := -0.0032300310971523135;
                        end
                        else
                        begin
                            Result := 0.0025836743890340044;
                        end;
                    end
                    else
                    begin
                        if features[91] <= -1.0000000180025095E-35 then
                        begin
                            if features[179] <= -5581.4999999999991 then
                            begin
                                Result := 0.0070979507261098446;
                            end
                            else
                            begin
                                Result := 0.031260780446475199;
                            end;
                        end
                        else
                        begin
                            Result := -0.00035937637490186249;
                        end;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.0072624149655553449;
                    end
                    else
                    begin
                        Result := 0.011299797755943013;
                    end;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    if features[202] <= -438.49999999999994 then
                    begin
                        Result := -0.010515702656796612;
                    end
                    else
                    begin
                        if features[25] <= 3.5000000000000004 then
                        begin
                            Result := 0.00033148262767680015;
                        end
                        else
                        begin
                            Result := 0.01736340057645373;
                        end;
                    end;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[90] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.057594927971793275;
                        end
                        else
                        begin
                            Result := -0.026312108587056283;
                        end;
                    end
                    else
                    begin
                        Result := 0.0047811418706063188;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.0077390533149254252;
        end;
    end;
end;

function settled_top2_residual_tree_119(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[185] <= -399.74999999999994 then
    begin
        if features[176] <= -5933.4999999999991 then
        begin
            if features[174] <= -8119.4999999999991 then
            begin
                if features[195] <= -5521.4999999999991 then
                begin
                    Result := -0.0018324469333391926;
                end
                else
                begin
                    if features[189] <= -4748.4999999999991 then
                    begin
                        if features[163] <= 136151328.00000003 then
                        begin
                            Result := 0.012652465180518963;
                        end
                        else
                        begin
                            if features[202] <= -378.49999999999994 then
                            begin
                                Result := 0.0060552873587052837;
                            end
                            else
                            begin
                                Result := 0.052675996884625945;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.012919560981279235;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -245435391.99999997 then
                begin
                    Result := -0.013402466087411783;
                end
                else
                begin
                    Result := -0.0006320336356159744;
                end;
            end;
        end
        else
        begin
            Result := -0.01147355481877004;
        end;
    end
    else
    begin
        if features[184] <= -1244.4999999999998 then
        begin
            if features[190] <= -1671.4999999999998 then
            begin
                Result := 0.0653218625251034;
            end
            else
            begin
                Result := 0.015349071503699475;
            end;
        end
        else
        begin
            if features[90] <= 10.500000000000002 then
            begin
                if features[176] <= -9156.4999999999982 then
                begin
                    if features[189] <= -4748.4999999999991 then
                    begin
                        Result := -0.0064061423899880593;
                    end
                    else
                    begin
                        Result := 0.0055155855838404698;
                    end;
                end
                else
                begin
                    Result := 0.0013301391896597984;
                end;
            end
            else
            begin
                if features[66] <= 1165.0000000000002 then
                begin
                    Result := 0.010416746209703799;
                end
                else
                begin
                    Result := -0.01805064403803602;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_120(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1043.4999999999998 then
    begin
        Result := -0.018116033370800557;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[172] <= 3.5000000000000004 then
            begin
                if features[189] <= -6241.4999999999991 then
                begin
                    Result := 0.0084444780590352507;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        if features[109] <= 22.500000000000004 then
                        begin
                            if features[190] <= -533.49999999999989 then
                            begin
                                Result := 0.005201689031822612;
                            end
                            else
                            begin
                                Result := -0.0089905498952825205;
                            end;
                        end
                        else
                        begin
                            Result := 0.01170985577996099;
                        end;
                    end
                    else
                    begin
                        if features[190] <= -676.49999999999989 then
                        begin
                            if features[171] <= 1.5000000000000002 then
                            begin
                                Result := 0.015987126973787829;
                            end
                            else
                            begin
                                Result := -0.0050543668844627212;
                            end;
                        end
                        else
                        begin
                            Result := 0.0032688980588407323;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.016193214259631349;
            end;
        end
        else
        begin
            if features[81] <= -233.49999999999997 then
            begin
                if features[192] <= -5469.4999999999991 then
                begin
                    Result := -0.012564767915735867;
                end
                else
                begin
                    if features[25] <= 3.5000000000000004 then
                    begin
                        Result := -0.0037275445150717992;
                    end
                    else
                    begin
                        Result := 0.018551315036723557;
                    end;
                end;
            end
            else
            begin
                if features[175] <= -890.49999999999989 then
                begin
                    Result := 0.0053169351600575619;
                end
                else
                begin
                    if features[175] <= -863.49999999999989 then
                    begin
                        Result := -0.024821923971740698;
                    end
                    else
                    begin
                        Result := -0.0013475322895568362;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_121(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -187.49999999999997 then
    begin
        if features[164] <= -264356407.99999997 then
        begin
            Result := -0.010630246816510437;
        end
        else
        begin
            if features[189] <= -7048.4999999999991 then
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.041116772617579664;
                end
                else
                begin
                    Result := 0.0048811784670555799;
                end;
            end
            else
            begin
                if features[176] <= -6822.4999999999991 then
                begin
                    if features[200] <= -4395.4999999999991 then
                    begin
                        Result := -0.0016670213280078642;
                    end
                    else
                    begin
                        Result := -0.01181851215172069;
                    end;
                end
                else
                begin
                    if features[185] <= 85.250000000000014 then
                    begin
                        if features[173] <= -5872.4999999999991 then
                        begin
                            if features[109] <= -242.49999999999997 then
                            begin
                                Result := -0.001154686499427126;
                            end
                            else
                            begin
                                Result := 0.012987192253807567;
                            end;
                        end
                        else
                        begin
                            Result := -0.0051702065514663007;
                        end;
                    end
                    else
                    begin
                        Result := 0.022877086468765115;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[27] <= -5908.4999999999991 then
        begin
            if features[188] <= -5611.4999999999991 then
            begin
                Result := 0.0003717655098497035;
            end
            else
            begin
                Result := 0.012304043789967099;
            end;
        end
        else
        begin
            if features[201] <= -4618.4999999999991 then
            begin
                Result := -0.0017720489196560011;
            end
            else
            begin
                if features[196] <= -307.49999999999994 then
                begin
                    Result := 0.024574052674745602;
                end
                else
                begin
                    if features[163] <= 290405984.00000006 then
                    begin
                        Result := 0.0063563537993823879;
                    end
                    else
                    begin
                        Result := -0.0020068928837109886;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_122(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -401039455.99999994 then
    begin
        Result := -0.012537853923601362;
    end
    else
    begin
        if features[166] <= 121207976.00000001 then
        begin
            if features[199] <= -1426.4999999999998 then
            begin
                Result := -0.016777759448944281;
            end
            else
            begin
                if features[66] <= 1218.0000000000002 then
                begin
                    if features[9] <= 11.500000000000002 then
                    begin
                        if features[176] <= -9628.4999999999982 then
                        begin
                            if features[189] <= -4859.4999999999991 then
                            begin
                                Result := -0.0076299646211056534;
                            end
                            else
                            begin
                                if features[188] <= -7079.4999999999991 then
                                begin
                                    Result := -0.010636386658604946;
                                end
                                else
                                begin
                                    Result := 0.013622347511315672;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[189] <= -6241.4999999999991 then
                            begin
                                if features[150] <= -14.499999999999998 then
                                begin
                                    Result := 0.027388983816242725;
                                end
                                else
                                begin
                                    if features[182] <= -6206.4999999999991 then
                                    begin
                                        Result := 0.0015427312158179957;
                                    end
                                    else
                                    begin
                                        if features[196] <= -1142.4999999999998 then
                                        begin
                                            if features[200] <= -4099.4999999999991 then
                                            begin
                                                Result := 0.021474869841390645;
                                            end
                                            else
                                            begin
                                                Result := 0.13389842955198836;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := 0.014107935817961612;
                                        end;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.00083644953316020475;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[199] <= -289.49999999999994 then
                        begin
                            Result := -0.0043510088486784183;
                        end
                        else
                        begin
                            Result := 0.011439278932268737;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.01631547650659157;
                end;
            end;
        end
        else
        begin
            Result := -0.0078045151918822459;
        end;
    end;
end;

function settled_top2_residual_tree_123(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1012.4999999999999 then
    begin
        Result := -0.017542668354366225;
    end
    else
    begin
        if features[92] <= 1.5000000000000002 then
        begin
            if features[202] <= 794.50000000000011 then
            begin
                if features[164] <= -315822463.99999994 then
                begin
                    Result := -0.0083833972080113225;
                end
                else
                begin
                    if features[166] <= 109196768.00000001 then
                    begin
                        if features[147] <= -1717.4999999999998 then
                        begin
                            Result := 0.047345443403750201;
                        end
                        else
                        begin
                            if features[184] <= -2330.4999999999995 then
                            begin
                                if features[36] <= 282.50000000000006 then
                                begin
                                    Result := 0.096580124057505989;
                                end
                                else
                                begin
                                    Result := 0.010034185986958089;
                                end;
                            end
                            else
                            begin
                                if features[188] <= -3966.4999999999995 then
                                begin
                                    Result := 0.0012931976200581934;
                                end
                                else
                                begin
                                    if features[174] <= -6674.4999999999991 then
                                    begin
                                        Result := 0.0034034730857949317;
                                    end
                                    else
                                    begin
                                        if features[167] <= 1.5000000000000002 then
                                        begin
                                            if features[90] <= 1.0000000180025095E-35 then
                                            begin
                                                if features[189] <= -4016.4999999999995 then
                                                begin
                                                    Result := -0.016796854909586028;
                                                end
                                                else
                                                begin
                                                    Result := 0.059926154317213244;
                                                end;
                                            end
                                            else
                                            begin
                                                Result := -0.025088394425918877;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := -0.00046641081130804245;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0074748542810000977;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -5195.4999999999991 then
                begin
                    Result := 0.034440878282046498;
                end
                else
                begin
                    Result := 0.0037730814062366703;
                end;
            end;
        end
        else
        begin
            Result := 0.0082862579717937635;
        end;
    end;
end;

function settled_top2_residual_tree_124(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -352383311.99999994 then
    begin
        if features[199] <= -524.49999999999989 then
        begin
            Result := -0.019500510544918664;
        end
        else
        begin
            Result := -0.0047630535009812206;
        end;
    end
    else
    begin
        if features[199] <= -1426.4999999999998 then
        begin
            Result := -0.017684647901987666;
        end
        else
        begin
            if features[66] <= 1218.0000000000002 then
            begin
                if features[90] <= 10.500000000000002 then
                begin
                    if features[173] <= -6126.4999999999991 then
                    begin
                        if features[175] <= -423.49999999999994 then
                        begin
                            Result := 0.0053507618432762751;
                        end
                        else
                        begin
                            if features[191] <= -4433.4999999999991 then
                            begin
                                if features[167] <= 1.5000000000000002 then
                                begin
                                    Result := -0.003044475763344478;
                                end
                                else
                                begin
                                    if features[118] <= 1.0000000180025095E-35 then
                                    begin
                                        if features[184] <= -378.49999999999994 then
                                        begin
                                            if features[192] <= -5555.4999999999991 then
                                            begin
                                                Result := 0.029947806058657184;
                                            end
                                            else
                                            begin
                                                Result := 0.0031145250638981523;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := 0.0056330872120687854;
                                        end;
                                    end
                                    else
                                    begin
                                        if features[189] <= -4940.4999999999991 then
                                        begin
                                            Result := -0.01335686598561308;
                                        end
                                        else
                                        begin
                                            Result := 0.0079941048157885202;
                                        end;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.0099530346950516581;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[92] <= 2.5000000000000004 then
                        begin
                            Result := -0.0023104330510205712;
                        end
                        else
                        begin
                            Result := 0.018414861412429904;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0086680896857021777;
                end;
            end
            else
            begin
                Result := -0.01579119043172298;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_125(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1043.4999999999998 then
    begin
        Result := -0.017560310387254453;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[173] <= -6126.4999999999991 then
            begin
                if features[147] <= -34.499999999999993 then
                begin
                    Result := 0.015922183703439459;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[175] <= -190.49999999999997 then
                        begin
                            Result := 0.0052683654170714222;
                        end
                        else
                        begin
                            if features[171] <= 1.5000000000000002 then
                            begin
                                if features[193] <= -1150.4999999999998 then
                                begin
                                    Result := 0.02297367800548842;
                                end
                                else
                                begin
                                    Result := -0.0097253127802874196;
                                end;
                            end
                            else
                            begin
                                if features[202] <= 181.50000000000003 then
                                begin
                                    Result := -0.001394854269982892;
                                end
                                else
                                begin
                                    Result := 0.010705424603295618;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0077214811009399965;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 22.500000000000004 then
                begin
                    Result := -0.0028783873011777885;
                end
                else
                begin
                    Result := 0.012109035754087782;
                end;
            end;
        end
        else
        begin
            if features[81] <= -209.49999999999997 then
            begin
                if features[177] <= -5301.4999999999991 then
                begin
                    if features[202] <= 353.50000000000006 then
                    begin
                        Result := -0.011755805254100533;
                    end
                    else
                    begin
                        Result := 0.0044295617853817191;
                    end;
                end
                else
                begin
                    Result := 0.015190328550657309;
                end;
            end
            else
            begin
                if features[148] <= -1156.4999999999998 then
                begin
                    Result := -0.0036842036800757011;
                end
                else
                begin
                    Result := 0.0047219659410715608;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_126(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -903.49999999999989 then
    begin
        Result := -0.0136937791494364;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6126.4999999999991 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[175] <= -190.49999999999997 then
                        begin
                            if features[189] <= -4220.4999999999991 then
                            begin
                                Result := 0.0053059437621639722;
                            end
                            else
                            begin
                                Result := 0.035953987816020785;
                            end;
                        end
                        else
                        begin
                            if features[191] <= -4697.4999999999991 then
                            begin
                                Result := -0.0031827917888905578;
                            end
                            else
                            begin
                                Result := 0.0089806057944353812;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[150] <= -13.499999999999998 then
                        begin
                            Result := 0.01975471582092472;
                        end
                        else
                        begin
                            Result := 0.0058333912728470959;
                        end;
                    end;
                end
                else
                begin
                    if features[69] <= 22.500000000000004 then
                    begin
                        Result := -0.0025567563643192496;
                    end
                    else
                    begin
                        Result := 0.011230032483078623;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -233.49999999999997 then
                begin
                    if features[177] <= -5062.4999999999991 then
                    begin
                        Result := -0.0094322155301291514;
                    end
                    else
                    begin
                        Result := 0.017143143012671256;
                    end;
                end
                else
                begin
                    if features[175] <= -890.49999999999989 then
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := 0.0082169143390152851;
                        end
                        else
                        begin
                            Result := -0.0097596967352195398;
                        end;
                    end
                    else
                    begin
                        Result := -0.0034774206232937978;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.017109757005825673;
        end;
    end;
end;

function settled_top2_residual_tree_127(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1043.4999999999998 then
    begin
        Result := -0.017334633726584569;
    end
    else
    begin
        if features[164] <= -53279485.999999993 then
        begin
            if features[195] <= -4695.4999999999991 then
            begin
                if features[164] <= -325222047.99999994 then
                begin
                    Result := -0.010528606486582964;
                end
                else
                begin
                    if features[154] <= 40.500000000000007 then
                    begin
                        if features[128] <= -46.499999999999993 then
                        begin
                            if features[105] <= 1.0000000180025095E-35 then
                            begin
                                if features[109] <= 13.500000000000002 then
                                begin
                                    Result := -0.0025871072496592763;
                                end
                                else
                                begin
                                    Result := 0.0069701652899173102;
                                end;
                            end
                            else
                            begin
                                Result := -0.0076546086534206087;
                            end;
                        end
                        else
                        begin
                            if features[188] <= -4049.4999999999995 then
                            begin
                                Result := 0.003724909562732102;
                            end
                            else
                            begin
                                Result := -0.0077104505098219206;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0087286727037756626;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -7012.4999999999991 then
                begin
                    if features[190] <= 2732.0000000000005 then
                    begin
                        if features[27] <= -5147.4999999999991 then
                        begin
                            Result := 0.02474293123484651;
                        end
                        else
                        begin
                            Result := 0.0068552615632781061;
                        end;
                    end
                    else
                    begin
                        Result := -0.02542174928009824;
                    end;
                end
                else
                begin
                    Result := 0.00076269869010975203;
                end;
            end;
        end
        else
        begin
            if features[136] <= -1.0000000180025095E-35 then
            begin
                Result := -0.0018080499518858862;
            end
            else
            begin
                if features[178] <= -1695.4999999999998 then
                begin
                    Result := 0.022059041050901933;
                end
                else
                begin
                    Result := 0.0048672960248032039;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_128(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[186] <= -319.74999999999994 then
    begin
        if features[176] <= -5712.4999999999991 then
        begin
            if features[148] <= -1156.4999999999998 then
            begin
                Result := -0.011362366360403317;
            end
            else
            begin
                if features[198] <= -4826.4999999999991 then
                begin
                    Result := -0.0015456609478946602;
                end
                else
                begin
                    if features[82] <= -20975.999999999996 then
                    begin
                        Result := -0.0015122091485894387;
                    end
                    else
                    begin
                        Result := 0.017347441502434769;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.011895048572126206;
        end;
    end
    else
    begin
        if features[202] <= 353.50000000000006 then
        begin
            if features[176] <= -8879.4999999999982 then
            begin
                if features[189] <= -4859.4999999999991 then
                begin
                    Result := -0.0069496615172867596;
                end
                else
                begin
                    Result := 0.0036222373453700728;
                end;
            end
            else
            begin
                if features[190] <= -143.49999999999997 then
                begin
                    Result := 0.0036209290173281738;
                end
                else
                begin
                    Result := -0.00070462934645952385;
                end;
            end;
        end
        else
        begin
            if features[191] <= -6583.4999999999991 then
            begin
                if features[177] <= -8921.4999999999982 then
                begin
                    if features[188] <= -7501.4999999999991 then
                    begin
                        Result := -0.0074814514922737808;
                    end
                    else
                    begin
                        if features[77] <= 2535.5000000000005 then
                        begin
                            Result := -0.0091002039810461847;
                        end
                        else
                        begin
                            Result := 0.036315776812625121;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0087505268310429426;
                end;
            end
            else
            begin
                if features[177] <= -6319.4999999999991 then
                begin
                    Result := 0.018375050851794663;
                end
                else
                begin
                    Result := 0.0012090102795167667;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_129(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1043.4999999999998 then
    begin
        Result := -0.017099512270458903;
    end
    else
    begin
        if features[186] <= -538.24999999999989 then
        begin
            if features[189] <= -5180.4999999999991 then
            begin
                if features[53] <= 5.0000000000000009 then
                begin
                    Result := 0.010305398763119901;
                end
                else
                begin
                    if features[198] <= -4295.4999999999991 then
                    begin
                        Result := -0.006650269936704623;
                    end
                    else
                    begin
                        Result := 0.027621571395877509;
                    end;
                end;
            end
            else
            begin
                Result := -0.010888593257066547;
            end;
        end
        else
        begin
            if features[149] <= -819.99999999999989 then
            begin
                Result := -0.02743420537283018;
            end
            else
            begin
                if features[202] <= 528.50000000000011 then
                begin
                    if features[176] <= -9527.4999999999982 then
                    begin
                        if features[189] <= -4770.4999999999991 then
                        begin
                            Result := -0.0077823553381312959;
                        end
                        else
                        begin
                            Result := 0.0044024914520777751;
                        end;
                    end
                    else
                    begin
                        if features[183] <= -8861.4999999999982 then
                        begin
                            if features[128] <= -9557.4999999999982 then
                            begin
                                Result := 0.0292280500638472;
                            end
                            else
                            begin
                                Result := 0.0067226531604234231;
                            end;
                        end
                        else
                        begin
                            Result := 0.0011556283725806847;
                        end;
                    end;
                end
                else
                begin
                    if features[191] <= -6583.4999999999991 then
                    begin
                        if features[177] <= -8921.4999999999982 then
                        begin
                            Result := 0.023381802039915023;
                        end
                        else
                        begin
                            Result := -0.0083464145244454575;
                        end;
                    end
                    else
                    begin
                        if features[180] <= -5516.4999999999991 then
                        begin
                            Result := 0.025255191916167642;
                        end
                        else
                        begin
                            Result := -0.013187323477863331;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_130(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.019113223649804733;
    end
    else
    begin
        if features[117] <= -15.499999999999998 then
        begin
            if features[164] <= -224280343.99999997 then
            begin
                if features[198] <= -5160.4999999999991 then
                begin
                    Result := -0.015166666188359247;
                end
                else
                begin
                    Result := -0.003106434089014037;
                end;
            end
            else
            begin
                if features[176] <= -7371.4999999999991 then
                begin
                    if features[150] <= -9.4999999999999982 then
                    begin
                        Result := 0.0051113062008676467;
                    end
                    else
                    begin
                        if features[118] <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.0063626892034943025;
                        end
                        else
                        begin
                            Result := -0.010326212673142583;
                        end;
                    end;
                end
                else
                begin
                    if features[110] <= 13.500000000000002 then
                    begin
                        Result := -0.00081070691875328191;
                    end
                    else
                    begin
                        Result := 0.012098843852713282;
                    end;
                end;
            end;
        end
        else
        begin
            if features[173] <= -6126.4999999999991 then
            begin
                if features[147] <= -9.4999999999999982 then
                begin
                    Result := 0.013744375155816283;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[175] <= -423.49999999999994 then
                        begin
                            if features[107] <= -2.4999999999999996 then
                            begin
                                Result := 0.031613621918003029;
                            end
                            else
                            begin
                                Result := 0.0040782959256666146;
                            end;
                        end
                        else
                        begin
                            Result := -0.0017052137879602824;
                        end;
                    end
                    else
                    begin
                        if features[150] <= -15.499999999999998 then
                        begin
                            Result := 0.024175360214869882;
                        end
                        else
                        begin
                            Result := 0.0037973160132751867;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0015009192403721823;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_131(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.019782652612808566;
    end
    else
    begin
        if features[164] <= -53279485.999999993 then
        begin
            if features[195] <= -4648.4999999999991 then
            begin
                if features[164] <= -325222047.99999994 then
                begin
                    Result := -0.010398371011543995;
                end
                else
                begin
                    if features[11] <= 2.5000000000000004 then
                    begin
                        if features[154] <= 40.500000000000007 then
                        begin
                            if features[81] <= -233.49999999999997 then
                            begin
                                Result := -0.0035492533324466996;
                            end
                            else
                            begin
                                if features[189] <= -4016.4999999999995 then
                                begin
                                    Result := 0.0030518185732099062;
                                end
                                else
                                begin
                                    if features[177] <= -9379.4999999999982 then
                                    begin
                                        Result := 0.031914736467022399;
                                    end
                                    else
                                    begin
                                        Result := -0.015755220762897135;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.009018636558110079;
                        end;
                    end
                    else
                    begin
                        Result := 0.0080608895474847796;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -4870.4999999999991 then
                begin
                    if features[178] <= 705.50000000000011 then
                    begin
                        if features[90] <= 3.5000000000000004 then
                        begin
                            Result := 0.0096334119937567277;
                        end
                        else
                        begin
                            Result := 0.026522192417482538;
                        end;
                    end
                    else
                    begin
                        Result := -0.0089718560530237402;
                    end;
                end
                else
                begin
                    Result := 0.00041922926925019687;
                end;
            end;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[178] <= -1266.4999999999998 then
                begin
                    Result := 0.023831383467430127;
                end
                else
                begin
                    Result := 0.0055679073634201928;
                end;
            end
            else
            begin
                Result := 0.0005272666966775933;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_132(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[185] <= -399.74999999999994 then
    begin
        if features[179] <= -5129.4999999999991 then
        begin
            if features[195] <= -5521.4999999999991 then
            begin
                Result := -0.0073924976569533299;
            end
            else
            begin
                if features[184] <= -2108.4999999999995 then
                begin
                    Result := 0.037524304365405353;
                end
                else
                begin
                    if features[195] <= -4216.4999999999991 then
                    begin
                        if features[164] <= -211178855.99999997 then
                        begin
                            Result := -0.0060828621296953886;
                        end
                        else
                        begin
                            Result := 0.0073493231161984411;
                        end;
                    end
                    else
                    begin
                        Result := 0.025103961878592724;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.013202833590798943;
        end;
    end
    else
    begin
        if features[184] <= -1244.4999999999998 then
        begin
            if features[190] <= -1186.4999999999998 then
            begin
                Result := 0.05302742208333594;
            end
            else
            begin
                Result := 0.012862995986193365;
            end;
        end
        else
        begin
            if features[202] <= -104.49999999999999 then
            begin
                if features[176] <= -6822.4999999999991 then
                begin
                    if features[201] <= -6648.4999999999991 then
                    begin
                        Result := 0.01655419711339317;
                    end
                    else
                    begin
                        Result := -0.0057725753350366194;
                    end;
                end
                else
                begin
                    if features[173] <= -7052.4999999999991 then
                    begin
                        Result := 0.014299258379788288;
                    end
                    else
                    begin
                        if features[185] <= 108.25000000000001 then
                        begin
                            Result := -0.0018333778615622941;
                        end
                        else
                        begin
                            if features[177] <= -6165.4999999999991 then
                            begin
                                Result := 0.00090299762805193013;
                            end
                            else
                            begin
                                Result := 0.044842269938504174;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.0022544045043414013;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_133(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.019258636777107235;
    end
    else
    begin
        if features[166] <= -16113090.499999998 then
        begin
            if features[184] <= -459.49999999999994 then
            begin
                Result := 0.034696571915283206;
            end
            else
            begin
                Result := 0.0066226241577689209;
            end;
        end
        else
        begin
            if features[202] <= -118.49999999999999 then
            begin
                if features[189] <= -6571.4999999999991 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        if features[179] <= -6481.4999999999991 then
                        begin
                            Result := 0.014312646148468451;
                        end
                        else
                        begin
                            if features[175] <= -3013.9999999999995 then
                            begin
                                Result := 0.0087279795140066639;
                            end
                            else
                            begin
                                Result := 0.10791776647874807;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.001121037684348502;
                    end;
                end
                else
                begin
                    if features[170] <= 1.5000000000000002 then
                    begin
                        Result := 0.0025002317220711705;
                    end
                    else
                    begin
                        Result := -0.004964746345233674;
                    end;
                end;
            end
            else
            begin
                if features[195] <= -5907.4999999999991 then
                begin
                    if features[109] <= -109.49999999999999 then
                    begin
                        Result := -0.011325750634240817;
                    end
                    else
                    begin
                        Result := 0.0021816580494776984;
                    end;
                end
                else
                begin
                    if features[180] <= -7558.4999999999991 then
                    begin
                        if features[192] <= -6085.4999999999991 then
                        begin
                            if features[181] <= -651.49999999999989 then
                            begin
                                Result := 0.013492232943360639;
                            end
                            else
                            begin
                                Result := -0.0044844418776086364;
                            end;
                        end
                        else
                        begin
                            Result := 0.011841974240125088;
                        end;
                    end
                    else
                    begin
                        Result := 0.00063447582556570815;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_134(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1174.4999999999998 then
    begin
        Result := -0.013509044514473968;
    end
    else
    begin
        if features[182] <= -3905.4999999999995 then
        begin
            if features[198] <= -3884.4999999999995 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    if features[174] <= -8622.4999999999982 then
                    begin
                        Result := 0.012736451064662042;
                    end
                    else
                    begin
                        if features[96] <= -64392531.999999993 then
                        begin
                            Result := 0.024005991098207623;
                        end
                        else
                        begin
                            Result := 0.00052258986568035233;
                        end;
                    end;
                end
                else
                begin
                    if features[186] <= -302.83332824707026 then
                    begin
                        if features[174] <= -8119.4999999999991 then
                        begin
                            if features[195] <= -4903.4999999999991 then
                            begin
                                Result := -0.0024155543044215265;
                            end
                            else
                            begin
                                Result := 0.021390216952719643;
                            end;
                        end
                        else
                        begin
                            if features[170] <= 4.5000000000000009 then
                            begin
                                Result := -0.0025247932908733276;
                            end
                            else
                            begin
                                Result := -0.014863188809867912;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[184] <= -509.49999999999994 then
                        begin
                            if features[108] <= -186.49999999999997 then
                            begin
                                Result := 0.0038595157657199523;
                            end
                            else
                            begin
                                if features[177] <= -6936.4999999999991 then
                                begin
                                    Result := 0.012608685257811284;
                                end
                                else
                                begin
                                    Result := 0.056962419519549258;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.00092181727852859181;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[163] <= 303080096.00000006 then
                begin
                    Result := 0.018671568626555748;
                end
                else
                begin
                    Result := 0.00049953994244645607;
                end;
            end;
        end
        else
        begin
            Result := -0.013529525191857914;
        end;
    end;
end;

function settled_top2_residual_tree_135(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -91709047.999999985 then
    begin
        if features[199] <= -399.49999999999994 then
        begin
            if features[189] <= -6025.4999999999991 then
            begin
                if features[190] <= -585.49999999999989 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        if features[37] <= 2.5000000000000004 then
                        begin
                            if features[178] <= -975.49999999999989 then
                            begin
                                Result := 0.11154039356269092;
                            end
                            else
                            begin
                                Result := -0.017684180252037253;
                            end;
                        end
                        else
                        begin
                            if features[164] <= -141296575.99999997 then
                            begin
                                Result := -0.010402860721393939;
                            end
                            else
                            begin
                                Result := 0.039703073645798975;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.010606000464564058;
                    end;
                end
                else
                begin
                    if features[185] <= -48.249999999999993 then
                    begin
                        if features[71] <= 2.5000000000000004 then
                        begin
                            Result := 0.053491575772987458;
                        end
                        else
                        begin
                            Result := -0.015150628748950297;
                        end;
                    end
                    else
                    begin
                        Result := 0.14795925195783297;
                    end;
                end;
            end
            else
            begin
                Result := -0.0092163027292235331;
            end;
        end
        else
        begin
            if features[201] <= -4652.4999999999991 then
            begin
                if features[179] <= -5129.4999999999991 then
                begin
                    if features[151] <= 75.500000000000014 then
                    begin
                        Result := -0.0012810185096057841;
                    end
                    else
                    begin
                        Result := -0.018386950707604294;
                    end;
                end
                else
                begin
                    Result := -0.016190593674336097;
                end;
            end
            else
            begin
                if features[27] <= -5505.4999999999991 then
                begin
                    Result := 0.01475757190306424;
                end
                else
                begin
                    Result := 0.0013113120241777995;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.0023461424285978662;
    end;
end;

function settled_top2_residual_tree_136(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -401039455.99999994 then
    begin
        Result := -0.011424455647786685;
    end
    else
    begin
        if features[92] <= 1.5000000000000002 then
        begin
            if features[147] <= -1717.4999999999998 then
            begin
                Result := 0.0463920983255946;
            end
            else
            begin
                if features[164] <= -110756839.99999999 then
                begin
                    if features[198] <= -4585.4999999999991 then
                    begin
                        if features[105] <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.0020447982940302355;
                        end
                        else
                        begin
                            if features[85] <= -1.0000000180025095E-35 then
                            begin
                                Result := 0.0022842344635570912;
                            end
                            else
                            begin
                                Result := -0.010174403153710208;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[183] <= -6362.4999999999991 then
                        begin
                            Result := 0.012540737908598016;
                        end
                        else
                        begin
                            Result := -0.00026845003528790421;
                        end;
                    end;
                end
                else
                begin
                    if features[158] <= -2464.4999999999995 then
                    begin
                        if features[140] <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.0053674352605948801;
                        end
                        else
                        begin
                            Result := -0.0078618165661112505;
                        end;
                    end
                    else
                    begin
                        if features[189] <= -4016.4999999999995 then
                        begin
                            Result := 0.003694970801675078;
                        end
                        else
                        begin
                            if features[175] <= -706.49999999999989 then
                            begin
                                Result := -0.018128515219173358;
                            end
                            else
                            begin
                                if features[175] <= -290.49999999999994 then
                                begin
                                    Result := 0.029390827944641797;
                                end
                                else
                                begin
                                    Result := -0.0022351940457880832;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[201] <= -4056.4999999999995 then
            begin
                Result := 0.0042960556311774575;
            end
            else
            begin
                Result := 0.024343020915984469;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_137(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -352383311.99999994 then
    begin
        if features[202] <= 200.50000000000003 then
        begin
            Result := -0.012192310047896809;
        end
        else
        begin
            Result := 0.0057289278570835335;
        end;
    end
    else
    begin
        if features[166] <= 121207976.00000001 then
        begin
            if features[166] <= -16113090.499999998 then
            begin
                if features[183] <= -8298.4999999999982 then
                begin
                    if features[164] <= -64403287.999999993 then
                    begin
                        Result := -0.011199840537328446;
                    end
                    else
                    begin
                        Result := 0.035400237514383204;
                    end;
                end
                else
                begin
                    Result := 0.0049224638883878964;
                end;
            end
            else
            begin
                if features[202] <= 321.50000000000006 then
                begin
                    if features[176] <= -9527.4999999999982 then
                    begin
                        if features[189] <= -4970.4999999999991 then
                        begin
                            Result := -0.0094197038366037027;
                        end
                        else
                        begin
                            if features[41] <= 1330.5000000000002 then
                            begin
                                Result := 0.00069193008739479984;
                            end
                            else
                            begin
                                Result := 0.030427027010110509;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.00089227861580934279;
                    end;
                end
                else
                begin
                    if features[193] <= 584.50000000000011 then
                    begin
                        Result := 0.016090293616853032;
                    end
                    else
                    begin
                        if features[186] <= -38.833333969116204 then
                        begin
                            if features[200] <= -5556.4999999999991 then
                            begin
                                Result := -0.015339079971793818;
                            end
                            else
                            begin
                                Result := 0.0025897385031978864;
                            end;
                        end
                        else
                        begin
                            if features[107] <= -1.0000000180025095E-35 then
                            begin
                                Result := -0.0083919703143879795;
                            end
                            else
                            begin
                                Result := 0.013104795741775359;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.0079389805338612018;
        end;
    end;
end;

function settled_top2_residual_tree_138(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1080.4999999999998 then
    begin
        Result := -0.016741109851054876;
    end
    else
    begin
        if features[122] <= -1039.4999999999998 then
        begin
            if features[171] <= 2.5000000000000004 then
            begin
                Result := -0.014547527150482659;
            end
            else
            begin
                Result := 0.0032499792695545046;
            end;
        end
        else
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6126.4999999999991 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.0019073044825876229;
                    end
                    else
                    begin
                        if features[181] <= 281.50000000000006 then
                        begin
                            Result := 0.010518375738526858;
                        end
                        else
                        begin
                            Result := -0.0017684808294554785;
                        end;
                    end;
                end
                else
                begin
                    if features[96] <= -91281263.999999985 then
                    begin
                        Result := 0.0088375091316808523;
                    end
                    else
                    begin
                        if features[108] <= 98.500000000000014 then
                        begin
                            Result := -0.0033926453114308205;
                        end
                        else
                        begin
                            if features[176] <= -8251.4999999999982 then
                            begin
                                Result := -0.008498877894446269;
                            end
                            else
                            begin
                                Result := 0.017059290107772806;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -194546647.99999997 then
                begin
                    Result := -0.0096030762245062004;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[190] <= -631.49999999999989 then
                        begin
                            if features[200] <= -5556.4999999999991 then
                            begin
                                Result := 0.039766041271251121;
                            end
                            else
                            begin
                                Result := 0.0082345302622780139;
                            end;
                        end
                        else
                        begin
                            Result := 0.00056774182320468169;
                        end;
                    end
                    else
                    begin
                        Result := -0.0072241606117515282;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_139(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1043.4999999999998 then
    begin
        Result := -0.016225510255882244;
    end
    else
    begin
        if features[105] <= 1.0000000180025095E-35 then
        begin
            if features[124] <= -167.99999999999997 then
            begin
                Result := -0.0045634418095592067;
            end
            else
            begin
                if features[109] <= 129.50000000000003 then
                begin
                    if features[201] <= -4686.4999999999991 then
                    begin
                        if features[126] <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.0044340870352335754;
                        end
                        else
                        begin
                            Result := -0.0020935694499384016;
                        end;
                    end
                    else
                    begin
                        if features[177] <= -6729.4999999999991 then
                        begin
                            if features[181] <= -632.49999999999989 then
                            begin
                                Result := 0.01227286331102723;
                            end
                            else
                            begin
                                Result := 0.0027157226014088548;
                            end;
                        end
                        else
                        begin
                            Result := -0.0013952669437339899;
                        end;
                    end;
                end
                else
                begin
                    if features[181] <= 247.50000000000003 then
                    begin
                        Result := 0.039994549889201411;
                    end
                    else
                    begin
                        Result := 0.0060636687781305473;
                    end;
                end;
            end;
        end
        else
        begin
            if features[81] <= -198.49999999999997 then
            begin
                Result := -0.0053460616791123237;
            end
            else
            begin
                if features[128] <= 16.500000000000004 then
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        if features[28] <= -7204.4999999999991 then
                        begin
                            Result := 0.04541420210336173;
                        end
                        else
                        begin
                            if features[178] <= -249.49999999999997 then
                            begin
                                Result := 0.0165222221589565;
                            end
                            else
                            begin
                                Result := 0.0024138872424671345;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.016253449727524565;
                    end;
                end
                else
                begin
                    Result := -0.0063503774302721807;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_140(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -374.49999999999994 then
    begin
        if features[164] <= -129461379.99999999 then
        begin
            Result := -0.007511051415817295;
        end
        else
        begin
            if features[176] <= -6958.4999999999991 then
            begin
                if features[200] <= -4614.4999999999991 then
                begin
                    Result := 0.0028150317185011348;
                end
                else
                begin
                    Result := -0.012256674824900463;
                end;
            end
            else
            begin
                if features[109] <= -347.49999999999994 then
                begin
                    Result := -0.0040790313405785483;
                end
                else
                begin
                    Result := 0.012138672996790655;
                end;
            end;
        end;
    end
    else
    begin
        if features[171] <= 1.0000000180025095E-35 then
        begin
            if features[190] <= -533.49999999999989 then
            begin
                Result := 0.01027808780397132;
            end
            else
            begin
                if features[173] <= -4590.4999999999991 then
                begin
                    Result := -0.0035175369399709586;
                end
                else
                begin
                    Result := -0.022353993707396953;
                end;
            end;
        end
        else
        begin
            if features[190] <= 1264.5000000000002 then
            begin
                if features[173] <= -4956.9999999999991 then
                begin
                    if features[173] <= -5604.4999999999991 then
                    begin
                        Result := 0.0018896042995865264;
                    end
                    else
                    begin
                        Result := -0.007084414215099844;
                    end;
                end
                else
                begin
                    if features[190] <= -676.49999999999989 then
                    begin
                        Result := -0.0023374789006266566;
                    end
                    else
                    begin
                        if features[192] <= -5492.4999999999991 then
                        begin
                            Result := 0.02181365219720463;
                        end
                        else
                        begin
                            Result := 0.0043035339531692631;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -5376.4999999999991 then
                begin
                    Result := 0.006161289840623153;
                end
                else
                begin
                    Result := 0.029642210197089326;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_141(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1043.4999999999998 then
    begin
        Result := -0.015665912557320607;
    end
    else
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.028286583094279401;
        end
        else
        begin
            if features[202] <= 794.50000000000011 then
            begin
                if features[122] <= -1141.4999999999998 then
                begin
                    Result := -0.0062362557362212337;
                end
                else
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        if features[15] <= -63057549.999999993 then
                        begin
                            Result := 0.0068448442119166987;
                        end
                        else
                        begin
                            if features[173] <= -6126.4999999999991 then
                            begin
                                if features[74] <= 4.5000000000000009 then
                                begin
                                    Result := 0.013215337245160712;
                                end
                                else
                                begin
                                    if features[175] <= -190.49999999999997 then
                                    begin
                                        if features[28] <= -5588.4999999999991 then
                                        begin
                                            Result := 0.0025842833375457844;
                                        end
                                        else
                                        begin
                                            Result := 0.012335349341379828;
                                        end;
                                    end
                                    else
                                    begin
                                        if features[191] <= -4356.4999999999991 then
                                        begin
                                            if features[169] <= 1.5000000000000002 then
                                            begin
                                                Result := -0.0038509409419047592;
                                            end
                                            else
                                            begin
                                                Result := 0.0060528337067279623;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := 0.011639706923897564;
                                        end;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.0019854007713199311;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[173] <= -4869.4999999999991 then
                        begin
                            if features[108] <= -251.49999999999997 then
                            begin
                                Result := -0.01086832231859715;
                            end
                            else
                            begin
                                Result := -0.0018530370445010314;
                            end;
                        end
                        else
                        begin
                            Result := 0.01015140454957689;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.016313519082944067;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_142(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.018200010413027604;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[173] <= -6091.4999999999991 then
            begin
                if features[147] <= -34.499999999999993 then
                begin
                    Result := 0.013641821664510577;
                end
                else
                begin
                    Result := 0.0021459011555112028;
                end;
            end
            else
            begin
                if features[69] <= 20.500000000000004 then
                begin
                    Result := -0.0023324048496283622;
                end
                else
                begin
                    Result := 0.0094775176333616196;
                end;
            end;
        end
        else
        begin
            if features[177] <= -5665.4999999999991 then
            begin
                if features[148] <= 1252.5000000000002 then
                begin
                    if features[202] <= -637.49999999999989 then
                    begin
                        Result := -0.01855413406638334;
                    end
                    else
                    begin
                        if features[175] <= -890.49999999999989 then
                        begin
                            if features[167] <= 1.5000000000000002 then
                            begin
                                if features[164] <= -191515135.99999997 then
                                begin
                                    Result := -0.0037223123911578394;
                                end
                                else
                                begin
                                    Result := 0.01147187710157729;
                                end;
                            end
                            else
                            begin
                                Result := -0.011027729835518418;
                            end;
                        end
                        else
                        begin
                            Result := -0.0065375647241475545;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.018421437661165826;
                end;
            end
            else
            begin
                if features[173] <= -5406.4999999999991 then
                begin
                    if features[171] <= 3.5000000000000004 then
                    begin
                        if features[195] <= -5268.4999999999991 then
                        begin
                            Result := 0.022671053740740649;
                        end
                        else
                        begin
                            Result := -0.012190670950489318;
                        end;
                    end
                    else
                    begin
                        Result := 0.029316007941601243;
                    end;
                end
                else
                begin
                    Result := -0.0062649752913868902;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_143(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -401039455.99999994 then
    begin
        Result := -0.010720045768225408;
    end
    else
    begin
        if features[145] <= -734.49999999999989 then
        begin
            Result := 0.015778935769815938;
        end
        else
        begin
            if features[90] <= -1.4999999999999998 then
            begin
                Result := -0.0058593464834006091;
            end
            else
            begin
                if features[164] <= -57023309.999999993 then
                begin
                    if features[199] <= -176.49999999999997 then
                    begin
                        if features[47] <= 11281.500000000002 then
                        begin
                            Result := -0.0050709134360135064;
                        end
                        else
                        begin
                            Result := 0.0037988600905026503;
                        end;
                    end
                    else
                    begin
                        if features[171] <= 1.0000000180025095E-35 then
                        begin
                            if features[193] <= -339.49999999999994 then
                            begin
                                Result := 0.022630589920954691;
                            end
                            else
                            begin
                                Result := -0.0060962753852662199;
                            end;
                        end
                        else
                        begin
                            if features[190] <= 663.50000000000011 then
                            begin
                                if features[173] <= -4956.9999999999991 then
                                begin
                                    Result := -0.0013775103497161336;
                                end
                                else
                                begin
                                    Result := 0.011356206058398381;
                                end;
                            end
                            else
                            begin
                                if features[188] <= -5423.4999999999991 then
                                begin
                                    Result := 0.0047699683758835416;
                                end
                                else
                                begin
                                    if features[177] <= -8039.4999999999991 then
                                    begin
                                        Result := 0.035559311090160965;
                                    end
                                    else
                                    begin
                                        Result := 0.008769461316800788;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[183] <= -8861.4999999999982 then
                    begin
                        Result := 0.0185266740252602;
                    end
                    else
                    begin
                        if features[193] <= -1510.4999999999998 then
                        begin
                            Result := 0.031199382923793428;
                        end
                        else
                        begin
                            Result := 0.0025759163573378561;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_144(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -176.49999999999997 then
    begin
        if features[189] <= -6571.4999999999991 then
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[179] <= -6513.4999999999991 then
                begin
                    Result := 0.015398151577036079;
                end
                else
                begin
                    if features[175] <= -3013.9999999999995 then
                    begin
                        Result := 0.0071643980115481502;
                    end
                    else
                    begin
                        Result := 0.090118435828045934;
                    end;
                end;
            end
            else
            begin
                Result := -0.00090470333521973476;
            end;
        end
        else
        begin
            if features[47] <= 11613.500000000002 then
            begin
                Result := -0.0049047152231556394;
            end
            else
            begin
                Result := 0.0021466189353494874;
            end;
        end;
    end
    else
    begin
        if features[176] <= -6219.4999999999991 then
        begin
            if features[198] <= -4585.4999999999991 then
            begin
                if features[189] <= -4389.4999999999991 then
                begin
                    if features[187] <= -24.267857551574703 then
                    begin
                        Result := -0.0061494633414944664;
                    end
                    else
                    begin
                        Result := 0.0015438207483532591;
                    end;
                end
                else
                begin
                    if features[174] <= -6743.9999999999991 then
                    begin
                        Result := 0.017808024392607022;
                    end
                    else
                    begin
                        Result := 0.003709358621306206;
                    end;
                end;
            end
            else
            begin
                Result := 0.0094743179642125096;
            end;
        end
        else
        begin
            if features[193] <= -325.49999999999994 then
            begin
                Result := 0.010329021227521815;
            end
            else
            begin
                if features[185] <= -86.249999999999986 then
                begin
                    Result := -0.0099506234870048813;
                end
                else
                begin
                    if features[148] <= -1327.4999999999998 then
                    begin
                        Result := 0.015949568457903494;
                    end
                    else
                    begin
                        Result := -0.0027293570728536142;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_145(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.018446300266963991;
    end
    else
    begin
        if features[166] <= -16113090.499999998 then
        begin
            if features[183] <= -8298.4999999999982 then
            begin
                Result := 0.029400687789001546;
            end
            else
            begin
                Result := 0.0034077685327033452;
            end;
        end
        else
        begin
            if features[199] <= 223.50000000000003 then
            begin
                if features[164] <= -315822463.99999994 then
                begin
                    Result := -0.008149964877701121;
                end
                else
                begin
                    if features[176] <= -9527.4999999999982 then
                    begin
                        if features[189] <= -4883.4999999999991 then
                        begin
                            Result := -0.010177678884799864;
                        end
                        else
                        begin
                            Result := 0.0076667301059360664;
                        end;
                    end
                    else
                    begin
                        if features[189] <= -6646.4999999999991 then
                        begin
                            Result := 0.0097983749504957987;
                        end
                        else
                        begin
                            Result := -0.00043761999534790348;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[195] <= -5950.4999999999991 then
                begin
                    Result := -0.0070242084977915377;
                end
                else
                begin
                    if features[190] <= 2732.0000000000005 then
                    begin
                        if features[180] <= -6963.4999999999991 then
                        begin
                            if features[201] <= -4652.4999999999991 then
                            begin
                                if features[80] <= -4326.4999999999991 then
                                begin
                                    Result := 0.045927208400790634;
                                end
                                else
                                begin
                                    Result := 0.0048203978101174607;
                                end;
                            end
                            else
                            begin
                                Result := 0.020052932988310457;
                            end;
                        end
                        else
                        begin
                            if features[201] <= -3901.4999999999995 then
                            begin
                                Result := -0.0022895600118107012;
                            end
                            else
                            begin
                                Result := 0.011965148312734169;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.01040192326550571;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_146(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.019750908699749062;
    end
    else
    begin
        if features[117] <= -15.499999999999998 then
        begin
            if features[199] <= -411.49999999999994 then
            begin
                Result := -0.0090171243355715008;
            end
            else
            begin
                if features[188] <= -5392.4999999999991 then
                begin
                    if features[192] <= -5780.4999999999991 then
                    begin
                        Result := -0.011840700387295355;
                    end
                    else
                    begin
                        Result := 0.00098998768954436768;
                    end;
                end
                else
                begin
                    if features[0] <= 111369.50000000001 then
                    begin
                        Result := -0.0015140740620138901;
                    end
                    else
                    begin
                        Result := 0.0074218606723088464;
                    end;
                end;
            end;
        end
        else
        begin
            if features[9] <= 12.500000000000002 then
            begin
                if features[173] <= -6091.4999999999991 then
                begin
                    if features[147] <= -9.4999999999999982 then
                    begin
                        Result := 0.012950838482558989;
                    end
                    else
                    begin
                        Result := 0.0017052888687791791;
                    end;
                end
                else
                begin
                    if features[176] <= -8707.4999999999982 then
                    begin
                        Result := -0.0096753480906800419;
                    end
                    else
                    begin
                        if features[108] <= 98.500000000000014 then
                        begin
                            if features[190] <= -447.49999999999994 then
                            begin
                                Result := 0.0021641763932608161;
                            end
                            else
                            begin
                                if features[171] <= 1.0000000180025095E-35 then
                                begin
                                    Result := -0.013004228467153035;
                                end
                                else
                                begin
                                    Result := -0.0024805216624540277;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.014144328984760219;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[66] <= 701.00000000000011 then
                begin
                    Result := 0.011811372589675382;
                end
                else
                begin
                    Result := -0.016704537240287472;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_147(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.017230027515520874;
    end
    else
    begin
        if features[118] <= 1.0000000180025095E-35 then
        begin
            if features[122] <= -1090.4999999999998 then
            begin
                Result := -0.0088659142398489609;
            end
            else
            begin
                if features[15] <= -5959789.4999999991 then
                begin
                    Result := 0.0057104739712282131;
                end
                else
                begin
                    if features[109] <= 99.500000000000014 then
                    begin
                        if features[194] <= -5523.4999999999991 then
                        begin
                            if features[179] <= -5961.4999999999991 then
                            begin
                                Result := -0.0018748881649877439;
                            end
                            else
                            begin
                                Result := -0.017091257071899481;
                            end;
                        end
                        else
                        begin
                            if features[173] <= -6244.4999999999991 then
                            begin
                                if features[193] <= -1557.4999999999998 then
                                begin
                                    if features[183] <= -6166.4999999999991 then
                                    begin
                                        Result := 0.010466910263755689;
                                    end
                                    else
                                    begin
                                        Result := 0.097729700184830071;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.0047242779297644527;
                                end;
                            end
                            else
                            begin
                                Result := -0.0017280943174793235;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[178] <= 401.50000000000006 then
                        begin
                            Result := 0.015351660654884575;
                        end
                        else
                        begin
                            Result := 0.0014867717349624473;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[81] <= -1.0000000180025095E-35 then
            begin
                if features[108] <= -251.49999999999997 then
                begin
                    Result := -0.015485240605598048;
                end
                else
                begin
                    Result := -0.0034982881473912585;
                end;
            end
            else
            begin
                if features[53] <= 5.0000000000000009 then
                begin
                    Result := 0.0030922773220427341;
                end
                else
                begin
                    Result := -0.014349068089969681;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_148(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -719.49999999999989 then
    begin
        Result := -0.0077954646790511567;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6126.4999999999991 then
                begin
                    if features[184] <= -1475.4999999999998 then
                    begin
                        if features[194] <= -5479.4999999999991 then
                        begin
                            Result := -0.0014026322041457396;
                        end
                        else
                        begin
                            if features[192] <= -6354.4999999999991 then
                            begin
                                if features[186] <= -1000.4999999999999 then
                                begin
                                    Result := 0.01649187776050183;
                                end
                                else
                                begin
                                    if features[195] <= -5629.4999999999991 then
                                    begin
                                        Result := -0.0068114806030316185;
                                    end
                                    else
                                    begin
                                        Result := 0.099686554552222861;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.01038167662108932;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0022397082354787198;
                    end;
                end
                else
                begin
                    if features[96] <= -93453755.999999985 then
                    begin
                        if features[41] <= 1186.5000000000002 then
                        begin
                            Result := 0.0035440766066435004;
                        end
                        else
                        begin
                            if features[11] <= 3.5000000000000004 then
                            begin
                                Result := 0.015015471251481942;
                            end
                            else
                            begin
                                Result := 0.06274199927088113;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0025073212558751339;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -172095327.99999997 then
                begin
                    Result := -0.0086940216425484083;
                end
                else
                begin
                    Result := -4.8450823813443561E-05;
                end;
            end;
        end
        else
        begin
            if features[201] <= -4233.4999999999991 then
            begin
                Result := 0.0037937278844255061;
            end
            else
            begin
                Result := 0.033015710676298209;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_149(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.017976087217868027;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[177] <= -5522.4999999999991 then
                begin
                    if features[189] <= -6408.4999999999991 then
                    begin
                        if features[181] <= -2574.4999999999995 then
                        begin
                            if features[175] <= -2382.4999999999995 then
                            begin
                                Result := 0.0033252759417442819;
                            end
                            else
                            begin
                                Result := 0.094878837601751975;
                            end;
                        end
                        else
                        begin
                            if features[174] <= -7118.4999999999991 then
                            begin
                                if features[164] <= -162324895.99999997 then
                                begin
                                    Result := -0.0051041858663053623;
                                end
                                else
                                begin
                                    Result := 0.0094004942197417115;
                                end;
                            end
                            else
                            begin
                                Result := 0.040275924636192173;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.00071832026171609687;
                    end;
                end
                else
                begin
                    Result := -0.0059987406710892456;
                end;
            end
            else
            begin
                if features[25] <= 3.5000000000000004 then
                begin
                    if features[11] <= 3.5000000000000004 then
                    begin
                        if features[81] <= -5012.4999999999991 then
                        begin
                            Result := -0.011328552410191888;
                        end
                        else
                        begin
                            if features[188] <= -5323.4999999999991 then
                            begin
                                Result := -0.010273426783390067;
                            end
                            else
                            begin
                                Result := 6.0496232325222528E-05;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.017277995609281269;
                    end;
                end
                else
                begin
                    if features[166] <= 72871844.000000015 then
                    begin
                        Result := 0.0037676408352679855;
                    end
                    else
                    begin
                        Result := -0.013277096159972916;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.014185158125551073;
        end;
    end;
end;

function settled_top2_residual_tree_150(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= 353.50000000000006 then
    begin
        if features[164] <= -315822463.99999994 then
        begin
            if features[198] <= -3884.4999999999995 then
            begin
                Result := -0.0091462366270404199;
            end
            else
            begin
                if features[193] <= -210.49999999999997 then
                begin
                    if features[182] <= -3905.4999999999995 then
                    begin
                        Result := 0.06589261493854931;
                    end
                    else
                    begin
                        Result := -0.00074096381944703516;
                    end;
                end
                else
                begin
                    Result := -0.015572180396620706;
                end;
            end;
        end
        else
        begin
            if features[176] <= -9527.4999999999982 then
            begin
                if features[189] <= -4883.4999999999991 then
                begin
                    Result := -0.0087458258855783455;
                end
                else
                begin
                    Result := 0.004162326194198606;
                end;
            end
            else
            begin
                if features[200] <= -3160.4999999999995 then
                begin
                    if features[194] <= -3013.4999999999995 then
                    begin
                        Result := 0.00080308812787643175;
                    end
                    else
                    begin
                        if features[173] <= -6467.4999999999991 then
                        begin
                            Result := 0.079980480780201063;
                        end
                        else
                        begin
                            Result := 0.011845484565518052;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.010083478290649888;
                end;
            end;
        end;
    end
    else
    begin
        if features[188] <= -6199.9999999999991 then
        begin
            if features[110] <= -3.4999999999999996 then
            begin
                Result := -0.0099536378902303265;
            end
            else
            begin
                Result := 0.0066584113424038617;
            end;
        end
        else
        begin
            if features[27] <= -3782.4999999999995 then
            begin
                if features[198] <= -6358.4999999999991 then
                begin
                    Result := -0.017015301459512338;
                end
                else
                begin
                    Result := 0.016584977947076255;
                end;
            end
            else
            begin
                Result := -0.0035757050175648265;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_151(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -447.49999999999994 then
    begin
        if features[164] <= -249149359.99999997 then
        begin
            Result := -0.012137436085931345;
        end
        else
        begin
            if features[176] <= -6993.4999999999991 then
            begin
                if features[195] <= -7046.4999999999991 then
                begin
                    if features[158] <= 1775.0000000000002 then
                    begin
                        Result := -0.00758662076488212;
                    end
                    else
                    begin
                        Result := 0.040210843131446738;
                    end;
                end
                else
                begin
                    Result := -0.0083401078825329558;
                end;
            end
            else
            begin
                if features[39] <= 1363.5000000000002 then
                begin
                    Result := 0.011185744824891247;
                end
                else
                begin
                    if features[185] <= 85.250000000000014 then
                    begin
                        Result := -0.003435713973664504;
                    end
                    else
                    begin
                        if features[179] <= -5581.4999999999991 then
                        begin
                            Result := 0.005101687414565262;
                        end
                        else
                        begin
                            Result := 0.085990523896306417;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[171] <= 1.0000000180025095E-35 then
        begin
            if features[190] <= -533.49999999999989 then
            begin
                if features[192] <= -4677.4999999999991 then
                begin
                    Result := 0.012334967666205935;
                end
                else
                begin
                    Result := -0.012994324276904841;
                end;
            end
            else
            begin
                Result := -0.0057763288356166677;
            end;
        end
        else
        begin
            if features[199] <= 607.50000000000011 then
            begin
                Result := 0.0011956175819556891;
            end
            else
            begin
                if features[183] <= -7102.4999999999991 then
                begin
                    Result := 0.02249256589214715;
                end
                else
                begin
                    if features[198] <= -5355.4999999999991 then
                    begin
                        Result := -0.019963579027332579;
                    end
                    else
                    begin
                        Result := 0.010347258523459963;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_152(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -187.49999999999997 then
    begin
        if features[126] <= -1.0000000180025095E-35 then
        begin
            if features[189] <= -6241.4999999999991 then
            begin
                if features[175] <= -933.49999999999989 then
                begin
                    Result := 0.011061887056070946;
                end
                else
                begin
                    Result := 0.051078709892570455;
                end;
            end
            else
            begin
                Result := 0.00058542303857444698;
            end;
        end
        else
        begin
            if features[177] <= -6855.4999999999991 then
            begin
                if features[47] <= 11281.500000000002 then
                begin
                    Result := -0.008341105701763947;
                end
                else
                begin
                    if features[148] <= 1333.5000000000002 then
                    begin
                        if features[189] <= -7383.9999999999991 then
                        begin
                            Result := 0.034838669460765852;
                        end
                        else
                        begin
                            Result := -0.0031056998738722722;
                        end;
                    end
                    else
                    begin
                        Result := 0.030002316035950299;
                    end;
                end;
            end
            else
            begin
                if features[173] <= -7373.4999999999991 then
                begin
                    if features[190] <= 332.50000000000006 then
                    begin
                        if features[196] <= -1112.4999999999998 then
                        begin
                            Result := 0.068197409297313716;
                        end
                        else
                        begin
                            Result := 0.018452911011868783;
                        end;
                    end
                    else
                    begin
                        Result := -0.00060332896552681083;
                    end;
                end
                else
                begin
                    Result := -0.0026538887372780898;
                end;
            end;
        end;
    end
    else
    begin
        if features[77] <= 3268.0000000000005 then
        begin
            Result := -0.0016986685061594121;
        end
        else
        begin
            if features[196] <= -428.49999999999994 then
            begin
                if features[198] <= -4490.4999999999991 then
                begin
                    Result := 0.0077664740306994237;
                end
                else
                begin
                    Result := 0.063060199414326376;
                end;
            end
            else
            begin
                Result := 0.002694769065591714;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_153(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1080.4999999999998 then
    begin
        Result := -0.01615115841532419;
    end
    else
    begin
        if features[66] <= 1165.0000000000002 then
        begin
            if features[90] <= 12.500000000000002 then
            begin
                if features[164] <= -53279485.999999993 then
                begin
                    if features[11] <= 2.5000000000000004 then
                    begin
                        if features[173] <= -6171.4999999999991 then
                        begin
                            if features[195] <= -5556.4999999999991 then
                            begin
                                Result := -0.0034696503542046655;
                            end
                            else
                            begin
                                if features[184] <= -1475.4999999999998 then
                                begin
                                    if features[189] <= -7383.9999999999991 then
                                    begin
                                        Result := 0.077222451623690416;
                                    end
                                    else
                                    begin
                                        if features[176] <= -7028.4999999999991 then
                                        begin
                                            if features[164] <= -284306271.99999994 then
                                            begin
                                                Result := -0.0011255210783798128;
                                            end
                                            else
                                            begin
                                                Result := 0.062520316394196487;
                                            end;
                                        end
                                        else
                                        begin
                                            Result := 0.0030887469628941041;
                                        end;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.0019794937067591366;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[188] <= -5108.9999999999991 then
                            begin
                                Result := -0.014125316465634197;
                            end
                            else
                            begin
                                Result := -0.0029682239726999244;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0067942971502828915;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0019977144862366996;
                    end
                    else
                    begin
                        Result := 0.004791887239567476;
                    end;
                end;
            end
            else
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.028283702261859972;
                end
                else
                begin
                    Result := 0.004418042802810467;
                end;
            end;
        end
        else
        begin
            Result := -0.014980471014141704;
        end;
    end;
end;

function settled_top2_residual_tree_154(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[179] <= -4630.4999999999991 then
    begin
        if features[195] <= -4648.4999999999991 then
        begin
            if features[164] <= -315822463.99999994 then
            begin
                Result := -0.0084997183375445928;
            end
            else
            begin
                if features[180] <= -5516.4999999999991 then
                begin
                    Result := -0.00060375273207575347;
                end
                else
                begin
                    if features[174] <= -7436.4999999999991 then
                    begin
                        Result := 0.049319290977786687;
                    end
                    else
                    begin
                        if features[175] <= -864.49999999999989 then
                        begin
                            Result := 0.029999714672027663;
                        end
                        else
                        begin
                            Result := -0.0022441447851670681;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[184] <= -1874.4999999999998 then
            begin
                if features[196] <= -273.49999999999994 then
                begin
                    Result := 0.087977908979562633;
                end
                else
                begin
                    Result := 0.017839154691839342;
                end;
            end
            else
            begin
                if features[181] <= 731.50000000000011 then
                begin
                    if features[202] <= -141.49999999999997 then
                    begin
                        Result := -0.0021412505819777827;
                    end
                    else
                    begin
                        if features[193] <= -117.49999999999999 then
                        begin
                            if features[191] <= -5772.4999999999991 then
                            begin
                                if features[47] <= 4114.5000000000009 then
                                begin
                                    Result := 0.00269890170710674;
                                end
                                else
                                begin
                                    Result := 0.056461548470684547;
                                end;
                            end
                            else
                            begin
                                Result := 0.013421284490777181;
                            end;
                        end
                        else
                        begin
                            if features[180] <= -6963.4999999999991 then
                            begin
                                Result := 0.013491744162379369;
                            end
                            else
                            begin
                                Result := 0.0011924651129621936;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0099225142742556238;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.0068761992932528278;
    end;
end;

function settled_top2_residual_tree_155(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -118.49999999999999 then
    begin
        if features[189] <= -6571.4999999999991 then
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[182] <= -6763.4999999999991 then
                begin
                    Result := 0.0089615388033203233;
                end
                else
                begin
                    if features[24] <= 3.5000000000000004 then
                    begin
                        Result := 0.09842497086207895;
                    end
                    else
                    begin
                        Result := 0.027371262402371928;
                    end;
                end;
            end
            else
            begin
                Result := -0.00055124299692010752;
            end;
        end
        else
        begin
            if features[164] <= -15719408.499999998 then
            begin
                Result := -0.0043862718439190247;
            end
            else
            begin
                if features[178] <= 401.50000000000006 then
                begin
                    Result := 0.0067772071678375611;
                end
                else
                begin
                    Result := -0.0067881615262132752;
                end;
            end;
        end;
    end
    else
    begin
        if features[90] <= 10.500000000000002 then
        begin
            if features[27] <= -5955.4999999999991 then
            begin
                if features[188] <= -5611.4999999999991 then
                begin
                    Result := -0.0002762954435552634;
                end
                else
                begin
                    Result := 0.010700104552755128;
                end;
            end
            else
            begin
                if features[198] <= -4971.4999999999991 then
                begin
                    Result := -0.0025520184520955937;
                end
                else
                begin
                    if features[183] <= -6225.4999999999991 then
                    begin
                        Result := 0.0069930773823380608;
                    end
                    else
                    begin
                        if features[192] <= -6302.4999999999991 then
                        begin
                            Result := 0.014655954684037274;
                        end
                        else
                        begin
                            Result := -0.0026920786344334646;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[64] <= 1218.0000000000002 then
            begin
                Result := 0.013115588342578165;
            end
            else
            begin
                Result := -0.012334162893215815;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_156(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.017073471877062048;
    end
    else
    begin
        if features[92] <= 1.5000000000000002 then
        begin
            if features[124] <= -1.0000000180025095E-35 then
            begin
                if features[164] <= -260459519.99999997 then
                begin
                    Result := -0.009750599391634647;
                end
                else
                begin
                    if features[179] <= -5624.4999999999991 then
                    begin
                        Result := -0.0032399797737918215;
                    end
                    else
                    begin
                        if features[108] <= 64.500000000000014 then
                        begin
                            if features[174] <= -7051.9999999999991 then
                            begin
                                Result := 0.015549427756883123;
                            end
                            else
                            begin
                                Result := -0.0057456643672938569;
                            end;
                        end
                        else
                        begin
                            Result := 0.038665877525727449;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -5204.4999999999991 then
                begin
                    if features[202] <= 794.50000000000011 then
                    begin
                        if features[181] <= -611.49999999999989 then
                        begin
                            Result := 0.0037415302610018263;
                        end
                        else
                        begin
                            if features[186] <= -221.83333587646482 then
                            begin
                                Result := -0.0096990919806188639;
                            end
                            else
                            begin
                                Result := 0.00066495161626071346;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.018484185985916477;
                    end;
                end
                else
                begin
                    if features[193] <= -762.49999999999989 then
                    begin
                        if features[185] <= -113.41666793823241 then
                        begin
                            Result := 0.00054188070204552719;
                        end
                        else
                        begin
                            Result := 0.029888923770415778;
                        end;
                    end
                    else
                    begin
                        if features[110] <= -287.49999999999994 then
                        begin
                            Result := -0.017253670882841025;
                        end
                        else
                        begin
                            Result := -0.0024979211957175456;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.0064081448361008727;
        end;
    end;
end;

function settled_top2_residual_tree_157(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -310.49999999999994 then
    begin
        if features[164] <= -264356407.99999997 then
        begin
            Result := -0.0099030080145941154;
        end
        else
        begin
            if features[74] <= 9.5000000000000018 then
            begin
                if features[179] <= -6685.4999999999991 then
                begin
                    Result := -0.003025642079228113;
                end
                else
                begin
                    if features[196] <= -342.49999999999994 then
                    begin
                        if features[173] <= -6869.4999999999991 then
                        begin
                            if features[77] <= 4690.5000000000009 then
                            begin
                                if features[164] <= -5609037.9999999991 then
                                begin
                                    Result := 0.0031599759752994564;
                                end
                                else
                                begin
                                    Result := 0.036901270604855783;
                                end;
                            end
                            else
                            begin
                                if features[153] <= -143.49999999999997 then
                                begin
                                    Result := 0.096928035348594357;
                                end
                                else
                                begin
                                    Result := 0.033514518008390635;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.0036235631102740995;
                        end;
                    end
                    else
                    begin
                        Result := -0.012970520892485491;
                    end;
                end;
            end
            else
            begin
                Result := -0.0065601341757945261;
            end;
        end;
    end
    else
    begin
        if features[188] <= -5423.4999999999991 then
        begin
            if features[106] <= -1.4999999999999998 then
            begin
                Result := 0.0063089290790039514;
            end
            else
            begin
                if features[136] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0079301571490636383;
                end
                else
                begin
                    Result := -0.00077165138028068372;
                end;
            end;
        end
        else
        begin
            if features[199] <= 335.50000000000006 then
            begin
                Result := 0.0014042592342168318;
            end
            else
            begin
                if features[180] <= -5792.4999999999991 then
                begin
                    Result := 0.011916275702318195;
                end
                else
                begin
                    Result := -0.0049320851387245103;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_158(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[126] <= -1.0000000180025095E-35 then
    begin
        if features[174] <= -9070.4999999999982 then
        begin
            if features[147] <= -142.49999999999997 then
            begin
                Result := 0.05526324130897653;
            end
            else
            begin
                Result := 0.011686317147201059;
            end;
        end
        else
        begin
            if features[96] <= -64392531.999999993 then
            begin
                Result := 0.018874960869801984;
            end
            else
            begin
                Result := 0.00065697956937667767;
            end;
        end;
    end
    else
    begin
        if features[186] <= -302.83332824707026 then
        begin
            if features[174] <= -8119.4999999999991 then
            begin
                if features[201] <= -4703.4999999999991 then
                begin
                    Result := -0.0042155509234641925;
                end
                else
                begin
                    Result := 0.0099850805101969753;
                end;
            end
            else
            begin
                if features[170] <= 4.5000000000000009 then
                begin
                    Result := -0.0031409464272100967;
                end
                else
                begin
                    Result := -0.013596426000357596;
                end;
            end;
        end
        else
        begin
            if features[184] <= -509.49999999999994 then
            begin
                if features[108] <= -177.49999999999997 then
                begin
                    if features[184] <= -1302.4999999999998 then
                    begin
                        Result := 0.036401114015742017;
                    end
                    else
                    begin
                        Result := 0.0030111374911521382;
                    end;
                end
                else
                begin
                    Result := 0.022391055211794807;
                end;
            end
            else
            begin
                if features[199] <= 304.50000000000006 then
                begin
                    if features[176] <= -9527.4999999999982 then
                    begin
                        Result := -0.0081258956267643671;
                    end
                    else
                    begin
                        Result := -0.0008917820943687044;
                    end;
                end
                else
                begin
                    if features[193] <= -325.49999999999994 then
                    begin
                        Result := 0.042706388840412612;
                    end
                    else
                    begin
                        Result := 0.0037871507672075778;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_159(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[66] <= 1218.0000000000002 then
    begin
        if features[9] <= 11.500000000000002 then
        begin
            if features[199] <= -1426.4999999999998 then
            begin
                Result := -0.017446314665627308;
            end
            else
            begin
                if features[166] <= 162914960.00000003 then
                begin
                    if features[189] <= -6408.4999999999991 then
                    begin
                        if features[181] <= -2039.4999999999998 then
                        begin
                            if features[189] <= -8121.9999999999991 then
                            begin
                                Result := -0.023093640099764178;
                            end
                            else
                            begin
                                if features[193] <= 120.50000000000001 then
                                begin
                                    if features[189] <= -7383.9999999999991 then
                                    begin
                                        Result := 0.079863383842255414;
                                    end
                                    else
                                    begin
                                        Result := 0.023458776742303407;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.005158235500286195;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.0033744962272244106;
                        end;
                    end
                    else
                    begin
                        if features[186] <= -538.24999999999989 then
                        begin
                            if features[189] <= -5180.4999999999991 then
                            begin
                                if features[195] <= -5737.4999999999991 then
                                begin
                                    Result := -0.0073442875512253637;
                                end
                                else
                                begin
                                    Result := 0.010120429680557694;
                                end;
                            end
                            else
                            begin
                                Result := -0.011113120106411901;
                            end;
                        end
                        else
                        begin
                            Result := 0.00016861088500382665;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0095322833714858377;
                end;
            end;
        end
        else
        begin
            if features[199] <= -289.49999999999994 then
            begin
                Result := -0.0049006798489250897;
            end
            else
            begin
                if features[148] <= 1353.5000000000002 then
                begin
                    Result := 0.0076384121441857578;
                end
                else
                begin
                    Result := 0.034922893330475747;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.016561083895566108;
    end;
end;

function settled_top2_residual_tree_160(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[118] <= -1.0000000180025095E-35 then
    begin
        if features[174] <= -8966.4999999999982 then
        begin
            if features[166] <= -1.0000000180025095E-35 then
            begin
                Result := 0.039021009989995116;
            end
            else
            begin
                Result := 0.0087530406755206933;
            end;
        end
        else
        begin
            Result := 0.0015439142663726502;
        end;
    end
    else
    begin
        if features[187] <= -135.70833587646482 then
        begin
            Result := -0.011744063920849531;
        end
        else
        begin
            if features[192] <= -5886.4999999999991 then
            begin
                if features[166] <= 109196768.00000001 then
                begin
                    if features[47] <= 11416.500000000002 then
                    begin
                        if features[199] <= -510.49999999999994 then
                        begin
                            Result := -0.010092726718139355;
                        end
                        else
                        begin
                            Result := -0.0017487067055238234;
                        end;
                    end
                    else
                    begin
                        Result := 0.0037169659424149733;
                    end;
                end
                else
                begin
                    Result := -0.012810952609866528;
                end;
            end
            else
            begin
                if features[183] <= -8861.4999999999982 then
                begin
                    if features[180] <= -8769.4999999999982 then
                    begin
                        Result := 0.037328596481017627;
                    end
                    else
                    begin
                        Result := 0.0071832103400758648;
                    end;
                end
                else
                begin
                    if features[185] <= -100.41666793823241 then
                    begin
                        if features[177] <= -7497.4999999999991 then
                        begin
                            Result := 0.0031201345617992604;
                        end
                        else
                        begin
                            Result := -0.005434986122278768;
                        end;
                    end
                    else
                    begin
                        if features[184] <= -315.49999999999994 then
                        begin
                            if features[82] <= -131862.49999999997 then
                            begin
                                Result := 0.043750048950862923;
                            end
                            else
                            begin
                                Result := 0.011403360707153563;
                            end;
                        end
                        else
                        begin
                            Result := 0.0021461587192916562;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_161(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= 321.50000000000006 then
    begin
        if features[164] <= -384867039.99999994 then
        begin
            Result := -0.010312401444883277;
        end
        else
        begin
            if features[176] <= -9527.4999999999982 then
            begin
                if features[189] <= -4970.4999999999991 then
                begin
                    Result := -0.0090108470367572628;
                end
                else
                begin
                    Result := 0.0018959031708756049;
                end;
            end
            else
            begin
                if features[183] <= -8861.4999999999982 then
                begin
                    if features[166] <= -18438158.999999996 then
                    begin
                        Result := 0.038823851175019554;
                    end
                    else
                    begin
                        if features[198] <= -5563.4999999999991 then
                        begin
                            if features[29] <= -6061.4999999999991 then
                            begin
                                if features[189] <= -6876.4999999999991 then
                                begin
                                    Result := 0.024534125776002044;
                                end
                                else
                                begin
                                    Result := -0.0020441341942571516;
                                end;
                            end
                            else
                            begin
                                Result := 0.034109631431870929;
                            end;
                        end
                        else
                        begin
                            Result := 0.025120248246557026;
                        end;
                    end;
                end
                else
                begin
                    if features[11] <= 5.5000000000000009 then
                    begin
                        Result := -0.00016153659251206729;
                    end
                    else
                    begin
                        Result := 0.028588429383991577;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[193] <= 584.50000000000011 then
        begin
            if features[183] <= -5993.4999999999991 then
            begin
                Result := 0.020557080888443754;
            end
            else
            begin
                Result := 0.0020079426012352525;
            end;
        end
        else
        begin
            if features[163] <= -72195451.999999985 then
            begin
                if features[198] <= -4789.4999999999991 then
                begin
                    Result := 0.0068052984770356033;
                end
                else
                begin
                    Result := 0.034246047721845654;
                end;
            end
            else
            begin
                Result := -0.004176320283184454;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_162(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[145] <= -698.99999999999989 then
    begin
        Result := 0.014206713788380962;
    end
    else
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.02807431781113507;
        end
        else
        begin
            if features[90] <= -1.4999999999999998 then
            begin
                Result := -0.0055905698121922996;
            end
            else
            begin
                if features[164] <= -24976078.999999996 then
                begin
                    if features[185] <= -399.74999999999994 then
                    begin
                        if features[174] <= -8119.4999999999991 then
                        begin
                            if features[170] <= 1.0000000180025095E-35 then
                            begin
                                Result := -0.018718034424940841;
                            end
                            else
                            begin
                                Result := 0.0057386093658769203;
                            end;
                        end
                        else
                        begin
                            if features[171] <= 1.0000000180025095E-35 then
                            begin
                                if features[189] <= -6747.4999999999991 then
                                begin
                                    Result := 0.083178138266953028;
                                end
                                else
                                begin
                                    Result := -0.018291081243836358;
                                end;
                            end
                            else
                            begin
                                Result := -0.0040137388286003396;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[184] <= -1244.4999999999998 then
                        begin
                            if features[189] <= -5668.4999999999991 then
                            begin
                                if features[47] <= 10299.500000000002 then
                                begin
                                    Result := 0.068851090405288085;
                                end
                                else
                                begin
                                    Result := -0.0054192399860751835;
                                end;
                            end
                            else
                            begin
                                Result := 0.009287136746019246;
                            end;
                        end
                        else
                        begin
                            Result := 0.0003254602753192069;
                        end;
                    end;
                end
                else
                begin
                    if features[181] <= -906.49999999999989 then
                    begin
                        Result := 0.021467387017593351;
                    end
                    else
                    begin
                        if features[166] <= 10296288.500000002 then
                        begin
                            Result := 0.0053486888493202225;
                        end
                        else
                        begin
                            Result := -0.0093651746445127648;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_163(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1547.4999999999998 then
    begin
        Result := -0.019729419909490634;
    end
    else
    begin
        if features[166] <= -16113090.499999998 then
        begin
            if features[184] <= -540.49999999999989 then
            begin
                Result := 0.031390798341939218;
            end
            else
            begin
                Result := 0.0044552897048688381;
            end;
        end
        else
        begin
            if features[66] <= 427.50000000000006 then
            begin
                if features[9] <= 5.5000000000000009 then
                begin
                    if features[81] <= -233.49999999999997 then
                    begin
                        Result := -0.0026989270439245049;
                    end
                    else
                    begin
                        Result := 0.00082125229811651646;
                    end;
                end
                else
                begin
                    if features[109] <= 113.50000000000001 then
                    begin
                        if features[126] <= -1.0000000180025095E-35 then
                        begin
                            if features[55] <= 1.5000000000000002 then
                            begin
                                if features[194] <= -6347.4999999999991 then
                                begin
                                    Result := -0.010644641580230816;
                                end
                                else
                                begin
                                    Result := 0.020203950078186851;
                                end;
                            end
                            else
                            begin
                                if features[183] <= -6722.4999999999991 then
                                begin
                                    if features[184] <= -269.49999999999994 then
                                    begin
                                        Result := 0.015994429086492967;
                                    end
                                    else
                                    begin
                                        Result := -0.0058040084565394411;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.011381348288791447;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[81] <= -119355.99999999999 then
                            begin
                                Result := 0.010652882990134045;
                            end
                            else
                            begin
                                Result := -0.0021821280291826526;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[181] <= 247.50000000000003 then
                        begin
                            Result := 0.040883398024966641;
                        end
                        else
                        begin
                            Result := 0.0089217780767804032;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.0083715851133034369;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_164(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[182] <= -3905.4999999999995 then
    begin
        if features[198] <= -4226.4999999999991 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6126.4999999999991 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[175] <= -334.49999999999994 then
                        begin
                            Result := 0.0054381910834904977;
                        end
                        else
                        begin
                            Result := -0.0025193153664436973;
                        end;
                    end
                    else
                    begin
                        if features[181] <= 247.50000000000003 then
                        begin
                            if features[198] <= -4826.4999999999991 then
                            begin
                                Result := 0.0067589150926964789;
                            end
                            else
                            begin
                                if features[192] <= -5921.4999999999991 then
                                begin
                                    Result := -0.00070278494099910722;
                                end
                                else
                                begin
                                    Result := 0.032703573828393832;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.0024577006591448465;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0018875355765045261;
                end;
            end
            else
            begin
                if features[45] <= 2.5000000000000004 then
                begin
                    Result := -0.013781070464341289;
                end
                else
                begin
                    if features[192] <= -5973.4999999999991 then
                    begin
                        if features[36] <= 346.50000000000006 then
                        begin
                            if features[173] <= -4832.4999999999991 then
                            begin
                                Result := -0.004800573463598269;
                            end
                            else
                            begin
                                Result := 0.01418441518829376;
                            end;
                        end
                        else
                        begin
                            Result := -0.013876892209308954;
                        end;
                    end
                    else
                    begin
                        Result := 0.0019844318711352803;
                    end;
                end;
            end;
        end
        else
        begin
            if features[90] <= 12.500000000000002 then
            begin
                Result := 0.0045688366535108346;
            end
            else
            begin
                Result := 0.031408907335885146;
            end;
        end;
    end
    else
    begin
        Result := -0.011562888614537647;
    end;
end;

function settled_top2_residual_tree_165(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.028009311193440911;
    end
    else
    begin
        if features[199] <= -1426.4999999999998 then
        begin
            Result := -0.016455178487492818;
        end
        else
        begin
            if features[143] <= -1.0000000180025095E-35 then
            begin
                Result := 0.0084722063162747437;
            end
            else
            begin
                if features[90] <= -1.4999999999999998 then
                begin
                    if features[195] <= -3649.4999999999995 then
                    begin
                        Result := -0.0078253413835754609;
                    end
                    else
                    begin
                        Result := 0.032981246448525174;
                    end;
                end
                else
                begin
                    if features[164] <= -24976078.999999996 then
                    begin
                        if features[201] <= -4006.4999999999995 then
                        begin
                            if features[179] <= -5129.4999999999991 then
                            begin
                                if features[195] <= -4447.4999999999991 then
                                begin
                                    Result := -0.00079551593035723949;
                                end
                                else
                                begin
                                    Result := 0.0080786832901370946;
                                end;
                            end
                            else
                            begin
                                Result := -0.008035329956014442;
                            end;
                        end
                        else
                        begin
                            if features[177] <= -6412.4999999999991 then
                            begin
                                if features[89] <= 1.0000000180025095E-35 then
                                begin
                                    Result := 0.014496690359512546;
                                end
                                else
                                begin
                                    if features[25] <= 1.0000000180025095E-35 then
                                    begin
                                        Result := 0.022964020695609957;
                                    end
                                    else
                                    begin
                                        Result := -0.0023178939884482127;
                                    end;
                                end;
                            end
                            else
                            begin
                                if features[175] <= 2451.5000000000005 then
                                begin
                                    Result := -0.0035132680511636297;
                                end
                                else
                                begin
                                    Result := 0.03559697241617537;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[109] <= -687.49999999999989 then
                        begin
                            Result := 0.035304143491116644;
                        end
                        else
                        begin
                            Result := 0.0037401044142685437;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_166(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.018588718314853005;
    end
    else
    begin
        if features[118] <= 1.0000000180025095E-35 then
        begin
            if features[122] <= -1090.4999999999998 then
            begin
                Result := -0.0088870576425857661;
            end
            else
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        Result := 0.00091044644525663265;
                    end
                    else
                    begin
                        if features[90] <= 1.0000000180025095E-35 then
                        begin
                            if features[190] <= 603.50000000000011 then
                            begin
                                Result := 0.058325075667330188;
                            end
                            else
                            begin
                                Result := -0.0013928765661307516;
                            end;
                        end
                        else
                        begin
                            if features[190] <= 132.50000000000003 then
                            begin
                                Result := -0.027141441528160427;
                            end
                            else
                            begin
                                if features[171] <= 6.5000000000000009 then
                                begin
                                    Result := -0.0070082826528519195;
                                end
                                else
                                begin
                                    Result := 0.026745569720433113;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[173] <= -7052.4999999999991 then
                    begin
                        Result := 0.0096407763230502951;
                    end
                    else
                    begin
                        Result := 0.0022342227572561785;
                    end;
                end;
            end;
        end
        else
        begin
            if features[169] <= 1.5000000000000002 then
            begin
                if features[190] <= -631.49999999999989 then
                begin
                    Result := 0.0081282933691104228;
                end
                else
                begin
                    Result := -0.0028839707719277414;
                end;
            end
            else
            begin
                if features[189] <= -5225.4999999999991 then
                begin
                    Result := -0.014802771852290836;
                end
                else
                begin
                    if features[196] <= 192.50000000000003 then
                    begin
                        Result := -0.010265943922246158;
                    end
                    else
                    begin
                        Result := 0.013978153865016704;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_167(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1080.4999999999998 then
    begin
        Result := -0.016670784514517527;
    end
    else
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.027556920803363045;
        end
        else
        begin
            if features[164] <= -53279485.999999993 then
            begin
                if features[198] <= -5005.4999999999991 then
                begin
                    Result := -0.0026271214053133203;
                end
                else
                begin
                    if features[183] <= -9054.4999999999982 then
                    begin
                        Result := 0.057560685700351145;
                    end
                    else
                    begin
                        if features[182] <= -4456.4999999999991 then
                        begin
                            if features[198] <= -3884.4999999999995 then
                            begin
                                if features[11] <= 2.5000000000000004 then
                                begin
                                    if features[109] <= -1281.4999999999998 then
                                    begin
                                        Result := 0.029452486001158119;
                                    end
                                    else
                                    begin
                                        Result := 0.00031333903259243693;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.013988496082203525;
                                end;
                            end
                            else
                            begin
                                Result := 0.012542766299280396;
                            end;
                        end
                        else
                        begin
                            Result := -0.006908537382186739;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[158] <= -1731.9999999999998 then
                begin
                    if features[142] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0071192991544383674;
                    end
                    else
                    begin
                        Result := -0.0045517325557651632;
                    end;
                end
                else
                begin
                    if features[196] <= -1059.4999999999998 then
                    begin
                        if features[176] <= -8251.4999999999982 then
                        begin
                            Result := -0.013085658943745746;
                        end
                        else
                        begin
                            Result := 0.063167876601458534;
                        end;
                    end
                    else
                    begin
                        if features[184] <= -723.49999999999989 then
                        begin
                            Result := 0.018431610009455396;
                        end
                        else
                        begin
                            Result := 0.0030547681939387325;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_168(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.026072374523115976;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[186] <= -538.24999999999989 then
            begin
                if features[174] <= -8119.4999999999991 then
                begin
                    Result := 0.0038188441811694306;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.018136185839034757;
                    end
                    else
                    begin
                        Result := -0.0050715588962047895;
                    end;
                end;
            end
            else
            begin
                if features[184] <= -526.49999999999989 then
                begin
                    if features[186] <= -86.833332061767564 then
                    begin
                        if features[194] <= -6059.4999999999991 then
                        begin
                            Result := -0.0063844284401435962;
                        end
                        else
                        begin
                            if features[199] <= -117.49999999999999 then
                            begin
                                Result := 0.00071631652192339409;
                            end
                            else
                            begin
                                Result := 0.010156631634703249;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.034976270575560679;
                    end;
                end
                else
                begin
                    if features[108] <= -108.49999999999999 then
                    begin
                        if features[171] <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.012228259265753274;
                        end
                        else
                        begin
                            Result := -0.0010286202131127684;
                        end;
                    end
                    else
                    begin
                        if features[176] <= -7643.4999999999991 then
                        begin
                            Result := -0.0013167354854636644;
                        end
                        else
                        begin
                            if features[184] <= -315.49999999999994 then
                            begin
                                if features[186] <= -27.749999999999996 then
                                begin
                                    Result := 0.014092738089251121;
                                end
                                else
                                begin
                                    Result := 0.068977642154371369;
                                end;
                            end
                            else
                            begin
                                Result := 0.00368500641915515;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.014694836576159248;
        end;
    end;
end;

function settled_top2_residual_tree_169(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[166] <= -16113090.499999998 then
    begin
        if features[123] <= -163.49999999999997 then
        begin
            Result := 0.044742810494770205;
        end
        else
        begin
            if features[184] <= -760.49999999999989 then
            begin
                Result := 0.035582573976378186;
            end
            else
            begin
                Result := 0.0043901314156067793;
            end;
        end;
    end
    else
    begin
        if features[195] <= -4695.4999999999991 then
        begin
            if features[66] <= 232.50000000000003 then
            begin
                if features[164] <= -325222047.99999994 then
                begin
                    if features[190] <= 3702.5000000000005 then
                    begin
                        Result := -0.0096280647224712447;
                    end
                    else
                    begin
                        Result := 0.027416496792636393;
                    end;
                end
                else
                begin
                    if features[166] <= 116324368.00000001 then
                    begin
                        Result := 0.00026206913654356153;
                    end
                    else
                    begin
                        Result := -0.007611836702492606;
                    end;
                end;
            end
            else
            begin
                Result := -0.012081855839954763;
            end;
        end
        else
        begin
            if features[163] <= -78419643.999999985 then
            begin
                Result := 0.014272449121620918;
            end
            else
            begin
                if features[193] <= -1150.4999999999998 then
                begin
                    if features[198] <= -4190.4999999999991 then
                    begin
                        Result := 0.0062040117113184769;
                    end
                    else
                    begin
                        Result := 0.053911014523472169;
                    end;
                end
                else
                begin
                    if features[0] <= 181287.50000000003 then
                    begin
                        if features[183] <= -5993.4999999999991 then
                        begin
                            if features[198] <= -4110.4999999999991 then
                            begin
                                Result := 0.0014644862666127129;
                            end
                            else
                            begin
                                Result := 0.017155918243382494;
                            end;
                        end
                        else
                        begin
                            Result := -0.0046852657669353478;
                        end;
                    end
                    else
                    begin
                        Result := 0.0093901027602404513;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_170(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.017094432973654657;
    end
    else
    begin
        if features[66] <= 1218.0000000000002 then
        begin
            if features[135] <= 3.5000000000000004 then
            begin
                if features[164] <= -310909967.99999994 then
                begin
                    Result := -0.0091913176581009254;
                end
                else
                begin
                    if features[147] <= -1717.4999999999998 then
                    begin
                        Result := 0.040614080136857578;
                    end
                    else
                    begin
                        Result := -0.00012705350740394885;
                    end;
                end;
            end
            else
            begin
                if features[109] <= 64.500000000000014 then
                begin
                    if features[11] <= 4.5000000000000009 then
                    begin
                        if features[182] <= -4247.4999999999991 then
                        begin
                            if features[195] <= -4672.4999999999991 then
                            begin
                                Result := -0.00025938017463629238;
                            end
                            else
                            begin
                                if features[163] <= 51249394.000000007 then
                                begin
                                    Result := 0.019197146415498825;
                                end
                                else
                                begin
                                    Result := 0.00058983319778546531;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.013582181436702154;
                        end;
                    end
                    else
                    begin
                        if features[41] <= 1231.5000000000002 then
                        begin
                            Result := 0.0096280364622689622;
                        end
                        else
                        begin
                            Result := 0.062640225957015336;
                        end;
                    end;
                end
                else
                begin
                    if features[179] <= -6096.4999999999991 then
                    begin
                        if features[155] <= -2.4999999999999996 then
                        begin
                            Result := 0.033991657603085895;
                        end
                        else
                        begin
                            Result := 0.0057067352126145554;
                        end;
                    end
                    else
                    begin
                        if features[157] <= 8.5000000000000018 then
                        begin
                            Result := 0.0053092328835528807;
                        end
                        else
                        begin
                            Result := 0.064607418972884273;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.013820054067871299;
        end;
    end;
end;

function settled_top2_residual_tree_171(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[186] <= -538.24999999999989 then
    begin
        if features[189] <= -5180.4999999999991 then
        begin
            if features[47] <= 2309.0000000000005 then
            begin
                Result := 0.045691862912530613;
            end
            else
            begin
                if features[198] <= -4862.4999999999991 then
                begin
                    Result := -0.0024979685883862175;
                end
                else
                begin
                    Result := 0.012307190319989602;
                end;
            end;
        end
        else
        begin
            Result := -0.01094731423374687;
        end;
    end
    else
    begin
        if features[154] <= 263.50000000000006 then
        begin
            if features[148] <= 2713.5000000000005 then
            begin
                if features[184] <= -1302.4999999999998 then
                begin
                    if features[186] <= -252.74999999999997 then
                    begin
                        Result := 0.0070180369506748011;
                    end
                    else
                    begin
                        Result := 0.04926416342053748;
                    end;
                end
                else
                begin
                    if features[166] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.008051780204085977;
                    end
                    else
                    begin
                        if features[202] <= 528.50000000000011 then
                        begin
                            if features[176] <= -10424.499999999998 then
                            begin
                                Result := -0.009776602006852618;
                            end
                            else
                            begin
                                if features[188] <= -4382.4999999999991 then
                                begin
                                    Result := 0.0014656854897543881;
                                end
                                else
                                begin
                                    Result := -0.0027131491619822412;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[194] <= -7010.4999999999991 then
                            begin
                                Result := -0.0094251136207095972;
                            end
                            else
                            begin
                                Result := 0.014413447843079156;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.010115942475903077;
            end;
        end
        else
        begin
            if features[194] <= -5958.4999999999991 then
            begin
                Result := -0.012228373918125847;
            end
            else
            begin
                Result := -0.00083170183601212564;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_172(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.026086618907336757;
    end
    else
    begin
        if features[164] <= -53279485.999999993 then
        begin
            if features[195] <= -4648.4999999999991 then
            begin
                if features[179] <= -5225.4999999999991 then
                begin
                    if features[187] <= -135.70833587646482 then
                    begin
                        Result := -0.011722250776168806;
                    end
                    else
                    begin
                        if features[81] <= -209.49999999999997 then
                        begin
                            if features[105] <= 1.0000000180025095E-35 then
                            begin
                                if features[128] <= -18364.499999999996 then
                                begin
                                    if features[181] <= -694.49999999999989 then
                                    begin
                                        Result := 0.023466687242422908;
                                    end
                                    else
                                    begin
                                        Result := 0.0011180746545877433;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.002010460749510481;
                                end;
                            end
                            else
                            begin
                                Result := -0.0078470019624366748;
                            end;
                        end
                        else
                        begin
                            if features[151] <= -19.499999999999996 then
                            begin
                                Result := 0.0038531656714114607;
                            end
                            else
                            begin
                                Result := -0.003956581375122897;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.010866470305509857;
                end;
            end
            else
            begin
                if features[180] <= -7251.4999999999991 then
                begin
                    if features[190] <= 2732.0000000000005 then
                    begin
                        Result := 0.016622062099506493;
                    end
                    else
                    begin
                        Result := -0.024347393358506681;
                    end;
                end
                else
                begin
                    if features[186] <= -538.24999999999989 then
                    begin
                        Result := -0.011499828997792947;
                    end
                    else
                    begin
                        Result := 0.0025610242846134932;
                    end;
                end;
            end;
        end
        else
        begin
            if features[136] <= -1.0000000180025095E-35 then
            begin
                Result := -0.0016764799426328845;
            end
            else
            begin
                Result := 0.0045241816286482345;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_173(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.017044540951033058;
    end
    else
    begin
        if features[122] <= -1039.4999999999998 then
        begin
            if features[171] <= 2.5000000000000004 then
            begin
                Result := -0.013680427414166316;
            end
            else
            begin
                if features[39] <= 1306.5000000000002 then
                begin
                    Result := 0.013128009990062443;
                end
                else
                begin
                    Result := -0.0056372234590284136;
                end;
            end;
        end
        else
        begin
            if features[145] <= -698.99999999999989 then
            begin
                Result := 0.013652305814420659;
            end
            else
            begin
                if features[90] <= -1.4999999999999998 then
                begin
                    Result := -0.0053411146970895954;
                end
                else
                begin
                    if features[47] <= 9757.5000000000018 then
                    begin
                        if features[202] <= 353.50000000000006 then
                        begin
                            if features[106] <= 1.5000000000000002 then
                            begin
                                Result := -1.5234262488094367E-05;
                            end
                            else
                            begin
                                Result := -0.0055793930103267978;
                            end;
                        end
                        else
                        begin
                            if features[193] <= 638.50000000000011 then
                            begin
                                Result := 0.016297154642051864;
                            end
                            else
                            begin
                                Result := 0.00086649885846646181;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[189] <= -4016.4999999999995 then
                        begin
                            if features[175] <= 183.50000000000003 then
                            begin
                                if features[129] <= -27259.999999999996 then
                                begin
                                    Result := -0.015060954834400724;
                                end
                                else
                                begin
                                    Result := 0.0083365519632349373;
                                end;
                            end
                            else
                            begin
                                Result := -6.9330505875681597E-05;
                            end;
                        end
                        else
                        begin
                            if features[189] <= -3965.4999999999995 then
                            begin
                                Result := -0.023552117289806388;
                            end
                            else
                            begin
                                Result := -0.00056617920574981453;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_174(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.025791332865170019;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[186] <= -538.24999999999989 then
            begin
                if features[189] <= -5180.4999999999991 then
                begin
                    Result := 0.0029499687644631784;
                end
                else
                begin
                    Result := -0.010383931629833998;
                end;
            end
            else
            begin
                if features[178] <= -198.49999999999997 then
                begin
                    if features[185] <= -60.749999999999993 then
                    begin
                        if features[201] <= -3868.4999999999995 then
                        begin
                            Result := -0.00026083414510286976;
                        end
                        else
                        begin
                            if features[202] <= 64.500000000000014 then
                            begin
                                if features[185] <= -516.24999999999989 then
                                begin
                                    Result := 0.052146814273761513;
                                end
                                else
                                begin
                                    Result := 8.6652228447092985E-05;
                                end;
                            end
                            else
                            begin
                                Result := 0.020942824224119;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[184] <= -164.49999999999997 then
                        begin
                            if features[109] <= -20.499999999999996 then
                            begin
                                Result := 0.0093649982452621676;
                            end
                            else
                            begin
                                if features[175] <= -1805.4999999999998 then
                                begin
                                    Result := -0.0063125408851832897;
                                end
                                else
                                begin
                                    Result := 0.045610262218321429;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.0028828812454146091;
                        end;
                    end;
                end
                else
                begin
                    if features[109] <= 5.5000000000000009 then
                    begin
                        if features[171] <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.012775628830031225;
                        end
                        else
                        begin
                            Result := -0.0016082097344152467;
                        end;
                    end
                    else
                    begin
                        Result := 0.00045687496276799051;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.012899642141809482;
        end;
    end;
end;

function settled_top2_residual_tree_175(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -116754263.99999999 then
    begin
        if features[202] <= -653.49999999999989 then
        begin
            if features[189] <= -6102.4999999999991 then
            begin
                if features[174] <= -8210.4999999999982 then
                begin
                    Result := -0.0068275562130993457;
                end
                else
                begin
                    if features[195] <= -5214.4999999999991 then
                    begin
                        Result := 0.017557202080377979;
                    end
                    else
                    begin
                        Result := 0.14455590911217653;
                    end;
                end;
            end
            else
            begin
                Result := -0.01474315077608928;
            end;
        end
        else
        begin
            if features[198] <= -4585.4999999999991 then
            begin
                Result := -0.0021573831326638887;
            end
            else
            begin
                if features[182] <= -4520.4999999999991 then
                begin
                    if features[196] <= -440.49999999999994 then
                    begin
                        if features[199] <= -217.49999999999997 then
                        begin
                            Result := 0.013158626167540636;
                        end
                        else
                        begin
                            Result := 0.062628851054471885;
                        end;
                    end
                    else
                    begin
                        Result := 0.0041052937286187681;
                    end;
                end
                else
                begin
                    Result := -0.0061731880654019239;
                end;
            end;
        end;
    end
    else
    begin
        if features[90] <= -1.4999999999999998 then
        begin
            if features[147] <= -1.0000000180025095E-35 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.037429423795641584;
                end
                else
                begin
                    Result := 0.0010620429874105583;
                end;
            end
            else
            begin
                Result := -0.005829586545707012;
            end;
        end
        else
        begin
            if features[188] <= -4539.4999999999991 then
            begin
                if features[189] <= -6747.4999999999991 then
                begin
                    Result := 0.017668446110975105;
                end
                else
                begin
                    Result := 0.0037631477555208552;
                end;
            end
            else
            begin
                Result := -0.0016182625817844525;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_176(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.026979522994100627;
    end
    else
    begin
        if features[202] <= 353.50000000000006 then
        begin
            if features[176] <= -9527.4999999999982 then
            begin
                if features[189] <= -4883.4999999999991 then
                begin
                    Result := -0.0085683748542040826;
                end
                else
                begin
                    if features[188] <= -5630.4999999999991 then
                    begin
                        Result := -0.013295476751208238;
                    end
                    else
                    begin
                        if features[173] <= -6709.4999999999991 then
                        begin
                            if features[202] <= -74.499999999999986 then
                            begin
                                Result := -0.0064366281103744099;
                            end
                            else
                            begin
                                if features[189] <= -4477.4999999999991 then
                                begin
                                    Result := 0.057192339033739749;
                                end
                                else
                                begin
                                    Result := 0.014450071688272729;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.001177808983745217;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -384867039.99999994 then
                begin
                    Result := -0.0097934387076248474;
                end
                else
                begin
                    if features[183] <= -8861.4999999999982 then
                    begin
                        Result := 0.0073646778276906721;
                    end
                    else
                    begin
                        Result := 0.00015388564389209511;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -6199.9999999999991 then
            begin
                if features[183] <= -7753.4999999999991 then
                begin
                    if features[198] <= -5057.4999999999991 then
                    begin
                        Result := 0.0031721793955915159;
                    end
                    else
                    begin
                        Result := 0.050849955413577501;
                    end;
                end
                else
                begin
                    Result := -0.0074019881584261593;
                end;
            end
            else
            begin
                if features[180] <= -7895.4999999999991 then
                begin
                    Result := 0.023870541569141392;
                end
                else
                begin
                    Result := 0.0058814747037444388;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_177(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[182] <= -4004.4999999999995 then
    begin
        if features[198] <= -3806.4999999999995 then
        begin
            if features[183] <= -8861.4999999999982 then
            begin
                if features[198] <= -5039.4999999999991 then
                begin
                    if features[164] <= -57023309.999999993 then
                    begin
                        Result := 0.00071234132360551566;
                    end
                    else
                    begin
                        Result := 0.012855631469603777;
                    end;
                end
                else
                begin
                    Result := 0.036849848382340893;
                end;
            end
            else
            begin
                if features[164] <= -371423039.99999994 then
                begin
                    if features[195] <= -4648.4999999999991 then
                    begin
                        Result := -0.012841899647230627;
                    end
                    else
                    begin
                        Result := 0.0064368241363002669;
                    end;
                end
                else
                begin
                    if features[184] <= -509.49999999999994 then
                    begin
                        if features[110] <= -174.49999999999997 then
                        begin
                            if features[194] <= -6059.4999999999991 then
                            begin
                                Result := -0.0074103427720308215;
                            end
                            else
                            begin
                                if features[176] <= -5889.4999999999991 then
                                begin
                                    Result := 0.0053654853758656768;
                                end
                                else
                                begin
                                    Result := -0.0036395288754084206;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.023945785685027213;
                        end;
                    end
                    else
                    begin
                        if features[110] <= -338.49999999999994 then
                        begin
                            Result := -0.012644832855303113;
                        end
                        else
                        begin
                            Result := -0.00065530017318707334;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[193] <= -1181.4999999999998 then
            begin
                Result := 0.059249538461411559;
            end
            else
            begin
                if features[183] <= -6871.4999999999991 then
                begin
                    Result := 0.03835308138743982;
                end
                else
                begin
                    Result := 0.0042352208890161702;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.010026958632714494;
    end;
end;

function settled_top2_residual_tree_178(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[164] <= -384867039.99999994 then
    begin
        if features[118] <= 1.0000000180025095E-35 then
        begin
            Result := -0.0029343674021555196;
        end
        else
        begin
            Result := -0.019791563278624986;
        end;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[176] <= -9527.4999999999982 then
            begin
                if features[189] <= -4748.4999999999991 then
                begin
                    Result := -0.0066207399642484697;
                end
                else
                begin
                    if features[188] <= -6553.4999999999991 then
                    begin
                        Result := -0.011052498349972021;
                    end
                    else
                    begin
                        Result := 0.010760232517415176;
                    end;
                end;
            end
            else
            begin
                if features[90] <= 3.5000000000000004 then
                begin
                    if features[147] <= -1717.4999999999998 then
                    begin
                        Result := 0.039264741258928232;
                    end
                    else
                    begin
                        Result := -0.00029573897103609271;
                    end;
                end
                else
                begin
                    if features[109] <= 64.500000000000014 then
                    begin
                        if features[180] <= -7204.4999999999991 then
                        begin
                            if features[195] <= -4672.4999999999991 then
                            begin
                                Result := 0.0035829040834597981;
                            end
                            else
                            begin
                                Result := 0.021099265728792033;
                            end;
                        end
                        else
                        begin
                            if features[82] <= -115780.49999999999 then
                            begin
                                Result := 0.0045633120516323745;
                            end
                            else
                            begin
                                Result := -0.0062737561326558638;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.010394244364137328;
                    end;
                end;
            end;
        end
        else
        begin
            if features[176] <= -6418.4999999999991 then
            begin
                if features[198] <= -5284.4999999999991 then
                begin
                    Result := 0.0017624398991795056;
                end
                else
                begin
                    Result := 0.033335062389887891;
                end;
            end
            else
            begin
                Result := -0.0086286471185593443;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_179(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[122] <= -1141.4999999999998 then
    begin
        if features[171] <= 2.5000000000000004 then
        begin
            Result := -0.013344147445058789;
        end
        else
        begin
            Result := 0.0030860265896175878;
        end;
    end
    else
    begin
        if features[195] <= -4812.4999999999991 then
        begin
            if features[108] <= -91.499999999999986 then
            begin
                if features[189] <= -6408.4999999999991 then
                begin
                    if features[175] <= -2513.4999999999995 then
                    begin
                        if features[164] <= -132289747.99999999 then
                        begin
                            Result := -0.015010181932108613;
                        end
                        else
                        begin
                            Result := 0.014138442738781646;
                        end;
                    end
                    else
                    begin
                        if features[178] <= -3033.4999999999995 then
                        begin
                            Result := 0.052586113958578345;
                        end
                        else
                        begin
                            Result := 0.011821310875119038;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0028547994328722726;
                end;
            end
            else
            begin
                if features[176] <= -7643.4999999999991 then
                begin
                    Result := -0.00095800395046816101;
                end
                else
                begin
                    Result := 0.0064503573378856044;
                end;
            end;
        end
        else
        begin
            if features[180] <= -7443.4999999999991 then
            begin
                if features[105] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.024901325971826628;
                end
                else
                begin
                    Result := 0.0071394625128500845;
                end;
            end
            else
            begin
                if features[0] <= 177603.50000000003 then
                begin
                    if features[181] <= 662.50000000000011 then
                    begin
                        Result := 0.0015434247375132079;
                    end
                    else
                    begin
                        Result := -0.010936996807472973;
                    end;
                end
                else
                begin
                    if features[117] <= -193.49999999999997 then
                    begin
                        Result := 0.02582870387754399;
                    end
                    else
                    begin
                        Result := 0.0048323049511046507;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_180(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[182] <= -3905.4999999999995 then
    begin
        if features[198] <= -3606.4999999999995 then
        begin
            if features[66] <= 1218.0000000000002 then
            begin
                if features[9] <= 11.500000000000002 then
                begin
                    if features[147] <= -1717.4999999999998 then
                    begin
                        Result := 0.031915573383015469;
                    end
                    else
                    begin
                        if features[120] <= -1438.4999999999998 then
                        begin
                            if features[109] <= 113.50000000000001 then
                            begin
                                Result := 0.003381796316194808;
                            end
                            else
                            begin
                                Result := 0.02531365381909036;
                            end;
                        end
                        else
                        begin
                            if features[187] <= -152.87499999999997 then
                            begin
                                Result := -0.012554795923625179;
                            end
                            else
                            begin
                                Result := -0.00051592850632363062;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[199] <= -289.49999999999994 then
                    begin
                        if features[201] <= -6060.4999999999991 then
                        begin
                            if features[175] <= -1243.4999999999998 then
                            begin
                                Result := -0.0046579064278245621;
                            end
                            else
                            begin
                                Result := 0.073138977125410606;
                            end;
                        end
                        else
                        begin
                            Result := -0.0076325871505857727;
                        end;
                    end
                    else
                    begin
                        if features[148] <= 1353.5000000000002 then
                        begin
                            if features[108] <= 112.50000000000001 then
                            begin
                                Result := 0.0048743255065591719;
                            end
                            else
                            begin
                                Result := 0.020946731477225554;
                            end;
                        end
                        else
                        begin
                            Result := 0.034747370828619277;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.014650510092588283;
            end;
        end
        else
        begin
            if features[178] <= -293.49999999999994 then
            begin
                Result := 0.020924168401782076;
            end
            else
            begin
                Result := 0.0020867916610514902;
            end;
        end;
    end
    else
    begin
        Result := -0.011239584972499361;
    end;
end;

function settled_top2_residual_tree_181(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= 484.50000000000006 then
    begin
        if features[117] <= -15.499999999999998 then
        begin
            if features[177] <= -5522.4999999999991 then
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0029509993867873202;
                end
                else
                begin
                    if features[128] <= -23.499999999999996 then
                    begin
                        Result := -0.010666706532212022;
                    end
                    else
                    begin
                        if features[82] <= -99541.499999999985 then
                        begin
                            Result := 0.0058595722675143938;
                        end
                        else
                        begin
                            Result := -0.0056169195814106086;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[186] <= 94.833332061767592 then
                begin
                    Result := 0.0015522597165154692;
                end
                else
                begin
                    Result := 0.032981247811333901;
                end;
            end;
        end
        else
        begin
            if features[188] <= -4387.4999999999991 then
            begin
                Result := 0.0015774351864809367;
            end
            else
            begin
                Result := -0.0028205791709179674;
            end;
        end;
    end
    else
    begin
        if features[193] <= 584.50000000000011 then
        begin
            Result := 0.015444383509343693;
        end
        else
        begin
            if features[177] <= -8921.4999999999982 then
            begin
                if features[186] <= -33.749999999999993 then
                begin
                    if features[191] <= -6826.4999999999991 then
                    begin
                        Result := -0.0043305207550925371;
                    end
                    else
                    begin
                        Result := 0.026258022926208303;
                    end;
                end
                else
                begin
                    Result := 0.025860406139155752;
                end;
            end
            else
            begin
                if features[191] <= -6152.4999999999991 then
                begin
                    Result := -0.0077168296737983397;
                end
                else
                begin
                    if features[179] <= -6542.4999999999991 then
                    begin
                        Result := 0.018208475400667775;
                    end
                    else
                    begin
                        Result := -0.0063417843472036639;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_182(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.026477058935218095;
    end
    else
    begin
        if features[199] <= 223.50000000000003 then
        begin
            if features[176] <= -9156.4999999999982 then
            begin
                if features[189] <= -4970.4999999999991 then
                begin
                    Result := -0.0079470954618273259;
                end
                else
                begin
                    Result := 0.0022751182218560431;
                end;
            end
            else
            begin
                if features[189] <= -6876.4999999999991 then
                begin
                    if features[175] <= -3197.9999999999995 then
                    begin
                        Result := -0.0025692961998747895;
                    end
                    else
                    begin
                        if features[184] <= -2023.4999999999998 then
                        begin
                            Result := 0.064836439622912884;
                        end
                        else
                        begin
                            Result := 0.013682553220092234;
                        end;
                    end;
                end
                else
                begin
                    if features[164] <= -459468399.99999994 then
                    begin
                        Result := -0.015831894745262289;
                    end
                    else
                    begin
                        Result := -0.00020780722173855903;
                    end;
                end;
            end;
        end
        else
        begin
            if features[193] <= -352.49999999999994 then
            begin
                Result := 0.025996298917512851;
            end
            else
            begin
                if features[195] <= -5950.4999999999991 then
                begin
                    if features[108] <= -186.49999999999997 then
                    begin
                        if features[190] <= 3702.5000000000005 then
                        begin
                            Result := -0.020668927890084773;
                        end
                        else
                        begin
                            Result := 0.027337169971557856;
                        end;
                    end
                    else
                    begin
                        Result := -0.00072406794913690731;
                    end;
                end
                else
                begin
                    if features[163] <= -85013479.999999985 then
                    begin
                        Result := 0.01085875973163937;
                    end
                    else
                    begin
                        if features[190] <= 2732.0000000000005 then
                        begin
                            Result := 0.002769084359042604;
                        end
                        else
                        begin
                            Result := -0.011864738054880104;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_183(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1547.4999999999998 then
    begin
        Result := -0.018863560985228189;
    end
    else
    begin
        if features[66] <= 1165.0000000000002 then
        begin
            if features[90] <= 3.5000000000000004 then
            begin
                if features[194] <= -3104.4999999999995 then
                begin
                    if features[164] <= -264356407.99999997 then
                    begin
                        if features[174] <= -3442.9999999999995 then
                        begin
                            Result := -0.0077102421801443751;
                        end
                        else
                        begin
                            Result := 0.05806257530044006;
                        end;
                    end
                    else
                    begin
                        if features[193] <= -1736.4999999999998 then
                        begin
                            if features[188] <= -5207.4999999999991 then
                            begin
                                if features[171] <= 6.5000000000000009 then
                                begin
                                    if features[95] <= -16015753.499999998 then
                                    begin
                                        Result := 0.003919896457427679;
                                    end
                                    else
                                    begin
                                        Result := 0.076932477169530777;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.01401102828249942;
                                end;
                            end
                            else
                            begin
                                Result := -0.00077032907616535716;
                            end;
                        end
                        else
                        begin
                            Result := -0.00038396682244758016;
                        end;
                    end;
                end
                else
                begin
                    if features[173] <= -6961.4999999999991 then
                    begin
                        if features[202] <= -519.49999999999989 then
                        begin
                            Result := -0.0010693804568597681;
                        end
                        else
                        begin
                            Result := 0.082128374777978561;
                        end;
                    end
                    else
                    begin
                        Result := 0.0094918518453635248;
                    end;
                end;
            end
            else
            begin
                if features[109] <= 53.500000000000007 then
                begin
                    Result := 0.0014258745299936474;
                end
                else
                begin
                    if features[179] <= -6881.4999999999991 then
                    begin
                        Result := 0.0042636223735289195;
                    end
                    else
                    begin
                        Result := 0.020808706930004632;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.012860893700311338;
        end;
    end;
end;

function settled_top2_residual_tree_184(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= -1080.4999999999998 then
    begin
        Result := -0.014306910801244486;
    end
    else
    begin
        if features[178] <= 539.50000000000011 then
        begin
            if features[109] <= 32.500000000000007 then
            begin
                if features[184] <= 110.50000000000001 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        if features[176] <= -5617.4999999999991 then
                        begin
                            if features[0] <= 17421.000000000004 then
                            begin
                                if features[184] <= -1020.4999999999999 then
                                begin
                                    Result := 0.058005050564202187;
                                end
                                else
                                begin
                                    Result := 0.013849047839778347;
                                end;
                            end
                            else
                            begin
                                if features[194] <= -6302.4999999999991 then
                                begin
                                    Result := -0.0048411725772215192;
                                end
                                else
                                begin
                                    if features[148] <= 1147.0000000000002 then
                                    begin
                                        Result := 0.0037381282582253624;
                                    end
                                    else
                                    begin
                                        Result := 0.013892823248031356;
                                    end;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[193] <= -1277.4999999999998 then
                            begin
                                Result := 0.025084066760599391;
                            end
                            else
                            begin
                                Result := -0.0085936959610844865;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.00095334190254382518;
                    end;
                end
                else
                begin
                    Result := -0.014210904766076943;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[145] <= 387.50000000000006 then
                    begin
                        Result := 0.016086512290555369;
                    end
                    else
                    begin
                        Result := 0.060799532407107205;
                    end;
                end
                else
                begin
                    if features[200] <= -5784.4999999999991 then
                    begin
                        Result := 0.015007082712153586;
                    end
                    else
                    begin
                        Result := 0.0018374739535809226;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.0028593544684009484;
        end;
    end;
end;

function settled_top2_residual_tree_185(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.015719114173102424;
    end
    else
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.024898156079071372;
        end
        else
        begin
            if features[202] <= 794.50000000000011 then
            begin
                if features[189] <= -6571.4999999999991 then
                begin
                    if features[184] <= -1814.4999999999998 then
                    begin
                        Result := 0.032574883642036298;
                    end
                    else
                    begin
                        if features[174] <= -6971.4999999999991 then
                        begin
                            Result := 0.0024824716370042085;
                        end
                        else
                        begin
                            Result := 0.043814169351784102;
                        end;
                    end;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        if features[185] <= -190.74999999999997 then
                        begin
                            if features[174] <= -8119.4999999999991 then
                            begin
                                Result := 0.00089429445877678535;
                            end
                            else
                            begin
                                Result := -0.013359082917215007;
                            end;
                        end
                        else
                        begin
                            if features[184] <= -362.49999999999994 then
                            begin
                                Result := 0.017115949964762619;
                            end
                            else
                            begin
                                if features[109] <= 13.500000000000002 then
                                begin
                                    Result := -0.0091009682731440795;
                                end
                                else
                                begin
                                    if features[184] <= 434.50000000000006 then
                                    begin
                                        Result := 0.015165906743921601;
                                    end
                                    else
                                    begin
                                        Result := -0.0039046698649177025;
                                    end;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[173] <= -4832.4999999999991 then
                        begin
                            Result := -0.00028648778051810808;
                        end
                        else
                        begin
                            if features[190] <= -676.49999999999989 then
                            begin
                                Result := -0.0038176308833188658;
                            end
                            else
                            begin
                                Result := 0.011257790643342206;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.01306506059814542;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_186(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[66] <= 1218.0000000000002 then
    begin
        if features[182] <= -4004.4999999999995 then
        begin
            if features[201] <= -4006.4999999999995 then
            begin
                if features[150] <= -12.499999999999998 then
                begin
                    if features[176] <= -5933.4999999999991 then
                    begin
                        if features[174] <= -9070.4999999999982 then
                        begin
                            if features[164] <= -175048263.99999997 then
                            begin
                                Result := -0.00045608075856860651;
                            end
                            else
                            begin
                                if features[129] <= -19759.499999999996 then
                                begin
                                    Result := -0.018523741768068886;
                                end
                                else
                                begin
                                    Result := 0.026344347634340973;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.0026563735966579072;
                        end;
                    end
                    else
                    begin
                        Result := -0.0051558207902353435;
                    end;
                end
                else
                begin
                    if features[117] <= -561.49999999999989 then
                    begin
                        Result := -0.011547765256672567;
                    end
                    else
                    begin
                        if features[191] <= -4398.4999999999991 then
                        begin
                            Result := -0.0013013556795902267;
                        end
                        else
                        begin
                            Result := 0.0043093920773177594;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[181] <= -231.49999999999997 then
                begin
                    if features[110] <= -33.499999999999993 then
                    begin
                        if features[200] <= -3774.4999999999995 then
                        begin
                            Result := 0.016768572817043716;
                        end
                        else
                        begin
                            if features[174] <= -3442.9999999999995 then
                            begin
                                Result := 0.0035299689375480866;
                            end
                            else
                            begin
                                Result := 0.060892185073677524;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.060818704931254956;
                    end;
                end
                else
                begin
                    Result := -0.00062122441141761946;
                end;
            end;
        end
        else
        begin
            Result := -0.0093241718041875612;
        end;
    end
    else
    begin
        Result := -0.014984635785707674;
    end;
end;

function settled_top2_residual_tree_187(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[92] <= 1.5000000000000002 then
    begin
        if features[188] <= -3966.4999999999995 then
        begin
            if features[189] <= -4389.4999999999991 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0030242222820761719;
                end
                else
                begin
                    Result := -0.001418675634833589;
                end;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    Result := -0.0069069844568661488;
                end
                else
                begin
                    if features[199] <= -187.49999999999997 then
                    begin
                        if features[170] <= 1.0000000180025095E-35 then
                        begin
                            if features[173] <= -7140.4999999999991 then
                            begin
                                Result := 0.054625156421934155;
                            end
                            else
                            begin
                                Result := 0.0068162826729831873;
                            end;
                        end
                        else
                        begin
                            Result := -0.0055527268608548987;
                        end;
                    end
                    else
                    begin
                        Result := 0.012583582971270975;
                    end;
                end;
            end;
        end
        else
        begin
            if features[174] <= -6429.4999999999991 then
            begin
                if features[171] <= 3.5000000000000004 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.028185305295271759;
                    end
                    else
                    begin
                        Result := 0.00059796573211531531;
                    end;
                end
                else
                begin
                    Result := -0.0029511574437417424;
                end;
            end
            else
            begin
                if features[169] <= 1.5000000000000002 then
                begin
                    if features[90] <= 1.0000000180025095E-35 then
                    begin
                        if features[189] <= -4016.4999999999995 then
                        begin
                            Result := -0.018381604784710442;
                        end
                        else
                        begin
                            Result := 0.053021872345436316;
                        end;
                    end
                    else
                    begin
                        Result := -0.025294184214544792;
                    end;
                end
                else
                begin
                    Result := -0.00012307392486353132;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.0057355439255953435;
    end;
end;

function settled_top2_residual_tree_188(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[126] <= -1.0000000180025095E-35 then
    begin
        if features[96] <= -71800303.999999985 then
        begin
            Result := 0.020061830995504057;
        end
        else
        begin
            if features[174] <= -8737.4999999999982 then
            begin
                if features[193] <= -158.49999999999997 then
                begin
                    Result := 0.016254048214478085;
                end
                else
                begin
                    Result := 0.00096763947776717289;
                end;
            end
            else
            begin
                Result := 0.00014129282018259307;
            end;
        end;
    end
    else
    begin
        if features[192] <= -6085.4999999999991 then
        begin
            if features[47] <= 9757.5000000000018 then
            begin
                if features[189] <= -4619.4999999999991 then
                begin
                    Result := -0.0069122898971355849;
                end
                else
                begin
                    Result := 0.0039421166606835329;
                end;
            end
            else
            begin
                Result := 0.0014511773102999729;
            end;
        end
        else
        begin
            if features[183] <= -8861.4999999999982 then
            begin
                Result := 0.013734515426940761;
            end
            else
            begin
                if features[186] <= -302.83332824707026 then
                begin
                    if features[174] <= -8046.4999999999991 then
                    begin
                        Result := 0.0046577203886251561;
                    end
                    else
                    begin
                        Result := -0.0077144511946206891;
                    end;
                end
                else
                begin
                    if features[184] <= -378.49999999999994 then
                    begin
                        if features[186] <= -86.833332061767564 then
                        begin
                            if features[184] <= -1302.4999999999998 then
                            begin
                                Result := 0.040034212325306628;
                            end
                            else
                            begin
                                Result := 0.0034124780842266552;
                            end;
                        end
                        else
                        begin
                            Result := 0.029056555076918268;
                        end;
                    end
                    else
                    begin
                        if features[186] <= -38.833333969116204 then
                        begin
                            Result := -0.0045032522430927891;
                        end
                        else
                        begin
                            Result := 0.0017409980802161021;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_189(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[0] <= -119012.99999999999 then
    begin
        if features[202] <= 1.0000000180025095E-35 then
        begin
            if features[184] <= -554.49999999999989 then
            begin
                Result := 0.01744755759239585;
            end
            else
            begin
                Result := -0.0073146924902661205;
            end;
        end
        else
        begin
            Result := 0.013934901475559348;
        end;
    end
    else
    begin
        if features[164] <= -110756839.99999999 then
        begin
            if features[195] <= -4648.4999999999991 then
            begin
                if features[105] <= 1.0000000180025095E-35 then
                begin
                    if features[37] <= 2.5000000000000004 then
                    begin
                        if features[148] <= -235.49999999999997 then
                        begin
                            Result := -0.010152136812484329;
                        end
                        else
                        begin
                            if features[184] <= -689.49999999999989 then
                            begin
                                if features[109] <= -508.49999999999994 then
                                begin
                                    Result := 0.01630270979810005;
                                end
                                else
                                begin
                                    Result := 0.098076944823341838;
                                end;
                            end
                            else
                            begin
                                Result := 0.0028317673818183103;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[202] <= -312.49999999999994 then
                        begin
                            Result := -0.0077284759878701523;
                        end
                        else
                        begin
                            if features[191] <= -4398.4999999999991 then
                            begin
                                Result := -0.0015027397471989742;
                            end
                            else
                            begin
                                Result := 0.014023452728619729;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[85] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0038833070727710239;
                    end
                    else
                    begin
                        Result := -0.0086409218297388828;
                    end;
                end;
            end
            else
            begin
                if features[182] <= -4520.4999999999991 then
                begin
                    Result := 0.0050107457780838357;
                end
                else
                begin
                    Result := -0.0054230880482704713;
                end;
            end;
        end
        else
        begin
            Result := 0.0012263559239041942;
        end;
    end;
end;

function settled_top2_residual_tree_190(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.026301099381497564;
    end
    else
    begin
        if features[186] <= -756.49999999999989 then
        begin
            if features[174] <= -8119.4999999999991 then
            begin
                Result := 0.0028174675345517498;
            end
            else
            begin
                Result := -0.011615628534256382;
            end;
        end
        else
        begin
            if features[176] <= -9628.4999999999982 then
            begin
                if features[13] <= -70486.999999999985 then
                begin
                    Result := 0.03572988699812496;
                end
                else
                begin
                    Result := -0.0042414846911373637;
                end;
            end
            else
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[191] <= -4433.4999999999991 then
                    begin
                        Result := 0.0010586288347453115;
                    end
                    else
                    begin
                        if features[176] <= -7412.4999999999991 then
                        begin
                            Result := -0.014325395754853119;
                        end
                        else
                        begin
                            if features[108] <= -260.49999999999994 then
                            begin
                                Result := 0.0015510046595918715;
                            end
                            else
                            begin
                                if features[196] <= -732.49999999999989 then
                                begin
                                    Result := 0.03666130327015265;
                                end
                                else
                                begin
                                    Result := 0.0097094045777391235;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[190] <= -143.49999999999997 then
                    begin
                        Result := 0.00078999484469218146;
                    end
                    else
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            if features[90] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.054061894715451801;
                            end
                            else
                            begin
                                Result := -0.025822551570020925;
                            end;
                        end
                        else
                        begin
                            if features[148] <= -1480.4999999999998 then
                            begin
                                Result := 0.030894413760693101;
                            end
                            else
                            begin
                                Result := -0.002380856992789851;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_191(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[66] <= 1165.0000000000002 then
    begin
        if features[90] <= 2.5000000000000004 then
        begin
            if features[81] <= -19287.499999999996 then
            begin
                Result := -0.0045327228118566196;
            end
            else
            begin
                if features[189] <= -7383.9999999999991 then
                begin
                    if features[194] <= -4725.4999999999991 then
                    begin
                        Result := 0.010048857872650065;
                    end
                    else
                    begin
                        Result := 0.057053728695366082;
                    end;
                end
                else
                begin
                    if features[188] <= -3966.4999999999995 then
                    begin
                        if features[171] <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.0041744594883673875;
                        end
                        else
                        begin
                            if features[151] <= -14.499999999999998 then
                            begin
                                if features[173] <= -4418.9999999999991 then
                                begin
                                    Result := 0.0037772988922117343;
                                end
                                else
                                begin
                                    Result := 0.02321355205986135;
                                end;
                            end
                            else
                            begin
                                if features[189] <= -4176.4999999999991 then
                                begin
                                    Result := -0.0026086397252700491;
                                end
                                else
                                begin
                                    Result := 0.0087664124095759837;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[188] <= -3812.4999999999995 then
                        begin
                            Result := -0.011237118595490085;
                        end
                        else
                        begin
                            if features[200] <= -5088.4999999999991 then
                            begin
                                if features[177] <= -7459.4999999999991 then
                                begin
                                    Result := 0.0031497681272801103;
                                end
                                else
                                begin
                                    if features[190] <= -1335.9999999999998 then
                                    begin
                                        Result := 0.0088223005991660483;
                                    end
                                    else
                                    begin
                                        Result := 0.072504129028197237;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.0034708714658287926;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.0021091477738933409;
        end;
    end
    else
    begin
        Result := -0.012773788876557612;
    end;
end;

function settled_top2_residual_tree_192(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[66] <= 1218.0000000000002 then
    begin
        if features[90] <= 12.500000000000002 then
        begin
            if features[173] <= -6091.4999999999991 then
            begin
                if features[154] <= 40.500000000000007 then
                begin
                    if features[166] <= -16113090.499999998 then
                    begin
                        if features[25] <= 3.5000000000000004 then
                        begin
                            Result := 0.020416501698434453;
                        end
                        else
                        begin
                            Result := -0.0081951762591730964;
                        end;
                    end
                    else
                    begin
                        Result := 0.0012594543500312457;
                    end;
                end
                else
                begin
                    if features[147] <= -617.49999999999989 then
                    begin
                        Result := 0.028922761866646596;
                    end
                    else
                    begin
                        Result := -0.0037270496636677588;
                    end;
                end;
            end
            else
            begin
                if features[108] <= 112.50000000000001 then
                begin
                    if features[69] <= 16.500000000000004 then
                    begin
                        Result := -0.0046867517580973439;
                    end
                    else
                    begin
                        Result := 0.0027059077169048237;
                    end;
                end
                else
                begin
                    if features[176] <= -8251.4999999999982 then
                    begin
                        Result := -0.0076693399568160889;
                    end
                    else
                    begin
                        if features[190] <= -1067.4999999999998 then
                        begin
                            if features[42] <= 418.50000000000006 then
                            begin
                                Result := -0.01075372490256093;
                            end
                            else
                            begin
                                Result := 0.029490191296011249;
                            end;
                        end
                        else
                        begin
                            if features[164] <= -135192759.99999997 then
                            begin
                                Result := 0.040476695352023445;
                            end
                            else
                            begin
                                Result := 0.012808211868121665;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[123] <= 112.00000000000001 then
            begin
                Result := 0.0043088261975445102;
            end
            else
            begin
                Result := 0.03747971897583495;
            end;
        end;
    end
    else
    begin
        Result := -0.014779683575981859;
    end;
end;

function settled_top2_residual_tree_193(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[92] <= 1.5000000000000002 then
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[172] <= 3.5000000000000004 then
            begin
                Result := 0.00025418206890571895;
            end
            else
            begin
                Result := 0.012232337485914291;
            end;
        end
        else
        begin
            if features[148] <= 1084.5000000000002 then
            begin
                if features[174] <= -5958.4999999999991 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        if features[164] <= -175048263.99999997 then
                        begin
                            Result := -0.0092018842343385056;
                        end
                        else
                        begin
                            if features[175] <= -890.49999999999989 then
                            begin
                                if features[175] <= -1071.4999999999998 then
                                begin
                                    if features[27] <= -5505.4999999999991 then
                                    begin
                                        Result := 0.02339946231975229;
                                    end
                                    else
                                    begin
                                        Result := 0.00096584500418067177;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.035349034292495495;
                                end;
                            end
                            else
                            begin
                                if features[175] <= -863.49999999999989 then
                                begin
                                    Result := -0.025430114316163013;
                                end
                                else
                                begin
                                    Result := -0.0017848375789954283;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.011980638477195502;
                    end;
                end
                else
                begin
                    if features[199] <= -447.49999999999994 then
                    begin
                        Result := -0.010973770970577747;
                    end
                    else
                    begin
                        if features[171] <= 1.5000000000000002 then
                        begin
                            Result := -0.00880470732610532;
                        end
                        else
                        begin
                            if features[191] <= -4156.4999999999991 then
                            begin
                                Result := 0.0089375057510156525;
                            end
                            else
                            begin
                                Result := 0.041755384429085905;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.014152113378288278;
            end;
        end;
    end
    else
    begin
        Result := 0.0056633603640581578;
    end;
end;

function settled_top2_residual_tree_194(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[182] <= -3905.4999999999995 then
    begin
        if features[198] <= -3806.4999999999995 then
        begin
            if features[166] <= 118461356.00000001 then
            begin
                if features[149] <= -819.99999999999989 then
                begin
                    Result := -0.02592693217287206;
                end
                else
                begin
                    if features[178] <= 539.50000000000011 then
                    begin
                        if features[186] <= 16.166666984558109 then
                        begin
                            if features[184] <= 52.500000000000007 then
                            begin
                                Result := 0.00041639239447705261;
                            end
                            else
                            begin
                                Result := -0.015157889372809291;
                            end;
                        end
                        else
                        begin
                            if features[171] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.020393748027632264;
                            end
                            else
                            begin
                                if features[196] <= 379.50000000000006 then
                                begin
                                    if features[179] <= -5925.4999999999991 then
                                    begin
                                        Result := 0.00019421515494530918;
                                    end
                                    else
                                    begin
                                        Result := 0.016939627193666922;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.016076936369753159;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0025683123252080329;
                    end;
                end;
            end
            else
            begin
                if features[198] <= -5338.4999999999991 then
                begin
                    Result := -0.013193660605455666;
                end
                else
                begin
                    Result := 0.00063332878576306253;
                end;
            end;
        end
        else
        begin
            if features[193] <= -1181.4999999999998 then
            begin
                Result := 0.055265687956445979;
            end
            else
            begin
                if features[177] <= -6270.4999999999991 then
                begin
                    if features[155] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0096443076695236236;
                    end
                    else
                    begin
                        Result := 0.034128399684583199;
                    end;
                end
                else
                begin
                    Result := -5.3097134932711878E-05;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.010342778783192187;
    end;
end;

function settled_top2_residual_tree_195(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1616.4999999999998 then
    begin
        Result := -0.018241923514794724;
    end
    else
    begin
        if features[194] <= -3013.4999999999995 then
        begin
            if features[179] <= -4083.4999999999995 then
            begin
                if features[178] <= 539.50000000000011 then
                begin
                    if features[110] <= 32.500000000000007 then
                    begin
                        if features[181] <= 140.50000000000003 then
                        begin
                            if features[195] <= -5521.4999999999991 then
                            begin
                                Result := -0.0020380339627345573;
                            end
                            else
                            begin
                                if features[175] <= 2451.5000000000005 then
                                begin
                                    if features[180] <= -7489.4999999999991 then
                                    begin
                                        Result := 0.0055514020962965814;
                                    end
                                    else
                                    begin
                                        Result := -0.00049704631618346267;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.015965651112424251;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.015161836491192385;
                        end;
                    end
                    else
                    begin
                        if features[171] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.018546483662389979;
                        end
                        else
                        begin
                            Result := 0.0025859903686367954;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0029248838481683494;
                end;
            end
            else
            begin
                if features[108] <= 86.500000000000014 then
                begin
                    Result := -0.01148588220702227;
                end
                else
                begin
                    Result := 0.047419345081467688;
                end;
            end;
        end
        else
        begin
            if features[173] <= -6467.4999999999991 then
            begin
                if features[200] <= -3202.4999999999995 then
                begin
                    if features[193] <= -171.49999999999997 then
                    begin
                        Result := 0.12055121218233503;
                    end
                    else
                    begin
                        Result := 0.020107546233026075;
                    end;
                end
                else
                begin
                    Result := 0.0055514257879842911;
                end;
            end
            else
            begin
                Result := 0.0046718922315393107;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_196(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.026062908972664375;
    end
    else
    begin
        if features[202] <= 794.50000000000011 then
        begin
            if features[176] <= -9527.4999999999982 then
            begin
                if features[148] <= 1186.5000000000002 then
                begin
                    Result := -0.0057151499622514184;
                end
                else
                begin
                    Result := 0.014526722860386377;
                end;
            end
            else
            begin
                if features[108] <= -100.49999999999999 then
                begin
                    if features[177] <= -7497.4999999999991 then
                    begin
                        if features[198] <= -4732.4999999999991 then
                        begin
                            Result := -0.00033113663097939313;
                        end
                        else
                        begin
                            Result := 0.0086609997039405282;
                        end;
                    end
                    else
                    begin
                        if features[171] <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.011177735962189139;
                        end
                        else
                        begin
                            Result := -0.0018432604427304679;
                        end;
                    end;
                end
                else
                begin
                    if features[184] <= -208.49999999999997 then
                    begin
                        if features[186] <= -38.833333969116204 then
                        begin
                            Result := 0.0068706813219380812;
                        end
                        else
                        begin
                            if features[186] <= 106.16666793823244 then
                            begin
                                Result := 0.038488511668020815;
                            end
                            else
                            begin
                                Result := -0.0088561715231274592;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[197] <= -5650.4999999999991 then
                        begin
                            Result := 0.0055806807159995376;
                        end
                        else
                        begin
                            if features[176] <= -7488.4999999999991 then
                            begin
                                if features[202] <= -104.49999999999999 then
                                begin
                                    Result := -0.010153948572544031;
                                end
                                else
                                begin
                                    Result := -0.00044411858342404526;
                                end;
                            end
                            else
                            begin
                                Result := 0.0025380785277771844;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.011755331534974581;
        end;
    end;
end;

function settled_top2_residual_tree_197(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[119] <= -1183.4999999999998 then
    begin
        Result := -0.018777574748391441;
    end
    else
    begin
        if features[66] <= 427.50000000000006 then
        begin
            if features[199] <= 484.50000000000006 then
            begin
                if features[173] <= -5604.4999999999991 then
                begin
                    Result := 0.00062896633727022402;
                end
                else
                begin
                    if features[173] <= -4956.9999999999991 then
                    begin
                        Result := -0.0071016844278486329;
                    end
                    else
                    begin
                        if features[25] <= 2.5000000000000004 then
                        begin
                            Result := -0.0025954501225499602;
                        end
                        else
                        begin
                            Result := 0.0095081544847238526;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[196] <= 213.50000000000003 then
                begin
                    Result := 0.036256156918148465;
                end
                else
                begin
                    if features[177] <= -6686.4999999999991 then
                    begin
                        if features[198] <= -4062.4999999999995 then
                        begin
                            if features[186] <= -33.749999999999993 then
                            begin
                                if features[191] <= -5443.4999999999991 then
                                begin
                                    Result := -0.0037009320458077678;
                                end
                                else
                                begin
                                    Result := 0.027749197219759492;
                                end;
                            end
                            else
                            begin
                                if features[178] <= 705.50000000000011 then
                                begin
                                    Result := 0.020445972348025657;
                                end
                                else
                                begin
                                    Result := 0.0023213295997340237;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.024515077464205948;
                        end;
                    end
                    else
                    begin
                        Result := -0.0064181021620217001;
                    end;
                end;
            end;
        end
        else
        begin
            if features[189] <= -4721.4999999999991 then
            begin
                Result := -0.012683878850799616;
            end
            else
            begin
                if features[175] <= 671.50000000000011 then
                begin
                    Result := 0.020736095578986459;
                end
                else
                begin
                    Result := -0.0081915657724249222;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_198(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1547.4999999999998 then
    begin
        Result := -0.018298248606487655;
    end
    else
    begin
        if features[66] <= 1165.0000000000002 then
        begin
            if features[90] <= 12.500000000000002 then
            begin
                if features[173] <= -5591.4999999999991 then
                begin
                    Result := 0.00069219401793789307;
                end
                else
                begin
                    if features[174] <= -5719.4999999999991 then
                    begin
                        if features[189] <= -4016.4999999999995 then
                        begin
                            if features[189] <= -4176.4999999999991 then
                            begin
                                if features[92] <= 2.5000000000000004 then
                                begin
                                    Result := -0.0074163881003437016;
                                end
                                else
                                begin
                                    Result := 0.023723005274636933;
                                end;
                            end
                            else
                            begin
                                if features[173] <= -4911.4999999999991 then
                                begin
                                    Result := -0.0016577834010861104;
                                end
                                else
                                begin
                                    Result := 0.019354949671270057;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[173] <= -5022.4999999999991 then
                            begin
                                Result := -0.024244241452418394;
                            end
                            else
                            begin
                                Result := 0.0020646135163518535;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[185] <= 26.166666984558109 then
                        begin
                            Result := 0.00010499508969297541;
                        end
                        else
                        begin
                            if features[195] <= -5450.4999999999991 then
                            begin
                                Result := 0.0415217213875438;
                            end
                            else
                            begin
                                Result := 0.0077171367137702064;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[123] <= 96.000000000000014 then
                begin
                    Result := 0.0043666653483705586;
                end
                else
                begin
                    if features[176] <= -7793.4999999999991 then
                    begin
                        Result := 0.061002136826120795;
                    end
                    else
                    begin
                        Result := 0.014232874859941118;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.012151811182882897;
        end;
    end;
end;

function settled_top2_residual_tree_199(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[182] <= -3799.4999999999995 then
    begin
        if features[198] <= -3948.4999999999995 then
        begin
            if features[164] <= -384867039.99999994 then
            begin
                if features[188] <= -8107.4999999999991 then
                begin
                    Result := 0.027539585994229794;
                end
                else
                begin
                    if features[195] <= -4648.4999999999991 then
                    begin
                        Result := -0.016037398414203246;
                    end
                    else
                    begin
                        Result := 0.0081717885917624265;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -4387.4999999999991 then
                begin
                    if features[188] <= -5423.4999999999991 then
                    begin
                        Result := -0.0013558306770454773;
                    end
                    else
                    begin
                        if features[189] <= -4176.4999999999991 then
                        begin
                            Result := 0.002066622949663807;
                        end
                        else
                        begin
                            if features[171] <= 1.5000000000000002 then
                            begin
                                Result := -0.0069140632346777857;
                            end
                            else
                            begin
                                Result := 0.017973147454259;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[173] <= -4869.4999999999991 then
                    begin
                        Result := -0.0048089407212260253;
                    end
                    else
                    begin
                        if features[173] <= -4748.9999999999991 then
                        begin
                            Result := 0.013942625661032465;
                        end
                        else
                        begin
                            Result := -0.0016584690433980084;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[192] <= -6374.4999999999991 then
            begin
                Result := 0.039207134679950476;
            end
            else
            begin
                if features[193] <= -1211.4999999999998 then
                begin
                    Result := 0.041082758955687304;
                end
                else
                begin
                    if features[27] <= -4783.4999999999991 then
                    begin
                        Result := 0.014912223509168807;
                    end
                    else
                    begin
                        Result := -0.00028699421458324987;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.011003091119707226;
    end;
end;

function settled_top2_residual_tree_200(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[145] <= -734.49999999999989 then
    begin
        Result := 0.013259891571587966;
    end
    else
    begin
        if features[183] <= -8861.4999999999982 then
        begin
            if features[192] <= -5798.4999999999991 then
            begin
                Result := 0.0010616522647126326;
            end
            else
            begin
                if features[179] <= -7837.4999999999991 then
                begin
                    Result := 0.030609431212912187;
                end
                else
                begin
                    Result := 0.0045670609530540926;
                end;
            end;
        end
        else
        begin
            if features[90] <= -1.4999999999999998 then
            begin
                Result := -0.0051908746903029266;
            end
            else
            begin
                if features[47] <= 9757.5000000000018 then
                begin
                    if features[175] <= -733.49999999999989 then
                    begin
                        if features[175] <= -864.49999999999989 then
                        begin
                            if features[198] <= -5005.4999999999991 then
                            begin
                                Result := -0.0055502454268448447;
                            end
                            else
                            begin
                                Result := 0.0012303229865355191;
                            end;
                        end
                        else
                        begin
                            Result := -0.014844465811965291;
                        end;
                    end
                    else
                    begin
                        if features[169] <= 1.5000000000000002 then
                        begin
                            Result := -0.0011860076184475364;
                        end
                        else
                        begin
                            if features[181] <= 662.50000000000011 then
                            begin
                                Result := 0.0080849973619070738;
                            end
                            else
                            begin
                                Result := -0.0067394404391456558;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[192] <= -7065.4999999999991 then
                    begin
                        Result := 0.017540617435701015;
                    end
                    else
                    begin
                        if features[189] <= -4016.4999999999995 then
                        begin
                            Result := 0.0028366572448719945;
                        end
                        else
                        begin
                            if features[190] <= -64.499999999999986 then
                            begin
                                Result := -0.022311608136597074;
                            end
                            else
                            begin
                                Result := -0.0011014496484246616;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_201(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[15] <= -5959789.4999999991 then
    begin
        if features[82] <= -210.49999999999997 then
        begin
            if features[73] <= 121.50000000000001 then
            begin
                if features[39] <= 1375.5000000000002 then
                begin
                    Result := -0.0059700499010139664;
                end
                else
                begin
                    if features[163] <= -135878623.99999997 then
                    begin
                        Result := 0.0026788033758072161;
                    end
                    else
                    begin
                        Result := 0.044332784701840947;
                    end;
                end;
            end
            else
            begin
                Result := -0.001540364964087269;
            end;
        end
        else
        begin
            Result := 0.0077013984175477619;
        end;
    end
    else
    begin
        if features[90] <= 11.500000000000002 then
        begin
            if features[164] <= -217627575.99999997 then
            begin
                if features[201] <= -4652.4999999999991 then
                begin
                    Result := -0.0094426847647656256;
                end
                else
                begin
                    if features[199] <= -524.49999999999989 then
                    begin
                        Result := -0.012131607381909307;
                    end
                    else
                    begin
                        if features[28] <= -7454.4999999999991 then
                        begin
                            Result := 0.048012375264215389;
                        end
                        else
                        begin
                            Result := 0.0018940198426849219;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[178] <= -59.499999999999993 then
                begin
                    if features[194] <= -6022.4999999999991 then
                    begin
                        if features[108] <= 145.50000000000003 then
                        begin
                            Result := -0.0055881330624833227;
                        end
                        else
                        begin
                            Result := 0.026986208668606099;
                        end;
                    end
                    else
                    begin
                        if features[190] <= 740.50000000000011 then
                        begin
                            Result := 0.0016874844859256473;
                        end
                        else
                        begin
                            Result := 0.0098589084970275073;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0021778345904132491;
                end;
            end;
        end
        else
        begin
            Result := 0.0055967156865371738;
        end;
    end;
end;

function settled_top2_residual_tree_202(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[189] <= -6408.4999999999991 then
    begin
        if features[184] <= -1370.4999999999998 then
        begin
            if features[175] <= -2513.4999999999995 then
            begin
                Result := -0.00049167867896735907;
            end
            else
            begin
                if features[200] <= -4036.4999999999995 then
                begin
                    Result := 0.030382202333359296;
                end
                else
                begin
                    Result := 0.094639074811660201;
                end;
            end;
        end
        else
        begin
            Result := 0.0023815963962428876;
        end;
    end
    else
    begin
        if features[186] <= -756.49999999999989 then
        begin
            Result := -0.0075227197959261667;
        end
        else
        begin
            if features[190] <= -1164.4999999999998 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    Result := 0.007209326000986855;
                end
                else
                begin
                    Result := -0.0079894203355588955;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[190] <= -533.49999999999989 then
                    begin
                        Result := 0.0092421033179029485;
                    end
                    else
                    begin
                        if features[193] <= -1150.4999999999998 then
                        begin
                            Result := 0.025229527916374464;
                        end
                        else
                        begin
                            Result := -0.0061021152821565706;
                        end;
                    end;
                end
                else
                begin
                    if features[173] <= -4956.9999999999991 then
                    begin
                        if features[173] <= -5591.4999999999991 then
                        begin
                            Result := 0.0018312954842265962;
                        end
                        else
                        begin
                            if features[174] <= -5958.4999999999991 then
                            begin
                                if features[189] <= -4016.4999999999995 then
                                begin
                                    Result := -0.0064490667287489499;
                                end
                                else
                                begin
                                    Result := -0.023998957896625445;
                                end;
                            end
                            else
                            begin
                                Result := 0.0045862385095921812;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0085255314024080889;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_203(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[175] <= -3013.9999999999995 then
    begin
        if features[13] <= 114202.50000000001 then
        begin
            if features[69] <= 1.5000000000000002 then
            begin
                Result := 0.011650500812670283;
            end
            else
            begin
                Result := -0.0082751958226685556;
            end;
        end
        else
        begin
            if features[75] <= 7.5000000000000009 then
            begin
                Result := 0.032360269056524331;
            end
            else
            begin
                Result := -0.0042354828746299948;
            end;
        end;
    end
    else
    begin
        if features[189] <= -6408.4999999999991 then
        begin
            if features[184] <= -1244.4999999999998 then
            begin
                if features[194] <= -5479.4999999999991 then
                begin
                    Result := 0.021161596253659508;
                end
                else
                begin
                    Result := 0.063950859441755228;
                end;
            end
            else
            begin
                Result := 0.0019717101021662453;
            end;
        end
        else
        begin
            if features[199] <= -1174.4999999999998 then
            begin
                Result := -0.012736320520629431;
            end
            else
            begin
                if features[191] <= -4433.4999999999991 then
                begin
                    if features[176] <= -5255.4999999999991 then
                    begin
                        if features[199] <= -473.49999999999994 then
                        begin
                            Result := -0.0053198031362254395;
                        end
                        else
                        begin
                            if features[173] <= -4911.4999999999991 then
                            begin
                                if features[181] <= -632.49999999999989 then
                                begin
                                    if features[194] <= -5958.4999999999991 then
                                    begin
                                        Result := -0.0042718517513463256;
                                    end
                                    else
                                    begin
                                        Result := 0.0064803726029862832;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.001179917436356007;
                                end;
                            end
                            else
                            begin
                                Result := 0.0072941571090186803;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0085130170454590266;
                    end;
                end
                else
                begin
                    Result := 0.0043262592059603606;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_204(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[185] <= -236.90000152587888 then
    begin
        if features[170] <= 4.5000000000000009 then
        begin
            if features[200] <= -5521.4999999999991 then
            begin
                Result := -0.0076674895406478108;
            end
            else
            begin
                if features[148] <= -1138.4999999999998 then
                begin
                    Result := -0.0042435140255221333;
                end
                else
                begin
                    Result := 0.0056248306071752154;
                end;
            end;
        end
        else
        begin
            if features[174] <= -8119.4999999999991 then
            begin
                Result := 0.0031178723393030464;
            end
            else
            begin
                Result := -0.010126083405894111;
            end;
        end;
    end
    else
    begin
        if features[184] <= -362.49999999999994 then
        begin
            if features[18] <= 8.5000000000000018 then
            begin
                Result := 0.018359276493445011;
            end
            else
            begin
                if features[186] <= -44.833333969116204 then
                begin
                    if features[184] <= -1302.4999999999998 then
                    begin
                        Result := 0.043035193408868647;
                    end
                    else
                    begin
                        Result := 0.0021498929198393592;
                    end;
                end
                else
                begin
                    Result := 0.040706046499920955;
                end;
            end;
        end
        else
        begin
            if features[108] <= -100.49999999999999 then
            begin
                Result := -0.0047454925199058168;
            end
            else
            begin
                if features[199] <= 124.50000000000001 then
                begin
                    if features[176] <= -7371.4999999999991 then
                    begin
                        Result := -0.0039603684111845401;
                    end
                    else
                    begin
                        if features[196] <= -654.49999999999989 then
                        begin
                            Result := 0.01764742142634327;
                        end
                        else
                        begin
                            Result := 0.0018651598698201739;
                        end;
                    end;
                end
                else
                begin
                    if features[27] <= -4259.4999999999991 then
                    begin
                        Result := 0.0070542937194126021;
                    end
                    else
                    begin
                        Result := -0.0038087447392460673;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_205(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[105] <= 1.0000000180025095E-35 then
    begin
        if features[122] <= -1216.4999999999998 then
        begin
            if features[171] <= 2.5000000000000004 then
            begin
                Result := -0.012863056342246338;
            end
            else
            begin
                Result := 0.0057992986247041084;
            end;
        end
        else
        begin
            if features[167] <= 1.5000000000000002 then
            begin
                Result := 0.00012967653461593657;
            end
            else
            begin
                if features[175] <= -772.49999999999989 then
                begin
                    Result := -0.001663138726324669;
                end
                else
                begin
                    Result := 0.0079787946441229156;
                end;
            end;
        end;
    end
    else
    begin
        if features[167] <= 1.5000000000000002 then
        begin
            if features[53] <= 5.0000000000000009 then
            begin
                if features[28] <= -6928.4999999999991 then
                begin
                    Result := 0.018320972087138968;
                end
                else
                begin
                    if features[178] <= -386.49999999999994 then
                    begin
                        if features[75] <= 5.5000000000000009 then
                        begin
                            Result := 0.017727460217513945;
                        end
                        else
                        begin
                            Result := 0.0016704182808413267;
                        end;
                    end
                    else
                    begin
                        Result := -0.001181907334506623;
                    end;
                end;
            end
            else
            begin
                if features[188] <= -3482.4999999999995 then
                begin
                    Result := -0.0053810284298728833;
                end
                else
                begin
                    if features[182] <= -6062.4999999999991 then
                    begin
                        Result := 0.0038691457354292874;
                    end
                    else
                    begin
                        Result := 0.088877863576451194;
                    end;
                end;
            end;
        end
        else
        begin
            if features[189] <= -5122.4999999999991 then
            begin
                Result := -0.012542113656157148;
            end
            else
            begin
                if features[196] <= 316.50000000000006 then
                begin
                    Result := -0.004518773322520246;
                end
                else
                begin
                    Result := 0.015210643581562391;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_206(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[185] <= -204.74999999999997 then
    begin
        if features[174] <= -8119.4999999999991 then
        begin
            if features[195] <= -5773.4999999999991 then
            begin
                Result := -0.0021752428278441808;
            end
            else
            begin
                Result := 0.0066236581929768838;
            end;
        end
        else
        begin
            if features[170] <= 4.5000000000000009 then
            begin
                Result := 0.00027055605170981696;
            end
            else
            begin
                Result := -0.0090853302750658997;
            end;
        end;
    end
    else
    begin
        if features[184] <= -509.49999999999994 then
        begin
            if features[201] <= -4517.4999999999991 then
            begin
                Result := 0.0030456977741517635;
            end
            else
            begin
                if features[18] <= 13.500000000000002 then
                begin
                    Result := 0.031435863842551801;
                end
                else
                begin
                    Result := 0.0060504389711850499;
                end;
            end;
        end
        else
        begin
            if features[199] <= 335.50000000000006 then
            begin
                if features[173] <= -4911.4999999999991 then
                begin
                    if features[173] <= -5406.4999999999991 then
                    begin
                        if features[191] <= -4235.4999999999991 then
                        begin
                            Result := -0.0013852620694336591;
                        end
                        else
                        begin
                            Result := 0.0092375818414537885;
                        end;
                    end
                    else
                    begin
                        if features[28] <= -7454.4999999999991 then
                        begin
                            Result := 0.027818804478892636;
                        end
                        else
                        begin
                            if features[174] <= -5868.4999999999991 then
                            begin
                                Result := -0.015380869225015987;
                            end
                            else
                            begin
                                Result := 0.0019547304053410364;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if features[188] <= -3473.9999999999995 then
                    begin
                        Result := 0.0088737170082688176;
                    end
                    else
                    begin
                        Result := -0.0084994664171011945;
                    end;
                end;
            end
            else
            begin
                Result := 0.0046428160293031304;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_207(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.024541728776116139;
    end
    else
    begin
        if features[202] <= -1080.4999999999998 then
        begin
            Result := -0.013808352870209756;
        end
        else
        begin
            if features[201] <= -4006.4999999999995 then
            begin
                if features[186] <= 16.166666984558109 then
                begin
                    if features[184] <= 52.500000000000007 then
                    begin
                        if features[173] <= -6091.4999999999991 then
                        begin
                            if features[126] <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.0022110050191737262;
                            end
                            else
                            begin
                                Result := -0.0048922784221253519;
                            end;
                        end
                        else
                        begin
                            Result := -0.0035572079598146311;
                        end;
                    end
                    else
                    begin
                        Result := -0.012881753593268706;
                    end;
                end
                else
                begin
                    if features[176] <= -6822.4999999999991 then
                    begin
                        if features[194] <= -5620.4999999999991 then
                        begin
                            Result := 0.0042724388149089302;
                        end
                        else
                        begin
                            Result := -0.0042279304831433313;
                        end;
                    end
                    else
                    begin
                        Result := 0.010811112483366768;
                    end;
                end;
            end
            else
            begin
                if features[202] <= 794.50000000000011 then
                begin
                    if features[199] <= -633.49999999999989 then
                    begin
                        Result := -0.010059787564086535;
                    end
                    else
                    begin
                        if features[184] <= -194.49999999999997 then
                        begin
                            if features[186] <= -93.833332061767564 then
                            begin
                                Result := 0.005601239656185461;
                            end
                            else
                            begin
                                if features[176] <= -7643.4999999999991 then
                                begin
                                    Result := -0.0091222843902269753;
                                end
                                else
                                begin
                                    Result := 0.035558241907947201;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.00070609831543295629;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.028436181004391187;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_208(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[201] <= -4006.4999999999995 then
    begin
        if features[166] <= 118461356.00000001 then
        begin
            if features[164] <= -384867039.99999994 then
            begin
                if features[190] <= 3702.5000000000005 then
                begin
                    Result := -0.011269740134055132;
                end
                else
                begin
                    Result := 0.06069401336667779;
                end;
            end
            else
            begin
                Result := 3.0625044472350409E-05;
            end;
        end
        else
        begin
            if features[201] <= -5202.4999999999991 then
            begin
                if features[77] <= 25562.500000000004 then
                begin
                    Result := -0.020535466575118722;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.020463213786087498;
                    end
                    else
                    begin
                        Result := -0.01797207909039444;
                    end;
                end;
            end
            else
            begin
                Result := -0.0015769484120162687;
            end;
        end;
    end
    else
    begin
        if features[202] <= -531.49999999999989 then
        begin
            Result := -0.011873557255318063;
        end
        else
        begin
            if features[193] <= -1150.4999999999998 then
            begin
                Result := 0.027353161424231651;
            end
            else
            begin
                if features[175] <= 2451.5000000000005 then
                begin
                    if features[183] <= -4909.4999999999991 then
                    begin
                        if features[194] <= -2921.4999999999995 then
                        begin
                            Result := 0.0046649120912426343;
                        end
                        else
                        begin
                            Result := 0.0576209774128848;
                        end;
                    end
                    else
                    begin
                        Result := -0.0046788990081180247;
                    end;
                end
                else
                begin
                    if features[179] <= -5543.4999999999991 then
                    begin
                        if features[180] <= -6623.4999999999991 then
                        begin
                            Result := 0.033677651991504513;
                        end
                        else
                        begin
                            Result := -0.010094039354895595;
                        end;
                    end
                    else
                    begin
                        Result := 0.05704020641099268;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_209(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[145] <= -698.99999999999989 then
    begin
        Result := 0.010590527424710786;
    end
    else
    begin
        if features[90] <= -1.4999999999999998 then
        begin
            if features[11] <= 1.5000000000000002 then
            begin
                Result := -0.0065841020420062046;
            end
            else
            begin
                Result := 0.011912288885313307;
            end;
        end
        else
        begin
            if features[164] <= -24976078.999999996 then
            begin
                if features[201] <= -4006.4999999999995 then
                begin
                    Result := -0.0011818929827682207;
                end
                else
                begin
                    if features[28] <= -7383.4999999999991 then
                    begin
                        Result := 0.049274819446494172;
                    end
                    else
                    begin
                        if features[177] <= -6412.4999999999991 then
                        begin
                            if features[201] <= -3317.4999999999995 then
                            begin
                                if features[89] <= 1.0000000180025095E-35 then
                                begin
                                    Result := 0.010062662539426667;
                                end
                                else
                                begin
                                    if features[25] <= 1.0000000180025095E-35 then
                                    begin
                                        Result := 0.015537619833555311;
                                    end
                                    else
                                    begin
                                        Result := -0.0059474154925134018;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.022006482742253138;
                            end;
                        end
                        else
                        begin
                            Result := -0.0028710943937324271;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[109] <= -687.49999999999989 then
                begin
                    if features[108] <= -751.49999999999989 then
                    begin
                        Result := 0.0096284569006566192;
                    end
                    else
                    begin
                        Result := 0.059066356673586617;
                    end;
                end
                else
                begin
                    if features[166] <= 10296288.500000002 then
                    begin
                        Result := 0.0051389302720017526;
                    end
                    else
                    begin
                        if features[109] <= -461.49999999999994 then
                        begin
                            Result := 0.029477070022821163;
                        end
                        else
                        begin
                            Result := -0.0092690793454757604;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_210(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[200] <= -3245.4999999999995 then
    begin
        if features[194] <= -3013.4999999999995 then
        begin
            if features[69] <= 39.500000000000007 then
            begin
                if features[179] <= -4083.4999999999995 then
                begin
                    if features[148] <= 2333.5000000000005 then
                    begin
                        if features[166] <= -16113090.499999998 then
                        begin
                            if features[123] <= -163.49999999999997 then
                            begin
                                Result := 0.040303092347950743;
                            end
                            else
                            begin
                                if features[183] <= -8298.4999999999982 then
                                begin
                                    if features[188] <= -4774.4999999999991 then
                                    begin
                                        Result := 0.030506108074671578;
                                    end
                                    else
                                    begin
                                        Result := -0.0068547326514312853;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.00056618743108423786;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.00033154998057567485;
                        end;
                    end
                    else
                    begin
                        if features[9] <= 5.5000000000000009 then
                        begin
                            Result := 0.0025784192814406848;
                        end
                        else
                        begin
                            if features[124] <= 233.50000000000003 then
                            begin
                                Result := 0.0074949531496229255;
                            end
                            else
                            begin
                                Result := 0.04010932422379182;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.01111803654451389;
                end;
            end
            else
            begin
                Result := 0.030319301072151229;
            end;
        end
        else
        begin
            if features[173] <= -6467.4999999999991 then
            begin
                Result := 0.066392019961766705;
            end
            else
            begin
                if features[129] <= -23272.999999999996 then
                begin
                    Result := 0.076349849735325354;
                end
                else
                begin
                    Result := -0.00097752188331965448;
                end;
            end;
        end;
    end
    else
    begin
        if features[174] <= -3442.9999999999995 then
        begin
            Result := -0.0087632709436141678;
        end
        else
        begin
            Result := 0.037947912365864679;
        end;
    end;
end;

function settled_top2_residual_tree_211(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.027302155707863596;
    end
    else
    begin
        if features[188] <= -5423.4999999999991 then
        begin
            Result := -0.001934764254327592;
        end
        else
        begin
            if features[175] <= 2451.5000000000005 then
            begin
                if features[202] <= -569.49999999999989 then
                begin
                    Result := -0.0059851129873709462;
                end
                else
                begin
                    if features[174] <= -6571.4999999999991 then
                    begin
                        if features[189] <= -4748.4999999999991 then
                        begin
                            if features[171] <= 5.5000000000000009 then
                            begin
                                Result := 0.0031779616601166297;
                            end
                            else
                            begin
                                Result := -0.0050272276848557056;
                            end;
                        end
                        else
                        begin
                            if features[192] <= -5492.4999999999991 then
                            begin
                                Result := 0.016225631266483423;
                            end
                            else
                            begin
                                Result := 0.0025686878052602418;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[169] <= 1.5000000000000002 then
                        begin
                            if features[188] <= -3966.4999999999995 then
                            begin
                                if features[191] <= -4156.4999999999991 then
                                begin
                                    if features[177] <= -8610.4999999999982 then
                                    begin
                                        Result := 0.0087610168413388544;
                                    end
                                    else
                                    begin
                                        Result := -0.0068867610525964297;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.02161938290522843;
                                end;
                            end
                            else
                            begin
                                if features[90] <= 1.0000000180025095E-35 then
                                begin
                                    if features[190] <= -143.49999999999997 then
                                    begin
                                        Result := -0.015907688446786496;
                                    end
                                    else
                                    begin
                                        Result := 0.045858652354677697;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.024625028712197388;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.0039761471555190536;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.012562879478027842;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_212(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[66] <= 427.50000000000006 then
    begin
        if features[187] <= -135.70833587646482 then
        begin
            Result := -0.00642371973343167;
        end
        else
        begin
            if features[9] <= 26.500000000000004 then
            begin
                if features[108] <= -100.49999999999999 then
                begin
                    if features[181] <= -448.49999999999994 then
                    begin
                        if features[174] <= -7695.4999999999991 then
                        begin
                            if features[198] <= -4988.4999999999991 then
                            begin
                                if features[166] <= -23350289.999999996 then
                                begin
                                    Result := 0.035729990117475019;
                                end
                                else
                                begin
                                    if features[128] <= -47131.499999999993 then
                                    begin
                                        Result := 0.025307975826040476;
                                    end
                                    else
                                    begin
                                        Result := -0.00019120212127183607;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := 0.013169217068342218;
                            end;
                        end
                        else
                        begin
                            if features[194] <= -6059.4999999999991 then
                            begin
                                Result := -0.010788009752066188;
                            end
                            else
                            begin
                                Result := 7.9058609821314459E-05;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[171] <= 1.5000000000000002 then
                        begin
                            Result := -0.012297762332279395;
                        end
                        else
                        begin
                            Result := -0.0012524210147678311;
                        end;
                    end;
                end
                else
                begin
                    if features[184] <= -164.49999999999997 then
                    begin
                        if features[173] <= -4590.4999999999991 then
                        begin
                            Result := 0.0092601234325450053;
                        end
                        else
                        begin
                            Result := 0.042434064110754913;
                        end;
                    end
                    else
                    begin
                        Result := 0.0011100855294687447;
                    end;
                end;
            end
            else
            begin
                Result := 0.039280268452539596;
            end;
        end;
    end
    else
    begin
        if features[189] <= -4495.4999999999991 then
        begin
            Result := -0.012279045081631067;
        end
        else
        begin
            Result := 0.0066611454995412697;
        end;
    end;
end;

function settled_top2_residual_tree_213(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[143] <= -1.0000000180025095E-35 then
    begin
        Result := 0.0063397231744397571;
    end
    else
    begin
        if features[158] <= -2464.4999999999995 then
        begin
            Result := -0.0059327172519935967;
        end
        else
        begin
            if features[164] <= -49570567.999999993 then
            begin
                if features[195] <= -4648.4999999999991 then
                begin
                    if features[37] <= 1.5000000000000002 then
                    begin
                        Result := 0.028511956471266336;
                    end
                    else
                    begin
                        if features[81] <= -233.49999999999997 then
                        begin
                            if features[105] <= 1.0000000180025095E-35 then
                            begin
                                if features[109] <= 42.500000000000007 then
                                begin
                                    Result := -0.002694894219851203;
                                end
                                else
                                begin
                                    if features[176] <= -5759.4999999999991 then
                                    begin
                                        Result := 0.0037327783186144985;
                                    end
                                    else
                                    begin
                                        Result := 0.050728026793874052;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.0077726838497626793;
                            end;
                        end
                        else
                        begin
                            Result := 0.00051044654334876682;
                        end;
                    end;
                end
                else
                begin
                    if features[180] <= -7012.4999999999991 then
                    begin
                        Result := 0.010839087999023157;
                    end
                    else
                    begin
                        if features[193] <= -325.49999999999994 then
                        begin
                            if features[158] <= 583.00000000000011 then
                            begin
                                Result := 0.043648198840587231;
                            end
                            else
                            begin
                                Result := 0.005427029972391223;
                            end;
                        end
                        else
                        begin
                            if features[108] <= -612.49999999999989 then
                            begin
                                Result := -0.017641641555296805;
                            end
                            else
                            begin
                                if features[177] <= -7676.4999999999991 then
                                begin
                                    Result := 0.011241402598152178;
                                end
                                else
                                begin
                                    Result := -0.003067061384236592;
                                end;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.0028211845397266653;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_214(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[96] <= -114773631.99999999 then
    begin
        if features[41] <= 1525.5000000000002 then
        begin
            if features[120] <= 334.50000000000006 then
            begin
                Result := 0.0012383486624147491;
            end
            else
            begin
                Result := 0.034895479808583076;
            end;
        end
        else
        begin
            if features[173] <= -6171.4999999999991 then
            begin
                Result := 0.004340478971767224;
            end
            else
            begin
                Result := 0.038196995252514465;
            end;
        end;
    end
    else
    begin
        if features[173] <= -6126.4999999999991 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[193] <= -1960.9999999999998 then
                begin
                    if features[171] <= 4.5000000000000009 then
                    begin
                        Result := 0.082625397471808304;
                    end
                    else
                    begin
                        Result := -0.0017853577331000078;
                    end;
                end
                else
                begin
                    Result := 0.0037528023104526562;
                end;
            end
            else
            begin
                if features[124] <= -1.0000000180025095E-35 then
                begin
                    if features[176] <= -6636.4999999999991 then
                    begin
                        if features[199] <= 484.50000000000006 then
                        begin
                            if features[85] <= -1.0000000180025095E-35 then
                            begin
                                if features[183] <= -6620.4999999999991 then
                                begin
                                    Result := -0.0078058260993539332;
                                end
                                else
                                begin
                                    Result := 0.016081284817506796;
                                end;
                            end
                            else
                            begin
                                Result := -0.012275168378194196;
                            end;
                        end
                        else
                        begin
                            Result := 0.0047934792066792525;
                        end;
                    end
                    else
                    begin
                        Result := 0.0039364974623074941;
                    end;
                end
                else
                begin
                    Result := 0.00070305491604842922;
                end;
            end;
        end
        else
        begin
            if features[0] <= 177603.50000000003 then
            begin
                Result := -0.0034611855744794322;
            end
            else
            begin
                Result := 0.0053642239812199521;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_215(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[187] <= -12.788888931274412 then
    begin
        if features[177] <= -5745.4999999999991 then
        begin
            if features[120] <= -1438.4999999999998 then
            begin
                if features[201] <= -5931.4999999999991 then
                begin
                    Result := -0.015500057870398536;
                end
                else
                begin
                    Result := 0.010220974605039561;
                end;
            end
            else
            begin
                if features[148] <= 1147.0000000000002 then
                begin
                    if features[118] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0023709776289540618;
                    end
                    else
                    begin
                        if features[174] <= -5991.4999999999991 then
                        begin
                            Result := -0.0098853281909471874;
                        end
                        else
                        begin
                            Result := -0.0012900341288906898;
                        end;
                    end;
                end
                else
                begin
                    if features[82] <= -39435.499999999993 then
                    begin
                        Result := 0.043586672573348383;
                    end
                    else
                    begin
                        Result := 0.0016798145785601873;
                    end;
                end;
            end;
        end
        else
        begin
            if features[173] <= -5406.4999999999991 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[13] <= 36676.500000000007 then
                    begin
                        Result := -0.011391767472628784;
                    end
                    else
                    begin
                        Result := 0.030292084409893633;
                    end;
                end
                else
                begin
                    Result := 0.021380152982125065;
                end;
            end
            else
            begin
                Result := -0.005117042563356539;
            end;
        end;
    end
    else
    begin
        if features[176] <= -5204.4999999999991 then
        begin
            Result := 0.0011765142441022237;
        end
        else
        begin
            if features[185] <= -286.74999999999994 then
            begin
                Result := -0.010010444054638846;
            end
            else
            begin
                if features[202] <= -369.49999999999994 then
                begin
                    Result := 0.018190941436750131;
                end
                else
                begin
                    Result := -0.0025733046646963936;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_216(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[92] <= -1.4999999999999998 then
    begin
        Result := -0.011005696341206711;
    end
    else
    begin
        if features[198] <= -3884.4999999999995 then
        begin
            if features[200] <= -3245.4999999999995 then
            begin
                if features[189] <= -4176.4999999999991 then
                begin
                    Result := -0.00052793081783009501;
                end
                else
                begin
                    if features[177] <= -9379.4999999999982 then
                    begin
                        if features[190] <= 663.50000000000011 then
                        begin
                            Result := 0.0076878987597844093;
                        end
                        else
                        begin
                            Result := 0.037472722161794821;
                        end;
                    end
                    else
                    begin
                        if features[189] <= -4016.4999999999995 then
                        begin
                            Result := 0.0092505913780725826;
                        end
                        else
                        begin
                            if features[175] <= -733.49999999999989 then
                            begin
                                if features[173] <= -5022.4999999999991 then
                                begin
                                    Result := -0.022520016266958116;
                                end
                                else
                                begin
                                    Result := -0.0017574162895083066;
                                end;
                            end
                            else
                            begin
                                if features[175] <= 671.50000000000011 then
                                begin
                                    Result := 0.011428994951581596;
                                end
                                else
                                begin
                                    if features[171] <= 1.5000000000000002 then
                                    begin
                                        Result := -0.018743778189403735;
                                    end
                                    else
                                    begin
                                        Result := 0.0016540213786788013;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.010965663484764368;
            end;
        end
        else
        begin
            if features[189] <= -5084.4999999999991 then
            begin
                if features[54] <= 2.5000000000000004 then
                begin
                    Result := 0.0051893938983871724;
                end
                else
                begin
                    Result := 0.032336519057900248;
                end;
            end
            else
            begin
                if features[175] <= 2451.5000000000005 then
                begin
                    Result := -0.00043899379934994045;
                end
                else
                begin
                    Result := 0.032117312179779076;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_217(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[92] <= 1.5000000000000002 then
    begin
        if features[124] <= -1.0000000180025095E-35 then
        begin
            if features[180] <= -5516.4999999999991 then
            begin
                if features[202] <= -349.49999999999994 then
                begin
                    Result := -0.010649206528181706;
                end
                else
                begin
                    Result := -0.0020169993945274569;
                end;
            end
            else
            begin
                if features[195] <= -5323.4999999999991 then
                begin
                    if features[190] <= -181.49999999999997 then
                    begin
                        Result := 0.068587234869683697;
                    end
                    else
                    begin
                        Result := 0.0051764872214784957;
                    end;
                end
                else
                begin
                    Result := 0.0029140794378229307;
                end;
            end;
        end
        else
        begin
            if features[9] <= 12.500000000000002 then
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    if features[189] <= -4176.4999999999991 then
                    begin
                        Result := 0.00016333640547942522;
                    end
                    else
                    begin
                        if features[175] <= -2238.4999999999995 then
                        begin
                            Result := 0.029277778204611013;
                        end
                        else
                        begin
                            Result := 0.0043872452053458147;
                        end;
                    end;
                end
                else
                begin
                    if features[175] <= -733.49999999999989 then
                    begin
                        Result := -0.015424754083422795;
                    end
                    else
                    begin
                        if features[175] <= 671.50000000000011 then
                        begin
                            Result := 0.01015873923597712;
                        end
                        else
                        begin
                            Result := -0.0071286812813778806;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -6707.4999999999991 then
                begin
                    Result := 0.032897909817709708;
                end
                else
                begin
                    Result := 0.0055624645657585065;
                end;
            end;
        end;
    end
    else
    begin
        if features[178] <= 448.50000000000006 then
        begin
            Result := 0.0080228263035919244;
        end
        else
        begin
            Result := -0.0061471472565703131;
        end;
    end;
end;

function settled_top2_residual_tree_218(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[172] <= 5.5000000000000009 then
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.025512568726436508;
        end
        else
        begin
            if features[92] <= -1.4999999999999998 then
            begin
                Result := -0.011629300674843562;
            end
            else
            begin
                if features[90] <= 3.5000000000000004 then
                begin
                    if features[164] <= -256588463.99999997 then
                    begin
                        if features[174] <= -3442.9999999999995 then
                        begin
                            if features[118] <= 1.0000000180025095E-35 then
                            begin
                                Result := -0.0026167618767049968;
                            end
                            else
                            begin
                                Result := -0.013267829621769625;
                            end;
                        end
                        else
                        begin
                            Result := 0.05643677361217625;
                        end;
                    end
                    else
                    begin
                        Result := -9.1162019265109804E-05;
                    end;
                end
                else
                begin
                    if features[109] <= 64.500000000000014 then
                    begin
                        if features[13] <= 93438.000000000015 then
                        begin
                            if features[123] <= 84.500000000000014 then
                            begin
                                Result := -0.0016180784939472147;
                            end
                            else
                            begin
                                Result := 0.0057385246216849111;
                            end;
                        end
                        else
                        begin
                            if features[73] <= 137.50000000000003 then
                            begin
                                Result := 0.031038726948111342;
                            end
                            else
                            begin
                                Result := 0.0045909539494669929;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[179] <= -5925.4999999999991 then
                        begin
                            Result := 0.0067030615315975999;
                        end
                        else
                        begin
                            if features[196] <= -80.499999999999986 then
                            begin
                                Result := 0.069990839190808465;
                            end
                            else
                            begin
                                Result := 0.0068979952509516098;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[196] <= 28.500000000000004 then
        begin
            Result := -0.0083778186763517459;
        end
        else
        begin
            Result := 0.026550997584148025;
        end;
    end;
end;

function settled_top2_residual_tree_219(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[166] <= 118461356.00000001 then
    begin
        if features[66] <= 583.50000000000011 then
        begin
            if features[188] <= -3966.4999999999995 then
            begin
                if features[189] <= -4389.4999999999991 then
                begin
                    Result := 0.00050459080306452196;
                end
                else
                begin
                    Result := 0.0048189945383928356;
                end;
            end
            else
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    if features[171] <= 3.5000000000000004 then
                    begin
                        if features[167] <= 1.5000000000000002 then
                        begin
                            Result := 0.023086887554546229;
                        end
                        else
                        begin
                            Result := 0.0037233127376875724;
                        end;
                    end
                    else
                    begin
                        if features[189] <= -4859.4999999999991 then
                        begin
                            Result := -0.011400439671132689;
                        end
                        else
                        begin
                            Result := 0.0019117570839509903;
                        end;
                    end;
                end
                else
                begin
                    if features[189] <= -3965.4999999999995 then
                    begin
                        Result := -0.024691773646522159;
                    end
                    else
                    begin
                        if features[9] <= 1.5000000000000002 then
                        begin
                            if features[189] <= -3832.4999999999995 then
                            begin
                                Result := 0.044671374362541177;
                            end
                            else
                            begin
                                Result := -0.010003088998378181;
                            end;
                        end
                        else
                        begin
                            if features[173] <= -5675.9999999999991 then
                            begin
                                Result := -0.02528321847809821;
                            end
                            else
                            begin
                                Result := 0.0024426975739170504;
                            end;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.0087115310535989896;
        end;
    end
    else
    begin
        if features[201] <= -5202.4999999999991 then
        begin
            Result := -0.015069197059360471;
        end
        else
        begin
            if features[146] <= -1658.9999999999998 then
            begin
                Result := 0.0375352721167845;
            end
            else
            begin
                Result := -0.0019426131913844163;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_220(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -873.49999999999989 then
    begin
        if features[189] <= -6155.4999999999991 then
        begin
            if features[176] <= -7180.4999999999991 then
            begin
                Result := -0.0051245445882764466;
            end
            else
            begin
                if features[180] <= -5664.4999999999991 then
                begin
                    if features[37] <= 2.5000000000000004 then
                    begin
                        if features[183] <= -6796.4999999999991 then
                        begin
                            if features[171] <= 1.5000000000000002 then
                            begin
                                Result := 0.12238509751439644;
                            end
                            else
                            begin
                                Result := 0.011551667733838927;
                            end;
                        end
                        else
                        begin
                            Result := -0.017097875142042186;
                        end;
                    end
                    else
                    begin
                        Result := 0.01046820767560706;
                    end;
                end
                else
                begin
                    Result := 0.10595547126824707;
                end;
            end;
        end
        else
        begin
            if features[177] <= -7241.4999999999991 then
            begin
                Result := -0.015847744855655623;
            end
            else
            begin
                if features[123] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.017491034835727066;
                end
                else
                begin
                    Result := 0.0070412901159860432;
                end;
            end;
        end;
    end
    else
    begin
        if features[37] <= 1.5000000000000002 then
        begin
            if features[193] <= -22.499999999999996 then
            begin
                if features[108] <= -298.49999999999994 then
                begin
                    Result := 0.0091083509874415932;
                end
                else
                begin
                    Result := 0.074322084509815006;
                end;
            end
            else
            begin
                Result := -0.015306350929865485;
            end;
        end
        else
        begin
            if features[178] <= 539.50000000000011 then
            begin
                if features[109] <= 113.50000000000001 then
                begin
                    Result := 0.00024386189199787913;
                end
                else
                begin
                    Result := 0.0067146945035866257;
                end;
            end
            else
            begin
                Result := -0.0026026308939892757;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_221(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.025289465221843367;
    end
    else
    begin
        if features[202] <= 528.50000000000011 then
        begin
            if features[176] <= -9527.4999999999982 then
            begin
                if features[189] <= -4970.4999999999991 then
                begin
                    Result := -0.0082620103455694864;
                end
                else
                begin
                    if features[177] <= -10095.499999999998 then
                    begin
                        if features[190] <= -45.499999999999993 then
                        begin
                            Result := -0.003871839971854708;
                        end
                        else
                        begin
                            Result := 0.024744046669951447;
                        end;
                    end
                    else
                    begin
                        if features[109] <= 64.500000000000014 then
                        begin
                            Result := -0.0098824569143154059;
                        end
                        else
                        begin
                            if features[25] <= 1.5000000000000002 then
                            begin
                                Result := -0.012506252746690268;
                            end
                            else
                            begin
                                Result := 0.016223435747468328;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[183] <= -8861.4999999999982 then
                begin
                    if features[109] <= 129.50000000000003 then
                    begin
                        Result := 0.0052403831736409952;
                    end
                    else
                    begin
                        Result := 0.039323534507876096;
                    end;
                end
                else
                begin
                    Result := 0.0;
                end;
            end;
        end
        else
        begin
            if features[177] <= -9044.4999999999982 then
            begin
                if features[151] <= -95.499999999999986 then
                begin
                    Result := 0.0040865382799544691;
                end
                else
                begin
                    Result := 0.040222401423583971;
                end;
            end
            else
            begin
                if features[191] <= -6583.4999999999991 then
                begin
                    if features[186] <= -33.749999999999993 then
                    begin
                        Result := -0.020896124074652328;
                    end
                    else
                    begin
                        Result := 0.0021265364538194612;
                    end;
                end
                else
                begin
                    Result := 0.011808415681435858;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_222(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[150] <= -8.4999999999999982 then
    begin
        if features[190] <= -506.49999999999994 then
        begin
            if features[189] <= -4115.4999999999991 then
            begin
                Result := 0.0053669745445208295;
            end
            else
            begin
                if features[183] <= -6620.4999999999991 then
                begin
                    Result := 0.0051526134846254417;
                end
                else
                begin
                    if features[201] <= -3980.4999999999995 then
                    begin
                        Result := 0.09968083771672008;
                    end
                    else
                    begin
                        Result := 0.022439608195597066;
                    end;
                end;
            end;
        end
        else
        begin
            if features[188] <= -4201.4999999999991 then
            begin
                if features[195] <= -5591.4999999999991 then
                begin
                    Result := -0.0022964816867206569;
                end
                else
                begin
                    if features[129] <= -1085.4999999999998 then
                    begin
                        Result := -0.00035052148114514387;
                    end
                    else
                    begin
                        if features[177] <= -6558.4999999999991 then
                        begin
                            if features[174] <= -6971.4999999999991 then
                            begin
                                Result := 0.022496975685903937;
                            end
                            else
                            begin
                                Result := 0.0066022138537153961;
                            end;
                        end
                        else
                        begin
                            Result := -0.0033755092518963701;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.010846956668801484;
            end;
        end;
    end
    else
    begin
        if features[199] <= 335.50000000000006 then
        begin
            if features[174] <= -6022.4999999999991 then
            begin
                Result := -0.0026786271641828286;
            end
            else
            begin
                if features[177] <= -8741.4999999999982 then
                begin
                    Result := 0.011828949156379432;
                end
                else
                begin
                    Result := -0.00010960110874909813;
                end;
            end;
        end
        else
        begin
            if features[193] <= -325.49999999999994 then
            begin
                Result := 0.029798546662762295;
            end
            else
            begin
                Result := 0.0023822455780559311;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_223(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[122] <= -1141.4999999999998 then
    begin
        if features[171] <= 2.5000000000000004 then
        begin
            Result := -0.012867869678607658;
        end
        else
        begin
            if features[39] <= 1384.5000000000002 then
            begin
                Result := 0.011703476285146671;
            end
            else
            begin
                Result := -0.0069256642511968825;
            end;
        end;
    end
    else
    begin
        if features[147] <= -1717.4999999999998 then
        begin
            Result := 0.031603793487276252;
        end
        else
        begin
            if features[90] <= 12.500000000000002 then
            begin
                if features[173] <= -5591.4999999999991 then
                begin
                    if features[181] <= 320.50000000000006 then
                    begin
                        Result := 0.0015389664658948701;
                    end
                    else
                    begin
                        Result := -0.0025392570075543786;
                    end;
                end
                else
                begin
                    if features[174] <= -7053.4999999999991 then
                    begin
                        Result := -0.0074848499477132725;
                    end
                    else
                    begin
                        if features[174] <= -7051.9999999999991 then
                        begin
                            Result := 0.017883701242259221;
                        end
                        else
                        begin
                            if features[201] <= -5971.4999999999991 then
                            begin
                                if features[189] <= -4016.4999999999995 then
                                begin
                                    if features[193] <= -22.499999999999996 then
                                    begin
                                        if features[106] <= -1.0000000180025095E-35 then
                                        begin
                                            Result := -0.0025611756100102773;
                                        end
                                        else
                                        begin
                                            Result := 0.043820930119452602;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := -0.0037676174985580217;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.013139825634124561;
                                end;
                            end
                            else
                            begin
                                Result := -0.0021214433138473481;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[198] <= -5473.4999999999991 then
                begin
                    Result := -0.0023016180872655729;
                end
                else
                begin
                    Result := 0.011517976353572911;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_224(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[66] <= 1218.0000000000002 then
    begin
        if features[90] <= 12.500000000000002 then
        begin
            if features[92] <= 2.5000000000000004 then
            begin
                if features[188] <= -3966.4999999999995 then
                begin
                    if features[164] <= -227728639.99999997 then
                    begin
                        Result := -0.0036687154708369093;
                    end
                    else
                    begin
                        Result := 0.0011988762105633137;
                    end;
                end
                else
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        Result := -0.00031578498396201673;
                    end
                    else
                    begin
                        if features[90] <= 1.0000000180025095E-35 then
                        begin
                            if features[167] <= 1.5000000000000002 then
                            begin
                                Result := 0.053522113054261168;
                            end
                            else
                            begin
                                Result := -0.0043832158892310137;
                            end;
                        end
                        else
                        begin
                            if features[169] <= 1.5000000000000002 then
                            begin
                                Result := -0.026250829654434416;
                            end
                            else
                            begin
                                Result := -0.00035073318482035389;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[41] <= 1393.5000000000002 then
                begin
                    Result := 0.0037100219373700284;
                end
                else
                begin
                    Result := 0.027510333989625674;
                end;
            end;
        end
        else
        begin
            if features[126] <= -1.0000000180025095E-35 then
            begin
                if features[151] <= -58.499999999999993 then
                begin
                    Result := 0.039628283481005749;
                end
                else
                begin
                    Result := 0.0056869669271254501;
                end;
            end
            else
            begin
                if features[197] <= -3944.4999999999995 then
                begin
                    Result := 0.00067663706354653501;
                end
                else
                begin
                    if features[71] <= 5.5000000000000009 then
                    begin
                        Result := 0.082973718805932628;
                    end
                    else
                    begin
                        Result := 0.013928613027031703;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.012751996560635227;
    end;
end;

function settled_top2_residual_tree_225(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[122] <= -1216.4999999999998 then
    begin
        if features[171] <= 2.5000000000000004 then
        begin
            if features[191] <= -4633.4999999999991 then
            begin
                Result := -0.017968134264068323;
            end
            else
            begin
                if features[148] <= -2821.4999999999995 then
                begin
                    if features[187] <= -56.18333435058593 then
                    begin
                        Result := 0.0013442075403658918;
                    end
                    else
                    begin
                        Result := 0.066587182026424593;
                    end;
                end
                else
                begin
                    Result := -0.0080908435364642449;
                end;
            end;
        end
        else
        begin
            if features[39] <= 1306.5000000000002 then
            begin
                if features[95] <= -176899151.99999997 then
                begin
                    if features[191] <= -5354.4999999999991 then
                    begin
                        Result := 0.076463513178140527;
                    end
                    else
                    begin
                        Result := 0.0015552467890732177;
                    end;
                end
                else
                begin
                    Result := 0.0067869255209814447;
                end;
            end
            else
            begin
                Result := -0.006092365257036346;
            end;
        end;
    end
    else
    begin
        if features[195] <= -4648.4999999999991 then
        begin
            Result := -0.00042938923839122979;
        end
        else
        begin
            if features[180] <= -7251.4999999999991 then
            begin
                if features[190] <= 2732.0000000000005 then
                begin
                    if features[184] <= -1874.4999999999998 then
                    begin
                        Result := 0.039743401523501823;
                    end
                    else
                    begin
                        if features[27] <= -4935.4999999999991 then
                        begin
                            Result := 0.018480314186987628;
                        end
                        else
                        begin
                            Result := 0.0019569639954492212;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.019164210799495315;
                end;
            end
            else
            begin
                if features[184] <= 650.50000000000011 then
                begin
                    Result := 0.0019384968624767446;
                end
                else
                begin
                    Result := -0.010944300833293438;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_226(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[143] <= -1.0000000180025095E-35 then
    begin
        Result := 0.0073392892334815628;
    end
    else
    begin
        if features[90] <= -1.4999999999999998 then
        begin
            Result := -0.0063963483988221373;
        end
        else
        begin
            if features[47] <= 9757.5000000000018 then
            begin
                if features[175] <= -3013.9999999999995 then
                begin
                    if features[180] <= -5598.4999999999991 then
                    begin
                        Result := -0.0079424160656506367;
                    end
                    else
                    begin
                        Result := 0.036780366788310467;
                    end;
                end
                else
                begin
                    if features[189] <= -6241.4999999999991 then
                    begin
                        if features[27] <= -3837.4999999999995 then
                        begin
                            Result := 0.0032732838368437853;
                        end
                        else
                        begin
                            if features[193] <= 391.50000000000006 then
                            begin
                                if features[190] <= -306.49999999999994 then
                                begin
                                    Result := 0.030059430353252148;
                                end
                                else
                                begin
                                    Result := 0.098415432638099931;
                                end;
                            end
                            else
                            begin
                                Result := -0.0092417859023976381;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[185] <= -743.74999999999989 then
                        begin
                            Result := -0.0098018734749658748;
                        end
                        else
                        begin
                            if features[190] <= -1132.4999999999998 then
                            begin
                                Result := -0.0071292488192194305;
                            end
                            else
                            begin
                                Result := 0.00061746840926127193;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[175] <= 183.50000000000003 then
                begin
                    if features[192] <= -5255.4999999999991 then
                    begin
                        if features[129] <= -27259.999999999996 then
                        begin
                            Result := -0.020290239242583566;
                        end
                        else
                        begin
                            Result := 0.0089879172796661546;
                        end;
                    end
                    else
                    begin
                        Result := -0.00086187546391317416;
                    end;
                end
                else
                begin
                    Result := -0.0015034663469756652;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_227(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[184] <= 1246.5000000000002 then
    begin
        if features[182] <= -4004.4999999999995 then
        begin
            if features[198] <= -3806.4999999999995 then
            begin
                if features[150] <= -12.499999999999998 then
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.0023121134377172437;
                    end
                    else
                    begin
                        Result := 0.023742554762264556;
                    end;
                end
                else
                begin
                    if features[66] <= 427.50000000000006 then
                    begin
                        if features[124] <= 112.00000000000001 then
                        begin
                            if features[174] <= -3442.9999999999995 then
                            begin
                                Result := -0.00084781259982274451;
                            end
                            else
                            begin
                                if features[28] <= -5823.4999999999991 then
                                begin
                                    Result := -0.0081636705429549115;
                                end
                                else
                                begin
                                    Result := 0.045595300290199821;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[147] <= -50.999999999999993 then
                            begin
                                if features[171] <= 4.5000000000000009 then
                                begin
                                    Result := 0.049017937057040745;
                                end
                                else
                                begin
                                    Result := -0.00038024010970680658;
                                end;
                            end
                            else
                            begin
                                Result := 0.0023058217371062814;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0095290374368780396;
                    end;
                end;
            end
            else
            begin
                if features[189] <= -5084.4999999999991 then
                begin
                    if features[192] <= -5635.4999999999991 then
                    begin
                        Result := 0.046266179835666096;
                    end
                    else
                    begin
                        Result := 0.011554953544395735;
                    end;
                end
                else
                begin
                    if features[202] <= 353.50000000000006 then
                    begin
                        Result := -0.0016938405683470268;
                    end
                    else
                    begin
                        Result := 0.018080936149493059;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.0083520711842072458;
        end;
    end
    else
    begin
        Result := -0.011400349132794771;
    end;
end;

function settled_top2_residual_tree_228(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1807.4999999999998 then
    begin
        Result := -0.022358175951067837;
    end
    else
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.023587762624910746;
        end
        else
        begin
            if features[189] <= -6408.4999999999991 then
            begin
                if features[184] <= -1814.4999999999998 then
                begin
                    Result := 0.02685789238519239;
                end
                else
                begin
                    if features[174] <= -7273.4999999999991 then
                    begin
                        Result := 0.0016410543120717429;
                    end
                    else
                    begin
                        Result := 0.027981350041737265;
                    end;
                end;
            end
            else
            begin
                if features[186] <= -756.49999999999989 then
                begin
                    if features[0] <= 2117.5000000000005 then
                    begin
                        Result := 0.052638341931680634;
                    end
                    else
                    begin
                        if features[37] <= 2.5000000000000004 then
                        begin
                            Result := 0.0063210527440383723;
                        end
                        else
                        begin
                            Result := -0.011417183100009247;
                        end;
                    end;
                end
                else
                begin
                    if features[190] <= -1132.4999999999998 then
                    begin
                        if features[171] <= 1.5000000000000002 then
                        begin
                            if features[188] <= -4080.4999999999995 then
                            begin
                                Result := -0.0027842534452370928;
                            end
                            else
                            begin
                                if features[184] <= -1302.4999999999998 then
                                begin
                                    Result := 0.057275807934156833;
                                end
                                else
                                begin
                                    Result := 0.012565909222870032;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[198] <= -3884.4999999999995 then
                            begin
                                if features[128] <= 53.500000000000007 then
                                begin
                                    Result := -0.011116942679656003;
                                end
                                else
                                begin
                                    Result := 0.0035109812312967056;
                                end;
                            end
                            else
                            begin
                                Result := 0.026071825321084121;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.00084770992330170352;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_229(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[15] <= -163318455.99999997 then
    begin
        if features[41] <= 1186.5000000000002 then
        begin
            if features[120] <= 1192.0000000000002 then
            begin
                Result := -0.00036588006252011524;
            end
            else
            begin
                Result := 0.048169116890698693;
            end;
        end
        else
        begin
            if features[70] <= 828.50000000000011 then
            begin
                if features[193] <= -784.49999999999989 then
                begin
                    if features[109] <= -508.49999999999994 then
                    begin
                        Result := 0.013259147476926612;
                    end
                    else
                    begin
                        Result := 0.12557742540265135;
                    end;
                end
                else
                begin
                    if features[129] <= -10189.499999999998 then
                    begin
                        Result := 0.054279559513532839;
                    end
                    else
                    begin
                        Result := 0.0015074875589192228;
                    end;
                end;
            end
            else
            begin
                if features[195] <= -4342.4999999999991 then
                begin
                    if features[82] <= -199.49999999999997 then
                    begin
                        Result := -0.0099802991159706114;
                    end
                    else
                    begin
                        Result := 0.042930121445805561;
                    end;
                end
                else
                begin
                    Result := 0.046728091568763584;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -53279485.999999993 then
        begin
            if features[195] <= -4648.4999999999991 then
            begin
                if features[179] <= -5129.4999999999991 then
                begin
                    if features[190] <= -1132.4999999999998 then
                    begin
                        Result := -0.0060638500838625462;
                    end
                    else
                    begin
                        Result := -0.00068384341037633616;
                    end;
                end
                else
                begin
                    Result := -0.01073511179351676;
                end;
            end
            else
            begin
                Result := 0.0024972633856483297;
            end;
        end
        else
        begin
            if features[14] <= 28229548.000000004 then
            begin
                Result := 0.0028662408655191138;
            end
            else
            begin
                Result := -0.00498152013521361;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_230(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[202] <= 528.50000000000011 then
    begin
        if features[11] <= 6.5000000000000009 then
        begin
            if features[199] <= -1616.4999999999998 then
            begin
                Result := -0.018614136266573888;
            end
            else
            begin
                if features[191] <= -4433.4999999999991 then
                begin
                    Result := -0.00060920318513181049;
                end
                else
                begin
                    if features[175] <= -530.99999999999989 then
                    begin
                        if features[189] <= -4016.4999999999995 then
                        begin
                            Result := 0.0019336021445727578;
                        end
                        else
                        begin
                            Result := -0.01632580226795732;
                        end;
                    end
                    else
                    begin
                        if features[13] <= 147254.50000000003 then
                        begin
                            if features[179] <= -7006.4999999999991 then
                            begin
                                Result := -0.0014419605778733479;
                            end
                            else
                            begin
                                Result := 0.014467804765749182;
                            end;
                        end
                        else
                        begin
                            Result := -0.0095478400263929609;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.037751250510190841;
        end;
    end
    else
    begin
        if features[177] <= -9236.4999999999982 then
        begin
            if features[154] <= -545.49999999999989 then
            begin
                Result := 0.0011974773586874007;
            end
            else
            begin
                Result := 0.036845009346756032;
            end;
        end
        else
        begin
            if features[191] <= -6583.4999999999991 then
            begin
                if features[186] <= -33.749999999999993 then
                begin
                    Result := -0.020073477224553007;
                end
                else
                begin
                    if features[47] <= 4474.5000000000009 then
                    begin
                        Result := 0.017435826448469024;
                    end
                    else
                    begin
                        Result := -0.015499932875736359;
                    end;
                end;
            end
            else
            begin
                if features[179] <= -4953.4999999999991 then
                begin
                    Result := 0.015689419797404146;
                end
                else
                begin
                    Result := -0.014173639502418496;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_231(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1426.4999999999998 then
    begin
        Result := -0.014985541407201665;
    end
    else
    begin
        if features[172] <= 5.5000000000000009 then
        begin
            if features[149] <= -819.99999999999989 then
            begin
                Result := -0.025069715214429335;
            end
            else
            begin
                if features[94] <= 163809.50000000003 then
                begin
                    if features[191] <= -4356.4999999999991 then
                    begin
                        if features[176] <= -5314.4999999999991 then
                        begin
                            if features[150] <= -12.499999999999998 then
                            begin
                                if features[174] <= -9070.4999999999982 then
                                begin
                                    Result := 0.012024126082210278;
                                end
                                else
                                begin
                                    if features[70] <= 781.50000000000011 then
                                    begin
                                        if features[164] <= -78593187.999999985 then
                                        begin
                                            Result := 0.0027951863462766084;
                                        end
                                        else
                                        begin
                                            Result := 0.022180694477999731;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := -0.00062685843102342788;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.00048149349421117496;
                            end;
                        end
                        else
                        begin
                            if features[189] <= -5102.4999999999991 then
                            begin
                                if features[185] <= -220.74999999999997 then
                                begin
                                    Result := -0.0065500870836341877;
                                end
                                else
                                begin
                                    Result := 0.014459281226400979;
                                end;
                            end
                            else
                            begin
                                if features[190] <= -533.49999999999989 then
                                begin
                                    Result := 0.017205949553129291;
                                end
                                else
                                begin
                                    Result := -0.014277067805280631;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0038421408558302708;
                    end;
                end
                else
                begin
                    Result := -0.0081001248822071669;
                end;
            end;
        end
        else
        begin
            if features[202] <= 31.500000000000004 then
            begin
                Result := -0.0071927324142294514;
            end
            else
            begin
                Result := 0.023478334529103494;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_232(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[184] <= 1246.5000000000002 then
    begin
        if features[47] <= 9300.5000000000018 then
        begin
            if features[105] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6126.4999999999991 then
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        if features[109] <= 53.500000000000007 then
                        begin
                            if features[201] <= -4686.4999999999991 then
                            begin
                                Result := -0.0037360673544283001;
                            end
                            else
                            begin
                                Result := 0.0039874893184753029;
                            end;
                        end
                        else
                        begin
                            Result := 0.0076623546296544333;
                        end;
                    end
                    else
                    begin
                        Result := 0.0066337499127356704;
                    end;
                end
                else
                begin
                    Result := -0.002051857629273555;
                end;
            end
            else
            begin
                if features[108] <= -288.49999999999994 then
                begin
                    if features[150] <= -13.499999999999998 then
                    begin
                        Result := 0.0035690605195029777;
                    end
                    else
                    begin
                        Result := -0.012654709387711649;
                    end;
                end
                else
                begin
                    if features[177] <= -4381.4999999999991 then
                    begin
                        if features[183] <= -8861.4999999999982 then
                        begin
                            Result := 0.015689948640948855;
                        end
                        else
                        begin
                            Result := -0.0027350659396127735;
                        end;
                    end
                    else
                    begin
                        Result := 0.038604023476171784;
                    end;
                end;
            end;
        end
        else
        begin
            if features[193] <= -1881.4999999999998 then
            begin
                if features[75] <= 6.5000000000000009 then
                begin
                    Result := 0.040598843518403788;
                end
                else
                begin
                    Result := -0.010825114649854382;
                end;
            end
            else
            begin
                if features[151] <= -25.499999999999996 then
                begin
                    Result := 0.0043715899747414945;
                end
                else
                begin
                    Result := -0.0012889988104848977;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.012236544170526095;
    end;
end;

function settled_top2_residual_tree_233(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1547.4999999999998 then
    begin
        Result := -0.016381665080585188;
    end
    else
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.023308419599049102;
        end
        else
        begin
            if features[129] <= 26338.500000000004 then
            begin
                if features[154] <= 40.500000000000007 then
                begin
                    if features[28] <= -7726.4999999999991 then
                    begin
                        if features[183] <= -9444.4999999999982 then
                        begin
                            if features[67] <= 1153.0000000000002 then
                            begin
                                if features[82] <= -8980.9999999999982 then
                                begin
                                    Result := 0.041472599639926305;
                                end
                                else
                                begin
                                    Result := 0.0075745431087574592;
                                end;
                            end
                            else
                            begin
                                if features[74] <= 8.5000000000000018 then
                                begin
                                    Result := -0.014803789265165471;
                                end
                                else
                                begin
                                    Result := 0.031673092312818639;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[201] <= -5144.4999999999991 then
                            begin
                                Result := -0.002452116492906567;
                            end
                            else
                            begin
                                Result := 0.025037680172302582;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0001255850763055531;
                    end;
                end
                else
                begin
                    if features[194] <= -5958.4999999999991 then
                    begin
                        Result := -0.010037416489879108;
                    end
                    else
                    begin
                        if features[36] <= 9.5000000000000018 then
                        begin
                            Result := 0.0053563832631224016;
                        end
                        else
                        begin
                            Result := -0.0032438460644061608;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[41] <= 1132.5000000000002 then
                begin
                    Result := 0.0050521299055999325;
                end
                else
                begin
                    if features[28] <= -5422.4999999999991 then
                    begin
                        Result := 0.069511893826158036;
                    end
                    else
                    begin
                        Result := 0.0018560692485132973;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_234(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[173] <= -6126.4999999999991 then
    begin
        if features[175] <= -423.49999999999994 then
        begin
            Result := 0.0035333078662612184;
        end
        else
        begin
            if features[169] <= 1.5000000000000002 then
            begin
                if features[191] <= -4235.4999999999991 then
                begin
                    Result := -0.0030438825319010145;
                end
                else
                begin
                    Result := 0.0095460474064335294;
                end;
            end
            else
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[108] <= -655.49999999999989 then
                    begin
                        if features[190] <= 2021.5000000000002 then
                        begin
                            Result := 0.036427351523026334;
                        end
                        else
                        begin
                            Result := -0.011187932099784968;
                        end;
                    end
                    else
                    begin
                        Result := 0.0056428779962364971;
                    end;
                end
                else
                begin
                    Result := -0.0054149429324768942;
                end;
            end;
        end;
    end
    else
    begin
        if features[108] <= -454.49999999999994 then
        begin
            Result := -0.0060812970337952707;
        end
        else
        begin
            if features[176] <= -8997.4999999999982 then
            begin
                Result := -0.0085221794819187076;
            end
            else
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    if features[185] <= 41.125000000000007 then
                    begin
                        if features[184] <= 195.50000000000003 then
                        begin
                            Result := 0.0015089208525419595;
                        end
                        else
                        begin
                            Result := -0.022311328051436277;
                        end;
                    end
                    else
                    begin
                        Result := 0.0086721331000316378;
                    end;
                end
                else
                begin
                    if features[189] <= -3965.4999999999995 then
                    begin
                        Result := -0.023569838032322672;
                    end
                    else
                    begin
                        if features[148] <= -1517.4999999999998 then
                        begin
                            Result := 0.022108981135362603;
                        end
                        else
                        begin
                            Result := -0.0057247824717436679;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_235(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[179] <= -4516.4999999999991 then
    begin
        if features[198] <= -3806.4999999999995 then
        begin
            if features[164] <= -57023309.999999993 then
            begin
                Result := -0.00114219944585836;
            end
            else
            begin
                if features[136] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.0023657020503954152;
                end
                else
                begin
                    Result := 0.0036223535602486383;
                end;
            end;
        end
        else
        begin
            if features[183] <= -6696.4999999999991 then
            begin
                Result := 0.033125559292966955;
            end
            else
            begin
                if features[192] <= -5653.4999999999991 then
                begin
                    if features[189] <= -5030.4999999999991 then
                    begin
                        Result := 0.045371320650716584;
                    end
                    else
                    begin
                        Result := 0.0039115880550785508;
                    end;
                end
                else
                begin
                    if features[175] <= -614.49999999999989 then
                    begin
                        Result := -0.010104393429932485;
                    end
                    else
                    begin
                        if features[148] <= -1558.4999999999998 then
                        begin
                            Result := 0.035613530696524086;
                        end
                        else
                        begin
                            Result := 0.0033237915065662937;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[200] <= -4354.4999999999991 then
        begin
            Result := -0.016713152023032848;
        end
        else
        begin
            if features[184] <= -954.49999999999989 then
            begin
                Result := -0.01119013850176951;
            end
            else
            begin
                if features[183] <= -4573.4999999999991 then
                begin
                    if features[129] <= -16739.999999999996 then
                    begin
                        if features[129] <= -27259.999999999996 then
                        begin
                            Result := 0.0038793505234818275;
                        end
                        else
                        begin
                            Result := 0.080099182844284245;
                        end;
                    end
                    else
                    begin
                        Result := 0.0082209423875658216;
                    end;
                end
                else
                begin
                    Result := -0.0055960115563349353;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_236(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[119] <= -1168.4999999999998 then
    begin
        Result := -0.017015575424973919;
    end
    else
    begin
        if features[123] <= -666.49999999999989 then
        begin
            Result := 0.034308511450313932;
        end
        else
        begin
            if features[145] <= -734.49999999999989 then
            begin
                Result := 0.010369022163677636;
            end
            else
            begin
                if features[90] <= -1.4999999999999998 then
                begin
                    Result := -0.0047146319683186591;
                end
                else
                begin
                    if features[188] <= -4387.4999999999991 then
                    begin
                        if features[171] <= 1.0000000180025095E-35 then
                        begin
                            if features[173] <= -5086.4999999999991 then
                            begin
                                if features[185] <= 26.166666984558109 then
                                begin
                                    if features[178] <= -947.49999999999989 then
                                    begin
                                        Result := 0.0038362699698356894;
                                    end
                                    else
                                    begin
                                        Result := -0.0077405142562348697;
                                    end;
                                end
                                else
                                begin
                                    if features[184] <= 399.50000000000006 then
                                    begin
                                        Result := 0.020794102357132839;
                                    end
                                    else
                                    begin
                                        Result := -0.001739119549009442;
                                    end;
                                end;
                            end
                            else
                            begin
                                Result := -0.021325011723887673;
                            end;
                        end
                        else
                        begin
                            if features[189] <= -4176.4999999999991 then
                            begin
                                Result := 0.0011050673864613765;
                            end
                            else
                            begin
                                Result := 0.01132107561473442;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[171] <= 1.5000000000000002 then
                        begin
                            if features[190] <= -1496.9999999999998 then
                            begin
                                if features[77] <= 3268.0000000000005 then
                                begin
                                    Result := 0.048203957537461234;
                                end
                                else
                                begin
                                    Result := 0.01047655668960226;
                                end;
                            end
                            else
                            begin
                                Result := 0.00017266165588860705;
                            end;
                        end
                        else
                        begin
                            Result := -0.0038785412203615581;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_237(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[47] <= 9300.5000000000018 then
    begin
        if features[9] <= 3.5000000000000004 then
        begin
            Result := -0.003022271492134345;
        end
        else
        begin
            if features[109] <= 99.500000000000014 then
            begin
                if features[172] <= 3.5000000000000004 then
                begin
                    Result := -0.0011714262415968315;
                end
                else
                begin
                    Result := 0.014416125127672581;
                end;
            end
            else
            begin
                if features[176] <= -5095.4999999999991 then
                begin
                    if features[194] <= -5644.4999999999991 then
                    begin
                        if features[184] <= 244.50000000000003 then
                        begin
                            Result := 0.031954127842712406;
                        end
                        else
                        begin
                            Result := 0.0089032837776183756;
                        end;
                    end
                    else
                    begin
                        if features[179] <= -7065.4999999999991 then
                        begin
                            Result := -0.0071127446455310208;
                        end
                        else
                        begin
                            Result := 0.009709557275138966;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.043523773048426195;
                end;
            end;
        end;
    end
    else
    begin
        if features[184] <= 1246.5000000000002 then
        begin
            if features[151] <= -25.499999999999996 then
            begin
                if features[189] <= -4016.4999999999995 then
                begin
                    Result := 0.0054082430736443633;
                end
                else
                begin
                    if features[190] <= -64.499999999999986 then
                    begin
                        Result := -0.023960884810961584;
                    end
                    else
                    begin
                        if features[48] <= 12823.500000000002 then
                        begin
                            Result := 0.014345391320996798;
                        end
                        else
                        begin
                            Result := -0.018633443522419673;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[184] <= -1404.4999999999998 then
                begin
                    Result := 0.013388093990084206;
                end
                else
                begin
                    Result := -0.0015070974474335366;
                end;
            end;
        end
        else
        begin
            Result := -0.025665584490775224;
        end;
    end;
end;

function settled_top2_residual_tree_238(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[183] <= -8861.4999999999982 then
    begin
        if features[192] <= -5798.4999999999991 then
        begin
            Result := 0.00034178062163442479;
        end
        else
        begin
            if features[180] <= -8769.4999999999982 then
            begin
                Result := 0.030172789837884906;
            end
            else
            begin
                Result := 0.0083738053370338312;
            end;
        end;
    end
    else
    begin
        if features[145] <= -734.49999999999989 then
        begin
            Result := 0.011546391860711627;
        end
        else
        begin
            if features[90] <= -1.4999999999999998 then
            begin
                Result := -0.0051271905512483519;
            end
            else
            begin
                if features[191] <= -4433.4999999999991 then
                begin
                    if features[120] <= -1423.4999999999998 then
                    begin
                        Result := 0.009375640086649973;
                    end
                    else
                    begin
                        if features[187] <= -77.944442749023423 then
                        begin
                            Result := -0.0090125946165505386;
                        end
                        else
                        begin
                            Result := -0.00044584470392229798;
                        end;
                    end;
                end
                else
                begin
                    if features[189] <= -4016.4999999999995 then
                    begin
                        if features[176] <= -7106.4999999999991 then
                        begin
                            Result := -0.0095595972681013948;
                        end
                        else
                        begin
                            if features[178] <= -638.49999999999989 then
                            begin
                                if features[174] <= -4498.4999999999991 then
                                begin
                                    Result := 0.001068139114881335;
                                end
                                else
                                begin
                                    Result := 0.041830667040814569;
                                end;
                            end
                            else
                            begin
                                if features[95] <= -164509495.99999997 then
                                begin
                                    if features[0] <= 83619.500000000015 then
                                    begin
                                        Result := 0.06328629776200774;
                                    end
                                    else
                                    begin
                                        Result := 0.0014846070800550787;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.012256846112706304;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.0070501534615315543;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_239(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.023293113327561846;
    end
    else
    begin
        if features[183] <= -8861.4999999999982 then
        begin
            if features[192] <= -5798.4999999999991 then
            begin
                if features[189] <= -6876.4999999999991 then
                begin
                    if features[40] <= 1285.5000000000002 then
                    begin
                        if features[126] <= -1.0000000180025095E-35 then
                        begin
                            Result := 0.057204652883133172;
                        end
                        else
                        begin
                            Result := 0.01461197305738215;
                        end;
                    end
                    else
                    begin
                        Result := -0.012212757970886973;
                    end;
                end
                else
                begin
                    if features[153] <= 39.500000000000007 then
                    begin
                        Result := 0.00090711096560455815;
                    end
                    else
                    begin
                        Result := -0.014884369584297133;
                    end;
                end;
            end
            else
            begin
                if features[26] <= 2.5000000000000004 then
                begin
                    if features[191] <= -5292.4999999999991 then
                    begin
                        if features[27] <= -6848.4999999999991 then
                        begin
                            Result := -0.013615689762855413;
                        end
                        else
                        begin
                            Result := 0.029286050707396205;
                        end;
                    end
                    else
                    begin
                        Result := -0.010558753482748411;
                    end;
                end
                else
                begin
                    if features[180] <= -9057.4999999999982 then
                    begin
                        Result := 0.049606187634814947;
                    end
                    else
                    begin
                        Result := 0.015101863045110015;
                    end;
                end;
            end;
        end
        else
        begin
            if features[145] <= -1428.9999999999998 then
            begin
                Result := 0.018201277913810942;
            end
            else
            begin
                if features[67] <= 1380.5000000000002 then
                begin
                    if features[180] <= -5731.4999999999991 then
                    begin
                        Result := 0.00015446392338609757;
                    end
                    else
                    begin
                        Result := 0.0074090904890702974;
                    end;
                end
                else
                begin
                    Result := -0.0015095698781390282;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_240(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[66] <= 1218.0000000000002 then
    begin
        if features[54] <= 11.500000000000002 then
        begin
            if features[147] <= -1717.4999999999998 then
            begin
                Result := 0.029429780463036986;
            end
            else
            begin
                if features[94] <= 163809.50000000003 then
                begin
                    if features[179] <= -7441.4999999999991 then
                    begin
                        Result := -0.0016856749885518947;
                    end
                    else
                    begin
                        if features[193] <= 30.500000000000004 then
                        begin
                            if features[173] <= -6244.4999999999991 then
                            begin
                                Result := 0.0057593011006101535;
                            end
                            else
                            begin
                                if features[92] <= 2.5000000000000004 then
                                begin
                                    Result := -0.00077226626828958388;
                                end
                                else
                                begin
                                    Result := 0.025996043037503653;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.0021515453057681772;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0089548893773982435;
                end;
            end;
        end
        else
        begin
            if features[199] <= -289.49999999999994 then
            begin
                Result := -0.0061169698712576197;
            end
            else
            begin
                if features[148] <= 1353.5000000000002 then
                begin
                    if features[108] <= 128.50000000000003 then
                    begin
                        if features[175] <= 1243.5000000000002 then
                        begin
                            if features[202] <= 244.50000000000003 then
                            begin
                                Result := 0.0023729693705580798;
                            end
                            else
                            begin
                                Result := 0.017627590375905305;
                            end;
                        end
                        else
                        begin
                            Result := -0.012247660584944186;
                        end;
                    end
                    else
                    begin
                        if features[147] <= 162.50000000000003 then
                        begin
                            Result := 0.026321692862978759;
                        end
                        else
                        begin
                            Result := -0.0058035741714525784;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.030179226929620325;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.011817923161034062;
    end;
end;

function settled_top2_residual_tree_241(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[185] <= -399.74999999999994 then
    begin
        if features[174] <= -8119.4999999999991 then
        begin
            if features[195] <= -5521.4999999999991 then
            begin
                Result := -0.0031188648669816664;
            end
            else
            begin
                if features[47] <= 2725.5000000000005 then
                begin
                    Result := 0.059926791930309004;
                end
                else
                begin
                    if features[189] <= -4748.4999999999991 then
                    begin
                        if features[199] <= -961.49999999999989 then
                        begin
                            Result := -0.023175579156792307;
                        end
                        else
                        begin
                            if features[184] <= -1475.4999999999998 then
                            begin
                                if features[178] <= -3144.4999999999995 then
                                begin
                                    Result := 0.0021605202384047261;
                                end
                                else
                                begin
                                    Result := 0.039294218028666034;
                                end;
                            end
                            else
                            begin
                                Result := 0.0082483225664844399;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.012500802721317426;
                    end;
                end;
            end;
        end
        else
        begin
            if features[170] <= 5.5000000000000009 then
            begin
                if features[1] <= 225252.00000000003 then
                begin
                    Result := -0.0029326495591319099;
                end
                else
                begin
                    Result := 0.029960733233703924;
                end;
            end
            else
            begin
                Result := -0.012312414371523616;
            end;
        end;
    end
    else
    begin
        if features[184] <= -1244.4999999999998 then
        begin
            if features[190] <= -1186.4999999999998 then
            begin
                if features[0] <= 49840.000000000007 then
                begin
                    Result := 0.084556360461727417;
                end
                else
                begin
                    Result := 0.022821988595603252;
                end;
            end
            else
            begin
                if features[178] <= -862.49999999999989 then
                begin
                    Result := 0.0042800204792318251;
                end
                else
                begin
                    Result := 0.043816239626496466;
                end;
            end;
        end
        else
        begin
            Result := 0.00063603952590906177;
        end;
    end;
end;

function settled_top2_residual_tree_242(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[178] <= 539.50000000000011 then
    begin
        if features[109] <= 113.50000000000001 then
        begin
            if features[173] <= -5591.4999999999991 then
            begin
                Result := 0.00085385875496728637;
            end
            else
            begin
                Result := -0.0025927482172009033;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[148] <= -1427.4999999999998 then
                begin
                    Result := 0.054547479408329096;
                end
                else
                begin
                    if features[197] <= -5143.4999999999991 then
                    begin
                        if features[151] <= -47.499999999999993 then
                        begin
                            Result := 0.042140493924314334;
                        end
                        else
                        begin
                            Result := 0.00088211729246576252;
                        end;
                    end
                    else
                    begin
                        Result := -0.0005039299154080886;
                    end;
                end;
            end
            else
            begin
                if features[184] <= 527.50000000000011 then
                begin
                    if features[151] <= -276.49999999999994 then
                    begin
                        Result := -0.018653187083469563;
                    end
                    else
                    begin
                        Result := 0.0088258745817581443;
                    end;
                end
                else
                begin
                    if features[194] <= -5547.4999999999991 then
                    begin
                        Result := 0.026346407042609279;
                    end
                    else
                    begin
                        Result := -0.01306021788944242;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[185] <= 204.16666412353518 then
        begin
            Result := -0.0057949283016444841;
        end
        else
        begin
            if features[75] <= 6.5000000000000009 then
            begin
                Result := -0.0027745491476665884;
            end
            else
            begin
                if features[198] <= -5895.4999999999991 then
                begin
                    if features[164] <= -94912271.999999985 then
                    begin
                        Result := 0.0018233653535937888;
                    end
                    else
                    begin
                        Result := 0.050882955318476586;
                    end;
                end
                else
                begin
                    Result := 0.0043951274176992758;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_243(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[173] <= -6126.4999999999991 then
    begin
        if features[173] <= -7695.4999999999991 then
        begin
            if features[194] <= -3425.4999999999995 then
            begin
                if features[173] <= -7705.9999999999991 then
                begin
                    Result := -0.0013079204434615537;
                end
                else
                begin
                    Result := -0.018827680518908804;
                end;
            end
            else
            begin
                if features[176] <= -7214.4999999999991 then
                begin
                    Result := -0.020244715298742125;
                end
                else
                begin
                    if features[189] <= -5081.4999999999991 then
                    begin
                        Result := 0.10268619555051402;
                    end
                    else
                    begin
                        Result := 0.015317418051912848;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.0026961461106028675;
        end;
    end
    else
    begin
        if features[185] <= -399.74999999999994 then
        begin
            Result := -0.0072060263116511501;
        end
        else
        begin
            if features[174] <= -6022.4999999999991 then
            begin
                if features[174] <= -6091.4999999999991 then
                begin
                    if features[189] <= -4220.4999999999991 then
                    begin
                        if features[192] <= -5886.4999999999991 then
                        begin
                            Result := -0.0087878443924883417;
                        end
                        else
                        begin
                            if features[47] <= 5484.5000000000009 then
                            begin
                                Result := -0.004937441868992835;
                            end
                            else
                            begin
                                if features[182] <= -7732.4999999999991 then
                                begin
                                    Result := 0.037923340765905339;
                                end
                                else
                                begin
                                    Result := 0.0044662305002861015;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.0070722468300795198;
                    end;
                end
                else
                begin
                    Result := -0.021540614075653594;
                end;
            end
            else
            begin
                if features[67] <= 1126.5000000000002 then
                begin
                    Result := 0.0082108434201741739;
                end
                else
                begin
                    Result := -0.0016411845631672608;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_244(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[147] <= -1717.4999999999998 then
    begin
        Result := 0.031299635797009888;
    end
    else
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.024500620930531639;
        end
        else
        begin
            if features[202] <= -1043.4999999999998 then
            begin
                Result := -0.011679561062575713;
            end
            else
            begin
                if features[191] <= -4433.4999999999991 then
                begin
                    if features[176] <= -5095.4999999999991 then
                    begin
                        Result := 0.00020902124815814138;
                    end
                    else
                    begin
                        Result := -0.0086434273906169975;
                    end;
                end
                else
                begin
                    if features[173] <= -5531.4999999999991 then
                    begin
                        if features[173] <= -5675.9999999999991 then
                        begin
                            if features[179] <= -6713.4999999999991 then
                            begin
                                Result := -0.0026728559282055467;
                            end
                            else
                            begin
                                if features[13] <= 149311.00000000003 then
                                begin
                                    if features[109] <= -101.49999999999999 then
                                    begin
                                        Result := 0.0054341463630936011;
                                    end
                                    else
                                    begin
                                        Result := 0.021960697334623785;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.012053099232325131;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[47] <= 6887.5000000000009 then
                            begin
                                Result := 0.0064772053072231902;
                            end
                            else
                            begin
                                if features[192] <= -4723.4999999999991 then
                                begin
                                    Result := 0.092544617980858154;
                                end
                                else
                                begin
                                    Result := 0.027295460770123455;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[90] <= 5.5000000000000009 then
                        begin
                            Result := -0.005119595215346052;
                        end
                        else
                        begin
                            if features[163] <= -91519575.999999985 then
                            begin
                                Result := 0.053556686250354549;
                            end
                            else
                            begin
                                Result := 0.0030644321737170331;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_245(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[201] <= -4006.4999999999995 then
    begin
        if features[164] <= -20456594.999999996 then
        begin
            if features[42] <= 866.00000000000011 then
            begin
                if features[185] <= -399.74999999999994 then
                begin
                    Result := -0.0041265168126142738;
                end
                else
                begin
                    if features[184] <= -1244.4999999999998 then
                    begin
                        Result := 0.016405773567087088;
                    end
                    else
                    begin
                        Result := -0.00074516695506224653;
                    end;
                end;
            end
            else
            begin
                Result := 0.030471285064742577;
            end;
        end
        else
        begin
            if features[154] <= -45.499999999999993 then
            begin
                if features[183] <= -6919.4999999999991 then
                begin
                    if features[184] <= -742.49999999999989 then
                    begin
                        Result := 0.041943397701039449;
                    end
                    else
                    begin
                        Result := 0.010539893316630272;
                    end;
                end
                else
                begin
                    Result := -0.0011367759562942344;
                end;
            end
            else
            begin
                Result := 2.3334885478246906E-05;
            end;
        end;
    end
    else
    begin
        if features[200] <= -3876.4999999999995 then
        begin
            Result := 0.010080062093771148;
        end
        else
        begin
            if features[174] <= -3442.9999999999995 then
            begin
                if features[9] <= 20.500000000000004 then
                begin
                    if features[202] <= -653.49999999999989 then
                    begin
                        Result := -0.019054765274371208;
                    end
                    else
                    begin
                        if features[175] <= -962.49999999999989 then
                        begin
                            Result := 0.005332828971770536;
                        end
                        else
                        begin
                            Result := -0.0038688520945475303;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.054700762444820375;
                end;
            end
            else
            begin
                if features[202] <= -88.499999999999986 then
                begin
                    Result := 0.059923470701850501;
                end
                else
                begin
                    Result := -0.00027095885601946231;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_246(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[9] <= 2.5000000000000004 then
    begin
        if features[128] <= -19.499999999999996 then
        begin
            Result := -0.0049458447231922409;
        end
        else
        begin
            if features[175] <= -890.49999999999989 then
            begin
                if features[169] <= 1.5000000000000002 then
                begin
                    if features[175] <= -1071.4999999999998 then
                    begin
                        if features[181] <= -448.49999999999994 then
                        begin
                            if features[186] <= -302.83332824707026 then
                            begin
                                if features[175] <= -1366.4999999999998 then
                                begin
                                    if features[158] <= 1645.5000000000002 then
                                    begin
                                        Result := 0.0028326031499819799;
                                    end
                                    else
                                    begin
                                        Result := 0.0267676687670097;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.016583584228821762;
                                end;
                            end
                            else
                            begin
                                Result := 0.02055061351728173;
                            end;
                        end
                        else
                        begin
                            Result := 0.00093219573197122661;
                        end;
                    end
                    else
                    begin
                        if features[171] <= 7.5000000000000009 then
                        begin
                            if features[174] <= -7485.4999999999991 then
                            begin
                                Result := 0.013679515908765425;
                            end
                            else
                            begin
                                Result := 0.047966250766711446;
                            end;
                        end
                        else
                        begin
                            Result := -0.01859329736530662;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0046158329844275762;
                end;
            end
            else
            begin
                if features[175] <= -863.49999999999989 then
                begin
                    Result := -0.022811470322323626;
                end
                else
                begin
                    if features[191] <= -4433.4999999999991 then
                    begin
                        Result := -0.0026200402405111324;
                    end
                    else
                    begin
                        Result := 0.0092310469258113578;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[129] <= 14589.500000000002 then
        begin
            Result := 0.00101753096218153;
        end
        else
        begin
            Result := 0.036353482318939125;
        end;
    end;
end;

function settled_top2_residual_tree_247(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[149] <= -819.99999999999989 then
    begin
        Result := -0.026592677973904594;
    end
    else
    begin
        if features[199] <= -1426.4999999999998 then
        begin
            Result := -0.014489752957102357;
        end
        else
        begin
            if features[199] <= 484.50000000000006 then
            begin
                if features[176] <= -9527.4999999999982 then
                begin
                    if features[189] <= -4970.4999999999991 then
                    begin
                        Result := -0.0079208316316011756;
                    end
                    else
                    begin
                        Result := 0.0043226493919363883;
                    end;
                end
                else
                begin
                    if features[189] <= -6287.4999999999991 then
                    begin
                        if features[174] <= -7273.4999999999991 then
                        begin
                            Result := 0.0040973313026636321;
                        end
                        else
                        begin
                            if features[29] <= -6061.4999999999991 then
                            begin
                                Result := 0.053225559884788526;
                            end
                            else
                            begin
                                Result := 0.0059272899747815685;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[186] <= -756.49999999999989 then
                        begin
                            if features[0] <= 2117.5000000000005 then
                            begin
                                Result := 0.051255232012216025;
                            end
                            else
                            begin
                                if features[190] <= -1089.4999999999998 then
                                begin
                                    Result := 0.014528013425628053;
                                end
                                else
                                begin
                                    Result := -0.011098383142104561;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := 0.00024758765666651989;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[177] <= -6319.4999999999991 then
                begin
                    if features[201] <= -5221.4999999999991 then
                    begin
                        if features[0] <= 25936.000000000004 then
                        begin
                            Result := 0.013087431336413541;
                        end
                        else
                        begin
                            Result := -0.0089578168683837039;
                        end;
                    end
                    else
                    begin
                        Result := 0.011150264815878167;
                    end;
                end
                else
                begin
                    Result := -0.0070790854391844368;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_248(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[189] <= -6408.4999999999991 then
    begin
        if features[181] <= -2039.4999999999998 then
        begin
            if features[175] <= -2865.9999999999995 then
            begin
                Result := -0.00078599211749507672;
            end
            else
            begin
                if features[18] <= 7.5000000000000009 then
                begin
                    if features[28] <= -6523.4999999999991 then
                    begin
                        Result := 0.016274505620380936;
                    end
                    else
                    begin
                        Result := 0.085458305737335122;
                    end;
                end
                else
                begin
                    Result := 0.015181091819590684;
                end;
            end;
        end
        else
        begin
            if features[174] <= -7273.4999999999991 then
            begin
                if features[129] <= 11113.500000000002 then
                begin
                    if features[195] <= -4216.4999999999991 then
                    begin
                        if features[164] <= -168846951.99999997 then
                        begin
                            Result := -0.009962186006496768;
                        end
                        else
                        begin
                            if features[157] <= -1.4999999999999998 then
                            begin
                                Result := -0.01485319329608671;
                            end
                            else
                            begin
                                if features[200] <= -4308.4999999999991 then
                                begin
                                    Result := 0.0065447613279035755;
                                end
                                else
                                begin
                                    Result := -0.014794666598762513;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.039337740793525755;
                    end;
                end
                else
                begin
                    if features[164] <= -24976078.999999996 then
                    begin
                        Result := 0.0024783301668123816;
                    end
                    else
                    begin
                        Result := 0.048586099279383309;
                    end;
                end;
            end
            else
            begin
                if features[28] <= -6523.4999999999991 then
                begin
                    Result := 0.057984297166575154;
                end
                else
                begin
                    Result := 0.01065360255972839;
                end;
            end;
        end;
    end
    else
    begin
        if features[186] <= -756.49999999999989 then
        begin
            Result := -0.0069820885679998893;
        end
        else
        begin
            Result := -0.00025858068661922985;
        end;
    end;
end;

function settled_top2_residual_tree_249(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[143] <= -1.0000000180025095E-35 then
    begin
        Result := 0.0066630802409789096;
    end
    else
    begin
        if features[158] <= -2464.4999999999995 then
        begin
            if features[188] <= -6024.4999999999991 then
            begin
                Result := -0.015364816123624017;
            end
            else
            begin
                if features[199] <= 277.50000000000006 then
                begin
                    if features[176] <= -9156.4999999999982 then
                    begin
                        Result := -0.018933308122057707;
                    end
                    else
                    begin
                        if features[180] <= -7466.4999999999991 then
                        begin
                            if features[195] <= -6128.4999999999991 then
                            begin
                                Result := -0.0068963292966537446;
                            end
                            else
                            begin
                                Result := 0.010838513417031539;
                            end;
                        end
                        else
                        begin
                            Result := -0.008028958588786687;
                        end;
                    end;
                end
                else
                begin
                    if features[45] <= 3.5000000000000004 then
                    begin
                        Result := -0.0019534866953044056;
                    end
                    else
                    begin
                        Result := 0.031183543759749872;
                    end;
                end;
            end;
        end
        else
        begin
            if features[164] <= -24976078.999999996 then
            begin
                Result := -0.00026739970367474448;
            end
            else
            begin
                if features[178] <= -1121.4999999999998 then
                begin
                    if features[37] <= 3.5000000000000004 then
                    begin
                        if features[188] <= -4387.4999999999991 then
                        begin
                            Result := 0.042140080791678726;
                        end
                        else
                        begin
                            Result := -0.0013709051156325269;
                        end;
                    end
                    else
                    begin
                        Result := 0.007816203161613678;
                    end;
                end
                else
                begin
                    if features[28] <= -6967.4999999999991 then
                    begin
                        Result := 0.012413516437663492;
                    end
                    else
                    begin
                        if features[15] <= -100273023.99999999 then
                        begin
                            Result := 0.039556865484349113;
                        end
                        else
                        begin
                            Result := -0.00059361580540060832;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_250(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[119] <= -1183.4999999999998 then
    begin
        Result := -0.017038113363589773;
    end
    else
    begin
        if features[123] <= -666.49999999999989 then
        begin
            if features[183] <= -6362.4999999999991 then
            begin
                Result := -0.0027632686817007993;
            end
            else
            begin
                Result := 0.048868845883144468;
            end;
        end
        else
        begin
            if features[201] <= -4006.4999999999995 then
            begin
                if features[108] <= 128.50000000000003 then
                begin
                    Result := -0.0011485376631202397;
                end
                else
                begin
                    if features[182] <= -5796.4999999999991 then
                    begin
                        if features[200] <= -5784.4999999999991 then
                        begin
                            if features[188] <= -5207.4999999999991 then
                            begin
                                if features[77] <= 41062.500000000007 then
                                begin
                                    Result := -0.00014453500129278378;
                                end
                                else
                                begin
                                    Result := 0.031895739834632141;
                                end;
                            end
                            else
                            begin
                                if features[177] <= -9236.4999999999982 then
                                begin
                                    Result := -0.0031039897222230875;
                                end
                                else
                                begin
                                    Result := 0.029462699912600272;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[189] <= -5225.4999999999991 then
                            begin
                                if features[170] <= 4.5000000000000009 then
                                begin
                                    Result := -0.011576320316064087;
                                end
                                else
                                begin
                                    Result := 0.00096221050002642501;
                                end;
                            end
                            else
                            begin
                                Result := 0.0034074389757642026;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := 0.020935157605715026;
                    end;
                end;
            end
            else
            begin
                if features[178] <= -315.49999999999994 then
                begin
                    if features[179] <= -4083.4999999999995 then
                    begin
                        Result := 0.0083517168490741776;
                    end
                    else
                    begin
                        Result := -0.0072102420906822416;
                    end;
                end
                else
                begin
                    Result := -0.0015205357220943296;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_251(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[199] <= -1547.4999999999998 then
    begin
        Result := -0.01795437395433724;
    end
    else
    begin
        if features[194] <= -3013.4999999999995 then
        begin
            if features[122] <= -1141.4999999999998 then
            begin
                if features[171] <= 2.5000000000000004 then
                begin
                    if features[191] <= -4510.4999999999991 then
                    begin
                        Result := -0.017102084519801903;
                    end
                    else
                    begin
                        if features[185] <= 85.250000000000014 then
                        begin
                            Result := -0.0055595311315864183;
                        end
                        else
                        begin
                            Result := 0.040300360546845833;
                        end;
                    end;
                end
                else
                begin
                    if features[120] <= -262.49999999999994 then
                    begin
                        if features[95] <= -172659311.99999997 then
                        begin
                            Result := 0.051442272570362914;
                        end
                        else
                        begin
                            if features[45] <= 4.5000000000000009 then
                            begin
                                if features[187] <= -204.74999999999997 then
                                begin
                                    Result := -0.003807143665668053;
                                end
                                else
                                begin
                                    Result := 0.037737334215696638;
                                end;
                            end
                            else
                            begin
                                Result := -0.0035030999473636146;
                            end;
                        end;
                    end
                    else
                    begin
                        if features[69] <= 23.500000000000004 then
                        begin
                            Result := -0.0060264125889039864;
                        end
                        else
                        begin
                            Result := 0.027721733657139383;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.00031720185077657492;
            end;
        end
        else
        begin
            if features[173] <= -6467.4999999999991 then
            begin
                if features[200] <= -3202.4999999999995 then
                begin
                    Result := 0.064567995087699323;
                end
                else
                begin
                    Result := 0.0002066323557840226;
                end;
            end
            else
            begin
                if features[0] <= 177603.50000000003 then
                begin
                    Result := -0.0034653805423209682;
                end
                else
                begin
                    Result := 0.035775156435589733;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_252(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[92] <= -1.4999999999999998 then
    begin
        Result := -0.010141390208521478;
    end
    else
    begin
        if features[149] <= -819.99999999999989 then
        begin
            Result := -0.024152817093411067;
        end
        else
        begin
            if features[189] <= -6241.4999999999991 then
            begin
                if features[180] <= -5434.4999999999991 then
                begin
                    if features[174] <= -6719.4999999999991 then
                    begin
                        if features[178] <= -198.49999999999997 then
                        begin
                            if features[175] <= -3197.9999999999995 then
                            begin
                                Result := -0.0015420990864741676;
                            end
                            else
                            begin
                                Result := 0.010162124435347589;
                            end;
                        end
                        else
                        begin
                            Result := -0.0041766026197317284;
                        end;
                    end
                    else
                    begin
                        if features[105] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.057928318729049071;
                        end
                        else
                        begin
                            Result := -0.005768557685471503;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.06206836089601081;
                end;
            end
            else
            begin
                if features[199] <= -815.49999999999989 then
                begin
                    if features[177] <= -6558.4999999999991 then
                    begin
                        Result := -0.011160714641824792;
                    end
                    else
                    begin
                        if features[201] <= -4839.4999999999991 then
                        begin
                            if features[47] <= 4982.5000000000009 then
                            begin
                                Result := -0.0062909253846713782;
                            end
                            else
                            begin
                                if features[0] <= 58207.500000000007 then
                                begin
                                    Result := 0.12536225192024672;
                                end
                                else
                                begin
                                    Result := 0.027155725518409751;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.0060685500092339285;
                        end;
                    end;
                end
                else
                begin
                    if features[189] <= -6155.4999999999991 then
                    begin
                        Result := -0.012134383676245829;
                    end
                    else
                    begin
                        Result := 0.00046853682977496199;
                    end;
                end;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_253(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[200] <= -3245.4999999999995 then
    begin
        if features[194] <= -3013.4999999999995 then
        begin
            if features[179] <= -4083.4999999999995 then
            begin
                if features[129] <= -28214.499999999996 then
                begin
                    Result := -0.0069148800418822459;
                end
                else
                begin
                    if features[195] <= -4507.4999999999991 then
                    begin
                        Result := 2.334255430149101E-05;
                    end
                    else
                    begin
                        if features[27] <= -5172.4999999999991 then
                        begin
                            Result := 0.011720581267249968;
                        end
                        else
                        begin
                            Result := 0.0011199264872048123;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[108] <= 86.500000000000014 then
                begin
                    Result := -0.014025343063176574;
                end
                else
                begin
                    Result := 0.042707170356488834;
                end;
            end;
        end
        else
        begin
            if features[129] <= -20580.499999999996 then
            begin
                Result := 0.072366063816954124;
            end
            else
            begin
                if features[173] <= -6206.4999999999991 then
                begin
                    if features[199] <= -815.49999999999989 then
                    begin
                        Result := 0.0;
                    end
                    else
                    begin
                        Result := 0.082282692038986555;
                    end;
                end
                else
                begin
                    Result := -0.0058746840070500609;
                end;
            end;
        end;
    end
    else
    begin
        if features[174] <= -3442.9999999999995 then
        begin
            if features[199] <= -246.49999999999997 then
            begin
                Result := -0.013746675523378396;
            end
            else
            begin
                if features[164] <= -211178855.99999997 then
                begin
                    if features[69] <= 9.5000000000000018 then
                    begin
                        Result := -0.00071703721552534097;
                    end
                    else
                    begin
                        Result := 0.044494487543963845;
                    end;
                end
                else
                begin
                    Result := -0.0071075073694499271;
                end;
            end;
        end
        else
        begin
            Result := 0.044609696243231502;
        end;
    end;
end;

function settled_top2_residual_tree_254(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[188] <= -5423.4999999999991 then
    begin
        if features[69] <= 24.500000000000004 then
        begin
            Result := -0.0011462335668836333;
        end
        else
        begin
            if features[198] <= -4808.4999999999991 then
            begin
                Result := -0.02146930357348914;
            end
            else
            begin
                Result := 0.010725202310028452;
            end;
        end;
    end
    else
    begin
        if features[175] <= 2451.5000000000005 then
        begin
            if features[175] <= 2219.5000000000005 then
            begin
                if features[173] <= -6126.4999999999991 then
                begin
                    if features[202] <= 163.50000000000003 then
                    begin
                        if features[175] <= 2195.5000000000005 then
                        begin
                            if features[175] <= -190.49999999999997 then
                            begin
                                if features[190] <= 270.50000000000006 then
                                begin
                                    Result := 0.0030952975711264347;
                                end
                                else
                                begin
                                    Result := 0.021391907011234612;
                                end;
                            end
                            else
                            begin
                                Result := -0.0023021751462988303;
                            end;
                        end
                        else
                        begin
                            Result := 0.032761258280930461;
                        end;
                    end
                    else
                    begin
                        Result := 0.010288298265165511;
                    end;
                end
                else
                begin
                    if features[176] <= -9156.4999999999982 then
                    begin
                        Result := -0.0099813428058199705;
                    end
                    else
                    begin
                        if features[108] <= 98.500000000000014 then
                        begin
                            if features[181] <= -212.49999999999997 then
                            begin
                                Result := 0.00016616174194423927;
                            end
                            else
                            begin
                                Result := -0.0065719623120148972;
                            end;
                        end
                        else
                        begin
                            Result := 0.0084056188696612997;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.012707242583611734;
            end;
        end
        else
        begin
            if features[173] <= -9123.4999999999982 then
            begin
                Result := -0.01656216676848344;
            end
            else
            begin
                Result := 0.015071282207260617;
            end;
        end;
    end;
end;

function settled_top2_residual_tree_255(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    if features[66] <= 1165.0000000000002 then
    begin
        if features[199] <= -1807.4999999999998 then
        begin
            Result := -0.023818580212381431;
        end
        else
        begin
            if features[90] <= 12.500000000000002 then
            begin
                if features[146] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0057672277082967951;
                end
                else
                begin
                    if features[90] <= -1.4999999999999998 then
                    begin
                        if features[195] <= -3849.4999999999995 then
                        begin
                            if features[15] <= -49368441.999999993 then
                            begin
                                Result := 0.019197541285115402;
                            end
                            else
                            begin
                                Result := -0.0080874727875728785;
                            end;
                        end
                        else
                        begin
                            Result := 0.023921614840856403;
                        end;
                    end
                    else
                    begin
                        if features[189] <= -4016.4999999999995 then
                        begin
                            if features[28] <= -4896.4999999999991 then
                            begin
                                Result := -0.00030730242840136903;
                            end
                            else
                            begin
                                if features[193] <= 16.500000000000004 then
                                begin
                                    Result := 0.010749327508213734;
                                end
                                else
                                begin
                                    Result := -0.0034778937032276338;
                                end;
                            end;
                        end
                        else
                        begin
                            if features[189] <= -3965.4999999999995 then
                            begin
                                Result := -0.019193475034289295;
                            end
                            else
                            begin
                                if features[171] <= 9.5000000000000018 then
                                begin
                                    Result := -0.0033313018299491203;
                                end
                                else
                                begin
                                    if features[191] <= -4542.4999999999991 then
                                    begin
                                        Result := 0.034436237404718358;
                                    end
                                    else
                                    begin
                                        Result := -0.0072126438993954621;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[192] <= -5028.4999999999991 then
                begin
                    Result := 0.0015989718169849558;
                end
                else
                begin
                    Result := 0.021645559249845583;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.012115816160987497;
    end;
end;
function long_settled_top2_residual_score(
    const features: TncLongSettledTop2ResidualFeatures): Double;
begin
    Result := 0.0;
    Result := Result + settled_top2_residual_tree_0(features);
    Result := Result + settled_top2_residual_tree_1(features);
    Result := Result + settled_top2_residual_tree_2(features);
    Result := Result + settled_top2_residual_tree_3(features);
    Result := Result + settled_top2_residual_tree_4(features);
    Result := Result + settled_top2_residual_tree_5(features);
    Result := Result + settled_top2_residual_tree_6(features);
    Result := Result + settled_top2_residual_tree_7(features);
    Result := Result + settled_top2_residual_tree_8(features);
    Result := Result + settled_top2_residual_tree_9(features);
    Result := Result + settled_top2_residual_tree_10(features);
    Result := Result + settled_top2_residual_tree_11(features);
    Result := Result + settled_top2_residual_tree_12(features);
    Result := Result + settled_top2_residual_tree_13(features);
    Result := Result + settled_top2_residual_tree_14(features);
    Result := Result + settled_top2_residual_tree_15(features);
    Result := Result + settled_top2_residual_tree_16(features);
    Result := Result + settled_top2_residual_tree_17(features);
    Result := Result + settled_top2_residual_tree_18(features);
    Result := Result + settled_top2_residual_tree_19(features);
    Result := Result + settled_top2_residual_tree_20(features);
    Result := Result + settled_top2_residual_tree_21(features);
    Result := Result + settled_top2_residual_tree_22(features);
    Result := Result + settled_top2_residual_tree_23(features);
    Result := Result + settled_top2_residual_tree_24(features);
    Result := Result + settled_top2_residual_tree_25(features);
    Result := Result + settled_top2_residual_tree_26(features);
    Result := Result + settled_top2_residual_tree_27(features);
    Result := Result + settled_top2_residual_tree_28(features);
    Result := Result + settled_top2_residual_tree_29(features);
    Result := Result + settled_top2_residual_tree_30(features);
    Result := Result + settled_top2_residual_tree_31(features);
    Result := Result + settled_top2_residual_tree_32(features);
    Result := Result + settled_top2_residual_tree_33(features);
    Result := Result + settled_top2_residual_tree_34(features);
    Result := Result + settled_top2_residual_tree_35(features);
    Result := Result + settled_top2_residual_tree_36(features);
    Result := Result + settled_top2_residual_tree_37(features);
    Result := Result + settled_top2_residual_tree_38(features);
    Result := Result + settled_top2_residual_tree_39(features);
    Result := Result + settled_top2_residual_tree_40(features);
    Result := Result + settled_top2_residual_tree_41(features);
    Result := Result + settled_top2_residual_tree_42(features);
    Result := Result + settled_top2_residual_tree_43(features);
    Result := Result + settled_top2_residual_tree_44(features);
    Result := Result + settled_top2_residual_tree_45(features);
    Result := Result + settled_top2_residual_tree_46(features);
    Result := Result + settled_top2_residual_tree_47(features);
    Result := Result + settled_top2_residual_tree_48(features);
    Result := Result + settled_top2_residual_tree_49(features);
    Result := Result + settled_top2_residual_tree_50(features);
    Result := Result + settled_top2_residual_tree_51(features);
    Result := Result + settled_top2_residual_tree_52(features);
    Result := Result + settled_top2_residual_tree_53(features);
    Result := Result + settled_top2_residual_tree_54(features);
    Result := Result + settled_top2_residual_tree_55(features);
    Result := Result + settled_top2_residual_tree_56(features);
    Result := Result + settled_top2_residual_tree_57(features);
    Result := Result + settled_top2_residual_tree_58(features);
    Result := Result + settled_top2_residual_tree_59(features);
    Result := Result + settled_top2_residual_tree_60(features);
    Result := Result + settled_top2_residual_tree_61(features);
    Result := Result + settled_top2_residual_tree_62(features);
    Result := Result + settled_top2_residual_tree_63(features);
    Result := Result + settled_top2_residual_tree_64(features);
    Result := Result + settled_top2_residual_tree_65(features);
    Result := Result + settled_top2_residual_tree_66(features);
    Result := Result + settled_top2_residual_tree_67(features);
    Result := Result + settled_top2_residual_tree_68(features);
    Result := Result + settled_top2_residual_tree_69(features);
    Result := Result + settled_top2_residual_tree_70(features);
    Result := Result + settled_top2_residual_tree_71(features);
    Result := Result + settled_top2_residual_tree_72(features);
    Result := Result + settled_top2_residual_tree_73(features);
    Result := Result + settled_top2_residual_tree_74(features);
    Result := Result + settled_top2_residual_tree_75(features);
    Result := Result + settled_top2_residual_tree_76(features);
    Result := Result + settled_top2_residual_tree_77(features);
    Result := Result + settled_top2_residual_tree_78(features);
    Result := Result + settled_top2_residual_tree_79(features);
    Result := Result + settled_top2_residual_tree_80(features);
    Result := Result + settled_top2_residual_tree_81(features);
    Result := Result + settled_top2_residual_tree_82(features);
    Result := Result + settled_top2_residual_tree_83(features);
    Result := Result + settled_top2_residual_tree_84(features);
    Result := Result + settled_top2_residual_tree_85(features);
    Result := Result + settled_top2_residual_tree_86(features);
    Result := Result + settled_top2_residual_tree_87(features);
    Result := Result + settled_top2_residual_tree_88(features);
    Result := Result + settled_top2_residual_tree_89(features);
    Result := Result + settled_top2_residual_tree_90(features);
    Result := Result + settled_top2_residual_tree_91(features);
    Result := Result + settled_top2_residual_tree_92(features);
    Result := Result + settled_top2_residual_tree_93(features);
    Result := Result + settled_top2_residual_tree_94(features);
    Result := Result + settled_top2_residual_tree_95(features);
    Result := Result + settled_top2_residual_tree_96(features);
    Result := Result + settled_top2_residual_tree_97(features);
    Result := Result + settled_top2_residual_tree_98(features);
    Result := Result + settled_top2_residual_tree_99(features);
    Result := Result + settled_top2_residual_tree_100(features);
    Result := Result + settled_top2_residual_tree_101(features);
    Result := Result + settled_top2_residual_tree_102(features);
    Result := Result + settled_top2_residual_tree_103(features);
    Result := Result + settled_top2_residual_tree_104(features);
    Result := Result + settled_top2_residual_tree_105(features);
    Result := Result + settled_top2_residual_tree_106(features);
    Result := Result + settled_top2_residual_tree_107(features);
    Result := Result + settled_top2_residual_tree_108(features);
    Result := Result + settled_top2_residual_tree_109(features);
    Result := Result + settled_top2_residual_tree_110(features);
    Result := Result + settled_top2_residual_tree_111(features);
    Result := Result + settled_top2_residual_tree_112(features);
    Result := Result + settled_top2_residual_tree_113(features);
    Result := Result + settled_top2_residual_tree_114(features);
    Result := Result + settled_top2_residual_tree_115(features);
    Result := Result + settled_top2_residual_tree_116(features);
    Result := Result + settled_top2_residual_tree_117(features);
    Result := Result + settled_top2_residual_tree_118(features);
    Result := Result + settled_top2_residual_tree_119(features);
    Result := Result + settled_top2_residual_tree_120(features);
    Result := Result + settled_top2_residual_tree_121(features);
    Result := Result + settled_top2_residual_tree_122(features);
    Result := Result + settled_top2_residual_tree_123(features);
    Result := Result + settled_top2_residual_tree_124(features);
    Result := Result + settled_top2_residual_tree_125(features);
    Result := Result + settled_top2_residual_tree_126(features);
    Result := Result + settled_top2_residual_tree_127(features);
    Result := Result + settled_top2_residual_tree_128(features);
    Result := Result + settled_top2_residual_tree_129(features);
    Result := Result + settled_top2_residual_tree_130(features);
    Result := Result + settled_top2_residual_tree_131(features);
    Result := Result + settled_top2_residual_tree_132(features);
    Result := Result + settled_top2_residual_tree_133(features);
    Result := Result + settled_top2_residual_tree_134(features);
    Result := Result + settled_top2_residual_tree_135(features);
    Result := Result + settled_top2_residual_tree_136(features);
    Result := Result + settled_top2_residual_tree_137(features);
    Result := Result + settled_top2_residual_tree_138(features);
    Result := Result + settled_top2_residual_tree_139(features);
    Result := Result + settled_top2_residual_tree_140(features);
    Result := Result + settled_top2_residual_tree_141(features);
    Result := Result + settled_top2_residual_tree_142(features);
    Result := Result + settled_top2_residual_tree_143(features);
    Result := Result + settled_top2_residual_tree_144(features);
    Result := Result + settled_top2_residual_tree_145(features);
    Result := Result + settled_top2_residual_tree_146(features);
    Result := Result + settled_top2_residual_tree_147(features);
    Result := Result + settled_top2_residual_tree_148(features);
    Result := Result + settled_top2_residual_tree_149(features);
    Result := Result + settled_top2_residual_tree_150(features);
    Result := Result + settled_top2_residual_tree_151(features);
    Result := Result + settled_top2_residual_tree_152(features);
    Result := Result + settled_top2_residual_tree_153(features);
    Result := Result + settled_top2_residual_tree_154(features);
    Result := Result + settled_top2_residual_tree_155(features);
    Result := Result + settled_top2_residual_tree_156(features);
    Result := Result + settled_top2_residual_tree_157(features);
    Result := Result + settled_top2_residual_tree_158(features);
    Result := Result + settled_top2_residual_tree_159(features);
    Result := Result + settled_top2_residual_tree_160(features);
    Result := Result + settled_top2_residual_tree_161(features);
    Result := Result + settled_top2_residual_tree_162(features);
    Result := Result + settled_top2_residual_tree_163(features);
    Result := Result + settled_top2_residual_tree_164(features);
    Result := Result + settled_top2_residual_tree_165(features);
    Result := Result + settled_top2_residual_tree_166(features);
    Result := Result + settled_top2_residual_tree_167(features);
    Result := Result + settled_top2_residual_tree_168(features);
    Result := Result + settled_top2_residual_tree_169(features);
    Result := Result + settled_top2_residual_tree_170(features);
    Result := Result + settled_top2_residual_tree_171(features);
    Result := Result + settled_top2_residual_tree_172(features);
    Result := Result + settled_top2_residual_tree_173(features);
    Result := Result + settled_top2_residual_tree_174(features);
    Result := Result + settled_top2_residual_tree_175(features);
    Result := Result + settled_top2_residual_tree_176(features);
    Result := Result + settled_top2_residual_tree_177(features);
    Result := Result + settled_top2_residual_tree_178(features);
    Result := Result + settled_top2_residual_tree_179(features);
    Result := Result + settled_top2_residual_tree_180(features);
    Result := Result + settled_top2_residual_tree_181(features);
    Result := Result + settled_top2_residual_tree_182(features);
    Result := Result + settled_top2_residual_tree_183(features);
    Result := Result + settled_top2_residual_tree_184(features);
    Result := Result + settled_top2_residual_tree_185(features);
    Result := Result + settled_top2_residual_tree_186(features);
    Result := Result + settled_top2_residual_tree_187(features);
    Result := Result + settled_top2_residual_tree_188(features);
    Result := Result + settled_top2_residual_tree_189(features);
    Result := Result + settled_top2_residual_tree_190(features);
    Result := Result + settled_top2_residual_tree_191(features);
    Result := Result + settled_top2_residual_tree_192(features);
    Result := Result + settled_top2_residual_tree_193(features);
    Result := Result + settled_top2_residual_tree_194(features);
    Result := Result + settled_top2_residual_tree_195(features);
    Result := Result + settled_top2_residual_tree_196(features);
    Result := Result + settled_top2_residual_tree_197(features);
    Result := Result + settled_top2_residual_tree_198(features);
    Result := Result + settled_top2_residual_tree_199(features);
    Result := Result + settled_top2_residual_tree_200(features);
    Result := Result + settled_top2_residual_tree_201(features);
    Result := Result + settled_top2_residual_tree_202(features);
    Result := Result + settled_top2_residual_tree_203(features);
    Result := Result + settled_top2_residual_tree_204(features);
    Result := Result + settled_top2_residual_tree_205(features);
    Result := Result + settled_top2_residual_tree_206(features);
    Result := Result + settled_top2_residual_tree_207(features);
    Result := Result + settled_top2_residual_tree_208(features);
    Result := Result + settled_top2_residual_tree_209(features);
    Result := Result + settled_top2_residual_tree_210(features);
    Result := Result + settled_top2_residual_tree_211(features);
    Result := Result + settled_top2_residual_tree_212(features);
    Result := Result + settled_top2_residual_tree_213(features);
    Result := Result + settled_top2_residual_tree_214(features);
    Result := Result + settled_top2_residual_tree_215(features);
    Result := Result + settled_top2_residual_tree_216(features);
    Result := Result + settled_top2_residual_tree_217(features);
    Result := Result + settled_top2_residual_tree_218(features);
    Result := Result + settled_top2_residual_tree_219(features);
    Result := Result + settled_top2_residual_tree_220(features);
    Result := Result + settled_top2_residual_tree_221(features);
    Result := Result + settled_top2_residual_tree_222(features);
    Result := Result + settled_top2_residual_tree_223(features);
    Result := Result + settled_top2_residual_tree_224(features);
    Result := Result + settled_top2_residual_tree_225(features);
    Result := Result + settled_top2_residual_tree_226(features);
    Result := Result + settled_top2_residual_tree_227(features);
    Result := Result + settled_top2_residual_tree_228(features);
    Result := Result + settled_top2_residual_tree_229(features);
    Result := Result + settled_top2_residual_tree_230(features);
    Result := Result + settled_top2_residual_tree_231(features);
    Result := Result + settled_top2_residual_tree_232(features);
    Result := Result + settled_top2_residual_tree_233(features);
    Result := Result + settled_top2_residual_tree_234(features);
    Result := Result + settled_top2_residual_tree_235(features);
    Result := Result + settled_top2_residual_tree_236(features);
    Result := Result + settled_top2_residual_tree_237(features);
    Result := Result + settled_top2_residual_tree_238(features);
    Result := Result + settled_top2_residual_tree_239(features);
    Result := Result + settled_top2_residual_tree_240(features);
    Result := Result + settled_top2_residual_tree_241(features);
    Result := Result + settled_top2_residual_tree_242(features);
    Result := Result + settled_top2_residual_tree_243(features);
    Result := Result + settled_top2_residual_tree_244(features);
    Result := Result + settled_top2_residual_tree_245(features);
    Result := Result + settled_top2_residual_tree_246(features);
    Result := Result + settled_top2_residual_tree_247(features);
    Result := Result + settled_top2_residual_tree_248(features);
    Result := Result + settled_top2_residual_tree_249(features);
    Result := Result + settled_top2_residual_tree_250(features);
    Result := Result + settled_top2_residual_tree_251(features);
    Result := Result + settled_top2_residual_tree_252(features);
    Result := Result + settled_top2_residual_tree_253(features);
    Result := Result + settled_top2_residual_tree_254(features);
    Result := Result + settled_top2_residual_tree_255(features);
end;

function long_settled_top2_residual_self_test: Boolean;
const
    c_tolerance = 1.0E-9;
var
    features: TncLongSettledTop2ResidualFeatures;
begin
    FillChar(features, SizeOf(features), 0);
    if Abs(long_settled_top2_residual_score(features) -
        c_long_settled_top2_residual_reference_zero) > c_tolerance then
        Exit(False);
    features[0] := -1000000.0;
    features[1] := -1000000.0;
    features[2] := -1000000.0;
    features[3] := -1000000.0;
    features[4] := -1000000.0;
    features[5] := -1000000.0;
    features[6] := -1000000.0;
    features[7] := -1000000.0;
    features[8] := -1000000.0;
    features[9] := -1000000.0;
    features[10] := -1000000.0;
    features[11] := -1000000.0;
    features[12] := -1000000.0;
    features[13] := -1000000.0;
    features[14] := -1000000.0;
    features[15] := -1000000.0;
    features[16] := -1000000.0;
    features[17] := -1000000.0;
    features[18] := -1000000.0;
    features[19] := -1000000.0;
    features[20] := -1000000.0;
    features[21] := -1000000.0;
    features[22] := -1000000.0;
    features[23] := -1000000.0;
    features[24] := -1000000.0;
    features[25] := -1000000.0;
    features[26] := -1000000.0;
    features[27] := -1000000.0;
    features[28] := -1000000.0;
    features[29] := -1000000.0;
    features[30] := -1000000.0;
    features[31] := -1000000.0;
    features[32] := -1000000.0;
    features[33] := -1000000.0;
    features[34] := -1000000.0;
    features[35] := -1000000.0;
    features[36] := -1000000.0;
    features[37] := -1000000.0;
    features[38] := -1000000.0;
    features[39] := -1000000.0;
    features[40] := -1000000.0;
    features[41] := -1000000.0;
    features[42] := -1000000.0;
    features[43] := -1000000.0;
    features[44] := -1000000.0;
    features[45] := -1000000.0;
    features[46] := -1000000.0;
    features[47] := -1000000.0;
    features[48] := -1000000.0;
    features[49] := -1000000.0;
    features[50] := -1000000.0;
    features[51] := -1000000.0;
    features[52] := -1000000.0;
    features[53] := -1000000.0;
    features[54] := -1000000.0;
    features[55] := -1000000.0;
    features[56] := -1000000.0;
    features[57] := -1000000.0;
    features[58] := -1000000.0;
    features[59] := -1000000.0;
    features[60] := -1000000.0;
    features[61] := -1000000.0;
    features[62] := -1000000.0;
    features[63] := -1000000.0;
    features[64] := -1000000.0;
    features[65] := -1000000.0;
    features[66] := -1000000.0;
    features[67] := -1000000.0;
    features[68] := -1000000.0;
    features[69] := -1000000.0;
    features[70] := -1000000.0;
    features[71] := -1000000.0;
    features[72] := -1000000.0;
    features[73] := -1000000.0;
    features[74] := -1000000.0;
    features[75] := -1000000.0;
    features[76] := -1000000.0;
    features[77] := -1000000.0;
    features[78] := -1000000.0;
    features[79] := -1000000.0;
    features[80] := -1000000.0;
    features[81] := -1000000.0;
    features[82] := -1000000.0;
    features[83] := -1000000.0;
    features[84] := -1000000.0;
    features[85] := -1000000.0;
    features[86] := -1000000.0;
    features[87] := -1000000.0;
    features[88] := -1000000.0;
    features[89] := -1000000.0;
    features[90] := -1000000.0;
    features[91] := -1000000.0;
    features[92] := -1000000.0;
    features[93] := -1000000.0;
    features[94] := -1000000.0;
    features[95] := -1000000.0;
    features[96] := -1000000.0;
    features[97] := -1000000.0;
    features[98] := -1000000.0;
    features[99] := -1000000.0;
    features[100] := -1000000.0;
    features[101] := -1000000.0;
    features[102] := -1000000.0;
    features[103] := -1000000.0;
    features[104] := -1000000.0;
    features[105] := -1000000.0;
    features[106] := -1000000.0;
    features[107] := -1000000.0;
    features[108] := -1000000.0;
    features[109] := -1000000.0;
    features[110] := -1000000.0;
    features[111] := -1000000.0;
    features[112] := -1000000.0;
    features[113] := -1000000.0;
    features[114] := -1000000.0;
    features[115] := -1000000.0;
    features[116] := -1000000.0;
    features[117] := -1000000.0;
    features[118] := -1000000.0;
    features[119] := -1000000.0;
    features[120] := -1000000.0;
    features[121] := -1000000.0;
    features[122] := -1000000.0;
    features[123] := -1000000.0;
    features[124] := -1000000.0;
    features[125] := -1000000.0;
    features[126] := -1000000.0;
    features[127] := -1000000.0;
    features[128] := -1000000.0;
    features[129] := -1000000.0;
    features[130] := -1000000.0;
    features[131] := -1000000.0;
    features[132] := -1000000.0;
    features[133] := -1000000.0;
    features[134] := -1000000.0;
    features[135] := -1000000.0;
    features[136] := -1000000.0;
    features[137] := -1000000.0;
    features[138] := -1000000.0;
    features[139] := -1000000.0;
    features[140] := -1000000.0;
    features[141] := -1000000.0;
    features[142] := -1000000.0;
    features[143] := -1000000.0;
    features[144] := -1000000.0;
    features[145] := -1000000.0;
    features[146] := -1000000.0;
    features[147] := -1000000.0;
    features[148] := -1000000.0;
    features[149] := -1000000.0;
    features[150] := -1000000.0;
    features[151] := -1000000.0;
    features[152] := -1000000.0;
    features[153] := -1000000.0;
    features[154] := -1000000.0;
    features[155] := -1000000.0;
    features[156] := -1000000.0;
    features[157] := -1000000.0;
    features[158] := -1000000.0;
    features[159] := -1000000.0;
    features[160] := -1000000.0;
    features[161] := -1000000.0;
    features[162] := -1000000.0;
    features[163] := -1000000.0;
    features[164] := -1000000.0;
    features[165] := -1000000.0;
    features[166] := -1000000.0;
    features[167] := -1000000.0;
    features[168] := -1000000.0;
    features[169] := -1000000.0;
    features[170] := -1000000.0;
    features[171] := -1000000.0;
    features[172] := -1000000.0;
    features[173] := -1000000.0;
    features[174] := -1000000.0;
    features[175] := -1000000.0;
    features[176] := -1000000.0;
    features[177] := -1000000.0;
    features[178] := -1000000.0;
    features[179] := -1000000.0;
    features[180] := -1000000.0;
    features[181] := -1000000.0;
    features[182] := -1000000.0;
    features[183] := -1000000.0;
    features[184] := -1000000.0;
    features[185] := -1000000.0;
    features[186] := -1000000.0;
    features[187] := -1000000.0;
    features[188] := -1000000.0;
    features[189] := -1000000.0;
    features[190] := -1000000.0;
    features[191] := -1000000.0;
    features[192] := -1000000.0;
    features[193] := -1000000.0;
    features[194] := -1000000.0;
    features[195] := -1000000.0;
    features[196] := -1000000.0;
    features[197] := -1000000.0;
    features[198] := -1000000.0;
    features[199] := -1000000.0;
    features[200] := -1000000.0;
    features[201] := -1000000.0;
    features[202] := -1000000.0;
    if Abs(long_settled_top2_residual_score(features) -
        c_long_settled_top2_residual_reference_low) > c_tolerance then
        Exit(False);
    features[0] := 1000000.0;
    features[1] := 1000000.0;
    features[2] := 1000000.0;
    features[3] := 1000000.0;
    features[4] := 1000000.0;
    features[5] := 1000000.0;
    features[6] := 1000000.0;
    features[7] := 1000000.0;
    features[8] := 1000000.0;
    features[9] := 1000000.0;
    features[10] := 1000000.0;
    features[11] := 1000000.0;
    features[12] := 1000000.0;
    features[13] := 1000000.0;
    features[14] := 1000000.0;
    features[15] := 1000000.0;
    features[16] := 1000000.0;
    features[17] := 1000000.0;
    features[18] := 1000000.0;
    features[19] := 1000000.0;
    features[20] := 1000000.0;
    features[21] := 1000000.0;
    features[22] := 1000000.0;
    features[23] := 1000000.0;
    features[24] := 1000000.0;
    features[25] := 1000000.0;
    features[26] := 1000000.0;
    features[27] := 1000000.0;
    features[28] := 1000000.0;
    features[29] := 1000000.0;
    features[30] := 1000000.0;
    features[31] := 1000000.0;
    features[32] := 1000000.0;
    features[33] := 1000000.0;
    features[34] := 1000000.0;
    features[35] := 1000000.0;
    features[36] := 1000000.0;
    features[37] := 1000000.0;
    features[38] := 1000000.0;
    features[39] := 1000000.0;
    features[40] := 1000000.0;
    features[41] := 1000000.0;
    features[42] := 1000000.0;
    features[43] := 1000000.0;
    features[44] := 1000000.0;
    features[45] := 1000000.0;
    features[46] := 1000000.0;
    features[47] := 1000000.0;
    features[48] := 1000000.0;
    features[49] := 1000000.0;
    features[50] := 1000000.0;
    features[51] := 1000000.0;
    features[52] := 1000000.0;
    features[53] := 1000000.0;
    features[54] := 1000000.0;
    features[55] := 1000000.0;
    features[56] := 1000000.0;
    features[57] := 1000000.0;
    features[58] := 1000000.0;
    features[59] := 1000000.0;
    features[60] := 1000000.0;
    features[61] := 1000000.0;
    features[62] := 1000000.0;
    features[63] := 1000000.0;
    features[64] := 1000000.0;
    features[65] := 1000000.0;
    features[66] := 1000000.0;
    features[67] := 1000000.0;
    features[68] := 1000000.0;
    features[69] := 1000000.0;
    features[70] := 1000000.0;
    features[71] := 1000000.0;
    features[72] := 1000000.0;
    features[73] := 1000000.0;
    features[74] := 1000000.0;
    features[75] := 1000000.0;
    features[76] := 1000000.0;
    features[77] := 1000000.0;
    features[78] := 1000000.0;
    features[79] := 1000000.0;
    features[80] := 1000000.0;
    features[81] := 1000000.0;
    features[82] := 1000000.0;
    features[83] := 1000000.0;
    features[84] := 1000000.0;
    features[85] := 1000000.0;
    features[86] := 1000000.0;
    features[87] := 1000000.0;
    features[88] := 1000000.0;
    features[89] := 1000000.0;
    features[90] := 1000000.0;
    features[91] := 1000000.0;
    features[92] := 1000000.0;
    features[93] := 1000000.0;
    features[94] := 1000000.0;
    features[95] := 1000000.0;
    features[96] := 1000000.0;
    features[97] := 1000000.0;
    features[98] := 1000000.0;
    features[99] := 1000000.0;
    features[100] := 1000000.0;
    features[101] := 1000000.0;
    features[102] := 1000000.0;
    features[103] := 1000000.0;
    features[104] := 1000000.0;
    features[105] := 1000000.0;
    features[106] := 1000000.0;
    features[107] := 1000000.0;
    features[108] := 1000000.0;
    features[109] := 1000000.0;
    features[110] := 1000000.0;
    features[111] := 1000000.0;
    features[112] := 1000000.0;
    features[113] := 1000000.0;
    features[114] := 1000000.0;
    features[115] := 1000000.0;
    features[116] := 1000000.0;
    features[117] := 1000000.0;
    features[118] := 1000000.0;
    features[119] := 1000000.0;
    features[120] := 1000000.0;
    features[121] := 1000000.0;
    features[122] := 1000000.0;
    features[123] := 1000000.0;
    features[124] := 1000000.0;
    features[125] := 1000000.0;
    features[126] := 1000000.0;
    features[127] := 1000000.0;
    features[128] := 1000000.0;
    features[129] := 1000000.0;
    features[130] := 1000000.0;
    features[131] := 1000000.0;
    features[132] := 1000000.0;
    features[133] := 1000000.0;
    features[134] := 1000000.0;
    features[135] := 1000000.0;
    features[136] := 1000000.0;
    features[137] := 1000000.0;
    features[138] := 1000000.0;
    features[139] := 1000000.0;
    features[140] := 1000000.0;
    features[141] := 1000000.0;
    features[142] := 1000000.0;
    features[143] := 1000000.0;
    features[144] := 1000000.0;
    features[145] := 1000000.0;
    features[146] := 1000000.0;
    features[147] := 1000000.0;
    features[148] := 1000000.0;
    features[149] := 1000000.0;
    features[150] := 1000000.0;
    features[151] := 1000000.0;
    features[152] := 1000000.0;
    features[153] := 1000000.0;
    features[154] := 1000000.0;
    features[155] := 1000000.0;
    features[156] := 1000000.0;
    features[157] := 1000000.0;
    features[158] := 1000000.0;
    features[159] := 1000000.0;
    features[160] := 1000000.0;
    features[161] := 1000000.0;
    features[162] := 1000000.0;
    features[163] := 1000000.0;
    features[164] := 1000000.0;
    features[165] := 1000000.0;
    features[166] := 1000000.0;
    features[167] := 1000000.0;
    features[168] := 1000000.0;
    features[169] := 1000000.0;
    features[170] := 1000000.0;
    features[171] := 1000000.0;
    features[172] := 1000000.0;
    features[173] := 1000000.0;
    features[174] := 1000000.0;
    features[175] := 1000000.0;
    features[176] := 1000000.0;
    features[177] := 1000000.0;
    features[178] := 1000000.0;
    features[179] := 1000000.0;
    features[180] := 1000000.0;
    features[181] := 1000000.0;
    features[182] := 1000000.0;
    features[183] := 1000000.0;
    features[184] := 1000000.0;
    features[185] := 1000000.0;
    features[186] := 1000000.0;
    features[187] := 1000000.0;
    features[188] := 1000000.0;
    features[189] := 1000000.0;
    features[190] := 1000000.0;
    features[191] := 1000000.0;
    features[192] := 1000000.0;
    features[193] := 1000000.0;
    features[194] := 1000000.0;
    features[195] := 1000000.0;
    features[196] := 1000000.0;
    features[197] := 1000000.0;
    features[198] := 1000000.0;
    features[199] := 1000000.0;
    features[200] := 1000000.0;
    features[201] := 1000000.0;
    features[202] := 1000000.0;
    if Abs(long_settled_top2_residual_score(features) -
        c_long_settled_top2_residual_reference_high) > c_tolerance then
        Exit(False);
    features[0] := 113.0;
    features[1] := -226.0;
    features[2] := 339.0;
    features[3] := -452.0;
    features[4] := 565.0;
    features[5] := -678.0;
    features[6] := 791.0;
    features[7] := -904.0;
    features[8] := 1017.0;
    features[9] := -1130.0;
    features[10] := 1243.0;
    features[11] := -1356.0;
    features[12] := 1469.0;
    features[13] := -1582.0;
    features[14] := 1695.0;
    features[15] := -1808.0;
    features[16] := 1921.0;
    features[17] := -2034.0;
    features[18] := 2147.0;
    features[19] := -2260.0;
    features[20] := 2373.0;
    features[21] := -2486.0;
    features[22] := 2599.0;
    features[23] := -2712.0;
    features[24] := 2825.0;
    features[25] := -2938.0;
    features[26] := 3051.0;
    features[27] := -3164.0;
    features[28] := 3277.0;
    features[29] := -3390.0;
    features[30] := 3503.0;
    features[31] := -3616.0;
    features[32] := 3729.0;
    features[33] := -3842.0;
    features[34] := 3955.0;
    features[35] := -4068.0;
    features[36] := 4181.0;
    features[37] := -4294.0;
    features[38] := 4407.0;
    features[39] := -4520.0;
    features[40] := 4633.0;
    features[41] := -4746.0;
    features[42] := 4859.0;
    features[43] := -4972.0;
    features[44] := 5085.0;
    features[45] := -5198.0;
    features[46] := 5311.0;
    features[47] := -5424.0;
    features[48] := 5537.0;
    features[49] := -5650.0;
    features[50] := 5763.0;
    features[51] := -5876.0;
    features[52] := 5989.0;
    features[53] := -6102.0;
    features[54] := 6215.0;
    features[55] := -6328.0;
    features[56] := 6441.0;
    features[57] := -6554.0;
    features[58] := 6667.0;
    features[59] := -6780.0;
    features[60] := 6893.0;
    features[61] := -7006.0;
    features[62] := 7119.0;
    features[63] := -7232.0;
    features[64] := 7345.0;
    features[65] := -7458.0;
    features[66] := 7571.0;
    features[67] := -7684.0;
    features[68] := 7797.0;
    features[69] := -7910.0;
    features[70] := 8023.0;
    features[71] := -8136.0;
    features[72] := 8249.0;
    features[73] := -8362.0;
    features[74] := 8475.0;
    features[75] := -8588.0;
    features[76] := 8701.0;
    features[77] := -8814.0;
    features[78] := 8927.0;
    features[79] := -9040.0;
    features[80] := 9153.0;
    features[81] := -9266.0;
    features[82] := 9379.0;
    features[83] := -9492.0;
    features[84] := 9605.0;
    features[85] := -9718.0;
    features[86] := 9831.0;
    features[87] := -9944.0;
    features[88] := 10057.0;
    features[89] := -10170.0;
    features[90] := 10283.0;
    features[91] := -10396.0;
    features[92] := 10509.0;
    features[93] := -10622.0;
    features[94] := 10735.0;
    features[95] := -10848.0;
    features[96] := 10961.0;
    features[97] := -11074.0;
    features[98] := 11187.0;
    features[99] := -11300.0;
    features[100] := 11413.0;
    features[101] := -11526.0;
    features[102] := 11639.0;
    features[103] := -11752.0;
    features[104] := 11865.0;
    features[105] := -11978.0;
    features[106] := 12091.0;
    features[107] := -12204.0;
    features[108] := 12317.0;
    features[109] := -12430.0;
    features[110] := 12543.0;
    features[111] := -12656.0;
    features[112] := 12769.0;
    features[113] := -12882.0;
    features[114] := 12995.0;
    features[115] := -13108.0;
    features[116] := 13221.0;
    features[117] := -13334.0;
    features[118] := 13447.0;
    features[119] := -13560.0;
    features[120] := 13673.0;
    features[121] := -13786.0;
    features[122] := 13899.0;
    features[123] := -14012.0;
    features[124] := 14125.0;
    features[125] := -14238.0;
    features[126] := 14351.0;
    features[127] := -14464.0;
    features[128] := 14577.0;
    features[129] := -14690.0;
    features[130] := 14803.0;
    features[131] := -14916.0;
    features[132] := 15029.0;
    features[133] := -15142.0;
    features[134] := 15255.0;
    features[135] := -15368.0;
    features[136] := 15481.0;
    features[137] := -15594.0;
    features[138] := 15707.0;
    features[139] := -15820.0;
    features[140] := 15933.0;
    features[141] := -16046.0;
    features[142] := 16159.0;
    features[143] := -16272.0;
    features[144] := 16385.0;
    features[145] := -16498.0;
    features[146] := 16611.0;
    features[147] := -16724.0;
    features[148] := 16837.0;
    features[149] := -16950.0;
    features[150] := 17063.0;
    features[151] := -17176.0;
    features[152] := 17289.0;
    features[153] := -17402.0;
    features[154] := 17515.0;
    features[155] := -17628.0;
    features[156] := 17741.0;
    features[157] := -17854.0;
    features[158] := 17967.0;
    features[159] := -18080.0;
    features[160] := 18193.0;
    features[161] := -18306.0;
    features[162] := 18419.0;
    features[163] := -18532.0;
    features[164] := 18645.0;
    features[165] := -18758.0;
    features[166] := 18871.0;
    features[167] := -18984.0;
    features[168] := 19097.0;
    features[169] := -19210.0;
    features[170] := 19323.0;
    features[171] := -19436.0;
    features[172] := 19549.0;
    features[173] := -19662.0;
    features[174] := 19775.0;
    features[175] := -19888.0;
    features[176] := 20001.0;
    features[177] := -20114.0;
    features[178] := 20227.0;
    features[179] := -20340.0;
    features[180] := 20453.0;
    features[181] := -20566.0;
    features[182] := 20679.0;
    features[183] := -20792.0;
    features[184] := 20905.0;
    features[185] := -21018.0;
    features[186] := 21131.0;
    features[187] := -21244.0;
    features[188] := 21357.0;
    features[189] := -21470.0;
    features[190] := 21583.0;
    features[191] := -21696.0;
    features[192] := 21809.0;
    features[193] := -21922.0;
    features[194] := 22035.0;
    features[195] := -22148.0;
    features[196] := 22261.0;
    features[197] := -22374.0;
    features[198] := 22487.0;
    features[199] := -22600.0;
    features[200] := 22713.0;
    features[201] := -22826.0;
    features[202] := 22939.0;
    Result := Abs(long_settled_top2_residual_score(features) -
        c_long_settled_top2_residual_reference_mixed) <= c_tolerance;
end;

end.
