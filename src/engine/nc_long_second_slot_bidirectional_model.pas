unit nc_long_second_slot_bidirectional_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_long_exact_anchor_pairwise_model;

type
    TncLongSecondSlotBidirectionalFeatures = array[0..229] of Double;

const
    c_long_second_slot_bidirectional_base_feature_count = 215;
    c_long_second_slot_bidirectional_reverse_radius_count = 5;
    c_long_second_slot_bidirectional_feature_count = 230;
    c_long_second_slot_bidirectional_tree_count = 256;
    c_long_second_slot_bidirectional_threshold = -0.2026193008381432;
    c_long_second_slot_bidirectional_reference_zero = -0.34102197101534065;
    c_long_second_slot_bidirectional_reference_low = -0.89147414270142056;
    c_long_second_slot_bidirectional_reference_high = -0.55821218914059112;
    c_long_second_slot_bidirectional_reference_mixed = -1.6033166908831569;

procedure build_long_second_slot_bidirectional_features(
    const base_features: TncLongExactAnchorPairwiseFeatures;
    const top_reverse_scores: array of Integer;
    const candidate_reverse_scores: array of Integer;
    out features: TncLongSecondSlotBidirectionalFeatures);
function long_second_slot_bidirectional_score(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
function long_second_slot_bidirectional_self_test: Boolean;

implementation

uses
    Math;

{ Generated from independently split novel, chat and formal-language corpora.
  The reverse character LM sees right context around the differing span. This
  ranker only inserts an existing rank-3 complete candidate into Top2.
  Training report SHA-256: 4DF136017699CD395F067F638DC69AE3693F0B1B904E91FD3AD4BAB497DDAF8C
  LightGBM model SHA-256: DCD9EC42C03081ABBE1A83E0627B2195D44B8C75441F03E0E48AD6015C6091C9 }

procedure build_long_second_slot_bidirectional_features(
    const base_features: TncLongExactAnchorPairwiseFeatures;
    const top_reverse_scores: array of Integer;
    const candidate_reverse_scores: array of Integer;
    out features: TncLongSecondSlotBidirectionalFeatures);
var
    idx: Integer;
    offset: Integer;
begin
    for idx := 0 to c_long_second_slot_bidirectional_base_feature_count - 1 do
    begin
        features[idx] := base_features[idx];
    end;
    offset := c_long_second_slot_bidirectional_base_feature_count;
    for idx := 0 to c_long_second_slot_bidirectional_reverse_radius_count - 1 do
    begin
        features[offset + idx * 3] := top_reverse_scores[idx];
        features[offset + idx * 3 + 1] := candidate_reverse_scores[idx];
        features[offset + idx * 3 + 2] :=
            candidate_reverse_scores[idx] - top_reverse_scores[idx];
    end;
end;

function second_slot_bidirectional_tree_0(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= 154.50000000000003 then
    begin
        if features[166] <= -69602031.999999985 then
        begin
            if features[229] <= -288.49999999999994 then
            begin
                Result := -1.6986194946090525;
            end
            else
            begin
                if features[216] <= -4200.4999999999991 then
                begin
                    if features[48] <= 3540.5000000000005 then
                    begin
                        Result := -1.6911157832718047;
                    end
                    else
                    begin
                        Result := -1.670931871183799;
                    end;
                end
                else
                begin
                    Result := -1.6637691998219166;
                end;
            end;
        end
        else
        begin
            if features[229] <= -509.49999999999994 then
            begin
                Result := -1.6881736470387847;
            end
            else
            begin
                if features[216] <= -4017.4999999999995 then
                begin
                    Result := -1.6632293544075218;
                end
                else
                begin
                    if features[216] <= -3833.4999999999995 then
                    begin
                        Result := -1.5904202116688524;
                    end
                    else
                    begin
                        Result := -1.6651006890807367;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -69602031.999999985 then
        begin
            if features[223] <= 1023.5000000000001 then
            begin
                Result := -1.6685640476805541;
            end
            else
            begin
                Result := -1.6256745383491826;
            end;
        end
        else
        begin
            if features[228] <= -4218.4999999999991 then
            begin
                if features[60] <= -1.0000000180025095E-35 then
                begin
                    if features[15] <= -153929175.99999997 then
                    begin
                        Result := -1.6711524272792277;
                    end
                    else
                    begin
                        Result := -1.6245377837587605;
                    end;
                end
                else
                begin
                    Result := -1.6697393754567245;
                end;
            end
            else
            begin
                if features[105] <= 2.5000000000000004 then
                begin
                    Result := -1.591610497818243;
                end
                else
                begin
                    Result := -1.6307595586569248;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_1(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= 44.500000000000007 then
    begin
        if features[226] <= -483.49999999999994 then
        begin
            Result := -0.02336901322580013;
        end
        else
        begin
            if features[175] <= -272.49999999999994 then
            begin
                if features[185] <= 69.366668701171889 then
                begin
                    Result := -0.013805476634516116;
                end
                else
                begin
                    Result := 0.0095532123451453586;
                end;
            end
            else
            begin
                if features[164] <= -112882087.99999999 then
                begin
                    Result := -0.011489228519807928;
                end
                else
                begin
                    if features[216] <= -4373.4999999999991 then
                    begin
                        Result := 0.0054567230521036202;
                    end
                    else
                    begin
                        Result := 0.031812618439805589;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 758.50000000000011 then
        begin
            if features[15] <= -177711079.99999997 then
            begin
                Result := -0.01068254791272601;
            end
            else
            begin
                if features[8] <= 1.0000000180025095E-35 then
                begin
                    if features[222] <= -5207.4999999999991 then
                    begin
                        Result := 0.023387682571105527;
                    end
                    else
                    begin
                        Result := 0.059414988078556843;
                    end;
                end
                else
                begin
                    if features[178] <= 122.50000000000001 then
                    begin
                        Result := 0.006125329971046283;
                    end
                    else
                    begin
                        Result := 0.029828951379850501;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -4547.4999999999991 then
            begin
                Result := 0.042465378226551415;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    Result := 0.098395720276169052;
                end
                else
                begin
                    if features[122] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0070372166943691687;
                    end
                    else
                    begin
                        Result := 0.060554996788091231;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_2(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= 154.50000000000003 then
    begin
        if features[166] <= -136065383.99999997 then
        begin
            if features[229] <= -311.49999999999994 then
            begin
                Result := -0.026629888377421081;
            end
            else
            begin
                Result := -0.01604360494258605;
            end;
        end
        else
        begin
            if features[229] <= -560.49999999999989 then
            begin
                Result := -0.018395920107681034;
            end
            else
            begin
                if features[166] <= -44508701.999999993 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0069874336605782045;
                    end
                    else
                    begin
                        Result := 0.016398023173869229;
                    end;
                end
                else
                begin
                    if features[174] <= -4950.4999999999991 then
                    begin
                        Result := 0.0098708609271420406;
                    end
                    else
                    begin
                        Result := 0.030644467738251871;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -69602031.999999985 then
        begin
            if features[172] <= 2.5000000000000004 then
            begin
                if features[219] <= -5726.4999999999991 then
                begin
                    Result := 0.0045885994850956534;
                end
                else
                begin
                    Result := 0.039000992559810016;
                end;
            end
            else
            begin
                Result := -0.0021846124112672649;
            end;
        end
        else
        begin
            if features[106] <= 1.0000000180025095E-35 then
            begin
                if features[229] <= 550.50000000000011 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.055910814944959523;
                    end
                    else
                    begin
                        Result := 0.029950882285937314;
                    end;
                end
                else
                begin
                    Result := 0.07307878351603668;
                end;
            end
            else
            begin
                if features[15] <= -193464599.99999997 then
                begin
                    Result := -0.015428152865817344;
                end
                else
                begin
                    Result := 0.035680228242427302;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_3(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -69602031.999999985 then
    begin
        if features[226] <= -157.49999999999997 then
        begin
            if features[166] <= -199453343.99999997 then
            begin
                Result := -0.026991261270000528;
            end
            else
            begin
                Result := -0.016382452164483113;
            end;
        end
        else
        begin
            if features[223] <= 1163.5000000000002 then
            begin
                if features[48] <= 2444.5000000000005 then
                begin
                    Result := -0.0081313030539187214;
                end
                else
                begin
                    if features[175] <= -432.49999999999994 then
                    begin
                        Result := -0.0036474521205554799;
                    end
                    else
                    begin
                        Result := 0.032515424045101569;
                    end;
                end;
            end
            else
            begin
                Result := 0.053250569265415992;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[229] <= -509.49999999999994 then
            begin
                Result := -0.014288592501464567;
            end
            else
            begin
                if features[174] <= -4772.4999999999991 then
                begin
                    Result := 0.0080762220580901569;
                end
                else
                begin
                    if features[216] <= -3981.9999999999995 then
                    begin
                        Result := 0.020413574611807844;
                    end
                    else
                    begin
                        Result := 0.061857303711567349;
                    end;
                end;
            end;
        end
        else
        begin
            if features[15] <= -228169327.99999997 then
            begin
                Result := -0.017596048311660544;
            end
            else
            begin
                if features[105] <= 2.5000000000000004 then
                begin
                    if features[226] <= 1103.5000000000002 then
                    begin
                        Result := 0.046436250894854945;
                    end
                    else
                    begin
                        Result := 0.078237105643730959;
                    end;
                end
                else
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.049392698816650371;
                    end
                    else
                    begin
                        Result := 0.016397679255755793;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_4(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -12.499999999999998 then
    begin
        if features[166] <= -83596415.999999985 then
        begin
            if features[166] <= -192896135.99999997 then
            begin
                Result := -0.025926954938307292;
            end
            else
            begin
                Result := -0.014847646865284057;
            end;
        end
        else
        begin
            if features[229] <= -560.49999999999989 then
            begin
                Result := -0.018803770701071563;
            end
            else
            begin
                if features[177] <= -4437.9999999999991 then
                begin
                    Result := 0.0052665837036411861;
                end
                else
                begin
                    Result := 0.056015989945527138;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= -68244751.999999985 then
        begin
            if features[226] <= 814.50000000000011 then
            begin
                if features[50] <= 1.0000000180025095E-35 then
                begin
                    if features[166] <= -215950815.99999997 then
                    begin
                        Result := -0.023282237785157617;
                    end
                    else
                    begin
                        Result := -0.00056832711760742627;
                    end;
                end
                else
                begin
                    Result := 0.019021256808616206;
                end;
            end
            else
            begin
                Result := 0.034151728280175257;
            end;
        end
        else
        begin
            if features[226] <= 495.50000000000006 then
            begin
                if features[105] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.041163856126805905;
                end
                else
                begin
                    if features[142] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.040722292333842905;
                    end
                    else
                    begin
                        Result := 0.014907948108605049;
                    end;
                end;
            end
            else
            begin
                if features[105] <= 2.5000000000000004 then
                begin
                    if features[15] <= -228169327.99999997 then
                    begin
                        Result := -0.019231824169536463;
                    end
                    else
                    begin
                        Result := 0.05898740708395827;
                    end;
                end
                else
                begin
                    Result := 0.030523608819445866;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_5(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[223] <= -8.4999999999999982 then
    begin
        if features[223] <= -677.49999999999989 then
        begin
            Result := -0.024265916270436127;
        end
        else
        begin
            if features[164] <= -25657317.999999996 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[108] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.012492816009848974;
                    end
                    else
                    begin
                        Result := 0.011363003249912981;
                    end;
                end
                else
                begin
                    Result := -0.023650138919137254;
                end;
            end
            else
            begin
                if features[184] <= -560.49999999999989 then
                begin
                    Result := -0.011298805887674417;
                end
                else
                begin
                    if features[216] <= -4054.4999999999995 then
                    begin
                        Result := 0.0027504925831761877;
                    end
                    else
                    begin
                        Result := 0.033116456090534714;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[223] <= 948.50000000000011 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[76] <= 3.5000000000000004 then
                begin
                    Result := 0.039893920106185671;
                end
                else
                begin
                    Result := 0.017687788955570893;
                end;
            end
            else
            begin
                if features[186] <= -56.874999999999993 then
                begin
                    Result := -0.0004978442352353774;
                end
                else
                begin
                    if features[216] <= -4080.4999999999995 then
                    begin
                        Result := 0.013350242045442225;
                    end
                    else
                    begin
                        Result := 0.042828110463315569;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -5176.4999999999991 then
            begin
                Result := 0.03199959824255804;
            end
            else
            begin
                if features[40] <= 1078.5000000000002 then
                begin
                    Result := 0.067858378236998251;
                end
                else
                begin
                    Result := 0.036339641075689356;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_6(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -68244751.999999985 then
    begin
        if features[226] <= -7.4999999999999991 then
        begin
            if features[166] <= -184685991.99999997 then
            begin
                Result := -0.025699173096894658;
            end
            else
            begin
                Result := -0.013899695065244409;
            end;
        end
        else
        begin
            if features[226] <= 839.50000000000011 then
            begin
                if features[166] <= -218413975.99999997 then
                begin
                    Result := -0.018316065708166972;
                end
                else
                begin
                    Result := 0.0045645317777616322;
                end;
            end
            else
            begin
                Result := 0.0349494536594743;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[229] <= -509.49999999999994 then
            begin
                Result := -0.014121524214736274;
            end
            else
            begin
                if features[216] <= -4017.4999999999995 then
                begin
                    if features[106] <= -1.4999999999999998 then
                    begin
                        Result := 0.022711115511406369;
                    end
                    else
                    begin
                        Result := 0.0043520726083762055;
                    end;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.084187696621935815;
                    end
                    else
                    begin
                        Result := 0.018543603731337299;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4248.4999999999991 then
            begin
                if features[15] <= -228169327.99999997 then
                begin
                    Result := -0.019328521846334622;
                end
                else
                begin
                    if features[106] <= 1.5000000000000002 then
                    begin
                        Result := 0.040004672855620725;
                    end
                    else
                    begin
                        Result := 0.022402398611411987;
                    end;
                end;
            end
            else
            begin
                if features[40] <= 1075.5000000000002 then
                begin
                    Result := 0.067054604672366805;
                end
                else
                begin
                    Result := 0.036713253121512614;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_7(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= 44.500000000000007 then
    begin
        if features[229] <= -509.49999999999994 then
        begin
            Result := -0.024160435836390562;
        end
        else
        begin
            if features[184] <= -527.49999999999989 then
            begin
                Result := -0.014509280985461216;
            end
            else
            begin
                if features[216] <= -4044.4999999999995 then
                begin
                    if features[118] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.010726973007475944;
                    end
                    else
                    begin
                        Result := -0.0067144982783553207;
                    end;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.071610556597280259;
                    end
                    else
                    begin
                        Result := -0.0048280295350766299;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 495.50000000000006 then
        begin
            if features[48] <= 10665.500000000002 then
            begin
                if features[15] <= -170665159.99999997 then
                begin
                    Result := -0.01646003209119104;
                end
                else
                begin
                    if features[174] <= -4889.4999999999991 then
                    begin
                        Result := 0.008891394305384848;
                    end
                    else
                    begin
                        Result := 0.030139080324029711;
                    end;
                end;
            end
            else
            begin
                Result := 0.04039245936454447;
            end;
        end
        else
        begin
            if features[15] <= -233863447.99999997 then
            begin
                Result := -0.01582910674414675;
            end
            else
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[106] <= 1.5000000000000002 then
                    begin
                        Result := 0.035562188399803019;
                    end
                    else
                    begin
                        Result := 0.0069741305173940463;
                    end;
                end
                else
                begin
                    if features[222] <= -4527.4999999999991 then
                    begin
                        Result := 0.037717165273633911;
                    end
                    else
                    begin
                        Result := 0.066922499245743935;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_8(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -69602031.999999985 then
    begin
        if features[229] <= -162.49999999999997 then
        begin
            if features[166] <= -199453343.99999997 then
            begin
                Result := -0.026376377661670575;
            end
            else
            begin
                Result := -0.016012099390315587;
            end;
        end
        else
        begin
            if features[166] <= -218413975.99999997 then
            begin
                Result := -0.017710484685928864;
            end
            else
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    if features[2] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0068189022459308121;
                    end
                    else
                    begin
                        Result := 0.014642508108254388;
                    end;
                end
                else
                begin
                    Result := 0.023048835610160478;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[229] <= -509.49999999999994 then
            begin
                Result := -0.013034404955270279;
            end
            else
            begin
                if features[174] <= -4772.4999999999991 then
                begin
                    if features[105] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.018071377359292606;
                    end
                    else
                    begin
                        Result := 0.0011404948678500374;
                    end;
                end
                else
                begin
                    if features[216] <= -3981.9999999999995 then
                    begin
                        Result := 0.019329697673770851;
                    end
                    else
                    begin
                        Result := 0.050698335199003186;
                    end;
                end;
            end;
        end
        else
        begin
            if features[105] <= 2.5000000000000004 then
            begin
                if features[15] <= -228169327.99999997 then
                begin
                    Result := -0.015951435903020738;
                end
                else
                begin
                    if features[226] <= 1103.5000000000002 then
                    begin
                        Result := 0.036822006572259633;
                    end
                    else
                    begin
                        Result := 0.059507167904524441;
                    end;
                end;
            end
            else
            begin
                Result := 0.018580135621394208;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_9(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -69602031.999999985 then
    begin
        if features[226] <= -211.49999999999997 then
        begin
            if features[166] <= -199453343.99999997 then
            begin
                Result := -0.026234854204804273;
            end
            else
            begin
                Result := -0.016366061924316225;
            end;
        end
        else
        begin
            if features[222] <= -5207.4999999999991 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0053921534223898004;
                end
                else
                begin
                    Result := -0.014394870913684667;
                end;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[216] <= -4079.4999999999995 then
                    begin
                        Result := 0.01499297584847374;
                    end
                    else
                    begin
                        Result := 0.057294687634960872;
                    end;
                end
                else
                begin
                    Result := -0.0052317048281336903;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 209.50000000000003 then
        begin
            if features[226] <= -555.49999999999989 then
            begin
                Result := -0.010991918202495071;
            end
            else
            begin
                if features[174] <= -4772.4999999999991 then
                begin
                    if features[105] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.018687759283499871;
                    end
                    else
                    begin
                        Result := 0.000743393138451581;
                    end;
                end
                else
                begin
                    Result := 0.027408817288986139;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4405.4999999999991 then
            begin
                if features[106] <= 1.0000000180025095E-35 then
                begin
                    if features[222] <= -4487.4999999999991 then
                    begin
                        Result := 0.030596838502308706;
                    end
                    else
                    begin
                        Result := 0.055882088301564818;
                    end;
                end
                else
                begin
                    Result := 0.018893025603632908;
                end;
            end
            else
            begin
                Result := 0.046579582412490411;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_10(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -68244751.999999985 then
    begin
        if features[229] <= -167.49999999999997 then
        begin
            if features[166] <= -149541167.99999997 then
            begin
                Result := -0.024948722001672301;
            end
            else
            begin
                Result := -0.014183120161349681;
            end;
        end
        else
        begin
            if features[166] <= -184685991.99999997 then
            begin
                Result := -0.014725519779041851;
            end
            else
            begin
                if features[222] <= -5185.4999999999991 then
                begin
                    Result := -0.0032679324550357047;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.0021401313162920654;
                    end
                    else
                    begin
                        Result := 0.028148473671814805;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= -24.499999999999996 then
        begin
            if features[229] <= -509.49999999999994 then
            begin
                Result := -0.012855088100958765;
            end
            else
            begin
                if features[177] <= -4437.9999999999991 then
                begin
                    Result := 0.0053423215778638788;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.074056683028232762;
                    end
                    else
                    begin
                        Result := -0.011636639391385558;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4054.4999999999995 then
            begin
                if features[106] <= -1.4999999999999998 then
                begin
                    Result := 0.039141587372983386;
                end
                else
                begin
                    if features[220] <= 386.50000000000006 then
                    begin
                        Result := 0.0098932056263144989;
                    end
                    else
                    begin
                        Result := 0.027139868471733105;
                    end;
                end;
            end
            else
            begin
                if features[122] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0038868560246841663;
                end
                else
                begin
                    Result := 0.050537636156765299;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_11(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -68244751.999999985 then
    begin
        if features[226] <= -7.4999999999999991 then
        begin
            if features[166] <= -184685991.99999997 then
            begin
                Result := -0.024670700715511914;
            end
            else
            begin
                Result := -0.012773970922952139;
            end;
        end
        else
        begin
            if features[2] <= 1.0000000180025095E-35 then
            begin
                if features[226] <= 871.50000000000011 then
                begin
                    Result := -0.0049194818220602548;
                end
                else
                begin
                    Result := 0.028318789676211133;
                end;
            end
            else
            begin
                Result := 0.020753398331953263;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[229] <= -509.49999999999994 then
            begin
                Result := -0.012375419794785014;
            end
            else
            begin
                if features[174] <= -4966.4999999999991 then
                begin
                    if features[106] <= -1.4999999999999998 then
                    begin
                        Result := 0.017690524566531307;
                    end
                    else
                    begin
                        Result := 0.00086113318049972512;
                    end;
                end
                else
                begin
                    Result := 0.022704641895732725;
                end;
            end;
        end
        else
        begin
            if features[106] <= 1.5000000000000002 then
            begin
                if features[222] <= -4654.4999999999991 then
                begin
                    Result := 0.029596748608217645;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.029170060512906812;
                    end
                    else
                    begin
                        Result := 0.054701546737451395;
                    end;
                end;
            end
            else
            begin
                if features[105] <= 1.5000000000000002 then
                begin
                    Result := 0.035311846260291428;
                end
                else
                begin
                    if features[217] <= 22.500000000000004 then
                    begin
                        Result := -0.0075647267851516615;
                    end
                    else
                    begin
                        Result := 0.020423806943937431;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_12(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -12.499999999999998 then
    begin
        if features[226] <= -650.49999999999989 then
        begin
            Result := -0.024157899189748033;
        end
        else
        begin
            if features[108] <= -61.499999999999993 then
            begin
                if features[48] <= 5037.0000000000009 then
                begin
                    Result := -0.014938719308688661;
                end
                else
                begin
                    Result := 0.00072289088568680603;
                end;
            end
            else
            begin
                if features[216] <= -3981.9999999999995 then
                begin
                    Result := 0.00040848759632239269;
                end
                else
                begin
                    if features[216] <= -3939.4999999999995 then
                    begin
                        Result := 0.075370909262027594;
                    end
                    else
                    begin
                        Result := 0.0015971187037372157;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 495.50000000000006 then
        begin
            if features[48] <= 10334.500000000002 then
            begin
                if features[15] <= -170665159.99999997 then
                begin
                    Result := -0.017647207426651927;
                end
                else
                begin
                    if features[175] <= -199.49999999999997 then
                    begin
                        Result := 0.00068913955758067788;
                    end
                    else
                    begin
                        Result := 0.016733448642937163;
                    end;
                end;
            end
            else
            begin
                Result := 0.033211443630769256;
            end;
        end
        else
        begin
            if features[15] <= -233863447.99999997 then
            begin
                Result := -0.014821079610699374;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[106] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.029562264616619344;
                    end
                    else
                    begin
                        Result := 0.00046875301023875237;
                    end;
                end
                else
                begin
                    if features[222] <= -4274.4999999999991 then
                    begin
                        Result := 0.031418933052606964;
                    end
                    else
                    begin
                        Result := 0.057307827343239359;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_13(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -79390879.999999985 then
    begin
        if features[229] <= -167.49999999999997 then
        begin
            if features[166] <= -199453343.99999997 then
            begin
                Result := -0.025622711604805105;
            end
            else
            begin
                Result := -0.015884130933897411;
            end;
        end
        else
        begin
            if features[166] <= -218413975.99999997 then
            begin
                Result := -0.019482531476074962;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    if features[216] <= -4589.4999999999991 then
                    begin
                        Result := 0.0097103663393687065;
                    end
                    else
                    begin
                        Result := 0.046015789763067035;
                    end;
                end
                else
                begin
                    Result := -0.0014335316449406972;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[229] <= -560.49999999999989 then
            begin
                Result := -0.015219486125863253;
            end
            else
            begin
                if features[216] <= -4017.4999999999995 then
                begin
                    if features[105] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.016279251521956462;
                    end
                    else
                    begin
                        Result := 0.0021446153020551308;
                    end;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.067592954989339593;
                    end
                    else
                    begin
                        Result := 0.01358533684353831;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 1340.5000000000002 then
            begin
                if features[53] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.036568411122536004;
                end
                else
                begin
                    Result := 0.019976593761947683;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.05613934965323622;
                end
                else
                begin
                    Result := 0.028730188921818063;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_14(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -69602031.999999985 then
    begin
        if features[229] <= -167.49999999999997 then
        begin
            if features[166] <= -199453343.99999997 then
            begin
                Result := -0.025489239458535269;
            end
            else
            begin
                Result := -0.014686387677864635;
            end;
        end
        else
        begin
            if features[1] <= 29293.000000000004 then
            begin
                if features[226] <= 871.50000000000011 then
                begin
                    if features[9] <= 3.5000000000000004 then
                    begin
                        Result := -0.011480250670159354;
                    end
                    else
                    begin
                        Result := 0.010090698990976931;
                    end;
                end
                else
                begin
                    Result := 0.027150268522787471;
                end;
            end
            else
            begin
                if features[225] <= -5865.4999999999991 then
                begin
                    Result := -0.013524227815749133;
                end
                else
                begin
                    Result := 0.021847924333576279;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[229] <= -509.49999999999994 then
            begin
                Result := -0.011582804437723793;
            end
            else
            begin
                if features[216] <= -3981.9999999999995 then
                begin
                    if features[106] <= -1.4999999999999998 then
                    begin
                        Result := 0.018682904086269103;
                    end
                    else
                    begin
                        Result := 0.0033058890274935749;
                    end;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.064794181569161224;
                    end
                    else
                    begin
                        Result := 0.013113792178855808;
                    end;
                end;
            end;
        end
        else
        begin
            if features[225] <= -4248.4999999999991 then
            begin
                if features[150] <= -6.4999999999999991 then
                begin
                    Result := 0.041832959339620106;
                end
                else
                begin
                    Result := 0.02037783126318627;
                end;
            end
            else
            begin
                Result := 0.039101953534225499;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_15(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -113380651.99999999 then
    begin
        if features[229] <= -254.49999999999997 then
        begin
            Result := -0.023764451904345844;
        end
        else
        begin
            if features[226] <= 839.50000000000011 then
            begin
                if features[166] <= -226073471.99999997 then
                begin
                    Result := -0.019929794197261666;
                end
                else
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0085960348986353213;
                    end
                    else
                    begin
                        Result := 0.010247265638271707;
                    end;
                end;
            end
            else
            begin
                if features[172] <= 3.5000000000000004 then
                begin
                    Result := 0.049340722949751788;
                end
                else
                begin
                    Result := -0.0046919279285832175;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= 154.50000000000003 then
        begin
            if features[229] <= -560.49999999999989 then
            begin
                Result := -0.014733430741887181;
            end
            else
            begin
                if features[175] <= -272.49999999999994 then
                begin
                    Result := -0.0027920323609728812;
                end
                else
                begin
                    if features[216] <= -4373.4999999999991 then
                    begin
                        Result := 0.0073480394879193575;
                    end
                    else
                    begin
                        Result := 0.029735046936650723;
                    end;
                end;
            end;
        end
        else
        begin
            if features[15] <= -228169327.99999997 then
            begin
                Result := -0.014215536282026112;
            end
            else
            begin
                if features[216] <= -4389.4999999999991 then
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.030594378367238412;
                    end
                    else
                    begin
                        Result := 0.016328980139605261;
                    end;
                end
                else
                begin
                    if features[40] <= 1069.5000000000002 then
                    begin
                        Result := 0.043300157617306059;
                    end
                    else
                    begin
                        Result := 0.022093336356429034;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_16(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -134512495.99999997 then
    begin
        if features[229] <= -305.49999999999994 then
        begin
            Result := -0.024601447944637738;
        end
        else
        begin
            if features[226] <= 783.50000000000011 then
            begin
                Result := -0.011852503544020648;
            end
            else
            begin
                Result := 0.021479438840481285;
            end;
        end;
    end
    else
    begin
        if features[226] <= 44.500000000000007 then
        begin
            if features[166] <= -33218063.999999996 then
            begin
                if features[216] <= -4054.4999999999995 then
                begin
                    if features[226] <= -362.49999999999994 then
                    begin
                        Result := -0.01738087449253492;
                    end
                    else
                    begin
                        Result := -0.0041478400404581809;
                    end;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.057400267159357511;
                    end
                    else
                    begin
                        Result := -0.0046753993593060287;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -4102.4999999999991 then
                begin
                    if features[215] <= -4108.4999999999991 then
                    begin
                        Result := 0.0092956567342457105;
                    end
                    else
                    begin
                        Result := 0.066574102103576185;
                    end;
                end
                else
                begin
                    Result := -0.011231756231423327;
                end;
            end;
        end
        else
        begin
            if features[15] <= -223976111.99999997 then
            begin
                Result := -0.015770291911642625;
            end
            else
            begin
                if features[216] <= -4102.4999999999991 then
                begin
                    if features[76] <= 3.5000000000000004 then
                    begin
                        Result := 0.026218854806382499;
                    end
                    else
                    begin
                        Result := 0.013144479064213602;
                    end;
                end
                else
                begin
                    if features[122] <= -1327.9999999999998 then
                    begin
                        Result := -0.0060436564464212174;
                    end
                    else
                    begin
                        Result := 0.040847897440689285;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_17(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -136065383.99999997 then
    begin
        if features[229] <= -305.49999999999994 then
        begin
            Result := -0.02446728834625822;
        end
        else
        begin
            if features[223] <= 758.50000000000011 then
            begin
                if features[166] <= -265031895.99999997 then
                begin
                    Result := -0.024057954752369062;
                end
                else
                begin
                    Result := -0.0082578266848762853;
                end;
            end
            else
            begin
                Result := 0.015887878160597918;
            end;
        end;
    end
    else
    begin
        if features[229] <= 154.50000000000003 then
        begin
            if features[229] <= -560.49999999999989 then
            begin
                if features[224] <= -5544.4999999999991 then
                begin
                    Result := 0.0071754993178896539;
                end
                else
                begin
                    Result := -0.019397805310002566;
                end;
            end
            else
            begin
                if features[216] <= -4017.4999999999995 then
                begin
                    if features[166] <= -40553171.999999993 then
                    begin
                        Result := -0.0047606119519889101;
                    end
                    else
                    begin
                        Result := 0.010038136706695918;
                    end;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.059767162219688579;
                    end
                    else
                    begin
                        Result := 0.0095749446877059982;
                    end;
                end;
            end;
        end
        else
        begin
            if features[15] <= -228169327.99999997 then
            begin
                Result := -0.012991540815632675;
            end
            else
            begin
                if features[105] <= 2.5000000000000004 then
                begin
                    if features[223] <= 1334.5000000000002 then
                    begin
                        Result := 0.024646650354745919;
                    end
                    else
                    begin
                        Result := 0.046130155492684538;
                    end;
                end
                else
                begin
                    if features[158] <= 3732.5000000000005 then
                    begin
                        Result := 0.023106400002794358;
                    end
                    else
                    begin
                        Result := 0.002682216476548668;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_18(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -136065383.99999997 then
    begin
        if features[229] <= -311.49999999999994 then
        begin
            Result := -0.024410206277626526;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                Result := 0.0045170557829155317;
            end
            else
            begin
                Result := -0.013842909068086119;
            end;
        end;
    end
    else
    begin
        if features[226] <= 44.500000000000007 then
        begin
            if features[229] <= -560.49999999999989 then
            begin
                Result := -0.016508159531784528;
            end
            else
            begin
                if features[166] <= -33218063.999999996 then
                begin
                    if features[216] <= -4054.4999999999995 then
                    begin
                        Result := -0.0068431583015566471;
                    end
                    else
                    begin
                        Result := 0.023878483617283619;
                    end;
                end
                else
                begin
                    if features[129] <= 9054.5000000000018 then
                    begin
                        Result := 0.0063697178768253584;
                    end
                    else
                    begin
                        Result := 0.026001968646528276;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 1103.5000000000002 then
            begin
                if features[106] <= -1.4999999999999998 then
                begin
                    if features[89] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.044184753749086134;
                    end
                    else
                    begin
                        Result := 0.023946535609378289;
                    end;
                end
                else
                begin
                    if features[216] <= -4102.4999999999991 then
                    begin
                        Result := 0.010409152050178019;
                    end
                    else
                    begin
                        Result := 0.02765901855030773;
                    end;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.044775010461968232;
                end
                else
                begin
                    if features[73] <= 334.50000000000006 then
                    begin
                        Result := 0.01719844343844144;
                    end
                    else
                    begin
                        Result := 0.060274879062972866;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_19(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -69602031.999999985 then
    begin
        if features[226] <= -157.49999999999997 then
        begin
            if features[166] <= -199453343.99999997 then
            begin
                Result := -0.02482313328604608;
            end
            else
            begin
                Result := -0.013526123169987143;
            end;
        end
        else
        begin
            if features[48] <= 3540.5000000000005 then
            begin
                if features[226] <= 350.50000000000006 then
                begin
                    if features[9] <= 3.5000000000000004 then
                    begin
                        Result := -0.013968913485447305;
                    end
                    else
                    begin
                        Result := 0.0069345237351404231;
                    end;
                end
                else
                begin
                    Result := 0.0079509091472081007;
                end;
            end
            else
            begin
                if features[176] <= -5174.4999999999991 then
                begin
                    if features[225] <= -5995.4999999999991 then
                    begin
                        Result := -0.015087241106219049;
                    end
                    else
                    begin
                        Result := 0.028736357652724056;
                    end;
                end
                else
                begin
                    Result := -0.017334487241334112;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -87.499999999999986 then
        begin
            if features[226] <= -863.49999999999989 then
            begin
                Result := -0.016435141720088184;
            end
            else
            begin
                Result := 0.0025667208254550938;
            end;
        end
        else
        begin
            if features[15] <= -228169327.99999997 then
            begin
                Result := -0.017681396702493489;
            end
            else
            begin
                if features[226] <= 495.50000000000006 then
                begin
                    if features[106] <= -1.4999999999999998 then
                    begin
                        Result := 0.027069466824271762;
                    end
                    else
                    begin
                        Result := 0.01158991910490397;
                    end;
                end
                else
                begin
                    if features[105] <= 2.5000000000000004 then
                    begin
                        Result := 0.033583123516031849;
                    end
                    else
                    begin
                        Result := 0.014332246546371389;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_20(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -24.499999999999996 then
    begin
        if features[229] <= -524.49999999999989 then
        begin
            Result := -0.022286221717076442;
        end
        else
        begin
            if features[164] <= -138402751.99999997 then
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.015840579131253002;
                end
                else
                begin
                    Result := 0.010354182369572843;
                end;
            end
            else
            begin
                if features[175] <= -262.49999999999994 then
                begin
                    Result := -0.0090253829858702155;
                end
                else
                begin
                    if features[48] <= 13362.500000000002 then
                    begin
                        Result := 0.0041382199102830471;
                    end
                    else
                    begin
                        Result := 0.037790367020603642;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[15] <= -223976111.99999997 then
        begin
            Result := -0.016158080252042486;
        end
        else
        begin
            if features[216] <= -4102.4999999999991 then
            begin
                if features[229] <= 398.50000000000006 then
                begin
                    if features[129] <= 10443.500000000002 then
                    begin
                        Result := 0.0045187601698895982;
                    end
                    else
                    begin
                        Result := 0.027023696325967517;
                    end;
                end
                else
                begin
                    if features[8] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.034047122979737159;
                    end
                    else
                    begin
                        Result := 0.015944250406872338;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -6122.4999999999991 then
                begin
                    if features[225] <= -5634.4999999999991 then
                    begin
                        Result := 0.01278740511710384;
                    end
                    else
                    begin
                        Result := 0.045309485883202015;
                    end;
                end
                else
                begin
                    if features[109] <= -272.49999999999994 then
                    begin
                        Result := -0.0046025962816511621;
                    end
                    else
                    begin
                        Result := 0.027618079313461649;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_21(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -134512495.99999997 then
    begin
        if features[229] <= -311.49999999999994 then
        begin
            Result := -0.023825139869164444;
        end
        else
        begin
            if features[166] <= -265031895.99999997 then
            begin
                Result := -0.020435783806197087;
            end
            else
            begin
                if features[222] <= -5196.4999999999991 then
                begin
                    Result := -0.010738325678616684;
                end
                else
                begin
                    Result := 0.0048145916838707812;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 44.500000000000007 then
        begin
            if features[166] <= -44508701.999999993 then
            begin
                if features[216] <= -4054.4999999999995 then
                begin
                    Result := -0.0091632768474410528;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.056762566236696912;
                    end
                    else
                    begin
                        Result := -0.0096021059538341468;
                    end;
                end;
            end
            else
            begin
                if features[229] <= -670.49999999999989 then
                begin
                    Result := -0.015083068221076808;
                end
                else
                begin
                    if features[148] <= 2974.5000000000005 then
                    begin
                        Result := 0.010090499279330738;
                    end
                    else
                    begin
                        Result := -0.015951929958124739;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4102.4999999999991 then
            begin
                if features[15] <= -196371783.99999997 then
                begin
                    Result := -0.013669238052555413;
                end
                else
                begin
                    if features[106] <= -1.4999999999999998 then
                    begin
                        Result := 0.027976163626524438;
                    end
                    else
                    begin
                        Result := 0.01329972332010481;
                    end;
                end;
            end
            else
            begin
                if features[122] <= -1327.9999999999998 then
                begin
                    Result := -0.0098713008917019028;
                end
                else
                begin
                    Result := 0.03418166678131173;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_22(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -134512495.99999997 then
    begin
        if features[229] <= -311.49999999999994 then
        begin
            Result := -0.023814103629106215;
        end
        else
        begin
            if features[166] <= -265031895.99999997 then
            begin
                Result := -0.020347803454311673;
            end
            else
            begin
                if features[91] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0091435615584667517;
                end
                else
                begin
                    if features[83] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.013254136690960644;
                    end
                    else
                    begin
                        Result := 0.0059417014654757549;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -12.499999999999998 then
        begin
            if features[229] <= -560.49999999999989 then
            begin
                Result := -0.01617236585948454;
            end
            else
            begin
                if features[177] <= -4437.9999999999991 then
                begin
                    if features[166] <= -37863439.999999993 then
                    begin
                        Result := -0.0051499055942273927;
                    end
                    else
                    begin
                        Result := 0.0064442777228318751;
                    end;
                end
                else
                begin
                    Result := 0.034592553006102471;
                end;
            end;
        end
        else
        begin
            if features[226] <= 971.50000000000011 then
            begin
                if features[106] <= -1.4999999999999998 then
                begin
                    if features[166] <= 26972834.000000004 then
                    begin
                        Result := 0.019112484543162507;
                    end
                    else
                    begin
                        Result := 0.038355494857675192;
                    end;
                end
                else
                begin
                    if features[174] <= -4462.4999999999991 then
                    begin
                        Result := 0.0075847665642427998;
                    end
                    else
                    begin
                        Result := 0.02381517808198598;
                    end;
                end;
            end
            else
            begin
                if features[40] <= 1378.5000000000002 then
                begin
                    Result := 0.032916593977499617;
                end
                else
                begin
                    Result := 0.0097197779688644528;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_23(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -70860131.999999985 then
    begin
        if features[226] <= -247.49999999999997 then
        begin
            if features[166] <= -258758599.99999997 then
            begin
                Result := -0.02581064926725193;
            end
            else
            begin
                Result := -0.015965700053999336;
            end;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[2] <= 1.0000000180025095E-35 then
                begin
                    if features[226] <= 168.50000000000003 then
                    begin
                        Result := -0.016021901820703632;
                    end
                    else
                    begin
                        Result := -0.00045824709196501775;
                    end;
                end
                else
                begin
                    if features[175] <= -376.49999999999994 then
                    begin
                        Result := -0.0049335704658752411;
                    end
                    else
                    begin
                        Result := 0.017973628801287275;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -4507.4999999999991 then
                begin
                    Result := 0.004860743240440845;
                end
                else
                begin
                    Result := 0.035015292149680619;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -112.49999999999999 then
        begin
            if features[226] <= -682.49999999999989 then
            begin
                Result := -0.012891567939438967;
            end
            else
            begin
                Result := 0.0036186853976408299;
            end;
        end
        else
        begin
            if features[15] <= -223976111.99999997 then
            begin
                Result := -0.018002066393051054;
            end
            else
            begin
                if features[226] <= 495.50000000000006 then
                begin
                    if features[14] <= 2233495.5000000005 then
                    begin
                        Result := 0.010634851305307735;
                    end
                    else
                    begin
                        Result := 0.027012031343744393;
                    end;
                end
                else
                begin
                    if features[71] <= 2.5000000000000004 then
                    begin
                        Result := 0.018193184253847673;
                    end
                    else
                    begin
                        Result := 0.03472699653064977;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_24(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[229] <= -254.49999999999997 then
        begin
            Result := -0.023661876519228457;
        end
        else
        begin
            Result := -0.0099092954440891147;
        end;
    end
    else
    begin
        if features[229] <= 28.500000000000004 then
        begin
            if features[166] <= -39122973.999999993 then
            begin
                if features[216] <= -4044.4999999999995 then
                begin
                    Result := -0.0086293833055634105;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.055755738128245962;
                    end
                    else
                    begin
                        Result := -0.008499759812615755;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -4102.4999999999991 then
                begin
                    if features[215] <= -4108.4999999999991 then
                    begin
                        Result := 0.006682609019769606;
                    end
                    else
                    begin
                        Result := 0.056701387978733975;
                    end;
                end
                else
                begin
                    Result := -0.012393430489971663;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[178] <= 341.50000000000006 then
                begin
                    Result := 0.0015437264727830428;
                end
                else
                begin
                    if features[106] <= 1.5000000000000002 then
                    begin
                        Result := 0.023284290852746463;
                    end
                    else
                    begin
                        Result := 0.0018679025733934883;
                    end;
                end;
            end
            else
            begin
                if features[228] <= -4386.4999999999991 then
                begin
                    if features[66] <= 196.00000000000003 then
                    begin
                        Result := 0.016821844558559711;
                    end
                    else
                    begin
                        Result := -0.01837588344562557;
                    end;
                end
                else
                begin
                    if features[53] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.048247143410379285;
                    end
                    else
                    begin
                        Result := 0.024271753969851522;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_25(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -157.49999999999997 then
    begin
        if features[226] <= -788.49999999999989 then
        begin
            Result := -0.023652327203017014;
        end
        else
        begin
            if features[108] <= -284.49999999999994 then
            begin
                Result := -0.014104325814713676;
            end
            else
            begin
                if features[216] <= -3981.9999999999995 then
                begin
                    Result := -0.0045310630038355787;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.074295729243432723;
                    end
                    else
                    begin
                        Result := -0.015450201641987973;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 495.50000000000006 then
        begin
            if features[175] <= -272.49999999999994 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.013380047359024486;
                end
                else
                begin
                    Result := 0.0012196032534095033;
                end;
            end
            else
            begin
                if features[1] <= 22085.500000000004 then
                begin
                    if features[15] <= -194766103.99999997 then
                    begin
                        Result := -0.018730861045544445;
                    end
                    else
                    begin
                        Result := 0.0086583232357645874;
                    end;
                end
                else
                begin
                    Result := 0.024811666139100737;
                end;
            end;
        end
        else
        begin
            if features[15] <= -228169327.99999997 then
            begin
                Result := -0.01655814805224276;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[106] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.02017938672385651;
                    end
                    else
                    begin
                        Result := -0.0043180182456823875;
                    end;
                end
                else
                begin
                    if features[222] <= -4464.4999999999991 then
                    begin
                        Result := 0.019826154945675474;
                    end
                    else
                    begin
                        Result := 0.036842516968790644;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_26(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -136065383.99999997 then
    begin
        if features[229] <= -305.49999999999994 then
        begin
            Result := -0.023416212804427284;
        end
        else
        begin
            if features[223] <= 758.50000000000011 then
            begin
                Result := -0.01089820931464424;
            end
            else
            begin
                Result := 0.017222655685867349;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[216] <= -4017.4999999999995 then
            begin
                if features[166] <= -40553171.999999993 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.003932365912520391;
                    end
                    else
                    begin
                        Result := -0.011431378046675973;
                    end;
                end
                else
                begin
                    if features[215] <= -4102.4999999999991 then
                    begin
                        Result := 0.0082194295810340892;
                    end
                    else
                    begin
                        Result := -0.015911821284479929;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    Result := 0.049763338877975578;
                end
                else
                begin
                    if features[229] <= -20.499999999999996 then
                    begin
                        Result := -0.0087191746364305694;
                    end
                    else
                    begin
                        Result := 0.02320012651658868;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 1103.5000000000002 then
            begin
                if features[172] <= 2.5000000000000004 then
                begin
                    if features[71] <= 2.5000000000000004 then
                    begin
                        Result := 0.01292446386039626;
                    end
                    else
                    begin
                        Result := 0.028817558089395567;
                    end;
                end
                else
                begin
                    if features[175] <= -1413.4999999999998 then
                    begin
                        Result := -0.017730455760394902;
                    end
                    else
                    begin
                        Result := 0.010806728035791774;
                    end;
                end;
            end
            else
            begin
                Result := 0.027265417551411705;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_27(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -136065383.99999997 then
    begin
        if features[229] <= -486.49999999999994 then
        begin
            Result := -0.024819477666348778;
        end
        else
        begin
            if features[166] <= -218413975.99999997 then
            begin
                Result := -0.017327192337864141;
            end
            else
            begin
                Result := -0.0044522844774940243;
            end;
        end;
    end
    else
    begin
        if features[226] <= -157.49999999999997 then
        begin
            if features[216] <= -4017.4999999999995 then
            begin
                if features[216] <= -7304.4999999999991 then
                begin
                    Result := 0.020121042978798173;
                end
                else
                begin
                    if features[226] <= -863.49999999999989 then
                    begin
                        Result := -0.023058720358172878;
                    end
                    else
                    begin
                        Result := -0.0047654456856733264;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    Result := 0.057574454603918093;
                end
                else
                begin
                    Result := -0.011411686140263203;
                end;
            end;
        end
        else
        begin
            if features[226] <= 495.50000000000006 then
            begin
                if features[48] <= 10334.500000000002 then
                begin
                    if features[175] <= -420.49999999999994 then
                    begin
                        Result := -0.0023057371537859726;
                    end
                    else
                    begin
                        Result := 0.010202347230015457;
                    end;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0010214292582754953;
                    end
                    else
                    begin
                        Result := 0.030954364663545127;
                    end;
                end;
            end
            else
            begin
                if features[155] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.031267874165972792;
                end
                else
                begin
                    if features[158] <= 3732.5000000000005 then
                    begin
                        Result := 0.020780480243536292;
                    end
                    else
                    begin
                        Result := 0.0067824323329992;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_28(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[226] <= -593.49999999999989 then
        begin
            Result := -0.025438544355223774;
        end
        else
        begin
            if features[226] <= 639.50000000000011 then
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    Result := -0.016085413325721547;
                end
                else
                begin
                    Result := -0.00022326342679948342;
                end;
            end
            else
            begin
                Result := 0.01296186503759097;
            end;
        end;
    end
    else
    begin
        if features[229] <= -24.499999999999996 then
        begin
            if features[229] <= -560.49999999999989 then
            begin
                Result := -0.014329374002341719;
            end
            else
            begin
                if features[166] <= -33218063.999999996 then
                begin
                    Result := -0.00418919602147182;
                end
                else
                begin
                    if features[148] <= 2957.0000000000005 then
                    begin
                        Result := 0.010211882621818975;
                    end
                    else
                    begin
                        Result := -0.01855887471837972;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 971.50000000000011 then
            begin
                if features[106] <= -1.4999999999999998 then
                begin
                    if features[166] <= 3018755.0000000005 then
                    begin
                        Result := 0.015483029276444791;
                    end
                    else
                    begin
                        Result := 0.032474947743993475;
                    end;
                end
                else
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := 0.0049735869042784337;
                    end
                    else
                    begin
                        Result := 0.020977106135411192;
                    end;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.032376061091917728;
                end
                else
                begin
                    if features[73] <= 334.50000000000006 then
                    begin
                        Result := 0.0096565438250567175;
                    end
                    else
                    begin
                        Result := 0.046798921575021538;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_29(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -24.499999999999996 then
    begin
        if features[229] <= -560.49999999999989 then
        begin
            Result := -0.021563230623913448;
        end
        else
        begin
            if features[164] <= -138402751.99999997 then
            begin
                Result := -0.014011964137918926;
            end
            else
            begin
                if features[175] <= -262.49999999999994 then
                begin
                    if features[186] <= 69.583332061767592 then
                    begin
                        Result := -0.0096380563712209419;
                    end
                    else
                    begin
                        Result := 0.014516197448844179;
                    end;
                end
                else
                begin
                    if features[48] <= 13362.500000000002 then
                    begin
                        Result := 0.0039084151247433425;
                    end
                    else
                    begin
                        Result := 0.037721476956603696;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[15] <= -223976111.99999997 then
        begin
            Result := -0.015529116553824749;
        end
        else
        begin
            if features[226] <= 495.50000000000006 then
            begin
                if features[73] <= 130.50000000000003 then
                begin
                    if features[178] <= 36.500000000000007 then
                    begin
                        Result := -0.0051295019962132055;
                    end
                    else
                    begin
                        Result := 0.0091518697203411305;
                    end;
                end
                else
                begin
                    if features[94] <= -44061.499999999993 then
                    begin
                        Result := -0.0037581625271086009;
                    end
                    else
                    begin
                        Result := 0.018320724002171468;
                    end;
                end;
            end
            else
            begin
                if features[106] <= 1.0000000180025095E-35 then
                begin
                    if features[222] <= -4547.4999999999991 then
                    begin
                        Result := 0.017231873467635061;
                    end
                    else
                    begin
                        Result := 0.034753038961486613;
                    end;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0055360194262335334;
                    end
                    else
                    begin
                        Result := 0.016926375918937499;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_30(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -136065383.99999997 then
    begin
        if features[223] <= -383.49999999999994 then
        begin
            Result := -0.022449893892322471;
        end
        else
        begin
            if features[223] <= 782.50000000000011 then
            begin
                if features[166] <= -265031895.99999997 then
                begin
                    Result := -0.021728478721303714;
                end
                else
                begin
                    Result := -0.006849032497246642;
                end;
            end
            else
            begin
                Result := 0.017254461818057901;
            end;
        end;
    end
    else
    begin
        if features[223] <= 201.50000000000003 then
        begin
            if features[216] <= -4017.4999999999995 then
            begin
                if features[166] <= -40553171.999999993 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0042698826416321554;
                    end
                    else
                    begin
                        Result := -0.011410700866756079;
                    end;
                end
                else
                begin
                    if features[215] <= -4102.4999999999991 then
                    begin
                        Result := 0.0083059356931522148;
                    end
                    else
                    begin
                        Result := -0.013221440928845786;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    Result := 0.048184284900267049;
                end
                else
                begin
                    Result := 0.0062497352199333174;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[174] <= -4481.4999999999991 then
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.014392686117454222;
                    end
                    else
                    begin
                        Result := -5.988713283751733E-05;
                    end;
                end
                else
                begin
                    Result := 0.026751243026340563;
                end;
            end
            else
            begin
                if features[228] <= -4386.4999999999991 then
                begin
                    Result := 0.014204985673515889;
                end
                else
                begin
                    Result := 0.03067950385290745;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_31(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[226] <= -593.49999999999989 then
        begin
            Result := -0.025078758952835359;
        end
        else
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                Result := 0.0037200223557922584;
            end
            else
            begin
                Result := -0.014491963183979481;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[216] <= -3981.9999999999995 then
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    if features[219] <= -7019.4999999999991 then
                    begin
                        Result := 0.034009015521866005;
                    end
                    else
                    begin
                        Result := 0.004415458800946858;
                    end;
                end
                else
                begin
                    if features[166] <= -41864945.999999993 then
                    begin
                        Result := -0.0096160333606411658;
                    end
                    else
                    begin
                        Result := 0.0023041202727759327;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    Result := 0.050453309215223244;
                end
                else
                begin
                    if features[226] <= -29.499999999999996 then
                    begin
                        Result := -0.0094785483925256993;
                    end
                    else
                    begin
                        Result := 0.020113849718690111;
                    end;
                end;
            end;
        end
        else
        begin
            if features[228] <= -4262.4999999999991 then
            begin
                if features[59] <= 1.0000000180025095E-35 then
                begin
                    if features[15] <= -137815887.99999997 then
                    begin
                        Result := -0.0049681566202267628;
                    end
                    else
                    begin
                        Result := 0.014799008182098051;
                    end;
                end
                else
                begin
                    Result := -0.0096561283527150047;
                end;
            end
            else
            begin
                if features[177] <= -7120.4999999999991 then
                begin
                    Result := 0.041944252485550663;
                end
                else
                begin
                    Result := 0.018679901454661512;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_32(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[229] <= -311.49999999999994 then
        begin
            Result := -0.023158186253726211;
        end
        else
        begin
            if features[166] <= -218413975.99999997 then
            begin
                Result := -0.016604700464248872;
            end
            else
            begin
                Result := -0.0026496026838790333;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[219] <= -7019.4999999999991 then
                begin
                    Result := 0.032251291306103567;
                end
                else
                begin
                    if features[229] <= -125.49999999999999 then
                    begin
                        Result := -0.0026095296468407639;
                    end
                    else
                    begin
                        Result := 0.013332527353593103;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -4462.4999999999991 then
                begin
                    if features[166] <= -39122973.999999993 then
                    begin
                        Result := -0.010283457507206438;
                    end
                    else
                    begin
                        Result := 8.6475700765227694E-05;
                    end;
                end
                else
                begin
                    if features[174] <= -4430.4999999999991 then
                    begin
                        Result := 0.040315690775844543;
                    end
                    else
                    begin
                        Result := 0.00094717733258979251;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[175] <= -226.49999999999997 then
                begin
                    Result := -0.0026048436557237764;
                end
                else
                begin
                    Result := 0.013765286698717821;
                end;
            end
            else
            begin
                if features[228] <= -4277.4999999999991 then
                begin
                    if features[65] <= 135.50000000000003 then
                    begin
                        Result := 0.016644616449146159;
                    end
                    else
                    begin
                        Result := -0.012007273240947689;
                    end;
                end
                else
                begin
                    Result := 0.029316215810427943;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_33(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -176.49999999999997 then
    begin
        if features[229] <= -640.49999999999989 then
        begin
            Result := -0.022505177945070721;
        end
        else
        begin
            if features[109] <= -63.499999999999993 then
            begin
                Result := -0.011122777498824907;
            end
            else
            begin
                if features[48] <= 13362.500000000002 then
                begin
                    if features[216] <= -3981.9999999999995 then
                    begin
                        Result := -0.0027777937503254222;
                    end
                    else
                    begin
                        Result := 0.032543303941733728;
                    end;
                end
                else
                begin
                    Result := 0.063834496730437437;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 495.50000000000006 then
        begin
            if features[175] <= -272.49999999999994 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    Result := -0.010802580581192031;
                end
                else
                begin
                    Result := 0.00040214328320119707;
                end;
            end
            else
            begin
                if features[129] <= 10443.500000000002 then
                begin
                    if features[164] <= -130641039.99999999 then
                    begin
                        Result := -0.0034065289255990998;
                    end
                    else
                    begin
                        Result := 0.0096201347339527812;
                    end;
                end
                else
                begin
                    Result := 0.028044563444410493;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[25] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.03006890412176046;
                end
                else
                begin
                    Result := 0.00047774107021124183;
                end;
            end
            else
            begin
                if features[222] <= -4274.4999999999991 then
                begin
                    if features[150] <= -9.4999999999999982 then
                    begin
                        Result := 0.037273712367613392;
                    end
                    else
                    begin
                        Result := 0.01282359590549524;
                    end;
                end
                else
                begin
                    Result := 0.032631166224282512;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_34(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -136065383.99999997 then
    begin
        if features[226] <= -593.49999999999989 then
        begin
            Result := -0.024281224656073058;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                Result := -0.012922559100117251;
            end
            else
            begin
                if features[47] <= 14269.500000000002 then
                begin
                    Result := 0.0016223970182218659;
                end
                else
                begin
                    Result := 0.056880758208441434;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[216] <= -4017.4999999999995 then
            begin
                if features[223] <= -564.49999999999989 then
                begin
                    if features[216] <= -7304.4999999999991 then
                    begin
                        Result := 0.025963454385114711;
                    end
                    else
                    begin
                        Result := -0.014641895456327911;
                    end;
                end
                else
                begin
                    if features[150] <= -7.4999999999999991 then
                    begin
                        Result := 0.016196642076060645;
                    end
                    else
                    begin
                        Result := -0.00045013531465899699;
                    end;
                end;
            end
            else
            begin
                if features[172] <= 1.5000000000000002 then
                begin
                    if features[217] <= 613.50000000000011 then
                    begin
                        Result := 0.048413244039241653;
                    end
                    else
                    begin
                        Result := -0.0044622040961191716;
                    end;
                end
                else
                begin
                    Result := 0.0023314684548192198;
                end;
            end;
        end
        else
        begin
            if features[55] <= 3.5000000000000004 then
            begin
                if features[65] <= 64.000000000000014 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0078892609987221158;
                    end
                    else
                    begin
                        Result := 0.021335123786550083;
                    end;
                end
                else
                begin
                    Result := -0.0054332303369825615;
                end;
            end
            else
            begin
                Result := 0.0029626145960194514;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_35(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[229] <= -486.49999999999994 then
        begin
            Result := -0.02437917577733973;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[83] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.016043019770686298;
                end
                else
                begin
                    if features[175] <= -349.49999999999994 then
                    begin
                        Result := -0.012946384006372984;
                    end
                    else
                    begin
                        Result := 0.015716228175075755;
                    end;
                end;
            end
            else
            begin
                if features[47] <= 19854.500000000004 then
                begin
                    Result := 0.001055352380547201;
                end
                else
                begin
                    Result := 0.061472823880002275;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= -134.49999999999997 then
        begin
            if features[46] <= 7.5000000000000009 then
            begin
                Result := 0.0043096724409528147;
            end
            else
            begin
                Result := -0.0080468819868540226;
            end;
        end
        else
        begin
            if features[166] <= -41864945.999999993 then
            begin
                if features[71] <= 1.5000000000000002 then
                begin
                    if features[178] <= 528.50000000000011 then
                    begin
                        Result := -0.013251935626331432;
                    end
                    else
                    begin
                        Result := 0.01645701436840968;
                    end;
                end
                else
                begin
                    if features[174] <= -5118.4999999999991 then
                    begin
                        Result := 0.0029830053257236915;
                    end
                    else
                    begin
                        Result := 0.018775876514198306;
                    end;
                end;
            end
            else
            begin
                if features[15] <= -137815887.99999997 then
                begin
                    Result := -0.0050593295984321454;
                end
                else
                begin
                    if features[8] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.024563042547768692;
                    end
                    else
                    begin
                        Result := 0.011904254076466413;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_36(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -136065383.99999997 then
    begin
        if features[220] <= 69.500000000000014 then
        begin
            if features[166] <= -226073471.99999997 then
            begin
                Result := -0.023231664646857469;
            end
            else
            begin
                Result := -0.012705127524308503;
            end;
        end
        else
        begin
            if features[37] <= 2.5000000000000004 then
            begin
                Result := 0.041166699935445111;
            end
            else
            begin
                Result := -0.00428002546570087;
            end;
        end;
    end
    else
    begin
        if features[223] <= -114.49999999999999 then
        begin
            if features[223] <= -730.49999999999989 then
            begin
                if features[224] <= -5772.4999999999991 then
                begin
                    Result := 0.017675266873908659;
                end
                else
                begin
                    Result := -0.016360331880840948;
                end;
            end
            else
            begin
                if features[129] <= 10320.500000000002 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.003473596637762191;
                    end
                    else
                    begin
                        Result := 0.013947088933010006;
                    end;
                end
                else
                begin
                    if features[94] <= 121353.00000000001 then
                    begin
                        Result := 0.024890854492993254;
                    end
                    else
                    begin
                        Result := -0.010332262274640963;
                    end;
                end;
            end;
        end
        else
        begin
            if features[15] <= -223976111.99999997 then
            begin
                Result := -0.019355115869808984;
            end
            else
            begin
                if features[71] <= 3.5000000000000004 then
                begin
                    if features[150] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.016569412426387934;
                    end
                    else
                    begin
                        Result := 0.0043107547880387375;
                    end;
                end
                else
                begin
                    if features[222] <= -5207.4999999999991 then
                    begin
                        Result := 0.0093310643732905894;
                    end
                    else
                    begin
                        Result := 0.023268909839656286;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_37(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -136065383.99999997 then
    begin
        if features[229] <= -486.49999999999994 then
        begin
            Result := -0.023779276574139089;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[77] <= 5937.5000000000009 then
                begin
                    Result := -0.0063051748280091901;
                end
                else
                begin
                    Result := -0.018446313714401343;
                end;
            end
            else
            begin
                if features[47] <= 14269.500000000002 then
                begin
                    Result := -0.00073889645223826784;
                end
                else
                begin
                    Result := 0.045335201507665158;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -12.499999999999998 then
        begin
            if features[226] <= -850.49999999999989 then
            begin
                if features[216] <= -7461.4999999999991 then
                begin
                    Result := 0.022963639006167314;
                end
                else
                begin
                    Result := -0.020372106384793087;
                end;
            end
            else
            begin
                if features[48] <= 12504.000000000002 then
                begin
                    if features[154] <= -446.49999999999994 then
                    begin
                        Result := 0.017270425342836716;
                    end
                    else
                    begin
                        Result := -0.0019972629734888491;
                    end;
                end
                else
                begin
                    Result := 0.018796506755828793;
                end;
            end;
        end
        else
        begin
            if features[15] <= -223976111.99999997 then
            begin
                Result := -0.015782895383832235;
            end
            else
            begin
                if features[73] <= 130.50000000000003 then
                begin
                    if features[178] <= 375.50000000000006 then
                    begin
                        Result := 0.0010579869678458175;
                    end
                    else
                    begin
                        Result := 0.013047858065197218;
                    end;
                end
                else
                begin
                    if features[225] <= -4959.4999999999991 then
                    begin
                        Result := 0.012023581277778186;
                    end
                    else
                    begin
                        Result := 0.02525947181783025;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_38(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -134.49999999999997 then
    begin
        if features[229] <= -692.49999999999989 then
        begin
            Result := -0.022516710086225012;
        end
        else
        begin
            if features[164] <= -228861023.99999997 then
            begin
                Result := -0.01799024206104664;
            end
            else
            begin
                if features[186] <= 74.416667938232436 then
                begin
                    if features[48] <= 19947.000000000004 then
                    begin
                        Result := -0.0073205097071303502;
                    end
                    else
                    begin
                        Result := 0.018207465997309821;
                    end;
                end
                else
                begin
                    if features[105] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.040010879738512181;
                    end
                    else
                    begin
                        Result := 0.0033151944563075478;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[175] <= -272.49999999999994 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                Result := -0.010759449737681309;
            end
            else
            begin
                if features[1] <= 112751.50000000001 then
                begin
                    if features[226] <= 599.50000000000011 then
                    begin
                        Result := -0.0031856948497719674;
                    end
                    else
                    begin
                        Result := 0.016098923010512096;
                    end;
                end
                else
                begin
                    Result := 0.022876097842301414;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4389.4999999999991 then
            begin
                if features[66] <= 108.50000000000001 then
                begin
                    if features[55] <= 3.5000000000000004 then
                    begin
                        Result := 0.011068098969671213;
                    end
                    else
                    begin
                        Result := 7.2520562540896234E-05;
                    end;
                end
                else
                begin
                    Result := -0.016005810549814946;
                end;
            end
            else
            begin
                if features[122] <= -47.499999999999993 then
                begin
                    Result := -0.0059873413632620378;
                end
                else
                begin
                    Result := 0.022677382336298482;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_39(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -144645415.99999997 then
    begin
        if features[229] <= -486.49999999999994 then
        begin
            Result := -0.023828630304461265;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[228] <= -3520.4999999999995 then
                begin
                    Result := -0.013831461474933988;
                end
                else
                begin
                    if features[173] <= -5020.4999999999991 then
                    begin
                        Result := 0.067727122437653373;
                    end
                    else
                    begin
                        Result := -0.017082908218207116;
                    end;
                end;
            end
            else
            begin
                Result := 0.0045903188858754124;
            end;
        end;
    end
    else
    begin
        if features[229] <= -176.49999999999997 then
        begin
            if features[216] <= -7304.4999999999991 then
            begin
                if features[164] <= 190037544.00000003 then
                begin
                    Result := 0.013094796874366307;
                end
                else
                begin
                    Result := 0.081117003932087206;
                end;
            end
            else
            begin
                if features[226] <= -863.49999999999989 then
                begin
                    Result := -0.020946972371660724;
                end
                else
                begin
                    if features[77] <= 6690.5000000000009 then
                    begin
                        Result := 0.0013739919720643903;
                    end
                    else
                    begin
                        Result := -0.011811540193443167;
                    end;
                end;
            end;
        end
        else
        begin
            if features[15] <= -228169327.99999997 then
            begin
                Result := -0.018770117348060625;
            end
            else
            begin
                if features[222] <= -5368.4999999999991 then
                begin
                    if features[166] <= -4344754.4999999991 then
                    begin
                        Result := 0.00022716529952179201;
                    end
                    else
                    begin
                        Result := 0.01162158081950284;
                    end;
                end
                else
                begin
                    if features[73] <= 150.50000000000003 then
                    begin
                        Result := 0.0087869774743480622;
                    end
                    else
                    begin
                        Result := 0.021680375920519662;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_40(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -157.49999999999997 then
    begin
        if features[229] <= -640.49999999999989 then
        begin
            Result := -0.021521830545606302;
        end
        else
        begin
            if features[108] <= -284.49999999999994 then
            begin
                if features[48] <= 19947.000000000004 then
                begin
                    Result := -0.013461308266148109;
                end
                else
                begin
                    Result := 0.019158165653902007;
                end;
            end
            else
            begin
                if features[174] <= -4572.4999999999991 then
                begin
                    Result := -0.0035969354342457599;
                end
                else
                begin
                    if features[216] <= -4017.4999999999995 then
                    begin
                        Result := 0.0026559909780205764;
                    end
                    else
                    begin
                        Result := 0.041018937456283301;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 758.50000000000011 then
        begin
            if features[15] <= -179339415.99999997 then
            begin
                Result := -0.013653920961644778;
            end
            else
            begin
                if features[71] <= 1.5000000000000002 then
                begin
                    if features[158] <= -7899.9999999999991 then
                    begin
                        Result := 0.015680269800272987;
                    end
                    else
                    begin
                        Result := -0.0085628877327606212;
                    end;
                end
                else
                begin
                    if features[24] <= 2.5000000000000004 then
                    begin
                        Result := -0.0087261995090124663;
                    end
                    else
                    begin
                        Result := 0.010296309885129178;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -5385.4999999999991 then
            begin
                Result := 0.0076666385463314782;
            end
            else
            begin
                if features[172] <= 3.5000000000000004 then
                begin
                    Result := 0.030683575039977175;
                end
                else
                begin
                    if features[40] <= 1318.5000000000002 then
                    begin
                        Result := 0.02083854674762672;
                    end
                    else
                    begin
                        Result := -0.0054875281532670919;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_41(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[226] <= -593.49999999999989 then
        begin
            Result := -0.023816730642563663;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                Result := -0.013453728861053268;
            end
            else
            begin
                if features[0] <= 178431.50000000003 then
                begin
                    Result := -0.00053518187759251388;
                end
                else
                begin
                    Result := 0.054775974955614148;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -38.499999999999993 then
        begin
            if features[166] <= -33218063.999999996 then
            begin
                Result := -0.0067471228506554848;
            end
            else
            begin
                if features[227] <= -4849.4999999999991 then
                begin
                    if features[164] <= 267596096.00000003 then
                    begin
                        Result := 0.0083390260927361463;
                    end
                    else
                    begin
                        Result := 0.046644607140521599;
                    end;
                end
                else
                begin
                    if features[165] <= 151086448.00000003 then
                    begin
                        Result := -0.013446877365545963;
                    end
                    else
                    begin
                        Result := 0.0063505893526606535;
                    end;
                end;
            end;
        end
        else
        begin
            if features[106] <= -1.4999999999999998 then
            begin
                if features[92] <= -1.4999999999999998 then
                begin
                    Result := -0.0033857731580302906;
                end
                else
                begin
                    Result := 0.020863697723066024;
                end;
            end
            else
            begin
                if features[226] <= 1103.5000000000002 then
                begin
                    if features[36] <= 721.50000000000011 then
                    begin
                        Result := 0.0063336977517544444;
                    end
                    else
                    begin
                        Result := -0.0073321810855577693;
                    end;
                end
                else
                begin
                    if features[158] <= 3937.5000000000005 then
                    begin
                        Result := 0.026244909803198341;
                    end
                    else
                    begin
                        Result := 0.0063034653306113216;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_42(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[229] <= -431.49999999999994 then
        begin
            Result := -0.023289100253100471;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                Result := -0.011878792409108965;
            end
            else
            begin
                Result := 0.0049077257063777132;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[216] <= -4054.4999999999995 then
            begin
                if features[229] <= -486.49999999999994 then
                begin
                    if features[224] <= -5989.4999999999991 then
                    begin
                        Result := 0.016335418367437751;
                    end
                    else
                    begin
                        Result := -0.015730271425170913;
                    end;
                end
                else
                begin
                    if features[71] <= 1.5000000000000002 then
                    begin
                        Result := -0.0094384809175315863;
                    end
                    else
                    begin
                        Result := 0.0034171750130334794;
                    end;
                end;
            end
            else
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[173] <= -5127.4999999999991 then
                    begin
                        Result := -0.0036238445285141233;
                    end
                    else
                    begin
                        Result := 0.040226113066132912;
                    end;
                end
                else
                begin
                    Result := 0.0020702969258503939;
                end;
            end;
        end
        else
        begin
            if features[55] <= 3.5000000000000004 then
            begin
                if features[59] <= 1.0000000180025095E-35 then
                begin
                    if features[226] <= 783.50000000000011 then
                    begin
                        Result := 0.011588840055385085;
                    end
                    else
                    begin
                        Result := 0.022103246499369213;
                    end;
                end
                else
                begin
                    Result := -0.006294213873564285;
                end;
            end
            else
            begin
                if features[150] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.01428554584273297;
                end
                else
                begin
                    Result := -0.0042733908761060013;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_43(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[229] <= -318.49999999999994 then
        begin
            Result := -0.021951531487628781;
        end
        else
        begin
            if features[48] <= 4045.5000000000005 then
            begin
                Result := -0.011327717326380419;
            end
            else
            begin
                if features[179] <= -5432.4999999999991 then
                begin
                    if features[225] <= -6078.4999999999991 then
                    begin
                        Result := -0.023302146719543643;
                    end
                    else
                    begin
                        Result := 0.029790031734100893;
                    end;
                end
                else
                begin
                    Result := -0.015845021623261891;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[219] <= -6925.4999999999991 then
                begin
                    if features[185] <= 69.366668701171889 then
                    begin
                        Result := 0.016861545699681332;
                    end
                    else
                    begin
                        Result := 0.065162811539154222;
                    end;
                end
                else
                begin
                    if features[223] <= -446.49999999999994 then
                    begin
                        Result := -0.008242574724933097;
                    end
                    else
                    begin
                        Result := 0.008586203120871631;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -4698.4999999999991 then
                begin
                    Result := -0.0052840999284335596;
                end
                else
                begin
                    if features[69] <= 3.5000000000000004 then
                    begin
                        Result := -0.0061404856650873274;
                    end
                    else
                    begin
                        Result := 0.017711985115991254;
                    end;
                end;
            end;
        end
        else
        begin
            if features[106] <= 1.5000000000000002 then
            begin
                if features[122] <= -1264.4999999999998 then
                begin
                    Result := -0.011865656917571655;
                end
                else
                begin
                    Result := 0.015038320346531851;
                end;
            end
            else
            begin
                Result := 0.0040682887922230855;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_44(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -184685991.99999997 then
    begin
        if features[229] <= -494.49999999999994 then
        begin
            Result := -0.023923739105716747;
        end
        else
        begin
            Result := -0.011766871294512253;
        end;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[216] <= -4389.4999999999991 then
            begin
                if features[178] <= 95.500000000000014 then
                begin
                    if features[2] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.011444380440265536;
                    end
                    else
                    begin
                        Result := 0.0004556119657696695;
                    end;
                end
                else
                begin
                    Result := 0.0041259112590192144;
                end;
            end
            else
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    if features[217] <= -136.49999999999997 then
                    begin
                        Result := -0.012090779071413482;
                    end
                    else
                    begin
                        Result := 0.011506485835059576;
                    end;
                end
                else
                begin
                    Result := 0.03156496464775646;
                end;
            end;
        end
        else
        begin
            if features[105] <= 2.5000000000000004 then
            begin
                if features[226] <= -87.499999999999986 then
                begin
                    if features[216] <= -7374.4999999999991 then
                    begin
                        Result := 0.035680697815147454;
                    end
                    else
                    begin
                        Result := 0.0016076257120683783;
                    end;
                end
                else
                begin
                    if features[15] <= -228169327.99999997 then
                    begin
                        Result := -0.015642200406652467;
                    end
                    else
                    begin
                        Result := 0.015280020337504897;
                    end;
                end;
            end
            else
            begin
                if features[220] <= 346.50000000000006 then
                begin
                    Result := -0.010432969330025072;
                end
                else
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.018226957870634171;
                    end
                    else
                    begin
                        Result := -0.0013298174276159831;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_45(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -184685991.99999997 then
    begin
        if features[220] <= 43.500000000000007 then
        begin
            if features[161] <= -3383.4999999999995 then
            begin
                Result := 0.040468669466400119;
            end
            else
            begin
                Result := -0.020903923829739237;
            end;
        end
        else
        begin
            if features[216] <= -4173.4999999999991 then
            begin
                Result := -0.010743236976127432;
            end
            else
            begin
                Result := 0.021823541766246776;
            end;
        end;
    end
    else
    begin
        if features[223] <= 358.50000000000006 then
        begin
            if features[166] <= -31767867.999999996 then
            begin
                if features[216] <= -4044.4999999999995 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.00206242231063546;
                    end
                    else
                    begin
                        Result := -0.0091085758585409456;
                    end;
                end
                else
                begin
                    if features[216] <= -3939.4999999999995 then
                    begin
                        Result := 0.039810719904049247;
                    end
                    else
                    begin
                        Result := -0.0016975246825710628;
                    end;
                end;
            end
            else
            begin
                if features[106] <= -1.4999999999999998 then
                begin
                    Result := 0.015506005597879497;
                end
                else
                begin
                    if features[148] <= 2779.5000000000005 then
                    begin
                        Result := 0.0046191655314043231;
                    end
                    else
                    begin
                        Result := -0.016338080264578083;
                    end;
                end;
            end;
        end
        else
        begin
            if features[150] <= -9.4999999999999982 then
            begin
                Result := 0.024996913888569616;
            end
            else
            begin
                if features[228] <= -4248.4999999999991 then
                begin
                    if features[59] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0072654880145824087;
                    end
                    else
                    begin
                        Result := -0.017876162336256531;
                    end;
                end
                else
                begin
                    Result := 0.017139026197363332;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_46(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -486.49999999999994 then
    begin
        if features[216] <= -7374.4999999999991 then
        begin
            if features[13] <= 106714.00000000001 then
            begin
                Result := -0.0045813154462478215;
            end
            else
            begin
                Result := 0.082999327586779192;
            end;
        end
        else
        begin
            Result := -0.019345133376647245;
        end;
    end
    else
    begin
        if features[175] <= -262.49999999999994 then
        begin
            if features[226] <= 413.50000000000006 then
            begin
                if features[179] <= -5336.4999999999991 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0028968443207885632;
                    end
                    else
                    begin
                        Result := -0.0077878775196677675;
                    end;
                end
                else
                begin
                    Result := -0.01712060287525265;
                end;
            end
            else
            begin
                if features[53] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.021362394459236128;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.015240345083804868;
                    end
                    else
                    begin
                        Result := 0.0082527273748394768;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4373.4999999999991 then
            begin
                if features[129] <= 10443.500000000002 then
                begin
                    if features[223] <= 125.50000000000001 then
                    begin
                        Result := -0.0026016673134280966;
                    end
                    else
                    begin
                        Result := 0.0073660276010861867;
                    end;
                end
                else
                begin
                    Result := 0.022251378784162269;
                end;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[222] <= -5185.4999999999991 then
                    begin
                        Result := 0.0088747801442242962;
                    end
                    else
                    begin
                        Result := 0.032207913506493095;
                    end;
                end
                else
                begin
                    Result := 0.0080898902016875822;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_47(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -144645415.99999997 then
    begin
        if features[229] <= -486.49999999999994 then
        begin
            Result := -0.023290504457087552;
        end
        else
        begin
            if features[166] <= -294566319.99999994 then
            begin
                Result := -0.021069707566731828;
            end
            else
            begin
                if features[222] <= -5869.4999999999991 then
                begin
                    Result := -0.015346713314671082;
                end
                else
                begin
                    if features[172] <= 4.5000000000000009 then
                    begin
                        Result := 0.004368145473492506;
                    end
                    else
                    begin
                        Result := -0.01328272244751786;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= -138.49999999999997 then
        begin
            if features[37] <= 5.5000000000000009 then
            begin
                if features[216] <= -7304.4999999999991 then
                begin
                    Result := 0.025995914886640627;
                end
                else
                begin
                    if features[216] <= -4017.4999999999995 then
                    begin
                        Result := -0.0034306963761499922;
                    end
                    else
                    begin
                        Result := 0.019750304799491272;
                    end;
                end;
            end
            else
            begin
                Result := -0.012623202045461579;
            end;
        end
        else
        begin
            if features[216] <= -4389.4999999999991 then
            begin
                if features[2] <= 1.0000000180025095E-35 then
                begin
                    if features[36] <= 697.50000000000011 then
                    begin
                        Result := 0.0052275470378991065;
                    end
                    else
                    begin
                        Result := -0.0083210200654136989;
                    end;
                end
                else
                begin
                    if features[222] <= -4896.4999999999991 then
                    begin
                        Result := 0.0069191777648378756;
                    end
                    else
                    begin
                        Result := 0.02948685823536536;
                    end;
                end;
            end
            else
            begin
                if features[122] <= -1327.9999999999998 then
                begin
                    Result := -0.017079691210277647;
                end
                else
                begin
                    Result := 0.015945833175054974;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_48(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -184685991.99999997 then
    begin
        if features[229] <= -494.49999999999994 then
        begin
            Result := -0.024032737906682859;
        end
        else
        begin
            Result := -0.011700397303619103;
        end;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[216] <= -4044.4999999999995 then
            begin
                if features[2] <= 1.0000000180025095E-35 then
                begin
                    if features[185] <= 150.12500000000003 then
                    begin
                        Result := -0.0096013987062557489;
                    end
                    else
                    begin
                        Result := 0.0069107782838318532;
                    end;
                end
                else
                begin
                    if features[223] <= -520.49999999999989 then
                    begin
                        Result := -0.012705636165962542;
                    end
                    else
                    begin
                        Result := 0.010122954433046113;
                    end;
                end;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[217] <= 258.50000000000006 then
                    begin
                        Result := 0.045932064527376852;
                    end
                    else
                    begin
                        Result := 0.010339935973728339;
                    end;
                end
                else
                begin
                    Result := -0.0068353774470597557;
                end;
            end;
        end
        else
        begin
            if features[217] <= -121.49999999999999 then
            begin
                if features[170] <= 1.5000000000000002 then
                begin
                    Result := -0.0073517340270955744;
                end
                else
                begin
                    if features[227] <= -4849.4999999999991 then
                    begin
                        Result := 0.013000922414013015;
                    end
                    else
                    begin
                        Result := -0.0013352752148108411;
                    end;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    if features[229] <= 894.50000000000011 then
                    begin
                        Result := 0.012426913285380179;
                    end
                    else
                    begin
                        Result := 0.025362086946074964;
                    end;
                end
                else
                begin
                    Result := 0.0052290710675323817;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_49(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -218413975.99999997 then
    begin
        Result := -0.019480901830579104;
    end
    else
    begin
        if features[226] <= -347.49999999999994 then
        begin
            if features[219] <= -6925.4999999999991 then
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    if features[95] <= 81541132.000000015 then
                    begin
                        Result := 0.013428615874810451;
                    end
                    else
                    begin
                        Result := 0.069774265510911274;
                    end;
                end
                else
                begin
                    Result := -0.0077296218732946665;
                end;
            end
            else
            begin
                if features[216] <= -3981.9999999999995 then
                begin
                    Result := -0.012055080222807798;
                end
                else
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.066568634512607291;
                    end
                    else
                    begin
                        Result := -0.01948692843372098;
                    end;
                end;
            end;
        end
        else
        begin
            if features[175] <= -238.49999999999997 then
            begin
                if features[53] <= 1.0000000180025095E-35 then
                begin
                    if features[229] <= 569.50000000000011 then
                    begin
                        Result := 0.0034139330666152915;
                    end
                    else
                    begin
                        Result := 0.028906779941807566;
                    end;
                end
                else
                begin
                    if features[9] <= 3.5000000000000004 then
                    begin
                        Result := -0.0075541780413771386;
                    end
                    else
                    begin
                        Result := 0.0073200349095141719;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -4389.4999999999991 then
                begin
                    if features[66] <= 108.50000000000001 then
                    begin
                        Result := 0.0070045022547641075;
                    end
                    else
                    begin
                        Result := -0.018238280839045846;
                    end;
                end
                else
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.0251862343951068;
                    end
                    else
                    begin
                        Result := 0.010452411685312789;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_50(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -509.49999999999994 then
    begin
        if features[216] <= -7374.4999999999991 then
        begin
            if features[13] <= 121177.00000000001 then
            begin
                Result := -0.0045409134468432704;
            end
            else
            begin
                Result := 0.085783525100326358;
            end;
        end
        else
        begin
            Result := -0.020033281090996377;
        end;
    end
    else
    begin
        if features[175] <= -440.49999999999994 then
        begin
            if features[226] <= 783.50000000000011 then
            begin
                if features[15] <= -174353919.99999997 then
                begin
                    Result := -0.019998376946713841;
                end
                else
                begin
                    if features[185] <= 13.125000000000002 then
                    begin
                        Result := -0.006713074196792965;
                    end
                    else
                    begin
                        Result := 0.0059259096327318513;
                    end;
                end;
            end
            else
            begin
                if features[106] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.021868149344295963;
                end
                else
                begin
                    Result := -0.0048742969221936064;
                end;
            end;
        end
        else
        begin
            if features[164] <= 50109822.000000007 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    if features[135] <= 1.5000000000000002 then
                    begin
                        Result := 0.0036894464648050021;
                    end
                    else
                    begin
                        Result := 0.019844857248652259;
                    end;
                end
                else
                begin
                    if features[185] <= 181.12500000000003 then
                    begin
                        Result := -0.01239538235010022;
                    end
                    else
                    begin
                        Result := 0.0053799355257382712;
                    end;
                end;
            end
            else
            begin
                if features[27] <= -2748.4999999999995 then
                begin
                    if features[28] <= -5493.4999999999991 then
                    begin
                        Result := 0.01694934318358178;
                    end
                    else
                    begin
                        Result := 0.0064255589532132788;
                    end;
                end
                else
                begin
                    Result := 0.034471068165079;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_51(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -486.49999999999994 then
    begin
        if features[186] <= 112.16666793823244 then
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                Result := -0.01482960234066278;
            end
            else
            begin
                Result := -0.024988394037903938;
            end;
        end
        else
        begin
            if features[225] <= -6715.4999999999991 then
            begin
                Result := 0.06155321648160892;
            end
            else
            begin
                Result := -0.0038815047037937173;
            end;
        end;
    end
    else
    begin
        if features[175] <= -262.49999999999994 then
        begin
            if features[15] <= -186560687.99999997 then
            begin
                Result := -0.018657644856940096;
            end
            else
            begin
                if features[71] <= 1.5000000000000002 then
                begin
                    Result := -0.010989801020103156;
                end
                else
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.0060652275338679527;
                    end
                    else
                    begin
                        Result := -0.005388581774874294;
                    end;
                end;
            end;
        end
        else
        begin
            if features[164] <= -158902135.99999997 then
            begin
                if features[226] <= 481.50000000000006 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0013765069869331843;
                    end
                    else
                    begin
                        Result := -0.018304172730685676;
                    end;
                end
                else
                begin
                    Result := 0.0089493583514353367;
                end;
            end
            else
            begin
                if features[129] <= 10029.000000000002 then
                begin
                    if features[226] <= 971.50000000000011 then
                    begin
                        Result := 0.0063038612469220592;
                    end
                    else
                    begin
                        Result := 0.016653138854110211;
                    end;
                end
                else
                begin
                    if features[94] <= 115779.50000000001 then
                    begin
                        Result := 0.02880353153050106;
                    end
                    else
                    begin
                        Result := 0.010590471231198891;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_52(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -184685991.99999997 then
    begin
        if features[166] <= -265031895.99999997 then
        begin
            Result := -0.022267322714124026;
        end
        else
        begin
            Result := -0.010116889786917892;
        end;
    end
    else
    begin
        if features[226] <= 495.50000000000006 then
        begin
            if features[166] <= -28946161.999999996 then
            begin
                if features[216] <= -4079.4999999999995 then
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0073500533586724585;
                    end
                    else
                    begin
                        Result := 0.0063204649805683692;
                    end;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.029447962979991735;
                    end
                    else
                    begin
                        Result := -0.0008472008348834768;
                    end;
                end;
            end
            else
            begin
                if features[105] <= 1.5000000000000002 then
                begin
                    if features[96] <= 170859808.00000003 then
                    begin
                        Result := 0.0088028279074432569;
                    end
                    else
                    begin
                        Result := -0.013440326077911641;
                    end;
                end
                else
                begin
                    if features[128] <= -18.499999999999996 then
                    begin
                        Result := -0.010235097219570836;
                    end
                    else
                    begin
                        Result := 0.011253919100947326;
                    end;
                end;
            end;
        end
        else
        begin
            if features[106] <= 1.0000000180025095E-35 then
            begin
                if features[222] <= -4547.4999999999991 then
                begin
                    Result := 0.011583361636535287;
                end
                else
                begin
                    if features[176] <= -5920.4999999999991 then
                    begin
                        Result := 0.031190323363470142;
                    end
                    else
                    begin
                        Result := 0.0076071485129379449;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0091177266721118675;
                end
                else
                begin
                    Result := 0.0088716282279526649;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_53(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[223] <= 858.50000000000011 then
        begin
            Result := -0.020176606645186577;
        end
        else
        begin
            if features[180] <= -7137.4999999999991 then
            begin
                Result := 0.048331926376368184;
            end
            else
            begin
                Result := -0.024825738692355749;
            end;
        end;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[175] <= -440.49999999999994 then
                begin
                    Result := -0.011171547319511432;
                end
                else
                begin
                    if features[77] <= 5646.0000000000009 then
                    begin
                        Result := 0.003943024530582667;
                    end
                    else
                    begin
                        Result := -0.008646801990162923;
                    end;
                end;
            end
            else
            begin
                if features[222] <= -4855.4999999999991 then
                begin
                    if features[0] <= 104793.00000000001 then
                    begin
                        Result := 0.00019511041622400391;
                    end
                    else
                    begin
                        Result := 0.029163460792962545;
                    end;
                end
                else
                begin
                    if features[229] <= -382.49999999999994 then
                    begin
                        Result := -0.018878628536431945;
                    end
                    else
                    begin
                        Result := 0.028590718632574948;
                    end;
                end;
            end;
        end
        else
        begin
            if features[150] <= -1.0000000180025095E-35 then
            begin
                if features[227] <= -3839.4999999999995 then
                begin
                    Result := 0.014305044631026885;
                end
                else
                begin
                    Result := -0.018026638612800409;
                end;
            end
            else
            begin
                if features[225] <= -3583.9999999999995 then
                begin
                    if features[121] <= 223.50000000000003 then
                    begin
                        Result := 0.0053230472561930807;
                    end
                    else
                    begin
                        Result := -0.0070137782016886198;
                    end;
                end
                else
                begin
                    Result := 0.022785210559700612;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_54(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[166] <= -298130495.99999994 then
        begin
            Result := -0.023206654852341052;
        end
        else
        begin
            if features[1] <= 179079.50000000003 then
            begin
                Result := -0.014206588911326944;
            end
            else
            begin
                Result := 0.039269119224812271;
            end;
        end;
    end
    else
    begin
        if features[166] <= -44508701.999999993 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[226] <= 350.50000000000006 then
                begin
                    if features[77] <= 5937.5000000000009 then
                    begin
                        Result := -0.0033119806039551901;
                    end
                    else
                    begin
                        Result := -0.013486274197511902;
                    end;
                end
                else
                begin
                    if features[215] <= -6249.4999999999991 then
                    begin
                        Result := -0.0087149227245245913;
                    end
                    else
                    begin
                        Result := 0.012293807133850247;
                    end;
                end;
            end
            else
            begin
                if features[47] <= 5921.5000000000009 then
                begin
                    if features[222] <= -4933.4999999999991 then
                    begin
                        Result := -0.0012697187368109378;
                    end
                    else
                    begin
                        Result := 0.017537539593767661;
                    end;
                end
                else
                begin
                    Result := 0.029063706137041817;
                end;
            end;
        end
        else
        begin
            if features[105] <= 2.5000000000000004 then
            begin
                if features[15] <= -228169327.99999997 then
                begin
                    Result := -0.01740883033240986;
                end
                else
                begin
                    if features[96] <= 170859808.00000003 then
                    begin
                        Result := 0.011164776177823086;
                    end
                    else
                    begin
                        Result := -0.0094562168516457018;
                    end;
                end;
            end
            else
            begin
                if features[218] <= -5806.4999999999991 then
                begin
                    Result := 0.0059154453753088769;
                end
                else
                begin
                    Result := -0.0098253898973735074;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_55(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -197215583.99999997 then
    begin
        if features[166] <= -298130495.99999994 then
        begin
            Result := -0.023301389499190625;
        end
        else
        begin
            Result := -0.01199626151349612;
        end;
    end
    else
    begin
        if features[229] <= -9.4999999999999982 then
        begin
            if features[229] <= -692.49999999999989 then
            begin
                Result := -0.014705269097238833;
            end
            else
            begin
                if features[48] <= 12504.000000000002 then
                begin
                    if features[166] <= -44508701.999999993 then
                    begin
                        Result := -0.0060656641352003424;
                    end
                    else
                    begin
                        Result := 0.0020794874324899077;
                    end;
                end
                else
                begin
                    if features[54] <= 2.5000000000000004 then
                    begin
                        Result := -0.0096766555281805403;
                    end
                    else
                    begin
                        Result := 0.024732239659000524;
                    end;
                end;
            end;
        end
        else
        begin
            if features[175] <= 214.50000000000003 then
            begin
                if features[166] <= -41864945.999999993 then
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.02106631801221821;
                    end
                    else
                    begin
                        Result := 0.00012602855345046331;
                    end;
                end
                else
                begin
                    if features[66] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0072226368287339367;
                    end
                    else
                    begin
                        Result := -0.024803757816868208;
                    end;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    if features[222] <= -4855.4999999999991 then
                    begin
                        Result := 0.0096602718206543862;
                    end
                    else
                    begin
                        Result := 0.021909833329141804;
                    end;
                end
                else
                begin
                    if features[157] <= -5.4999999999999991 then
                    begin
                        Result := 0.022155105607715199;
                    end
                    else
                    begin
                        Result := -0.00066254580921785305;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_56(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -149541167.99999997 then
    begin
        if features[229] <= -621.49999999999989 then
        begin
            Result := -0.023815852112048577;
        end
        else
        begin
            if features[166] <= -309517551.99999994 then
            begin
                Result := -0.022150450557807635;
            end
            else
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    if features[83] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.012512160023650977;
                    end
                    else
                    begin
                        Result := 0.0044371436779565591;
                    end;
                end
                else
                begin
                    if features[0] <= 169252.00000000003 then
                    begin
                        Result := 0.0040972179829023318;
                    end
                    else
                    begin
                        Result := 0.057958594430700963;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= 1.0000000180025095E-35 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[216] <= -4079.4999999999995 then
                begin
                    if features[178] <= 1471.5000000000002 then
                    begin
                        Result := -0.0046003210282663893;
                    end
                    else
                    begin
                        Result := 0.02614402999241032;
                    end;
                end
                else
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.019730411237575227;
                    end
                    else
                    begin
                        Result := -0.0095728584205772693;
                    end;
                end;
            end
            else
            begin
                Result := 0.011173740372559115;
            end;
        end
        else
        begin
            if features[106] <= -1.4999999999999998 then
            begin
                if features[92] <= -1.4999999999999998 then
                begin
                    Result := -0.0065454209735024919;
                end
                else
                begin
                    Result := 0.021196581723226214;
                end;
            end
            else
            begin
                if features[141] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.0072059561723975055;
                end
                else
                begin
                    Result := -0.012474862322690579;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_57(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -180490975.99999997 then
    begin
        if features[166] <= -298130495.99999994 then
        begin
            Result := -0.023608738492074122;
        end
        else
        begin
            Result := -0.0096953592477082347;
        end;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[216] <= -4079.4999999999995 then
            begin
                if features[226] <= 350.50000000000006 then
                begin
                    if features[48] <= 136.50000000000003 then
                    begin
                        Result := -0.0090492821384273846;
                    end
                    else
                    begin
                        Result := 0.002083960922925412;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.0059105935447863849;
                    end
                    else
                    begin
                        Result := 0.01458958483721912;
                    end;
                end;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[228] <= -4447.4999999999991 then
                    begin
                        Result := 0.010169912534317614;
                    end
                    else
                    begin
                        Result := 0.038003741557046528;
                    end;
                end
                else
                begin
                    Result := -0.0060622913131400478;
                end;
            end;
        end
        else
        begin
            if features[107] <= -1.0000000180025095E-35 then
            begin
                if features[218] <= -6003.4999999999991 then
                begin
                    if features[47] <= 4332.5000000000009 then
                    begin
                        Result := 0.01421310422768232;
                    end
                    else
                    begin
                        Result := -0.0048440437206946282;
                    end;
                end
                else
                begin
                    Result := -0.0060931508098948641;
                end;
            end
            else
            begin
                if features[172] <= 3.5000000000000004 then
                begin
                    if features[173] <= -6406.4999999999991 then
                    begin
                        Result := 0.018724671131638421;
                    end
                    else
                    begin
                        Result := 0.0088443843002977956;
                    end;
                end
                else
                begin
                    Result := 0.0046285849815777876;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_58(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -197215583.99999997 then
    begin
        if features[90] <= 7.5000000000000009 then
        begin
            if features[229] <= -134.49999999999997 then
            begin
                Result := -0.020943642147823183;
            end
            else
            begin
                Result := -0.0077804428245600637;
            end;
        end
        else
        begin
            Result := 0.033319603798321017;
        end;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[48] <= 11746.000000000002 then
                begin
                    if features[226] <= 350.50000000000006 then
                    begin
                        Result := -0.0083934856978228039;
                    end
                    else
                    begin
                        Result := 0.0037953890432425004;
                    end;
                end
                else
                begin
                    if features[175] <= -859.49999999999989 then
                    begin
                        Result := -0.0062778677509694155;
                    end
                    else
                    begin
                        Result := 0.01834035597288346;
                    end;
                end;
            end
            else
            begin
                if features[47] <= 5921.5000000000009 then
                begin
                    if features[216] <= -4574.4999999999991 then
                    begin
                        Result := -0.0016491010703049318;
                    end
                    else
                    begin
                        Result := 0.018401486890481097;
                    end;
                end
                else
                begin
                    Result := 0.029100141865725088;
                end;
            end;
        end
        else
        begin
            if features[15] <= -228169327.99999997 then
            begin
                Result := -0.017117872973005474;
            end
            else
            begin
                if features[105] <= 2.5000000000000004 then
                begin
                    if features[226] <= 1201.5000000000002 then
                    begin
                        Result := 0.0082281536116840925;
                    end
                    else
                    begin
                        Result := 0.022698027984010501;
                    end;
                end
                else
                begin
                    if features[217] <= 10.500000000000002 then
                    begin
                        Result := -0.0081287579263619025;
                    end
                    else
                    begin
                        Result := 0.0060527384567595939;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_59(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[223] <= 858.50000000000011 then
        begin
            Result := -0.019354566107916662;
        end
        else
        begin
            Result := 0.020407180605893385;
        end;
    end
    else
    begin
        if features[226] <= -12.499999999999998 then
        begin
            if features[229] <= -692.49999999999989 then
            begin
                Result := -0.015906008076327815;
            end
            else
            begin
                if features[175] <= -440.49999999999994 then
                begin
                    if features[219] <= -7061.4999999999991 then
                    begin
                        Result := 0.01048370371118326;
                    end
                    else
                    begin
                        Result := -0.0089500955679514393;
                    end;
                end
                else
                begin
                    if features[164] <= -112882087.99999999 then
                    begin
                        Result := -0.007718165769387832;
                    end
                    else
                    begin
                        Result := 0.0062469099303641661;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[175] <= 270.50000000000006 then
                begin
                    if features[166] <= 3018755.0000000005 then
                    begin
                        Result := -0.0097872250700192578;
                    end
                    else
                    begin
                        Result := 0.002268734873619201;
                    end;
                end
                else
                begin
                    if features[151] <= -57.499999999999993 then
                    begin
                        Result := 0.017598254686459851;
                    end
                    else
                    begin
                        Result := 0.00034481999972810803;
                    end;
                end;
            end
            else
            begin
                if features[228] <= -4386.4999999999991 then
                begin
                    if features[66] <= 196.00000000000003 then
                    begin
                        Result := 0.0072707010654539496;
                    end
                    else
                    begin
                        Result := -0.017967060940527614;
                    end;
                end
                else
                begin
                    if features[177] <= -6907.4999999999991 then
                    begin
                        Result := 0.030849161217645395;
                    end
                    else
                    begin
                        Result := 0.011250392682238812;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_60(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -650.49999999999989 then
    begin
        if features[224] <= -5321.4999999999991 then
        begin
            if features[13] <= 83476.500000000015 then
            begin
                Result := -0.011297971021839001;
            end
            else
            begin
                if features[183] <= -7227.4999999999991 then
                begin
                    Result := -0.0049771557140041384;
                end
                else
                begin
                    Result := 0.085054523208354271;
                end;
            end;
        end
        else
        begin
            Result := -0.020226030575735871;
        end;
    end
    else
    begin
        if features[175] <= -226.49999999999997 then
        begin
            if features[15] <= -176183095.99999997 then
            begin
                Result := -0.017269419848240351;
            end
            else
            begin
                if features[71] <= 2.5000000000000004 then
                begin
                    if features[47] <= 3396.5000000000005 then
                    begin
                        Result := 0.0038990209077447665;
                    end
                    else
                    begin
                        Result := -0.0088828344484268851;
                    end;
                end
                else
                begin
                    if features[92] <= -1.4999999999999998 then
                    begin
                        Result := -0.01533601585519076;
                    end
                    else
                    begin
                        Result := 0.0068585128723719097;
                    end;
                end;
            end;
        end
        else
        begin
            if features[164] <= -158902135.99999997 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.0020157755369233604;
                end
                else
                begin
                    if features[226] <= 730.50000000000011 then
                    begin
                        Result := -0.017136464195448262;
                    end
                    else
                    begin
                        Result := 0.016374746678314803;
                    end;
                end;
            end
            else
            begin
                if features[48] <= 9431.5000000000018 then
                begin
                    if features[151] <= -83.499999999999986 then
                    begin
                        Result := 0.013383221542986774;
                    end
                    else
                    begin
                        Result := 0.0039732168982370853;
                    end;
                end
                else
                begin
                    Result := 0.019088634658726584;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_61(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -650.49999999999989 then
    begin
        if features[216] <= -7374.4999999999991 then
        begin
            if features[13] <= 86540.000000000015 then
            begin
                Result := -0.0043927585794809078;
            end
            else
            begin
                Result := 0.060887134259287205;
            end;
        end
        else
        begin
            Result := -0.019581415837803373;
        end;
    end
    else
    begin
        if features[15] <= -197931207.99999997 then
        begin
            if features[69] <= 10.500000000000002 then
            begin
                Result := -0.017903089835475571;
            end
            else
            begin
                if features[175] <= 68.500000000000014 then
                begin
                    Result := -0.0093238245275826404;
                end
                else
                begin
                    if features[96] <= -159046207.99999997 then
                    begin
                        Result := 0.059832915454876727;
                    end
                    else
                    begin
                        Result := 0.0033785013888403903;
                    end;
                end;
            end;
        end
        else
        begin
            if features[222] <= -5358.4999999999991 then
            begin
                if features[124] <= 35.500000000000007 then
                begin
                    if features[109] <= 88.500000000000014 then
                    begin
                        Result := -0.0074935633178513086;
                    end
                    else
                    begin
                        Result := 0.0055933953030485092;
                    end;
                end
                else
                begin
                    if features[219] <= -6782.4999999999991 then
                    begin
                        Result := 0.026092277368531952;
                    end
                    else
                    begin
                        Result := 0.0035428652484964292;
                    end;
                end;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[8] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.02128301957323973;
                    end
                    else
                    begin
                        Result := 0.0094692664351249539;
                    end;
                end
                else
                begin
                    if features[217] <= -230.49999999999997 then
                    begin
                        Result := -0.014120841414495404;
                    end
                    else
                    begin
                        Result := 0.0041494766685510991;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_62(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -199453343.99999997 then
    begin
        if features[9] <= 9.5000000000000018 then
        begin
            if features[220] <= -16.499999999999996 then
            begin
                Result := -0.01984323803356746;
            end
            else
            begin
                if features[48] <= 6526.0000000000009 then
                begin
                    Result := -0.010770719680771437;
                end
                else
                begin
                    if features[165] <= 233117600.00000003 then
                    begin
                        Result := 0.036509142074992854;
                    end
                    else
                    begin
                        Result := -0.013820941095180839;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.029421564346524393;
        end;
    end
    else
    begin
        if features[220] <= -273.49999999999994 then
        begin
            if features[166] <= 6453940.0000000009 then
            begin
                Result := -0.0068569489276927619;
            end
            else
            begin
                if features[219] <= -6875.4999999999991 then
                begin
                    if features[164] <= -279727503.99999994 then
                    begin
                        Result := -0.024395505770922116;
                    end
                    else
                    begin
                        Result := 0.0407299953224027;
                    end;
                end
                else
                begin
                    if features[106] <= -1.4999999999999998 then
                    begin
                        Result := 0.018919354947969876;
                    end
                    else
                    begin
                        Result := -0.007652582810309342;
                    end;
                end;
            end;
        end
        else
        begin
            if features[15] <= -228169327.99999997 then
            begin
                Result := -0.016329967485823504;
            end
            else
            begin
                if features[222] <= -5368.4999999999991 then
                begin
                    if features[166] <= -30380654.999999996 then
                    begin
                        Result := -0.0030632917673516723;
                    end
                    else
                    begin
                        Result := 0.0060312815344314361;
                    end;
                end
                else
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.013968957193891927;
                    end
                    else
                    begin
                        Result := 0.0031341374899177404;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_63(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -199453343.99999997 then
    begin
        if features[223] <= -8.4999999999999982 then
        begin
            if features[80] <= -2926.9999999999995 then
            begin
                if features[69] <= 20.500000000000004 then
                begin
                    Result := -0.019417015010044145;
                end
                else
                begin
                    Result := 0.1000262191034911;
                end;
            end
            else
            begin
                Result := -0.020030526681147416;
            end;
        end
        else
        begin
            if features[48] <= 1.0000000180025095E-35 then
            begin
                Result := -0.0086998266093946588;
            end
            else
            begin
                Result := 0.018778541856374717;
            end;
        end;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[171] <= 2.5000000000000004 then
                begin
                    Result := -0.0015141470766196206;
                end
                else
                begin
                    if features[215] <= -4798.4999999999991 then
                    begin
                        Result := 0.0044610945762041916;
                    end
                    else
                    begin
                        Result := 0.025223286358631327;
                    end;
                end;
            end
            else
            begin
                if features[48] <= 10632.500000000002 then
                begin
                    if features[223] <= -730.49999999999989 then
                    begin
                        Result := -0.018138381481534259;
                    end
                    else
                    begin
                        Result := -0.0050699978819101228;
                    end;
                end
                else
                begin
                    Result := 0.0077078896388081122;
                end;
            end;
        end
        else
        begin
            if features[66] <= 157.00000000000003 then
            begin
                if features[15] <= -164642559.99999997 then
                begin
                    Result := -0.0078134071944381666;
                end
                else
                begin
                    if features[170] <= 1.5000000000000002 then
                    begin
                        Result := 0.0030257129175428319;
                    end
                    else
                    begin
                        Result := 0.010558654171155625;
                    end;
                end;
            end
            else
            begin
                Result := -0.014598264718317678;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_64(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -184685991.99999997 then
    begin
        if features[229] <= -621.49999999999989 then
        begin
            Result := -0.023629022143344475;
        end
        else
        begin
            if features[69] <= 20.500000000000004 then
            begin
                Result := -0.010927028967171196;
            end
            else
            begin
                if features[73] <= 108.50000000000001 then
                begin
                    if features[221] <= -5261.4999999999991 then
                    begin
                        Result := -0.0046748067647914828;
                    end
                    else
                    begin
                        Result := 0.111053914123631;
                    end;
                end
                else
                begin
                    Result := -0.0013495737322494687;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= -341.49999999999994 then
        begin
            if features[226] <= -1231.4999999999998 then
            begin
                Result := -0.024434384198836243;
            end
            else
            begin
                if features[219] <= -6875.4999999999991 then
                begin
                    if features[118] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.026350084708500917;
                    end
                    else
                    begin
                        Result := -0.0052169913288110685;
                    end;
                end
                else
                begin
                    if features[216] <= -4017.4999999999995 then
                    begin
                        Result := -0.0089479644362787346;
                    end
                    else
                    begin
                        Result := 0.013318465955962434;
                    end;
                end;
            end;
        end
        else
        begin
            if features[15] <= -223976111.99999997 then
            begin
                Result := -0.015599254559584601;
            end
            else
            begin
                if features[53] <= 3.5000000000000004 then
                begin
                    if features[222] <= -5368.4999999999991 then
                    begin
                        Result := 0.0036691443761243678;
                    end
                    else
                    begin
                        Result := 0.01413953661693655;
                    end;
                end
                else
                begin
                    if features[178] <= 149.50000000000003 then
                    begin
                        Result := -0.0034603955979480455;
                    end
                    else
                    begin
                        Result := 0.0060701243746555944;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_65(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[220] <= -16.499999999999996 then
        begin
            Result := -0.020441626071595595;
        end
        else
        begin
            Result := -0.0045357764103537614;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[76] <= 2.5000000000000004 then
                begin
                    if features[226] <= -788.49999999999989 then
                    begin
                        Result := -0.017841561766892961;
                    end
                    else
                    begin
                        Result := 0.003183757915532168;
                    end;
                end
                else
                begin
                    if features[166] <= -65235857.999999993 then
                    begin
                        Result := -0.012244352643968004;
                    end
                    else
                    begin
                        Result := -0.0024455839027580886;
                    end;
                end;
            end
            else
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    if features[186] <= 79.099998474121108 then
                    begin
                        Result := 0.0070016245626865108;
                    end
                    else
                    begin
                        Result := 0.026912461566196817;
                    end;
                end
                else
                begin
                    Result := -0.010561729118614548;
                end;
            end;
        end
        else
        begin
            if features[172] <= 2.5000000000000004 then
            begin
                if features[222] <= -5143.4999999999991 then
                begin
                    Result := 0.0057649137872333896;
                end
                else
                begin
                    if features[28] <= -5320.4999999999991 then
                    begin
                        Result := 0.023745714955203945;
                    end
                    else
                    begin
                        Result := 0.0064012962474322256;
                    end;
                end;
            end
            else
            begin
                if features[36] <= 821.50000000000011 then
                begin
                    if features[106] <= 1.5000000000000002 then
                    begin
                        Result := 0.0089925494764674929;
                    end
                    else
                    begin
                        Result := -0.0038898696848145512;
                    end;
                end
                else
                begin
                    Result := -0.013808933874323581;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_66(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[223] <= -707.49999999999989 then
    begin
        if features[216] <= -7374.4999999999991 then
        begin
            if features[220] <= -1336.4999999999998 then
            begin
                Result := -0.0048668473438625241;
            end
            else
            begin
                Result := 0.042807419599311843;
            end;
        end
        else
        begin
            if features[108] <= -221.49999999999997 then
            begin
                Result := -0.021830503856278168;
            end
            else
            begin
                if features[186] <= -241.87499999999997 then
                begin
                    Result := 0.059910781928831473;
                end
                else
                begin
                    Result := -0.0077988525746492884;
                end;
            end;
        end;
    end
    else
    begin
        if features[15] <= -223976111.99999997 then
        begin
            if features[48] <= 14642.000000000002 then
            begin
                Result := -0.016499143060674598;
            end
            else
            begin
                Result := 0.05315843613463548;
            end;
        end
        else
        begin
            if features[222] <= -5368.4999999999991 then
            begin
                if features[71] <= 1.5000000000000002 then
                begin
                    if features[139] <= -1.4999999999999998 then
                    begin
                        Result := 0.012906349484850786;
                    end
                    else
                    begin
                        Result := -0.011551561661030836;
                    end;
                end
                else
                begin
                    if features[48] <= 37946.000000000007 then
                    begin
                        Result := 0.0014453664131292947;
                    end
                    else
                    begin
                        Result := 0.049797244961333316;
                    end;
                end;
            end
            else
            begin
                if features[121] <= 310.50000000000006 then
                begin
                    if features[223] <= 1334.5000000000002 then
                    begin
                        Result := 0.0071793936598549615;
                    end
                    else
                    begin
                        Result := 0.020685938209622026;
                    end;
                end
                else
                begin
                    if features[176] <= -5020.4999999999991 then
                    begin
                        Result := -0.0011912898790857635;
                    end
                    else
                    begin
                        Result := -0.024154973897255599;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_67(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -223383351.99999997 then
    begin
        if features[220] <= -16.499999999999996 then
        begin
            Result := -0.020327715818429029;
        end
        else
        begin
            Result := -0.0039234627702613399;
        end;
    end
    else
    begin
        if features[229] <= -176.49999999999997 then
        begin
            if features[219] <= -7019.4999999999991 then
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    if features[183] <= -7032.4999999999991 then
                    begin
                        Result := 0.0098239948245202446;
                    end
                    else
                    begin
                        Result := 0.054119960372594381;
                    end;
                end
                else
                begin
                    if features[77] <= 1062.5000000000002 then
                    begin
                        Result := 0.041146604969027972;
                    end
                    else
                    begin
                        Result := -0.007920623464278043;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -863.49999999999989 then
                begin
                    Result := -0.019419229100228075;
                end
                else
                begin
                    if features[82] <= -48049.999999999993 then
                    begin
                        Result := -0.014745707081493071;
                    end
                    else
                    begin
                        Result := -0.0019221630789308158;
                    end;
                end;
            end;
        end
        else
        begin
            if features[129] <= 10443.500000000002 then
            begin
                if features[15] <= -197931207.99999997 then
                begin
                    Result := -0.014658838723384133;
                end
                else
                begin
                    if features[216] <= -4389.4999999999991 then
                    begin
                        Result := 0.0020528651617810287;
                    end
                    else
                    begin
                        Result := 0.010334338979184808;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -5934.4999999999991 then
                begin
                    if features[215] <= -6817.4999999999991 then
                    begin
                        Result := -0.02060124628211497;
                    end
                    else
                    begin
                        Result := 0.023912803775404036;
                    end;
                end
                else
                begin
                    Result := 0.0017702411974329611;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_68(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -218413975.99999997 then
    begin
        if features[229] <= -610.49999999999989 then
        begin
            Result := -0.023612922963553048;
        end
        else
        begin
            Result := -0.011394294711674649;
        end;
    end
    else
    begin
        if features[226] <= 495.50000000000006 then
        begin
            if features[175] <= -238.49999999999997 then
            begin
                if features[176] <= -4488.4999999999991 then
                begin
                    if features[166] <= -79390879.999999985 then
                    begin
                        Result := -0.007893265536626384;
                    end
                    else
                    begin
                        Result := 0.00021063727517835228;
                    end;
                end
                else
                begin
                    Result := -0.021878546495324856;
                end;
            end
            else
            begin
                if features[177] <= -4437.9999999999991 then
                begin
                    if features[96] <= 170859808.00000003 then
                    begin
                        Result := 0.0026423198256185082;
                    end
                    else
                    begin
                        Result := -0.023044875912620735;
                    end;
                end
                else
                begin
                    if features[180] <= -4808.4999999999991 then
                    begin
                        Result := 0.037168253174089665;
                    end
                    else
                    begin
                        Result := 0.00072499011785397474;
                    end;
                end;
            end;
        end
        else
        begin
            if features[155] <= 1.0000000180025095E-35 then
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    if features[175] <= 270.50000000000006 then
                    begin
                        Result := -0.0070830765617323366;
                    end
                    else
                    begin
                        Result := 0.013365394021098782;
                    end;
                end
                else
                begin
                    if features[226] <= 1340.5000000000002 then
                    begin
                        Result := 0.013293965365257685;
                    end
                    else
                    begin
                        Result := 0.031086695766286806;
                    end;
                end;
            end
            else
            begin
                if features[150] <= -9.4999999999999982 then
                begin
                    Result := 0.037389151167923955;
                end
                else
                begin
                    Result := -0.00089008729163889068;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_69(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -265031895.99999997 then
    begin
        if features[226] <= 706.50000000000011 then
        begin
            Result := -0.021469110756541482;
        end
        else
        begin
            if features[180] <= -7352.4999999999991 then
            begin
                Result := 0.053180543846058449;
            end
            else
            begin
                Result := -0.022636362979401858;
            end;
        end;
    end
    else
    begin
        if features[229] <= -640.49999999999989 then
        begin
            if features[216] <= -7461.4999999999991 then
            begin
                if features[151] <= -20.499999999999996 then
                begin
                    if features[164] <= -112882087.99999999 then
                    begin
                        Result := -0.0032189857486275039;
                    end
                    else
                    begin
                        Result := 0.066171751632641551;
                    end;
                end
                else
                begin
                    Result := -0.017342097338112622;
                end;
            end
            else
            begin
                if features[37] <= 2.5000000000000004 then
                begin
                    Result := 0.0049386485434402992;
                end
                else
                begin
                    Result := -0.019032737577921829;
                end;
            end;
        end
        else
        begin
            if features[175] <= -238.49999999999997 then
            begin
                if features[182] <= -4579.4999999999991 then
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.0019100029455880647;
                    end
                    else
                    begin
                        Result := -0.007179834001804772;
                    end;
                end
                else
                begin
                    Result := -0.021925278631245521;
                end;
            end
            else
            begin
                if features[216] <= -4373.4999999999991 then
                begin
                    if features[129] <= 10443.500000000002 then
                    begin
                        Result := 0.0018458877908584322;
                    end
                    else
                    begin
                        Result := 0.01582271729440422;
                    end;
                end
                else
                begin
                    if features[172] <= 4.5000000000000009 then
                    begin
                        Result := 0.01777485810258685;
                    end
                    else
                    begin
                        Result := 0.003238831009119147;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_70(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[166] <= -309517551.99999994 then
        begin
            Result := -0.022317876783915898;
        end
        else
        begin
            Result := -0.010290463642273819;
        end;
    end
    else
    begin
        if features[175] <= -238.49999999999997 then
        begin
            if features[182] <= -4541.4999999999991 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        Result := 0.016999545026452824;
                    end
                    else
                    begin
                        Result := -0.0014323196998385368;
                    end;
                end
                else
                begin
                    if features[135] <= 1.5000000000000002 then
                    begin
                        Result := -0.0068871188726343548;
                    end
                    else
                    begin
                        Result := 0.008280625106009569;
                    end;
                end;
            end
            else
            begin
                Result := -0.023846490774339455;
            end;
        end
        else
        begin
            if features[216] <= -4373.4999999999991 then
            begin
                if features[218] <= -5535.4999999999991 then
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        Result := -0.0019698334194312313;
                    end
                    else
                    begin
                        Result := 0.0084311089225763327;
                    end;
                end
                else
                begin
                    if features[165] <= 163161376.00000003 then
                    begin
                        Result := -0.009961908333993694;
                    end
                    else
                    begin
                        Result := 0.0069203788162335135;
                    end;
                end;
            end
            else
            begin
                if features[172] <= 4.5000000000000009 then
                begin
                    if features[217] <= 428.50000000000006 then
                    begin
                        Result := 0.028515972796384501;
                    end
                    else
                    begin
                        Result := 0.010779083831391275;
                    end;
                end
                else
                begin
                    if features[229] <= 825.50000000000011 then
                    begin
                        Result := -0.0027767721987580068;
                    end
                    else
                    begin
                        Result := 0.017192179239019025;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_71(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[220] <= -16.499999999999996 then
        begin
            Result := -0.019998606444491612;
        end
        else
        begin
            Result := -0.0037563549529430439;
        end;
    end
    else
    begin
        if features[166] <= -43191019.999999993 then
        begin
            if features[91] <= -1.0000000180025095E-35 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    if features[228] <= -5226.4999999999991 then
                    begin
                        Result := 0.00088874241479049122;
                    end
                    else
                    begin
                        Result := 0.017425518133492423;
                    end;
                end
                else
                begin
                    Result := -0.0046803547802246317;
                end;
            end
            else
            begin
                if features[2] <= 1.0000000180025095E-35 then
                begin
                    if features[172] <= 4.5000000000000009 then
                    begin
                        Result := -0.0047265871004878654;
                    end
                    else
                    begin
                        Result := -0.016680862730990797;
                    end;
                end
                else
                begin
                    if features[45] <= 2.5000000000000004 then
                    begin
                        Result := 0.01782216258381988;
                    end
                    else
                    begin
                        Result := -0.0017413365320958244;
                    end;
                end;
            end;
        end
        else
        begin
            if features[105] <= 2.5000000000000004 then
            begin
                if features[96] <= 179340080.00000003 then
                begin
                    if features[226] <= 1340.5000000000002 then
                    begin
                        Result := 0.0067780389759942387;
                    end
                    else
                    begin
                        Result := 0.021829910746957767;
                    end;
                end
                else
                begin
                    Result := -0.011600403052335242;
                end;
            end
            else
            begin
                if features[218] <= -5928.4999999999991 then
                begin
                    if features[155] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.012504871546171635;
                    end
                    else
                    begin
                        Result := -0.0051127996792055715;
                    end;
                end
                else
                begin
                    Result := -0.010213903652072524;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_72(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -486.49999999999994 then
    begin
        if features[166] <= -28946161.999999996 then
        begin
            if features[14] <= 415348336.00000006 then
            begin
                Result := -0.01885107534953627;
            end
            else
            begin
                Result := 0.047750793747670224;
            end;
        end
        else
        begin
            if features[224] <= -5533.4999999999991 then
            begin
                if features[173] <= -7395.4999999999991 then
                begin
                    Result := -0.0067172822447847079;
                end
                else
                begin
                    Result := 0.044591488336636613;
                end;
            end
            else
            begin
                if features[120] <= -1442.4999999999998 then
                begin
                    Result := 0.051554977381593418;
                end
                else
                begin
                    Result := -0.012285265843258432;
                end;
            end;
        end;
    end
    else
    begin
        if features[15] <= -274806975.99999994 then
        begin
            Result := -0.01812589810789603;
        end
        else
        begin
            if features[71] <= 1.5000000000000002 then
            begin
                if features[178] <= 308.50000000000006 then
                begin
                    if features[166] <= -41864945.999999993 then
                    begin
                        Result := -0.013105761276244876;
                    end
                    else
                    begin
                        Result := 0.00088653465595148911;
                    end;
                end
                else
                begin
                    if features[174] <= -6400.4999999999991 then
                    begin
                        Result := -0.0080264999235681849;
                    end
                    else
                    begin
                        Result := 0.013476762577764029;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 5937.5000000000009 then
                begin
                    if features[175] <= -432.49999999999994 then
                    begin
                        Result := 0.0021015208424361716;
                    end
                    else
                    begin
                        Result := 0.011125930922849249;
                    end;
                end
                else
                begin
                    if features[166] <= -93711059.999999985 then
                    begin
                        Result := -0.0072273067476134253;
                    end
                    else
                    begin
                        Result := 0.004048920299406243;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_73(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -560.49999999999989 then
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[221] <= -5665.4999999999991 then
            begin
                if features[107] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0068595194012362861;
                end
                else
                begin
                    Result := 0.046190156996119947;
                end;
            end
            else
            begin
                Result := -0.014335809182038459;
            end;
        end
        else
        begin
            Result := -0.023380929805316499;
        end;
    end
    else
    begin
        if features[175] <= -238.49999999999997 then
        begin
            if features[15] <= -176183095.99999997 then
            begin
                Result := -0.016238481842492731;
            end
            else
            begin
                if features[182] <= -4916.4999999999991 then
                begin
                    if features[71] <= 2.5000000000000004 then
                    begin
                        Result := -0.0044360745073175377;
                    end
                    else
                    begin
                        Result := 0.0044759643194390219;
                    end;
                end
                else
                begin
                    Result := -0.015012012862665675;
                end;
            end;
        end
        else
        begin
            if features[164] <= -141052407.99999997 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.00088499074202102914;
                end
                else
                begin
                    if features[226] <= 730.50000000000011 then
                    begin
                        Result := -0.016342901604909813;
                    end
                    else
                    begin
                        Result := 0.011231468527015174;
                    end;
                end;
            end
            else
            begin
                if features[55] <= 3.5000000000000004 then
                begin
                    if features[143] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.010230450784709945;
                    end
                    else
                    begin
                        Result := -0.0059283970729618538;
                    end;
                end
                else
                begin
                    if features[185] <= 29.083333015441898 then
                    begin
                        Result := -0.011606939322531413;
                    end
                    else
                    begin
                        Result := 0.0034277673395143615;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_74(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -486.49999999999994 then
    begin
        if features[216] <= -7374.4999999999991 then
        begin
            if features[13] <= 106714.00000000001 then
            begin
                if features[224] <= -5772.4999999999991 then
                begin
                    Result := 0.026650128092090136;
                end
                else
                begin
                    Result := -0.019837519340370698;
                end;
            end
            else
            begin
                Result := 0.072246694928348537;
            end;
        end
        else
        begin
            if features[164] <= 131472688.00000001 then
            begin
                Result := -0.019869156519717643;
            end
            else
            begin
                Result := -0.0047129643172123398;
            end;
        end;
    end
    else
    begin
        if features[175] <= -420.49999999999994 then
        begin
            if features[226] <= 413.50000000000006 then
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    if features[179] <= -5336.4999999999991 then
                    begin
                        Result := -0.0057910234815225859;
                    end
                    else
                    begin
                        Result := -0.01982142304125813;
                    end;
                end
                else
                begin
                    if features[47] <= 13687.500000000002 then
                    begin
                        Result := 0.0034011156776453284;
                    end
                    else
                    begin
                        Result := 0.048911733165459943;
                    end;
                end;
            end
            else
            begin
                if features[106] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.012409593126476489;
                end
                else
                begin
                    Result := -0.0094426538759209578;
                end;
            end;
        end
        else
        begin
            if features[164] <= -363563103.99999994 then
            begin
                Result := -0.0122008680855679;
            end
            else
            begin
                if features[66] <= 196.00000000000003 then
                begin
                    if features[27] <= -2748.4999999999995 then
                    begin
                        Result := 0.0053340669871776662;
                    end
                    else
                    begin
                        Result := 0.028450132467445533;
                    end;
                end
                else
                begin
                    Result := -0.014317882517167292;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_75(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[220] <= -16.499999999999996 then
        begin
            Result := -0.019820135113465226;
        end
        else
        begin
            Result := -0.0053512634025537674;
        end;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[216] <= -4044.4999999999995 then
            begin
                if features[226] <= -411.49999999999994 then
                begin
                    Result := -0.012384947535276556;
                end
                else
                begin
                    if features[150] <= -4.4999999999999991 then
                    begin
                        Result := 0.0064420662657693351;
                    end
                    else
                    begin
                        Result := -0.0042059721075312006;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    if features[70] <= 821.50000000000011 then
                    begin
                        Result := 0.0044882887388121503;
                    end
                    else
                    begin
                        Result := 0.047424638430156089;
                    end;
                end
                else
                begin
                    if features[176] <= -5768.4999999999991 then
                    begin
                        Result := 0.011681692434329788;
                    end
                    else
                    begin
                        Result := -0.011057928322618676;
                    end;
                end;
            end;
        end
        else
        begin
            if features[106] <= 1.0000000180025095E-35 then
            begin
                if features[96] <= 182914768.00000003 then
                begin
                    if features[70] <= 832.50000000000011 then
                    begin
                        Result := 0.011847479554501321;
                    end
                    else
                    begin
                        Result := 0.0037869050166620985;
                    end;
                end
                else
                begin
                    Result := -0.011170949111222813;
                end;
            end
            else
            begin
                if features[76] <= 2.5000000000000004 then
                begin
                    Result := 0.0080827909535095589;
                end
                else
                begin
                    if features[218] <= -5909.4999999999991 then
                    begin
                        Result := 0.0019754239333557824;
                    end
                    else
                    begin
                        Result := -0.010960940045389901;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_76(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -265031895.99999997 then
    begin
        if features[80] <= -3369.4999999999995 then
        begin
            Result := 0.038570361650164114;
        end
        else
        begin
            Result := -0.020258524631287234;
        end;
    end
    else
    begin
        if features[229] <= -692.49999999999989 then
        begin
            if features[218] <= -6776.4999999999991 then
            begin
                if features[229] <= -851.49999999999989 then
                begin
                    Result := 0.053357450075049856;
                end
                else
                begin
                    Result := -0.018513455431000279;
                end;
            end
            else
            begin
                if features[54] <= 8.5000000000000018 then
                begin
                    Result := -0.01736771789657154;
                end
                else
                begin
                    if features[166] <= -47585967.999999993 then
                    begin
                        Result := -0.012350755755428662;
                    end
                    else
                    begin
                        Result := 0.056279707058603107;
                    end;
                end;
            end;
        end
        else
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[219] <= -7019.4999999999991 then
                begin
                    if features[69] <= 6.5000000000000009 then
                    begin
                        Result := 0.033949420964027394;
                    end
                    else
                    begin
                        Result := -0.00061555382094939182;
                    end;
                end
                else
                begin
                    if features[155] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0077193411817527051;
                    end
                    else
                    begin
                        Result := -0.0020558872684279562;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 934.50000000000011 then
                begin
                    if features[174] <= -4547.4999999999991 then
                    begin
                        Result := -0.0034529295165452497;
                    end
                    else
                    begin
                        Result := 0.006255109417178069;
                    end;
                end
                else
                begin
                    if features[40] <= 1297.5000000000002 then
                    begin
                        Result := 0.015483427362449832;
                    end
                    else
                    begin
                        Result := -0.0048106102301579308;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_77(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -261947207.99999997 then
    begin
        Result := -0.018647339989067847;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[219] <= -6925.4999999999991 then
                begin
                    if features[183] <= -7065.4999999999991 then
                    begin
                        Result := 0.0075329488910207383;
                    end
                    else
                    begin
                        Result := 0.039136476747848932;
                    end;
                end
                else
                begin
                    if features[223] <= -446.49999999999994 then
                    begin
                        Result := -0.0092225694487094133;
                    end
                    else
                    begin
                        Result := 0.0040504845304682093;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 3.5000000000000004 then
                begin
                    if features[139] <= -3.4999999999999996 then
                    begin
                        Result := 0.0079191832311762411;
                    end
                    else
                    begin
                        Result := -0.009926830907216409;
                    end;
                end
                else
                begin
                    if features[181] <= -1069.4999999999998 then
                    begin
                        Result := -0.019778152213116809;
                    end
                    else
                    begin
                        Result := 0.0014417104239901196;
                    end;
                end;
            end;
        end
        else
        begin
            if features[172] <= 2.5000000000000004 then
            begin
                if features[221] <= -5646.4999999999991 then
                begin
                    if features[70] <= 846.50000000000011 then
                    begin
                        Result := 0.010344780484774559;
                    end
                    else
                    begin
                        Result := -0.0049818989797895631;
                    end;
                end
                else
                begin
                    Result := 0.017682253180636338;
                end;
            end
            else
            begin
                if features[36] <= 828.50000000000011 then
                begin
                    if features[228] <= -3631.4999999999995 then
                    begin
                        Result := 0.00176043475159327;
                    end
                    else
                    begin
                        Result := 0.023961112777370366;
                    end;
                end
                else
                begin
                    Result := -0.012224054686805827;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_78(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -265031895.99999997 then
    begin
        if features[80] <= -3369.4999999999995 then
        begin
            Result := 0.041067565181075995;
        end
        else
        begin
            if features[223] <= -8.4999999999999982 then
            begin
                Result := -0.021644276752211519;
            end
            else
            begin
                if features[216] <= -4103.4999999999991 then
                begin
                    if features[1] <= 72122.500000000015 then
                    begin
                        Result := -0.0194274158081469;
                    end
                    else
                    begin
                        Result := 0.026574600018690865;
                    end;
                end
                else
                begin
                    if features[171] <= 3.5000000000000004 then
                    begin
                        Result := -0.009274065150696266;
                    end
                    else
                    begin
                        Result := 0.074694450435780088;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[229] <= -692.49999999999989 then
        begin
            if features[37] <= 1.5000000000000002 then
            begin
                Result := 0.055840723030047251;
            end
            else
            begin
                Result := -0.0155455649419392;
            end;
        end
        else
        begin
            if features[55] <= 4.5000000000000009 then
            begin
                if features[60] <= -1.0000000180025095E-35 then
                begin
                    if features[226] <= 526.50000000000011 then
                    begin
                        Result := 0.0024633062202908894;
                    end
                    else
                    begin
                        Result := 0.010156802205792683;
                    end;
                end
                else
                begin
                    if features[9] <= 3.5000000000000004 then
                    begin
                        Result := -0.016002625291355679;
                    end
                    else
                    begin
                        Result := 0.0029211329017924392;
                    end;
                end;
            end
            else
            begin
                if features[109] <= 62.500000000000007 then
                begin
                    Result := -0.014443860537211953;
                end
                else
                begin
                    if features[150] <= -9.4999999999999982 then
                    begin
                        Result := 0.019209026190489632;
                    end
                    else
                    begin
                        Result := -0.002651874750586914;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_79(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[223] <= 858.50000000000011 then
        begin
            Result := -0.016991109829231625;
        end
        else
        begin
            Result := 0.027940003951578526;
        end;
    end
    else
    begin
        if features[226] <= 218.50000000000003 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[219] <= -6828.4999999999991 then
                begin
                    if features[164] <= -195133903.99999997 then
                    begin
                        Result := -0.0063513929507742779;
                    end
                    else
                    begin
                        Result := 0.024791764553054207;
                    end;
                end
                else
                begin
                    if features[106] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0042827282410318156;
                    end
                    else
                    begin
                        Result := -0.0093319576925844326;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 3.5000000000000004 then
                begin
                    Result := -0.0083602190624595934;
                end
                else
                begin
                    if features[174] <= -4641.4999999999991 then
                    begin
                        Result := -0.0021809779261528456;
                    end
                    else
                    begin
                        Result := 0.012593760300474557;
                    end;
                end;
            end;
        end
        else
        begin
            if features[155] <= -1.0000000180025095E-35 then
            begin
                if features[215] <= -6472.4999999999991 then
                begin
                    Result := -0.0014052189228669853;
                end
                else
                begin
                    if features[179] <= -5960.4999999999991 then
                    begin
                        Result := 0.018711632742751727;
                    end
                    else
                    begin
                        Result := 0.002590601919227423;
                    end;
                end;
            end
            else
            begin
                if features[76] <= 2.5000000000000004 then
                begin
                    Result := 0.0080469209028471451;
                end
                else
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.0054798487564753969;
                    end
                    else
                    begin
                        Result := -0.0055726742891820105;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_80(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -640.49999999999989 then
    begin
        if features[216] <= -7105.4999999999991 then
        begin
            Result := 0.0043761908435748049;
        end
        else
        begin
            Result := -0.018840955349056304;
        end;
    end
    else
    begin
        if features[175] <= -262.49999999999994 then
        begin
            if features[168] <= 1.5000000000000002 then
            begin
                if features[222] <= -5368.4999999999991 then
                begin
                    Result := -0.0038057551713867803;
                end
                else
                begin
                    if features[71] <= 2.5000000000000004 then
                    begin
                        Result := -0.0018228511892338245;
                    end
                    else
                    begin
                        Result := 0.013335638368542641;
                    end;
                end;
            end
            else
            begin
                if features[182] <= -7272.4999999999991 then
                begin
                    if features[81] <= -45935.499999999993 then
                    begin
                        Result := -0.014818681732665599;
                    end
                    else
                    begin
                        Result := 0.017783000276037367;
                    end;
                end
                else
                begin
                    if features[85] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.013538858845918511;
                    end
                    else
                    begin
                        Result := 3.3455570222124155E-05;
                    end;
                end;
            end;
        end
        else
        begin
            if features[27] <= -2748.4999999999995 then
            begin
                if features[164] <= -342043167.99999994 then
                begin
                    if features[9] <= 3.5000000000000004 then
                    begin
                        Result := -0.01407241957684475;
                    end
                    else
                    begin
                        Result := 0.020706428298344168;
                    end;
                end
                else
                begin
                    if features[48] <= 9431.5000000000018 then
                    begin
                        Result := 0.0029040770892700056;
                    end
                    else
                    begin
                        Result := 0.012141907949262171;
                    end;
                end;
            end
            else
            begin
                if features[148] <= 1504.5000000000002 then
                begin
                    Result := 0.040720894339541958;
                end
                else
                begin
                    Result := 0.0050680030301368268;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_81(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -692.49999999999989 then
    begin
        if features[221] <= -6085.4999999999991 then
        begin
            if features[174] <= -8743.9999999999982 then
            begin
                Result := 0.0559794727835215;
            end
            else
            begin
                Result := -0.016036607096555189;
            end;
        end
        else
        begin
            Result := -0.01958868947079713;
        end;
    end
    else
    begin
        if features[175] <= -272.49999999999994 then
        begin
            if features[182] <= -4579.4999999999991 then
            begin
                if features[76] <= 2.5000000000000004 then
                begin
                    if features[225] <= -5188.4999999999991 then
                    begin
                        Result := -0.002451127867119221;
                    end
                    else
                    begin
                        Result := 0.0095137011367361964;
                    end;
                end
                else
                begin
                    if features[9] <= 3.5000000000000004 then
                    begin
                        Result := -0.00940951911659621;
                    end
                    else
                    begin
                        Result := 0.005567942085271795;
                    end;
                end;
            end
            else
            begin
                Result := -0.020871480648993673;
            end;
        end
        else
        begin
            if features[216] <= -4373.4999999999991 then
            begin
                if features[41] <= 1366.5000000000002 then
                begin
                    if features[164] <= -363563103.99999994 then
                    begin
                        Result := -0.01246784994219613;
                    end
                    else
                    begin
                        Result := 0.0043334701223061642;
                    end;
                end
                else
                begin
                    if features[226] <= 1103.5000000000002 then
                    begin
                        Result := -0.0094579760699165048;
                    end
                    else
                    begin
                        Result := 0.0088134202298025249;
                    end;
                end;
            end
            else
            begin
                if features[122] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.012001291031330843;
                end
                else
                begin
                    if features[27] <= -2748.4999999999995 then
                    begin
                        Result := 0.010717815066455269;
                    end
                    else
                    begin
                        Result := 0.039419823515496895;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_82(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -265031895.99999997 then
    begin
        Result := -0.018464414358372778;
    end
    else
    begin
        if features[226] <= -229.49999999999997 then
        begin
            if features[216] <= -7374.4999999999991 then
            begin
                if features[166] <= -83596415.999999985 then
                begin
                    if features[13] <= 106714.00000000001 then
                    begin
                        Result := -0.019047097313596509;
                    end
                    else
                    begin
                        Result := 0.064441605946402081;
                    end;
                end
                else
                begin
                    Result := 0.028422341327519404;
                end;
            end
            else
            begin
                if features[37] <= 3.5000000000000004 then
                begin
                    if features[216] <= -4044.4999999999995 then
                    begin
                        Result := -0.00068348910074502009;
                    end
                    else
                    begin
                        Result := 0.032407382212476736;
                    end;
                end
                else
                begin
                    if features[217] <= 170.50000000000003 then
                    begin
                        Result := -0.006331139190330801;
                    end
                    else
                    begin
                        Result := -0.018890978435754453;
                    end;
                end;
            end;
        end
        else
        begin
            if features[2] <= 1.0000000180025095E-35 then
            begin
                if features[36] <= 750.50000000000011 then
                begin
                    if features[15] <= -228169327.99999997 then
                    begin
                        Result := -0.016754711554850296;
                    end
                    else
                    begin
                        Result := 0.0036951113344679308;
                    end;
                end
                else
                begin
                    if features[155] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.003877250925622563;
                    end
                    else
                    begin
                        Result := -0.012685682279250213;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -6165.4999999999991 then
                begin
                    Result := -0.0095510345393039903;
                end
                else
                begin
                    if features[176] <= -6004.4999999999991 then
                    begin
                        Result := 0.016815116975002691;
                    end
                    else
                    begin
                        Result := 0.0020460586870462661;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_83(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -890.49999999999989 then
    begin
        if features[221] <= -5665.4999999999991 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[166] <= -105620823.99999999 then
                begin
                    Result := -0.0098437273488765839;
                end
                else
                begin
                    Result := 0.060016044016498397;
                end;
            end
            else
            begin
                if features[184] <= 575.50000000000011 then
                begin
                    Result := -0.019389904422559921;
                end
                else
                begin
                    Result := 0.04781858215876366;
                end;
            end;
        end
        else
        begin
            Result := -0.02163164889905933;
        end;
    end
    else
    begin
        if features[15] <= -274806975.99999994 then
        begin
            if features[177] <= -5052.4999999999991 then
            begin
                Result := -0.020056041110628479;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    Result := 0.042653288566166722;
                end
                else
                begin
                    Result := -0.023284499856334004;
                end;
            end;
        end
        else
        begin
            if features[24] <= 1.5000000000000002 then
            begin
                if features[226] <= 706.50000000000011 then
                begin
                    if features[89] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0049767393673813276;
                    end
                    else
                    begin
                        Result := -0.021735061400565425;
                    end;
                end
                else
                begin
                    Result := 0.022017912884020677;
                end;
            end
            else
            begin
                if features[150] <= -1.4999999999999998 then
                begin
                    if features[106] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.01394521052994196;
                    end
                    else
                    begin
                        Result := 0.0019857440485498111;
                    end;
                end
                else
                begin
                    if features[71] <= 1.5000000000000002 then
                    begin
                        Result := -0.0062601494242138624;
                    end
                    else
                    begin
                        Result := 0.0024709499497771389;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_84(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -261947207.99999997 then
    begin
        Result := -0.017616360050721959;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[77] <= 5937.5000000000009 then
                begin
                    if features[225] <= -5370.4999999999991 then
                    begin
                        Result := -0.0064711032069044222;
                    end
                    else
                    begin
                        Result := 0.0033199796769796358;
                    end;
                end
                else
                begin
                    if features[178] <= -612.49999999999989 then
                    begin
                        Result := -0.018184612424510537;
                    end
                    else
                    begin
                        Result := -0.0064340094267348134;
                    end;
                end;
            end
            else
            begin
                if features[1] <= 19761.500000000004 then
                begin
                    if features[70] <= 598.50000000000011 then
                    begin
                        Result := -0.015807926842350783;
                    end
                    else
                    begin
                        Result := 0.0069626755238710704;
                    end;
                end
                else
                begin
                    if features[178] <= -406.49999999999994 then
                    begin
                        Result := 0.012175954499303447;
                    end
                    else
                    begin
                        Result := 0.052327570819648464;
                    end;
                end;
            end;
        end
        else
        begin
            if features[105] <= 2.5000000000000004 then
            begin
                if features[226] <= 1340.5000000000002 then
                begin
                    if features[15] <= -164642559.99999997 then
                    begin
                        Result := -0.0092624612809717646;
                    end
                    else
                    begin
                        Result := 0.0060272042534084734;
                    end;
                end
                else
                begin
                    Result := 0.018796238038051374;
                end;
            end
            else
            begin
                if features[36] <= 694.50000000000011 then
                begin
                    if features[158] <= 6535.5000000000009 then
                    begin
                        Result := 0.0070904358183069803;
                    end
                    else
                    begin
                        Result := -0.0083189049169766164;
                    end;
                end
                else
                begin
                    Result := -0.01395092429674828;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_85(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        if features[80] <= -1.0000000180025095E-35 then
        begin
            Result := 0.060907097027147264;
        end
        else
        begin
            Result := -0.021248072105413157;
        end;
    end
    else
    begin
        if features[220] <= 289.50000000000006 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[166] <= -86367283.999999985 then
                begin
                    if features[48] <= 12021.500000000002 then
                    begin
                        Result := -0.010122681859290335;
                    end
                    else
                    begin
                        Result := 0.0066108847328054336;
                    end;
                end
                else
                begin
                    if features[13] <= 43125.500000000007 then
                    begin
                        Result := -0.0028750241980981207;
                    end
                    else
                    begin
                        Result := 0.0064871528008743004;
                    end;
                end;
            end
            else
            begin
                if features[37] <= 7.5000000000000009 then
                begin
                    if features[74] <= 5.5000000000000009 then
                    begin
                        Result := -0.0028115758834912287;
                    end
                    else
                    begin
                        Result := 0.015902101133513119;
                    end;
                end
                else
                begin
                    if features[39] <= 1387.5000000000002 then
                    begin
                        Result := 0.029255094294286629;
                    end
                    else
                    begin
                        Result := -0.019027040567459349;
                    end;
                end;
            end;
        end
        else
        begin
            if features[108] <= -1453.4999999999998 then
            begin
                Result := 0.061370399723039148;
            end
            else
            begin
                if features[121] <= 1402.5000000000002 then
                begin
                    if features[65] <= 11.500000000000002 then
                    begin
                        Result := 0.0067171240045160608;
                    end
                    else
                    begin
                        Result := -0.0083157212981379881;
                    end;
                end
                else
                begin
                    if features[166] <= -25979130.999999996 then
                    begin
                        Result := -0.028293988547312583;
                    end
                    else
                    begin
                        Result := -0.0027478156169730454;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_86(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        Result := -0.020874455990226401;
    end
    else
    begin
        if features[166] <= -44508701.999999993 then
        begin
            if features[216] <= -4389.4999999999991 then
            begin
                if features[2] <= 1.0000000180025095E-35 then
                begin
                    if features[9] <= 11.500000000000002 then
                    begin
                        Result := -0.0087167461100947485;
                    end
                    else
                    begin
                        Result := 0.012415044295333919;
                    end;
                end
                else
                begin
                    if features[225] <= -6211.4999999999991 then
                    begin
                        Result := -0.014904840103599132;
                    end
                    else
                    begin
                        Result := 0.0061096148384450627;
                    end;
                end;
            end
            else
            begin
                if features[172] <= 4.5000000000000009 then
                begin
                    if features[225] <= -5769.4999999999991 then
                    begin
                        Result := -0.0080851942323982504;
                    end
                    else
                    begin
                        Result := 0.015323363675338059;
                    end;
                end
                else
                begin
                    if features[220] <= 10.500000000000002 then
                    begin
                        Result := -0.01987330776695596;
                    end
                    else
                    begin
                        Result := 0.0026508865151535829;
                    end;
                end;
            end;
        end
        else
        begin
            if features[105] <= 2.5000000000000004 then
            begin
                if features[15] <= -228169327.99999997 then
                begin
                    Result := -0.015928643423431223;
                end
                else
                begin
                    if features[96] <= 179340080.00000003 then
                    begin
                        Result := 0.0073674600240473606;
                    end
                    else
                    begin
                        Result := -0.0094991536686060869;
                    end;
                end;
            end
            else
            begin
                if features[218] <= -5909.4999999999991 then
                begin
                    if features[47] <= 4610.5000000000009 then
                    begin
                        Result := 0.0069914391637514511;
                    end
                    else
                    begin
                        Result := -0.0085351741277223305;
                    end;
                end
                else
                begin
                    Result := -0.010631594831147171;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_87(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        Result := -0.020153307580513282;
    end
    else
    begin
        if features[229] <= -692.49999999999989 then
        begin
            if features[218] <= -5473.4999999999991 then
            begin
                if features[70] <= 833.50000000000011 then
                begin
                    if features[25] <= 2.5000000000000004 then
                    begin
                        Result := 0.013050993933986212;
                    end
                    else
                    begin
                        Result := -0.023211233880822111;
                    end;
                end
                else
                begin
                    Result := -0.021297883127128978;
                end;
            end
            else
            begin
                if features[47] <= 19854.500000000004 then
                begin
                    Result := -0.021898051824802183;
                end
                else
                begin
                    if features[166] <= -121520975.99999999 then
                    begin
                        Result := -0.023551577998686738;
                    end
                    else
                    begin
                        Result := 0.028185011538336965;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4054.4999999999995 then
            begin
                if features[150] <= -7.4999999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.011794916203081377;
                    end
                    else
                    begin
                        Result := -0.0056986766686430677;
                    end;
                end
                else
                begin
                    if features[166] <= -15977888.499999998 then
                    begin
                        Result := -0.0043787159389991849;
                    end
                    else
                    begin
                        Result := 0.0029089514879484732;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    if features[172] <= 1.5000000000000002 then
                    begin
                        Result := 0.034742993776456794;
                    end
                    else
                    begin
                        Result := 0.006168045182424392;
                    end;
                end
                else
                begin
                    if features[229] <= -20.499999999999996 then
                    begin
                        Result := -0.012268691342242611;
                    end
                    else
                    begin
                        Result := 0.0080551797754125267;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_88(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -890.49999999999989 then
    begin
        Result := -0.018559234391272137;
    end
    else
    begin
        if features[118] <= -1.0000000180025095E-35 then
        begin
            if features[150] <= -1.4999999999999998 then
            begin
                if features[176] <= -7176.4999999999991 then
                begin
                    if features[185] <= -273.87499999999994 then
                    begin
                        Result := 0.049475979424258937;
                    end
                    else
                    begin
                        Result := 0.015929041327116981;
                    end;
                end
                else
                begin
                    Result := 0.0087928294970134654;
                end;
            end
            else
            begin
                if features[218] <= -5796.4999999999991 then
                begin
                    if features[158] <= 3062.5000000000005 then
                    begin
                        Result := 0.011483999478662313;
                    end
                    else
                    begin
                        Result := -0.0015232250570330222;
                    end;
                end
                else
                begin
                    Result := -0.0031761014216081132;
                end;
            end;
        end
        else
        begin
            if features[174] <= -4572.4999999999991 then
            begin
                if features[226] <= 934.50000000000011 then
                begin
                    if features[178] <= -1207.4999999999998 then
                    begin
                        Result := -0.016889457768421691;
                    end
                    else
                    begin
                        Result := -0.0032740459301086864;
                    end;
                end
                else
                begin
                    if features[27] <= -3848.4999999999995 then
                    begin
                        Result := 0.011988541349561928;
                    end
                    else
                    begin
                        Result := -0.010136166986236528;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5378.4999999999991 then
                begin
                    if features[108] <= 361.50000000000006 then
                    begin
                        Result := -0.0098026101743488043;
                    end
                    else
                    begin
                        Result := 0.017935234474716885;
                    end;
                end
                else
                begin
                    if features[217] <= 161.50000000000003 then
                    begin
                        Result := 0.024040780405139892;
                    end
                    else
                    begin
                        Result := 0.0042924264964325351;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_89(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -692.49999999999989 then
    begin
        if features[166] <= -166605455.99999997 then
        begin
            Result := -0.023315869662122936;
        end
        else
        begin
            if features[47] <= 19493.500000000004 then
            begin
                Result := -0.013711486167536445;
            end
            else
            begin
                Result := 0.01199151965075048;
            end;
        end;
    end
    else
    begin
        if features[166] <= -41864945.999999993 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[94] <= -108380.99999999999 then
                begin
                    Result := -0.018451989553623649;
                end
                else
                begin
                    if features[175] <= -262.49999999999994 then
                    begin
                        Result := -0.0074570534597748518;
                    end
                    else
                    begin
                        Result := 0.0011506276945741191;
                    end;
                end;
            end
            else
            begin
                if features[47] <= 12869.500000000002 then
                begin
                    if features[70] <= 598.50000000000011 then
                    begin
                        Result := -0.015848556407153092;
                    end
                    else
                    begin
                        Result := 0.0068889933069055638;
                    end;
                end
                else
                begin
                    if features[227] <= -5662.4999999999991 then
                    begin
                        Result := -0.027017859544779539;
                    end
                    else
                    begin
                        Result := 0.041410676224176143;
                    end;
                end;
            end;
        end
        else
        begin
            if features[159] <= 52.500000000000007 then
            begin
                if features[36] <= 735.50000000000011 then
                begin
                    if features[226] <= 971.50000000000011 then
                    begin
                        Result := 0.0042101064033838662;
                    end
                    else
                    begin
                        Result := 0.012510250678434951;
                    end;
                end
                else
                begin
                    if features[106] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0034187904368399194;
                    end
                    else
                    begin
                        Result := -0.012764029828421364;
                    end;
                end;
            end
            else
            begin
                Result := -0.030067081287211545;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_90(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        if features[80] <= -1.0000000180025095E-35 then
        begin
            Result := 0.060983229440248636;
        end
        else
        begin
            Result := -0.021353110334326408;
        end;
    end
    else
    begin
        if features[223] <= -730.49999999999989 then
        begin
            if features[216] <= -7374.4999999999991 then
            begin
                if features[13] <= 86540.000000000015 then
                begin
                    if features[220] <= -1252.4999999999998 then
                    begin
                        Result := -0.014935718371057068;
                    end
                    else
                    begin
                        Result := 0.031030093297395103;
                    end;
                end
                else
                begin
                    if features[176] <= -6992.4999999999991 then
                    begin
                        Result := 0.0072713494364110122;
                    end
                    else
                    begin
                        Result := 0.10702219041368491;
                    end;
                end;
            end
            else
            begin
                Result := -0.014654552349374858;
            end;
        end
        else
        begin
            if features[150] <= -8.4999999999999982 then
            begin
                if features[185] <= -528.87499999999989 then
                begin
                    if features[224] <= -5483.4999999999991 then
                    begin
                        Result := 0.0031571907515162314;
                    end
                    else
                    begin
                        Result := 0.047519247361271638;
                    end;
                end
                else
                begin
                    if features[107] <= 2.5000000000000004 then
                    begin
                        Result := 0.0082670924216380511;
                    end
                    else
                    begin
                        Result := -0.018016510288141184;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 1340.5000000000002 then
                begin
                    if features[174] <= -4462.4999999999991 then
                    begin
                        Result := -0.0020446544249454958;
                    end
                    else
                    begin
                        Result := 0.006464405883416055;
                    end;
                end
                else
                begin
                    if features[155] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.020383422477740405;
                    end
                    else
                    begin
                        Result := 0.0024466108696967687;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_91(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -890.49999999999989 then
    begin
        if features[221] <= -6085.4999999999991 then
        begin
            if features[174] <= -8743.9999999999982 then
            begin
                Result := 0.048440249577020596;
            end
            else
            begin
                Result := -0.011181436105551421;
            end;
        end
        else
        begin
            Result := -0.020049331975315179;
        end;
    end
    else
    begin
        if features[164] <= -342043167.99999994 then
        begin
            if features[219] <= -4751.4999999999991 then
            begin
                if features[9] <= 3.5000000000000004 then
                begin
                    Result := -0.015286292307637579;
                end
                else
                begin
                    Result := 0.0060494547616447578;
                end;
            end
            else
            begin
                if features[14] <= -411206191.99999994 then
                begin
                    Result := 0.064279683898588416;
                end
                else
                begin
                    Result := 0.00059765525279155537;
                end;
            end;
        end
        else
        begin
            if features[175] <= -440.49999999999994 then
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[150] <= -2.4999999999999996 then
                    begin
                        Result := 0.010086435753581882;
                    end
                    else
                    begin
                        Result := -0.0033624575689548174;
                    end;
                end
                else
                begin
                    if features[173] <= -7654.4999999999991 then
                    begin
                        Result := 0.034245474266103519;
                    end
                    else
                    begin
                        Result := -0.0096472759187631197;
                    end;
                end;
            end
            else
            begin
                if features[129] <= 10320.500000000002 then
                begin
                    if features[228] <= -3520.4999999999995 then
                    begin
                        Result := 0.002215288595877924;
                    end
                    else
                    begin
                        Result := 0.018856673722612658;
                    end;
                end
                else
                begin
                    if features[82] <= 99971.000000000015 then
                    begin
                        Result := 0.034157389210064913;
                    end
                    else
                    begin
                        Result := 0.0096511768927265134;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_92(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -650.49999999999989 then
    begin
        if features[118] <= 1.0000000180025095E-35 then
        begin
            if features[216] <= -4017.4999999999995 then
            begin
                if features[216] <= -6725.4999999999991 then
                begin
                    if features[164] <= -177046671.99999997 then
                    begin
                        Result := -0.012698438071035649;
                    end
                    else
                    begin
                        Result := 0.021253408216465507;
                    end;
                end
                else
                begin
                    Result := -0.016064094447841255;
                end;
            end
            else
            begin
                if features[165] <= 257554672.00000003 then
                begin
                    Result := -0.0092878101379509359;
                end
                else
                begin
                    if features[215] <= -4023.4999999999995 then
                    begin
                        Result := 0.083828590675135706;
                    end
                    else
                    begin
                        Result := 0.0042650321317214092;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.023960622897453789;
        end;
    end
    else
    begin
        if features[15] <= -274806975.99999994 then
        begin
            if features[177] <= -5052.4999999999991 then
            begin
                Result := -0.019981943247075709;
            end
            else
            begin
                Result := 0.015823157576165956;
            end;
        end
        else
        begin
            if features[66] <= 108.50000000000001 then
            begin
                if features[55] <= 4.5000000000000009 then
                begin
                    if features[24] <= 1.5000000000000002 then
                    begin
                        Result := -0.0079969592806550284;
                    end
                    else
                    begin
                        Result := 0.0045627247672378945;
                    end;
                end
                else
                begin
                    if features[109] <= 47.500000000000007 then
                    begin
                        Result := -0.013861517491487639;
                    end
                    else
                    begin
                        Result := 0.00057729865753384103;
                    end;
                end;
            end
            else
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.02105137322102317;
                end
                else
                begin
                    Result := 0.001634514153947275;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_93(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -560.49999999999989 then
    begin
        if features[221] <= -5799.4999999999991 then
        begin
            if features[67] <= 1394.0000000000002 then
            begin
                if features[1] <= 239563.50000000003 then
                begin
                    Result := -0.013833391635553577;
                end
                else
                begin
                    Result := 0.080836696133547326;
                end;
            end
            else
            begin
                if features[105] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.070358483957264226;
                end
                else
                begin
                    Result := -0.006965976128350912;
                end;
            end;
        end
        else
        begin
            if features[27] <= -2884.4999999999995 then
            begin
                Result := -0.018022963903180308;
            end
            else
            begin
                Result := 0.04861550227318593;
            end;
        end;
    end
    else
    begin
        if features[15] <= -274806975.99999994 then
        begin
            Result := -0.017094151544605998;
        end
        else
        begin
            if features[222] <= -5368.4999999999991 then
            begin
                if features[186] <= 79.099998474121108 then
                begin
                    if features[187] <= 10.033333301544191 then
                    begin
                        Result := -0.0059622724644842768;
                    end
                    else
                    begin
                        Result := 0.0040305501518813781;
                    end;
                end
                else
                begin
                    if features[148] <= 2872.5000000000005 then
                    begin
                        Result := 0.0066892497433463831;
                    end
                    else
                    begin
                        Result := -0.02295305335908485;
                    end;
                end;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[180] <= -8221.4999999999982 then
                    begin
                        Result := 0.044301014680194845;
                    end
                    else
                    begin
                        Result := 0.0091216231477299192;
                    end;
                end
                else
                begin
                    if features[217] <= -230.49999999999997 then
                    begin
                        Result := -0.012328923863411275;
                    end
                    else
                    begin
                        Result := 0.0020577412670412412;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_94(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -692.49999999999989 then
    begin
        if features[218] <= -5503.4999999999991 then
        begin
            if features[216] <= -7374.4999999999991 then
            begin
                if features[81] <= 1.0000000180025095E-35 then
                begin
                    if features[174] <= -5396.4999999999991 then
                    begin
                        Result := -0.023861579050325984;
                    end
                    else
                    begin
                        Result := 0.041697004220185054;
                    end;
                end
                else
                begin
                    if features[221] <= -5665.4999999999991 then
                    begin
                        Result := 0.055348171663992335;
                    end
                    else
                    begin
                        Result := -0.018521335237693805;
                    end;
                end;
            end
            else
            begin
                Result := -0.011482919452109263;
            end;
        end
        else
        begin
            Result := -0.021058968868197084;
        end;
    end
    else
    begin
        if features[15] <= -336406943.99999994 then
        begin
            Result := -0.022275039029803826;
        end
        else
        begin
            if features[216] <= -4054.4999999999995 then
            begin
                if features[182] <= -4541.4999999999991 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0044508918768400149;
                    end
                    else
                    begin
                        Result := -0.0016946032950260486;
                    end;
                end
                else
                begin
                    if features[108] <= 4.5000000000000009 then
                    begin
                        Result := -0.022057553472207687;
                    end
                    else
                    begin
                        Result := 0.0061786980601455993;
                    end;
                end;
            end
            else
            begin
                if features[167] <= 1.5000000000000002 then
                begin
                    if features[217] <= 590.50000000000011 then
                    begin
                        Result := 0.030158871145076885;
                    end
                    else
                    begin
                        Result := -0.0012632101245765501;
                    end;
                end
                else
                begin
                    if features[226] <= 1270.0000000000002 then
                    begin
                        Result := -0.00012914934246534748;
                    end
                    else
                    begin
                        Result := 0.020973272903954954;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_95(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -261947207.99999997 then
    begin
        if features[226] <= 706.50000000000011 then
        begin
            Result := -0.018436423031417275;
        end
        else
        begin
            if features[180] <= -7352.4999999999991 then
            begin
                Result := 0.058577187283817334;
            end
            else
            begin
                Result := -0.022712910901824736;
            end;
        end;
    end
    else
    begin
        if features[66] <= 34.500000000000007 then
        begin
            if features[55] <= 3.5000000000000004 then
            begin
                if features[226] <= 526.50000000000011 then
                begin
                    if features[24] <= 1.5000000000000002 then
                    begin
                        Result := -0.011744932544741453;
                    end
                    else
                    begin
                        Result := 0.0023704939610599356;
                    end;
                end
                else
                begin
                    if features[155] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.017378582376035692;
                    end
                    else
                    begin
                        Result := 0.0057160115502125491;
                    end;
                end;
            end
            else
            begin
                if features[9] <= 3.5000000000000004 then
                begin
                    if features[186] <= 65.26666641235353 then
                    begin
                        Result := -0.011430690640553909;
                    end
                    else
                    begin
                        Result := -0.001303284543042146;
                    end;
                end
                else
                begin
                    if features[27] <= -5204.4999999999991 then
                    begin
                        Result := 0.019354419072092441;
                    end
                    else
                    begin
                        Result := -0.0032395241158983869;
                    end;
                end;
            end;
        end
        else
        begin
            if features[150] <= -1.4999999999999998 then
            begin
                if features[215] <= -4764.4999999999991 then
                begin
                    Result := -0.012123243134538417;
                end
                else
                begin
                    if features[81] <= -48747.499999999993 then
                    begin
                        Result := -0.0030752516745553545;
                    end
                    else
                    begin
                        Result := 0.055619246103869181;
                    end;
                end;
            end
            else
            begin
                Result := -0.019914801218223616;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_96(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -265031895.99999997 then
    begin
        if features[69] <= 17.500000000000004 then
        begin
            if features[220] <= 1232.5000000000002 then
            begin
                Result := -0.019336266039434544;
            end
            else
            begin
                Result := 0.027671402840006853;
            end;
        end
        else
        begin
            if features[158] <= 20937.500000000004 then
            begin
                Result := 0.0;
            end
            else
            begin
                Result := 0.077637536244364244;
            end;
        end;
    end
    else
    begin
        if features[55] <= 4.5000000000000009 then
        begin
            if features[226] <= -890.49999999999989 then
            begin
                if features[218] <= -6799.4999999999991 then
                begin
                    Result := 0.028345559167478846;
                end
                else
                begin
                    Result := -0.015951907775606334;
                end;
            end
            else
            begin
                if features[66] <= 108.50000000000001 then
                begin
                    if features[175] <= -676.49999999999989 then
                    begin
                        Result := -0.0012109646939254459;
                    end
                    else
                    begin
                        Result := 0.0050669951191399457;
                    end;
                end
                else
                begin
                    if features[69] <= 6.5000000000000009 then
                    begin
                        Result := -0.014992627354863203;
                    end
                    else
                    begin
                        Result := 0.014006267753391373;
                    end;
                end;
            end;
        end
        else
        begin
            if features[108] <= 23.500000000000004 then
            begin
                Result := -0.013049676669585923;
            end
            else
            begin
                if features[148] <= 1231.5000000000002 then
                begin
                    if features[77] <= 27562.500000000004 then
                    begin
                        Result := -9.5758427906393899E-05;
                    end
                    else
                    begin
                        Result := 0.024136860548383276;
                    end;
                end
                else
                begin
                    if features[171] <= 3.5000000000000004 then
                    begin
                        Result := -0.01926182510522001;
                    end
                    else
                    begin
                        Result := 0.010471356373800847;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_97(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -692.49999999999989 then
    begin
        if features[166] <= -123143799.99999999 then
        begin
            Result := -0.022185244187755415;
        end
        else
        begin
            if features[47] <= 19854.500000000004 then
            begin
                Result := -0.011837565065503161;
            end
            else
            begin
                if features[218] <= -4675.4999999999991 then
                begin
                    Result := -0.0063402116019566253;
                end
                else
                begin
                    if features[81] <= 117499.50000000001 then
                    begin
                        Result := 0.09288803024956703;
                    end
                    else
                    begin
                        Result := -0.0014914372647321225;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[15] <= -274806975.99999994 then
        begin
            if features[177] <= -5052.4999999999991 then
            begin
                Result := -0.01871641170042344;
            end
            else
            begin
                if features[229] <= -92.499999999999986 then
                begin
                    Result := 0.056819125360025272;
                end
                else
                begin
                    Result := -0.023459517831431305;
                end;
            end;
        end
        else
        begin
            if features[60] <= -1.0000000180025095E-35 then
            begin
                if features[55] <= 4.5000000000000009 then
                begin
                    if features[226] <= 526.50000000000011 then
                    begin
                        Result := 0.0013159224565037894;
                    end
                    else
                    begin
                        Result := 0.0085452659519852561;
                    end;
                end
                else
                begin
                    if features[109] <= 62.500000000000007 then
                    begin
                        Result := -0.014117882708451539;
                    end
                    else
                    begin
                        Result := 0.00055557215571209898;
                    end;
                end;
            end
            else
            begin
                if features[90] <= 2.5000000000000004 then
                begin
                    Result := -0.014279680915641212;
                end
                else
                begin
                    if features[77] <= 32062.500000000004 then
                    begin
                        Result := 0.018605114026153578;
                    end
                    else
                    begin
                        Result := -0.0087038445309151769;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_98(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -692.49999999999989 then
    begin
        if features[37] <= 1.5000000000000002 then
        begin
            Result := 0.057513958453392536;
        end
        else
        begin
            if features[227] <= -5325.4999999999991 then
            begin
                Result := -0.0039203336771157496;
            end
            else
            begin
                if features[226] <= -775.49999999999989 then
                begin
                    Result := -0.021334688168044132;
                end
                else
                begin
                    Result := 0.0055743827267516477;
                end;
            end;
        end;
    end
    else
    begin
        if features[15] <= -274806975.99999994 then
        begin
            if features[177] <= -5052.4999999999991 then
            begin
                Result := -0.018682211362116497;
            end
            else
            begin
                if features[185] <= -77.291667938232408 then
                begin
                    Result := 0.055981992450923307;
                end
                else
                begin
                    Result := -0.023732853420847244;
                end;
            end;
        end
        else
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[219] <= -7127.4999999999991 then
                begin
                    if features[227] <= -4533.4999999999991 then
                    begin
                        Result := 0.020420233809545715;
                    end
                    else
                    begin
                        Result := 0.05934098531046459;
                    end;
                end
                else
                begin
                    if features[226] <= -147.49999999999997 then
                    begin
                        Result := -0.0030807741976105461;
                    end
                    else
                    begin
                        Result := 0.0063148765471033909;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 934.50000000000011 then
                begin
                    if features[96] <= 158816232.00000003 then
                    begin
                        Result := -0.001080816966093665;
                    end
                    else
                    begin
                        Result := -0.021714573647850913;
                    end;
                end
                else
                begin
                    if features[215] <= -5007.4999999999991 then
                    begin
                        Result := 0.0049343601737149604;
                    end
                    else
                    begin
                        Result := 0.02696176738041195;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_99(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        Result := -0.019019169736438173;
    end
    else
    begin
        if features[166] <= -28946161.999999996 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[83] <= 1.0000000180025095E-35 then
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := -0.0031342149996342467;
                    end
                    else
                    begin
                        Result := -0.01370592550846894;
                    end;
                end
                else
                begin
                    if features[224] <= -6015.4999999999991 then
                    begin
                        Result := -0.013018000710896559;
                    end
                    else
                    begin
                        Result := 0.0046380332826755329;
                    end;
                end;
            end
            else
            begin
                if features[0] <= 98309.500000000015 then
                begin
                    if features[216] <= -4373.4999999999991 then
                    begin
                        Result := -0.00031233826650416954;
                    end
                    else
                    begin
                        Result := 0.013861102708555451;
                    end;
                end
                else
                begin
                    Result := 0.022535691332776064;
                end;
            end;
        end
        else
        begin
            if features[158] <= 3732.5000000000005 then
            begin
                if features[148] <= 3037.0000000000005 then
                begin
                    if features[150] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.013333769404078051;
                    end
                    else
                    begin
                        Result := 0.0047955985577238175;
                    end;
                end
                else
                begin
                    if features[165] <= -183102015.99999997 then
                    begin
                        Result := -0.026493590265945367;
                    end
                    else
                    begin
                        Result := -0.00021178499349259005;
                    end;
                end;
            end
            else
            begin
                if features[154] <= -418.49999999999994 then
                begin
                    if features[215] <= -4649.4999999999991 then
                    begin
                        Result := 0.021143964689076006;
                    end
                    else
                    begin
                        Result := -0.022261578636443822;
                    end;
                end
                else
                begin
                    Result := -0.004041987532903411;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_100(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -890.49999999999989 then
    begin
        if features[221] <= -5665.4999999999991 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[217] <= -1139.4999999999998 then
                begin
                    Result := 0.054212898641800816;
                end
                else
                begin
                    Result := -0.018053200151436695;
                end;
            end
            else
            begin
                if features[180] <= -6820.4999999999991 then
                begin
                    Result := -0.024915794379021205;
                end
                else
                begin
                    Result := 0.038395848208489652;
                end;
            end;
        end
        else
        begin
            Result := -0.020198144279159072;
        end;
    end
    else
    begin
        if features[15] <= -274806975.99999994 then
        begin
            if features[177] <= -5052.4999999999991 then
            begin
                Result := -0.019148606538255699;
            end
            else
            begin
                if features[172] <= 6.5000000000000009 then
                begin
                    Result := 0.042896212309353962;
                end
                else
                begin
                    Result := -0.021140618053400503;
                end;
            end;
        end
        else
        begin
            if features[57] <= 1.5000000000000002 then
            begin
                if features[122] <= -374.99999999999994 then
                begin
                    if features[171] <= 3.5000000000000004 then
                    begin
                        Result := -0.018514400626161134;
                    end
                    else
                    begin
                        Result := 0.0073463934235200347;
                    end;
                end
                else
                begin
                    if features[216] <= -4389.4999999999991 then
                    begin
                        Result := 0.0006683441919427967;
                    end
                    else
                    begin
                        Result := 0.007716683635849971;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 6.5000000000000009 then
                begin
                    Result := -0.019408572691876496;
                end
                else
                begin
                    if features[175] <= 405.50000000000006 then
                    begin
                        Result := -0.0098874677848084895;
                    end
                    else
                    begin
                        Result := 0.025680096197917213;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_101(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        if features[80] <= -1.0000000180025095E-35 then
        begin
            Result := 0.058040381778241168;
        end
        else
        begin
            Result := -0.019785774758634272;
        end;
    end
    else
    begin
        if features[118] <= -1.0000000180025095E-35 then
        begin
            if features[150] <= -1.0000000180025095E-35 then
            begin
                if features[176] <= -7176.4999999999991 then
                begin
                    if features[181] <= -1518.4999999999998 then
                    begin
                        Result := 0.073413162576693988;
                    end
                    else
                    begin
                        Result := 0.017290527668156527;
                    end;
                end
                else
                begin
                    Result := 0.0063750656570508149;
                end;
            end
            else
            begin
                if features[218] <= -5796.4999999999991 then
                begin
                    if features[138] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0074045986062012091;
                    end
                    else
                    begin
                        Result := -0.01586032323766989;
                    end;
                end
                else
                begin
                    Result := -0.0035219861448714399;
                end;
            end;
        end
        else
        begin
            if features[226] <= 934.50000000000011 then
            begin
                if features[174] <= -4462.4999999999991 then
                begin
                    if features[224] <= -3931.4999999999995 then
                    begin
                        Result := -0.0034392830709396461;
                    end
                    else
                    begin
                        Result := -0.021578130466525052;
                    end;
                end
                else
                begin
                    if features[174] <= -4430.4999999999991 then
                    begin
                        Result := 0.023690444475194476;
                    end
                    else
                    begin
                        Result := -0.000227703002926991;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -5599.4999999999991 then
                begin
                    if features[77] <= 8062.5000000000009 then
                    begin
                        Result := 0.0093926380913767187;
                    end
                    else
                    begin
                        Result := -0.011493316572764768;
                    end;
                end
                else
                begin
                    Result := 0.020342139374599957;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_102(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[220] <= -16.499999999999996 then
        begin
            if features[80] <= -5939.9999999999991 then
            begin
                Result := 0.058692827199539159;
            end
            else
            begin
                Result := -0.017973965337359669;
            end;
        end
        else
        begin
            if features[69] <= 23.500000000000004 then
            begin
                if features[1] <= 196057.00000000003 then
                begin
                    Result := -0.0058808185205225265;
                end
                else
                begin
                    Result := 0.055700143261165472;
                end;
            end
            else
            begin
                Result := 0.078784014492060656;
            end;
        end;
    end
    else
    begin
        if features[175] <= -238.49999999999997 then
        begin
            if features[182] <= -4613.4999999999991 then
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[150] <= -2.4999999999999996 then
                    begin
                        Result := 0.0094992147785143335;
                    end
                    else
                    begin
                        Result := -0.001171444466227851;
                    end;
                end
                else
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.013434440949884843;
                    end
                    else
                    begin
                        Result := -0.0016665270337531469;
                    end;
                end;
            end
            else
            begin
                Result := -0.021070104221173707;
            end;
        end
        else
        begin
            if features[27] <= -2748.4999999999995 then
            begin
                if features[229] <= -670.49999999999989 then
                begin
                    Result := -0.014234057458255393;
                end
                else
                begin
                    if features[66] <= 196.00000000000003 then
                    begin
                        Result := 0.0039945234362230514;
                    end
                    else
                    begin
                        Result := -0.012175791297435026;
                    end;
                end;
            end
            else
            begin
                if features[224] <= -4497.4999999999991 then
                begin
                    Result := 0.013047682602497314;
                end
                else
                begin
                    Result := 0.041529237347366771;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_103(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        Result := -0.018845339768863927;
    end
    else
    begin
        if features[216] <= -4054.4999999999995 then
        begin
            if features[166] <= -40553171.999999993 then
            begin
                if features[2] <= 1.0000000180025095E-35 then
                begin
                    if features[185] <= 150.12500000000003 then
                    begin
                        Result := -0.007920335590829497;
                    end
                    else
                    begin
                        Result := 0.0064264393861391614;
                    end;
                end
                else
                begin
                    if features[225] <= -5995.4999999999991 then
                    begin
                        Result := -0.0096145789533609478;
                    end
                    else
                    begin
                        Result := 0.0070623451090258181;
                    end;
                end;
            end
            else
            begin
                if features[150] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0083561260063646538;
                end
                else
                begin
                    if features[107] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0055766367624667532;
                    end
                    else
                    begin
                        Result := 0.0030644138944526268;
                    end;
                end;
            end;
        end
        else
        begin
            if features[168] <= 1.5000000000000002 then
            begin
                if features[217] <= 294.50000000000006 then
                begin
                    if features[215] <= -4079.4999999999995 then
                    begin
                        Result := 0.042338589346879556;
                    end
                    else
                    begin
                        Result := 0.016945352936391541;
                    end;
                end
                else
                begin
                    if features[225] <= -5025.4999999999991 then
                    begin
                        Result := -0.0038256847313756074;
                    end
                    else
                    begin
                        Result := 0.015345238374657741;
                    end;
                end;
            end
            else
            begin
                if features[220] <= 34.500000000000007 then
                begin
                    Result := -0.018096358433053236;
                end
                else
                begin
                    if features[121] <= 1312.5000000000002 then
                    begin
                        Result := 0.0080768463268112104;
                    end
                    else
                    begin
                        Result := -0.017386355687736881;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_104(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -284066959.99999994 then
    begin
        Result := -0.01711151986154829;
    end
    else
    begin
        if features[222] <= -5368.4999999999991 then
        begin
            if features[166] <= 1.0000000180025095E-35 then
            begin
                if features[150] <= -7.4999999999999991 then
                begin
                    if features[26] <= 6.5000000000000009 then
                    begin
                        Result := 0.0065749043368592821;
                    end
                    else
                    begin
                        Result := -0.024132868718975287;
                    end;
                end
                else
                begin
                    if features[181] <= 437.50000000000006 then
                    begin
                        Result := -0.0082087353614604744;
                    end
                    else
                    begin
                        Result := 0.004406426049410792;
                    end;
                end;
            end
            else
            begin
                if features[158] <= 6535.5000000000009 then
                begin
                    if features[165] <= 116475184.00000001 then
                    begin
                        Result := 0.0044290649610284078;
                    end
                    else
                    begin
                        Result := 0.018611996087018367;
                    end;
                end
                else
                begin
                    Result := -0.0062020678353696592;
                end;
            end;
        end
        else
        begin
            if features[168] <= 1.5000000000000002 then
            begin
                if features[180] <= -7364.4999999999991 then
                begin
                    if features[221] <= -4605.4999999999991 then
                    begin
                        Result := 0.025437271792744409;
                    end
                    else
                    begin
                        Result := -0.018586521346846137;
                    end;
                end
                else
                begin
                    if features[175] <= -687.49999999999989 then
                    begin
                        Result := -0.00029997772888207106;
                    end
                    else
                    begin
                        Result := 0.010016214068821441;
                    end;
                end;
            end
            else
            begin
                if features[217] <= -230.49999999999997 then
                begin
                    Result := -0.013578626046070602;
                end
                else
                begin
                    if features[36] <= 821.50000000000011 then
                    begin
                        Result := 0.0039326204266947476;
                    end
                    else
                    begin
                        Result := -0.014062471517973216;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_105(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        if features[80] <= -5626.9999999999991 then
        begin
            Result := 0.066112652727417384;
        end
        else
        begin
            Result := -0.019397575239424158;
        end;
    end
    else
    begin
        if features[55] <= 4.5000000000000009 then
        begin
            if features[164] <= -342043167.99999994 then
            begin
                if features[150] <= -14.499999999999998 then
                begin
                    if features[67] <= 47.500000000000007 then
                    begin
                        Result := -0.0082010489929152559;
                    end
                    else
                    begin
                        Result := 0.036926340613752377;
                    end;
                end
                else
                begin
                    Result := -0.013973900913081407;
                end;
            end
            else
            begin
                if features[226] <= -890.49999999999989 then
                begin
                    if features[216] <= -6725.4999999999991 then
                    begin
                        Result := 0.0056521227173420355;
                    end
                    else
                    begin
                        Result := -0.019333431249470581;
                    end;
                end
                else
                begin
                    if features[175] <= -440.49999999999994 then
                    begin
                        Result := -0.0010074883783098003;
                    end
                    else
                    begin
                        Result := 0.0048771760445613238;
                    end;
                end;
            end;
        end
        else
        begin
            if features[77] <= 11775.000000000002 then
            begin
                if features[47] <= 3430.5000000000005 then
                begin
                    Result := -0.0051663912245448751;
                end
                else
                begin
                    if features[154] <= -551.49999999999989 then
                    begin
                        Result := 0.015862803395255629;
                    end
                    else
                    begin
                        Result := -0.021155847878072998;
                    end;
                end;
            end
            else
            begin
                if features[109] <= -152.49999999999997 then
                begin
                    Result := -0.019580127779970268;
                end
                else
                begin
                    if features[178] <= -285.49999999999994 then
                    begin
                        Result := 0.040943672285790267;
                    end
                    else
                    begin
                        Result := 0.00080057048109147006;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_106(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -309517551.99999994 then
    begin
        if features[80] <= -1.0000000180025095E-35 then
        begin
            Result := 0.063213260403290228;
        end
        else
        begin
            if features[70] <= 401.00000000000006 then
            begin
                Result := 0.040943666599220691;
            end
            else
            begin
                Result := -0.020598403064311099;
            end;
        end;
    end
    else
    begin
        if features[164] <= -363563103.99999994 then
        begin
            if features[219] <= -4751.4999999999991 then
            begin
                if features[28] <= -8178.4999999999991 then
                begin
                    if features[167] <= 2.5000000000000004 then
                    begin
                        Result := -0.012861720202544141;
                    end
                    else
                    begin
                        Result := 0.011814029899810537;
                    end;
                end
                else
                begin
                    Result := -0.017317245628690338;
                end;
            end
            else
            begin
                Result := 0.018342034778570888;
            end;
        end
        else
        begin
            if features[48] <= 9431.5000000000018 then
            begin
                if features[141] <= -1.4999999999999998 then
                begin
                    if features[95] <= -47580851.999999993 then
                    begin
                        Result := -0.014606418185196139;
                    end
                    else
                    begin
                        Result := 0.012752767987274852;
                    end;
                end
                else
                begin
                    if features[135] <= 1.5000000000000002 then
                    begin
                        Result := -0.0021798417328079381;
                    end
                    else
                    begin
                        Result := 0.0064554510212978802;
                    end;
                end;
            end
            else
            begin
                if features[173] <= -6698.4999999999991 then
                begin
                    if features[151] <= -26.499999999999996 then
                    begin
                        Result := 0.034272690278379196;
                    end
                    else
                    begin
                        Result := 0.012539569824328953;
                    end;
                end
                else
                begin
                    if features[228] <= -6464.4999999999991 then
                    begin
                        Result := -0.028676667510347899;
                    end
                    else
                    begin
                        Result := 0.0051236098782108603;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_107(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -309517551.99999994 then
    begin
        if features[80] <= -1.0000000180025095E-35 then
        begin
            Result := 0.070337653232401889;
        end
        else
        begin
            Result := -0.019677790049234551;
        end;
    end
    else
    begin
        if features[118] <= -1.0000000180025095E-35 then
        begin
            if features[155] <= 1.0000000180025095E-35 then
            begin
                if features[218] <= -5745.4999999999991 then
                begin
                    if features[65] <= 1459.5000000000002 then
                    begin
                        Result := 0.011281869193938327;
                    end
                    else
                    begin
                        Result := -0.017628523262664713;
                    end;
                end
                else
                begin
                    if features[175] <= -687.49999999999989 then
                    begin
                        Result := -0.0062561728459431991;
                    end
                    else
                    begin
                        Result := 0.0053466378004409995;
                    end;
                end;
            end
            else
            begin
                if features[25] <= 1.5000000000000002 then
                begin
                    if features[47] <= 3895.5000000000005 then
                    begin
                        Result := 0.014829951036754208;
                    end
                    else
                    begin
                        Result := -0.0044826065776836675;
                    end;
                end
                else
                begin
                    Result := -0.011042612828476708;
                end;
            end;
        end
        else
        begin
            if features[226] <= 971.50000000000011 then
            begin
                if features[96] <= 158816232.00000003 then
                begin
                    if features[71] <= 1.5000000000000002 then
                    begin
                        Result := -0.0075322698794567785;
                    end
                    else
                    begin
                        Result := 2.3835905105982314E-05;
                    end;
                end
                else
                begin
                    Result := -0.021937904661678838;
                end;
            end
            else
            begin
                if features[40] <= 1333.5000000000002 then
                begin
                    if features[228] <= -4447.4999999999991 then
                    begin
                        Result := 0.0062260001723732196;
                    end
                    else
                    begin
                        Result := 0.020756374010371195;
                    end;
                end
                else
                begin
                    Result := -0.0063857381033595815;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_108(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -226073471.99999997 then
    begin
        if features[216] <= -4044.4999999999995 then
        begin
            if features[13] <= 248843.50000000003 then
            begin
                if features[110] <= 586.50000000000011 then
                begin
                    if features[47] <= 25203.000000000004 then
                    begin
                        Result := -0.018734307721079285;
                    end
                    else
                    begin
                        Result := 0.0052838926668533305;
                    end;
                end
                else
                begin
                    Result := 0.053191112751655625;
                end;
            end
            else
            begin
                Result := 0.055841773526882993;
            end;
        end
        else
        begin
            if features[216] <= -3965.4999999999995 then
            begin
                if features[110] <= -582.49999999999989 then
                begin
                    Result := -0.00064232320021927755;
                end
                else
                begin
                    Result := 0.10560697221371507;
                end;
            end
            else
            begin
                Result := -0.0049839883458996795;
            end;
        end;
    end
    else
    begin
        if features[57] <= 1.5000000000000002 then
        begin
            if features[9] <= 11.500000000000002 then
            begin
                if features[118] <= -1.0000000180025095E-35 then
                begin
                    if features[106] <= 1.5000000000000002 then
                    begin
                        Result := 0.0064194511522491504;
                    end
                    else
                    begin
                        Result := -0.0053072697259379268;
                    end;
                end
                else
                begin
                    if features[172] <= 4.5000000000000009 then
                    begin
                        Result := 0.00086771996711644528;
                    end
                    else
                    begin
                        Result := -0.0063942912497619853;
                    end;
                end;
            end
            else
            begin
                if features[178] <= -924.49999999999989 then
                begin
                    Result := -0.015919235030690284;
                end
                else
                begin
                    if features[179] <= -7821.4999999999991 then
                    begin
                        Result := -0.017000472430754972;
                    end
                    else
                    begin
                        Result := 0.028323675085818081;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.013955152076842446;
        end;
    end;
end;

function second_slot_bidirectional_tree_109(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -309517551.99999994 then
    begin
        if features[216] <= -7225.4999999999991 then
        begin
            if features[219] <= -6557.4999999999991 then
            begin
                Result := -0.011497115245083855;
            end
            else
            begin
                Result := 0.10008762313223162;
            end;
        end
        else
        begin
            Result := -0.021916048109948058;
        end;
    end
    else
    begin
        if features[122] <= -1303.4999999999998 then
        begin
            if features[171] <= 3.5000000000000004 then
            begin
                Result := -0.020212971237186707;
            end
            else
            begin
                if features[164] <= 223737832.00000003 then
                begin
                    if features[150] <= 25.500000000000004 then
                    begin
                        Result := -0.017417423626342125;
                    end
                    else
                    begin
                        Result := 0.028030381782214116;
                    end;
                end
                else
                begin
                    Result := 0.022296357667244044;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4054.4999999999995 then
            begin
                if features[218] <= -5036.4999999999991 then
                begin
                    if features[129] <= 10443.500000000002 then
                    begin
                        Result := 0.00018152590473239405;
                    end
                    else
                    begin
                        Result := 0.0096002980310617835;
                    end;
                end
                else
                begin
                    if features[227] <= -4108.4999999999991 then
                    begin
                        Result := -0.0034013519733062125;
                    end
                    else
                    begin
                        Result := -0.016123228300304712;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.030491891401866825;
                    end
                    else
                    begin
                        Result := 0.003543844871731071;
                    end;
                end
                else
                begin
                    if features[229] <= -32.499999999999993 then
                    begin
                        Result := -0.012629832751994237;
                    end
                    else
                    begin
                        Result := 0.0078730513339179738;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_110(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -309517551.99999994 then
    begin
        if features[80] <= -1.0000000180025095E-35 then
        begin
            Result := 0.061134864919944021;
        end
        else
        begin
            Result := -0.021110486219098161;
        end;
    end
    else
    begin
        if features[226] <= 495.50000000000006 then
        begin
            if features[96] <= 158816232.00000003 then
            begin
                if features[229] <= -976.49999999999989 then
                begin
                    if features[227] <= -5449.4999999999991 then
                    begin
                        Result := 0.014075057302437599;
                    end
                    else
                    begin
                        Result := -0.023694942347928551;
                    end;
                end
                else
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0017277163722876838;
                    end
                    else
                    begin
                        Result := -0.0043048839162342263;
                    end;
                end;
            end
            else
            begin
                Result := -0.019609118206242698;
            end;
        end
        else
        begin
            if features[155] <= -1.0000000180025095E-35 then
            begin
                if features[77] <= 7062.5000000000009 then
                begin
                    if features[42] <= 471.50000000000006 then
                    begin
                        Result := 0.024546212805307461;
                    end
                    else
                    begin
                        Result := 0.0084565496440238037;
                    end;
                end
                else
                begin
                    if features[215] <= -5138.4999999999991 then
                    begin
                        Result := -0.001126952888749644;
                    end
                    else
                    begin
                        Result := 0.021778730483348406;
                    end;
                end;
            end
            else
            begin
                if features[158] <= 3937.5000000000005 then
                begin
                    if features[36] <= 814.50000000000011 then
                    begin
                        Result := 0.0074924080268851502;
                    end
                    else
                    begin
                        Result := -0.0078512696630610602;
                    end;
                end
                else
                begin
                    if features[27] <= -5633.4999999999991 then
                    begin
                        Result := 0.011164885245830392;
                    end
                    else
                    begin
                        Result := -0.0087502194766950845;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_111(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[223] <= -730.49999999999989 then
    begin
        if features[219] <= -6999.4999999999991 then
        begin
            if features[13] <= 73698.000000000015 then
            begin
                if features[186] <= 130.58333587646487 then
                begin
                    Result := -0.0087025143810115901;
                end
                else
                begin
                    Result := 0.045577861749899501;
                end;
            end
            else
            begin
                Result := 0.035439922212623251;
            end;
        end
        else
        begin
            if features[108] <= -221.49999999999997 then
            begin
                Result := -0.020675272435935064;
            end
            else
            begin
                if features[186] <= -241.87499999999997 then
                begin
                    Result := 0.08070210004388749;
                end
                else
                begin
                    Result := -0.0048316970405220374;
                end;
            end;
        end;
    end
    else
    begin
        if features[15] <= -274806975.99999994 then
        begin
            Result := -0.015154645594213556;
        end
        else
        begin
            if features[73] <= 114.50000000000001 then
            begin
                if features[47] <= 4475.5000000000009 then
                begin
                    if features[55] <= 3.5000000000000004 then
                    begin
                        Result := 0.0041992858278352557;
                    end
                    else
                    begin
                        Result := -0.0038928913988379391;
                    end;
                end
                else
                begin
                    if features[161] <= -67.499999999999986 then
                    begin
                        Result := 0.014193882536926359;
                    end
                    else
                    begin
                        Result := -0.0087266725288901829;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -4978.4999999999991 then
                begin
                    if features[166] <= -2782540.9999999995 then
                    begin
                        Result := -0.0022959069246111788;
                    end
                    else
                    begin
                        Result := 0.0072782153902610615;
                    end;
                end
                else
                begin
                    if features[183] <= -7134.4999999999991 then
                    begin
                        Result := 0.033065245892897679;
                    end
                    else
                    begin
                        Result := 0.0081095407226086467;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_112(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1206.4999999999998 then
    begin
        Result := -0.022072589590150998;
    end
    else
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[150] <= -2.4999999999999996 then
            begin
                if features[185] <= -528.87499999999989 then
                begin
                    if features[178] <= -1241.4999999999998 then
                    begin
                        Result := 0.0030381916599090306;
                    end
                    else
                    begin
                        Result := 0.039327290201320968;
                    end;
                end
                else
                begin
                    if features[158] <= -16937.499999999996 then
                    begin
                        Result := 0.03115777287880684;
                    end
                    else
                    begin
                        Result := 0.0047497596147571507;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -4102.4999999999991 then
                begin
                    if features[42] <= 449.00000000000006 then
                    begin
                        Result := 0.0013631641331533198;
                    end
                    else
                    begin
                        Result := -0.0078248678958407428;
                    end;
                end
                else
                begin
                    if features[40] <= 1066.5000000000002 then
                    begin
                        Result := 0.013451615192525565;
                    end
                    else
                    begin
                        Result := -0.0021602635404588408;
                    end;
                end;
            end;
        end
        else
        begin
            if features[141] <= -2.4999999999999996 then
            begin
                if features[95] <= -46077839.999999993 then
                begin
                    Result := -0.026531311246245137;
                end
                else
                begin
                    if features[117] <= -77.499999999999986 then
                    begin
                        Result := -0.00052846676818291789;
                    end
                    else
                    begin
                        Result := 0.025035142543611572;
                    end;
                end;
            end
            else
            begin
                if features[181] <= -475.49999999999994 then
                begin
                    Result := -0.017615058895910255;
                end
                else
                begin
                    if features[177] <= -6095.4999999999991 then
                    begin
                        Result := -0.0084719983365571343;
                    end
                    else
                    begin
                        Result := 0.0054902646725809787;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_113(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -692.49999999999989 then
    begin
        if features[37] <= 1.5000000000000002 then
        begin
            Result := 0.050362468216067081;
        end
        else
        begin
            if features[164] <= 488074368.00000006 then
            begin
                if features[216] <= -7461.4999999999991 then
                begin
                    if features[170] <= 5.5000000000000009 then
                    begin
                        Result := -0.0089139938182517097;
                    end
                    else
                    begin
                        Result := 0.034726652977667881;
                    end;
                end
                else
                begin
                    if features[37] <= 2.5000000000000004 then
                    begin
                        Result := 0.0036615798448016456;
                    end
                    else
                    begin
                        Result := -0.020639208496231715;
                    end;
                end;
            end
            else
            begin
                Result := 0.035834261375917796;
            end;
        end;
    end
    else
    begin
        if features[15] <= -336406943.99999994 then
        begin
            Result := -0.020320455264119283;
        end
        else
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[71] <= 2.5000000000000004 then
                begin
                    if features[47] <= 4203.5000000000009 then
                    begin
                        Result := 0.0025716194868328664;
                    end
                    else
                    begin
                        Result := -0.0069995105382589353;
                    end;
                end
                else
                begin
                    if features[106] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0070875349997621163;
                    end
                    else
                    begin
                        Result := -0.0014892321593278661;
                    end;
                end;
            end
            else
            begin
                if features[164] <= -2571554.4999999995 then
                begin
                    if features[229] <= -100.49999999999999 then
                    begin
                        Result := -0.01839266908244663;
                    end
                    else
                    begin
                        Result := -0.0051470910753738204;
                    end;
                end
                else
                begin
                    if features[139] <= -3.4999999999999996 then
                    begin
                        Result := 0.020907318905366571;
                    end
                    else
                    begin
                        Result := -0.001708205947158023;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_114(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -890.49999999999989 then
    begin
        if features[216] <= -7105.4999999999991 then
        begin
            if features[226] <= -1231.4999999999998 then
            begin
                Result := -0.014127636943011466;
            end
            else
            begin
                if features[181] <= -1919.4999999999998 then
                begin
                    if features[218] <= -5836.4999999999991 then
                    begin
                        Result := -0.011171648574706945;
                    end
                    else
                    begin
                        Result := 0.12618141999227833;
                    end;
                end
                else
                begin
                    if features[175] <= -283.49999999999994 then
                    begin
                        Result := -0.016719239335976587;
                    end
                    else
                    begin
                        Result := 0.046849290346257559;
                    end;
                end;
            end;
        end
        else
        begin
            if features[219] <= -3426.9999999999995 then
            begin
                Result := -0.020113629593958203;
            end
            else
            begin
                Result := 0.05415833076059974;
            end;
        end;
    end
    else
    begin
        if features[15] <= -336406943.99999994 then
        begin
            Result := -0.021260751956381489;
        end
        else
        begin
            if features[122] <= -1102.9999999999998 then
            begin
                if features[171] <= 3.5000000000000004 then
                begin
                    Result := -0.01703680550335852;
                end
                else
                begin
                    if features[165] <= 285360832.00000006 then
                    begin
                        Result := -0.0095101839009084973;
                    end
                    else
                    begin
                        Result := 0.036212682936791474;
                    end;
                end;
            end
            else
            begin
                if features[222] <= -5368.4999999999991 then
                begin
                    if features[186] <= 79.099998474121108 then
                    begin
                        Result := -0.0037247027254387697;
                    end
                    else
                    begin
                        Result := 0.0044110909830559885;
                    end;
                end
                else
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.0082716746028702257;
                    end
                    else
                    begin
                        Result := -0.00052352376608642175;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_115(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.020975372937973816;
    end
    else
    begin
        if features[118] <= -1.0000000180025095E-35 then
        begin
            if features[172] <= 2.5000000000000004 then
            begin
                if features[65] <= 1751.5000000000002 then
                begin
                    if features[73] <= 330.50000000000006 then
                    begin
                        Result := 0.012283233862163066;
                    end
                    else
                    begin
                        Result := -0.0024827008321331731;
                    end;
                end
                else
                begin
                    Result := -0.020600335914419492;
                end;
            end
            else
            begin
                if features[181] <= -648.49999999999989 then
                begin
                    Result := -0.011051627200824289;
                end
                else
                begin
                    if features[106] <= 1.5000000000000002 then
                    begin
                        Result := 0.0049805131985916681;
                    end
                    else
                    begin
                        Result := -0.0076742786298331315;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 934.50000000000011 then
            begin
                if features[69] <= 3.5000000000000004 then
                begin
                    if features[139] <= -3.4999999999999996 then
                    begin
                        Result := 0.010210460909145201;
                    end
                    else
                    begin
                        Result := -0.007774585594669892;
                    end;
                end
                else
                begin
                    if features[122] <= -1285.4999999999998 then
                    begin
                        Result := -0.017944153421043843;
                    end
                    else
                    begin
                        Result := 0.0010304800550159632;
                    end;
                end;
            end
            else
            begin
                if features[45] <= 2.5000000000000004 then
                begin
                    if features[107] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.020152345123673865;
                    end
                    else
                    begin
                        Result := 0.0049318843996513798;
                    end;
                end
                else
                begin
                    if features[215] <= -5599.4999999999991 then
                    begin
                        Result := 0.0073341719327058982;
                    end
                    else
                    begin
                        Result := 0.025814543232808951;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_116(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        if features[216] <= -8210.4999999999982 then
        begin
            if features[186] <= -180.55000305175778 then
            begin
                Result := -0.018839578336602884;
            end
            else
            begin
                Result := 0.041704645890744164;
            end;
        end
        else
        begin
            Result := -0.023989361738712515;
        end;
    end
    else
    begin
        if features[175] <= -440.49999999999994 then
        begin
            if features[150] <= -32.499999999999993 then
            begin
                if features[4] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.072454558995069876;
                end
                else
                begin
                    Result := 0.0099822351211829429;
                end;
            end
            else
            begin
                if features[182] <= -4940.4999999999991 then
                begin
                    if features[222] <= -4654.4999999999991 then
                    begin
                        Result := -0.004300997759667185;
                    end
                    else
                    begin
                        Result := 0.0063634299327141493;
                    end;
                end
                else
                begin
                    Result := -0.015596256076231888;
                end;
            end;
        end
        else
        begin
            if features[27] <= -2884.4999999999995 then
            begin
                if features[55] <= 3.5000000000000004 then
                begin
                    if features[26] <= 6.5000000000000009 then
                    begin
                        Result := 0.0035568449891517011;
                    end
                    else
                    begin
                        Result := -0.01012479389149556;
                    end;
                end
                else
                begin
                    if features[9] <= 3.5000000000000004 then
                    begin
                        Result := -0.0065605925422077896;
                    end
                    else
                    begin
                        Result := 0.0076781072640957557;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 418.50000000000006 then
                begin
                    Result := 0.035124889662962323;
                end
                else
                begin
                    if features[224] <= -4324.4999999999991 then
                    begin
                        Result := -0.006149685443624868;
                    end
                    else
                    begin
                        Result := 0.030529955328693428;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_117(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -309517551.99999994 then
    begin
        if features[80] <= -1.0000000180025095E-35 then
        begin
            Result := 0.06062243017270405;
        end
        else
        begin
            if features[216] <= -7163.4999999999991 then
            begin
                if features[173] <= -5748.4999999999991 then
                begin
                    Result := -0.019677039591916273;
                end
                else
                begin
                    if features[223] <= -1264.4999999999998 then
                    begin
                        Result := -0.013640925596690319;
                    end
                    else
                    begin
                        Result := 0.11103540025291299;
                    end;
                end;
            end
            else
            begin
                Result := -0.021913855490588715;
            end;
        end;
    end
    else
    begin
        if features[173] <= -3910.9999999999995 then
        begin
            if features[216] <= -4044.4999999999995 then
            begin
                if features[224] <= -3931.4999999999995 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0038886693076787444;
                    end
                    else
                    begin
                        Result := -0.0014822705040492641;
                    end;
                end
                else
                begin
                    Result := -0.016223513340836951;
                end;
            end
            else
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[216] <= -3965.4999999999995 then
                    begin
                        Result := 0.027429010175708087;
                    end
                    else
                    begin
                        Result := 0.0080405952734730543;
                    end;
                end
                else
                begin
                    if features[40] <= 1129.5000000000002 then
                    begin
                        Result := 0.0053438126016775228;
                    end
                    else
                    begin
                        Result := -0.011575920023479106;
                    end;
                end;
            end;
        end
        else
        begin
            if features[166] <= 47674426.000000007 then
            begin
                if features[219] <= -6941.4999999999991 then
                begin
                    Result := 0.013130412673005687;
                end
                else
                begin
                    Result := -0.0184039382911227;
                end;
            end
            else
            begin
                Result := 0.0083552031610851091;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_118(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -877.49999999999989 then
    begin
        if features[216] <= -6725.4999999999991 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[221] <= -5655.4999999999991 then
                begin
                    if features[69] <= 5.5000000000000009 then
                    begin
                        Result := 0.066691292610692982;
                    end
                    else
                    begin
                        Result := -0.01526195002704909;
                    end;
                end
                else
                begin
                    Result := -0.0068615385962682131;
                end;
            end
            else
            begin
                Result := -0.011956764299364587;
            end;
        end
        else
        begin
            if features[219] <= -3426.9999999999995 then
            begin
                Result := -0.019870574285223597;
            end
            else
            begin
                Result := 0.051197171149473433;
            end;
        end;
    end
    else
    begin
        if features[164] <= -368292223.99999994 then
        begin
            if features[69] <= 2.5000000000000004 then
            begin
                Result := -0.018164495116565666;
            end
            else
            begin
                Result := -0.0042591678673643864;
            end;
        end
        else
        begin
            if features[219] <= -7019.4999999999991 then
            begin
                if features[180] <= -8242.4999999999982 then
                begin
                    if features[39] <= 1537.5000000000002 then
                    begin
                        Result := 0.041435646031838455;
                    end
                    else
                    begin
                        Result := -0.0028620974556574003;
                    end;
                end
                else
                begin
                    if features[177] <= -8196.4999999999982 then
                    begin
                        Result := -0.0079344552634469448;
                    end
                    else
                    begin
                        Result := 0.016650406656025397;
                    end;
                end;
            end
            else
            begin
                if features[173] <= -3910.9999999999995 then
                begin
                    if features[216] <= -4054.4999999999995 then
                    begin
                        Result := -1.8680717371714204E-05;
                    end
                    else
                    begin
                        Result := 0.0084685297860114649;
                    end;
                end
                else
                begin
                    Result := -0.013168377945890097;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_119(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -877.49999999999989 then
    begin
        if features[221] <= -5695.4999999999991 then
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[217] <= -2142.4999999999995 then
                begin
                    Result := -0.017947328429329709;
                end
                else
                begin
                    if features[217] <= -1118.4999999999998 then
                    begin
                        Result := 0.07219726408971347;
                    end
                    else
                    begin
                        Result := -0.016234436541336921;
                    end;
                end;
            end
            else
            begin
                if features[164] <= 160521008.00000003 then
                begin
                    Result := -0.020547398358016111;
                end
                else
                begin
                    Result := 0.042574994784053605;
                end;
            end;
        end
        else
        begin
            if features[219] <= -3426.9999999999995 then
            begin
                Result := -0.019257482075599852;
            end
            else
            begin
                Result := 0.049518639002364438;
            end;
        end;
    end
    else
    begin
        if features[15] <= -336406943.99999994 then
        begin
            Result := -0.019193506775621653;
        end
        else
        begin
            if features[96] <= 182914768.00000003 then
            begin
                if features[173] <= -3910.9999999999995 then
                begin
                    if features[225] <= -3489.4999999999995 then
                    begin
                        Result := 0.0012767836498391468;
                    end
                    else
                    begin
                        Result := 0.017944948935918904;
                    end;
                end
                else
                begin
                    if features[219] <= -7299.4999999999991 then
                    begin
                        Result := 0.038576048790680842;
                    end
                    else
                    begin
                        Result := -0.013586587174373124;
                    end;
                end;
            end
            else
            begin
                if features[166] <= 91686248.000000015 then
                begin
                    Result := -0.026424287963638705;
                end
                else
                begin
                    if features[148] <= 2506.5000000000005 then
                    begin
                        Result := 0.0039750700473755165;
                    end
                    else
                    begin
                        Result := -0.031289463529572556;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_120(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.021812348768135561;
    end
    else
    begin
        if features[26] <= 8.5000000000000018 then
        begin
            if features[55] <= 4.5000000000000009 then
            begin
                if features[66] <= 108.50000000000001 then
                begin
                    if features[226] <= 814.50000000000011 then
                    begin
                        Result := 0.0012601879723501675;
                    end
                    else
                    begin
                        Result := 0.008316104798468579;
                    end;
                end
                else
                begin
                    if features[108] <= 399.50000000000006 then
                    begin
                        Result := -0.017770181648401214;
                    end
                    else
                    begin
                        Result := -0.0012048831620422884;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 36937.500000000007 then
                begin
                    if features[109] <= -184.49999999999997 then
                    begin
                        Result := -0.019460650767833269;
                    end
                    else
                    begin
                        Result := -0.0048111068230064415;
                    end;
                end
                else
                begin
                    Result := 0.017405649275092472;
                end;
            end;
        end
        else
        begin
            if features[67] <= 2620.5000000000005 then
            begin
                if features[157] <= -9.4999999999999982 then
                begin
                    if features[146] <= -304.49999999999994 then
                    begin
                        Result := -0.02080006460314068;
                    end
                    else
                    begin
                        Result := 0.04425077121187837;
                    end;
                end
                else
                begin
                    if features[14] <= -223703351.99999997 then
                    begin
                        Result := 0.013914213129900819;
                    end
                    else
                    begin
                        Result := -0.022019104376341761;
                    end;
                end;
            end
            else
            begin
                if features[74] <= 8.5000000000000018 then
                begin
                    Result := 0.040259057983437367;
                end
                else
                begin
                    if features[94] <= -17014.499999999996 then
                    begin
                        Result := -0.028018218321628485;
                    end
                    else
                    begin
                        Result := 0.014945426208782284;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_121(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -976.49999999999989 then
    begin
        if features[227] <= -5449.4999999999991 then
        begin
            if features[47] <= 20667.500000000004 then
            begin
                if features[218] <= -6776.4999999999991 then
                begin
                    Result := 0.030300463623338981;
                end
                else
                begin
                    Result := -0.016675517926673388;
                end;
            end
            else
            begin
                Result := 0.065161575699476434;
            end;
        end
        else
        begin
            if features[69] <= 30.500000000000004 then
            begin
                Result := -0.02338784396435389;
            end
            else
            begin
                Result := 0.026826265753253326;
            end;
        end;
    end
    else
    begin
        if features[15] <= -336406943.99999994 then
        begin
            if features[177] <= -4836.4999999999991 then
            begin
                Result := -0.022779020735824523;
            end
            else
            begin
                Result := 0.018428945614854822;
            end;
        end
        else
        begin
            if features[66] <= 108.50000000000001 then
            begin
                if features[24] <= 1.5000000000000002 then
                begin
                    if features[47] <= 50996.500000000007 then
                    begin
                        Result := -0.01062289275289733;
                    end
                    else
                    begin
                        Result := 0.042176827204104567;
                    end;
                end
                else
                begin
                    if features[150] <= -1.4999999999999998 then
                    begin
                        Result := 0.0064072880781640158;
                    end
                    else
                    begin
                        Result := 4.7876048642481136E-05;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -4727.4999999999991 then
                begin
                    if features[223] <= 326.50000000000006 then
                    begin
                        Result := -0.026399511099319119;
                    end
                    else
                    begin
                        Result := -0.0097335196675256298;
                    end;
                end
                else
                begin
                    if features[183] <= -6985.4999999999991 then
                    begin
                        Result := -0.024397266167056838;
                    end
                    else
                    begin
                        Result := 0.017440937574078864;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_122(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.021735735450413431;
    end
    else
    begin
        if features[226] <= -12.499999999999998 then
        begin
            if features[37] <= 7.5000000000000009 then
            begin
                if features[164] <= -272901487.99999994 then
                begin
                    if features[180] <= -9693.9999999999982 then
                    begin
                        Result := 0.04988005776538431;
                    end
                    else
                    begin
                        Result := -0.013589240594671443;
                    end;
                end
                else
                begin
                    if features[217] <= 280.50000000000006 then
                    begin
                        Result := 0.0022937869232366221;
                    end
                    else
                    begin
                        Result := -0.0075499669998425091;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -419.49999999999994 then
                begin
                    Result := -0.023319158480840239;
                end
                else
                begin
                    Result := -0.008720572909898399;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                if features[175] <= 270.50000000000006 then
                begin
                    if features[170] <= 7.5000000000000009 then
                    begin
                        Result := -0.0079417790079064632;
                    end
                    else
                    begin
                        Result := 0.0058951847387638074;
                    end;
                end
                else
                begin
                    if features[151] <= -57.499999999999993 then
                    begin
                        Result := 0.011432612864461393;
                    end
                    else
                    begin
                        Result := -0.001962290305259178;
                    end;
                end;
            end
            else
            begin
                if features[170] <= 3.5000000000000004 then
                begin
                    if features[222] <= -5358.4999999999991 then
                    begin
                        Result := -0.0025951633998430191;
                    end
                    else
                    begin
                        Result := 0.0066072763995175298;
                    end;
                end
                else
                begin
                    if features[180] <= -5577.4999999999991 then
                    begin
                        Result := 0.013280272138749724;
                    end
                    else
                    begin
                        Result := -0.005793544846481806;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_123(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        if features[216] <= -8210.4999999999982 then
        begin
            Result := 0.014282223723349136;
        end
        else
        begin
            Result := -0.023640539185706522;
        end;
    end
    else
    begin
        if features[164] <= -368292223.99999994 then
        begin
            if features[69] <= 2.5000000000000004 then
            begin
                if features[177] <= -6078.4999999999991 then
                begin
                    Result := -0.020365546750117852;
                end
                else
                begin
                    Result := 0.017676856343562912;
                end;
            end
            else
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[76] <= 2.5000000000000004 then
                    begin
                        Result := -0.017640462423169478;
                    end
                    else
                    begin
                        Result := 0.0076726053453792867;
                    end;
                end
                else
                begin
                    Result := -0.022133399044231117;
                end;
            end;
        end
        else
        begin
            if features[173] <= -3910.9999999999995 then
            begin
                if features[168] <= 1.5000000000000002 then
                begin
                    if features[216] <= -4044.4999999999995 then
                    begin
                        Result := 0.0019342225305464611;
                    end
                    else
                    begin
                        Result := 0.013990776896362692;
                    end;
                end
                else
                begin
                    if features[36] <= 663.50000000000011 then
                    begin
                        Result := 0.00049203492208802044;
                    end
                    else
                    begin
                        Result := -0.0096343906500591815;
                    end;
                end;
            end
            else
            begin
                if features[166] <= 52018590.000000007 then
                begin
                    if features[219] <= -7061.4999999999991 then
                    begin
                        Result := 0.015858377864646514;
                    end
                    else
                    begin
                        Result := -0.016554892035438546;
                    end;
                end
                else
                begin
                    if features[215] <= -4935.4999999999991 then
                    begin
                        Result := 0.035964271300472105;
                    end
                    else
                    begin
                        Result := -0.0059876557407699321;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_124(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        if features[80] <= -1.0000000180025095E-35 then
        begin
            Result := 0.052589941080673941;
        end
        else
        begin
            Result := -0.017436302042145024;
        end;
    end
    else
    begin
        if features[122] <= -1102.9999999999998 then
        begin
            if features[171] <= 3.5000000000000004 then
            begin
                if features[186] <= 266.12500000000006 then
                begin
                    Result := -0.019541828986663786;
                end
                else
                begin
                    Result := 0.0044868411657915984;
                end;
            end
            else
            begin
                if features[165] <= 281574016.00000006 then
                begin
                    if features[223] <= 93.500000000000014 then
                    begin
                        Result := -0.02215213396785512;
                    end
                    else
                    begin
                        Result := 0.0081690756441533639;
                    end;
                end
                else
                begin
                    Result := 0.027279889652782243;
                end;
            end;
        end
        else
        begin
            if features[57] <= 1.5000000000000002 then
            begin
                if features[15] <= -336406943.99999994 then
                begin
                    if features[174] <= -4993.4999999999991 then
                    begin
                        Result := -0.026544817768128361;
                    end
                    else
                    begin
                        Result := 0.0066667342854461941;
                    end;
                end
                else
                begin
                    if features[105] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0039807676818758601;
                    end
                    else
                    begin
                        Result := -0.0010544624167068549;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 5.5000000000000009 then
                begin
                    if features[225] <= -3992.4999999999995 then
                    begin
                        Result := -0.022607977361831164;
                    end
                    else
                    begin
                        Result := 0.021194565913063207;
                    end;
                end
                else
                begin
                    if features[175] <= 405.50000000000006 then
                    begin
                        Result := -0.011786728047411536;
                    end
                    else
                    begin
                        Result := 0.017560750973159327;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_125(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        if features[13] <= 269780.50000000006 then
        begin
            Result := -0.021393037744418419;
        end
        else
        begin
            Result := 0.027586476800854368;
        end;
    end
    else
    begin
        if features[135] <= 1.5000000000000002 then
        begin
            if features[122] <= -374.99999999999994 then
            begin
                if features[171] <= 3.5000000000000004 then
                begin
                    if features[176] <= -7302.4999999999991 then
                    begin
                        Result := 0.0015141297130348288;
                    end
                    else
                    begin
                        Result := -0.023468252722763549;
                    end;
                end
                else
                begin
                    if features[223] <= 93.500000000000014 then
                    begin
                        Result := -0.014932142954015496;
                    end
                    else
                    begin
                        Result := 0.017894934593208619;
                    end;
                end;
            end
            else
            begin
                if features[60] <= -1.0000000180025095E-35 then
                begin
                    if features[55] <= 4.5000000000000009 then
                    begin
                        Result := 0.0017559592464333317;
                    end
                    else
                    begin
                        Result := -0.0068859505852527543;
                    end;
                end
                else
                begin
                    if features[69] <= 6.5000000000000009 then
                    begin
                        Result := -0.01736288324843693;
                    end
                    else
                    begin
                        Result := 0.006539841953378739;
                    end;
                end;
            end;
        end
        else
        begin
            if features[150] <= 5.5000000000000009 then
            begin
                if features[219] <= -6713.4999999999991 then
                begin
                    if features[221] <= -6157.4999999999991 then
                    begin
                        Result := 0.0022702431600568978;
                    end
                    else
                    begin
                        Result := 0.029008318793323148;
                    end;
                end
                else
                begin
                    if features[219] <= -6053.4999999999991 then
                    begin
                        Result := -0.0060975899975206005;
                    end
                    else
                    begin
                        Result := 0.0075141092728959226;
                    end;
                end;
            end
            else
            begin
                Result := 0.044011508923934267;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_126(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1162.4999999999998 then
    begin
        if features[227] <= -5449.4999999999991 then
        begin
            Result := 0.0040783496163351377;
        end
        else
        begin
            Result := -0.021532804835032032;
        end;
    end
    else
    begin
        if features[96] <= 179340080.00000003 then
        begin
            if features[15] <= -336406943.99999994 then
            begin
                if features[129] <= 729.50000000000011 then
                begin
                    Result := -0.02389319175721677;
                end
                else
                begin
                    if features[174] <= -4993.4999999999991 then
                    begin
                        Result := -0.015250005611175893;
                    end
                    else
                    begin
                        Result := 0.044635153772173121;
                    end;
                end;
            end
            else
            begin
                if features[107] <= -1.4999999999999998 then
                begin
                    if features[218] <= -5928.4999999999991 then
                    begin
                        Result := 0.00016218044833071473;
                    end
                    else
                    begin
                        Result := -0.010094825561543038;
                    end;
                end
                else
                begin
                    if features[71] <= 1.5000000000000002 then
                    begin
                        Result := -0.0030828690558221961;
                    end
                    else
                    begin
                        Result := 0.0035950179233266832;
                    end;
                end;
            end;
        end
        else
        begin
            if features[108] <= 748.50000000000011 then
            begin
                if features[83] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.024757799424608137;
                end
                else
                begin
                    if features[226] <= 161.50000000000003 then
                    begin
                        Result := -0.025033530258397069;
                    end
                    else
                    begin
                        Result := 0.022836180112535291;
                    end;
                end;
            end
            else
            begin
                if features[95] <= 252107424.00000003 then
                begin
                    if features[42] <= 322.50000000000006 then
                    begin
                        Result := 0.033819849007342424;
                    end
                    else
                    begin
                        Result := -0.0069945225875480193;
                    end;
                end
                else
                begin
                    Result := -0.019293180705226252;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_127(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        if features[215] <= -6817.4999999999991 then
        begin
            Result := 0.017845080458911668;
        end
        else
        begin
            Result := -0.022829362139582008;
        end;
    end
    else
    begin
        if features[15] <= -336406943.99999994 then
        begin
            if features[28] <= -4895.4999999999991 then
            begin
                if features[120] <= -1429.9999999999998 then
                begin
                    if features[42] <= 155.00000000000003 then
                    begin
                        Result := -0.019131527186326398;
                    end
                    else
                    begin
                        Result := 0.052858518942325398;
                    end;
                end
                else
                begin
                    Result := -0.023302527718705123;
                end;
            end
            else
            begin
                if features[96] <= -121221619.99999999 then
                begin
                    Result := -0.014755872394243134;
                end
                else
                begin
                    Result := 0.039728957559088882;
                end;
            end;
        end
        else
        begin
            if features[26] <= 8.5000000000000018 then
            begin
                if features[150] <= -1.4999999999999998 then
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.0085647227179865837;
                    end
                    else
                    begin
                        Result := 5.1751406948540648E-05;
                    end;
                end
                else
                begin
                    if features[69] <= 3.5000000000000004 then
                    begin
                        Result := -0.0036192976439153343;
                    end
                    else
                    begin
                        Result := 0.0024159844069038513;
                    end;
                end;
            end
            else
            begin
                if features[148] <= 1366.5000000000002 then
                begin
                    if features[92] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.02428681027444932;
                    end
                    else
                    begin
                        Result := -0.0081468444839004964;
                    end;
                end
                else
                begin
                    if features[155] <= -1.4999999999999998 then
                    begin
                        Result := 0.06381855484288039;
                    end
                    else
                    begin
                        Result := -0.0012589415282901269;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_128(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        if features[69] <= 17.500000000000004 then
        begin
            if features[218] <= -6776.4999999999991 then
            begin
                if features[166] <= -329089295.99999994 then
                begin
                    Result := -0.021032671266916596;
                end
                else
                begin
                    Result := 0.060319541706813265;
                end;
            end
            else
            begin
                Result := -0.020503915077685356;
            end;
        end
        else
        begin
            if features[218] <= -5217.4999999999991 then
            begin
                Result := -0.017832094799352733;
            end
            else
            begin
                if features[218] <= -4595.4999999999991 then
                begin
                    Result := 0.10406994124169711;
                end
                else
                begin
                    Result := -0.015339071927996203;
                end;
            end;
        end;
    end
    else
    begin
        if features[9] <= 11.500000000000002 then
        begin
            if features[96] <= 182914768.00000003 then
            begin
                if features[166] <= 3018755.0000000005 then
                begin
                    if features[168] <= 1.5000000000000002 then
                    begin
                        Result := 0.00065624996515808607;
                    end
                    else
                    begin
                        Result := -0.0063306311207727744;
                    end;
                end
                else
                begin
                    if features[105] <= 1.5000000000000002 then
                    begin
                        Result := 0.0071992133111702279;
                    end
                    else
                    begin
                        Result := -0.0024576868613204561;
                    end;
                end;
            end
            else
            begin
                if features[166] <= 91686248.000000015 then
                begin
                    Result := -0.026050445962265658;
                end
                else
                begin
                    if features[148] <= 2458.5000000000005 then
                    begin
                        Result := 0.0028364852084549071;
                    end
                    else
                    begin
                        Result := -0.030753222536121356;
                    end;
                end;
            end;
        end
        else
        begin
            if features[180] <= -7261.4999999999991 then
            begin
                Result := -0.0052843555514911706;
            end
            else
            begin
                Result := 0.020287956992379282;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_129(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -218413975.99999997 then
    begin
        if features[47] <= 25203.000000000004 then
        begin
            Result := -0.012530751279195777;
        end
        else
        begin
            if features[229] <= -692.49999999999989 then
            begin
                Result := -0.021288932309198542;
            end
            else
            begin
                if features[81] <= 230490.00000000003 then
                begin
                    if features[227] <= -4785.4999999999991 then
                    begin
                        Result := 0.018971403610750823;
                    end
                    else
                    begin
                        Result := 0.10074217466569418;
                    end;
                end
                else
                begin
                    Result := -0.0048566726145259269;
                end;
            end;
        end;
    end
    else
    begin
        if features[226] <= 1340.5000000000002 then
        begin
            if features[42] <= 620.00000000000011 then
            begin
                if features[135] <= 1.5000000000000002 then
                begin
                    if features[66] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.00030098659500575039;
                    end
                    else
                    begin
                        Result := -0.016967288281065637;
                    end;
                end
                else
                begin
                    if features[0] <= 22517.500000000004 then
                    begin
                        Result := -0.0057838338913322896;
                    end
                    else
                    begin
                        Result := 0.0095155079274743953;
                    end;
                end;
            end
            else
            begin
                if features[73] <= 113.50000000000001 then
                begin
                    Result := -0.013024689046561644;
                end
                else
                begin
                    Result := 0.0067333383912684926;
                end;
            end;
        end
        else
        begin
            if features[155] <= 1.0000000180025095E-35 then
            begin
                if features[225] <= -5216.4999999999991 then
                begin
                    Result := -0.012807222603066487;
                end
                else
                begin
                    Result := 0.02073142849076598;
                end;
            end
            else
            begin
                if features[134] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.018952611290738192;
                end
                else
                begin
                    Result := -0.0039518493664223954;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_130(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -316588159.99999994 then
    begin
        Result := -0.018886374392356357;
    end
    else
    begin
        if features[150] <= -2.4999999999999996 then
        begin
            if features[107] <= 2.5000000000000004 then
            begin
                if features[108] <= -1051.4999999999998 then
                begin
                    if features[173] <= -6506.4999999999991 then
                    begin
                        Result := 0.069354585151735135;
                    end
                    else
                    begin
                        Result := 0.011098985134122262;
                    end;
                end
                else
                begin
                    Result := 0.0048092437991049414;
                end;
            end
            else
            begin
                if features[148] <= 301.50000000000006 then
                begin
                    Result := -0.019930255837621275;
                end
                else
                begin
                    if features[176] <= -6422.4999999999991 then
                    begin
                        Result := 0.041428928865944625;
                    end
                    else
                    begin
                        Result := -0.018104796171235473;
                    end;
                end;
            end;
        end
        else
        begin
            if features[69] <= 3.5000000000000004 then
            begin
                if features[216] <= -4200.4999999999991 then
                begin
                    if features[36] <= 691.50000000000011 then
                    begin
                        Result := -0.0039746478079552552;
                    end
                    else
                    begin
                        Result := -0.016611844747564584;
                    end;
                end
                else
                begin
                    if features[173] <= -4812.4999999999991 then
                    begin
                        Result := 0.010958478801892491;
                    end
                    else
                    begin
                        Result := -0.012436707976690123;
                    end;
                end;
            end
            else
            begin
                if features[166] <= 26972834.000000004 then
                begin
                    if features[47] <= 3320.5000000000005 then
                    begin
                        Result := 0.0074505288407738278;
                    end
                    else
                    begin
                        Result := -0.0027675239791885922;
                    end;
                end
                else
                begin
                    if features[128] <= -16716.499999999996 then
                    begin
                        Result := -0.0070801623322060137;
                    end
                    else
                    begin
                        Result := 0.0096882598845630524;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_131(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.019463445050316788;
    end
    else
    begin
        if features[122] <= -1303.4999999999998 then
        begin
            if features[25] <= 3.5000000000000004 then
            begin
                if features[147] <= -1378.9999999999998 then
                begin
                    Result := 0.038113568918608093;
                end
                else
                begin
                    if features[48] <= 19947.000000000004 then
                    begin
                        Result := -0.020790494677830642;
                    end
                    else
                    begin
                        Result := 0.018354492745973082;
                    end;
                end;
            end
            else
            begin
                if features[29] <= -6250.4999999999991 then
                begin
                    Result := 0.026835252501197893;
                end
                else
                begin
                    if features[164] <= 261841056.00000003 then
                    begin
                        Result := -0.024331836154012184;
                    end
                    else
                    begin
                        Result := 0.020181355786559985;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 1340.5000000000002 then
            begin
                if features[106] <= -1.4999999999999998 then
                begin
                    if features[92] <= -1.4999999999999998 then
                    begin
                        Result := -0.012444212595695087;
                    end
                    else
                    begin
                        Result := 0.0059429558194862529;
                    end;
                end
                else
                begin
                    if features[90] <= 1.5000000000000002 then
                    begin
                        Result := -0.0024190745324545885;
                    end
                    else
                    begin
                        Result := 0.005182501656055636;
                    end;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    if features[225] <= -5216.4999999999991 then
                    begin
                        Result := -0.013461915105715875;
                    end
                    else
                    begin
                        Result := 0.021078705864223678;
                    end;
                end
                else
                begin
                    if features[40] <= 1372.5000000000002 then
                    begin
                        Result := 0.0068973284423546558;
                    end
                    else
                    begin
                        Result := -0.017615203761782029;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_132(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[220] <= -1272.4999999999998 then
    begin
        if features[221] <= -6107.4999999999991 then
        begin
            if features[45] <= 2.5000000000000004 then
            begin
                Result := 0.041628460541627478;
            end
            else
            begin
                if features[181] <= -1955.4999999999998 then
                begin
                    Result := 0.047687504219087351;
                end
                else
                begin
                    Result := -0.020186979003461506;
                end;
            end;
        end
        else
        begin
            Result := -0.017562589966375046;
        end;
    end
    else
    begin
        if features[164] <= -342043167.99999994 then
        begin
            if features[150] <= -10.499999999999998 then
            begin
                if features[180] <= -7170.4999999999991 then
                begin
                    Result := -0.0055319195796641081;
                end
                else
                begin
                    Result := 0.029629488720580095;
                end;
            end
            else
            begin
                Result := -0.012208861411076447;
            end;
        end
        else
        begin
            if features[180] <= -8221.4999999999982 then
            begin
                if features[171] <= 4.5000000000000009 then
                begin
                    if features[222] <= -5860.4999999999991 then
                    begin
                        Result := 0.012783791444349863;
                    end
                    else
                    begin
                        Result := 0.038130777444964847;
                    end;
                end
                else
                begin
                    if features[177] <= -7041.4999999999991 then
                    begin
                        Result := -0.0084660080839441803;
                    end
                    else
                    begin
                        Result := 0.024764561198888053;
                    end;
                end;
            end
            else
            begin
                if features[175] <= -687.49999999999989 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.012041169973918353;
                    end
                    else
                    begin
                        Result := -0.0010680828887501069;
                    end;
                end
                else
                begin
                    if features[225] <= -3663.4999999999995 then
                    begin
                        Result := 0.0019082603813151949;
                    end
                    else
                    begin
                        Result := 0.014349156815997299;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_133(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[220] <= -1272.4999999999998 then
    begin
        if features[216] <= -8005.9999999999991 then
        begin
            Result := 0.015224929111741515;
        end
        else
        begin
            Result := -0.015272069153463625;
        end;
    end
    else
    begin
        if features[90] <= 1.5000000000000002 then
        begin
            if features[60] <= -1.0000000180025095E-35 then
            begin
                if features[118] <= -1.4999999999999998 then
                begin
                    if features[182] <= -4264.4999999999991 then
                    begin
                        Result := 0.0078435642449097339;
                    end
                    else
                    begin
                        Result := -0.025771060406915843;
                    end;
                end
                else
                begin
                    if features[179] <= -8217.4999999999982 then
                    begin
                        Result := 0.0090105639193945458;
                    end
                    else
                    begin
                        Result := -0.0015801971556876826;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 6.5000000000000009 then
                begin
                    Result := -0.01707874305538978;
                end
                else
                begin
                    if features[70] <= 545.50000000000011 then
                    begin
                        Result := 0.056968320897184066;
                    end
                    else
                    begin
                        Result := 7.6385389577520845E-05;
                    end;
                end;
            end;
        end
        else
        begin
            if features[47] <= 12869.500000000002 then
            begin
                if features[36] <= 864.50000000000011 then
                begin
                    if features[225] <= -4060.4999999999995 then
                    begin
                        Result := 0.0045354959681221472;
                    end
                    else
                    begin
                        Result := 0.022330917796961312;
                    end;
                end
                else
                begin
                    Result := -0.015640122767373119;
                end;
            end
            else
            begin
                if features[227] <= -5662.4999999999991 then
                begin
                    Result := -0.022602442043695339;
                end
                else
                begin
                    if features[172] <= 2.5000000000000004 then
                    begin
                        Result := 0.039307275115848334;
                    end
                    else
                    begin
                        Result := 0.00020555378558089672;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_134(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -294566319.99999994 then
    begin
        if features[80] <= -6351.4999999999991 then
        begin
            Result := 0.074941264027453117;
        end
        else
        begin
            Result := -0.016523788435882494;
        end;
    end
    else
    begin
        if features[55] <= 4.5000000000000009 then
        begin
            if features[164] <= -342043167.99999994 then
            begin
                if features[219] <= -4751.4999999999991 then
                begin
                    Result := -0.010837221633127735;
                end
                else
                begin
                    Result := 0.01966590025247638;
                end;
            end
            else
            begin
                if features[28] <= -7204.4999999999991 then
                begin
                    if features[179] <= -8297.4999999999982 then
                    begin
                        Result := 0.023853547654114501;
                    end
                    else
                    begin
                        Result := 0.00588539164705759;
                    end;
                end
                else
                begin
                    if features[175] <= -420.49999999999994 then
                    begin
                        Result := -0.0021231423669921222;
                    end
                    else
                    begin
                        Result := 0.0028470908423078281;
                    end;
                end;
            end;
        end
        else
        begin
            if features[109] <= 26.500000000000004 then
            begin
                if features[144] <= -289.49999999999994 then
                begin
                    if features[166] <= -90734603.999999985 then
                    begin
                        Result := 0.054427975091381676;
                    end
                    else
                    begin
                        Result := -0.012805806318094441;
                    end;
                end
                else
                begin
                    Result := -0.014077565526879424;
                end;
            end
            else
            begin
                if features[228] <= -5156.4999999999991 then
                begin
                    if features[54] <= 3.5000000000000004 then
                    begin
                        Result := 0.0042354662055116036;
                    end
                    else
                    begin
                        Result := 0.029895506440595677;
                    end;
                end
                else
                begin
                    if features[68] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.01086449759630294;
                    end
                    else
                    begin
                        Result := 0.0078101339358607746;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_135(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[126] <= 1.0000000180025095E-35 then
    begin
        if features[55] <= 4.5000000000000009 then
        begin
            if features[57] <= 1.5000000000000002 then
            begin
                if features[36] <= 859.50000000000011 then
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.007053727765310467;
                    end
                    else
                    begin
                        Result := 0.0015506749380495173;
                    end;
                end
                else
                begin
                    if features[73] <= 150.50000000000003 then
                    begin
                        Result := -0.0099608966663487994;
                    end
                    else
                    begin
                        Result := 0.0097524878040498725;
                    end;
                end;
            end
            else
            begin
                Result := -0.011886633626689874;
            end;
        end
        else
        begin
            Result := -0.0068208334843522364;
        end;
    end
    else
    begin
        if features[164] <= -61142731.999999993 then
        begin
            if features[223] <= 348.50000000000006 then
            begin
                if features[129] <= -22481.499999999996 then
                begin
                    Result := 0.033826081268098378;
                end
                else
                begin
                    Result := -0.017511253478559165;
                end;
            end
            else
            begin
                if features[172] <= 4.5000000000000009 then
                begin
                    Result := 0.0088969076582962048;
                end
                else
                begin
                    Result := -0.020120052536570118;
                end;
            end;
        end
        else
        begin
            if features[141] <= -2.4999999999999996 then
            begin
                if features[227] <= -5604.4999999999991 then
                begin
                    Result := -0.023346000975799187;
                end
                else
                begin
                    Result := 0.019460011908984259;
                end;
            end
            else
            begin
                if features[174] <= -4772.4999999999991 then
                begin
                    Result := -0.0079018042641939065;
                end
                else
                begin
                    if features[185] <= -126.36666870117186 then
                    begin
                        Result := -0.013819082517153367;
                    end
                    else
                    begin
                        Result := 0.015343637086673701;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_136(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[66] <= 108.50000000000001 then
    begin
        if features[26] <= 7.5000000000000009 then
        begin
            if features[55] <= 4.5000000000000009 then
            begin
                if features[175] <= -903.49999999999989 then
                begin
                    if features[222] <= -6667.4999999999991 then
                    begin
                        Result := 0.011415844985156994;
                    end
                    else
                    begin
                        Result := -0.0051194693285539685;
                    end;
                end
                else
                begin
                    if features[167] <= 2.5000000000000004 then
                    begin
                        Result := 0.0044935060435799395;
                    end
                    else
                    begin
                        Result := -0.00071872559863557961;
                    end;
                end;
            end
            else
            begin
                if features[109] <= -127.49999999999999 then
                begin
                    Result := -0.015561912794808494;
                end
                else
                begin
                    if features[178] <= -275.49999999999994 then
                    begin
                        Result := 0.022263625029474651;
                    end
                    else
                    begin
                        Result := -0.0043674809316985178;
                    end;
                end;
            end;
        end
        else
        begin
            if features[148] <= 1366.5000000000002 then
            begin
                if features[47] <= 25203.000000000004 then
                begin
                    Result := -0.018831692500341588;
                end
                else
                begin
                    Result := 0.025821119465217302;
                end;
            end
            else
            begin
                if features[177] <= -8274.4999999999982 then
                begin
                    Result := 0.072668142630828686;
                end
                else
                begin
                    if features[223] <= 505.50000000000006 then
                    begin
                        Result := -0.020477161567891408;
                    end
                    else
                    begin
                        Result := 0.020938094185086048;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[69] <= 5.5000000000000009 then
        begin
            Result := -0.018980854925840465;
        end
        else
        begin
            if features[174] <= -6931.4999999999991 then
            begin
                Result := 0.031162705884630146;
            end
            else
            begin
                Result := -0.0072563095252196168;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_137(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[126] <= 1.0000000180025095E-35 then
    begin
        if features[182] <= -4708.4999999999991 then
        begin
            if features[150] <= -2.4999999999999996 then
            begin
                if features[185] <= -528.87499999999989 then
                begin
                    if features[178] <= -1241.4999999999998 then
                    begin
                        Result := 0.0010699557831775021;
                    end
                    else
                    begin
                        Result := 0.039030604507587691;
                    end;
                end
                else
                begin
                    Result := 0.0054126872361044426;
                end;
            end
            else
            begin
                if features[69] <= 3.5000000000000004 then
                begin
                    if features[106] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0034418992808828834;
                    end
                    else
                    begin
                        Result := -0.0053603468338885886;
                    end;
                end
                else
                begin
                    if features[222] <= -5358.4999999999991 then
                    begin
                        Result := -0.00051234790403898226;
                    end
                    else
                    begin
                        Result := 0.0062457201385109551;
                    end;
                end;
            end;
        end
        else
        begin
            if features[174] <= -4431.4999999999991 then
            begin
                Result := -0.017400526681190964;
            end
            else
            begin
                Result := 0.0028386274072234752;
            end;
        end;
    end
    else
    begin
        if features[27] <= -5204.4999999999991 then
        begin
            if features[226] <= 327.50000000000006 then
            begin
                Result := -0.016977621641724446;
            end
            else
            begin
                Result := 0.0023874616859894237;
            end;
        end
        else
        begin
            if features[174] <= -4772.4999999999991 then
            begin
                if features[141] <= -2.4999999999999996 then
                begin
                    Result := 0.015041200034899614;
                end
                else
                begin
                    Result := -0.0081228394096223237;
                end;
            end
            else
            begin
                if features[108] <= -396.49999999999994 then
                begin
                    Result := -0.021181780520810087;
                end
                else
                begin
                    Result := 0.016040029669079664;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_138(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -877.49999999999989 then
    begin
        if features[216] <= -6725.4999999999991 then
        begin
            if features[215] <= -4956.4999999999991 then
            begin
                if features[164] <= -237618191.99999997 then
                begin
                    if features[47] <= 50996.500000000007 then
                    begin
                        Result := -0.018314294746666557;
                    end
                    else
                    begin
                        Result := 0.069618148866206098;
                    end;
                end
                else
                begin
                    if features[151] <= -14.499999999999998 then
                    begin
                        Result := 0.050639778316861776;
                    end
                    else
                    begin
                        Result := -0.011385131290167595;
                    end;
                end;
            end
            else
            begin
                Result := -0.023665877511836266;
            end;
        end
        else
        begin
            Result := -0.019780260065561356;
        end;
    end
    else
    begin
        if features[15] <= -329166463.99999994 then
        begin
            Result := -0.018491550574752127;
        end
        else
        begin
            if features[216] <= -4389.4999999999991 then
            begin
                if features[41] <= 1414.5000000000002 then
                begin
                    if features[175] <= -1166.4999999999998 then
                    begin
                        Result := -0.0050721131317908244;
                    end
                    else
                    begin
                        Result := 0.0015436336185341455;
                    end;
                end
                else
                begin
                    if features[184] <= -983.49999999999989 then
                    begin
                        Result := 0.023551451362124078;
                    end
                    else
                    begin
                        Result := -0.0095084826293817745;
                    end;
                end;
            end
            else
            begin
                if features[174] <= -5953.4999999999991 then
                begin
                    if features[60] <= 1.5000000000000002 then
                    begin
                        Result := 0.018593173945699201;
                    end
                    else
                    begin
                        Result := -0.027599239114285603;
                    end;
                end
                else
                begin
                    if features[109] <= -162.49999999999997 then
                    begin
                        Result := -0.0057604129338224919;
                    end
                    else
                    begin
                        Result := 0.0063853928599344858;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_139(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -157.49999999999997 then
    begin
        if features[219] <= -7299.4999999999991 then
        begin
            if features[177] <= -7946.4999999999991 then
            begin
                Result := 0.00087134893737012302;
            end
            else
            begin
                if features[215] <= -4538.4999999999991 then
                begin
                    Result := 0.037865847008279448;
                end
                else
                begin
                    Result := -0.023799994727143656;
                end;
            end;
        end
        else
        begin
            if features[164] <= -252947183.99999997 then
            begin
                Result := -0.015891752585717105;
            end
            else
            begin
                if features[18] <= 12.500000000000002 then
                begin
                    if features[154] <= -498.49999999999994 then
                    begin
                        Result := 0.013536227640820781;
                    end
                    else
                    begin
                        Result := -0.002700679676225557;
                    end;
                end
                else
                begin
                    Result := -0.01371419745617173;
                end;
            end;
        end;
    end
    else
    begin
        if features[171] <= 1.5000000000000002 then
        begin
            if features[121] <= 1129.5000000000002 then
            begin
                if features[177] <= -4836.4999999999991 then
                begin
                    if features[118] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.003911068781080408;
                    end
                    else
                    begin
                        Result := -0.0048768514593094036;
                    end;
                end
                else
                begin
                    Result := 0.012697997715423957;
                end;
            end
            else
            begin
                Result := -0.011058972220871309;
            end;
        end
        else
        begin
            if features[216] <= -5836.4999999999991 then
            begin
                Result := -0.0041516924869799245;
            end
            else
            begin
                if features[89] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.013569562283406229;
                end
                else
                begin
                    if features[47] <= 4332.5000000000009 then
                    begin
                        Result := 0.0080373190261957567;
                    end
                    else
                    begin
                        Result := -0.00017850719101646692;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_140(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -316588159.99999994 then
    begin
        if features[216] <= -7163.4999999999991 then
        begin
            if features[173] <= -5748.4999999999991 then
            begin
                Result := -0.018046397395992061;
            end
            else
            begin
                if features[154] <= -152.49999999999997 then
                begin
                    Result := -0.011700278979491613;
                end
                else
                begin
                    Result := 0.1114833675219767;
                end;
            end;
        end
        else
        begin
            Result := -0.019213000430905344;
        end;
    end
    else
    begin
        if features[96] <= 179340080.00000003 then
        begin
            if features[172] <= 3.5000000000000004 then
            begin
                if features[222] <= -5153.4999999999991 then
                begin
                    if features[219] <= -7019.4999999999991 then
                    begin
                        Result := 0.0086579071824394397;
                    end
                    else
                    begin
                        Result := -0.0012946051708103434;
                    end;
                end
                else
                begin
                    if features[28] <= -6923.4999999999991 then
                    begin
                        Result := 0.019052839581317094;
                    end
                    else
                    begin
                        Result := 0.0062863525073742765;
                    end;
                end;
            end
            else
            begin
                if features[36] <= 697.50000000000011 then
                begin
                    if features[117] <= -18.499999999999996 then
                    begin
                        Result := -0.0092891846548449931;
                    end
                    else
                    begin
                        Result := 0.0027934825571129846;
                    end;
                end
                else
                begin
                    if features[217] <= 413.50000000000006 then
                    begin
                        Result := -0.017782759771880468;
                    end
                    else
                    begin
                        Result := -0.0029888592067720573;
                    end;
                end;
            end;
        end
        else
        begin
            if features[108] <= 748.50000000000011 then
            begin
                Result := -0.020917000603053317;
            end
            else
            begin
                if features[95] <= 257739088.00000003 then
                begin
                    Result := 0.019476614042530711;
                end
                else
                begin
                    Result := -0.017230219196613435;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_141(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -560.49999999999989 then
    begin
        if features[221] <= -5799.4999999999991 then
        begin
            if features[1] <= 102684.00000000001 then
            begin
                Result := -0.0027182500066297837;
            end
            else
            begin
                if features[221] <= -5895.4999999999991 then
                begin
                    Result := 0.013906639318952502;
                end
                else
                begin
                    Result := 0.10751023438549119;
                end;
            end;
        end
        else
        begin
            if features[27] <= -3988.4999999999995 then
            begin
                Result := -0.015542680920210234;
            end
            else
            begin
                if features[1] <= 127992.50000000001 then
                begin
                    if features[108] <= 316.50000000000006 then
                    begin
                        Result := -0.014036476876782304;
                    end
                    else
                    begin
                        Result := 0.048959530493405602;
                    end;
                end
                else
                begin
                    Result := 0.056810144211149806;
                end;
            end;
        end;
    end
    else
    begin
        if features[225] <= -3663.4999999999995 then
        begin
            if features[182] <= -4613.4999999999991 then
            begin
                if features[129] <= 10443.500000000002 then
                begin
                    if features[15] <= -331810335.99999994 then
                    begin
                        Result := -0.020229330583915465;
                    end
                    else
                    begin
                        Result := -3.6002603581047961E-05;
                    end;
                end
                else
                begin
                    if features[173] <= -6629.4999999999991 then
                    begin
                        Result := 0.019013740177895713;
                    end
                    else
                    begin
                        Result := 0.0036236895799772414;
                    end;
                end;
            end
            else
            begin
                if features[108] <= -25.499999999999996 then
                begin
                    Result := -0.018956455744041086;
                end
                else
                begin
                    Result := 0.010731261196760428;
                end;
            end;
        end
        else
        begin
            if features[36] <= 859.50000000000011 then
            begin
                Result := 0.015273924847118146;
            end
            else
            begin
                Result := -0.0047284659458358439;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_142(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[126] <= 1.0000000180025095E-35 then
    begin
        if features[150] <= -1.0000000180025095E-35 then
        begin
            if features[219] <= -6999.4999999999991 then
            begin
                if features[0] <= 20033.500000000004 then
                begin
                    Result := -0.026128731950196035;
                end
                else
                begin
                    Result := 0.023725512464901174;
                end;
            end
            else
            begin
                Result := 0.0040903520295744655;
            end;
        end
        else
        begin
            if features[55] <= 3.5000000000000004 then
            begin
                if features[47] <= 3320.5000000000005 then
                begin
                    if features[15] <= -142486575.99999997 then
                    begin
                        Result := -0.014652090420178046;
                    end
                    else
                    begin
                        Result := 0.012530687746793041;
                    end;
                end
                else
                begin
                    if features[175] <= -272.49999999999994 then
                    begin
                        Result := -0.0048135160430020571;
                    end
                    else
                    begin
                        Result := 0.0023170900263225808;
                    end;
                end;
            end
            else
            begin
                if features[67] <= 1317.5000000000002 then
                begin
                    Result := 0.0;
                end
                else
                begin
                    Result := -0.013941434755572378;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= -80436775.999999985 then
        begin
            if features[220] <= 322.50000000000006 then
            begin
                Result := -0.018154566792267204;
            end
            else
            begin
                Result := 0.00073832892756148206;
            end;
        end
        else
        begin
            if features[141] <= -2.4999999999999996 then
            begin
                Result := 0.012327981782765523;
            end
            else
            begin
                if features[96] <= -218356839.99999997 then
                begin
                    if features[166] <= -252773191.99999997 then
                    begin
                        Result := -0.019073856045333681;
                    end
                    else
                    begin
                        Result := 0.075328647248225328;
                    end;
                end
                else
                begin
                    Result := -0.0049895675181973994;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_143(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        if features[216] <= -8210.4999999999982 then
        begin
            Result := 0.01555375713660969;
        end
        else
        begin
            Result := -0.022053770836158147;
        end;
    end
    else
    begin
        if features[122] <= -1303.4999999999998 then
        begin
            if features[172] <= 3.5000000000000004 then
            begin
                if features[225] <= -5352.4999999999991 then
                begin
                    Result := -0.018667315989829011;
                end
                else
                begin
                    if features[224] <= -5340.4999999999991 then
                    begin
                        Result := 0.037386161194537297;
                    end
                    else
                    begin
                        Result := -0.0031232239209588132;
                    end;
                end;
            end
            else
            begin
                if features[147] <= -279.49999999999994 then
                begin
                    Result := 0.012335840734837018;
                end
                else
                begin
                    Result := -0.023031574909243256;
                end;
            end;
        end
        else
        begin
            if features[225] <= -3827.4999999999995 then
            begin
                if features[66] <= 34.500000000000007 then
                begin
                    if features[55] <= 4.5000000000000009 then
                    begin
                        Result := 0.0016988482937425908;
                    end
                    else
                    begin
                        Result := -0.0053027842626462707;
                    end;
                end
                else
                begin
                    if features[215] <= -4727.4999999999991 then
                    begin
                        Result := -0.017679058821867807;
                    end
                    else
                    begin
                        Result := 0.0095790669507239204;
                    end;
                end;
            end
            else
            begin
                if features[187] <= 5.3541667461395273 then
                begin
                    if features[215] <= -3975.4999999999995 then
                    begin
                        Result := 0.026661769539788761;
                    end
                    else
                    begin
                        Result := 0.0046498155779893186;
                    end;
                end
                else
                begin
                    if features[226] <= 439.50000000000006 then
                    begin
                        Result := -0.015030900299551475;
                    end
                    else
                    begin
                        Result := 0.0097578349682786447;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_144(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -316588159.99999994 then
    begin
        if features[80] <= -6351.4999999999991 then
        begin
            Result := 0.073546929795381605;
        end
        else
        begin
            Result := -0.01853789288070121;
        end;
    end
    else
    begin
        if features[172] <= 3.5000000000000004 then
        begin
            if features[225] <= -4060.4999999999995 then
            begin
                if features[57] <= 1.5000000000000002 then
                begin
                    if features[222] <= -5237.4999999999991 then
                    begin
                        Result := -0.00067320743278933258;
                    end
                    else
                    begin
                        Result := 0.0050890052164034409;
                    end;
                end
                else
                begin
                    Result := -0.016425802421908869;
                end;
            end
            else
            begin
                if features[175] <= -634.49999999999989 then
                begin
                    if features[28] <= -5381.4999999999991 then
                    begin
                        Result := 0.025043331361582134;
                    end
                    else
                    begin
                        Result := -0.017834768622909291;
                    end;
                end
                else
                begin
                    Result := 0.022510433925407195;
                end;
            end;
        end
        else
        begin
            if features[36] <= 697.50000000000011 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[227] <= -4724.4999999999991 then
                    begin
                        Result := 0.0036419837118714278;
                    end
                    else
                    begin
                        Result := -0.0055691580155942293;
                    end;
                end
                else
                begin
                    Result := -0.010595488952068433;
                end;
            end
            else
            begin
                if features[216] <= -4479.4999999999991 then
                begin
                    if features[228] <= -4828.4999999999991 then
                    begin
                        Result := -0.006907553771931369;
                    end
                    else
                    begin
                        Result := -0.026838990103946581;
                    end;
                end
                else
                begin
                    if features[221] <= -4550.4999999999991 then
                    begin
                        Result := 0.0038179518130183315;
                    end
                    else
                    begin
                        Result := -0.016341982765696587;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_145(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[175] <= -440.49999999999994 then
    begin
        if features[150] <= -32.499999999999993 then
        begin
            Result := 0.040687191219821207;
        end
        else
        begin
            if features[226] <= 413.50000000000006 then
            begin
                if features[219] <= -7039.4999999999991 then
                begin
                    if features[177] <= -8037.4999999999991 then
                    begin
                        Result := -0.0028485585098711606;
                    end
                    else
                    begin
                        Result := 0.020539677731383862;
                    end;
                end
                else
                begin
                    if features[177] <= -9220.4999999999982 then
                    begin
                        Result := 0.03707645124384755;
                    end
                    else
                    begin
                        Result := -0.0076361007309032865;
                    end;
                end;
            end
            else
            begin
                if features[106] <= 1.0000000180025095E-35 then
                begin
                    if features[215] <= -5771.4999999999991 then
                    begin
                        Result := -0.0041551121915345797;
                    end
                    else
                    begin
                        Result := 0.015491196506494029;
                    end;
                end
                else
                begin
                    Result := -0.010220442003927525;
                end;
            end;
        end;
    end
    else
    begin
        if features[27] <= -2748.4999999999995 then
        begin
            if features[96] <= 182914768.00000003 then
            begin
                if features[164] <= -363563103.99999994 then
                begin
                    if features[73] <= 51.500000000000007 then
                    begin
                        Result := 0.001059069685641548;
                    end
                    else
                    begin
                        Result := -0.017687778726152511;
                    end;
                end
                else
                begin
                    if features[28] <= -7413.4999999999991 then
                    begin
                        Result := 0.011934736396583035;
                    end
                    else
                    begin
                        Result := 0.0013428996657642942;
                    end;
                end;
            end
            else
            begin
                if features[164] <= 95188640.000000015 then
                begin
                    Result := -0.024721262764923976;
                end
                else
                begin
                    Result := 0.00040994031111937069;
                end;
            end;
        end
        else
        begin
            Result := 0.020283919840593238;
        end;
    end;
end;

function second_slot_bidirectional_tree_146(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -298130495.99999994 then
    begin
        if features[69] <= 18.500000000000004 then
        begin
            if features[70] <= 401.00000000000006 then
            begin
                Result := 0.057439531527264602;
            end
            else
            begin
                if features[218] <= -7631.4999999999991 then
                begin
                    Result := 0.045589857167151214;
                end
                else
                begin
                    Result := -0.021062592799693559;
                end;
            end;
        end
        else
        begin
            if features[225] <= -5130.4999999999991 then
            begin
                Result := -0.017639741681078413;
            end
            else
            begin
                Result := 0.066454457206512524;
            end;
        end;
    end
    else
    begin
        if features[143] <= 1.0000000180025095E-35 then
        begin
            if features[9] <= 11.500000000000002 then
            begin
                if features[150] <= -2.4999999999999996 then
                begin
                    if features[24] <= 1.5000000000000002 then
                    begin
                        Result := -0.0096360364032320577;
                    end
                    else
                    begin
                        Result := 0.0066672846887787483;
                    end;
                end
                else
                begin
                    if features[174] <= -4431.4999999999991 then
                    begin
                        Result := -0.0011548133666389919;
                    end
                    else
                    begin
                        Result := 0.0057851705464300263;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -7261.4999999999991 then
                begin
                    Result := -0.0059194073859981976;
                end
                else
                begin
                    Result := 0.02289211651814824;
                end;
            end;
        end
        else
        begin
            if features[9] <= 3.5000000000000004 then
            begin
                Result := -0.015180631310500112;
            end
            else
            begin
                if features[177] <= -4962.4999999999991 then
                begin
                    if features[176] <= -6901.4999999999991 then
                    begin
                        Result := 0.0042518442788228401;
                    end
                    else
                    begin
                        Result := -0.016694339618000802;
                    end;
                end
                else
                begin
                    Result := 0.028352263259549745;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_147(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -12.499999999999998 then
    begin
        if features[26] <= 7.5000000000000009 then
        begin
            if features[219] <= -6999.4999999999991 then
            begin
                if features[126] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.019256573788774461;
                end
                else
                begin
                    Result := -0.00032749162983577318;
                end;
            end
            else
            begin
                if features[220] <= -1272.4999999999998 then
                begin
                    Result := -0.017144836426596831;
                end
                else
                begin
                    if features[161] <= -1233.4999999999998 then
                    begin
                        Result := 0.028633782951656302;
                    end
                    else
                    begin
                        Result := -0.0031318796374788026;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.018884085577729331;
        end;
    end
    else
    begin
        if features[171] <= 1.5000000000000002 then
        begin
            if features[172] <= 4.5000000000000009 then
            begin
                if features[177] <= -5005.4999999999991 then
                begin
                    if features[28] <= -5584.4999999999991 then
                    begin
                        Result := 0.0029312311275368846;
                    end
                    else
                    begin
                        Result := -0.010500621287320435;
                    end;
                end
                else
                begin
                    if features[117] <= 463.50000000000006 then
                    begin
                        Result := 0.022583752642038338;
                    end
                    else
                    begin
                        Result := -0.021625323242264839;
                    end;
                end;
            end
            else
            begin
                Result := -0.0061580543884466807;
            end;
        end
        else
        begin
            if features[216] <= -5836.4999999999991 then
            begin
                if features[82] <= 157825.00000000003 then
                begin
                    Result := -0.0048928291909773516;
                end
                else
                begin
                    Result := 0.03206999182907639;
                end;
            end
            else
            begin
                if features[177] <= -6803.4999999999991 then
                begin
                    Result := 0.01021878408183971;
                end
                else
                begin
                    Result := 0.0030816039604225254;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_148(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -976.49999999999989 then
    begin
        if features[182] <= -8454.4999999999982 then
        begin
            Result := 0.029004478978678597;
        end
        else
        begin
            if features[216] <= -8210.4999999999982 then
            begin
                if features[1] <= 123270.00000000001 then
                begin
                    Result := -0.019493774286826596;
                end
                else
                begin
                    Result := 0.04580018847217731;
                end;
            end
            else
            begin
                if features[69] <= 30.500000000000004 then
                begin
                    if features[153] <= 428.50000000000006 then
                    begin
                        Result := -0.023484578966252022;
                    end
                    else
                    begin
                        Result := 0.027930262357917703;
                    end;
                end
                else
                begin
                    Result := 0.02754624704551531;
                end;
            end;
        end;
    end
    else
    begin
        if features[215] <= -3227.4999999999995 then
        begin
            if features[228] <= -3446.4999999999995 then
            begin
                if features[106] <= 1.5000000000000002 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0025499828491281702;
                    end
                    else
                    begin
                        Result := -0.0060775431696786057;
                    end;
                end
                else
                begin
                    if features[157] <= -6.4999999999999991 then
                    begin
                        Result := 0.0070585604370993387;
                    end
                    else
                    begin
                        Result := -0.0050712722334079006;
                    end;
                end;
            end
            else
            begin
                if features[40] <= 1135.5000000000002 then
                begin
                    if features[29] <= -4944.4999999999991 then
                    begin
                        Result := 0.031943768788282173;
                    end
                    else
                    begin
                        Result := 0.010051585717888365;
                    end;
                end
                else
                begin
                    if features[71] <= 3.5000000000000004 then
                    begin
                        Result := -0.0086953125576882864;
                    end
                    else
                    begin
                        Result := 0.020609146206311386;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.024012082401756452;
        end;
    end;
end;

function second_slot_bidirectional_tree_149(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[216] <= -4054.4999999999995 then
        begin
            if features[182] <= -4541.4999999999991 then
            begin
                if features[15] <= -272749359.99999994 then
                begin
                    if features[216] <= -7840.4999999999991 then
                    begin
                        Result := 0.053480210216654167;
                    end
                    else
                    begin
                        Result := -0.017565515805699164;
                    end;
                end
                else
                begin
                    if features[82] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0012536584092736158;
                    end
                    else
                    begin
                        Result := 0.004484165716826651;
                    end;
                end;
            end
            else
            begin
                if features[109] <= 5.5000000000000009 then
                begin
                    Result := -0.021288894236257822;
                end
                else
                begin
                    Result := 0.0083882923751154616;
                end;
            end;
        end
        else
        begin
            if features[216] <= -3965.4999999999995 then
            begin
                if features[223] <= -454.49999999999994 then
                begin
                    if features[27] <= -5516.4999999999991 then
                    begin
                        Result := 0.0061053771713126129;
                    end
                    else
                    begin
                        Result := 0.049685786497685569;
                    end;
                end
                else
                begin
                    if features[166] <= -201899431.99999997 then
                    begin
                        Result := 0.052724491279922937;
                    end
                    else
                    begin
                        Result := 0.00865966084319259;
                    end;
                end;
            end
            else
            begin
                if features[223] <= -38.499999999999993 then
                begin
                    if features[218] <= -6480.4999999999991 then
                    begin
                        Result := 0.025449491530273954;
                    end
                    else
                    begin
                        Result := -0.014506185196145372;
                    end;
                end
                else
                begin
                    if features[151] <= 25.500000000000004 then
                    begin
                        Result := 0.0090972332098851003;
                    end
                    else
                    begin
                        Result := -0.0059196800426383062;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.023519689154403341;
    end;
end;

function second_slot_bidirectional_tree_150(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[223] <= -1219.4999999999998 then
    begin
        if features[216] <= -7840.4999999999991 then
        begin
            if features[174] <= -7335.4999999999991 then
            begin
                Result := -0.01501601966682474;
            end
            else
            begin
                Result := 0.059137486105095928;
            end;
        end
        else
        begin
            if features[9] <= 10.500000000000002 then
            begin
                if features[216] <= -4017.4999999999995 then
                begin
                    Result := -0.0244094173904453;
                end
                else
                begin
                    if features[129] <= 20092.000000000004 then
                    begin
                        Result := -0.016266523166209981;
                    end
                    else
                    begin
                        Result := 0.069062665325673345;
                    end;
                end;
            end
            else
            begin
                Result := 0.035991505267932843;
            end;
        end;
    end
    else
    begin
        if features[15] <= -336406943.99999994 then
        begin
            Result := -0.018554738662766614;
        end
        else
        begin
            if features[96] <= 182914768.00000003 then
            begin
                if features[71] <= 1.5000000000000002 then
                begin
                    if features[128] <= -1130.4999999999998 then
                    begin
                        Result := 0.0069544118088304442;
                    end
                    else
                    begin
                        Result := -0.0065323668625925108;
                    end;
                end
                else
                begin
                    if features[172] <= 12.500000000000002 then
                    begin
                        Result := 0.0024642716317221747;
                    end
                    else
                    begin
                        Result := -0.019116738985187638;
                    end;
                end;
            end
            else
            begin
                if features[108] <= 748.50000000000011 then
                begin
                    if features[71] <= 4.5000000000000009 then
                    begin
                        Result := 0.0065037532434769479;
                    end
                    else
                    begin
                        Result := -0.022464422879175688;
                    end;
                end
                else
                begin
                    if features[95] <= 257739088.00000003 then
                    begin
                        Result := 0.017291584418659411;
                    end
                    else
                    begin
                        Result := -0.021113815727789243;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_151(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -890.49999999999989 then
    begin
        if features[216] <= -6777.4999999999991 then
        begin
            Result := 0.0044472973776938417;
        end
        else
        begin
            Result := -0.018953362910434708;
        end;
    end
    else
    begin
        if features[172] <= 2.5000000000000004 then
        begin
            if features[222] <= -5368.4999999999991 then
            begin
                if features[71] <= 1.5000000000000002 then
                begin
                    if features[47] <= 3019.5000000000005 then
                    begin
                        Result := 0.0081897913947081326;
                    end
                    else
                    begin
                        Result := -0.012090716836940921;
                    end;
                end
                else
                begin
                    if features[109] <= 450.50000000000006 then
                    begin
                        Result := -0.00010592571432125773;
                    end
                    else
                    begin
                        Result := 0.015112677143025359;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5965.4999999999991 then
                begin
                    Result := -0.0067296748098372361;
                end
                else
                begin
                    if features[215] <= -4049.4999999999995 then
                    begin
                        Result := 0.010343030433345054;
                    end
                    else
                    begin
                        Result := -0.0012495371380493673;
                    end;
                end;
            end;
        end
        else
        begin
            if features[227] <= -4803.4999999999991 then
            begin
                if features[106] <= 1.5000000000000002 then
                begin
                    if features[117] <= -26.499999999999996 then
                    begin
                        Result := -0.0083909066077378653;
                    end
                    else
                    begin
                        Result := 0.0046993214433638346;
                    end;
                end
                else
                begin
                    if features[144] <= -1309.9999999999998 then
                    begin
                        Result := 0.024897231963960233;
                    end
                    else
                    begin
                        Result := -0.0072141716928997377;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -4917.4999999999991 then
                begin
                    Result := -0.016179703711369637;
                end
                else
                begin
                    Result := -0.0022398948840572342;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_152(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[164] <= -342043167.99999994 then
    begin
        if features[218] <= -5546.4999999999991 then
        begin
            if features[219] <= -4707.4999999999991 then
            begin
                if features[150] <= -14.499999999999998 then
                begin
                    Result := 0.010519723204887858;
                end
                else
                begin
                    Result := -0.010219089893133049;
                end;
            end
            else
            begin
                Result := 0.031831141015440483;
            end;
        end
        else
        begin
            Result := -0.020976602170601658;
        end;
    end
    else
    begin
        if features[28] <= -7745.4999999999991 then
        begin
            if features[217] <= -2142.4999999999995 then
            begin
                Result := -0.02482324621181637;
            end
            else
            begin
                if features[217] <= -1689.4999999999998 then
                begin
                    Result := 0.066492283130364954;
                end
                else
                begin
                    if features[166] <= 26972834.000000004 then
                    begin
                        Result := 0.0079762021331748739;
                    end
                    else
                    begin
                        Result := 0.028497583401312962;
                    end;
                end;
            end;
        end
        else
        begin
            if features[175] <= -687.49999999999989 then
            begin
                if features[182] <= -4579.4999999999991 then
                begin
                    if features[71] <= 2.5000000000000004 then
                    begin
                        Result := -0.0066869037985110959;
                    end
                    else
                    begin
                        Result := 0.00057412314091723259;
                    end;
                end
                else
                begin
                    Result := -0.019933437273643797;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    if features[226] <= 1340.5000000000002 then
                    begin
                        Result := 0.0021465698570069035;
                    end
                    else
                    begin
                        Result := 0.016691613934644533;
                    end;
                end
                else
                begin
                    if features[151] <= 57.500000000000007 then
                    begin
                        Result := -0.0071766130108370553;
                    end
                    else
                    begin
                        Result := 0.0016835341186952305;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_153(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        if features[216] <= -8210.4999999999982 then
        begin
            if features[28] <= -6528.4999999999991 then
            begin
                Result := -0.02028832204469844;
            end
            else
            begin
                Result := 0.047690245566153935;
            end;
        end
        else
        begin
            Result := -0.023903476418838433;
        end;
    end
    else
    begin
        if features[15] <= -336406943.99999994 then
        begin
            if features[120] <= -1429.9999999999998 then
            begin
                if features[36] <= 6.5000000000000009 then
                begin
                    Result := -0.017827830243156609;
                end
                else
                begin
                    Result := 0.057870831954367902;
                end;
            end
            else
            begin
                if features[174] <= -4993.4999999999991 then
                begin
                    Result := -0.026048675297779985;
                end
                else
                begin
                    Result := -0.0040113104557150782;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4054.4999999999995 then
            begin
                if features[176] <= -4348.4999999999991 then
                begin
                    if features[41] <= 1465.5000000000002 then
                    begin
                        Result := 0.00081022143401083657;
                    end
                    else
                    begin
                        Result := -0.0072807964109463975;
                    end;
                end
                else
                begin
                    if features[39] <= 1438.5000000000002 then
                    begin
                        Result := -0.028155680621582885;
                    end
                    else
                    begin
                        Result := -0.0054100585951938722;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 4.5000000000000009 then
                begin
                    if features[173] <= -4205.4999999999991 then
                    begin
                        Result := 0.003065470252599874;
                    end
                    else
                    begin
                        Result := -0.018243548368366454;
                    end;
                end
                else
                begin
                    if features[14] <= -70750783.999999985 then
                    begin
                        Result := -0.012094695555909238;
                    end
                    else
                    begin
                        Result := 0.018679533293692593;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_154(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[223] <= -1289.4999999999998 then
    begin
        if features[145] <= -884.49999999999989 then
        begin
            Result := 0.030282930796117144;
        end
        else
        begin
            if features[13] <= 86540.000000000015 then
            begin
                Result := -0.02204471493680861;
            end
            else
            begin
                if features[219] <= -7335.4999999999991 then
                begin
                    if features[180] <= -7294.4999999999991 then
                    begin
                        Result := 0.00050763876429963902;
                    end
                    else
                    begin
                        Result := 0.06023477613068088;
                    end;
                end
                else
                begin
                    Result := -0.022595700547811955;
                end;
            end;
        end;
    end
    else
    begin
        if features[215] <= -3227.4999999999995 then
        begin
            if features[228] <= -3446.4999999999995 then
            begin
                if features[182] <= -4541.4999999999991 then
                begin
                    if features[77] <= 5937.5000000000009 then
                    begin
                        Result := 0.0023298204925763142;
                    end
                    else
                    begin
                        Result := -0.0020827959629259388;
                    end;
                end
                else
                begin
                    if features[186] <= -30.291666984558102 then
                    begin
                        Result := -0.017788093052164226;
                    end
                    else
                    begin
                        Result := 0.0067159545747210907;
                    end;
                end;
            end
            else
            begin
                if features[45] <= 2.5000000000000004 then
                begin
                    if features[175] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0072870735753598039;
                    end
                    else
                    begin
                        Result := 0.01436384926246655;
                    end;
                end
                else
                begin
                    if features[173] <= -6744.4999999999991 then
                    begin
                        Result := -0.010610297452686926;
                    end
                    else
                    begin
                        Result := 0.028541355910962119;
                    end;
                end;
            end;
        end
        else
        begin
            if features[154] <= 239.50000000000003 then
            begin
                Result := -0.025503622117076515;
            end
            else
            begin
                Result := 0.0058835748222857524;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_155(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[164] <= -368292223.99999994 then
    begin
        if features[226] <= 581.50000000000011 then
        begin
            Result := -0.014016966372651141;
        end
        else
        begin
            Result := 0.0064054632660201687;
        end;
    end
    else
    begin
        if features[183] <= -8284.4999999999982 then
        begin
            if features[81] <= 1.0000000180025095E-35 then
            begin
                if features[128] <= -1130.4999999999998 then
                begin
                    if features[81] <= -21449.999999999996 then
                    begin
                        Result := 0.004958120978209535;
                    end
                    else
                    begin
                        Result := 0.045255801063102924;
                    end;
                end
                else
                begin
                    Result := -0.011366337937039193;
                end;
            end
            else
            begin
                if features[171] <= 5.5000000000000009 then
                begin
                    if features[154] <= 182.50000000000003 then
                    begin
                        Result := 0.049882747664299475;
                    end
                    else
                    begin
                        Result := 0.001108695194399116;
                    end;
                end
                else
                begin
                    Result := -0.0076456041799341512;
                end;
            end;
        end
        else
        begin
            if features[175] <= -687.49999999999989 then
            begin
                if features[182] <= -4963.4999999999991 then
                begin
                    if features[216] <= -4888.4999999999991 then
                    begin
                        Result := -0.0043168639656932847;
                    end
                    else
                    begin
                        Result := 0.0048344756247175403;
                    end;
                end
                else
                begin
                    Result := -0.016189846746146066;
                end;
            end
            else
            begin
                if features[225] <= -3583.9999999999995 then
                begin
                    if features[106] <= -1.4999999999999998 then
                    begin
                        Result := 0.0052957136057052434;
                    end
                    else
                    begin
                        Result := -0.00019239430135625313;
                    end;
                end
                else
                begin
                    if features[215] <= -3719.4999999999995 then
                    begin
                        Result := 0.019456088948978215;
                    end
                    else
                    begin
                        Result := -0.011783794604351978;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_156(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -229.49999999999997 then
    begin
        if features[227] <= -5048.4999999999991 then
        begin
            if features[164] <= -256287415.99999997 then
            begin
                Result := -0.012134190810837768;
            end
            else
            begin
                if features[9] <= 2.5000000000000004 then
                begin
                    Result := -0.0082291340293105652;
                end
                else
                begin
                    Result := 0.010262736783553033;
                end;
            end;
        end
        else
        begin
            if features[167] <= 1.5000000000000002 then
            begin
                if features[215] <= -4547.4999999999991 then
                begin
                    if features[173] <= -6106.4999999999991 then
                    begin
                        Result := 0.021695834949829421;
                    end
                    else
                    begin
                        Result := -0.010952586912454284;
                    end;
                end
                else
                begin
                    if features[217] <= 22.500000000000004 then
                    begin
                        Result := -0.0015075775099838682;
                    end
                    else
                    begin
                        Result := 0.048644519792663467;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 10.500000000000002 then
                begin
                    Result := -0.015687317164367665;
                end
                else
                begin
                    Result := 0.00043068647318980733;
                end;
            end;
        end;
    end
    else
    begin
        if features[129] <= 10443.500000000002 then
        begin
            if features[36] <= 864.50000000000011 then
            begin
                if features[225] <= -3663.4999999999995 then
                begin
                    Result := 0.00071720475067803019;
                end
                else
                begin
                    Result := 0.014728027522613896;
                end;
            end
            else
            begin
                Result := -0.0086713081134101484;
            end;
        end
        else
        begin
            if features[176] <= -6004.4999999999991 then
            begin
                if features[145] <= -568.49999999999989 then
                begin
                    Result := -0.01935123141284462;
                end
                else
                begin
                    Result := 0.016188254087220969;
                end;
            end
            else
            begin
                Result := -0.0016189621799819823;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_157(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.019522020954316557;
    end
    else
    begin
        if features[129] <= 10320.500000000002 then
        begin
            if features[146] <= -445.49999999999994 then
            begin
                if features[146] <= -1030.4999999999998 then
                begin
                    if features[172] <= 7.5000000000000009 then
                    begin
                        Result := 0.0069725746523373253;
                    end
                    else
                    begin
                        Result := -0.020655065461997028;
                    end;
                end
                else
                begin
                    if features[25] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.057109226709247174;
                    end
                    else
                    begin
                        Result := 0.014313778514751518;
                    end;
                end;
            end
            else
            begin
                if features[9] <= 11.500000000000002 then
                begin
                    if features[177] <= -5134.4999999999991 then
                    begin
                        Result := -0.0022918327800184111;
                    end
                    else
                    begin
                        Result := 0.0050296488978768678;
                    end;
                end
                else
                begin
                    if features[178] <= -924.49999999999989 then
                    begin
                        Result := -0.026935324228153125;
                    end
                    else
                    begin
                        Result := 0.014543995350925619;
                    end;
                end;
            end;
        end
        else
        begin
            if features[173] <= -6629.4999999999991 then
            begin
                if features[82] <= 97557.000000000015 then
                begin
                    Result := 0.036439667128317303;
                end
                else
                begin
                    if features[172] <= 3.5000000000000004 then
                    begin
                        Result := 0.021488734080618039;
                    end
                    else
                    begin
                        Result := -0.0070651937343473963;
                    end;
                end;
            end
            else
            begin
                if features[227] <= -5972.4999999999991 then
                begin
                    Result := -0.016947778271251154;
                end
                else
                begin
                    if features[94] <= 137413.50000000003 then
                    begin
                        Result := 0.0081068407843985207;
                    end
                    else
                    begin
                        Result := -0.0067142488788322968;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_158(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.018576887564968642;
    end
    else
    begin
        if features[55] <= 4.5000000000000009 then
        begin
            if features[96] <= 170859808.00000003 then
            begin
                if features[57] <= 1.5000000000000002 then
                begin
                    if features[175] <= -1076.4999999999998 then
                    begin
                        Result := -0.00272971144014637;
                    end
                    else
                    begin
                        Result := 0.0028231337357641152;
                    end;
                end
                else
                begin
                    if features[69] <= 6.5000000000000009 then
                    begin
                        Result := -0.014739298787045064;
                    end
                    else
                    begin
                        Result := 0.0052363267253664504;
                    end;
                end;
            end
            else
            begin
                if features[108] <= 720.50000000000011 then
                begin
                    Result := -0.018312376942996318;
                end
                else
                begin
                    Result := 0.0026906476223490911;
                end;
            end;
        end
        else
        begin
            if features[178] <= 95.500000000000014 then
            begin
                if features[67] <= 1317.5000000000002 then
                begin
                    if features[222] <= -5227.4999999999991 then
                    begin
                        Result := -0.01251450624568814;
                    end
                    else
                    begin
                        Result := 0.0097290319062580087;
                    end;
                end
                else
                begin
                    if features[183] <= -8888.9999999999982 then
                    begin
                        Result := 0.051511524209406856;
                    end
                    else
                    begin
                        Result := -0.020545753287880535;
                    end;
                end;
            end
            else
            begin
                if features[228] <= -5156.4999999999991 then
                begin
                    if features[148] <= 49.500000000000007 then
                    begin
                        Result := 0.01577004310215388;
                    end
                    else
                    begin
                        Result := -0.012766446299148399;
                    end;
                end
                else
                begin
                    if features[85] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.019427899745851237;
                    end
                    else
                    begin
                        Result := -0.0095722850087795359;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_159(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[24] <= 1.5000000000000002 then
    begin
        if features[0] <= 308393.50000000006 then
        begin
            if features[229] <= 661.50000000000011 then
            begin
                Result := -0.01380737691640084;
            end
            else
            begin
                Result := 0.015705770809262328;
            end;
        end
        else
        begin
            if features[73] <= 279.50000000000006 then
            begin
                Result := 0.072531295549790362;
            end
            else
            begin
                Result := -0.00067952129584757223;
            end;
        end;
    end
    else
    begin
        if features[106] <= -1.4999999999999998 then
        begin
            if features[179] <= -5356.4999999999991 then
            begin
                Result := 0.0068699298235726782;
            end
            else
            begin
                if features[109] <= -245.49999999999997 then
                begin
                    if features[47] <= 18652.000000000004 then
                    begin
                        Result := -0.019055906491616037;
                    end
                    else
                    begin
                        Result := 0.013086716966940757;
                    end;
                end
                else
                begin
                    Result := 0.0091459601909295012;
                end;
            end;
        end
        else
        begin
            if features[174] <= -4462.4999999999991 then
            begin
                if features[182] <= -4579.4999999999991 then
                begin
                    if features[148] <= 2746.5000000000005 then
                    begin
                        Result := -0.00034258510998930083;
                    end
                    else
                    begin
                        Result := -0.0096071325036724969;
                    end;
                end
                else
                begin
                    Result := -0.022861029977303791;
                end;
            end
            else
            begin
                if features[174] <= -4430.4999999999991 then
                begin
                    if features[217] <= 170.50000000000003 then
                    begin
                        Result := 0.026867397149785865;
                    end
                    else
                    begin
                        Result := -0.0060865894266133244;
                    end;
                end
                else
                begin
                    if features[183] <= -6586.4999999999991 then
                    begin
                        Result := -0.0092196272714333543;
                    end
                    else
                    begin
                        Result := 0.0053183204243131216;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_160(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -9.4999999999999982 then
    begin
        if features[105] <= -4.4999999999999991 then
        begin
            Result := -0.020005340324770846;
        end
        else
        begin
            if features[217] <= 294.50000000000006 then
            begin
                if features[215] <= -3454.4999999999995 then
                begin
                    if features[216] <= -3981.9999999999995 then
                    begin
                        Result := -0.0010112858575408272;
                    end
                    else
                    begin
                        Result := 0.019451253092072324;
                    end;
                end
                else
                begin
                    Result := -0.022086078090354094;
                end;
            end
            else
            begin
                if features[187] <= 75.062500000000014 then
                begin
                    Result := -0.012671842406563267;
                end
                else
                begin
                    if features[70] <= 740.50000000000011 then
                    begin
                        Result := 0.042480725587967505;
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
        if features[36] <= 721.50000000000011 then
        begin
            if features[171] <= 1.5000000000000002 then
            begin
                Result := -0.00058546971348304578;
            end
            else
            begin
                if features[225] <= -5025.4999999999991 then
                begin
                    if features[183] <= -6311.4999999999991 then
                    begin
                        Result := 0.004220327948740811;
                    end
                    else
                    begin
                        Result := -0.0072359861394901415;
                    end;
                end
                else
                begin
                    if features[108] <= -533.49999999999989 then
                    begin
                        Result := 0.029081479642230436;
                    end
                    else
                    begin
                        Result := 0.0080104679944453267;
                    end;
                end;
            end;
        end
        else
        begin
            if features[73] <= 73.500000000000014 then
            begin
                if features[216] <= -4709.4999999999991 then
                begin
                    Result := -0.015755233381494205;
                end
                else
                begin
                    Result := -0.0018795644846772192;
                end;
            end
            else
            begin
                Result := 0.007412270803109966;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_161(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[122] <= -1303.4999999999998 then
    begin
        Result := -0.011870173979363657;
    end
    else
    begin
        if features[216] <= -4389.4999999999991 then
        begin
            if features[166] <= -37863439.999999993 then
            begin
                if features[82] <= 1.0000000180025095E-35 then
                begin
                    if features[178] <= 122.50000000000001 then
                    begin
                        Result := -0.0080988473516654114;
                    end
                    else
                    begin
                        Result := 0.0012062265798155557;
                    end;
                end
                else
                begin
                    if features[176] <= -5533.4999999999991 then
                    begin
                        Result := 0.0058815507028542376;
                    end
                    else
                    begin
                        Result := -0.010685179447268177;
                    end;
                end;
            end
            else
            begin
                if features[150] <= -1.0000000180025095E-35 then
                begin
                    if features[170] <= 7.5000000000000009 then
                    begin
                        Result := 0.0054294916543246247;
                    end
                    else
                    begin
                        Result := 0.023309070911153747;
                    end;
                end
                else
                begin
                    if features[105] <= 1.5000000000000002 then
                    begin
                        Result := 0.0021926069875399371;
                    end
                    else
                    begin
                        Result := -0.0061029696841661931;
                    end;
                end;
            end;
        end
        else
        begin
            if features[174] <= -5953.4999999999991 then
            begin
                if features[222] <= -5806.4999999999991 then
                begin
                    Result := -0.019651676677091546;
                end
                else
                begin
                    Result := 0.018452125675176997;
                end;
            end
            else
            begin
                if features[175] <= -388.49999999999994 then
                begin
                    if features[41] <= 1444.5000000000002 then
                    begin
                        Result := -0.012009567978990729;
                    end
                    else
                    begin
                        Result := 0.012610426018830851;
                    end;
                end
                else
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0082256299670808563;
                    end
                    else
                    begin
                        Result := -0.0054340616743051877;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_162(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[164] <= -368292223.99999994 then
    begin
        if features[224] <= -5805.4999999999991 then
        begin
            if features[146] <= -1741.9999999999998 then
            begin
                Result := 0.042933097031556108;
            end
            else
            begin
                if features[0] <= 75458.500000000015 then
                begin
                    if features[219] <= -5916.4999999999991 then
                    begin
                        Result := -0.0085415419458597496;
                    end
                    else
                    begin
                        Result := 0.019222635665957957;
                    end;
                end
                else
                begin
                    Result := -0.023514789498399954;
                end;
            end;
        end
        else
        begin
            Result := -0.021015421817801416;
        end;
    end
    else
    begin
        if features[226] <= 1340.5000000000002 then
        begin
            if features[172] <= 2.5000000000000004 then
            begin
                if features[187] <= 10.033333301544191 then
                begin
                    if features[225] <= -4091.4999999999995 then
                    begin
                        Result := -0.00097468818115550393;
                    end
                    else
                    begin
                        Result := 0.01689682983067653;
                    end;
                end
                else
                begin
                    if features[182] <= -4579.4999999999991 then
                    begin
                        Result := 0.0090693817660641874;
                    end
                    else
                    begin
                        Result := -0.016315065000264792;
                    end;
                end;
            end
            else
            begin
                if features[227] <= -4859.4999999999991 then
                begin
                    if features[228] <= -4948.4999999999991 then
                    begin
                        Result := 0.0029199511801408719;
                    end
                    else
                    begin
                        Result := -0.0058733138098676346;
                    end;
                end
                else
                begin
                    if features[216] <= -5081.4999999999991 then
                    begin
                        Result := -0.015729630260146735;
                    end
                    else
                    begin
                        Result := -0.0033799045012955367;
                    end;
                end;
            end;
        end
        else
        begin
            if features[121] <= 1381.5000000000002 then
            begin
                Result := 0.011870559022402458;
            end
            else
            begin
                Result := -0.009005672153523046;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_163(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[24] <= 1.5000000000000002 then
    begin
        if features[47] <= 50996.500000000007 then
        begin
            if features[226] <= 510.50000000000006 then
            begin
                Result := -0.014151186263843927;
            end
            else
            begin
                Result := 0.010965613700953419;
            end;
        end
        else
        begin
            if features[37] <= 3.5000000000000004 then
            begin
                Result := -0.011726811027941229;
            end
            else
            begin
                Result := 0.077481785755030452;
            end;
        end;
    end
    else
    begin
        if features[105] <= 1.0000000180025095E-35 then
        begin
            if features[71] <= 1.5000000000000002 then
            begin
                if features[47] <= 3060.5000000000005 then
                begin
                    if features[173] <= -4397.4999999999991 then
                    begin
                        Result := 0.01619575175218765;
                    end
                    else
                    begin
                        Result := -0.024625338489574222;
                    end;
                end
                else
                begin
                    if features[81] <= -4210.4999999999991 then
                    begin
                        Result := 0.0075244580255338298;
                    end
                    else
                    begin
                        Result := -0.0079602354192584591;
                    end;
                end;
            end
            else
            begin
                if features[157] <= -6.4999999999999991 then
                begin
                    Result := -0.0073973022142321491;
                end
                else
                begin
                    if features[129] <= -13.499999999999998 then
                    begin
                        Result := 0.0011783810492675814;
                    end
                    else
                    begin
                        Result := 0.0071136677480955245;
                    end;
                end;
            end;
        end
        else
        begin
            if features[67] <= 4306.5000000000009 then
            begin
                if features[66] <= 1.0000000180025095E-35 then
                begin
                    if features[14] <= -55923515.999999993 then
                    begin
                        Result := -0.0098924133295696329;
                    end
                    else
                    begin
                        Result := 0.00092947445190103744;
                    end;
                end
                else
                begin
                    Result := -0.017165225783568598;
                end;
            end
            else
            begin
                Result := -0.013632561613401954;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_164(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.020709710779132556;
    end
    else
    begin
        if features[90] <= 1.5000000000000002 then
        begin
            if features[229] <= 154.50000000000003 then
            begin
                if features[150] <= -28.499999999999996 then
                begin
                    if features[186] <= -152.87499999999997 then
                    begin
                        Result := 0.038248988109251592;
                    end
                    else
                    begin
                        Result := -0.0074944946004077686;
                    end;
                end
                else
                begin
                    if features[94] <= -108380.99999999999 then
                    begin
                        Result := -0.016099603888340037;
                    end
                    else
                    begin
                        Result := -0.0028729947056525184;
                    end;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    if features[226] <= 1340.5000000000002 then
                    begin
                        Result := 0.0027028540400441999;
                    end
                    else
                    begin
                        Result := 0.015692593831381274;
                    end;
                end
                else
                begin
                    if features[139] <= 1.5000000000000002 then
                    begin
                        Result := -0.0025170128350932883;
                    end
                    else
                    begin
                        Result := -0.028367965253883722;
                    end;
                end;
            end;
        end
        else
        begin
            if features[47] <= 13259.000000000002 then
            begin
                if features[184] <= -1648.4999999999998 then
                begin
                    Result := 0.062740088651277517;
                end
                else
                begin
                    if features[110] <= 47.500000000000007 then
                    begin
                        Result := -0.0016261416370818877;
                    end
                    else
                    begin
                        Result := 0.0076413562780691148;
                    end;
                end;
            end
            else
            begin
                if features[217] <= 413.50000000000006 then
                begin
                    if features[173] <= -5527.4999999999991 then
                    begin
                        Result := 0.0040321692521933265;
                    end
                    else
                    begin
                        Result := 0.042086852633190813;
                    end;
                end
                else
                begin
                    Result := -0.0061146203754643995;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_165(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[146] <= 1794.5000000000002 then
    begin
        if features[172] <= 14.500000000000002 then
        begin
            if features[173] <= -3910.9999999999995 then
            begin
                if features[225] <= -3489.4999999999995 then
                begin
                    if features[54] <= 11.500000000000002 then
                    begin
                        Result := 0.00047775820154137295;
                    end
                    else
                    begin
                        Result := 0.013555919198807574;
                    end;
                end
                else
                begin
                    if features[40] <= 1267.5000000000002 then
                    begin
                        Result := 0.021307516930281937;
                    end
                    else
                    begin
                        Result := 0.0022897262263907293;
                    end;
                end;
            end
            else
            begin
                if features[219] <= -6941.4999999999991 then
                begin
                    if features[216] <= -5207.4999999999991 then
                    begin
                        Result := -0.010850212921176029;
                    end
                    else
                    begin
                        Result := 0.048938131417494479;
                    end;
                end
                else
                begin
                    if features[76] <= 2.5000000000000004 then
                    begin
                        Result := -0.0041668743942949076;
                    end
                    else
                    begin
                        Result := -0.021862904683177697;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.027030002332149607;
        end;
    end
    else
    begin
        if features[69] <= 7.5000000000000009 then
        begin
            if features[183] <= -4791.4999999999991 then
            begin
                Result := -0.023337482010418964;
            end
            else
            begin
                Result := 0.011071406249724778;
            end;
        end
        else
        begin
            if features[183] <= -5894.4999999999991 then
            begin
                if features[225] <= -5287.4999999999991 then
                begin
                    if features[178] <= 472.50000000000006 then
                    begin
                        Result := -0.023684291938915195;
                    end
                    else
                    begin
                        Result := 0.017850625947054197;
                    end;
                end
                else
                begin
                    Result := 0.032437185601852069;
                end;
            end
            else
            begin
                Result := -0.020582561393413742;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_166(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[122] <= -1102.9999999999998 then
    begin
        if features[172] <= 3.5000000000000004 then
        begin
            if features[181] <= -161.49999999999997 then
            begin
                Result := -0.013831497557642902;
            end
            else
            begin
                if features[95] <= -36761843.999999993 then
                begin
                    Result := -0.029443732382198162;
                end
                else
                begin
                    Result := 0.016248882875437704;
                end;
            end;
        end
        else
        begin
            Result := -0.018198596409740867;
        end;
    end
    else
    begin
        if features[222] <= -5358.4999999999991 then
        begin
            if features[108] <= 81.500000000000014 then
            begin
                if features[187] <= 10.033333301544191 then
                begin
                    if features[48] <= 37946.000000000007 then
                    begin
                        Result := -0.0070297904555913539;
                    end
                    else
                    begin
                        Result := 0.032421425123581801;
                    end;
                end
                else
                begin
                    if features[221] <= -4980.4999999999991 then
                    begin
                        Result := 0.0043929793104939057;
                    end
                    else
                    begin
                        Result := -0.021628159759845882;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -4992.4999999999991 then
                begin
                    Result := 0.001870270887588784;
                end
                else
                begin
                    Result := 0.043550605512749002;
                end;
            end;
        end
        else
        begin
            if features[121] <= 310.50000000000006 then
            begin
                if features[177] <= -7344.4999999999991 then
                begin
                    if features[229] <= -343.49999999999994 then
                    begin
                        Result := -0.015391943057700414;
                    end
                    else
                    begin
                        Result := 0.013730657850740581;
                    end;
                end
                else
                begin
                    if features[27] <= -3152.4999999999995 then
                    begin
                        Result := 0.0010466583867842828;
                    end
                    else
                    begin
                        Result := 0.014436535469344059;
                    end;
                end;
            end
            else
            begin
                Result := -0.0072478848112654641;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_167(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[66] <= 34.500000000000007 then
    begin
        if features[172] <= 4.5000000000000009 then
        begin
            if features[222] <= -5368.4999999999991 then
            begin
                if features[166] <= 34964100.000000007 then
                begin
                    if features[183] <= -8316.4999999999982 then
                    begin
                        Result := 0.010881004492791564;
                    end
                    else
                    begin
                        Result := -0.0039341380010727367;
                    end;
                end
                else
                begin
                    if features[165] <= 143530496.00000003 then
                    begin
                        Result := 0.0025948659123908517;
                    end
                    else
                    begin
                        Result := 0.02328762849126028;
                    end;
                end;
            end
            else
            begin
                if features[28] <= -6896.4999999999991 then
                begin
                    Result := 0.017325463616208844;
                end
                else
                begin
                    if features[225] <= -5933.4999999999991 then
                    begin
                        Result := -0.011815348963846404;
                    end
                    else
                    begin
                        Result := 0.0041309478059886042;
                    end;
                end;
            end;
        end
        else
        begin
            if features[42] <= 449.00000000000006 then
            begin
                if features[126] <= 1.0000000180025095E-35 then
                begin
                    if features[181] <= -525.49999999999989 then
                    begin
                        Result := -0.0081078859246172062;
                    end
                    else
                    begin
                        Result := 0.0047368651911538313;
                    end;
                end
                else
                begin
                    if features[141] <= -4.4999999999999991 then
                    begin
                        Result := 0.01462030487235714;
                    end
                    else
                    begin
                        Result := -0.014645828290185757;
                    end;
                end;
            end
            else
            begin
                if features[228] <= -5501.4999999999991 then
                begin
                    Result := 0.014140672053725031;
                end
                else
                begin
                    if features[222] <= -3643.4999999999995 then
                    begin
                        Result := -0.015143863646216428;
                    end
                    else
                    begin
                        Result := 0.0039127956661084177;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.011044046349478715;
    end;
end;

function second_slot_bidirectional_tree_168(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[173] <= -3910.9999999999995 then
    begin
        if features[216] <= -4054.4999999999995 then
        begin
            if features[224] <= -3740.4999999999995 then
            begin
                if features[150] <= -7.4999999999999991 then
                begin
                    if features[48] <= 21758.000000000004 then
                    begin
                        Result := 0.0031577016959472405;
                    end
                    else
                    begin
                        Result := 0.02919490813948078;
                    end;
                end
                else
                begin
                    if features[69] <= 3.5000000000000004 then
                    begin
                        Result := -0.0040416378952766721;
                    end
                    else
                    begin
                        Result := 0.0012062082730213905;
                    end;
                end;
            end
            else
            begin
                Result := -0.02383410306013797;
            end;
        end
        else
        begin
            if features[167] <= 1.5000000000000002 then
            begin
                if features[173] <= -5186.4999999999991 then
                begin
                    if features[223] <= 358.50000000000006 then
                    begin
                        Result := -0.018563742235288453;
                    end
                    else
                    begin
                        Result := 0.014790816234242414;
                    end;
                end
                else
                begin
                    if features[166] <= -111989907.99999999 then
                    begin
                        Result := 0.042022269773993343;
                    end
                    else
                    begin
                        Result := 0.016409339058314137;
                    end;
                end;
            end
            else
            begin
                if features[177] <= -6598.4999999999991 then
                begin
                    Result := 0.011481379137355453;
                end
                else
                begin
                    if features[185] <= -123.87499999999999 then
                    begin
                        Result := -0.018022208196385239;
                    end
                    else
                    begin
                        Result := 0.0013812974297258531;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= 47674426.000000007 then
        begin
            Result := -0.015358815508238814;
        end
        else
        begin
            if features[226] <= -48.499999999999993 then
            begin
                Result := -0.025553662231816921;
            end
            else
            begin
                Result := 0.022841414151464356;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_169(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[122] <= -1033.4999999999998 then
    begin
        if features[172] <= 2.5000000000000004 then
        begin
            if features[27] <= -4599.4999999999991 then
            begin
                Result := -0.013722856627120656;
            end
            else
            begin
                if features[94] <= -17014.499999999996 then
                begin
                    Result := -0.028462168235449198;
                end
                else
                begin
                    Result := 0.023272528959009331;
                end;
            end;
        end
        else
        begin
            Result := -0.016225929818251311;
        end;
    end
    else
    begin
        if features[220] <= -1252.4999999999998 then
        begin
            if features[218] <= -5503.4999999999991 then
            begin
                if features[215] <= -5360.4999999999991 then
                begin
                    if features[128] <= 25.500000000000004 then
                    begin
                        Result := -0.0028156813189108691;
                    end
                    else
                    begin
                        Result := 0.048268588251386475;
                    end;
                end
                else
                begin
                    Result := -0.01902729108310202;
                end;
            end
            else
            begin
                Result := -0.017129096705717918;
            end;
        end
        else
        begin
            if features[106] <= 1.5000000000000002 then
            begin
                if features[118] <= 1.0000000180025095E-35 then
                begin
                    if features[150] <= -1.4999999999999998 then
                    begin
                        Result := 0.0076600802635104631;
                    end
                    else
                    begin
                        Result := 0.0014517269081779376;
                    end;
                end
                else
                begin
                    if features[158] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0062080318795071998;
                    end
                    else
                    begin
                        Result := -0.012194620966308011;
                    end;
                end;
            end
            else
            begin
                if features[144] <= -439.49999999999994 then
                begin
                    Result := 0.011385921017914736;
                end
                else
                begin
                    if features[221] <= -7279.4999999999991 then
                    begin
                        Result := 0.011831219370691721;
                    end
                    else
                    begin
                        Result := -0.0051329511383470128;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_170(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[66] <= 34.500000000000007 then
    begin
        if features[15] <= -336406943.99999994 then
        begin
            if features[177] <= -6248.4999999999991 then
            begin
                Result := -0.024314085904275917;
            end
            else
            begin
                if features[70] <= 786.50000000000011 then
                begin
                    if features[165] <= 54552590.000000007 then
                    begin
                        Result := 0.057825722022223781;
                    end
                    else
                    begin
                        Result := -0.01964560197821414;
                    end;
                end
                else
                begin
                    Result := -0.019092523742320445;
                end;
            end;
        end
        else
        begin
            if features[172] <= 4.5000000000000009 then
            begin
                if features[222] <= -5207.4999999999991 then
                begin
                    if features[219] <= -7081.4999999999991 then
                    begin
                        Result := 0.0080200710641343351;
                    end
                    else
                    begin
                        Result := -0.0015644298140599798;
                    end;
                end
                else
                begin
                    if features[28] <= -6896.4999999999991 then
                    begin
                        Result := 0.018847181856325355;
                    end
                    else
                    begin
                        Result := 0.0041818708070813244;
                    end;
                end;
            end
            else
            begin
                if features[117] <= -81.499999999999986 then
                begin
                    if features[118] <= -1.4999999999999998 then
                    begin
                        Result := 0.0066423920562497423;
                    end
                    else
                    begin
                        Result := -0.016227796324364201;
                    end;
                end
                else
                begin
                    if features[43] <= 457.50000000000006 then
                    begin
                        Result := 0.0019191396183204524;
                    end
                    else
                    begin
                        Result := -0.0084721883053955043;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[225] <= -4651.4999999999991 then
        begin
            Result := -0.017155371702665814;
        end
        else
        begin
            if features[9] <= 5.5000000000000009 then
            begin
                Result := -0.012795548603889477;
            end
            else
            begin
                Result := 0.025963128441458285;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_171(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[96] <= 182914768.00000003 then
    begin
        if features[15] <= -336406943.99999994 then
        begin
            Result := -0.017120790427468394;
        end
        else
        begin
            if features[71] <= 1.5000000000000002 then
            begin
                if features[139] <= -3.4999999999999996 then
                begin
                    if features[67] <= 2611.5000000000005 then
                    begin
                        Result := 0.018441104535594218;
                    end
                    else
                    begin
                        Result := -0.0076964745416633965;
                    end;
                end
                else
                begin
                    if features[216] <= -4102.4999999999991 then
                    begin
                        Result := -0.007155047060590951;
                    end
                    else
                    begin
                        Result := 0.0079925005781726396;
                    end;
                end;
            end
            else
            begin
                if features[220] <= -996.49999999999989 then
                begin
                    if features[216] <= -6725.4999999999991 then
                    begin
                        Result := 0.0071555378178162392;
                    end
                    else
                    begin
                        Result := -0.014344059928084791;
                    end;
                end
                else
                begin
                    if features[105] <= 1.5000000000000002 then
                    begin
                        Result := 0.0037122635349412813;
                    end
                    else
                    begin
                        Result := -0.0027225153607423869;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[108] <= 782.50000000000011 then
        begin
            if features[83] <= -1.0000000180025095E-35 then
            begin
                Result := -0.023414336909035105;
            end
            else
            begin
                if features[226] <= 161.50000000000003 then
                begin
                    Result := -0.023968784619085155;
                end
                else
                begin
                    Result := 0.027855806686289349;
                end;
            end;
        end
        else
        begin
            if features[27] <= -4892.4999999999991 then
            begin
                Result := -0.020936605882701971;
            end
            else
            begin
                if features[36] <= 400.50000000000006 then
                begin
                    Result := 0.034630419633413352;
                end
                else
                begin
                    Result := -0.0089700709932254256;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_172(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[172] <= 3.5000000000000004 then
    begin
        if features[225] <= -4395.4999999999991 then
        begin
            if features[126] <= -1.0000000180025095E-35 then
            begin
                if features[107] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.0056561086430993307;
                end
                else
                begin
                    if features[155] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.010192130841113938;
                    end
                    else
                    begin
                        Result := -0.01007719722165879;
                    end;
                end;
            end
            else
            begin
                if features[109] <= 412.50000000000006 then
                begin
                    if features[225] <= -5438.4999999999991 then
                    begin
                        Result := -0.0064231197210092988;
                    end
                    else
                    begin
                        Result := 0.00088101483328263468;
                    end;
                end
                else
                begin
                    if features[222] <= -6380.4999999999991 then
                    begin
                        Result := 0.032679934264873554;
                    end
                    else
                    begin
                        Result := 0.0028557763501993495;
                    end;
                end;
            end;
        end
        else
        begin
            if features[183] <= -6736.4999999999991 then
            begin
                Result := 0.036091709132205413;
            end
            else
            begin
                if features[175] <= -505.49999999999994 then
                begin
                    Result := -0.0042587847744191276;
                end
                else
                begin
                    Result := 0.012792043199362214;
                end;
            end;
        end;
    end
    else
    begin
        if features[36] <= 697.50000000000011 then
        begin
            if features[187] <= -2.9545454978942867 then
            begin
                Result := -0.009738828357462587;
            end
            else
            begin
                if features[121] <= 1399.5000000000002 then
                begin
                    if features[27] <= -3216.4999999999995 then
                    begin
                        Result := 0.001809313655433846;
                    end
                    else
                    begin
                        Result := 0.025797682233162558;
                    end;
                end
                else
                begin
                    Result := -0.016468745614878249;
                end;
            end;
        end
        else
        begin
            Result := -0.011728801556064705;
        end;
    end;
end;

function second_slot_bidirectional_tree_173(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -312987215.99999994 then
    begin
        if features[216] <= -7163.4999999999991 then
        begin
            if features[173] <= -5748.4999999999991 then
            begin
                Result := -0.016944638328089248;
            end
            else
            begin
                if features[220] <= -1586.4999999999998 then
                begin
                    Result := -0.0098207457311070764;
                end
                else
                begin
                    Result := 0.11103164028366258;
                end;
            end;
        end
        else
        begin
            if features[69] <= 17.500000000000004 then
            begin
                Result := -0.020768310920212182;
            end
            else
            begin
                if features[218] <= -4956.4999999999991 then
                begin
                    Result := -0.016185140372473542;
                end
                else
                begin
                    if features[218] <= -4595.4999999999991 then
                    begin
                        Result := 0.095672123656358521;
                    end
                    else
                    begin
                        Result := -0.011992252166894778;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[172] <= 14.500000000000002 then
        begin
            if features[225] <= -3345.9999999999995 then
            begin
                if features[107] <= -1.4999999999999998 then
                begin
                    if features[218] <= -5909.4999999999991 then
                    begin
                        Result := -0.00029581835820798529;
                    end
                    else
                    begin
                        Result := -0.011380492631828682;
                    end;
                end
                else
                begin
                    if features[48] <= 12021.500000000002 then
                    begin
                        Result := 0.00025353927579073064;
                    end
                    else
                    begin
                        Result := 0.0082691744874128642;
                    end;
                end;
            end
            else
            begin
                if features[165] <= 362984224.00000006 then
                begin
                    Result := 0.019377968830862829;
                end
                else
                begin
                    if features[172] <= 4.5000000000000009 then
                    begin
                        Result := 0.011345692023246912;
                    end
                    else
                    begin
                        Result := -0.026552871780675974;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.026247731859182111;
        end;
    end;
end;

function second_slot_bidirectional_tree_174(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[26] <= 12.500000000000002 then
    begin
        if features[215] <= -3227.4999999999995 then
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[60] <= -1.0000000180025095E-35 then
                begin
                    if features[55] <= 4.5000000000000009 then
                    begin
                        Result := 0.0011920750884810724;
                    end
                    else
                    begin
                        Result := -0.0064304736663507167;
                    end;
                end
                else
                begin
                    if features[145] <= 334.50000000000006 then
                    begin
                        Result := -0.023630687193056922;
                    end
                    else
                    begin
                        Result := -0.0067424710875976738;
                    end;
                end;
            end
            else
            begin
                if features[36] <= 864.50000000000011 then
                begin
                    if features[150] <= 5.5000000000000009 then
                    begin
                        Result := 0.0058176699557417827;
                    end
                    else
                    begin
                        Result := 0.038919016923695378;
                    end;
                end
                else
                begin
                    if features[216] <= -4356.4999999999991 then
                    begin
                        Result := -0.024141356041025235;
                    end
                    else
                    begin
                        Result := 0.0057141633097724355;
                    end;
                end;
            end;
        end
        else
        begin
            if features[121] <= 1225.5000000000002 then
            begin
                Result := -0.025791179633577306;
            end
            else
            begin
                if features[36] <= 571.50000000000011 then
                begin
                    Result := 0.031701396341173617;
                end
                else
                begin
                    Result := -0.020969935574216329;
                end;
            end;
        end;
    end
    else
    begin
        if features[67] <= 2950.5000000000005 then
        begin
            if features[177] <= -9574.9999999999982 then
            begin
                Result := 0.035093276280510614;
            end
            else
            begin
                Result := -0.027070195851826812;
            end;
        end
        else
        begin
            if features[165] <= 230196112.00000003 then
            begin
                Result := -0.023037384158063917;
            end
            else
            begin
                Result := 0.039233166605029603;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_175(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[228] <= -3446.4999999999995 then
        begin
            if features[41] <= 1447.5000000000002 then
            begin
                if features[24] <= 1.5000000000000002 then
                begin
                    if features[0] <= 308393.50000000006 then
                    begin
                        Result := -0.010229466964729064;
                    end
                    else
                    begin
                        Result := 0.040590993644348719;
                    end;
                end
                else
                begin
                    if features[106] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0047056787765111458;
                    end
                    else
                    begin
                        Result := -0.00032896393369438227;
                    end;
                end;
            end
            else
            begin
                if features[129] <= 10812.500000000002 then
                begin
                    if features[164] <= 488074368.00000006 then
                    begin
                        Result := -0.009390954781500779;
                    end
                    else
                    begin
                        Result := 0.014897978372697886;
                    end;
                end
                else
                begin
                    if features[122] <= 1558.5000000000002 then
                    begin
                        Result := 0.022570235558058468;
                    end
                    else
                    begin
                        Result := -0.0071952676454137615;
                    end;
                end;
            end;
        end
        else
        begin
            if features[40] <= 1135.5000000000002 then
            begin
                if features[226] <= 386.50000000000006 then
                begin
                    if features[174] <= -4966.4999999999991 then
                    begin
                        Result := -0.022000882607229901;
                    end
                    else
                    begin
                        Result := 0.021635973019453098;
                    end;
                end
                else
                begin
                    Result := 0.026096624747691529;
                end;
            end
            else
            begin
                if features[224] <= -5544.4999999999991 then
                begin
                    Result := -0.029232122836921962;
                end
                else
                begin
                    if features[175] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0090400000628994021;
                    end
                    else
                    begin
                        Result := 0.015113209206781006;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.024463052754756118;
    end;
end;

function second_slot_bidirectional_tree_176(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[96] <= 182914768.00000003 then
    begin
        if features[15] <= -336406943.99999994 then
        begin
            if features[129] <= 729.50000000000011 then
            begin
                Result := -0.022826904245343827;
            end
            else
            begin
                if features[174] <= -4993.4999999999991 then
                begin
                    Result := -0.013438098039306266;
                end
                else
                begin
                    Result := 0.043745401261209065;
                end;
            end;
        end
        else
        begin
            if features[47] <= 3320.5000000000005 then
            begin
                if features[82] <= -140183.49999999997 then
                begin
                    if features[117] <= 318.50000000000006 then
                    begin
                        Result := -0.011522094660150958;
                    end
                    else
                    begin
                        Result := 0.023929754653234117;
                    end;
                end
                else
                begin
                    if features[229] <= -389.49999999999994 then
                    begin
                        Result := -0.0078253499626643186;
                    end
                    else
                    begin
                        Result := 0.0076512954995080779;
                    end;
                end;
            end
            else
            begin
                if features[53] <= 5.0000000000000009 then
                begin
                    if features[225] <= -4978.4999999999991 then
                    begin
                        Result := -0.001074114911484479;
                    end
                    else
                    begin
                        Result := 0.0066081503337978341;
                    end;
                end
                else
                begin
                    if features[175] <= -1292.4999999999998 then
                    begin
                        Result := -0.012626038917546165;
                    end
                    else
                    begin
                        Result := -0.001566699994198192;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[108] <= 748.50000000000011 then
        begin
            Result := -0.020617529008774671;
        end
        else
        begin
            if features[27] <= -4892.4999999999991 then
            begin
                Result := -0.019674815994214463;
            end
            else
            begin
                if features[42] <= 322.50000000000006 then
                begin
                    Result := 0.034482732259954976;
                end
                else
                begin
                    Result := -0.010194148287393418;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_177(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.019039797877366073;
    end
    else
    begin
        if features[55] <= 4.5000000000000009 then
        begin
            if features[164] <= -342043167.99999994 then
            begin
                if features[180] <= -9693.9999999999982 then
                begin
                    Result := 0.037061242812695842;
                end
                else
                begin
                    Result := -0.0092772088787490582;
                end;
            end
            else
            begin
                if features[36] <= 859.50000000000011 then
                begin
                    if features[219] <= -6999.4999999999991 then
                    begin
                        Result := 0.010776473761286971;
                    end
                    else
                    begin
                        Result := 0.0016403596287612042;
                    end;
                end
                else
                begin
                    if features[73] <= 113.50000000000001 then
                    begin
                        Result := -0.0099674957256457534;
                    end
                    else
                    begin
                        Result := 0.0070037469742279482;
                    end;
                end;
            end;
        end
        else
        begin
            if features[228] <= -5018.4999999999991 then
            begin
                if features[222] <= -5358.4999999999991 then
                begin
                    if features[128] <= 312.50000000000006 then
                    begin
                        Result := -0.0062573219138203386;
                    end
                    else
                    begin
                        Result := 0.035925017739988907;
                    end;
                end
                else
                begin
                    if features[218] <= -5453.4999999999991 then
                    begin
                        Result := 0.022253867200500314;
                    end
                    else
                    begin
                        Result := -0.0099121574351681702;
                    end;
                end;
            end
            else
            begin
                if features[120] <= -118.49999999999999 then
                begin
                    if features[220] <= -229.49999999999997 then
                    begin
                        Result := 0.040182468778903697;
                    end
                    else
                    begin
                        Result := -0.0027684007117544053;
                    end;
                end
                else
                begin
                    if features[158] <= 13062.500000000002 then
                    begin
                        Result := -0.016678143604855776;
                    end
                    else
                    begin
                        Result := -0.001097200607190084;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_178(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[228] <= -3446.4999999999995 then
        begin
            if features[182] <= -4579.4999999999991 then
            begin
                if features[96] <= 179340080.00000003 then
                begin
                    if features[15] <= -336406943.99999994 then
                    begin
                        Result := -0.016269784680110894;
                    end
                    else
                    begin
                        Result := 0.00080615675832267477;
                    end;
                end
                else
                begin
                    if features[184] <= 277.50000000000006 then
                    begin
                        Result := -0.022124900692629845;
                    end
                    else
                    begin
                        Result := -0.0014173139071972549;
                    end;
                end;
            end
            else
            begin
                if features[185] <= -126.36666870117186 then
                begin
                    if features[182] <= -3844.4999999999995 then
                    begin
                        Result := -0.025189894236675822;
                    end
                    else
                    begin
                        Result := -0.0034233870937534247;
                    end;
                end
                else
                begin
                    if features[70] <= 888.50000000000011 then
                    begin
                        Result := -0.0055974438784222522;
                    end
                    else
                    begin
                        Result := 0.022109251715507382;
                    end;
                end;
            end;
        end
        else
        begin
            if features[40] <= 1138.5000000000002 then
            begin
                if features[28] <= -4944.4999999999991 then
                begin
                    Result := 0.028660018823776674;
                end
                else
                begin
                    if features[216] <= -4044.4999999999995 then
                    begin
                        Result := -0.0054257837468125441;
                    end
                    else
                    begin
                        Result := 0.02713006972017161;
                    end;
                end;
            end
            else
            begin
                if features[94] <= -63517.999999999993 then
                begin
                    Result := 0.026630618149880998;
                end
                else
                begin
                    if features[177] <= -4836.4999999999991 then
                    begin
                        Result := -0.014386595359926405;
                    end
                    else
                    begin
                        Result := 0.011791377768292864;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.020893035302366313;
    end;
end;

function second_slot_bidirectional_tree_179(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[55] <= 4.5000000000000009 then
    begin
        if features[126] <= 1.0000000180025095E-35 then
        begin
            if features[47] <= 3320.5000000000005 then
            begin
                if features[15] <= -142486575.99999997 then
                begin
                    Result := -0.0072603500561828549;
                end
                else
                begin
                    if features[216] <= -5195.4999999999991 then
                    begin
                        Result := 0.016760408417684537;
                    end
                    else
                    begin
                        Result := 0.0031352870875509735;
                    end;
                end;
            end
            else
            begin
                if features[175] <= -272.49999999999994 then
                begin
                    if features[27] <= -5289.4999999999991 then
                    begin
                        Result := 0.0026064504392425488;
                    end
                    else
                    begin
                        Result := -0.0055739403276752215;
                    end;
                end
                else
                begin
                    Result := 0.0028512033121334962;
                end;
            end;
        end
        else
        begin
            if features[177] <= -6095.4999999999991 then
            begin
                if features[141] <= -3.4999999999999996 then
                begin
                    if features[165] <= -94406119.999999985 then
                    begin
                        Result := -0.01092853436529144;
                    end
                    else
                    begin
                        Result := 0.019592125988235096;
                    end;
                end
                else
                begin
                    if features[69] <= 18.500000000000004 then
                    begin
                        Result := -0.012750116736416045;
                    end
                    else
                    begin
                        Result := 0.0061143280669707185;
                    end;
                end;
            end
            else
            begin
                Result := 0.0042581658250114909;
            end;
        end;
    end
    else
    begin
        if features[109] <= -184.49999999999997 then
        begin
            Result := -0.017027780763227789;
        end
        else
        begin
            if features[228] <= -5156.4999999999991 then
            begin
                if features[222] <= -5248.4999999999991 then
                begin
                    Result := 5.5929177866246965E-05;
                end
                else
                begin
                    Result := 0.0263444100576131;
                end;
            end
            else
            begin
                Result := -0.0086571223286530073;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_180(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[164] <= -342043167.99999994 then
    begin
        if features[40] <= 1429.5000000000002 then
        begin
            if features[219] <= -4751.4999999999991 then
            begin
                Result := -0.012184244681544698;
            end
            else
            begin
                Result := 0.016145451666332522;
            end;
        end
        else
        begin
            if features[221] <= -6629.4999999999991 then
            begin
                Result := 0.051770181948483589;
            end
            else
            begin
                Result := -0.0067799511207811171;
            end;
        end;
    end
    else
    begin
        if features[55] <= 4.5000000000000009 then
        begin
            if features[26] <= 1.5000000000000002 then
            begin
                Result := -0.017978989357181348;
            end
            else
            begin
                if features[155] <= 1.5000000000000002 then
                begin
                    if features[156] <= 1.5000000000000002 then
                    begin
                        Result := 0.0018703362633361691;
                    end
                    else
                    begin
                        Result := 0.0377166007942576;
                    end;
                end
                else
                begin
                    if features[28] <= -7974.4999999999991 then
                    begin
                        Result := 0.024523273891429852;
                    end
                    else
                    begin
                        Result := -0.0067656539879223437;
                    end;
                end;
            end;
        end
        else
        begin
            if features[77] <= 30646.000000000004 then
            begin
                if features[67] <= 1317.5000000000002 then
                begin
                    if features[173] <= -4410.4999999999991 then
                    begin
                        Result := -0.0040224193565305197;
                    end
                    else
                    begin
                        Result := 0.021629068296114048;
                    end;
                end
                else
                begin
                    if features[216] <= -6911.4999999999991 then
                    begin
                        Result := 0.028158558899727001;
                    end
                    else
                    begin
                        Result := -0.015283019490001524;
                    end;
                end;
            end
            else
            begin
                if features[185] <= 64.708332061767592 then
                begin
                    Result := -0.0059376050255594308;
                end
                else
                begin
                    Result := 0.025136237381541221;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_181(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[122] <= -1102.9999999999998 then
    begin
        if features[171] <= 3.5000000000000004 then
        begin
            Result := -0.016042833492467743;
        end
        else
        begin
            if features[223] <= 125.50000000000001 then
            begin
                if features[47] <= 27972.500000000004 then
                begin
                    if features[121] <= -1282.4999999999998 then
                    begin
                        Result := 0.033253947023757932;
                    end
                    else
                    begin
                        Result := -0.025107749342091014;
                    end;
                end
                else
                begin
                    Result := 0.053438261031655936;
                end;
            end
            else
            begin
                Result := 0.017762683352190375;
            end;
        end;
    end
    else
    begin
        if features[225] <= -3827.4999999999995 then
        begin
            if features[182] <= -4579.4999999999991 then
            begin
                if features[150] <= -1.0000000180025095E-35 then
                begin
                    if features[129] <= -238.99999999999997 then
                    begin
                        Result := -0.0019266568557998226;
                    end
                    else
                    begin
                        Result := 0.007271584281676075;
                    end;
                end
                else
                begin
                    if features[69] <= 9.5000000000000018 then
                    begin
                        Result := -0.0036262417692818367;
                    end
                    else
                    begin
                        Result := 0.0025433713237869599;
                    end;
                end;
            end
            else
            begin
                if features[154] <= 447.50000000000006 then
                begin
                    if features[108] <= -25.499999999999996 then
                    begin
                        Result := -0.02292648517769038;
                    end
                    else
                    begin
                        Result := 0.010522184944402378;
                    end;
                end
                else
                begin
                    Result := 0.020019436298558752;
                end;
            end;
        end
        else
        begin
            if features[187] <= 5.3541667461395273 then
            begin
                Result := 0.018206498972164357;
            end
            else
            begin
                if features[226] <= 439.50000000000006 then
                begin
                    Result := -0.018096386447257803;
                end
                else
                begin
                    Result := 0.0071346164637893922;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_182(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        if features[216] <= -8625.4999999999982 then
        begin
            Result := 0.023391881272819603;
        end
        else
        begin
            Result := -0.022104732700175756;
        end;
    end
    else
    begin
        if features[95] <= -290593695.99999994 then
        begin
            if features[150] <= -22.499999999999996 then
            begin
                Result := 0.026338856029676058;
            end
            else
            begin
                if features[215] <= -4079.4999999999995 then
                begin
                    if features[174] <= -4547.4999999999991 then
                    begin
                        Result := -0.023379504818518349;
                    end
                    else
                    begin
                        Result := 0.0085604122788492682;
                    end;
                end
                else
                begin
                    if features[154] <= -498.49999999999994 then
                    begin
                        Result := 0.061730917473233463;
                    end
                    else
                    begin
                        Result := -0.0062734409919077546;
                    end;
                end;
            end;
        end
        else
        begin
            if features[57] <= 1.5000000000000002 then
            begin
                if features[9] <= 11.500000000000002 then
                begin
                    if features[180] <= -9444.9999999999982 then
                    begin
                        Result := 0.034108795627803251;
                    end
                    else
                    begin
                        Result := 0.00039259757536843867;
                    end;
                end
                else
                begin
                    if features[180] <= -7261.4999999999991 then
                    begin
                        Result := -0.0061870080170478414;
                    end
                    else
                    begin
                        Result := 0.020598147559162089;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 5.5000000000000009 then
                begin
                    if features[222] <= -3992.4999999999995 then
                    begin
                        Result := -0.020095264027564726;
                    end
                    else
                    begin
                        Result := 0.017911188663500638;
                    end;
                end
                else
                begin
                    if features[175] <= 405.50000000000006 then
                    begin
                        Result := -0.012199074859928917;
                    end
                    else
                    begin
                        Result := 0.019430708690540536;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_183(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[24] <= 1.5000000000000002 then
    begin
        if features[0] <= 308393.50000000006 then
        begin
            Result := -0.010158653821070791;
        end
        else
        begin
            Result := 0.036235535672786673;
        end;
    end
    else
    begin
        if features[105] <= 1.0000000180025095E-35 then
        begin
            if features[216] <= -4017.4999999999995 then
            begin
                if features[182] <= -4541.4999999999991 then
                begin
                    if features[169] <= 1.5000000000000002 then
                    begin
                        Result := -0.00094025208624729276;
                    end
                    else
                    begin
                        Result := 0.00438159853298204;
                    end;
                end
                else
                begin
                    Result := -0.018329030493868741;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    if features[226] <= -264.49999999999994 then
                    begin
                        Result := 0.045245709139130889;
                    end
                    else
                    begin
                        Result := 0.012407461967302436;
                    end;
                end
                else
                begin
                    Result := 0.003613572208418413;
                end;
            end;
        end
        else
        begin
            if features[220] <= 373.50000000000006 then
            begin
                if features[146] <= -11.499999999999998 then
                begin
                    Result := 0.0074564410689423946;
                end
                else
                begin
                    if features[1] <= 303710.00000000006 then
                    begin
                        Result := -0.0091667880445709653;
                    end
                    else
                    begin
                        Result := 0.037313306866498634;
                    end;
                end;
            end
            else
            begin
                if features[47] <= 4513.5000000000009 then
                begin
                    if features[121] <= 1378.5000000000002 then
                    begin
                        Result := 0.0058682872520832898;
                    end
                    else
                    begin
                        Result := -0.011869295062523351;
                    end;
                end
                else
                begin
                    if features[215] <= -6522.4999999999991 then
                    begin
                        Result := -0.024735389514677096;
                    end
                    else
                    begin
                        Result := -0.0023290641129567638;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_184(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[182] <= -4680.4999999999991 then
    begin
        if features[15] <= -336406943.99999994 then
        begin
            Result := -0.018360625527905954;
        end
        else
        begin
            if features[96] <= 182914768.00000003 then
            begin
                if features[172] <= 14.500000000000002 then
                begin
                    if features[225] <= -3663.4999999999995 then
                    begin
                        Result := 0.0011342007550894598;
                    end
                    else
                    begin
                        Result := 0.012646064501697113;
                    end;
                end
                else
                begin
                    Result := -0.025059096927136044;
                end;
            end
            else
            begin
                if features[178] <= 326.50000000000006 then
                begin
                    Result := -0.022741153127223766;
                end
                else
                begin
                    if features[164] <= -70801895.999999985 then
                    begin
                        Result := -0.026622932868784394;
                    end
                    else
                    begin
                        Result := 0.0044593758650573112;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[184] <= -132.49999999999997 then
        begin
            if features[77] <= 4775.0000000000009 then
            begin
                if features[171] <= 1.5000000000000002 then
                begin
                    if features[178] <= -31.499999999999996 then
                    begin
                        Result := -0.025997872725552908;
                    end
                    else
                    begin
                        Result := 0.037850670477199193;
                    end;
                end
                else
                begin
                    Result := 0.00046654862069860455;
                end;
            end
            else
            begin
                Result := -0.023554598983283076;
            end;
        end
        else
        begin
            if features[217] <= -327.49999999999994 then
            begin
                Result := -0.028647017675774124;
            end
            else
            begin
                if features[217] <= 559.50000000000011 then
                begin
                    if features[36] <= 697.50000000000011 then
                    begin
                        Result := 0.030847090873663392;
                    end
                    else
                    begin
                        Result := -0.007216114429724009;
                    end;
                end
                else
                begin
                    Result := -0.016193097984614605;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_185(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= 218.50000000000003 then
    begin
        if features[74] <= 15.500000000000002 then
        begin
            if features[227] <= -4849.4999999999991 then
            begin
                if features[48] <= 50626.500000000007 then
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := -0.0040543656335633007;
                    end
                    else
                    begin
                        Result := 0.0032766683091390207;
                    end;
                end
                else
                begin
                    Result := 0.03983257717426681;
                end;
            end
            else
            begin
                if features[164] <= -73001447.999999985 then
                begin
                    Result := -0.015188924394098241;
                end
                else
                begin
                    if features[73] <= 119.50000000000001 then
                    begin
                        Result := -0.0066462844388145356;
                    end
                    else
                    begin
                        Result := 0.0021676082785685286;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.014594966387437951;
        end;
    end
    else
    begin
        if features[172] <= 4.5000000000000009 then
        begin
            if features[215] <= -5039.4999999999991 then
            begin
                if features[27] <= -4521.4999999999991 then
                begin
                    if features[222] <= -4686.4999999999991 then
                    begin
                        Result := 0.0023525190993079863;
                    end
                    else
                    begin
                        Result := 0.016681139290227357;
                    end;
                end
                else
                begin
                    Result := -0.0042445291901453009;
                end;
            end
            else
            begin
                if features[166] <= -131156291.99999999 then
                begin
                    Result := 0.035531632573340279;
                end
                else
                begin
                    Result := 0.0088618302472101961;
                end;
            end;
        end
        else
        begin
            if features[126] <= 1.0000000180025095E-35 then
            begin
                if features[43] <= 457.50000000000006 then
                begin
                    Result := 0.0027076488124878877;
                end
                else
                begin
                    Result := -0.0091201818989736626;
                end;
            end
            else
            begin
                Result := -0.01634483916588729;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_186(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[66] <= 108.50000000000001 then
        begin
            if features[15] <= -336406943.99999994 then
            begin
                if features[129] <= 729.50000000000011 then
                begin
                    Result := -0.024135918686300727;
                end
                else
                begin
                    if features[174] <= -4993.4999999999991 then
                    begin
                        Result := -0.012559707246665261;
                    end
                    else
                    begin
                        Result := 0.044896980904619611;
                    end;
                end;
            end
            else
            begin
                if features[182] <= -4541.4999999999991 then
                begin
                    if features[225] <= -3663.4999999999995 then
                    begin
                        Result := 0.0008253163912570389;
                    end
                    else
                    begin
                        Result := 0.011579830846327632;
                    end;
                end
                else
                begin
                    if features[227] <= -4009.4999999999995 then
                    begin
                        Result := -0.02082655602036609;
                    end
                    else
                    begin
                        Result := 0.0044581903135232541;
                    end;
                end;
            end;
        end
        else
        begin
            if features[215] <= -4727.4999999999991 then
            begin
                if features[175] <= 2402.5000000000005 then
                begin
                    if features[28] <= -8230.4999999999982 then
                    begin
                        Result := 0.011595432500454042;
                    end
                    else
                    begin
                        Result := -0.02107344354361957;
                    end;
                end
                else
                begin
                    if features[184] <= 753.50000000000011 then
                    begin
                        Result := 0.023888513467501121;
                    end
                    else
                    begin
                        Result := -0.017057383901437087;
                    end;
                end;
            end
            else
            begin
                if features[144] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.056912269565029587;
                end
                else
                begin
                    if features[0] <= 39829.000000000007 then
                    begin
                        Result := 0.033267144398179398;
                    end
                    else
                    begin
                        Result := -0.0080578722558158049;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.023927706386470883;
    end;
end;

function second_slot_bidirectional_tree_187(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[223] <= -1337.4999999999998 then
    begin
        if features[118] <= -1.4999999999999998 then
        begin
            Result := 0.0074742612712816849;
        end
        else
        begin
            Result := -0.022191616774852971;
        end;
    end
    else
    begin
        if features[55] <= 4.5000000000000009 then
        begin
            if features[37] <= 7.5000000000000009 then
            begin
                if features[146] <= 1794.5000000000002 then
                begin
                    if features[166] <= 47674426.000000007 then
                    begin
                        Result := 0.00078581445496484154;
                    end
                    else
                    begin
                        Result := 0.0054767802591072926;
                    end;
                end
                else
                begin
                    if features[151] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0049291326988646252;
                    end
                    else
                    begin
                        Result := -0.028111078436838674;
                    end;
                end;
            end
            else
            begin
                if features[223] <= 134.50000000000003 then
                begin
                    if features[81] <= 11164.500000000002 then
                    begin
                        Result := -0.0084367239139183405;
                    end
                    else
                    begin
                        Result := -0.02298845315504533;
                    end;
                end
                else
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := -0.012512652667387681;
                    end
                    else
                    begin
                        Result := 0.0071784483733730101;
                    end;
                end;
            end;
        end
        else
        begin
            if features[77] <= 5387.5000000000009 then
            begin
                Result := -0.024340527079975725;
            end
            else
            begin
                if features[179] <= -6945.4999999999991 then
                begin
                    if features[128] <= 312.50000000000006 then
                    begin
                        Result := -7.1658135146287049E-05;
                    end
                    else
                    begin
                        Result := 0.040633999620977579;
                    end;
                end
                else
                begin
                    if features[121] <= -1138.4999999999998 then
                    begin
                        Result := 0.020995359586375391;
                    end
                    else
                    begin
                        Result := -0.010554896150766685;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_188(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[172] <= 2.5000000000000004 then
    begin
        if features[225] <= -4959.4999999999991 then
        begin
            if features[187] <= 10.033333301544191 then
            begin
                if features[108] <= 399.50000000000006 then
                begin
                    if features[96] <= 36617348.000000007 then
                    begin
                        Result := -0.0033178137502395686;
                    end
                    else
                    begin
                        Result := -0.020512470532834066;
                    end;
                end
                else
                begin
                    if features[178] <= 227.50000000000003 then
                    begin
                        Result := -0.022674616297247284;
                    end
                    else
                    begin
                        Result := 0.013892566268754125;
                    end;
                end;
            end
            else
            begin
                Result := 0.0070678604050215064;
            end;
        end
        else
        begin
            if features[28] <= -5320.4999999999991 then
            begin
                if features[222] <= -5905.4999999999991 then
                begin
                    if features[18] <= 8.5000000000000018 then
                    begin
                        Result := -0.016456918002150964;
                    end
                    else
                    begin
                        Result := 0.012163581726812166;
                    end;
                end
                else
                begin
                    Result := 0.012978112671644566;
                end;
            end
            else
            begin
                if features[177] <= -4437.9999999999991 then
                begin
                    Result := -0.0033842166595535426;
                end
                else
                begin
                    Result := 0.018669212931226645;
                end;
            end;
        end;
    end
    else
    begin
        if features[227] <= -4830.4999999999991 then
        begin
            if features[121] <= 1552.5000000000002 then
            begin
                Result := 0.0011823021845550762;
            end
            else
            begin
                Result := -0.017606675208879295;
            end;
        end
        else
        begin
            if features[216] <= -4917.4999999999991 then
            begin
                Result := -0.013939487391213519;
            end
            else
            begin
                if features[121] <= 1312.5000000000002 then
                begin
                    Result := 0.00046208331115806385;
                end
                else
                begin
                    Result := -0.017733444552084959;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_189(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[27] <= -2884.4999999999995 then
    begin
        if features[182] <= -4579.4999999999991 then
        begin
            if features[15] <= -272749359.99999994 then
            begin
                if features[216] <= -7225.4999999999991 then
                begin
                    if features[164] <= -92951159.999999985 then
                    begin
                        Result := -0.014925224201856602;
                    end
                    else
                    begin
                        Result := 0.082006676605728079;
                    end;
                end
                else
                begin
                    if features[177] <= -6248.4999999999991 then
                    begin
                        Result := -0.02246437605122148;
                    end
                    else
                    begin
                        Result := 0.0012743297901992032;
                    end;
                end;
            end
            else
            begin
                if features[107] <= -1.4999999999999998 then
                begin
                    if features[218] <= -5909.4999999999991 then
                    begin
                        Result := 0.00072632333862919464;
                    end
                    else
                    begin
                        Result := -0.011390655473662447;
                    end;
                end
                else
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0039012397476107605;
                    end
                    else
                    begin
                        Result := -0.00063055577323016868;
                    end;
                end;
            end;
        end
        else
        begin
            if features[123] <= -132.49999999999997 then
            begin
                if features[187] <= -1.3166666626930235 then
                begin
                    if features[41] <= 1198.5000000000002 then
                    begin
                        Result := -0.013517152873601918;
                    end
                    else
                    begin
                        Result := 0.042716982876239463;
                    end;
                end
                else
                begin
                    Result := 0.067287354707529709;
                end;
            end
            else
            begin
                Result := -0.017113588907061831;
            end;
        end;
    end
    else
    begin
        if features[108] <= -294.49999999999994 then
        begin
            Result := -0.01786994789355012;
        end
        else
        begin
            if features[150] <= 1.5000000000000002 then
            begin
                Result := 0.023132628477669677;
            end
            else
            begin
                Result := -0.0015982978003556596;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_190(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[95] <= -294076223.99999994 then
    begin
        if features[13] <= 225253.00000000003 then
        begin
            if features[229] <= 969.50000000000011 then
            begin
                Result := -0.021168103849626575;
            end
            else
            begin
                Result := 0.017772888972782574;
            end;
        end
        else
        begin
            Result := 0.048008337772386084;
        end;
    end
    else
    begin
        if features[220] <= -1272.4999999999998 then
        begin
            if features[221] <= -6096.4999999999991 then
            begin
                if features[221] <= -6504.4999999999991 then
                begin
                    Result := -0.022743560816402525;
                end
                else
                begin
                    if features[45] <= 3.5000000000000004 then
                    begin
                        Result := 0.04609961222268754;
                    end
                    else
                    begin
                        Result := -0.0094240571729523083;
                    end;
                end;
            end
            else
            begin
                Result := -0.015425586401301129;
            end;
        end
        else
        begin
            if features[150] <= -1.4999999999999998 then
            begin
                if features[129] <= -4064.4999999999995 then
                begin
                    if features[226] <= 814.50000000000011 then
                    begin
                        Result := -0.0046856673087151751;
                    end
                    else
                    begin
                        Result := 0.010890096694616935;
                    end;
                end
                else
                begin
                    if features[176] <= -6072.4999999999991 then
                    begin
                        Result := 0.010375315640549601;
                    end
                    else
                    begin
                        Result := -0.00048373936065879543;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 9.5000000000000018 then
                begin
                    if features[47] <= 3430.5000000000005 then
                    begin
                        Result := 0.0028455758695993274;
                    end
                    else
                    begin
                        Result := -0.0039930718009599303;
                    end;
                end
                else
                begin
                    if features[77] <= 2354.0000000000005 then
                    begin
                        Result := -0.0055142358757260951;
                    end
                    else
                    begin
                        Result := 0.005441550625630621;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_191(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[15] <= -179339415.99999997 then
    begin
        if features[69] <= 10.500000000000002 then
        begin
            if features[185] <= -422.83332824707026 then
            begin
                if features[166] <= -258758599.99999997 then
                begin
                    Result := -0.017904621930106942;
                end
                else
                begin
                    if features[154] <= -73.499999999999986 then
                    begin
                        Result := -0.0031816520018105032;
                    end
                    else
                    begin
                        Result := 0.057158575713291686;
                    end;
                end;
            end
            else
            begin
                Result := -0.015791556815395378;
            end;
        end
        else
        begin
            if features[13] <= -33176.999999999993 then
            begin
                Result := 0.06793062770117006;
            end
            else
            begin
                if features[175] <= 68.500000000000014 then
                begin
                    Result := -0.007992923829496108;
                end
                else
                begin
                    Result := 0.017784836823485577;
                end;
            end;
        end;
    end
    else
    begin
        if features[36] <= 904.50000000000011 then
        begin
            if features[228] <= -3446.4999999999995 then
            begin
                if features[179] <= -5336.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0021406003804965686;
                    end
                    else
                    begin
                        Result := -0.0038240216365698757;
                    end;
                end
                else
                begin
                    if features[109] <= -245.49999999999997 then
                    begin
                        Result := -0.012578400852303077;
                    end
                    else
                    begin
                        Result := 0.0022222289428360385;
                    end;
                end;
            end
            else
            begin
                Result := 0.013442705619850706;
            end;
        end
        else
        begin
            if features[73] <= 73.500000000000014 then
            begin
                Result := -0.012873462140014447;
            end
            else
            begin
                if features[36] <= 964.50000000000011 then
                begin
                    Result := -0.011999902746556027;
                end
                else
                begin
                    Result := 0.02077338892149427;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_192(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[15] <= -336406943.99999994 then
    begin
        Result := -0.018251744973708735;
    end
    else
    begin
        if features[121] <= 223.50000000000003 then
        begin
            if features[229] <= 795.50000000000011 then
            begin
                if features[220] <= -996.49999999999989 then
                begin
                    if features[218] <= -5673.4999999999991 then
                    begin
                        Result := 0.0076008517481551061;
                    end
                    else
                    begin
                        Result := -0.012482737329372263;
                    end;
                end
                else
                begin
                    if features[71] <= 1.5000000000000002 then
                    begin
                        Result := -0.004239110364193938;
                    end
                    else
                    begin
                        Result := 0.0011397804974384435;
                    end;
                end;
            end
            else
            begin
                if features[124] <= 503.50000000000006 then
                begin
                    if features[225] <= -4248.4999999999991 then
                    begin
                        Result := 0.0040217964028483886;
                    end
                    else
                    begin
                        Result := 0.015557664056340851;
                    end;
                end
                else
                begin
                    Result := -0.025308560142645199;
                end;
            end;
        end
        else
        begin
            if features[222] <= -5153.4999999999991 then
            begin
                if features[177] <= -5656.4999999999991 then
                begin
                    Result := -0.0011246694753644995;
                end
                else
                begin
                    if features[117] <= 312.50000000000006 then
                    begin
                        Result := 0.054244384433281556;
                    end
                    else
                    begin
                        Result := -0.0017663507661255199;
                    end;
                end;
            end
            else
            begin
                if features[73] <= 236.50000000000003 then
                begin
                    if features[218] <= -7283.4999999999991 then
                    begin
                        Result := 0.019476074904503704;
                    end
                    else
                    begin
                        Result := -0.014390961868062935;
                    end;
                end
                else
                begin
                    if features[148] <= 1366.5000000000002 then
                    begin
                        Result := -0.01407591180838693;
                    end
                    else
                    begin
                        Result := 0.015169537763474746;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_193(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[15] <= -331810335.99999994 then
    begin
        if features[174] <= -4783.4999999999991 then
        begin
            Result := -0.024230016723477892;
        end
        else
        begin
            if features[150] <= 2.5000000000000004 then
            begin
                Result := -0.0049657283948660582;
            end
            else
            begin
                Result := 0.053229399242133262;
            end;
        end;
    end
    else
    begin
        if features[219] <= -7019.4999999999991 then
        begin
            if features[14] <= -249622351.99999997 then
            begin
                Result := -0.020589968563486577;
            end
            else
            begin
                if features[215] <= -8020.9999999999991 then
                begin
                    Result := -0.029003740093845209;
                end
                else
                begin
                    if features[179] <= -8217.4999999999982 then
                    begin
                        Result := 0.02943134592915574;
                    end
                    else
                    begin
                        Result := 0.0074717557148918758;
                    end;
                end;
            end;
        end
        else
        begin
            if features[173] <= -3910.9999999999995 then
            begin
                if features[122] <= -1033.4999999999998 then
                begin
                    if features[171] <= 3.5000000000000004 then
                    begin
                        Result := -0.015984659980874661;
                    end
                    else
                    begin
                        Result := 0.0037236406648262876;
                    end;
                end
                else
                begin
                    if features[222] <= -5207.4999999999991 then
                    begin
                        Result := -0.0013789051057273537;
                    end
                    else
                    begin
                        Result := 0.0031429930227823131;
                    end;
                end;
            end
            else
            begin
                if features[166] <= 47674426.000000007 then
                begin
                    if features[151] <= -55.499999999999993 then
                    begin
                        Result := -0.024814936411952343;
                    end
                    else
                    begin
                        Result := -0.0081353978329337089;
                    end;
                end
                else
                begin
                    if features[218] <= -5432.4999999999991 then
                    begin
                        Result := 0.024910979733634823;
                    end
                    else
                    begin
                        Result := -0.015946635651011686;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_194(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[15] <= -331810335.99999994 then
    begin
        Result := -0.017623723739414298;
    end
    else
    begin
        if features[122] <= -1303.4999999999998 then
        begin
            if features[28] <= -5493.4999999999991 then
            begin
                if features[221] <= -5895.4999999999991 then
                begin
                    Result := -0.003748280976767378;
                end
                else
                begin
                    Result := -0.025008968828840589;
                end;
            end
            else
            begin
                if features[171] <= 4.5000000000000009 then
                begin
                    if features[148] <= -1349.4999999999998 then
                    begin
                        Result := 0.008570939002755287;
                    end
                    else
                    begin
                        Result := -0.023036963773566132;
                    end;
                end
                else
                begin
                    if features[219] <= -5533.4999999999991 then
                    begin
                        Result := -0.011618714842370504;
                    end
                    else
                    begin
                        Result := 0.03799289240308764;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4044.4999999999995 then
            begin
                if features[171] <= 5.5000000000000009 then
                begin
                    if features[148] <= 2746.5000000000005 then
                    begin
                        Result := 0.0016456145512924254;
                    end
                    else
                    begin
                        Result := -0.007209121803495061;
                    end;
                end
                else
                begin
                    if features[223] <= 201.50000000000003 then
                    begin
                        Result := -0.0094918373744366652;
                    end
                    else
                    begin
                        Result := 0.0016064252248498391;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -3965.4999999999995 then
                begin
                    if features[166] <= -58468385.999999993 then
                    begin
                        Result := 0.027550409730643668;
                    end
                    else
                    begin
                        Result := 0.006253197982063835;
                    end;
                end
                else
                begin
                    if features[229] <= -20.499999999999996 then
                    begin
                        Result := -0.0094304683978273969;
                    end
                    else
                    begin
                        Result := 0.0050138364695728709;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_195(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[57] <= 1.5000000000000002 then
    begin
        if features[9] <= 11.500000000000002 then
        begin
            if features[122] <= -1033.4999999999998 then
            begin
                if features[171] <= 4.5000000000000009 then
                begin
                    Result := -0.014336821208644128;
                end
                else
                begin
                    if features[165] <= 281574016.00000006 then
                    begin
                        Result := -0.0060248359780442594;
                    end
                    else
                    begin
                        Result := 0.033692701128853038;
                    end;
                end;
            end
            else
            begin
                if features[55] <= 4.5000000000000009 then
                begin
                    if features[180] <= -9444.9999999999982 then
                    begin
                        Result := 0.029933373271641046;
                    end
                    else
                    begin
                        Result := 0.0010569814401603134;
                    end;
                end
                else
                begin
                    if features[109] <= 26.500000000000004 then
                    begin
                        Result := -0.010883409208082362;
                    end
                    else
                    begin
                        Result := -0.0002470040573351929;
                    end;
                end;
            end;
        end
        else
        begin
            if features[183] <= -7146.4999999999991 then
            begin
                Result := -0.0051128669257179162;
            end
            else
            begin
                if features[0] <= 31770.500000000004 then
                begin
                    Result := -0.0178652851646387;
                end
                else
                begin
                    if features[158] <= 37562.500000000007 then
                    begin
                        Result := 0.034640739047411877;
                    end
                    else
                    begin
                        Result := 0.011043488190755221;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[175] <= 405.50000000000006 then
        begin
            Result := -0.018020119712675996;
        end
        else
        begin
            if features[69] <= 5.5000000000000009 then
            begin
                Result := -0.012413106218994297;
            end
            else
            begin
                if features[175] <= 1021.5000000000001 then
                begin
                    Result := 0.041769264598632769;
                end
                else
                begin
                    Result := -0.0041861253955016659;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_196(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[96] <= 182914768.00000003 then
    begin
        if features[15] <= -274806975.99999994 then
        begin
            if features[148] <= -3899.9999999999995 then
            begin
                if features[228] <= -5261.4999999999991 then
                begin
                    Result := 0.089186625062424668;
                end
                else
                begin
                    Result := -0.017547968119205924;
                end;
            end
            else
            begin
                Result := -0.014057343012648936;
            end;
        end
        else
        begin
            if features[146] <= 1794.5000000000002 then
            begin
                if features[182] <= -4579.4999999999991 then
                begin
                    if features[105] <= 2.5000000000000004 then
                    begin
                        Result := 0.0021160265506680234;
                    end
                    else
                    begin
                        Result := -0.0034202672137891737;
                    end;
                end
                else
                begin
                    if features[108] <= -294.49999999999994 then
                    begin
                        Result := -0.021272013990463676;
                    end
                    else
                    begin
                        Result := 0.00264393766134;
                    end;
                end;
            end
            else
            begin
                if features[90] <= 4.5000000000000009 then
                begin
                    Result := -0.019119447985454452;
                end
                else
                begin
                    if features[185] <= 233.41666412353518 then
                    begin
                        Result := -0.015565484048546069;
                    end
                    else
                    begin
                        Result := 0.041861693618706938;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= 91686248.000000015 then
        begin
            Result := -0.024273307874399221;
        end
        else
        begin
            if features[129] <= -11810.999999999998 then
            begin
                Result := -0.03465655313847496;
            end
            else
            begin
                if features[164] <= 95188640.000000015 then
                begin
                    if features[226] <= 153.50000000000003 then
                    begin
                        Result := 0.013734017036121189;
                    end
                    else
                    begin
                        Result := -0.029773696265310307;
                    end;
                end
                else
                begin
                    Result := 0.013308275781163581;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_197(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[146] <= 1779.5000000000002 then
        begin
            if features[118] <= -1.0000000180025095E-35 then
            begin
                if features[218] <= -5806.4999999999991 then
                begin
                    if features[155] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0081673790364185234;
                    end
                    else
                    begin
                        Result := -0.00075245749716408182;
                    end;
                end
                else
                begin
                    if features[117] <= 302.50000000000006 then
                    begin
                        Result := 0.002350604794013712;
                    end
                    else
                    begin
                        Result := -0.0080836878283114359;
                    end;
                end;
            end
            else
            begin
                if features[178] <= -1207.4999999999998 then
                begin
                    if features[225] <= -3827.4999999999995 then
                    begin
                        Result := -0.011309265310806914;
                    end
                    else
                    begin
                        Result := 0.030655087562217589;
                    end;
                end
                else
                begin
                    if features[107] <= -1.4999999999999998 then
                    begin
                        Result := -0.0098411082997755476;
                    end
                    else
                    begin
                        Result := 0.00025179167302428882;
                    end;
                end;
            end;
        end
        else
        begin
            if features[177] <= -5769.4999999999991 then
            begin
                if features[69] <= 7.5000000000000009 then
                begin
                    Result := -0.024094052779851122;
                end
                else
                begin
                    Result := -0.0032872314135541144;
                end;
            end
            else
            begin
                if features[221] <= -5072.4999999999991 then
                begin
                    if features[180] <= -5949.4999999999991 then
                    begin
                        Result := 0.0064179037589203727;
                    end
                    else
                    begin
                        Result := -0.03044576905939532;
                    end;
                end
                else
                begin
                    if features[175] <= 405.50000000000006 then
                    begin
                        Result := -0.010273555163511297;
                    end
                    else
                    begin
                        Result := 0.038590073423178134;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.024251781069271405;
    end;
end;

function second_slot_bidirectional_tree_198(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[229] <= -1214.4999999999998 then
    begin
        Result := -0.020980718950549357;
    end
    else
    begin
        if features[55] <= 3.5000000000000004 then
        begin
            if features[146] <= 1771.5000000000002 then
            begin
                if features[219] <= -6844.4999999999991 then
                begin
                    if features[157] <= 1.5000000000000002 then
                    begin
                        Result := 0.00034590446497712453;
                    end
                    else
                    begin
                        Result := 0.017313507042025646;
                    end;
                end
                else
                begin
                    if features[175] <= -1058.4999999999998 then
                    begin
                        Result := -0.0050708123022695541;
                    end
                    else
                    begin
                        Result := 0.0019621117820378896;
                    end;
                end;
            end
            else
            begin
                if features[186] <= 217.16666412353518 then
                begin
                    Result := -0.018995859160678724;
                end
                else
                begin
                    if features[155] <= -1.4999999999999998 then
                    begin
                        Result := 0.0344410635195605;
                    end
                    else
                    begin
                        Result := -0.01119640706716378;
                    end;
                end;
            end;
        end
        else
        begin
            if features[228] <= -4902.4999999999991 then
            begin
                if features[215] <= -5113.4999999999991 then
                begin
                    if features[218] <= -5420.4999999999991 then
                    begin
                        Result := -0.0010287653301915764;
                    end
                    else
                    begin
                        Result := -0.023120802860329984;
                    end;
                end
                else
                begin
                    if features[218] <= -5546.4999999999991 then
                    begin
                        Result := 0.017641165114617958;
                    end
                    else
                    begin
                        Result := -0.0021648521765806309;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 1340.5000000000002 then
                begin
                    if features[215] <= -4944.4999999999991 then
                    begin
                        Result := -0.016114618950516236;
                    end
                    else
                    begin
                        Result := -0.0042905083247705769;
                    end;
                end
                else
                begin
                    Result := 0.0056928372118746542;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_199(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[96] <= 179340080.00000003 then
    begin
        if features[215] <= -3227.4999999999995 then
        begin
            if features[225] <= -3171.4999999999995 then
            begin
                if features[182] <= -4541.4999999999991 then
                begin
                    if features[15] <= -336406943.99999994 then
                    begin
                        Result := -0.015768780130037085;
                    end
                    else
                    begin
                        Result := 0.00072853390622616937;
                    end;
                end
                else
                begin
                    if features[123] <= -132.49999999999997 then
                    begin
                        Result := 0.011921897244294424;
                    end
                    else
                    begin
                        Result := -0.015389478686747844;
                    end;
                end;
            end
            else
            begin
                Result := 0.020038819610090606;
            end;
        end
        else
        begin
            if features[154] <= 239.50000000000003 then
            begin
                if features[175] <= 1285.5000000000002 then
                begin
                    Result := -0.02807004426858288;
                end
                else
                begin
                    Result := 0.0076598349060553383;
                end;
            end
            else
            begin
                Result := 0.0080194598355905217;
            end;
        end;
    end
    else
    begin
        if features[164] <= 95188640.000000015 then
        begin
            if features[220] <= 1809.0000000000002 then
            begin
                Result := -0.025978123912723607;
            end
            else
            begin
                Result := 0.012186632340346773;
            end;
        end
        else
        begin
            if features[36] <= 544.50000000000011 then
            begin
                if features[166] <= 91686248.000000015 then
                begin
                    Result := -0.025153755642841603;
                end
                else
                begin
                    if features[67] <= 1543.0000000000002 then
                    begin
                        Result := 0.0081013648931618411;
                    end
                    else
                    begin
                        Result := 0.041048219844571132;
                    end;
                end;
            end
            else
            begin
                if features[76] <= 12.500000000000002 then
                begin
                    Result := -0.025292854497993678;
                end
                else
                begin
                    Result := 0.013871236058673199;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_200(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[220] <= -1272.4999999999998 then
    begin
        if features[77] <= 3354.0000000000005 then
        begin
            if features[216] <= -4373.4999999999991 then
            begin
                if features[108] <= -52.499999999999993 then
                begin
                    Result := -0.01036427520402724;
                end
                else
                begin
                    if features[173] <= -5512.4999999999991 then
                    begin
                        Result := -0.015655270616093571;
                    end
                    else
                    begin
                        Result := 0.076825514463547837;
                    end;
                end;
            end
            else
            begin
                if features[154] <= -121.49999999999999 then
                begin
                    Result := 0.10038069837603503;
                end
                else
                begin
                    Result := -0.015100637972033263;
                end;
            end;
        end
        else
        begin
            Result := -0.01638292096470171;
        end;
    end
    else
    begin
        if features[95] <= -290593695.99999994 then
        begin
            Result := -0.013734426406356724;
        end
        else
        begin
            if features[69] <= 12.500000000000002 then
            begin
                if features[150] <= -1.4999999999999998 then
                begin
                    if features[26] <= 6.5000000000000009 then
                    begin
                        Result := 0.0045247517726345957;
                    end
                    else
                    begin
                        Result := -0.011984255694706337;
                    end;
                end
                else
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.0015453241553302884;
                    end
                    else
                    begin
                        Result := -0.0045756581242305727;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 2354.0000000000005 then
                begin
                    if features[216] <= -7304.4999999999991 then
                    begin
                        Result := 0.032485414973350439;
                    end
                    else
                    begin
                        Result := -0.0066113916706731796;
                    end;
                end
                else
                begin
                    if features[96] <= -209164751.99999997 then
                    begin
                        Result := 0.038780255196499733;
                    end
                    else
                    begin
                        Result := 0.0068479121214307815;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_201(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[26] <= 12.500000000000002 then
    begin
        if features[36] <= 859.50000000000011 then
        begin
            if features[27] <= -2884.4999999999995 then
            begin
                if features[90] <= 1.5000000000000002 then
                begin
                    if features[60] <= -1.0000000180025095E-35 then
                    begin
                        Result := 3.0483512736432687E-05;
                    end
                    else
                    begin
                        Result := -0.011874859403834592;
                    end;
                end
                else
                begin
                    if features[47] <= 5921.5000000000009 then
                    begin
                        Result := 0.0026636703671695915;
                    end
                    else
                    begin
                        Result := 0.015077471887443107;
                    end;
                end;
            end
            else
            begin
                if features[186] <= -56.874999999999993 then
                begin
                    Result := -0.0091656789918631784;
                end
                else
                begin
                    if features[107] <= -3.4999999999999996 then
                    begin
                        Result := -0.0034955692689423775;
                    end
                    else
                    begin
                        Result := 0.026353880940438543;
                    end;
                end;
            end;
        end
        else
        begin
            if features[2] <= 1.0000000180025095E-35 then
            begin
                if features[55] <= 1.5000000000000002 then
                begin
                    if features[108] <= 109.50000000000001 then
                    begin
                        Result := -0.012747805029554752;
                    end
                    else
                    begin
                        Result := 0.015506061281364891;
                    end;
                end
                else
                begin
                    if features[124] <= 466.50000000000006 then
                    begin
                        Result := -0.010943983617706141;
                    end
                    else
                    begin
                        Result := -0.02815321749406732;
                    end;
                end;
            end
            else
            begin
                if features[182] <= -4987.4999999999991 then
                begin
                    if features[174] <= -5773.4999999999991 then
                    begin
                        Result := -0.00088094717691641813;
                    end
                    else
                    begin
                        Result := 0.030620051103880858;
                    end;
                end
                else
                begin
                    Result := -0.014980853939992081;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.021612967498024539;
    end;
end;

function second_slot_bidirectional_tree_202(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[164] <= -368292223.99999994 then
    begin
        if features[158] <= 71062.500000000015 then
        begin
            if features[224] <= -5533.4999999999991 then
            begin
                Result := -0.0062104199961497165;
            end
            else
            begin
                Result := -0.023302659169445405;
            end;
        end
        else
        begin
            Result := 0.044691927262141343;
        end;
    end
    else
    begin
        if features[183] <= -8284.4999999999982 then
        begin
            if features[128] <= 1.0000000180025095E-35 then
            begin
                if features[166] <= -69602031.999999985 then
                begin
                    Result := -0.013472671287346309;
                end
                else
                begin
                    Result := 0.014533694795802909;
                end;
            end
            else
            begin
                if features[171] <= 5.5000000000000009 then
                begin
                    if features[154] <= 182.50000000000003 then
                    begin
                        Result := 0.046807648115618126;
                    end
                    else
                    begin
                        Result := 0.0023119445766052629;
                    end;
                end
                else
                begin
                    Result := -0.0083881643532134394;
                end;
            end;
        end
        else
        begin
            if features[175] <= -1221.4999999999998 then
            begin
                if features[216] <= -4389.4999999999991 then
                begin
                    if features[222] <= -6956.4999999999991 then
                    begin
                        Result := 0.017908174149564356;
                    end
                    else
                    begin
                        Result := -0.0089226809190261335;
                    end;
                end
                else
                begin
                    if features[216] <= -3981.9999999999995 then
                    begin
                        Result := 0.023723651213578213;
                    end
                    else
                    begin
                        Result := -0.010916575354946959;
                    end;
                end;
            end
            else
            begin
                if features[178] <= -2058.4999999999995 then
                begin
                    Result := -0.020399770308681432;
                end
                else
                begin
                    if features[108] <= -1103.4999999999998 then
                    begin
                        Result := 0.015703534838026466;
                    end
                    else
                    begin
                        Result := 0.00072970937217781888;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_203(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[164] <= 76017060.000000015 then
        begin
            if features[28] <= -5763.4999999999991 then
            begin
                if features[220] <= -1336.4999999999998 then
                begin
                    Result := -0.016107260806212383;
                end
                else
                begin
                    if features[96] <= 179340080.00000003 then
                    begin
                        Result := 0.00026486062243120235;
                    end
                    else
                    begin
                        Result := -0.017568334284699293;
                    end;
                end;
            end
            else
            begin
                if features[226] <= 971.50000000000011 then
                begin
                    if features[173] <= -4447.4999999999991 then
                    begin
                        Result := -0.017949041051661643;
                    end
                    else
                    begin
                        Result := 0.0077144597511971148;
                    end;
                end
                else
                begin
                    Result := 0.012759323609487588;
                end;
            end;
        end
        else
        begin
            if features[28] <= -5443.4999999999991 then
            begin
                if features[70] <= 721.50000000000011 then
                begin
                    if features[173] <= -6287.4999999999991 then
                    begin
                        Result := 0.0091856344187734949;
                    end
                    else
                    begin
                        Result := -0.016727080985449817;
                    end;
                end
                else
                begin
                    if features[73] <= 583.50000000000011 then
                    begin
                        Result := 0.0093420700198174299;
                    end
                    else
                    begin
                        Result := -0.010264988937355106;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -3403.4999999999995 then
                begin
                    if features[174] <= -4462.4999999999991 then
                    begin
                        Result := -0.002835912166458265;
                    end
                    else
                    begin
                        Result := 0.006236699049964863;
                    end;
                end
                else
                begin
                    if features[70] <= 854.50000000000011 then
                    begin
                        Result := 0.048216368252349699;
                    end
                    else
                    begin
                        Result := -0.0062480354057051005;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.021672177078817242;
    end;
end;

function second_slot_bidirectional_tree_204(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[27] <= -2884.4999999999995 then
    begin
        if features[182] <= -4541.4999999999991 then
        begin
            if features[172] <= 2.5000000000000004 then
            begin
                if features[222] <= -5368.4999999999991 then
                begin
                    if features[108] <= 419.50000000000006 then
                    begin
                        Result := -0.0020658914187558844;
                    end
                    else
                    begin
                        Result := 0.010921086159869699;
                    end;
                end
                else
                begin
                    if features[184] <= -1246.4999999999998 then
                    begin
                        Result := 0.030447945855120881;
                    end
                    else
                    begin
                        Result := 0.0055653058064070397;
                    end;
                end;
            end
            else
            begin
                if features[227] <= -4830.4999999999991 then
                begin
                    if features[128] <= -25483.499999999996 then
                    begin
                        Result := -0.0080720305862531875;
                    end
                    else
                    begin
                        Result := 0.0016493773720813048;
                    end;
                end
                else
                begin
                    if features[216] <= -4917.4999999999991 then
                    begin
                        Result := -0.014584464670304362;
                    end
                    else
                    begin
                        Result := -0.0025740336277169972;
                    end;
                end;
            end;
        end
        else
        begin
            if features[123] <= -132.49999999999997 then
            begin
                if features[187] <= -1.3166666626930235 then
                begin
                    if features[41] <= 1198.5000000000002 then
                    begin
                        Result := -0.014656748317726627;
                    end
                    else
                    begin
                        Result := 0.042560224026985442;
                    end;
                end
                else
                begin
                    Result := 0.068493259514278051;
                end;
            end
            else
            begin
                Result := -0.018134179505305065;
            end;
        end;
    end
    else
    begin
        if features[175] <= -226.49999999999997 then
        begin
            Result := -0.004648947184728601;
        end
        else
        begin
            if features[224] <= -4510.4999999999991 then
            begin
                Result := 0.0074006255034196099;
            end
            else
            begin
                Result := 0.033174738130544106;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_205(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[96] <= 182914768.00000003 then
    begin
        if features[57] <= 1.5000000000000002 then
        begin
            if features[9] <= 11.500000000000002 then
            begin
                if features[166] <= -1468094.4999999998 then
                begin
                    if features[75] <= 11.500000000000002 then
                    begin
                        Result := -0.00046956486740246231;
                    end
                    else
                    begin
                        Result := -0.011978346449627406;
                    end;
                end
                else
                begin
                    if features[105] <= 1.5000000000000002 then
                    begin
                        Result := 0.0060763729229093505;
                    end
                    else
                    begin
                        Result := -0.0017819114882585262;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -7261.4999999999991 then
                begin
                    if features[227] <= -6436.4999999999991 then
                    begin
                        Result := 0.023915607582373391;
                    end
                    else
                    begin
                        Result := -0.017627292279018405;
                    end;
                end
                else
                begin
                    if features[147] <= -197.49999999999997 then
                    begin
                        Result := -0.013457020246675992;
                    end
                    else
                    begin
                        Result := 0.021549073926513476;
                    end;
                end;
            end;
        end
        else
        begin
            if features[69] <= 5.5000000000000009 then
            begin
                if features[225] <= -4060.4999999999995 then
                begin
                    Result := -0.020636593058743758;
                end
                else
                begin
                    Result := 0.019614802311651615;
                end;
            end
            else
            begin
                if features[173] <= -6390.4999999999991 then
                begin
                    if features[215] <= -6154.4999999999991 then
                    begin
                        Result := -0.0077528932907142941;
                    end
                    else
                    begin
                        Result := 0.035298561062351096;
                    end;
                end
                else
                begin
                    Result := -0.011156711337929892;
                end;
            end;
        end;
    end
    else
    begin
        if features[164] <= 95188640.000000015 then
        begin
            Result := -0.020814863029821017;
        end
        else
        begin
            Result := -0.0014615158479902284;
        end;
    end;
end;

function second_slot_bidirectional_tree_206(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= 1340.5000000000002 then
    begin
        if features[107] <= -1.4999999999999998 then
        begin
            if features[68] <= 820.00000000000011 then
            begin
                Result := -0.0060935388657371095;
            end
            else
            begin
                if features[70] <= 794.50000000000011 then
                begin
                    Result := -0.016757314961018382;
                end
                else
                begin
                    Result := 0.031237798874802936;
                end;
            end;
        end
        else
        begin
            if features[71] <= 1.5000000000000002 then
            begin
                if features[25] <= 1.5000000000000002 then
                begin
                    if features[219] <= -7299.4999999999991 then
                    begin
                        Result := 0.029066399432414625;
                    end
                    else
                    begin
                        Result := 0.00059752003380172188;
                    end;
                end
                else
                begin
                    if features[216] <= -4080.4999999999995 then
                    begin
                        Result := -0.0087087171037726445;
                    end
                    else
                    begin
                        Result := 0.011019780165457571;
                    end;
                end;
            end
            else
            begin
                if features[155] <= 1.0000000180025095E-35 then
                begin
                    if features[166] <= -312987215.99999994 then
                    begin
                        Result := -0.014500319182002983;
                    end
                    else
                    begin
                        Result := 0.0035779654306659181;
                    end;
                end
                else
                begin
                    if features[94] <= -110946.49999999999 then
                    begin
                        Result := -0.021638981390146132;
                    end
                    else
                    begin
                        Result := -0.0016137982633992163;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[155] <= 1.0000000180025095E-35 then
        begin
            if features[179] <= -8493.4999999999982 then
            begin
                Result := -0.016093511370210683;
            end
            else
            begin
                Result := 0.017026075646278772;
            end;
        end
        else
        begin
            if features[121] <= 1372.5000000000002 then
            begin
                Result := 0.004123672335205982;
            end
            else
            begin
                Result := -0.019732212020928751;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_207(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[96] <= 224475544.00000003 then
    begin
        if features[226] <= -1231.4999999999998 then
        begin
            if features[215] <= -6817.4999999999991 then
            begin
                Result := 0.023001713124048355;
            end
            else
            begin
                if features[9] <= 10.500000000000002 then
                begin
                    Result := -0.021731711657083326;
                end
                else
                begin
                    Result := 0.021290824051791932;
                end;
            end;
        end
        else
        begin
            if features[184] <= -1614.4999999999998 then
            begin
                if features[73] <= 162.50000000000003 then
                begin
                    if features[173] <= -4946.4999999999991 then
                    begin
                        Result := 0.066223954462858101;
                    end
                    else
                    begin
                        Result := 0.00024832724770978688;
                    end;
                end
                else
                begin
                    if features[219] <= -4772.4999999999991 then
                    begin
                        Result := -0.0062979900407839203;
                    end
                    else
                    begin
                        Result := 0.038681892440809114;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -309517551.99999994 then
                begin
                    if features[178] <= -19.499999999999996 then
                    begin
                        Result := -0.020435024981297359;
                    end
                    else
                    begin
                        Result := 0.022682437485049129;
                    end;
                end
                else
                begin
                    if features[172] <= 14.500000000000002 then
                    begin
                        Result := 0.00073660099250314707;
                    end
                    else
                    begin
                        Result := -0.024794073731131912;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[108] <= 748.50000000000011 then
        begin
            Result := -0.025050022988415407;
        end
        else
        begin
            if features[27] <= -4810.4999999999991 then
            begin
                Result := -0.024273132790859332;
            end
            else
            begin
                if features[42] <= 322.50000000000006 then
                begin
                    Result := 0.0293887191566654;
                end
                else
                begin
                    Result := -0.00638988290105504;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_208(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[172] <= 14.500000000000002 then
    begin
        if features[73] <= 573.50000000000011 then
        begin
            if features[154] <= 10.500000000000002 then
            begin
                if features[154] <= -90.499999999999986 then
                begin
                    if features[77] <= 3646.0000000000005 then
                    begin
                        Result := 0.0063120740896306154;
                    end
                    else
                    begin
                        Result := -0.00038794248424235255;
                    end;
                end
                else
                begin
                    if features[39] <= 29.500000000000004 then
                    begin
                        Result := 0.00236456446850021;
                    end
                    else
                    begin
                        Result := -0.005390030651154361;
                    end;
                end;
            end
            else
            begin
                if features[226] <= -671.49999999999989 then
                begin
                    if features[9] <= 3.5000000000000004 then
                    begin
                        Result := -0.019052511342117565;
                    end
                    else
                    begin
                        Result := 0.040013708068408205;
                    end;
                end
                else
                begin
                    if features[108] <= -1069.4999999999998 then
                    begin
                        Result := 0.026806651246998103;
                    end
                    else
                    begin
                        Result := 0.0045617850263173915;
                    end;
                end;
            end;
        end
        else
        begin
            if features[228] <= -4262.4999999999991 then
            begin
                if features[27] <= -6765.4999999999991 then
                begin
                    if features[175] <= -388.49999999999994 then
                    begin
                        Result := -0.023797758923960816;
                    end
                    else
                    begin
                        Result := 0.029501918646494027;
                    end;
                end
                else
                begin
                    if features[129] <= 19223.000000000004 then
                    begin
                        Result := -0.021649227684362948;
                    end
                    else
                    begin
                        Result := 0.00052709326114312065;
                    end;
                end;
            end
            else
            begin
                if features[39] <= 1462.5000000000002 then
                begin
                    Result := 0.024879169432381498;
                end
                else
                begin
                    Result := -0.0074824023302224032;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.027437722092826956;
    end;
end;

function second_slot_bidirectional_tree_209(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[172] <= 4.5000000000000009 then
    begin
        if features[225] <= -5361.4999999999991 then
        begin
            if features[216] <= -5563.4999999999991 then
            begin
                if features[170] <= 1.0000000180025095E-35 then
                begin
                    if features[180] <= -7955.4999999999991 then
                    begin
                        Result := 0.014707346814330297;
                    end
                    else
                    begin
                        Result := -0.014434199264927375;
                    end;
                end
                else
                begin
                    if features[219] <= -5398.4999999999991 then
                    begin
                        Result := 0.0030673498939741638;
                    end
                    else
                    begin
                        Result := 0.019522782987004394;
                    end;
                end;
            end
            else
            begin
                if features[166] <= 56636886.000000007 then
                begin
                    if features[73] <= 123.50000000000001 then
                    begin
                        Result := -0.0022127877102294169;
                    end
                    else
                    begin
                        Result := -0.012027972894318603;
                    end;
                end
                else
                begin
                    Result := 0.0067712480127232232;
                end;
            end;
        end
        else
        begin
            if features[216] <= -4054.4999999999995 then
            begin
                if features[27] <= -4508.4999999999991 then
                begin
                    if features[225] <= -4395.4999999999991 then
                    begin
                        Result := 0.003547724090718676;
                    end
                    else
                    begin
                        Result := 0.017083465887255175;
                    end;
                end
                else
                begin
                    if features[183] <= -6757.4999999999991 then
                    begin
                        Result := 0.021179377873850026;
                    end
                    else
                    begin
                        Result := -0.003168213419790602;
                    end;
                end;
            end
            else
            begin
                if features[217] <= 450.50000000000006 then
                begin
                    Result := 0.022590329628039002;
                end
                else
                begin
                    if features[229] <= 215.50000000000003 then
                    begin
                        Result := -0.0095870951445128621;
                    end
                    else
                    begin
                        Result := 0.010101095602704536;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.0029808433547909366;
    end;
end;

function second_slot_bidirectional_tree_210(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1231.4999999999998 then
    begin
        Result := -0.01775977203973848;
    end
    else
    begin
        if features[173] <= -3910.9999999999995 then
        begin
            if features[164] <= -486010335.99999994 then
            begin
                if features[146] <= -1758.4999999999998 then
                begin
                    Result := 0.038309700651815611;
                end
                else
                begin
                    if features[226] <= 783.50000000000011 then
                    begin
                        Result := -0.02266468154787496;
                    end
                    else
                    begin
                        Result := 0.0086948552925158497;
                    end;
                end;
            end
            else
            begin
                if features[172] <= 2.5000000000000004 then
                begin
                    if features[222] <= -5368.4999999999991 then
                    begin
                        Result := -0.00029783764699767214;
                    end
                    else
                    begin
                        Result := 0.0058795563217090702;
                    end;
                end
                else
                begin
                    if features[121] <= 1057.5000000000002 then
                    begin
                        Result := 2.6724030890721442E-05;
                    end
                    else
                    begin
                        Result := -0.0079596563910004602;
                    end;
                end;
            end;
        end
        else
        begin
            if features[219] <= -7061.4999999999991 then
            begin
                if features[0] <= 65658.000000000015 then
                begin
                    if features[0] <= 31491.500000000004 then
                    begin
                        Result := 0.00033397165856932924;
                    end
                    else
                    begin
                        Result := 0.07962070432748132;
                    end;
                end
                else
                begin
                    Result := -0.020255905313260519;
                end;
            end
            else
            begin
                if features[76] <= 2.5000000000000004 then
                begin
                    if features[158] <= 2387.5000000000005 then
                    begin
                        Result := -0.0087663398283522927;
                    end
                    else
                    begin
                        Result := 0.047815195329567253;
                    end;
                end
                else
                begin
                    if features[156] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.02251500003908067;
                    end
                    else
                    begin
                        Result := 0.026902313278912127;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_211(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[172] <= 14.500000000000002 then
        begin
            if features[9] <= 11.500000000000002 then
            begin
                if features[66] <= 34.500000000000007 then
                begin
                    if features[55] <= 3.5000000000000004 then
                    begin
                        Result := 0.00097769078352877661;
                    end
                    else
                    begin
                        Result := -0.0040776296132070773;
                    end;
                end
                else
                begin
                    if features[215] <= -4727.4999999999991 then
                    begin
                        Result := -0.01588854174039735;
                    end
                    else
                    begin
                        Result := 0.0044302708073220036;
                    end;
                end;
            end
            else
            begin
                if features[225] <= -5463.4999999999991 then
                begin
                    if features[174] <= -5649.4999999999991 then
                    begin
                        Result := -0.016090984542365162;
                    end
                    else
                    begin
                        Result := 0.011762090301227081;
                    end;
                end
                else
                begin
                    if features[225] <= -5140.4999999999991 then
                    begin
                        Result := 0.033719333870484307;
                    end
                    else
                    begin
                        Result := 0.011648138094151552;
                    end;
                end;
            end;
        end
        else
        begin
            if features[217] <= 1080.5000000000002 then
            begin
                Result := -0.029778559024082614;
            end
            else
            begin
                Result := 0.010980127574566602;
            end;
        end;
    end
    else
    begin
        if features[177] <= -7477.4999999999991 then
        begin
            if features[177] <= -7675.4999999999991 then
            begin
                Result := -0.021729667549622647;
            end
            else
            begin
                Result := 0.028188753300934056;
            end;
        end
        else
        begin
            if features[146] <= -1887.4999999999998 then
            begin
                Result := 0.010471247507969104;
            end
            else
            begin
                Result := -0.028750132195136009;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_212(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[105] <= 1.0000000180025095E-35 then
    begin
        if features[122] <= -1517.4999999999998 then
        begin
            Result := -0.019835564205032102;
        end
        else
        begin
            if features[216] <= -4044.4999999999995 then
            begin
                if features[224] <= -4256.4999999999991 then
                begin
                    if features[166] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.00013929357948222834;
                    end
                    else
                    begin
                        Result := 0.0058748219999419579;
                    end;
                end
                else
                begin
                    Result := -0.010882788883387499;
                end;
            end
            else
            begin
                if features[217] <= 465.50000000000006 then
                begin
                    if features[215] <= -4023.4999999999995 then
                    begin
                        Result := 0.031687633840148596;
                    end
                    else
                    begin
                        Result := 0.0065482095979075205;
                    end;
                end
                else
                begin
                    if features[177] <= -6815.4999999999991 then
                    begin
                        Result := 0.01085685511403175;
                    end
                    else
                    begin
                        Result := -0.0061704328734845208;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[172] <= 7.5000000000000009 then
        begin
            if features[225] <= -4333.4999999999991 then
            begin
                if features[36] <= 750.50000000000011 then
                begin
                    if features[121] <= 1375.5000000000002 then
                    begin
                        Result := -0.0012819331580613486;
                    end
                    else
                    begin
                        Result := -0.018707604228693626;
                    end;
                end
                else
                begin
                    if features[184] <= 1075.5000000000002 then
                    begin
                        Result := -0.0082644121981676703;
                    end
                    else
                    begin
                        Result := -0.034857894839854978;
                    end;
                end;
            end
            else
            begin
                if features[171] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0070392361876107021;
                end
                else
                begin
                    Result := 0.010577183247758529;
                end;
            end;
        end
        else
        begin
            Result := -0.013414493176491599;
        end;
    end;
end;

function second_slot_bidirectional_tree_213(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[96] <= 182914768.00000003 then
    begin
        if features[73] <= 573.50000000000011 then
        begin
            if features[55] <= 4.5000000000000009 then
            begin
                if features[164] <= -342043167.99999994 then
                begin
                    if features[150] <= -16.499999999999996 then
                    begin
                        Result := 0.012533872801875913;
                    end
                    else
                    begin
                        Result := -0.0095990333271780345;
                    end;
                end
                else
                begin
                    if features[183] <= -8383.4999999999982 then
                    begin
                        Result := 0.016927802831338285;
                    end
                    else
                    begin
                        Result := 0.0015572793585627966;
                    end;
                end;
            end
            else
            begin
                if features[76] <= 9.5000000000000018 then
                begin
                    if features[47] <= 3430.5000000000005 then
                    begin
                        Result := -0.0014652528362477197;
                    end
                    else
                    begin
                        Result := -0.013098662215732868;
                    end;
                end
                else
                begin
                    if features[148] <= 1408.5000000000002 then
                    begin
                        Result := 0.016644971204819;
                    end
                    else
                    begin
                        Result := -0.014761103876401985;
                    end;
                end;
            end;
        end
        else
        begin
            if features[48] <= 19043.500000000004 then
            begin
                if features[166] <= 74983788.000000015 then
                begin
                    if features[107] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.023879326225417621;
                    end
                    else
                    begin
                        Result := -0.0014919918951356644;
                    end;
                end
                else
                begin
                    Result := 0.0083535168354372854;
                end;
            end
            else
            begin
                if features[175] <= -903.49999999999989 then
                begin
                    Result := -0.016400315581470884;
                end
                else
                begin
                    Result := 0.01617628833687251;
                end;
            end;
        end;
    end
    else
    begin
        if features[108] <= 748.50000000000011 then
        begin
            Result := -0.019372384815659907;
        end
        else
        begin
            Result := 0.0022918041538577366;
        end;
    end;
end;

function second_slot_bidirectional_tree_214(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[105] <= 2.5000000000000004 then
    begin
        if features[185] <= 215.29166412353518 then
        begin
            if features[126] <= -1.0000000180025095E-35 then
            begin
                if features[179] <= -5467.4999999999991 then
                begin
                    if features[172] <= 2.5000000000000004 then
                    begin
                        Result := 0.0095222371102587546;
                    end
                    else
                    begin
                        Result := 0.0016155519986868747;
                    end;
                end
                else
                begin
                    if features[129] <= -19787.499999999996 then
                    begin
                        Result := 0.028380329942962492;
                    end
                    else
                    begin
                        Result := -0.0087377544647081855;
                    end;
                end;
            end
            else
            begin
                if features[222] <= -5358.4999999999991 then
                begin
                    if features[217] <= 139.50000000000003 then
                    begin
                        Result := -0.0023296064101051245;
                    end
                    else
                    begin
                        Result := -0.010179906886396486;
                    end;
                end
                else
                begin
                    if features[69] <= 11.500000000000002 then
                    begin
                        Result := -0.0012138857445709822;
                    end
                    else
                    begin
                        Result := 0.0083181167195719909;
                    end;
                end;
            end;
        end
        else
        begin
            if features[177] <= -5354.4999999999991 then
            begin
                if features[222] <= -5768.4999999999991 then
                begin
                    if features[174] <= -7942.4999999999991 then
                    begin
                        Result := -0.022011819148079387;
                    end
                    else
                    begin
                        Result := 0.013709924347897596;
                    end;
                end
                else
                begin
                    if features[70] <= 833.50000000000011 then
                    begin
                        Result := 0.0035305937060143935;
                    end
                    else
                    begin
                        Result := -0.011431222843829154;
                    end;
                end;
            end
            else
            begin
                Result := 0.015054135439308336;
            end;
        end;
    end
    else
    begin
        if features[129] <= -19545.999999999996 then
        begin
            Result := -0.020947143131741387;
        end
        else
        begin
            Result := -0.0031836846608278009;
        end;
    end;
end;

function second_slot_bidirectional_tree_215(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[146] <= 1771.5000000000002 then
    begin
        if features[223] <= 2070.5000000000005 then
        begin
            if features[121] <= 1033.5000000000002 then
            begin
                if features[222] <= -5207.4999999999991 then
                begin
                    if features[179] <= -7097.4999999999991 then
                    begin
                        Result := 0.0020959934413662235;
                    end
                    else
                    begin
                        Result := -0.0034501534735593073;
                    end;
                end
                else
                begin
                    if features[180] <= -6534.4999999999991 then
                    begin
                        Result := 0.008406752035921795;
                    end
                    else
                    begin
                        Result := 0.0010770511423828367;
                    end;
                end;
            end
            else
            begin
                if features[219] <= -4641.4999999999991 then
                begin
                    if features[75] <= 2.5000000000000004 then
                    begin
                        Result := 0.017706470314108082;
                    end
                    else
                    begin
                        Result := -0.0035427705565557847;
                    end;
                end
                else
                begin
                    if features[225] <= -3583.9999999999995 then
                    begin
                        Result := -0.021154894182743578;
                    end
                    else
                    begin
                        Result := 0.0037178760575709356;
                    end;
                end;
            end;
        end
        else
        begin
            if features[180] <= -5370.4999999999991 then
            begin
                Result := 0.019261277962893258;
            end
            else
            begin
                if features[77] <= 7354.0000000000009 then
                begin
                    Result := 0.012491094276736375;
                end
                else
                begin
                    Result := -0.027692280987422976;
                end;
            end;
        end;
    end
    else
    begin
        if features[186] <= 217.16666412353518 then
        begin
            Result := -0.020097311537448988;
        end
        else
        begin
            if features[158] <= 23687.500000000004 then
            begin
                Result := -0.024217279474156642;
            end
            else
            begin
                if features[226] <= 706.50000000000011 then
                begin
                    Result := 0.036690632133248628;
                end
                else
                begin
                    Result := -0.020386091983950257;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_216(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[172] <= 14.500000000000002 then
    begin
        if features[150] <= -1.0000000180025095E-35 then
        begin
            if features[24] <= 1.5000000000000002 then
            begin
                if features[229] <= 496.50000000000006 then
                begin
                    if features[45] <= 1.5000000000000002 then
                    begin
                        Result := 0.038079899056005034;
                    end
                    else
                    begin
                        Result := -0.015714011046161106;
                    end;
                end
                else
                begin
                    Result := 0.020981576389827464;
                end;
            end
            else
            begin
                if features[82] <= -37838.499999999993 then
                begin
                    if features[164] <= 327071536.00000006 then
                    begin
                        Result := -0.0023837510438930514;
                    end
                    else
                    begin
                        Result := 0.01800856264404543;
                    end;
                end
                else
                begin
                    if features[126] <= -1.4999999999999998 then
                    begin
                        Result := -0.0024170441122675383;
                    end
                    else
                    begin
                        Result := 0.0091250414746288713;
                    end;
                end;
            end;
        end
        else
        begin
            if features[69] <= 10.500000000000002 then
            begin
                if features[15] <= -142486575.99999997 then
                begin
                    Result := -0.01347702854809316;
                end
                else
                begin
                    if features[47] <= 3320.5000000000005 then
                    begin
                        Result := 0.00461505410992946;
                    end
                    else
                    begin
                        Result := -0.0034409978633237331;
                    end;
                end;
            end
            else
            begin
                if features[11] <= 1.5000000000000002 then
                begin
                    if features[176] <= -7091.4999999999991 then
                    begin
                        Result := 0.0059310633264341587;
                    end
                    else
                    begin
                        Result := -0.0059681576819345852;
                    end;
                end
                else
                begin
                    if features[149] <= 430.00000000000006 then
                    begin
                        Result := 0.0087077016360688729;
                    end
                    else
                    begin
                        Result := -0.019646631717191308;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.024911387971213533;
    end;
end;

function second_slot_bidirectional_tree_217(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[122] <= -1517.4999999999998 then
    begin
        if features[174] <= -5449.4999999999991 then
        begin
            if features[158] <= -56937.499999999993 then
            begin
                Result := 0.016151698292939887;
            end
            else
            begin
                Result := -0.027560066072819259;
            end;
        end
        else
        begin
            if features[216] <= -4147.4999999999991 then
            begin
                if features[225] <= -5271.4999999999991 then
                begin
                    Result := -0.018333159513834608;
                end
                else
                begin
                    if features[0] <= 65658.000000000015 then
                    begin
                        Result := -0.012371787560015795;
                    end
                    else
                    begin
                        Result := 0.04047649014553676;
                    end;
                end;
            end
            else
            begin
                Result := -0.024105142206245697;
            end;
        end;
    end
    else
    begin
        if features[164] <= -535007231.99999994 then
        begin
            if features[147] <= 493.50000000000006 then
            begin
                Result := -0.025217218012577588;
            end
            else
            begin
                Result := 0.032807879546326947;
            end;
        end
        else
        begin
            if features[180] <= -9444.9999999999982 then
            begin
                if features[95] <= -2123864.9999999995 then
                begin
                    Result := -0.01994611598274447;
                end
                else
                begin
                    if features[167] <= 1.5000000000000002 then
                    begin
                        Result := 0.0012078966198843621;
                    end
                    else
                    begin
                        Result := 0.052035216954573485;
                    end;
                end;
            end
            else
            begin
                if features[228] <= -3446.4999999999995 then
                begin
                    if features[182] <= -4680.4999999999991 then
                    begin
                        Result := 0.00055133820613083697;
                    end
                    else
                    begin
                        Result := -0.0082484795605263991;
                    end;
                end
                else
                begin
                    if features[28] <= -5206.4999999999991 then
                    begin
                        Result := 0.02040303020406856;
                    end
                    else
                    begin
                        Result := 0.0026809533985073042;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_218(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[57] <= 1.5000000000000002 then
    begin
        if features[215] <= -3227.4999999999995 then
        begin
            if features[55] <= 4.5000000000000009 then
            begin
                if features[226] <= 495.50000000000006 then
                begin
                    if features[219] <= -7019.4999999999991 then
                    begin
                        Result := 0.007433733569727533;
                    end
                    else
                    begin
                        Result := -0.0010198460251591619;
                    end;
                end
                else
                begin
                    if features[151] <= -22.499999999999996 then
                    begin
                        Result := 0.0078193341467488742;
                    end
                    else
                    begin
                        Result := 0.00018584824427263802;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 11775.000000000002 then
                begin
                    if features[182] <= -8861.4999999999982 then
                    begin
                        Result := 0.030765682103764763;
                    end
                    else
                    begin
                        Result := -0.010657007045773971;
                    end;
                end
                else
                begin
                    if features[129] <= -11532.499999999998 then
                    begin
                        Result := -0.018640725774452593;
                    end
                    else
                    begin
                        Result := 0.0051143860689637837;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.021179633313184554;
        end;
    end
    else
    begin
        if features[222] <= -4585.4999999999991 then
        begin
            if features[179] <= -7373.4999999999991 then
            begin
                if features[179] <= -7421.4999999999991 then
                begin
                    if features[95] <= 279973504.00000006 then
                    begin
                        Result := -0.013704249099929922;
                    end
                    else
                    begin
                        Result := 0.033546919905863212;
                    end;
                end
                else
                begin
                    Result := 0.043429921086117332;
                end;
            end
            else
            begin
                Result := -0.021642244413483652;
            end;
        end
        else
        begin
            if features[29] <= -5809.4999999999991 then
            begin
                Result := 0.027312712801793367;
            end
            else
            begin
                Result := -0.0090288488253884389;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_219(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[175] <= -687.49999999999989 then
    begin
        if features[182] <= -7375.4999999999991 then
        begin
            if features[227] <= -5169.4999999999991 then
            begin
                if features[136] <= -1.0000000180025095E-35 then
                begin
                    if features[47] <= 4121.5000000000009 then
                    begin
                        Result := 0.045953158963752433;
                    end
                    else
                    begin
                        Result := -0.00065282462328093553;
                    end;
                end
                else
                begin
                    if features[225] <= -6068.4999999999991 then
                    begin
                        Result := -0.0058691179641481954;
                    end
                    else
                    begin
                        Result := 0.017360906292059882;
                    end;
                end;
            end
            else
            begin
                Result := -0.011755262447828582;
            end;
        end
        else
        begin
            if features[150] <= -32.499999999999993 then
            begin
                Result := 0.032796736489466599;
            end
            else
            begin
                Result := -0.0047962786434413551;
            end;
        end;
    end
    else
    begin
        if features[155] <= 1.0000000180025095E-35 then
        begin
            if features[229] <= 894.50000000000011 then
            begin
                if features[106] <= -1.4999999999999998 then
                begin
                    if features[216] <= -5676.4999999999991 then
                    begin
                        Result := 0.014482246045685036;
                    end
                    else
                    begin
                        Result := 0.0031625321804800177;
                    end;
                end
                else
                begin
                    if features[177] <= -5700.4999999999991 then
                    begin
                        Result := -0.0024909277232948081;
                    end
                    else
                    begin
                        Result := 0.0078909069930158168;
                    end;
                end;
            end
            else
            begin
                if features[182] <= -5657.4999999999991 then
                begin
                    if features[225] <= -5188.4999999999991 then
                    begin
                        Result := -0.0034973244400458995;
                    end
                    else
                    begin
                        Result := 0.016613884626195129;
                    end;
                end
                else
                begin
                    Result := -0.011403415570601295;
                end;
            end;
        end
        else
        begin
            Result := -0.0025782679174581559;
        end;
    end;
end;

function second_slot_bidirectional_tree_220(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[27] <= -2884.4999999999995 then
    begin
        if features[182] <= -4763.4999999999991 then
        begin
            if features[66] <= 34.500000000000007 then
            begin
                if features[225] <= -3583.9999999999995 then
                begin
                    if features[224] <= -4256.4999999999991 then
                    begin
                        Result := 0.00054532532576927911;
                    end
                    else
                    begin
                        Result := -0.0083989133237340214;
                    end;
                end
                else
                begin
                    if features[229] <= 412.50000000000006 then
                    begin
                        Result := -0.014460754185527898;
                    end
                    else
                    begin
                        Result := 0.016298987362329896;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 5.5000000000000009 then
                begin
                    Result := -0.0152811900271451;
                end
                else
                begin
                    if features[174] <= -6931.4999999999991 then
                    begin
                        Result := 0.044362304758391632;
                    end
                    else
                    begin
                        Result := -0.0030110446880619608;
                    end;
                end;
            end;
        end
        else
        begin
            if features[220] <= 511.50000000000006 then
            begin
                if features[185] <= -2.8333333730697627 then
                begin
                    if features[123] <= -141.49999999999997 then
                    begin
                        Result := 0.0076974777888439098;
                    end
                    else
                    begin
                        Result := -0.012675350150647009;
                    end;
                end
                else
                begin
                    if features[27] <= -3522.4999999999995 then
                    begin
                        Result := 0.02682717904042797;
                    end
                    else
                    begin
                        Result := -0.018817455182473838;
                    end;
                end;
            end
            else
            begin
                Result := -0.026349879016333358;
            end;
        end;
    end
    else
    begin
        if features[120] <= 1512.5000000000002 then
        begin
            if features[175] <= -226.49999999999997 then
            begin
                Result := -0.0027002484983139913;
            end
            else
            begin
                Result := 0.022088948853834941;
            end;
        end
        else
        begin
            Result := -0.024980424810427282;
        end;
    end;
end;

function second_slot_bidirectional_tree_221(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= 26972834.000000004 then
    begin
        if features[172] <= 4.5000000000000009 then
        begin
            if features[222] <= -5368.4999999999991 then
            begin
                if features[48] <= 50626.500000000007 then
                begin
                    if features[186] <= 79.099998474121108 then
                    begin
                        Result := -0.0052987044003924774;
                    end
                    else
                    begin
                        Result := 0.0038632432719832247;
                    end;
                end
                else
                begin
                    Result := 0.035569262580162846;
                end;
            end
            else
            begin
                if features[180] <= -7459.4999999999991 then
                begin
                    if features[169] <= 1.5000000000000002 then
                    begin
                        Result := 0.0035807146721756212;
                    end
                    else
                    begin
                        Result := 0.029008104964232336;
                    end;
                end
                else
                begin
                    if features[120] <= 355.50000000000006 then
                    begin
                        Result := 0.0041554942070246353;
                    end
                    else
                    begin
                        Result := -0.0085110128292124332;
                    end;
                end;
            end;
        end
        else
        begin
            if features[78] <= 83.000000000000014 then
            begin
                Result := -0.0066545733594089137;
            end
            else
            begin
                if features[0] <= 54187.500000000007 then
                begin
                    Result := 0.054924095009318691;
                end
                else
                begin
                    Result := -0.015443768111781886;
                end;
            end;
        end;
    end
    else
    begin
        if features[47] <= 9733.0000000000018 then
        begin
            if features[110] <= -558.49999999999989 then
            begin
                Result := 0.030123150428356445;
            end
            else
            begin
                Result := 0.00037208097281988053;
            end;
        end
        else
        begin
            if features[1] <= 152024.00000000003 then
            begin
                if features[15] <= -121025235.99999999 then
                begin
                    Result := -0.0069960751327598509;
                end
                else
                begin
                    Result := 0.016022227055083618;
                end;
            end
            else
            begin
                Result := -0.0076665457047306734;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_222(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[122] <= -1303.4999999999998 then
    begin
        if features[147] <= -1862.4999999999998 then
        begin
            Result := 0.043727471099271921;
        end
        else
        begin
            if features[28] <= -5620.4999999999991 then
            begin
                Result := -0.019088667128488682;
            end
            else
            begin
                if features[183] <= -5558.4999999999991 then
                begin
                    if features[95] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.026062129009343123;
                    end
                    else
                    begin
                        Result := 0.034202658424515385;
                    end;
                end
                else
                begin
                    if features[118] <= -1.4999999999999998 then
                    begin
                        Result := 0.03533595763889371;
                    end
                    else
                    begin
                        Result := -0.019011696756638569;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[225] <= -3663.4999999999995 then
        begin
            if features[41] <= 1462.5000000000002 then
            begin
                if features[164] <= -522761983.99999994 then
                begin
                    Result := -0.020687030019942654;
                end
                else
                begin
                    if features[180] <= -7923.4999999999991 then
                    begin
                        Result := 0.0061240916411474701;
                    end
                    else
                    begin
                        Result := 3.895597515062859E-05;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -5055.4999999999991 then
                begin
                    if features[73] <= 504.50000000000006 then
                    begin
                        Result := -0.011568657409017797;
                    end
                    else
                    begin
                        Result := 0.025895827831543122;
                    end;
                end
                else
                begin
                    if features[219] <= -6392.4999999999991 then
                    begin
                        Result := 0.023385115038286032;
                    end
                    else
                    begin
                        Result := -0.0023319712077269957;
                    end;
                end;
            end;
        end
        else
        begin
            if features[226] <= 246.50000000000003 then
            begin
                Result := -0.0046902101758842258;
            end
            else
            begin
                Result := 0.012014222569400336;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_223(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[122] <= -1102.9999999999998 then
    begin
        if features[28] <= -4895.4999999999991 then
        begin
            if features[179] <= -6480.4999999999991 then
            begin
                if features[42] <= 418.50000000000006 then
                begin
                    Result := -0.0081230807606465175;
                end
                else
                begin
                    if features[229] <= -125.49999999999999 then
                    begin
                        Result := 0.069280967279905764;
                    end
                    else
                    begin
                        Result := -0.0087777327395359758;
                    end;
                end;
            end
            else
            begin
                Result := -0.01967070301388598;
            end;
        end
        else
        begin
            if features[218] <= -4943.4999999999991 then
            begin
                if features[215] <= -5437.4999999999991 then
                begin
                    Result := -0.01189347433704608;
                end
                else
                begin
                    Result := 0.043900428338133152;
                end;
            end
            else
            begin
                Result := -0.01712991896995621;
            end;
        end;
    end
    else
    begin
        if features[225] <= -3827.4999999999995 then
        begin
            if features[26] <= 12.500000000000002 then
            begin
                if features[150] <= -7.4999999999999991 then
                begin
                    if features[176] <= -7161.4999999999991 then
                    begin
                        Result := 0.010422954800841225;
                    end
                    else
                    begin
                        Result := 0.00037510593003926433;
                    end;
                end
                else
                begin
                    if features[66] <= 34.500000000000007 then
                    begin
                        Result := -0.00045727268084943022;
                    end
                    else
                    begin
                        Result := -0.013132604607870935;
                    end;
                end;
            end
            else
            begin
                Result := -0.020128716037171791;
            end;
        end
        else
        begin
            if features[187] <= 5.3541667461395273 then
            begin
                Result := 0.016112860245470883;
            end
            else
            begin
                if features[226] <= 439.50000000000006 then
                begin
                    Result := -0.016372911279030348;
                end
                else
                begin
                    Result := 0.0075363419911056691;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_224(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[26] <= 12.500000000000002 then
    begin
        if features[106] <= -1.0000000180025095E-35 then
        begin
            if features[179] <= -5356.4999999999991 then
            begin
                if features[83] <= -1.0000000180025095E-35 then
                begin
                    if features[219] <= -6999.4999999999991 then
                    begin
                        Result := 0.017949514779277923;
                    end
                    else
                    begin
                        Result := -0.0058423499257928627;
                    end;
                end
                else
                begin
                    if features[73] <= 505.50000000000006 then
                    begin
                        Result := 0.0069567060321072656;
                    end
                    else
                    begin
                        Result := -0.0076012871423408838;
                    end;
                end;
            end
            else
            begin
                if features[185] <= -72.900001525878892 then
                begin
                    Result := -0.0098742081164370846;
                end
                else
                begin
                    if features[223] <= 260.50000000000006 then
                    begin
                        Result := 0.023631600150948624;
                    end
                    else
                    begin
                        Result := -0.0063533416820071575;
                    end;
                end;
            end;
        end
        else
        begin
            if features[175] <= -1271.4999999999998 then
            begin
                if features[228] <= -6192.4999999999991 then
                begin
                    if features[218] <= -6465.4999999999991 then
                    begin
                        Result := -0.01424423501056123;
                    end
                    else
                    begin
                        Result := 0.022717408759160184;
                    end;
                end
                else
                begin
                    if features[216] <= -4356.4999999999991 then
                    begin
                        Result := -0.012671850415905329;
                    end
                    else
                    begin
                        Result := 0.0092206513786076191;
                    end;
                end;
            end
            else
            begin
                if features[66] <= 108.50000000000001 then
                begin
                    if features[172] <= 10.500000000000002 then
                    begin
                        Result := 0.00083250684087122812;
                    end
                    else
                    begin
                        Result := -0.013262240091943123;
                    end;
                end
                else
                begin
                    Result := -0.013782623168525548;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.018794598045156683;
    end;
end;

function second_slot_bidirectional_tree_225(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[90] <= 1.5000000000000002 then
    begin
        if features[166] <= -1468094.4999999998 then
        begin
            if features[168] <= 1.5000000000000002 then
            begin
                if features[225] <= -5045.4999999999991 then
                begin
                    if features[186] <= 595.75000000000011 then
                    begin
                        Result := -0.0034699585535461481;
                    end
                    else
                    begin
                        Result := 0.033156886472369806;
                    end;
                end
                else
                begin
                    if features[13] <= -19781.499999999996 then
                    begin
                        Result := 0.029512445112474202;
                    end
                    else
                    begin
                        Result := 0.003858636137251307;
                    end;
                end;
            end
            else
            begin
                if features[83] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.013581359974217012;
                end
                else
                begin
                    Result := -0.0041880264706143774;
                end;
            end;
        end
        else
        begin
            if features[178] <= -634.49999999999989 then
            begin
                if features[69] <= 7.5000000000000009 then
                begin
                    Result := 0.0046499898393888312;
                end
                else
                begin
                    if features[75] <= 6.5000000000000009 then
                    begin
                        Result := 0.037401623441494496;
                    end
                    else
                    begin
                        Result := 0.0037277774889277922;
                    end;
                end;
            end
            else
            begin
                if features[36] <= 587.50000000000011 then
                begin
                    if features[158] <= 6645.5000000000009 then
                    begin
                        Result := 0.0046832603946435156;
                    end
                    else
                    begin
                        Result := -0.0033373414333129391;
                    end;
                end
                else
                begin
                    if features[164] <= 85446772.000000015 then
                    begin
                        Result := -0.014558198833113418;
                    end
                    else
                    begin
                        Result := -0.00078308016310226804;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[47] <= 5921.5000000000009 then
        begin
            Result := 0.0022437774721315597;
        end
        else
        begin
            Result := 0.013552996686162548;
        end;
    end;
end;

function second_slot_bidirectional_tree_226(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[95] <= -290593695.99999994 then
    begin
        if features[76] <= 3.5000000000000004 then
        begin
            if features[70] <= 829.50000000000011 then
            begin
                if features[108] <= -357.49999999999994 then
                begin
                    if features[75] <= 5.5000000000000009 then
                    begin
                        Result := -0.020870210758929818;
                    end
                    else
                    begin
                        Result := 0.02789712770181434;
                    end;
                end
                else
                begin
                    if features[94] <= 817.50000000000011 then
                    begin
                        Result := 0.051045735151530082;
                    end
                    else
                    begin
                        Result := 0.0035235589798803136;
                    end;
                end;
            end
            else
            begin
                Result := -0.022609269956169686;
            end;
        end
        else
        begin
            Result := -0.026999896446675088;
        end;
    end
    else
    begin
        if features[226] <= -1334.4999999999998 then
        begin
            Result := -0.02022158379703063;
        end
        else
        begin
            if features[184] <= -1614.4999999999998 then
            begin
                if features[216] <= -6512.4999999999991 then
                begin
                    if features[73] <= 162.50000000000003 then
                    begin
                        Result := 0.091468983459178088;
                    end
                    else
                    begin
                        Result := 0.0011768650512804051;
                    end;
                end
                else
                begin
                    if features[77] <= 42562.500000000007 then
                    begin
                        Result := 0.0013473257651635837;
                    end
                    else
                    begin
                        Result := 0.071883390940292544;
                    end;
                end;
            end
            else
            begin
                if features[178] <= -959.49999999999989 then
                begin
                    if features[183] <= -9097.9999999999982 then
                    begin
                        Result := 0.044389986123190742;
                    end
                    else
                    begin
                        Result := -0.0055644633171133906;
                    end;
                end
                else
                begin
                    if features[185] <= -546.36666870117176 then
                    begin
                        Result := 0.015799992414210869;
                    end
                    else
                    begin
                        Result := 0.00060169061114904434;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_227(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[57] <= 1.5000000000000002 then
    begin
        if features[9] <= 11.500000000000002 then
        begin
            if features[172] <= 14.500000000000002 then
            begin
                if features[229] <= -1214.4999999999998 then
                begin
                    Result := -0.021771776911026663;
                end
                else
                begin
                    if features[55] <= 4.5000000000000009 then
                    begin
                        Result := 0.0011554982568730283;
                    end
                    else
                    begin
                        Result := -0.0042902216802361594;
                    end;
                end;
            end
            else
            begin
                Result := -0.026303960136652333;
            end;
        end
        else
        begin
            if features[177] <= -8294.4999999999982 then
            begin
                Result := -0.02022710439202903;
            end
            else
            begin
                if features[0] <= 31193.000000000004 then
                begin
                    Result := -0.0090512756299123524;
                end
                else
                begin
                    if features[147] <= -197.49999999999997 then
                    begin
                        Result := -0.012168169250969823;
                    end
                    else
                    begin
                        Result := 0.022783628451325262;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[69] <= 6.5000000000000009 then
        begin
            if features[73] <= 150.50000000000003 then
            begin
                if features[81] <= -127491.99999999999 then
                begin
                    if features[227] <= -5938.4999999999991 then
                    begin
                        Result := 0.028972025745532017;
                    end
                    else
                    begin
                        Result := -0.015468650464898568;
                    end;
                end
                else
                begin
                    Result := -0.023527264186609217;
                end;
            end
            else
            begin
                Result := 0.015151023403976296;
            end;
        end
        else
        begin
            if features[175] <= 405.50000000000006 then
            begin
                Result := -0.014391160713750552;
            end
            else
            begin
                if features[64] <= 753.00000000000011 then
                begin
                    Result := -0.00083069172370855548;
                end
                else
                begin
                    Result := 0.044362022557069822;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_228(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[150] <= -1.4999999999999998 then
    begin
        if features[26] <= 6.5000000000000009 then
        begin
            if features[143] <= -1.4999999999999998 then
            begin
                Result := 0.017140695846103487;
            end
            else
            begin
                if features[185] <= -528.87499999999989 then
                begin
                    if features[224] <= -5483.4999999999991 then
                    begin
                        Result := -0.0069591565209176174;
                    end
                    else
                    begin
                        Result := 0.025376430021129749;
                    end;
                end
                else
                begin
                    Result := 0.0017109876801069354;
                end;
            end;
        end
        else
        begin
            if features[67] <= 2950.5000000000005 then
            begin
                Result := -0.016626917833404302;
            end
            else
            begin
                Result := 0.027674053089349462;
            end;
        end;
    end
    else
    begin
        if features[69] <= 1.5000000000000002 then
        begin
            Result := -0.010471052454015969;
        end
        else
        begin
            if features[155] <= 1.0000000180025095E-35 then
            begin
                if features[71] <= 1.5000000000000002 then
                begin
                    if features[25] <= 1.5000000000000002 then
                    begin
                        Result := 0.0018086613866974022;
                    end
                    else
                    begin
                        Result := -0.0095102788906760768;
                    end;
                end
                else
                begin
                    if features[215] <= -4006.4999999999995 then
                    begin
                        Result := 0.0034604593002465663;
                    end
                    else
                    begin
                        Result := -0.006496695349304406;
                    end;
                end;
            end
            else
            begin
                if features[9] <= 5.5000000000000009 then
                begin
                    if features[59] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0045476389341901824;
                    end
                    else
                    begin
                        Result := -0.027760108090937777;
                    end;
                end
                else
                begin
                    if features[175] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.031127413862660172;
                    end
                    else
                    begin
                        Result := -0.0032151917281478975;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_229(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[82] <= -76366.499999999985 then
    begin
        if features[107] <= 1.5000000000000002 then
        begin
            if features[37] <= 4.5000000000000009 then
            begin
                Result := 0.0032676882001423861;
            end
            else
            begin
                Result := -0.0054110352050199331;
            end;
        end
        else
        begin
            if features[128] <= 3278.5000000000005 then
            begin
                Result := -0.016538873016178037;
            end
            else
            begin
                if features[174] <= -8176.4999999999991 then
                begin
                    Result := 0.072423697846396212;
                end
                else
                begin
                    Result := 0.0032953192924630257;
                end;
            end;
        end;
    end
    else
    begin
        if features[150] <= -1.0000000180025095E-35 then
        begin
            if features[176] <= -6096.4999999999991 then
            begin
                Result := 0.0076264459985392052;
            end
            else
            begin
                if features[72] <= 772.50000000000011 then
                begin
                    Result := -0.01506345462454;
                end
                else
                begin
                    if features[217] <= 294.50000000000006 then
                    begin
                        Result := 0.008251421721694267;
                    end
                    else
                    begin
                        Result := -0.0081930472791089375;
                    end;
                end;
            end;
        end
        else
        begin
            if features[42] <= 449.00000000000006 then
            begin
                if features[66] <= 108.50000000000001 then
                begin
                    if features[64] <= 800.50000000000011 then
                    begin
                        Result := 0.0012245951508976858;
                    end
                    else
                    begin
                        Result := 0.028912514178109951;
                    end;
                end
                else
                begin
                    Result := -0.016836441928010218;
                end;
            end
            else
            begin
                if features[218] <= -6003.4999999999991 then
                begin
                    Result := 0.0006919885523139534;
                end
                else
                begin
                    if features[216] <= -4798.4999999999991 then
                    begin
                        Result := -0.016578610331146135;
                    end
                    else
                    begin
                        Result := -0.0025174647086956279;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_230(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[226] <= -1206.4999999999998 then
    begin
        Result := -0.020229547789056789;
    end
    else
    begin
        if features[71] <= 1.5000000000000002 then
        begin
            if features[81] <= -8999.4999999999982 then
            begin
                if features[223] <= -639.49999999999989 then
                begin
                    if features[70] <= 832.50000000000011 then
                    begin
                        Result := -0.0050387034500258788;
                    end
                    else
                    begin
                        Result := 0.078689927241111804;
                    end;
                end
                else
                begin
                    Result := 0.0033671368608466992;
                end;
            end
            else
            begin
                if features[43] <= 218.00000000000003 then
                begin
                    if features[178] <= -886.49999999999989 then
                    begin
                        Result := -0.020543836312524655;
                    end
                    else
                    begin
                        Result := 0.0040841584183136138;
                    end;
                end
                else
                begin
                    if features[221] <= -6312.4999999999991 then
                    begin
                        Result := -0.021227885123788245;
                    end
                    else
                    begin
                        Result := -0.006621048122355787;
                    end;
                end;
            end;
        end
        else
        begin
            if features[155] <= 1.0000000180025095E-35 then
            begin
                if features[226] <= 439.50000000000006 then
                begin
                    if features[69] <= 21.500000000000004 then
                    begin
                        Result := -0.00055911199921575706;
                    end
                    else
                    begin
                        Result := 0.012336235186463141;
                    end;
                end
                else
                begin
                    if features[170] <= 2.5000000000000004 then
                    begin
                        Result := 0.0032224141789640296;
                    end
                    else
                    begin
                        Result := 0.011253983976909371;
                    end;
                end;
            end
            else
            begin
                if features[36] <= 735.50000000000011 then
                begin
                    if features[140] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0009810001288311132;
                    end
                    else
                    begin
                        Result := -0.022083638466472728;
                    end;
                end
                else
                begin
                    Result := -0.015586790735395399;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_231(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[225] <= -3583.9999999999995 then
    begin
        if features[15] <= -336406943.99999994 then
        begin
            Result := -0.016897799755137565;
        end
        else
        begin
            if features[148] <= 2974.5000000000005 then
            begin
                if features[177] <= -5134.4999999999991 then
                begin
                    if features[176] <= -5551.4999999999991 then
                    begin
                        Result := 0.00041582016401635753;
                    end
                    else
                    begin
                        Result := -0.0068176844692747172;
                    end;
                end
                else
                begin
                    if features[185] <= -270.55000305175776 then
                    begin
                        Result := -0.019456959567713636;
                    end
                    else
                    begin
                        Result := 0.0087589020472816654;
                    end;
                end;
            end
            else
            begin
                if features[229] <= 5.5000000000000009 then
                begin
                    if features[222] <= -5548.4999999999991 then
                    begin
                        Result := -0.0027646610923340088;
                    end
                    else
                    begin
                        Result := -0.024534391037224958;
                    end;
                end
                else
                begin
                    if features[108] <= 316.50000000000006 then
                    begin
                        Result := 0.0039775744167737407;
                    end
                    else
                    begin
                        Result := -0.012252482076382793;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[175] <= 568.50000000000011 then
        begin
            if features[1] <= 122693.50000000001 then
            begin
                if features[221] <= -4293.4999999999991 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.0064347685441178797;
                    end
                    else
                    begin
                        Result := 0.019294684167295639;
                    end;
                end
                else
                begin
                    if features[91] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.02304537886695979;
                    end
                    else
                    begin
                        Result := -0.025089118107647624;
                    end;
                end;
            end
            else
            begin
                Result := 0.026154766442411478;
            end;
        end
        else
        begin
            Result := 0.018417964401502031;
        end;
    end;
end;

function second_slot_bidirectional_tree_232(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= -312987215.99999994 then
    begin
        if features[69] <= 17.500000000000004 then
        begin
            Result := -0.017774157955564213;
        end
        else
        begin
            Result := 0.036685410461293796;
        end;
    end
    else
    begin
        if features[47] <= 3274.5000000000005 then
        begin
            if features[129] <= -3788.9999999999995 then
            begin
                if features[45] <= 1.5000000000000002 then
                begin
                    Result := 0.055465852808267727;
                end
                else
                begin
                    if features[105] <= 1.5000000000000002 then
                    begin
                        Result := -0.0006193954592999722;
                    end
                    else
                    begin
                        Result := -0.02383872101305546;
                    end;
                end;
            end
            else
            begin
                if features[77] <= 4535.5000000000009 then
                begin
                    Result := 0.015421923451258585;
                end
                else
                begin
                    Result := 0.0041881750330129064;
                end;
            end;
        end
        else
        begin
            if features[90] <= 1.5000000000000002 then
            begin
                if features[55] <= 3.5000000000000004 then
                begin
                    if features[166] <= 64430050.000000007 then
                    begin
                        Result := -0.002037654225589886;
                    end
                    else
                    begin
                        Result := 0.0036782267774799699;
                    end;
                end
                else
                begin
                    if features[77] <= 60562.500000000007 then
                    begin
                        Result := -0.0083436789905573811;
                    end
                    else
                    begin
                        Result := 0.0489103827173741;
                    end;
                end;
            end
            else
            begin
                if features[158] <= 4775.0000000000009 then
                begin
                    if features[215] <= -4854.4999999999991 then
                    begin
                        Result := 0.0050974217184769077;
                    end
                    else
                    begin
                        Result := 0.02566416763460851;
                    end;
                end
                else
                begin
                    if features[70] <= 678.50000000000011 then
                    begin
                        Result := -0.0092741586720976165;
                    end
                    else
                    begin
                        Result := 0.0044376454299219483;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_233(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[15] <= -336406943.99999994 then
    begin
        if features[177] <= -4836.4999999999991 then
        begin
            Result := -0.019593324062151234;
        end
        else
        begin
            Result := 0.025422942949861208;
        end;
    end
    else
    begin
        if features[96] <= 224475544.00000003 then
        begin
            if features[41] <= 1462.5000000000002 then
            begin
                if features[215] <= -3227.4999999999995 then
                begin
                    if features[9] <= 11.500000000000002 then
                    begin
                        Result := 0.00055652123234804036;
                    end
                    else
                    begin
                        Result := 0.010614788449543703;
                    end;
                end
                else
                begin
                    Result := -0.020117473864871484;
                end;
            end
            else
            begin
                if features[216] <= -4337.4999999999991 then
                begin
                    if features[186] <= -98.291667938232408 then
                    begin
                        Result := 0.00028714496464278229;
                    end
                    else
                    begin
                        Result := -0.012202391513817698;
                    end;
                end
                else
                begin
                    if features[47] <= 3789.5000000000005 then
                    begin
                        Result := -0.025578840998770926;
                    end
                    else
                    begin
                        Result := 0.0090061596036005356;
                    end;
                end;
            end;
        end
        else
        begin
            if features[108] <= 748.50000000000011 then
            begin
                if features[177] <= -8313.4999999999982 then
                begin
                    if features[154] <= -323.49999999999994 then
                    begin
                        Result := 0.038415115981554906;
                    end
                    else
                    begin
                        Result := -0.018296796179642558;
                    end;
                end
                else
                begin
                    Result := -0.025649445136117804;
                end;
            end
            else
            begin
                if features[109] <= 1316.0000000000002 then
                begin
                    if features[96] <= 286974320.00000006 then
                    begin
                        Result := 0.028700263913791442;
                    end
                    else
                    begin
                        Result := -0.0048951684949477417;
                    end;
                end
                else
                begin
                    Result := -0.029509236831673419;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_234(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[173] <= -3910.9999999999995 then
    begin
        if features[27] <= -2884.4999999999995 then
        begin
            if features[180] <= -6271.4999999999991 then
            begin
                if features[222] <= -5368.4999999999991 then
                begin
                    if features[149] <= 820.00000000000011 then
                    begin
                        Result := -0.00090362864219882164;
                    end
                    else
                    begin
                        Result := 0.044171509959101733;
                    end;
                end
                else
                begin
                    if features[184] <= -1285.4999999999998 then
                    begin
                        Result := 0.024979404302599359;
                    end
                    else
                    begin
                        Result := 0.0038724943914706825;
                    end;
                end;
            end
            else
            begin
                if features[108] <= -581.49999999999989 then
                begin
                    if features[96] <= -8002660.4999999991 then
                    begin
                        Result := 0.0029662385707574911;
                    end
                    else
                    begin
                        Result := -0.021554637570606845;
                    end;
                end
                else
                begin
                    if features[173] <= -4430.4999999999991 then
                    begin
                        Result := -0.0030084233094036764;
                    end
                    else
                    begin
                        Result := 0.008851362905172749;
                    end;
                end;
            end;
        end
        else
        begin
            if features[148] <= 1609.5000000000002 then
            begin
                if features[217] <= 1284.5000000000002 then
                begin
                    Result := 0.021711055763455028;
                end
                else
                begin
                    Result := -0.0080986987795052517;
                end;
            end
            else
            begin
                if features[41] <= 47.500000000000007 then
                begin
                    Result := -0.03705925626511633;
                end
                else
                begin
                    Result := 0.011136105314066417;
                end;
            end;
        end;
    end
    else
    begin
        if features[166] <= 52018590.000000007 then
        begin
            if features[180] <= -8856.4999999999982 then
            begin
                Result := 0.041549101185644435;
            end
            else
            begin
                Result := -0.015386559324169319;
            end;
        end
        else
        begin
            Result := 0.010968478097750856;
        end;
    end;
end;

function second_slot_bidirectional_tree_235(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[42] <= 620.00000000000011 then
    begin
        if features[27] <= -2884.4999999999995 then
        begin
            if features[226] <= -1231.4999999999998 then
            begin
                Result := -0.018228706317866574;
            end
            else
            begin
                if features[108] <= -1306.4999999999998 then
                begin
                    if features[222] <= -5841.4999999999991 then
                    begin
                        Result := -0.0067001763388289592;
                    end
                    else
                    begin
                        Result := 0.027862818877571961;
                    end;
                end
                else
                begin
                    if features[179] <= -7097.4999999999991 then
                    begin
                        Result := 0.0023267709319022894;
                    end
                    else
                    begin
                        Result := -0.0013355510003317966;
                    end;
                end;
            end;
        end
        else
        begin
            if features[177] <= -5888.4999999999991 then
            begin
                Result := -0.012340038585921519;
            end
            else
            begin
                if features[148] <= 1504.5000000000002 then
                begin
                    Result := 0.024756463326354356;
                end
                else
                begin
                    Result := -0.010786632877902623;
                end;
            end;
        end;
    end
    else
    begin
        if features[53] <= 1.0000000180025095E-35 then
        begin
            if features[18] <= 8.5000000000000018 then
            begin
                Result := 0.029004044037586409;
            end
            else
            begin
                Result := -0.0033191996841826737;
            end;
        end
        else
        begin
            if features[216] <= -4715.4999999999991 then
            begin
                if features[182] <= -7097.4999999999991 then
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.026862788212590666;
                    end
                    else
                    begin
                        Result := -0.012483310069936492;
                    end;
                end
                else
                begin
                    Result := -0.020520214018340043;
                end;
            end
            else
            begin
                if features[182] <= -4644.4999999999991 then
                begin
                    Result := 0.0024048863658858652;
                end
                else
                begin
                    Result := -0.030008981683535704;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_236(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[9] <= 11.500000000000002 then
        begin
            if features[164] <= 76017060.000000015 then
            begin
                if features[28] <= -5993.4999999999991 then
                begin
                    if features[126] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.00094479021264162787;
                    end
                    else
                    begin
                        Result := -0.0060124322226773998;
                    end;
                end
                else
                begin
                    if features[216] <= -6312.4999999999991 then
                    begin
                        Result := -0.025389621175340174;
                    end
                    else
                    begin
                        Result := -0.0066151987202077659;
                    end;
                end;
            end
            else
            begin
                if features[150] <= -1.0000000180025095E-35 then
                begin
                    if features[186] <= -539.89999389648426 then
                    begin
                        Result := 0.024687386449086138;
                    end
                    else
                    begin
                        Result := 0.0052883956111203587;
                    end;
                end
                else
                begin
                    if features[77] <= 6775.0000000000009 then
                    begin
                        Result := 0.0019469124754430322;
                    end
                    else
                    begin
                        Result := -0.0062710833978639018;
                    end;
                end;
            end;
        end
        else
        begin
            if features[180] <= -7261.4999999999991 then
            begin
                if features[42] <= 471.50000000000006 then
                begin
                    Result := -0.015676236258850871;
                end
                else
                begin
                    Result := 0.015146248564924365;
                end;
            end
            else
            begin
                if features[151] <= -111.49999999999999 then
                begin
                    if features[67] <= 3753.5000000000005 then
                    begin
                        Result := -0.01319664563506133;
                    end
                    else
                    begin
                        Result := 0.031214747611923166;
                    end;
                end
                else
                begin
                    if features[95] <= 30634392.000000004 then
                    begin
                        Result := 0.022961729488575132;
                    end
                    else
                    begin
                        Result := -0.010448585819874977;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.024548976984234777;
    end;
end;

function second_slot_bidirectional_tree_237(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[164] <= -502674303.99999994 then
    begin
        if features[136] <= -1.0000000180025095E-35 then
        begin
            if features[225] <= -6200.4999999999991 then
            begin
                Result := -0.019899295500810373;
            end
            else
            begin
                Result := 0.048375469877880557;
            end;
        end
        else
        begin
            if features[92] <= 6.5000000000000009 then
            begin
                if features[166] <= 224717184.00000003 then
                begin
                    Result := -0.027337268170270792;
                end
                else
                begin
                    Result := 0.021984590726975017;
                end;
            end
            else
            begin
                Result := 0.031263422744074003;
            end;
        end;
    end
    else
    begin
        if features[78] <= 309.00000000000006 then
        begin
            if features[182] <= -4541.4999999999991 then
            begin
                if features[78] <= 257.00000000000006 then
                begin
                    if features[181] <= -1518.4999999999998 then
                    begin
                        Result := 0.010786393601548896;
                    end
                    else
                    begin
                        Result := 0.00024994706694438459;
                    end;
                end
                else
                begin
                    Result := 0.045652434189261293;
                end;
            end
            else
            begin
                if features[109] <= -294.49999999999994 then
                begin
                    if features[0] <= 23854.000000000004 then
                    begin
                        Result := 0.011763854692800542;
                    end
                    else
                    begin
                        Result := -0.02312315531763736;
                    end;
                end
                else
                begin
                    if features[216] <= -4044.4999999999995 then
                    begin
                        Result := -0.012445447967927209;
                    end
                    else
                    begin
                        Result := 0.01277406841342669;
                    end;
                end;
            end;
        end
        else
        begin
            if features[216] <= -6166.4999999999991 then
            begin
                Result := 4.6944626050869338E-05;
            end
            else
            begin
                Result := -0.030242458307622344;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_238(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[164] <= 53095248.000000007 then
    begin
        if features[28] <= -5763.4999999999991 then
        begin
            if features[179] <= -7097.4999999999991 then
            begin
                if features[70] <= 837.50000000000011 then
                begin
                    if features[69] <= 12.500000000000002 then
                    begin
                        Result := 0.0026431235962899166;
                    end
                    else
                    begin
                        Result := 0.017444645809799656;
                    end;
                end
                else
                begin
                    if features[173] <= -7227.4999999999991 then
                    begin
                        Result := -0.015140594576138564;
                    end
                    else
                    begin
                        Result := 0.00066385483514084024;
                    end;
                end;
            end
            else
            begin
                Result := -0.0024671559355360973;
            end;
        end
        else
        begin
            Result := -0.012998030802373304;
        end;
    end
    else
    begin
        if features[28] <= -5443.4999999999991 then
        begin
            if features[92] <= 1.5000000000000002 then
            begin
                if features[226] <= 373.50000000000006 then
                begin
                    if features[107] <= -1.4999999999999998 then
                    begin
                        Result := -0.017862160508697052;
                    end
                    else
                    begin
                        Result := 0.0013412311322714516;
                    end;
                end
                else
                begin
                    Result := 0.0092908451882808326;
                end;
            end
            else
            begin
                if features[82] <= 132789.50000000003 then
                begin
                    Result := 0.019753432498958886;
                end
                else
                begin
                    Result := -0.0071659539759642669;
                end;
            end;
        end
        else
        begin
            if features[174] <= -4509.4999999999991 then
            begin
                Result := -0.0024246584563321098;
            end
            else
            begin
                if features[223] <= -437.49999999999994 then
                begin
                    Result := 0.025092568284457495;
                end
                else
                begin
                    if features[185] <= -49.874999999999993 then
                    begin
                        Result := -0.0083420711467474661;
                    end
                    else
                    begin
                        Result := 0.0077675275935916339;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_239(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[36] <= 921.50000000000011 then
    begin
        if features[164] <= 73272196.000000015 then
        begin
            if features[179] <= -6108.4999999999991 then
            begin
                if features[82] <= -83932.499999999985 then
                begin
                    if features[218] <= -5483.4999999999991 then
                    begin
                        Result := -0.0021111881162162328;
                    end
                    else
                    begin
                        Result := -0.015672047043502505;
                    end;
                end
                else
                begin
                    if features[222] <= -5368.4999999999991 then
                    begin
                        Result := -0.00027301574756636638;
                    end
                    else
                    begin
                        Result := 0.0057378795945961002;
                    end;
                end;
            end
            else
            begin
                if features[228] <= -3446.4999999999995 then
                begin
                    if features[165] <= -183102015.99999997 then
                    begin
                        Result := 0.0091068786149316409;
                    end
                    else
                    begin
                        Result := -0.0088467198637927746;
                    end;
                end
                else
                begin
                    Result := 0.02795794219506308;
                end;
            end;
        end
        else
        begin
            if features[219] <= -6892.4999999999991 then
            begin
                if features[215] <= -5390.4999999999991 then
                begin
                    if features[94] <= 87587.500000000015 then
                    begin
                        Result := -0.0059275507424223443;
                    end
                    else
                    begin
                        Result := 0.037750349389075177;
                    end;
                end
                else
                begin
                    if features[27] <= -4948.4999999999991 then
                    begin
                        Result := -0.026641652921963563;
                    end
                    else
                    begin
                        Result := 0.036279080850985621;
                    end;
                end;
            end
            else
            begin
                if features[215] <= -6426.4999999999991 then
                begin
                    Result := -0.0056074205666820634;
                end
                else
                begin
                    Result := 0.0031540191938283315;
                end;
            end;
        end;
    end
    else
    begin
        if features[73] <= 113.50000000000001 then
        begin
            Result := -0.012528748996605544;
        end
        else
        begin
            Result := 0.006784665514213091;
        end;
    end;
end;

function second_slot_bidirectional_tree_240(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[15] <= -384300207.99999994 then
    begin
        if features[120] <= -1429.9999999999998 then
        begin
            Result := 0.023834398439269249;
        end
        else
        begin
            Result := -0.025169807977658627;
        end;
    end
    else
    begin
        if features[146] <= 1794.5000000000002 then
        begin
            if features[63] <= 140.50000000000003 then
            begin
                if features[166] <= -298130495.99999994 then
                begin
                    if features[216] <= -7163.4999999999991 then
                    begin
                        Result := 0.036154657263260982;
                    end
                    else
                    begin
                        Result := -0.01518865302693901;
                    end;
                end
                else
                begin
                    if features[186] <= -474.87499999999994 then
                    begin
                        Result := 0.0072930050912027901;
                    end
                    else
                    begin
                        Result := 6.4354645727112095E-05;
                    end;
                end;
            end
            else
            begin
                if features[223] <= 271.50000000000006 then
                begin
                    if features[106] <= 1.5000000000000002 then
                    begin
                        Result := 0.012771118381308282;
                    end
                    else
                    begin
                        Result := 0.047794040254048341;
                    end;
                end
                else
                begin
                    if features[180] <= -6998.4999999999991 then
                    begin
                        Result := -0.027948637938721099;
                    end
                    else
                    begin
                        Result := 0.0040235026881303591;
                    end;
                end;
            end;
        end
        else
        begin
            if features[141] <= 7.5000000000000009 then
            begin
                if features[128] <= -18734.499999999996 then
                begin
                    if features[224] <= -5155.4999999999991 then
                    begin
                        Result := -0.020837437276782882;
                    end
                    else
                    begin
                        Result := 0.029326543803131894;
                    end;
                end
                else
                begin
                    Result := -0.019729210263688846;
                end;
            end
            else
            begin
                if features[75] <= 8.5000000000000018 then
                begin
                    Result := 0.031025391471517335;
                end
                else
                begin
                    Result := -0.023741510954196372;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_241(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[26] <= 12.500000000000002 then
    begin
        if features[107] <= -1.0000000180025095E-35 then
        begin
            if features[47] <= 4283.5000000000009 then
            begin
                if features[175] <= 1474.5000000000002 then
                begin
                    if features[171] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.011762171456563039;
                    end
                    else
                    begin
                        Result := 0.0013572646720718272;
                    end;
                end
                else
                begin
                    Result := 0.011493237534774959;
                end;
            end
            else
            begin
                if features[179] <= -6357.4999999999991 then
                begin
                    Result := -0.012779568614450679;
                end
                else
                begin
                    if features[166] <= 34964100.000000007 then
                    begin
                        Result := -0.0083391922532809627;
                    end
                    else
                    begin
                        Result := 0.0081987950035898802;
                    end;
                end;
            end;
        end
        else
        begin
            if features[173] <= -6124.4999999999991 then
            begin
                if features[218] <= -5277.4999999999991 then
                begin
                    if features[187] <= 3.0357142686843877 then
                    begin
                        Result := 0.0021413139904837069;
                    end
                    else
                    begin
                        Result := 0.0090154753491679934;
                    end;
                end
                else
                begin
                    if features[173] <= -6302.4999999999991 then
                    begin
                        Result := -0.0099175715143673977;
                    end
                    else
                    begin
                        Result := 0.014192536846816048;
                    end;
                end;
            end
            else
            begin
                if features[216] <= -4044.4999999999995 then
                begin
                    if features[108] <= 56.500000000000007 then
                    begin
                        Result := -0.0037564950510211499;
                    end
                    else
                    begin
                        Result := 0.0025218307184215367;
                    end;
                end
                else
                begin
                    if features[217] <= 465.50000000000006 then
                    begin
                        Result := 0.013479793141431096;
                    end
                    else
                    begin
                        Result := -0.0034998941411093854;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.018403682292621182;
    end;
end;

function second_slot_bidirectional_tree_242(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[107] <= -1.0000000180025095E-35 then
    begin
        Result := -0.0040448684368617387;
    end
    else
    begin
        if features[226] <= -12.499999999999998 then
        begin
            if features[217] <= 494.50000000000006 then
            begin
                if features[47] <= 12014.000000000002 then
                begin
                    if features[26] <= 8.5000000000000018 then
                    begin
                        Result := -0.0012085929970941528;
                    end
                    else
                    begin
                        Result := -0.025094908470237993;
                    end;
                end
                else
                begin
                    if features[215] <= -5629.4999999999991 then
                    begin
                        Result := 0.024427475830478343;
                    end
                    else
                    begin
                        Result := 0.0020571834384407327;
                    end;
                end;
            end
            else
            begin
                if features[187] <= 92.585712432861342 then
                begin
                    Result := -0.013084147911423328;
                end
                else
                begin
                    if features[180] <= -6643.4999999999991 then
                    begin
                        Result := 0.055415030930947608;
                    end
                    else
                    begin
                        Result := -0.0069340978039260474;
                    end;
                end;
            end;
        end
        else
        begin
            if features[171] <= 1.0000000180025095E-35 then
            begin
                if features[175] <= 284.50000000000006 then
                begin
                    if features[180] <= -7990.4999999999991 then
                    begin
                        Result := 0.011788975013846476;
                    end
                    else
                    begin
                        Result := -0.010251058944335645;
                    end;
                end
                else
                begin
                    Result := 0.0059124754731067469;
                end;
            end
            else
            begin
                if features[82] <= -279430.99999999994 then
                begin
                    if features[225] <= -3957.4999999999995 then
                    begin
                        Result := -0.034527541899266379;
                    end
                    else
                    begin
                        Result := 0.025305853154301533;
                    end;
                end
                else
                begin
                    if features[96] <= 182914768.00000003 then
                    begin
                        Result := 0.0051180446280471486;
                    end
                    else
                    begin
                        Result := -0.016286494225038566;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_243(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[117] <= 924.50000000000011 then
    begin
        if features[173] <= -3910.9999999999995 then
        begin
            if features[27] <= -2884.4999999999995 then
            begin
                if features[182] <= -4680.4999999999991 then
                begin
                    if features[129] <= 10443.500000000002 then
                    begin
                        Result := -6.8047365420984088E-05;
                    end
                    else
                    begin
                        Result := 0.005057261808202252;
                    end;
                end
                else
                begin
                    if features[217] <= 258.50000000000006 then
                    begin
                        Result := -0.00089710437169659833;
                    end
                    else
                    begin
                        Result := -0.021264291566000296;
                    end;
                end;
            end
            else
            begin
                if features[185] <= -74.874999999999986 then
                begin
                    Result := -0.01176307392001825;
                end
                else
                begin
                    if features[176] <= -5513.4999999999991 then
                    begin
                        Result := 0.007937509369041168;
                    end
                    else
                    begin
                        Result := 0.029840016696349;
                    end;
                end;
            end;
        end
        else
        begin
            if features[219] <= -7153.4999999999991 then
            begin
                if features[73] <= 108.50000000000001 then
                begin
                    Result := 0.050134778931173754;
                end
                else
                begin
                    Result := -0.020089275722878254;
                end;
            end
            else
            begin
                if features[76] <= 2.5000000000000004 then
                begin
                    if features[158] <= 2387.5000000000005 then
                    begin
                        Result := -0.0072642305769358099;
                    end
                    else
                    begin
                        Result := 0.036373152960927725;
                    end;
                end
                else
                begin
                    if features[185] <= 410.16667175292974 then
                    begin
                        Result := -0.021763506009927675;
                    end
                    else
                    begin
                        Result := 0.019949551215645216;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[36] <= 1040.5000000000002 then
        begin
            Result := -0.028628610129882638;
        end
        else
        begin
            Result := 0.0035616549521330964;
        end;
    end;
end;

function second_slot_bidirectional_tree_244(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[146] <= 1794.5000000000002 then
    begin
        if features[164] <= -486010335.99999994 then
        begin
            if features[158] <= 30536.000000000004 then
            begin
                Result := -0.019265420120312321;
            end
            else
            begin
                Result := 0.02506046329221755;
            end;
        end
        else
        begin
            if features[173] <= -3910.9999999999995 then
            begin
                if features[216] <= -4102.4999999999991 then
                begin
                    if features[224] <= -3740.4999999999995 then
                    begin
                        Result := -8.9679858039989395E-05;
                    end
                    else
                    begin
                        Result := -0.020781217363879372;
                    end;
                end
                else
                begin
                    if features[171] <= 4.5000000000000009 then
                    begin
                        Result := 0.00031394832467668596;
                    end
                    else
                    begin
                        Result := 0.012001098991870289;
                    end;
                end;
            end
            else
            begin
                if features[76] <= 2.5000000000000004 then
                begin
                    if features[136] <= 1.5000000000000002 then
                    begin
                        Result := -0.0053006917527784522;
                    end
                    else
                    begin
                        Result := 0.045109897852511738;
                    end;
                end
                else
                begin
                    if features[26] <= 3.5000000000000004 then
                    begin
                        Result := -0.021512562128514656;
                    end
                    else
                    begin
                        Result := 0.017598948387377477;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[151] <= -1.4999999999999998 then
        begin
            if features[81] <= 5940.0000000000009 then
            begin
                if features[219] <= -4975.4999999999991 then
                begin
                    Result := -0.024394883494541601;
                end
                else
                begin
                    Result := 0.001953077590157958;
                end;
            end
            else
            begin
                if features[226] <= 246.50000000000003 then
                begin
                    Result := -0.015863470321508987;
                end
                else
                begin
                    Result := 0.034098787467811295;
                end;
            end;
        end
        else
        begin
            Result := -0.030007099041409076;
        end;
    end;
end;

function second_slot_bidirectional_tree_245(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[228] <= -3446.4999999999995 then
    begin
        if features[121] <= 310.50000000000006 then
        begin
            if features[222] <= -5196.4999999999991 then
            begin
                if features[179] <= -7110.4999999999991 then
                begin
                    if features[68] <= 820.00000000000011 then
                    begin
                        Result := 0.001057952571382243;
                    end
                    else
                    begin
                        Result := 0.019527097936246594;
                    end;
                end
                else
                begin
                    if features[166] <= 6453940.0000000009 then
                    begin
                        Result := -0.0056392056060172949;
                    end
                    else
                    begin
                        Result := 0.0029746506746954043;
                    end;
                end;
            end
            else
            begin
                if features[180] <= -7181.4999999999991 then
                begin
                    if features[96] <= -76211895.999999985 then
                    begin
                        Result := 0.039162008887593053;
                    end
                    else
                    begin
                        Result := 0.0098197103128621135;
                    end;
                end
                else
                begin
                    if features[107] <= 1.5000000000000002 then
                    begin
                        Result := 0.0028584674024553051;
                    end
                    else
                    begin
                        Result := -0.0091201866370202288;
                    end;
                end;
            end;
        end
        else
        begin
            if features[172] <= 2.5000000000000004 then
            begin
                if features[121] <= 1213.5000000000002 then
                begin
                    Result := -0.019742145199256014;
                end
                else
                begin
                    if features[224] <= -5031.4999999999991 then
                    begin
                        Result := 0.000692559477287058;
                    end
                    else
                    begin
                        Result := 0.020904497167360089;
                    end;
                end;
            end
            else
            begin
                if features[166] <= 452138240.00000006 then
                begin
                    if features[128] <= -1065.4999999999998 then
                    begin
                        Result := -0.017989899326132222;
                    end
                    else
                    begin
                        Result := -0.0053190816568281672;
                    end;
                end
                else
                begin
                    Result := 0.0092469080823327308;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.0092450531213195478;
    end;
end;

function second_slot_bidirectional_tree_246(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[95] <= -290593695.99999994 then
    begin
        if features[13] <= 248843.50000000003 then
        begin
            Result := -0.014608154335956539;
        end
        else
        begin
            Result := 0.053116891931421023;
        end;
    end
    else
    begin
        if features[215] <= -4006.4999999999995 then
        begin
            if features[215] <= -4288.4999999999991 then
            begin
                if features[176] <= -4608.4999999999991 then
                begin
                    if features[36] <= 767.50000000000011 then
                    begin
                        Result := 0.0011946908081674386;
                    end
                    else
                    begin
                        Result := -0.0052038512877542091;
                    end;
                end
                else
                begin
                    if features[128] <= -1.4999999999999998 then
                    begin
                        Result := -0.0042124904778896135;
                    end
                    else
                    begin
                        Result := -0.024442825253028155;
                    end;
                end;
            end
            else
            begin
                if features[218] <= -5890.4999999999991 then
                begin
                    if features[221] <= -4948.4999999999991 then
                    begin
                        Result := -0.018523903690962185;
                    end
                    else
                    begin
                        Result := 0.011171036092435223;
                    end;
                end
                else
                begin
                    if features[157] <= -9.4999999999999982 then
                    begin
                        Result := -0.032386189086892406;
                    end
                    else
                    begin
                        Result := 0.014497909256076883;
                    end;
                end;
            end;
        end
        else
        begin
            if features[184] <= -494.49999999999994 then
            begin
                Result := -0.016940172789310249;
            end
            else
            begin
                if features[218] <= -6495.4999999999991 then
                begin
                    if features[117] <= 7.5000000000000009 then
                    begin
                        Result := -0.003247080774461235;
                    end
                    else
                    begin
                        Result := 0.051828044424323316;
                    end;
                end
                else
                begin
                    if features[216] <= -4054.4999999999995 then
                    begin
                        Result := -0.010150299148245768;
                    end
                    else
                    begin
                        Result := 0.0049831101853292726;
                    end;
                end;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_247(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[166] <= 26972834.000000004 then
    begin
        if features[108] <= 81.500000000000014 then
        begin
            if features[176] <= -5934.4999999999991 then
            begin
                if features[184] <= -1285.4999999999998 then
                begin
                    Result := 0.019050711701192408;
                end
                else
                begin
                    if features[222] <= -5368.4999999999991 then
                    begin
                        Result := -0.0043391403458565535;
                    end
                    else
                    begin
                        Result := 0.0031520137321361047;
                    end;
                end;
            end
            else
            begin
                if features[224] <= -5502.4999999999991 then
                begin
                    Result := -0.015884319524950331;
                end
                else
                begin
                    if features[121] <= 310.50000000000006 then
                    begin
                        Result := -0.0016164936638387558;
                    end
                    else
                    begin
                        Result := -0.018733073028220911;
                    end;
                end;
            end;
        end
        else
        begin
            if features[151] <= -60.499999999999993 then
            begin
                if features[177] <= -6062.4999999999991 then
                begin
                    if features[117] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.014282633952044672;
                    end
                    else
                    begin
                        Result := 0.006406496272034802;
                    end;
                end
                else
                begin
                    Result := 0.017529194535919345;
                end;
            end
            else
            begin
                if features[82] <= -210.99999999999997 then
                begin
                    Result := -0.0089207985645358822;
                end
                else
                begin
                    Result := 0.0054820235502202191;
                end;
            end;
        end;
    end
    else
    begin
        if features[128] <= -16716.499999999996 then
        begin
            if features[121] <= 1441.5000000000002 then
            begin
                Result := -0.0013448280696301688;
            end
            else
            begin
                Result := -0.026488883277733955;
            end;
        end
        else
        begin
            if features[15] <= -121025235.99999999 then
            begin
                Result := -0.011689460376531534;
            end
            else
            begin
                Result := 0.0054997033488885889;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_248(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[73] <= 563.00000000000011 then
    begin
        if features[121] <= 1402.5000000000002 then
        begin
            if features[226] <= 1340.5000000000002 then
            begin
                if features[219] <= -7019.4999999999991 then
                begin
                    if features[14] <= -249622351.99999997 then
                    begin
                        Result := -0.020021026784447837;
                    end
                    else
                    begin
                        Result := 0.0084601120140427016;
                    end;
                end
                else
                begin
                    if features[223] <= -740.49999999999989 then
                    begin
                        Result := -0.0091577303847681351;
                    end
                    else
                    begin
                        Result := 0.00022983994049750341;
                    end;
                end;
            end
            else
            begin
                Result := 0.0089106748250101543;
            end;
        end
        else
        begin
            if features[128] <= -406.49999999999994 then
            begin
                if features[220] <= -273.49999999999994 then
                begin
                    if features[184] <= -166.49999999999997 then
                    begin
                        Result := -0.024564216112966455;
                    end
                    else
                    begin
                        Result := 0.038908797055825055;
                    end;
                end
                else
                begin
                    Result := -0.018546549523348693;
                end;
            end
            else
            begin
                if features[166] <= -25979130.999999996 then
                begin
                    if features[222] <= -5519.4999999999991 then
                    begin
                        Result := 0.017916650665103971;
                    end
                    else
                    begin
                        Result := -0.020086464451190569;
                    end;
                end
                else
                begin
                    if features[117] <= 311.50000000000006 then
                    begin
                        Result := -0.018630037127052849;
                    end
                    else
                    begin
                        Result := 0.023625710355578488;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[48] <= 27790.500000000004 then
        begin
            if features[228] <= -4218.4999999999991 then
            begin
                Result := -0.014201337496066918;
            end
            else
            begin
                Result := 0.0076988274134227545;
            end;
        end
        else
        begin
            Result := 0.020038940869130582;
        end;
    end;
end;

function second_slot_bidirectional_tree_249(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[117] <= 924.50000000000011 then
    begin
        if features[215] <= -3227.4999999999995 then
        begin
            if features[228] <= -3446.4999999999995 then
            begin
                if features[227] <= -3728.4999999999995 then
                begin
                    if features[73] <= 573.50000000000011 then
                    begin
                        Result := 0.0005460102217967808;
                    end
                    else
                    begin
                        Result := -0.0087516156771404088;
                    end;
                end
                else
                begin
                    if features[151] <= -9.4999999999999982 then
                    begin
                        Result := -0.020466396794506552;
                    end
                    else
                    begin
                        Result := -0.00032377640900386182;
                    end;
                end;
            end
            else
            begin
                if features[40] <= 1135.5000000000002 then
                begin
                    if features[226] <= 386.50000000000006 then
                    begin
                        Result := -0.00014009124180902033;
                    end
                    else
                    begin
                        Result := 0.02307675539368469;
                    end;
                end
                else
                begin
                    if features[77] <= 4464.5000000000009 then
                    begin
                        Result := -0.017165300316827815;
                    end
                    else
                    begin
                        Result := 0.0084488226722647091;
                    end;
                end;
            end;
        end
        else
        begin
            if features[121] <= 448.50000000000006 then
            begin
                if features[154] <= -685.99999999999989 then
                begin
                    Result := 0.00809189550298672;
                end
                else
                begin
                    Result := -0.028691002529377469;
                end;
            end
            else
            begin
                if features[27] <= -3869.4999999999995 then
                begin
                    Result := 0.03170016490988966;
                end
                else
                begin
                    Result := -0.018307707474098;
                end;
            end;
        end;
    end
    else
    begin
        if features[123] <= 718.00000000000011 then
        begin
            Result := -0.030903393376164514;
        end
        else
        begin
            if features[121] <= 1267.5000000000002 then
            begin
                Result := -0.021743171999152513;
            end
            else
            begin
                Result := 0.02137626266140458;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_250(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[107] <= 10.500000000000002 then
    begin
        if features[73] <= 573.50000000000011 then
        begin
            if features[77] <= 5937.5000000000009 then
            begin
                if features[145] <= -1661.4999999999998 then
                begin
                    if features[75] <= 7.5000000000000009 then
                    begin
                        Result := 0.036393535793615601;
                    end
                    else
                    begin
                        Result := -0.014199108030150032;
                    end;
                end
                else
                begin
                    if features[70] <= 949.50000000000011 then
                    begin
                        Result := 0.0017958709813181218;
                    end
                    else
                    begin
                        Result := 0.040244854350947747;
                    end;
                end;
            end
            else
            begin
                if features[166] <= -65235857.999999993 then
                begin
                    if features[77] <= 20437.500000000004 then
                    begin
                        Result := -0.008469571620068608;
                    end
                    else
                    begin
                        Result := 0.0024544948190309726;
                    end;
                end
                else
                begin
                    if features[54] <= 12.500000000000002 then
                    begin
                        Result := 9.4530309162463579E-05;
                    end
                    else
                    begin
                        Result := 0.017046539647354957;
                    end;
                end;
            end;
        end
        else
        begin
            if features[228] <= -4262.4999999999991 then
            begin
                if features[18] <= 6.5000000000000009 then
                begin
                    if features[182] <= -6166.4999999999991 then
                    begin
                        Result := 0.016972802869362518;
                    end
                    else
                    begin
                        Result := -0.022804048172422358;
                    end;
                end
                else
                begin
                    Result := -0.018767540365300608;
                end;
            end
            else
            begin
                if features[39] <= 1462.5000000000002 then
                begin
                    Result := 0.025547154329785916;
                end
                else
                begin
                    Result := -0.013279659559645135;
                end;
            end;
        end;
    end
    else
    begin
        if features[120] <= 247.50000000000003 then
        begin
            Result := -0.025409549980038904;
        end
        else
        begin
            Result := 0.019633424008653571;
        end;
    end;
end;

function second_slot_bidirectional_tree_251(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[146] <= 1779.5000000000002 then
    begin
        if features[94] <= -126027.49999999999 then
        begin
            if features[120] <= -1.0000000180025095E-35 then
            begin
                Result := -0.027751047861833529;
            end
            else
            begin
                if features[177] <= -6078.4999999999991 then
                begin
                    if features[181] <= 562.50000000000011 then
                    begin
                        Result := -0.015099355078807112;
                    end
                    else
                    begin
                        Result := 0.0049500764509075174;
                    end;
                end
                else
                begin
                    if features[151] <= 13.500000000000002 then
                    begin
                        Result := 0.014849127342081395;
                    end
                    else
                    begin
                        Result := -0.025111525507754803;
                    end;
                end;
            end;
        end
        else
        begin
            if features[64] <= 779.00000000000011 then
            begin
                if features[219] <= -7299.4999999999991 then
                begin
                    if features[171] <= 1.5000000000000002 then
                    begin
                        Result := 0.02050862987907183;
                    end
                    else
                    begin
                        Result := -0.0012564615499041437;
                    end;
                end
                else
                begin
                    if features[178] <= -959.49999999999989 then
                    begin
                        Result := -0.0050623166092606557;
                    end
                    else
                    begin
                        Result := 0.00047151425981384343;
                    end;
                end;
            end
            else
            begin
                if features[69] <= 6.5000000000000009 then
                begin
                    if features[180] <= -6676.4999999999991 then
                    begin
                        Result := -0.015252927162291133;
                    end
                    else
                    begin
                        Result := 0.013295901802684564;
                    end;
                end
                else
                begin
                    Result := 0.038408508541266831;
                end;
            end;
        end;
    end
    else
    begin
        if features[186] <= 217.16666412353518 then
        begin
            Result := -0.020817722307012204;
        end
        else
        begin
            if features[135] <= 4.5000000000000009 then
            begin
                Result := -0.0087085356807118323;
            end
            else
            begin
                Result := 0.03319409556673554;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_252(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[215] <= -3227.4999999999995 then
    begin
        if features[216] <= -4054.4999999999995 then
        begin
            if features[224] <= -3882.4999999999995 then
            begin
                if features[41] <= 1462.5000000000002 then
                begin
                    if features[164] <= 73272196.000000015 then
                    begin
                        Result := -0.00088847957652483402;
                    end
                    else
                    begin
                        Result := 0.0029925110617914398;
                    end;
                end
                else
                begin
                    Result := -0.0058552467147949963;
                end;
            end
            else
            begin
                if features[77] <= 31812.500000000004 then
                begin
                    Result := -0.020317315411635561;
                end
                else
                begin
                    if features[227] <= -3877.4999999999995 then
                    begin
                        Result := 0.080674054462080161;
                    end
                    else
                    begin
                        Result := -0.016583896839178571;
                    end;
                end;
            end;
        end
        else
        begin
            if features[217] <= 465.50000000000006 then
            begin
                if features[215] <= -4049.4999999999995 then
                begin
                    if features[166] <= -110342239.99999999 then
                    begin
                        Result := 0.049802603304832993;
                    end
                    else
                    begin
                        Result := 0.013925268244315094;
                    end;
                end
                else
                begin
                    if features[173] <= -6142.4999999999991 then
                    begin
                        Result := -0.022651399965664867;
                    end
                    else
                    begin
                        Result := 0.0081897110370943924;
                    end;
                end;
            end
            else
            begin
                if features[176] <= -6122.4999999999991 then
                begin
                    if features[226] <= -306.49999999999994 then
                    begin
                        Result := -0.026661685854859743;
                    end
                    else
                    begin
                        Result := 0.006276190324868397;
                    end;
                end
                else
                begin
                    if features[164] <= 433469504.00000006 then
                    begin
                        Result := -0.013223267244233713;
                    end
                    else
                    begin
                        Result := 0.01815279105514574;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.020773957701756052;
    end;
end;

function second_slot_bidirectional_tree_253(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[105] <= 2.5000000000000004 then
    begin
        if features[71] <= 1.5000000000000002 then
        begin
            if features[47] <= 3060.5000000000005 then
            begin
                if features[76] <= 1.5000000000000002 then
                begin
                    if features[219] <= -6638.4999999999991 then
                    begin
                        Result := 0.069708870076601231;
                    end
                    else
                    begin
                        Result := 0.012378834889662099;
                    end;
                end
                else
                begin
                    if features[216] <= -4079.4999999999995 then
                    begin
                        Result := -0.001566972701174636;
                    end
                    else
                    begin
                        Result := 0.037744284418615208;
                    end;
                end;
            end
            else
            begin
                if features[81] <= -122124.49999999999 then
                begin
                    if features[178] <= -473.49999999999994 then
                    begin
                        Result := 0.053067214152200629;
                    end
                    else
                    begin
                        Result := 0.002675382349331457;
                    end;
                end
                else
                begin
                    if features[175] <= -409.49999999999994 then
                    begin
                        Result := -0.011722253125662595;
                    end
                    else
                    begin
                        Result := -0.0026364777579075595;
                    end;
                end;
            end;
        end
        else
        begin
            if features[166] <= -312987215.99999994 then
            begin
                Result := -0.013792428916135073;
            end
            else
            begin
                if features[96] <= 179340080.00000003 then
                begin
                    if features[107] <= -1.4999999999999998 then
                    begin
                        Result := -0.0071875720649815875;
                    end
                    else
                    begin
                        Result := 0.0026846920105820086;
                    end;
                end
                else
                begin
                    Result := -0.0087459408848876256;
                end;
            end;
        end;
    end
    else
    begin
        if features[129] <= -19545.999999999996 then
        begin
            Result := -0.02123645653031709;
        end
        else
        begin
            if features[106] <= 2.5000000000000004 then
            begin
                Result := 0.00054039923425648498;
            end
            else
            begin
                Result := -0.0089500408779465239;
            end;
        end;
    end;
end;

function second_slot_bidirectional_tree_254(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[225] <= -3345.9999999999995 then
    begin
        if features[107] <= -1.4999999999999998 then
        begin
            if features[221] <= -5777.4999999999991 then
            begin
                if features[47] <= 4332.5000000000009 then
                begin
                    if features[228] <= -6113.4999999999991 then
                    begin
                        Result := 0.024475091845842251;
                    end
                    else
                    begin
                        Result := 0.0014824699816288699;
                    end;
                end
                else
                begin
                    if features[219] <= -6557.4999999999991 then
                    begin
                        Result := 0.013096666214043547;
                    end
                    else
                    begin
                        Result := -0.013056112394990108;
                    end;
                end;
            end
            else
            begin
                if features[129] <= 3749.5000000000005 then
                begin
                    Result := -0.012805786520064472;
                end
                else
                begin
                    Result := 0.00067624111025514925;
                end;
            end;
        end
        else
        begin
            if features[94] <= -39871.999999999993 then
            begin
                if features[154] <= -122.49999999999999 then
                begin
                    if features[226] <= -390.49999999999994 then
                    begin
                        Result := -0.014135181751748473;
                    end
                    else
                    begin
                        Result := 0.0032349841959090613;
                    end;
                end
                else
                begin
                    if features[0] <= 75458.500000000015 then
                    begin
                        Result := -0.005534919290227586;
                    end
                    else
                    begin
                        Result := -0.020036093342601161;
                    end;
                end;
            end
            else
            begin
                if features[74] <= 15.500000000000002 then
                begin
                    if features[47] <= 2795.5000000000005 then
                    begin
                        Result := 0.0078935039408955573;
                    end
                    else
                    begin
                        Result := 0.00071638009205487129;
                    end;
                end
                else
                begin
                    if features[0] <= 219072.50000000003 then
                    begin
                        Result := -0.016399059657095413;
                    end
                    else
                    begin
                        Result := 0.0069647773560953287;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.011379793302504205;
    end;
end;

function second_slot_bidirectional_tree_255(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    if features[118] <= -1.4999999999999998 then
    begin
        if features[117] <= -346.49999999999994 then
        begin
            if features[221] <= -5519.4999999999991 then
            begin
                Result := -0.011555498928358721;
            end
            else
            begin
                Result := 0.042583537190123172;
            end;
        end
        else
        begin
            if features[77] <= 13535.500000000002 then
            begin
                if features[179] <= -4279.4999999999991 then
                begin
                    if features[94] <= 163181.50000000003 then
                    begin
                        Result := 0.0071807237512254499;
                    end
                    else
                    begin
                        Result := -0.0098923640497464611;
                    end;
                end
                else
                begin
                    Result := -0.025835419418532003;
                end;
            end
            else
            begin
                Result := -0.012088992990781564;
            end;
        end;
    end
    else
    begin
        if features[120] <= -1516.4999999999998 then
        begin
            Result := -0.016940442123949389;
        end
        else
        begin
            if features[150] <= -7.4999999999999991 then
            begin
                if features[172] <= 4.5000000000000009 then
                begin
                    if features[176] <= -7161.4999999999991 then
                    begin
                        Result := 0.012758387085078333;
                    end
                    else
                    begin
                        Result := 0.0029575930983008411;
                    end;
                end
                else
                begin
                    if features[40] <= 1477.5000000000002 then
                    begin
                        Result := -0.0076016808905812029;
                    end
                    else
                    begin
                        Result := 0.015878657763534584;
                    end;
                end;
            end
            else
            begin
                if features[107] <= -1.0000000180025095E-35 then
                begin
                    if features[151] <= -192.49999999999997 then
                    begin
                        Result := 0.0076264347326493037;
                    end
                    else
                    begin
                        Result := -0.0069894173304016552;
                    end;
                end
                else
                begin
                    if features[166] <= 34964100.000000007 then
                    begin
                        Result := -0.0016122926059012319;
                    end
                    else
                    begin
                        Result := 0.0038493155946279878;
                    end;
                end;
            end;
        end;
    end;
end;

function long_second_slot_bidirectional_score(
    const features: TncLongSecondSlotBidirectionalFeatures): Double;
begin
    Result := 0.0;
    Result := Result + second_slot_bidirectional_tree_0(features);
    Result := Result + second_slot_bidirectional_tree_1(features);
    Result := Result + second_slot_bidirectional_tree_2(features);
    Result := Result + second_slot_bidirectional_tree_3(features);
    Result := Result + second_slot_bidirectional_tree_4(features);
    Result := Result + second_slot_bidirectional_tree_5(features);
    Result := Result + second_slot_bidirectional_tree_6(features);
    Result := Result + second_slot_bidirectional_tree_7(features);
    Result := Result + second_slot_bidirectional_tree_8(features);
    Result := Result + second_slot_bidirectional_tree_9(features);
    Result := Result + second_slot_bidirectional_tree_10(features);
    Result := Result + second_slot_bidirectional_tree_11(features);
    Result := Result + second_slot_bidirectional_tree_12(features);
    Result := Result + second_slot_bidirectional_tree_13(features);
    Result := Result + second_slot_bidirectional_tree_14(features);
    Result := Result + second_slot_bidirectional_tree_15(features);
    Result := Result + second_slot_bidirectional_tree_16(features);
    Result := Result + second_slot_bidirectional_tree_17(features);
    Result := Result + second_slot_bidirectional_tree_18(features);
    Result := Result + second_slot_bidirectional_tree_19(features);
    Result := Result + second_slot_bidirectional_tree_20(features);
    Result := Result + second_slot_bidirectional_tree_21(features);
    Result := Result + second_slot_bidirectional_tree_22(features);
    Result := Result + second_slot_bidirectional_tree_23(features);
    Result := Result + second_slot_bidirectional_tree_24(features);
    Result := Result + second_slot_bidirectional_tree_25(features);
    Result := Result + second_slot_bidirectional_tree_26(features);
    Result := Result + second_slot_bidirectional_tree_27(features);
    Result := Result + second_slot_bidirectional_tree_28(features);
    Result := Result + second_slot_bidirectional_tree_29(features);
    Result := Result + second_slot_bidirectional_tree_30(features);
    Result := Result + second_slot_bidirectional_tree_31(features);
    Result := Result + second_slot_bidirectional_tree_32(features);
    Result := Result + second_slot_bidirectional_tree_33(features);
    Result := Result + second_slot_bidirectional_tree_34(features);
    Result := Result + second_slot_bidirectional_tree_35(features);
    Result := Result + second_slot_bidirectional_tree_36(features);
    Result := Result + second_slot_bidirectional_tree_37(features);
    Result := Result + second_slot_bidirectional_tree_38(features);
    Result := Result + second_slot_bidirectional_tree_39(features);
    Result := Result + second_slot_bidirectional_tree_40(features);
    Result := Result + second_slot_bidirectional_tree_41(features);
    Result := Result + second_slot_bidirectional_tree_42(features);
    Result := Result + second_slot_bidirectional_tree_43(features);
    Result := Result + second_slot_bidirectional_tree_44(features);
    Result := Result + second_slot_bidirectional_tree_45(features);
    Result := Result + second_slot_bidirectional_tree_46(features);
    Result := Result + second_slot_bidirectional_tree_47(features);
    Result := Result + second_slot_bidirectional_tree_48(features);
    Result := Result + second_slot_bidirectional_tree_49(features);
    Result := Result + second_slot_bidirectional_tree_50(features);
    Result := Result + second_slot_bidirectional_tree_51(features);
    Result := Result + second_slot_bidirectional_tree_52(features);
    Result := Result + second_slot_bidirectional_tree_53(features);
    Result := Result + second_slot_bidirectional_tree_54(features);
    Result := Result + second_slot_bidirectional_tree_55(features);
    Result := Result + second_slot_bidirectional_tree_56(features);
    Result := Result + second_slot_bidirectional_tree_57(features);
    Result := Result + second_slot_bidirectional_tree_58(features);
    Result := Result + second_slot_bidirectional_tree_59(features);
    Result := Result + second_slot_bidirectional_tree_60(features);
    Result := Result + second_slot_bidirectional_tree_61(features);
    Result := Result + second_slot_bidirectional_tree_62(features);
    Result := Result + second_slot_bidirectional_tree_63(features);
    Result := Result + second_slot_bidirectional_tree_64(features);
    Result := Result + second_slot_bidirectional_tree_65(features);
    Result := Result + second_slot_bidirectional_tree_66(features);
    Result := Result + second_slot_bidirectional_tree_67(features);
    Result := Result + second_slot_bidirectional_tree_68(features);
    Result := Result + second_slot_bidirectional_tree_69(features);
    Result := Result + second_slot_bidirectional_tree_70(features);
    Result := Result + second_slot_bidirectional_tree_71(features);
    Result := Result + second_slot_bidirectional_tree_72(features);
    Result := Result + second_slot_bidirectional_tree_73(features);
    Result := Result + second_slot_bidirectional_tree_74(features);
    Result := Result + second_slot_bidirectional_tree_75(features);
    Result := Result + second_slot_bidirectional_tree_76(features);
    Result := Result + second_slot_bidirectional_tree_77(features);
    Result := Result + second_slot_bidirectional_tree_78(features);
    Result := Result + second_slot_bidirectional_tree_79(features);
    Result := Result + second_slot_bidirectional_tree_80(features);
    Result := Result + second_slot_bidirectional_tree_81(features);
    Result := Result + second_slot_bidirectional_tree_82(features);
    Result := Result + second_slot_bidirectional_tree_83(features);
    Result := Result + second_slot_bidirectional_tree_84(features);
    Result := Result + second_slot_bidirectional_tree_85(features);
    Result := Result + second_slot_bidirectional_tree_86(features);
    Result := Result + second_slot_bidirectional_tree_87(features);
    Result := Result + second_slot_bidirectional_tree_88(features);
    Result := Result + second_slot_bidirectional_tree_89(features);
    Result := Result + second_slot_bidirectional_tree_90(features);
    Result := Result + second_slot_bidirectional_tree_91(features);
    Result := Result + second_slot_bidirectional_tree_92(features);
    Result := Result + second_slot_bidirectional_tree_93(features);
    Result := Result + second_slot_bidirectional_tree_94(features);
    Result := Result + second_slot_bidirectional_tree_95(features);
    Result := Result + second_slot_bidirectional_tree_96(features);
    Result := Result + second_slot_bidirectional_tree_97(features);
    Result := Result + second_slot_bidirectional_tree_98(features);
    Result := Result + second_slot_bidirectional_tree_99(features);
    Result := Result + second_slot_bidirectional_tree_100(features);
    Result := Result + second_slot_bidirectional_tree_101(features);
    Result := Result + second_slot_bidirectional_tree_102(features);
    Result := Result + second_slot_bidirectional_tree_103(features);
    Result := Result + second_slot_bidirectional_tree_104(features);
    Result := Result + second_slot_bidirectional_tree_105(features);
    Result := Result + second_slot_bidirectional_tree_106(features);
    Result := Result + second_slot_bidirectional_tree_107(features);
    Result := Result + second_slot_bidirectional_tree_108(features);
    Result := Result + second_slot_bidirectional_tree_109(features);
    Result := Result + second_slot_bidirectional_tree_110(features);
    Result := Result + second_slot_bidirectional_tree_111(features);
    Result := Result + second_slot_bidirectional_tree_112(features);
    Result := Result + second_slot_bidirectional_tree_113(features);
    Result := Result + second_slot_bidirectional_tree_114(features);
    Result := Result + second_slot_bidirectional_tree_115(features);
    Result := Result + second_slot_bidirectional_tree_116(features);
    Result := Result + second_slot_bidirectional_tree_117(features);
    Result := Result + second_slot_bidirectional_tree_118(features);
    Result := Result + second_slot_bidirectional_tree_119(features);
    Result := Result + second_slot_bidirectional_tree_120(features);
    Result := Result + second_slot_bidirectional_tree_121(features);
    Result := Result + second_slot_bidirectional_tree_122(features);
    Result := Result + second_slot_bidirectional_tree_123(features);
    Result := Result + second_slot_bidirectional_tree_124(features);
    Result := Result + second_slot_bidirectional_tree_125(features);
    Result := Result + second_slot_bidirectional_tree_126(features);
    Result := Result + second_slot_bidirectional_tree_127(features);
    Result := Result + second_slot_bidirectional_tree_128(features);
    Result := Result + second_slot_bidirectional_tree_129(features);
    Result := Result + second_slot_bidirectional_tree_130(features);
    Result := Result + second_slot_bidirectional_tree_131(features);
    Result := Result + second_slot_bidirectional_tree_132(features);
    Result := Result + second_slot_bidirectional_tree_133(features);
    Result := Result + second_slot_bidirectional_tree_134(features);
    Result := Result + second_slot_bidirectional_tree_135(features);
    Result := Result + second_slot_bidirectional_tree_136(features);
    Result := Result + second_slot_bidirectional_tree_137(features);
    Result := Result + second_slot_bidirectional_tree_138(features);
    Result := Result + second_slot_bidirectional_tree_139(features);
    Result := Result + second_slot_bidirectional_tree_140(features);
    Result := Result + second_slot_bidirectional_tree_141(features);
    Result := Result + second_slot_bidirectional_tree_142(features);
    Result := Result + second_slot_bidirectional_tree_143(features);
    Result := Result + second_slot_bidirectional_tree_144(features);
    Result := Result + second_slot_bidirectional_tree_145(features);
    Result := Result + second_slot_bidirectional_tree_146(features);
    Result := Result + second_slot_bidirectional_tree_147(features);
    Result := Result + second_slot_bidirectional_tree_148(features);
    Result := Result + second_slot_bidirectional_tree_149(features);
    Result := Result + second_slot_bidirectional_tree_150(features);
    Result := Result + second_slot_bidirectional_tree_151(features);
    Result := Result + second_slot_bidirectional_tree_152(features);
    Result := Result + second_slot_bidirectional_tree_153(features);
    Result := Result + second_slot_bidirectional_tree_154(features);
    Result := Result + second_slot_bidirectional_tree_155(features);
    Result := Result + second_slot_bidirectional_tree_156(features);
    Result := Result + second_slot_bidirectional_tree_157(features);
    Result := Result + second_slot_bidirectional_tree_158(features);
    Result := Result + second_slot_bidirectional_tree_159(features);
    Result := Result + second_slot_bidirectional_tree_160(features);
    Result := Result + second_slot_bidirectional_tree_161(features);
    Result := Result + second_slot_bidirectional_tree_162(features);
    Result := Result + second_slot_bidirectional_tree_163(features);
    Result := Result + second_slot_bidirectional_tree_164(features);
    Result := Result + second_slot_bidirectional_tree_165(features);
    Result := Result + second_slot_bidirectional_tree_166(features);
    Result := Result + second_slot_bidirectional_tree_167(features);
    Result := Result + second_slot_bidirectional_tree_168(features);
    Result := Result + second_slot_bidirectional_tree_169(features);
    Result := Result + second_slot_bidirectional_tree_170(features);
    Result := Result + second_slot_bidirectional_tree_171(features);
    Result := Result + second_slot_bidirectional_tree_172(features);
    Result := Result + second_slot_bidirectional_tree_173(features);
    Result := Result + second_slot_bidirectional_tree_174(features);
    Result := Result + second_slot_bidirectional_tree_175(features);
    Result := Result + second_slot_bidirectional_tree_176(features);
    Result := Result + second_slot_bidirectional_tree_177(features);
    Result := Result + second_slot_bidirectional_tree_178(features);
    Result := Result + second_slot_bidirectional_tree_179(features);
    Result := Result + second_slot_bidirectional_tree_180(features);
    Result := Result + second_slot_bidirectional_tree_181(features);
    Result := Result + second_slot_bidirectional_tree_182(features);
    Result := Result + second_slot_bidirectional_tree_183(features);
    Result := Result + second_slot_bidirectional_tree_184(features);
    Result := Result + second_slot_bidirectional_tree_185(features);
    Result := Result + second_slot_bidirectional_tree_186(features);
    Result := Result + second_slot_bidirectional_tree_187(features);
    Result := Result + second_slot_bidirectional_tree_188(features);
    Result := Result + second_slot_bidirectional_tree_189(features);
    Result := Result + second_slot_bidirectional_tree_190(features);
    Result := Result + second_slot_bidirectional_tree_191(features);
    Result := Result + second_slot_bidirectional_tree_192(features);
    Result := Result + second_slot_bidirectional_tree_193(features);
    Result := Result + second_slot_bidirectional_tree_194(features);
    Result := Result + second_slot_bidirectional_tree_195(features);
    Result := Result + second_slot_bidirectional_tree_196(features);
    Result := Result + second_slot_bidirectional_tree_197(features);
    Result := Result + second_slot_bidirectional_tree_198(features);
    Result := Result + second_slot_bidirectional_tree_199(features);
    Result := Result + second_slot_bidirectional_tree_200(features);
    Result := Result + second_slot_bidirectional_tree_201(features);
    Result := Result + second_slot_bidirectional_tree_202(features);
    Result := Result + second_slot_bidirectional_tree_203(features);
    Result := Result + second_slot_bidirectional_tree_204(features);
    Result := Result + second_slot_bidirectional_tree_205(features);
    Result := Result + second_slot_bidirectional_tree_206(features);
    Result := Result + second_slot_bidirectional_tree_207(features);
    Result := Result + second_slot_bidirectional_tree_208(features);
    Result := Result + second_slot_bidirectional_tree_209(features);
    Result := Result + second_slot_bidirectional_tree_210(features);
    Result := Result + second_slot_bidirectional_tree_211(features);
    Result := Result + second_slot_bidirectional_tree_212(features);
    Result := Result + second_slot_bidirectional_tree_213(features);
    Result := Result + second_slot_bidirectional_tree_214(features);
    Result := Result + second_slot_bidirectional_tree_215(features);
    Result := Result + second_slot_bidirectional_tree_216(features);
    Result := Result + second_slot_bidirectional_tree_217(features);
    Result := Result + second_slot_bidirectional_tree_218(features);
    Result := Result + second_slot_bidirectional_tree_219(features);
    Result := Result + second_slot_bidirectional_tree_220(features);
    Result := Result + second_slot_bidirectional_tree_221(features);
    Result := Result + second_slot_bidirectional_tree_222(features);
    Result := Result + second_slot_bidirectional_tree_223(features);
    Result := Result + second_slot_bidirectional_tree_224(features);
    Result := Result + second_slot_bidirectional_tree_225(features);
    Result := Result + second_slot_bidirectional_tree_226(features);
    Result := Result + second_slot_bidirectional_tree_227(features);
    Result := Result + second_slot_bidirectional_tree_228(features);
    Result := Result + second_slot_bidirectional_tree_229(features);
    Result := Result + second_slot_bidirectional_tree_230(features);
    Result := Result + second_slot_bidirectional_tree_231(features);
    Result := Result + second_slot_bidirectional_tree_232(features);
    Result := Result + second_slot_bidirectional_tree_233(features);
    Result := Result + second_slot_bidirectional_tree_234(features);
    Result := Result + second_slot_bidirectional_tree_235(features);
    Result := Result + second_slot_bidirectional_tree_236(features);
    Result := Result + second_slot_bidirectional_tree_237(features);
    Result := Result + second_slot_bidirectional_tree_238(features);
    Result := Result + second_slot_bidirectional_tree_239(features);
    Result := Result + second_slot_bidirectional_tree_240(features);
    Result := Result + second_slot_bidirectional_tree_241(features);
    Result := Result + second_slot_bidirectional_tree_242(features);
    Result := Result + second_slot_bidirectional_tree_243(features);
    Result := Result + second_slot_bidirectional_tree_244(features);
    Result := Result + second_slot_bidirectional_tree_245(features);
    Result := Result + second_slot_bidirectional_tree_246(features);
    Result := Result + second_slot_bidirectional_tree_247(features);
    Result := Result + second_slot_bidirectional_tree_248(features);
    Result := Result + second_slot_bidirectional_tree_249(features);
    Result := Result + second_slot_bidirectional_tree_250(features);
    Result := Result + second_slot_bidirectional_tree_251(features);
    Result := Result + second_slot_bidirectional_tree_252(features);
    Result := Result + second_slot_bidirectional_tree_253(features);
    Result := Result + second_slot_bidirectional_tree_254(features);
    Result := Result + second_slot_bidirectional_tree_255(features);
end;

function score_reference(const mode: Integer): Double;
var
    features: TncLongSecondSlotBidirectionalFeatures;
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
    Result := long_second_slot_bidirectional_score(features);
end;

function long_second_slot_bidirectional_self_test: Boolean;
const
    c_tolerance = 1.0E-9;
begin
    Result := (Abs(score_reference(0) -
        c_long_second_slot_bidirectional_reference_zero) <= c_tolerance) and
        (Abs(score_reference(1) -
        c_long_second_slot_bidirectional_reference_low) <= c_tolerance) and
        (Abs(score_reference(2) -
        c_long_second_slot_bidirectional_reference_high) <= c_tolerance) and
        (Abs(score_reference(3) -
        c_long_second_slot_bidirectional_reference_mixed) <= c_tolerance);
end;

end.
