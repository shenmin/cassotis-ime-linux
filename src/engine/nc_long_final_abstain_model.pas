unit nc_long_final_abstain_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

type
    TncLongFinalAbstainFeatures = record
        candidate_count: Integer;
        complete_count: Integer;
        chain_count: Integer;
        input_syllable_count: Integer;
        has_left_context: Boolean;
        ranker_top_score: Int64;
        ranker_second_score: Int64;
        ranker_third_score: Int64;
        ranker_top_margin: Int64;
        ranker_second_margin: Int64;
        ranker_score_range: Int64;
        ranker_top_legacy_rank: Integer;
        ranker_top_chain_rank: Integer;
        ranker_top_complete: Boolean;
        ranker_top_user: Boolean;
        ranker_top_dictionary: Boolean;
        ranker_top_chain: Boolean;
        legacy_top_ranker_score: Int64;
        ranker_top_over_legacy_margin: Int64;
        ranker_disagrees: Boolean;
        legacy_top_complete: Boolean;
        legacy_top_user: Boolean;
        legacy_top_dictionary: Boolean;
        legacy_top_chain: Boolean;
        legacy_top_chain_rank: Integer;
        ranker_top_char_lm_score: Integer;
        legacy_top_char_lm_score: Integer;
        ranker_top_char_lm_gain: Integer;
        ranker_top_path_confidence: Integer;
        legacy_top_path_confidence: Integer;
        ranker_top_path_confidence_gain: Integer;
        ranker_top_query_choice_bonus: Integer;
        legacy_top_query_choice_bonus: Integer;
        ranker_top_pool_source_kind: Integer;
        legacy_top_pool_source_kind: Integer;
        ranker_top_pool_rank: Integer;
        legacy_top_pool_rank: Integer;
        ranker_top_pair_evidence: Integer;
        legacy_top_pair_evidence: Integer;
        ranker_top_word_lm_bonus: Integer;
        legacy_top_word_lm_bonus: Integer;
        ranker_top_word_lm_gain: Integer;
        ranker_top_consensus_support: Integer;
        legacy_top_consensus_support: Integer;
        ranker_top_consensus_gain: Integer;
        ranker_top_proper_name_confidence: Integer;
        legacy_top_proper_name_confidence: Integer;
        ranker_top_local_pairwise_score: Integer;
        legacy_top_local_pairwise_score: Integer;
        ranker_top_edge_model_anchor_count: Integer;
        legacy_top_edge_model_anchor_count: Integer;
        ranker_top_edge_model_anchor_gain: Integer;
        ranker_top_edge_model_score_total: Integer;
        legacy_top_edge_model_score_total: Integer;
        ranker_top_edge_model_score_total_gain: Integer;
        ranker_top_edge_model_score_max: Integer;
        legacy_top_edge_model_score_max: Integer;
        ranker_top_edge_model_score_max_gain: Integer;
        ranker_top_edge_model_word_count: Integer;
        legacy_top_edge_model_word_count: Integer;
        ranker_top_edge_model_word_count_gain: Integer;
        ranker_top_edge_model_word_score_mean: Integer;
        legacy_top_edge_model_word_score_mean: Integer;
        ranker_top_edge_model_word_score_mean_gain: Integer;
        ranker_top_edge_model_word_score_min: Integer;
        legacy_top_edge_model_word_score_min: Integer;
        ranker_top_edge_model_word_score_min_gain: Integer;
    end;

const
    c_long_final_abstain_feature_count: Integer = 33;
    c_long_final_abstain_tree_count: Integer = 60;
    c_long_final_abstain_score_scale: Double = 100000000.0;
    c_long_final_abstain_reference_score: Int64 = 65600670;
    c_long_final_abstain_reference_score_low: Int64 = 100591385;
    c_long_final_abstain_reference_score_high: Int64 = 44588292;
    c_long_final_abstain_reference_score_mixed: Int64 = 65980925;

function long_final_abstain_score(
    const features: TncLongFinalAbstainFeatures): Int64;
function long_final_abstain_self_test: Boolean;

implementation

{ Learned LightGBM final-ranker fallback policy. The generated unit has no LightGBM runtime dependency.
  Training report SHA-256: C1730A95627F4668E03D59FFAAF97573EE8CB082CE5DCC12B5DA3FA9CFB00EC3
  LightGBM model SHA-256: 0F34525856BFC52CF5FB7DDF5142EA98D808D087C0EA796899266C2D42D8DD2E }

function long_final_abstain_tree_0(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_over_legacy_margin <= 13861866.000000002 then
    begin
        if features.ranker_top_char_lm_gain <= -210.99999999999997 then
        begin
            Result := 1.1949445000865635;
        end
        else
        begin
            Result := 1.1280288978425452;
        end;
    end
    else
    begin
        Result := 1.1960173443455313;
    end;
end;

function long_final_abstain_tree_1(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -295.49999999999994 then
    begin
        if features.chain_count <= 2.5000000000000004 then
        begin
            Result := 0.034404778582020679;
        end
        else
        begin
            Result := -0.088530626771943233;
        end;
    end
    else
    begin
        Result := -0.011873248413585653;
    end;
end;

function long_final_abstain_tree_2(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_over_legacy_margin <= 13405201.000000002 then
    begin
        Result := -0.034724555747805516;
    end
    else
    begin
        if features.legacy_top_char_lm_score <= -4587.9999999999991 then
        begin
            Result := -0.00038140713065365397;
        end
        else
        begin
            Result := 0.027569245022909816;
        end;
    end;
end;

function long_final_abstain_tree_3(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_over_legacy_margin <= 13861866.000000002 then
    begin
        if features.ranker_top_char_lm_gain <= -210.99999999999997 then
        begin
            Result := 0.013172258861170672;
        end
        else
        begin
            Result := -0.05441485847847545;
        end;
    end
    else
    begin
        Result := 0.0072478868728791277;
    end;
end;

function long_final_abstain_tree_4(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_over_legacy_margin <= 13861866.000000002 then
    begin
        if features.ranker_top_char_lm_gain <= -210.99999999999997 then
        begin
            Result := 0.012835342494302909;
        end
        else
        begin
            Result := -0.046950544795398022;
        end;
    end
    else
    begin
        Result := 0.010378833131892692;
    end;
end;

function long_final_abstain_tree_5(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -450.49999999999994 then
    begin
        Result := 0.03495639485490222;
    end
    else
    begin
        if features.ranker_top_char_lm_score <= -4598.9999999999991 then
        begin
            Result := -0.01751996779511605;
        end
        else
        begin
            Result := 0.020120340412858852;
        end;
    end;
end;

function long_final_abstain_tree_6(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_over_legacy_margin <= 13861866.000000002 then
    begin
        if features.ranker_top_char_lm_gain <= -498.49999999999994 then
        begin
            Result := 0.047531231343280078;
        end
        else
        begin
            Result := -0.034510129718431821;
        end;
    end
    else
    begin
        Result := 0.0071929103130029676;
    end;
end;

function long_final_abstain_tree_7(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -450.49999999999994 then
    begin
        Result := 0.031677337709674049;
    end
    else
    begin
        if features.ranker_top_score <= 14817556.000000002 then
        begin
            Result := -0.033785155197859774;
        end
        else
        begin
            Result := 0.0016537224970897724;
        end;
    end;
end;

function long_final_abstain_tree_8(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -450.49999999999994 then
    begin
        Result := 0.037539851866967892;
    end
    else
    begin
        if features.ranker_top_margin <= 13479699.000000002 then
        begin
            Result := -0.035064479325910336;
        end
        else
        begin
            Result := 0.0033187333511111262;
        end;
    end;
end;

function long_final_abstain_tree_9(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -329.49999999999994 then
    begin
        Result := 0.02394108006135345;
    end
    else
    begin
        if features.ranker_top_score <= 14817556.000000002 then
        begin
            Result := -0.047960716090480401;
        end
        else
        begin
            Result := -0.0044787812385432349;
        end;
    end;
end;

function long_final_abstain_tree_10(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -450.49999999999994 then
    begin
        Result := 0.036854357426291007;
    end
    else
    begin
        if features.ranker_top_char_lm_score <= -4598.9999999999991 then
        begin
            Result := -0.015083903297068942;
        end
        else
        begin
            Result := 0.013530570643799722;
        end;
    end;
end;

function long_final_abstain_tree_11(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -4569.4999999999991 then
    begin
        if features.ranker_top_char_lm_score <= -7113.9999999999991 then
        begin
            Result := 0.048922657902594618;
        end
        else
        begin
            Result := -0.015624751653527707;
        end;
    end
    else
    begin
        Result := 0.015770983955116467;
    end;
end;

function long_final_abstain_tree_12(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -445.49999999999994 then
    begin
        Result := 0.03646121013218865;
    end
    else
    begin
        if features.ranker_second_score <= 13386639.500000002 then
        begin
            Result := -0.0025976951436116765;
        end
        else
        begin
            Result := -0.073599533388577429;
        end;
    end;
end;

function long_final_abstain_tree_13(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -329.49999999999994 then
    begin
        if features.ranker_third_score <= -25506806.999999996 then
        begin
            Result := 0.037600663566581399;
        end
        else
        begin
            Result := -0.071310431246186648;
        end;
    end
    else
    begin
        Result := -0.0069728634825036708;
    end;
end;

function long_final_abstain_tree_14(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_chain_rank <= 3.5000000000000004 then
    begin
        if features.ranker_top_char_lm_score <= -6964.9999999999991 then
        begin
            Result := 0.048547179287570234;
        end
        else
        begin
            Result := -4.8875963675079116E-05;
        end;
    end
    else
    begin
        Result := -0.073406964671553554;
    end;
end;

function long_final_abstain_tree_15(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -4569.4999999999991 then
    begin
        if features.ranker_top_char_lm_score <= -7113.9999999999991 then
        begin
            Result := 0.047801439041017607;
        end
        else
        begin
            Result := -0.010157729765279526;
        end;
    end
    else
    begin
        Result := 0.023036114395366573;
    end;
end;

function long_final_abstain_tree_16(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_margin <= 13479699.000000002 then
    begin
        if features.chain_count <= 2.5000000000000004 then
        begin
            Result := -0.014105181458353187;
        end
        else
        begin
            Result := -0.08466299335453685;
        end;
    end
    else
    begin
        Result := 0.0077716071560961176;
    end;
end;

function long_final_abstain_tree_17(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -305.49999999999994 then
    begin
        Result := 0.027871913132313186;
    end
    else
    begin
        if features.ranker_top_char_lm_score <= -4598.9999999999991 then
        begin
            Result := -0.017729752951905438;
        end
        else
        begin
            Result := 0.023897237128000404;
        end;
    end;
end;

function long_final_abstain_tree_18(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_score <= -4598.9999999999991 then
    begin
        Result := -0.0067133029992349491;
    end
    else
    begin
        if features.ranker_top_char_lm_score <= -4018.9999999999995 then
        begin
            Result := 0.049793198690115767;
        end
        else
        begin
            Result := -0.0019855424839089341;
        end;
    end;
end;

function long_final_abstain_tree_19(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_second_score <= 13386639.500000002 then
    begin
        if features.legacy_top_chain_rank <= 3.5000000000000004 then
        begin
            Result := 0.0059176644563312961;
        end
        else
        begin
            Result := -0.059332034457252616;
        end;
    end
    else
    begin
        Result := -0.050904372886246697;
    end;
end;

function long_final_abstain_tree_20(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_third_score <= -17722485.999999996 then
    begin
        if features.ranker_top_char_lm_gain <= -445.49999999999994 then
        begin
            Result := 0.035070398176080632;
        end
        else
        begin
            Result := -0.0065510802639603292;
        end;
    end
    else
    begin
        Result := -0.082229704473293919;
    end;
end;

function long_final_abstain_tree_21(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_score <= -4598.9999999999991 then
    begin
        if features.ranker_top_char_lm_score <= -7113.9999999999991 then
        begin
            Result := 0.046898812755439313;
        end
        else
        begin
            Result := -0.011713150473832503;
        end;
    end
    else
    begin
        Result := 0.016932721811238539;
    end;
end;

function long_final_abstain_tree_22(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_margin <= 11824127.500000002 then
    begin
        if features.ranker_second_margin <= 32932375.000000004 then
        begin
            Result := -0.067064290033388083;
        end
        else
        begin
            Result := -0.0016553385409148452;
        end;
    end
    else
    begin
        Result := 0.012109701071390415;
    end;
end;

function long_final_abstain_tree_23(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -5445.9999999999991 then
    begin
        if features.ranker_second_margin <= 19311440.000000004 then
        begin
            Result := -0.066586761919933193;
        end
        else
        begin
            Result := -0.0038106350597701499;
        end;
    end
    else
    begin
        Result := 0.0069705569409770022;
    end;
end;

function long_final_abstain_tree_24(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_second_score <= -9697500.9999999981 then
    begin
        Result := -0.021970869381239079;
    end
    else
    begin
        if features.ranker_top_over_legacy_margin <= 19957137.500000004 then
        begin
            Result := -0.0084874319424498735;
        end
        else
        begin
            Result := 0.026707434894095661;
        end;
    end;
end;

function long_final_abstain_tree_25(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -6349.4999999999991 then
    begin
        if features.ranker_top_char_lm_score <= -7113.9999999999991 then
        begin
            Result := 0.046064097637102536;
        end
        else
        begin
            Result := -0.064259306477524453;
        end;
    end
    else
    begin
        Result := 0.0078663685146957638;
    end;
end;

function long_final_abstain_tree_26(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -329.49999999999994 then
    begin
        if features.ranker_third_score <= -25506806.999999996 then
        begin
            Result := 0.029677665574487599;
        end
        else
        begin
            Result := -0.088556868142804529;
        end;
    end
    else
    begin
        Result := -0.007059624252448285;
    end;
end;

function long_final_abstain_tree_27(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_second_margin <= 27925720.000000004 then
    begin
        if features.ranker_second_margin <= 23370959.000000004 then
        begin
            Result := -0.00302131734258046;
        end
        else
        begin
            Result := 0.036627149051157624;
        end;
    end
    else
    begin
        Result := -0.011053347501604622;
    end;
end;

function long_final_abstain_tree_28(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -5416.4999999999991 then
    begin
        if features.ranker_second_margin <= 19063832.500000004 then
        begin
            Result := -0.062529677173525797;
        end
        else
        begin
            Result := -0.0057890987693718764;
        end;
    end
    else
    begin
        Result := 0.0065241018181491544;
    end;
end;

function long_final_abstain_tree_29(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -450.49999999999994 then
    begin
        Result := 0.032279168960140867;
    end
    else
    begin
        if features.legacy_top_ranker_score <= 13386639.500000002 then
        begin
            Result := -0.0020663117988520981;
        end
        else
        begin
            Result := -0.064463024548012518;
        end;
    end;
end;

function long_final_abstain_tree_30(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_margin <= 18994988.500000004 then
    begin
        if features.ranker_top_margin <= 18367540.500000004 then
        begin
            Result := -0.0043198932954191171;
        end
        else
        begin
            Result := -0.077160896289541162;
        end;
    end
    else
    begin
        Result := 0.01205819139226133;
    end;
end;

function long_final_abstain_tree_31(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -4952.9999999999991 then
    begin
        Result := -0.010225644016030934;
    end
    else
    begin
        if features.ranker_top_char_lm_gain <= -214.49999999999997 then
        begin
            Result := 0.036279309548835209;
        end
        else
        begin
            Result := 0.00010921715668177872;
        end;
    end;
end;

function long_final_abstain_tree_32(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -498.49999999999994 then
    begin
        Result := 0.037748459613451052;
    end
    else
    begin
        if features.ranker_top_margin <= 13479699.000000002 then
        begin
            Result := -0.021630986030126219;
        end
        else
        begin
            Result := 0.0031341689768896674;
        end;
    end;
end;

function long_final_abstain_tree_33(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_score_range <= 52369635.000000007 then
    begin
        if features.input_syllable_count <= 13.500000000000002 then
        begin
            Result := -0.012529845118529536;
        end
        else
        begin
            Result := 0.012019980697157866;
        end;
    end
    else
    begin
        Result := 0.038197672284646128;
    end;
end;

function long_final_abstain_tree_34(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_over_legacy_margin <= 13405201.000000002 then
    begin
        Result := -0.019249490666993902;
    end
    else
    begin
        if features.ranker_second_score <= 2876163.5000000005 then
        begin
            Result := 0.0029394973239688432;
        end
        else
        begin
            Result := 0.05014572966875127;
        end;
    end;
end;

function long_final_abstain_tree_35(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -305.49999999999994 then
    begin
        if features.legacy_top_char_lm_score <= -5556.4999999999991 then
        begin
            Result := -0.0056493906459490085;
        end
        else
        begin
            Result := 0.042645568861969296;
        end;
    end
    else
    begin
        Result := -0.0072611747222548753;
    end;
end;

function long_final_abstain_tree_36(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_score <= 20729264.000000004 then
    begin
        if features.ranker_top_score <= 19739420.500000004 then
        begin
            Result := 0.0;
        end
        else
        begin
            Result := -0.033224702751736265;
        end;
    end
    else
    begin
        Result := 0.019439105017907608;
    end;
end;

function long_final_abstain_tree_37(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -498.49999999999994 then
    begin
        Result := 0.036554046680874037;
    end
    else
    begin
        if features.legacy_top_char_lm_score <= -6851.9999999999991 then
        begin
            Result := 0.047185865645063892;
        end
        else
        begin
            Result := -0.0044153069251322077;
        end;
    end;
end;

function long_final_abstain_tree_38(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -305.49999999999994 then
    begin
        if features.ranker_third_score <= -25506806.999999996 then
        begin
            Result := 0.025412382828776822;
        end
        else
        begin
            Result := -0.07410784560992241;
        end;
    end
    else
    begin
        Result := -0.0077435338961038;
    end;
end;

function long_final_abstain_tree_39(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -329.49999999999994 then
    begin
        Result := 0.023770779953473632;
    end
    else
    begin
        if features.ranker_second_score <= -9697500.9999999981 then
        begin
            Result := -0.036120781281280427;
        end
        else
        begin
            Result := 0.0013369892686893173;
        end;
    end;
end;

function long_final_abstain_tree_40(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_second_score <= -9697500.9999999981 then
    begin
        Result := -0.02111344361196359;
    end
    else
    begin
        if features.ranker_top_over_legacy_margin <= 19038467.000000004 then
        begin
            Result := -0.0072206558958481503;
        end
        else
        begin
            Result := 0.02761819406555158;
        end;
    end;
end;

function long_final_abstain_tree_41(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_ranker_score <= -1013069.4999999999 then
    begin
        if features.ranker_second_score <= -8021759.9999999991 then
        begin
            Result := -0.0029410237033498875;
        end
        else
        begin
            Result := 0.038554982049132089;
        end;
    end
    else
    begin
        Result := -0.0069246272608218997;
    end;
end;

function long_final_abstain_tree_42(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_score_range <= 45779446.000000007 then
    begin
        Result := -0.025590768368202114;
    end
    else
    begin
        if features.ranker_score_range <= 47957458.500000007 then
        begin
            Result := 0.040330978916288868;
        end
        else
        begin
            Result := -0.0013576136425487461;
        end;
    end;
end;

function long_final_abstain_tree_43(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_third_score <= -17722485.999999996 then
    begin
        if features.ranker_top_char_lm_gain <= -445.49999999999994 then
        begin
            Result := 0.030391436169691623;
        end
        else
        begin
            Result := -0.0042636060359879501;
        end;
    end
    else
    begin
        Result := -0.05663427063861301;
    end;
end;

function long_final_abstain_tree_44(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_over_legacy_margin <= 19957137.500000004 then
    begin
        if features.chain_count <= 2.5000000000000004 then
        begin
            Result := -0.0043289767274384029;
        end
        else
        begin
            Result := -0.067062725207656521;
        end;
    end
    else
    begin
        Result := 0.0098428021760176045;
    end;
end;

function long_final_abstain_tree_45(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_score <= -4598.9999999999991 then
    begin
        if features.legacy_top_chain_rank <= 3.5000000000000004 then
        begin
            Result := -0.0043618405275759635;
        end
        else
        begin
            Result := -0.081142403564165036;
        end;
    end
    else
    begin
        Result := 0.021092613839305181;
    end;
end;

function long_final_abstain_tree_46(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -4938.4999999999991 then
    begin
        if features.legacy_top_char_lm_score <= -5097.4999999999991 then
        begin
            Result := 0.00048161788476813283;
        end
        else
        begin
            Result := -0.04626885706558273;
        end;
    end
    else
    begin
        Result := 0.019522210490807938;
    end;
end;

function long_final_abstain_tree_47(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.input_syllable_count <= 13.500000000000002 then
    begin
        Result := -0.0072085301113269194;
    end
    else
    begin
        if features.legacy_top_ranker_score <= 2635485.5000000005 then
        begin
            Result := 0.030017206987568774;
        end
        else
        begin
            Result := -0.015954564170521816;
        end;
    end;
end;

function long_final_abstain_tree_48(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -329.49999999999994 then
    begin
        if features.chain_count <= 2.5000000000000004 then
        begin
            Result := 0.030063650564917423;
        end
        else
        begin
            Result := -0.075167831211110772;
        end;
    end
    else
    begin
        Result := -0.0050075132407905601;
    end;
end;

function long_final_abstain_tree_49(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -329.49999999999994 then
    begin
        if features.ranker_third_score <= -23668188.499999996 then
        begin
            Result := 0.025383120488363286;
        end
        else
        begin
            Result := -0.10067797567193094;
        end;
    end
    else
    begin
        Result := -0.0083192314682903994;
    end;
end;

function long_final_abstain_tree_50(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -4911.9999999999991 then
    begin
        if features.ranker_second_margin <= 19210565.500000004 then
        begin
            Result := -0.041407402721517599;
        end
        else
        begin
            Result := -0.0027047736510445765;
        end;
    end
    else
    begin
        Result := 0.014557532085775444;
    end;
end;

function long_final_abstain_tree_51(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_ranker_score <= -14083075.499999998 then
    begin
        Result := 0.047181254659487082;
    end
    else
    begin
        if features.ranker_second_score <= -9697500.9999999981 then
        begin
            Result := -0.034941546820662694;
        end
        else
        begin
            Result := 0.0034995871174234973;
        end;
    end;
end;

function long_final_abstain_tree_52(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_second_margin <= 28092734.500000004 then
    begin
        if features.ranker_second_score <= -9697500.9999999981 then
        begin
            Result := -0.014658098047051808;
        end
        else
        begin
            Result := 0.024480709572280841;
        end;
    end
    else
    begin
        Result := -0.0102792980971515;
    end;
end;

function long_final_abstain_tree_53(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_score <= -7113.9999999999991 then
    begin
        Result := 0.045773356297854263;
    end
    else
    begin
        if features.ranker_top_char_lm_score <= -6784.9999999999991 then
        begin
            Result := -0.068450280828140628;
        end
        else
        begin
            Result := -6.5375570683510583E-05;
        end;
    end;
end;

function long_final_abstain_tree_54(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -329.49999999999994 then
    begin
        if features.ranker_third_score <= -23668188.499999996 then
        begin
            Result := 0.032012734020748911;
        end
        else
        begin
            Result := -0.092233999693562455;
        end;
    end
    else
    begin
        Result := -0.0040407706615544223;
    end;
end;

function long_final_abstain_tree_55(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -498.49999999999994 then
    begin
        Result := 0.033849673144857546;
    end
    else
    begin
        if features.ranker_second_score <= 13386639.500000002 then
        begin
            Result := -0.0021513416619084696;
        end
        else
        begin
            Result := -0.05338436604146389;
        end;
    end;
end;

function long_final_abstain_tree_56(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -450.49999999999994 then
    begin
        Result := 0.027067350197015255;
    end
    else
    begin
        if features.ranker_top_score <= 14466785.500000002 then
        begin
            Result := -0.025390218897828727;
        end
        else
        begin
            Result := -0.00072387065395796031;
        end;
    end;
end;

function long_final_abstain_tree_57(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_top_char_lm_gain <= -305.49999999999994 then
    begin
        if features.ranker_third_score <= -23668188.499999996 then
        begin
            Result := 0.025136945196787872;
        end
        else
        begin
            Result := -0.088263406431772995;
        end;
    end
    else
    begin
        Result := -0.0043785900706745165;
    end;
end;

function long_final_abstain_tree_58(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.legacy_top_char_lm_score <= -4569.4999999999991 then
    begin
        Result := -0.0064056382096254957;
    end
    else
    begin
        if features.ranker_second_score <= 8063557.5000000009 then
        begin
            Result := 0.025472840968377448;
        end
        else
        begin
            Result := -0.02988399864182615;
        end;
    end;
end;

function long_final_abstain_tree_59(
    const features: TncLongFinalAbstainFeatures): Double;
begin
    if features.ranker_second_score <= -9697500.9999999981 then
    begin
        if features.legacy_top_char_lm_score <= -5393.4999999999991 then
        begin
            Result := -0.052042756171719731;
        end
        else
        begin
            Result := 0.0046691071915477512;
        end;
    end
    else
    begin
        Result := 0.0066730754913277368;
    end;
end;
function long_final_abstain_score(
    const features: TncLongFinalAbstainFeatures): Int64;
var
    score: Double;
begin
    score := 0.0;
    score := score + long_final_abstain_tree_0(features);
    score := score + long_final_abstain_tree_1(features);
    score := score + long_final_abstain_tree_2(features);
    score := score + long_final_abstain_tree_3(features);
    score := score + long_final_abstain_tree_4(features);
    score := score + long_final_abstain_tree_5(features);
    score := score + long_final_abstain_tree_6(features);
    score := score + long_final_abstain_tree_7(features);
    score := score + long_final_abstain_tree_8(features);
    score := score + long_final_abstain_tree_9(features);
    score := score + long_final_abstain_tree_10(features);
    score := score + long_final_abstain_tree_11(features);
    score := score + long_final_abstain_tree_12(features);
    score := score + long_final_abstain_tree_13(features);
    score := score + long_final_abstain_tree_14(features);
    score := score + long_final_abstain_tree_15(features);
    score := score + long_final_abstain_tree_16(features);
    score := score + long_final_abstain_tree_17(features);
    score := score + long_final_abstain_tree_18(features);
    score := score + long_final_abstain_tree_19(features);
    score := score + long_final_abstain_tree_20(features);
    score := score + long_final_abstain_tree_21(features);
    score := score + long_final_abstain_tree_22(features);
    score := score + long_final_abstain_tree_23(features);
    score := score + long_final_abstain_tree_24(features);
    score := score + long_final_abstain_tree_25(features);
    score := score + long_final_abstain_tree_26(features);
    score := score + long_final_abstain_tree_27(features);
    score := score + long_final_abstain_tree_28(features);
    score := score + long_final_abstain_tree_29(features);
    score := score + long_final_abstain_tree_30(features);
    score := score + long_final_abstain_tree_31(features);
    score := score + long_final_abstain_tree_32(features);
    score := score + long_final_abstain_tree_33(features);
    score := score + long_final_abstain_tree_34(features);
    score := score + long_final_abstain_tree_35(features);
    score := score + long_final_abstain_tree_36(features);
    score := score + long_final_abstain_tree_37(features);
    score := score + long_final_abstain_tree_38(features);
    score := score + long_final_abstain_tree_39(features);
    score := score + long_final_abstain_tree_40(features);
    score := score + long_final_abstain_tree_41(features);
    score := score + long_final_abstain_tree_42(features);
    score := score + long_final_abstain_tree_43(features);
    score := score + long_final_abstain_tree_44(features);
    score := score + long_final_abstain_tree_45(features);
    score := score + long_final_abstain_tree_46(features);
    score := score + long_final_abstain_tree_47(features);
    score := score + long_final_abstain_tree_48(features);
    score := score + long_final_abstain_tree_49(features);
    score := score + long_final_abstain_tree_50(features);
    score := score + long_final_abstain_tree_51(features);
    score := score + long_final_abstain_tree_52(features);
    score := score + long_final_abstain_tree_53(features);
    score := score + long_final_abstain_tree_54(features);
    score := score + long_final_abstain_tree_55(features);
    score := score + long_final_abstain_tree_56(features);
    score := score + long_final_abstain_tree_57(features);
    score := score + long_final_abstain_tree_58(features);
    score := score + long_final_abstain_tree_59(features);
    Result := Trunc(score * c_long_final_abstain_score_scale);
end;

function long_final_abstain_self_test: Boolean;
var
    features: TncLongFinalAbstainFeatures;
begin
    FillChar(features, SizeOf(features), 0);
    if long_final_abstain_score(features) <>
        c_long_final_abstain_reference_score then
    begin
        Exit(False);
    end;

    features.candidate_count := -1000000;
    features.complete_count := -1000000;
    features.chain_count := -1000000;
    features.input_syllable_count := -1000000;
    features.has_left_context := False;
    features.ranker_top_score := -1000000;
    features.ranker_second_score := -1000000;
    features.ranker_third_score := -1000000;
    features.ranker_top_margin := -1000000;
    features.ranker_second_margin := -1000000;
    features.ranker_score_range := -1000000;
    features.ranker_top_legacy_rank := -1000000;
    features.ranker_top_chain_rank := -1000000;
    features.ranker_top_complete := False;
    features.ranker_top_user := False;
    features.ranker_top_dictionary := False;
    features.ranker_top_chain := False;
    features.legacy_top_ranker_score := -1000000;
    features.ranker_top_over_legacy_margin := -1000000;
    features.ranker_disagrees := False;
    features.legacy_top_complete := False;
    features.legacy_top_user := False;
    features.legacy_top_dictionary := False;
    features.legacy_top_chain := False;
    features.legacy_top_chain_rank := -1000000;
    features.ranker_top_char_lm_score := -1000000;
    features.legacy_top_char_lm_score := -1000000;
    features.ranker_top_char_lm_gain := -1000000;
    features.ranker_top_path_confidence := -1000000;
    features.legacy_top_path_confidence := -1000000;
    features.ranker_top_path_confidence_gain := -1000000;
    features.ranker_top_query_choice_bonus := -1000000;
    features.legacy_top_query_choice_bonus := -1000000;
    if long_final_abstain_score(features) <>
        c_long_final_abstain_reference_score_low then
    begin
        Exit(False);
    end;

    features.candidate_count := 1000000;
    features.complete_count := 1000000;
    features.chain_count := 1000000;
    features.input_syllable_count := 1000000;
    features.has_left_context := True;
    features.ranker_top_score := 1000000;
    features.ranker_second_score := 1000000;
    features.ranker_third_score := 1000000;
    features.ranker_top_margin := 1000000;
    features.ranker_second_margin := 1000000;
    features.ranker_score_range := 1000000;
    features.ranker_top_legacy_rank := 1000000;
    features.ranker_top_chain_rank := 1000000;
    features.ranker_top_complete := True;
    features.ranker_top_user := True;
    features.ranker_top_dictionary := True;
    features.ranker_top_chain := True;
    features.legacy_top_ranker_score := 1000000;
    features.ranker_top_over_legacy_margin := 1000000;
    features.ranker_disagrees := True;
    features.legacy_top_complete := True;
    features.legacy_top_user := True;
    features.legacy_top_dictionary := True;
    features.legacy_top_chain := True;
    features.legacy_top_chain_rank := 1000000;
    features.ranker_top_char_lm_score := 1000000;
    features.legacy_top_char_lm_score := 1000000;
    features.ranker_top_char_lm_gain := 1000000;
    features.ranker_top_path_confidence := 1000000;
    features.legacy_top_path_confidence := 1000000;
    features.ranker_top_path_confidence_gain := 1000000;
    features.ranker_top_query_choice_bonus := 1000000;
    features.legacy_top_query_choice_bonus := 1000000;
    if long_final_abstain_score(features) <>
        c_long_final_abstain_reference_score_high then
    begin
        Exit(False);
    end;

    features.candidate_count := 137;
    features.complete_count := -274;
    features.chain_count := 411;
    features.input_syllable_count := -548;
    features.has_left_context := False;
    features.ranker_top_score := -822;
    features.ranker_second_score := 959;
    features.ranker_third_score := -1096;
    features.ranker_top_margin := 1233;
    features.ranker_second_margin := -1370;
    features.ranker_score_range := 1507;
    features.ranker_top_legacy_rank := -1644;
    features.ranker_top_chain_rank := 1781;
    features.ranker_top_complete := True;
    features.ranker_top_user := False;
    features.ranker_top_dictionary := True;
    features.ranker_top_chain := False;
    features.legacy_top_ranker_score := -2466;
    features.ranker_top_over_legacy_margin := 2603;
    features.ranker_disagrees := True;
    features.legacy_top_complete := False;
    features.legacy_top_user := True;
    features.legacy_top_dictionary := False;
    features.legacy_top_chain := True;
    features.legacy_top_chain_rank := 3425;
    features.ranker_top_char_lm_score := -3562;
    features.legacy_top_char_lm_score := 3699;
    features.ranker_top_char_lm_gain := -3836;
    features.ranker_top_path_confidence := 3973;
    features.legacy_top_path_confidence := -4110;
    features.ranker_top_path_confidence_gain := 4247;
    features.ranker_top_query_choice_bonus := -4384;
    features.legacy_top_query_choice_bonus := 4521;
    Result := long_final_abstain_score(features) =
        c_long_final_abstain_reference_score_mixed;
end;

end.
