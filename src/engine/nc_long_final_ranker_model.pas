unit nc_long_final_ranker_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

type
    TncLongFinalRankerFeatures = record
        candidate_score: Integer;
        dict_weight: Integer;
        has_dict_weight: Boolean;
        source_user: Boolean;
        source_chain: Boolean;
        source_pattern: Boolean;
        source_redup: Boolean;
        source_local_rerank: Boolean;
        source_rule_fallback: Boolean;
        legacy_rank: Integer;
        legacy_top: Boolean;
        chain_rank: Integer;
        chain_present: Boolean;
        chain_first_stage_score: Integer;
        chain_second_stage_score: Int64;
        chain_score_gap: Int64;
        complete_match: Boolean;
        partial_match: Boolean;
        text_units: Integer;
        comment_length: Integer;
        unit_delta: Integer;
        path_available: Boolean;
        path_confidence_score: Integer;
        path_confidence_tier: Integer;
        path_segments: Integer;
        path_single_segments: Integer;
        path_max_segment_units: Integer;
        char_lm_score: Integer;
        char_lm_suffix_score: Integer;
        char_lm_context_score: Integer;
        char_lm_context_gain: Integer;
        has_left_context: Boolean;
        query_choice_bonus: Integer;
        latest_query_choice: Boolean;
        query_path_bonus: Integer;
        query_path_penalty: Integer;
        word_lm_bonus: Integer;
        word_lm_boundary_count: Integer;
        word_lm_boundary_min: Integer;
        word_lm_boundary_max: Integer;
        word_lm_boundary_first: Integer;
        word_lm_boundary_last: Integer;
        word_lm_supported_ratio: Integer;
        word_lm_strong_ratio: Integer;
        word_lm_trigram_ratio: Integer;
        word_lm_zero_count: Integer;
        input_syllable_count: Integer;
        score_per_unit: Integer;
        dict_weight_per_unit: Integer;
        complete_user: Boolean;
        complete_dictionary: Boolean;
        complete_chain: Boolean;
        complete_pool_present: Boolean;
        complete_pool_source_kind: Integer;
        complete_pool_rank: Integer;
        complete_pool_seed_rank: Integer;
        complete_pool_original: Boolean;
        complete_pool_substitutions: Integer;
        complete_pool_changed_position: Integer;
        complete_pool_anchor_present: Boolean;
        complete_pool_anchor_start: Integer;
        complete_pool_anchor_units: Integer;
        complete_pool_anchor_exact_rank: Integer;
        complete_pool_anchor_source_weight: Integer;
        complete_pool_anchor_replacement_weight: Integer;
        complete_pool_anchor_top_weight: Integer;
        complete_pool_anchor_weight_gain: Integer;
        complete_pool_pair_evidence: Integer;
        complete_pool_proper_name_confidence: Integer;
        complete_pool_signature_support: Integer;
        complete_pool_consensus_support: Integer;
        complete_pool_consensus_seed_count: Integer;
        complete_pool_consensus_support_mean: Integer;
        complete_pool_consensus_support_min: Integer;
        complete_pool_consensus_majority_units: Integer;
        complete_pool_consensus_unanimous_units: Integer;
        complete_pool_consensus_nearest_distance: Integer;
        complete_pool_consensus_mean_distance: Integer;
        complete_pool_consensus_changed_support: Integer;
        complete_pool_consensus_changed_top_match: Boolean;
        complete_pool_local_pairwise_score: Integer;
        complete_pool_edge_model_anchor_count: Integer;
        complete_pool_edge_model_score_total: Integer;
        complete_pool_edge_model_score_max: Integer;
        complete_pool_edge_model_word_count: Integer;
        complete_pool_edge_model_word_score_total: Integer;
        complete_pool_edge_model_word_score_min: Integer;
        complete_pool_edge_model_word_score_max: Integer;
        complete_pool_edge_model_word_score_mean: Integer;
    end;

const
    c_long_final_ranker_default_profile: Integer = 2;
    c_long_final_ranker_feature_count: Integer = 52;
    c_long_final_ranker_tree_count: Integer = 5;
    c_long_final_ranker_score_scale: Double = 100000000.0;
    c_long_final_ranker_reference_score: Int64 = 18440205;
    c_long_final_ranker_reference_score_low: Int64 = 18440205;
    c_long_final_ranker_reference_score_high: Int64 = 8901831;
    c_long_final_ranker_reference_score_mixed: Int64 = 18857961;

function long_final_ranker_score(
    const features: TncLongFinalRankerFeatures): Int64;
function long_final_ranker_self_test: Boolean;

implementation

{ Final visible-candidate LightGBM LambdaRank model. The generated unit has no LightGBM runtime dependency.
  Training report SHA-256: C1730A95627F4668E03D59FFAAF97573EE8CB082CE5DCC12B5DA3FA9CFB00EC3
  LightGBM model SHA-256: A78CA8ADB01285A58ED97A0603FB9798E3ECD64E5E746667D3DA95C3525DA095 }

function long_final_ranker_tree_0(
    const features: TncLongFinalRankerFeatures): Double;
begin
    if features.legacy_rank <= 1.5000000000000002 then
    begin
        if features.chain_rank <= 1.5000000000000002 then
        begin
            Result := 0.068740348913920488;
        end
        else
        begin
            if features.chain_score_gap <= 59020763.500000007 then
            begin
                if features.chain_score_gap <= -15111662.999999998 then
                begin
                    Result := 0.012042239464699263;
                end
                else
                begin
                    Result := 0.044414755802406322;
                end;
            end
            else
            begin
                Result := -0.041836071181239838;
            end;
        end;
    end
    else
    begin
        if Ord(features.complete_dictionary) <= 1.0000000180025095E-35 then
        begin
            if Ord(features.complete_match) <= 1.0000000180025095E-35 then
            begin
                Result := -0.06998718254130229;
            end
            else
            begin
                if features.score_per_unit <= 22061.500000000004 then
                begin
                    if features.legacy_rank <= 2.5000000000000004 then
                    begin
                        Result := -0.046012130382981471;
                    end
                    else
                    begin
                        Result := -0.065592478397642498;
                    end;
                end
                else
                begin
                    if features.candidate_score <= 173104.00000000003 then
                    begin
                        Result := -0.048845845803282502;
                    end
                    else
                    begin
                        Result := -0.014239079836044371;
                    end;
                end;
            end;
        end
        else
        begin
            if features.chain_score_gap <= -140614221.99999997 then
            begin
                if features.chain_score_gap <= -166529854.49999997 then
                begin
                    if features.text_units <= 6.5000000000000009 then
                    begin
                        Result := 0.014238996760611912;
                    end
                    else
                    begin
                        if features.chain_score_gap <= -206149365.49999997 then
                        begin
                            Result := -0.061446472569638345;
                        end
                        else
                        begin
                            if features.path_segments <= 5.5000000000000009 then
                            begin
                                Result := -0.0096948722908352589;
                            end
                            else
                            begin
                                Result := -0.050608210981352701;
                            end;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.016017527337741526;
                end;
            end
            else
            begin
                if features.legacy_rank <= 2.5000000000000004 then
                begin
                    if Ord(features.source_chain) <= 1.0000000180025095E-35 then
                    begin
                        if features.path_segments <= 1.5000000000000002 then
                        begin
                            if features.dict_weight <= 48463.500000000007 then
                            begin
                                Result := 0.02982093383332143;
                            end
                            else
                            begin
                                Result := -0.029947457252552757;
                            end;
                        end
                        else
                        begin
                            if features.path_single_segments <= 1.5000000000000002 then
                            begin
                                Result := 0.022544245601617146;
                            end
                            else
                            begin
                                if features.char_lm_suffix_score <= -6729.4999999999991 then
                                begin
                                    if features.score_per_unit <= 23093.500000000004 then
                                    begin
                                        Result := -0.021229903529102152;
                                    end
                                    else
                                    begin
                                        Result := 0.017204975820245029;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.011183060338854831;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.chain_rank <= 1.5000000000000002 then
                        begin
                            Result := 0.054455106932352185;
                        end
                        else
                        begin
                            if features.chain_score_gap <= -104077303.49999999 then
                            begin
                                if features.path_segments <= 7.5000000000000009 then
                                begin
                                    Result := 0.0072902466312380646;
                                end
                                else
                                begin
                                    Result := -0.025499947714315543;
                                end;
                            end
                            else
                            begin
                                if features.char_lm_score <= -4028.4999999999995 then
                                begin
                                    Result := 0.026805051546331126;
                                end
                                else
                                begin
                                    Result := 0.0035459956994582818;
                                end;
                            end;
                        end;
                    end;
                end
                else
                begin
                    if Ord(features.source_chain) <= 1.0000000180025095E-35 then
                    begin
                        if features.path_max_segment_units <= 3.5000000000000004 then
                        begin
                            Result := -0.054956770245394686;
                        end
                        else
                        begin
                            Result := 0.0036021529479355616;
                        end;
                    end
                    else
                    begin
                        if features.chain_score_gap <= -10845463.499999998 then
                        begin
                            if features.path_single_segments <= 2.5000000000000004 then
                            begin
                                Result := -0.0062912183436289199;
                            end
                            else
                            begin
                                Result := -0.049466162254640927;
                            end;
                        end
                        else
                        begin
                            if features.word_lm_bonus <= 229.50000000000003 then
                            begin
                                Result := -0.01041169294148324;
                            end
                            else
                            begin
                                Result := 0.038641837044338205;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function long_final_ranker_tree_1(
    const features: TncLongFinalRankerFeatures): Double;
begin
    if features.legacy_rank <= 1.5000000000000002 then
    begin
        if features.chain_rank <= 1.5000000000000002 then
        begin
            if features.dict_weight_per_unit <= 710.50000000000011 then
            begin
                Result := 0.059871109364532632;
            end
            else
            begin
                Result := 0.064048664127358712;
            end;
        end
        else
        begin
            if features.word_lm_supported_ratio <= 159.50000000000003 then
            begin
                Result := 0.017813297609650086;
            end
            else
            begin
                if features.path_single_segments <= 2.5000000000000004 then
                begin
                    if features.candidate_score <= 107769.00000000001 then
                    begin
                        Result := -0.034913030883997304;
                    end
                    else
                    begin
                        Result := 0.014467136012239808;
                    end;
                end
                else
                begin
                    Result := -0.033571067465773666;
                end;
            end;
        end;
    end
    else
    begin
        if Ord(features.complete_dictionary) <= 1.0000000180025095E-35 then
        begin
            if Ord(features.partial_match) <= 1.0000000180025095E-35 then
            begin
                if features.legacy_rank <= 2.5000000000000004 then
                begin
                    if features.candidate_score <= 176614.50000000003 then
                    begin
                        if features.chain_second_stage_score <= -37290360.999999993 then
                        begin
                            Result := 0.01191700217562138;
                        end
                        else
                        begin
                            if features.char_lm_score <= -3215.4999999999995 then
                            begin
                                Result := -0.044746278555048043;
                            end
                            else
                            begin
                                Result := 0.020737578889621803;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.01627069465257177;
                    end;
                end
                else
                begin
                    if features.chain_second_stage_score <= -5104899.4999999991 then
                    begin
                        if features.chain_score_gap <= -261047710.99999997 then
                        begin
                            Result := -0.061536034660286995;
                        end
                        else
                        begin
                            Result := 0.0078117363937865794;
                        end;
                    end
                    else
                    begin
                        Result := -0.059318320327885136;
                    end;
                end;
            end
            else
            begin
                Result := -0.065585270286695002;
            end;
        end
        else
        begin
            if features.chain_score_gap <= -164095187.49999997 then
            begin
                if features.chain_score_gap <= -206149365.49999997 then
                begin
                    if features.path_segments <= 4.5000000000000009 then
                    begin
                        Result := -0.0081522520885499283;
                    end
                    else
                    begin
                        Result := -0.054747988918175776;
                    end;
                end
                else
                begin
                    Result := -0.028661243046480992;
                end;
            end
            else
            begin
                if Ord(features.source_chain) <= 1.0000000180025095E-35 then
                begin
                    if features.legacy_rank <= 2.5000000000000004 then
                    begin
                        Result := -0.0040887923392876986;
                    end
                    else
                    begin
                        Result := -0.042404214636862336;
                    end;
                end
                else
                begin
                    if features.chain_rank <= 1.5000000000000002 then
                    begin
                        if features.path_single_segments <= 1.5000000000000002 then
                        begin
                            Result := 0.047308820312043393;
                        end
                        else
                        begin
                            if features.word_lm_supported_ratio <= 261.00000000000006 then
                            begin
                                if features.chain_first_stage_score <= 95784.000000000015 then
                                begin
                                    if features.word_lm_boundary_first <= 1138.5000000000002 then
                                    begin
                                        if features.char_lm_suffix_score <= -7724.4999999999991 then
                                        begin
                                            Result := 0.043259757112217884;
                                        end
                                        else
                                        begin
                                            if features.char_lm_score <= -4433.4999999999991 then
                                            begin
                                                if features.candidate_score <= 56156.000000000007 then
                                                begin
                                                    Result := 0.0056905148668257776;
                                                end
                                                else
                                                begin
                                                    Result := -0.041733705934901458;
                                                end;
                                            end
                                            else
                                            begin
                                                Result := 0.028131459904696253;
                                            end;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := 0.03720027288017555;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.028799262018997632;
                                end;
                            end
                            else
                            begin
                                Result := 0.034783314860149489;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.chain_score_gap <= -76189907.999999985 then
                        begin
                            if features.word_lm_boundary_count <= 8.5000000000000018 then
                            begin
                                Result := -0.0070381856251843615;
                            end
                            else
                            begin
                                Result := -0.037286130670106901;
                            end;
                        end
                        else
                        begin
                            if features.candidate_score <= 207623.00000000003 then
                            begin
                                Result := 0.0093808393980898321;
                            end
                            else
                            begin
                                Result := -0.019571360756684995;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function long_final_ranker_tree_2(
    const features: TncLongFinalRankerFeatures): Double;
begin
    if features.legacy_rank <= 1.5000000000000002 then
    begin
        if features.chain_score_gap <= -15111662.999999998 then
        begin
            if features.word_lm_boundary_max <= 1225.5000000000002 then
            begin
                Result := 0.0082839726168225346;
            end
            else
            begin
                Result := -0.020450383333259322;
            end;
        end
        else
        begin
            if features.chain_score_gap <= 6062606.0000000009 then
            begin
                Result := 0.060053278215232396;
            end
            else
            begin
                if features.path_segments <= 5.5000000000000009 then
                begin
                    Result := 0.029872809978823096;
                end
                else
                begin
                    Result := -0.033305641130764688;
                end;
            end;
        end;
    end
    else
    begin
        if Ord(features.complete_dictionary) <= 1.0000000180025095E-35 then
        begin
            if Ord(features.complete_match) <= 1.0000000180025095E-35 then
            begin
                Result := -0.062017170211555346;
            end
            else
            begin
                if features.path_max_segment_units <= 8.5000000000000018 then
                begin
                    if features.candidate_score <= 307971.50000000006 then
                    begin
                        if features.char_lm_score <= -3215.4999999999995 then
                        begin
                            Result := -0.032932523104096063;
                        end
                        else
                        begin
                            Result := 0.022088957282072386;
                        end;
                    end
                    else
                    begin
                        Result := 0.026260595066476843;
                    end;
                end
                else
                begin
                    Result := -0.052638861894193791;
                end;
            end;
        end
        else
        begin
            if features.chain_score_gap <= -107876904.99999999 then
            begin
                if features.chain_score_gap <= -166529854.49999997 then
                begin
                    if features.path_single_segments <= 2.5000000000000004 then
                    begin
                        if features.word_lm_supported_ratio <= 240.00000000000003 then
                        begin
                            if features.char_lm_context_score <= -7316.4999999999991 then
                            begin
                                Result := 0.0067771738297054858;
                            end
                            else
                            begin
                                Result := -0.061244965096613792;
                            end;
                        end
                        else
                        begin
                            if features.word_lm_boundary_max <= 1555.5000000000002 then
                            begin
                                Result := -0.0029055477502158678;
                            end
                            else
                            begin
                                Result := -0.037183963191904965;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.054123806841919586;
                    end;
                end
                else
                begin
                    Result := -0.014464703029407279;
                end;
            end
            else
            begin
                if Ord(features.source_chain) <= 1.0000000180025095E-35 then
                begin
                    if features.legacy_rank <= 2.5000000000000004 then
                    begin
                        if features.path_segments <= 1.5000000000000002 then
                        begin
                            if features.dict_weight <= 32153.500000000004 then
                            begin
                                Result := 0.02258189962736222;
                            end
                            else
                            begin
                                Result := -0.026277999934648064;
                            end;
                        end
                        else
                        begin
                            if features.path_single_segments <= 1.0000000180025095E-35 then
                            begin
                                Result := 0.01375895707334236;
                            end
                            else
                            begin
                                if features.path_max_segment_units <= 3.5000000000000004 then
                                begin
                                    if features.char_lm_context_score <= -5930.4999999999991 then
                                    begin
                                        if features.candidate_score <= 304477.50000000006 then
                                        begin
                                            Result := -0.010758543148529335;
                                        end
                                        else
                                        begin
                                            Result := 0.028712676606676344;
                                        end;
                                    end
                                    else
                                    begin
                                        Result := 0.01049862890951022;
                                    end;
                                end
                                else
                                begin
                                    Result := -0.045629267936613024;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Result := -0.041896653962547527;
                    end;
                end
                else
                begin
                    if features.chain_score_gap <= -1.0000000180025095E-35 then
                    begin
                        if features.path_single_segments <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.024991217155784094;
                        end
                        else
                        begin
                            if features.chain_score_gap <= -73788530.499999985 then
                            begin
                                Result := -0.008118266978883926;
                            end
                            else
                            begin
                                Result := 0.0067651989924694496;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.chain_score_gap <= 26726920.000000004 then
                        begin
                            if features.chain_second_stage_score <= -27119382.999999996 then
                            begin
                                if features.char_lm_score <= -5710.4999999999991 then
                                begin
                                    Result := 0.031739589242947501;
                                end
                                else
                                begin
                                    Result := -2.3385382418252149E-05;
                                end;
                            end
                            else
                            begin
                                Result := 0.035700971241389733;
                            end;
                        end
                        else
                        begin
                            Result := -7.1513893195586319E-05;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function long_final_ranker_tree_3(
    const features: TncLongFinalRankerFeatures): Double;
begin
    if Ord(features.legacy_top) <= 1.0000000180025095E-35 then
    begin
        if Ord(features.complete_dictionary) <= 1.0000000180025095E-35 then
        begin
            if Ord(features.complete_match) <= 1.0000000180025095E-35 then
            begin
                Result := -0.059026136440666413;
            end
            else
            begin
                if features.path_max_segment_units <= 8.5000000000000018 then
                begin
                    if features.candidate_score <= 173104.00000000003 then
                    begin
                        Result := -0.034892687487946411;
                    end
                    else
                    begin
                        Result := -0.010360648306767726;
                    end;
                end
                else
                begin
                    if features.chain_second_stage_score <= -5104899.4999999991 then
                    begin
                        if features.chain_score_gap <= -193079000.99999997 then
                        begin
                            Result := -0.056287875461202411;
                        end
                        else
                        begin
                            Result := 0.017508250342553325;
                        end;
                    end
                    else
                    begin
                        Result := -0.052202777937567654;
                    end;
                end;
            end;
        end
        else
        begin
            if features.chain_score_gap <= -143471495.99999997 then
            begin
                if features.chain_score_gap <= -206149365.49999997 then
                begin
                    if features.text_units <= 6.5000000000000009 then
                    begin
                        Result := 0.012189112106169584;
                    end
                    else
                    begin
                        Result := -0.048264033223487247;
                    end;
                end
                else
                begin
                    if features.word_lm_bonus <= 279.50000000000006 then
                    begin
                        Result := -0.03615135024647155;
                    end
                    else
                    begin
                        Result := -0.014083062380312499;
                    end;
                end;
            end
            else
            begin
                if Ord(features.source_chain) <= 1.0000000180025095E-35 then
                begin
                    if features.char_lm_suffix_score <= -6770.4999999999991 then
                    begin
                        if features.path_max_segment_units <= 2.5000000000000004 then
                        begin
                            if features.char_lm_suffix_score <= -7724.4999999999991 then
                            begin
                                if features.dict_weight <= 8402.5000000000018 then
                                begin
                                    Result := 0.018268979764545251;
                                end
                                else
                                begin
                                    Result := -0.041695705293506316;
                                end;
                            end
                            else
                            begin
                                Result := -0.016113875010064452;
                            end;
                        end
                        else
                        begin
                            if features.char_lm_suffix_score <= -8140.4999999999991 then
                            begin
                                Result := 0.024807208049284522;
                            end
                            else
                            begin
                                Result := -0.010572839968084998;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.text_units <= 10.500000000000002 then
                        begin
                            Result := 0.0026693754578792496;
                        end
                        else
                        begin
                            Result := -0.032403686399758234;
                        end;
                    end;
                end
                else
                begin
                    if features.chain_rank <= 1.5000000000000002 then
                    begin
                        if features.path_single_segments <= 1.5000000000000002 then
                        begin
                            Result := 0.043580271530595835;
                        end
                        else
                        begin
                            if features.word_lm_boundary_max <= 1177.5000000000002 then
                            begin
                                if features.chain_first_stage_score <= 60111.500000000007 then
                                begin
                                    Result := -0.010303901574895294;
                                end
                                else
                                begin
                                    Result := 0.019799847707289386;
                                end;
                            end
                            else
                            begin
                                Result := 0.031748010852802232;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.path_single_segments <= 3.5000000000000004 then
                        begin
                            if features.chain_second_stage_score <= 424984027.50000006 then
                            begin
                                if features.chain_score_gap <= -60099710.999999993 then
                                begin
                                    Result := 0.00037059020820299517;
                                end
                                else
                                begin
                                    Result := 0.012004051681183046;
                                end;
                            end
                            else
                            begin
                                Result := -0.036477144686539349;
                            end;
                        end
                        else
                        begin
                            Result := -0.012984405582965656;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features.chain_rank <= 1.5000000000000002 then
        begin
            Result := 0.057213324819445147;
        end
        else
        begin
            if features.word_lm_boundary_count <= 1.0000000180025095E-35 then
            begin
                Result := 0.036514079013987039;
            end
            else
            begin
                if features.chain_score_gap <= 43128349.000000007 then
                begin
                    if features.chain_score_gap <= -15111662.999999998 then
                    begin
                        Result := -0.010757770685450896;
                    end
                    else
                    begin
                        if features.candidate_score <= 59543.000000000007 then
                        begin
                            Result := -0.04644940688721904;
                        end
                        else
                        begin
                            Result := 0.027570224648036705;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.053604745769331621;
                end;
            end;
        end;
    end;
end;

function long_final_ranker_tree_4(
    const features: TncLongFinalRankerFeatures): Double;
begin
    if features.legacy_rank <= 1.5000000000000002 then
    begin
        if features.chain_rank <= 1.5000000000000002 then
        begin
            Result := 0.054763457252133232;
        end
        else
        begin
            if features.word_lm_supported_ratio <= 171.00000000000003 then
            begin
                if features.chain_score_gap <= -15111662.999999998 then
                begin
                    if features.word_lm_boundary_max <= 1288.5000000000002 then
                    begin
                        Result := 0.0046879140578625668;
                    end
                    else
                    begin
                        Result := -0.050213693546031113;
                    end;
                end
                else
                begin
                    Result := 0.03096340567990203;
                end;
            end
            else
            begin
                Result := -0.012813678962678226;
            end;
        end;
    end
    else
    begin
        if Ord(features.complete_dictionary) <= 1.0000000180025095E-35 then
        begin
            if Ord(features.complete_match) <= 1.0000000180025095E-35 then
            begin
                Result := -0.056489841250695075;
            end
            else
            begin
                if features.legacy_rank <= 2.5000000000000004 then
                begin
                    if features.score_per_unit <= 24254.500000000004 then
                    begin
                        Result := -0.033220056788614283;
                    end
                    else
                    begin
                        Result := -0.013480887722405273;
                    end;
                end
                else
                begin
                    Result := -0.049638752067498799;
                end;
            end;
        end
        else
        begin
            if features.chain_score_gap <= -106206222.49999999 then
            begin
                if features.chain_score_gap <= -206149365.49999997 then
                begin
                    if features.text_units <= 6.5000000000000009 then
                    begin
                        Result := 0.020251651584927786;
                    end
                    else
                    begin
                        Result := -0.044386698091565861;
                    end;
                end
                else
                begin
                    if features.path_segments <= 10.500000000000002 then
                    begin
                        Result := -0.01296404392964306;
                    end
                    else
                    begin
                        Result := -0.052916338885171325;
                    end;
                end;
            end
            else
            begin
                if features.chain_rank <= 1.0000000180025095E-35 then
                begin
                    if features.legacy_rank <= 2.5000000000000004 then
                    begin
                        if features.path_max_segment_units <= 1.5000000000000002 then
                        begin
                            if features.dict_weight <= 48463.500000000007 then
                            begin
                                Result := 0.017630197994569247;
                            end
                            else
                            begin
                                Result := -0.028909665238230957;
                            end;
                        end
                        else
                        begin
                            if features.path_single_segments <= 1.5000000000000002 then
                            begin
                                Result := 0.0081410251716867773;
                            end
                            else
                            begin
                                if features.char_lm_suffix_score <= -5977.4999999999991 then
                                begin
                                    if features.candidate_score <= 304477.50000000006 then
                                    begin
                                        Result := -0.018008078072114232;
                                    end
                                    else
                                    begin
                                        Result := 0.021529908351927675;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.0056214426069602667;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.path_max_segment_units <= 3.5000000000000004 then
                        begin
                            Result := -0.040966335798781277;
                        end
                        else
                        begin
                            Result := 0.012207606333479523;
                        end;
                    end;
                end
                else
                begin
                    if features.chain_rank <= 1.5000000000000002 then
                    begin
                        if features.path_single_segments <= 1.5000000000000002 then
                        begin
                            Result := 0.040202371829813219;
                        end
                        else
                        begin
                            if features.word_lm_boundary_max <= 1408.5000000000002 then
                            begin
                                if features.char_lm_suffix_score <= -7724.4999999999991 then
                                begin
                                    Result := 0.045439899745228593;
                                end
                                else
                                begin
                                    Result := 0.012028219488862233;
                                end;
                            end
                            else
                            begin
                                Result := 0.031946402343303912;
                            end;
                        end;
                    end
                    else
                    begin
                        if features.chain_second_stage_score <= 313489992.00000006 then
                        begin
                            if features.path_single_segments <= 1.5000000000000002 then
                            begin
                                if features.chain_second_stage_score <= 76619886.500000015 then
                                begin
                                    if features.char_lm_suffix_score <= -6134.4999999999991 then
                                    begin
                                        Result := 0.0094237619630747702;
                                    end
                                    else
                                    begin
                                        Result := -0.028461720622929534;
                                    end;
                                end
                                else
                                begin
                                    Result := 0.028261642379196629;
                                end;
                            end
                            else
                            begin
                                if features.chain_score_gap <= -73788530.499999985 then
                                begin
                                    Result := -0.0094635219580743637;
                                end
                                else
                                begin
                                    Result := 0.0066766461295246545;
                                end;
                            end;
                        end
                        else
                        begin
                            Result := -0.013522214111484351;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;
function long_final_ranker_score(
    const features: TncLongFinalRankerFeatures): Int64;
var
    score: Double;
begin
    score := 0.0;
    score := score + long_final_ranker_tree_0(features);
    score := score + long_final_ranker_tree_1(features);
    score := score + long_final_ranker_tree_2(features);
    score := score + long_final_ranker_tree_3(features);
    score := score + long_final_ranker_tree_4(features);
    Result := Trunc(score * c_long_final_ranker_score_scale);
end;

function long_final_ranker_self_test: Boolean;
var
    features: TncLongFinalRankerFeatures;
begin
    FillChar(features, SizeOf(features), 0);
    if long_final_ranker_score(features) <>
        c_long_final_ranker_reference_score then
    begin
        Exit(False);
    end;

    features.candidate_score := -1000000;
    features.dict_weight := -1000000;
    features.has_dict_weight := False;
    features.source_user := False;
    features.source_chain := False;
    features.source_pattern := False;
    features.source_redup := False;
    features.source_local_rerank := False;
    features.source_rule_fallback := False;
    features.legacy_rank := -1000000;
    features.legacy_top := False;
    features.chain_rank := -1000000;
    features.chain_present := False;
    features.chain_first_stage_score := -1000000;
    features.chain_second_stage_score := -1000000;
    features.chain_score_gap := -1000000;
    features.complete_match := False;
    features.partial_match := False;
    features.text_units := -1000000;
    features.comment_length := -1000000;
    features.unit_delta := -1000000;
    features.path_available := False;
    features.path_confidence_score := -1000000;
    features.path_confidence_tier := -1000000;
    features.path_segments := -1000000;
    features.path_single_segments := -1000000;
    features.path_max_segment_units := -1000000;
    features.char_lm_score := -1000000;
    features.char_lm_suffix_score := -1000000;
    features.char_lm_context_score := -1000000;
    features.char_lm_context_gain := -1000000;
    features.has_left_context := False;
    features.query_choice_bonus := -1000000;
    features.latest_query_choice := False;
    features.query_path_bonus := -1000000;
    features.query_path_penalty := -1000000;
    features.word_lm_bonus := -1000000;
    features.word_lm_boundary_count := -1000000;
    features.word_lm_boundary_min := -1000000;
    features.word_lm_boundary_max := -1000000;
    features.word_lm_boundary_first := -1000000;
    features.word_lm_boundary_last := -1000000;
    features.word_lm_supported_ratio := -1000000;
    features.word_lm_strong_ratio := -1000000;
    features.word_lm_trigram_ratio := -1000000;
    features.word_lm_zero_count := -1000000;
    features.input_syllable_count := -1000000;
    features.score_per_unit := -1000000;
    features.dict_weight_per_unit := -1000000;
    features.complete_user := False;
    features.complete_dictionary := False;
    features.complete_chain := False;
    if long_final_ranker_score(features) <>
        c_long_final_ranker_reference_score_low then
    begin
        Exit(False);
    end;

    features.candidate_score := 1000000;
    features.dict_weight := 1000000;
    features.has_dict_weight := True;
    features.source_user := True;
    features.source_chain := True;
    features.source_pattern := True;
    features.source_redup := True;
    features.source_local_rerank := True;
    features.source_rule_fallback := True;
    features.legacy_rank := 1000000;
    features.legacy_top := True;
    features.chain_rank := 1000000;
    features.chain_present := True;
    features.chain_first_stage_score := 1000000;
    features.chain_second_stage_score := 1000000;
    features.chain_score_gap := 1000000;
    features.complete_match := True;
    features.partial_match := True;
    features.text_units := 1000000;
    features.comment_length := 1000000;
    features.unit_delta := 1000000;
    features.path_available := True;
    features.path_confidence_score := 1000000;
    features.path_confidence_tier := 1000000;
    features.path_segments := 1000000;
    features.path_single_segments := 1000000;
    features.path_max_segment_units := 1000000;
    features.char_lm_score := 1000000;
    features.char_lm_suffix_score := 1000000;
    features.char_lm_context_score := 1000000;
    features.char_lm_context_gain := 1000000;
    features.has_left_context := True;
    features.query_choice_bonus := 1000000;
    features.latest_query_choice := True;
    features.query_path_bonus := 1000000;
    features.query_path_penalty := 1000000;
    features.word_lm_bonus := 1000000;
    features.word_lm_boundary_count := 1000000;
    features.word_lm_boundary_min := 1000000;
    features.word_lm_boundary_max := 1000000;
    features.word_lm_boundary_first := 1000000;
    features.word_lm_boundary_last := 1000000;
    features.word_lm_supported_ratio := 1000000;
    features.word_lm_strong_ratio := 1000000;
    features.word_lm_trigram_ratio := 1000000;
    features.word_lm_zero_count := 1000000;
    features.input_syllable_count := 1000000;
    features.score_per_unit := 1000000;
    features.dict_weight_per_unit := 1000000;
    features.complete_user := True;
    features.complete_dictionary := True;
    features.complete_chain := True;
    if long_final_ranker_score(features) <>
        c_long_final_ranker_reference_score_high then
    begin
        Exit(False);
    end;

    features.candidate_score := 137;
    features.dict_weight := -274;
    features.has_dict_weight := False;
    features.source_user := True;
    features.source_chain := False;
    features.source_pattern := True;
    features.source_redup := False;
    features.source_local_rerank := True;
    features.source_rule_fallback := False;
    features.legacy_rank := -1370;
    features.legacy_top := False;
    features.chain_rank := -1644;
    features.chain_present := False;
    features.chain_first_stage_score := -1918;
    features.chain_second_stage_score := 2055;
    features.chain_score_gap := -2192;
    features.complete_match := False;
    features.partial_match := True;
    features.text_units := 2603;
    features.comment_length := -2740;
    features.unit_delta := 2877;
    features.path_available := True;
    features.path_confidence_score := 3151;
    features.path_confidence_tier := -3288;
    features.path_segments := 3425;
    features.path_single_segments := -3562;
    features.path_max_segment_units := 3699;
    features.char_lm_score := -3836;
    features.char_lm_suffix_score := 3973;
    features.char_lm_context_score := -4110;
    features.char_lm_context_gain := 4247;
    features.has_left_context := True;
    features.query_choice_bonus := 4521;
    features.latest_query_choice := True;
    features.query_path_bonus := 4795;
    features.query_path_penalty := -4932;
    features.word_lm_bonus := 5069;
    features.word_lm_boundary_count := -5206;
    features.word_lm_boundary_min := 5343;
    features.word_lm_boundary_max := -5480;
    features.word_lm_boundary_first := 5617;
    features.word_lm_boundary_last := -5754;
    features.word_lm_supported_ratio := 5891;
    features.word_lm_strong_ratio := -6028;
    features.word_lm_trigram_ratio := 6165;
    features.word_lm_zero_count := -6302;
    features.input_syllable_count := 6439;
    features.score_per_unit := -6576;
    features.dict_weight_per_unit := 6713;
    features.complete_user := True;
    features.complete_dictionary := False;
    features.complete_chain := True;
    Result := long_final_ranker_score(features) =
        c_long_final_ranker_reference_score_mixed;
end;

end.
