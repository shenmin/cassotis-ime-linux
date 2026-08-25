unit nc_long_bidirectional_difference_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_long_exact_anchor_pairwise_model;

type
    TncLongBidirectionalDifferenceFeatures = array[0..229] of Double;

const
    c_long_bidirectional_base_feature_count = 215;
    c_long_bidirectional_reverse_radius_count = 5;
    c_long_bidirectional_feature_count = 230;
    c_long_bidirectional_tree_count = 254;
    c_long_bidirectional_threshold = 0.75;
    c_long_bidirectional_reference_zero = 0.070179656093378728;
    c_long_bidirectional_reference_low = -0.96295845304999539;
    c_long_bidirectional_reference_high = 2.5095364131607623;
    c_long_bidirectional_reference_mixed = -0.15889060337012817;

procedure build_long_bidirectional_difference_features(
    const base_features: TncLongExactAnchorPairwiseFeatures;
    const top_reverse_scores: array of Integer;
    const candidate_reverse_scores: array of Integer;
    out features: TncLongBidirectionalDifferenceFeatures);
function long_bidirectional_difference_score(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
function long_bidirectional_difference_self_test: Boolean;

implementation

uses
    Math;

{ Generated from independently split novel, chat and formal-language corpora.
  The reverse character LM sees right context around the differing span. This
  ranker only compares existing complete long-sentence candidates.
  Training report SHA-256: BAFE47033CA31C8644FE02D4DB5392E4020B0BD3C3E1676A89810FC667798923
  LightGBM model SHA-256: 061DF7611696FD4DC60FBEE87DC3331EC11354CCD94490945B733A4248D17004 }

procedure build_long_bidirectional_difference_features(
    const base_features: TncLongExactAnchorPairwiseFeatures;
    const top_reverse_scores: array of Integer;
    const candidate_reverse_scores: array of Integer;
    out features: TncLongBidirectionalDifferenceFeatures);
var
    idx: Integer;
    offset: Integer;
begin
    for idx := 0 to c_long_bidirectional_base_feature_count - 1 do
    begin
        features[idx] := base_features[idx];
    end;
    offset := c_long_bidirectional_base_feature_count;
    for idx := 0 to c_long_bidirectional_reverse_radius_count - 1 do
    begin
        features[offset + idx * 3] := top_reverse_scores[idx];
        features[offset + idx * 3 + 1] := candidate_reverse_scores[idx];
        features[offset + idx * 3 + 2] :=
            candidate_reverse_scores[idx] - top_reverse_scores[idx];
    end;
end;

function bidirectional_tree_0(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -117.49999999999999 then
    begin
        if features[166] <= -199630583.99999997 then
        begin
            if features[229] <= -478.49999999999994 then
            begin
                Result := -1.4958278053915939;
            end
            else
            begin
                Result := -1.4854849430336612;
            end;
        end
        else
        begin
            if features[229] <= -440.49999999999994 then
            begin
                Result := -1.4836265771009689;
            end
            else
            begin
                if features[166] <= -67825651.999999985 then
                begin
                    Result := -1.4622490030425135;
                end
                else
                begin
                    Result := -1.4445911164172702;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -178230655.99999997 then
        begin
            if features[229] <= 456.50000000000006 then
            begin
                if features[166] <= -253630303.99999997 then
                begin
                    Result := -1.4801883070640409;
                end
                else
                begin
                    Result := -1.4523437475508634;
                end;
            end
            else
            begin
                if features[215] <= -6537.4999999999991 then
                begin
                    Result := -1.4702365420065489;
                end
                else
                begin
                    Result := -1.3743110683844995;
                end;
            end;
        end
        else
        begin
            if features[229] <= 226.50000000000003 then
            begin
                if features[229] <= 118.50000000000001 then
                begin
                    Result := -1.4269162094543038;
                end
                else
                begin
                    Result := -1.4079156922941254;
                end;
            end
            else
            begin
                if features[215] <= -6109.4999999999991 then
                begin
                    if features[175] <= -290.49999999999994 then
                    begin
                        Result := -1.4490699795827171;
                    end
                    else
                    begin
                        Result := -1.4002271396774515;
                    end;
                end
                else
                begin
                    if features[229] <= 442.50000000000006 then
                    begin
                        Result := -1.3835361949644918;
                    end
                    else
                    begin
                        Result := -1.3496559025252532;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_1(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -150.49999999999997 then
    begin
        if features[226] <= -530.49999999999989 then
        begin
            if features[226] <= -893.49999999999989 then
            begin
                Result := -0.028140427628624589;
            end
            else
            begin
                Result := -0.018959882017766091;
            end;
        end
        else
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[185] <= -286.83332824707026 then
                begin
                    Result := -0.003407861017050034;
                end
                else
                begin
                    Result := 0.015887050878082846;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.021123975637923342;
                end
                else
                begin
                    Result := -0.00069113995508975155;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 203.50000000000003 then
        begin
            if features[178] <= -1251.4999999999998 then
            begin
                Result := -0.0032967765903813696;
            end
            else
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.038188347296620045;
                end
                else
                begin
                    if features[81] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0021187392279599778;
                    end
                    else
                    begin
                        Result := 0.033083320717243146;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6273.4999999999991 then
            begin
                if features[178] <= -212.49999999999997 then
                begin
                    Result := 0.0035424263619663284;
                end
                else
                begin
                    Result := 0.048629051519146399;
                end;
            end
            else
            begin
                if features[226] <= 447.50000000000006 then
                begin
                    if features[185] <= -434.83332824707026 then
                    begin
                        Result := 0.021329689757083752;
                    end
                    else
                    begin
                        Result := 0.063177860467654709;
                    end;
                end
                else
                begin
                    Result := 0.098266340155206869;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_2(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -117.49999999999999 then
    begin
        if features[166] <= -199630583.99999997 then
        begin
            if features[229] <= -478.49999999999994 then
            begin
                Result := -0.028817409255067584;
            end
            else
            begin
                Result := -0.018573857705759526;
            end;
        end
        else
        begin
            if features[229] <= -440.49999999999994 then
            begin
                Result := -0.01687731029573325;
            end
            else
            begin
                if features[166] <= -74583523.999999985 then
                begin
                    Result := 0.00411230351329146;
                end
                else
                begin
                    Result := 0.020713601983013676;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -197676431.99999997 then
        begin
            if features[229] <= 185.50000000000003 then
            begin
                Result := -0.0080082347055975035;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0049106869883261137;
                end
                else
                begin
                    Result := 0.055461810434077323;
                end;
            end;
        end
        else
        begin
            if features[229] <= 312.50000000000006 then
            begin
                if features[229] <= 118.50000000000001 then
                begin
                    Result := 0.035171395408217787;
                end
                else
                begin
                    if features[227] <= -5237.4999999999991 then
                    begin
                        Result := 0.039598514131441276;
                    end
                    else
                    begin
                        Result := 0.063818114479693516;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5348.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.015081712204348764;
                    end
                    else
                    begin
                        Result := 0.062281609670020867;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.067808942794710156;
                    end
                    else
                    begin
                        Result := 0.095417305404339958;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_3(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -117.49999999999999 then
    begin
        if features[166] <= -207069847.99999997 then
        begin
            if features[229] <= -478.49999999999994 then
            begin
                Result := -0.028712652373531558;
            end
            else
            begin
                Result := -0.018750366197773788;
            end;
        end
        else
        begin
            if features[226] <= -530.49999999999989 then
            begin
                if features[229] <= -679.49999999999989 then
                begin
                    Result := -0.021864224085255762;
                end
                else
                begin
                    Result := -0.0085506710638246115;
                end;
            end
            else
            begin
                if features[166] <= -74583523.999999985 then
                begin
                    Result := 0.0039842476723781798;
                end
                else
                begin
                    Result := 0.020514918183567557;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -203331271.99999997 then
        begin
            if features[222] <= -4965.4999999999991 then
            begin
                Result := -0.0093512317687902673;
            end
            else
            begin
                if features[229] <= 385.50000000000006 then
                begin
                    Result := 0.0071293912479112589;
                end
                else
                begin
                    Result := 0.064690009983090713;
                end;
            end;
        end
        else
        begin
            if features[229] <= 456.50000000000006 then
            begin
                if features[229] <= 118.50000000000001 then
                begin
                    if features[154] <= 191.50000000000003 then
                    begin
                        Result := 0.036352964070251355;
                    end
                    else
                    begin
                        Result := 0.016537115504393317;
                    end;
                end
                else
                begin
                    if features[215] <= -6160.4999999999991 then
                    begin
                        Result := 0.024346817765843951;
                    end
                    else
                    begin
                        Result := 0.059651317811669081;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6975.9999999999991 then
                begin
                    Result := 0.030378449539139346;
                end
                else
                begin
                    Result := 0.089606909589855649;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_4(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -117.49999999999999 then
    begin
        if features[166] <= -199630583.99999997 then
        begin
            if features[226] <= -407.49999999999994 then
            begin
                Result := -0.027722825545202313;
            end
            else
            begin
                Result := -0.014296854177076997;
            end;
        end
        else
        begin
            if features[229] <= -440.49999999999994 then
            begin
                Result := -0.016351194763968985;
            end
            else
            begin
                if features[166] <= -74583523.999999985 then
                begin
                    Result := 0.004010796730141793;
                end
                else
                begin
                    Result := 0.019581608138939943;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -199630583.99999997 then
        begin
            if features[229] <= 185.50000000000003 then
            begin
                Result := -0.0081145389168082137;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0049370254778120922;
                end
                else
                begin
                    Result := 0.052653135258820497;
                end;
            end;
        end
        else
        begin
            if features[226] <= 397.50000000000006 then
            begin
                if features[222] <= -4953.4999999999991 then
                begin
                    if features[166] <= -108239995.99999999 then
                    begin
                        Result := 0.020866694274167374;
                    end
                    else
                    begin
                        Result := 0.037832126821355019;
                    end;
                end
                else
                begin
                    Result := 0.047503361369258437;
                end;
            end
            else
            begin
                if features[215] <= -7096.9999999999991 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.0043337654424618361;
                    end
                    else
                    begin
                        Result := 0.053597549971144125;
                    end;
                end
                else
                begin
                    if features[228] <= -4752.4999999999991 then
                    begin
                        Result := 0.062262182278805644;
                    end
                    else
                    begin
                        Result := 0.08374266793486429;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_5(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[223] <= -204.49999999999997 then
    begin
        if features[223] <= -705.49999999999989 then
        begin
            if features[108] <= -291.49999999999994 then
            begin
                Result := -0.026701675392302438;
            end
            else
            begin
                Result := -0.016454676432892008;
            end;
        end
        else
        begin
            if features[108] <= -221.49999999999997 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0052802343519174205;
                end
                else
                begin
                    Result := -0.021114197247416033;
                end;
            end
            else
            begin
                if features[9] <= 2.5000000000000004 then
                begin
                    Result := 0.0042898988538198441;
                end
                else
                begin
                    Result := 0.027996865268945677;
                end;
            end;
        end;
    end
    else
    begin
        if features[223] <= 169.50000000000003 then
        begin
            if features[186] <= -87.874999999999986 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.016738816806722342;
                end
                else
                begin
                    Result := -0.0058428781417787694;
                end;
            end
            else
            begin
                Result := 0.029398843260077429;
            end;
        end
        else
        begin
            if features[215] <= -6794.4999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0036662947213779102;
                end
                else
                begin
                    Result := 0.031457603632987413;
                end;
            end
            else
            begin
                if features[223] <= 607.50000000000011 then
                begin
                    if features[185] <= -371.89999389648432 then
                    begin
                        Result := 0.016347064727338413;
                    end
                    else
                    begin
                        Result := 0.048196261150154254;
                    end;
                end
                else
                begin
                    if features[179] <= -4862.4999999999991 then
                    begin
                        Result := 0.075182304613508763;
                    end
                    else
                    begin
                        Result := 0.028767025519181717;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_6(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -278.49999999999994 then
    begin
        if features[166] <= -213082135.99999997 then
        begin
            Result := -0.026695939273565884;
        end
        else
        begin
            if features[226] <= -645.49999999999989 then
            begin
                Result := -0.017899203180990513;
            end
            else
            begin
                Result := 0.0028423416561094077;
            end;
        end;
    end
    else
    begin
        if features[166] <= -197676431.99999997 then
        begin
            if features[226] <= 136.50000000000003 then
            begin
                if features[166] <= -253630303.99999997 then
                begin
                    Result := -0.018240570088324092;
                end
                else
                begin
                    Result := -0.00038150701584848849;
                end;
            end
            else
            begin
                if features[108] <= -362.49999999999994 then
                begin
                    Result := -0.002931803143977443;
                end
                else
                begin
                    if features[218] <= -6389.4999999999991 then
                    begin
                        Result := 0.0068246583318233153;
                    end
                    else
                    begin
                        Result := 0.055079298531207715;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 129.50000000000003 then
            begin
                if features[166] <= -139258119.99999997 then
                begin
                    Result := 0.014283474474642963;
                end
                else
                begin
                    if features[154] <= 191.50000000000003 then
                    begin
                        Result := 0.033899946153615419;
                    end
                    else
                    begin
                        Result := 0.01819787740804436;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6160.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.010206098475056954;
                    end
                    else
                    begin
                        Result := 0.041887607918907277;
                    end;
                end
                else
                begin
                    if features[226] <= 467.50000000000006 then
                    begin
                        Result := 0.048908371648977787;
                    end
                    else
                    begin
                        Result := 0.073904330433366333;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_7(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -150.49999999999997 then
    begin
        if features[229] <= -440.49999999999994 then
        begin
            if features[226] <= -893.49999999999989 then
            begin
                Result := -0.027111780797459857;
            end
            else
            begin
                Result := -0.017960154252946978;
            end;
        end
        else
        begin
            if features[108] <= -285.49999999999994 then
            begin
                if features[82] <= -143.49999999999997 then
                begin
                    Result := -0.01750584769621184;
                end
                else
                begin
                    Result := -0.0015402283482014889;
                end;
            end
            else
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.014124650007373066;
                end
                else
                begin
                    Result := -0.0023163844221438662;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 203.50000000000003 then
        begin
            if features[178] <= -1251.4999999999998 then
            begin
                Result := -0.0038437875427499873;
            end
            else
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.030586869968846787;
                end
                else
                begin
                    if features[81] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0011795550622516744;
                    end
                    else
                    begin
                        Result := 0.024971509856480015;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6160.4999999999991 then
            begin
                if features[175] <= -36.499999999999993 then
                begin
                    Result := 0.0020055998808479643;
                end
                else
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.054513058407072747;
                    end
                    else
                    begin
                        Result := 0.015819073007359546;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 467.50000000000006 then
                begin
                    Result := 0.044506036392062569;
                end
                else
                begin
                    Result := 0.067955610148675724;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_8(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -278.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.02668013274873729;
        end
        else
        begin
            if features[226] <= -645.49999999999989 then
            begin
                if features[227] <= -6063.4999999999991 then
                begin
                    Result := 0.023270996499690208;
                end
                else
                begin
                    Result := -0.01900906133365915;
                end;
            end
            else
            begin
                Result := 0.0021986333254318861;
            end;
        end;
    end
    else
    begin
        if features[166] <= -203331271.99999997 then
        begin
            if features[229] <= 185.50000000000003 then
            begin
                if features[166] <= -253630303.99999997 then
                begin
                    Result := -0.018156959933534288;
                end
                else
                begin
                    Result := 0.0014601496036182602;
                end;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0074062112839241873;
                end
                else
                begin
                    Result := 0.042720959942539348;
                end;
            end;
        end
        else
        begin
            if features[229] <= 139.50000000000003 then
            begin
                if features[166] <= -139258119.99999997 then
                begin
                    Result := 0.013019946528837518;
                end
                else
                begin
                    if features[226] <= -46.499999999999993 then
                    begin
                        Result := 0.022719891064628791;
                    end
                    else
                    begin
                        Result := 0.034184732188778849;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5576.4999999999991 then
                begin
                    if features[178] <= -163.49999999999997 then
                    begin
                        Result := 0.01228085674298351;
                    end
                    else
                    begin
                        Result := 0.04044916554904629;
                    end;
                end
                else
                begin
                    if features[229] <= 529.50000000000011 then
                    begin
                        Result := 0.048974458575650297;
                    end
                    else
                    begin
                        Result := 0.069468735391994232;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_9(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -307.49999999999994 then
    begin
        if features[166] <= -207069847.99999997 then
        begin
            Result := -0.026346837830823006;
        end
        else
        begin
            if features[226] <= -645.49999999999989 then
            begin
                if features[227] <= -6063.4999999999991 then
                begin
                    Result := 0.021375466107212086;
                end
                else
                begin
                    Result := -0.017843556916265001;
                end;
            end
            else
            begin
                Result := 0.0016481952967126855;
            end;
        end;
    end
    else
    begin
        if features[166] <= -197676431.99999997 then
        begin
            if features[226] <= 236.50000000000003 then
            begin
                if features[166] <= -256058583.99999997 then
                begin
                    Result := -0.017882494049524727;
                end
                else
                begin
                    Result := 0.0015835826351978074;
                end;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0062601801899903322;
                end
                else
                begin
                    if features[226] <= 499.50000000000006 then
                    begin
                        Result := 0.020836716728273811;
                    end
                    else
                    begin
                        Result := 0.065166164786166048;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 163.50000000000003 then
            begin
                if features[226] <= -71.499999999999986 then
                begin
                    Result := 0.017266952805470279;
                end
                else
                begin
                    Result := 0.028541931303513193;
                end;
            end
            else
            begin
                if features[215] <= -6109.4999999999991 then
                begin
                    if features[175] <= 96.000000000000014 then
                    begin
                        Result := 0.011004129801568101;
                    end
                    else
                    begin
                        Result := 0.038358655504444228;
                    end;
                end
                else
                begin
                    if features[226] <= 562.50000000000011 then
                    begin
                        Result := 0.044595423048683261;
                    end
                    else
                    begin
                        Result := 0.066247375288451343;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_10(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -260.49999999999994 then
    begin
        if features[166] <= -199630583.99999997 then
        begin
            Result := -0.026126548411783763;
        end
        else
        begin
            if features[229] <= -640.49999999999989 then
            begin
                Result := -0.019307611808737125;
            end
            else
            begin
                if features[18] <= 8.5000000000000018 then
                begin
                    Result := 0.0057833743683281006;
                end
                else
                begin
                    Result := -0.0070954251717129284;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -217256167.99999997 then
        begin
            if features[222] <= -4965.4999999999991 then
            begin
                Result := -0.014115456292043258;
            end
            else
            begin
                if features[229] <= 368.50000000000006 then
                begin
                    Result := 0.00033395420389865297;
                end
                else
                begin
                    Result := 0.049084782860952858;
                end;
            end;
        end
        else
        begin
            if features[229] <= 118.50000000000001 then
            begin
                if features[166] <= -134083339.99999999 then
                begin
                    if features[222] <= -5319.4999999999991 then
                    begin
                        Result := 0.0032744683809232547;
                    end
                    else
                    begin
                        Result := 0.020095529329218004;
                    end;
                end
                else
                begin
                    if features[158] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.015117651763144469;
                    end
                    else
                    begin
                        Result := 0.027736013448410431;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6137.4999999999991 then
                begin
                    if features[175] <= 1522.5000000000002 then
                    begin
                        Result := 0.014649002155083073;
                    end
                    else
                    begin
                        Result := 0.046671730116473291;
                    end;
                end
                else
                begin
                    if features[229] <= 312.50000000000006 then
                    begin
                        Result := 0.038272462265802713;
                    end
                    else
                    begin
                        Result := 0.058961146254692648;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_11(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -307.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.026405000114005241;
        end
        else
        begin
            if features[226] <= -645.49999999999989 then
            begin
                if features[143] <= 2.5000000000000004 then
                begin
                    Result := -0.01742898193864521;
                end
                else
                begin
                    Result := 0.038408668482731285;
                end;
            end
            else
            begin
                Result := 0.00095702231082825558;
            end;
        end;
    end
    else
    begin
        if features[166] <= -197676431.99999997 then
        begin
            if features[229] <= 185.50000000000003 then
            begin
                if features[166] <= -256058583.99999997 then
                begin
                    Result := -0.01724012795989345;
                end
                else
                begin
                    Result := 0.0014810592717211333;
                end;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0063029774283163351;
                end
                else
                begin
                    Result := 0.039808480607685492;
                end;
            end;
        end
        else
        begin
            if features[229] <= 118.50000000000001 then
            begin
                if features[166] <= -139258119.99999997 then
                begin
                    Result := 0.011648636682171219;
                end
                else
                begin
                    if features[158] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.013942605564184227;
                    end
                    else
                    begin
                        Result := 0.027920436358415693;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -7096.9999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0045530629703397435;
                    end
                    else
                    begin
                        Result := 0.032451714700695959;
                    end;
                end
                else
                begin
                    if features[226] <= 467.50000000000006 then
                    begin
                        Result := 0.038353336020393397;
                    end
                    else
                    begin
                        Result := 0.055953675295490696;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_12(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -335.49999999999994 then
    begin
        if features[226] <= -645.49999999999989 then
        begin
            if features[226] <= -1034.4999999999998 then
            begin
                Result := -0.027087596586279256;
            end
            else
            begin
                Result := -0.019098496740901909;
            end;
        end
        else
        begin
            if features[109] <= -284.49999999999994 then
            begin
                Result := -0.014464365511474512;
            end
            else
            begin
                Result := 0.00049430491645463743;
            end;
        end;
    end
    else
    begin
        if features[226] <= 124.50000000000001 then
        begin
            if features[178] <= -1264.4999999999998 then
            begin
                if features[82] <= -128.49999999999997 then
                begin
                    Result := -0.018584499913967656;
                end
                else
                begin
                    Result := 0.0018986763210647442;
                end;
            end
            else
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[226] <= -71.499999999999986 then
                    begin
                        Result := 0.014203644587163953;
                    end
                    else
                    begin
                        Result := 0.028238011161460231;
                    end;
                end
                else
                begin
                    if features[128] <= -605.99999999999989 then
                    begin
                        Result := -0.010523957216751416;
                    end
                    else
                    begin
                        Result := 0.012238910464864456;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6794.4999999999991 then
            begin
                if features[109] <= -10.499999999999998 then
                begin
                    Result := -0.0045702109397479677;
                end
                else
                begin
                    Result := 0.026936943503651931;
                end;
            end
            else
            begin
                if features[226] <= 467.50000000000006 then
                begin
                    if features[185] <= -376.87499999999994 then
                    begin
                        Result := 0.0083519779066779098;
                    end
                    else
                    begin
                        Result := 0.035452076659829967;
                    end;
                end
                else
                begin
                    Result := 0.052952292488248447;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_13(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -341.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.026287656701867442;
        end
        else
        begin
            if features[226] <= -882.49999999999989 then
            begin
                Result := -0.020534799684362809;
            end
            else
            begin
                if features[216] <= -7394.4999999999991 then
                begin
                    Result := 0.031958499905657418;
                end
                else
                begin
                    Result := -0.0039352779556283716;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -217256167.99999997 then
        begin
            if features[229] <= 368.50000000000006 then
            begin
                if features[166] <= -309296735.99999994 then
                begin
                    Result := -0.019999456206601859;
                end
                else
                begin
                    Result := -0.0045342266844488992;
                end;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0090518999147253185;
                end
                else
                begin
                    Result := 0.052641336903198548;
                end;
            end;
        end
        else
        begin
            if features[229] <= 139.50000000000003 then
            begin
                if features[226] <= -71.499999999999986 then
                begin
                    if features[166] <= -135888783.99999997 then
                    begin
                        Result := 0.0039280417967165245;
                    end
                    else
                    begin
                        Result := 0.016780182438252408;
                    end;
                end
                else
                begin
                    Result := 0.024361607493414789;
                end;
            end
            else
            begin
                if features[215] <= -6109.4999999999991 then
                begin
                    if features[166] <= -89999783.999999985 then
                    begin
                        Result := 0.0094502876319193067;
                    end
                    else
                    begin
                        Result := 0.034747508095811744;
                    end;
                end
                else
                begin
                    if features[226] <= 397.50000000000006 then
                    begin
                        Result := 0.034714435611168486;
                    end
                    else
                    begin
                        Result := 0.052370321133784037;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_14(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -335.49999999999994 then
    begin
        if features[166] <= -207069847.99999997 then
        begin
            Result := -0.025816118001362229;
        end
        else
        begin
            if features[226] <= -645.49999999999989 then
            begin
                if features[216] <= -6993.4999999999991 then
                begin
                    Result := 0.0055642226048470446;
                end
                else
                begin
                    Result := -0.018105032708220684;
                end;
            end
            else
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    Result := -0.004841308318751218;
                end
                else
                begin
                    Result := 0.0088447426406408104;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -197676431.99999997 then
        begin
            if features[229] <= 185.50000000000003 then
            begin
                if features[166] <= -256058583.99999997 then
                begin
                    Result := -0.017478258763643891;
                end
                else
                begin
                    Result := 0.00034617142886883204;
                end;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0053855161525193686;
                end
                else
                begin
                    Result := 0.034445792780530227;
                end;
            end;
        end
        else
        begin
            if features[229] <= 139.50000000000003 then
            begin
                if features[226] <= -52.499999999999993 then
                begin
                    Result := 0.014116836725441055;
                end
                else
                begin
                    Result := 0.025046092174401138;
                end;
            end
            else
            begin
                if features[225] <= -5593.4999999999991 then
                begin
                    if features[166] <= -140928295.99999997 then
                    begin
                        Result := -0.00080549505026459786;
                    end
                    else
                    begin
                        Result := 0.027586095951388969;
                    end;
                end
                else
                begin
                    if features[229] <= 529.50000000000011 then
                    begin
                        Result := 0.039353438158717745;
                    end
                    else
                    begin
                        Result := 0.054554698647755723;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_15(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -341.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.025983681739945516;
        end
        else
        begin
            if features[226] <= -882.49999999999989 then
            begin
                Result := -0.019721068436479288;
            end
            else
            begin
                if features[177] <= -5410.4999999999991 then
                begin
                    Result := -0.0050776855273511196;
                end
                else
                begin
                    if features[108] <= -273.49999999999994 then
                    begin
                        Result := -0.0082586212795897479;
                    end
                    else
                    begin
                        Result := 0.022324493737523307;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -185915207.99999997 then
        begin
            if features[226] <= 352.50000000000006 then
            begin
                if features[166] <= -263177239.99999997 then
                begin
                    Result := -0.01623711742632054;
                end
                else
                begin
                    Result := 0.0014703271613107354;
                end;
            end
            else
            begin
                if features[215] <= -5763.4999999999991 then
                begin
                    Result := -0.00031445477211067578;
                end
                else
                begin
                    Result := 0.041895263632734263;
                end;
            end;
        end
        else
        begin
            if features[229] <= 118.50000000000001 then
            begin
                if features[229] <= -120.49999999999999 then
                begin
                    Result := 0.01158439129443526;
                end
                else
                begin
                    if features[154] <= -119.49999999999999 then
                    begin
                        Result := 0.028114748269373283;
                    end
                    else
                    begin
                        Result := 0.016050587794660173;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -4731.4999999999991 then
                begin
                    if features[225] <= -6298.4999999999991 then
                    begin
                        Result := 0.0079682305768398725;
                    end
                    else
                    begin
                        Result := 0.032809654951557347;
                    end;
                end
                else
                begin
                    Result := 0.046921326009575826;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_16(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -335.49999999999994 then
    begin
        if features[166] <= -207069847.99999997 then
        begin
            Result := -0.025387225805877357;
        end
        else
        begin
            if features[226] <= -873.49999999999989 then
            begin
                Result := -0.019392674341527489;
            end
            else
            begin
                if features[216] <= -7297.4999999999991 then
                begin
                    Result := 0.029985570722934313;
                end
                else
                begin
                    Result := -0.0025822852733996936;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -185915207.99999997 then
        begin
            if features[229] <= 185.50000000000003 then
            begin
                if features[166] <= -263177239.99999997 then
                begin
                    Result := -0.016796613664397438;
                end
                else
                begin
                    Result := 0.00077436027721577896;
                end;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0028596093742474997;
                end
                else
                begin
                    Result := 0.034005357581415596;
                end;
            end;
        end
        else
        begin
            if features[229] <= 139.50000000000003 then
            begin
                if features[229] <= -107.49999999999999 then
                begin
                    Result := 0.010946187662054151;
                end
                else
                begin
                    if features[154] <= 241.00000000000003 then
                    begin
                        Result := 0.024776075190099226;
                    end
                    else
                    begin
                        Result := 0.00946526901736831;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5461.4999999999991 then
                begin
                    if features[165] <= 137520696.00000003 then
                    begin
                        Result := 0.03021385393578703;
                    end
                    else
                    begin
                        Result := 0.0091331401075655117;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.030336282047080006;
                    end
                    else
                    begin
                        Result := 0.045593350465294447;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_17(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -260.49999999999994 then
    begin
        if features[166] <= -199630583.99999997 then
        begin
            Result := -0.024799235625202781;
        end
        else
        begin
            if features[229] <= -640.49999999999989 then
            begin
                Result := -0.018095063010257172;
            end
            else
            begin
                if features[9] <= 1.5000000000000002 then
                begin
                    Result := -0.012251863553140304;
                end
                else
                begin
                    if features[166] <= -89999783.999999985 then
                    begin
                        Result := -0.0027463404208942464;
                    end
                    else
                    begin
                        Result := 0.013100239737097799;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -171165071.99999997 then
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[166] <= -263177239.99999997 then
                begin
                    Result := -0.017191803530265459;
                end
                else
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0025088539686565583;
                    end
                    else
                    begin
                        Result := 0.030739415185350345;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 185.50000000000003 then
                begin
                    Result := 0.0045417921313778515;
                end
                else
                begin
                    Result := 0.032804209016118094;
                end;
            end;
        end
        else
        begin
            if features[229] <= 172.50000000000003 then
            begin
                if features[166] <= -76688567.999999985 then
                begin
                    Result := 0.01451914590130189;
                end
                else
                begin
                    Result := 0.023793347726855686;
                end;
            end
            else
            begin
                if features[215] <= -6045.4999999999991 then
                begin
                    if features[158] <= 583.00000000000011 then
                    begin
                        Result := 0.00056095594445240639;
                    end
                    else
                    begin
                        Result := 0.031974015193039357;
                    end;
                end
                else
                begin
                    Result := 0.041712410128894692;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_18(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -341.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.025602031910137629;
        end
        else
        begin
            if features[226] <= -902.49999999999989 then
            begin
                if features[146] <= 1860.0000000000002 then
                begin
                    Result := -0.020945005432274427;
                end
                else
                begin
                    Result := 0.030583968698293815;
                end;
            end
            else
            begin
                Result := -0.0030733770719187131;
            end;
        end;
    end
    else
    begin
        if features[166] <= -173005119.99999997 then
        begin
            if features[166] <= -271977871.99999994 then
            begin
                if features[225] <= -3815.4999999999995 then
                begin
                    Result := -0.015506616384979702;
                end
                else
                begin
                    Result := 0.022320493628941677;
                end;
            end
            else
            begin
                if features[229] <= 577.50000000000011 then
                begin
                    if features[9] <= 6.5000000000000009 then
                    begin
                        Result := 0.0026459784939452855;
                    end
                    else
                    begin
                        Result := 0.034113610071535641;
                    end;
                end
                else
                begin
                    Result := 0.039221803388159261;
                end;
            end;
        end
        else
        begin
            if features[226] <= 327.50000000000006 then
            begin
                if features[226] <= -46.499999999999993 then
                begin
                    Result := 0.012905722375110921;
                end
                else
                begin
                    if features[166] <= -95149143.999999985 then
                    begin
                        Result := 0.017312660313546984;
                    end
                    else
                    begin
                        Result := 0.028817836571436096;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -7276.4999999999991 then
                begin
                    Result := 0.011402850576509553;
                end
                else
                begin
                    if features[226] <= 562.50000000000011 then
                    begin
                        Result := 0.03409996506449172;
                    end
                    else
                    begin
                        Result := 0.047294563407479076;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_19(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -335.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.025393664616921226;
        end
        else
        begin
            if features[226] <= -882.49999999999989 then
            begin
                Result := -0.019266604031842348;
            end
            else
            begin
                Result := -0.0027745894800585607;
            end;
        end;
    end
    else
    begin
        if features[166] <= -217256167.99999997 then
        begin
            if features[166] <= -309296735.99999994 then
            begin
                Result := -0.016942032058948696;
            end
            else
            begin
                if features[180] <= -6062.4999999999991 then
                begin
                    Result := -0.0061572003091266824;
                end
                else
                begin
                    if features[226] <= 53.500000000000007 then
                    begin
                        Result := 0.0016116883009705174;
                    end
                    else
                    begin
                        Result := 0.033365398298850275;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 307.50000000000006 then
            begin
                if features[226] <= -46.499999999999993 then
                begin
                    if features[166] <= -135888783.99999997 then
                    begin
                        Result := 0.0022215961948079902;
                    end
                    else
                    begin
                        Result := 0.014673433196246938;
                    end;
                end
                else
                begin
                    if features[0] <= 158407.50000000003 then
                    begin
                        Result := 0.019713542949936907;
                    end
                    else
                    begin
                        Result := 0.034751298929926393;
                    end;
                end;
            end
            else
            begin
                if features[217] <= 2608.5000000000005 then
                begin
                    if features[228] <= -4752.4999999999991 then
                    begin
                        Result := 0.028184629276970061;
                    end
                    else
                    begin
                        Result := 0.044075601088411902;
                    end;
                end
                else
                begin
                    if features[173] <= -6626.4999999999991 then
                    begin
                        Result := 0.03360897349954331;
                    end
                    else
                    begin
                        Result := -0.0065427396436607971;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_20(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -260.49999999999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            if features[90] <= 9.5000000000000018 then
            begin
                Result := -0.023134337786719146;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.081098269589874566;
                end
                else
                begin
                    Result := -0.019280947493693676;
                end;
            end;
        end
        else
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                Result := -0.00069659688123450275;
            end
            else
            begin
                Result := -0.013093698123114964;
            end;
        end;
    end
    else
    begin
        if features[229] <= 99.500000000000014 then
        begin
            if features[178] <= -1264.4999999999998 then
            begin
                Result := -0.0051877030987314693;
            end
            else
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[178] <= 70.500000000000014 then
                    begin
                        Result := 0.012555701903794301;
                    end
                    else
                    begin
                        Result := 0.025750610582520091;
                    end;
                end
                else
                begin
                    if features[81] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0077835495202505213;
                    end
                    else
                    begin
                        Result := 0.012306933228415338;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -5461.4999999999991 then
            begin
                if features[184] <= -116.49999999999999 then
                begin
                    Result := 0.0021849749434983789;
                end
                else
                begin
                    Result := 0.024234727059219321;
                end;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[217] <= 2465.5000000000005 then
                    begin
                        Result := 0.025929770796442733;
                    end
                    else
                    begin
                        Result := -0.009638382344775388;
                    end;
                end
                else
                begin
                    Result := 0.038318343497088854;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_21(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -335.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.025167699133348955;
        end
        else
        begin
            if features[226] <= -645.49999999999989 then
            begin
                if features[227] <= -6063.4999999999991 then
                begin
                    Result := 0.026383764345906269;
                end
                else
                begin
                    Result := -0.016324315165929876;
                end;
            end
            else
            begin
                Result := 0.0012152263617191206;
            end;
        end;
    end
    else
    begin
        if features[166] <= -176496199.99999997 then
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[90] <= 6.5000000000000009 then
                begin
                    if features[166] <= -263177239.99999997 then
                    begin
                        Result := -0.017175594018060143;
                    end
                    else
                    begin
                        Result := -0.0027431429146192662;
                    end;
                end
                else
                begin
                    Result := 0.035992769477575813;
                end;
            end
            else
            begin
                if features[229] <= 368.50000000000006 then
                begin
                    Result := 0.0065928181946706662;
                end
                else
                begin
                    Result := 0.036903256921618159;
                end;
            end;
        end
        else
        begin
            if features[229] <= 139.50000000000003 then
            begin
                if features[229] <= -120.49999999999999 then
                begin
                    Result := 0.0091668949233777164;
                end
                else
                begin
                    if features[154] <= 210.50000000000003 then
                    begin
                        Result := 0.021807006143908316;
                    end
                    else
                    begin
                        Result := 0.0071250762071723532;
                    end;
                end;
            end
            else
            begin
                if features[228] <= -5029.4999999999991 then
                begin
                    Result := 0.021656088378010446;
                end
                else
                begin
                    if features[229] <= 529.50000000000011 then
                    begin
                        Result := 0.032053018243585835;
                    end
                    else
                    begin
                        Result := 0.046355297451471753;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_22(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -341.49999999999994 then
    begin
        if features[166] <= -199630583.99999997 then
        begin
            Result := -0.024338092143481656;
        end
        else
        begin
            if features[226] <= -1023.4999999999999 then
            begin
                Result := -0.020720576422109813;
            end
            else
            begin
                if features[216] <= -7164.9999999999991 then
                begin
                    Result := 0.02611949681636383;
                end
                else
                begin
                    Result := -0.0033255212784111562;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -158301679.99999997 then
        begin
            if features[166] <= -263177239.99999997 then
            begin
                if features[225] <= -3869.4999999999995 then
                begin
                    Result := -0.014821101910227678;
                end
                else
                begin
                    Result := 0.021486111630148744;
                end;
            end
            else
            begin
                if features[229] <= 529.50000000000011 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := 0.0020811859304153556;
                    end
                    else
                    begin
                        Result := 0.030935202474177359;
                    end;
                end
                else
                begin
                    Result := 0.035003176483269727;
                end;
            end;
        end
        else
        begin
            if features[229] <= 260.50000000000006 then
            begin
                if features[226] <= -71.499999999999986 then
                begin
                    Result := 0.012030858358414309;
                end
                else
                begin
                    if features[215] <= -5467.4999999999991 then
                    begin
                        Result := 0.012936805869581031;
                    end
                    else
                    begin
                        Result := 0.024838183256421325;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6089.4999999999991 then
                begin
                    if features[175] <= -69.499999999999986 then
                    begin
                        Result := 0.0034243027427279388;
                    end
                    else
                    begin
                        Result := 0.02933770787188212;
                    end;
                end
                else
                begin
                    Result := 0.038914276773463534;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_23(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -341.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            if features[90] <= 7.5000000000000009 then
            begin
                Result := -0.025045667942770994;
            end
            else
            begin
                Result := 0.037254629292857111;
            end;
        end
        else
        begin
            if features[226] <= -882.49999999999989 then
            begin
                Result := -0.018727040863895861;
            end
            else
            begin
                if features[177] <= -5501.4999999999991 then
                begin
                    Result := -0.0043250011099540409;
                end
                else
                begin
                    Result := 0.010222936950920573;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -217256167.99999997 then
        begin
            if features[222] <= -5503.4999999999991 then
            begin
                Result := -0.015430441596186954;
            end
            else
            begin
                if features[226] <= 529.50000000000011 then
                begin
                    Result := -0.0029639614842770887;
                end
                else
                begin
                    Result := 0.032808392123921497;
                end;
            end;
        end
        else
        begin
            if features[226] <= 124.50000000000001 then
            begin
                if features[166] <= -139258119.99999997 then
                begin
                    Result := 0.0047116785460522316;
                end
                else
                begin
                    if features[151] <= 24.500000000000004 then
                    begin
                        Result := 0.018030060532652686;
                    end
                    else
                    begin
                        Result := 0.0069459622243571058;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -4587.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.007154019506512033;
                    end
                    else
                    begin
                        Result := 0.026834607280722629;
                    end;
                end
                else
                begin
                    if features[226] <= 633.50000000000011 then
                    begin
                        Result := 0.031205220992263541;
                    end
                    else
                    begin
                        Result := 0.046064887699334194;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_24(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -281.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.02482969669168799;
        end
        else
        begin
            if features[229] <= -679.49999999999989 then
            begin
                if features[180] <= -4377.4999999999991 then
                begin
                    Result := -0.019393366375131293;
                end
                else
                begin
                    Result := 0.035713947092537605;
                end;
            end
            else
            begin
                if features[74] <= 6.5000000000000009 then
                begin
                    Result := 0.0069504060198105379;
                end
                else
                begin
                    Result := -0.0061598772240122647;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -217256167.99999997 then
        begin
            if features[229] <= 185.50000000000003 then
            begin
                Result := -0.011651403813336394;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.007406837022256061;
                end
                else
                begin
                    Result := 0.026947580247507142;
                end;
            end;
        end
        else
        begin
            if features[229] <= 118.50000000000001 then
            begin
                if features[166] <= -39740415.999999993 then
                begin
                    if features[90] <= -1.4999999999999998 then
                    begin
                        Result := -0.0080932630259339389;
                    end
                    else
                    begin
                        Result := 0.010471063331818862;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0082722838140909995;
                    end
                    else
                    begin
                        Result := 0.02659629564849262;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -4731.4999999999991 then
                begin
                    if features[225] <= -6421.4999999999991 then
                    begin
                        Result := -0.0019800599424040005;
                    end
                    else
                    begin
                        Result := 0.023506384407729553;
                    end;
                end
                else
                begin
                    Result := 0.036470183876599144;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_25(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -335.49999999999994 then
    begin
        if features[226] <= -893.49999999999989 then
        begin
            if features[90] <= 9.5000000000000018 then
            begin
                Result := -0.024811908004125433;
            end
            else
            begin
                Result := 0.035944648548275476;
            end;
        end
        else
        begin
            if features[108] <= -244.49999999999997 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.008047460756065718;
                end
                else
                begin
                    Result := -0.021216502330655834;
                end;
            end
            else
            begin
                if features[177] <= -5501.4999999999991 then
                begin
                    Result := -0.0067316960188674897;
                end
                else
                begin
                    Result := 0.018868574830572696;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -28.499999999999996 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                Result := 0.0080629553647042548;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.013510396388764591;
                end
                else
                begin
                    Result := 0.0055926784080266162;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[184] <= -935.49999999999989 then
                begin
                    Result := -0.0077749460784241461;
                end
                else
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.021506663680635266;
                    end
                    else
                    begin
                        Result := 0.0092471225367408132;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 741.50000000000011 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.013971354206650594;
                    end
                    else
                    begin
                        Result := 0.030867140611324523;
                    end;
                end
                else
                begin
                    Result := 0.042345507594498809;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_26(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -438.49999999999994 then
    begin
        if features[166] <= -229466495.99999997 then
        begin
            Result := -0.025338490162602825;
        end
        else
        begin
            if features[226] <= -882.49999999999989 then
            begin
                Result := -0.018118243238348746;
            end
            else
            begin
                Result := -0.0035830591619822739;
            end;
        end;
    end
    else
    begin
        if features[166] <= -217256167.99999997 then
        begin
            if features[166] <= -325197183.99999994 then
            begin
                Result := -0.018009011291704579;
            end
            else
            begin
                if features[225] <= -3913.4999999999995 then
                begin
                    if features[135] <= 5.5000000000000009 then
                    begin
                        Result := -0.0060477667342916019;
                    end
                    else
                    begin
                        Result := 0.037507687250591552;
                    end;
                end
                else
                begin
                    Result := 0.025906436127636337;
                end;
            end;
        end
        else
        begin
            if features[229] <= 226.50000000000003 then
            begin
                if features[226] <= -52.499999999999993 then
                begin
                    if features[166] <= -67825651.999999985 then
                    begin
                        Result := 0.0045326720708634754;
                    end
                    else
                    begin
                        Result := 0.01375660496160629;
                    end;
                end
                else
                begin
                    if features[0] <= 158407.50000000003 then
                    begin
                        Result := 0.014954946337360268;
                    end
                    else
                    begin
                        Result := 0.029789615790488486;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6109.4999999999991 then
                begin
                    if features[175] <= -290.49999999999994 then
                    begin
                        Result := -0.00089359415748656843;
                    end
                    else
                    begin
                        Result := 0.021960360566730966;
                    end;
                end
                else
                begin
                    if features[226] <= 633.50000000000011 then
                    begin
                        Result := 0.028322053917497883;
                    end
                    else
                    begin
                        Result := 0.041247601885838342;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_27(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -438.49999999999994 then
    begin
        if features[166] <= -229466495.99999997 then
        begin
            Result := -0.025079655838884621;
        end
        else
        begin
            if features[229] <= -824.49999999999989 then
            begin
                Result := -0.020046567536518664;
            end
            else
            begin
                if features[216] <= -6261.4999999999991 then
                begin
                    if features[166] <= -127464423.99999999 then
                    begin
                        Result := -0.010179586516214546;
                    end
                    else
                    begin
                        Result := 0.02340966235154571;
                    end;
                end
                else
                begin
                    if features[176] <= -6433.4999999999991 then
                    begin
                        Result := -0.016329318387471134;
                    end
                    else
                    begin
                        Result := -0.002194733123011505;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -173005119.99999997 then
        begin
            if features[222] <= -4965.4999999999991 then
            begin
                if features[166] <= -306868479.99999994 then
                begin
                    Result := -0.019484293952253477;
                end
                else
                begin
                    Result := -0.0038842530282697015;
                end;
            end
            else
            begin
                if features[229] <= 456.50000000000006 then
                begin
                    Result := 0.0053469665035116992;
                end
                else
                begin
                    Result := 0.03584800492313802;
                end;
            end;
        end
        else
        begin
            if features[229] <= 226.50000000000003 then
            begin
                if features[226] <= -52.499999999999993 then
                begin
                    Result := 0.0084550586458924364;
                end
                else
                begin
                    Result := 0.017470127517808361;
                end;
            end
            else
            begin
                if features[215] <= -6109.4999999999991 then
                begin
                    if features[158] <= 583.00000000000011 then
                    begin
                        Result := -0.0034847666606253359;
                    end
                    else
                    begin
                        Result := 0.023826445122191026;
                    end;
                end
                else
                begin
                    Result := 0.032553605020938403;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_28(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -438.49999999999994 then
    begin
        if features[166] <= -207069847.99999997 then
        begin
            Result := -0.024321413707638184;
        end
        else
        begin
            if features[226] <= -1034.4999999999998 then
            begin
                Result := -0.019540379616896083;
            end
            else
            begin
                if features[221] <= -6946.4999999999991 then
                begin
                    Result := 0.051744971166998756;
                end
                else
                begin
                    if features[176] <= -6418.4999999999991 then
                    begin
                        Result := -0.010673804536039546;
                    end
                    else
                    begin
                        Result := 0.0015227109790225673;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -223003903.99999997 then
        begin
            if features[228] <= -4104.4999999999991 then
            begin
                Result := -0.011393475388951276;
            end
            else
            begin
                if features[128] <= -15.499999999999998 then
                begin
                    Result := -0.0070574438442561173;
                end
                else
                begin
                    if features[176] <= -4377.4999999999991 then
                    begin
                        Result := 0.039123111518399298;
                    end
                    else
                    begin
                        Result := -0.010846939445646004;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 118.50000000000001 then
            begin
                if features[54] <= 1.5000000000000002 then
                begin
                    Result := 0.0011955338260745344;
                end
                else
                begin
                    if features[166] <= -29654539.999999996 then
                    begin
                        Result := 0.010000833643332045;
                    end
                    else
                    begin
                        Result := 0.025445118893721294;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -4587.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0064748913502232792;
                    end
                    else
                    begin
                        Result := 0.022585986645490937;
                    end;
                end
                else
                begin
                    Result := 0.034007106179550967;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_29(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -440.49999999999994 then
    begin
        if features[226] <= -1034.4999999999998 then
        begin
            Result := -0.024871476546091783;
        end
        else
        begin
            Result := -0.014728754701032715;
        end;
    end
    else
    begin
        if features[229] <= -26.499999999999996 then
        begin
            if features[181] <= -468.49999999999994 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[81] <= 42889.000000000007 then
                    begin
                        Result := -0.0023444950080973156;
                    end
                    else
                    begin
                        Result := 0.02038499236605814;
                    end;
                end
                else
                begin
                    Result := -0.01347323916875918;
                end;
            end
            else
            begin
                if features[177] <= -5117.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.010159356279706081;
                    end
                    else
                    begin
                        Result := -0.0018020222162242463;
                    end;
                end
                else
                begin
                    Result := 0.021156307996291937;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[185] <= -376.87499999999994 then
                begin
                    if features[221] <= -5987.4999999999991 then
                    begin
                        Result := -0.01250844148621464;
                    end
                    else
                    begin
                        Result := 0.010840149959770406;
                    end;
                end
                else
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.020857289810686835;
                    end
                    else
                    begin
                        Result := 0.0078577002342600458;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 529.50000000000011 then
                begin
                    if features[215] <= -7478.4999999999991 then
                    begin
                        Result := -0.01534844368730473;
                    end
                    else
                    begin
                        Result := 0.024175750468584736;
                    end;
                end
                else
                begin
                    Result := 0.038089108203333374;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_30(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -223003903.99999997 then
    begin
        if features[223] <= -489.49999999999994 then
        begin
            Result := -0.024316663510483338;
        end
        else
        begin
            if features[166] <= -325197183.99999994 then
            begin
                Result := -0.019568021226115201;
            end
            else
            begin
                Result := -0.0020836789851126055;
            end;
        end;
    end
    else
    begin
        if features[223] <= -525.49999999999989 then
        begin
            if features[177] <= -5501.4999999999991 then
            begin
                if features[223] <= -814.49999999999989 then
                begin
                    if features[227] <= -4660.4999999999991 then
                    begin
                        Result := -0.0048565637737473218;
                    end
                    else
                    begin
                        Result := -0.022028780055039276;
                    end;
                end
                else
                begin
                    Result := -0.0028198717971404485;
                end;
            end
            else
            begin
                if features[144] <= 493.50000000000006 then
                begin
                    Result := 0.0020885455362983523;
                end
                else
                begin
                    Result := 0.07360739127191232;
                end;
            end;
        end
        else
        begin
            if features[223] <= 11.500000000000002 then
            begin
                if features[166] <= -67825651.999999985 then
                begin
                    Result := 0.0040785910938707639;
                end
                else
                begin
                    if features[151] <= -13.499999999999998 then
                    begin
                        Result := 0.023257341453429572;
                    end
                    else
                    begin
                        Result := 0.0087385050205396851;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[166] <= -139258119.99999997 then
                    begin
                        Result := -0.010903455403675294;
                    end
                    else
                    begin
                        Result := 0.012887605459330804;
                    end;
                end
                else
                begin
                    if features[223] <= 544.50000000000011 then
                    begin
                        Result := 0.018937371699057525;
                    end
                    else
                    begin
                        Result := 0.031734319292538213;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_31(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -438.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.024472168159412621;
        end
        else
        begin
            if features[226] <= -882.49999999999989 then
            begin
                Result := -0.016892532161252607;
            end
            else
            begin
                if features[216] <= -6638.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.04838681056911634;
                    end
                    else
                    begin
                        Result := 0.0033228095321737199;
                    end;
                end
                else
                begin
                    if features[176] <= -6433.4999999999991 then
                    begin
                        Result := -0.013155834579775223;
                    end
                    else
                    begin
                        Result := 0.0012860661882249959;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -195698087.99999997 then
        begin
            if features[228] <= -4104.4999999999991 then
            begin
                if features[166] <= -283469215.99999994 then
                begin
                    Result := -0.016920582131625068;
                end
                else
                begin
                    Result := -0.0023739934948773709;
                end;
            end
            else
            begin
                if features[226] <= 221.50000000000003 then
                begin
                    Result := 0.0029705751198911999;
                end
                else
                begin
                    Result := 0.031041238921505246;
                end;
            end;
        end
        else
        begin
            if features[226] <= 397.50000000000006 then
            begin
                if features[226] <= -99.499999999999986 then
                begin
                    Result := 0.0067405017635745017;
                end
                else
                begin
                    if features[227] <= -5492.4999999999991 then
                    begin
                        Result := 0.0086051025078620579;
                    end
                    else
                    begin
                        Result := 0.01837569997081509;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -7276.4999999999991 then
                begin
                    Result := 0.0049584072013250814;
                end
                else
                begin
                    Result := 0.030879686754775138;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_32(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -507.49999999999994 then
    begin
        if features[166] <= -237796711.99999997 then
        begin
            Result := -0.025002053492514144;
        end
        else
        begin
            if features[177] <= -5591.4999999999991 then
            begin
                if features[224] <= -5847.4999999999991 then
                begin
                    Result := 0.0099139872926086239;
                end
                else
                begin
                    Result := -0.015162930894217727;
                end;
            end
            else
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -6.5832773758730891E-05;
                end
                else
                begin
                    Result := 0.059067341652897079;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -176496199.99999997 then
        begin
            if features[226] <= 373.50000000000006 then
            begin
                if features[166] <= -263177239.99999997 then
                begin
                    Result := -0.01504523680146768;
                end
                else
                begin
                    Result := -0.0011810728502434603;
                end;
            end
            else
            begin
                if features[218] <= -6389.4999999999991 then
                begin
                    Result := -0.0032244843500495914;
                end
                else
                begin
                    Result := 0.032129273971375376;
                end;
            end;
        end
        else
        begin
            if features[229] <= 226.50000000000003 then
            begin
                if features[157] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0033584131304485784;
                end
                else
                begin
                    if features[166] <= -74583523.999999985 then
                    begin
                        Result := 0.0093814184635014255;
                    end
                    else
                    begin
                        Result := 0.019875409755567369;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6045.4999999999991 then
                begin
                    if features[54] <= 1.5000000000000002 then
                    begin
                        Result := -0.010773848135946566;
                    end
                    else
                    begin
                        Result := 0.018932025649031403;
                    end;
                end
                else
                begin
                    Result := 0.029561991152395769;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_33(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -440.49999999999994 then
    begin
        if features[226] <= -1034.4999999999998 then
        begin
            if features[90] <= 9.5000000000000018 then
            begin
                Result := -0.024890555394822857;
            end
            else
            begin
                Result := 0.044025427926004446;
            end;
        end
        else
        begin
            if features[129] <= 11876.000000000002 then
            begin
                if features[177] <= -5351.4999999999991 then
                begin
                    Result := -0.01788569554763739;
                end
                else
                begin
                    if features[108] <= -267.49999999999994 then
                    begin
                        Result := -0.015733180835109325;
                    end
                    else
                    begin
                        Result := 0.021725243993015259;
                    end;
                end;
            end
            else
            begin
                Result := 0.0028519897728869542;
            end;
        end;
    end
    else
    begin
        if features[229] <= -30.499999999999996 then
        begin
            if features[184] <= -750.49999999999989 then
            begin
                Result := -0.0074209949617535425;
            end
            else
            begin
                if features[117] <= -89.499999999999986 then
                begin
                    Result := -0.0022760134348327131;
                end
                else
                begin
                    Result := 0.0074624889043406958;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[186] <= -355.83332824707026 then
                begin
                    Result := -0.0036170170678109718;
                end
                else
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.019081150636183895;
                    end
                    else
                    begin
                        Result := 0.0062166107710414416;
                    end;
                end;
            end
            else
            begin
                if features[179] <= -3792.4999999999995 then
                begin
                    if features[226] <= 741.50000000000011 then
                    begin
                        Result := 0.021962572278725861;
                    end
                    else
                    begin
                        Result := 0.036604992295922574;
                    end;
                end
                else
                begin
                    Result := -0.0074472772542095904;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_34(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -530.49999999999989 then
    begin
        if features[166] <= -237796711.99999997 then
        begin
            Result := -0.024687820881684207;
        end
        else
        begin
            if features[177] <= -5015.4999999999991 then
            begin
                if features[227] <= -4660.4999999999991 then
                begin
                    Result := -0.0035887286365116518;
                end
                else
                begin
                    Result := -0.017516023996504912;
                end;
            end
            else
            begin
                if features[62] <= 1.5000000000000002 then
                begin
                    Result := 0.0029505423151806069;
                end
                else
                begin
                    Result := 0.077157010416262495;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -176496199.99999997 then
        begin
            if features[166] <= -309296735.99999994 then
            begin
                Result := -0.016363278747647935;
            end
            else
            begin
                if features[226] <= 53.500000000000007 then
                begin
                    if features[28] <= -5645.4999999999991 then
                    begin
                        Result := -0.0097826223920424032;
                    end
                    else
                    begin
                        Result := 0.0036746622552421473;
                    end;
                end
                else
                begin
                    if features[225] <= -4672.4999999999991 then
                    begin
                        Result := 0.0024911978690714039;
                    end
                    else
                    begin
                        Result := 0.027127831874481034;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 327.50000000000006 then
            begin
                if features[166] <= -74583523.999999985 then
                begin
                    if features[151] <= 72.500000000000014 then
                    begin
                        Result := 0.0084600060334738478;
                    end
                    else
                    begin
                        Result := -0.014304811837165358;
                    end;
                end
                else
                begin
                    Result := 0.014681473943917828;
                end;
            end
            else
            begin
                if features[215] <= -6089.4999999999991 then
                begin
                    Result := 0.011275480588982992;
                end
                else
                begin
                    Result := 0.029763469244985952;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_35(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -507.49999999999994 then
    begin
        if features[166] <= -237796711.99999997 then
        begin
            Result := -0.02470363974902182;
        end
        else
        begin
            if features[177] <= -5591.4999999999991 then
            begin
                if features[227] <= -4724.4999999999991 then
                begin
                    Result := -0.0049498110596571882;
                end
                else
                begin
                    Result := -0.017692014379418593;
                end;
            end
            else
            begin
                if features[63] <= 492.50000000000006 then
                begin
                    Result := 0.00023861398191512377;
                end
                else
                begin
                    Result := 0.049894079154501995;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -158301679.99999997 then
        begin
            if features[166] <= -325197183.99999994 then
            begin
                Result := -0.016611471416842726;
            end
            else
            begin
                if features[222] <= -5309.4999999999991 then
                begin
                    Result := -0.0052632427089360397;
                end
                else
                begin
                    if features[229] <= -147.49999999999997 then
                    begin
                        Result := -0.0052773921698396203;
                    end
                    else
                    begin
                        Result := 0.015139018840630531;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 172.50000000000003 then
            begin
                if features[178] <= 70.500000000000014 then
                begin
                    Result := 0.0079486961910091476;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.031940913394557173;
                    end
                    else
                    begin
                        Result := 0.013143354699959682;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6794.4999999999991 then
                begin
                    Result := 0.0072202956079234527;
                end
                else
                begin
                    if features[226] <= 562.50000000000011 then
                    begin
                        Result := 0.021078233884559816;
                    end
                    else
                    begin
                        Result := 0.033046656105578824;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_36(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -223003903.99999997 then
    begin
        if features[223] <= -489.49999999999994 then
        begin
            Result := -0.023587646228472488;
        end
        else
        begin
            if features[166] <= -325197183.99999994 then
            begin
                Result := -0.018979683337763426;
            end
            else
            begin
                Result := -0.0025813458092818942;
            end;
        end;
    end
    else
    begin
        if features[223] <= -175.49999999999997 then
        begin
            if features[223] <= -796.49999999999989 then
            begin
                if features[227] <= -6063.4999999999991 then
                begin
                    Result := 0.032312830530484928;
                end
                else
                begin
                    if features[180] <= -4465.4999999999991 then
                    begin
                        Result := -0.014074316597204515;
                    end
                    else
                    begin
                        Result := 0.027127388508884406;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    Result := -0.0012973205533229008;
                end
                else
                begin
                    Result := 0.009257600878159104;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[166] <= -110262351.99999999 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := 0.0011545264658967206;
                    end
                    else
                    begin
                        Result := 0.023181960262482062;
                    end;
                end
                else
                begin
                    if features[154] <= 258.50000000000006 then
                    begin
                        Result := 0.017861473231003924;
                    end
                    else
                    begin
                        Result := 0.0025229365375924774;
                    end;
                end;
            end
            else
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.0061776064240517351;
                    end
                    else
                    begin
                        Result := 0.021909110615574254;
                    end;
                end
                else
                begin
                    Result := 0.029912557858702005;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_37(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -440.49999999999994 then
    begin
        if features[166] <= -223003903.99999997 then
        begin
            Result := -0.024234753539963166;
        end
        else
        begin
            if features[224] <= -5847.4999999999991 then
            begin
                Result := 0.015746345192946796;
            end
            else
            begin
                if features[90] <= 9.5000000000000018 then
                begin
                    Result := -0.013123319015875155;
                end
                else
                begin
                    Result := 0.031423259216128402;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -158301679.99999997 then
        begin
            if features[166] <= -263177239.99999997 then
            begin
                if features[226] <= 421.50000000000006 then
                begin
                    Result := -0.014487222759865741;
                end
                else
                begin
                    Result := 0.0098268145107518606;
                end;
            end
            else
            begin
                if features[225] <= -4535.4999999999991 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0031044799662249007;
                    end
                    else
                    begin
                        Result := 0.0218244453249569;
                    end;
                end
                else
                begin
                    Result := 0.014987507435379228;
                end;
            end;
        end
        else
        begin
            if features[229] <= -30.499999999999996 then
            begin
                if features[216] <= -6705.4999999999991 then
                begin
                    Result := 0.028095923978166449;
                end
                else
                begin
                    Result := 0.0054858963691348239;
                end;
            end
            else
            begin
                if features[225] <= -5340.4999999999991 then
                begin
                    if features[151] <= 41.500000000000007 then
                    begin
                        Result := 0.015580785059418178;
                    end
                    else
                    begin
                        Result := -0.0014327319330821892;
                    end;
                end
                else
                begin
                    if features[226] <= 562.50000000000011 then
                    begin
                        Result := 0.018873794495409848;
                    end
                    else
                    begin
                        Result := 0.0329464458843532;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_38(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -440.49999999999994 then
    begin
        if features[226] <= -1034.4999999999998 then
        begin
            if features[90] <= 9.5000000000000018 then
            begin
                Result := -0.024283096052351013;
            end
            else
            begin
                Result := 0.045343014507807727;
            end;
        end
        else
        begin
            if features[180] <= -4778.4999999999991 then
            begin
                if features[129] <= 12288.500000000002 then
                begin
                    Result := -0.015944212879771501;
                end
                else
                begin
                    Result := 0.0028120786458262353;
                end;
            end
            else
            begin
                Result := 0.014720969465414136;
            end;
        end;
    end
    else
    begin
        if features[229] <= 99.500000000000014 then
        begin
            if features[178] <= -1264.4999999999998 then
            begin
                Result := -0.0079077493303187901;
            end
            else
            begin
                if features[229] <= -120.49999999999999 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.00084178708835492937;
                    end
                    else
                    begin
                        Result := 0.021951159922982581;
                    end;
                end
                else
                begin
                    Result := 0.0095009622098522831;
                end;
            end;
        end
        else
        begin
            if features[222] <= -5381.4999999999991 then
            begin
                if features[109] <= -329.49999999999994 then
                begin
                    Result := -0.0095599883173067002;
                end
                else
                begin
                    if features[154] <= 19.500000000000004 then
                    begin
                        Result := 0.017857899326274043;
                    end
                    else
                    begin
                        Result := -0.0074077404964866117;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[217] <= 1799.5000000000002 then
                    begin
                        Result := 0.018428607406025321;
                    end
                    else
                    begin
                        Result := -0.0086230469194168834;
                    end;
                end
                else
                begin
                    Result := 0.026997747980007876;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_39(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -440.49999999999994 then
    begin
        if features[166] <= -225080519.99999997 then
        begin
            Result := -0.024076813167252187;
        end
        else
        begin
            if features[180] <= -4674.4999999999991 then
            begin
                if features[216] <= -7297.4999999999991 then
                begin
                    Result := 0.016274628012925934;
                end
                else
                begin
                    if features[226] <= -1046.4999999999998 then
                    begin
                        Result := -0.022011486853673125;
                    end
                    else
                    begin
                        Result := -0.0081356924896308479;
                    end;
                end;
            end
            else
            begin
                if features[227] <= -3219.4999999999995 then
                begin
                    Result := 0.035879255436137868;
                end
                else
                begin
                    Result := -0.021684620413731186;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -140928295.99999997 then
        begin
            if features[166] <= -327673023.99999994 then
            begin
                Result := -0.017418940716382291;
            end
            else
            begin
                if features[222] <= -5459.4999999999991 then
                begin
                    Result := -0.0052779942873345757;
                end
                else
                begin
                    if features[229] <= -81.499999999999986 then
                    begin
                        Result := -0.001833654118411264;
                    end
                    else
                    begin
                        Result := 0.013372849496953845;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 312.50000000000006 then
            begin
                if features[158] <= 1732.5000000000002 then
                begin
                    if features[216] <= -4382.4999999999991 then
                    begin
                        Result := 0.0045562265850339276;
                    end
                    else
                    begin
                        Result := 0.015694142804156742;
                    end;
                end
                else
                begin
                    Result := 0.01537444329052918;
                end;
            end
            else
            begin
                if features[215] <= -6089.4999999999991 then
                begin
                    Result := 0.012218657841529715;
                end
                else
                begin
                    Result := 0.028378942813139015;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_40(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -440.49999999999994 then
    begin
        if features[226] <= -1034.4999999999998 then
        begin
            if features[90] <= 9.5000000000000018 then
            begin
                Result := -0.024093323574073362;
            end
            else
            begin
                Result := 0.044626690680472418;
            end;
        end
        else
        begin
            if features[124] <= -27.499999999999996 then
            begin
                Result := -0.018905640147550966;
            end
            else
            begin
                Result := -0.0077260620355295703;
            end;
        end;
    end
    else
    begin
        if features[226] <= -71.499999999999986 then
        begin
            if features[178] <= -235.49999999999997 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[173] <= -5560.4999999999991 then
                    begin
                        Result := 0.011314747058287207;
                    end
                    else
                    begin
                        Result := -0.0031554601520378772;
                    end;
                end
                else
                begin
                    if features[164] <= 13702725.000000002 then
                    begin
                        Result := -0.020888717832615505;
                    end
                    else
                    begin
                        Result := -0.003002303756897225;
                    end;
                end;
            end
            else
            begin
                Result := 0.0056897684353304006;
            end;
        end
        else
        begin
            if features[225] <= -5461.4999999999991 then
            begin
                if features[165] <= -110907067.99999999 then
                begin
                    Result := 0.019439861722800173;
                end
                else
                begin
                    if features[221] <= -5969.4999999999991 then
                    begin
                        Result := -0.0033892422003597607;
                    end
                    else
                    begin
                        Result := 0.0082646109392237842;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 456.50000000000006 then
                begin
                    if features[171] <= 2.5000000000000004 then
                    begin
                        Result := 0.0073398076238687521;
                    end
                    else
                    begin
                        Result := 0.018323297536322111;
                    end;
                end
                else
                begin
                    Result := 0.029919934710567409;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_41(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -256058583.99999997 then
    begin
        if features[226] <= -500.49999999999994 then
        begin
            Result := -0.024215664617750557;
        end
        else
        begin
            if features[225] <= -4549.4999999999991 then
            begin
                Result := -0.015807737519982584;
            end
            else
            begin
                Result := 0.0052762519415065377;
            end;
        end;
    end
    else
    begin
        if features[226] <= -313.49999999999994 then
        begin
            if features[226] <= -893.49999999999989 then
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.017692162904078466;
                end
                else
                begin
                    if features[180] <= -4960.4999999999991 then
                    begin
                        Result := 0.0;
                    end
                    else
                    begin
                        Result := 0.090046825736399799;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    Result := -0.0055463798440642436;
                end
                else
                begin
                    if features[151] <= -19.499999999999996 then
                    begin
                        Result := 0.01446555116237655;
                    end
                    else
                    begin
                        Result := -0.0020435418301689851;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 467.50000000000006 then
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    if features[176] <= -7655.4999999999991 then
                    begin
                        Result := -0.0077549936030178084;
                    end
                    else
                    begin
                        Result := 0.0070809649424365744;
                    end;
                end
                else
                begin
                    if features[158] <= 1267.5000000000002 then
                    begin
                        Result := 0.0088544694690553729;
                    end
                    else
                    begin
                        Result := 0.01752833384485988;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5297.4999999999991 then
                begin
                    Result := 0.0083726890411260531;
                end
                else
                begin
                    Result := 0.028627579757551577;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_42(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -477.49999999999994 then
    begin
        if features[166] <= -227331887.99999997 then
        begin
            Result := -0.023335501609860906;
        end
        else
        begin
            if features[177] <= -5501.4999999999991 then
            begin
                if features[224] <= -5847.4999999999991 then
                begin
                    Result := 0.0090908694917726813;
                end
                else
                begin
                    Result := -0.012548533544477334;
                end;
            end
            else
            begin
                if features[216] <= -6261.4999999999991 then
                begin
                    Result := 0.055732921862638146;
                end
                else
                begin
                    Result := 0.00054376504987094123;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -185915207.99999997 then
        begin
            if features[229] <= 185.50000000000003 then
            begin
                if features[81] <= -2957.4999999999995 then
                begin
                    Result := -0.014509810301327607;
                end
                else
                begin
                    Result := -0.0023378739204055086;
                end;
            end
            else
            begin
                if features[224] <= -4675.4999999999991 then
                begin
                    Result := 0.0033928166606920157;
                end
                else
                begin
                    Result := 0.033304577747246863;
                end;
            end;
        end
        else
        begin
            if features[229] <= 312.50000000000006 then
            begin
                if features[154] <= 76.500000000000014 then
                begin
                    if features[166] <= -29654539.999999996 then
                    begin
                        Result := 0.0089014757070493729;
                    end
                    else
                    begin
                        Result := 0.020109088400678529;
                    end;
                end
                else
                begin
                    if features[222] <= -5399.4999999999991 then
                    begin
                        Result := -0.0046804244699281414;
                    end
                    else
                    begin
                        Result := 0.0094621456771783255;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6273.4999999999991 then
                begin
                    Result := 0.0068147797755724396;
                end
                else
                begin
                    Result := 0.027057835047555191;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_43(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -530.49999999999989 then
    begin
        if features[166] <= -237796711.99999997 then
        begin
            Result := -0.023630169553033663;
        end
        else
        begin
            if features[180] <= -4674.4999999999991 then
            begin
                if features[227] <= -5694.4999999999991 then
                begin
                    Result := 0.011929768283861037;
                end
                else
                begin
                    Result := -0.012655880941541107;
                end;
            end
            else
            begin
                if features[108] <= 89.500000000000014 then
                begin
                    Result := 0.0043654820229899098;
                end
                else
                begin
                    Result := 0.070137897379011008;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -185915207.99999997 then
        begin
            if features[226] <= 136.50000000000003 then
            begin
                if features[166] <= -327673023.99999994 then
                begin
                    Result := -0.019178841979284322;
                end
                else
                begin
                    Result := -0.0058771942371252644;
                end;
            end
            else
            begin
                if features[225] <= -4188.4999999999991 then
                begin
                    if features[135] <= 4.5000000000000009 then
                    begin
                        Result := -0.0033109367874268867;
                    end
                    else
                    begin
                        Result := 0.038806247217654716;
                    end;
                end
                else
                begin
                    Result := 0.029683750712865227;
                end;
            end;
        end
        else
        begin
            if features[229] <= 529.50000000000011 then
            begin
                if features[226] <= -99.499999999999986 then
                begin
                    if features[135] <= 1.5000000000000002 then
                    begin
                        Result := 0.0038024570932701078;
                    end
                    else
                    begin
                        Result := 0.019645630940524482;
                    end;
                end
                else
                begin
                    if features[215] <= -6160.4999999999991 then
                    begin
                        Result := 0.0018539825871567506;
                    end
                    else
                    begin
                        Result := 0.014302470448569291;
                    end;
                end;
            end
            else
            begin
                Result := 0.027466312703230807;
            end;
        end;
    end;
end;

function bidirectional_tree_44(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -478.49999999999994 then
    begin
        if features[166] <= -207069847.99999997 then
        begin
            if features[90] <= 7.5000000000000009 then
            begin
                Result := -0.023813986552210148;
            end
            else
            begin
                Result := 0.04256853728228701;
            end;
        end
        else
        begin
            if features[216] <= -6792.4999999999991 then
            begin
                Result := 0.01400954666887832;
            end
            else
            begin
                Result := -0.011525157962174151;
            end;
        end;
    end
    else
    begin
        if features[166] <= -140928295.99999997 then
        begin
            if features[166] <= -263177239.99999997 then
            begin
                Result := -0.011882700730079451;
            end
            else
            begin
                if features[222] <= -5459.4999999999991 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0060733960264257644;
                    end
                    else
                    begin
                        Result := 0.017279312825870179;
                    end;
                end
                else
                begin
                    if features[229] <= 368.50000000000006 then
                    begin
                        Result := 0.0050949358893927869;
                    end
                    else
                    begin
                        Result := 0.022788406893317043;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= -71.499999999999986 then
            begin
                if features[216] <= -6575.4999999999991 then
                begin
                    Result := 0.024723232477651173;
                end
                else
                begin
                    if features[124] <= -193.49999999999997 then
                    begin
                        Result := -0.0088646500681303919;
                    end
                    else
                    begin
                        Result := 0.0060528219593790874;
                    end;
                end;
            end
            else
            begin
                if features[222] <= -4661.4999999999991 then
                begin
                    if features[154] <= 258.50000000000006 then
                    begin
                        Result := 0.015624028783914648;
                    end
                    else
                    begin
                        Result := 0.0020675430502312187;
                    end;
                end
                else
                begin
                    Result := 0.023795077348325408;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_45(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[166] <= -344168303.99999994 then
        begin
            Result := -0.023882344291406579;
        end
        else
        begin
            if features[225] <= -3913.4999999999995 then
            begin
                Result := -0.013806777594817394;
            end
            else
            begin
                Result := 0.019705803796578582;
            end;
        end;
    end
    else
    begin
        if features[223] <= -525.49999999999989 then
        begin
            if features[180] <= -4674.4999999999991 then
            begin
                if features[216] <= -7074.9999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.043732644730849;
                    end
                    else
                    begin
                        Result := 0.0023694420457964732;
                    end;
                end
                else
                begin
                    if features[223] <= -882.49999999999989 then
                    begin
                        Result := -0.01621431234078349;
                    end
                    else
                    begin
                        Result := -0.0040260629624858605;
                    end;
                end;
            end
            else
            begin
                if features[227] <= -3219.4999999999995 then
                begin
                    Result := 0.035401075529297936;
                end
                else
                begin
                    Result := -0.016442943162267572;
                end;
            end;
        end
        else
        begin
            if features[223] <= 154.50000000000003 then
            begin
                if features[166] <= -139258119.99999997 then
                begin
                    Result := -0.00037004592074864687;
                end
                else
                begin
                    Result := 0.0082729522245885596;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[217] <= 1160.5000000000002 then
                    begin
                        Result := 0.01085877655272113;
                    end
                    else
                    begin
                        Result := -0.0089516814947780635;
                    end;
                end
                else
                begin
                    if features[77] <= 2937.5000000000005 then
                    begin
                        Result := 0.010893417672877721;
                    end
                    else
                    begin
                        Result := 0.021659063048834085;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_46(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -440.49999999999994 then
    begin
        if features[226] <= -1034.4999999999998 then
        begin
            Result := -0.023118198603881427;
        end
        else
        begin
            if features[216] <= -6792.4999999999991 then
            begin
                if features[48] <= 10480.500000000002 then
                begin
                    Result := -0.0020945907662043937;
                end
                else
                begin
                    Result := 0.0467178259991365;
                end;
            end
            else
            begin
                Result := -0.013200859964966769;
            end;
        end;
    end
    else
    begin
        if features[229] <= -16.499999999999996 then
        begin
            if features[178] <= 116.50000000000001 then
            begin
                if features[187] <= -21.232142448425289 then
                begin
                    Result := -0.0087223270273881544;
                end
                else
                begin
                    if features[222] <= -5439.4999999999991 then
                    begin
                        Result := -0.0031508161222132246;
                    end
                    else
                    begin
                        Result := 0.0060851580934120049;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.026639301294630546;
                end
                else
                begin
                    Result := 0.0048562578435142507;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4621.4999999999991 then
            begin
                if features[18] <= 10.500000000000002 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0037282559807220389;
                    end
                    else
                    begin
                        Result := 0.008575181453335445;
                    end;
                end
                else
                begin
                    Result := 0.016090783270700383;
                end;
            end
            else
            begin
                if features[229] <= 456.50000000000006 then
                begin
                    if features[171] <= 2.5000000000000004 then
                    begin
                        Result := 0.00610164568741999;
                    end
                    else
                    begin
                        Result := 0.021398942624889918;
                    end;
                end
                else
                begin
                    Result := 0.03093593151818096;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_47(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[226] <= -407.49999999999994 then
        begin
            Result := -0.02346561651391145;
        end
        else
        begin
            Result := -0.0098892808809211991;
        end;
    end
    else
    begin
        if features[229] <= -120.49999999999999 then
        begin
            if features[226] <= -902.49999999999989 then
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    if features[216] <= -7164.9999999999991 then
                    begin
                        Result := 0.016404303507492439;
                    end
                    else
                    begin
                        Result := -0.019501190822679985;
                    end;
                end
                else
                begin
                    Result := 0.02578260522228026;
                end;
            end
            else
            begin
                if features[166] <= -82083855.999999985 then
                begin
                    if features[219] <= -5077.4999999999991 then
                    begin
                        Result := -0.0053710671889527131;
                    end
                    else
                    begin
                        Result := 0.0082671315437900465;
                    end;
                end
                else
                begin
                    if features[216] <= -6993.4999999999991 then
                    begin
                        Result := 0.037305626667636697;
                    end
                    else
                    begin
                        Result := 0.0052324415755616253;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 529.50000000000011 then
            begin
                if features[166] <= -140928295.99999997 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := 0.00077132397369909919;
                    end
                    else
                    begin
                        Result := 0.022883767993320838;
                    end;
                end
                else
                begin
                    if features[91] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.015233933447840554;
                    end
                    else
                    begin
                        Result := 0.0066037439483898237;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5244.4999999999991 then
                begin
                    Result := 0.010580982346118133;
                end
                else
                begin
                    Result := 0.029660228903136063;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_48(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -453.49999999999994 then
    begin
        if features[166] <= -260709623.99999997 then
        begin
            Result := -0.023894371161550319;
        end
        else
        begin
            if features[216] <= -7074.9999999999991 then
            begin
                Result := 0.014494762538937795;
            end
            else
            begin
                if features[180] <= -4729.4999999999991 then
                begin
                    Result := -0.013222468390970478;
                end
                else
                begin
                    if features[158] <= 24625.000000000004 then
                    begin
                        Result := 0.0055942036594889511;
                    end
                    else
                    begin
                        Result := 0.074836252847016491;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -140928295.99999997 then
        begin
            if features[222] <= -5459.4999999999991 then
            begin
                if features[135] <= 1.5000000000000002 then
                begin
                    Result := -0.0095937291866295613;
                end
                else
                begin
                    Result := 0.015777878365181089;
                end;
            end
            else
            begin
                if features[229] <= 368.50000000000006 then
                begin
                    if features[81] <= -1131.4999999999998 then
                    begin
                        Result := -0.0068741756929785519;
                    end
                    else
                    begin
                        Result := 0.0066710555073727848;
                    end;
                end
                else
                begin
                    Result := 0.021308302819100788;
                end;
            end;
        end
        else
        begin
            if features[229] <= 118.50000000000001 then
            begin
                if features[136] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.0015348837690475662;
                end
                else
                begin
                    if features[166] <= -8296810.4999999991 then
                    begin
                        Result := 0.0073290948759710296;
                    end
                    else
                    begin
                        Result := 0.021807090900777454;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 2937.5000000000005 then
                begin
                    Result := 0.011581256988453276;
                end
                else
                begin
                    Result := 0.021494475241031662;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_49(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[226] <= -500.49999999999994 then
        begin
            Result := -0.023760627617494916;
        end
        else
        begin
            if features[229] <= 702.50000000000011 then
            begin
                Result := -0.011936573485113807;
            end
            else
            begin
                Result := 0.026219506413457612;
            end;
        end;
    end
    else
    begin
        if features[226] <= -278.49999999999994 then
        begin
            if features[226] <= -1034.4999999999998 then
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.019193370642413519;
                end
                else
                begin
                    Result := 0.01970248889677207;
                end;
            end
            else
            begin
                if features[177] <= -5591.4999999999991 then
                begin
                    if features[37] <= 2.5000000000000004 then
                    begin
                        Result := 0.018030934989009692;
                    end
                    else
                    begin
                        Result := -0.0051222288537892706;
                    end;
                end
                else
                begin
                    if features[108] <= -190.49999999999997 then
                    begin
                        Result := -0.005194265208039197;
                    end
                    else
                    begin
                        Result := 0.019496037472467035;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 529.50000000000011 then
            begin
                if features[166] <= -41992811.999999993 then
                begin
                    if features[228] <= -5348.4999999999991 then
                    begin
                        Result := -0.00017902637100174386;
                    end
                    else
                    begin
                        Result := 0.0089316516957378429;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0070342343267740179;
                    end
                    else
                    begin
                        Result := 0.017991967386958248;
                    end;
                end;
            end
            else
            begin
                if features[228] <= -5559.4999999999991 then
                begin
                    Result := 0.0047047915923220489;
                end
                else
                begin
                    Result := 0.027576060630459743;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_50(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -478.49999999999994 then
    begin
        if features[226] <= -1034.4999999999998 then
        begin
            if features[135] <= 9.5000000000000018 then
            begin
                Result := -0.02285441871634987;
            end
            else
            begin
                Result := 0.035543343083158332;
            end;
        end
        else
        begin
            if features[216] <= -6792.4999999999991 then
            begin
                Result := 0.010336013974057055;
            end
            else
            begin
                if features[177] <= -5740.4999999999991 then
                begin
                    Result := -0.015734834758171716;
                end
                else
                begin
                    Result := 0.0012115450608778866;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -71.499999999999986 then
        begin
            if features[9] <= 2.5000000000000004 then
            begin
                if features[81] <= -212.49999999999997 then
                begin
                    Result := -0.0089455429922011814;
                end
                else
                begin
                    Result := 0.0017996743088007261;
                end;
            end
            else
            begin
                if features[185] <= -109.83333206176756 then
                begin
                    Result := -0.0037466899451632611;
                end
                else
                begin
                    Result := 0.017702965253448482;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4444.4999999999991 then
            begin
                if features[176] <= -4760.4999999999991 then
                begin
                    if features[215] <= -6137.4999999999991 then
                    begin
                        Result := -0.00033518829252339552;
                    end
                    else
                    begin
                        Result := 0.012353428247645723;
                    end;
                end
                else
                begin
                    if features[181] <= -536.49999999999989 then
                    begin
                        Result := -0.018844450056593895;
                    end
                    else
                    begin
                        Result := 0.0060238986826160945;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 260.50000000000006 then
                begin
                    Result := 0.011835409764082101;
                end
                else
                begin
                    Result := 0.026231729413289495;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_51(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -440.49999999999994 then
    begin
        if features[226] <= -1034.4999999999998 then
        begin
            if features[90] <= 2.5000000000000004 then
            begin
                Result := -0.023152790139487733;
            end
            else
            begin
                if features[180] <= -4882.4999999999991 then
                begin
                    Result := -0.0041531634591773703;
                end
                else
                begin
                    Result := 0.086012985879638848;
                end;
            end;
        end
        else
        begin
            if features[129] <= 11509.500000000002 then
            begin
                Result := -0.012150630761398929;
            end
            else
            begin
                Result := 0.0068628482635941859;
            end;
        end;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[178] <= 70.500000000000014 then
                begin
                    if features[176] <= -4377.4999999999991 then
                    begin
                        Result := 0.0058121623779240211;
                    end
                    else
                    begin
                        Result := -0.0068864560209337573;
                    end;
                end
                else
                begin
                    Result := 0.014070547544436214;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[177] <= -6245.4999999999991 then
                    begin
                        Result := -0.018239095993295932;
                    end
                    else
                    begin
                        Result := 0.0017513481771580042;
                    end;
                end
                else
                begin
                    if features[154] <= 40.500000000000007 then
                    begin
                        Result := 0.0082619838642872031;
                    end
                    else
                    begin
                        Result := -0.0059756619047958304;
                    end;
                end;
            end;
        end
        else
        begin
            if features[218] <= -6563.4999999999991 then
            begin
                if features[176] <= -6686.4999999999991 then
                begin
                    Result := 0.014600054028045109;
                end
                else
                begin
                    Result := -0.0063414383084218458;
                end;
            end
            else
            begin
                Result := 0.023516442433255291;
            end;
        end;
    end;
end;

function bidirectional_tree_52(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -485.49999999999994 then
    begin
        if features[166] <= -207069847.99999997 then
        begin
            Result := -0.022979717007811953;
        end
        else
        begin
            if features[227] <= -4660.4999999999991 then
            begin
                if features[176] <= -6418.4999999999991 then
                begin
                    Result := -0.007122034433190128;
                end
                else
                begin
                    if features[37] <= 4.5000000000000009 then
                    begin
                        Result := 0.02855033620054738;
                    end
                    else
                    begin
                        Result := -0.0019700795508004027;
                    end;
                end;
            end
            else
            begin
                Result := -0.012657952044833498;
            end;
        end;
    end
    else
    begin
        if features[166] <= -140928295.99999997 then
        begin
            if features[166] <= -309296735.99999994 then
            begin
                Result := -0.014090194816927214;
            end
            else
            begin
                if features[222] <= -5459.4999999999991 then
                begin
                    Result := -0.004773448924910135;
                end
                else
                begin
                    if features[76] <= 10.500000000000002 then
                    begin
                        Result := 0.0051005476960401409;
                    end
                    else
                    begin
                        Result := 0.034167098957579557;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 118.50000000000001 then
            begin
                if features[216] <= -7394.4999999999991 then
                begin
                    Result := 0.032087017262571911;
                end
                else
                begin
                    if features[157] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.00059284018323336638;
                    end
                    else
                    begin
                        Result := 0.007726492071287192;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 741.50000000000011 then
                begin
                    if features[220] <= 236.50000000000003 then
                    begin
                        Result := 0.021750040604059842;
                    end
                    else
                    begin
                        Result := 0.010419748313359734;
                    end;
                end
                else
                begin
                    Result := 0.025786359379930915;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_53(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[226] <= -407.49999999999994 then
        begin
            Result := -0.022861512560892645;
        end
        else
        begin
            if features[222] <= -5583.4999999999991 then
            begin
                Result := -0.016327077197386949;
            end
            else
            begin
                if features[226] <= 447.50000000000006 then
                begin
                    Result := -0.0057919601075120605;
                end
                else
                begin
                    Result := 0.023580843472857417;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -71.499999999999986 then
        begin
            if features[226] <= -882.49999999999989 then
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.016178652394172408;
                end
                else
                begin
                    Result := 0.02036182446831214;
                end;
            end
            else
            begin
                if features[166] <= -76688567.999999985 then
                begin
                    if features[90] <= 9.5000000000000018 then
                    begin
                        Result := -0.0021845010730665898;
                    end
                    else
                    begin
                        Result := 0.026180035587629404;
                    end;
                end
                else
                begin
                    if features[10] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.010493535018808668;
                    end
                    else
                    begin
                        Result := -0.00096147198879954906;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 577.50000000000011 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[217] <= 432.50000000000006 then
                    begin
                        Result := 0.0099543896938030715;
                    end
                    else
                    begin
                        Result := -0.0088045441497989277;
                    end;
                end
                else
                begin
                    if features[173] <= -4971.4999999999991 then
                    begin
                        Result := 0.0079381395672004518;
                    end
                    else
                    begin
                        Result := 0.017244441092536655;
                    end;
                end;
            end
            else
            begin
                Result := 0.024649648382653624;
            end;
        end;
    end;
end;

function bidirectional_tree_54(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[229] <= -513.49999999999989 then
        begin
            Result := -0.023962608547877493;
        end
        else
        begin
            if features[225] <= -3913.4999999999995 then
            begin
                Result := -0.012788486900455576;
            end
            else
            begin
                if features[179] <= -4084.4999999999995 then
                begin
                    Result := 0.027717319333399673;
                end
                else
                begin
                    Result := -0.021795188082533268;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= -107.49999999999999 then
        begin
            if features[226] <= -1034.4999999999998 then
            begin
                Result := -0.01651341002667607;
            end
            else
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    if features[176] <= -6749.4999999999991 then
                    begin
                        Result := -0.011451489973249953;
                    end
                    else
                    begin
                        Result := 0.0001568713976214072;
                    end;
                end
                else
                begin
                    if features[216] <= -7164.9999999999991 then
                    begin
                        Result := 0.034742022046547361;
                    end
                    else
                    begin
                        Result := 0.0043922527342336341;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 529.50000000000011 then
            begin
                if features[18] <= 12.500000000000002 then
                begin
                    if features[147] <= -754.99999999999989 then
                    begin
                        Result := 0.027233819608000882;
                    end
                    else
                    begin
                        Result := 0.0058374718033568536;
                    end;
                end
                else
                begin
                    if features[178] <= -906.49999999999989 then
                    begin
                        Result := -0.0025733603389933388;
                    end
                    else
                    begin
                        Result := 0.018190864639386208;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5244.4999999999991 then
                begin
                    Result := 0.0086606280046283048;
                end
                else
                begin
                    Result := 0.027178764477939828;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_55(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[229] <= -513.49999999999989 then
        begin
            Result := -0.023735111023392177;
        end
        else
        begin
            if features[225] <= -4549.4999999999991 then
            begin
                Result := -0.013524021448241653;
            end
            else
            begin
                if features[176] <= -4760.4999999999991 then
                begin
                    if features[82] <= -208.49999999999997 then
                    begin
                        Result := 0.0;
                    end
                    else
                    begin
                        Result := 0.040174218363534839;
                    end;
                end
                else
                begin
                    Result := -0.011435966629429778;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= -120.49999999999999 then
        begin
            if features[229] <= -1033.4999999999998 then
            begin
                Result := -0.020229127563945268;
            end
            else
            begin
                if features[166] <= -93540307.999999985 then
                begin
                    if features[177] <= -5591.4999999999991 then
                    begin
                        Result := -0.0070055716984520379;
                    end
                    else
                    begin
                        Result := 0.0081240590383219787;
                    end;
                end
                else
                begin
                    if features[151] <= -19.499999999999996 then
                    begin
                        Result := 0.010410058719621883;
                    end
                    else
                    begin
                        Result := -0.00034099813188945722;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 529.50000000000011 then
            begin
                if features[18] <= 12.500000000000002 then
                begin
                    if features[166] <= -110262351.99999999 then
                    begin
                        Result := 0.0017211371665860665;
                    end
                    else
                    begin
                        Result := 0.0092611266659621775;
                    end;
                end
                else
                begin
                    Result := 0.01609820536016816;
                end;
            end
            else
            begin
                if features[225] <= -5399.4999999999991 then
                begin
                    Result := 0.0043840132351655346;
                end
                else
                begin
                    Result := 0.026014662173834403;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_56(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -533.49999999999989 then
    begin
        if features[166] <= -205280911.99999997 then
        begin
            Result := -0.022811151475150671;
        end
        else
        begin
            if features[216] <= -6792.4999999999991 then
            begin
                Result := 0.013134671416544803;
            end
            else
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.01257442930578199;
                end
                else
                begin
                    if features[216] <= -5398.4999999999991 then
                    begin
                        Result := 0.049296292727946722;
                    end
                    else
                    begin
                        Result := -0.011171883055578355;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -217256167.99999997 then
        begin
            if features[166] <= -403654255.99999994 then
            begin
                Result := -0.021283079323138068;
            end
            else
            begin
                if features[226] <= 53.500000000000007 then
                begin
                    Result := -0.0077610104211172154;
                end
                else
                begin
                    Result := 0.0053724280669985138;
                end;
            end;
        end
        else
        begin
            if features[229] <= 456.50000000000006 then
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    if features[134] <= -4.4999999999999991 then
                    begin
                        Result := -0.017272977107068817;
                    end
                    else
                    begin
                        Result := 0.0038239189882151091;
                    end;
                end
                else
                begin
                    if features[9] <= 1.5000000000000002 then
                    begin
                        Result := 0.0025573939633829553;
                    end
                    else
                    begin
                        Result := 0.011555881406412784;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5314.4999999999991 then
                begin
                    if features[27] <= -5471.4999999999991 then
                    begin
                        Result := 0.018341122554112649;
                    end
                    else
                    begin
                        Result := -0.013409033902856339;
                    end;
                end
                else
                begin
                    Result := 0.025852830317730887;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_57(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[226] <= -595.49999999999989 then
        begin
            Result := -0.023455562193144056;
        end
        else
        begin
            Result := -0.010029259940790326;
        end;
    end
    else
    begin
        if features[226] <= -341.49999999999994 then
        begin
            if features[226] <= -1023.4999999999999 then
            begin
                if features[216] <= -7394.4999999999991 then
                begin
                    if features[182] <= -6060.4999999999991 then
                    begin
                        Result := -0.013420927554124971;
                    end
                    else
                    begin
                        Result := 0.058375009556771877;
                    end;
                end
                else
                begin
                    Result := -0.017872244712202411;
                end;
            end
            else
            begin
                if features[18] <= 8.5000000000000018 then
                begin
                    if features[148] <= -55.499999999999993 then
                    begin
                        Result := -0.0090067623674523183;
                    end
                    else
                    begin
                        Result := 0.0087904809725661455;
                    end;
                end
                else
                begin
                    if features[216] <= -6261.4999999999991 then
                    begin
                        Result := 0.0095223149819381233;
                    end
                    else
                    begin
                        Result := -0.008980758245426922;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 741.50000000000011 then
            begin
                if features[166] <= -31727439.999999996 then
                begin
                    if features[221] <= -5066.4999999999991 then
                    begin
                        Result := 0.0023094414429284324;
                    end
                    else
                    begin
                        Result := 0.0098408819471136298;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0037869615569429099;
                    end
                    else
                    begin
                        Result := 0.017238361115318759;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6975.9999999999991 then
                begin
                    Result := 0.0048495174172674647;
                end
                else
                begin
                    Result := 0.02718604434053383;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_58(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -256058583.99999997 then
    begin
        if features[229] <= -491.49999999999994 then
        begin
            Result := -0.023239391390433073;
        end
        else
        begin
            if features[225] <= -4549.4999999999991 then
            begin
                Result := -0.012702610406220997;
            end
            else
            begin
                if features[217] <= -1398.4999999999998 then
                begin
                    Result := 0.04404606553788537;
                end
                else
                begin
                    Result := -0.0023487504681190294;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -71.499999999999986 then
        begin
            if features[226] <= -1034.4999999999998 then
            begin
                Result := -0.015325603219532996;
            end
            else
            begin
                if features[166] <= -139258119.99999997 then
                begin
                    if features[177] <= -5410.4999999999991 then
                    begin
                        Result := -0.0068708682567863227;
                    end
                    else
                    begin
                        Result := 0.0097923211397038887;
                    end;
                end
                else
                begin
                    if features[216] <= -6638.4999999999991 then
                    begin
                        Result := 0.023595382357959323;
                    end
                    else
                    begin
                        Result := 0.0020316382133761866;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4690.4999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[217] <= 328.50000000000006 then
                    begin
                        Result := 0.011792320215376169;
                    end
                    else
                    begin
                        Result := -0.0096518686823862301;
                    end;
                end
                else
                begin
                    if features[154] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.01216778609129821;
                    end
                    else
                    begin
                        Result := 0.0011630053473825302;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -5367.4999999999991 then
                begin
                    Result := 0.022153485909463103;
                end
                else
                begin
                    Result := 0.0078588202145743313;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_59(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -506.49999999999994 then
    begin
        if features[166] <= -205280911.99999997 then
        begin
            if features[90] <= 7.5000000000000009 then
            begin
                Result := -0.022953376497184069;
            end
            else
            begin
                Result := 0.043232304170966934;
            end;
        end
        else
        begin
            if features[227] <= -4713.4999999999991 then
            begin
                if features[176] <= -5756.4999999999991 then
                begin
                    Result := -0.0026377041930219598;
                end
                else
                begin
                    Result := 0.023053223731934008;
                end;
            end
            else
            begin
                Result := -0.012468535654302294;
            end;
        end;
    end
    else
    begin
        if features[166] <= -139258119.99999997 then
        begin
            if features[166] <= -327673023.99999994 then
            begin
                Result := -0.014368902967718134;
            end
            else
            begin
                if features[222] <= -5521.4999999999991 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0070477598875232491;
                    end
                    else
                    begin
                        Result := 0.013123120516855116;
                    end;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0047123313978471989;
                    end
                    else
                    begin
                        Result := 0.0073291350831755381;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 118.50000000000001 then
            begin
                if features[54] <= 1.5000000000000002 then
                begin
                    Result := -0.00067336792771346336;
                end
                else
                begin
                    Result := 0.0070494916808450398;
                end;
            end
            else
            begin
                if features[228] <= -6102.4999999999991 then
                begin
                    Result := -0.0070737461326420732;
                end
                else
                begin
                    if features[215] <= -6975.9999999999991 then
                    begin
                        Result := 0.0008399005793294673;
                    end
                    else
                    begin
                        Result := 0.016907103506047037;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_60(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -645.49999999999989 then
    begin
        if features[226] <= -1034.4999999999998 then
        begin
            Result := -0.021743717429490963;
        end
        else
        begin
            Result := -0.01016498928709033;
        end;
    end
    else
    begin
        if features[226] <= 136.50000000000003 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[169] <= 1.5000000000000002 then
                begin
                    Result := 0.0015889471415777179;
                end
                else
                begin
                    if features[175] <= -828.49999999999989 then
                    begin
                        Result := -0.0004728232828796227;
                    end
                    else
                    begin
                        Result := 0.016136351126567819;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[183] <= -4980.4999999999991 then
                    begin
                        Result := -0.015778914678585661;
                    end
                    else
                    begin
                        Result := 0.013533620404797463;
                    end;
                end
                else
                begin
                    if features[154] <= -56.499999999999993 then
                    begin
                        Result := 0.0072397578496886305;
                    end
                    else
                    begin
                        Result := -0.0073318511365176812;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[217] <= 1374.5000000000002 then
                begin
                    if features[228] <= -4991.4999999999991 then
                    begin
                        Result := -0.0035869768444269177;
                    end
                    else
                    begin
                        Result := 0.015403237692117294;
                    end;
                end
                else
                begin
                    Result := -0.011378341825831658;
                end;
            end
            else
            begin
                if features[226] <= 633.50000000000011 then
                begin
                    if features[18] <= 10.500000000000002 then
                    begin
                        Result := 0.007171952493030139;
                    end
                    else
                    begin
                        Result := 0.017982685310997726;
                    end;
                end
                else
                begin
                    Result := 0.023627898691081593;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_61(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -645.49999999999989 then
    begin
        if features[226] <= -1069.4999999999998 then
        begin
            if features[158] <= 56312.500000000007 then
            begin
                Result := -0.022049239865256989;
            end
            else
            begin
                Result := 0.037541409542650409;
            end;
        end
        else
        begin
            if features[216] <= -6792.4999999999991 then
            begin
                Result := 0.013579702256072836;
            end
            else
            begin
                if features[180] <= -4674.4999999999991 then
                begin
                    Result := -0.013754089170442175;
                end
                else
                begin
                    Result := 0.021235705066092774;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -40.499999999999993 then
        begin
            if features[178] <= 116.50000000000001 then
            begin
                Result := -0.0019756015495749472;
            end
            else
            begin
                if features[176] <= -5898.4999999999991 then
                begin
                    if features[224] <= -5458.4999999999991 then
                    begin
                        Result := 0.012321847951156059;
                    end
                    else
                    begin
                        Result := -0.0036649208015331817;
                    end;
                end
                else
                begin
                    Result := 0.021321858701683155;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[217] <= 328.50000000000006 then
                    begin
                        Result := 0.0079388661923711374;
                    end
                    else
                    begin
                        Result := -0.011727333453122607;
                    end;
                end
                else
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.011111682962964503;
                    end
                    else
                    begin
                        Result := 0.001321246150114122;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 818.50000000000011 then
                begin
                    Result := 0.012413556561993682;
                end
                else
                begin
                    Result := 0.026648000306644538;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_62(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[166] <= -403654255.99999994 then
        begin
            Result := -0.024274801849087913;
        end
        else
        begin
            if features[220] <= -892.49999999999989 then
            begin
                Result := -0.019340609011055193;
            end
            else
            begin
                if features[174] <= -3120.9999999999995 then
                begin
                    Result := -0.009221407649481636;
                end
                else
                begin
                    Result := 0.061236251727747937;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -139258119.99999997 then
        begin
            if features[90] <= 5.5000000000000009 then
            begin
                if features[222] <= -4865.4999999999991 then
                begin
                    if features[154] <= 40.500000000000007 then
                    begin
                        Result := -0.0038855312038196263;
                    end
                    else
                    begin
                        Result := -0.017402121912633794;
                    end;
                end
                else
                begin
                    if features[81] <= -1702.4999999999998 then
                    begin
                        Result := -0.0048332206893569284;
                    end
                    else
                    begin
                        Result := 0.0086070171474879643;
                    end;
                end;
            end
            else
            begin
                Result := 0.021172864002869669;
            end;
        end
        else
        begin
            if features[54] <= 1.5000000000000002 then
            begin
                if features[222] <= -5883.4999999999991 then
                begin
                    Result := -0.0090014995399475672;
                end
                else
                begin
                    if features[109] <= -458.49999999999994 then
                    begin
                        Result := 0.013068846355907663;
                    end
                    else
                    begin
                        Result := -0.00056395698206731636;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -50412017.999999993 then
                begin
                    if features[219] <= -5550.4999999999991 then
                    begin
                        Result := 0.0039032784780447002;
                    end
                    else
                    begin
                        Result := 0.011498155859316718;
                    end;
                end
                else
                begin
                    Result := 0.014057140974068204;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_63(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[223] <= -498.49999999999994 then
        begin
            Result := -0.023288855363139495;
        end
        else
        begin
            Result := -0.013357860449123758;
        end;
    end
    else
    begin
        if features[166] <= -139258119.99999997 then
        begin
            if features[90] <= 8.5000000000000018 then
            begin
                if features[223] <= -796.49999999999989 then
                begin
                    Result := -0.013513806960248119;
                end
                else
                begin
                    if features[221] <= -5700.4999999999991 then
                    begin
                        Result := -0.0076814911707274646;
                    end
                    else
                    begin
                        Result := 0.0020083748295370431;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -4998.4999999999991 then
                begin
                    Result := 0.018536088232421432;
                end
                else
                begin
                    Result := 0.063923933970976121;
                end;
            end;
        end
        else
        begin
            if features[157] <= -1.0000000180025095E-35 then
            begin
                if features[222] <= -5429.4999999999991 then
                begin
                    if features[166] <= -35583741.999999993 then
                    begin
                        Result := -0.013531227737617816;
                    end
                    else
                    begin
                        Result := 0.00042403891090058435;
                    end;
                end
                else
                begin
                    if features[180] <= -6781.4999999999991 then
                    begin
                        Result := 0.01798030441647144;
                    end
                    else
                    begin
                        Result := 0.0012296186607229846;
                    end;
                end;
            end
            else
            begin
                if features[223] <= 340.50000000000006 then
                begin
                    if features[166] <= -50412017.999999993 then
                    begin
                        Result := 0.0051529039558830883;
                    end
                    else
                    begin
                        Result := 0.011633902874575358;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.0054325167631604811;
                    end
                    else
                    begin
                        Result := 0.01978697659321467;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_64(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[229] <= -491.49999999999994 then
        begin
            Result := -0.023070143156312672;
        end
        else
        begin
            if features[166] <= -403654255.99999994 then
            begin
                Result := -0.021383092719689981;
            end
            else
            begin
                Result := -0.0060332870620005176;
            end;
        end;
    end
    else
    begin
        if features[229] <= -120.49999999999999 then
        begin
            if features[229] <= -1033.4999999999998 then
            begin
                Result := -0.019049598889520951;
            end
            else
            begin
                if features[216] <= -7297.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.046633838201886893;
                    end
                    else
                    begin
                        Result := 0.0096980826929163304;
                    end;
                end
                else
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0035070628493025433;
                    end
                    else
                    begin
                        Result := 0.012030134245566917;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[166] <= -110262351.99999999 then
                begin
                    if features[151] <= 67.500000000000014 then
                    begin
                        Result := 0.0011529349303383567;
                    end
                    else
                    begin
                        Result := -0.02695703776715775;
                    end;
                end
                else
                begin
                    if features[136] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0014800093240052274;
                    end
                    else
                    begin
                        Result := 0.012072753636757529;
                    end;
                end;
            end
            else
            begin
                if features[179] <= -4056.4999999999995 then
                begin
                    if features[18] <= 11.500000000000002 then
                    begin
                        Result := 0.012044722787945489;
                    end
                    else
                    begin
                        Result := 0.022542930097584166;
                    end;
                end
                else
                begin
                    Result := -0.0063305498612376936;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_65(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[226] <= -500.49999999999994 then
        begin
            Result := -0.02247533076038806;
        end
        else
        begin
            if features[166] <= -355201055.99999994 then
            begin
                Result := -0.017063074725759277;
            end
            else
            begin
                Result := -0.0032269415898255223;
            end;
        end;
    end
    else
    begin
        if features[226] <= -71.499999999999986 then
        begin
            if features[229] <= -824.49999999999989 then
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.016386143771395127;
                end
                else
                begin
                    Result := 0.023719923018873101;
                end;
            end
            else
            begin
                if features[166] <= -139258119.99999997 then
                begin
                    if features[177] <= -5117.4999999999991 then
                    begin
                        Result := -0.0066804045840988318;
                    end
                    else
                    begin
                        Result := 0.0091323261113667297;
                    end;
                end
                else
                begin
                    if features[75] <= 13.500000000000002 then
                    begin
                        Result := 0.0036376490375638658;
                    end
                    else
                    begin
                        Result := -0.020832108541024297;
                    end;
                end;
            end;
        end
        else
        begin
            if features[228] <= -4626.4999999999991 then
            begin
                if features[27] <= -5870.4999999999991 then
                begin
                    if features[18] <= 8.5000000000000018 then
                    begin
                        Result := 0.0036132659916551543;
                    end
                    else
                    begin
                        Result := 0.018917180925981183;
                    end;
                end
                else
                begin
                    if features[228] <= -5779.4999999999991 then
                    begin
                        Result := -0.0071457862726451429;
                    end
                    else
                    begin
                        Result := 0.0043640580376778154;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 529.50000000000011 then
                begin
                    Result := 0.010242143255191414;
                end
                else
                begin
                    Result := 0.023524737987060049;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_66(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[223] <= -796.49999999999989 then
    begin
        if features[90] <= 2.5000000000000004 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                Result := 0.0039327039664655283;
            end
            else
            begin
                if features[223] <= -1291.4999999999998 then
                begin
                    Result := -0.022893838529024338;
                end
                else
                begin
                    Result := -0.013018502674075861;
                end;
            end;
        end
        else
        begin
            if features[177] <= -5322.4999999999991 then
            begin
                Result := 0.00045159809581292188;
            end
            else
            begin
                Result := 0.072744107543421851;
            end;
        end;
    end
    else
    begin
        if features[223] <= -33.499999999999993 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                Result := 0.0025022266354327721;
            end
            else
            begin
                if features[128] <= -18.499999999999996 then
                begin
                    Result := -0.015275548856544783;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.0038096108361949941;
                    end
                    else
                    begin
                        Result := -0.012414274300806875;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[217] <= 294.50000000000006 then
                begin
                    Result := 0.0070500575687920362;
                end
                else
                begin
                    if features[173] <= -4030.4999999999995 then
                    begin
                        Result := -0.0023564269117612364;
                    end
                    else
                    begin
                        Result := -0.022503470743344019;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -6421.4999999999991 then
                begin
                    Result := -0.0078627088281983618;
                end
                else
                begin
                    if features[27] <= -6222.4999999999991 then
                    begin
                        Result := 0.024550565436520778;
                    end
                    else
                    begin
                        Result := 0.0095983763760098522;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_67(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -263177239.99999997 then
    begin
        if features[226] <= -407.49999999999994 then
        begin
            if features[90] <= 7.5000000000000009 then
            begin
                if features[174] <= -3120.9999999999995 then
                begin
                    Result := -0.022258466167593;
                end
                else
                begin
                    Result := 0.0340777964842423;
                end;
            end
            else
            begin
                Result := 0.047307584547659792;
            end;
        end
        else
        begin
            Result := -0.0072954791910287949;
        end;
    end
    else
    begin
        if features[226] <= -307.49999999999994 then
        begin
            if features[216] <= -7394.4999999999991 then
            begin
                if features[1] <= 82434.500000000015 then
                begin
                    Result := 0.0077178881981666732;
                end
                else
                begin
                    Result := 0.046078603143727671;
                end;
            end
            else
            begin
                if features[226] <= -1034.4999999999998 then
                begin
                    Result := -0.016287957528352888;
                end
                else
                begin
                    if features[18] <= 8.5000000000000018 then
                    begin
                        Result := 0.0032170432760853804;
                    end
                    else
                    begin
                        Result := -0.0064808819222447692;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 529.50000000000011 then
            begin
                if features[166] <= -48176933.999999993 then
                begin
                    if features[176] <= -7483.4999999999991 then
                    begin
                        Result := -0.0044283751416363468;
                    end
                    else
                    begin
                        Result := 0.0054125721178742113;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0037468959446102113;
                    end
                    else
                    begin
                        Result := 0.013233206057676729;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6975.9999999999991 then
                begin
                    Result := 0.003282624621818957;
                end
                else
                begin
                    Result := 0.022690142173624566;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_68(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -283469215.99999994 then
    begin
        if features[229] <= -459.49999999999994 then
        begin
            Result := -0.022627071439455828;
        end
        else
        begin
            if features[166] <= -403654255.99999994 then
            begin
                Result := -0.019456863896427059;
            end
            else
            begin
                if features[169] <= 2.5000000000000004 then
                begin
                    Result := -0.007827378639499262;
                end
                else
                begin
                    Result := 0.029841038691723217;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= -260.49999999999994 then
        begin
            if features[229] <= -1033.4999999999998 then
            begin
                Result := -0.019024396257316854;
            end
            else
            begin
                if features[177] <= -5501.4999999999991 then
                begin
                    if features[37] <= 2.5000000000000004 then
                    begin
                        Result := 0.015326408142275436;
                    end
                    else
                    begin
                        Result := -0.0066016687444374724;
                    end;
                end
                else
                begin
                    if features[108] <= -273.49999999999994 then
                    begin
                        Result := -0.010388941525501948;
                    end
                    else
                    begin
                        Result := 0.019600414927414211;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 635.50000000000011 then
            begin
                if features[166] <= -31727439.999999996 then
                begin
                    if features[221] <= -5936.4999999999991 then
                    begin
                        Result := -0.0018238138207863606;
                    end
                    else
                    begin
                        Result := 0.0059129523540445367;
                    end;
                end
                else
                begin
                    if features[176] <= -6120.4999999999991 then
                    begin
                        Result := 0.014570538059454083;
                    end
                    else
                    begin
                        Result := 0.0036243627704179264;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5399.4999999999991 then
                begin
                    Result := 0.0045025951687009324;
                end
                else
                begin
                    Result := 0.025610232671621894;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_69(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -283469215.99999994 then
    begin
        if features[226] <= -507.49999999999994 then
        begin
            Result := -0.02234336221298695;
        end
        else
        begin
            Result := -0.0095681438122829712;
        end;
    end
    else
    begin
        if features[229] <= -120.49999999999999 then
        begin
            if features[229] <= -1033.4999999999998 then
            begin
                Result := -0.01906166561856866;
            end
            else
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    if features[216] <= -5414.4999999999991 then
                    begin
                        Result := 0.020537809746850183;
                    end
                    else
                    begin
                        Result := 0.00013275652769570895;
                    end;
                end
                else
                begin
                    if features[164] <= -16165704.499999998 then
                    begin
                        Result := -0.0095900616929679768;
                    end
                    else
                    begin
                        Result := -3.2479156254427324E-05;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4976.4999999999991 then
            begin
                if features[176] <= -4865.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.008475401932697758;
                    end
                    else
                    begin
                        Result := 0.0001586510546827018;
                    end;
                end
                else
                begin
                    if features[108] <= -113.49999999999999 then
                    begin
                        Result := -0.014317194981935172;
                    end
                    else
                    begin
                        Result := 0.012799600522412212;
                    end;
                end;
            end
            else
            begin
                if features[75] <= 7.5000000000000009 then
                begin
                    if features[229] <= 260.50000000000006 then
                    begin
                        Result := 0.004867883846756702;
                    end
                    else
                    begin
                        Result := 0.01603418233220371;
                    end;
                end
                else
                begin
                    if features[176] <= -4611.4999999999991 then
                    begin
                        Result := 0.022995875993341006;
                    end
                    else
                    begin
                        Result := 0.003458743441421159;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_70(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            Result := -0.02372616190574818;
        end
        else
        begin
            Result := -0.011706766118099904;
        end;
    end
    else
    begin
        if features[229] <= -120.49999999999999 then
        begin
            if features[229] <= -1033.4999999999998 then
            begin
                if features[221] <= -5546.4999999999991 then
                begin
                    Result := 0.019075839362014402;
                end
                else
                begin
                    Result := -0.020489728418178123;
                end;
            end
            else
            begin
                if features[216] <= -7297.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.052186306419588137;
                    end
                    else
                    begin
                        Result := 0.007286597813523376;
                    end;
                end
                else
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0067803030706127358;
                    end
                    else
                    begin
                        Result := -0.0035261698858226036;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 635.50000000000011 then
            begin
                if features[215] <= -5467.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0045001332351617121;
                    end
                    else
                    begin
                        Result := -0.0073637279023097066;
                    end;
                end
                else
                begin
                    if features[176] <= -4804.4999999999991 then
                    begin
                        Result := 0.010155828810958004;
                    end
                    else
                    begin
                        Result := -0.00081375226912291693;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5399.4999999999991 then
                begin
                    if features[175] <= 465.50000000000006 then
                    begin
                        Result := -0.0210942879022873;
                    end
                    else
                    begin
                        Result := 0.016097327341590587;
                    end;
                end
                else
                begin
                    Result := 0.024283534825583271;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_71(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[229] <= -491.49999999999994 then
        begin
            if features[174] <= -3120.9999999999995 then
            begin
                Result := -0.02407195815284956;
            end
            else
            begin
                Result := 0.043611679154729632;
            end;
        end
        else
        begin
            Result := -0.011202262921678981;
        end;
    end
    else
    begin
        if features[229] <= -120.49999999999999 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[226] <= -1034.4999999999998 then
                begin
                    Result := -0.016296984349179824;
                end
                else
                begin
                    if features[166] <= -89999783.999999985 then
                    begin
                        Result := -0.0048240437638173705;
                    end
                    else
                    begin
                        Result := 0.0032070011953569365;
                    end;
                end;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[215] <= -5409.4999999999991 then
                    begin
                        Result := 0.053098908588417072;
                    end
                    else
                    begin
                        Result := 0.018146274852316392;
                    end;
                end
                else
                begin
                    Result := 0.0015514954086793063;
                end;
            end;
        end
        else
        begin
            if features[229] <= 635.50000000000011 then
            begin
                if features[18] <= 12.500000000000002 then
                begin
                    if features[227] <= -5492.4999999999991 then
                    begin
                        Result := -0.0018767461871998668;
                    end
                    else
                    begin
                        Result := 0.006014188612459022;
                    end;
                end
                else
                begin
                    if features[173] <= -6350.4999999999991 then
                    begin
                        Result := -0.0047688103564645715;
                    end
                    else
                    begin
                        Result := 0.014978417474771733;
                    end;
                end;
            end
            else
            begin
                if features[222] <= -6122.4999999999991 then
                begin
                    Result := -0.01060239549648084;
                end
                else
                begin
                    Result := 0.023265192626636583;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_72(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -283469215.99999994 then
    begin
        if features[229] <= -459.49999999999994 then
        begin
            Result := -0.022145990231835475;
        end
        else
        begin
            if features[174] <= -8125.4999999999991 then
            begin
                Result := 0.032678387752142227;
            end
            else
            begin
                if features[222] <= -5601.4999999999991 then
                begin
                    Result := -0.017382953853828393;
                end
                else
                begin
                    Result := -0.0041716960181713784;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -71.499999999999986 then
        begin
            if features[229] <= -1033.4999999999998 then
            begin
                Result := -0.019195342843508684;
            end
            else
            begin
                if features[166] <= -139258119.99999997 then
                begin
                    if features[177] <= -5260.4999999999991 then
                    begin
                        Result := -0.0070907307925964147;
                    end
                    else
                    begin
                        Result := 0.0061825301520308067;
                    end;
                end
                else
                begin
                    if features[74] <= 8.5000000000000018 then
                    begin
                        Result := 0.0063967622927595382;
                    end
                    else
                    begin
                        Result := -0.0026665335753014077;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -5901.4999999999991 then
            begin
                if features[154] <= 1.0000000180025095E-35 then
                begin
                    if features[166] <= -100168163.99999999 then
                    begin
                        Result := -0.0036991577613689091;
                    end
                    else
                    begin
                        Result := 0.010575154384759167;
                    end;
                end
                else
                begin
                    Result := -0.013679777179406933;
                end;
            end
            else
            begin
                if features[229] <= 702.50000000000011 then
                begin
                    if features[217] <= 2608.5000000000005 then
                    begin
                        Result := 0.0088442988055536225;
                    end
                    else
                    begin
                        Result := -0.011967526012165847;
                    end;
                end
                else
                begin
                    Result := 0.023271877839793949;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_73(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -640.49999999999989 then
    begin
        if features[216] <= -7164.9999999999991 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                Result := 0.024371040049240761;
            end
            else
            begin
                Result := -0.013625575623712827;
            end;
        end
        else
        begin
            if features[90] <= 2.5000000000000004 then
            begin
                Result := -0.019830414562470068;
            end
            else
            begin
                if features[177] <= -5322.4999999999991 then
                begin
                    Result := -0.005760731035393687;
                end
                else
                begin
                    Result := 0.055647930591167918;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[179] <= -3792.4999999999995 then
                begin
                    if features[222] <= -5846.4999999999991 then
                    begin
                        Result := -0.00031498690028742123;
                    end
                    else
                    begin
                        Result := 0.0063779207999066102;
                    end;
                end
                else
                begin
                    Result := -0.01691714669108578;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[177] <= -6245.4999999999991 then
                    begin
                        Result := -0.018241393323940557;
                    end
                    else
                    begin
                        Result := 0.00040591588387855327;
                    end;
                end
                else
                begin
                    if features[154] <= -90.499999999999986 then
                    begin
                        Result := 0.0064526923355263423;
                    end
                    else
                    begin
                        Result := -0.0058566471622745944;
                    end;
                end;
            end;
        end
        else
        begin
            if features[217] <= 2926.5000000000005 then
            begin
                if features[228] <= -4491.4999999999991 then
                begin
                    Result := 0.0086854608380732418;
                end
                else
                begin
                    Result := 0.02162429294141055;
                end;
            end
            else
            begin
                Result := -0.0095844904795304164;
            end;
        end;
    end;
end;

function bidirectional_tree_74(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -506.49999999999994 then
    begin
        if features[90] <= 2.5000000000000004 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[216] <= -6792.4999999999991 then
                begin
                    Result := 0.014233694249154603;
                end
                else
                begin
                    if features[181] <= -1135.4999999999998 then
                    begin
                        Result := -0.020259305779436607;
                    end
                    else
                    begin
                        Result := -0.0052932047219140764;
                    end;
                end;
            end
            else
            begin
                Result := -0.020951963994065056;
            end;
        end
        else
        begin
            if features[215] <= -5843.4999999999991 then
            begin
                Result := 0.064590183193826312;
            end
            else
            begin
                Result := 0.00034492207224025013;
            end;
        end;
    end
    else
    begin
        if features[226] <= 467.50000000000006 then
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[179] <= -3792.4999999999995 then
                begin
                    if features[222] <= -5938.4999999999991 then
                    begin
                        Result := -0.00083472060905920059;
                    end
                    else
                    begin
                        Result := 0.0061616980941670754;
                    end;
                end
                else
                begin
                    Result := -0.013695826854395099;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[177] <= -6953.4999999999991 then
                    begin
                        Result := -0.019658913953355325;
                    end
                    else
                    begin
                        Result := -0.0056375730374774793;
                    end;
                end
                else
                begin
                    if features[157] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0058400589928086881;
                    end
                    else
                    begin
                        Result := 0.0077355073137534815;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -7276.4999999999991 then
            begin
                Result := -0.0058616685702633309;
            end
            else
            begin
                Result := 0.017841705598325125;
            end;
        end;
    end;
end;

function bidirectional_tree_75(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[229] <= -459.49999999999994 then
        begin
            Result := -0.023382165269155656;
        end
        else
        begin
            Result := -0.011391775131754166;
        end;
    end
    else
    begin
        if features[226] <= -278.49999999999994 then
        begin
            if features[216] <= -7297.4999999999991 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[216] <= -7501.9999999999991 then
                    begin
                        Result := 0.015063395279177914;
                    end
                    else
                    begin
                        Result := 0.081561050875304103;
                    end;
                end
                else
                begin
                    Result := 0.0043188545414577046;
                end;
            end
            else
            begin
                if features[226] <= -1034.4999999999998 then
                begin
                    if features[90] <= 2.5000000000000004 then
                    begin
                        Result := -0.019275733268837126;
                    end
                    else
                    begin
                        Result := 0.025508970743021542;
                    end;
                end
                else
                begin
                    if features[170] <= 1.5000000000000002 then
                    begin
                        Result := 0.0061347855384153334;
                    end
                    else
                    begin
                        Result := -0.0051001077845842409;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 577.50000000000011 then
            begin
                if features[166] <= -140928295.99999997 then
                begin
                    if features[221] <= -5700.4999999999991 then
                    begin
                        Result := -0.0067625093270800548;
                    end
                    else
                    begin
                        Result := 0.0038784288347956776;
                    end;
                end
                else
                begin
                    Result := 0.0064806263232986237;
                end;
            end
            else
            begin
                if features[215] <= -6109.4999999999991 then
                begin
                    if features[173] <= -5587.4999999999991 then
                    begin
                        Result := 0.015547608996934687;
                    end
                    else
                    begin
                        Result := -0.014815205645025404;
                    end;
                end
                else
                begin
                    Result := 0.024616503875939087;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_76(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[229] <= -459.49999999999994 then
        begin
            Result := -0.022999838319175403;
        end
        else
        begin
            Result := -0.010597124639332515;
        end;
    end
    else
    begin
        if features[226] <= -530.49999999999989 then
        begin
            if features[216] <= -6792.4999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[174] <= -5198.4999999999991 then
                    begin
                        Result := 0.013669088708018135;
                    end
                    else
                    begin
                        Result := 0.073362502158408963;
                    end;
                end
                else
                begin
                    if features[215] <= -5565.4999999999991 then
                    begin
                        Result := 0.023022754754767952;
                    end
                    else
                    begin
                        Result := -0.011889188054741226;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -4674.4999999999991 then
                begin
                    if features[226] <= -873.49999999999989 then
                    begin
                        Result := -0.016459164860803916;
                    end
                    else
                    begin
                        Result := -0.005918520392726453;
                    end;
                end
                else
                begin
                    if features[227] <= -3219.4999999999995 then
                    begin
                        Result := 0.033481621869315109;
                    end
                    else
                    begin
                        Result := -0.025427344469332144;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 635.50000000000011 then
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    if features[151] <= 67.500000000000014 then
                    begin
                        Result := 0.0020108596146742644;
                    end
                    else
                    begin
                        Result := -0.015002376028151507;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.00091874925541504638;
                    end
                    else
                    begin
                        Result := 0.0084517189513764659;
                    end;
                end;
            end
            else
            begin
                Result := 0.019606574221001493;
            end;
        end;
    end;
end;

function bidirectional_tree_77(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[229] <= -491.49999999999994 then
        begin
            Result := -0.023018789498716115;
        end
        else
        begin
            Result := -0.0098552590550351777;
        end;
    end
    else
    begin
        if features[226] <= -71.499999999999986 then
        begin
            if features[226] <= -1034.4999999999998 then
            begin
                if features[180] <= -4465.4999999999991 then
                begin
                    if features[216] <= -7394.4999999999991 then
                    begin
                        Result := 0.016382142643097022;
                    end
                    else
                    begin
                        Result := -0.018264589527409027;
                    end;
                end
                else
                begin
                    if features[154] <= -381.49999999999994 then
                    begin
                        Result := 0.056343480300586946;
                    end
                    else
                    begin
                        Result := -0.010705037922606971;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -7164.9999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.036639552681351849;
                    end
                    else
                    begin
                        Result := 0.0069005788565622882;
                    end;
                end
                else
                begin
                    if features[117] <= -25.499999999999996 then
                    begin
                        Result := -0.0057902585768069906;
                    end
                    else
                    begin
                        Result := 0.0015883350896198996;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -6421.4999999999991 then
            begin
                Result := -0.0074910158864652555;
            end
            else
            begin
                if features[176] <= -4865.4999999999991 then
                begin
                    if features[229] <= 702.50000000000011 then
                    begin
                        Result := 0.0080879064515109057;
                    end
                    else
                    begin
                        Result := 0.023858377321056858;
                    end;
                end
                else
                begin
                    if features[181] <= -536.49999999999989 then
                    begin
                        Result := -0.018114729791734313;
                    end
                    else
                    begin
                        Result := 0.0085391892033463666;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_78(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[226] <= -595.49999999999989 then
        begin
            if features[174] <= -3120.9999999999995 then
            begin
                Result := -0.02354648545426569;
            end
            else
            begin
                Result := 0.04661641056581;
            end;
        end
        else
        begin
            Result := -0.0096569465145971214;
        end;
    end
    else
    begin
        if features[226] <= -335.49999999999994 then
        begin
            if features[229] <= -1033.4999999999998 then
            begin
                Result := -0.019126183645570699;
            end
            else
            begin
                if features[18] <= 8.5000000000000018 then
                begin
                    if features[187] <= -59.774999618530266 then
                    begin
                        Result := -0.009944041547982136;
                    end
                    else
                    begin
                        Result := 0.007536186507094117;
                    end;
                end
                else
                begin
                    if features[216] <= -6261.4999999999991 then
                    begin
                        Result := 0.0094625711574032236;
                    end
                    else
                    begin
                        Result := -0.0098803290926325962;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 397.50000000000006 then
            begin
                if features[179] <= -3792.4999999999995 then
                begin
                    if features[0] <= 38021.000000000007 then
                    begin
                        Result := -0.0014228884812697699;
                    end
                    else
                    begin
                        Result := 0.0052589676263752301;
                    end;
                end
                else
                begin
                    Result := -0.016742944552296555;
                end;
            end
            else
            begin
                if features[215] <= -6109.4999999999991 then
                begin
                    if features[173] <= -5904.4999999999991 then
                    begin
                        Result := 0.0090509953394370627;
                    end
                    else
                    begin
                        Result := -0.008193276679961118;
                    end;
                end
                else
                begin
                    if features[179] <= -4862.4999999999991 then
                    begin
                        Result := 0.019289121154101006;
                    end
                    else
                    begin
                        Result := 0.004071053882946641;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_79(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[226] <= -507.49999999999994 then
        begin
            Result := -0.022555473693844023;
        end
        else
        begin
            Result := -0.0092277659698900057;
        end;
    end
    else
    begin
        if features[226] <= -52.499999999999993 then
        begin
            if features[226] <= -1034.4999999999998 then
            begin
                if features[143] <= 2.5000000000000004 then
                begin
                    if features[216] <= -7394.4999999999991 then
                    begin
                        Result := 0.013791552378009298;
                    end
                    else
                    begin
                        Result := -0.016645213951648283;
                    end;
                end
                else
                begin
                    Result := 0.046000476520240266;
                end;
            end
            else
            begin
                if features[216] <= -7164.9999999999991 then
                begin
                    Result := 0.018114028903916078;
                end
                else
                begin
                    if features[177] <= -6131.4999999999991 then
                    begin
                        Result := -0.0030644614888118201;
                    end
                    else
                    begin
                        Result := 0.0038956103178627122;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4444.4999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[217] <= 310.50000000000006 then
                    begin
                        Result := 0.0080657934726988643;
                    end
                    else
                    begin
                        Result := -0.010498686641090863;
                    end;
                end
                else
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0089500435571968403;
                    end
                    else
                    begin
                        Result := 0.000424668611203855;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 633.50000000000011 then
                begin
                    if features[45] <= 1.5000000000000002 then
                    begin
                        Result := -0.0075343736088556964;
                    end
                    else
                    begin
                        Result := 0.012057261846665203;
                    end;
                end
                else
                begin
                    Result := 0.023708777829628613;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_80(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -632.49999999999989 then
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[229] <= -1344.4999999999998 then
                begin
                    Result := -0.017582503157179557;
                end
                else
                begin
                    Result := 0.039566927135649396;
                end;
            end
            else
            begin
                Result := -0.012189538681882809;
            end;
        end
        else
        begin
            Result := -0.021710011105458296;
        end;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[176] <= -4760.4999999999991 then
                begin
                    if features[81] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0024660465680311507;
                    end
                    else
                    begin
                        Result := 0.010540194086883933;
                    end;
                end
                else
                begin
                    if features[184] <= -760.49999999999989 then
                    begin
                        Result := -0.013409091270470961;
                    end
                    else
                    begin
                        Result := 0.0020455225700062229;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[183] <= -4980.4999999999991 then
                    begin
                        Result := -0.014172859220711532;
                    end
                    else
                    begin
                        Result := 0.012650232306939402;
                    end;
                end
                else
                begin
                    if features[69] <= 4.5000000000000009 then
                    begin
                        Result := 0.0060562384625364243;
                    end
                    else
                    begin
                        Result := -0.0048928371138779701;
                    end;
                end;
            end;
        end
        else
        begin
            if features[217] <= 1035.5000000000002 then
            begin
                Result := 0.016830791613474089;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0092827103567574478;
                end
                else
                begin
                    Result := 0.010326711097649412;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_81(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -533.49999999999989 then
    begin
        if features[90] <= 2.5000000000000004 then
        begin
            if features[148] <= -55.499999999999993 then
            begin
                Result := -0.021297921875340738;
            end
            else
            begin
                if features[216] <= -6660.4999999999991 then
                begin
                    if features[82] <= -8574.4999999999982 then
                    begin
                        Result := -0.014922161793629603;
                    end
                    else
                    begin
                        Result := 0.025624650030497284;
                    end;
                end
                else
                begin
                    if features[180] <= -4377.4999999999991 then
                    begin
                        Result := -0.013317635824971608;
                    end
                    else
                    begin
                        Result := 0.03674359940383698;
                    end;
                end;
            end;
        end
        else
        begin
            if features[180] <= -5036.4999999999991 then
            begin
                Result := 0.0029763421128938383;
            end
            else
            begin
                Result := 0.066464058250720534;
            end;
        end;
    end
    else
    begin
        if features[226] <= 397.50000000000006 then
        begin
            if features[154] <= -900.49999999999989 then
            begin
                Result := -0.005608156190073905;
            end
            else
            begin
                if features[179] <= -3792.4999999999995 then
                begin
                    if features[222] <= -4486.4999999999991 then
                    begin
                        Result := 0.0018628016991085374;
                    end
                    else
                    begin
                        Result := 0.010592284303885416;
                    end;
                end
                else
                begin
                    Result := -0.015320971669856118;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6273.4999999999991 then
            begin
                if features[173] <= -5904.4999999999991 then
                begin
                    if features[107] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.020397941967604926;
                    end
                    else
                    begin
                        Result := 0.014727833485344823;
                    end;
                end
                else
                begin
                    Result := -0.010520948697076506;
                end;
            end
            else
            begin
                Result := 0.016326382008001156;
            end;
        end;
    end;
end;

function bidirectional_tree_82(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[215] <= -8107.4999999999991 then
        begin
            Result := 0.024399731026345347;
        end
        else
        begin
            Result := -0.020573983652609071;
        end;
    end
    else
    begin
        if features[226] <= -530.49999999999989 then
        begin
            if features[177] <= -5351.4999999999991 then
            begin
                if features[216] <= -6575.4999999999991 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.025066080603255238;
                    end
                    else
                    begin
                        Result := -0.0040007854804663765;
                    end;
                end
                else
                begin
                    if features[174] <= -3120.9999999999995 then
                    begin
                        Result := -0.012200146508424286;
                    end
                    else
                    begin
                        Result := 0.036382633578123609;
                    end;
                end;
            end
            else
            begin
                if features[108] <= -267.49999999999994 then
                begin
                    Result := -0.010408992149321929;
                end
                else
                begin
                    if features[153] <= -39.499999999999993 then
                    begin
                        Result := 0.037100466468703366;
                    end
                    else
                    begin
                        Result := 0.0015988516645720299;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 529.50000000000011 then
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    if features[90] <= -2.4999999999999996 then
                    begin
                        Result := -0.02238920203423661;
                    end
                    else
                    begin
                        Result := 0.00087884204933905542;
                    end;
                end
                else
                begin
                    if features[136] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0024377798223101411;
                    end
                    else
                    begin
                        Result := 0.0082881180646736854;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6975.9999999999991 then
                begin
                    Result := -0.0019384816517866101;
                end
                else
                begin
                    Result := 0.019944671648397104;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_83(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -332986879.99999994 then
    begin
        if features[229] <= -485.49999999999994 then
        begin
            Result := -0.023536068139897191;
        end
        else
        begin
            Result := -0.011442567274475285;
        end;
    end
    else
    begin
        if features[226] <= -307.49999999999994 then
        begin
            if features[229] <= -1033.4999999999998 then
            begin
                if features[221] <= -5546.4999999999991 then
                begin
                    if features[70] <= 799.50000000000011 then
                    begin
                        Result := 0.061162221774356818;
                    end
                    else
                    begin
                        Result := -0.020864550529948567;
                    end;
                end
                else
                begin
                    Result := -0.019929790866349814;
                end;
            end
            else
            begin
                if features[74] <= 7.5000000000000009 then
                begin
                    if features[117] <= -20.499999999999996 then
                    begin
                        Result := -0.0067407459921056002;
                    end
                    else
                    begin
                        Result := 0.0062693105947693693;
                    end;
                end
                else
                begin
                    if features[180] <= -4674.4999999999991 then
                    begin
                        Result := -0.0077108278335768768;
                    end
                    else
                    begin
                        Result := 0.017251086883581256;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 635.50000000000011 then
            begin
                if features[166] <= -48176933.999999993 then
                begin
                    if features[222] <= -5521.4999999999991 then
                    begin
                        Result := -0.001862481169556712;
                    end
                    else
                    begin
                        Result := 0.0053704809514540149;
                    end;
                end
                else
                begin
                    if features[158] <= 583.00000000000011 then
                    begin
                        Result := 0.0047438699904999646;
                    end
                    else
                    begin
                        Result := 0.01244879789160426;
                    end;
                end;
            end
            else
            begin
                if features[222] <= -6122.4999999999991 then
                begin
                    Result := -0.01088866251778238;
                end
                else
                begin
                    Result := 0.019850126184582706;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_84(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -341334223.99999994 then
    begin
        Result := -0.019809967025294171;
    end
    else
    begin
        if features[229] <= 99.500000000000014 then
        begin
            if features[166] <= -139258119.99999997 then
            begin
                if features[90] <= 8.5000000000000018 then
                begin
                    if features[229] <= -434.49999999999994 then
                    begin
                        Result := -0.012073872579565898;
                    end
                    else
                    begin
                        Result := -0.0021616355509378438;
                    end;
                end
                else
                begin
                    if features[180] <= -5162.4999999999991 then
                    begin
                        Result := 0.014111771344452363;
                    end
                    else
                    begin
                        Result := 0.068877385201835603;
                    end;
                end;
            end
            else
            begin
                if features[154] <= 191.50000000000003 then
                begin
                    if features[228] <= -6140.4999999999991 then
                    begin
                        Result := 0.01235106614791949;
                    end
                    else
                    begin
                        Result := 0.0028246010892978924;
                    end;
                end
                else
                begin
                    Result := -0.0031685817141802728;
                end;
            end;
        end
        else
        begin
            if features[228] <= -4626.4999999999991 then
            begin
                if features[165] <= 134540048.00000003 then
                begin
                    if features[225] <= -6459.4999999999991 then
                    begin
                        Result := -0.0099366325031718487;
                    end
                    else
                    begin
                        Result := 0.010339910705341985;
                    end;
                end
                else
                begin
                    if features[158] <= 1816.5000000000002 then
                    begin
                        Result := -0.009013771523631418;
                    end
                    else
                    begin
                        Result := 0.0042607857010994012;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6975.9999999999991 then
                begin
                    Result := -0.0081682883325255879;
                end
                else
                begin
                    if features[226] <= 499.50000000000006 then
                    begin
                        Result := 0.010397685260487555;
                    end
                    else
                    begin
                        Result := 0.022769709724296053;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_85(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[226] <= -636.49999999999989 then
        begin
            Result := -0.022499727525642714;
        end
        else
        begin
            Result := -0.01030657930027596;
        end;
    end
    else
    begin
        if features[226] <= -278.49999999999994 then
        begin
            if features[18] <= 8.5000000000000018 then
            begin
                if features[117] <= -20.499999999999996 then
                begin
                    Result := -0.0081143692488306381;
                end
                else
                begin
                    if features[226] <= -1486.4999999999998 then
                    begin
                        Result := -0.02114992220101564;
                    end
                    else
                    begin
                        Result := 0.007481178093036763;
                    end;
                end;
            end
            else
            begin
                if features[143] <= 2.5000000000000004 then
                begin
                    if features[227] <= -6098.4999999999991 then
                    begin
                        Result := 0.017037020941942788;
                    end
                    else
                    begin
                        Result := -0.0087021511337596041;
                    end;
                end
                else
                begin
                    if features[215] <= -5467.4999999999991 then
                    begin
                        Result := 0.064554013090956999;
                    end
                    else
                    begin
                        Result := -0.0065021089392407558;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[166] <= -115573507.99999999 then
                begin
                    if features[66] <= -106.99999999999999 then
                    begin
                        Result := 0.01932254682433537;
                    end
                    else
                    begin
                        Result := -0.0034082893763483744;
                    end;
                end
                else
                begin
                    if features[157] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.001995824909496556;
                    end
                    else
                    begin
                        Result := 0.0078490427404050607;
                    end;
                end;
            end
            else
            begin
                if features[18] <= 13.500000000000002 then
                begin
                    Result := 0.0064726534330602492;
                end
                else
                begin
                    Result := 0.019823440578678062;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_86(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -341334223.99999994 then
    begin
        if features[215] <= -7708.4999999999991 then
        begin
            Result := 0.017662054092473813;
        end
        else
        begin
            Result := -0.020377053792147694;
        end;
    end
    else
    begin
        if features[226] <= -278.49999999999994 then
        begin
            if features[18] <= 8.5000000000000018 then
            begin
                if features[187] <= -5.9583332538604727 then
                begin
                    Result := -0.0088822099626228827;
                end
                else
                begin
                    if features[71] <= 1.5000000000000002 then
                    begin
                        Result := -0.0047031270470775212;
                    end
                    else
                    begin
                        Result := 0.0096024059269656445;
                    end;
                end;
            end
            else
            begin
                if features[90] <= 9.5000000000000018 then
                begin
                    if features[226] <= -902.49999999999989 then
                    begin
                        Result := -0.017964468963606837;
                    end
                    else
                    begin
                        Result := -0.0054732104586212391;
                    end;
                end
                else
                begin
                    if features[128] <= -2426.4999999999995 then
                    begin
                        Result := 0.038577282033842288;
                    end
                    else
                    begin
                        Result := -0.011770507362676342;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 891.50000000000011 then
            begin
                if features[215] <= -5467.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.003411877066671302;
                    end
                    else
                    begin
                        Result := -0.0081850416931427139;
                    end;
                end
                else
                begin
                    if features[216] <= -4018.9999999999995 then
                    begin
                        Result := 0.0042692203271545853;
                    end
                    else
                    begin
                        Result := 0.014384680357611798;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6137.4999999999991 then
                begin
                    Result := 0.0054601316503923476;
                end
                else
                begin
                    Result := 0.02656396830154277;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_87(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -288730991.99999994 then
    begin
        if features[166] <= -403654255.99999994 then
        begin
            Result := -0.022955934980804935;
        end
        else
        begin
            Result := -0.010477134474921865;
        end;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    if features[137] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0017230509034359539;
                    end
                    else
                    begin
                        Result := -0.017553159534404585;
                    end;
                end
                else
                begin
                    if features[216] <= -6993.4999999999991 then
                    begin
                        Result := 0.021844552002438188;
                    end
                    else
                    begin
                        Result := 0.0030376888756800851;
                    end;
                end;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[64] <= 1418.0000000000002 then
                    begin
                        Result := 0.022880161165687262;
                    end
                    else
                    begin
                        Result := -0.0064185341705624002;
                    end;
                end
                else
                begin
                    if features[25] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.024905761904972273;
                    end
                    else
                    begin
                        Result := -0.0013131763107231645;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6109.4999999999991 then
            begin
                if features[173] <= -5710.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.020858498226188765;
                    end
                    else
                    begin
                        Result := -0.0062357195833120755;
                    end;
                end
                else
                begin
                    Result := -0.0094759994404549717;
                end;
            end
            else
            begin
                if features[46] <= 10.500000000000002 then
                begin
                    Result := 0.011154983366857671;
                end
                else
                begin
                    Result := 0.023416393856718884;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_88(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -640.49999999999989 then
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[216] <= -7501.9999999999991 then
                begin
                    Result := 0.0052745581337986357;
                end
                else
                begin
                    if features[175] <= -1190.9999999999998 then
                    begin
                        Result := -0.0091136324522411959;
                    end
                    else
                    begin
                        Result := 0.1083801842698766;
                    end;
                end;
            end
            else
            begin
                Result := -0.011029677688521065;
            end;
        end
        else
        begin
            Result := -0.021332466589763233;
        end;
    end
    else
    begin
        if features[226] <= 124.50000000000001 then
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[148] <= -1127.4999999999998 then
                begin
                    if features[216] <= -4080.4999999999995 then
                    begin
                        Result := -0.0048939012661772217;
                    end
                    else
                    begin
                        Result := 0.013280506044771576;
                    end;
                end
                else
                begin
                    Result := 0.0036029517844434742;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[177] <= -6953.4999999999991 then
                    begin
                        Result := -0.019543560159042486;
                    end
                    else
                    begin
                        Result := -0.0061342968403743075;
                    end;
                end
                else
                begin
                    if features[220] <= -21.499999999999996 then
                    begin
                        Result := 0.0059152657841976134;
                    end
                    else
                    begin
                        Result := -0.0075328397330287275;
                    end;
                end;
            end;
        end
        else
        begin
            if features[18] <= 10.500000000000002 then
            begin
                if features[228] <= -5001.4999999999991 then
                begin
                    Result := -0.003094802452429414;
                end
                else
                begin
                    Result := 0.0080395179339467771;
                end;
            end
            else
            begin
                Result := 0.014100553160560145;
            end;
        end;
    end;
end;

function bidirectional_tree_89(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[215] <= -7708.4999999999991 then
        begin
            if features[39] <= 1222.5000000000002 then
            begin
                Result := 0.068323173304507656;
            end
            else
            begin
                Result := -0.0089561519305746823;
            end;
        end
        else
        begin
            Result := -0.020262009930059985;
        end;
    end
    else
    begin
        if features[226] <= -313.49999999999994 then
        begin
            if features[216] <= -7297.4999999999991 then
            begin
                Result := 0.017038214402441812;
            end
            else
            begin
                if features[226] <= -1103.4999999999998 then
                begin
                    if features[146] <= 1860.0000000000002 then
                    begin
                        Result := -0.018186513273653917;
                    end
                    else
                    begin
                        Result := 0.03077981605192966;
                    end;
                end
                else
                begin
                    if features[164] <= -16165704.499999998 then
                    begin
                        Result := -0.0098275999948030882;
                    end
                    else
                    begin
                        Result := 2.7350262058175538E-05;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4535.4999999999991 then
            begin
                if features[166] <= -48176933.999999993 then
                begin
                    if features[154] <= 33.000000000000007 then
                    begin
                        Result := 0.0017387027941035587;
                    end
                    else
                    begin
                        Result := -0.0089732669641816188;
                    end;
                end
                else
                begin
                    if features[158] <= 583.00000000000011 then
                    begin
                        Result := 0.0021150125052381212;
                    end
                    else
                    begin
                        Result := 0.011394054289607929;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 633.50000000000011 then
                begin
                    if features[220] <= -610.49999999999989 then
                    begin
                        Result := 0.023738237687373591;
                    end
                    else
                    begin
                        Result := 0.0055704335904525832;
                    end;
                end
                else
                begin
                    Result := 0.021202058103938673;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_90(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -341334223.99999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            Result := -0.023138666040113939;
        end
        else
        begin
            Result := -0.011216266112248807;
        end;
    end
    else
    begin
        if features[229] <= -440.49999999999994 then
        begin
            if features[177] <= -5591.4999999999991 then
            begin
                if features[216] <= -6747.4999999999991 then
                begin
                    if features[48] <= 10135.500000000002 then
                    begin
                        Result := -0.0024652778609993722;
                    end
                    else
                    begin
                        Result := 0.028619589284018865;
                    end;
                end
                else
                begin
                    if features[180] <= -4377.4999999999991 then
                    begin
                        Result := -0.01270580332682348;
                    end
                    else
                    begin
                        Result := 0.027949454283660857;
                    end;
                end;
            end
            else
            begin
                if features[224] <= -3470.4999999999995 then
                begin
                    if features[108] <= -267.49999999999994 then
                    begin
                        Result := -0.0041066467733994185;
                    end
                    else
                    begin
                        Result := 0.030701207377568436;
                    end;
                end
                else
                begin
                    Result := -0.020761602129616051;
                end;
            end;
        end
        else
        begin
            if features[226] <= 741.50000000000011 then
            begin
                if features[166] <= -89999783.999999985 then
                begin
                    if features[66] <= -181.99999999999997 then
                    begin
                        Result := 0.019463784905097134;
                    end
                    else
                    begin
                        Result := -0.00098481927332945418;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := -6.7806702775103189E-05;
                    end
                    else
                    begin
                        Result := 0.0065881993924317263;
                    end;
                end;
            end
            else
            begin
                if features[217] <= 1374.5000000000002 then
                begin
                    Result := 0.021108072352355262;
                end
                else
                begin
                    Result := 0.005188151313041625;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_91(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        Result := -0.019286197963033182;
    end
    else
    begin
        if features[226] <= -313.49999999999994 then
        begin
            if features[216] <= -6261.4999999999991 then
            begin
                if features[174] <= -5595.4999999999991 then
                begin
                    if features[221] <= -7023.9999999999991 then
                    begin
                        Result := 0.049710755338714468;
                    end
                    else
                    begin
                        Result := -0.004231367078899771;
                    end;
                end
                else
                begin
                    if features[222] <= -5512.4999999999991 then
                    begin
                        Result := 0.0099461788144661473;
                    end
                    else
                    begin
                        Result := 0.059756432510610462;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -1046.4999999999998 then
                begin
                    Result := -0.017236224108846222;
                end
                else
                begin
                    if features[46] <= 8.5000000000000018 then
                    begin
                        Result := 0.0021701279672051875;
                    end
                    else
                    begin
                        Result := -0.0081847861309899458;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4953.4999999999991 then
            begin
                if features[166] <= -29654539.999999996 then
                begin
                    if features[90] <= -3.4999999999999996 then
                    begin
                        Result := -0.018280313958502697;
                    end
                    else
                    begin
                        Result := 0.00052517885527362661;
                    end;
                end
                else
                begin
                    if features[91] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.014581939510615208;
                    end
                    else
                    begin
                        Result := 0.0019686926876105594;
                    end;
                end;
            end
            else
            begin
                if features[179] <= -4056.4999999999995 then
                begin
                    if features[37] <= 8.5000000000000018 then
                    begin
                        Result := 0.0082806796394535136;
                    end
                    else
                    begin
                        Result := 0.022443828037468722;
                    end;
                end
                else
                begin
                    Result := -0.0075499239141004239;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_92(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -873.49999999999989 then
    begin
        if features[216] <= -7164.9999999999991 then
        begin
            Result := 0.0073491453018223966;
        end
        else
        begin
            if features[177] <= -5591.4999999999991 then
            begin
                Result := -0.019469905621951149;
            end
            else
            begin
                if features[108] <= -70.499999999999986 then
                begin
                    Result := -0.012532781710777678;
                end
                else
                begin
                    if features[218] <= -4296.4999999999991 then
                    begin
                        Result := 0.0020181570508775335;
                    end
                    else
                    begin
                        Result := 0.069545475017721223;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 136.50000000000003 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[179] <= -3792.4999999999995 then
                begin
                    Result := 0.003140436656425342;
                end
                else
                begin
                    Result := -0.016342001452352119;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[177] <= -6316.4999999999991 then
                    begin
                        Result := -0.018074174225318641;
                    end
                    else
                    begin
                        Result := -0.0015770178220962856;
                    end;
                end
                else
                begin
                    if features[181] <= -931.49999999999989 then
                    begin
                        Result := -0.011189530304620499;
                    end
                    else
                    begin
                        Result := 0.00275321015347153;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4721.4999999999991 then
            begin
                if features[182] <= -5955.4999999999991 then
                begin
                    if features[225] <= -6285.4999999999991 then
                    begin
                        Result := -0.0071012625766710066;
                    end
                    else
                    begin
                        Result := 0.008200256776242856;
                    end;
                end
                else
                begin
                    Result := -0.0050732313369754867;
                end;
            end
            else
            begin
                Result := 0.012904296051536687;
            end;
        end;
    end;
end;

function bidirectional_tree_93(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -640.49999999999989 then
    begin
        if features[180] <= -4277.4999999999991 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                Result := 0.0053696552780473595;
            end
            else
            begin
                Result := -0.017415140687510794;
            end;
        end
        else
        begin
            if features[174] <= -4738.4999999999991 then
            begin
                Result := 0.064159813343472955;
            end
            else
            begin
                Result := -0.021331372093860039;
            end;
        end;
    end
    else
    begin
        if features[226] <= 124.50000000000001 then
        begin
            if features[154] <= -900.49999999999989 then
            begin
                Result := -0.0067598846412872714;
            end
            else
            begin
                if features[154] <= 19.500000000000004 then
                begin
                    if features[118] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0097349592013155507;
                    end
                    else
                    begin
                        Result := 0.00096300957089924056;
                    end;
                end
                else
                begin
                    if features[221] <= -3711.4999999999995 then
                    begin
                        Result := -0.0058469209358108934;
                    end
                    else
                    begin
                        Result := 0.019181618095118112;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4721.4999999999991 then
            begin
                if features[176] <= -5164.4999999999991 then
                begin
                    if features[18] <= 10.500000000000002 then
                    begin
                        Result := 0.0011188803610343557;
                    end
                    else
                    begin
                        Result := 0.012035840941452365;
                    end;
                end
                else
                begin
                    if features[217] <= 488.50000000000006 then
                    begin
                        Result := 0.0019027484757956202;
                    end
                    else
                    begin
                        Result := -0.020552130239241063;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -4895.4999999999991 then
                begin
                    Result := 0.021665933057894254;
                end
                else
                begin
                    Result := 0.0083662533901968233;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_94(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1034.4999999999998 then
    begin
        if features[90] <= 2.5000000000000004 then
        begin
            Result := -0.01857095043178765;
        end
        else
        begin
            Result := 0.020333893627044741;
        end;
    end
    else
    begin
        if features[226] <= -117.49999999999999 then
        begin
            if features[126] <= -1.0000000180025095E-35 then
            begin
                if features[216] <= -5414.4999999999991 then
                begin
                    Result := 0.019036504769611922;
                end
                else
                begin
                    if features[107] <= -3.4999999999999996 then
                    begin
                        Result := 0.028031220644657767;
                    end
                    else
                    begin
                        Result := -0.0039065246594303348;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -95938383.999999985 then
                begin
                    Result := -0.012085198600168828;
                end
                else
                begin
                    if features[227] <= -6813.4999999999991 then
                    begin
                        Result := 0.044574099080707523;
                    end
                    else
                    begin
                        Result := -0.0016456250501151745;
                    end;
                end;
            end;
        end
        else
        begin
            if features[176] <= -4865.4999999999991 then
            begin
                if features[225] <= -4535.4999999999991 then
                begin
                    if features[215] <= -5467.4999999999991 then
                    begin
                        Result := -0.00063634951937790497;
                    end
                    else
                    begin
                        Result := 0.006818620533113268;
                    end;
                end
                else
                begin
                    if features[229] <= 529.50000000000011 then
                    begin
                        Result := 0.010650128719698915;
                    end
                    else
                    begin
                        Result := 0.024452599696125021;
                    end;
                end;
            end
            else
            begin
                if features[181] <= -536.49999999999989 then
                begin
                    Result := -0.015676950148782412;
                end
                else
                begin
                    if features[15] <= -94571291.999999985 then
                    begin
                        Result := 0.026350913558678163;
                    end
                    else
                    begin
                        Result := 0.00075869655090354609;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_95(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[215] <= -8107.4999999999991 then
        begin
            if features[39] <= 1246.5000000000002 then
            begin
                Result := 0.072392452999072279;
            end
            else
            begin
                Result := -0.0067872744972646646;
            end;
        end
        else
        begin
            Result := -0.019563505812418544;
        end;
    end
    else
    begin
        if features[166] <= -140928295.99999997 then
        begin
            if features[90] <= 5.5000000000000009 then
            begin
                if features[226] <= -446.49999999999994 then
                begin
                    if features[47] <= 23924.000000000004 then
                    begin
                        Result := -0.012006332174822828;
                    end
                    else
                    begin
                        Result := 0.0085691068296493578;
                    end;
                end
                else
                begin
                    if features[221] <= -4601.4999999999991 then
                    begin
                        Result := -0.0029888099778001063;
                    end
                    else
                    begin
                        Result := 0.0077787704688106751;
                    end;
                end;
            end
            else
            begin
                if features[154] <= -445.49999999999994 then
                begin
                    Result := 0.032954161553554281;
                end
                else
                begin
                    Result := 0.0063705543453505447;
                end;
            end;
        end
        else
        begin
            if features[157] <= -1.0000000180025095E-35 then
            begin
                if features[145] <= -502.49999999999994 then
                begin
                    Result := 0.012177820461365728;
                end
                else
                begin
                    if features[221] <= -6688.4999999999991 then
                    begin
                        Result := -0.0192945093443679;
                    end
                    else
                    begin
                        Result := -0.0016092195415514513;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 562.50000000000011 then
                begin
                    if features[166] <= -2890982.4999999995 then
                    begin
                        Result := 0.0043112744323657174;
                    end
                    else
                    begin
                        Result := 0.014391178536767208;
                    end;
                end
                else
                begin
                    Result := 0.015014870910137357;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_96(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -341334223.99999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            Result := -0.022600447950429713;
        end
        else
        begin
            if features[175] <= -2412.4999999999995 then
            begin
                if features[166] <= -394465039.99999994 then
                begin
                    Result := -0.011462885635922978;
                end
                else
                begin
                    Result := 0.053597178008204197;
                end;
            end
            else
            begin
                Result := -0.012591744522849816;
            end;
        end;
    end
    else
    begin
        if features[166] <= -139258119.99999997 then
        begin
            if features[90] <= 8.5000000000000018 then
            begin
                if features[229] <= -506.49999999999994 then
                begin
                    if features[219] <= -4884.4999999999991 then
                    begin
                        Result := -0.013977537979684752;
                    end
                    else
                    begin
                        Result := 0.006054878386399583;
                    end;
                end
                else
                begin
                    if features[218] <= -4444.4999999999991 then
                    begin
                        Result := -0.0024926284565569851;
                    end
                    else
                    begin
                        Result := 0.010286592722575226;
                    end;
                end;
            end
            else
            begin
                Result := 0.02237533675200476;
            end;
        end
        else
        begin
            if features[54] <= 1.5000000000000002 then
            begin
                if features[222] <= -5883.4999999999991 then
                begin
                    Result := -0.0098085859722017374;
                end
                else
                begin
                    if features[109] <= -452.49999999999994 then
                    begin
                        Result := 0.013008061391593757;
                    end
                    else
                    begin
                        Result := -0.002756382688218339;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 741.50000000000011 then
                begin
                    if features[166] <= -29654539.999999996 then
                    begin
                        Result := 0.0034577748394518208;
                    end
                    else
                    begin
                        Result := 0.0092524549817410984;
                    end;
                end
                else
                begin
                    Result := 0.017804714625190701;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_97(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            Result := -0.022497701582381145;
        end
        else
        begin
            Result := -0.0099824929242831283;
        end;
    end
    else
    begin
        if features[229] <= -440.49999999999994 then
        begin
            if features[177] <= -5351.4999999999991 then
            begin
                if features[47] <= 14075.500000000002 then
                begin
                    if features[228] <= -7512.9999999999991 then
                    begin
                        Result := 0.04257090557234617;
                    end
                    else
                    begin
                        Result := -0.011912576545008165;
                    end;
                end
                else
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.016006468563794247;
                    end
                    else
                    begin
                        Result := -0.0124945036061267;
                    end;
                end;
            end
            else
            begin
                if features[108] <= -267.49999999999994 then
                begin
                    Result := -0.013499570038551456;
                end
                else
                begin
                    if features[224] <= -3470.4999999999995 then
                    begin
                        Result := 0.032828569683883355;
                    end
                    else
                    begin
                        Result := -0.014719764666162783;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 529.50000000000011 then
            begin
                if features[166] <= -74583523.999999985 then
                begin
                    if features[153] <= 49.500000000000007 then
                    begin
                        Result := 0.0009688275108975992;
                    end
                    else
                    begin
                        Result := -0.013564587187350641;
                    end;
                end
                else
                begin
                    Result := 0.0050395636599530188;
                end;
            end
            else
            begin
                if features[225] <= -5244.4999999999991 then
                begin
                    Result := 0.0015498080531707922;
                end
                else
                begin
                    if features[176] <= -5045.4999999999991 then
                    begin
                        Result := 0.022395380361212778;
                    end
                    else
                    begin
                        Result := -0.00077392799849079427;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_98(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1034.4999999999998 then
    begin
        Result := -0.016439816504476235;
    end
    else
    begin
        if features[226] <= -117.49999999999999 then
        begin
            if features[124] <= -1.0000000180025095E-35 then
            begin
                if features[177] <= -5501.4999999999991 then
                begin
                    if features[216] <= -7394.4999999999991 then
                    begin
                        Result := 0.020817633586992554;
                    end
                    else
                    begin
                        Result := -0.010586715325265054;
                    end;
                end
                else
                begin
                    Result := 0.003831953903090986;
                end;
            end
            else
            begin
                if features[82] <= -143.49999999999997 then
                begin
                    Result := -0.0031501716524265548;
                end
                else
                begin
                    if features[216] <= -6023.4999999999991 then
                    begin
                        Result := 0.016104908902075936;
                    end
                    else
                    begin
                        Result := 0.0023647555089419945;
                    end;
                end;
            end;
        end
        else
        begin
            if features[176] <= -4865.4999999999991 then
            begin
                if features[225] <= -4997.4999999999991 then
                begin
                    if features[27] <= -5942.4999999999991 then
                    begin
                        Result := 0.010420808881382214;
                    end
                    else
                    begin
                        Result := -0.00026509282718591056;
                    end;
                end
                else
                begin
                    if features[229] <= 787.50000000000011 then
                    begin
                        Result := 0.0088376674157836753;
                    end
                    else
                    begin
                        Result := 0.0267224190003751;
                    end;
                end;
            end
            else
            begin
                if features[185] <= -102.37499999999999 then
                begin
                    if features[216] <= -6293.4999999999991 then
                    begin
                        Result := 0.017998506014994291;
                    end
                    else
                    begin
                        Result := -0.01416848468918798;
                    end;
                end
                else
                begin
                    if features[15] <= -94571291.999999985 then
                    begin
                        Result := 0.03467883975703473;
                    end
                    else
                    begin
                        Result := 0.0033530289217256976;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_99(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[215] <= -7708.4999999999991 then
        begin
            Result := 0.018251706995208648;
        end
        else
        begin
            Result := -0.018846872469744275;
        end;
    end
    else
    begin
        if features[166] <= -93540307.999999985 then
        begin
            if features[90] <= 8.5000000000000018 then
            begin
                if features[176] <= -7655.4999999999991 then
                begin
                    if features[109] <= -857.49999999999989 then
                    begin
                        Result := 0.028196661169575289;
                    end
                    else
                    begin
                        Result := -0.013997332048080326;
                    end;
                end
                else
                begin
                    if features[226] <= -470.49999999999994 then
                    begin
                        Result := -0.0079572156549623969;
                    end
                    else
                    begin
                        Result := 0.0010745505479563134;
                    end;
                end;
            end
            else
            begin
                if features[64] <= 1563.0000000000002 then
                begin
                    Result := 0.025233772470342544;
                end
                else
                begin
                    Result := -0.00885483963860253;
                end;
            end;
        end
        else
        begin
            if features[157] <= -1.0000000180025095E-35 then
            begin
                if features[14] <= 28301058.000000004 then
                begin
                    if features[222] <= -5279.4999999999991 then
                    begin
                        Result := -0.0029093971413517742;
                    end
                    else
                    begin
                        Result := 0.0088847613573959216;
                    end;
                end
                else
                begin
                    if features[215] <= -6089.4999999999991 then
                    begin
                        Result := -0.038427888747530184;
                    end
                    else
                    begin
                        Result := -0.0089827711910620747;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 635.50000000000011 then
                begin
                    if features[227] <= -5409.4999999999991 then
                    begin
                        Result := 0.010559195246508481;
                    end
                    else
                    begin
                        Result := 0.0044073223486714528;
                    end;
                end
                else
                begin
                    Result := 0.022059463394710498;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_100(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -655.49999999999989 then
    begin
        if features[180] <= -4465.4999999999991 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[222] <= -5209.4999999999991 then
                begin
                    if features[148] <= 271.00000000000006 then
                    begin
                        Result := -0.0029439646550269757;
                    end
                    else
                    begin
                        Result := 0.064747540729440223;
                    end;
                end
                else
                begin
                    Result := 0.083956446234906099;
                end;
            end
            else
            begin
                Result := -0.017099071794913746;
            end;
        end
        else
        begin
            if features[176] <= -4906.4999999999991 then
            begin
                Result := 0.04369274678900472;
            end
            else
            begin
                Result := -0.021004361056004978;
            end;
        end;
    end
    else
    begin
        if features[229] <= 702.50000000000011 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6747.4999999999991 then
                begin
                    if features[107] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.010216070978810486;
                    end
                    else
                    begin
                        Result := 0.019621869164633328;
                    end;
                end
                else
                begin
                    if features[216] <= -6454.4999999999991 then
                    begin
                        Result := 0.015809968121550128;
                    end
                    else
                    begin
                        Result := 0.0014117379825860229;
                    end;
                end;
            end
            else
            begin
                if features[108] <= -216.49999999999997 then
                begin
                    if features[225] <= -5179.4999999999991 then
                    begin
                        Result := -0.014644969150911178;
                    end
                    else
                    begin
                        Result := -0.0027726461748747919;
                    end;
                end
                else
                begin
                    if features[176] <= -6862.4999999999991 then
                    begin
                        Result := -0.0079751953789475132;
                    end
                    else
                    begin
                        Result := 0.0082303453625354184;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.017437628576373185;
        end;
    end;
end;

function bidirectional_tree_101(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[215] <= -7708.4999999999991 then
        begin
            if features[39] <= 1246.5000000000002 then
            begin
                Result := 0.060963426722313079;
            end
            else
            begin
                Result := -0.0091496396669676992;
            end;
        end
        else
        begin
            Result := -0.018512867985002165;
        end;
    end
    else
    begin
        if features[166] <= -139258119.99999997 then
        begin
            if features[90] <= 2.5000000000000004 then
            begin
                if features[81] <= -986.49999999999989 then
                begin
                    if features[229] <= 385.50000000000006 then
                    begin
                        Result := -0.009633978805919546;
                    end
                    else
                    begin
                        Result := 0.0070111069428988012;
                    end;
                end
                else
                begin
                    if features[154] <= 19.500000000000004 then
                    begin
                        Result := 0.0021138937587753532;
                    end
                    else
                    begin
                        Result := -0.011322818991587894;
                    end;
                end;
            end
            else
            begin
                if features[154] <= -445.49999999999994 then
                begin
                    Result := 0.028491473455467892;
                end
                else
                begin
                    Result := 0.0026745235065795026;
                end;
            end;
        end
        else
        begin
            if features[54] <= 1.5000000000000002 then
            begin
                if features[222] <= -5883.4999999999991 then
                begin
                    Result := -0.0093618487705803208;
                end
                else
                begin
                    if features[184] <= -419.49999999999994 then
                    begin
                        Result := 0.0084925739782210682;
                    end
                    else
                    begin
                        Result := -0.0043558516803034386;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 702.50000000000011 then
                begin
                    if features[216] <= -6454.4999999999991 then
                    begin
                        Result := 0.014511413317309567;
                    end
                    else
                    begin
                        Result := 0.0035675586712518464;
                    end;
                end
                else
                begin
                    Result := 0.020485831437302232;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_102(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        Result := -0.021351768698161799;
    end
    else
    begin
        if features[166] <= -156489495.99999997 then
        begin
            if features[229] <= -506.49999999999994 then
            begin
                if features[225] <= -7728.9999999999991 then
                begin
                    Result := 0.065774324099275944;
                end
                else
                begin
                    if features[158] <= 42562.500000000007 then
                    begin
                        Result := -0.012991924808681785;
                    end
                    else
                    begin
                        Result := 0.025453232146880056;
                    end;
                end;
            end
            else
            begin
                if features[154] <= 33.000000000000007 then
                begin
                    if features[81] <= -383.49999999999994 then
                    begin
                        Result := -0.0055812950475337885;
                    end
                    else
                    begin
                        Result := 0.0054652901997761143;
                    end;
                end
                else
                begin
                    Result := -0.014520390463621606;
                end;
            end;
        end
        else
        begin
            if features[229] <= 312.50000000000006 then
            begin
                if features[154] <= 19.500000000000004 then
                begin
                    if features[166] <= -15719408.499999998 then
                    begin
                        Result := 0.0025046053928503395;
                    end
                    else
                    begin
                        Result := 0.010338999972478106;
                    end;
                end
                else
                begin
                    if features[141] <= -2.4999999999999996 then
                    begin
                        Result := 0.011227596525692527;
                    end
                    else
                    begin
                        Result := -0.0035906390913093378;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6273.4999999999991 then
                begin
                    if features[107] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.019455078546074912;
                    end
                    else
                    begin
                        Result := 0.0044513577434949587;
                    end;
                end
                else
                begin
                    if features[77] <= 1690.5000000000002 then
                    begin
                        Result := 0.0040717950840032787;
                    end
                    else
                    begin
                        Result := 0.017485842856039151;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_103(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            Result := -0.022731936008340288;
        end
        else
        begin
            if features[216] <= -5337.4999999999991 then
            begin
                Result := 0.0032615993294799871;
            end
            else
            begin
                Result := -0.015926880448303846;
            end;
        end;
    end
    else
    begin
        if features[166] <= -139258119.99999997 then
        begin
            if features[90] <= 7.5000000000000009 then
            begin
                if features[81] <= -986.49999999999989 then
                begin
                    if features[219] <= -5111.4999999999991 then
                    begin
                        Result := -0.010905138369644587;
                    end
                    else
                    begin
                        Result := 0.003538788931472333;
                    end;
                end
                else
                begin
                    if features[151] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0021842985638496713;
                    end
                    else
                    begin
                        Result := -0.010484177302757247;
                    end;
                end;
            end
            else
            begin
                if features[73] <= 81.500000000000014 then
                begin
                    Result := 0.027544690640685206;
                end
                else
                begin
                    Result := -0.0019902261640559159;
                end;
            end;
        end
        else
        begin
            if features[54] <= 1.5000000000000002 then
            begin
                if features[222] <= -5901.4999999999991 then
                begin
                    Result := -0.010392089202446792;
                end
                else
                begin
                    if features[184] <= -590.49999999999989 then
                    begin
                        Result := 0.0091847167183991187;
                    end
                    else
                    begin
                        Result := -0.0031935443866509643;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 702.50000000000011 then
                begin
                    if features[216] <= -6454.4999999999991 then
                    begin
                        Result := 0.014610174307966678;
                    end
                    else
                    begin
                        Result := 0.0034498548152188039;
                    end;
                end
                else
                begin
                    Result := 0.019732762928984109;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_104(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -309296735.99999994 then
    begin
        if features[229] <= -371.49999999999994 then
        begin
            if features[174] <= -3120.9999999999995 then
            begin
                Result := -0.020560555228314133;
            end
            else
            begin
                Result := 0.06595427785337675;
            end;
        end
        else
        begin
            Result := -0.0061927466656065792;
        end;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[47] <= 8737.5000000000018 then
                begin
                    if features[229] <= -434.49999999999994 then
                    begin
                        Result := -0.012017251998131709;
                    end
                    else
                    begin
                        Result := -0.0019382718153945955;
                    end;
                end
                else
                begin
                    if features[154] <= 76.500000000000014 then
                    begin
                        Result := 0.0046644603995855509;
                    end
                    else
                    begin
                        Result := -0.0029202009930394896;
                    end;
                end;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[64] <= 1418.0000000000002 then
                    begin
                        Result := 0.020764660703395128;
                    end
                    else
                    begin
                        Result := -0.0099432425214008441;
                    end;
                end
                else
                begin
                    if features[25] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.023359517391711257;
                    end
                    else
                    begin
                        Result := -0.004033861849618554;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6089.4999999999991 then
            begin
                if features[173] <= -5904.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.017172881723265591;
                    end
                    else
                    begin
                        Result := -0.0076333047477954068;
                    end;
                end
                else
                begin
                    Result := -0.010856789774260757;
                end;
            end
            else
            begin
                Result := 0.01335268079763507;
            end;
        end;
    end;
end;

function bidirectional_tree_105(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            Result := -0.023015391387374545;
        end
        else
        begin
            Result := -0.010107938036695692;
        end;
    end
    else
    begin
        if features[166] <= -139258119.99999997 then
        begin
            if features[90] <= 5.5000000000000009 then
            begin
                if features[128] <= -20.499999999999996 then
                begin
                    if features[117] <= -12.499999999999998 then
                    begin
                        Result := -0.014517797184800358;
                    end
                    else
                    begin
                        Result := -0.0050967042860259075;
                    end;
                end
                else
                begin
                    if features[154] <= 19.500000000000004 then
                    begin
                        Result := 0.0025681878596766584;
                    end
                    else
                    begin
                        Result := -0.011210318406926165;
                    end;
                end;
            end
            else
            begin
                if features[154] <= -445.49999999999994 then
                begin
                    Result := 0.030357696424632732;
                end
                else
                begin
                    Result := 0.0052873016327606073;
                end;
            end;
        end
        else
        begin
            if features[154] <= 19.500000000000004 then
            begin
                if features[216] <= -6705.4999999999991 then
                begin
                    Result := 0.017631478675582048;
                end
                else
                begin
                    if features[229] <= 172.50000000000003 then
                    begin
                        Result := 0.0026428376513394584;
                    end
                    else
                    begin
                        Result := 0.0090740146209885835;
                    end;
                end;
            end
            else
            begin
                if features[222] <= -5399.4999999999991 then
                begin
                    if features[96] <= -11412847.999999998 then
                    begin
                        Result := 0.014220420721220463;
                    end
                    else
                    begin
                        Result := -0.0079025225668313773;
                    end;
                end
                else
                begin
                    if features[180] <= -6769.4999999999991 then
                    begin
                        Result := 0.014997814398182388;
                    end
                    else
                    begin
                        Result := -0.00098356900909781484;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_106(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            Result := -0.022502329166228033;
        end
        else
        begin
            Result := -0.008742573994932815;
        end;
    end
    else
    begin
        if features[229] <= -120.49999999999999 then
        begin
            if features[37] <= 4.5000000000000009 then
            begin
                if features[148] <= -1127.4999999999998 then
                begin
                    if features[135] <= 1.5000000000000002 then
                    begin
                        Result := -0.010621013527978637;
                    end
                    else
                    begin
                        Result := 0.013462250365748175;
                    end;
                end
                else
                begin
                    if features[71] <= 1.5000000000000002 then
                    begin
                        Result := -0.0048189279849036931;
                    end
                    else
                    begin
                        Result := 0.0078683305430247361;
                    end;
                end;
            end
            else
            begin
                if features[177] <= -5150.4999999999991 then
                begin
                    if features[166] <= -44188333.999999993 then
                    begin
                        Result := -0.0089467913007327798;
                    end
                    else
                    begin
                        Result := 0.0019785667830356998;
                    end;
                end
                else
                begin
                    if features[185] <= 141.25000000000003 then
                    begin
                        Result := 0.0031154098613415766;
                    end
                    else
                    begin
                        Result := 0.035279920722282865;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -6386.4999999999991 then
            begin
                Result := -0.0070461498250947302;
            end
            else
            begin
                if features[176] <= -4760.4999999999991 then
                begin
                    if features[226] <= 1149.0000000000002 then
                    begin
                        Result := 0.0053185717411312833;
                    end
                    else
                    begin
                        Result := 0.024629649004701881;
                    end;
                end
                else
                begin
                    if features[181] <= -536.49999999999989 then
                    begin
                        Result := -0.01755625316031206;
                    end
                    else
                    begin
                        Result := 0.0064306481846621221;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_107(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[229] <= -719.49999999999989 then
        begin
            Result := -0.023710356401527646;
        end
        else
        begin
            Result := -0.010094829110943698;
        end;
    end
    else
    begin
        if features[166] <= -91803931.999999985 then
        begin
            if features[63] <= 404.50000000000006 then
            begin
                if features[151] <= 72.500000000000014 then
                begin
                    if features[81] <= -221.49999999999997 then
                    begin
                        Result := -0.0059114168874077142;
                    end
                    else
                    begin
                        Result := 0.002030666055513016;
                    end;
                end
                else
                begin
                    if features[148] <= 315.50000000000006 then
                    begin
                        Result := -0.018318364069797387;
                    end
                    else
                    begin
                        Result := 0.025067839206533594;
                    end;
                end;
            end
            else
            begin
                if features[184] <= -65.499999999999986 then
                begin
                    Result := -0.0032546875113867676;
                end
                else
                begin
                    Result := 0.021260578237929956;
                end;
            end;
        end
        else
        begin
            if features[136] <= 1.0000000180025095E-35 then
            begin
                if features[14] <= 28301058.000000004 then
                begin
                    if features[166] <= -39740415.999999993 then
                    begin
                        Result := -0.0046439108771005209;
                    end
                    else
                    begin
                        Result := 0.0061092535206309839;
                    end;
                end
                else
                begin
                    if features[215] <= -6089.4999999999991 then
                    begin
                        Result := -0.03909486890677278;
                    end
                    else
                    begin
                        Result := -0.0090612436300322088;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 891.50000000000011 then
                begin
                    if features[216] <= -6993.4999999999991 then
                    begin
                        Result := 0.025396912400391755;
                    end
                    else
                    begin
                        Result := 0.005518679447449837;
                    end;
                end
                else
                begin
                    Result := 0.023900284283152631;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_108(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        if features[108] <= -238.49999999999997 then
        begin
            Result := -0.021776095637777382;
        end
        else
        begin
            if features[28] <= -5763.4999999999991 then
            begin
                Result := -0.014594706519839164;
            end
            else
            begin
                Result := 0.058072645685036221;
            end;
        end;
    end
    else
    begin
        if features[226] <= -1486.4999999999998 then
        begin
            if features[216] <= -6897.4999999999991 then
            begin
                if features[150] <= -8.4999999999999982 then
                begin
                    if features[215] <= -4828.4999999999991 then
                    begin
                        Result := 0.067915978330408244;
                    end
                    else
                    begin
                        Result := -0.0024409147380793314;
                    end;
                end
                else
                begin
                    Result := -0.013660120809636453;
                end;
            end
            else
            begin
                if features[183] <= -3716.4999999999995 then
                begin
                    Result := -0.024273804349870236;
                end
                else
                begin
                    Result := 0.031621692339337558;
                end;
            end;
        end
        else
        begin
            if features[229] <= 702.50000000000011 then
            begin
                if features[216] <= -7164.9999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.02798533884503401;
                    end
                    else
                    begin
                        Result := 0.003255757750667802;
                    end;
                end
                else
                begin
                    if features[166] <= -158301679.99999997 then
                    begin
                        Result := -0.0032225406771277153;
                    end
                    else
                    begin
                        Result := 0.0022818943623742877;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6200.4999999999991 then
                begin
                    if features[177] <= -6118.4999999999991 then
                    begin
                        Result := 0.012773335803164771;
                    end
                    else
                    begin
                        Result := -0.019283783952338762;
                    end;
                end
                else
                begin
                    Result := 0.02426623051274027;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_109(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -355201055.99999994 then
    begin
        if features[229] <= -506.49999999999994 then
        begin
            Result := -0.022159331840200098;
        end
        else
        begin
            Result := -0.0084514506421458444;
        end;
    end
    else
    begin
        if features[229] <= 185.50000000000003 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[221] <= -5005.4999999999991 then
                    begin
                        Result := 0.018698052730762443;
                    end
                    else
                    begin
                        Result := 0.063729319097837286;
                    end;
                end
                else
                begin
                    if features[175] <= -3766.4999999999995 then
                    begin
                        Result := 0.0540832327950483;
                    end
                    else
                    begin
                        Result := -0.0025278270686001905;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -233554639.99999997 then
                begin
                    if features[90] <= 8.5000000000000018 then
                    begin
                        Result := -0.0088950824294134218;
                    end
                    else
                    begin
                        Result := 0.036683211225851269;
                    end;
                end
                else
                begin
                    if features[216] <= -4018.9999999999995 then
                    begin
                        Result := -0.00022533637733117564;
                    end
                    else
                    begin
                        Result := 0.0091796526994456073;
                    end;
                end;
            end;
        end
        else
        begin
            if features[220] <= 203.50000000000003 then
            begin
                Result := 0.01707786829056326;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[229] <= 1098.0000000000002 then
                    begin
                        Result := -0.0055708150434196115;
                    end
                    else
                    begin
                        Result := 0.031298164695904865;
                    end;
                end
                else
                begin
                    if features[18] <= 10.500000000000002 then
                    begin
                        Result := 0.0028236692536880931;
                    end
                    else
                    begin
                        Result := 0.015668063928240671;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_110(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        Result := -0.020316221832955166;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[216] <= -6454.4999999999991 then
                begin
                    if features[154] <= -900.49999999999989 then
                    begin
                        Result := -0.0045527479040869548;
                    end
                    else
                    begin
                        Result := 0.015458872105665575;
                    end;
                end
                else
                begin
                    if features[222] <= -5928.4999999999991 then
                    begin
                        Result := -0.0035445686648495505;
                    end
                    else
                    begin
                        Result := 0.0029815496829775434;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[177] <= -6316.4999999999991 then
                    begin
                        Result := -0.01770640320730589;
                    end
                    else
                    begin
                        Result := 0.00066862157708708438;
                    end;
                end
                else
                begin
                    if features[226] <= -742.49999999999989 then
                    begin
                        Result := -0.014867402999430627;
                    end
                    else
                    begin
                        Result := 0.0020361163185161333;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6109.4999999999991 then
            begin
                if features[27] <= -6151.4999999999991 then
                begin
                    Result := 0.015605847431907528;
                end
                else
                begin
                    if features[136] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.016177113694223724;
                    end
                    else
                    begin
                        Result := 0.00098888057921372422;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 1866.0000000000002 then
                begin
                    if features[173] <= -6350.4999999999991 then
                    begin
                        Result := -0.025672352047187499;
                    end
                    else
                    begin
                        Result := 0.0062639038436736322;
                    end;
                end
                else
                begin
                    Result := 0.016406105136573399;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_111(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -355201055.99999994 then
    begin
        if features[220] <= -1099.4999999999998 then
        begin
            Result := -0.022825095502005809;
        end
        else
        begin
            Result := -0.010707674454624115;
        end;
    end
    else
    begin
        if features[166] <= -139258119.99999997 then
        begin
            if features[90] <= 7.5000000000000009 then
            begin
                if features[225] <= -5270.4999999999991 then
                begin
                    if features[174] <= -8889.4999999999982 then
                    begin
                        Result := 0.043895562213107364;
                    end
                    else
                    begin
                        Result := -0.0072543096693813355;
                    end;
                end
                else
                begin
                    if features[128] <= -33.499999999999993 then
                    begin
                        Result := -0.0047443095394110943;
                    end
                    else
                    begin
                        Result := 0.0038433720253403646;
                    end;
                end;
            end
            else
            begin
                if features[73] <= 81.500000000000014 then
                begin
                    Result := 0.023978917245344848;
                end
                else
                begin
                    Result := -0.0010742157436678121;
                end;
            end;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[166] <= -29654539.999999996 then
                begin
                    if features[77] <= 55062.500000000007 then
                    begin
                        Result := 0.0034014838777612199;
                    end
                    else
                    begin
                        Result := 0.021905825101098841;
                    end;
                end
                else
                begin
                    Result := 0.011595998965224766;
                end;
            end
            else
            begin
                if features[222] <= -5419.4999999999991 then
                begin
                    if features[158] <= -1464.4999999999998 then
                    begin
                        Result := -0.0071858636280558458;
                    end
                    else
                    begin
                        Result := 0.0016251820503028376;
                    end;
                end
                else
                begin
                    if features[180] <= -6792.4999999999991 then
                    begin
                        Result := 0.013425756033040645;
                    end
                    else
                    begin
                        Result := -0.00057402891376804265;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_112(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1034.4999999999998 then
    begin
        if features[180] <= -4377.4999999999991 then
        begin
            if features[216] <= -7297.4999999999991 then
            begin
                if features[222] <= -5209.4999999999991 then
                begin
                    if features[71] <= 4.5000000000000009 then
                    begin
                        Result := -0.019058929149332923;
                    end
                    else
                    begin
                        Result := 0.02359124093668832;
                    end;
                end
                else
                begin
                    Result := 0.082819217993711128;
                end;
            end
            else
            begin
                Result := -0.018123792015690986;
            end;
        end
        else
        begin
            Result := 0.028443644638026691;
        end;
    end
    else
    begin
        if features[229] <= 702.50000000000011 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[216] <= -5398.4999999999991 then
                    begin
                        Result := 0.0062311725409998787;
                    end
                    else
                    begin
                        Result := -0.0024470403599226869;
                    end;
                end
                else
                begin
                    if features[82] <= -168002.49999999997 then
                    begin
                        Result := -0.0085520093059930306;
                    end
                    else
                    begin
                        Result := 0.008076689242816756;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[183] <= -5007.4999999999991 then
                    begin
                        Result := -0.012351925137278145;
                    end
                    else
                    begin
                        Result := 0.011129576230831356;
                    end;
                end
                else
                begin
                    if features[154] <= -46.499999999999993 then
                    begin
                        Result := 0.0041410282049087841;
                    end
                    else
                    begin
                        Result := -0.0064465621334046696;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -5407.4999999999991 then
            begin
                Result := -0.0011591503206840965;
            end
            else
            begin
                Result := 0.020592271097173351;
            end;
        end;
    end;
end;

function bidirectional_tree_113(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1034.4999999999998 then
    begin
        if features[180] <= -4465.4999999999991 then
        begin
            if features[227] <= -4971.4999999999991 then
            begin
                if features[183] <= -6653.4999999999991 then
                begin
                    if features[217] <= -2885.4999999999995 then
                    begin
                        Result := 0.029921883337917472;
                    end
                    else
                    begin
                        Result := -0.021285508308802572;
                    end;
                end
                else
                begin
                    Result := 0.034234685742640839;
                end;
            end
            else
            begin
                Result := -0.019118545512071688;
            end;
        end
        else
        begin
            if features[174] <= -5397.4999999999991 then
            begin
                Result := 0.055750214849553607;
            end
            else
            begin
                Result := -0.014335134014714103;
            end;
        end;
    end
    else
    begin
        if features[229] <= 702.50000000000011 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[180] <= -7546.4999999999991 then
                    begin
                        Result := -0.0027063861681933411;
                    end
                    else
                    begin
                        Result := 0.034398810002538943;
                    end;
                end
                else
                begin
                    Result := 0.0033056410834105192;
                end;
            end
            else
            begin
                if features[181] <= -1121.4999999999998 then
                begin
                    if features[177] <= -6843.4999999999991 then
                    begin
                        Result := 0.00019467393166553272;
                    end
                    else
                    begin
                        Result := -0.014586255969546902;
                    end;
                end
                else
                begin
                    if features[218] <= -4444.4999999999991 then
                    begin
                        Result := 0.00036245117188012847;
                    end
                    else
                    begin
                        Result := 0.0084498340886862439;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6137.4999999999991 then
            begin
                Result := 0.0040133508711819778;
            end
            else
            begin
                Result := 0.023641227331265887;
            end;
        end;
    end;
end;

function bidirectional_tree_114(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1033.4999999999998 then
    begin
        Result := -0.018482749408759182;
    end
    else
    begin
        if features[226] <= -117.49999999999999 then
        begin
            if features[164] <= -141239415.99999997 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    if features[180] <= -8044.4999999999991 then
                    begin
                        Result := 0.038814983382978785;
                    end
                    else
                    begin
                        Result := -0.0040372997061034034;
                    end;
                end
                else
                begin
                    Result := -0.01430371905687842;
                end;
            end
            else
            begin
                if features[187] <= -21.232142448425289 then
                begin
                    if features[180] <= -5452.4999999999991 then
                    begin
                        Result := -0.008507462041371372;
                    end
                    else
                    begin
                        Result := 0.0048689826790595742;
                    end;
                end
                else
                begin
                    if features[18] <= 8.5000000000000018 then
                    begin
                        Result := 0.0058406493918500696;
                    end
                    else
                    begin
                        Result := -0.0014704853400669046;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[215] <= -4644.4999999999991 then
                begin
                    if features[216] <= -4619.4999999999991 then
                    begin
                        Result := -0.0021520180843092583;
                    end
                    else
                    begin
                        Result := -0.015514791210341826;
                    end;
                end
                else
                begin
                    Result := 0.016046557599211402;
                end;
            end
            else
            begin
                if features[216] <= -4018.9999999999995 then
                begin
                    if features[0] <= 38370.500000000007 then
                    begin
                        Result := -0.0016866479155843311;
                    end
                    else
                    begin
                        Result := 0.0056086810851243805;
                    end;
                end
                else
                begin
                    if features[175] <= 1847.0000000000002 then
                    begin
                        Result := 0.018163400939876364;
                    end
                    else
                    begin
                        Result := -0.0024501425762488236;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_115(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1034.4999999999998 then
    begin
        if features[90] <= 2.5000000000000004 then
        begin
            if features[216] <= -7297.4999999999991 then
            begin
                if features[174] <= -5162.4999999999991 then
                begin
                    Result := -0.0055030187387609458;
                end
                else
                begin
                    if features[182] <= -6018.4999999999991 then
                    begin
                        Result := -0.017976835962769885;
                    end
                    else
                    begin
                        Result := 0.077171908878945206;
                    end;
                end;
            end
            else
            begin
                Result := -0.018603341388650944;
            end;
        end
        else
        begin
            Result := 0.017465962964611042;
        end;
    end
    else
    begin
        if features[229] <= 702.50000000000011 then
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[124] <= -193.49999999999997 then
                begin
                    if features[183] <= -6459.4999999999991 then
                    begin
                        Result := -0.012159825417581968;
                    end
                    else
                    begin
                        Result := -0.00027820731097299008;
                    end;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.0012522171798856577;
                    end
                    else
                    begin
                        Result := 0.0076235461034521966;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[216] <= -5525.4999999999991 then
                    begin
                        Result := -0.019242510359589043;
                    end
                    else
                    begin
                        Result := -0.0060680909322040942;
                    end;
                end
                else
                begin
                    if features[157] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.006283430501705595;
                    end
                    else
                    begin
                        Result := 0.0057990391504290275;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -5986.4999999999991 then
            begin
                Result := 0.0038609997042705563;
            end
            else
            begin
                Result := 0.022702804523728231;
            end;
        end;
    end;
end;

function bidirectional_tree_116(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -397343039.99999994 then
    begin
        if features[108] <= -238.49999999999997 then
        begin
            Result := -0.020277712812829966;
        end
        else
        begin
            Result := 0.022987540975666514;
        end;
    end
    else
    begin
        if features[229] <= 635.50000000000011 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[221] <= -4283.4999999999991 then
                    begin
                        Result := 0.017454450811326939;
                    end
                    else
                    begin
                        Result := 0.07278050048274097;
                    end;
                end
                else
                begin
                    if features[175] <= -3766.4999999999995 then
                    begin
                        Result := 0.04789681604794721;
                    end
                    else
                    begin
                        Result := -0.00049198330256303375;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -882.49999999999989 then
                begin
                    if features[177] <= -5591.4999999999991 then
                    begin
                        Result := -0.014886071440557636;
                    end
                    else
                    begin
                        Result := 0.0080500650117328269;
                    end;
                end
                else
                begin
                    if features[166] <= -89999783.999999985 then
                    begin
                        Result := -0.0013175855251424734;
                    end
                    else
                    begin
                        Result := 0.0029972830648828251;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6137.4999999999991 then
            begin
                if features[27] <= -4885.4999999999991 then
                begin
                    if features[216] <= -5799.4999999999991 then
                    begin
                        Result := -0.01063048158688714;
                    end
                    else
                    begin
                        Result := 0.020930027531140427;
                    end;
                end
                else
                begin
                    if features[55] <= 1.5000000000000002 then
                    begin
                        Result := -0.037975775489592946;
                    end
                    else
                    begin
                        Result := -0.0011271840384642897;
                    end;
                end;
            end
            else
            begin
                Result := 0.020863063768753687;
            end;
        end;
    end;
end;

function bidirectional_tree_117(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        Result := -0.020891248016000778;
    end
    else
    begin
        if features[166] <= -199630583.99999997 then
        begin
            if features[222] <= -5601.4999999999991 then
            begin
                if features[174] <= -8889.4999999999982 then
                begin
                    Result := 0.048274619294163969;
                end
                else
                begin
                    if features[135] <= 1.5000000000000002 then
                    begin
                        Result := -0.011020254461161104;
                    end
                    else
                    begin
                        Result := 0.0093861073485423888;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -5468.4999999999991 then
                begin
                    if features[47] <= 10551.500000000002 then
                    begin
                        Result := -0.0017047815599360917;
                    end
                    else
                    begin
                        Result := 0.026608764949387326;
                    end;
                end
                else
                begin
                    if features[223] <= -55.499999999999993 then
                    begin
                        Result := -0.0080048147357982581;
                    end
                    else
                    begin
                        Result := 0.0037339978129046201;
                    end;
                end;
            end;
        end
        else
        begin
            if features[154] <= 19.500000000000004 then
            begin
                if features[216] <= -7164.9999999999991 then
                begin
                    Result := 0.015060266453186727;
                end
                else
                begin
                    if features[217] <= -1206.4999999999998 then
                    begin
                        Result := -0.0036237074194741693;
                    end
                    else
                    begin
                        Result := 0.0036829302404260398;
                    end;
                end;
            end
            else
            begin
                if features[222] <= -5883.4999999999991 then
                begin
                    if features[166] <= -82083855.999999985 then
                    begin
                        Result := -0.017761684350086467;
                    end
                    else
                    begin
                        Result := -0.0048244442600163416;
                    end;
                end
                else
                begin
                    if features[148] <= -1159.4999999999998 then
                    begin
                        Result := -0.0080000220520307138;
                    end
                    else
                    begin
                        Result := 0.0049099124061076508;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_118(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1033.4999999999998 then
    begin
        if features[227] <= -5596.4999999999991 then
        begin
            if features[218] <= -5622.4999999999991 then
            begin
                Result := 0.058040677091769854;
            end
            else
            begin
                Result := -0.01900752199138387;
            end;
        end
        else
        begin
            Result := -0.020160038173816279;
        end;
    end
    else
    begin
        if features[216] <= -7164.9999999999991 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[221] <= -4456.4999999999991 then
                begin
                    if features[175] <= -1925.9999999999998 then
                    begin
                        Result := -0.018426036001037309;
                    end
                    else
                    begin
                        Result := 0.025146576264015237;
                    end;
                end
                else
                begin
                    Result := 0.081330021955792253;
                end;
            end
            else
            begin
                Result := 0.0034702668127009092;
            end;
        end
        else
        begin
            if features[226] <= -71.499999999999986 then
            begin
                if features[177] <= -5015.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.00059819894478499707;
                    end
                    else
                    begin
                        Result := -0.0080859971328901287;
                    end;
                end
                else
                begin
                    if features[108] <= -267.49999999999994 then
                    begin
                        Result := -0.0092040205073420974;
                    end
                    else
                    begin
                        Result := 0.013088576730293018;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[217] <= -533.49999999999989 then
                    begin
                        Result := 0.015662641104858883;
                    end
                    else
                    begin
                        Result := -0.0077423758703546331;
                    end;
                end
                else
                begin
                    if features[173] <= -4771.4999999999991 then
                    begin
                        Result := 0.0021271854533266295;
                    end
                    else
                    begin
                        Result := 0.0099407523806610554;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_119(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[124] <= 330.50000000000006 then
        begin
            if features[225] <= -4492.4999999999991 then
            begin
                Result := -0.023044701410364597;
            end
            else
            begin
                Result := -0.0051060861818405835;
            end;
        end
        else
        begin
            if features[220] <= 21.500000000000004 then
            begin
                Result := -0.013031476009824329;
            end
            else
            begin
                Result := 0.061420003545216498;
            end;
        end;
    end
    else
    begin
        if features[226] <= -1486.4999999999998 then
        begin
            if features[174] <= -9314.4999999999982 then
            begin
                Result := 0.053113806225617261;
            end
            else
            begin
                if features[180] <= -3750.4999999999995 then
                begin
                    Result := -0.020814215075900103;
                end
                else
                begin
                    Result := 0.029268111388228314;
                end;
            end;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[128] <= -149.49999999999997 then
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.00073153807204065632;
                    end
                    else
                    begin
                        Result := -0.008639142180574896;
                    end;
                end
                else
                begin
                    if features[154] <= 19.500000000000004 then
                    begin
                        Result := 0.0037014268053405675;
                    end
                    else
                    begin
                        Result := -0.0026000016404206135;
                    end;
                end;
            end
            else
            begin
                if features[154] <= -275.49999999999994 then
                begin
                    if features[176] <= -6814.4999999999991 then
                    begin
                        Result := 0.0050369136565520077;
                    end
                    else
                    begin
                        Result := 0.021659367458687115;
                    end;
                end
                else
                begin
                    if features[37] <= 2.5000000000000004 then
                    begin
                        Result := 0.031329218295385208;
                    end
                    else
                    begin
                        Result := 0.0;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_120(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1055.4999999999998 then
    begin
        Result := -0.019377728946530153;
    end
    else
    begin
        if features[226] <= -117.49999999999999 then
        begin
            if features[164] <= -93086051.999999985 then
            begin
                if features[165] <= -60613691.999999993 then
                begin
                    if features[164] <= -144727127.99999997 then
                    begin
                        Result := -0.0059808664364604715;
                    end
                    else
                    begin
                        Result := 0.017007346727214448;
                    end;
                end
                else
                begin
                    Result := -0.014686238088965518;
                end;
            end
            else
            begin
                if features[216] <= -7164.9999999999991 then
                begin
                    if features[221] <= -4241.4999999999991 then
                    begin
                        Result := 0.0121548629850098;
                    end
                    else
                    begin
                        Result := 0.070270206117408626;
                    end;
                end
                else
                begin
                    if features[170] <= 1.5000000000000002 then
                    begin
                        Result := 0.0066060488404064161;
                    end
                    else
                    begin
                        Result := -0.0022618658323679008;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[220] <= -13.499999999999998 then
                begin
                    Result := 0.0077231265159500295;
                end
                else
                begin
                    if features[181] <= -158.49999999999997 then
                    begin
                        Result := -0.011947532668508282;
                    end
                    else
                    begin
                        Result := 0.00093324394830550232;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -4018.9999999999995 then
                begin
                    if features[121] <= -1171.4999999999998 then
                    begin
                        Result := -0.0096173088710509586;
                    end
                    else
                    begin
                        Result := 0.0041514696950364248;
                    end;
                end
                else
                begin
                    if features[175] <= 1847.0000000000002 then
                    begin
                        Result := 0.016242370807189804;
                    end
                    else
                    begin
                        Result := -0.0024248669676971576;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_121(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1055.4999999999998 then
    begin
        if features[227] <= -5596.4999999999991 then
        begin
            Result := 0.026853418389334922;
        end
        else
        begin
            Result := -0.019567243148090555;
        end;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[173] <= -4215.4999999999991 then
            begin
                if features[172] <= 1.5000000000000002 then
                begin
                    if features[175] <= -1142.4999999999998 then
                    begin
                        Result := 0.010971171304684037;
                    end
                    else
                    begin
                        Result := 0.00059858927212560554;
                    end;
                end
                else
                begin
                    if features[175] <= -912.49999999999989 then
                    begin
                        Result := -0.0022141280324916974;
                    end
                    else
                    begin
                        Result := 0.013458290518760505;
                    end;
                end;
            end
            else
            begin
                if features[217] <= 432.50000000000006 then
                begin
                    if features[215] <= -5038.4999999999991 then
                    begin
                        Result := 0.017988526385427892;
                    end
                    else
                    begin
                        Result := -0.0033839485562397044;
                    end;
                end
                else
                begin
                    Result := -0.014868996704005126;
                end;
            end;
        end
        else
        begin
            if features[81] <= -1.0000000180025095E-35 then
            begin
                if features[177] <= -6131.4999999999991 then
                begin
                    Result := -0.014583422638117009;
                end
                else
                begin
                    Result := 0.0016430965032342667;
                end;
            end
            else
            begin
                if features[154] <= 33.000000000000007 then
                begin
                    if features[148] <= 226.50000000000003 then
                    begin
                        Result := 0.0029485217181828777;
                    end
                    else
                    begin
                        Result := 0.022670062874979798;
                    end;
                end
                else
                begin
                    if features[215] <= -4803.4999999999991 then
                    begin
                        Result := -0.012365804507543288;
                    end
                    else
                    begin
                        Result := 0.0029203761220474873;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_122(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1069.4999999999998 then
    begin
        if features[177] <= -5193.4999999999991 then
        begin
            if features[227] <= -5596.4999999999991 then
            begin
                Result := 0.02120324485923258;
            end
            else
            begin
                Result := -0.018800128409476018;
            end;
        end
        else
        begin
            if features[173] <= -5527.4999999999991 then
            begin
                Result := 0.04755139639769046;
            end
            else
            begin
                Result := -0.01206143427555173;
            end;
        end;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[176] <= -7434.4999999999991 then
            begin
                if features[0] <= 23055.500000000004 then
                begin
                    Result := -0.014969219523981321;
                end
                else
                begin
                    Result := -0.0033174327562363092;
                end;
            end
            else
            begin
                if features[217] <= 328.50000000000006 then
                begin
                    if features[47] <= 3777.5000000000005 then
                    begin
                        Result := -0.0042910401584463935;
                    end
                    else
                    begin
                        Result := 0.0038952910215493326;
                    end;
                end
                else
                begin
                    if features[181] <= -1591.4999999999998 then
                    begin
                        Result := -0.021379366754300654;
                    end
                    else
                    begin
                        Result := -0.0013747870315612516;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6109.4999999999991 then
            begin
                if features[55] <= 1.5000000000000002 then
                begin
                    Result := -0.015117527102602751;
                end
                else
                begin
                    Result := 0.0026036534934500977;
                end;
            end
            else
            begin
                if features[77] <= 1690.5000000000002 then
                begin
                    if features[217] <= -257.49999999999994 then
                    begin
                        Result := 0.015622189604123801;
                    end
                    else
                    begin
                        Result := -0.0061832028325525326;
                    end;
                end
                else
                begin
                    Result := 0.015609103524548341;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_123(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        Result := -0.019712432513511572;
    end
    else
    begin
        if features[229] <= 442.50000000000006 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -4215.4999999999991 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.00072443761593451105;
                    end
                    else
                    begin
                        Result := 0.0089155726625184152;
                    end;
                end
                else
                begin
                    if features[217] <= 432.50000000000006 then
                    begin
                        Result := -0.0010544640454984947;
                    end
                    else
                    begin
                        Result := -0.014575829748332528;
                    end;
                end;
            end
            else
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[215] <= -4712.4999999999991 then
                    begin
                        Result := -0.0044433799573035315;
                    end
                    else
                    begin
                        Result := 0.0061451538035977912;
                    end;
                end
                else
                begin
                    if features[174] <= -4447.4999999999991 then
                    begin
                        Result := -0.014788344265218082;
                    end
                    else
                    begin
                        Result := 0.0072098267705756119;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6109.4999999999991 then
            begin
                if features[173] <= -5844.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.019440128607566554;
                    end
                    else
                    begin
                        Result := -0.0050689910396597548;
                    end;
                end
                else
                begin
                    Result := -0.011103957814642906;
                end;
            end
            else
            begin
                if features[180] <= -4778.4999999999991 then
                begin
                    if features[225] <= -5280.4999999999991 then
                    begin
                        Result := 0.0016920144165674571;
                    end
                    else
                    begin
                        Result := 0.021410439360326498;
                    end;
                end
                else
                begin
                    Result := -0.0042395386146473488;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_124(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -397343039.99999994 then
    begin
        if features[108] <= -238.49999999999997 then
        begin
            if features[229] <= -640.49999999999989 then
            begin
                Result := -0.023442941845950374;
            end
            else
            begin
                Result := -0.012981364696670609;
            end;
        end
        else
        begin
            if features[74] <= 8.5000000000000018 then
            begin
                Result := -0.013801588320046534;
            end
            else
            begin
                Result := 0.057169470948621862;
            end;
        end;
    end
    else
    begin
        if features[226] <= -1504.4999999999998 then
        begin
            if features[183] <= -3716.4999999999995 then
            begin
                if features[174] <= -8889.4999999999982 then
                begin
                    Result := 0.021506763841423342;
                end
                else
                begin
                    Result := -0.021906677090823213;
                end;
            end
            else
            begin
                Result := 0.029970357224111583;
            end;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[47] <= 8737.5000000000018 then
                begin
                    if features[219] <= -5129.4999999999991 then
                    begin
                        Result := -0.0040307842984103649;
                    end
                    else
                    begin
                        Result := 0.0044645935159512594;
                    end;
                end
                else
                begin
                    if features[158] <= 1645.5000000000002 then
                    begin
                        Result := 0.00041760803000783099;
                    end
                    else
                    begin
                        Result := 0.0068880641056932078;
                    end;
                end;
            end
            else
            begin
                if features[67] <= 1483.0000000000002 then
                begin
                    if features[147] <= 409.00000000000006 then
                    begin
                        Result := 0.015284226175598653;
                    end
                    else
                    begin
                        Result := -0.0015965547896121973;
                    end;
                end
                else
                begin
                    if features[180] <= -7686.4999999999991 then
                    begin
                        Result := -0.02909268870501848;
                    end
                    else
                    begin
                        Result := 0.00070057764812131104;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_125(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1069.4999999999998 then
    begin
        if features[177] <= -5193.4999999999991 then
        begin
            if features[174] <= -3120.9999999999995 then
            begin
                Result := -0.017327646536111168;
            end
            else
            begin
                Result := 0.059357171305616956;
            end;
        end
        else
        begin
            if features[173] <= -5527.4999999999991 then
            begin
                Result := 0.048374211513331961;
            end
            else
            begin
                Result := -0.012270539506116155;
            end;
        end;
    end
    else
    begin
        if features[226] <= 136.50000000000003 then
        begin
            if features[220] <= 453.50000000000006 then
            begin
                if features[176] <= -7459.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0014086959785668117;
                    end
                    else
                    begin
                        Result := -0.012446796575043809;
                    end;
                end
                else
                begin
                    if features[179] <= -3792.4999999999995 then
                    begin
                        Result := 0.0013381674691325192;
                    end
                    else
                    begin
                        Result := -0.013653523296191364;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.028514742652237069;
                end
                else
                begin
                    Result := -0.0060487241021395521;
                end;
            end;
        end
        else
        begin
            if features[220] <= 236.50000000000003 then
            begin
                Result := 0.012387932732828462;
            end
            else
            begin
                if features[158] <= 1387.5000000000002 then
                begin
                    if features[217] <= -563.49999999999989 then
                    begin
                        Result := 0.011822663447803805;
                    end
                    else
                    begin
                        Result := -0.0064202049204808431;
                    end;
                end
                else
                begin
                    if features[48] <= 8623.5000000000018 then
                    begin
                        Result := 0.0030045916299341266;
                    end
                    else
                    begin
                        Result := 0.015338504796572575;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_126(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1486.4999999999998 then
    begin
        if features[227] <= -5652.4999999999991 then
        begin
            if features[174] <= -9314.4999999999982 then
            begin
                Result := 0.074376795304107859;
            end
            else
            begin
                Result := -0.016633521738092058;
            end;
        end
        else
        begin
            Result := -0.02176398052566865;
        end;
    end
    else
    begin
        if features[226] <= 421.50000000000006 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[82] <= -169806.99999999997 then
                begin
                    if features[180] <= -5858.4999999999991 then
                    begin
                        Result := -0.014491297542881355;
                    end
                    else
                    begin
                        Result := 0.0059604082387994433;
                    end;
                end
                else
                begin
                    if features[179] <= -3792.4999999999995 then
                    begin
                        Result := 0.0025272676808326252;
                    end
                    else
                    begin
                        Result := -0.01652481795235218;
                    end;
                end;
            end
            else
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[175] <= -2028.4999999999998 then
                    begin
                        Result := 0.016659375866275195;
                    end
                    else
                    begin
                        Result := -0.0020565683321857394;
                    end;
                end
                else
                begin
                    if features[174] <= -4718.4999999999991 then
                    begin
                        Result := -0.016212182126401749;
                    end
                    else
                    begin
                        Result := 0.0036137264991263638;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4293.4999999999991 then
            begin
                if features[77] <= 1690.5000000000002 then
                begin
                    Result := -0.0078574235200182165;
                end
                else
                begin
                    if features[225] <= -6285.4999999999991 then
                    begin
                        Result := -0.014005701244170998;
                    end
                    else
                    begin
                        Result := 0.0082049557991753352;
                    end;
                end;
            end
            else
            begin
                Result := 0.016879199429585309;
            end;
        end;
    end;
end;

function bidirectional_tree_127(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[225] <= -4521.4999999999991 then
        begin
            Result := -0.021093129600728205;
        end
        else
        begin
            Result := -0.0018278026175991718;
        end;
    end
    else
    begin
        if features[166] <= -93540307.999999985 then
        begin
            if features[90] <= 8.5000000000000018 then
            begin
                if features[176] <= -7655.4999999999991 then
                begin
                    if features[216] <= -4940.4999999999991 then
                    begin
                        Result := -0.015274316998550775;
                    end
                    else
                    begin
                        Result := 0.00041159395065481412;
                    end;
                end
                else
                begin
                    if features[226] <= -414.49999999999994 then
                    begin
                        Result := -0.0061113713779491867;
                    end
                    else
                    begin
                        Result := 0.00092786314911317842;
                    end;
                end;
            end
            else
            begin
                if features[151] <= -83.499999999999986 then
                begin
                    if features[171] <= 4.5000000000000009 then
                    begin
                        Result := 0.0128257534749893;
                    end
                    else
                    begin
                        Result := 0.041960956374063267;
                    end;
                end
                else
                begin
                    if features[225] <= -5357.4999999999991 then
                    begin
                        Result := -0.0057919987390783016;
                    end
                    else
                    begin
                        Result := 0.018367374514119763;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -3699.4999999999995 then
            begin
                if features[136] <= -1.0000000180025095E-35 then
                begin
                    if features[109] <= -452.49999999999994 then
                    begin
                        Result := 0.0083533146944327532;
                    end
                    else
                    begin
                        Result := -0.0059613983213236714;
                    end;
                end
                else
                begin
                    if features[216] <= -6319.4999999999991 then
                    begin
                        Result := 0.013210851669956345;
                    end
                    else
                    begin
                        Result := 0.0031467044157861518;
                    end;
                end;
            end
            else
            begin
                Result := 0.018495228995802891;
            end;
        end;
    end;
end;

function bidirectional_tree_128(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        if features[108] <= -238.49999999999997 then
        begin
            Result := -0.019487877455540186;
        end
        else
        begin
            Result := 0.027298621626431992;
        end;
    end
    else
    begin
        if features[225] <= -3627.4999999999995 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[81] <= -1131.4999999999998 then
                begin
                    if features[187] <= -13.464285850524901 then
                    begin
                        Result := -0.012472083029531305;
                    end
                    else
                    begin
                        Result := -0.0023312173073901667;
                    end;
                end
                else
                begin
                    if features[148] <= -1132.4999999999998 then
                    begin
                        Result := -0.0025314206027879163;
                    end
                    else
                    begin
                        Result := 0.0030263610407189369;
                    end;
                end;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[66] <= 512.50000000000011 then
                    begin
                        Result := 0.017750606917233503;
                    end
                    else
                    begin
                        Result := -0.0017948125104985822;
                    end;
                end
                else
                begin
                    if features[25] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.021745721944530168;
                    end
                    else
                    begin
                        Result := -0.0032507455637742948;
                    end;
                end;
            end;
        end
        else
        begin
            if features[27] <= -4237.4999999999991 then
            begin
                Result := 0.026822898013004828;
            end
            else
            begin
                if features[220] <= -390.49999999999994 then
                begin
                    if features[182] <= -3837.4999999999995 then
                    begin
                        Result := 0.040974765166142305;
                    end
                    else
                    begin
                        Result := 0.0048305662794076686;
                    end;
                end
                else
                begin
                    if features[224] <= -3756.4999999999995 then
                    begin
                        Result := 0.013373312392325211;
                    end
                    else
                    begin
                        Result := -0.009486128510722322;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_129(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        Result := -0.019653242201252984;
    end
    else
    begin
        if features[166] <= -185915207.99999997 then
        begin
            if features[174] <= -8889.4999999999982 then
            begin
                if features[110] <= -1011.4999999999999 then
                begin
                    Result := 0.09044316524683288;
                end
                else
                begin
                    Result := 0.012536017688511307;
                end;
            end
            else
            begin
                if features[135] <= 5.5000000000000009 then
                begin
                    if features[229] <= -596.49999999999989 then
                    begin
                        Result := -0.014547891844569508;
                    end
                    else
                    begin
                        Result := -0.0027606065825816119;
                    end;
                end
                else
                begin
                    if features[154] <= -597.49999999999989 then
                    begin
                        Result := 0.033315566474001364;
                    end
                    else
                    begin
                        Result := 0.0041746923686880157;
                    end;
                end;
            end;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[62] <= 1.5000000000000002 then
                begin
                    if features[166] <= -29654539.999999996 then
                    begin
                        Result := 0.0015215340459097855;
                    end
                    else
                    begin
                        Result := 0.0087267643918433405;
                    end;
                end
                else
                begin
                    if features[177] <= -6331.4999999999991 then
                    begin
                        Result := 0.0013733181165186527;
                    end
                    else
                    begin
                        Result := 0.023038332760385666;
                    end;
                end;
            end
            else
            begin
                if features[14] <= 28301058.000000004 then
                begin
                    if features[166] <= -69524739.999999985 then
                    begin
                        Result := -0.0056987979042676749;
                    end
                    else
                    begin
                        Result := 0.0035077556666522993;
                    end;
                end
                else
                begin
                    if features[110] <= -652.49999999999989 then
                    begin
                        Result := 0.019386135383389919;
                    end
                    else
                    begin
                        Result := -0.014084638143983259;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_130(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        if features[180] <= -5250.4999999999991 then
        begin
            Result := -0.019669069182025326;
        end
        else
        begin
            if features[221] <= -4625.4999999999991 then
            begin
                Result := 0.073010193747515176;
            end
            else
            begin
                Result := -0.010706323457411663;
            end;
        end;
    end
    else
    begin
        if features[229] <= 787.50000000000011 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[216] <= -6454.4999999999991 then
                begin
                    if features[107] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0086893542894231537;
                    end
                    else
                    begin
                        Result := 0.035354446082322445;
                    end;
                end
                else
                begin
                    if features[176] <= -4356.4999999999991 then
                    begin
                        Result := 0.002077781408507764;
                    end
                    else
                    begin
                        Result := -0.0073500573154862405;
                    end;
                end;
            end
            else
            begin
                if features[219] <= -5918.4999999999991 then
                begin
                    if features[173] <= -3070.4999999999995 then
                    begin
                        Result := -0.0082455426060906219;
                    end
                    else
                    begin
                        Result := 0.021296109662027409;
                    end;
                end
                else
                begin
                    if features[108] <= -184.49999999999997 then
                    begin
                        Result := -0.0053934291191004846;
                    end
                    else
                    begin
                        Result := 0.0046420295578579298;
                    end;
                end;
            end;
        end
        else
        begin
            if features[228] <= -5300.4999999999991 then
            begin
                if features[166] <= -74583523.999999985 then
                begin
                    Result := -0.017387758763384244;
                end
                else
                begin
                    Result := 0.015392050013128281;
                end;
            end
            else
            begin
                if features[150] <= 5.5000000000000009 then
                begin
                    Result := 0.023544308875760575;
                end
                else
                begin
                    Result := -0.0029616433542562644;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_131(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1486.4999999999998 then
    begin
        if features[227] <= -5652.4999999999991 then
        begin
            Result := 0.029502786609368045;
        end
        else
        begin
            if features[180] <= -4277.4999999999991 then
            begin
                Result := -0.02294396947537276;
            end
            else
            begin
                Result := 0.026848032646147154;
            end;
        end;
    end
    else
    begin
        if features[179] <= -4143.4999999999991 then
        begin
            if features[225] <= -3815.4999999999995 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[173] <= -4232.4999999999991 then
                    begin
                        Result := 0.0034969881559581716;
                    end
                    else
                    begin
                        Result := -0.0027786068451570224;
                    end;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.00049477198771592866;
                    end
                    else
                    begin
                        Result := -0.010391674742128734;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -4226.4999999999991 then
                begin
                    Result := 0.024227998457954036;
                end
                else
                begin
                    if features[47] <= 22224.000000000004 then
                    begin
                        Result := -0.0035666204694071164;
                    end
                    else
                    begin
                        Result := 0.02603351917416771;
                    end;
                end;
            end;
        end
        else
        begin
            if features[185] <= -238.83333587646482 then
            begin
                Result := -0.016963771028456521;
            end
            else
            begin
                if features[223] <= -525.49999999999989 then
                begin
                    if features[228] <= -4334.4999999999991 then
                    begin
                        Result := 0.049333393596420756;
                    end
                    else
                    begin
                        Result := -0.0068082827610369233;
                    end;
                end
                else
                begin
                    if features[169] <= 1.5000000000000002 then
                    begin
                        Result := -0.0054261844857330767;
                    end
                    else
                    begin
                        Result := 0.027558929187348175;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_132(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -378899951.99999994 then
    begin
        Result := -0.017218150507888812;
    end
    else
    begin
        if features[166] <= -158301679.99999997 then
        begin
            if features[180] <= -4837.4999999999991 then
            begin
                if features[179] <= -4302.4999999999991 then
                begin
                    if features[186] <= -648.41665649414051 then
                    begin
                        Result := 0.0062387372512124773;
                    end
                    else
                    begin
                        Result := -0.0048385051427547177;
                    end;
                end
                else
                begin
                    Result := -0.02012382045485752;
                end;
            end
            else
            begin
                if features[186] <= -160.74999999999997 then
                begin
                    Result := -0.004880672099185311;
                end
                else
                begin
                    if features[220] <= 88.500000000000014 then
                    begin
                        Result := 0.034146738957395444;
                    end
                    else
                    begin
                        Result := 0.0;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -6428.4999999999991 then
            begin
                if features[171] <= 2.5000000000000004 then
                begin
                    if features[185] <= -166.29166412353513 then
                    begin
                        Result := 0.027801547960519587;
                    end
                    else
                    begin
                        Result := 0.0074319611336101186;
                    end;
                end
                else
                begin
                    if features[166] <= -13305157.999999998 then
                    begin
                        Result := -0.0028363689584611548;
                    end
                    else
                    begin
                        Result := 0.026763928544703032;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -4176.4999999999991 then
                begin
                    if features[147] <= -524.49999999999989 then
                    begin
                        Result := 0.012705820294280174;
                    end
                    else
                    begin
                        Result := -0.0001167854624196305;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.0070092021373681429;
                    end
                    else
                    begin
                        Result := 0.010070728906130866;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_133(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1055.4999999999998 then
    begin
        Result := -0.017621755312260932;
    end
    else
    begin
        if features[90] <= 1.5000000000000002 then
        begin
            if features[47] <= 8737.5000000000018 then
            begin
                if features[229] <= -434.49999999999994 then
                begin
                    if features[177] <= -6157.4999999999991 then
                    begin
                        Result := -0.015436524455896619;
                    end
                    else
                    begin
                        Result := 0.00035911827969293761;
                    end;
                end
                else
                begin
                    if features[218] <= -5037.4999999999991 then
                    begin
                        Result := -0.0027869484185103453;
                    end
                    else
                    begin
                        Result := 0.005335564659849786;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 3268.0000000000005 then
                begin
                    if features[221] <= -6306.4999999999991 then
                    begin
                        Result := -0.0089479449150726871;
                    end
                    else
                    begin
                        Result := 0.0013222216839324631;
                    end;
                end
                else
                begin
                    if features[229] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0025391108832682357;
                    end
                    else
                    begin
                        Result := 0.011095984071184343;
                    end;
                end;
            end;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[64] <= 1418.0000000000002 then
                begin
                    if features[176] <= -7028.4999999999991 then
                    begin
                        Result := 0.0051401219123460747;
                    end
                    else
                    begin
                        Result := 0.021124355013292545;
                    end;
                end
                else
                begin
                    Result := -0.0063140574653512823;
                end;
            end
            else
            begin
                if features[25] <= 1.0000000180025095E-35 then
                begin
                    if features[108] <= -584.49999999999989 then
                    begin
                        Result := 0.059356375525905884;
                    end
                    else
                    begin
                        Result := 0.0039952810099855808;
                    end;
                end
                else
                begin
                    Result := -0.0016170624790945946;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_134(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[225] <= -4521.4999999999991 then
        begin
            if features[215] <= -8107.4999999999991 then
            begin
                Result := 0.023502277212980604;
            end
            else
            begin
                Result := -0.021916660951729224;
            end;
        end
        else
        begin
            if features[224] <= -3631.4999999999995 then
            begin
                if features[82] <= -363.49999999999994 then
                begin
                    Result := -0.0015204140524981212;
                end
                else
                begin
                    Result := 0.086606000782704737;
                end;
            end
            else
            begin
                Result := -0.022790944956214067;
            end;
        end;
    end
    else
    begin
        if features[226] <= -1504.4999999999998 then
        begin
            if features[174] <= -8889.4999999999982 then
            begin
                Result := 0.037454623812714617;
            end
            else
            begin
                if features[180] <= -4277.4999999999991 then
                begin
                    Result := -0.022225536376534627;
                end
                else
                begin
                    Result := 0.029772562093941801;
                end;
            end;
        end
        else
        begin
            if features[226] <= 891.50000000000011 then
            begin
                if features[154] <= 19.500000000000004 then
                begin
                    if features[128] <= -127.49999999999999 then
                    begin
                        Result := -0.0018645659232428488;
                    end
                    else
                    begin
                        Result := 0.0030203320082378203;
                    end;
                end
                else
                begin
                    if features[221] <= -5953.4999999999991 then
                    begin
                        Result := -0.011445938606427564;
                    end
                    else
                    begin
                        Result := -0.00071944892770006014;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6137.4999999999991 then
                begin
                    if features[27] <= -6132.4999999999991 then
                    begin
                        Result := 0.02729806573585062;
                    end
                    else
                    begin
                        Result := -0.0063763542384802771;
                    end;
                end
                else
                begin
                    Result := 0.021409604455452515;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_135(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[180] <= -5250.4999999999991 then
        begin
            Result := -0.019813891196158312;
        end
        else
        begin
            Result := 0.016985378986035696;
        end;
    end
    else
    begin
        if features[166] <= -89999783.999999985 then
        begin
            if features[90] <= -2.4999999999999996 then
            begin
                Result := -0.019483859931042666;
            end
            else
            begin
                if features[90] <= 8.5000000000000018 then
                begin
                    if features[176] <= -7568.4999999999991 then
                    begin
                        Result := -0.0094040085756145544;
                    end
                    else
                    begin
                        Result := -9.7920158604243275E-05;
                    end;
                end
                else
                begin
                    if features[66] <= 1357.5000000000002 then
                    begin
                        Result := 0.018741950987889399;
                    end
                    else
                    begin
                        Result := -0.013576602635601807;
                    end;
                end;
            end;
        end
        else
        begin
            if features[136] <= 1.0000000180025095E-35 then
            begin
                if features[129] <= 13945.000000000002 then
                begin
                    if features[222] <= -5846.4999999999991 then
                    begin
                        Result := -0.0087373543147413035;
                    end
                    else
                    begin
                        Result := 0.0013632015639223696;
                    end;
                end
                else
                begin
                    if features[227] <= -6216.4999999999991 then
                    begin
                        Result := -0.020208704153250375;
                    end
                    else
                    begin
                        Result := 0.012667949437792238;
                    end;
                end;
            end
            else
            begin
                if features[15] <= -102908303.99999999 then
                begin
                    if features[164] <= -2016433.9999999998 then
                    begin
                        Result := -0.0013470081103226228;
                    end
                    else
                    begin
                        Result := 0.034076710702745969;
                    end;
                end
                else
                begin
                    if features[227] <= -5349.4999999999991 then
                    begin
                        Result := 0.0086491052786762303;
                    end
                    else
                    begin
                        Result := 0.0023944152072289289;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_136(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        Result := -0.017969878429737966;
    end
    else
    begin
        if features[226] <= 397.50000000000006 then
        begin
            if features[166] <= -44188333.999999993 then
            begin
                if features[154] <= 60.500000000000007 then
                begin
                    if features[128] <= -20.499999999999996 then
                    begin
                        Result := -0.0036368150329618622;
                    end
                    else
                    begin
                        Result := 0.0018601655720042326;
                    end;
                end
                else
                begin
                    if features[222] <= -4761.4999999999991 then
                    begin
                        Result := -0.0110442459319103;
                    end
                    else
                    begin
                        Result := 0.0045156001396074912;
                    end;
                end;
            end
            else
            begin
                if features[14] <= 37348750.000000007 then
                begin
                    if features[176] <= -5331.4999999999991 then
                    begin
                        Result := 0.00660674708011423;
                    end
                    else
                    begin
                        Result := -0.0029615077139312617;
                    end;
                end
                else
                begin
                    if features[158] <= 1612.5000000000002 then
                    begin
                        Result := -0.011836987951120925;
                    end
                    else
                    begin
                        Result := 0.0082450376725497748;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6109.4999999999991 then
            begin
                if features[173] <= -6062.4999999999991 then
                begin
                    if features[54] <= 1.5000000000000002 then
                    begin
                        Result := -0.01806547570935902;
                    end
                    else
                    begin
                        Result := 0.011106445107619885;
                    end;
                end
                else
                begin
                    Result := -0.010219363362603415;
                end;
            end
            else
            begin
                if features[179] <= -4862.4999999999991 then
                begin
                    Result := 0.013376039202733659;
                end
                else
                begin
                    if features[227] <= -5059.4999999999991 then
                    begin
                        Result := -0.033004403067386771;
                    end
                    else
                    begin
                        Result := 0.0045660085260254583;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_137(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1022.4999999999999 then
    begin
        if features[221] <= -4938.4999999999991 then
        begin
            if features[48] <= 1.0000000180025095E-35 then
            begin
                Result := -0.017851845026638363;
            end
            else
            begin
                if features[82] <= 111735.00000000001 then
                begin
                    if features[128] <= -263.49999999999994 then
                    begin
                        Result := -0.0068858903962756863;
                    end
                    else
                    begin
                        Result := 0.057009141456333637;
                    end;
                end
                else
                begin
                    Result := -0.018847791053967416;
                end;
            end;
        end
        else
        begin
            Result := -0.021068716616812273;
        end;
    end
    else
    begin
        if features[166] <= -93540307.999999985 then
        begin
            if features[222] <= -5548.4999999999991 then
            begin
                if features[154] <= 142.50000000000003 then
                begin
                    if features[179] <= -4403.4999999999991 then
                    begin
                        Result := -0.0028056250474771996;
                    end
                    else
                    begin
                        Result := -0.024534716769623693;
                    end;
                end
                else
                begin
                    Result := -0.01599728847658731;
                end;
            end
            else
            begin
                if features[179] <= -3580.4999999999995 then
                begin
                    if features[150] <= 1.5000000000000002 then
                    begin
                        Result := 0.0027726444973425503;
                    end
                    else
                    begin
                        Result := -0.01158159445681929;
                    end;
                end
                else
                begin
                    Result := -0.015533184366344098;
                end;
            end;
        end
        else
        begin
            if features[216] <= -6993.4999999999991 then
            begin
                Result := 0.016662497840831562;
            end
            else
            begin
                if features[226] <= 891.50000000000011 then
                begin
                    if features[96] <= -109370743.99999999 then
                    begin
                        Result := 0.020268723491538132;
                    end
                    else
                    begin
                        Result := 0.0018238764319424405;
                    end;
                end
                else
                begin
                    Result := 0.016335271159991765;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_138(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[225] <= -4521.4999999999991 then
        begin
            Result := -0.020549749537247062;
        end
        else
        begin
            Result := 0.0014484127491879407;
        end;
    end
    else
    begin
        if features[225] <= -4233.4999999999991 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[175] <= -1472.4999999999998 then
                    begin
                        Result := -0.0044732555655615366;
                    end
                    else
                    begin
                        Result := 0.028431035361590942;
                    end;
                end
                else
                begin
                    if features[174] <= -9314.4999999999982 then
                    begin
                        Result := 0.047723400124209017;
                    end
                    else
                    begin
                        Result := -0.00082038200801106288;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -1486.4999999999998 then
                begin
                    Result := -0.019946523548947104;
                end
                else
                begin
                    if features[154] <= 19.500000000000004 then
                    begin
                        Result := 0.0008451641747481679;
                    end
                    else
                    begin
                        Result := -0.004628379075399678;
                    end;
                end;
            end;
        end
        else
        begin
            if features[179] <= -3792.4999999999995 then
            begin
                if features[226] <= 203.50000000000003 then
                begin
                    if features[221] <= -5558.4999999999991 then
                    begin
                        Result := -0.013174814205262238;
                    end
                    else
                    begin
                        Result := 0.0064174194689496271;
                    end;
                end
                else
                begin
                    if features[183] <= -5145.4999999999991 then
                    begin
                        Result := 0.020865738361817439;
                    end
                    else
                    begin
                        Result := 0.0055940971607325515;
                    end;
                end;
            end
            else
            begin
                if features[175] <= -2032.4999999999998 then
                begin
                    Result := 0.031876834436174041;
                end
                else
                begin
                    Result := -0.015609233336276455;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_139(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        Result := -0.017930926601462931;
    end
    else
    begin
        if features[216] <= -4176.4999999999991 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[216] <= -5384.4999999999991 then
                begin
                    if features[118] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.012341913047790663;
                    end
                    else
                    begin
                        Result := 0.0021468173589769116;
                    end;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := -0.0036382342784752504;
                    end
                    else
                    begin
                        Result := 0.0062612485519031626;
                    end;
                end;
            end
            else
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[217] <= -230.49999999999997 then
                    begin
                        Result := 0.0028965892582465298;
                    end
                    else
                    begin
                        Result := -0.0053104545253136945;
                    end;
                end
                else
                begin
                    if features[174] <= -4045.4999999999995 then
                    begin
                        Result := -0.013550278046451834;
                    end
                    else
                    begin
                        Result := 0.018420304157469959;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[217] <= 893.50000000000011 then
                begin
                    Result := 0.0088340520220997754;
                end
                else
                begin
                    Result := -0.017402483773009129;
                end;
            end
            else
            begin
                if features[217] <= 22.500000000000004 then
                begin
                    if features[174] <= -6170.4999999999991 then
                    begin
                        Result := 0.015277363813596144;
                    end
                    else
                    begin
                        Result := -0.0073220180126899919;
                    end;
                end
                else
                begin
                    if features[0] <= 181098.00000000003 then
                    begin
                        Result := 0.010441181051276919;
                    end
                    else
                    begin
                        Result := 0.028141491091116057;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_140(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        Result := -0.017811147458425505;
    end
    else
    begin
        if features[90] <= 1.5000000000000002 then
        begin
            if features[47] <= 8737.5000000000018 then
            begin
                if features[219] <= -5129.4999999999991 then
                begin
                    if features[166] <= -129191879.99999999 then
                    begin
                        Result := -0.0087785934656367613;
                    end
                    else
                    begin
                        Result := -0.00054782608798536016;
                    end;
                end
                else
                begin
                    if features[182] <= -5226.4999999999991 then
                    begin
                        Result := 0.0094071144638454927;
                    end
                    else
                    begin
                        Result := -0.0047405893528592261;
                    end;
                end;
            end
            else
            begin
                if features[158] <= 1845.5000000000002 then
                begin
                    if features[176] <= -7541.4999999999991 then
                    begin
                        Result := -0.0095518950119664603;
                    end
                    else
                    begin
                        Result := 0.0014558000856454969;
                    end;
                end
                else
                begin
                    if features[185] <= 93.250000000000014 then
                    begin
                        Result := 0.0043872787722751784;
                    end
                    else
                    begin
                        Result := 0.016951474382760925;
                    end;
                end;
            end;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[64] <= 1401.0000000000002 then
                begin
                    if features[176] <= -6899.4999999999991 then
                    begin
                        Result := 0.006240213067957274;
                    end
                    else
                    begin
                        Result := 0.02196465790887079;
                    end;
                end
                else
                begin
                    Result := -0.0069172376410514581;
                end;
            end
            else
            begin
                if features[25] <= 1.0000000180025095E-35 then
                begin
                    if features[108] <= -584.49999999999989 then
                    begin
                        Result := 0.048659881103505567;
                    end
                    else
                    begin
                        Result := 0.0054631379409763028;
                    end;
                end
                else
                begin
                    Result := -0.0014958666777340401;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_141(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        if features[108] <= -238.49999999999997 then
        begin
            if features[187] <= 126.09999847412111 then
            begin
                Result := -0.019574391313976227;
            end
            else
            begin
                Result := 0.015932748767966857;
            end;
        end
        else
        begin
            Result := 0.031277552649313249;
        end;
    end
    else
    begin
        if features[229] <= 702.50000000000011 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[175] <= 192.50000000000003 then
                    begin
                        Result := 0.011862632662031527;
                    end
                    else
                    begin
                        Result := 0.04475040360377211;
                    end;
                end
                else
                begin
                    if features[70] <= 764.50000000000011 then
                    begin
                        Result := 0.025938734297409123;
                    end
                    else
                    begin
                        Result := -0.0055780084733473715;
                    end;
                end;
            end
            else
            begin
                if features[229] <= -640.49999999999989 then
                begin
                    if features[176] <= -5821.4999999999991 then
                    begin
                        Result := -0.014897485609654555;
                    end
                    else
                    begin
                        Result := 1.978206410076105E-05;
                    end;
                end
                else
                begin
                    if features[222] <= -6295.4999999999991 then
                    begin
                        Result := -0.0042993373937959172;
                    end
                    else
                    begin
                        Result := 0.0011886304845230287;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6137.4999999999991 then
            begin
                if features[27] <= -5942.4999999999991 then
                begin
                    Result := 0.02695684568630044;
                end
                else
                begin
                    if features[177] <= -6286.4999999999991 then
                    begin
                        Result := 0.0033395640248627678;
                    end
                    else
                    begin
                        Result := -0.023622790127610236;
                    end;
                end;
            end
            else
            begin
                Result := 0.020767567377131167;
            end;
        end;
    end;
end;

function bidirectional_tree_142(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1486.4999999999998 then
    begin
        Result := -0.021626823002401076;
    end
    else
    begin
        if features[166] <= -89999783.999999985 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[227] <= -5492.4999999999991 then
                begin
                    if features[134] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.02593365843514734;
                    end
                    else
                    begin
                        Result := -0.006746197599098995;
                    end;
                end
                else
                begin
                    if features[226] <= -117.49999999999999 then
                    begin
                        Result := -0.0034767681134154657;
                    end
                    else
                    begin
                        Result := 0.0035133155346895382;
                    end;
                end;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[66] <= 485.00000000000006 then
                    begin
                        Result := 0.019667402335393498;
                    end
                    else
                    begin
                        Result := -0.0042943046948021634;
                    end;
                end
                else
                begin
                    if features[25] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.025946620870446455;
                    end
                    else
                    begin
                        Result := -0.0062739453957117207;
                    end;
                end;
            end;
        end
        else
        begin
            if features[136] <= 1.0000000180025095E-35 then
            begin
                if features[14] <= 37348750.000000007 then
                begin
                    if features[166] <= -39740415.999999993 then
                    begin
                        Result := -0.0034527575308683171;
                    end
                    else
                    begin
                        Result := 0.0054523916661764239;
                    end;
                end
                else
                begin
                    Result := -0.011427685090353537;
                end;
            end
            else
            begin
                if features[15] <= -102908303.99999999 then
                begin
                    Result := 0.019825434819034864;
                end
                else
                begin
                    if features[216] <= -6395.4999999999991 then
                    begin
                        Result := 0.015466169448320431;
                    end
                    else
                    begin
                        Result := 0.00338988883123015;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_143(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -893.49999999999989 then
    begin
        if features[216] <= -6792.4999999999991 then
        begin
            if features[37] <= 2.5000000000000004 then
            begin
                if features[183] <= -6631.4999999999991 then
                begin
                    Result := 0.0044024430656606885;
                end
                else
                begin
                    Result := 0.089066168684258748;
                end;
            end
            else
            begin
                Result := 0.0016285014275082045;
            end;
        end
        else
        begin
            if features[90] <= 2.5000000000000004 then
            begin
                Result := -0.016046645780926037;
            end
            else
            begin
                Result := 0.014839927759383304;
            end;
        end;
    end
    else
    begin
        if features[225] <= -3627.4999999999995 then
        begin
            if features[176] <= -4845.4999999999991 then
            begin
                if features[106] <= 1.0000000180025095E-35 then
                begin
                    if features[225] <= -4997.4999999999991 then
                    begin
                        Result := 0.00071513791914061238;
                    end
                    else
                    begin
                        Result := 0.0073975641975481503;
                    end;
                end
                else
                begin
                    if features[81] <= -198.49999999999997 then
                    begin
                        Result := -0.0078129293298006969;
                    end
                    else
                    begin
                        Result := 0.0019885948063356361;
                    end;
                end;
            end
            else
            begin
                if features[181] <= -526.49999999999989 then
                begin
                    if features[170] <= 4.5000000000000009 then
                    begin
                        Result := 0.0012562202952982678;
                    end
                    else
                    begin
                        Result := -0.01412622527508001;
                    end;
                end
                else
                begin
                    if features[223] <= -634.49999999999989 then
                    begin
                        Result := 0.020048283077020314;
                    end
                    else
                    begin
                        Result := -0.00027401764852555248;
                    end;
                end;
            end;
        end
        else
        begin
            if features[165] <= 599659296.00000012 then
            begin
                Result := 0.017730058848673291;
            end
            else
            begin
                Result := -0.0032290945138404026;
            end;
        end;
    end;
end;

function bidirectional_tree_144(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[187] <= 126.09999847412111 then
        begin
            Result := -0.020569195557205794;
        end
        else
        begin
            if features[82] <= -128585.49999999999 then
            begin
                Result := -0.017289901326742529;
            end
            else
            begin
                if features[228] <= -4908.4999999999991 then
                begin
                    Result := 0.091008193133186199;
                end
                else
                begin
                    Result := -0.0080197539430093626;
                end;
            end;
        end;
    end
    else
    begin
        if features[225] <= -3627.4999999999995 then
        begin
            if features[227] <= -3240.4999999999995 then
            begin
                if features[216] <= -4176.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0012463077455248119;
                    end
                    else
                    begin
                        Result := -0.003758658055110969;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.0077621037897548139;
                    end
                    else
                    begin
                        Result := 0.0088547335272478028;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -3120.9999999999995 then
                begin
                    if features[216] <= -6897.4999999999991 then
                    begin
                        Result := 0.025206136753369243;
                    end
                    else
                    begin
                        Result := -0.017190400213028645;
                    end;
                end
                else
                begin
                    Result := 0.047203012844220134;
                end;
            end;
        end
        else
        begin
            if features[179] <= -3792.4999999999995 then
            begin
                if features[220] <= -505.49999999999994 then
                begin
                    Result := 0.037527672908333136;
                end
                else
                begin
                    if features[164] <= 229254984.00000003 then
                    begin
                        Result := 0.021006145194438126;
                    end
                    else
                    begin
                        Result := 0.0043180901493151151;
                    end;
                end;
            end
            else
            begin
                Result := -0.013192038634483722;
            end;
        end;
    end;
end;

function bidirectional_tree_145(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[225] <= -4492.4999999999991 then
        begin
            Result := -0.020858015931663067;
        end
        else
        begin
            if features[82] <= -201.49999999999997 then
            begin
                Result := -0.015903045836058501;
            end
            else
            begin
                if features[227] <= -3538.4999999999995 then
                begin
                    Result := 0.098125126002599816;
                end
                else
                begin
                    Result := -0.013763484246648756;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -1504.4999999999998 then
        begin
            if features[174] <= -9314.4999999999982 then
            begin
                Result := 0.047972673069268709;
            end
            else
            begin
                if features[222] <= -4828.4999999999991 then
                begin
                    Result := -0.023459444549386459;
                end
                else
                begin
                    if features[216] <= -5107.4999999999991 then
                    begin
                        Result := 0.042931702031931411;
                    end
                    else
                    begin
                        Result := -0.019257689452883218;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 702.50000000000011 then
            begin
                if features[216] <= -6993.4999999999991 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.019605397470041069;
                    end
                    else
                    begin
                        Result := -0.0006408224227646064;
                    end;
                end
                else
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.00052229728452123439;
                    end
                    else
                    begin
                        Result := 0.0067524292243595907;
                    end;
                end;
            end
            else
            begin
                if features[150] <= 5.5000000000000009 then
                begin
                    if features[228] <= -5309.4999999999991 then
                    begin
                        Result := 0.00050267479875125355;
                    end
                    else
                    begin
                        Result := 0.020256536853264923;
                    end;
                end
                else
                begin
                    Result := -0.011818539684085505;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_146(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        Result := -0.017848106331689508;
    end
    else
    begin
        if features[229] <= -440.49999999999994 then
        begin
            if features[47] <= 14286.000000000002 then
            begin
                if features[177] <= -5591.4999999999991 then
                begin
                    if features[174] <= -8889.4999999999982 then
                    begin
                        Result := 0.033169142179457788;
                    end
                    else
                    begin
                        Result := -0.010574847548944215;
                    end;
                end
                else
                begin
                    if features[108] <= -178.49999999999997 then
                    begin
                        Result := -0.011617924358305031;
                    end
                    else
                    begin
                        Result := 0.019153776765449632;
                    end;
                end;
            end
            else
            begin
                if features[148] <= 1339.5000000000002 then
                begin
                    if features[154] <= -433.49999999999994 then
                    begin
                        Result := 0.030214465665223712;
                    end
                    else
                    begin
                        Result := -0.003147779485484975;
                    end;
                end
                else
                begin
                    if features[184] <= -542.49999999999989 then
                    begin
                        Result := 0.081248395742776536;
                    end
                    else
                    begin
                        Result := 0.002616715093371125;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -3815.4999999999995 then
            begin
                if features[176] <= -4845.4999999999991 then
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0031935608976880327;
                    end
                    else
                    begin
                        Result := -0.0015534705296840132;
                    end;
                end
                else
                begin
                    if features[177] <= -4256.9999999999991 then
                    begin
                        Result := -0.007725196099367857;
                    end
                    else
                    begin
                        Result := 0.0070048841222926372;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -4226.4999999999991 then
                begin
                    Result := 0.02064924214513373;
                end
                else
                begin
                    Result := 0.0030186928628032649;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_147(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        Result := -0.017995883951239088;
    end
    else
    begin
        if features[229] <= -120.49999999999999 then
        begin
            if features[216] <= -6747.4999999999991 then
            begin
                if features[175] <= 304.00000000000006 then
                begin
                    if features[48] <= 10135.500000000002 then
                    begin
                        Result := -0.0050753918948425059;
                    end
                    else
                    begin
                        Result := 0.019591617362721248;
                    end;
                end
                else
                begin
                    Result := 0.030295671050398789;
                end;
            end
            else
            begin
                if features[180] <= -4674.4999999999991 then
                begin
                    if features[37] <= 4.5000000000000009 then
                    begin
                        Result := -0.00038679942764495239;
                    end
                    else
                    begin
                        Result := -0.0070360951159092761;
                    end;
                end
                else
                begin
                    if features[108] <= 89.500000000000014 then
                    begin
                        Result := 0.0051932333984066993;
                    end
                    else
                    begin
                        Result := 0.038757358807849716;
                    end;
                end;
            end;
        end
        else
        begin
            if features[176] <= -4845.4999999999991 then
            begin
                if features[215] <= -5467.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0022968891627323106;
                    end
                    else
                    begin
                        Result := -0.0068590397076137444;
                    end;
                end
                else
                begin
                    if features[175] <= 507.50000000000006 then
                    begin
                        Result := 0.0074077508747047889;
                    end
                    else
                    begin
                        Result := -0.0005102388129800987;
                    end;
                end;
            end
            else
            begin
                if features[185] <= -113.41666793823241 then
                begin
                    if features[220] <= -5.4999999999999991 then
                    begin
                        Result := -0.0020824614769108774;
                    end
                    else
                    begin
                        Result := -0.0176938858603106;
                    end;
                end
                else
                begin
                    Result := 0.0062548659441119467;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_148(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1486.4999999999998 then
    begin
        Result := -0.01891230832801799;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[176] <= -7434.4999999999991 then
            begin
                if features[216] <= -4859.4999999999991 then
                begin
                    if features[166] <= -29654539.999999996 then
                    begin
                        Result := -0.011678012942580232;
                    end
                    else
                    begin
                        Result := 0.0037746722830612743;
                    end;
                end
                else
                begin
                    if features[229] <= -125.49999999999999 then
                    begin
                        Result := -0.0098137757385842565;
                    end
                    else
                    begin
                        Result := 0.0099185749539170472;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -242340727.99999997 then
                begin
                    if features[174] <= -3120.9999999999995 then
                    begin
                        Result := -0.0061121469686961274;
                    end
                    else
                    begin
                        Result := 0.054390596938067574;
                    end;
                end
                else
                begin
                    if features[220] <= 475.50000000000006 then
                    begin
                        Result := 0.0022498359109484885;
                    end
                    else
                    begin
                        Result := -0.0058319231264313326;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6109.4999999999991 then
            begin
                if features[173] <= -5904.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.015554559206244946;
                    end
                    else
                    begin
                        Result := -0.0077533793675937787;
                    end;
                end
                else
                begin
                    Result := -0.0099749480392129705;
                end;
            end
            else
            begin
                if features[46] <= 10.500000000000002 then
                begin
                    if features[223] <= 228.50000000000003 then
                    begin
                        Result := 0.0258799388919599;
                    end
                    else
                    begin
                        Result := 0.0028503525161617752;
                    end;
                end
                else
                begin
                    Result := 0.019121402917426429;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_149(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1055.4999999999998 then
    begin
        if features[218] <= -7244.4999999999991 then
        begin
            Result := 0.062722082007007698;
        end
        else
        begin
            if features[180] <= -4377.4999999999991 then
            begin
                Result := -0.01905978880379143;
            end
            else
            begin
                Result := 0.02865027337153625;
            end;
        end;
    end
    else
    begin
        if features[225] <= -4233.4999999999991 then
        begin
            if features[166] <= -110262351.99999999 then
            begin
                if features[90] <= -2.4999999999999996 then
                begin
                    Result := -0.022499677641337847;
                end
                else
                begin
                    if features[222] <= -6259.4999999999991 then
                    begin
                        Result := -0.0082343066326525105;
                    end
                    else
                    begin
                        Result := -0.00030401238438072879;
                    end;
                end;
            end
            else
            begin
                if features[85] <= 1.0000000180025095E-35 then
                begin
                    if features[216] <= -8105.9999999999991 then
                    begin
                        Result := 0.029338080261310264;
                    end
                    else
                    begin
                        Result := 0.0022471354647380449;
                    end;
                end
                else
                begin
                    if features[151] <= 42.500000000000007 then
                    begin
                        Result := 0.0032021255413186116;
                    end
                    else
                    begin
                        Result := -0.013386623158874761;
                    end;
                end;
            end;
        end
        else
        begin
            if features[27] <= -3918.4999999999995 then
            begin
                if features[229] <= 456.50000000000006 then
                begin
                    if features[220] <= -1219.4999999999998 then
                    begin
                        Result := 0.040770079984010769;
                    end
                    else
                    begin
                        Result := 0.0057750678614715461;
                    end;
                end
                else
                begin
                    Result := 0.022039660315182803;
                end;
            end
            else
            begin
                if features[220] <= -257.49999999999994 then
                begin
                    Result := 0.0090180293847804873;
                end
                else
                begin
                    Result := -0.0038895085141194604;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_150(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1468.4999999999998 then
    begin
        if features[174] <= -9314.4999999999982 then
        begin
            Result := 0.031068875339814651;
        end
        else
        begin
            Result := -0.019728456555666119;
        end;
    end
    else
    begin
        if features[179] <= -3792.4999999999995 then
        begin
            if features[222] <= -4486.4999999999991 then
            begin
                if features[180] <= -4882.4999999999991 then
                begin
                    if features[187] <= -15.585714340209959 then
                    begin
                        Result := -0.0045559707242414302;
                    end
                    else
                    begin
                        Result := 0.00085414660005278444;
                    end;
                end
                else
                begin
                    if features[108] <= 96.500000000000014 then
                    begin
                        Result := 0.004925911339855143;
                    end
                    else
                    begin
                        Result := 0.030944449370520641;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -6137.4999999999991 then
                begin
                    if features[174] <= -5522.4999999999991 then
                    begin
                        Result := 0.029779805543221377;
                    end
                    else
                    begin
                        Result := 0.0059734746762516028;
                    end;
                end
                else
                begin
                    if features[219] <= -6277.4999999999991 then
                    begin
                        Result := 0.013243135498259215;
                    end
                    else
                    begin
                        Result := 0.0012244482340211299;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -4201.4999999999991 then
            begin
                if features[109] <= -35.499999999999993 then
                begin
                    Result := -0.020590158717583722;
                end
                else
                begin
                    Result := 0.015591153244991638;
                end;
            end
            else
            begin
                if features[217] <= -823.49999999999989 then
                begin
                    Result := -0.020534256595635205;
                end
                else
                begin
                    if features[164] <= 421729984.00000006 then
                    begin
                        Result := 0.031097683610583623;
                    end
                    else
                    begin
                        Result := -0.00592991082070949;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_151(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1055.4999999999998 then
    begin
        if features[216] <= -6792.4999999999991 then
        begin
            if features[37] <= 2.5000000000000004 then
            begin
                Result := 0.051830563858950462;
            end
            else
            begin
                Result := -0.0085607915305819949;
            end;
        end
        else
        begin
            Result := -0.01977622178788354;
        end;
    end
    else
    begin
        if features[229] <= 702.50000000000011 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[175] <= -2121.4999999999995 then
                    begin
                        Result := -0.018441341747037928;
                    end
                    else
                    begin
                        Result := 0.027028320509357873;
                    end;
                end
                else
                begin
                    if features[105] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.015988884266510194;
                    end
                    else
                    begin
                        Result := -0.0073241933358967172;
                    end;
                end;
            end
            else
            begin
                if features[181] <= -1941.4999999999998 then
                begin
                    if features[179] <= -5990.4999999999991 then
                    begin
                        Result := 0.019025447000277543;
                    end
                    else
                    begin
                        Result := -0.015052977839857956;
                    end;
                end
                else
                begin
                    if features[108] <= -1347.4999999999998 then
                    begin
                        Result := 0.029700901513278335;
                    end
                    else
                    begin
                        Result := -0.00020110885475553214;
                    end;
                end;
            end;
        end
        else
        begin
            if features[176] <= -4906.4999999999991 then
            begin
                if features[218] <= -7760.4999999999991 then
                begin
                    Result := -0.0080377013648218528;
                end
                else
                begin
                    Result := 0.019385467598860687;
                end;
            end
            else
            begin
                if features[109] <= -217.49999999999997 then
                begin
                    Result := -0.037866744460623047;
                end
                else
                begin
                    Result := 0.013773564750728988;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_152(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        if features[187] <= 126.09999847412111 then
        begin
            if features[81] <= 29415.000000000004 then
            begin
                Result := -0.019650906208702565;
            end
            else
            begin
                if features[166] <= -433273583.99999994 then
                begin
                    Result := -0.019336757685217754;
                end
                else
                begin
                    Result := 0.059000897430560729;
                end;
            end;
        end
        else
        begin
            if features[82] <= -128585.49999999999 then
            begin
                Result := -0.017553262264561598;
            end
            else
            begin
                if features[228] <= -4908.4999999999991 then
                begin
                    Result := 0.086592200559459431;
                end
                else
                begin
                    Result := -0.0084639654462821453;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= 787.50000000000011 then
        begin
            if features[216] <= -7164.9999999999991 then
            begin
                if features[150] <= -17.499999999999996 then
                begin
                    Result := 0.036763390032506491;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.015570193671747362;
                    end
                    else
                    begin
                        Result := -0.0018712594123199127;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -185915207.99999997 then
                begin
                    if features[94] <= -230886.49999999997 then
                    begin
                        Result := 0.021468975728182717;
                    end
                    else
                    begin
                        Result := -0.0043174975820315055;
                    end;
                end
                else
                begin
                    if features[170] <= 4.5000000000000009 then
                    begin
                        Result := 0.0025850460481488813;
                    end
                    else
                    begin
                        Result := -0.0010935302654574252;
                    end;
                end;
            end;
        end
        else
        begin
            if features[150] <= 5.5000000000000009 then
            begin
                Result := 0.018352296224208291;
            end
            else
            begin
                Result := -0.0090598130164067526;
            end;
        end;
    end;
end;

function bidirectional_tree_153(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1486.4999999999998 then
    begin
        if features[174] <= -9314.4999999999982 then
        begin
            Result := 0.027904305338288256;
        end
        else
        begin
            if features[180] <= -4277.4999999999991 then
            begin
                Result := -0.020872890821106702;
            end
            else
            begin
                Result := 0.026809497411306851;
            end;
        end;
    end
    else
    begin
        if features[225] <= -3627.4999999999995 then
        begin
            if features[166] <= -263177239.99999997 then
            begin
                if features[174] <= -3120.9999999999995 then
                begin
                    if features[216] <= -5436.4999999999991 then
                    begin
                        Result := 0.00073006614338432137;
                    end
                    else
                    begin
                        Result := -0.010327037663401336;
                    end;
                end
                else
                begin
                    Result := 0.065264127326328317;
                end;
            end
            else
            begin
                if features[216] <= -4382.4999999999991 then
                begin
                    if features[176] <= -7459.4999999999991 then
                    begin
                        Result := -0.0047964317275590307;
                    end
                    else
                    begin
                        Result := 0.0010024772719056513;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.0069183857728554749;
                    end
                    else
                    begin
                        Result := 0.0080389801470389065;
                    end;
                end;
            end;
        end
        else
        begin
            if features[27] <= -4237.4999999999991 then
            begin
                Result := 0.02390390420604388;
            end
            else
            begin
                if features[220] <= -390.49999999999994 then
                begin
                    if features[129] <= -5413.4999999999991 then
                    begin
                        Result := -0.0054448419825925999;
                    end
                    else
                    begin
                        Result := 0.036759346438214179;
                    end;
                end
                else
                begin
                    if features[224] <= -3756.4999999999995 then
                    begin
                        Result := 0.011921778428728382;
                    end
                    else
                    begin
                        Result := -0.0094352720126537355;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_154(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        Result := -0.016074653574555672;
    end
    else
    begin
        if features[147] <= -524.49999999999989 then
        begin
            if features[144] <= 1935.5000000000002 then
            begin
                if features[171] <= 6.5000000000000009 then
                begin
                    if features[165] <= 137520696.00000003 then
                    begin
                        Result := 0.027933663562346795;
                    end
                    else
                    begin
                        Result := 0.0099634488506730439;
                    end;
                end
                else
                begin
                    if features[158] <= 16812.500000000004 then
                    begin
                        Result := 0.010075083597061617;
                    end
                    else
                    begin
                        Result := -0.03004690714959787;
                    end;
                end;
            end
            else
            begin
                if features[108] <= 4.5000000000000009 then
                begin
                    Result := -0.021819710963573883;
                end
                else
                begin
                    Result := 0.0068538668112851156;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4486.4999999999991 then
            begin
                if features[180] <= -4882.4999999999991 then
                begin
                    if features[166] <= -15719408.499999998 then
                    begin
                        Result := -0.0020569122987468009;
                    end
                    else
                    begin
                        Result := 0.0050693938776225668;
                    end;
                end
                else
                begin
                    if features[108] <= -512.49999999999989 then
                    begin
                        Result := -0.026615285234406767;
                    end
                    else
                    begin
                        Result := 0.016258745101534258;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -6323.4999999999991 then
                begin
                    if features[222] <= -4201.4999999999991 then
                    begin
                        Result := 0.0060688941006106709;
                    end
                    else
                    begin
                        Result := 0.024438248711637269;
                    end;
                end
                else
                begin
                    if features[171] <= 2.5000000000000004 then
                    begin
                        Result := -0.0031415767576329491;
                    end
                    else
                    begin
                        Result := 0.0062938866229182312;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_155(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1504.4999999999998 then
    begin
        Result := -0.018405204405881444;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[173] <= -4215.4999999999991 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[173] <= -4993.4999999999991 then
                    begin
                        Result := -0.0013533951981597695;
                    end
                    else
                    begin
                        Result := 0.0054709641100482388;
                    end;
                end
                else
                begin
                    if features[175] <= -912.49999999999989 then
                    begin
                        Result := -0.00066897753119610865;
                    end
                    else
                    begin
                        Result := 0.011215407787216213;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -5111.4999999999991 then
                begin
                    if features[174] <= -5859.4999999999991 then
                    begin
                        Result := -0.011497499155832354;
                    end
                    else
                    begin
                        Result := 0.0078973215102440316;
                    end;
                end
                else
                begin
                    if features[175] <= -621.49999999999989 then
                    begin
                        Result := -0.01117696633913318;
                    end
                    else
                    begin
                        Result := 0.0010813567917398049;
                    end;
                end;
            end;
        end
        else
        begin
            if features[81] <= -1.0000000180025095E-35 then
            begin
                if features[183] <= -4704.4999999999991 then
                begin
                    Result := -0.010235874558374996;
                end
                else
                begin
                    if features[185] <= -64.874999999999986 then
                    begin
                        Result := -0.011621255350014065;
                    end
                    else
                    begin
                        Result := 0.02695794821810904;
                    end;
                end;
            end
            else
            begin
                if features[148] <= 196.50000000000003 then
                begin
                    if features[91] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.002189570766708236;
                    end
                    else
                    begin
                        Result := -0.007023176499623484;
                    end;
                end
                else
                begin
                    Result := 0.017126000404755381;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_156(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -397343039.99999994 then
    begin
        Result := -0.014722658746093235;
    end
    else
    begin
        if features[226] <= 397.50000000000006 then
        begin
            if features[179] <= -3657.4999999999995 then
            begin
                if features[180] <= -4960.4999999999991 then
                begin
                    if features[148] <= -1168.4999999999998 then
                    begin
                        Result := -0.0043374637294028521;
                    end
                    else
                    begin
                        Result := 0.00033484751144122427;
                    end;
                end
                else
                begin
                    if features[220] <= 391.50000000000006 then
                    begin
                        Result := 0.01262678772231051;
                    end
                    else
                    begin
                        Result := -0.012828281269491957;
                    end;
                end;
            end
            else
            begin
                if features[82] <= -156369.49999999997 then
                begin
                    if features[166] <= -209009079.99999997 then
                    begin
                        Result := -0.021481328137039041;
                    end
                    else
                    begin
                        Result := 0.031109853264407607;
                    end;
                end
                else
                begin
                    Result := -0.018631771878294599;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6273.4999999999991 then
            begin
                if features[55] <= 1.5000000000000002 then
                begin
                    if features[164] <= -144727127.99999997 then
                    begin
                        Result := 0.004297018710807632;
                    end
                    else
                    begin
                        Result := -0.024725874606391959;
                    end;
                end
                else
                begin
                    Result := 0.0032115474531040689;
                end;
            end
            else
            begin
                if features[179] <= -5054.4999999999991 then
                begin
                    if features[217] <= -698.99999999999989 then
                    begin
                        Result := 0.022944546440082359;
                    end
                    else
                    begin
                        Result := 0.009903990457485282;
                    end;
                end
                else
                begin
                    if features[223] <= 452.50000000000006 then
                    begin
                        Result := 0.019909260284993555;
                    end
                    else
                    begin
                        Result := -0.013858500516949673;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_157(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1344.4999999999998 then
    begin
        if features[227] <= -5786.4999999999991 then
        begin
            Result := 0.028997261915954683;
        end
        else
        begin
            Result := -0.021904625692345372;
        end;
    end
    else
    begin
        if features[135] <= 8.5000000000000018 then
        begin
            if features[47] <= 8600.5000000000018 then
            begin
                if features[229] <= -434.49999999999994 then
                begin
                    if features[177] <= -6000.4999999999991 then
                    begin
                        Result := -0.011703597591029206;
                    end
                    else
                    begin
                        Result := 0.0026077930465162086;
                    end;
                end
                else
                begin
                    if features[218] <= -5037.4999999999991 then
                    begin
                        Result := -0.0025563758247278447;
                    end
                    else
                    begin
                        Result := 0.004600159552206203;
                    end;
                end;
            end
            else
            begin
                if features[158] <= 1845.5000000000002 then
                begin
                    if features[148] <= -1109.4999999999998 then
                    begin
                        Result := -0.0040758533121517211;
                    end
                    else
                    begin
                        Result := 0.002315646222699576;
                    end;
                end
                else
                begin
                    if features[229] <= -21.499999999999996 then
                    begin
                        Result := 0.0021183414774692088;
                    end
                    else
                    begin
                        Result := 0.010365730226145684;
                    end;
                end;
            end;
        end
        else
        begin
            if features[156] <= -1.0000000180025095E-35 then
            begin
                Result := 0.025948554613319713;
            end
            else
            begin
                if features[225] <= -5366.4999999999991 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := -0.016054092119283256;
                    end
                    else
                    begin
                        Result := 0.0081887356605082184;
                    end;
                end
                else
                begin
                    if features[228] <= -5045.4999999999991 then
                    begin
                        Result := 0.025660791843291481;
                    end
                    else
                    begin
                        Result := 0.0054938480326555154;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_158(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1344.4999999999998 then
    begin
        Result := -0.02269579693398683;
    end
    else
    begin
        if features[179] <= -3657.4999999999995 then
        begin
            if features[222] <= -4647.4999999999991 then
            begin
                if features[117] <= -290.49999999999994 then
                begin
                    if features[148] <= -1087.4999999999998 then
                    begin
                        Result := -0.0081746042397679939;
                    end
                    else
                    begin
                        Result := 0.003077154409136874;
                    end;
                end
                else
                begin
                    if features[81] <= -1131.4999999999998 then
                    begin
                        Result := -0.0022048420493996387;
                    end
                    else
                    begin
                        Result := 0.0022080545936242128;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -307.49999999999994 then
                begin
                    if features[215] <= -5916.4999999999991 then
                    begin
                        Result := 0.030805770930203109;
                    end
                    else
                    begin
                        Result := -0.0045494534966730405;
                    end;
                end
                else
                begin
                    if features[220] <= -13.499999999999998 then
                    begin
                        Result := 0.011787111730874529;
                    end
                    else
                    begin
                        Result := 0.0031818699507694865;
                    end;
                end;
            end;
        end
        else
        begin
            if features[106] <= 1.5000000000000002 then
            begin
                if features[225] <= -3087.9999999999995 then
                begin
                    if features[121] <= 1462.5000000000002 then
                    begin
                        Result := -0.021181748843674686;
                    end
                    else
                    begin
                        Result := 0.019220719058985161;
                    end;
                end
                else
                begin
                    Result := 0.012847599928753436;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.015989107225827266;
                end
                else
                begin
                    if features[227] <= -3259.4999999999995 then
                    begin
                        Result := 0.036509104719750669;
                    end
                    else
                    begin
                        Result := -0.01628167140283272;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_159(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        Result := -0.016430117465270771;
    end
    else
    begin
        if features[216] <= -7297.4999999999991 then
        begin
            if features[182] <= -6282.4999999999991 then
            begin
                if features[224] <= -5326.4999999999991 then
                begin
                    if features[180] <= -8789.4999999999982 then
                    begin
                        Result := 0.041596874111101037;
                    end
                    else
                    begin
                        Result := 0.0011671037615459381;
                    end;
                end
                else
                begin
                    Result := -0.021833818832090013;
                end;
            end
            else
            begin
                if features[81] <= -8575.4999999999982 then
                begin
                    Result := -0.0075924862977516487;
                end
                else
                begin
                    if features[217] <= -2711.4999999999995 then
                    begin
                        Result := 0.042841519472296072;
                    end
                    else
                    begin
                        Result := 0.015176460004776966;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= -453.49999999999994 then
            begin
                if features[174] <= -3120.9999999999995 then
                begin
                    if features[176] <= -5756.4999999999991 then
                    begin
                        Result := -0.010656179100562269;
                    end
                    else
                    begin
                        Result := 0.00051205554518439749;
                    end;
                end
                else
                begin
                    if features[105] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.072840158789614168;
                    end
                    else
                    begin
                        Result := 0.0;
                    end;
                end;
            end
            else
            begin
                if features[179] <= -3792.4999999999995 then
                begin
                    if features[218] <= -4444.4999999999991 then
                    begin
                        Result := 7.9581632992813611E-05;
                    end
                    else
                    begin
                        Result := 0.0071495790536416446;
                    end;
                end
                else
                begin
                    if features[185] <= -229.41666412353513 then
                    begin
                        Result := -0.02376164376433168;
                    end
                    else
                    begin
                        Result := 0.0014452396908804955;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_160(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[225] <= -4521.4999999999991 then
        begin
            if features[187] <= 126.09999847412111 then
            begin
                Result := -0.021786054171572075;
            end
            else
            begin
                Result := 0.031162038972949738;
            end;
        end
        else
        begin
            if features[224] <= -3631.4999999999995 then
            begin
                if features[82] <= -201.49999999999997 then
                begin
                    Result := 0.0028465846716841524;
                end
                else
                begin
                    Result := 0.09211812487362786;
                end;
            end
            else
            begin
                Result := -0.021778971868162952;
            end;
        end;
    end
    else
    begin
        if features[225] <= -3699.4999999999995 then
        begin
            if features[224] <= -3437.4999999999995 then
            begin
                if features[90] <= 8.5000000000000018 then
                begin
                    if features[81] <= -1131.4999999999998 then
                    begin
                        Result := -0.0034841978435897719;
                    end
                    else
                    begin
                        Result := 0.0011671176198100809;
                    end;
                end
                else
                begin
                    if features[159] <= 48.500000000000007 then
                    begin
                        Result := 0.020460647676295893;
                    end
                    else
                    begin
                        Result := 0.00043178574992126795;
                    end;
                end;
            end
            else
            begin
                if features[145] <= -554.99999999999989 then
                begin
                    Result := 0.053749334707531932;
                end
                else
                begin
                    if features[217] <= -3514.4999999999995 then
                    begin
                        Result := 0.038296311568139611;
                    end
                    else
                    begin
                        Result := -0.019209793327537562;
                    end;
                end;
            end;
        end
        else
        begin
            if features[183] <= -4869.4999999999991 then
            begin
                Result := 0.01952480631966845;
            end
            else
            begin
                if features[186] <= -133.83333587646482 then
                begin
                    Result := -0.0081639934548805651;
                end
                else
                begin
                    Result := 0.009836153177317444;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_161(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        Result := -0.016160733498835306;
    end
    else
    begin
        if features[154] <= 19.500000000000004 then
        begin
            if features[108] <= -1327.4999999999998 then
            begin
                if features[173] <= -6208.4999999999991 then
                begin
                    if features[154] <= -104.49999999999999 then
                    begin
                        Result := 0.092945567920384622;
                    end
                    else
                    begin
                        Result := 0.007172381575209043;
                    end;
                end
                else
                begin
                    if features[216] <= -5229.4999999999991 then
                    begin
                        Result := 0.023776945759132438;
                    end
                    else
                    begin
                        Result := -0.012623151730851432;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 226.50000000000003 then
                begin
                    if features[176] <= -7434.4999999999991 then
                    begin
                        Result := -0.0050048966151986975;
                    end
                    else
                    begin
                        Result := 0.00091777942411270543;
                    end;
                end
                else
                begin
                    if features[220] <= 431.50000000000006 then
                    begin
                        Result := 0.013629801193026503;
                    end
                    else
                    begin
                        Result := 0.0023639239735299173;
                    end;
                end;
            end;
        end
        else
        begin
            if features[221] <= -5953.4999999999991 then
            begin
                if features[166] <= -112029371.99999999 then
                begin
                    Result := -0.023690586788957736;
                end
                else
                begin
                    Result := -0.0076081002141933172;
                end;
            end
            else
            begin
                if features[229] <= -293.49999999999994 then
                begin
                    if features[227] <= -5071.4999999999991 then
                    begin
                        Result := 0.0054000814421719112;
                    end
                    else
                    begin
                        Result := -0.01160867696315657;
                    end;
                end
                else
                begin
                    if features[221] <= -4089.4999999999995 then
                    begin
                        Result := -1.4902195397766995E-05;
                    end
                    else
                    begin
                        Result := 0.01901890257917736;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_162(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        Result := -0.019160985524552539;
    end
    else
    begin
        if features[216] <= -4176.4999999999991 then
        begin
            if features[154] <= 19.500000000000004 then
            begin
                if features[166] <= -29654539.999999996 then
                begin
                    if features[176] <= -7595.4999999999991 then
                    begin
                        Result := -0.0068255011458208384;
                    end
                    else
                    begin
                        Result := 0.0008578377966422337;
                    end;
                end
                else
                begin
                    if features[183] <= -6438.4999999999991 then
                    begin
                        Result := 0.011703597043729721;
                    end
                    else
                    begin
                        Result := 0.0022871505819856363;
                    end;
                end;
            end
            else
            begin
                if features[148] <= -896.49999999999989 then
                begin
                    if features[225] <= -5374.4999999999991 then
                    begin
                        Result := -0.017381343091950736;
                    end
                    else
                    begin
                        Result := -0.0055248835560127814;
                    end;
                end
                else
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.0048292334987213009;
                    end
                    else
                    begin
                        Result := -0.0054579636535011938;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[215] <= -3833.4999999999995 then
                begin
                    Result := -0.01161425352886436;
                end
                else
                begin
                    Result := 0.0194098746850998;
                end;
            end
            else
            begin
                if features[174] <= -5146.4999999999991 then
                begin
                    if features[227] <= -3219.4999999999995 then
                    begin
                        Result := 0.016851103638176112;
                    end
                    else
                    begin
                        Result := -0.016947897241440826;
                    end;
                end
                else
                begin
                    if features[174] <= -4315.4999999999991 then
                    begin
                        Result := -0.0041467458892250619;
                    end
                    else
                    begin
                        Result := 0.014784895653901628;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_163(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1344.4999999999998 then
    begin
        Result := -0.01999015559623666;
    end
    else
    begin
        if features[216] <= -7164.9999999999991 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[221] <= -5016.4999999999991 then
                begin
                    if features[180] <= -7546.4999999999991 then
                    begin
                        Result := -0.0092395435887077087;
                    end
                    else
                    begin
                        Result := 0.021830602605149504;
                    end;
                end
                else
                begin
                    Result := 0.048855661519828827;
                end;
            end
            else
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    if features[222] <= -6958.4999999999991 then
                    begin
                        Result := 0.053519110936814024;
                    end
                    else
                    begin
                        Result := -0.0008726835594905282;
                    end;
                end
                else
                begin
                    if features[175] <= -1295.4999999999998 then
                    begin
                        Result := 0.0078422420706541103;
                    end
                    else
                    begin
                        Result := -0.020165412693359502;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= -640.49999999999989 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[173] <= -5527.4999999999991 then
                    begin
                        Result := 0.011456671054246517;
                    end
                    else
                    begin
                        Result := -0.0077102465626003791;
                    end;
                end
                else
                begin
                    Result := -0.015498542223265742;
                end;
            end
            else
            begin
                if features[216] <= -4176.4999999999991 then
                begin
                    if features[176] <= -7682.4999999999991 then
                    begin
                        Result := -0.0059461558658317005;
                    end
                    else
                    begin
                        Result := 0.00037694281890147165;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.0066760705333093438;
                    end
                    else
                    begin
                        Result := 0.0079082371288330452;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_164(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1468.4999999999998 then
    begin
        Result := -0.016699749082921333;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[216] <= -6993.4999999999991 then
            begin
                if features[105] <= -1.0000000180025095E-35 then
                begin
                    if features[175] <= -318.49999999999994 then
                    begin
                        Result := 0.0072104369538239788;
                    end
                    else
                    begin
                        Result := 0.046892711691514835;
                    end;
                end
                else
                begin
                    if features[69] <= 16.500000000000004 then
                    begin
                        Result := -0.00012997328386172801;
                    end
                    else
                    begin
                        Result := 0.02237024682205372;
                    end;
                end;
            end
            else
            begin
                if features[187] <= -20.535714149475094 then
                begin
                    if features[183] <= -5812.4999999999991 then
                    begin
                        Result := -0.0070917117240578489;
                    end
                    else
                    begin
                        Result := 0.0015609081197895047;
                    end;
                end
                else
                begin
                    if features[108] <= -1311.4999999999998 then
                    begin
                        Result := 0.016470702964278369;
                    end
                    else
                    begin
                        Result := 0.00014951419602428635;
                    end;
                end;
            end;
        end
        else
        begin
            if features[217] <= 184.50000000000003 then
            begin
                if features[226] <= 373.50000000000006 then
                begin
                    Result := -0.01468000282246258;
                end
                else
                begin
                    Result := 0.014064500729275772;
                end;
            end
            else
            begin
                if features[27] <= -6033.4999999999991 then
                begin
                    if features[107] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.012812100968551491;
                    end
                    else
                    begin
                        Result := 0.019183248657380973;
                    end;
                end
                else
                begin
                    if features[225] <= -4293.4999999999991 then
                    begin
                        Result := -0.0053581188975787026;
                    end
                    else
                    begin
                        Result := 0.011319349223214911;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_165(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1504.4999999999998 then
    begin
        if features[224] <= -6701.4999999999991 then
        begin
            Result := 0.053977012373576397;
        end
        else
        begin
            if features[222] <= -4731.4999999999991 then
            begin
                Result := -0.021855425491017308;
            end
            else
            begin
                if features[216] <= -5207.4999999999991 then
                begin
                    Result := 0.039157651020688848;
                end
                else
                begin
                    Result := -0.0185404399412759;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= 787.50000000000011 then
        begin
            if features[216] <= -6428.4999999999991 then
            begin
                if features[174] <= -6384.4999999999991 then
                begin
                    if features[180] <= -8875.4999999999982 then
                    begin
                        Result := 0.03311535529385342;
                    end
                    else
                    begin
                        Result := -0.003932980102639004;
                    end;
                end
                else
                begin
                    if features[109] <= -645.49999999999989 then
                    begin
                        Result := 0.032531347586790958;
                    end
                    else
                    begin
                        Result := 0.010688527284261798;
                    end;
                end;
            end
            else
            begin
                if features[217] <= -1186.4999999999998 then
                begin
                    if features[176] <= -7717.4999999999991 then
                    begin
                        Result := -0.023136277745889354;
                    end
                    else
                    begin
                        Result := -0.0040362868356676419;
                    end;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0048979525243523329;
                    end
                    else
                    begin
                        Result := 0.001501861310777432;
                    end;
                end;
            end;
        end
        else
        begin
            if features[175] <= 1997.0000000000002 then
            begin
                if features[10] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.019772259421841902;
                end
                else
                begin
                    Result := -0.0019589112995401095;
                end;
            end
            else
            begin
                Result := -0.011999984637741219;
            end;
        end;
    end;
end;

function bidirectional_tree_166(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -403654255.99999994 then
    begin
        if features[14] <= 98871568.000000015 then
        begin
            Result := -0.018565852433496913;
        end
        else
        begin
            if features[77] <= 3062.5000000000005 then
            begin
                Result := 0.047442138438950968;
            end
            else
            begin
                Result := -0.0094114845486348991;
            end;
        end;
    end
    else
    begin
        if features[90] <= 1.5000000000000002 then
        begin
            if features[47] <= 8737.5000000000018 then
            begin
                if features[229] <= -434.49999999999994 then
                begin
                    if features[217] <= 2185.0000000000005 then
                    begin
                        Result := -0.011393924534408809;
                    end
                    else
                    begin
                        Result := 0.053243482323158453;
                    end;
                end
                else
                begin
                    if features[13] <= -70432.999999999985 then
                    begin
                        Result := 0.01425534941859119;
                    end
                    else
                    begin
                        Result := -0.0020331307613240955;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 3268.0000000000005 then
                begin
                    if features[148] <= -1118.4999999999998 then
                    begin
                        Result := -0.005159873381345919;
                    end
                    else
                    begin
                        Result := 0.0021297090502759939;
                    end;
                end
                else
                begin
                    if features[226] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0013292365825413057;
                    end
                    else
                    begin
                        Result := 0.010744291895597098;
                    end;
                end;
            end;
        end
        else
        begin
            if features[178] <= -1696.4999999999998 then
            begin
                Result := -0.022423458258131204;
            end
            else
            begin
                if features[64] <= 1418.0000000000002 then
                begin
                    if features[215] <= -4550.9999999999991 then
                    begin
                        Result := 0.013523818157387867;
                    end
                    else
                    begin
                        Result := 2.4568876366669242E-05;
                    end;
                end
                else
                begin
                    Result := -0.0084357982660291323;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_167(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[225] <= -4521.4999999999991 then
        begin
            Result := -0.019749872201592279;
        end
        else
        begin
            if features[224] <= -3631.4999999999995 then
            begin
                if features[82] <= -201.49999999999997 then
                begin
                    Result := 0.0042402293967164842;
                end
                else
                begin
                    Result := 0.096645259358106347;
                end;
            end
            else
            begin
                Result := -0.021551589993309233;
            end;
        end;
    end
    else
    begin
        if features[90] <= 8.5000000000000018 then
        begin
            if features[225] <= -3627.4999999999995 then
            begin
                if features[128] <= -342.49999999999994 then
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.00083225041368674164;
                    end
                    else
                    begin
                        Result := -0.0079251251206047656;
                    end;
                end
                else
                begin
                    if features[154] <= 19.500000000000004 then
                    begin
                        Result := 0.0022039157442769112;
                    end
                    else
                    begin
                        Result := -0.0031685023886160995;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -4250.4999999999991 then
                begin
                    Result := 0.022283171437685864;
                end
                else
                begin
                    if features[220] <= -382.49999999999994 then
                    begin
                        Result := 0.021049501939112505;
                    end
                    else
                    begin
                        Result := -0.0028025240153593733;
                    end;
                end;
            end;
        end
        else
        begin
            if features[151] <= -83.499999999999986 then
            begin
                Result := 0.022353898378215303;
            end
            else
            begin
                if features[47] <= 4012.5000000000005 then
                begin
                    Result := 0.019998028779450602;
                end
                else
                begin
                    if features[25] <= 2.5000000000000004 then
                    begin
                        Result := 0.0065730179039424604;
                    end
                    else
                    begin
                        Result := -0.014803742212447372;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_168(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        Result := -0.018573582169058748;
    end
    else
    begin
        if features[216] <= -6993.4999999999991 then
        begin
            if features[182] <= -6414.4999999999991 then
            begin
                if features[77] <= 2225.0000000000005 then
                begin
                    if features[176] <= -6330.4999999999991 then
                    begin
                        Result := -0.023576235363274717;
                    end
                    else
                    begin
                        Result := 0.015456911100277755;
                    end;
                end
                else
                begin
                    if features[107] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0055214703985623694;
                    end
                    else
                    begin
                        Result := 0.040699847949681685;
                    end;
                end;
            end
            else
            begin
                if features[72] <= 737.50000000000011 then
                begin
                    Result := 0.048667765959688802;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.021711631932658557;
                    end
                    else
                    begin
                        Result := -0.001312148830330262;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= 635.50000000000011 then
            begin
                if features[218] <= -4444.4999999999991 then
                begin
                    if features[176] <= -4783.4999999999991 then
                    begin
                        Result := -0.00032795794047528931;
                    end
                    else
                    begin
                        Result := -0.0088104976872818708;
                    end;
                end
                else
                begin
                    if features[176] <= -6433.4999999999991 then
                    begin
                        Result := -0.018871605055273584;
                    end
                    else
                    begin
                        Result := 0.0064877997100353498;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -5996.4999999999991 then
                begin
                    Result := 0.024912483254340388;
                end
                else
                begin
                    if features[228] <= -4430.4999999999991 then
                    begin
                        Result := -0.0045250975120002075;
                    end
                    else
                    begin
                        Result := 0.016653447547418779;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_169(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1504.4999999999998 then
    begin
        Result := -0.017327422081818099;
    end
    else
    begin
        if features[174] <= -3967.4999999999995 then
        begin
            if features[176] <= -4760.4999999999991 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[81] <= 1.0000000180025095E-35 then
                    begin
                        Result := 9.56091613256602E-05;
                    end
                    else
                    begin
                        Result := 0.0073555957620417825;
                    end;
                end
                else
                begin
                    if features[173] <= -3132.4999999999995 then
                    begin
                        Result := -0.0037416653292196671;
                    end
                    else
                    begin
                        Result := 0.015850512305588968;
                    end;
                end;
            end
            else
            begin
                if features[186] <= -268.74999999999994 then
                begin
                    if features[174] <= -5280.4999999999991 then
                    begin
                        Result := -0.002860662798090205;
                    end
                    else
                    begin
                        Result := -0.017068081339524182;
                    end;
                end
                else
                begin
                    if features[218] <= -5454.4999999999991 then
                    begin
                        Result := -0.018299081856755196;
                    end
                    else
                    begin
                        Result := 0.0038203458966202483;
                    end;
                end;
            end;
        end
        else
        begin
            if features[218] <= -4183.4999999999991 then
            begin
                if features[222] <= -4942.4999999999991 then
                begin
                    if features[28] <= -4649.4999999999991 then
                    begin
                        Result := -0.0054524487318079731;
                    end
                    else
                    begin
                        Result := 0.026163284712211951;
                    end;
                end
                else
                begin
                    Result := 0.011561108609294012;
                end;
            end
            else
            begin
                if features[216] <= -5288.4999999999991 then
                begin
                    if features[183] <= -5747.4999999999991 then
                    begin
                        Result := 0.088753518025748324;
                    end
                    else
                    begin
                        Result := 0.010818585324871214;
                    end;
                end
                else
                begin
                    Result := 0.012198560182561519;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_170(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[180] <= -5250.4999999999991 then
        begin
            Result := -0.017569997797331951;
        end
        else
        begin
            if features[221] <= -4433.4999999999991 then
            begin
                Result := 0.089437960331299318;
            end
            else
            begin
                Result := -0.0028841875634259746;
            end;
        end;
    end
    else
    begin
        if features[90] <= 8.5000000000000018 then
        begin
            if features[128] <= -342.49999999999994 then
            begin
                if features[105] <= 1.0000000180025095E-35 then
                begin
                    if features[220] <= -826.49999999999989 then
                    begin
                        Result := -0.0089772274950210718;
                    end
                    else
                    begin
                        Result := 0.0023222236380233885;
                    end;
                end
                else
                begin
                    if features[219] <= -5531.4999999999991 then
                    begin
                        Result := -0.011358468785138479;
                    end
                    else
                    begin
                        Result := 0.00079796628294730794;
                    end;
                end;
            end
            else
            begin
                if features[15] <= -6916047.9999999991 then
                begin
                    if features[226] <= -124.49999999999999 then
                    begin
                        Result := 0.00035393385928766588;
                    end
                    else
                    begin
                        Result := 0.011006260848375873;
                    end;
                end
                else
                begin
                    if features[221] <= -5459.4999999999991 then
                    begin
                        Result := -0.0026175295580457927;
                    end
                    else
                    begin
                        Result := 0.0013199332313303285;
                    end;
                end;
            end;
        end
        else
        begin
            if features[73] <= 1.0000000180025095E-35 then
            begin
                Result := 0.018631662568419072;
            end
            else
            begin
                if features[155] <= -1.4999999999999998 then
                begin
                    if features[73] <= 157.50000000000003 then
                    begin
                        Result := -0.0047938761289251291;
                    end
                    else
                    begin
                        Result := 0.025809009398841249;
                    end;
                end
                else
                begin
                    Result := -0.0078007987789431403;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_171(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -397343039.99999994 then
    begin
        if features[183] <= -5787.4999999999991 then
        begin
            Result := -0.017629624546422949;
        end
        else
        begin
            if features[176] <= -5677.4999999999991 then
            begin
                if features[227] <= -4124.4999999999991 then
                begin
                    if features[226] <= -477.49999999999994 then
                    begin
                        Result := 0.14878000168447497;
                    end
                    else
                    begin
                        Result := -0.01138576237264048;
                    end;
                end
                else
                begin
                    Result := -0.0055076711606165188;
                end;
            end
            else
            begin
                Result := -0.010277866461493299;
            end;
        end;
    end
    else
    begin
        if features[174] <= -8889.4999999999982 then
        begin
            if features[48] <= 7936.5000000000009 then
            begin
                Result := 0.053968316449555659;
            end
            else
            begin
                Result := 0.005574550938117818;
            end;
        end
        else
        begin
            if features[47] <= 8737.5000000000018 then
            begin
                if features[219] <= -5550.4999999999991 then
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.000887338508922547;
                    end
                    else
                    begin
                        Result := -0.0079459504986401364;
                    end;
                end
                else
                begin
                    if features[182] <= -5280.4999999999991 then
                    begin
                        Result := 0.0050751003045047269;
                    end
                    else
                    begin
                        Result := -0.0035374338496591594;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -6428.4999999999991 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.020107670469787203;
                    end
                    else
                    begin
                        Result := 0.0022258985163286769;
                    end;
                end
                else
                begin
                    if features[217] <= -1186.4999999999998 then
                    begin
                        Result := -0.0058431488271586032;
                    end
                    else
                    begin
                        Result := 0.0021250975854694627;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_172(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1504.4999999999998 then
    begin
        if features[184] <= -3610.9999999999995 then
        begin
            if features[218] <= -5316.4999999999991 then
            begin
                Result := 0.089463947979270347;
            end
            else
            begin
                Result := -0.014603277092205985;
            end;
        end
        else
        begin
            Result := -0.018887653264094473;
        end;
    end
    else
    begin
        if features[182] <= -3802.4999999999995 then
        begin
            if features[225] <= -3533.4999999999995 then
            begin
                if features[216] <= -4176.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.001416369649032973;
                    end
                    else
                    begin
                        Result := -0.0034484569067260414;
                    end;
                end
                else
                begin
                    if features[175] <= -1811.4999999999998 then
                    begin
                        Result := 0.015099421258597437;
                    end
                    else
                    begin
                        Result := 0.0017920242926460874;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -27923.999999999996 then
                begin
                    Result := 0.033154733891867093;
                end
                else
                begin
                    if features[27] <= -4154.4999999999991 then
                    begin
                        Result := 0.020359951205943663;
                    end
                    else
                    begin
                        Result := 0.00074959481684815717;
                    end;
                end;
            end;
        end
        else
        begin
            if features[185] <= -181.87499999999997 then
            begin
                if features[174] <= -3516.9999999999995 then
                begin
                    Result := -0.020262387941385025;
                end
                else
                begin
                    Result := 0.0096651007275088373;
                end;
            end
            else
            begin
                if features[148] <= -1246.4999999999998 then
                begin
                    Result := -0.021035206115274055;
                end
                else
                begin
                    if features[220] <= -207.49999999999997 then
                    begin
                        Result := 0.03198883484428857;
                    end
                    else
                    begin
                        Result := -0.0023158408475006816;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_173(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1034.4999999999998 then
    begin
        if features[216] <= -6575.4999999999991 then
        begin
            if features[107] <= 1.0000000180025095E-35 then
            begin
                if features[46] <= 7.5000000000000009 then
                begin
                    Result := 0.01760406121834087;
                end
                else
                begin
                    Result := -0.016516518259385965;
                end;
            end
            else
            begin
                if features[225] <= -6313.4999999999991 then
                begin
                    Result := -0.0099463195373926463;
                end
                else
                begin
                    Result := 0.065350583329853537;
                end;
            end;
        end
        else
        begin
            if features[174] <= -3120.9999999999995 then
            begin
                Result := -0.013933845943747112;
            end
            else
            begin
                Result := 0.051349689688885813;
            end;
        end;
    end
    else
    begin
        if features[179] <= -3792.4999999999995 then
        begin
            if features[108] <= -1311.4999999999998 then
            begin
                if features[222] <= -5665.4999999999991 then
                begin
                    if features[109] <= -547.49999999999989 then
                    begin
                        Result := -0.011180623262320662;
                    end
                    else
                    begin
                        Result := 0.070078222871359494;
                    end;
                end
                else
                begin
                    if features[181] <= -1941.4999999999998 then
                    begin
                        Result := 0.011162850589800932;
                    end
                    else
                    begin
                        Result := 0.050603367377714793;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -3627.4999999999995 then
                begin
                    if features[94] <= -155228.99999999997 then
                    begin
                        Result := 0.0089808962421015822;
                    end
                    else
                    begin
                        Result := -4.8458308957279867E-05;
                    end;
                end
                else
                begin
                    Result := 0.011196880418581611;
                end;
            end;
        end
        else
        begin
            if features[105] <= 1.5000000000000002 then
            begin
                Result := -0.015091831018517021;
            end
            else
            begin
                Result := 0.014575790226041897;
            end;
        end;
    end;
end;

function bidirectional_tree_174(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        if features[215] <= -8107.4999999999991 then
        begin
            Result := 0.03248434642511578;
        end
        else
        begin
            Result := -0.019662323759678035;
        end;
    end
    else
    begin
        if features[129] <= -28181.999999999996 then
        begin
            if features[147] <= -586.99999999999989 then
            begin
                Result := 0.0239866204426889;
            end
            else
            begin
                if features[222] <= -5801.4999999999991 then
                begin
                    if features[225] <= -4814.4999999999991 then
                    begin
                        Result := -0.031676830438175915;
                    end
                    else
                    begin
                        Result := -0.0021805607240077919;
                    end;
                end
                else
                begin
                    if features[175] <= -300.49999999999994 then
                    begin
                        Result := -0.016889639345516322;
                    end
                    else
                    begin
                        Result := 0.0025919235447311329;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -6428.4999999999991 then
            begin
                if features[174] <= -5292.4999999999991 then
                begin
                    if features[180] <= -8789.4999999999982 then
                    begin
                        Result := 0.031481038766545733;
                    end
                    else
                    begin
                        Result := 0.00068615135161609721;
                    end;
                end
                else
                begin
                    if features[82] <= -158.49999999999997 then
                    begin
                        Result := 0.0088154570407532728;
                    end
                    else
                    begin
                        Result := 0.03444806844754969;
                    end;
                end;
            end
            else
            begin
                if features[217] <= -1186.4999999999998 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0066581009033199112;
                    end
                    else
                    begin
                        Result := -0.0094522505583780961;
                    end;
                end
                else
                begin
                    if features[181] <= -1121.4999999999998 then
                    begin
                        Result := -0.0054364623078943537;
                    end
                    else
                    begin
                        Result := 0.0017216908943892334;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_175(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1504.4999999999998 then
    begin
        Result := -0.017253456372383583;
    end
    else
    begin
        if features[229] <= 529.50000000000011 then
        begin
            if features[166] <= -31727439.999999996 then
            begin
                if features[176] <= -7459.4999999999991 then
                begin
                    if features[217] <= 287.50000000000006 then
                    begin
                        Result := -0.0090707174717140418;
                    end
                    else
                    begin
                        Result := 0.00017871122797639001;
                    end;
                end
                else
                begin
                    if features[154] <= -130.49999999999997 then
                    begin
                        Result := 0.0015661835123923309;
                    end
                    else
                    begin
                        Result := -0.0031476881843887786;
                    end;
                end;
            end
            else
            begin
                if features[183] <= -6513.4999999999991 then
                begin
                    if features[121] <= -1156.4999999999998 then
                    begin
                        Result := 0.037674411204939189;
                    end
                    else
                    begin
                        Result := 0.0067640193790362672;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0073830854537568482;
                    end
                    else
                    begin
                        Result := 0.0030296756662513795;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -6975.9999999999991 then
            begin
                if features[27] <= -6033.4999999999991 then
                begin
                    Result := 0.018317115494086628;
                end
                else
                begin
                    Result := -0.010844913738466506;
                end;
            end
            else
            begin
                if features[179] <= -4862.4999999999991 then
                begin
                    if features[228] <= -4942.4999999999991 then
                    begin
                        Result := 0.0022693827845048716;
                    end
                    else
                    begin
                        Result := 0.019871356782533336;
                    end;
                end
                else
                begin
                    if features[224] <= -4881.4999999999991 then
                    begin
                        Result := -0.03049259204170772;
                    end
                    else
                    begin
                        Result := 0.015417297280586446;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_176(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1757.4999999999998 then
    begin
        Result := -0.020413828921009316;
    end
    else
    begin
        if features[216] <= -7164.9999999999991 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[187] <= 19.348484992980961 then
                begin
                    if features[166] <= -242340727.99999997 then
                    begin
                        Result := 0.072475697383351384;
                    end
                    else
                    begin
                        Result := 0.023279527786341514;
                    end;
                end
                else
                begin
                    Result := -0.010704317556817049;
                end;
            end
            else
            begin
                if features[182] <= -6567.4999999999991 then
                begin
                    if features[69] <= 17.500000000000004 then
                    begin
                        Result := -0.01446306713751383;
                    end
                    else
                    begin
                        Result := 0.022735420859033087;
                    end;
                end
                else
                begin
                    Result := 0.012360152607359886;
                end;
            end;
        end
        else
        begin
            if features[178] <= -1264.4999999999998 then
            begin
                if features[176] <= -4377.4999999999991 then
                begin
                    if features[166] <= -39740415.999999993 then
                    begin
                        Result := -0.0033788680976616979;
                    end
                    else
                    begin
                        Result := 0.015436236121593045;
                    end;
                end
                else
                begin
                    if features[173] <= -6292.4999999999991 then
                    begin
                        Result := 0.034811816703287611;
                    end
                    else
                    begin
                        Result := -0.016037545597402236;
                    end;
                end;
            end
            else
            begin
                if features[218] <= -4444.4999999999991 then
                begin
                    if features[108] <= -642.49999999999989 then
                    begin
                        Result := 0.0079938905922388222;
                    end
                    else
                    begin
                        Result := -0.00074205245861762553;
                    end;
                end
                else
                begin
                    if features[176] <= -6433.4999999999991 then
                    begin
                        Result := -0.016210470569332038;
                    end
                    else
                    begin
                        Result := 0.0086341704624107018;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_177(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1263.4999999999998 then
    begin
        if features[218] <= -7311.4999999999991 then
        begin
            Result := 0.06258939513991954;
        end
        else
        begin
            Result := -0.019294085121168078;
        end;
    end
    else
    begin
        if features[179] <= -3792.4999999999995 then
        begin
            if features[226] <= 1149.0000000000002 then
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    if features[216] <= -5414.4999999999991 then
                    begin
                        Result := 0.011478190154792164;
                    end
                    else
                    begin
                        Result := -0.00012296639071972121;
                    end;
                end
                else
                begin
                    if features[216] <= -4176.4999999999991 then
                    begin
                        Result := -0.0012478228069233014;
                    end
                    else
                    begin
                        Result := 0.0044801066120585143;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5314.4999999999991 then
                begin
                    Result := -0.001752905868997905;
                end
                else
                begin
                    Result := 0.021700628113120943;
                end;
            end;
        end
        else
        begin
            if features[186] <= -404.41667175292963 then
            begin
                if features[175] <= -2028.4999999999998 then
                begin
                    if features[39] <= 1555.5000000000002 then
                    begin
                        Result := 0.045007009044072593;
                    end
                    else
                    begin
                        Result := -0.017589911256617231;
                    end;
                end
                else
                begin
                    if features[219] <= -7457.4999999999991 then
                    begin
                        Result := 0.022877613647779405;
                    end
                    else
                    begin
                        Result := -0.025867244005101892;
                    end;
                end;
            end
            else
            begin
                if features[223] <= -996.49999999999989 then
                begin
                    Result := 0.045230952820477704;
                end
                else
                begin
                    if features[215] <= -4049.4999999999995 then
                    begin
                        Result := -0.012829477949206714;
                    end
                    else
                    begin
                        Result := 0.01348604625056282;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_178(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1504.4999999999998 then
    begin
        if features[174] <= -8889.4999999999982 then
        begin
            if features[71] <= 6.5000000000000009 then
            begin
                Result := -0.016715110455510357;
            end
            else
            begin
                Result := 0.0560734433795822;
            end;
        end
        else
        begin
            Result := -0.018497399661591245;
        end;
    end
    else
    begin
        if features[94] <= -155228.99999999997 then
        begin
            if features[229] <= -26.499999999999996 then
            begin
                if features[74] <= 11.500000000000002 then
                begin
                    if features[215] <= -5371.4999999999991 then
                    begin
                        Result := -0.0094116263678557192;
                    end
                    else
                    begin
                        Result := 0.021578144237890902;
                    end;
                end
                else
                begin
                    Result := -0.012472975231907428;
                end;
            end
            else
            begin
                Result := 0.01744506917867425;
            end;
        end
        else
        begin
            if features[147] <= -674.99999999999989 then
            begin
                if features[47] <= 5412.5000000000009 then
                begin
                    if features[70] <= 749.50000000000011 then
                    begin
                        Result := -0.0067972064345119534;
                    end
                    else
                    begin
                        Result := 0.0097150744547792964;
                    end;
                end
                else
                begin
                    if features[216] <= -4382.4999999999991 then
                    begin
                        Result := 0.025916001980183047;
                    end
                    else
                    begin
                        Result := -0.010766307585416921;
                    end;
                end;
            end
            else
            begin
                if features[82] <= -172271.49999999997 then
                begin
                    if features[219] <= -4821.4999999999991 then
                    begin
                        Result := -0.01245750097926262;
                    end
                    else
                    begin
                        Result := 0.0055188766796219159;
                    end;
                end
                else
                begin
                    if features[170] <= 4.5000000000000009 then
                    begin
                        Result := 0.0018079720767214163;
                    end
                    else
                    begin
                        Result := -0.0017861205226105176;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_179(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1504.4999999999998 then
    begin
        Result := -0.015191704436382484;
    end
    else
    begin
        if features[77] <= 3354.0000000000005 then
        begin
            if features[222] <= -5892.4999999999991 then
            begin
                if features[129] <= -25202.999999999996 then
                begin
                    Result := -0.022567137567376425;
                end
                else
                begin
                    if features[151] <= -9.4999999999999982 then
                    begin
                        Result := -0.0012156527611180403;
                    end
                    else
                    begin
                        Result := -0.01004147758135881;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -6293.4999999999991 then
                begin
                    Result := 0.013108108319983644;
                end
                else
                begin
                    if features[220] <= 475.50000000000006 then
                    begin
                        Result := 0.00076513231156799446;
                    end
                    else
                    begin
                        Result := -0.0066727718034806337;
                    end;
                end;
            end;
        end
        else
        begin
            if features[105] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -5221.4999999999991 then
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        Result := 0.0025834703953469739;
                    end
                    else
                    begin
                        Result := 0.012699264522637711;
                    end;
                end
                else
                begin
                    if features[216] <= -4078.4999999999995 then
                    begin
                        Result := -0.00051800520563016316;
                    end
                    else
                    begin
                        Result := 0.0096214433601339161;
                    end;
                end;
            end
            else
            begin
                if features[129] <= -8228.4999999999982 then
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        Result := 0.01050792743499878;
                    end
                    else
                    begin
                        Result := -0.010918495996895018;
                    end;
                end
                else
                begin
                    if features[219] <= -5330.4999999999991 then
                    begin
                        Result := -0.011539334101327235;
                    end
                    else
                    begin
                        Result := 0.0020809390266296485;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_180(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        if features[225] <= -4414.4999999999991 then
        begin
            Result := -0.021799540576098859;
        end
        else
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                Result := 0.049906152460177905;
            end
            else
            begin
                Result := -0.019841936935915828;
            end;
        end;
    end
    else
    begin
        if features[166] <= -93540307.999999985 then
        begin
            if features[90] <= -2.4999999999999996 then
            begin
                Result := -0.01714960646170666;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[177] <= -6105.4999999999991 then
                    begin
                        Result := -0.0063959582809544743;
                    end
                    else
                    begin
                        Result := 0.0026379877870526779;
                    end;
                end
                else
                begin
                    if features[176] <= -4274.4999999999991 then
                    begin
                        Result := 0.0029492877250373809;
                    end
                    else
                    begin
                        Result := -0.0088867059595648494;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -3699.4999999999995 then
            begin
                if features[14] <= 24302217.000000004 then
                begin
                    if features[67] <= 1.0000000180025095E-35 then
                    begin
                        Result := -7.9491760917577687E-05;
                    end
                    else
                    begin
                        Result := 0.0047660405116046432;
                    end;
                end
                else
                begin
                    if features[154] <= 383.00000000000006 then
                    begin
                        Result := -0.00079407244680768552;
                    end
                    else
                    begin
                        Result := -0.020925307690497625;
                    end;
                end;
            end
            else
            begin
                if features[223] <= -182.49999999999997 then
                begin
                    Result := 0.035157081520078855;
                end
                else
                begin
                    if features[67] <= 1501.5000000000002 then
                    begin
                        Result := 0.019897206502079087;
                    end
                    else
                    begin
                        Result := -0.0023271659226917689;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_181(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[164] <= -2016433.9999999998 then
        begin
            Result := -0.022720859378434863;
        end
        else
        begin
            if features[95] <= -296241967.99999994 then
            begin
                Result := 0.033347810731931209;
            end
            else
            begin
                Result := -0.012430248453388928;
            end;
        end;
    end
    else
    begin
        if features[178] <= 70.500000000000014 then
        begin
            if features[227] <= -5492.4999999999991 then
            begin
                if features[36] <= 469.50000000000006 then
                begin
                    if features[223] <= -975.49999999999989 then
                    begin
                        Result := 0.023211685317853746;
                    end
                    else
                    begin
                        Result := -0.0039265637672350707;
                    end;
                end
                else
                begin
                    if features[67] <= 5848.5000000000009 then
                    begin
                        Result := -0.018024317851806592;
                    end
                    else
                    begin
                        Result := 0.020868199468915331;
                    end;
                end;
            end
            else
            begin
                if features[170] <= 4.5000000000000009 then
                begin
                    if features[108] <= -1228.4999999999998 then
                    begin
                        Result := 0.020843293159241702;
                    end
                    else
                    begin
                        Result := 0.0025649649729208518;
                    end;
                end
                else
                begin
                    if features[216] <= -5440.4999999999991 then
                    begin
                        Result := 0.0032007008112982386;
                    end
                    else
                    begin
                        Result := -0.0050062583927145826;
                    end;
                end;
            end;
        end
        else
        begin
            if features[129] <= -34865.499999999993 then
            begin
                Result := -0.026409766698850659;
            end
            else
            begin
                if features[121] <= -1204.4999999999998 then
                begin
                    Result := -0.010573839173304463;
                end
                else
                begin
                    if features[184] <= -849.49999999999989 then
                    begin
                        Result := 0.028604246236607747;
                    end
                    else
                    begin
                        Result := 0.0035077190985284994;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_182(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1468.4999999999998 then
    begin
        if features[77] <= 6646.0000000000009 then
        begin
            Result := -0.019353756736443684;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[77] <= 8937.5000000000018 then
                begin
                    Result := 0.12854125416592835;
                end
                else
                begin
                    Result := -0.011191786534929809;
                end;
            end
            else
            begin
                Result := -0.0092323221996021016;
            end;
        end;
    end
    else
    begin
        if features[90] <= 8.5000000000000018 then
        begin
            if features[47] <= 8737.5000000000018 then
            begin
                if features[218] <= -4278.4999999999991 then
                begin
                    if features[229] <= -434.49999999999994 then
                    begin
                        Result := -0.010046756980207209;
                    end
                    else
                    begin
                        Result := -0.0014844247124927116;
                    end;
                end
                else
                begin
                    if features[215] <= -3285.4999999999995 then
                    begin
                        Result := 0.0081674792024073097;
                    end
                    else
                    begin
                        Result := -0.025703790203753376;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -5192.4999999999991 then
                begin
                    if features[173] <= -3931.4999999999995 then
                    begin
                        Result := 0.0055680572233426304;
                    end
                    else
                    begin
                        Result := -0.0128123038613406;
                    end;
                end
                else
                begin
                    if features[186] <= -291.74999999999994 then
                    begin
                        Result := -0.0062253638829072467;
                    end
                    else
                    begin
                        Result := 0.0018704114201728733;
                    end;
                end;
            end;
        end
        else
        begin
            if features[151] <= -83.499999999999986 then
            begin
                Result := 0.019213197487006013;
            end
            else
            begin
                if features[180] <= -5679.4999999999991 then
                begin
                    Result := -0.0013000480678581391;
                end
                else
                begin
                    Result := 0.019980272413873401;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_183(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1757.4999999999998 then
    begin
        Result := -0.020019734666220049;
    end
    else
    begin
        if features[216] <= -6993.4999999999991 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[187] <= 19.348484992980961 then
                begin
                    Result := 0.031814681127727146;
                end
                else
                begin
                    Result := -0.0034855690389410908;
                end;
            end
            else
            begin
                if features[182] <= -6550.4999999999991 then
                begin
                    if features[69] <= 17.500000000000004 then
                    begin
                        Result := -0.011545164248666877;
                    end
                    else
                    begin
                        Result := 0.024134280933432034;
                    end;
                end
                else
                begin
                    if features[70] <= 737.50000000000011 then
                    begin
                        Result := 0.044222336577825518;
                    end
                    else
                    begin
                        Result := 0.007024390516036455;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4176.4999999999991 then
            begin
                if features[187] <= -23.309524536132809 then
                begin
                    if features[225] <= -5461.4999999999991 then
                    begin
                        Result := -0.010617329397878014;
                    end
                    else
                    begin
                        Result := -0.0012115011764126742;
                    end;
                end
                else
                begin
                    if features[175] <= -1426.4999999999998 then
                    begin
                        Result := -0.004925027312079824;
                    end
                    else
                    begin
                        Result := 0.0014001570463702123;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[217] <= 137.50000000000003 then
                    begin
                        Result := 0.021342307099555494;
                    end
                    else
                    begin
                        Result := -0.017892920642052886;
                    end;
                end
                else
                begin
                    if features[175] <= 1822.0000000000002 then
                    begin
                        Result := 0.009208173778103455;
                    end
                    else
                    begin
                        Result := -0.0057473409145434966;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_184(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1504.4999999999998 then
    begin
        if features[184] <= -3610.9999999999995 then
        begin
            if features[77] <= 4937.5000000000009 then
            begin
                Result := -0.012967056805301982;
            end
            else
            begin
                Result := 0.077626030968382637;
            end;
        end
        else
        begin
            Result := -0.017045497788141593;
        end;
    end
    else
    begin
        if features[229] <= 787.50000000000011 then
        begin
            if features[217] <= 2926.5000000000005 then
            begin
                if features[229] <= 312.50000000000006 then
                begin
                    if features[176] <= -7655.4999999999991 then
                    begin
                        Result := -0.0052436732813605598;
                    end
                    else
                    begin
                        Result := 0.00057314924560124367;
                    end;
                end
                else
                begin
                    if features[221] <= -7113.4999999999991 then
                    begin
                        Result := -0.0112951457829626;
                    end
                    else
                    begin
                        Result := 0.0065630260932415339;
                    end;
                end;
            end
            else
            begin
                if features[39] <= 38.500000000000007 then
                begin
                    if features[73] <= 280.50000000000006 then
                    begin
                        Result := 0.013998995604554448;
                    end
                    else
                    begin
                        Result := -0.024434411553909571;
                    end;
                end
                else
                begin
                    Result := -0.020263295926418592;
                end;
            end;
        end
        else
        begin
            if features[225] <= -5314.4999999999991 then
            begin
                if features[28] <= -6932.4999999999991 then
                begin
                    Result := 0.016017988466823962;
                end
                else
                begin
                    Result := -0.017183849157750019;
                end;
            end
            else
            begin
                if features[177] <= -5788.4999999999991 then
                begin
                    Result := 0.0253580959991145;
                end
                else
                begin
                    if features[73] <= 365.50000000000006 then
                    begin
                        Result := 0.011581608278430931;
                    end
                    else
                    begin
                        Result := -0.029380948243313179;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_185(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        if features[215] <= -8299.9999999999982 then
        begin
            Result := 0.045923100545810565;
        end
        else
        begin
            if features[225] <= -4521.4999999999991 then
            begin
                Result := -0.013588044485547188;
            end
            else
            begin
                Result := 0.0060960268082639064;
            end;
        end;
    end
    else
    begin
        if features[147] <= -524.49999999999989 then
        begin
            if features[215] <= -5111.4999999999991 then
            begin
                if features[123] <= -73.999999999999986 then
                begin
                    Result := -0.010101095861447537;
                end
                else
                begin
                    Result := 0.024389908289957414;
                end;
            end
            else
            begin
                if features[171] <= 4.5000000000000009 then
                begin
                    Result := 0.0086410021880372039;
                end
                else
                begin
                    Result := -0.011700083773520957;
                end;
            end;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[81] <= 1.0000000180025095E-35 then
                begin
                    if features[158] <= 56312.500000000007 then
                    begin
                        Result := -0.00047557571602710024;
                    end
                    else
                    begin
                        Result := 0.020024584659638609;
                    end;
                end
                else
                begin
                    if features[215] <= -3425.4999999999995 then
                    begin
                        Result := 0.007764374717492091;
                    end
                    else
                    begin
                        Result := -0.023940795400127734;
                    end;
                end;
            end
            else
            begin
                if features[105] <= 1.0000000180025095E-35 then
                begin
                    if features[176] <= -4965.4999999999991 then
                    begin
                        Result := 0.0005409214403762308;
                    end
                    else
                    begin
                        Result := -0.0087398806538835899;
                    end;
                end
                else
                begin
                    if features[70] <= 829.50000000000011 then
                    begin
                        Result := -0.020225420184126239;
                    end
                    else
                    begin
                        Result := -0.0056130345724117797;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_186(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1034.4999999999998 then
    begin
        if features[177] <= -5087.4999999999991 then
        begin
            if features[216] <= -6660.4999999999991 then
            begin
                if features[18] <= 7.5000000000000009 then
                begin
                    Result := 0.020046919579649995;
                end
                else
                begin
                    Result := -0.01166177653596211;
                end;
            end
            else
            begin
                Result := -0.016280653055084929;
            end;
        end
        else
        begin
            if features[227] <= -3405.4999999999995 then
            begin
                if features[173] <= -4583.4999999999991 then
                begin
                    if features[215] <= -4957.4999999999991 then
                    begin
                        Result := 0.015922704407507662;
                    end
                    else
                    begin
                        Result := 0.089519062546678269;
                    end;
                end
                else
                begin
                    Result := -0.018968425078944556;
                end;
            end
            else
            begin
                Result := -0.022398671963787704;
            end;
        end;
    end
    else
    begin
        if features[179] <= -3792.4999999999995 then
        begin
            if features[225] <= -3627.4999999999995 then
            begin
                if features[109] <= -1011.4999999999999 then
                begin
                    if features[222] <= -5429.4999999999991 then
                    begin
                        Result := -0.0019346719074607118;
                    end
                    else
                    begin
                        Result := 0.023560453269427101;
                    end;
                end
                else
                begin
                    if features[94] <= -155228.99999999997 then
                    begin
                        Result := 0.0078212561616120054;
                    end
                    else
                    begin
                        Result := -0.00040785859418808294;
                    end;
                end;
            end
            else
            begin
                Result := 0.010691185260509;
            end;
        end
        else
        begin
            if features[105] <= 1.5000000000000002 then
            begin
                if features[149] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.033914395834134616;
                end
                else
                begin
                    Result := -0.016464952259830117;
                end;
            end
            else
            begin
                Result := 0.01581223039873185;
            end;
        end;
    end;
end;

function bidirectional_tree_187(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        if features[215] <= -8107.4999999999991 then
        begin
            Result := 0.031282035124263037;
        end
        else
        begin
            Result := -0.01995771784983736;
        end;
    end
    else
    begin
        if features[229] <= 787.50000000000011 then
        begin
            if features[217] <= 2926.5000000000005 then
            begin
                if features[176] <= -7434.4999999999991 then
                begin
                    if features[216] <= -4382.4999999999991 then
                    begin
                        Result := -0.0051683562572514968;
                    end
                    else
                    begin
                        Result := 0.010392103155276423;
                    end;
                end
                else
                begin
                    if features[216] <= -6575.4999999999991 then
                    begin
                        Result := 0.0088423692184167978;
                    end
                    else
                    begin
                        Result := 0.0006467995883757138;
                    end;
                end;
            end
            else
            begin
                if features[177] <= -8194.4999999999982 then
                begin
                    if features[36] <= 8.5000000000000018 then
                    begin
                        Result := 0.023537060859613698;
                    end
                    else
                    begin
                        Result := -0.010660176544527743;
                    end;
                end
                else
                begin
                    if features[164] <= -249738935.99999997 then
                    begin
                        Result := 0.007843864684030059;
                    end
                    else
                    begin
                        Result := -0.02322226988781563;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -5314.4999999999991 then
            begin
                if features[164] <= -40867371.999999993 then
                begin
                    Result := 0.0090502637168340949;
                end
                else
                begin
                    Result := -0.022220449562449958;
                end;
            end
            else
            begin
                if features[177] <= -5763.4999999999991 then
                begin
                    Result := 0.02480114223817631;
                end
                else
                begin
                    if features[55] <= 1.5000000000000002 then
                    begin
                        Result := -0.023255001429139638;
                    end
                    else
                    begin
                        Result := 0.019183727937326301;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_188(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        if features[215] <= -8107.4999999999991 then
        begin
            Result := 0.029028564593606684;
        end
        else
        begin
            Result := -0.018896742544805084;
        end;
    end
    else
    begin
        if features[147] <= -524.49999999999989 then
        begin
            if features[173] <= -4499.4999999999991 then
            begin
                if features[123] <= -59.999999999999993 then
                begin
                    if features[174] <= -5560.4999999999991 then
                    begin
                        Result := -0.027708114623234154;
                    end
                    else
                    begin
                        Result := 0.0099116059065864209;
                    end;
                end
                else
                begin
                    if features[158] <= 7937.5000000000009 then
                    begin
                        Result := 0.035637500651140262;
                    end
                    else
                    begin
                        Result := 0.013068959772048873;
                    end;
                end;
            end
            else
            begin
                if features[173] <= -3752.4999999999995 then
                begin
                    if features[47] <= 5366.5000000000009 then
                    begin
                        Result := -0.020773584049853022;
                    end
                    else
                    begin
                        Result := 0.0053339696902134628;
                    end;
                end
                else
                begin
                    if features[227] <= -5349.4999999999991 then
                    begin
                        Result := 0.043851730945319647;
                    end
                    else
                    begin
                        Result := 0.0093142228942733538;
                    end;
                end;
            end;
        end
        else
        begin
            if features[135] <= -10.499999999999998 then
            begin
                Result := -0.019285346616619868;
            end
            else
            begin
                if features[216] <= -4176.4999999999991 then
                begin
                    if features[118] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0033774475271547998;
                    end
                    else
                    begin
                        Result := -0.0018508865461414007;
                    end;
                end
                else
                begin
                    if features[177] <= -7925.4999999999991 then
                    begin
                        Result := 0.021083127100485509;
                    end
                    else
                    begin
                        Result := 0.002086213015895184;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_189(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[164] <= -2016433.9999999998 then
        begin
            Result := -0.023629703112063305;
        end
        else
        begin
            if features[95] <= -296241967.99999994 then
            begin
                Result := 0.033302216978230971;
            end
            else
            begin
                Result := -0.011759377506894941;
            end;
        end;
    end
    else
    begin
        if features[90] <= 1.5000000000000002 then
        begin
            if features[47] <= 9294.5000000000018 then
            begin
                if features[219] <= -5330.4999999999991 then
                begin
                    if features[166] <= -129191879.99999999 then
                    begin
                        Result := -0.0071660546493806394;
                    end
                    else
                    begin
                        Result := -0.00089720613230533466;
                    end;
                end
                else
                begin
                    if features[182] <= -5524.4999999999991 then
                    begin
                        Result := 0.0067579293999219751;
                    end
                    else
                    begin
                        Result := -0.0038987008078907887;
                    end;
                end;
            end
            else
            begin
                if features[158] <= 1775.0000000000002 then
                begin
                    if features[221] <= -6306.4999999999991 then
                    begin
                        Result := -0.0079301200785073592;
                    end
                    else
                    begin
                        Result := 0.0010091748801299703;
                    end;
                end
                else
                begin
                    if features[96] <= 26435888.000000004 then
                    begin
                        Result := 0.0061840437690355368;
                    end
                    else
                    begin
                        Result := -0.017631611052506869;
                    end;
                end;
            end;
        end
        else
        begin
            if features[36] <= 780.50000000000011 then
            begin
                if features[147] <= 507.00000000000006 then
                begin
                    if features[178] <= -1696.4999999999998 then
                    begin
                        Result := -0.021843012777961145;
                    end
                    else
                    begin
                        Result := 0.010066397206651815;
                    end;
                end
                else
                begin
                    Result := -0.0054845675251699302;
                end;
            end
            else
            begin
                Result := -0.015800472341714774;
            end;
        end;
    end;
end;

function bidirectional_tree_190(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[117] <= -587.49999999999989 then
    begin
        if features[180] <= -6037.4999999999991 then
        begin
            if features[226] <= 26.500000000000004 then
            begin
                Result := -0.011589907732870565;
            end
            else
            begin
                Result := -0.036268812435290614;
            end;
        end
        else
        begin
            Result := -7.964168667045832E-05;
        end;
    end
    else
    begin
        if features[229] <= 702.50000000000011 then
        begin
            if features[166] <= -29654539.999999996 then
            begin
                if features[176] <= -6829.4999999999991 then
                begin
                    if features[166] <= -103363235.99999999 then
                    begin
                        Result := -0.0065728661775042996;
                    end
                    else
                    begin
                        Result := 0.00037820307992217443;
                    end;
                end
                else
                begin
                    if features[178] <= -297.49999999999994 then
                    begin
                        Result := -0.0017937582694808872;
                    end
                    else
                    begin
                        Result := 0.0046338350922392399;
                    end;
                end;
            end
            else
            begin
                if features[110] <= -452.49999999999994 then
                begin
                    if features[177] <= -7110.4999999999991 then
                    begin
                        Result := 0.024781960935422731;
                    end
                    else
                    begin
                        Result := 0.00093332284754049752;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0053758173427669465;
                    end
                    else
                    begin
                        Result := 0.0054418315533224975;
                    end;
                end;
            end;
        end
        else
        begin
            if features[177] <= -6118.4999999999991 then
            begin
                if features[222] <= -6060.4999999999991 then
                begin
                    Result := -0.013471574270752046;
                end
                else
                begin
                    Result := 0.021835011896012117;
                end;
            end
            else
            begin
                if features[110] <= -217.49999999999997 then
                begin
                    Result := -0.03051236526641939;
                end
                else
                begin
                    Result := 0.0079567235958290777;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_191(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -341334223.99999994 then
    begin
        Result := -0.008649213069023335;
    end
    else
    begin
        if features[154] <= 19.500000000000004 then
        begin
            if features[120] <= -1432.4999999999998 then
            begin
                if features[173] <= -3550.4999999999995 then
                begin
                    if features[122] <= -1285.4999999999998 then
                    begin
                        Result := 0.025113543098218463;
                    end
                    else
                    begin
                        Result := 0.00067284665837880888;
                    end;
                end
                else
                begin
                    Result := 0.036711895340864241;
                end;
            end
            else
            begin
                if features[120] <= -1138.9999999999998 then
                begin
                    if features[217] <= 874.50000000000011 then
                    begin
                        Result := -0.013183740767061528;
                    end
                    else
                    begin
                        Result := 0.010209060265116173;
                    end;
                end
                else
                begin
                    if features[217] <= 2926.5000000000005 then
                    begin
                        Result := 0.0016271287659030071;
                    end
                    else
                    begin
                        Result := -0.012354165044481585;
                    end;
                end;
            end;
        end
        else
        begin
            if features[221] <= -5953.4999999999991 then
            begin
                if features[166] <= -112029371.99999999 then
                begin
                    Result := -0.023959603660381169;
                end
                else
                begin
                    if features[96] <= -20435285.999999996 then
                    begin
                        Result := 0.018795123109766766;
                    end
                    else
                    begin
                        Result := -0.0086406071320346226;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -307.49999999999994 then
                begin
                    if features[146] <= -1946.4999999999998 then
                    begin
                        Result := 0.028865948028366013;
                    end
                    else
                    begin
                        Result := -0.0085976949671517228;
                    end;
                end
                else
                begin
                    if features[177] <= -7188.4999999999991 then
                    begin
                        Result := 0.010208640953908461;
                    end
                    else
                    begin
                        Result := -0.0014278873560823358;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_192(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1344.4999999999998 then
    begin
        if features[28] <= -9010.4999999999982 then
        begin
            Result := 0.02685332070925214;
        end
        else
        begin
            if features[187] <= 95.325000762939467 then
            begin
                Result := -0.024682400507883666;
            end
            else
            begin
                Result := 0.010536043892813571;
            end;
        end;
    end
    else
    begin
        if features[147] <= -195.49999999999997 then
        begin
            if features[149] <= 430.00000000000006 then
            begin
                if features[171] <= 3.5000000000000004 then
                begin
                    if features[117] <= 162.50000000000003 then
                    begin
                        Result := 0.012693427864629417;
                    end
                    else
                    begin
                        Result := 0.041860298733898654;
                    end;
                end
                else
                begin
                    if features[173] <= -4484.4999999999991 then
                    begin
                        Result := 0.0090442304024108151;
                    end
                    else
                    begin
                        Result := -0.0096078098857937215;
                    end;
                end;
            end
            else
            begin
                Result := -0.024758330024980058;
            end;
        end
        else
        begin
            if features[229] <= 312.50000000000006 then
            begin
                if features[220] <= 453.50000000000006 then
                begin
                    if features[180] <= -4837.4999999999991 then
                    begin
                        Result := -0.00069124045120575828;
                    end
                    else
                    begin
                        Result := 0.0092702044318339807;
                    end;
                end
                else
                begin
                    if features[41] <= 1411.5000000000002 then
                    begin
                        Result := -0.0098631753021550701;
                    end
                    else
                    begin
                        Result := 0.012337141393268481;
                    end;
                end;
            end
            else
            begin
                if features[223] <= 282.50000000000006 then
                begin
                    Result := 0.023287599741643222;
                end
                else
                begin
                    if features[217] <= -271.49999999999994 then
                    begin
                        Result := 0.013492319107701548;
                    end
                    else
                    begin
                        Result := -0.00021369064288217503;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_193(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        Result := -0.017745145764604432;
    end
    else
    begin
        if features[90] <= 1.5000000000000002 then
        begin
            if features[47] <= 8737.5000000000018 then
            begin
                if features[219] <= -5129.4999999999991 then
                begin
                    if features[166] <= -139258119.99999997 then
                    begin
                        Result := -0.0073168722849802637;
                    end
                    else
                    begin
                        Result := -0.00079624757223324184;
                    end;
                end
                else
                begin
                    if features[177] <= -7331.4999999999991 then
                    begin
                        Result := 0.035649996566345474;
                    end
                    else
                    begin
                        Result := 0.002138866307993312;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 4.5000000000000009 then
                begin
                    if features[81] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0048863573757223083;
                    end
                    else
                    begin
                        Result := 0.0069450830908617273;
                    end;
                end
                else
                begin
                    if features[174] <= -4045.4999999999995 then
                    begin
                        Result := -0.0012539329367692112;
                    end
                    else
                    begin
                        Result := 0.0082474803234336234;
                    end;
                end;
            end;
        end
        else
        begin
            if features[151] <= -229.99999999999997 then
            begin
                if features[220] <= -344.49999999999994 then
                begin
                    Result := 0.04391003138404502;
                end
                else
                begin
                    if features[60] <= 2.5000000000000004 then
                    begin
                        Result := -0.0083525662595918537;
                    end
                    else
                    begin
                        Result := 0.023733200511802707;
                    end;
                end;
            end
            else
            begin
                if features[183] <= -4704.4999999999991 then
                begin
                    if features[217] <= -977.49999999999989 then
                    begin
                        Result := -0.0089208038596163171;
                    end
                    else
                    begin
                        Result := 0.0048510422196186677;
                    end;
                end
                else
                begin
                    Result := 0.024806956038273542;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_194(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1806.4999999999998 then
    begin
        Result := -0.021636298404969438;
    end
    else
    begin
        if features[226] <= 741.50000000000011 then
        begin
            if features[216] <= -7297.4999999999991 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[215] <= -4415.4999999999991 then
                    begin
                        Result := 0.011408180129500321;
                    end
                    else
                    begin
                        Result := 0.054612583704651288;
                    end;
                end
                else
                begin
                    if features[174] <= -7804.4999999999991 then
                    begin
                        Result := 0.02142247706092942;
                    end
                    else
                    begin
                        Result := -0.0070567311462653758;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -263177239.99999997 then
                begin
                    if features[174] <= -3120.9999999999995 then
                    begin
                        Result := -0.0071053650725151907;
                    end
                    else
                    begin
                        Result := 0.05382340105153112;
                    end;
                end
                else
                begin
                    if features[218] <= -4444.4999999999991 then
                    begin
                        Result := -0.00065292497422998654;
                    end
                    else
                    begin
                        Result := 0.0047096658188649256;
                    end;
                end;
            end;
        end
        else
        begin
            if features[77] <= 1866.0000000000002 then
            begin
                if features[228] <= -3620.4999999999995 then
                begin
                    Result := -0.0087398689467868447;
                end
                else
                begin
                    Result := 0.01411217308764658;
                end;
            end
            else
            begin
                if features[27] <= -5242.4999999999991 then
                begin
                    if features[107] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.00093839336102571772;
                    end
                    else
                    begin
                        Result := 0.024890941537134892;
                    end;
                end
                else
                begin
                    if features[225] <= -5314.4999999999991 then
                    begin
                        Result := -0.018079632698141956;
                    end
                    else
                    begin
                        Result := 0.012252310446901574;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_195(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1757.4999999999998 then
    begin
        Result := -0.019334713637238744;
    end
    else
    begin
        if features[216] <= -7164.9999999999991 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[175] <= -1208.4999999999998 then
                begin
                    Result := 0.0059206053652124703;
                end
                else
                begin
                    Result := 0.032264301552199774;
                end;
            end
            else
            begin
                if features[175] <= -1208.4999999999998 then
                begin
                    if features[13] <= 92836.000000000015 then
                    begin
                        Result := 0.0030260803775096642;
                    end
                    else
                    begin
                        Result := 0.039831726647424577;
                    end;
                end
                else
                begin
                    if features[70] <= 747.50000000000011 then
                    begin
                        Result := 0.0234666658995153;
                    end
                    else
                    begin
                        Result := -0.021006535063817236;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= -640.49999999999989 then
            begin
                if features[180] <= -4465.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0026218478762623817;
                    end
                    else
                    begin
                        Result := -0.016301448409032828;
                    end;
                end
                else
                begin
                    if features[174] <= -5397.4999999999991 then
                    begin
                        Result := 0.056067100700614936;
                    end
                    else
                    begin
                        Result := 0.00029603139804965925;
                    end;
                end;
            end
            else
            begin
                if features[179] <= -3792.4999999999995 then
                begin
                    if features[222] <= -4486.4999999999991 then
                    begin
                        Result := -0.00025197777756757767;
                    end
                    else
                    begin
                        Result := 0.0047338924446517217;
                    end;
                end
                else
                begin
                    if features[105] <= 1.5000000000000002 then
                    begin
                        Result := -0.014712876988007276;
                    end
                    else
                    begin
                        Result := 0.016003315201161078;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_196(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1344.4999999999998 then
    begin
        if features[28] <= -9010.4999999999982 then
        begin
            Result := 0.028287554256022841;
        end
        else
        begin
            Result := -0.020949962760974418;
        end;
    end
    else
    begin
        if features[94] <= -155228.99999999997 then
        begin
            if features[226] <= 124.50000000000001 then
            begin
                if features[224] <= -3910.4999999999995 then
                begin
                    if features[164] <= 347888976.00000006 then
                    begin
                        Result := 0.0017194375415904711;
                    end
                    else
                    begin
                        Result := 0.028687557434969532;
                    end;
                end
                else
                begin
                    Result := -0.018973746285813536;
                end;
            end
            else
            begin
                if features[173] <= -6262.4999999999991 then
                begin
                    Result := -0.0041938000661178275;
                end
                else
                begin
                    Result := 0.024649830904280023;
                end;
            end;
        end
        else
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                if features[173] <= -6747.4999999999991 then
                begin
                    if features[108] <= -628.49999999999989 then
                    begin
                        Result := 0.028654643241970597;
                    end
                    else
                    begin
                        Result := 0.0073634600943772513;
                    end;
                end
                else
                begin
                    if features[184] <= 514.50000000000011 then
                    begin
                        Result := 1.1548702823204561E-05;
                    end
                    else
                    begin
                        Result := 0.012191879017229665;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -1.0000000180025095E-35 then
                begin
                    if features[217] <= -1016.4999999999999 then
                    begin
                        Result := -0.020223444859338531;
                    end
                    else
                    begin
                        Result := -0.0061801664020141762;
                    end;
                end
                else
                begin
                    if features[91] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0034608491490258466;
                    end
                    else
                    begin
                        Result := -0.0074254620076759613;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_197(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1069.4999999999998 then
    begin
        if features[90] <= 2.5000000000000004 then
        begin
            Result := -0.010558081989969577;
        end
        else
        begin
            Result := 0.01933305721660044;
        end;
    end
    else
    begin
        if features[218] <= -4444.4999999999991 then
        begin
            if features[166] <= -31727439.999999996 then
            begin
                if features[217] <= -146.49999999999997 then
                begin
                    if features[173] <= -2977.9999999999995 then
                    begin
                        Result := 0.00050672928945930487;
                    end
                    else
                    begin
                        Result := 0.050605171567132769;
                    end;
                end
                else
                begin
                    if features[217] <= -100.49999999999999 then
                    begin
                        Result := -0.022398837546125466;
                    end
                    else
                    begin
                        Result := -0.0024857934275387419;
                    end;
                end;
            end
            else
            begin
                if features[177] <= -5788.4999999999991 then
                begin
                    if features[109] <= -452.49999999999994 then
                    begin
                        Result := 0.015696787101351421;
                    end
                    else
                    begin
                        Result := 0.0035681886697299966;
                    end;
                end
                else
                begin
                    if features[178] <= -235.49999999999997 then
                    begin
                        Result := -0.021433600702791062;
                    end
                    else
                    begin
                        Result := -0.00063635441903817178;
                    end;
                end;
            end;
        end
        else
        begin
            if features[217] <= -715.49999999999989 then
            begin
                Result := -0.0054334583439188122;
            end
            else
            begin
                if features[184] <= -770.49999999999989 then
                begin
                    if features[48] <= 11550.500000000002 then
                    begin
                        Result := -0.012317126723840402;
                    end
                    else
                    begin
                        Result := 0.014255445618744825;
                    end;
                end
                else
                begin
                    if features[177] <= -6233.4999999999991 then
                    begin
                        Result := -0.0032554011313222306;
                    end
                    else
                    begin
                        Result := 0.01311227771729717;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_198(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[227] <= -3219.4999999999995 then
    begin
        if features[228] <= -3976.4999999999995 then
        begin
            if features[117] <= -617.49999999999989 then
            begin
                if features[123] <= -666.49999999999989 then
                begin
                    if features[173] <= -4074.4999999999995 then
                    begin
                        Result := -0.0047126733462855936;
                    end
                    else
                    begin
                        Result := 0.051144346844437472;
                    end;
                end
                else
                begin
                    if features[222] <= -4139.4999999999991 then
                    begin
                        Result := -0.019570293976816908;
                    end
                    else
                    begin
                        Result := 0.015873654994098083;
                    end;
                end;
            end
            else
            begin
                if features[48] <= 23447.000000000004 then
                begin
                    if features[154] <= 19.500000000000004 then
                    begin
                        Result := 0.00055903690543347739;
                    end
                    else
                    begin
                        Result := -0.0037250671559659679;
                    end;
                end
                else
                begin
                    if features[170] <= 4.5000000000000009 then
                    begin
                        Result := 0.017207378885881999;
                    end
                    else
                    begin
                        Result := -0.0066171503154482366;
                    end;
                end;
            end;
        end
        else
        begin
            if features[223] <= -634.49999999999989 then
            begin
                Result := 0.027819863948750568;
            end
            else
            begin
                if features[227] <= -3873.4999999999995 then
                begin
                    Result := 0.011196762093156976;
                end
                else
                begin
                    if features[174] <= -4070.4999999999995 then
                    begin
                        Result := -0.00080877378626493905;
                    end
                    else
                    begin
                        Result := 0.015170944957060528;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[174] <= -3592.9999999999995 then
        begin
            if features[229] <= -179.49999999999997 then
            begin
                Result := -0.019530652497862545;
            end
            else
            begin
                Result := 0.0039259934434709527;
            end;
        end
        else
        begin
            Result := 0.031293689870052578;
        end;
    end;
end;

function bidirectional_tree_199(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[179] <= -3792.4999999999995 then
    begin
        if features[225] <= -4535.4999999999991 then
        begin
            if features[166] <= -416537119.99999994 then
            begin
                Result := -0.017138754378668252;
            end
            else
            begin
                if features[66] <= 413.50000000000006 then
                begin
                    if features[154] <= 19.500000000000004 then
                    begin
                        Result := 0.00079701532735364971;
                    end
                    else
                    begin
                        Result := -0.0036247680495706484;
                    end;
                end
                else
                begin
                    if features[183] <= -5125.4999999999991 then
                    begin
                        Result := -0.0142127127249054;
                    end
                    else
                    begin
                        Result := 0.02071223346531946;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= -619.49999999999989 then
            begin
                if features[223] <= -1194.4999999999998 then
                begin
                    if features[227] <= -3596.4999999999995 then
                    begin
                        Result := 0.063804994184294278;
                    end
                    else
                    begin
                        Result := -0.010057467462916093;
                    end;
                end
                else
                begin
                    Result := -0.015835226506537885;
                end;
            end
            else
            begin
                if features[220] <= -1354.4999999999998 then
                begin
                    if features[186] <= -145.41666412353513 then
                    begin
                        Result := 0.057561861415734689;
                    end
                    else
                    begin
                        Result := 0.0068210392227320369;
                    end;
                end
                else
                begin
                    if features[176] <= -4825.4999999999991 then
                    begin
                        Result := 0.0065088227171139039;
                    end
                    else
                    begin
                        Result := -0.0016785991327530865;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[185] <= -281.87499999999994 then
        begin
            Result := -0.017892621556933115;
        end
        else
        begin
            if features[153] <= -86.499999999999986 then
            begin
                Result := 0.043014107998100626;
            end
            else
            begin
                Result := -0.0049618103217978424;
            end;
        end;
    end;
end;

function bidirectional_tree_200(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -344168303.99999994 then
    begin
        Result := -0.0091038194434097698;
    end
    else
    begin
        if features[176] <= -4845.4999999999991 then
        begin
            if features[108] <= -649.49999999999989 then
            begin
                if features[224] <= -6181.4999999999991 then
                begin
                    Result := -0.0096573015322679607;
                end
                else
                begin
                    if features[173] <= -5671.4999999999991 then
                    begin
                        Result := 0.01925414523368502;
                    end
                    else
                    begin
                        Result := 0.0050747259325171264;
                    end;
                end;
            end
            else
            begin
                if features[173] <= -3070.4999999999995 then
                begin
                    if features[219] <= -5550.4999999999991 then
                    begin
                        Result := -0.0017510679165932388;
                    end
                    else
                    begin
                        Result := 0.0029376859263454736;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.016768287052182505;
                    end
                    else
                    begin
                        Result := 0.016772446799014008;
                    end;
                end;
            end;
        end
        else
        begin
            if features[220] <= 64.500000000000014 then
            begin
                if features[109] <= -192.49999999999997 then
                begin
                    if features[173] <= -5527.4999999999991 then
                    begin
                        Result := 0.0099492799176066089;
                    end
                    else
                    begin
                        Result := -0.0077279620577702414;
                    end;
                end
                else
                begin
                    if features[217] <= 798.50000000000011 then
                    begin
                        Result := 0.0039948621256701801;
                    end
                    else
                    begin
                        Result := 0.028624519990651839;
                    end;
                end;
            end
            else
            begin
                if features[218] <= -4529.4999999999991 then
                begin
                    Result := -0.015651456008282005;
                end
                else
                begin
                    if features[72] <= 838.50000000000011 then
                    begin
                        Result := 0.027058200217351547;
                    end
                    else
                    begin
                        Result := -0.0018772475800804299;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_201(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= 136.50000000000003 then
    begin
        if features[220] <= 101.50000000000001 then
        begin
            if features[180] <= -5224.4999999999991 then
            begin
                if features[129] <= 13945.000000000002 then
                begin
                    if features[70] <= 861.50000000000011 then
                    begin
                        Result := 0.00080905468245319142;
                    end
                    else
                    begin
                        Result := -0.0047224797299046765;
                    end;
                end
                else
                begin
                    if features[220] <= -488.49999999999994 then
                    begin
                        Result := 0.01444143097867516;
                    end
                    else
                    begin
                        Result := -0.0016187143863651298;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -5809.4999999999991 then
                begin
                    if features[174] <= -5069.4999999999991 then
                    begin
                        Result := 0.051285873519273162;
                    end
                    else
                    begin
                        Result := 0.0044046591267485327;
                    end;
                end
                else
                begin
                    if features[187] <= -87.22499847412108 then
                    begin
                        Result := 0.024105759007958975;
                    end
                    else
                    begin
                        Result := 0.0016147594165232114;
                    end;
                end;
            end;
        end
        else
        begin
            if features[41] <= 1414.5000000000002 then
            begin
                Result := -0.0070456375062951859;
            end
            else
            begin
                if features[216] <= -4766.4999999999991 then
                begin
                    Result := -0.0069777252516046084;
                end
                else
                begin
                    Result := 0.022899268741198464;
                end;
            end;
        end;
    end
    else
    begin
        if features[46] <= 10.500000000000002 then
        begin
            if features[220] <= -782.49999999999989 then
            begin
                Result := 0.03019963029537643;
            end
            else
            begin
                Result := -0.0006886511626686305;
            end;
        end
        else
        begin
            if features[225] <= -5593.4999999999991 then
            begin
                Result := -0.00053062199022786834;
            end
            else
            begin
                Result := 0.011092593966608695;
            end;
        end;
    end;
end;

function bidirectional_tree_202(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[179] <= -3544.4999999999995 then
    begin
        if features[154] <= 19.500000000000004 then
        begin
            if features[128] <= -378.49999999999994 then
            begin
                if features[105] <= 1.0000000180025095E-35 then
                begin
                    if features[124] <= 35.500000000000007 then
                    begin
                        Result := 0.00069362939404665454;
                    end
                    else
                    begin
                        Result := 0.01146130822357324;
                    end;
                end
                else
                begin
                    if features[180] <= -5224.4999999999991 then
                    begin
                        Result := -0.0087390322556505553;
                    end
                    else
                    begin
                        Result := 0.0092307197685031032;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 260.50000000000006 then
                begin
                    if features[14] <= 152965072.00000003 then
                    begin
                        Result := 0.00067523078534476413;
                    end
                    else
                    begin
                        Result := 0.0085127466738568816;
                    end;
                end
                else
                begin
                    if features[186] <= -318.83332824707026 then
                    begin
                        Result := -0.0043133530230180595;
                    end
                    else
                    begin
                        Result := 0.010229047839616694;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -5948.4999999999991 then
            begin
                if features[70] <= 957.50000000000011 then
                begin
                    Result := -0.012167651909973133;
                end
                else
                begin
                    Result := 0.0025182264058461316;
                end;
            end
            else
            begin
                if features[184] <= -419.49999999999994 then
                begin
                    if features[148] <= -1109.4999999999998 then
                    begin
                        Result := -0.008625054210006193;
                    end
                    else
                    begin
                        Result := 0.0091358438439460895;
                    end;
                end
                else
                begin
                    if features[0] <= 156752.50000000003 then
                    begin
                        Result := -0.0094453261819369624;
                    end
                    else
                    begin
                        Result := 0.0040791816935240666;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.013443722468090042;
    end;
end;

function bidirectional_tree_203(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[147] <= -195.49999999999997 then
    begin
        if features[215] <= -5111.4999999999991 then
        begin
            Result := 0.01529153689514548;
        end
        else
        begin
            if features[28] <= -4839.4999999999991 then
            begin
                if features[173] <= -3752.4999999999995 then
                begin
                    Result := -0.0067114598106148837;
                end
                else
                begin
                    Result := 0.017900966568408682;
                end;
            end
            else
            begin
                Result := 0.025536553277712967;
            end;
        end;
    end
    else
    begin
        if features[124] <= -403.99999999999994 then
        begin
            if features[220] <= 55.500000000000007 then
            begin
                if features[229] <= -352.49999999999994 then
                begin
                    Result := -0.018028041853968644;
                end
                else
                begin
                    if features[183] <= -5812.4999999999991 then
                    begin
                        Result := -0.0082129449261500887;
                    end
                    else
                    begin
                        Result := 0.023667991046865497;
                    end;
                end;
            end
            else
            begin
                Result := -0.022691537242308615;
            end;
        end
        else
        begin
            if features[176] <= -4377.4999999999991 then
            begin
                if features[129] <= -26634.999999999996 then
                begin
                    if features[222] <= -5855.4999999999991 then
                    begin
                        Result := -0.024505457210685349;
                    end
                    else
                    begin
                        Result := -0.0035956391832789531;
                    end;
                end
                else
                begin
                    if features[47] <= 22224.000000000004 then
                    begin
                        Result := 0.00018445645469620416;
                    end
                    else
                    begin
                        Result := 0.0080771812870548253;
                    end;
                end;
            end
            else
            begin
                if features[184] <= -534.49999999999989 then
                begin
                    if features[216] <= -6395.4999999999991 then
                    begin
                        Result := 0.012737731046224197;
                    end
                    else
                    begin
                        Result := -0.014748894681255689;
                    end;
                end
                else
                begin
                    Result := 0.0022672036958099203;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_204(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[227] <= -3219.4999999999995 then
    begin
        if features[228] <= -3405.4999999999995 then
        begin
            if features[221] <= -3007.4999999999995 then
            begin
                if features[129] <= -28181.999999999996 then
                begin
                    if features[175] <= -300.49999999999994 then
                    begin
                        Result := -0.018991135017725556;
                    end
                    else
                    begin
                        Result := -0.0020907933296542051;
                    end;
                end
                else
                begin
                    if features[179] <= -3544.4999999999995 then
                    begin
                        Result := 0.00021124873165037029;
                    end
                    else
                    begin
                        Result := -0.016535204756614272;
                    end;
                end;
            end
            else
            begin
                if features[36] <= 715.50000000000011 then
                begin
                    if features[182] <= -5293.4999999999991 then
                    begin
                        Result := -0.021090305595103553;
                    end
                    else
                    begin
                        Result := 0.020906693653613272;
                    end;
                end
                else
                begin
                    if features[170] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.00081545170149009477;
                    end
                    else
                    begin
                        Result := 0.081914397083590842;
                    end;
                end;
            end;
        end
        else
        begin
            if features[179] <= -4024.4999999999995 then
            begin
                Result := 0.016733371634846509;
            end
            else
            begin
                Result := -0.01346528722529688;
            end;
        end;
    end
    else
    begin
        if features[229] <= -179.49999999999997 then
        begin
            if features[174] <= -3120.9999999999995 then
            begin
                Result := -0.018404150751642638;
            end
            else
            begin
                Result := 0.03683393258296986;
            end;
        end
        else
        begin
            if features[164] <= 393846032.00000006 then
            begin
                if features[36] <= 663.50000000000011 then
                begin
                    Result := 0.0;
                end
                else
                begin
                    Result := 0.040755015251643628;
                end;
            end
            else
            begin
                Result := -0.0071106470469027884;
            end;
        end;
    end;
end;

function bidirectional_tree_205(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        Result := -0.017039692331231933;
    end
    else
    begin
        if features[216] <= -7164.9999999999991 then
        begin
            if features[70] <= 747.50000000000011 then
            begin
                if features[47] <= 3986.5000000000005 then
                begin
                    Result := -0.0039159537381845194;
                end
                else
                begin
                    Result := 0.032566706301599649;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[215] <= -5119.4999999999991 then
                    begin
                        Result := 0.0042170885681688678;
                    end
                    else
                    begin
                        Result := 0.035151396574663644;
                    end;
                end
                else
                begin
                    if features[175] <= -1295.4999999999998 then
                    begin
                        Result := 0.0064186294681766306;
                    end
                    else
                    begin
                        Result := -0.017262902095315624;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= -645.49999999999989 then
            begin
                if features[174] <= -3120.9999999999995 then
                begin
                    if features[227] <= -3800.4999999999995 then
                    begin
                        Result := -0.0020453627554361665;
                    end
                    else
                    begin
                        Result := -0.0150284766802216;
                    end;
                end
                else
                begin
                    if features[186] <= -464.83332824707026 then
                    begin
                        Result := 0.087669133220745987;
                    end
                    else
                    begin
                        Result := 0.0016864269652027957;
                    end;
                end;
            end
            else
            begin
                if features[1] <= -36874.499999999993 then
                begin
                    if features[95] <= -149748583.99999997 then
                    begin
                        Result := 0.040357797854141425;
                    end
                    else
                    begin
                        Result := 0.0035263124033429725;
                    end;
                end
                else
                begin
                    if features[175] <= -2028.4999999999998 then
                    begin
                        Result := 0.0061069485684249903;
                    end
                    else
                    begin
                        Result := -0.00052641236697184438;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_206(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[215] <= -3285.4999999999995 then
    begin
        if features[166] <= -48176933.999999993 then
        begin
            if features[151] <= 52.500000000000007 then
            begin
                if features[81] <= -221.49999999999997 then
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.00098147301814504738;
                    end
                    else
                    begin
                        Result := -0.0079653406043645094;
                    end;
                end
                else
                begin
                    if features[96] <= -6916047.9999999991 then
                    begin
                        Result := 0.0071505892930542464;
                    end
                    else
                    begin
                        Result := -8.2557165952220271E-05;
                    end;
                end;
            end
            else
            begin
                if features[221] <= -5459.4999999999991 then
                begin
                    Result := -0.014486615330505145;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.011591767773616982;
                    end
                    else
                    begin
                        Result := -0.010690547975167955;
                    end;
                end;
            end;
        end
        else
        begin
            if features[81] <= 6595.5000000000009 then
            begin
                if features[136] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.0049314702405033719;
                end
                else
                begin
                    Result := 0.0034724376163596743;
                end;
            end
            else
            begin
                if features[176] <= -5023.4999999999991 then
                begin
                    if features[67] <= 2955.5000000000005 then
                    begin
                        Result := 0.0098271762272594786;
                    end
                    else
                    begin
                        Result := 0.030256254203947675;
                    end;
                end
                else
                begin
                    if features[178] <= -2006.4999999999998 then
                    begin
                        Result := 0.022533895551287597;
                    end
                    else
                    begin
                        Result := -0.017638476448230106;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[58] <= 1.0000000180025095E-35 then
        begin
            Result := -0.01739235175608414;
        end
        else
        begin
            Result := 0.02455566314336978;
        end;
    end;
end;

function bidirectional_tree_207(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1806.4999999999998 then
    begin
        if features[61] <= 2.5000000000000004 then
        begin
            Result := -0.021305555363280028;
        end
        else
        begin
            Result := 0.031830845124302634;
        end;
    end
    else
    begin
        if features[129] <= -26634.999999999996 then
        begin
            if features[66] <= -1068.9999999999998 then
            begin
                Result := 0.026168744483212093;
            end
            else
            begin
                if features[219] <= -4821.4999999999991 then
                begin
                    if features[215] <= -3476.4999999999995 then
                    begin
                        Result := -0.016428419618905326;
                    end
                    else
                    begin
                        Result := 0.022273903055788431;
                    end;
                end
                else
                begin
                    if features[45] <= 1.5000000000000002 then
                    begin
                        Result := -0.026186344811776414;
                    end
                    else
                    begin
                        Result := 0.014240648166609285;
                    end;
                end;
            end;
        end
        else
        begin
            if features[154] <= 19.500000000000004 then
            begin
                if features[229] <= 702.50000000000011 then
                begin
                    if features[220] <= 1060.5000000000002 then
                    begin
                        Result := 0.0011504096511860162;
                    end
                    else
                    begin
                        Result := -0.0097634116102968543;
                    end;
                end
                else
                begin
                    if features[27] <= -6347.4999999999991 then
                    begin
                        Result := 0.03374560459175259;
                    end
                    else
                    begin
                        Result := 0.0092569532792119887;
                    end;
                end;
            end
            else
            begin
                if features[221] <= -5953.4999999999991 then
                begin
                    if features[166] <= -112029371.99999999 then
                    begin
                        Result := -0.023021267215753559;
                    end
                    else
                    begin
                        Result := -0.0051791914467241313;
                    end;
                end
                else
                begin
                    if features[148] <= -1109.4999999999998 then
                    begin
                        Result := -0.0061835098301057517;
                    end
                    else
                    begin
                        Result := 0.0019263280410286793;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_208(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        Result := -0.016750577855868698;
    end
    else
    begin
        if features[96] <= -283994191.99999994 then
        begin
            if features[29] <= -5705.4999999999991 then
            begin
                if features[219] <= -6053.4999999999991 then
                begin
                    Result := -0.02062959938128564;
                end
                else
                begin
                    if features[179] <= -6772.4999999999991 then
                    begin
                        Result := 0.065533825214354913;
                    end
                    else
                    begin
                        Result := 0.0;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -4154.4999999999991 then
                begin
                    if features[82] <= -83050.499999999985 then
                    begin
                        Result := 0.14527683012141418;
                    end
                    else
                    begin
                        Result := 0.023902732530755672;
                    end;
                end
                else
                begin
                    Result := -0.012583764672190689;
                end;
            end;
        end
        else
        begin
            if features[226] <= 891.50000000000011 then
            begin
                if features[145] <= 1418.0000000000002 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.00027214537824749415;
                    end
                    else
                    begin
                        Result := 0.0057581148717292035;
                    end;
                end
                else
                begin
                    if features[65] <= 1943.5000000000002 then
                    begin
                        Result := -0.022483648826866074;
                    end
                    else
                    begin
                        Result := 0.00042567110850904704;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -5045.4999999999991 then
                begin
                    if features[228] <= -4735.4999999999991 then
                    begin
                        Result := 0.00078941071108832531;
                    end
                    else
                    begin
                        Result := 0.024254674732111618;
                    end;
                end
                else
                begin
                    if features[176] <= -4521.4999999999991 then
                    begin
                        Result := -0.035624136236093208;
                    end
                    else
                    begin
                        Result := 0.0075206394846255714;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_209(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[179] <= -3617.4999999999995 then
    begin
        if features[94] <= -155228.99999999997 then
        begin
            if features[226] <= 10.500000000000002 then
            begin
                if features[39] <= 1546.5000000000002 then
                begin
                    Result := 0.010336813138580156;
                end
                else
                begin
                    Result := -0.0060035927211156996;
                end;
            end
            else
            begin
                if features[70] <= 809.50000000000011 then
                begin
                    Result := -0.0058010092220977874;
                end
                else
                begin
                    Result := 0.020554786460837186;
                end;
            end;
        end
        else
        begin
            if features[82] <= -171308.49999999997 then
            begin
                if features[183] <= -5566.4999999999991 then
                begin
                    if features[60] <= 4.5000000000000009 then
                    begin
                        Result := -0.012444954248950674;
                    end
                    else
                    begin
                        Result := 0.036843095707487575;
                    end;
                end
                else
                begin
                    if features[217] <= 267.50000000000006 then
                    begin
                        Result := 0.0085046624442436432;
                    end
                    else
                    begin
                        Result := -0.017217869063922253;
                    end;
                end;
            end
            else
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    if features[173] <= -6747.4999999999991 then
                    begin
                        Result := 0.011247198057442981;
                    end
                    else
                    begin
                        Result := 0.00087915845281496662;
                    end;
                end
                else
                begin
                    if features[81] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0072635897023441438;
                    end
                    else
                    begin
                        Result := 0.0011481347347108428;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[185] <= -229.41666412353513 then
        begin
            Result := -0.021391478180235467;
        end
        else
        begin
            if features[47] <= 4933.5000000000009 then
            begin
                Result := 0.036794253181282273;
            end
            else
            begin
                Result := -0.0026041872652962858;
            end;
        end;
    end;
end;

function bidirectional_tree_210(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[118] <= -1.0000000180025095E-35 then
    begin
        if features[81] <= 1.0000000180025095E-35 then
        begin
            if features[216] <= -5414.4999999999991 then
            begin
                Result := 0.0069666469053391664;
            end
            else
            begin
                if features[108] <= 380.50000000000006 then
                begin
                    Result := -0.0049181396394031053;
                end
                else
                begin
                    Result := 0.022371922002470235;
                end;
            end;
        end
        else
        begin
            Result := 0.011545580279093632;
        end;
    end
    else
    begin
        if features[216] <= -4176.4999999999991 then
        begin
            if features[124] <= -21.499999999999996 then
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[94] <= -196735.49999999997 then
                    begin
                        Result := 0.0209047919932525;
                    end
                    else
                    begin
                        Result := -0.0030015655012998427;
                    end;
                end
                else
                begin
                    if features[225] <= -5280.4999999999991 then
                    begin
                        Result := -0.019147279356085803;
                    end
                    else
                    begin
                        Result := -0.0056756070780903233;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -7728.9999999999991 then
                begin
                    Result := 0.032478078154044208;
                end
                else
                begin
                    Result := -0.00043610190700599206;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[217] <= 893.50000000000011 then
                begin
                    Result := 0.010457022118256941;
                end
                else
                begin
                    Result := -0.016240920711855091;
                end;
            end
            else
            begin
                if features[0] <= 178661.00000000003 then
                begin
                    Result := 0.0040249728570145547;
                end
                else
                begin
                    if features[217] <= -185.49999999999997 then
                    begin
                        Result := -0.0079698910529530497;
                    end
                    else
                    begin
                        Result := 0.027041612539225719;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_211(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[179] <= -4084.4999999999995 then
    begin
        if features[185] <= -1288.2499999999998 then
        begin
            if features[222] <= -5601.4999999999991 then
            begin
                if features[41] <= 1558.5000000000002 then
                begin
                    Result := -0.0066066329496359023;
                end
                else
                begin
                    Result := 0.066819591506515258;
                end;
            end
            else
            begin
                if features[174] <= -5062.4999999999991 then
                begin
                    if features[73] <= 408.50000000000006 then
                    begin
                        Result := 0.078547938086018176;
                    end
                    else
                    begin
                        Result := 0.0056521609421041558;
                    end;
                end
                else
                begin
                    Result := 8.8451187432334855E-05;
                end;
            end;
        end
        else
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[81] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.00024415730190762379;
                end
                else
                begin
                    if features[176] <= -5367.4999999999991 then
                    begin
                        Result := 0.01644857627037705;
                    end
                    else
                    begin
                        Result := -0.0047778316756221439;
                    end;
                end;
            end
            else
            begin
                Result := -0.00057070809350268125;
            end;
        end;
    end
    else
    begin
        if features[185] <= -281.87499999999994 then
        begin
            Result := -0.015523899634003004;
        end
        else
        begin
            if features[223] <= -248.49999999999997 then
            begin
                if features[174] <= -4399.4999999999991 then
                begin
                    if features[151] <= -28.499999999999996 then
                    begin
                        Result := 0.042376109901982241;
                    end
                    else
                    begin
                        Result := -0.0030231228250092541;
                    end;
                end
                else
                begin
                    Result := -0.0087069544287365803;
                end;
            end
            else
            begin
                if features[227] <= -3052.4999999999995 then
                begin
                    Result := -0.015871494160888174;
                end
                else
                begin
                    Result := 0.024644791251382407;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_212(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[178] <= 70.500000000000014 then
    begin
        if features[227] <= -5492.4999999999991 then
        begin
            if features[36] <= 469.50000000000006 then
            begin
                if features[166] <= -88399803.999999985 then
                begin
                    if features[77] <= 20562.500000000004 then
                    begin
                        Result := -0.0089111855054185424;
                    end
                    else
                    begin
                        Result := 0.018086212298498758;
                    end;
                end
                else
                begin
                    if features[223] <= -975.49999999999989 then
                    begin
                        Result := 0.039338840273718229;
                    end
                    else
                    begin
                        Result := 0.00061136996445387761;
                    end;
                end;
            end
            else
            begin
                Result := -0.014150565766469654;
            end;
        end
        else
        begin
            if features[170] <= 4.5000000000000009 then
            begin
                if features[217] <= -698.99999999999989 then
                begin
                    Result := -0.0034908959016400087;
                end
                else
                begin
                    if features[82] <= 221.00000000000003 then
                    begin
                        Result := 0.0029720222379176833;
                    end
                    else
                    begin
                        Result := 0.010885823462767154;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -5172.4999999999991 then
                begin
                    Result := 0.0020072781434627251;
                end
                else
                begin
                    if features[176] <= -5003.4999999999991 then
                    begin
                        Result := -0.0024808339111522058;
                    end
                    else
                    begin
                        Result := -0.013252738356992935;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[121] <= -1144.4999999999998 then
        begin
            Result := -0.010931996070011505;
        end
        else
        begin
            if features[176] <= -5898.4999999999991 then
            begin
                Result := 0.0015766378991226395;
            end
            else
            begin
                if features[220] <= 391.50000000000006 then
                begin
                    Result := 0.014002419776590095;
                end
                else
                begin
                    Result := -0.0035514213182860806;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_213(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[216] <= -7297.4999999999991 then
    begin
        if features[70] <= 852.50000000000011 then
        begin
            if features[150] <= -16.499999999999996 then
            begin
                Result := 0.046549202489437801;
            end
            else
            begin
                if features[110] <= -785.49999999999989 then
                begin
                    if features[180] <= -7078.4999999999991 then
                    begin
                        Result := 0.038768843956307794;
                    end
                    else
                    begin
                        Result := -0.0054003824347622405;
                    end;
                end
                else
                begin
                    Result := 0.0045063994513171446;
                end;
            end;
        end
        else
        begin
            if features[176] <= -6330.4999999999991 then
            begin
                Result := -0.012743926548409182;
            end
            else
            begin
                Result := 0.0090628305608548339;
            end;
        end;
    end
    else
    begin
        if features[184] <= -1689.4999999999998 then
        begin
            Result := -0.012985888951518823;
        end
        else
        begin
            if features[108] <= -1311.4999999999998 then
            begin
                if features[222] <= -5592.4999999999991 then
                begin
                    if features[110] <= -547.49999999999989 then
                    begin
                        Result := -0.011372090133271694;
                    end
                    else
                    begin
                        Result := 0.080744690505107755;
                    end;
                end
                else
                begin
                    if features[148] <= -55.499999999999993 then
                    begin
                        Result := -0.0099449309895880793;
                    end
                    else
                    begin
                        Result := 0.05148636191817732;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -177.49999999999997 then
                begin
                    if features[75] <= 6.5000000000000009 then
                    begin
                        Result := -4.9325579565310558E-05;
                    end
                    else
                    begin
                        Result := -0.0069004085145245534;
                    end;
                end
                else
                begin
                    if features[27] <= -5925.4999999999991 then
                    begin
                        Result := 0.0065860270996813191;
                    end
                    else
                    begin
                        Result := -0.00025592493260195197;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_214(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[117] <= -587.49999999999989 then
    begin
        if features[180] <= -6037.4999999999991 then
        begin
            Result := -0.018732191580770642;
        end
        else
        begin
            if features[220] <= 431.50000000000006 then
            begin
                Result := 0.0046098393634490557;
            end
            else
            begin
                Result := -0.021505221283419501;
            end;
        end;
    end
    else
    begin
        if features[145] <= -521.99999999999989 then
        begin
            if features[222] <= -5449.4999999999991 then
            begin
                if features[180] <= -7670.4999999999991 then
                begin
                    Result := 0.021851745404479532;
                end
                else
                begin
                    Result := -0.014493705705942234;
                end;
            end
            else
            begin
                if features[215] <= -4693.4999999999991 then
                begin
                    if features[147] <= 10.500000000000002 then
                    begin
                        Result := 0.043908191767036683;
                    end
                    else
                    begin
                        Result := 0.011313670597361705;
                    end;
                end
                else
                begin
                    Result := 0.0065359797995354508;
                end;
            end;
        end
        else
        begin
            if features[13] <= -70432.999999999985 then
            begin
                if features[82] <= -226031.99999999997 then
                begin
                    Result := -0.017419252443967005;
                end
                else
                begin
                    if features[95] <= 23372564.000000004 then
                    begin
                        Result := 0.017697928044764416;
                    end
                    else
                    begin
                        Result := -0.012650342889580536;
                    end;
                end;
            end
            else
            begin
                if features[117] <= -488.49999999999994 then
                begin
                    if features[166] <= -33781211.999999993 then
                    begin
                        Result := 0.0051715603495446029;
                    end
                    else
                    begin
                        Result := 0.037487307545901807;
                    end;
                end
                else
                begin
                    if features[145] <= -440.49999999999994 then
                    begin
                        Result := -0.023594956288064236;
                    end
                    else
                    begin
                        Result := -0.00019185573876673062;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_215(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1806.4999999999998 then
    begin
        if features[227] <= -5786.4999999999991 then
        begin
            Result := 0.049521785038908958;
        end
        else
        begin
            Result := -0.022665145724278284;
        end;
    end
    else
    begin
        if features[229] <= 702.50000000000011 then
        begin
            if features[220] <= 1218.5000000000002 then
            begin
                if features[180] <= -4837.4999999999991 then
                begin
                    if features[148] <= -1168.4999999999998 then
                    begin
                        Result := -0.0031986056161531088;
                    end
                    else
                    begin
                        Result := 0.0009097814328195233;
                    end;
                end
                else
                begin
                    if features[185] <= 45.250000000000007 then
                    begin
                        Result := -0.00039936548286233811;
                    end
                    else
                    begin
                        Result := 0.018524067270819861;
                    end;
                end;
            end
            else
            begin
                if features[179] <= -6200.4999999999991 then
                begin
                    if features[73] <= 110.50000000000001 then
                    begin
                        Result := 0.021581453854476029;
                    end
                    else
                    begin
                        Result := -0.0056274966044869658;
                    end;
                end
                else
                begin
                    if features[69] <= 14.500000000000002 then
                    begin
                        Result := -0.014787027935155687;
                    end
                    else
                    begin
                        Result := -0.03946644896527176;
                    end;
                end;
            end;
        end
        else
        begin
            if features[27] <= -6245.4999999999991 then
            begin
                Result := 0.028949957134388277;
            end
            else
            begin
                if features[225] <= -5314.4999999999991 then
                begin
                    if features[81] <= -8575.4999999999982 then
                    begin
                        Result := -0.031877707768688042;
                    end
                    else
                    begin
                        Result := 0.00026343887325477021;
                    end;
                end
                else
                begin
                    if features[183] <= -6121.4999999999991 then
                    begin
                        Result := 0.024295682040831695;
                    end
                    else
                    begin
                        Result := 0.0015493750887969246;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_216(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1033.4999999999998 then
    begin
        Result := -0.012053911954636596;
    end
    else
    begin
        if features[118] <= -1.0000000180025095E-35 then
        begin
            if features[81] <= 1.0000000180025095E-35 then
            begin
                if features[216] <= -5414.4999999999991 then
                begin
                    if features[220] <= -1150.4999999999998 then
                    begin
                        Result := 0.029609460391339368;
                    end
                    else
                    begin
                        Result := 0.0057488186496344193;
                    end;
                end
                else
                begin
                    if features[185] <= 244.25000000000003 then
                    begin
                        Result := -0.0045570138089727789;
                    end
                    else
                    begin
                        Result := 0.019606002488750766;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -5367.4999999999991 then
                begin
                    if features[67] <= 3862.5000000000005 then
                    begin
                        Result := 0.013929418467506716;
                    end
                    else
                    begin
                        Result := 0.042196644318235152;
                    end;
                end
                else
                begin
                    if features[0] <= 140422.00000000003 then
                    begin
                        Result := -0.011358785562884791;
                    end
                    else
                    begin
                        Result := 0.018986650187958538;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= -125.49999999999999 then
            begin
                if features[164] <= -95938383.999999985 then
                begin
                    Result := -0.0096647881430686877;
                end
                else
                begin
                    if features[96] <= -283994191.99999994 then
                    begin
                        Result := 0.047398400322691055;
                    end
                    else
                    begin
                        Result := -0.0012755446533528373;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -5888.4999999999991 then
                begin
                    Result := 0.007978331501838588;
                end
                else
                begin
                    if features[224] <= -6408.4999999999991 then
                    begin
                        Result := -0.010911685490433703;
                    end
                    else
                    begin
                        Result := 0.0010312066647859034;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_217(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[174] <= -3967.4999999999995 then
    begin
        if features[227] <= -3219.4999999999995 then
        begin
            if features[228] <= -4280.4999999999991 then
            begin
                if features[173] <= -3974.4999999999995 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0015692050657220881;
                    end
                    else
                    begin
                        Result := -0.0034508463058522906;
                    end;
                end
                else
                begin
                    if features[185] <= 93.250000000000014 then
                    begin
                        Result := -0.0094594115247880022;
                    end
                    else
                    begin
                        Result := 0.010851588312216739;
                    end;
                end;
            end
            else
            begin
                if features[96] <= -255970343.99999997 then
                begin
                    if features[43] <= 365.50000000000006 then
                    begin
                        Result := 0.088996244244951103;
                    end
                    else
                    begin
                        Result := 0.00020604997815915635;
                    end;
                end
                else
                begin
                    Result := 0.0029864361564371721;
                end;
            end;
        end
        else
        begin
            if features[229] <= -179.49999999999997 then
            begin
                Result := -0.01763617860334827;
            end
            else
            begin
                Result := 0.0034850817294459187;
            end;
        end;
    end
    else
    begin
        if features[171] <= 1.0000000180025095E-35 then
        begin
            if features[219] <= -5453.4999999999991 then
            begin
                Result := 0.037102205163743733;
            end
            else
            begin
                Result := 0.0051956561792858413;
            end;
        end
        else
        begin
            if features[216] <= -5037.4999999999991 then
            begin
                Result := -0.010636626937661257;
            end
            else
            begin
                if features[165] <= 560746496.00000012 then
                begin
                    Result := 0.0026188466610125023;
                end
                else
                begin
                    if features[178] <= -919.49999999999989 then
                    begin
                        Result := -0.022407233527379208;
                    end
                    else
                    begin
                        Result := 0.037634400417430595;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_218(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1421.4999999999998 then
    begin
        if features[184] <= -3610.9999999999995 then
        begin
            if features[77] <= 4937.5000000000009 then
            begin
                Result := -0.010528010507082469;
            end
            else
            begin
                Result := 0.077757828830242195;
            end;
        end
        else
        begin
            Result := -0.016704433610645924;
        end;
    end
    else
    begin
        if features[90] <= 8.5000000000000018 then
        begin
            if features[66] <= 258.00000000000006 then
            begin
                if features[158] <= 1666.5000000000002 then
                begin
                    if features[221] <= -2941.4999999999995 then
                    begin
                        Result := -0.0015373998119855084;
                    end
                    else
                    begin
                        Result := 0.025694678246239111;
                    end;
                end
                else
                begin
                    if features[47] <= 8737.5000000000018 then
                    begin
                        Result := -0.00065614797254020954;
                    end
                    else
                    begin
                        Result := 0.0047874427399916125;
                    end;
                end;
            end
            else
            begin
                if features[151] <= -24.499999999999996 then
                begin
                    if features[39] <= 1537.5000000000002 then
                    begin
                        Result := -0.02175504672657539;
                    end
                    else
                    begin
                        Result := 0.0052197877945134551;
                    end;
                end
                else
                begin
                    if features[150] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.029071918003654437;
                    end
                    else
                    begin
                        Result := -0.0091469063112379033;
                    end;
                end;
            end;
        end
        else
        begin
            if features[156] <= -1.0000000180025095E-35 then
            begin
                Result := 0.022528464643228562;
            end
            else
            begin
                if features[216] <= -4015.9999999999995 then
                begin
                    if features[221] <= -6254.4999999999991 then
                    begin
                        Result := 0.018161455266678988;
                    end
                    else
                    begin
                        Result := -0.0037970458060151932;
                    end;
                end
                else
                begin
                    Result := 0.026535892448638451;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_219(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[215] <= -3285.4999999999995 then
    begin
        if features[215] <= -3510.4999999999995 then
        begin
            if features[176] <= -4760.4999999999991 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[173] <= -4215.4999999999991 then
                    begin
                        Result := 0.0031496086942007836;
                    end
                    else
                    begin
                        Result := -0.004105435392529627;
                    end;
                end
                else
                begin
                    if features[173] <= -4168.9999999999991 then
                    begin
                        Result := -0.0040100237084306697;
                    end
                    else
                    begin
                        Result := 0.0063582651374617313;
                    end;
                end;
            end
            else
            begin
                if features[108] <= -119.49999999999999 then
                begin
                    if features[216] <= -6293.4999999999991 then
                    begin
                        Result := 0.010813949144262786;
                    end
                    else
                    begin
                        Result := -0.0087435237142860691;
                    end;
                end
                else
                begin
                    if features[223] <= -634.49999999999989 then
                    begin
                        Result := 0.032906201408702228;
                    end
                    else
                    begin
                        Result := 0.0010732495620494925;
                    end;
                end;
            end;
        end
        else
        begin
            if features[180] <= -5782.4999999999991 then
            begin
                if features[217] <= -823.49999999999989 then
                begin
                    if features[36] <= 720.50000000000011 then
                    begin
                        Result := -0.019570662935867067;
                    end
                    else
                    begin
                        Result := 0.029202459963979202;
                    end;
                end
                else
                begin
                    Result := 0.0083950729571325485;
                end;
            end
            else
            begin
                if features[28] <= -6145.4999999999991 then
                begin
                    Result := -0.010933158618591433;
                end
                else
                begin
                    Result := 0.032498868927460643;
                end;
            end;
        end;
    end
    else
    begin
        if features[171] <= 2.5000000000000004 then
        begin
            Result := 0.008725762700247032;
        end
        else
        begin
            Result := -0.019082462323729982;
        end;
    end;
end;

function bidirectional_tree_220(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[129] <= -28181.999999999996 then
    begin
        Result := -0.0091451617127855395;
    end
    else
    begin
        if features[69] <= 4.5000000000000009 then
        begin
            if features[229] <= 787.50000000000011 then
            begin
                if features[229] <= -663.49999999999989 then
                begin
                    if features[177] <= -5591.4999999999991 then
                    begin
                        Result := -0.0098687680996689658;
                    end
                    else
                    begin
                        Result := 0.017219474189372041;
                    end;
                end
                else
                begin
                    if features[220] <= -116.49999999999999 then
                    begin
                        Result := 0.0045990058463174742;
                    end
                    else
                    begin
                        Result := -0.00047405529880357647;
                    end;
                end;
            end
            else
            begin
                if features[224] <= -7201.9999999999991 then
                begin
                    Result := -0.014289339217728639;
                end
                else
                begin
                    Result := 0.022223203766707559;
                end;
            end;
        end
        else
        begin
            if features[124] <= -166.49999999999997 then
            begin
                if features[216] <= -4062.4999999999995 then
                begin
                    if features[148] <= -1132.4999999999998 then
                    begin
                        Result := -0.014021387240840982;
                    end
                    else
                    begin
                        Result := 0.0;
                    end;
                end
                else
                begin
                    if features[220] <= 550.50000000000011 then
                    begin
                        Result := 0.016320152364186605;
                    end
                    else
                    begin
                        Result := -0.01725399915801808;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -4845.4999999999991 then
                begin
                    if features[109] <= -464.49999999999994 then
                    begin
                        Result := 0.0072838215481352804;
                    end
                    else
                    begin
                        Result := -0.00034086571285413231;
                    end;
                end
                else
                begin
                    if features[220] <= 283.50000000000006 then
                    begin
                        Result := -0.0023547604757002865;
                    end
                    else
                    begin
                        Result := -0.016267023794135652;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_221(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[176] <= -4760.4999999999991 then
    begin
        if features[226] <= -130.49999999999997 then
        begin
            if features[75] <= 5.5000000000000009 then
            begin
                if features[110] <= -942.49999999999989 then
                begin
                    if features[164] <= -18965168.999999996 then
                    begin
                        Result := -0.0015318029040244465;
                    end
                    else
                    begin
                        Result := 0.028655353064529515;
                    end;
                end
                else
                begin
                    if features[76] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.013661044710927321;
                    end
                    else
                    begin
                        Result := 0.0019118601502824029;
                    end;
                end;
            end
            else
            begin
                if features[158] <= 775.00000000000011 then
                begin
                    Result := 0.00014777084165287324;
                end
                else
                begin
                    if features[228] <= -5999.4999999999991 then
                    begin
                        Result := 0.0050678452972552617;
                    end
                    else
                    begin
                        Result := -0.0092231481666258698;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -6356.4999999999991 then
            begin
                Result := -0.0070314563171205539;
            end
            else
            begin
                if features[27] <= -5961.4999999999991 then
                begin
                    Result := 0.0099768482959646469;
                end
                else
                begin
                    if features[228] <= -4491.4999999999991 then
                    begin
                        Result := 0.0;
                    end
                    else
                    begin
                        Result := 0.0063155906325603446;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[181] <= -376.49999999999994 then
        begin
            Result := -0.0075900933409483277;
        end
        else
        begin
            if features[220] <= -398.49999999999994 then
            begin
                Result := 0.012990961777431243;
            end
            else
            begin
                if features[15] <= -94571291.999999985 then
                begin
                    Result := 0.021938750244735846;
                end
                else
                begin
                    Result := -0.0062603840940603193;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_222(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[225] <= -3627.4999999999995 then
    begin
        if features[224] <= -3437.4999999999995 then
        begin
            if features[129] <= -28181.999999999996 then
            begin
                if features[219] <= -4688.4999999999991 then
                begin
                    if features[165] <= 434197968.00000006 then
                    begin
                        Result := -0.017475977180556681;
                    end
                    else
                    begin
                        Result := 0.0054693762567864729;
                    end;
                end
                else
                begin
                    if features[165] <= 407113472.00000006 then
                    begin
                        Result := 0.030614195462270701;
                    end
                    else
                    begin
                        Result := -0.008956429138869312;
                    end;
                end;
            end
            else
            begin
                if features[93] <= 1.0000000180025095E-35 then
                begin
                    if features[13] <= -70432.999999999985 then
                    begin
                        Result := 0.013251652148060842;
                    end
                    else
                    begin
                        Result := 0.00054382002069736123;
                    end;
                end
                else
                begin
                    if features[225] <= -5348.4999999999991 then
                    begin
                        Result := -0.010621592145632901;
                    end
                    else
                    begin
                        Result := 0.0019525228365331545;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -6897.4999999999991 then
            begin
                Result := 0.030523080913085476;
            end
            else
            begin
                Result := -0.015906477218271212;
            end;
        end;
    end
    else
    begin
        if features[27] <= -4237.4999999999991 then
        begin
            Result := 0.020419891945547664;
        end
        else
        begin
            if features[220] <= -390.49999999999994 then
            begin
                if features[129] <= -5413.4999999999991 then
                begin
                    Result := -0.011581388262300846;
                end
                else
                begin
                    Result := 0.035346958787961812;
                end;
            end
            else
            begin
                if features[223] <= -217.49999999999997 then
                begin
                    Result := -0.023761070419386281;
                end
                else
                begin
                    Result := 0.0013467963833817681;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_223(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1486.4999999999998 then
    begin
        if features[174] <= -8889.4999999999982 then
        begin
            Result := 0.028627356409382989;
        end
        else
        begin
            Result := -0.017779693856316513;
        end;
    end
    else
    begin
        if features[218] <= -4444.4999999999991 then
        begin
            if features[176] <= -5183.4999999999991 then
            begin
                if features[166] <= -31727439.999999996 then
                begin
                    if features[176] <= -7434.4999999999991 then
                    begin
                        Result := -0.0045431447525359457;
                    end
                    else
                    begin
                        Result := 0.00087177252612584291;
                    end;
                end
                else
                begin
                    if features[109] <= -318.49999999999994 then
                    begin
                        Result := 0.012891849219825446;
                    end
                    else
                    begin
                        Result := 0.0018883887814752226;
                    end;
                end;
            end
            else
            begin
                if features[220] <= 42.500000000000007 then
                begin
                    if features[215] <= -7276.4999999999991 then
                    begin
                        Result := 0.032339835941383538;
                    end
                    else
                    begin
                        Result := -0.0017373057718583632;
                    end;
                end
                else
                begin
                    if features[177] <= -7440.4999999999991 then
                    begin
                        Result := 0.028898275663315723;
                    end
                    else
                    begin
                        Result := -0.011346254353673072;
                    end;
                end;
            end;
        end
        else
        begin
            if features[176] <= -6433.4999999999991 then
            begin
                Result := -0.019260731903966474;
            end
            else
            begin
                if features[178] <= -1621.4999999999998 then
                begin
                    if features[69] <= 1.5000000000000002 then
                    begin
                        Result := 0.015012847731606889;
                    end
                    else
                    begin
                        Result := -0.011744436977516152;
                    end;
                end
                else
                begin
                    if features[223] <= -1052.4999999999998 then
                    begin
                        Result := 0.025965218202187852;
                    end
                    else
                    begin
                        Result := 0.0063065689146592609;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_224(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -117.49999999999999 then
    begin
        if features[164] <= -141239415.99999997 then
        begin
            if features[221] <= -5520.4999999999991 then
            begin
                Result := -0.0010276441756546554;
            end
            else
            begin
                Result := -0.017070883491679685;
            end;
        end
        else
        begin
            if features[176] <= -7434.4999999999991 then
            begin
                if features[184] <= -1178.4999999999998 then
                begin
                    Result := 0.030039597669648529;
                end
                else
                begin
                    Result := -0.011189035694390016;
                end;
            end
            else
            begin
                if features[216] <= -5190.4999999999991 then
                begin
                    if features[215] <= -4245.4999999999991 then
                    begin
                        Result := 0.0067088234800114985;
                    end
                    else
                    begin
                        Result := -0.0053716028666310625;
                    end;
                end
                else
                begin
                    if features[170] <= 4.5000000000000009 then
                    begin
                        Result := 0.0012972549032546942;
                    end
                    else
                    begin
                        Result := -0.0080387967092972572;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[176] <= -4804.4999999999991 then
        begin
            if features[220] <= -180.49999999999997 then
            begin
                Result := 0.0095659864482330569;
            end
            else
            begin
                if features[225] <= -6745.4999999999991 then
                begin
                    Result := -0.012931006412953479;
                end
                else
                begin
                    if features[27] <= -5066.4999999999991 then
                    begin
                        Result := 0.0050862445080531232;
                    end
                    else
                    begin
                        Result := -0.00053183171863840602;
                    end;
                end;
            end;
        end
        else
        begin
            if features[108] <= -103.49999999999999 then
            begin
                Result := -0.010717174018474919;
            end
            else
            begin
                if features[96] <= -95510531.999999985 then
                begin
                    Result := 0.030545554379167839;
                end
                else
                begin
                    Result := 2.0828076048937843E-05;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_225(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[13] <= -190493.49999999997 then
    begin
        if features[82] <= -226031.99999999997 then
        begin
            Result := -0.011351545485730341;
        end
        else
        begin
            if features[73] <= 491.50000000000006 then
            begin
                if features[217] <= -19.499999999999996 then
                begin
                    Result := 0.0091398010873690091;
                end
                else
                begin
                    if features[166] <= -105160295.99999999 then
                    begin
                        Result := 0.065164023503577181;
                    end
                    else
                    begin
                        Result := 0.019317842818574321;
                    end;
                end;
            end
            else
            begin
                Result := -0.0092568317809022024;
            end;
        end;
    end
    else
    begin
        if features[229] <= -1344.4999999999998 then
        begin
            if features[227] <= -5786.4999999999991 then
            begin
                Result := 0.031763113096661445;
            end
            else
            begin
                Result := -0.020059203776867096;
            end;
        end
        else
        begin
            if features[47] <= 8737.5000000000018 then
            begin
                if features[175] <= -898.49999999999989 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.013667615823513696;
                    end
                    else
                    begin
                        Result := -0.0023923631999094169;
                    end;
                end
                else
                begin
                    if features[216] <= -6243.4999999999991 then
                    begin
                        Result := 0.0097421094367338042;
                    end
                    else
                    begin
                        Result := -0.00075442676670894079;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -5192.4999999999991 then
                begin
                    if features[186] <= -160.74999999999997 then
                    begin
                        Result := 0.0074099219808024643;
                    end
                    else
                    begin
                        Result := -0.00065821339055553328;
                    end;
                end
                else
                begin
                    if features[174] <= -4104.4999999999991 then
                    begin
                        Result := -0.0027494620054070288;
                    end
                    else
                    begin
                        Result := 0.0054373168743233335;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_226(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[182] <= -3566.4999999999995 then
    begin
        if features[180] <= -4882.4999999999991 then
        begin
            if features[225] <= -3815.4999999999995 then
            begin
                if features[226] <= -407.49999999999994 then
                begin
                    if features[216] <= -6454.4999999999991 then
                    begin
                        Result := 0.006600767263994234;
                    end
                    else
                    begin
                        Result := -0.0055414681618980418;
                    end;
                end
                else
                begin
                    if features[13] <= -157594.99999999997 then
                    begin
                        Result := 0.018200678314520966;
                    end
                    else
                    begin
                        Result := 0.00025821976533294721;
                    end;
                end;
            end
            else
            begin
                if features[164] <= 421729984.00000006 then
                begin
                    Result := 0.014949119638778388;
                end
                else
                begin
                    Result := -0.011040592870131533;
                end;
            end;
        end
        else
        begin
            if features[223] <= 452.50000000000006 then
            begin
                if features[185] <= 45.250000000000007 then
                begin
                    if features[175] <= -2028.4999999999998 then
                    begin
                        Result := 0.025827144967060917;
                    end
                    else
                    begin
                        Result := 0.0016910030046917641;
                    end;
                end
                else
                begin
                    if features[67] <= 2692.5000000000005 then
                    begin
                        Result := 0.025080611266021836;
                    end
                    else
                    begin
                        Result := -0.001468423661611081;
                    end;
                end;
            end
            else
            begin
                if features[24] <= 5.5000000000000009 then
                begin
                    if features[81] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.012815544431085743;
                    end
                    else
                    begin
                        Result := -0.052478371996010666;
                    end;
                end
                else
                begin
                    Result := 0.0037402523921937349;
                end;
            end;
        end;
    end
    else
    begin
        if features[148] <= 4228.5000000000009 then
        begin
            Result := -0.016681248366340856;
        end
        else
        begin
            Result := 0.025105931985490756;
        end;
    end;
end;

function bidirectional_tree_227(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[182] <= -3768.4999999999995 then
    begin
        if features[216] <= -7164.9999999999991 then
        begin
            if features[177] <= -7675.4999999999991 then
            begin
                if features[158] <= 2062.5000000000005 then
                begin
                    Result := -0.012910032270164918;
                end
                else
                begin
                    if features[175] <= -3766.4999999999995 then
                    begin
                        Result := 0.062775857435235421;
                    end
                    else
                    begin
                        Result := 0.0075995260199963489;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.020712393687867422;
                end
                else
                begin
                    Result := 0.0024263853903485561;
                end;
            end;
        end
        else
        begin
            if features[229] <= -640.49999999999989 then
            begin
                if features[176] <= -5839.4999999999991 then
                begin
                    if features[70] <= 430.00000000000006 then
                    begin
                        Result := 0.037918742429717156;
                    end
                    else
                    begin
                        Result := -0.014827631673504402;
                    end;
                end
                else
                begin
                    if features[180] <= -4960.4999999999991 then
                    begin
                        Result := -0.0015011481117140233;
                    end
                    else
                    begin
                        Result := 0.031701691477728638;
                    end;
                end;
            end
            else
            begin
                if features[186] <= -1268.2499999999998 then
                begin
                    if features[174] <= -5426.4999999999991 then
                    begin
                        Result := 0.044587686530183461;
                    end
                    else
                    begin
                        Result := -0.0094660990860282405;
                    end;
                end
                else
                begin
                    if features[216] <= -4176.4999999999991 then
                    begin
                        Result := -0.00059255491287475367;
                    end
                    else
                    begin
                        Result := 0.0037045286478064997;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[185] <= -248.83333587646482 then
        begin
            Result := -0.01814058134941671;
        end
        else
        begin
            Result := 0.00095698346846439901;
        end;
    end;
end;

function bidirectional_tree_228(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1486.4999999999998 then
    begin
        Result := -0.014655004470848826;
    end
    else
    begin
        if features[91] <= -1.0000000180025095E-35 then
        begin
            if features[158] <= 61166.500000000007 then
            begin
                if features[66] <= 493.50000000000006 then
                begin
                    if features[81] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.00051635967350667966;
                    end
                    else
                    begin
                        Result := 0.0052199040038935843;
                    end;
                end
                else
                begin
                    if features[219] <= -5603.4999999999991 then
                    begin
                        Result := -0.032318872507309658;
                    end
                    else
                    begin
                        Result := -0.0036015095682492824;
                    end;
                end;
            end
            else
            begin
                if features[185] <= 109.16666793823244 then
                begin
                    if features[177] <= -7154.4999999999991 then
                    begin
                        Result := 0.045907830953166973;
                    end
                    else
                    begin
                        Result := 0.015707980375240436;
                    end;
                end
                else
                begin
                    Result := -0.0029310232548154175;
                end;
            end;
        end
        else
        begin
            if features[145] <= -521.99999999999989 then
            begin
                if features[224] <= -6127.4999999999991 then
                begin
                    Result := -0.016954700214189437;
                end
                else
                begin
                    if features[218] <= -4427.4999999999991 then
                    begin
                        Result := 0.017436455747680279;
                    end
                    else
                    begin
                        Result := -0.013636082426142613;
                    end;
                end;
            end
            else
            begin
                if features[14] <= 28301058.000000004 then
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.00011414715073813319;
                    end
                    else
                    begin
                        Result := -0.0081664691575140027;
                    end;
                end
                else
                begin
                    if features[182] <= -6429.4999999999991 then
                    begin
                        Result := -0.023295469669473365;
                    end
                    else
                    begin
                        Result := -0.0067815063460791927;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_229(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[176] <= -4760.4999999999991 then
    begin
        if features[176] <= -7434.4999999999991 then
        begin
            if features[216] <= -4970.4999999999991 then
            begin
                if features[166] <= -22678971.999999996 then
                begin
                    Result := -0.0090547237386264523;
                end
                else
                begin
                    Result := 0.0058839390831379561;
                end;
            end
            else
            begin
                if features[229] <= -97.499999999999986 then
                begin
                    Result := -0.0083738359095983789;
                end
                else
                begin
                    Result := 0.0092582865758913096;
                end;
            end;
        end
        else
        begin
            if features[175] <= 1997.0000000000002 then
            begin
                if features[173] <= -6747.4999999999991 then
                begin
                    if features[47] <= 7930.5000000000009 then
                    begin
                        Result := 0.0033766392424059593;
                    end
                    else
                    begin
                        Result := 0.025612274837115395;
                    end;
                end
                else
                begin
                    if features[47] <= 22224.000000000004 then
                    begin
                        Result := 0.00087275003322209884;
                    end
                    else
                    begin
                        Result := 0.0077259093696086974;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -4315.4999999999991 then
                begin
                    Result := -0.014267545988001533;
                end
                else
                begin
                    Result := 0.0040563596827760699;
                end;
            end;
        end;
    end
    else
    begin
        if features[109] <= -290.49999999999994 then
        begin
            Result := -0.0094329785183548589;
        end
        else
        begin
            if features[223] <= -278.49999999999994 then
            begin
                if features[182] <= -5018.4999999999991 then
                begin
                    Result := 0.002312347567794346;
                end
                else
                begin
                    if features[227] <= -3099.4999999999995 then
                    begin
                        Result := 0.026364325608379431;
                    end
                    else
                    begin
                        Result := -0.016260231991469271;
                    end;
                end;
            end
            else
            begin
                Result := -0.003557086789452961;
            end;
        end;
    end;
end;

function bidirectional_tree_230(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[90] <= -10.499999999999998 then
    begin
        Result := -0.015617430356260545;
    end
    else
    begin
        if features[226] <= -150.49999999999997 then
        begin
            if features[164] <= -16165704.499999998 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    if features[228] <= -5582.4999999999991 then
                    begin
                        Result := 0.016062841078253919;
                    end
                    else
                    begin
                        Result := -0.0076720503968801985;
                    end;
                end
                else
                begin
                    if features[178] <= 116.50000000000001 then
                    begin
                        Result := -0.011414648228778388;
                    end
                    else
                    begin
                        Result := -0.00061231589806357977;
                    end;
                end;
            end
            else
            begin
                if features[48] <= 18023.500000000004 then
                begin
                    if features[151] <= -23.499999999999996 then
                    begin
                        Result := 0.0016636459047951607;
                    end
                    else
                    begin
                        Result := -0.0049566148471389777;
                    end;
                end
                else
                begin
                    if features[69] <= 3.5000000000000004 then
                    begin
                        Result := 0.023183395155195921;
                    end
                    else
                    begin
                        Result := 0.0024233003658040062;
                    end;
                end;
            end;
        end
        else
        begin
            if features[27] <= -5925.4999999999991 then
            begin
                if features[228] <= -5157.4999999999991 then
                begin
                    if features[81] <= -225.49999999999997 then
                    begin
                        Result := -0.0027006912609076196;
                    end
                    else
                    begin
                        Result := 0.0085749532033170175;
                    end;
                end
                else
                begin
                    Result := 0.01531960903856463;
                end;
            end
            else
            begin
                if features[224] <= -6533.4999999999991 then
                begin
                    Result := -0.0084458219801394705;
                end
                else
                begin
                    if features[176] <= -4760.4999999999991 then
                    begin
                        Result := 0.0018817611235651618;
                    end
                    else
                    begin
                        Result := -0.0050454582180855488;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_231(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[117] <= -587.49999999999989 then
    begin
        if features[120] <= -1540.4999999999998 then
        begin
            if features[180] <= -6010.4999999999991 then
            begin
                Result := -0.011577244429051173;
            end
            else
            begin
                if features[226] <= -300.49999999999994 then
                begin
                    Result := -0.0023003427114559063;
                end
                else
                begin
                    Result := 0.040680547136072456;
                end;
            end;
        end
        else
        begin
            if features[24] <= 1.0000000180025095E-35 then
            begin
                Result := 0.04655830272425749;
            end
            else
            begin
                Result := -0.016318494639241007;
            end;
        end;
    end
    else
    begin
        if features[215] <= -3285.4999999999995 then
        begin
            if features[215] <= -3510.4999999999995 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    if features[82] <= -169806.99999999997 then
                    begin
                        Result := -0.0065730988111512264;
                    end
                    else
                    begin
                        Result := 0.001591644355714211;
                    end;
                end
                else
                begin
                    if features[81] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0076310848955047032;
                    end
                    else
                    begin
                        Result := 0.0014356260009342398;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -5782.4999999999991 then
                begin
                    Result := 0.00069229468375579112;
                end
                else
                begin
                    if features[185] <= -334.24999999999994 then
                    begin
                        Result := 0.052025000665358229;
                    end
                    else
                    begin
                        Result := 0.016544957060652173;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[178] <= -894.49999999999989 then
                begin
                    Result := -0.019517486173910442;
                end
                else
                begin
                    Result := 0.051172782546522355;
                end;
            end
            else
            begin
                Result := -0.017683352601917775;
            end;
        end;
    end;
end;

function bidirectional_tree_232(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[179] <= -3544.4999999999995 then
    begin
        if features[216] <= -7297.4999999999991 then
        begin
            if features[77] <= 2062.5000000000005 then
            begin
                if features[176] <= -6330.4999999999991 then
                begin
                    if features[182] <= -5966.4999999999991 then
                    begin
                        Result := -0.023148305221650997;
                    end
                    else
                    begin
                        Result := 0.011547090741762972;
                    end;
                end
                else
                begin
                    if features[120] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.015702446379884619;
                    end
                    else
                    begin
                        Result := -0.02852132738110464;
                    end;
                end;
            end
            else
            begin
                if features[48] <= 13262.500000000002 then
                begin
                    if features[150] <= -16.499999999999996 then
                    begin
                        Result := 0.032915376056810455;
                    end
                    else
                    begin
                        Result := 0.0059306643874655757;
                    end;
                end
                else
                begin
                    Result := 0.037397156843378465;
                end;
            end;
        end
        else
        begin
            if features[217] <= -2435.4999999999995 then
            begin
                Result := -0.014341485598687807;
            end
            else
            begin
                if features[13] <= -70432.999999999985 then
                begin
                    if features[14] <= 17325690.000000004 then
                    begin
                        Result := 0.01962581374160503;
                    end
                    else
                    begin
                        Result := -0.0028718410862197605;
                    end;
                end
                else
                begin
                    if features[180] <= -3750.4999999999995 then
                    begin
                        Result := -0.0003515881484464903;
                    end
                    else
                    begin
                        Result := 0.024013960830866661;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[185] <= -281.87499999999994 then
        begin
            Result := -0.021450333855033234;
        end
        else
        begin
            if features[187] <= 1.0625000000000002 then
            begin
                Result := -0.011571456936156691;
            end
            else
            begin
                Result := 0.022268695382059261;
            end;
        end;
    end;
end;

function bidirectional_tree_233(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -459524975.99999994 then
    begin
        Result := -0.016989144822354453;
    end
    else
    begin
        if features[25] <= 1.0000000180025095E-35 then
        begin
            if features[221] <= -6228.4999999999991 then
            begin
                if features[14] <= -2420597.9999999995 then
                begin
                    Result := 0.018340415867702849;
                end
                else
                begin
                    Result := -0.014787302553364823;
                end;
            end
            else
            begin
                if features[148] <= -1127.4999999999998 then
                begin
                    if features[219] <= -3486.9999999999995 then
                    begin
                        Result := -0.0050107377201498594;
                    end
                    else
                    begin
                        Result := 0.04550630492752919;
                    end;
                end
                else
                begin
                    if features[174] <= -5123.4999999999991 then
                    begin
                        Result := 0.011533857393329581;
                    end
                    else
                    begin
                        Result := 0.0031924940658831927;
                    end;
                end;
            end;
        end
        else
        begin
            if features[96] <= -216273439.99999997 then
            begin
                if features[41] <= 1186.5000000000002 then
                begin
                    if features[45] <= 5.5000000000000009 then
                    begin
                        Result := 0.0012634784066330375;
                    end
                    else
                    begin
                        Result := 0.054381297056855453;
                    end;
                end
                else
                begin
                    if features[180] <= -7915.4999999999991 then
                    begin
                        Result := 0.10150514878708335;
                    end
                    else
                    begin
                        Result := 0.017922194997810819;
                    end;
                end;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[9] <= 2.5000000000000004 then
                    begin
                        Result := -0.00049743611605338584;
                    end
                    else
                    begin
                        Result := 0.0094692890123466936;
                    end;
                end
                else
                begin
                    if features[225] <= -5314.4999999999991 then
                    begin
                        Result := -0.0073407549980858315;
                    end
                    else
                    begin
                        Result := 0.00041423946259017434;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_234(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[129] <= -31746.499999999996 then
    begin
        if features[118] <= -1.4999999999999998 then
        begin
            Result := 0.026932609788348029;
        end
        else
        begin
            if features[176] <= -6027.4999999999991 then
            begin
                Result := -0.022792943924208907;
            end
            else
            begin
                if features[176] <= -5545.4999999999991 then
                begin
                    if features[224] <= -4510.4999999999991 then
                    begin
                        Result := 0.0;
                    end
                    else
                    begin
                        Result := 0.053024991776035181;
                    end;
                end
                else
                begin
                    Result := -0.015632639923626936;
                end;
            end;
        end;
    end
    else
    begin
        if features[13] <= -190493.49999999997 then
        begin
            if features[148] <= 40.500000000000007 then
            begin
                if features[81] <= -224440.99999999997 then
                begin
                    Result := 3.4984846935794014E-05;
                end
                else
                begin
                    Result := 0.032186498042126248;
                end;
            end
            else
            begin
                Result := -0.0077682559495334301;
            end;
        end
        else
        begin
            if features[145] <= -521.99999999999989 then
            begin
                if features[227] <= -6216.4999999999991 then
                begin
                    Result := -0.026721213340713409;
                end
                else
                begin
                    if features[178] <= -1681.4999999999998 then
                    begin
                        Result := 0.035183099531066693;
                    end
                    else
                    begin
                        Result := 0.0079666767717707435;
                    end;
                end;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[77] <= 63291.500000000007 then
                    begin
                        Result := 0.0005426981829192417;
                    end
                    else
                    begin
                        Result := 0.017052916967859433;
                    end;
                end
                else
                begin
                    if features[105] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0014713476940020451;
                    end
                    else
                    begin
                        Result := -0.0048729176131818855;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_235(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[166] <= -409983439.99999994 then
    begin
        if features[225] <= -4521.4999999999991 then
        begin
            if features[124] <= 330.50000000000006 then
            begin
                Result := -0.021012800954867249;
            end
            else
            begin
                Result := 0.039670655744631619;
            end;
        end
        else
        begin
            if features[224] <= -3631.4999999999995 then
            begin
                if features[224] <= -4027.4999999999995 then
                begin
                    Result := -0.0071657324718006291;
                end
                else
                begin
                    if features[26] <= 2.5000000000000004 then
                    begin
                        Result := 0.10913052303345797;
                    end
                    else
                    begin
                        Result := -0.013252826999289979;
                    end;
                end;
            end
            else
            begin
                Result := -0.020016833391438685;
            end;
        end;
    end
    else
    begin
        if features[215] <= -3349.4999999999995 then
        begin
            if features[218] <= -4444.4999999999991 then
            begin
                if features[176] <= -4887.4999999999991 then
                begin
                    if features[108] <= -649.49999999999989 then
                    begin
                        Result := 0.0058534177884464527;
                    end
                    else
                    begin
                        Result := -6.6825078450363012E-05;
                    end;
                end
                else
                begin
                    if features[216] <= -5094.4999999999991 then
                    begin
                        Result := -0.00023117457498915718;
                    end
                    else
                    begin
                        Result := -0.011943941228715733;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -4135.9999999999991 then
                begin
                    if features[215] <= -5826.4999999999991 then
                    begin
                        Result := 0.019989824345606855;
                    end
                    else
                    begin
                        Result := 0.00044201858946499274;
                    end;
                end
                else
                begin
                    if features[74] <= 10.500000000000002 then
                    begin
                        Result := 0.023330672719201383;
                    end
                    else
                    begin
                        Result := -0.0073326011004474769;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.009952285296757693;
        end;
    end;
end;

function bidirectional_tree_236(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[119] <= -1168.4999999999998 then
    begin
        if features[166] <= -37581131.999999993 then
        begin
            Result := -0.026563223769151136;
        end
        else
        begin
            Result := 0.0082726584847212167;
        end;
    end
    else
    begin
        if features[123] <= -666.49999999999989 then
        begin
            if features[219] <= -5868.4999999999991 then
            begin
                if features[226] <= -951.49999999999989 then
                begin
                    Result := -0.010366908086542908;
                end
                else
                begin
                    Result := 0.067120831614146934;
                end;
            end
            else
            begin
                if features[226] <= -144.49999999999997 then
                begin
                    Result := -0.01977572581157086;
                end
                else
                begin
                    Result := 0.023349412048617846;
                end;
            end;
        end
        else
        begin
            if features[187] <= -20.535714149475094 then
            begin
                if features[166] <= -39740415.999999993 then
                begin
                    if features[183] <= -6675.4999999999991 then
                    begin
                        Result := -0.010933176507013873;
                    end
                    else
                    begin
                        Result := -0.0018826327249908939;
                    end;
                end
                else
                begin
                    if features[28] <= -6438.4999999999991 then
                    begin
                        Result := 0.01728159859341296;
                    end
                    else
                    begin
                        Result := 0.0016142996301332934;
                    end;
                end;
            end
            else
            begin
                if features[123] <= -174.49999999999997 then
                begin
                    if features[174] <= -4653.4999999999991 then
                    begin
                        Result := 0.020578140258644004;
                    end
                    else
                    begin
                        Result := -0.0077267847611638928;
                    end;
                end
                else
                begin
                    if features[13] <= -70432.999999999985 then
                    begin
                        Result := 0.011681097561131696;
                    end
                    else
                    begin
                        Result := 0.0001348713339986071;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_237(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -530.49999999999989 then
    begin
        if features[176] <= -6108.4999999999991 then
        begin
            if features[224] <= -5885.4999999999991 then
            begin
                if features[150] <= -10.499999999999998 then
                begin
                    Result := 0.043842909394315226;
                end
                else
                begin
                    Result := -0.00028114923344887689;
                end;
            end
            else
            begin
                if features[148] <= 1279.5000000000002 then
                begin
                    Result := -0.013035919405074215;
                end
                else
                begin
                    Result := 0.007134100969980327;
                end;
            end;
        end
        else
        begin
            if features[173] <= -5279.4999999999991 then
            begin
                if features[175] <= 865.50000000000011 then
                begin
                    if features[179] <= -6425.4999999999991 then
                    begin
                        Result := -0.0050853529979933516;
                    end
                    else
                    begin
                        Result := 0.026043831235415229;
                    end;
                end
                else
                begin
                    if features[215] <= -4590.4999999999991 then
                    begin
                        Result := -0.014511747364401537;
                    end
                    else
                    begin
                        Result := 0.017140923193148191;
                    end;
                end;
            end
            else
            begin
                if features[175] <= 1664.5000000000002 then
                begin
                    if features[186] <= -182.83333587646482 then
                    begin
                        Result := -0.0098275270993371557;
                    end
                    else
                    begin
                        Result := 0.0068192376470203875;
                    end;
                end
                else
                begin
                    if features[178] <= -596.49999999999989 then
                    begin
                        Result := -0.0025446556477672923;
                    end
                    else
                    begin
                        Result := 0.084578300033294695;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[126] <= -2.4999999999999996 then
        begin
            if features[215] <= -4495.4999999999991 then
            begin
                Result := -0.0034553364835989402;
            end
            else
            begin
                Result := -0.030807980118922624;
            end;
        end
        else
        begin
            Result := 0.00078042027257707624;
        end;
    end;
end;

function bidirectional_tree_238(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[94] <= -155228.99999999997 then
    begin
        if features[226] <= 84.500000000000014 then
        begin
            if features[223] <= 86.500000000000014 then
            begin
                Result := 0.0033350294603820296;
            end
            else
            begin
                Result := -0.023230732784866245;
            end;
        end
        else
        begin
            Result := 0.018281448558396501;
        end;
    end
    else
    begin
        if features[82] <= -171308.49999999997 then
        begin
            if features[183] <= -5429.4999999999991 then
            begin
                Result := -0.010354766991194453;
            end
            else
            begin
                if features[217] <= 244.50000000000003 then
                begin
                    if features[227] <= -3293.4999999999995 then
                    begin
                        Result := 0.01675253970335417;
                    end
                    else
                    begin
                        Result := -0.01652151732861978;
                    end;
                end
                else
                begin
                    Result := -0.016829242867541973;
                end;
            end;
        end
        else
        begin
            if features[179] <= -3792.4999999999995 then
            begin
                if features[129] <= -22573.999999999996 then
                begin
                    if features[216] <= -5263.4999999999991 then
                    begin
                        Result := 0.020679460571955514;
                    end
                    else
                    begin
                        Result := 0.0010952945856555526;
                    end;
                end
                else
                begin
                    if features[108] <= -1327.4999999999998 then
                    begin
                        Result := 0.010926864109976189;
                    end
                    else
                    begin
                        Result := -4.6423855968924591E-05;
                    end;
                end;
            end
            else
            begin
                if features[175] <= -2028.4999999999998 then
                begin
                    if features[28] <= -4871.4999999999991 then
                    begin
                        Result := 0.0352255032291156;
                    end
                    else
                    begin
                        Result := -0.017984446176362405;
                    end;
                end
                else
                begin
                    if features[185] <= -177.24999999999997 then
                    begin
                        Result := -0.021122955544803836;
                    end
                    else
                    begin
                        Result := 0.0039041951138788647;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_239(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= -1806.4999999999998 then
    begin
        if features[172] <= 5.5000000000000009 then
        begin
            Result := -0.022302622800363884;
        end
        else
        begin
            Result := 0.038781034037410678;
        end;
    end
    else
    begin
        if features[218] <= -4444.4999999999991 then
        begin
            if features[176] <= -5183.4999999999991 then
            begin
                if features[222] <= -4139.4999999999991 then
                begin
                    if features[166] <= -29654539.999999996 then
                    begin
                        Result := -0.00077977353085606396;
                    end
                    else
                    begin
                        Result := 0.0039299116467709869;
                    end;
                end
                else
                begin
                    if features[220] <= -13.499999999999998 then
                    begin
                        Result := 0.020711781304840176;
                    end
                    else
                    begin
                        Result := 0.0030589826107056818;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -4995.4999999999991 then
                begin
                    if features[165] <= 470389728.00000006 then
                    begin
                        Result := -0.0030360163032820877;
                    end
                    else
                    begin
                        Result := 0.010725055799494487;
                    end;
                end
                else
                begin
                    if features[215] <= -3349.4999999999995 then
                    begin
                        Result := -0.01064050660921903;
                    end
                    else
                    begin
                        Result := 0.046910366836597064;
                    end;
                end;
            end;
        end
        else
        begin
            if features[176] <= -6433.4999999999991 then
            begin
                Result := -0.016071676164570437;
            end
            else
            begin
                if features[181] <= -1135.4999999999998 then
                begin
                    if features[107] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.011810271141987322;
                    end
                    else
                    begin
                        Result := -0.0094974183602737593;
                    end;
                end
                else
                begin
                    if features[174] <= -6406.4999999999991 then
                    begin
                        Result := 0.024303016501901059;
                    end
                    else
                    begin
                        Result := 0.0064860589968961839;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_240(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[227] <= -3219.4999999999995 then
    begin
        if features[228] <= -3405.4999999999995 then
        begin
            if features[69] <= 4.5000000000000009 then
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    if features[81] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0022161543499499016;
                    end
                    else
                    begin
                        Result := 0.0032918298974356284;
                    end;
                end
                else
                begin
                    if features[215] <= -4926.4999999999991 then
                    begin
                        Result := 0.013541865996359244;
                    end
                    else
                    begin
                        Result := -0.00044232352833499002;
                    end;
                end;
            end
            else
            begin
                if features[187] <= -31.422618865966793 then
                begin
                    if features[215] <= -4679.4999999999991 then
                    begin
                        Result := -0.011457028097097338;
                    end
                    else
                    begin
                        Result := 0.0010031985286394452;
                    end;
                end
                else
                begin
                    if features[15] <= -224362927.99999997 then
                    begin
                        Result := 0.034349135965088692;
                    end
                    else
                    begin
                        Result := -0.00046906525960911031;
                    end;
                end;
            end;
        end
        else
        begin
            if features[179] <= -4024.4999999999995 then
            begin
                Result := 0.016934462823148304;
            end
            else
            begin
                Result := -0.010621693123632387;
            end;
        end;
    end
    else
    begin
        if features[174] <= -3120.9999999999995 then
        begin
            if features[229] <= -164.49999999999997 then
            begin
                if features[217] <= -631.49999999999989 then
                begin
                    if features[215] <= -4379.4999999999991 then
                    begin
                        Result := 0.022997540654540707;
                    end
                    else
                    begin
                        Result := -0.016435520772075284;
                    end;
                end
                else
                begin
                    Result := -0.024084926645559775;
                end;
            end
            else
            begin
                Result := 0.0035891214816221387;
            end;
        end
        else
        begin
            Result := 0.031172198018914389;
        end;
    end;
end;

function bidirectional_tree_241(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[227] <= -3240.4999999999995 then
    begin
        if features[218] <= -4444.4999999999991 then
        begin
            if features[147] <= -494.99999999999994 then
            begin
                if features[47] <= 5412.5000000000009 then
                begin
                    if features[173] <= -4658.4999999999991 then
                    begin
                        Result := 0.0098608057775670249;
                    end
                    else
                    begin
                        Result := -0.0086408109993933255;
                    end;
                end
                else
                begin
                    Result := 0.019243222588917284;
                end;
            end
            else
            begin
                if features[176] <= -4984.4999999999991 then
                begin
                    if features[173] <= -3070.4999999999995 then
                    begin
                        Result := -0.00032882421424811856;
                    end
                    else
                    begin
                        Result := 0.011189810430548288;
                    end;
                end
                else
                begin
                    if features[174] <= -4992.4999999999991 then
                    begin
                        Result := 0.00011468339372594627;
                    end
                    else
                    begin
                        Result := -0.010130093207837441;
                    end;
                end;
            end;
        end
        else
        begin
            if features[176] <= -6418.4999999999991 then
            begin
                Result := -0.016449901269520409;
            end
            else
            begin
                if features[181] <= -1110.4999999999998 then
                begin
                    if features[173] <= -6120.4999999999991 then
                    begin
                        Result := 0.021948980315274719;
                    end
                    else
                    begin
                        Result := -0.0099946731515170532;
                    end;
                end
                else
                begin
                    if features[37] <= 4.5000000000000009 then
                    begin
                        Result := 0.01465227278035772;
                    end
                    else
                    begin
                        Result := 0.0023301539776239568;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= -179.49999999999997 then
        begin
            if features[174] <= -3120.9999999999995 then
            begin
                Result := -0.01840485445483753;
            end
            else
            begin
                Result := 0.03843671998158648;
            end;
        end
        else
        begin
            Result := 0.0049327680080675611;
        end;
    end;
end;

function bidirectional_tree_242(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[124] <= -403.99999999999994 then
    begin
        if features[220] <= 1.0000000180025095E-35 then
        begin
            if features[226] <= -251.49999999999997 then
            begin
                if features[180] <= -4729.4999999999991 then
                begin
                    Result := -0.018440538066244277;
                end
                else
                begin
                    Result := 0.030714114538694035;
                end;
            end
            else
            begin
                Result := 0.014200220059094227;
            end;
        end
        else
        begin
            Result := -0.020597183727969044;
        end;
    end
    else
    begin
        if features[229] <= 312.50000000000006 then
        begin
            if features[48] <= 14047.000000000002 then
            begin
                if features[180] <= -4960.4999999999991 then
                begin
                    if features[179] <= -3992.4999999999995 then
                    begin
                        Result := -0.0010006113877358267;
                    end
                    else
                    begin
                        Result := -0.020206288762990854;
                    end;
                end
                else
                begin
                    if features[223] <= -1063.4999999999998 then
                    begin
                        Result := 0.029917402472993161;
                    end
                    else
                    begin
                        Result := 0.0034844185039703797;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 1.5000000000000002 then
                begin
                    Result := 0.021032373673588622;
                end
                else
                begin
                    if features[220] <= -926.49999999999989 then
                    begin
                        Result := 0.015769272552915891;
                    end
                    else
                    begin
                        Result := -0.00059339316261496989;
                    end;
                end;
            end;
        end
        else
        begin
            if features[223] <= 282.50000000000006 then
            begin
                Result := 0.021434656817351239;
            end
            else
            begin
                if features[217] <= -715.49999999999989 then
                begin
                    Result := 0.01716843542414969;
                end
                else
                begin
                    if features[180] <= -4778.4999999999991 then
                    begin
                        Result := 0.0026486744536787805;
                    end
                    else
                    begin
                        Result := -0.017715606359135584;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_243(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -1344.4999999999998 then
    begin
        Result := -0.018288534903370401;
    end
    else
    begin
        if features[158] <= 1732.5000000000002 then
        begin
            if features[221] <= -2941.4999999999995 then
            begin
                if features[173] <= -5235.4999999999991 then
                begin
                    if features[108] <= -477.49999999999994 then
                    begin
                        Result := 0.002933935672257644;
                    end
                    else
                    begin
                        Result := -0.0069106783937520457;
                    end;
                end
                else
                begin
                    if features[176] <= -4845.4999999999991 then
                    begin
                        Result := 0.0017199136297696861;
                    end
                    else
                    begin
                        Result := -0.0054042515521650954;
                    end;
                end;
            end
            else
            begin
                if features[165] <= 491183088.00000006 then
                begin
                    Result := 0.04326054830860384;
                end
                else
                begin
                    Result := 0.00011667080108138301;
                end;
            end;
        end
        else
        begin
            if features[175] <= -621.49999999999989 then
            begin
                if features[47] <= 8737.5000000000018 then
                begin
                    if features[183] <= -4741.4999999999991 then
                    begin
                        Result := -0.0065862071792886084;
                    end
                    else
                    begin
                        Result := 0.0077567976219762788;
                    end;
                end
                else
                begin
                    if features[216] <= -6958.4999999999991 then
                    begin
                        Result := 0.023475792202088813;
                    end
                    else
                    begin
                        Result := 0.0020188124916373515;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3532.4999999999995 then
                begin
                    if features[15] <= -190971807.99999997 then
                    begin
                        Result := 0.023422336519918589;
                    end
                    else
                    begin
                        Result := 0.0031973258050608127;
                    end;
                end
                else
                begin
                    if features[226] <= 84.500000000000014 then
                    begin
                        Result := -0.032686047639670077;
                    end
                    else
                    begin
                        Result := 0.0033464994590285402;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_244(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[226] <= 1149.0000000000002 then
    begin
        if features[124] <= -193.49999999999997 then
        begin
            if features[120] <= -1432.4999999999998 then
            begin
                if features[95] <= -211370447.99999997 then
                begin
                    if features[187] <= -173.29166412353513 then
                    begin
                        Result := -0.020212033928345641;
                    end
                    else
                    begin
                        Result := 0.038258543620268162;
                    end;
                end
                else
                begin
                    if features[181] <= 172.50000000000003 then
                    begin
                        Result := -0.0021656919530685555;
                    end
                    else
                    begin
                        Result := 0.017081636395526099;
                    end;
                end;
            end
            else
            begin
                if features[177] <= -4494.4999999999991 then
                begin
                    if features[43] <= 365.50000000000006 then
                    begin
                        Result := -0.0054845040485908087;
                    end
                    else
                    begin
                        Result := -0.017145052950341275;
                    end;
                end
                else
                begin
                    if features[180] <= -5980.4999999999991 then
                    begin
                        Result := 0.043102370769666082;
                    end
                    else
                    begin
                        Result := 0.0015318409495684074;
                    end;
                end;
            end;
        end
        else
        begin
            if features[81] <= 7533.0000000000009 then
            begin
                if features[42] <= 591.50000000000011 then
                begin
                    Result := 0.000197095518537533;
                end
                else
                begin
                    Result := -0.0050320942013737362;
                end;
            end
            else
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    if features[176] <= -5941.4999999999991 then
                    begin
                        Result := 0.02109419611586787;
                    end
                    else
                    begin
                        Result := 0.001228583793789379;
                    end;
                end
                else
                begin
                    if features[165] <= 537450144.00000012 then
                    begin
                        Result := -0.00037064851971930037;
                    end
                    else
                    begin
                        Result := 0.021824327120741741;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.014574380020439591;
    end;
end;

function bidirectional_tree_245(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[182] <= -3651.4999999999995 then
    begin
        if features[228] <= -3405.4999999999995 then
        begin
            if features[124] <= -414.99999999999994 then
            begin
                if features[229] <= 149.50000000000003 then
                begin
                    if features[180] <= -4778.4999999999991 then
                    begin
                        Result := -0.0081277789944604242;
                    end
                    else
                    begin
                        Result := 0.022999598135878506;
                    end;
                end
                else
                begin
                    Result := -0.032062903165913759;
                end;
            end
            else
            begin
                if features[147] <= -1715.9999999999998 then
                begin
                    Result := 0.031273570291928947;
                end
                else
                begin
                    if features[69] <= 4.5000000000000009 then
                    begin
                        Result := 0.0015620871509008833;
                    end
                    else
                    begin
                        Result := -0.0011636934719347028;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 203.50000000000003 then
            begin
                if features[124] <= -166.49999999999997 then
                begin
                    Result := -0.015214085403751654;
                end
                else
                begin
                    if features[221] <= -3944.4999999999995 then
                    begin
                        Result := -0.0063290122810946599;
                    end
                    else
                    begin
                        Result := 0.016386614252819742;
                    end;
                end;
            end
            else
            begin
                Result := 0.020587297727977238;
            end;
        end;
    end
    else
    begin
        if features[108] <= 21.500000000000004 then
        begin
            if features[175] <= 972.50000000000011 then
            begin
                if features[165] <= 313971392.00000006 then
                begin
                    Result := 0.0072577308307974295;
                end
                else
                begin
                    Result := -0.019987048674466833;
                end;
            end
            else
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.02921549307847689;
                end
                else
                begin
                    Result := -0.017945263555962397;
                end;
            end;
        end
        else
        begin
            Result := 0.020360898193012955;
        end;
    end;
end;

function bidirectional_tree_246(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[90] <= -10.499999999999998 then
    begin
        if features[147] <= -39.499999999999993 then
        begin
            Result := -0.00218370523464577;
        end
        else
        begin
            Result := -0.024296077396878866;
        end;
    end
    else
    begin
        if features[166] <= -41992811.999999993 then
        begin
            if features[147] <= 1357.5000000000002 then
            begin
                if features[148] <= -1168.4999999999998 then
                begin
                    if features[109] <= -290.49999999999994 then
                    begin
                        Result := -0.0098589234860313995;
                    end
                    else
                    begin
                        Result := -0.00035071544581270623;
                    end;
                end
                else
                begin
                    if features[173] <= -4232.4999999999991 then
                    begin
                        Result := 0.001840342613188631;
                    end
                    else
                    begin
                        Result := -0.0031990182155305111;
                    end;
                end;
            end
            else
            begin
                Result := -0.020714618875430187;
            end;
        end
        else
        begin
            if features[81] <= 6595.5000000000009 then
            begin
                if features[39] <= 1501.5000000000002 then
                begin
                    if features[148] <= 1354.5000000000002 then
                    begin
                        Result := 0.002588755024800399;
                    end
                    else
                    begin
                        Result := 0.018819275006818882;
                    end;
                end
                else
                begin
                    if features[95] <= -70739291.999999985 then
                    begin
                        Result := -0.024001676030079751;
                    end
                    else
                    begin
                        Result := -0.0034863880787761891;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -4965.4999999999991 then
                begin
                    if features[45] <= 5.5000000000000009 then
                    begin
                        Result := 0.010354285304240712;
                    end
                    else
                    begin
                        Result := 0.029501210712784283;
                    end;
                end
                else
                begin
                    if features[185] <= -198.87499999999997 then
                    begin
                        Result := -0.027618222840828197;
                    end
                    else
                    begin
                        Result := 0.0015188527228278436;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_247(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[216] <= -6454.4999999999991 then
    begin
        if features[174] <= -6384.4999999999991 then
        begin
            if features[107] <= 1.0000000180025095E-35 then
            begin
                if features[0] <= 110493.50000000001 then
                begin
                    Result := -0.0096568004583539938;
                end
                else
                begin
                    Result := 0.0079584121356965562;
                end;
            end
            else
            begin
                if features[155] <= -2.4999999999999996 then
                begin
                    Result := 0.072255017713317896;
                end
                else
                begin
                    Result := 0.0065535494999480557;
                end;
            end;
        end
        else
        begin
            Result := 0.012546557181057664;
        end;
    end
    else
    begin
        if features[217] <= -1186.4999999999998 then
        begin
            if features[186] <= -1198.4999999999998 then
            begin
                if features[174] <= -5596.4999999999991 then
                begin
                    Result := 0.092243927269707218;
                end
                else
                begin
                    Result := -0.018675452527047137;
                end;
            end
            else
            begin
                Result := -0.0066171308660518229;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[174] <= -3925.9999999999995 then
                begin
                    if features[173] <= -3974.4999999999995 then
                    begin
                        Result := -0.0017712137947912415;
                    end
                    else
                    begin
                        Result := -0.018099600127979374;
                    end;
                end
                else
                begin
                    if features[219] <= -5453.4999999999991 then
                    begin
                        Result := 0.034450392697079939;
                    end
                    else
                    begin
                        Result := 0.0053648882522539876;
                    end;
                end;
            end
            else
            begin
                if features[173] <= -3638.4999999999995 then
                begin
                    if features[174] <= -5146.4999999999991 then
                    begin
                        Result := 0.0031638758843750558;
                    end
                    else
                    begin
                        Result := -0.0017621492222925337;
                    end;
                end
                else
                begin
                    Result := 0.012747491950269425;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_248(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[229] <= -533.49999999999989 then
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[176] <= -5839.4999999999991 then
            begin
                Result := -0.0052642161528601598;
            end
            else
            begin
                if features[40] <= 1096.5000000000002 then
                begin
                    if features[182] <= -4161.4999999999991 then
                    begin
                        Result := 0.017486530193856802;
                    end
                    else
                    begin
                        Result := -0.013065737066981773;
                    end;
                end
                else
                begin
                    Result := -0.01090174903242571;
                end;
            end;
        end
        else
        begin
            if features[166] <= -160165343.99999997 then
            begin
                Result := -0.018201503302405653;
            end
            else
            begin
                if features[176] <= -6358.4999999999991 then
                begin
                    Result := -0.019651180400750458;
                end
                else
                begin
                    if features[154] <= -381.49999999999994 then
                    begin
                        Result := 0.048450774275447313;
                    end
                    else
                    begin
                        Result := 0.001286491826111366;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[13] <= -157594.99999999997 then
        begin
            Result := 0.016114256427743164;
        end
        else
        begin
            if features[81] <= 1.0000000180025095E-35 then
            begin
                if features[220] <= 219.50000000000003 then
                begin
                    Result := 0.00068773969971500949;
                end
                else
                begin
                    Result := -0.0035755874108067335;
                end;
            end
            else
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    if features[176] <= -5331.4999999999991 then
                    begin
                        Result := 0.016339136160053957;
                    end
                    else
                    begin
                        Result := -0.0052033106389767839;
                    end;
                end
                else
                begin
                    if features[221] <= -5969.4999999999991 then
                    begin
                        Result := -0.0063723696710884323;
                    end
                    else
                    begin
                        Result := 0.0030303020530789123;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_249(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[154] <= 19.500000000000004 then
    begin
        if features[105] <= -4.4999999999999991 then
        begin
            if features[151] <= -75.499999999999986 then
            begin
                Result := 0.031041427343780549;
            end
            else
            begin
                Result := -0.018191816507751517;
            end;
        end
        else
        begin
            if features[81] <= -221.49999999999997 then
            begin
                if features[183] <= -4527.4999999999991 then
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0010848298509236434;
                    end
                    else
                    begin
                        Result := -0.0056808012499902673;
                    end;
                end
                else
                begin
                    if features[224] <= -3488.4999999999995 then
                    begin
                        Result := 0.021897126511234766;
                    end
                    else
                    begin
                        Result := -0.011380594951107686;
                    end;
                end;
            end
            else
            begin
                if features[173] <= -6792.9999999999991 then
                begin
                    Result := 0.01405211867628847;
                end
                else
                begin
                    Result := 0.0020483390501027971;
                end;
            end;
        end;
    end
    else
    begin
        if features[221] <= -3603.4999999999995 then
        begin
            if features[96] <= -4979166.9999999991 then
            begin
                if features[69] <= 22.500000000000004 then
                begin
                    Result := 0.0039126915226200152;
                end
                else
                begin
                    Result := 0.040902738477139988;
                end;
            end
            else
            begin
                if features[222] <= -5855.4999999999991 then
                begin
                    Result := -0.0096537209660231757;
                end
                else
                begin
                    if features[180] <= -6628.4999999999991 then
                    begin
                        Result := 0.0043582310498360699;
                    end
                    else
                    begin
                        Result := -0.0066353451707170004;
                    end;
                end;
            end;
        end
        else
        begin
            if features[229] <= -735.49999999999989 then
            begin
                Result := -0.01092390467130192;
            end
            else
            begin
                Result := 0.027168464403501319;
            end;
        end;
    end;
end;

function bidirectional_tree_250(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[124] <= -159.49999999999997 then
    begin
        if features[69] <= 4.5000000000000009 then
        begin
            Result := 0.00090003608083235329;
        end
        else
        begin
            if features[215] <= -4693.4999999999991 then
            begin
                if features[148] <= -1132.4999999999998 then
                begin
                    Result := -0.017466594106713862;
                end
                else
                begin
                    Result := -0.00086625959997107833;
                end;
            end
            else
            begin
                if features[174] <= -4718.4999999999991 then
                begin
                    Result := -0.010072492992883113;
                end
                else
                begin
                    Result := 0.011202549399902791;
                end;
            end;
        end;
    end
    else
    begin
        if features[173] <= -4215.4999999999991 then
        begin
            if features[175] <= -1998.4999999999998 then
            begin
                if features[77] <= 5268.0000000000009 then
                begin
                    if features[184] <= -669.49999999999989 then
                    begin
                        Result := 0.001126549458960532;
                    end
                    else
                    begin
                        Result := 0.018614072910914728;
                    end;
                end
                else
                begin
                    Result := -0.0087978449451642151;
                end;
            end
            else
            begin
                if features[108] <= -1311.4999999999998 then
                begin
                    if features[184] <= -1689.4999999999998 then
                    begin
                        Result := -0.011369319580796376;
                    end
                    else
                    begin
                        Result := 0.032112071539857782;
                    end;
                end
                else
                begin
                    Result := 0.00097576680991170474;
                end;
            end;
        end
        else
        begin
            if features[173] <= -4204.9999999999991 then
            begin
                Result := -0.019724683155880839;
            end
            else
            begin
                if features[174] <= -5279.4999999999991 then
                begin
                    Result := -0.0076144282907465791;
                end
                else
                begin
                    if features[216] <= -5183.4999999999991 then
                    begin
                        Result := 0.010552741840103711;
                    end
                    else
                    begin
                        Result := -0.0020627010649014606;
                    end;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_251(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[216] <= -4176.4999999999991 then
    begin
        if features[128] <= 45609.500000000007 then
        begin
            if features[48] <= 13684.000000000002 then
            begin
                if features[174] <= -5630.4999999999991 then
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.00066397216177273852;
                    end
                    else
                    begin
                        Result := -0.0096373273473204929;
                    end;
                end
                else
                begin
                    if features[216] <= -6048.4999999999991 then
                    begin
                        Result := 0.010686119269882013;
                    end
                    else
                    begin
                        Result := -0.00050107314852008218;
                    end;
                end;
            end
            else
            begin
                if features[220] <= -459.49999999999994 then
                begin
                    Result := 0.012389524915356923;
                end
                else
                begin
                    Result := -7.5312793333259749E-05;
                end;
            end;
        end
        else
        begin
            Result := -0.017287466157331604;
        end;
    end
    else
    begin
        if features[174] <= -5636.4999999999991 then
        begin
            Result := 0.011063950448474757;
        end
        else
        begin
            if features[174] <= -4315.4999999999991 then
            begin
                if features[123] <= 41.500000000000007 then
                begin
                    if features[24] <= 4.5000000000000009 then
                    begin
                        Result := -0.010783248229815284;
                    end
                    else
                    begin
                        Result := 0.004019341128526535;
                    end;
                end
                else
                begin
                    if features[0] <= 177748.50000000003 then
                    begin
                        Result := -0.021888172980993909;
                    end
                    else
                    begin
                        Result := 0.029808026789277148;
                    end;
                end;
            end
            else
            begin
                if features[218] <= -3211.4999999999995 then
                begin
                    if features[226] <= -462.49999999999994 then
                    begin
                        Result := -0.01819763377515201;
                    end
                    else
                    begin
                        Result := 0.010460387062503499;
                    end;
                end
                else
                begin
                    Result := 0.054622677457601888;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_252(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[178] <= 70.500000000000014 then
    begin
        if features[227] <= -5492.4999999999991 then
        begin
            if features[182] <= -5158.4999999999991 then
            begin
                if features[170] <= 9.5000000000000018 then
                begin
                    if features[42] <= 379.50000000000006 then
                    begin
                        Result := -0.0030231013278168295;
                    end
                    else
                    begin
                        Result := -0.016907602998086527;
                    end;
                end
                else
                begin
                    Result := 0.0097430097280955218;
                end;
            end
            else
            begin
                Result := -0.017330974634570378;
            end;
        end
        else
        begin
            if features[164] <= -181311311.99999997 then
            begin
                if features[223] <= -410.49999999999994 then
                begin
                    Result := -0.02042644750875525;
                end
                else
                begin
                    Result := 0.0008654689989685215;
                end;
            end
            else
            begin
                if features[108] <= -1088.4999999999998 then
                begin
                    if features[176] <= -4339.4999999999991 then
                    begin
                        Result := 0.015849135322725225;
                    end
                    else
                    begin
                        Result := -0.013075392924683375;
                    end;
                end
                else
                begin
                    Result := 0.00043579660813382754;
                end;
            end;
        end;
    end
    else
    begin
        if features[107] <= -1.0000000180025095E-35 then
        begin
            if features[224] <= -6533.4999999999991 then
            begin
                Result := -0.030343371698336646;
            end
            else
            begin
                Result := -0.0032702625421878215;
            end;
        end
        else
        begin
            if features[228] <= -6158.4999999999991 then
            begin
                if features[185] <= 16.166666984558109 then
                begin
                    Result := -0.012080156883492781;
                end
                else
                begin
                    Result := 0.021395438864847894;
                end;
            end
            else
            begin
                if features[184] <= -925.49999999999989 then
                begin
                    Result := 0.034228781151115738;
                end
                else
                begin
                    Result := 0.0021051957141947626;
                end;
            end;
        end;
    end;
end;

function bidirectional_tree_253(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    if features[224] <= -7201.9999999999991 then
    begin
        Result := -0.0120676465536231;
    end
    else
    begin
        if features[229] <= 139.50000000000003 then
        begin
            if features[176] <= -7655.4999999999991 then
            begin
                if features[216] <= -4101.9999999999991 then
                begin
                    if features[108] <= -555.49999999999989 then
                    begin
                        Result := 0.0086481097256618095;
                    end
                    else
                    begin
                        Result := -0.0090031779819702683;
                    end;
                end
                else
                begin
                    if features[225] <= -5288.4999999999991 then
                    begin
                        Result := 0.027785074419597589;
                    end
                    else
                    begin
                        Result := -0.0096258614823051848;
                    end;
                end;
            end
            else
            begin
                if features[220] <= 453.50000000000006 then
                begin
                    if features[216] <= -5190.4999999999991 then
                    begin
                        Result := 0.0027059820134539788;
                    end
                    else
                    begin
                        Result := -0.0013230906124219826;
                    end;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.027741910862130327;
                    end
                    else
                    begin
                        Result := -0.0023919415170622418;
                    end;
                end;
            end;
        end
        else
        begin
            if features[74] <= 7.5000000000000009 then
            begin
                if features[123] <= -403.99999999999994 then
                begin
                    Result := -0.023237754582033473;
                end
                else
                begin
                    Result := 3.2068834220869811E-05;
                end;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[216] <= -4590.4999999999991 then
                    begin
                        Result := 0.0040609969524008594;
                    end
                    else
                    begin
                        Result := -0.018279333068332595;
                    end;
                end
                else
                begin
                    if features[95] <= 15490034.500000002 then
                    begin
                        Result := 0.012028573960972247;
                    end
                    else
                    begin
                        Result := -0.0021392698607174128;
                    end;
                end;
            end;
        end;
    end;
end;

function long_bidirectional_difference_score(
    const features: TncLongBidirectionalDifferenceFeatures): Double;
begin
    Result := 0.0;
    Result := Result + bidirectional_tree_0(features);
    Result := Result + bidirectional_tree_1(features);
    Result := Result + bidirectional_tree_2(features);
    Result := Result + bidirectional_tree_3(features);
    Result := Result + bidirectional_tree_4(features);
    Result := Result + bidirectional_tree_5(features);
    Result := Result + bidirectional_tree_6(features);
    Result := Result + bidirectional_tree_7(features);
    Result := Result + bidirectional_tree_8(features);
    Result := Result + bidirectional_tree_9(features);
    Result := Result + bidirectional_tree_10(features);
    Result := Result + bidirectional_tree_11(features);
    Result := Result + bidirectional_tree_12(features);
    Result := Result + bidirectional_tree_13(features);
    Result := Result + bidirectional_tree_14(features);
    Result := Result + bidirectional_tree_15(features);
    Result := Result + bidirectional_tree_16(features);
    Result := Result + bidirectional_tree_17(features);
    Result := Result + bidirectional_tree_18(features);
    Result := Result + bidirectional_tree_19(features);
    Result := Result + bidirectional_tree_20(features);
    Result := Result + bidirectional_tree_21(features);
    Result := Result + bidirectional_tree_22(features);
    Result := Result + bidirectional_tree_23(features);
    Result := Result + bidirectional_tree_24(features);
    Result := Result + bidirectional_tree_25(features);
    Result := Result + bidirectional_tree_26(features);
    Result := Result + bidirectional_tree_27(features);
    Result := Result + bidirectional_tree_28(features);
    Result := Result + bidirectional_tree_29(features);
    Result := Result + bidirectional_tree_30(features);
    Result := Result + bidirectional_tree_31(features);
    Result := Result + bidirectional_tree_32(features);
    Result := Result + bidirectional_tree_33(features);
    Result := Result + bidirectional_tree_34(features);
    Result := Result + bidirectional_tree_35(features);
    Result := Result + bidirectional_tree_36(features);
    Result := Result + bidirectional_tree_37(features);
    Result := Result + bidirectional_tree_38(features);
    Result := Result + bidirectional_tree_39(features);
    Result := Result + bidirectional_tree_40(features);
    Result := Result + bidirectional_tree_41(features);
    Result := Result + bidirectional_tree_42(features);
    Result := Result + bidirectional_tree_43(features);
    Result := Result + bidirectional_tree_44(features);
    Result := Result + bidirectional_tree_45(features);
    Result := Result + bidirectional_tree_46(features);
    Result := Result + bidirectional_tree_47(features);
    Result := Result + bidirectional_tree_48(features);
    Result := Result + bidirectional_tree_49(features);
    Result := Result + bidirectional_tree_50(features);
    Result := Result + bidirectional_tree_51(features);
    Result := Result + bidirectional_tree_52(features);
    Result := Result + bidirectional_tree_53(features);
    Result := Result + bidirectional_tree_54(features);
    Result := Result + bidirectional_tree_55(features);
    Result := Result + bidirectional_tree_56(features);
    Result := Result + bidirectional_tree_57(features);
    Result := Result + bidirectional_tree_58(features);
    Result := Result + bidirectional_tree_59(features);
    Result := Result + bidirectional_tree_60(features);
    Result := Result + bidirectional_tree_61(features);
    Result := Result + bidirectional_tree_62(features);
    Result := Result + bidirectional_tree_63(features);
    Result := Result + bidirectional_tree_64(features);
    Result := Result + bidirectional_tree_65(features);
    Result := Result + bidirectional_tree_66(features);
    Result := Result + bidirectional_tree_67(features);
    Result := Result + bidirectional_tree_68(features);
    Result := Result + bidirectional_tree_69(features);
    Result := Result + bidirectional_tree_70(features);
    Result := Result + bidirectional_tree_71(features);
    Result := Result + bidirectional_tree_72(features);
    Result := Result + bidirectional_tree_73(features);
    Result := Result + bidirectional_tree_74(features);
    Result := Result + bidirectional_tree_75(features);
    Result := Result + bidirectional_tree_76(features);
    Result := Result + bidirectional_tree_77(features);
    Result := Result + bidirectional_tree_78(features);
    Result := Result + bidirectional_tree_79(features);
    Result := Result + bidirectional_tree_80(features);
    Result := Result + bidirectional_tree_81(features);
    Result := Result + bidirectional_tree_82(features);
    Result := Result + bidirectional_tree_83(features);
    Result := Result + bidirectional_tree_84(features);
    Result := Result + bidirectional_tree_85(features);
    Result := Result + bidirectional_tree_86(features);
    Result := Result + bidirectional_tree_87(features);
    Result := Result + bidirectional_tree_88(features);
    Result := Result + bidirectional_tree_89(features);
    Result := Result + bidirectional_tree_90(features);
    Result := Result + bidirectional_tree_91(features);
    Result := Result + bidirectional_tree_92(features);
    Result := Result + bidirectional_tree_93(features);
    Result := Result + bidirectional_tree_94(features);
    Result := Result + bidirectional_tree_95(features);
    Result := Result + bidirectional_tree_96(features);
    Result := Result + bidirectional_tree_97(features);
    Result := Result + bidirectional_tree_98(features);
    Result := Result + bidirectional_tree_99(features);
    Result := Result + bidirectional_tree_100(features);
    Result := Result + bidirectional_tree_101(features);
    Result := Result + bidirectional_tree_102(features);
    Result := Result + bidirectional_tree_103(features);
    Result := Result + bidirectional_tree_104(features);
    Result := Result + bidirectional_tree_105(features);
    Result := Result + bidirectional_tree_106(features);
    Result := Result + bidirectional_tree_107(features);
    Result := Result + bidirectional_tree_108(features);
    Result := Result + bidirectional_tree_109(features);
    Result := Result + bidirectional_tree_110(features);
    Result := Result + bidirectional_tree_111(features);
    Result := Result + bidirectional_tree_112(features);
    Result := Result + bidirectional_tree_113(features);
    Result := Result + bidirectional_tree_114(features);
    Result := Result + bidirectional_tree_115(features);
    Result := Result + bidirectional_tree_116(features);
    Result := Result + bidirectional_tree_117(features);
    Result := Result + bidirectional_tree_118(features);
    Result := Result + bidirectional_tree_119(features);
    Result := Result + bidirectional_tree_120(features);
    Result := Result + bidirectional_tree_121(features);
    Result := Result + bidirectional_tree_122(features);
    Result := Result + bidirectional_tree_123(features);
    Result := Result + bidirectional_tree_124(features);
    Result := Result + bidirectional_tree_125(features);
    Result := Result + bidirectional_tree_126(features);
    Result := Result + bidirectional_tree_127(features);
    Result := Result + bidirectional_tree_128(features);
    Result := Result + bidirectional_tree_129(features);
    Result := Result + bidirectional_tree_130(features);
    Result := Result + bidirectional_tree_131(features);
    Result := Result + bidirectional_tree_132(features);
    Result := Result + bidirectional_tree_133(features);
    Result := Result + bidirectional_tree_134(features);
    Result := Result + bidirectional_tree_135(features);
    Result := Result + bidirectional_tree_136(features);
    Result := Result + bidirectional_tree_137(features);
    Result := Result + bidirectional_tree_138(features);
    Result := Result + bidirectional_tree_139(features);
    Result := Result + bidirectional_tree_140(features);
    Result := Result + bidirectional_tree_141(features);
    Result := Result + bidirectional_tree_142(features);
    Result := Result + bidirectional_tree_143(features);
    Result := Result + bidirectional_tree_144(features);
    Result := Result + bidirectional_tree_145(features);
    Result := Result + bidirectional_tree_146(features);
    Result := Result + bidirectional_tree_147(features);
    Result := Result + bidirectional_tree_148(features);
    Result := Result + bidirectional_tree_149(features);
    Result := Result + bidirectional_tree_150(features);
    Result := Result + bidirectional_tree_151(features);
    Result := Result + bidirectional_tree_152(features);
    Result := Result + bidirectional_tree_153(features);
    Result := Result + bidirectional_tree_154(features);
    Result := Result + bidirectional_tree_155(features);
    Result := Result + bidirectional_tree_156(features);
    Result := Result + bidirectional_tree_157(features);
    Result := Result + bidirectional_tree_158(features);
    Result := Result + bidirectional_tree_159(features);
    Result := Result + bidirectional_tree_160(features);
    Result := Result + bidirectional_tree_161(features);
    Result := Result + bidirectional_tree_162(features);
    Result := Result + bidirectional_tree_163(features);
    Result := Result + bidirectional_tree_164(features);
    Result := Result + bidirectional_tree_165(features);
    Result := Result + bidirectional_tree_166(features);
    Result := Result + bidirectional_tree_167(features);
    Result := Result + bidirectional_tree_168(features);
    Result := Result + bidirectional_tree_169(features);
    Result := Result + bidirectional_tree_170(features);
    Result := Result + bidirectional_tree_171(features);
    Result := Result + bidirectional_tree_172(features);
    Result := Result + bidirectional_tree_173(features);
    Result := Result + bidirectional_tree_174(features);
    Result := Result + bidirectional_tree_175(features);
    Result := Result + bidirectional_tree_176(features);
    Result := Result + bidirectional_tree_177(features);
    Result := Result + bidirectional_tree_178(features);
    Result := Result + bidirectional_tree_179(features);
    Result := Result + bidirectional_tree_180(features);
    Result := Result + bidirectional_tree_181(features);
    Result := Result + bidirectional_tree_182(features);
    Result := Result + bidirectional_tree_183(features);
    Result := Result + bidirectional_tree_184(features);
    Result := Result + bidirectional_tree_185(features);
    Result := Result + bidirectional_tree_186(features);
    Result := Result + bidirectional_tree_187(features);
    Result := Result + bidirectional_tree_188(features);
    Result := Result + bidirectional_tree_189(features);
    Result := Result + bidirectional_tree_190(features);
    Result := Result + bidirectional_tree_191(features);
    Result := Result + bidirectional_tree_192(features);
    Result := Result + bidirectional_tree_193(features);
    Result := Result + bidirectional_tree_194(features);
    Result := Result + bidirectional_tree_195(features);
    Result := Result + bidirectional_tree_196(features);
    Result := Result + bidirectional_tree_197(features);
    Result := Result + bidirectional_tree_198(features);
    Result := Result + bidirectional_tree_199(features);
    Result := Result + bidirectional_tree_200(features);
    Result := Result + bidirectional_tree_201(features);
    Result := Result + bidirectional_tree_202(features);
    Result := Result + bidirectional_tree_203(features);
    Result := Result + bidirectional_tree_204(features);
    Result := Result + bidirectional_tree_205(features);
    Result := Result + bidirectional_tree_206(features);
    Result := Result + bidirectional_tree_207(features);
    Result := Result + bidirectional_tree_208(features);
    Result := Result + bidirectional_tree_209(features);
    Result := Result + bidirectional_tree_210(features);
    Result := Result + bidirectional_tree_211(features);
    Result := Result + bidirectional_tree_212(features);
    Result := Result + bidirectional_tree_213(features);
    Result := Result + bidirectional_tree_214(features);
    Result := Result + bidirectional_tree_215(features);
    Result := Result + bidirectional_tree_216(features);
    Result := Result + bidirectional_tree_217(features);
    Result := Result + bidirectional_tree_218(features);
    Result := Result + bidirectional_tree_219(features);
    Result := Result + bidirectional_tree_220(features);
    Result := Result + bidirectional_tree_221(features);
    Result := Result + bidirectional_tree_222(features);
    Result := Result + bidirectional_tree_223(features);
    Result := Result + bidirectional_tree_224(features);
    Result := Result + bidirectional_tree_225(features);
    Result := Result + bidirectional_tree_226(features);
    Result := Result + bidirectional_tree_227(features);
    Result := Result + bidirectional_tree_228(features);
    Result := Result + bidirectional_tree_229(features);
    Result := Result + bidirectional_tree_230(features);
    Result := Result + bidirectional_tree_231(features);
    Result := Result + bidirectional_tree_232(features);
    Result := Result + bidirectional_tree_233(features);
    Result := Result + bidirectional_tree_234(features);
    Result := Result + bidirectional_tree_235(features);
    Result := Result + bidirectional_tree_236(features);
    Result := Result + bidirectional_tree_237(features);
    Result := Result + bidirectional_tree_238(features);
    Result := Result + bidirectional_tree_239(features);
    Result := Result + bidirectional_tree_240(features);
    Result := Result + bidirectional_tree_241(features);
    Result := Result + bidirectional_tree_242(features);
    Result := Result + bidirectional_tree_243(features);
    Result := Result + bidirectional_tree_244(features);
    Result := Result + bidirectional_tree_245(features);
    Result := Result + bidirectional_tree_246(features);
    Result := Result + bidirectional_tree_247(features);
    Result := Result + bidirectional_tree_248(features);
    Result := Result + bidirectional_tree_249(features);
    Result := Result + bidirectional_tree_250(features);
    Result := Result + bidirectional_tree_251(features);
    Result := Result + bidirectional_tree_252(features);
    Result := Result + bidirectional_tree_253(features);
end;

function score_reference(const mode: Integer): Double;
var
    features: TncLongBidirectionalDifferenceFeatures;
    idx: Integer;
begin
    for idx := 0 to High(features) do
    begin
        case mode of
            0: features[idx] := 0.0;
            1: features[idx] := -1000000.0;
            2: features[idx] := 1000000.0;
        else
            begin
                features[idx] := (idx + 1) * 97.0;
                if Odd(idx) then
                begin
                    features[idx] := -features[idx];
                end;
            end;
        end;
    end;
    Result := long_bidirectional_difference_score(features);
end;

function long_bidirectional_difference_self_test: Boolean;
const
    c_tolerance = 1.0E-9;
begin
    Result := (Abs(score_reference(0) -
        c_long_bidirectional_reference_zero) <= c_tolerance) and
        (Abs(score_reference(1) -
        c_long_bidirectional_reference_low) <= c_tolerance) and
        (Abs(score_reference(2) -
        c_long_bidirectional_reference_high) <= c_tolerance) and
        (Abs(score_reference(3) -
        c_long_bidirectional_reference_mixed) <= c_tolerance);
end;

end.
