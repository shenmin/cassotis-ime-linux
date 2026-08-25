unit nc_long_exact_edge_candidate_auditor_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

type
    TncLongExactEdgeAuditorFeatures =
        array[0..141] of Double;

const
    c_long_exact_edge_auditor_feature_count = 142;
    c_long_exact_edge_auditor_tree_count = 160;
    c_long_exact_edge_auditor_threshold: Double = 0.51264261489905227;

function long_exact_edge_auditor_score(
    const features: TncLongExactEdgeAuditorFeatures): Double;
function long_exact_edge_auditor_self_test: Boolean;

implementation

uses
    Math;

{ Independent-corpus KEEP/SWITCH auditor for long exact-edge recall paths.
  Training report SHA-256: 0E00BBFD70D67E686C0A72E43E9199F10F9B8FE6401504D60E375FF54170A870
  LightGBM model SHA-256: 2CBB06C6D94E87F6A2759BF4B41766AF7BC6C6DED3F53A0CCF90AB96CF66A818 }

function exact_edge_auditor_tree_0(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[76] <= 932.50000000000011 then
        begin
            Result := 0.59036695184854471;
        end
        else
        begin
            Result := 0.63544059699320776;
        end;
    end
    else
    begin
        if features[133] <= -1.0000000180025095E-35 then
        begin
            if features[97] <= 101.00000000000001 then
            begin
                if features[90] <= 5109.5000000000009 then
                begin
                    Result := 0.6346663583426958;
                end
                else
                begin
                    if features[105] <= -147.49999999999997 then
                    begin
                        Result := 0.63946276791460976;
                    end
                    else
                    begin
                        Result := 0.59642889741199889;
                    end;
                end;
            end
            else
            begin
                if features[89] <= 125.50000000000001 then
                begin
                    Result := 0.66009464948245056;
                end
                else
                begin
                    if features[14] <= 1134.0000000000002 then
                    begin
                        Result := 0.60913224975558089;
                    end
                    else
                    begin
                        Result := 0.64938015866808318;
                    end;
                end;
            end;
        end
        else
        begin
            if features[96] <= 196.50000000000003 then
            begin
                if features[137] <= 1.5000000000000002 then
                begin
                    if features[80] <= 12.500000000000002 then
                    begin
                        if features[102] <= 210.00000000000003 then
                        begin
                            Result := 0.6224284087850116;
                        end
                        else
                        begin
                            Result := 0.64834254685435244;
                        end;
                    end
                    else
                    begin
                        Result := 0.65198536460621104;
                    end;
                end
                else
                begin
                    if features[44] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.63627899445417091;
                    end
                    else
                    begin
                        Result := 0.66270767236548866;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.62839483401399343;
                end
                else
                begin
                    Result := 0.6667033732861255;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_1(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[76] <= 932.50000000000011 then
        begin
            Result := -0.043223272735113206;
        end
        else
        begin
            Result := -0.00010737613383023277;
        end;
    end
    else
    begin
        if features[133] <= -1.0000000180025095E-35 then
        begin
            if features[91] <= 3284.5000000000005 then
            begin
                if features[96] <= 10.500000000000002 then
                begin
                    Result := -0.016748587482627024;
                end
                else
                begin
                    Result := 0.017854300841813421;
                end;
            end
            else
            begin
                if features[134] <= 1581.0000000000002 then
                begin
                    Result := -0.032276994131719187;
                end
                else
                begin
                    Result := 0.0095231843336579195;
                end;
            end;
        end
        else
        begin
            if features[96] <= 196.50000000000003 then
            begin
                if features[137] <= 1.5000000000000002 then
                begin
                    if features[80] <= 12.500000000000002 then
                    begin
                        if features[73] <= 1297.5000000000002 then
                        begin
                            Result := 0.0032826270045236395;
                        end
                        else
                        begin
                            Result := -0.018558579404094087;
                        end;
                    end
                    else
                    begin
                        Result := 0.016102952937361217;
                    end;
                end
                else
                begin
                    if features[134] <= 8.5000000000000018 then
                    begin
                        Result := -0.0002302012396998014;
                    end
                    else
                    begin
                        Result := 0.026957550462091886;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0070294538970196779;
                end
                else
                begin
                    if features[92] <= -140578.99999999997 then
                    begin
                        Result := 0.0030629308505872258;
                    end
                    else
                    begin
                        if features[99] <= -234.49999999999997 then
                        begin
                            Result := -0.0022453586249776654;
                        end
                        else
                        begin
                            Result := 0.035048488490522445;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_2(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[96] <= -84.499999999999986 then
        begin
            Result := -0.017122965209408002;
        end
        else
        begin
            Result := -0.045106016824795328;
        end;
    end
    else
    begin
        if features[96] <= 180.50000000000003 then
        begin
            if features[136] <= -1.0000000180025095E-35 then
            begin
                if features[88] <= 10679.000000000002 then
                begin
                    Result := -0.0047134861692398264;
                end
                else
                begin
                    Result := -0.031309034053066363;
                end;
            end
            else
            begin
                if features[137] <= 1.5000000000000002 then
                begin
                    if features[20] <= 5.5000000000000009 then
                    begin
                        if features[136] <= 1693.5000000000002 then
                        begin
                            Result := -0.00072669056719820561;
                        end
                        else
                        begin
                            Result := -0.024444842016254444;
                        end;
                    end
                    else
                    begin
                        if features[80] <= 12.500000000000002 then
                        begin
                            Result := -0.0021183013364523681;
                        end
                        else
                        begin
                            Result := 0.020838441849238821;
                        end;
                    end;
                end
                else
                begin
                    if features[44] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.00092460879071233225;
                    end
                    else
                    begin
                        Result := 0.026223725146586493;
                    end;
                end;
            end;
        end
        else
        begin
            if features[42] <= 1.0000000180025095E-35 then
            begin
                Result := -0.016343356487562757;
            end
            else
            begin
                if features[89] <= 125.50000000000001 then
                begin
                    Result := 0.032072367432637854;
                end
                else
                begin
                    if features[121] <= -90.499999999999986 then
                    begin
                        if features[57] <= 1378.5000000000002 then
                        begin
                            Result := -0.022389190155930966;
                        end
                        else
                        begin
                            Result := 0.0045896692902549687;
                        end;
                    end
                    else
                    begin
                        Result := 0.027409627095857272;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_3(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[76] <= 932.50000000000011 then
        begin
            Result := -0.039929812996639724;
        end
        else
        begin
            Result := 0.00049297568573961612;
        end;
    end
    else
    begin
        if features[133] <= -1.0000000180025095E-35 then
        begin
            if features[91] <= 3284.5000000000005 then
            begin
                if features[97] <= 48.000000000000007 then
                begin
                    if features[7] <= -7390.4999999999991 then
                    begin
                        Result := 0.012751379546788606;
                    end
                    else
                    begin
                        Result := -0.0240776054892958;
                    end;
                end
                else
                begin
                    Result := 0.018594638921693548;
                end;
            end
            else
            begin
                if features[134] <= 1581.0000000000002 then
                begin
                    Result := -0.030599412468680681;
                end
                else
                begin
                    Result := 0.00943502171126589;
                end;
            end;
        end
        else
        begin
            if features[96] <= 196.50000000000003 then
            begin
                if features[137] <= 1.5000000000000002 then
                begin
                    if features[80] <= 12.500000000000002 then
                    begin
                        if features[102] <= 210.00000000000003 then
                        begin
                            Result := -0.012210444386235694;
                        end
                        else
                        begin
                            Result := 0.012720225414605471;
                        end;
                    end
                    else
                    begin
                        Result := 0.015499384676187868;
                    end;
                end
                else
                begin
                    if features[134] <= 8.5000000000000018 then
                    begin
                        Result := -0.00021492000423093156;
                    end
                    else
                    begin
                        Result := 0.025862249530451478;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0066202326582969406;
                end
                else
                begin
                    if features[95] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0021280766318442185;
                    end
                    else
                    begin
                        Result := 0.031723411028786994;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_4(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[76] <= 932.50000000000011 then
        begin
            Result := -0.038326694579194083;
        end
        else
        begin
            Result := 0.00048521996716551668;
        end;
    end
    else
    begin
        if features[133] <= -1.0000000180025095E-35 then
        begin
            if features[91] <= 3284.5000000000005 then
            begin
                if features[97] <= 48.000000000000007 then
                begin
                    if features[8] <= -7390.4999999999991 then
                    begin
                        Result := 0.012615268587091222;
                    end
                    else
                    begin
                        Result := -0.023397531985737772;
                    end;
                end
                else
                begin
                    Result := 0.01815877571975236;
                end;
            end
            else
            begin
                if features[60] <= 585.50000000000011 then
                begin
                    if features[38] <= 9083.5000000000018 then
                    begin
                        Result := 0.0042584605541239797;
                    end
                    else
                    begin
                        Result := -0.034422878662177067;
                    end;
                end
                else
                begin
                    Result := 0.0065317071049988424;
                end;
            end;
        end
        else
        begin
            if features[96] <= 196.50000000000003 then
            begin
                if features[137] <= 1.5000000000000002 then
                begin
                    if features[118] <= 1.0000000180025095E-35 then
                    begin
                        if features[133] <= 6282.5000000000009 then
                        begin
                            Result := 0.001870552174924555;
                        end
                        else
                        begin
                            Result := -0.023289910302006542;
                        end;
                    end
                    else
                    begin
                        Result := 0.012119251877171696;
                    end;
                end
                else
                begin
                    if features[134] <= 8.5000000000000018 then
                    begin
                        Result := -0.00020922449250298256;
                    end
                    else
                    begin
                        Result := 0.025318950863885217;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0065044366610310708;
                end
                else
                begin
                    Result := 0.028368691989677178;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_5(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[76] <= 932.50000000000011 then
        begin
            Result := -0.036823680483577932;
        end
        else
        begin
            Result := 0.00047758618746661781;
        end;
    end
    else
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            if features[89] <= 800.50000000000011 then
            begin
                if features[97] <= 134.50000000000003 then
                begin
                    if features[76] <= 915.50000000000011 then
                    begin
                        Result := -0.019028125674599446;
                    end
                    else
                    begin
                        Result := 0.0091030422157921034;
                    end;
                end
                else
                begin
                    Result := 0.01718256295775213;
                end;
            end
            else
            begin
                if features[54] <= 532.50000000000011 then
                begin
                    if features[111] <= 6.5000000000000009 then
                    begin
                        Result := -0.0427422446715401;
                    end
                    else
                    begin
                        Result := 0.00048635936767630667;
                    end;
                end
                else
                begin
                    Result := -0.0029140252134349496;
                end;
            end;
        end
        else
        begin
            if features[96] <= 180.50000000000003 then
            begin
                if features[104] <= 1306.5000000000002 then
                begin
                    if features[137] <= 2.5000000000000004 then
                    begin
                        if features[66] <= 1.5000000000000002 then
                        begin
                            Result := 0.0043453003526251043;
                        end
                        else
                        begin
                            Result := -0.014993561839329804;
                        end;
                    end
                    else
                    begin
                        Result := 0.018055833520931201;
                    end;
                end
                else
                begin
                    Result := 0.028263799482532295;
                end;
            end
            else
            begin
                if features[47] <= 105112.50000000001 then
                begin
                    if features[110] <= 1.5000000000000002 then
                    begin
                        Result := 0.0073021156964497777;
                    end
                    else
                    begin
                        Result := 0.033099208313296193;
                    end;
                end
                else
                begin
                    Result := 0.0083632735155133951;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_6(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[76] <= 932.50000000000011 then
        begin
            Result := -0.035410896778342311;
        end
        else
        begin
            Result := 0.00047007081403343653;
        end;
    end
    else
    begin
        if features[133] <= -1.0000000180025095E-35 then
        begin
            if features[91] <= 3284.5000000000005 then
            begin
                if features[97] <= 48.000000000000007 then
                begin
                    if features[8] <= -7390.4999999999991 then
                    begin
                        Result := 0.012555829021801388;
                    end
                    else
                    begin
                        Result := -0.02255517865685263;
                    end;
                end
                else
                begin
                    Result := 0.017473904463431708;
                end;
            end
            else
            begin
                if features[134] <= 1581.0000000000002 then
                begin
                    if features[38] <= 9083.5000000000018 then
                    begin
                        Result := 0.0037445112104105417;
                    end
                    else
                    begin
                        Result := -0.031934997744752128;
                    end;
                end
                else
                begin
                    Result := 0.0094036970306073005;
                end;
            end;
        end
        else
        begin
            if features[97] <= 134.50000000000003 then
            begin
                if features[104] <= 1306.5000000000002 then
                begin
                    if features[20] <= 12.500000000000002 then
                    begin
                        if features[52] <= -5264.9999999999991 then
                        begin
                            Result := -0.006558790574114925;
                        end
                        else
                        begin
                            Result := 0.014613392664530699;
                        end;
                    end
                    else
                    begin
                        Result := 0.01588862604545466;
                    end;
                end
                else
                begin
                    Result := 0.026565785433019191;
                end;
            end
            else
            begin
                if features[47] <= 105112.50000000001 then
                begin
                    Result := 0.029907554297186754;
                end
                else
                begin
                    if features[94] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.017335547248541795;
                    end
                    else
                    begin
                        Result := -0.0095507496709973157;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_7(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[96] <= -84.499999999999986 then
        begin
            if features[54] <= 391.50000000000006 then
            begin
                Result := 0.0041080536942700785;
            end
            else
            begin
                Result := -0.02703596804484474;
            end;
        end
        else
        begin
            Result := -0.038054583933792942;
        end;
    end
    else
    begin
        if features[133] <= -1.0000000180025095E-35 then
        begin
            if features[91] <= 3284.5000000000005 then
            begin
                if features[97] <= 35.500000000000007 then
                begin
                    if features[7] <= -7390.4999999999991 then
                    begin
                        Result := 0.011490549582427408;
                    end
                    else
                    begin
                        Result := -0.022357156910484663;
                    end;
                end
                else
                begin
                    Result := 0.016580223254995165;
                end;
            end
            else
            begin
                if features[60] <= 585.50000000000011 then
                begin
                    Result := -0.027916427032617555;
                end
                else
                begin
                    Result := 0.0066619740350956766;
                end;
            end;
        end
        else
        begin
            if features[96] <= 196.50000000000003 then
            begin
                if features[137] <= 1.5000000000000002 then
                begin
                    if features[80] <= 12.500000000000002 then
                    begin
                        if features[73] <= 1297.5000000000002 then
                        begin
                            Result := 0.0034505968548458141;
                        end
                        else
                        begin
                            Result := -0.017358811676419866;
                        end;
                    end
                    else
                    begin
                        Result := 0.014891475560886791;
                    end;
                end
                else
                begin
                    if features[134] <= 8.5000000000000018 then
                    begin
                        Result := -0.00047732308444990414;
                    end
                    else
                    begin
                        Result := 0.024541079587993151;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.0070162546181477227;
                end
                else
                begin
                    Result := 0.026659753429631831;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_8(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[76] <= 932.50000000000011 then
        begin
            Result := -0.033020719121464051;
        end
        else
        begin
            Result := 0.00091301577006492013;
        end;
    end
    else
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            if features[89] <= 800.50000000000011 then
            begin
                if features[98] <= 134.50000000000003 then
                begin
                    if features[79] <= 627.50000000000011 then
                    begin
                        Result := -0.01944428420915011;
                    end
                    else
                    begin
                        Result := 0.01043414181810111;
                    end;
                end
                else
                begin
                    Result := 0.016481627178394045;
                end;
            end
            else
            begin
                if features[54] <= 532.50000000000011 then
                begin
                    if features[111] <= 6.5000000000000009 then
                    begin
                        Result := -0.03999374492013405;
                    end
                    else
                    begin
                        Result := 0.0010456425440325968;
                    end;
                end
                else
                begin
                    Result := -0.0022057472145723279;
                end;
            end;
        end
        else
        begin
            if features[96] <= 180.50000000000003 then
            begin
                if features[104] <= 1306.5000000000002 then
                begin
                    if features[137] <= 2.5000000000000004 then
                    begin
                        if features[66] <= 1.5000000000000002 then
                        begin
                            Result := 0.0041832308618548458;
                        end
                        else
                        begin
                            Result := -0.014429542419629014;
                        end;
                    end
                    else
                    begin
                        Result := 0.017358236103306775;
                    end;
                end
                else
                begin
                    Result := 0.0274741802660694;
                end;
            end
            else
            begin
                if features[47] <= 105112.50000000001 then
                begin
                    if features[110] <= 1.5000000000000002 then
                    begin
                        Result := 0.0061389463626995398;
                    end
                    else
                    begin
                        Result := 0.031435506736682849;
                    end;
                end
                else
                begin
                    Result := 0.0074321855000311693;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_9(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[19] <= 4595.5000000000009 then
    begin
        if features[133] <= -1.0000000180025095E-35 then
        begin
            if features[44] <= -753.99999999999989 then
            begin
                if features[97] <= 430.50000000000006 then
                begin
                    Result := -0.0032102784765145392;
                end
                else
                begin
                    Result := 0.027676432713440707;
                end;
            end
            else
            begin
                if features[15] <= 563.00000000000011 then
                begin
                    if features[83] <= 583.50000000000011 then
                    begin
                        Result := 0.0011025866914086734;
                    end
                    else
                    begin
                        if features[65] <= 3.5000000000000004 then
                        begin
                            Result := -0.034243934609189626;
                        end
                        else
                        begin
                            Result := 0.0056114659317756726;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0079682566230327729;
                end;
            end;
        end
        else
        begin
            if features[20] <= 4.5000000000000009 then
            begin
                if features[120] <= 7.5000000000000009 then
                begin
                    if features[120] <= -2.4999999999999996 then
                    begin
                        if features[135] <= 2881.5000000000005 then
                        begin
                            Result := -0.017025034347869623;
                        end
                        else
                        begin
                            Result := 0.0086139237564992997;
                        end;
                    end
                    else
                    begin
                        if features[44] <= 2875.5000000000005 then
                        begin
                            Result := 0.015993588259688673;
                        end
                        else
                        begin
                            Result := -0.0087423215272548795;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.025367313933927639;
                end;
            end
            else
            begin
                if features[97] <= 381.00000000000006 then
                begin
                    Result := 0.013838901818641695;
                end
                else
                begin
                    Result := 0.030875286986603936;
                end;
            end;
        end;
    end
    else
    begin
        if features[28] <= 8055.0000000000009 then
        begin
            Result := -0.027495494001483444;
        end
        else
        begin
            Result := 0.0042300773585269612;
        end;
    end;
end;

function exact_edge_auditor_tree_10(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[96] <= -84.499999999999986 then
        begin
            if features[54] <= 391.50000000000006 then
            begin
                Result := 0.0052485312057937491;
            end
            else
            begin
                Result := -0.025037354681120325;
            end;
        end
        else
        begin
            Result := -0.034776301972634066;
        end;
    end
    else
    begin
        if features[136] <= -2110.4999999999995 then
        begin
            if features[2] <= 21338.000000000004 then
            begin
                Result := 0.0030833972213704613;
            end
            else
            begin
                if features[23] <= 1.5000000000000002 then
                begin
                    Result := -0.035671976325932671;
                end
                else
                begin
                    Result := 0.0037880745638957827;
                end;
            end;
        end
        else
        begin
            if features[98] <= 154.50000000000003 then
            begin
                if features[20] <= 12.500000000000002 then
                begin
                    if features[134] <= 8.5000000000000018 then
                    begin
                        if features[75] <= 15.500000000000002 then
                        begin
                            Result := -0.016119499445796055;
                        end
                        else
                        begin
                            Result := 0.0075045365249802572;
                        end;
                    end
                    else
                    begin
                        if features[137] <= 1.5000000000000002 then
                        begin
                            Result := -0.0059209130022612353;
                        end
                        else
                        begin
                            Result := 0.020262660706369971;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.017167305762127848;
                end;
            end
            else
            begin
                if features[47] <= 105112.50000000001 then
                begin
                    Result := 0.026115096435786297;
                end
                else
                begin
                    if features[14] <= 1246.5000000000002 then
                    begin
                        if features[44] <= 1536.5000000000002 then
                        begin
                            Result := 0.0084667069067562353;
                        end
                        else
                        begin
                            Result := -0.018570322269750177;
                        end;
                    end
                    else
                    begin
                        Result := 0.021594345791524312;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_11(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[54] <= 391.50000000000006 then
        begin
            if features[96] <= -84.499999999999986 then
            begin
                Result := 0.0051303967774210821;
            end
            else
            begin
                Result := -0.024105591442468141;
            end;
        end
        else
        begin
            Result := -0.036696853772381653;
        end;
    end
    else
    begin
        if features[136] <= -2110.4999999999995 then
        begin
            if features[2] <= 21338.000000000004 then
            begin
                Result := 0.0030336111263827383;
            end
            else
            begin
                if features[23] <= 1.5000000000000002 then
                begin
                    Result := -0.034608957450846502;
                end
                else
                begin
                    Result := 0.0037373456972557857;
                end;
            end;
        end
        else
        begin
            if features[97] <= 154.50000000000003 then
            begin
                if features[20] <= 12.500000000000002 then
                begin
                    if features[134] <= 8.5000000000000018 then
                    begin
                        if features[104] <= 1318.5000000000002 then
                        begin
                            Result := -0.014151047089592233;
                        end
                        else
                        begin
                            Result := 0.016959677351232098;
                        end;
                    end
                    else
                    begin
                        if features[137] <= 1.5000000000000002 then
                        begin
                            Result := -0.0057445138988898832;
                        end
                        else
                        begin
                            Result := 0.019844369920049093;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.016778163331284849;
                end;
            end
            else
            begin
                if features[47] <= 105112.50000000001 then
                begin
                    Result := 0.025520601681050092;
                end
                else
                begin
                    if features[14] <= 1246.5000000000002 then
                    begin
                        if features[88] <= 967.00000000000011 then
                        begin
                            Result := 0.013905067745673192;
                        end
                        else
                        begin
                            Result := -0.011168045068475062;
                        end;
                    end
                    else
                    begin
                        Result := 0.021234387481991298;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_12(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[2] <= 31282.000000000004 then
        begin
            if features[97] <= -38.499999999999993 then
            begin
                Result := 0.019767125802154707;
            end
            else
            begin
                if features[97] <= 337.50000000000006 then
                begin
                    Result := -0.019426031066815792;
                end
                else
                begin
                    Result := 0.0084376666454878697;
                end;
            end;
        end
        else
        begin
            if features[128] <= -60749.999999999993 then
            begin
                Result := -0.0030699817543105201;
            end
            else
            begin
                Result := -0.030270079230568823;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[96] <= 158.00000000000003 then
            begin
                if features[9] <= 220.00000000000003 then
                begin
                    Result := -0.0077927901120927916;
                end
                else
                begin
                    Result := 0.012123092616124943;
                end;
            end
            else
            begin
                if features[115] <= 1.0000000180025095E-35 then
                begin
                    if features[121] <= -249.49999999999997 then
                    begin
                        Result := 0.0032485618312308555;
                    end
                    else
                    begin
                        Result := 0.031820511751310059;
                    end;
                end
                else
                begin
                    Result := -0.00068598212155542178;
                end;
            end;
        end
        else
        begin
            if features[67] <= 1.0000000180025095E-35 then
            begin
                Result := 0.015075527735070053;
            end
            else
            begin
                if features[14] <= 1267.5000000000002 then
                begin
                    if features[76] <= 971.00000000000011 then
                    begin
                        if features[9] <= 750.50000000000011 then
                        begin
                            Result := -0.037627615600582913;
                        end
                        else
                        begin
                            Result := 0.0026279428631260288;
                        end;
                    end
                    else
                    begin
                        Result := 0.0079321951134784102;
                    end;
                end
                else
                begin
                    Result := 0.0086584734900308109;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_13(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[37] <= 1.5000000000000002 then
    begin
        if features[76] <= 932.50000000000011 then
        begin
            Result := -0.028306754810293242;
        end
        else
        begin
            Result := 0.0022883344041216202;
        end;
    end
    else
    begin
        if features[135] <= -852.99999999999989 then
        begin
            if features[89] <= 1.0000000180025095E-35 then
            begin
                if features[76] <= 904.50000000000011 then
                begin
                    Result := -0.012243823013070814;
                end
                else
                begin
                    Result := 0.01315835136900923;
                end;
            end
            else
            begin
                Result := -0.030841831691611712;
            end;
        end
        else
        begin
            if features[98] <= 134.50000000000003 then
            begin
                if features[133] <= -1.0000000180025095E-35 then
                begin
                    if features[76] <= 944.50000000000011 then
                    begin
                        if features[64] <= 4236.5000000000009 then
                        begin
                            Result := -0.0010485392751728192;
                        end
                        else
                        begin
                            Result := -0.027418181777062872;
                        end;
                    end
                    else
                    begin
                        Result := 0.0085436634167228315;
                    end;
                end
                else
                begin
                    if features[104] <= 1306.5000000000002 then
                    begin
                        if features[137] <= 1.5000000000000002 then
                        begin
                            Result := -0.0046319027613648655;
                        end
                        else
                        begin
                            Result := 0.010604922356361313;
                        end;
                    end
                    else
                    begin
                        Result := 0.02521696013512929;
                    end;
                end;
            end
            else
            begin
                if features[64] <= 9453.5000000000018 then
                begin
                    Result := 0.024401944306526556;
                end
                else
                begin
                    if features[37] <= 5.5000000000000009 then
                    begin
                        Result := -0.016127729645786883;
                    end
                    else
                    begin
                        if features[89] <= 1153.0000000000002 then
                        begin
                            Result := 0.016743199047195366;
                        end
                        else
                        begin
                            Result := -0.0059916915078786622;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_14(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[2] <= 31282.000000000004 then
        begin
            if features[97] <= -38.499999999999993 then
            begin
                Result := 0.01948474040310175;
            end
            else
            begin
                if features[97] <= 337.50000000000006 then
                begin
                    Result := -0.01886547842462102;
                end
                else
                begin
                    Result := 0.0080722188827236901;
                end;
            end;
        end
        else
        begin
            if features[106] <= 83.500000000000014 then
            begin
                if features[97] <= -78.499999999999986 then
                begin
                    if features[38] <= 1062.5000000000002 then
                    begin
                        Result := 0.0080839253380781285;
                    end
                    else
                    begin
                        Result := -0.019309037547642238;
                    end;
                end
                else
                begin
                    Result := -0.034768316649873739;
                end;
            end
            else
            begin
                Result := -0.00052107998209098615;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[115] <= 1.0000000180025095E-35 then
            begin
                if features[97] <= 101.00000000000001 then
                begin
                    Result := 0.0086511030244133431;
                end
                else
                begin
                    if features[134] <= 3585.5000000000005 then
                    begin
                        Result := 0.030705238336495279;
                    end
                    else
                    begin
                        Result := 0.0061020414764039249;
                    end;
                end;
            end
            else
            begin
                Result := -0.0063843653194348444;
            end;
        end
        else
        begin
            if features[54] <= 609.50000000000011 then
            begin
                if features[124] <= -58.999999999999993 then
                begin
                    if features[104] <= 1261.5000000000002 then
                    begin
                        Result := -0.030502530352553476;
                    end
                    else
                    begin
                        Result := 0.0098684812935400362;
                    end;
                end
                else
                begin
                    Result := 0.013935069483242144;
                end;
            end
            else
            begin
                Result := 0.014252177074292572;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_15(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[2] <= 31282.000000000004 then
        begin
            if features[97] <= -38.499999999999993 then
            begin
                Result := 0.019125963986932299;
            end
            else
            begin
                if features[97] <= 337.50000000000006 then
                begin
                    Result := -0.018377150924089265;
                end
                else
                begin
                    Result := 0.0079133941331893422;
                end;
            end;
        end
        else
        begin
            if features[128] <= -60749.999999999993 then
            begin
                Result := -0.0021201095268266806;
            end
            else
            begin
                Result := -0.027636034509587525;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[115] <= 1.0000000180025095E-35 then
            begin
                if features[97] <= 101.00000000000001 then
                begin
                    if features[35] <= 9.5000000000000018 then
                    begin
                        Result := 0.0011646540443018536;
                    end
                    else
                    begin
                        Result := 0.01771217689925271;
                    end;
                end
                else
                begin
                    if features[44] <= 3686.0000000000005 then
                    begin
                        Result := 0.028112313708940361;
                    end
                    else
                    begin
                        Result := 0.00013941361763725364;
                    end;
                end;
            end
            else
            begin
                Result := -0.006210958247588905;
            end;
        end
        else
        begin
            if features[54] <= 609.50000000000011 then
            begin
                if features[124] <= -58.999999999999993 then
                begin
                    if features[104] <= 1261.5000000000002 then
                    begin
                        if features[78] <= 971.00000000000011 then
                        begin
                            Result := -0.033311604720045733;
                        end
                        else
                        begin
                            Result := 0.0032451415081822263;
                        end;
                    end
                    else
                    begin
                        Result := 0.0097167864244892162;
                    end;
                end
                else
                begin
                    Result := 0.013682773491141283;
                end;
            end
            else
            begin
                Result := 0.013939070343708121;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_16(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[2] <= 31282.000000000004 then
        begin
            if features[97] <= -38.499999999999993 then
            begin
                Result := 0.018775294418895219;
            end
            else
            begin
                Result := -0.0071349971120970362;
            end;
        end
        else
        begin
            if features[106] <= 83.500000000000014 then
            begin
                if features[97] <= -78.499999999999986 then
                begin
                    if features[38] <= 1062.5000000000002 then
                    begin
                        Result := 0.0084064883947659926;
                    end
                    else
                    begin
                        Result := -0.018133253782566017;
                    end;
                end
                else
                begin
                    Result := -0.032695774445317495;
                end;
            end
            else
            begin
                Result := -7.1718265779943823E-05;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[96] <= 158.00000000000003 then
            begin
                if features[9] <= 220.00000000000003 then
                begin
                    Result := -0.0080714202706876435;
                end
                else
                begin
                    Result := 0.011217327924099432;
                end;
            end
            else
            begin
                if features[47] <= 144238.50000000003 then
                begin
                    Result := 0.027957086510311969;
                end
                else
                begin
                    Result := 0.0016932957161842148;
                end;
            end;
        end
        else
        begin
            if features[67] <= 1.0000000180025095E-35 then
            begin
                Result := 0.014105420099885382;
            end
            else
            begin
                if features[14] <= 1267.5000000000002 then
                begin
                    if features[78] <= 971.00000000000011 then
                    begin
                        if features[9] <= 750.50000000000011 then
                        begin
                            Result := -0.034131192781588812;
                        end
                        else
                        begin
                            Result := 0.0028853527042708013;
                        end;
                    end
                    else
                    begin
                        Result := 0.0079201142303755821;
                    end;
                end
                else
                begin
                    Result := 0.0084410626240163152;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_17(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[34] <= 1.0000000180025095E-35 then
    begin
        if features[96] <= 457.50000000000006 then
        begin
            if features[133] <= -1.0000000180025095E-35 then
            begin
                if features[91] <= 3558.5000000000005 then
                begin
                    if features[85] <= 5674.5000000000009 then
                    begin
                        if features[66] <= 1.5000000000000002 then
                        begin
                            Result := 0.015715284460423001;
                        end
                        else
                        begin
                            Result := -0.010403866006028564;
                        end;
                    end
                    else
                    begin
                        Result := -0.0228728196381595;
                    end;
                end
                else
                begin
                    Result := -0.024911616333895683;
                end;
            end
            else
            begin
                if features[80] <= 12.500000000000002 then
                begin
                    if features[78] <= 753.50000000000011 then
                    begin
                        Result := 0.012616325694439504;
                    end
                    else
                    begin
                        Result := -0.00358540361500813;
                    end;
                end
                else
                begin
                    Result := 0.022583248128544488;
                end;
            end;
        end
        else
        begin
            if features[45] <= 1.0000000180025095E-35 then
            begin
                Result := -0.010978425997703038;
            end
            else
            begin
                Result := 0.025218574686584509;
            end;
        end;
    end
    else
    begin
        if features[133] <= 713.00000000000011 then
        begin
            if features[111] <= 1.0000000180025095E-35 then
            begin
                if features[128] <= -23937.499999999996 then
                begin
                    Result := -0.0065315120286825023;
                end
                else
                begin
                    Result := -0.035928113691499688;
                end;
            end
            else
            begin
                Result := -0.0060242925298492735;
            end;
        end
        else
        begin
            if features[57] <= 1414.5000000000002 then
            begin
                Result := 0.010612216741571884;
            end
            else
            begin
                if features[110] <= 3.5000000000000004 then
                begin
                    Result := -0.022140015099287935;
                end
                else
                begin
                    Result := 0.011798050512265597;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_18(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[2] <= 31282.000000000004 then
        begin
            if features[97] <= -38.499999999999993 then
            begin
                Result := 0.01844933516018164;
            end
            else
            begin
                if features[6] <= -3772.9999999999995 then
                begin
                    Result := -0.014011219806639956;
                end
                else
                begin
                    Result := 0.013411524442647992;
                end;
            end;
        end
        else
        begin
            if features[106] <= 83.500000000000014 then
            begin
                if features[97] <= -78.499999999999986 then
                begin
                    if features[38] <= 1062.5000000000002 then
                    begin
                        Result := 0.0085268626286166983;
                    end
                    else
                    begin
                        Result := -0.017247740173357458;
                    end;
                end
                else
                begin
                    Result := -0.031117706243397544;
                end;
            end
            else
            begin
                Result := 0.00010864301322442431;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[97] <= 134.50000000000003 then
            begin
                Result := 0.0058813008690222594;
            end
            else
            begin
                if features[24] <= 1.0000000180025095E-35 then
                begin
                    if features[134] <= 3585.5000000000005 then
                    begin
                        Result := 0.028969297488107486;
                    end
                    else
                    begin
                        Result := 0.0052008065621929169;
                    end;
                end
                else
                begin
                    Result := -0.0010788431480787675;
                end;
            end;
        end
        else
        begin
            if features[54] <= 609.50000000000011 then
            begin
                if features[124] <= -58.999999999999993 then
                begin
                    if features[99] <= 455.50000000000006 then
                    begin
                        Result := -0.026369631280285282;
                    end
                    else
                    begin
                        Result := 0.0062875595186979534;
                    end;
                end
                else
                begin
                    Result := 0.013224976361771119;
                end;
            end
            else
            begin
                Result := 0.013525081091974046;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_19(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[19] <= 4595.5000000000009 then
    begin
        if features[96] <= 457.50000000000006 then
        begin
            if features[133] <= -1.0000000180025095E-35 then
            begin
                if features[124] <= -646.49999999999989 then
                begin
                    if features[89] <= 1479.0000000000002 then
                    begin
                        Result := 0.016372655117511282;
                    end
                    else
                    begin
                        Result := -0.012581514328801368;
                    end;
                end
                else
                begin
                    if features[65] <= 3.5000000000000004 then
                    begin
                        if features[59] <= 1396.5000000000002 then
                        begin
                            Result := -0.030842053980294725;
                        end
                        else
                        begin
                            Result := 0.0024145261096471158;
                        end;
                    end
                    else
                    begin
                        Result := 0.0044462411944952438;
                    end;
                end;
            end
            else
            begin
                if features[20] <= 4.5000000000000009 then
                begin
                    if features[137] <= 1.5000000000000002 then
                    begin
                        if features[9] <= 577.50000000000011 then
                        begin
                            Result := -0.019073362895629185;
                        end
                        else
                        begin
                            Result := 0.0065753738438755873;
                        end;
                    end
                    else
                    begin
                        Result := 0.0092939144699755276;
                    end;
                end
                else
                begin
                    if features[45] <= 4697.0000000000009 then
                    begin
                        Result := -0.0013178975468846538;
                    end
                    else
                    begin
                        Result := 0.016640473690670888;
                    end;
                end;
            end;
        end
        else
        begin
            if features[132] <= -1.4999999999999998 then
            begin
                Result := -0.011039269052801727;
            end
            else
            begin
                if features[37] <= 7.5000000000000009 then
                begin
                    if features[91] <= 1513.0000000000002 then
                    begin
                        Result := 0.01705235005721116;
                    end
                    else
                    begin
                        Result := -0.0072329952241545143;
                    end;
                end
                else
                begin
                    Result := 0.030117130036859632;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.019144223353190746;
    end;
end;

function exact_edge_auditor_tree_20(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[34] <= 1.0000000180025095E-35 then
    begin
        if features[96] <= 457.50000000000006 then
        begin
            if features[133] <= -1.0000000180025095E-35 then
            begin
                if features[91] <= 3558.5000000000005 then
                begin
                    if features[85] <= 5674.5000000000009 then
                    begin
                        if features[66] <= 1.5000000000000002 then
                        begin
                            Result := 0.015518263915452437;
                        end
                        else
                        begin
                            Result := -0.009775666024141632;
                        end;
                    end
                    else
                    begin
                        Result := -0.022303199174164651;
                    end;
                end
                else
                begin
                    Result := -0.023365818678166093;
                end;
            end
            else
            begin
                if features[80] <= 12.500000000000002 then
                begin
                    if features[2] <= 22123.000000000004 then
                    begin
                        Result := 0.0114097478350006;
                    end
                    else
                    begin
                        if features[76] <= 725.50000000000011 then
                        begin
                            Result := 0.010565653515990868;
                        end
                        else
                        begin
                            Result := -0.010676108357777499;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.021826133770649292;
                end;
            end;
        end
        else
        begin
            if features[42] <= 1.5000000000000002 then
            begin
                Result := -0.011264632506280511;
            end
            else
            begin
                Result := 0.024456634163589477;
            end;
        end;
    end
    else
    begin
        if features[133] <= 713.00000000000011 then
        begin
            if features[111] <= 1.0000000180025095E-35 then
            begin
                Result := -0.028903000834341865;
            end
            else
            begin
                Result := -0.0052589775038756302;
            end;
        end
        else
        begin
            if features[30] <= 10.500000000000002 then
            begin
                if features[135] <= 5698.0000000000009 then
                begin
                    Result := 0.01473785307801684;
                end
                else
                begin
                    Result := -0.012748533887012158;
                end;
            end
            else
            begin
                Result := -0.01598887728064571;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_21(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[2] <= 31282.000000000004 then
        begin
            if features[96] <= -54.499999999999993 then
            begin
                Result := 0.01866925606112161;
            end
            else
            begin
                Result := -0.0065457557902810848;
            end;
        end
        else
        begin
            if features[128] <= -60749.999999999993 then
            begin
                Result := -0.00047828320442425511;
            end
            else
            begin
                if features[30] <= 1.5000000000000002 then
                begin
                    Result := -0.0014043131734243239;
                end
                else
                begin
                    Result := -0.026743185943044565;
                end;
            end;
        end;
    end
    else
    begin
        if features[133] <= -1.0000000180025095E-35 then
        begin
            if features[44] <= -886.99999999999989 then
            begin
                if features[96] <= 432.50000000000006 then
                begin
                    Result := -0.0012771250879609615;
                end
                else
                begin
                    Result := 0.02428795782772359;
                end;
            end
            else
            begin
                if features[59] <= 1236.0000000000002 then
                begin
                    if features[9] <= 739.50000000000011 then
                    begin
                        Result := -0.027148053150862283;
                    end
                    else
                    begin
                        Result := 0.004453023181509452;
                    end;
                end
                else
                begin
                    Result := 0.0075137605366595332;
                end;
            end;
        end
        else
        begin
            if features[96] <= 196.50000000000003 then
            begin
                if features[16] <= 173.50000000000003 then
                begin
                    Result := -0.0086861023467611383;
                end
                else
                begin
                    Result := 0.012271827186815873;
                end;
            end
            else
            begin
                if features[120] <= -2.4999999999999996 then
                begin
                    if features[47] <= 105112.50000000001 then
                    begin
                        Result := 0.015612361534790254;
                    end
                    else
                    begin
                        Result := -0.0095646771129191226;
                    end;
                end
                else
                begin
                    Result := 0.027041093686459881;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_22(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[34] <= 1.0000000180025095E-35 then
    begin
        if features[136] <= -2110.4999999999995 then
        begin
            Result := -0.015574130178088594;
        end
        else
        begin
            if features[96] <= 457.50000000000006 then
            begin
                if features[80] <= 12.500000000000002 then
                begin
                    if features[76] <= 753.50000000000011 then
                    begin
                        if features[45] <= 5702.0000000000009 then
                        begin
                            Result := 0.015829401697542739;
                        end
                        else
                        begin
                            Result := -0.011459624997599338;
                        end;
                    end
                    else
                    begin
                        if features[75] <= 15.500000000000002 then
                        begin
                            Result := -0.0088664932126160598;
                        end
                        else
                        begin
                            Result := 0.0096010759404435934;
                        end;
                    end;
                end
                else
                begin
                    if features[88] <= 23812.000000000004 then
                    begin
                        Result := 0.020665100315637095;
                    end
                    else
                    begin
                        Result := -0.0094105220049214584;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 1.5000000000000002 then
                begin
                    Result := -0.0087228580172277765;
                end
                else
                begin
                    if features[38] <= 15416.500000000002 then
                    begin
                        Result := 0.00045508590642981037;
                    end
                    else
                    begin
                        Result := 0.027353148401612383;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[133] <= 713.00000000000011 then
        begin
            if features[4] <= 4.5000000000000009 then
            begin
                Result := -0.026421992779379691;
            end
            else
            begin
                Result := 0.0030080461453229519;
            end;
        end
        else
        begin
            if features[57] <= 1414.5000000000002 then
            begin
                Result := 0.010894749582876341;
            end
            else
            begin
                if features[37] <= 8.5000000000000018 then
                begin
                    Result := -0.019826021888267938;
                end
                else
                begin
                    Result := 0.0076930753988247542;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_23(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[34] <= 54.000000000000007 then
        begin
            if features[136] <= -1724.9999999999998 then
            begin
                Result := -0.021685630806717923;
            end
            else
            begin
                if features[136] <= 421.50000000000006 then
                begin
                    Result := 0.012820379229690522;
                end
                else
                begin
                    if features[140] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.015197286828036036;
                    end
                    else
                    begin
                        if features[16] <= 436.00000000000006 then
                        begin
                            Result := -0.019150596913027423;
                        end
                        else
                        begin
                            Result := 0.0095607709536151969;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[133] <= 3564.0000000000005 then
            begin
                Result := -0.023714840412421018;
            end
            else
            begin
                if features[57] <= 1417.5000000000002 then
                begin
                    Result := 0.012643301892900895;
                end
                else
                begin
                    Result := -0.01401320419790265;
                end;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[127] <= 6.5000000000000009 then
            begin
                if features[96] <= 84.500000000000014 then
                begin
                    Result := -0.0086347694141115129;
                end
                else
                begin
                    Result := 0.016558174821460329;
                end;
            end
            else
            begin
                if features[118] <= 1354.5000000000002 then
                begin
                    Result := -0.026393996566795419;
                end
                else
                begin
                    Result := 0.006440277696833501;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[41] <= 5665.0000000000009 then
                begin
                    Result := 0.013078947323312525;
                end
                else
                begin
                    Result := -0.0082367598765992287;
                end;
            end
            else
            begin
                Result := 0.030468552997062796;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_24(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[58] <= 1098.0000000000002 then
        begin
            if features[2] <= 30344.500000000004 then
            begin
                if features[109] <= -1456.4999999999998 then
                begin
                    Result := -0.002451838273916096;
                end
                else
                begin
                    Result := 0.022201165852557228;
                end;
            end
            else
            begin
                Result := -0.012762256330820653;
            end;
        end
        else
        begin
            Result := -0.028689537206990186;
        end;
    end
    else
    begin
        if features[135] <= -852.99999999999989 then
        begin
            if features[128] <= 10125.000000000002 then
            begin
                Result := 0.0079077781677917274;
            end
            else
            begin
                Result := -0.022566134668417136;
            end;
        end
        else
        begin
            if features[96] <= 457.50000000000006 then
            begin
                if features[16] <= 173.50000000000003 then
                begin
                    if features[141] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.012063528931580783;
                    end
                    else
                    begin
                        if features[30] <= 2.5000000000000004 then
                        begin
                            Result := -0.022654319137487264;
                        end
                        else
                        begin
                            Result := 0.0019621522120502532;
                        end;
                    end;
                end
                else
                begin
                    if features[103] <= 1424.0000000000002 then
                    begin
                        if features[136] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0048569391161829446;
                        end
                        else
                        begin
                            Result := 0.014481456058243893;
                        end;
                    end
                    else
                    begin
                        Result := -0.014399406251179817;
                    end;
                end;
            end
            else
            begin
                if features[38] <= 15416.500000000002 then
                begin
                    Result := -0.00038015632003480702;
                end
                else
                begin
                    if features[42] <= 1.5000000000000002 then
                    begin
                        Result := -0.0073682534457219376;
                    end
                    else
                    begin
                        Result := 0.028540902229850319;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_25(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[37] <= 1.5000000000000002 then
        begin
            if features[54] <= 391.50000000000006 then
            begin
                if features[54] <= 247.50000000000003 then
                begin
                    Result := -0.01656716690657312;
                end
                else
                begin
                    Result := 0.0075585008189913254;
                end;
            end
            else
            begin
                Result := -0.027152092715934863;
            end;
        end
        else
        begin
            if features[136] <= -1724.9999999999998 then
            begin
                Result := -0.021689410258697358;
            end
            else
            begin
                if features[43] <= 8080.5000000000009 then
                begin
                    if features[52] <= -6650.4999999999991 then
                    begin
                        if features[52] <= -6936.4999999999991 then
                        begin
                            Result := 0.0091757613812680598;
                        end
                        else
                        begin
                            Result := -0.01943413932251874;
                        end;
                    end
                    else
                    begin
                        Result := 0.019880861829079791;
                    end;
                end
                else
                begin
                    Result := -0.0058247447728243364;
                end;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[127] <= 6.5000000000000009 then
            begin
                Result := 0.0051836890408328787;
            end
            else
            begin
                if features[118] <= 1354.5000000000002 then
                begin
                    Result := -0.025423865781187962;
                end
                else
                begin
                    Result := 0.0062481750888097858;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[40] <= 5701.0000000000009 then
                begin
                    if features[132] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.01120333932378605;
                    end
                    else
                    begin
                        Result := 0.015624995629967667;
                    end;
                end
                else
                begin
                    Result := -0.010875381717085112;
                end;
            end
            else
            begin
                Result := 0.029618334821679804;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_26(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[34] <= 1.0000000180025095E-35 then
    begin
        if features[96] <= 457.50000000000006 then
        begin
            if features[136] <= -2110.4999999999995 then
            begin
                Result := -0.016574966164712365;
            end
            else
            begin
                if features[80] <= 12.500000000000002 then
                begin
                    if features[76] <= 753.50000000000011 then
                    begin
                        if features[45] <= 5702.0000000000009 then
                        begin
                            Result := 0.014961830298647404;
                        end
                        else
                        begin
                            Result := -0.011519425302351047;
                        end;
                    end
                    else
                    begin
                        Result := -0.0044142051209506246;
                    end;
                end
                else
                begin
                    if features[136] <= -81.999999999999986 then
                    begin
                        Result := -0.010437984785477281;
                    end
                    else
                    begin
                        Result := 0.019481774547861316;
                    end;
                end;
            end;
        end
        else
        begin
            if features[42] <= 1.5000000000000002 then
            begin
                Result := -0.010612648164011225;
            end
            else
            begin
                Result := 0.022146882795987848;
            end;
        end;
    end
    else
    begin
        if features[21] <= 2.5000000000000004 then
        begin
            if features[58] <= 1.0000000180025095E-35 then
            begin
                if features[42] <= 2.5000000000000004 then
                begin
                    if features[97] <= -113.99999999999999 then
                    begin
                        Result := 0.0065111198909862953;
                    end
                    else
                    begin
                        Result := -0.029567649377388074;
                    end;
                end
                else
                begin
                    if features[57] <= 1408.5000000000002 then
                    begin
                        Result := 0.0096094339225406469;
                    end
                    else
                    begin
                        if features[80] <= 8.5000000000000018 then
                        begin
                            Result := 0.011039982984545711;
                        end
                        else
                        begin
                            Result := -0.021194473610633823;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := -0.027764136769987558;
            end;
        end
        else
        begin
            Result := 0.0060415636277699001;
        end;
    end;
end;

function exact_edge_auditor_tree_27(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[34] <= 54.000000000000007 then
        begin
            if features[136] <= -1724.9999999999998 then
            begin
                Result := -0.020082950386828495;
            end
            else
            begin
                if features[136] <= 421.50000000000006 then
                begin
                    Result := 0.012267567645877574;
                end
                else
                begin
                    if features[140] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.014655127470773379;
                    end
                    else
                    begin
                        if features[16] <= 436.00000000000006 then
                        begin
                            Result := -0.018847038575530616;
                        end
                        else
                        begin
                            Result := 0.0092676053208325341;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[133] <= 3564.0000000000005 then
            begin
                Result := -0.021571912212029358;
            end
            else
            begin
                if features[57] <= 1429.5000000000002 then
                begin
                    Result := 0.012469701699583601;
                end
                else
                begin
                    Result := -0.012777576757191324;
                end;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[127] <= 6.5000000000000009 then
            begin
                if features[96] <= 84.500000000000014 then
                begin
                    Result := -0.0086497597900125553;
                end
                else
                begin
                    Result := 0.015722289841072684;
                end;
            end
            else
            begin
                if features[118] <= 1354.5000000000002 then
                begin
                    Result := -0.02460275275696602;
                end
                else
                begin
                    Result := 0.0061339172308968477;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[40] <= 5701.0000000000009 then
                begin
                    Result := 0.011591491037349426;
                end
                else
                begin
                    Result := -0.010737546848803674;
                end;
            end
            else
            begin
                Result := 0.028861455649394588;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_28(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[58] <= 1098.0000000000002 then
        begin
            if features[2] <= 30344.500000000004 then
            begin
                Result := 0.01169599727266247;
            end
            else
            begin
                if features[64] <= 4163.0000000000009 then
                begin
                    if features[134] <= -3779.4999999999995 then
                    begin
                        Result := 0.0074141763917934585;
                    end
                    else
                    begin
                        Result := -0.024425221433900659;
                    end;
                end
                else
                begin
                    Result := -0.0024423331093319503;
                end;
            end;
        end
        else
        begin
            Result := -0.026688351898649321;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[96] <= 158.00000000000003 then
            begin
                if features[12] <= 1165.5000000000002 then
                begin
                    if features[121] <= -50.499999999999993 then
                    begin
                        if features[109] <= -8725.9999999999982 then
                        begin
                            Result := 0.0060853742096005949;
                        end
                        else
                        begin
                            Result := -0.02397931543373448;
                        end;
                    end
                    else
                    begin
                        Result := 0.0097720208616329692;
                    end;
                end
                else
                begin
                    Result := 0.0091205298308782417;
                end;
            end
            else
            begin
                if features[47] <= 144238.50000000003 then
                begin
                    Result := 0.024094157508288042;
                end
                else
                begin
                    Result := -0.00081338725171615394;
                end;
            end;
        end
        else
        begin
            if features[60] <= 369.00000000000006 then
            begin
                if features[127] <= 3.5000000000000004 then
                begin
                    Result := 0.0097116135331500007;
                end
                else
                begin
                    if features[99] <= 455.50000000000006 then
                    begin
                        Result := -0.027269015836460037;
                    end
                    else
                    begin
                        Result := 0.0047475383388797783;
                    end;
                end;
            end
            else
            begin
                Result := 0.010093614645903064;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_29(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[19] <= 4595.5000000000009 then
    begin
        if features[96] <= 457.50000000000006 then
        begin
            if features[136] <= -1.0000000180025095E-35 then
            begin
                if features[46] <= 3254.5000000000005 then
                begin
                    if features[19] <= 3074.5000000000005 then
                    begin
                        Result := 0.0050197502229522425;
                    end
                    else
                    begin
                        if features[124] <= -646.49999999999989 then
                        begin
                            Result := 0.0036062571695688519;
                        end
                        else
                        begin
                            Result := -0.020921023809288439;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.02993040791435355;
                end;
            end
            else
            begin
                if features[80] <= 12.500000000000002 then
                begin
                    if features[80] <= 9.5000000000000018 then
                    begin
                        if features[21] <= 1.5000000000000002 then
                        begin
                            Result := -0.0016572862609413562;
                        end
                        else
                        begin
                            Result := 0.011399102774873961;
                        end;
                    end
                    else
                    begin
                        if features[137] <= 1.5000000000000002 then
                        begin
                            Result := -0.020183778390318652;
                        end
                        else
                        begin
                            Result := 0.0040929830340642537;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.016127920953830234;
                end;
            end;
        end
        else
        begin
            if features[42] <= 1.5000000000000002 then
            begin
                Result := -0.0055610002445888153;
            end
            else
            begin
                if features[123] <= 19.500000000000004 then
                begin
                    if features[109] <= -7885.4999999999991 then
                    begin
                        if features[89] <= 125.50000000000001 then
                        begin
                            Result := 0.015173707161090089;
                        end
                        else
                        begin
                            Result := -0.0076030751495909021;
                        end;
                    end
                    else
                    begin
                        Result := 0.029521295784071488;
                    end;
                end
                else
                begin
                    Result := -0.0043762294058048989;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.014544377373067071;
    end;
end;

function exact_edge_auditor_tree_30(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[105] <= 246.50000000000003 then
        begin
            if features[21] <= 2.5000000000000004 then
            begin
                if features[134] <= 1711.5000000000002 then
                begin
                    if features[97] <= -480.99999999999994 then
                    begin
                        Result := 0.0038499260126049414;
                    end
                    else
                    begin
                        Result := -0.020728592552561046;
                    end;
                end
                else
                begin
                    Result := -0.0010074373793944292;
                end;
            end
            else
            begin
                if features[111] <= 4.5000000000000009 then
                begin
                    if features[134] <= 1711.5000000000002 then
                    begin
                        Result := 0.021159204084744532;
                    end
                    else
                    begin
                        Result := -0.0073980624241647228;
                    end;
                end
                else
                begin
                    Result := -0.011958611811385973;
                end;
            end;
        end
        else
        begin
            Result := 0.0084471917428798268;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[32] <= 2.5000000000000004 then
            begin
                Result := 0.011739395894889777;
            end
            else
            begin
                if features[82] <= 4.5000000000000009 then
                begin
                    if features[2] <= 16994.500000000004 then
                    begin
                        Result := 0.0087449583789659738;
                    end
                    else
                    begin
                        Result := -0.027332173949254229;
                    end;
                end
                else
                begin
                    if features[128] <= 16187.500000000002 then
                    begin
                        Result := -0.0113349203614743;
                    end
                    else
                    begin
                        Result := 0.013912169453929923;
                    end;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[41] <= 5665.0000000000009 then
                begin
                    Result := 0.011684124167346764;
                end
                else
                begin
                    Result := -0.0084865168219312136;
                end;
            end
            else
            begin
                Result := 0.027885071409101184;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_31(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[58] <= 1084.5000000000002 then
        begin
            if features[52] <= -6706.9999999999991 then
            begin
                if features[16] <= 184.00000000000003 then
                begin
                    Result := -0.020336769512923302;
                end
                else
                begin
                    Result := 0.0018217401550113983;
                end;
            end
            else
            begin
                if features[34] <= 228.50000000000003 then
                begin
                    if features[90] <= 5269.5000000000009 then
                    begin
                        Result := 0.017716822406130591;
                    end
                    else
                    begin
                        if features[31] <= 820.50000000000011 then
                        begin
                            Result := -0.012788938703200563;
                        end
                        else
                        begin
                            Result := 0.011470981379321701;
                        end;
                    end;
                end
                else
                begin
                    if features[3] <= 4.5000000000000009 then
                    begin
                        Result := 0.011117272748849258;
                    end
                    else
                    begin
                        if features[57] <= 1429.5000000000002 then
                        begin
                            Result := 0.0024137388851292636;
                        end
                        else
                        begin
                            Result := -0.023706850039954833;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.019716548175414385;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[127] <= 6.5000000000000009 then
            begin
                if features[96] <= 84.500000000000014 then
                begin
                    Result := -0.0084124230009217926;
                end
                else
                begin
                    Result := 0.014825927443633846;
                end;
            end
            else
            begin
                Result := -0.017218498598247103;
            end;
        end
        else
        begin
            if features[96] <= 344.50000000000006 then
            begin
                if features[85] <= 5674.5000000000009 then
                begin
                    Result := 0.01063802894850494;
                end
                else
                begin
                    Result := -0.012104919822541827;
                end;
            end
            else
            begin
                Result := 0.026235852809935616;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_32(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[54] <= 391.50000000000006 then
        begin
            if features[16] <= 226.00000000000003 then
            begin
                if features[97] <= -78.499999999999986 then
                begin
                    Result := 0.0071494326927960209;
                end
                else
                begin
                    Result := -0.014226875035481796;
                end;
            end
            else
            begin
                Result := 0.010614310108539169;
            end;
        end
        else
        begin
            if features[73] <= 1249.5000000000002 then
            begin
                Result := 0.001593247999572714;
            end
            else
            begin
                Result := -0.024614502033639546;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[115] <= 1.5000000000000002 then
            begin
                if features[97] <= 101.00000000000001 then
                begin
                    if features[80] <= 10.500000000000002 then
                    begin
                        Result := -0.0012191110358287279;
                    end
                    else
                    begin
                        if features[9] <= 836.50000000000011 then
                        begin
                            Result := 0.020561249653844517;
                        end
                        else
                        begin
                            Result := -0.0092227916174907557;
                        end;
                    end;
                end
                else
                begin
                    if features[134] <= 3585.5000000000005 then
                    begin
                        Result := 0.024306539763166688;
                    end
                    else
                    begin
                        Result := 0.0014402490169346492;
                    end;
                end;
            end
            else
            begin
                Result := -0.0068353969989308414;
            end;
        end
        else
        begin
            if features[54] <= 609.50000000000011 then
            begin
                if features[127] <= 3.5000000000000004 then
                begin
                    Result := 0.010847151043799848;
                end
                else
                begin
                    if features[32] <= 2.5000000000000004 then
                    begin
                        Result := -0.0015227616228015001;
                    end
                    else
                    begin
                        Result := -0.025547195623972476;
                    end;
                end;
            end
            else
            begin
                Result := 0.012181573444773771;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_33(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[58] <= 1084.5000000000002 then
        begin
            if features[52] <= -6706.9999999999991 then
            begin
                if features[16] <= 184.00000000000003 then
                begin
                    Result := -0.019623724717873596;
                end
                else
                begin
                    Result := 0.0018007296876195668;
                end;
            end
            else
            begin
                if features[34] <= 228.50000000000003 then
                begin
                    Result := 0.0080765911373736725;
                end
                else
                begin
                    if features[28] <= 2797.5000000000005 then
                    begin
                        Result := 0.0021019616204526279;
                    end
                    else
                    begin
                        Result := -0.021358361844694501;
                    end;
                end;
            end;
        end
        else
        begin
            if features[124] <= -666.49999999999989 then
            begin
                Result := 0.0017612995828473895;
            end
            else
            begin
                Result := -0.023661436549434693;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[6] <= -6011.9999999999991 then
            begin
                Result := 0.013190026058304119;
            end
            else
            begin
                if features[79] <= 154.50000000000003 then
                begin
                    Result := 0.0027845603495432708;
                end
                else
                begin
                    if features[79] <= 583.50000000000011 then
                    begin
                        Result := -0.027647798039888375;
                    end
                    else
                    begin
                        Result := 0.0057863579124003998;
                    end;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[40] <= 5701.0000000000009 then
                begin
                    if features[132] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.011582044737551115;
                    end
                    else
                    begin
                        Result := 0.013950797428619906;
                    end;
                end
                else
                begin
                    Result := -0.01051513426858126;
                end;
            end
            else
            begin
                Result := 0.026813519014002422;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_34(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[34] <= 1.0000000180025095E-35 then
    begin
        if features[96] <= 457.50000000000006 then
        begin
            if features[133] <= -1.0000000180025095E-35 then
            begin
                if features[89] <= -69.999999999999986 then
                begin
                    if features[79] <= 627.50000000000011 then
                    begin
                        Result := -0.0079271056189398337;
                    end
                    else
                    begin
                        Result := 0.019262303906113668;
                    end;
                end
                else
                begin
                    Result := -0.014638976674723879;
                end;
            end
            else
            begin
                if features[80] <= 12.500000000000002 then
                begin
                    if features[2] <= 22123.000000000004 then
                    begin
                        if features[126] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0024401064036028279;
                        end
                        else
                        begin
                            Result := 0.018143663164624662;
                        end;
                    end
                    else
                    begin
                        if features[78] <= 725.50000000000011 then
                        begin
                            Result := 0.0085200989066301722;
                        end
                        else
                        begin
                            Result := -0.010988807798651913;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.01910537813129929;
                end;
            end;
        end
        else
        begin
            if features[42] <= 1.5000000000000002 then
            begin
                Result := -0.010076947728503679;
            end
            else
            begin
                Result := 0.019820853648507903;
            end;
        end;
    end
    else
    begin
        if features[133] <= 713.00000000000011 then
        begin
            if features[4] <= 4.5000000000000009 then
            begin
                Result := -0.021564830060758457;
            end
            else
            begin
                Result := 0.0059181434627927562;
            end;
        end
        else
        begin
            if features[30] <= 13.500000000000002 then
            begin
                Result := 0.007803272876711201;
            end
            else
            begin
                if features[64] <= 10319.500000000002 then
                begin
                    Result := -0.023047058444724992;
                end
                else
                begin
                    Result := 0.0086737611805322232;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_35(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[58] <= 1084.5000000000002 then
        begin
            if features[52] <= -6706.9999999999991 then
            begin
                Result := -0.011963225654525834;
            end
            else
            begin
                if features[88] <= 7107.0000000000009 then
                begin
                    if features[37] <= 1.5000000000000002 then
                    begin
                        Result := -0.0055504568200772817;
                    end
                    else
                    begin
                        Result := 0.019135120720578012;
                    end;
                end
                else
                begin
                    if features[76] <= 906.50000000000011 then
                    begin
                        Result := -0.016382448357531079;
                    end
                    else
                    begin
                        Result := 0.0065454645740575731;
                    end;
                end;
            end;
        end
        else
        begin
            if features[124] <= -666.49999999999989 then
            begin
                Result := 0.0016756498573207311;
            end
            else
            begin
                Result := -0.022771835008617246;
            end;
        end;
    end
    else
    begin
        if features[42] <= 1.5000000000000002 then
        begin
            if features[74] <= 1.0000000180025095E-35 then
            begin
                Result := -0.016883637014875778;
            end
            else
            begin
                Result := 0.010804366866177657;
            end;
        end
        else
        begin
            if features[96] <= 344.50000000000006 then
            begin
                if features[20] <= 12.500000000000002 then
                begin
                    if features[2] <= 22123.000000000004 then
                    begin
                        if features[83] <= 16375.000000000002 then
                        begin
                            Result := 0.019317023957325041;
                        end
                        else
                        begin
                            Result := -0.0072318319095175309;
                        end;
                    end
                    else
                    begin
                        if features[44] <= 985.50000000000011 then
                        begin
                            Result := 0.0047409172412009107;
                        end
                        else
                        begin
                            Result := -0.016857856274247265;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.016644800151101698;
                end;
            end
            else
            begin
                Result := 0.022303773358140655;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_36(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[136] <= -1724.9999999999998 then
        begin
            Result := -0.021884977487392418;
        end
        else
        begin
            if features[125] <= -1.4999999999999998 then
            begin
                if features[90] <= 4483.0000000000009 then
                begin
                    Result := 0.01817543462398458;
                end
                else
                begin
                    Result := -0.002766221308294022;
                end;
            end
            else
            begin
                if features[28] <= 2884.5000000000005 then
                begin
                    Result := -0.0028685761825051771;
                end
                else
                begin
                    Result := -0.021215743148589213;
                end;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[6] <= -6011.9999999999991 then
            begin
                Result := 0.012806357450525737;
            end
            else
            begin
                if features[96] <= 84.500000000000014 then
                begin
                    Result := -0.021080387273597317;
                end
                else
                begin
                    if features[79] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.01557476506905823;
                    end
                    else
                    begin
                        if features[79] <= 640.50000000000011 then
                        begin
                            Result := -0.017081776699563969;
                        end
                        else
                        begin
                            Result := 0.011381502790401501;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[41] <= 5665.0000000000009 then
                begin
                    if features[91] <= 3864.5000000000005 then
                    begin
                        Result := 0.013726283486132385;
                    end
                    else
                    begin
                        if features[96] <= -123.49999999999999 then
                        begin
                            Result := 0.01166598188192914;
                        end
                        else
                        begin
                            Result := -0.017813188731276259;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0086602401055564573;
                end;
            end
            else
            begin
                Result := 0.025814385324714209;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_37(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[105] <= 246.50000000000003 then
        begin
            if features[21] <= 2.5000000000000004 then
            begin
                if features[134] <= 1711.5000000000002 then
                begin
                    if features[98] <= -480.99999999999994 then
                    begin
                        Result := 0.0046258452661256666;
                    end
                    else
                    begin
                        Result := -0.018266107275330113;
                    end;
                end
                else
                begin
                    Result := 3.7712157023085995E-05;
                end;
            end
            else
            begin
                if features[111] <= 4.5000000000000009 then
                begin
                    if features[134] <= 1711.5000000000002 then
                    begin
                        Result := 0.020888021790144835;
                    end
                    else
                    begin
                        Result := -0.0072759420424317826;
                    end;
                end
                else
                begin
                    Result := -0.011462425237496882;
                end;
            end;
        end
        else
        begin
            Result := 0.0081959438816980278;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[127] <= 6.5000000000000009 then
            begin
                if features[96] <= 84.500000000000014 then
                begin
                    Result := -0.0078790244615675482;
                end
                else
                begin
                    Result := 0.013935814024900359;
                end;
            end
            else
            begin
                if features[118] <= 1354.5000000000002 then
                begin
                    Result := -0.021698165917852369;
                end
                else
                begin
                    Result := 0.0067377509330061565;
                end;
            end;
        end
        else
        begin
            if features[98] <= 357.50000000000006 then
            begin
                if features[41] <= 5665.0000000000009 then
                begin
                    if features[91] <= 3864.5000000000005 then
                    begin
                        Result := 0.013366138504634249;
                    end
                    else
                    begin
                        Result := -0.0073289575283984453;
                    end;
                end
                else
                begin
                    Result := -0.0084377401902798396;
                end;
            end
            else
            begin
                Result := 0.025391413989810038;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_38(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[34] <= 1.0000000180025095E-35 then
    begin
        if features[130] <= -2809.9999999999995 then
        begin
            if features[38] <= 125312.50000000001 then
            begin
                Result := -0.021109656969931948;
            end
            else
            begin
                Result := 0.0089455069792980062;
            end;
        end
        else
        begin
            if features[96] <= 457.50000000000006 then
            begin
                if features[38] <= 48562.500000000007 then
                begin
                    if features[75] <= 15.500000000000002 then
                    begin
                        if features[76] <= 770.50000000000011 then
                        begin
                            Result := 0.0065163833294834828;
                        end
                        else
                        begin
                            Result := -0.011899494036847659;
                        end;
                    end
                    else
                    begin
                        Result := 0.013389126751132458;
                    end;
                end
                else
                begin
                    if features[6] <= -5025.9999999999991 then
                    begin
                        Result := 0.019429315942901735;
                    end
                    else
                    begin
                        if features[52] <= -5420.9999999999991 then
                        begin
                            Result := -0.014897796343293085;
                        end
                        else
                        begin
                            Result := 0.013018061129954225;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 1.5000000000000002 then
                begin
                    Result := -0.011785759202920484;
                end
                else
                begin
                    Result := 0.019370250815748759;
                end;
            end;
        end;
    end
    else
    begin
        if features[133] <= 713.00000000000011 then
        begin
            if features[4] <= 4.5000000000000009 then
            begin
                Result := -0.020018292987643498;
            end
            else
            begin
                Result := 0.006478591372659789;
            end;
        end
        else
        begin
            if features[57] <= 1423.5000000000002 then
            begin
                Result := 0.011270259046320528;
            end
            else
            begin
                if features[38] <= 14166.500000000002 then
                begin
                    Result := -0.015774821047261797;
                end
                else
                begin
                    Result := 0.0083295727606180446;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_39(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[58] <= 1098.0000000000002 then
        begin
            if features[2] <= 30344.500000000004 then
            begin
                Result := 0.011575406726686378;
            end
            else
            begin
                if features[47] <= 64908.000000000007 then
                begin
                    if features[134] <= -6268.4999999999991 then
                    begin
                        Result := 0.0094056724076206893;
                    end
                    else
                    begin
                        if features[127] <= -10.499999999999998 then
                        begin
                            Result := 0.0038416574520294764;
                        end
                        else
                        begin
                            Result := -0.023380808023618443;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0021496366982802794;
                end;
            end;
        end
        else
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                Result := -0.027936738753458017;
            end
            else
            begin
                Result := -0.00077267559604884343;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[96] <= 103.50000000000001 then
            begin
                if features[47] <= 46969.500000000007 then
                begin
                    Result := -0.0088984577965893034;
                end
                else
                begin
                    Result := 0.0098443473807410548;
                end;
            end
            else
            begin
                if features[47] <= 144238.50000000003 then
                begin
                    Result := 0.020129918806889375;
                end
                else
                begin
                    Result := -0.0008032552128154493;
                end;
            end;
        end
        else
        begin
            if features[60] <= 369.00000000000006 then
            begin
                if features[127] <= 3.5000000000000004 then
                begin
                    Result := 0.0085949629997450656;
                end
                else
                begin
                    if features[99] <= 455.50000000000006 then
                    begin
                        Result := -0.025215712018645243;
                    end
                    else
                    begin
                        Result := 0.0043800965755567637;
                    end;
                end;
            end
            else
            begin
                Result := 0.0096360770131632949;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_40(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[136] <= -1724.9999999999998 then
        begin
            Result := -0.020592791784831855;
        end
        else
        begin
            if features[125] <= -1.4999999999999998 then
            begin
                if features[46] <= 3254.5000000000005 then
                begin
                    Result := 0.01714698594461854;
                end
                else
                begin
                    Result := -0.0046696639004225491;
                end;
            end
            else
            begin
                if features[3] <= 5.5000000000000009 then
                begin
                    if features[81] <= 4.5000000000000009 then
                    begin
                        if features[141] <= 4.5000000000000009 then
                        begin
                            Result := -0.015426895872852193;
                        end
                        else
                        begin
                            Result := 0.0095492446546133359;
                        end;
                    end
                    else
                    begin
                        if features[58] <= 1098.0000000000002 then
                        begin
                            Result := 0.017338016044467372;
                        end
                        else
                        begin
                            Result := -0.0069638150733990082;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.015499703609162929;
                end;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[127] <= 6.5000000000000009 then
            begin
                if features[83] <= 24062.500000000004 then
                begin
                    Result := 0.012303692192089908;
                end
                else
                begin
                    Result := -0.0080760268558112726;
                end;
            end
            else
            begin
                if features[118] <= 1354.5000000000002 then
                begin
                    Result := -0.021038513992994529;
                end
                else
                begin
                    Result := 0.0065021260775097447;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[41] <= 5665.0000000000009 then
                begin
                    Result := 0.0097907743409785756;
                end
                else
                begin
                    Result := -0.0084674711337844495;
                end;
            end
            else
            begin
                Result := 0.024579043912041628;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_41(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[54] <= 391.50000000000006 then
        begin
            if features[45] <= 2520.0000000000005 then
            begin
                Result := -0.01224196000467268;
            end
            else
            begin
                if features[3] <= 5.5000000000000009 then
                begin
                    if features[92] <= -21166.999999999996 then
                    begin
                        Result := -0.0046910399162571883;
                    end
                    else
                    begin
                        Result := 0.024091068973136846;
                    end;
                end
                else
                begin
                    Result := -0.0065554900819979169;
                end;
            end;
        end
        else
        begin
            if features[73] <= 1249.5000000000002 then
            begin
                Result := 0.0027849624372614573;
            end
            else
            begin
                if features[97] <= -278.49999999999994 then
                begin
                    Result := 0.0016429879362846792;
                end
                else
                begin
                    Result := -0.025041216298966246;
                end;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[96] <= 103.50000000000001 then
            begin
                if features[80] <= 10.500000000000002 then
                begin
                    Result := -0.0054837094991432613;
                end
                else
                begin
                    if features[60] <= 408.00000000000006 then
                    begin
                        Result := 0.018987294485769766;
                    end
                    else
                    begin
                        Result := -0.0052469531214566411;
                    end;
                end;
            end
            else
            begin
                Result := 0.015989943980990132;
            end;
        end
        else
        begin
            if features[60] <= 369.00000000000006 then
            begin
                if features[127] <= 3.5000000000000004 then
                begin
                    Result := 0.0082907216739017305;
                end
                else
                begin
                    if features[83] <= 1268.0000000000002 then
                    begin
                        Result := -0.0026831119551135475;
                    end
                    else
                    begin
                        Result := -0.027813494240448856;
                    end;
                end;
            end
            else
            begin
                Result := 0.0093199957904250494;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_42(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[34] <= 1.0000000180025095E-35 then
    begin
        if features[97] <= 134.50000000000003 then
        begin
            if features[130] <= -2809.9999999999995 then
            begin
                Result := -0.018304507248084065;
            end
            else
            begin
                if features[38] <= 48562.500000000007 then
                begin
                    if features[0] <= 9.5000000000000018 then
                    begin
                        if features[32] <= 5.5000000000000009 then
                        begin
                            Result := 0.010418031542871426;
                        end
                        else
                        begin
                            Result := -0.0095260071716993088;
                        end;
                    end
                    else
                    begin
                        if features[36] <= 10.500000000000002 then
                        begin
                            Result := -0.022347212318838079;
                        end
                        else
                        begin
                            Result := 0.010169904224251923;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.01186033530778857;
                end;
            end;
        end
        else
        begin
            if features[109] <= -8263.4999999999982 then
            begin
                if features[91] <= 274.50000000000006 then
                begin
                    Result := 0.010996591134578196;
                end
                else
                begin
                    if features[14] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.018358731938060795;
                    end
                    else
                    begin
                        Result := 0.010311836879619939;
                    end;
                end;
            end
            else
            begin
                if features[91] <= 3176.5000000000005 then
                begin
                    Result := 0.019766979838115123;
                end
                else
                begin
                    Result := -0.0002473639905973309;
                end;
            end;
        end;
    end
    else
    begin
        if features[133] <= 713.00000000000011 then
        begin
            if features[4] <= 4.5000000000000009 then
            begin
                Result := -0.018770758191345677;
            end
            else
            begin
                Result := 0.0070330794574308452;
            end;
        end
        else
        begin
            if features[30] <= 13.500000000000002 then
            begin
                Result := 0.0081698232452095624;
            end
            else
            begin
                Result := -0.013404902251816076;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_43(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 1.5000000000000002 then
    begin
        if features[58] <= 1098.0000000000002 then
        begin
            if features[2] <= 30344.500000000004 then
            begin
                Result := 0.011202654100367818;
            end
            else
            begin
                if features[47] <= 64908.000000000007 then
                begin
                    Result := -0.013633774466654832;
                end
                else
                begin
                    Result := 0.0027498624535730633;
                end;
            end;
        end
        else
        begin
            if features[118] <= 1.0000000180025095E-35 then
            begin
                Result := -0.026330527439062505;
            end
            else
            begin
                Result := -0.00026090621072815545;
            end;
        end;
    end
    else
    begin
        if features[89] <= 1.0000000180025095E-35 then
        begin
            if features[115] <= 1.5000000000000002 then
            begin
                if features[96] <= -228.49999999999997 then
                begin
                    if features[47] <= 50285.000000000007 then
                    begin
                        Result := -0.018362379676940089;
                    end
                    else
                    begin
                        if features[13] <= 1414.5000000000002 then
                        begin
                            Result := 0.019194602342011237;
                        end
                        else
                        begin
                            Result := -0.014504792547420133;
                        end;
                    end;
                end
                else
                begin
                    if features[134] <= 6282.5000000000009 then
                    begin
                        Result := 0.016596321693097008;
                    end
                    else
                    begin
                        Result := -0.0040582447497423636;
                    end;
                end;
            end
            else
            begin
                Result := -0.0068134522728414996;
            end;
        end
        else
        begin
            if features[60] <= 369.00000000000006 then
            begin
                if features[121] <= -1.0000000180025095E-35 then
                begin
                    if features[83] <= 1268.0000000000002 then
                    begin
                        Result := -0.00048192890244893845;
                    end
                    else
                    begin
                        Result := -0.026231763166554675;
                    end;
                end
                else
                begin
                    Result := 0.012659051857685654;
                end;
            end
            else
            begin
                Result := 0.0091414679470918792;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_44(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            Result := -0.016781599579896705;
        end
        else
        begin
            if features[120] <= 7.5000000000000009 then
            begin
                if features[15] <= 449.00000000000006 then
                begin
                    if features[2] <= 10549.500000000002 then
                    begin
                        Result := 0.01470973509141142;
                    end
                    else
                    begin
                        if features[96] <= -102.49999999999999 then
                        begin
                            Result := 0.0054377439594652521;
                        end
                        else
                        begin
                            Result := -0.0098127670708372597;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.011213415074158604;
                end;
            end
            else
            begin
                Result := -0.015744318242606845;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[6] <= -6011.9999999999991 then
            begin
                Result := 0.012354469595261385;
            end
            else
            begin
                if features[96] <= 84.500000000000014 then
                begin
                    Result := -0.019640651485319714;
                end
                else
                begin
                    if features[79] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.014291870368256547;
                    end
                    else
                    begin
                        if features[79] <= 640.50000000000011 then
                        begin
                            Result := -0.016945705300427997;
                        end
                        else
                        begin
                            Result := 0.011113073982649326;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[41] <= 5665.0000000000009 then
                begin
                    if features[91] <= 3864.5000000000005 then
                    begin
                        Result := 0.012222848770036814;
                    end
                    else
                    begin
                        Result := -0.0067885588219541767;
                    end;
                end
                else
                begin
                    Result := -0.0086661358108004165;
                end;
            end
            else
            begin
                Result := 0.02369942926303251;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_45(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 4.5000000000000009 then
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            Result := -0.016292401904290557;
        end
        else
        begin
            if features[120] <= 7.5000000000000009 then
            begin
                if features[15] <= 449.00000000000006 then
                begin
                    if features[2] <= 10549.500000000002 then
                    begin
                        Result := 0.014482523417742879;
                    end
                    else
                    begin
                        if features[99] <= 329.50000000000006 then
                        begin
                            Result := -0.007612094580335271;
                        end
                        else
                        begin
                            Result := 0.012172407282426669;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.010931266124227072;
                end;
            end
            else
            begin
                Result := -0.015337727944222578;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4697.0000000000009 then
        begin
            if features[6] <= -6011.9999999999991 then
            begin
                Result := 0.012128677310395866;
            end
            else
            begin
                if features[79] <= 631.50000000000011 then
                begin
                    if features[124] <= -139.49999999999997 then
                    begin
                        Result := -0.025799906582153222;
                    end
                    else
                    begin
                        Result := 0.00079588795598657983;
                    end;
                end
                else
                begin
                    Result := 0.008358501921339398;
                end;
            end;
        end
        else
        begin
            if features[97] <= 357.50000000000006 then
            begin
                if features[41] <= 5665.0000000000009 then
                begin
                    if features[132] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0079703496011685245;
                    end
                    else
                    begin
                        if features[43] <= 13907.000000000002 then
                        begin
                            Result := 0.01944576044715517;
                        end
                        else
                        begin
                            Result := 0.002174239251479455;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0084440749981111122;
                end;
            end
            else
            begin
                Result := 0.02330852176033783;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_46(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 7.5000000000000009 then
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            if features[52] <= -6133.4999999999991 then
            begin
                if features[23] <= 1.0000000180025095E-35 then
                begin
                    if features[90] <= 4090.5000000000005 then
                    begin
                        Result := 1.274881524237982E-05;
                    end
                    else
                    begin
                        Result := -0.032129797093193496;
                    end;
                end
                else
                begin
                    Result := 0.006326982556820241;
                end;
            end
            else
            begin
                if features[91] <= 4041.0000000000005 then
                begin
                    if features[85] <= 5672.0000000000009 then
                    begin
                        if features[33] <= 702.00000000000011 then
                        begin
                            Result := -0.0077680078232258733;
                        end
                        else
                        begin
                            Result := 0.023073944540664575;
                        end;
                    end
                    else
                    begin
                        Result := -0.011242299503865143;
                    end;
                end
                else
                begin
                    Result := -0.011768720026903885;
                end;
            end;
        end
        else
        begin
            if features[96] <= 180.50000000000003 then
            begin
                if features[104] <= 1306.5000000000002 then
                begin
                    if features[137] <= 2.5000000000000004 then
                    begin
                        Result := -0.0046832347296212658;
                    end
                    else
                    begin
                        Result := 0.013882001454694551;
                    end;
                end
                else
                begin
                    Result := 0.023014155063016465;
                end;
            end
            else
            begin
                if features[132] <= 3.5000000000000004 then
                begin
                    if features[120] <= -1.0000000180025095E-35 then
                    begin
                        if features[73] <= 2695.5000000000005 then
                        begin
                            Result := -0.010949195436222086;
                        end
                        else
                        begin
                            Result := 0.0086229688517946053;
                        end;
                    end
                    else
                    begin
                        Result := 0.01474491267760966;
                    end;
                end
                else
                begin
                    Result := 0.02677573443926121;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.016174393497681717;
    end;
end;

function exact_edge_auditor_tree_47(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[135] <= -852.99999999999989 then
    begin
        if features[23] <= 1.5000000000000002 then
        begin
            Result := -0.02022422944794499;
        end
        else
        begin
            Result := 0.0041986105828698897;
        end;
    end
    else
    begin
        if features[20] <= 4.5000000000000009 then
        begin
            if features[3] <= 5.5000000000000009 then
            begin
                if features[31] <= 791.50000000000011 then
                begin
                    if features[15] <= 630.50000000000011 then
                    begin
                        Result := -0.0099619303578022036;
                    end
                    else
                    begin
                        Result := 0.012258012991889881;
                    end;
                end
                else
                begin
                    Result := 0.010871247635948397;
                end;
            end
            else
            begin
                if features[125] <= -1.4999999999999998 then
                begin
                    Result := 0.010929502851435763;
                end
                else
                begin
                    Result := -0.013873219381543032;
                end;
            end;
        end
        else
        begin
            if features[96] <= 344.50000000000006 then
            begin
                if features[20] <= 12.500000000000002 then
                begin
                    if features[2] <= 22123.000000000004 then
                    begin
                        if features[83] <= 16375.000000000002 then
                        begin
                            Result := 0.020418428068987915;
                        end
                        else
                        begin
                            Result := -0.010697443055047762;
                        end;
                    end
                    else
                    begin
                        if features[14] <= 1354.5000000000002 then
                        begin
                            Result := -0.014766519233583368;
                        end
                        else
                        begin
                            Result := 0.0068867814596775771;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.014354730907767699;
                end;
            end
            else
            begin
                if features[35] <= 5.5000000000000009 then
                begin
                    if features[111] <= 2.5000000000000004 then
                    begin
                        Result := 0.0098554134323016775;
                    end
                    else
                    begin
                        Result := -0.014405949142907298;
                    end;
                end
                else
                begin
                    Result := 0.024216685357021518;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_48(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[34] <= 1.0000000180025095E-35 then
    begin
        if features[97] <= 134.50000000000003 then
        begin
            if features[66] <= 1.5000000000000002 then
            begin
                if features[83] <= 2062.5000000000005 then
                begin
                    if features[76] <= 944.50000000000011 then
                    begin
                        if features[6] <= -3851.4999999999995 then
                        begin
                            Result := -0.017872971285222788;
                        end
                        else
                        begin
                            Result := 0.011514958085972393;
                        end;
                    end
                    else
                    begin
                        Result := 0.0100021196218131;
                    end;
                end
                else
                begin
                    if features[110] <= 1.5000000000000002 then
                    begin
                        Result := -0.0045452394159358391;
                    end
                    else
                    begin
                        Result := 0.021127375328993489;
                    end;
                end;
            end
            else
            begin
                if features[99] <= 1.0000000180025095E-35 then
                begin
                    Result := -0.018140778494940613;
                end
                else
                begin
                    Result := 0.0060677492171083876;
                end;
            end;
        end
        else
        begin
            if features[109] <= -7885.4999999999991 then
            begin
                if features[97] <= 732.00000000000011 then
                begin
                    if features[31] <= 702.00000000000011 then
                    begin
                        Result := -0.025342943269833176;
                    end
                    else
                    begin
                        Result := 0.0039869397794760056;
                    end;
                end
                else
                begin
                    Result := 0.010852883129523453;
                end;
            end
            else
            begin
                Result := 0.01519939967732656;
            end;
        end;
    end
    else
    begin
        if features[133] <= 713.00000000000011 then
        begin
            if features[4] <= 4.5000000000000009 then
            begin
                Result := -0.017240683809898311;
            end
            else
            begin
                Result := 0.0079002424447578035;
            end;
        end
        else
        begin
            if features[30] <= 13.500000000000002 then
            begin
                Result := 0.0082089366801126294;
            end
            else
            begin
                Result := -0.012117595369723545;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_49(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[42] <= 1.0000000180025095E-35 then
    begin
        if features[59] <= 1236.0000000000002 then
        begin
            Result := -0.015590453033752151;
        end
        else
        begin
            Result := 0.0044035246661282409;
        end;
    end
    else
    begin
        if features[96] <= 196.50000000000003 then
        begin
            if features[125] <= -1.4999999999999998 then
            begin
                if features[7] <= -6008.9999999999991 then
                begin
                    if features[6] <= -5716.4999999999991 then
                    begin
                        Result := 0.009341002068827868;
                    end
                    else
                    begin
                        Result := -0.015791025567121159;
                    end;
                end
                else
                begin
                    Result := 0.021920168268512123;
                end;
            end
            else
            begin
                if features[28] <= 2797.5000000000005 then
                begin
                    if features[38] <= 14166.500000000002 then
                    begin
                        Result := 0.0092753112229200154;
                    end
                    else
                    begin
                        if features[38] <= 34062.500000000007 then
                        begin
                            Result := -0.016225736450957845;
                        end
                        else
                        begin
                            Result := 0.0027365816441163055;
                        end;
                    end;
                end
                else
                begin
                    if features[133] <= 24271.000000000004 then
                    begin
                        Result := -0.018352624712616269;
                    end
                    else
                    begin
                        Result := 0.0067786817134885199;
                    end;
                end;
            end;
        end
        else
        begin
            if features[108] <= 1.0000000180025095E-35 then
            begin
                if features[121] <= -249.49999999999997 then
                begin
                    Result := -0.0051926826379225192;
                end
                else
                begin
                    Result := 0.018074456514514906;
                end;
            end
            else
            begin
                if features[76] <= 924.50000000000011 then
                begin
                    if features[14] <= 1447.5000000000002 then
                    begin
                        Result := -0.018168774763107857;
                    end
                    else
                    begin
                        Result := 0.011034218479181616;
                    end;
                end
                else
                begin
                    Result := 0.012643155929727463;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_50(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[135] <= -852.99999999999989 then
    begin
        Result := -0.014993003701894386;
    end
    else
    begin
        if features[20] <= 4.5000000000000009 then
        begin
            if features[105] <= 246.50000000000003 then
            begin
                if features[21] <= 2.5000000000000004 then
                begin
                    if features[9] <= 390.50000000000006 then
                    begin
                        Result := -0.0034965140450428731;
                    end
                    else
                    begin
                        if features[73] <= 1080.0000000000002 then
                        begin
                            Result := 0.0089541467625588803;
                        end
                        else
                        begin
                            Result := -0.020407366279350678;
                        end;
                    end;
                end
                else
                begin
                    if features[46] <= 3254.5000000000005 then
                    begin
                        if features[54] <= 196.50000000000003 then
                        begin
                            Result := -0.0054843980565823236;
                        end
                        else
                        begin
                            Result := 0.024491063004036733;
                        end;
                    end
                    else
                    begin
                        Result := -0.0067988674097303487;
                    end;
                end;
            end
            else
            begin
                Result := 0.010282349396241819;
            end;
        end
        else
        begin
            if features[97] <= 381.00000000000006 then
            begin
                if features[20] <= 12.500000000000002 then
                begin
                    if features[2] <= 22123.000000000004 then
                    begin
                        if features[127] <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.0028040824735163839;
                        end
                        else
                        begin
                            Result := 0.019176521138065446;
                        end;
                    end
                    else
                    begin
                        if features[14] <= 1354.5000000000002 then
                        begin
                            Result := -0.014061524548107754;
                        end
                        else
                        begin
                            Result := 0.0067875489032815546;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.013321725638612105;
                end;
            end
            else
            begin
                if features[35] <= 5.5000000000000009 then
                begin
                    Result := 0.00091230454892366559;
                end
                else
                begin
                    Result := 0.02452279614728187;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_51(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[133] <= -9171.9999999999982 then
        begin
            if features[113] <= 1.5000000000000002 then
            begin
                Result := -0.021357683174882975;
            end
            else
            begin
                Result := 0.011820583911918314;
            end;
        end
        else
        begin
            if features[96] <= 732.50000000000011 then
            begin
                if features[20] <= 12.500000000000002 then
                begin
                    if features[104] <= 1318.5000000000002 then
                    begin
                        if features[78] <= 932.50000000000011 then
                        begin
                            Result := -0.0042882680597776598;
                        end
                        else
                        begin
                            Result := 0.0092134513652310339;
                        end;
                    end
                    else
                    begin
                        Result := 0.017789244685778343;
                    end;
                end
                else
                begin
                    if features[42] <= 3.5000000000000004 then
                    begin
                        if features[121] <= -12.499999999999998 then
                        begin
                            Result := -0.011610740121798789;
                        end
                        else
                        begin
                            Result := 0.015294002929966993;
                        end;
                    end
                    else
                    begin
                        Result := 0.021379138296741828;
                    end;
                end;
            end
            else
            begin
                if features[95] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.0028485627491037237;
                end
                else
                begin
                    Result := 0.019852979772564023;
                end;
            end;
        end;
    end
    else
    begin
        if features[54] <= 439.00000000000006 then
        begin
            if features[42] <= 2.5000000000000004 then
            begin
                Result := -0.016323387129916132;
            end
            else
            begin
                Result := 0.011686872881782877;
            end;
        end
        else
        begin
            if features[136] <= 2776.5000000000005 then
            begin
                if features[30] <= 8.5000000000000018 then
                begin
                    Result := -0.0028239396001731622;
                end
                else
                begin
                    Result := -0.032747470022057044;
                end;
            end
            else
            begin
                Result := 0.0014821894235723452;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_52(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[135] <= -852.99999999999989 then
    begin
        if features[23] <= 1.5000000000000002 then
        begin
            Result := -0.018484296075607691;
        end
        else
        begin
            Result := 0.0043185555378504482;
        end;
    end
    else
    begin
        if features[20] <= 4.5000000000000009 then
        begin
            if features[105] <= 246.50000000000003 then
            begin
                if features[21] <= 2.5000000000000004 then
                begin
                    if features[28] <= 1381.5000000000002 then
                    begin
                        if features[79] <= 496.00000000000006 then
                        begin
                            Result := 0.0070300093592336249;
                        end
                        else
                        begin
                            Result := -0.015993277971278707;
                        end;
                    end
                    else
                    begin
                        if features[76] <= 924.50000000000011 then
                        begin
                            Result := -0.017537606115721659;
                        end
                        else
                        begin
                            Result := 0.0051229381206598298;
                        end;
                    end;
                end
                else
                begin
                    if features[52] <= -5480.4999999999991 then
                    begin
                        Result := -0.0034868699925619949;
                    end
                    else
                    begin
                        Result := 0.018166389601173054;
                    end;
                end;
            end
            else
            begin
                Result := 0.0099213108653665606;
            end;
        end
        else
        begin
            if features[98] <= 337.50000000000006 then
            begin
                if features[20] <= 12.500000000000002 then
                begin
                    if features[19] <= 2480.5000000000005 then
                    begin
                        if features[83] <= 16375.000000000002 then
                        begin
                            Result := 0.017171806050184597;
                        end
                        else
                        begin
                            Result := -0.0059671660973528249;
                        end;
                    end
                    else
                    begin
                        if features[105] <= -80.499999999999986 then
                        begin
                            Result := 0.013849089790795828;
                        end
                        else
                        begin
                            Result := -0.012040456576721615;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.012840072348542635;
                end;
            end
            else
            begin
                Result := 0.016650543359227526;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_53(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 6.5000000000000009 then
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            if features[89] <= 800.50000000000011 then
            begin
                if features[140] <= 1.5000000000000002 then
                begin
                    Result := -0.010696737787591329;
                end
                else
                begin
                    Result := 0.0099134329679515104;
                end;
            end
            else
            begin
                Result := -0.017429659205133209;
            end;
        end
        else
        begin
            if features[96] <= 180.50000000000003 then
            begin
                if features[104] <= 1306.5000000000002 then
                begin
                    if features[138] <= 1.5000000000000002 then
                    begin
                        if features[66] <= 1.5000000000000002 then
                        begin
                            Result := 0.0018675440924516631;
                        end
                        else
                        begin
                            Result := -0.010320899898719729;
                        end;
                    end
                    else
                    begin
                        Result := 0.016749550154740674;
                    end;
                end
                else
                begin
                    Result := 0.021832709144900302;
                end;
            end
            else
            begin
                if features[132] <= 3.5000000000000004 then
                begin
                    if features[120] <= -1.0000000180025095E-35 then
                    begin
                        if features[73] <= 2695.5000000000005 then
                        begin
                            Result := -0.011467164429455915;
                        end
                        else
                        begin
                            Result := 0.0077468228295830086;
                        end;
                    end
                    else
                    begin
                        if features[124] <= 530.00000000000011 then
                        begin
                            Result := 0.015944385688702888;
                        end
                        else
                        begin
                            Result := -0.0097540326291657535;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0256913738296989;
                end;
            end;
        end;
    end
    else
    begin
        if features[127] <= -4.4999999999999991 then
        begin
            Result := -0.001438241311179264;
        end
        else
        begin
            if features[134] <= 1581.0000000000002 then
            begin
                Result := -0.027770078016049204;
            end
            else
            begin
                Result := 0.0055688230738772096;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_54(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 7.5000000000000009 then
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            if features[52] <= -6133.4999999999991 then
            begin
                if features[23] <= 1.0000000180025095E-35 then
                begin
                    if features[2] <= 16994.500000000004 then
                    begin
                        Result := 0.00030769969421098469;
                    end
                    else
                    begin
                        Result := -0.030148959008455208;
                    end;
                end
                else
                begin
                    Result := 0.0066387233221080443;
                end;
            end
            else
            begin
                if features[91] <= 4041.0000000000005 then
                begin
                    if features[85] <= 5672.0000000000009 then
                    begin
                        Result := 0.016594689832391301;
                    end
                    else
                    begin
                        Result := -0.010574266930173036;
                    end;
                end
                else
                begin
                    Result := -0.010614541357659915;
                end;
            end;
        end
        else
        begin
            if features[104] <= 1318.5000000000002 then
            begin
                if features[97] <= 134.50000000000003 then
                begin
                    if features[140] <= 2.5000000000000004 then
                    begin
                        Result := 0.0076973299485513609;
                    end
                    else
                    begin
                        if features[141] <= 2.5000000000000004 then
                        begin
                            Result := 0.0021877170565956076;
                        end
                        else
                        begin
                            Result := -0.012685796588592197;
                        end;
                    end;
                end
                else
                begin
                    if features[47] <= 105112.50000000001 then
                    begin
                        if features[80] <= 6.5000000000000009 then
                        begin
                            Result := -0.0025162039033011568;
                        end
                        else
                        begin
                            Result := 0.021019582513879781;
                        end;
                    end
                    else
                    begin
                        if features[54] <= 520.50000000000011 then
                        begin
                            Result := -0.010009601532119194;
                        end
                        else
                        begin
                            Result := 0.010948656411931336;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.021086510058819587;
            end;
        end;
    end
    else
    begin
        Result := -0.014139776054605206;
    end;
end;

function exact_edge_auditor_tree_55(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[133] <= -9171.9999999999982 then
        begin
            if features[23] <= 1.5000000000000002 then
            begin
                Result := -0.020071060804678208;
            end
            else
            begin
                Result := 0.011630667687508185;
            end;
        end
        else
        begin
            if features[104] <= 1318.5000000000002 then
            begin
                if features[97] <= 134.50000000000003 then
                begin
                    if features[20] <= 12.500000000000002 then
                    begin
                        if features[97] <= 16.500000000000004 then
                        begin
                            Result := -0.00074800725468919538;
                        end
                        else
                        begin
                            Result := -0.016866132769109723;
                        end;
                    end
                    else
                    begin
                        if features[15] <= 483.00000000000006 then
                        begin
                            Result := 0.016757663298775895;
                        end
                        else
                        begin
                            Result := -0.0050611332786241114;
                        end;
                    end;
                end
                else
                begin
                    if features[120] <= 3.5000000000000004 then
                    begin
                        if features[109] <= -5439.9999999999991 then
                        begin
                            Result := -0.0022984700035887863;
                        end
                        else
                        begin
                            Result := 0.016851899413291772;
                        end;
                    end
                    else
                    begin
                        Result := -0.017638061219312443;
                    end;
                end;
            end
            else
            begin
                if features[45] <= 3020.5000000000005 then
                begin
                    Result := -0.0044599373584648478;
                end
                else
                begin
                    Result := 0.023174171766528636;
                end;
            end;
        end;
    end
    else
    begin
        if features[54] <= 439.00000000000006 then
        begin
            if features[42] <= 2.5000000000000004 then
            begin
                Result := -0.015636948654875121;
            end
            else
            begin
                if features[91] <= 3032.0000000000005 then
                begin
                    Result := 0.018931984449960772;
                end
                else
                begin
                    Result := -0.0088222397583671668;
                end;
            end;
        end
        else
        begin
            Result := -0.022777127608565914;
        end;
    end;
end;

function exact_edge_auditor_tree_56(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 6.5000000000000009 then
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            if features[52] <= -6133.4999999999991 then
            begin
                if features[23] <= 1.0000000180025095E-35 then
                begin
                    if features[90] <= 4090.5000000000005 then
                    begin
                        Result := 0.00028609349964601132;
                    end
                    else
                    begin
                        Result := -0.029540576130936694;
                    end;
                end
                else
                begin
                    Result := 0.0064808307753870219;
                end;
            end
            else
            begin
                if features[36] <= 4.5000000000000009 then
                begin
                    Result := -0.010631534977786045;
                end
                else
                begin
                    Result := 0.0085126485512523106;
                end;
            end;
        end
        else
        begin
            if features[104] <= 1318.5000000000002 then
            begin
                if features[96] <= 180.50000000000003 then
                begin
                    if features[138] <= 1.5000000000000002 then
                    begin
                        if features[28] <= 2725.5000000000005 then
                        begin
                            Result := 0.00099406446016183422;
                        end
                        else
                        begin
                            Result := -0.01015684445250755;
                        end;
                    end
                    else
                    begin
                        Result := 0.016479730521444039;
                    end;
                end
                else
                begin
                    if features[132] <= 3.5000000000000004 then
                    begin
                        if features[120] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0060603692907899185;
                        end
                        else
                        begin
                            Result := 0.01182102437426525;
                        end;
                    end
                    else
                    begin
                        Result := 0.024663819279370055;
                    end;
                end;
            end
            else
            begin
                Result := 0.020070643102781508;
            end;
        end;
    end
    else
    begin
        if features[127] <= -4.4999999999999991 then
        begin
            Result := -0.00094454811539661958;
        end
        else
        begin
            if features[134] <= 1581.0000000000002 then
            begin
                Result := -0.026684501364146768;
            end
            else
            begin
                Result := 0.0057009520283059813;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_57(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[42] <= 1.0000000180025095E-35 then
    begin
        if features[98] <= -97.499999999999986 then
        begin
            Result := 0.0048905356642352906;
        end
        else
        begin
            if features[20] <= 20.500000000000004 then
            begin
                if features[79] <= 484.50000000000006 then
                begin
                    Result := -0.022751597282921136;
                end
                else
                begin
                    Result := -0.0024771643452694372;
                end;
            end
            else
            begin
                Result := 0.0097278168617029905;
            end;
        end;
    end
    else
    begin
        if features[20] <= 4.5000000000000009 then
        begin
            if features[58] <= 1084.5000000000002 then
            begin
                if features[88] <= 7414.0000000000009 then
                begin
                    Result := 0.0061827249010112254;
                end
                else
                begin
                    Result := -0.0060780726633944153;
                end;
            end
            else
            begin
                if features[51] <= -3457.9999999999995 then
                begin
                    if features[7] <= -6635.9999999999991 then
                    begin
                        Result := 0.0028350355227365386;
                    end
                    else
                    begin
                        if features[126] <= -1.4999999999999998 then
                        begin
                            Result := 0.0040247315839972734;
                        end
                        else
                        begin
                            Result := -0.025444053190065541;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0082567552693048867;
                end;
            end;
        end
        else
        begin
            if features[98] <= 450.50000000000006 then
            begin
                if features[85] <= 5674.5000000000009 then
                begin
                    if features[66] <= 2.5000000000000004 then
                    begin
                        Result := 0.0093861445817914318;
                    end
                    else
                    begin
                        if features[98] <= 101.00000000000001 then
                        begin
                            Result := -0.017003378456274136;
                        end
                        else
                        begin
                            Result := 0.010603623247847659;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.012862752322920928;
                end;
            end
            else
            begin
                Result := 0.01963539050629742;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_58(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[133] <= -9171.9999999999982 then
        begin
            if features[23] <= 1.5000000000000002 then
            begin
                Result := -0.019257498699031948;
            end
            else
            begin
                Result := 0.011458599466747892;
            end;
        end
        else
        begin
            if features[96] <= 732.50000000000011 then
            begin
                if features[20] <= 12.500000000000002 then
                begin
                    if features[104] <= 1318.5000000000002 then
                    begin
                        if features[120] <= -1.4999999999999998 then
                        begin
                            Result := -0.0085603886352870855;
                        end
                        else
                        begin
                            Result := 0.0021499831066132649;
                        end;
                    end
                    else
                    begin
                        Result := 0.01648428636645579;
                    end;
                end
                else
                begin
                    if features[42] <= 3.5000000000000004 then
                    begin
                        if features[121] <= -12.499999999999998 then
                        begin
                            Result := -0.01196005382022762;
                        end
                        else
                        begin
                            Result := 0.014728725454744669;
                        end;
                    end
                    else
                    begin
                        Result := 0.020349043214885273;
                    end;
                end;
            end
            else
            begin
                if features[58] <= 1060.5000000000002 then
                begin
                    Result := 0.018713095382805071;
                end
                else
                begin
                    Result := -0.0035832671704461392;
                end;
            end;
        end;
    end
    else
    begin
        if features[54] <= 439.00000000000006 then
        begin
            if features[42] <= 2.5000000000000004 then
            begin
                Result := -0.015002763412408204;
            end
            else
            begin
                if features[91] <= 3032.0000000000005 then
                begin
                    Result := 0.018522305251962457;
                end
                else
                begin
                    Result := -0.0086080820848932135;
                end;
            end;
        end
        else
        begin
            if features[136] <= 2934.5000000000005 then
            begin
                Result := -0.025645002609250275;
            end
            else
            begin
                Result := 0.0030758544404856088;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_59(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 6.5000000000000009 then
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            if features[89] <= 800.50000000000011 then
            begin
                if features[140] <= 1.5000000000000002 then
                begin
                    Result := -0.010285596224190275;
                end
                else
                begin
                    Result := 0.010049585755895426;
                end;
            end
            else
            begin
                Result := -0.016085972704922256;
            end;
        end
        else
        begin
            if features[96] <= 180.50000000000003 then
            begin
                if features[137] <= 2.5000000000000004 then
                begin
                    if features[102] <= 210.00000000000003 then
                    begin
                        if features[124] <= -58.999999999999993 then
                        begin
                            Result := -0.011007684284216805;
                        end
                        else
                        begin
                            Result := 0.0023967908764103841;
                        end;
                    end
                    else
                    begin
                        Result := 0.010988712663969507;
                    end;
                end
                else
                begin
                    Result := 0.015073607588841175;
                end;
            end
            else
            begin
                if features[132] <= 3.5000000000000004 then
                begin
                    if features[120] <= -1.0000000180025095E-35 then
                    begin
                        if features[73] <= 2695.5000000000005 then
                        begin
                            Result := -0.011451650815371235;
                        end
                        else
                        begin
                            Result := 0.0070733509267341867;
                        end;
                    end
                    else
                    begin
                        if features[132] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0070799755231037848;
                        end
                        else
                        begin
                            Result := 0.015519276426311143;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.024513663078728615;
                end;
            end;
        end;
    end
    else
    begin
        if features[96] <= -123.49999999999999 then
        begin
            Result := 0.0028828685750368309;
        end
        else
        begin
            if features[82] <= 10.500000000000002 then
            begin
                Result := -0.023350914831873255;
            end
            else
            begin
                Result := 0.00062598631078126436;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_60(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[96] <= 804.50000000000011 then
        begin
            if features[31] <= 722.50000000000011 then
            begin
                if features[109] <= -5439.9999999999991 then
                begin
                    if features[20] <= 11.500000000000002 then
                    begin
                        Result := -0.023654207872504579;
                    end
                    else
                    begin
                        Result := 0.0060822173677908091;
                    end;
                end
                else
                begin
                    if features[96] <= 103.50000000000001 then
                    begin
                        if features[66] <= 1.5000000000000002 then
                        begin
                            Result := 0.0066749601261351819;
                        end
                        else
                        begin
                            Result := -0.014042218416430779;
                        end;
                    end
                    else
                    begin
                        if features[41] <= 5665.0000000000009 then
                        begin
                            Result := 0.016317762005274114;
                        end
                        else
                        begin
                            Result := -0.01165014508826606;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[2] <= 22123.000000000004 then
                begin
                    Result := 0.016669980085366541;
                end
                else
                begin
                    if features[92] <= 59467.000000000007 then
                    begin
                        if features[120] <= -2.4999999999999996 then
                        begin
                            Result := -0.0036632954408615057;
                        end
                        else
                        begin
                            Result := 0.0070475113543788954;
                        end;
                    end
                    else
                    begin
                        Result := -0.014005751790805624;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.014323126277220969;
        end;
    end
    else
    begin
        if features[54] <= 439.00000000000006 then
        begin
            if features[42] <= 2.5000000000000004 then
            begin
                Result := -0.014624061599722923;
            end
            else
            begin
                if features[91] <= 3032.0000000000005 then
                begin
                    Result := 0.018181749223932626;
                end
                else
                begin
                    Result := -0.0084704163091341798;
                end;
            end;
        end
        else
        begin
            Result := -0.021403218749449466;
        end;
    end;
end;

function exact_edge_auditor_tree_61(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 6.5000000000000009 then
    begin
        if features[134] <= 1.0000000180025095E-35 then
        begin
            if features[13] <= 1303.5000000000002 then
            begin
                if features[128] <= 40750.000000000007 then
                begin
                    if features[66] <= 1.5000000000000002 then
                    begin
                        Result := 0.0094976922280014791;
                    end
                    else
                    begin
                        Result := -0.0023651085602830087;
                    end;
                end
                else
                begin
                    if features[100] <= -1.0000000180025095E-35 then
                    begin
                        Result := 0.0075994049122568861;
                    end
                    else
                    begin
                        Result := -0.019301665958551102;
                    end;
                end;
            end
            else
            begin
                if features[60] <= 585.50000000000011 then
                begin
                    Result := -0.018344652167798348;
                end
                else
                begin
                    Result := 0.0070211852661700045;
                end;
            end;
        end
        else
        begin
            if features[37] <= 13.500000000000002 then
            begin
                if features[134] <= 2882.5000000000005 then
                begin
                    if features[80] <= 9.5000000000000018 then
                    begin
                        if features[91] <= 2670.0000000000005 then
                        begin
                            Result := 0.020558540688089436;
                        end
                        else
                        begin
                            Result := -0.0035473373957861957;
                        end;
                    end
                    else
                    begin
                        if features[136] <= 421.50000000000006 then
                        begin
                            Result := 0.015486839598729204;
                        end
                        else
                        begin
                            Result := -0.013441048954975937;
                        end;
                    end;
                end
                else
                begin
                    if features[36] <= 5.5000000000000009 then
                    begin
                        if features[141] <= 4.5000000000000009 then
                        begin
                            Result := -0.019854577597078416;
                        end
                        else
                        begin
                            Result := 0.0050708678858955789;
                        end;
                    end
                    else
                    begin
                        Result := 0.0091066469938794956;
                    end;
                end;
            end
            else
            begin
                Result := 0.023077790750062901;
            end;
        end;
    end
    else
    begin
        Result := -0.012313936511869589;
    end;
end;

function exact_edge_auditor_tree_62(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[135] <= -852.99999999999989 then
    begin
        Result := -0.012351743534025411;
    end
    else
    begin
        if features[110] <= 3.5000000000000004 then
        begin
            if features[52] <= -6330.4999999999991 then
            begin
                if features[88] <= 12078.000000000002 then
                begin
                    if features[105] <= 172.50000000000003 then
                    begin
                        if features[90] <= 5395.0000000000009 then
                        begin
                            Result := -0.011951706724038818;
                        end
                        else
                        begin
                            Result := 0.007757069176793337;
                        end;
                    end
                    else
                    begin
                        Result := 0.016314981728767212;
                    end;
                end
                else
                begin
                    Result := -0.021592756782500031;
                end;
            end
            else
            begin
                if features[28] <= 2797.5000000000005 then
                begin
                    if features[58] <= 1225.5000000000002 then
                    begin
                        Result := 0.013694422828997896;
                    end
                    else
                    begin
                        Result := -0.0047110902951850442;
                    end;
                end
                else
                begin
                    if features[124] <= 69.000000000000014 then
                    begin
                        if features[96] <= 135.50000000000003 then
                        begin
                            Result := -0.0071580493727899132;
                        end
                        else
                        begin
                            Result := 0.01288846419109899;
                        end;
                    end
                    else
                    begin
                        Result := -0.02144161296971293;
                    end;
                end;
            end;
        end
        else
        begin
            if features[51] <= -5416.9999999999991 then
            begin
                if features[66] <= 1.5000000000000002 then
                begin
                    Result := 0.02087004618539727;
                end
                else
                begin
                    if features[51] <= -5970.4999999999991 then
                    begin
                        Result := -0.011110407070932806;
                    end
                    else
                    begin
                        Result := 0.016155255496190721;
                    end;
                end;
            end
            else
            begin
                if features[135] <= 4178.5000000000009 then
                begin
                    Result := -0.0038381137183079294;
                end
                else
                begin
                    Result := 0.012011208886465006;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_63(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[45] <= 2520.0000000000005 then
    begin
        if features[77] <= 2.5000000000000004 then
        begin
            Result := 0.0027436201019522795;
        end
        else
        begin
            if features[6] <= -5025.9999999999991 then
            begin
                if features[60] <= 173.50000000000003 then
                begin
                    Result := -0.014490899416522299;
                end
                else
                begin
                    Result := 0.0074164537241613185;
                end;
            end
            else
            begin
                Result := -0.021807072121142294;
            end;
        end;
    end
    else
    begin
        if features[20] <= 12.500000000000002 then
        begin
            if features[13] <= 1191.0000000000002 then
            begin
                if features[50] <= 2.5000000000000004 then
                begin
                    if features[34] <= 668.50000000000011 then
                    begin
                        Result := 0.010797731418631088;
                    end
                    else
                    begin
                        Result := -0.012715818832111652;
                    end;
                end
                else
                begin
                    if features[121] <= 56.500000000000007 then
                    begin
                        if features[105] <= 172.50000000000003 then
                        begin
                            Result := -0.011784396631541599;
                        end
                        else
                        begin
                            Result := 0.0072454044824330141;
                        end;
                    end
                    else
                    begin
                        Result := 0.017416905309293355;
                    end;
                end;
            end
            else
            begin
                if features[7] <= -5894.4999999999991 then
                begin
                    if features[41] <= 5648.0000000000009 then
                    begin
                        Result := -0.021894140574068816;
                    end
                    else
                    begin
                        Result := 0.0035285761958553973;
                    end;
                end
                else
                begin
                    if features[46] <= 2938.0000000000005 then
                    begin
                        Result := 0.01681265727420125;
                    end
                    else
                    begin
                        if features[15] <= 483.00000000000006 then
                        begin
                            Result := -0.015854696574581953;
                        end
                        else
                        begin
                            Result := 0.0065439434765649038;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.01596706447484765;
        end;
    end;
end;

function exact_edge_auditor_tree_64(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[133] <= -9171.9999999999982 then
        begin
            if features[23] <= 1.5000000000000002 then
            begin
                Result := -0.018268885805482311;
            end
            else
            begin
                Result := 0.011502993909396832;
            end;
        end
        else
        begin
            if features[16] <= 173.50000000000003 then
            begin
                if features[124] <= -35.999999999999993 then
                begin
                    if features[43] <= 4747.0000000000009 then
                    begin
                        if features[24] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.012330381663128935;
                        end
                        else
                        begin
                            Result := -0.014150654761347973;
                        end;
                    end
                    else
                    begin
                        if features[97] <= 732.00000000000011 then
                        begin
                            Result := -0.019332777711799181;
                        end
                        else
                        begin
                            Result := 0.0068850836350481497;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0070620626962704797;
                end;
            end
            else
            begin
                if features[103] <= 1483.5000000000002 then
                begin
                    if features[58] <= 1060.5000000000002 then
                    begin
                        if features[130] <= 5701.0000000000009 then
                        begin
                            Result := 0.011564544727419464;
                        end
                        else
                        begin
                            Result := -0.011137850343082257;
                        end;
                    end
                    else
                    begin
                        if features[20] <= 6.5000000000000009 then
                        begin
                            Result := -0.0064353160135253761;
                        end
                        else
                        begin
                            Result := 0.0093520868353287132;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.014267250858132192;
                end;
            end;
        end;
    end
    else
    begin
        if features[54] <= 439.00000000000006 then
        begin
            if features[45] <= 2520.0000000000005 then
            begin
                Result := -0.01398746350316896;
            end
            else
            begin
                Result := 0.0099520870648580964;
            end;
        end
        else
        begin
            Result := -0.020555680076714607;
        end;
    end;
end;

function exact_edge_auditor_tree_65(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 6.5000000000000009 then
    begin
        if features[133] <= -2272.4999999999995 then
        begin
            if features[52] <= -6133.4999999999991 then
            begin
                if features[113] <= 1.0000000180025095E-35 then
                begin
                    if features[2] <= 16994.500000000004 then
                    begin
                        Result := 0.00051522697994228479;
                    end
                    else
                    begin
                        Result := -0.028112412475297464;
                    end;
                end
                else
                begin
                    Result := 0.0067105330028031721;
                end;
            end
            else
            begin
                Result := 0.0032948647326609469;
            end;
        end
        else
        begin
            if features[14] <= 1330.5000000000002 then
            begin
                if features[120] <= -2.4999999999999996 then
                begin
                    if features[132] <= 3.5000000000000004 then
                    begin
                        if features[43] <= 5087.5000000000009 then
                        begin
                            Result := 0.00039605331087751405;
                        end
                        else
                        begin
                            Result := -0.016905858307344163;
                        end;
                    end
                    else
                    begin
                        Result := 0.011942444557704853;
                    end;
                end
                else
                begin
                    if features[130] <= 5710.0000000000009 then
                    begin
                        if features[13] <= 1075.5000000000002 then
                        begin
                            Result := 0.00994451006326472;
                        end
                        else
                        begin
                            Result := -0.0022586284748559002;
                        end;
                    end
                    else
                    begin
                        Result := -0.016075113220238451;
                    end;
                end;
            end
            else
            begin
                if features[79] <= 1.0000000180025095E-35 then
                begin
                    if features[97] <= 101.00000000000001 then
                    begin
                        Result := -0.014483307306519744;
                    end
                    else
                    begin
                        Result := 0.012684359523829411;
                    end;
                end
                else
                begin
                    if features[136] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0058458139383865595;
                    end
                    else
                    begin
                        Result := 0.022018847738321565;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.011707704323926099;
    end;
end;

function exact_edge_auditor_tree_66(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[45] <= 2520.0000000000005 then
    begin
        Result := -0.0074855965056538727;
    end
    else
    begin
        if features[20] <= 12.500000000000002 then
        begin
            if features[13] <= 1191.0000000000002 then
            begin
                if features[141] <= 3.5000000000000004 then
                begin
                    if features[21] <= 10.500000000000002 then
                    begin
                        if features[90] <= 5686.5000000000009 then
                        begin
                            Result := 0.015223070696194514;
                        end
                        else
                        begin
                            Result := -0.0032140388928053984;
                        end;
                    end
                    else
                    begin
                        Result := -0.015111738038160613;
                    end;
                end
                else
                begin
                    if features[140] <= 3.5000000000000004 then
                    begin
                        if features[108] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0090166686543452675;
                        end
                        else
                        begin
                            Result := 0.0074841694901974709;
                        end;
                    end
                    else
                    begin
                        if features[96] <= 180.50000000000003 then
                        begin
                            Result := -0.021051089028109208;
                        end
                        else
                        begin
                            Result := 0.0062801995818560011;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[8] <= -5894.4999999999991 then
                begin
                    if features[134] <= 1581.0000000000002 then
                    begin
                        if features[51] <= -6219.4999999999991 then
                        begin
                            Result := 0.0049587411114050241;
                        end
                        else
                        begin
                            Result := -0.027408389175987619;
                        end;
                    end
                    else
                    begin
                        Result := 0.001614951308871532;
                    end;
                end
                else
                begin
                    if features[51] <= -4674.4999999999991 then
                    begin
                        Result := 0.015937574311246816;
                    end
                    else
                    begin
                        if features[15] <= 483.00000000000006 then
                        begin
                            Result := -0.014484244576947782;
                        end
                        else
                        begin
                            Result := 0.0063706342347583274;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.015403626507724637;
        end;
    end;
end;

function exact_edge_auditor_tree_67(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[96] <= 804.50000000000011 then
        begin
            if features[31] <= 722.50000000000011 then
            begin
                if features[109] <= -5439.9999999999991 then
                begin
                    if features[51] <= -6360.4999999999991 then
                    begin
                        Result := 0.0057719877497003939;
                    end
                    else
                    begin
                        Result := -0.022966466794426516;
                    end;
                end
                else
                begin
                    if features[96] <= 103.50000000000001 then
                    begin
                        if features[31] <= 692.50000000000011 then
                        begin
                            Result := 0.00065475722573924919;
                        end
                        else
                        begin
                            Result := -0.020471989258937281;
                        end;
                    end
                    else
                    begin
                        if features[41] <= 5665.0000000000009 then
                        begin
                            Result := 0.015564547157167744;
                        end
                        else
                        begin
                            Result := -0.011578059211200774;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[32] <= 2.5000000000000004 then
                begin
                    Result := 0.013031865191344383;
                end
                else
                begin
                    if features[134] <= 1581.0000000000002 then
                    begin
                        if features[24] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.00039941393547058429;
                        end
                        else
                        begin
                            Result := -0.017990670771324772;
                        end;
                    end
                    else
                    begin
                        if features[110] <= 1.5000000000000002 then
                        begin
                            Result := -0.011838799592385624;
                        end
                        else
                        begin
                            Result := 0.020733122944337649;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.01365890376575031;
        end;
    end
    else
    begin
        if features[133] <= 713.00000000000011 then
        begin
            Result := -0.017709114124805313;
        end
        else
        begin
            if features[60] <= 303.50000000000006 then
            begin
                Result := 0.01394232843321452;
            end
            else
            begin
                Result := -0.0095653702309804831;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_68(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[66] <= 1.5000000000000002 then
    begin
        if features[14] <= 1246.5000000000002 then
        begin
            if features[130] <= -2809.9999999999995 then
            begin
                Result := -0.016298124698139384;
            end
            else
            begin
                if features[29] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.0041569093798387788;
                end
                else
                begin
                    if features[75] <= 16.500000000000004 then
                    begin
                        Result := -0.015313816325585818;
                    end
                    else
                    begin
                        Result := 0.0090871839569503978;
                    end;
                end;
            end;
        end
        else
        begin
            if features[117] <= 25.500000000000004 then
            begin
                Result := 0.016724331090370598;
            end
            else
            begin
                Result := -0.011900101501417563;
            end;
        end;
    end
    else
    begin
        if features[45] <= 2520.0000000000005 then
        begin
            if features[63] <= 6.5000000000000009 then
            begin
                Result := -0.017826389421007491;
            end
            else
            begin
                Result := 0.0086758646517462856;
            end;
        end
        else
        begin
            if features[54] <= 391.50000000000006 then
            begin
                if features[45] <= 5702.0000000000009 then
                begin
                    if features[132] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.012086046800708957;
                    end
                    else
                    begin
                        if features[133] <= 14524.500000000002 then
                        begin
                            Result := 0.017722246078934606;
                        end
                        else
                        begin
                            Result := -0.0053125787192914355;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.012769937510363826;
                end;
            end
            else
            begin
                if features[128] <= 12062.500000000002 then
                begin
                    if features[97] <= -278.49999999999994 then
                    begin
                        Result := 0.0052762621156235041;
                    end
                    else
                    begin
                        Result := -0.022378559732187647;
                    end;
                end
                else
                begin
                    Result := 0.0053449346201513643;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_69(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[110] <= 1.5000000000000002 then
        begin
            if features[28] <= 2572.5000000000005 then
            begin
                if features[97] <= -78.499999999999986 then
                begin
                    Result := 0.013954123691377855;
                end
                else
                begin
                    if features[65] <= 3.5000000000000004 then
                    begin
                        if features[90] <= 3879.0000000000005 then
                        begin
                            Result := -0.02343378747558374;
                        end
                        else
                        begin
                            Result := 0.0014547571776428398;
                        end;
                    end
                    else
                    begin
                        Result := 0.0082599544387016808;
                    end;
                end;
            end
            else
            begin
                if features[30] <= 1.5000000000000002 then
                begin
                    Result := 0.007018546763684832;
                end
                else
                begin
                    if features[136] <= 2934.5000000000005 then
                    begin
                        Result := -0.024887815600847709;
                    end
                    else
                    begin
                        Result := 0.0022880628019993814;
                    end;
                end;
            end;
        end
        else
        begin
            if features[79] <= 164.00000000000003 then
            begin
                if features[96] <= -102.49999999999999 then
                begin
                    if features[44] <= -199.99999999999997 then
                    begin
                        Result := -0.017947310783806989;
                    end
                    else
                    begin
                        Result := 0.011344811336894281;
                    end;
                end
                else
                begin
                    Result := 0.01716880381981872;
                end;
            end
            else
            begin
                if features[33] <= 722.50000000000011 then
                begin
                    if features[96] <= 860.50000000000011 then
                    begin
                        if features[51] <= -6448.4999999999991 then
                        begin
                            Result := 0.010966035359767716;
                        end
                        else
                        begin
                            Result := -0.018594452322085408;
                        end;
                    end
                    else
                    begin
                        Result := 0.014111743425359159;
                    end;
                end
                else
                begin
                    Result := 0.0060471627013153617;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.011747373165684803;
    end;
end;

function exact_edge_auditor_tree_70(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[135] <= -852.99999999999989 then
    begin
        Result := -0.010958654292748013;
    end
    else
    begin
        if features[110] <= 3.5000000000000004 then
        begin
            if features[52] <= -6330.4999999999991 then
            begin
                if features[51] <= -6519.4999999999991 then
                begin
                    if features[80] <= 10.500000000000002 then
                    begin
                        Result := 0.013881594037678597;
                    end
                    else
                    begin
                        Result := -0.011638070241136956;
                    end;
                end
                else
                begin
                    if features[99] <= 195.50000000000003 then
                    begin
                        Result := -0.013834908183843522;
                    end
                    else
                    begin
                        Result := 0.0079822884430645023;
                    end;
                end;
            end
            else
            begin
                if features[28] <= 2797.5000000000005 then
                begin
                    if features[46] <= 3297.5000000000005 then
                    begin
                        if features[133] <= 713.00000000000011 then
                        begin
                            Result := 0.021280445939725147;
                        end
                        else
                        begin
                            Result := -0.0021752582444736742;
                        end;
                    end
                    else
                    begin
                        if features[6] <= -4718.9999999999991 then
                        begin
                            Result := 0.017316182814647162;
                        end
                        else
                        begin
                            Result := -0.0092544829845795599;
                        end;
                    end;
                end
                else
                begin
                    if features[124] <= 69.000000000000014 then
                    begin
                        if features[96] <= 135.50000000000003 then
                        begin
                            Result := -0.0070654163018428603;
                        end
                        else
                        begin
                            Result := 0.012330226763346162;
                        end;
                    end
                    else
                    begin
                        Result := -0.019969779475166129;
                    end;
                end;
            end;
        end
        else
        begin
            if features[51] <= -5416.9999999999991 then
            begin
                Result := 0.013206056397181773;
            end
            else
            begin
                if features[135] <= 4178.5000000000009 then
                begin
                    Result := -0.0042401864335762504;
                end
                else
                begin
                    Result := 0.011154893626636601;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_71(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[66] <= 1.5000000000000002 then
    begin
        if features[14] <= 1246.5000000000002 then
        begin
            if features[51] <= -6166.4999999999991 then
            begin
                Result := 0.011541036914865552;
            end
            else
            begin
                if features[53] <= -6330.4999999999991 then
                begin
                    if features[37] <= 12.500000000000002 then
                    begin
                        Result := -0.017447431448275191;
                    end
                    else
                    begin
                        Result := 0.010901961668715501;
                    end;
                end
                else
                begin
                    if features[128] <= 24437.500000000004 then
                    begin
                        if features[120] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.012751526021091848;
                        end
                        else
                        begin
                            Result := -0.012382083694496582;
                        end;
                    end
                    else
                    begin
                        Result := -0.0077237722180048341;
                    end;
                end;
            end;
        end
        else
        begin
            if features[117] <= 25.500000000000004 then
            begin
                Result := 0.016280988878004599;
            end
            else
            begin
                Result := -0.011838958962123676;
            end;
        end;
    end
    else
    begin
        if features[141] <= 2.5000000000000004 then
        begin
            if features[42] <= 2.5000000000000004 then
            begin
                if features[20] <= 7.5000000000000009 then
                begin
                    Result := -0.017985328499326176;
                end
                else
                begin
                    Result := 0.011427023446706123;
                end;
            end
            else
            begin
                Result := 0.013327779236689378;
            end;
        end
        else
        begin
            if features[140] <= 3.5000000000000004 then
            begin
                if features[31] <= 838.50000000000011 then
                begin
                    Result := -0.010440338340926125;
                end
                else
                begin
                    Result := 0.011946895259259998;
                end;
            end
            else
            begin
                if features[96] <= 180.50000000000003 then
                begin
                    Result := -0.028964364223472927;
                end
                else
                begin
                    Result := 0.0057546741828497549;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_72(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 6.5000000000000009 then
    begin
        if features[97] <= 732.00000000000011 then
        begin
            if features[89] <= 1698.0000000000002 then
            begin
                if features[12] <= 534.00000000000011 then
                begin
                    if features[2] <= 16994.500000000004 then
                    begin
                        Result := 0.0038898546970004542;
                    end
                    else
                    begin
                        if features[31] <= 838.50000000000011 then
                        begin
                            Result := -0.018563399849650161;
                        end
                        else
                        begin
                            Result := 0.0052414987978019936;
                        end;
                    end;
                end
                else
                begin
                    if features[124] <= -646.49999999999989 then
                    begin
                        if features[81] <= 5.5000000000000009 then
                        begin
                            Result := -0.0036044269884796987;
                        end
                        else
                        begin
                            Result := 0.020881051556281102;
                        end;
                    end
                    else
                    begin
                        if features[123] <= -79.499999999999986 then
                        begin
                            Result := -0.0074757724779803405;
                        end
                        else
                        begin
                            Result := 0.0058875764813149153;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[46] <= 4386.5000000000009 then
                begin
                    if features[97] <= -480.99999999999994 then
                    begin
                        Result := 0.0082843364922826207;
                    end
                    else
                    begin
                        if features[105] <= -166.49999999999997 then
                        begin
                            Result := 0.003396307565498274;
                        end
                        else
                        begin
                            Result := -0.025567314799904269;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0099514449773884083;
                end;
            end;
        end
        else
        begin
            Result := 0.013825775949875019;
        end;
    end
    else
    begin
        if features[127] <= -4.4999999999999991 then
        begin
            Result := 0.00095071504929691625;
        end
        else
        begin
            if features[134] <= 1581.0000000000002 then
            begin
                Result := -0.023966047943973879;
            end
            else
            begin
                Result := 0.0057676964912146142;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_73(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[110] <= 1.5000000000000002 then
        begin
            if features[28] <= 2572.5000000000005 then
            begin
                if features[97] <= -78.499999999999986 then
                begin
                    Result := 0.013542811812237751;
                end
                else
                begin
                    if features[65] <= 3.5000000000000004 then
                    begin
                        if features[90] <= 3879.0000000000005 then
                        begin
                            Result := -0.022572166152893317;
                        end
                        else
                        begin
                            Result := 0.001594202735010374;
                        end;
                    end
                    else
                    begin
                        Result := 0.0081650649388173742;
                    end;
                end;
            end
            else
            begin
                if features[30] <= 1.5000000000000002 then
                begin
                    Result := 0.0068623006302454895;
                end
                else
                begin
                    Result := -0.018064258186163241;
                end;
            end;
        end
        else
        begin
            if features[79] <= 164.00000000000003 then
            begin
                if features[50] <= 2.5000000000000004 then
                begin
                    Result := 0.017859717861994615;
                end
                else
                begin
                    if features[2] <= 28717.000000000004 then
                    begin
                        Result := -0.015550151213298358;
                    end
                    else
                    begin
                        Result := 0.0084370917842788232;
                    end;
                end;
            end
            else
            begin
                if features[14] <= 1246.5000000000002 then
                begin
                    if features[89] <= 1153.0000000000002 then
                    begin
                        if features[79] <= 552.50000000000011 then
                        begin
                            Result := -0.0066153598964800607;
                        end
                        else
                        begin
                            Result := 0.0085172564530884304;
                        end;
                    end
                    else
                    begin
                        if features[32] <= 2.5000000000000004 then
                        begin
                            Result := 0.0057885024801750682;
                        end
                        else
                        begin
                            Result := -0.020930625566553215;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.012213052336988139;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.011255299787833876;
    end;
end;

function exact_edge_auditor_tree_74(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[133] <= -1235.4999999999998 then
    begin
        if features[89] <= 800.50000000000011 then
        begin
            if features[140] <= 1.5000000000000002 then
            begin
                Result := -0.012026189655244608;
            end
            else
            begin
                Result := 0.0087956979176055088;
            end;
        end
        else
        begin
            if features[76] <= 920.50000000000011 then
            begin
                Result := -0.018352000009341403;
            end
            else
            begin
                Result := 0.00030186106288371874;
            end;
        end;
    end
    else
    begin
        if features[96] <= 804.50000000000011 then
        begin
            if features[12] <= 1267.5000000000002 then
            begin
                if features[38] <= 18291.500000000004 then
                begin
                    Result := 0.0029212124050593392;
                end
                else
                begin
                    if features[141] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0074205250609090294;
                    end
                    else
                    begin
                        Result := -0.017989257862330146;
                    end;
                end;
            end
            else
            begin
                if features[38] <= 19583.500000000004 then
                begin
                    if features[12] <= 1405.5000000000002 then
                    begin
                        Result := 0.012769626389037617;
                    end
                    else
                    begin
                        if features[52] <= -6024.9999999999991 then
                        begin
                            Result := -0.017416888541085251;
                        end
                        else
                        begin
                            Result := 0.001929379492659812;
                        end;
                    end;
                end
                else
                begin
                    if features[64] <= 8133.0000000000009 then
                    begin
                        if features[2] <= 65646.000000000015 then
                        begin
                            Result := 0.016881170606263804;
                        end
                        else
                        begin
                            Result := -0.0085754537375244723;
                        end;
                    end
                    else
                    begin
                        if features[47] <= 154803.00000000003 then
                        begin
                            Result := -0.013488143143153409;
                        end
                        else
                        begin
                            Result := 0.013610630037541403;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.013876959094446159;
        end;
    end;
end;

function exact_edge_auditor_tree_75(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[120] <= -1.4999999999999998 then
        begin
            if features[132] <= 3.5000000000000004 then
            begin
                if features[124] <= -666.49999999999989 then
                begin
                    if features[133] <= 437.00000000000006 then
                    begin
                        Result := 0.011586921779193916;
                    end
                    else
                    begin
                        Result := -0.010339769087749379;
                    end;
                end
                else
                begin
                    Result := -0.01249473818033533;
                end;
            end
            else
            begin
                if features[2] <= 28717.000000000004 then
                begin
                    Result := -0.0076865582909946039;
                end
                else
                begin
                    Result := 0.020476298816331805;
                end;
            end;
        end
        else
        begin
            if features[66] <= 1.5000000000000002 then
            begin
                if features[89] <= 125.50000000000001 then
                begin
                    Result := 0.013936095504123346;
                end
                else
                begin
                    if features[92] <= -19173.999999999996 then
                    begin
                        Result := -0.015515041083798439;
                    end
                    else
                    begin
                        Result := 0.013328113287570881;
                    end;
                end;
            end
            else
            begin
                if features[6] <= -5716.4999999999991 then
                begin
                    Result := -0.013788913352769923;
                end
                else
                begin
                    if features[133] <= -1235.4999999999998 then
                    begin
                        Result := -0.0090453812957819422;
                    end
                    else
                    begin
                        if features[79] <= 466.00000000000006 then
                        begin
                            Result := 0.012460487914976386;
                        end
                        else
                        begin
                            Result := -0.014807149745413726;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[42] <= 2.5000000000000004 then
        begin
            Result := -0.020374822599096742;
        end
        else
        begin
            if features[60] <= 292.50000000000006 then
            begin
                Result := 0.012811725404496448;
            end
            else
            begin
                Result := -0.013252382406466253;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_76(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 6.5000000000000009 then
    begin
        if features[98] <= 732.00000000000011 then
        begin
            if features[89] <= 1698.0000000000002 then
            begin
                if features[12] <= 534.00000000000011 then
                begin
                    if features[19] <= 1589.5000000000002 then
                    begin
                        Result := 0.0073097065929414807;
                    end
                    else
                    begin
                        if features[31] <= 838.50000000000011 then
                        begin
                            Result := -0.014762936378550444;
                        end
                        else
                        begin
                            Result := 0.0052564277973752909;
                        end;
                    end;
                end
                else
                begin
                    if features[109] <= 2972.5000000000005 then
                    begin
                        if features[31] <= 722.50000000000011 then
                        begin
                            Result := -0.0015029735131918552;
                        end
                        else
                        begin
                            Result := 0.0091310391255402992;
                        end;
                    end
                    else
                    begin
                        if features[109] <= 7447.0000000000009 then
                        begin
                            Result := -0.018768856933271554;
                        end
                        else
                        begin
                            Result := 0.0031917296569662144;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[32] <= 5.5000000000000009 then
                begin
                    if features[53] <= -6087.4999999999991 then
                    begin
                        Result := -0.01235720206242129;
                    end
                    else
                    begin
                        Result := 0.011769109739579875;
                    end;
                end
                else
                begin
                    if features[82] <= 7.5000000000000009 then
                    begin
                        Result := -0.026606037857837939;
                    end
                    else
                    begin
                        Result := 0.0078304269723961165;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.013238865243820891;
        end;
    end
    else
    begin
        if features[127] <= -4.4999999999999991 then
        begin
            Result := 0.001044206762523376;
        end
        else
        begin
            if features[134] <= 1581.0000000000002 then
            begin
                Result := -0.023090494999934177;
            end
            else
            begin
                Result := 0.0056404868651540171;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_77(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 3.5000000000000004 then
    begin
        if features[52] <= -6370.9999999999991 then
        begin
            if features[88] <= 12078.000000000002 then
            begin
                if features[90] <= 5395.0000000000009 then
                begin
                    if features[105] <= 172.50000000000003 then
                    begin
                        Result := -0.012337915425760619;
                    end
                    else
                    begin
                        Result := 0.011080734174397904;
                    end;
                end
                else
                begin
                    Result := 0.0097666843008630839;
                end;
            end
            else
            begin
                Result := -0.021463918489079577;
            end;
        end
        else
        begin
            if features[21] <= 2.5000000000000004 then
            begin
                if features[73] <= 1443.0000000000002 then
                begin
                    Result := 0.0051802395225820346;
                end
                else
                begin
                    Result := -0.0090824349442652844;
                end;
            end
            else
            begin
                if features[128] <= 8875.0000000000018 then
                begin
                    Result := 0.025873547881141032;
                end
                else
                begin
                    if features[54] <= 576.50000000000011 then
                    begin
                        Result := -0.0079941084803099912;
                    end
                    else
                    begin
                        Result := 0.014813204862173976;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[45] <= 4897.0000000000009 then
        begin
            if features[6] <= -6011.9999999999991 then
            begin
                Result := 0.014202016758145773;
            end
            else
            begin
                if features[79] <= 631.50000000000011 then
                begin
                    if features[121] <= -7.4999999999999991 then
                    begin
                        Result := -0.021181664823925823;
                    end
                    else
                    begin
                        Result := 0.008739090854658094;
                    end;
                end
                else
                begin
                    Result := 0.0071543053746398501;
                end;
            end;
        end
        else
        begin
            if features[86] <= 5686.5000000000009 then
            begin
                Result := 0.011783845422578796;
            end
            else
            begin
                Result := -0.0087841970206130361;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_78(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[110] <= 1.5000000000000002 then
        begin
            if features[58] <= 1098.0000000000002 then
            begin
                if features[96] <= -68.499999999999986 then
                begin
                    if features[28] <= 2797.5000000000005 then
                    begin
                        Result := 0.015811948837868531;
                    end
                    else
                    begin
                        Result := -0.0086636225732042108;
                    end;
                end
                else
                begin
                    if features[52] <= -6167.4999999999991 then
                    begin
                        if features[128] <= 4062.5000000000005 then
                        begin
                            Result := -0.020523708822872782;
                        end
                        else
                        begin
                            Result := 0.0065693540590667909;
                        end;
                    end
                    else
                    begin
                        Result := 0.008200198056942401;
                    end;
                end;
            end
            else
            begin
                Result := -0.014338341386933689;
            end;
        end
        else
        begin
            if features[79] <= 164.00000000000003 then
            begin
                if features[96] <= -102.49999999999999 then
                begin
                    Result := -0.0039188131504584939;
                end
                else
                begin
                    if features[93] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.020114898764855588;
                    end
                    else
                    begin
                        Result := -0.0085009370403161272;
                    end;
                end;
            end
            else
            begin
                if features[14] <= 1246.5000000000002 then
                begin
                    if features[31] <= 722.50000000000011 then
                    begin
                        if features[97] <= 813.50000000000011 then
                        begin
                            Result := -0.016264863978970073;
                        end
                        else
                        begin
                            Result := 0.010184608132542123;
                        end;
                    end
                    else
                    begin
                        if features[92] <= -124428.99999999999 then
                        begin
                            Result := 0.014352291605404846;
                        end
                        else
                        begin
                            Result := -0.0025539446765278579;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.011704321525215618;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.010803028532449794;
    end;
end;

function exact_edge_auditor_tree_79(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[66] <= 1.5000000000000002 then
    begin
        if features[14] <= 1246.5000000000002 then
        begin
            if features[51] <= -6166.4999999999991 then
            begin
                Result := 0.011248176658385739;
            end
            else
            begin
                if features[52] <= -6330.4999999999991 then
                begin
                    if features[37] <= 12.500000000000002 then
                    begin
                        Result := -0.016610833415221238;
                    end
                    else
                    begin
                        Result := 0.010672340730720769;
                    end;
                end
                else
                begin
                    Result := 0.0016108160194139858;
                end;
            end;
        end
        else
        begin
            if features[117] <= 25.500000000000004 then
            begin
                Result := 0.015224770946882286;
            end
            else
            begin
                Result := -0.011875467105895305;
            end;
        end;
    end
    else
    begin
        if features[141] <= 2.5000000000000004 then
        begin
            if features[42] <= 2.5000000000000004 then
            begin
                if features[110] <= 4.5000000000000009 then
                begin
                    Result := -0.016181650633073232;
                end
                else
                begin
                    Result := 0.010376883533673475;
                end;
            end
            else
            begin
                Result := 0.01295154678378287;
            end;
        end
        else
        begin
            if features[140] <= 3.5000000000000004 then
            begin
                if features[31] <= 838.50000000000011 then
                begin
                    Result := -0.0099979748199999583;
                end
                else
                begin
                    if features[14] <= 1405.5000000000002 then
                    begin
                        Result := 0.018118054760873397;
                    end
                    else
                    begin
                        Result := -0.010134373302992709;
                    end;
                end;
            end
            else
            begin
                if features[96] <= 180.50000000000003 then
                begin
                    if features[30] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0057187337004838863;
                    end
                    else
                    begin
                        Result := -0.032945016387950561;
                    end;
                end
                else
                begin
                    Result := 0.0057046012676960495;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_80(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[133] <= -1235.4999999999998 then
    begin
        if features[91] <= 3931.5000000000005 then
        begin
            if features[2] <= 34756.000000000007 then
            begin
                Result := 0.0082774383982069516;
            end
            else
            begin
                Result := -0.0092387023205301507;
            end;
        end
        else
        begin
            Result := -0.016420753403525289;
        end;
    end
    else
    begin
        if features[37] <= 13.500000000000002 then
        begin
            if features[50] <= 2.5000000000000004 then
            begin
                if features[121] <= 50.500000000000007 then
                begin
                    if features[124] <= -185.99999999999997 then
                    begin
                        if features[2] <= 44484.500000000007 then
                        begin
                            Result := 0.0034179804183321547;
                        end
                        else
                        begin
                            Result := -0.018500794314382889;
                        end;
                    end
                    else
                    begin
                        if features[102] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0080279787574273846;
                        end
                        else
                        begin
                            Result := 0.017736778859765368;
                        end;
                    end;
                end
                else
                begin
                    if features[43] <= 4747.0000000000009 then
                    begin
                        Result := -0.01894822146893602;
                    end
                    else
                    begin
                        if features[140] <= 4.5000000000000009 then
                        begin
                            Result := 0.014870534900401166;
                        end
                        else
                        begin
                            Result := -0.011134558249169918;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[136] <= 733.50000000000011 then
                begin
                    if features[44] <= -56.999999999999993 then
                    begin
                        Result := 0.01260475060032735;
                    end
                    else
                    begin
                        Result := -0.0066700399878285108;
                    end;
                end
                else
                begin
                    Result := -0.014312191777453055;
                end;
            end;
        end
        else
        begin
            if features[35] <= 21.500000000000004 then
            begin
                Result := 0.016469354410182997;
            end
            else
            begin
                Result := -0.0089813308496052083;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_81(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[66] <= 1.5000000000000002 then
    begin
        if features[130] <= -2809.9999999999995 then
        begin
            if features[38] <= 125312.50000000001 then
            begin
                Result := -0.018843034930786449;
            end
            else
            begin
                Result := 0.0088989287719334932;
            end;
        end
        else
        begin
            if features[134] <= 2882.5000000000005 then
            begin
                Result := 0.00702611023688354;
            end
            else
            begin
                if features[6] <= -5453.4999999999991 then
                begin
                    Result := 0.01015383786138087;
                end
                else
                begin
                    Result := -0.014940542276622351;
                end;
            end;
        end;
    end
    else
    begin
        if features[141] <= 2.5000000000000004 then
        begin
            if features[58] <= 1378.5000000000002 then
            begin
                if features[121] <= 111.50000000000001 then
                begin
                    Result := 0.014033201838487729;
                end
                else
                begin
                    Result := -0.0089209025923363636;
                end;
            end
            else
            begin
                Result := -0.011572214194015138;
            end;
        end
        else
        begin
            if features[140] <= 3.5000000000000004 then
            begin
                if features[31] <= 838.50000000000011 then
                begin
                    if features[7] <= -5575.4999999999991 then
                    begin
                        Result := -0.015705115874067779;
                    end
                    else
                    begin
                        Result := 0.0056236585328906961;
                    end;
                end
                else
                begin
                    if features[14] <= 1405.5000000000002 then
                    begin
                        Result := 0.01762179112898795;
                    end
                    else
                    begin
                        Result := -0.0099414004262942546;
                    end;
                end;
            end
            else
            begin
                if features[96] <= 180.50000000000003 then
                begin
                    if features[30] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0055819059054641358;
                    end
                    else
                    begin
                        Result := -0.032132460201312066;
                    end;
                end
                else
                begin
                    Result := 0.0055612299431257398;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_82(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[134] <= 1.0000000180025095E-35 then
    begin
        if features[13] <= 1345.5000000000002 then
        begin
            if features[45] <= 4697.0000000000009 then
            begin
                if features[97] <= -133.49999999999997 then
                begin
                    if features[76] <= 725.50000000000011 then
                    begin
                        Result := -0.0068146994257597838;
                    end
                    else
                    begin
                        Result := 0.017198523266731498;
                    end;
                end
                else
                begin
                    Result := -0.012089931818111511;
                end;
            end
            else
            begin
                if features[77] <= 7.5000000000000009 then
                begin
                    if features[82] <= 10.500000000000002 then
                    begin
                        Result := 0.014795734103228679;
                    end
                    else
                    begin
                        Result := -0.009784703124875815;
                    end;
                end
                else
                begin
                    if features[75] <= 16.500000000000004 then
                    begin
                        if features[45] <= 5660.0000000000009 then
                        begin
                            Result := 0.0083893434463322737;
                        end
                        else
                        begin
                            Result := -0.012194963018445162;
                        end;
                    end
                    else
                    begin
                        Result := 0.013337372712030856;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.014481127544348556;
        end;
    end
    else
    begin
        if features[37] <= 13.500000000000002 then
        begin
            if features[134] <= 644.50000000000011 then
            begin
                Result := 0.013696296135309172;
            end
            else
            begin
                if features[3] <= 8.5000000000000018 then
                begin
                    if features[48] <= 5.5000000000000009 then
                    begin
                        if features[50] <= 2.5000000000000004 then
                        begin
                            Result := 0.0015948303027227609;
                        end
                        else
                        begin
                            Result := -0.016175619665097445;
                        end;
                    end
                    else
                    begin
                        Result := 0.0080113944449978422;
                    end;
                end
                else
                begin
                    Result := -0.021971805865192519;
                end;
            end;
        end
        else
        begin
            Result := 0.019915651288892316;
        end;
    end;
end;

function exact_edge_auditor_tree_83(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[85] <= 5657.0000000000009 then
        begin
            if features[97] <= 732.00000000000011 then
            begin
                if features[97] <= -480.99999999999994 then
                begin
                    if features[3] <= 4.5000000000000009 then
                    begin
                        if features[51] <= -4373.4999999999991 then
                        begin
                            Result := -0.01124997801536233;
                        end
                        else
                        begin
                            Result := 0.0083563580038531343;
                        end;
                    end
                    else
                    begin
                        Result := 0.019649828192686083;
                    end;
                end
                else
                begin
                    if features[89] <= 1431.0000000000002 then
                    begin
                        if features[96] <= -319.49999999999994 then
                        begin
                            Result := -0.016750198588264931;
                        end
                        else
                        begin
                            Result := 0.0008800443099888128;
                        end;
                    end
                    else
                    begin
                        if features[65] <= 3.5000000000000004 then
                        begin
                            Result := -0.017048526922190808;
                        end
                        else
                        begin
                            Result := 0.004383375118941206;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[95] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.0056595100397827097;
                end
                else
                begin
                    if features[105] <= -64.499999999999986 then
                    begin
                        Result := -0.0045929154451319169;
                    end
                    else
                    begin
                        Result := 0.019534135320205554;
                    end;
                end;
            end;
        end
        else
        begin
            if features[57] <= 1384.5000000000002 then
            begin
                if features[85] <= 5660.0000000000009 then
                begin
                    Result := 0.010462877635232572;
                end
                else
                begin
                    Result := -0.0093582084969633314;
                end;
            end
            else
            begin
                Result := 0.019280582373584054;
            end;
        end;
    end
    else
    begin
        if features[133] <= 1907.0000000000002 then
        begin
            Result := -0.013458050195181401;
        end
        else
        begin
            Result := 0.0058846253226481878;
        end;
    end;
end;

function exact_edge_auditor_tree_84(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[92] <= 59467.000000000007 then
    begin
        if features[133] <= 17639.500000000004 then
        begin
            if features[77] <= 2.5000000000000004 then
            begin
                if features[31] <= 774.00000000000011 then
                begin
                    if features[47] <= 37848.500000000007 then
                    begin
                        if features[100] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.014571611253261082;
                        end
                        else
                        begin
                            Result := -0.011070645440913952;
                        end;
                    end
                    else
                    begin
                        Result := -0.0084196248059616348;
                    end;
                end
                else
                begin
                    if features[64] <= 3931.0000000000005 then
                    begin
                        Result := -0.0036457186551106832;
                    end
                    else
                    begin
                        if features[134] <= -1.0000000180025095E-35 then
                        begin
                            Result := -3.1430089904814153E-05;
                        end
                        else
                        begin
                            Result := 0.021891960514049021;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[97] <= 563.00000000000011 then
                begin
                    if features[59] <= 1192.5000000000002 then
                    begin
                        if features[96] <= 23.000000000000004 then
                        begin
                            Result := -0.0012213676469483511;
                        end
                        else
                        begin
                            Result := -0.014326741985900801;
                        end;
                    end
                    else
                    begin
                        if features[61] <= 303.50000000000006 then
                        begin
                            Result := -0.010656238284013526;
                        end
                        else
                        begin
                            Result := 0.012578829175416587;
                        end;
                    end;
                end
                else
                begin
                    if features[45] <= 1352.0000000000002 then
                    begin
                        Result := -0.012094609586131778;
                    end
                    else
                    begin
                        Result := 0.017040774563054549;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.013745453505725643;
        end;
    end
    else
    begin
        if features[81] <= 7.5000000000000009 then
        begin
            Result := -0.0020175844316763351;
        end
        else
        begin
            Result := -0.01974410450903279;
        end;
    end;
end;

function exact_edge_auditor_tree_85(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[66] <= 1.5000000000000002 then
    begin
        if features[14] <= 1246.5000000000002 then
        begin
            if features[13] <= 1468.5000000000002 then
            begin
                if features[32] <= 2.5000000000000004 then
                begin
                    Result := 0.008336731444359459;
                end
                else
                begin
                    if features[133] <= 8762.0000000000018 then
                    begin
                        Result := -0.0068562843702320913;
                    end
                    else
                    begin
                        Result := 0.0088817414837045403;
                    end;
                end;
            end
            else
            begin
                Result := -0.01322091709594393;
            end;
        end
        else
        begin
            if features[117] <= 25.500000000000004 then
            begin
                Result := 0.014617285543147542;
            end
            else
            begin
                Result := -0.011670590716065393;
            end;
        end;
    end
    else
    begin
        if features[141] <= 2.5000000000000004 then
        begin
            if features[42] <= 2.5000000000000004 then
            begin
                if features[20] <= 7.5000000000000009 then
                begin
                    Result := -0.016561847088144614;
                end
                else
                begin
                    Result := 0.010925808887390968;
                end;
            end
            else
            begin
                if features[90] <= 5702.0000000000009 then
                begin
                    Result := 0.016135047146490267;
                end
                else
                begin
                    Result := -0.010186590597636401;
                end;
            end;
        end
        else
        begin
            if features[140] <= 3.5000000000000004 then
            begin
                if features[31] <= 838.50000000000011 then
                begin
                    Result := -0.0094760815230436422;
                end
                else
                begin
                    if features[14] <= 1405.5000000000002 then
                    begin
                        Result := 0.017210556445411303;
                    end
                    else
                    begin
                        Result := -0.0097945202296792367;
                    end;
                end;
            end
            else
            begin
                if features[96] <= 180.50000000000003 then
                begin
                    Result := -0.026353185893943656;
                end
                else
                begin
                    Result := 0.005566785775509093;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_86(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[120] <= -1.4999999999999998 then
        begin
            if features[132] <= 3.5000000000000004 then
            begin
                if features[54] <= 646.50000000000011 then
                begin
                    if features[105] <= 218.50000000000003 then
                    begin
                        if features[51] <= -6448.4999999999991 then
                        begin
                            Result := 0.0059064561490232556;
                        end
                        else
                        begin
                            Result := -0.01814027564311621;
                        end;
                    end
                    else
                    begin
                        if features[51] <= -4870.9999999999991 then
                        begin
                            Result := 0.014211252438608055;
                        end
                        else
                        begin
                            Result := -0.0080978819855026148;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0068257938159657899;
                end;
            end
            else
            begin
                if features[2] <= 28717.000000000004 then
                begin
                    Result := -0.0076606247880756616;
                end
                else
                begin
                    Result := 0.019524471735964152;
                end;
            end;
        end
        else
        begin
            if features[99] <= 63.000000000000007 then
            begin
                if features[136] <= 1993.0000000000002 then
                begin
                    Result := 0.0059303243382353215;
                end
                else
                begin
                    if features[46] <= 2996.5000000000005 then
                    begin
                        Result := -0.022604198540256332;
                    end
                    else
                    begin
                        Result := 0.0012130062736948001;
                    end;
                end;
            end
            else
            begin
                if features[126] <= -1.4999999999999998 then
                begin
                    Result := -0.011251445099081433;
                end
                else
                begin
                    Result := 0.017051843745975407;
                end;
            end;
        end;
    end
    else
    begin
        if features[42] <= 2.5000000000000004 then
        begin
            Result := -0.019077816837801295;
        end
        else
        begin
            if features[60] <= 292.50000000000006 then
            begin
                Result := 0.01201203020242826;
            end
            else
            begin
                Result := -0.012409491282856752;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_87(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 3.5000000000000004 then
    begin
        if features[52] <= -6370.9999999999991 then
        begin
            Result := -0.0078538854889734465;
        end
        else
        begin
            if features[21] <= 2.5000000000000004 then
            begin
                if features[58] <= 1225.5000000000002 then
                begin
                    if features[141] <= 11.500000000000002 then
                    begin
                        if features[8] <= -5240.4999999999991 then
                        begin
                            Result := 0.010356072934624967;
                        end
                        else
                        begin
                            Result := -0.0070683151557603442;
                        end;
                    end
                    else
                    begin
                        Result := -0.016183666873485953;
                    end;
                end
                else
                begin
                    Result := -0.013294896871630792;
                end;
            end
            else
            begin
                if features[128] <= 8875.0000000000018 then
                begin
                    Result := 0.025302391550074382;
                end
                else
                begin
                    if features[54] <= 576.50000000000011 then
                    begin
                        Result := -0.0077262214182404441;
                    end
                    else
                    begin
                        Result := 0.01422672381695967;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[44] <= -753.99999999999989 then
        begin
            if features[79] <= 484.50000000000006 then
            begin
                Result := 0.0027687342265602407;
            end
            else
            begin
                Result := 0.021525305582282328;
            end;
        end
        else
        begin
            if features[120] <= -5.4999999999999991 then
            begin
                if features[118] <= 1173.0000000000002 then
                begin
                    if features[54] <= 646.50000000000011 then
                    begin
                        Result := -0.024456888270940252;
                    end
                    else
                    begin
                        Result := 0.0060609953381098548;
                    end;
                end
                else
                begin
                    Result := 0.0065183697730382233;
                end;
            end
            else
            begin
                if features[123] <= -18.499999999999996 then
                begin
                    Result := 0.0012423909715774068;
                end
                else
                begin
                    Result := 0.01533695295142057;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_88(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[92] <= 59467.000000000007 then
    begin
        if features[133] <= 17639.500000000004 then
        begin
            if features[32] <= 2.5000000000000004 then
            begin
                if features[95] <= -1.0000000180025095E-35 then
                begin
                    if features[52] <= -6370.9999999999991 then
                    begin
                        Result := -0.020978356039409306;
                    end
                    else
                    begin
                        Result := 0.005491489311472606;
                    end;
                end
                else
                begin
                    if features[134] <= -524.99999999999989 then
                    begin
                        if features[20] <= 4.5000000000000009 then
                        begin
                            Result := -0.011489568005361623;
                        end
                        else
                        begin
                            Result := 0.0086153813527236629;
                        end;
                    end
                    else
                    begin
                        if features[31] <= 740.50000000000011 then
                        begin
                            Result := 0.0024217678236901348;
                        end
                        else
                        begin
                            Result := 0.018415308967491963;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[20] <= 11.500000000000002 then
                begin
                    if features[97] <= 563.00000000000011 then
                    begin
                        if features[38] <= 18291.500000000004 then
                        begin
                            Result := 4.4532911738436525E-05;
                        end
                        else
                        begin
                            Result := -0.013701510687550099;
                        end;
                    end
                    else
                    begin
                        Result := 0.01024245118634764;
                    end;
                end
                else
                begin
                    if features[38] <= 53687.500000000007 then
                    begin
                        if features[30] <= 2.5000000000000004 then
                        begin
                            Result := -0.014036616222783307;
                        end
                        else
                        begin
                            Result := 0.0067608263438889097;
                        end;
                    end
                    else
                    begin
                        Result := 0.014711569440625934;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.013229942430609189;
        end;
    end
    else
    begin
        if features[81] <= 7.5000000000000009 then
        begin
            Result := -0.0019865786101855593;
        end
        else
        begin
            Result := -0.019217057831052223;
        end;
    end;
end;

function exact_edge_auditor_tree_89(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[66] <= 1.5000000000000002 then
    begin
        if features[130] <= -2809.9999999999995 then
        begin
            Result := -0.011932611828370628;
        end
        else
        begin
            if features[134] <= 2882.5000000000005 then
            begin
                if features[2] <= 139906.50000000003 then
                begin
                    if features[59] <= 1192.5000000000002 then
                    begin
                        if features[89] <= 125.50000000000001 then
                        begin
                            Result := 0.0090756050617879763;
                        end
                        else
                        begin
                            Result := -0.0032791709683115994;
                        end;
                    end
                    else
                    begin
                        Result := 0.017522960298313142;
                    end;
                end
                else
                begin
                    Result := -0.0091782559279380733;
                end;
            end
            else
            begin
                if features[0] <= 10.500000000000002 then
                begin
                    Result := -0.014244576611082317;
                end
                else
                begin
                    Result := 0.01024598389690197;
                end;
            end;
        end;
    end
    else
    begin
        if features[141] <= 2.5000000000000004 then
        begin
            if features[0] <= 6.5000000000000009 then
            begin
                Result := -0.012346036514424848;
            end
            else
            begin
                Result := 0.0090640824318386163;
            end;
        end
        else
        begin
            if features[140] <= 3.5000000000000004 then
            begin
                if features[31] <= 838.50000000000011 then
                begin
                    Result := -0.0092342665226211925;
                end
                else
                begin
                    if features[14] <= 1405.5000000000002 then
                    begin
                        Result := 0.016723231216506953;
                    end
                    else
                    begin
                        Result := -0.0095937560239510999;
                    end;
                end;
            end
            else
            begin
                if features[96] <= 180.50000000000003 then
                begin
                    if features[30] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0055858517671308573;
                    end
                    else
                    begin
                        Result := -0.03046142261416606;
                    end;
                end
                else
                begin
                    Result := 0.0053596119078871268;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_90(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[96] <= 804.50000000000011 then
        begin
            if features[31] <= 722.50000000000011 then
            begin
                if features[109] <= -3644.9999999999995 then
                begin
                    if features[51] <= -6448.4999999999991 then
                    begin
                        Result := 0.011870628534991509;
                    end
                    else
                    begin
                        if features[28] <= 1561.5000000000002 then
                        begin
                            Result := -0.026849067986986379;
                        end
                        else
                        begin
                            Result := 0.005064977475371212;
                        end;
                    end;
                end
                else
                begin
                    if features[96] <= 103.50000000000001 then
                    begin
                        if features[31] <= 692.50000000000011 then
                        begin
                            Result := 0.001869644062773525;
                        end
                        else
                        begin
                            Result := -0.021995343894916863;
                        end;
                    end
                    else
                    begin
                        if features[41] <= 5665.0000000000009 then
                        begin
                            Result := 0.015151297717254814;
                        end
                        else
                        begin
                            Result := -0.0086183765575415568;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[2] <= 22123.000000000004 then
                begin
                    Result := 0.015229290024087074;
                end
                else
                begin
                    if features[92] <= 59467.000000000007 then
                    begin
                        if features[34] <= 344.50000000000006 then
                        begin
                            Result := -0.00036422469952507601;
                        end
                        else
                        begin
                            Result := 0.015782177699222542;
                        end;
                    end
                    else
                    begin
                        Result := -0.011900954582883403;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.01188748555477228;
        end;
    end
    else
    begin
        if features[42] <= 2.5000000000000004 then
        begin
            Result := -0.018633909149661388;
        end
        else
        begin
            if features[60] <= 292.50000000000006 then
            begin
                Result := 0.011621581733538805;
            end
            else
            begin
                Result := -0.012032335037676326;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_91(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 6.5000000000000009 then
    begin
        if features[97] <= 732.00000000000011 then
        begin
            if features[133] <= -1235.4999999999998 then
            begin
                if features[52] <= -6087.4999999999991 then
                begin
                    if features[23] <= 1.0000000180025095E-35 then
                    begin
                        if features[19] <= 2189.0000000000005 then
                        begin
                            Result := 6.6002444904249695E-05;
                        end
                        else
                        begin
                            Result := -0.02499999165134207;
                        end;
                    end
                    else
                    begin
                        Result := 0.0073586400375612333;
                    end;
                end
                else
                begin
                    if features[7] <= -5288.9999999999991 then
                    begin
                        Result := 0.0115736899018301;
                    end
                    else
                    begin
                        if features[19] <= 4106.0000000000009 then
                        begin
                            Result := 0.0051803719051872772;
                        end
                        else
                        begin
                            Result := -0.018994507151901978;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[37] <= 13.500000000000002 then
                begin
                    if features[120] <= -1.4999999999999998 then
                    begin
                        if features[54] <= 646.50000000000011 then
                        begin
                            Result := -0.010554245216063518;
                        end
                        else
                        begin
                            Result := 0.011761427730145213;
                        end;
                    end
                    else
                    begin
                        if features[141] <= 9.5000000000000018 then
                        begin
                            Result := 0.0056070012306628798;
                        end
                        else
                        begin
                            Result := -0.016455097449321603;
                        end;
                    end;
                end
                else
                begin
                    if features[0] <= 26.500000000000004 then
                    begin
                        Result := 0.016253434463917221;
                    end
                    else
                    begin
                        Result := -0.010270113515818653;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.012143037273278579;
        end;
    end
    else
    begin
        if features[110] <= -2.4999999999999996 then
        begin
            Result := 0.003134794017545964;
        end
        else
        begin
            Result := -0.015234095926147301;
        end;
    end;
end;

function exact_edge_auditor_tree_92(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.011489270609952546;
    end
    else
    begin
        if features[133] <= -1235.4999999999998 then
        begin
            if features[76] <= 917.50000000000011 then
            begin
                if features[65] <= 3.5000000000000004 then
                begin
                    if features[38] <= 53687.500000000007 then
                    begin
                        Result := -0.020911917072712859;
                    end
                    else
                    begin
                        Result := 0.0012093648930983315;
                    end;
                end
                else
                begin
                    Result := 0.0034513222591336262;
                end;
            end
            else
            begin
                Result := 0.0053533982842901935;
            end;
        end
        else
        begin
            if features[37] <= 13.500000000000002 then
            begin
                if features[50] <= 2.5000000000000004 then
                begin
                    if features[64] <= 3474.5000000000005 then
                    begin
                        if features[124] <= -207.49999999999997 then
                        begin
                            Result := -0.0073316888026737524;
                        end
                        else
                        begin
                            Result := 0.016519382380771452;
                        end;
                    end
                    else
                    begin
                        if features[110] <= 1.5000000000000002 then
                        begin
                            Result := -0.0086088048708680941;
                        end
                        else
                        begin
                            Result := 0.0040339676723972068;
                        end;
                    end;
                end
                else
                begin
                    if features[4] <= 1.0000000180025095E-35 then
                    begin
                        if features[120] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0081755668034229397;
                        end
                        else
                        begin
                            Result := 0.018249171571332538;
                        end;
                    end
                    else
                    begin
                        if features[75] <= 15.500000000000002 then
                        begin
                            Result := -0.013131488214076045;
                        end
                        else
                        begin
                            Result := 0.0052003597776648491;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[80] <= 23.500000000000004 then
                begin
                    Result := 0.014816779766034266;
                end
                else
                begin
                    Result := -0.0094266607563901345;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_93(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[85] <= 5657.0000000000009 then
        begin
            if features[66] <= 1.5000000000000002 then
            begin
                if features[120] <= -1.4999999999999998 then
                begin
                    if features[51] <= -5920.4999999999991 then
                    begin
                        Result := 0.0082513549721106322;
                    end
                    else
                    begin
                        if features[7] <= -5926.9999999999991 then
                        begin
                            Result := -0.016056397214406118;
                        end
                        else
                        begin
                            Result := 0.0011297877388828739;
                        end;
                    end;
                end
                else
                begin
                    if features[12] <= 1222.5000000000002 then
                    begin
                        if features[136] <= 30.000000000000004 then
                        begin
                            Result := 0.006675584239470617;
                        end
                        else
                        begin
                            Result := -0.011866781460383388;
                        end;
                    end
                    else
                    begin
                        if features[110] <= 1.5000000000000002 then
                        begin
                            Result := 0.0021865833737208158;
                        end
                        else
                        begin
                            Result := 0.018345602422324098;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[51] <= -5683.9999999999991 then
                begin
                    if features[51] <= -6448.4999999999991 then
                    begin
                        Result := 0.003021596953823993;
                    end
                    else
                    begin
                        if features[57] <= 1080.0000000000002 then
                        begin
                            Result := 0.00039779470837901667;
                        end
                        else
                        begin
                            Result := -0.0254791342289413;
                        end;
                    end;
                end
                else
                begin
                    if features[133] <= 9.0000000000000018 then
                    begin
                        if features[66] <= 2.5000000000000004 then
                        begin
                            Result := -0.014288686066283036;
                        end
                        else
                        begin
                            Result := 0.0025720411253685829;
                        end;
                    end
                    else
                    begin
                        Result := 0.0086528126288172354;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.011891649009152452;
        end;
    end
    else
    begin
        Result := -0.009532800241209588;
    end;
end;

function exact_edge_auditor_tree_94(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[92] <= 59467.000000000007 then
    begin
        if features[133] <= 17639.500000000004 then
        begin
            if features[32] <= 2.5000000000000004 then
            begin
                if features[95] <= -1.0000000180025095E-35 then
                begin
                    if features[52] <= -6370.9999999999991 then
                    begin
                        Result := -0.020392913096144126;
                    end
                    else
                    begin
                        Result := 0.0054121449341724501;
                    end;
                end
                else
                begin
                    if features[134] <= -524.99999999999989 then
                    begin
                        Result := -0.0041959825734117053;
                    end
                    else
                    begin
                        if features[136] <= 4091.0000000000005 then
                        begin
                            Result := 0.013575478262936983;
                        end
                        else
                        begin
                            Result := -0.0063964727851306318;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[20] <= 11.500000000000002 then
                begin
                    if features[97] <= 563.00000000000011 then
                    begin
                        if features[38] <= 18291.500000000004 then
                        begin
                            Result := 0.00023766913063455079;
                        end
                        else
                        begin
                            Result := -0.013185403858187401;
                        end;
                    end
                    else
                    begin
                        Result := 0.0098041789646402706;
                    end;
                end
                else
                begin
                    if features[38] <= 51937.500000000007 then
                    begin
                        if features[30] <= 2.5000000000000004 then
                        begin
                            Result := -0.014674447435742213;
                        end
                        else
                        begin
                            Result := 0.0068232142980625106;
                        end;
                    end
                    else
                    begin
                        if features[106] <= 227.00000000000003 then
                        begin
                            Result := 0.017670185809740432;
                        end
                        else
                        begin
                            Result := -0.0082922600055648412;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.012582575168512774;
        end;
    end
    else
    begin
        if features[21] <= 2.5000000000000004 then
        begin
            Result := -0.011656340192039998;
        end
        else
        begin
            Result := 0.0069612651687509727;
        end;
    end;
end;

function exact_edge_auditor_tree_95(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.01122364758898026;
    end
    else
    begin
        if features[110] <= 3.5000000000000004 then
        begin
            if features[2] <= 16994.500000000004 then
            begin
                if features[95] <= -1.0000000180025095E-35 then
                begin
                    Result := -0.017155653086112936;
                end
                else
                begin
                    if features[13] <= 1351.5000000000002 then
                    begin
                        Result := 0.015069048997195911;
                    end
                    else
                    begin
                        Result := -0.0074018443668702463;
                    end;
                end;
            end
            else
            begin
                if features[104] <= -58.499999999999993 then
                begin
                    Result := 0.0069647901570963153;
                end
                else
                begin
                    if features[106] <= 227.00000000000003 then
                    begin
                        Result := -0.0087816451019146705;
                    end
                    else
                    begin
                        Result := 0.0051536235084959307;
                    end;
                end;
            end;
        end
        else
        begin
            if features[45] <= 4897.0000000000009 then
            begin
                if features[6] <= -6011.9999999999991 then
                begin
                    Result := 0.01180643705472198;
                end
                else
                begin
                    if features[121] <= -1.0000000180025095E-35 then
                    begin
                        if features[79] <= 583.50000000000011 then
                        begin
                            Result := -0.020869617375186236;
                        end
                        else
                        begin
                            Result := 0.0053346537004571289;
                        end;
                    end
                    else
                    begin
                        Result := 0.011623286264361321;
                    end;
                end;
            end
            else
            begin
                if features[86] <= 5686.5000000000009 then
                begin
                    if features[109] <= 47682.500000000007 then
                    begin
                        if features[45] <= 5723.5000000000009 then
                        begin
                            Result := 0.013585963879371516;
                        end
                        else
                        begin
                            Result := -0.0068485398054620407;
                        end;
                    end
                    else
                    begin
                        Result := -0.0098016142909381678;
                    end;
                end
                else
                begin
                    Result := -0.0078571567283311494;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_96(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[89] <= 1698.0000000000002 then
    begin
        if features[124] <= -554.49999999999989 then
        begin
            if features[44] <= 2084.5000000000005 then
            begin
                Result := 0.013064220123417456;
            end
            else
            begin
                Result := -0.0077576347412584446;
            end;
        end
        else
        begin
            if features[124] <= -207.49999999999997 then
            begin
                if features[135] <= 4178.5000000000009 then
                begin
                    if features[54] <= 595.50000000000011 then
                    begin
                        if features[141] <= 2.5000000000000004 then
                        begin
                            Result := -0.0018890877698617922;
                        end
                        else
                        begin
                            Result := -0.02602860197923744;
                        end;
                    end
                    else
                    begin
                        Result := 0.0081719364446267741;
                    end;
                end
                else
                begin
                    Result := 0.0058492308657860474;
                end;
            end
            else
            begin
                if features[45] <= 5702.0000000000009 then
                begin
                    if features[45] <= 2724.5000000000005 then
                    begin
                        if features[80] <= 10.500000000000002 then
                        begin
                            Result := -0.010710545330536047;
                        end
                        else
                        begin
                            Result := 0.010191434590158428;
                        end;
                    end
                    else
                    begin
                        if features[54] <= 391.50000000000006 then
                        begin
                            Result := 0.016455472772884186;
                        end
                        else
                        begin
                            Result := -0.0012966200849203052;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0097788956812500799;
                end;
            end;
        end;
    end
    else
    begin
        if features[32] <= 5.5000000000000009 then
        begin
            if features[44] <= 2084.5000000000005 then
            begin
                Result := -0.011412153585900085;
            end
            else
            begin
                Result := 0.012713602706494798;
            end;
        end
        else
        begin
            if features[82] <= 7.5000000000000009 then
            begin
                Result := -0.024991587814773342;
            end
            else
            begin
                Result := 0.0089378612029552482;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_97(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.010998722190764358;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[140] <= 9.5000000000000018 then
            begin
                if features[34] <= 599.50000000000011 then
                begin
                    if features[125] <= -1.4999999999999998 then
                    begin
                        Result := -0.00066911299678144734;
                    end
                    else
                    begin
                        Result := -0.023826028064148377;
                    end;
                end
                else
                begin
                    Result := 0.0040405569891764194;
                end;
            end
            else
            begin
                Result := 0.0072783156761869663;
            end;
        end
        else
        begin
            if features[42] <= 1.0000000180025095E-35 then
            begin
                if features[97] <= -97.499999999999986 then
                begin
                    Result := 0.009797544749529246;
                end
                else
                begin
                    if features[20] <= 20.500000000000004 then
                    begin
                        if features[89] <= -25.999999999999996 then
                        begin
                            Result := 0.0017345419746536981;
                        end
                        else
                        begin
                            Result := -0.016209907122630093;
                        end;
                    end
                    else
                    begin
                        Result := 0.0098471589255570043;
                    end;
                end;
            end
            else
            begin
                if features[95] <= -1.0000000180025095E-35 then
                begin
                    if features[102] <= 298.50000000000006 then
                    begin
                        if features[136] <= 205.50000000000003 then
                        begin
                            Result := 0.0014603172501591721;
                        end
                        else
                        begin
                            Result := -0.022585533125924102;
                        end;
                    end
                    else
                    begin
                        Result := 0.0083549977143976273;
                    end;
                end
                else
                begin
                    if features[109] <= 12043.000000000002 then
                    begin
                        if features[88] <= 14665.000000000002 then
                        begin
                            Result := 0.0085803302377512082;
                        end
                        else
                        begin
                            Result := -0.0021789270189612286;
                        end;
                    end
                    else
                    begin
                        Result := -0.011249624098801928;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_98(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[66] <= 1.5000000000000002 then
    begin
        if features[14] <= 1246.5000000000002 then
        begin
            if features[51] <= -6166.4999999999991 then
            begin
                Result := 0.010424807829112677;
            end
            else
            begin
                if features[52] <= -6330.4999999999991 then
                begin
                    Result := -0.012603341331019405;
                end
                else
                begin
                    if features[128] <= 24437.500000000004 then
                    begin
                        if features[120] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.01190156137366654;
                        end
                        else
                        begin
                            Result := -0.010890163821856744;
                        end;
                    end
                    else
                    begin
                        Result := -0.0072554008168587945;
                    end;
                end;
            end;
        end
        else
        begin
            if features[117] <= 25.500000000000004 then
            begin
                Result := 0.013692076803099956;
            end
            else
            begin
                Result := -0.011511077676469174;
            end;
        end;
    end
    else
    begin
        if features[141] <= 2.5000000000000004 then
        begin
            if features[42] <= 2.5000000000000004 then
            begin
                Result := -0.0078845929788528574;
            end
            else
            begin
                if features[2] <= 31282.000000000004 then
                begin
                    Result := 0.020512463751310706;
                end
                else
                begin
                    Result := -0.0010361937152722233;
                end;
            end;
        end
        else
        begin
            if features[140] <= 3.5000000000000004 then
            begin
                if features[31] <= 838.50000000000011 then
                begin
                    Result := -0.0089711705285187363;
                end
                else
                begin
                    Result := 0.011120251099310523;
                end;
            end
            else
            begin
                if features[96] <= 180.50000000000003 then
                begin
                    if features[30] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0052415719218108494;
                    end
                    else
                    begin
                        Result := -0.029362812396895227;
                    end;
                end
                else
                begin
                    Result := 0.0053810774039000121;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_99(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[89] <= 1698.0000000000002 then
    begin
        if features[20] <= 7.5000000000000009 then
        begin
            if features[58] <= 1098.0000000000002 then
            begin
                if features[114] <= 1.0000000180025095E-35 then
                begin
                    if features[111] <= -1.0000000180025095E-35 then
                    begin
                        if features[4] <= 1.5000000000000002 then
                        begin
                            Result := 0.0094174682992565276;
                        end
                        else
                        begin
                            Result := -0.013482526121620141;
                        end;
                    end
                    else
                    begin
                        if features[45] <= 5660.0000000000009 then
                        begin
                            Result := 0.012723673001894861;
                        end
                        else
                        begin
                            Result := -0.0024308780285651659;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.015230432640540593;
                end;
            end
            else
            begin
                if features[58] <= 1342.5000000000002 then
                begin
                    if features[89] <= 936.00000000000011 then
                    begin
                        Result := -0.025911866825063586;
                    end
                    else
                    begin
                        Result := 0.0031838742189461162;
                    end;
                end
                else
                begin
                    Result := -0.0016627647621165547;
                end;
            end;
        end
        else
        begin
            if features[12] <= 1150.5000000000002 then
            begin
                Result := -0.0061881805619099055;
            end
            else
            begin
                if features[92] <= -92884.499999999985 then
                begin
                    if features[47] <= 162488.00000000003 then
                    begin
                        Result := -0.018401343035687866;
                    end
                    else
                    begin
                        Result := 0.011377473376766171;
                    end;
                end
                else
                begin
                    if features[2] <= 69694.500000000015 then
                    begin
                        Result := 0.01757892787189113;
                    end
                    else
                    begin
                        Result := -0.0062816272629002499;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[46] <= 4386.5000000000009 then
        begin
            Result := -0.014460163083614953;
        end
        else
        begin
            Result := 0.010476457003901398;
        end;
    end;
end;

function exact_edge_auditor_tree_100(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.01072567216614433;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[38] <= 10875.000000000002 then
            begin
                if features[134] <= -668.49999999999989 then
                begin
                    Result := -0.015515599269974719;
                end
                else
                begin
                    Result := 0.0081437685829727369;
                end;
            end
            else
            begin
                Result := -0.017906850439892555;
            end;
        end
        else
        begin
            if features[110] <= 1.5000000000000002 then
            begin
                if features[97] <= -113.99999999999999 then
                begin
                    Result := 0.01143752424437258;
                end
                else
                begin
                    if features[99] <= 75.000000000000014 then
                    begin
                        if features[91] <= 4629.0000000000009 then
                        begin
                            Result := -0.012340716832008776;
                        end
                        else
                        begin
                            Result := 0.007545332788850217;
                        end;
                    end
                    else
                    begin
                        Result := 0.0076623568127340957;
                    end;
                end;
            end
            else
            begin
                if features[135] <= 2881.5000000000005 then
                begin
                    if features[136] <= 1993.0000000000002 then
                    begin
                        if features[89] <= -69.999999999999986 then
                        begin
                            Result := 0.014092724284374646;
                        end
                        else
                        begin
                            Result := -0.0045589694208811385;
                        end;
                    end
                    else
                    begin
                        if features[136] <= 3683.5000000000005 then
                        begin
                            Result := -0.027667474789193413;
                        end
                        else
                        begin
                            Result := 0.0060165624793512857;
                        end;
                    end;
                end
                else
                begin
                    if features[66] <= 2.5000000000000004 then
                    begin
                        Result := 0.014789992459984599;
                    end
                    else
                    begin
                        if features[96] <= 135.50000000000003 then
                        begin
                            Result := -0.015209205184739635;
                        end
                        else
                        begin
                            Result := 0.0092743456089565985;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_101(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[130] <= -5669.9999999999991 then
    begin
        if features[125] <= -1.4999999999999998 then
        begin
            Result := 0.0061682717571446494;
        end
        else
        begin
            Result := -0.022252210336070694;
        end;
    end
    else
    begin
        if features[66] <= 1.5000000000000002 then
        begin
            if features[59] <= 1213.5000000000002 then
            begin
                if features[51] <= -6166.4999999999991 then
                begin
                    Result := 0.011377721457434176;
                end
                else
                begin
                    if features[51] <= -3457.9999999999995 then
                    begin
                        if features[118] <= 1249.5000000000002 then
                        begin
                            Result := -0.0083399880992859471;
                        end
                        else
                        begin
                            Result := 0.0055498042881738452;
                        end;
                    end
                    else
                    begin
                        Result := 0.013596890173482683;
                    end;
                end;
            end
            else
            begin
                if features[117] <= 25.500000000000004 then
                begin
                    if features[106] <= 187.50000000000003 then
                    begin
                        Result := 0.017916706031101428;
                    end
                    else
                    begin
                        Result := -0.0069523323416764574;
                    end;
                end
                else
                begin
                    Result := -0.0075304404376004682;
                end;
            end;
        end
        else
        begin
            if features[51] <= -5683.9999999999991 then
            begin
                if features[51] <= -6448.4999999999991 then
                begin
                    Result := 0.0026718808081849822;
                end
                else
                begin
                    Result := -0.016946412802710708;
                end;
            end
            else
            begin
                if features[133] <= 713.00000000000011 then
                begin
                    if features[140] <= 5.5000000000000009 then
                    begin
                        if features[65] <= 3.5000000000000004 then
                        begin
                            Result := -0.017284635035610924;
                        end
                        else
                        begin
                            Result := 0.0065141720539053259;
                        end;
                    end
                    else
                    begin
                        Result := 0.0069580586448226142;
                    end;
                end
                else
                begin
                    Result := 0.008514779033437829;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_102(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        if features[52] <= -6133.4999999999991 then
        begin
            Result := -0.0027153041464812;
        end
        else
        begin
            Result := 0.017509602353258484;
        end;
    end
    else
    begin
        if features[97] <= 732.00000000000011 then
        begin
            if features[20] <= 11.500000000000002 then
            begin
                if features[13] <= 1191.0000000000002 then
                begin
                    if features[31] <= 740.50000000000011 then
                    begin
                        if features[102] <= 148.50000000000003 then
                        begin
                            Result := -0.011884644722644179;
                        end
                        else
                        begin
                            Result := 0.008665876449608997;
                        end;
                    end
                    else
                    begin
                        if features[114] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.0050402645940278122;
                        end
                        else
                        begin
                            Result := -0.014798388290664582;
                        end;
                    end;
                end
                else
                begin
                    if features[30] <= 1.5000000000000002 then
                    begin
                        if features[13] <= 1540.5000000000002 then
                        begin
                            Result := 0.012830380255568907;
                        end
                        else
                        begin
                            Result := -0.010731738455160327;
                        end;
                    end
                    else
                    begin
                        if features[97] <= 175.50000000000003 then
                        begin
                            Result := -0.019552738081183674;
                        end
                        else
                        begin
                            Result := -0.0013279282043829246;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[51] <= -4631.4999999999991 then
                begin
                    if features[50] <= 3.5000000000000004 then
                    begin
                        Result := 0.013526280767321394;
                    end
                    else
                    begin
                        Result := -0.0051389137581030137;
                    end;
                end
                else
                begin
                    Result := -0.0069648557010491821;
                end;
            end;
        end
        else
        begin
            if features[95] <= -1.0000000180025095E-35 then
            begin
                Result := -0.0070005426872216184;
            end
            else
            begin
                Result := 0.014062168149790943;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_103(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[85] <= 5657.0000000000009 then
        begin
            if features[132] <= -1.0000000180025095E-35 then
            begin
                if features[100] <= 1.0000000180025095E-35 then
                begin
                    if features[8] <= -6635.9999999999991 then
                    begin
                        Result := 0.0071014331037371698;
                    end
                    else
                    begin
                        Result := -0.023491897132586814;
                    end;
                end
                else
                begin
                    if features[82] <= 1.5000000000000002 then
                    begin
                        Result := 0.010294693027969048;
                    end
                    else
                    begin
                        if features[59] <= 1147.5000000000002 then
                        begin
                            Result := -0.018053037829521553;
                        end
                        else
                        begin
                            Result := 0.0112615388141265;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[13] <= 1303.5000000000002 then
                begin
                    if features[45] <= 2924.5000000000005 then
                    begin
                        if features[97] <= -133.49999999999997 then
                        begin
                            Result := 0.012437945356549131;
                        end
                        else
                        begin
                            Result := -0.012172230604785485;
                        end;
                    end
                    else
                    begin
                        if features[109] <= 4905.5000000000009 then
                        begin
                            Result := 0.0086204073697317384;
                        end
                        else
                        begin
                            Result := -0.005957984017902429;
                        end;
                    end;
                end
                else
                begin
                    if features[141] <= 6.5000000000000009 then
                    begin
                        Result := -0.011647080963602468;
                    end
                    else
                    begin
                        if features[58] <= 1327.5000000000002 then
                        begin
                            Result := -0.0076317099418654168;
                        end
                        else
                        begin
                            Result := 0.019160889416605358;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[57] <= 1384.5000000000002 then
            begin
                Result := -0.0020089042034037519;
            end
            else
            begin
                Result := 0.018572458800221452;
            end;
        end;
    end
    else
    begin
        Result := -0.0087662264638737608;
    end;
end;

function exact_edge_auditor_tree_104(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 8.5000000000000018 then
    begin
        if features[96] <= 180.50000000000003 then
        begin
            if features[125] <= -1.4999999999999998 then
            begin
                if features[7] <= -6008.9999999999991 then
                begin
                    Result := -0.002309637906005827;
                end
                else
                begin
                    Result := 0.017525173803894525;
                end;
            end
            else
            begin
                if features[121] <= -18.499999999999996 then
                begin
                    if features[104] <= 1252.5000000000002 then
                    begin
                        Result := -0.012233352804058658;
                    end
                    else
                    begin
                        Result := 0.0065662415411208231;
                    end;
                end
                else
                begin
                    if features[28] <= 2245.5000000000005 then
                    begin
                        if features[97] <= -10.499999999999998 then
                        begin
                            Result := 0.01607796774997914;
                        end
                        else
                        begin
                            Result := -0.0050101075940343692;
                        end;
                    end
                    else
                    begin
                        if features[46] <= 3715.0000000000005 then
                        begin
                            Result := -0.014428525248803352;
                        end
                        else
                        begin
                            Result := 0.0078170394363162015;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[35] <= 6.5000000000000009 then
            begin
                if features[44] <= -4431.9999999999991 then
                begin
                    Result := 0.0099282600982977792;
                end
                else
                begin
                    if features[97] <= 732.00000000000011 then
                    begin
                        Result := -0.013592525966682431;
                    end
                    else
                    begin
                        Result := 0.0052900866814390088;
                    end;
                end;
            end
            else
            begin
                if features[42] <= 1.0000000180025095E-35 then
                begin
                    if features[97] <= 257.50000000000006 then
                    begin
                        Result := 0.011896801370946931;
                    end
                    else
                    begin
                        Result := -0.011706092486812987;
                    end;
                end
                else
                begin
                    Result := 0.015071535203095359;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.0088139347119416053;
    end;
end;

function exact_edge_auditor_tree_105(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[130] <= -5669.9999999999991 then
    begin
        Result := -0.012690673760916741;
    end
    else
    begin
        if features[66] <= 1.5000000000000002 then
        begin
            if features[14] <= 1246.5000000000002 then
            begin
                if features[64] <= 3931.0000000000005 then
                begin
                    if features[30] <= 5.5000000000000009 then
                    begin
                        Result := 0.018081784301103996;
                    end
                    else
                    begin
                        if features[97] <= 121.50000000000001 then
                        begin
                            Result := 0.0071731510246116964;
                        end
                        else
                        begin
                            Result := -0.017001956781895849;
                        end;
                    end;
                end
                else
                begin
                    if features[76] <= 917.50000000000011 then
                    begin
                        if features[96] <= 23.000000000000004 then
                        begin
                            Result := 0.0026213068632548716;
                        end
                        else
                        begin
                            Result := -0.014993101697530879;
                        end;
                    end
                    else
                    begin
                        if features[46] <= 4014.5000000000005 then
                        begin
                            Result := 0.011611439855474711;
                        end
                        else
                        begin
                            Result := -0.0086709377175073765;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.011705417315966462;
            end;
        end
        else
        begin
            if features[51] <= -5683.9999999999991 then
            begin
                if features[105] <= -147.49999999999997 then
                begin
                    Result := 0.0098430047370454549;
                end
                else
                begin
                    Result := -0.013738232856775136;
                end;
            end
            else
            begin
                if features[133] <= 713.00000000000011 then
                begin
                    if features[140] <= 5.5000000000000009 then
                    begin
                        if features[65] <= 3.5000000000000004 then
                        begin
                            Result := -0.016645695138831247;
                        end
                        else
                        begin
                            Result := 0.0064328106156864694;
                        end;
                    end
                    else
                    begin
                        Result := 0.0069763261186969704;
                    end;
                end
                else
                begin
                    Result := 0.0082839372130881512;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_106(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[96] <= 804.50000000000011 then
        begin
            if features[34] <= 328.00000000000006 then
            begin
                if features[97] <= -480.99999999999994 then
                begin
                    if features[134] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0045733139011922804;
                    end
                    else
                    begin
                        Result := 0.0175254044401758;
                    end;
                end
                else
                begin
                    if features[96] <= -228.49999999999997 then
                    begin
                        if features[118] <= 47.000000000000007 then
                        begin
                            Result := -0.021610853256595078;
                        end
                        else
                        begin
                            Result := 0.0012331998577474626;
                        end;
                    end
                    else
                    begin
                        if features[97] <= -161.49999999999997 then
                        begin
                            Result := 0.014515883323930147;
                        end
                        else
                        begin
                            Result := -0.0019914916935739684;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[35] <= 14.500000000000002 then
                begin
                    if features[124] <= -225.49999999999997 then
                    begin
                        Result := -0.0042915202666601437;
                    end
                    else
                    begin
                        Result := 0.020627110371313123;
                    end;
                end
                else
                begin
                    Result := -0.0082806894008895932;
                end;
            end;
        end
        else
        begin
            if features[88] <= 11024.500000000002 then
            begin
                Result := 0.014270877255963231;
            end
            else
            begin
                Result := -0.0061188768070925392;
            end;
        end;
    end
    else
    begin
        if features[54] <= 439.00000000000006 then
        begin
            if features[36] <= 5.5000000000000009 then
            begin
                Result := -0.010112300613096942;
            end
            else
            begin
                if features[91] <= 2467.5000000000005 then
                begin
                    Result := 0.016053093246475355;
                end
                else
                begin
                    Result := -0.0084229577285579223;
                end;
            end;
        end
        else
        begin
            Result := -0.015826044299339485;
        end;
    end;
end;

function exact_edge_auditor_tree_107(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[89] <= 1698.0000000000002 then
    begin
        if features[20] <= 7.5000000000000009 then
        begin
            if features[136] <= 4091.0000000000005 then
            begin
                if features[124] <= -554.49999999999989 then
                begin
                    if features[134] <= 6282.5000000000009 then
                    begin
                        Result := 0.012476986663221869;
                    end
                    else
                    begin
                        Result := -0.0096260439209180631;
                    end;
                end
                else
                begin
                    if features[51] <= -4242.4999999999991 then
                    begin
                        if features[124] <= -107.49999999999999 then
                        begin
                            Result := -0.014893249455708637;
                        end
                        else
                        begin
                            Result := -0.00089234646856358834;
                        end;
                    end
                    else
                    begin
                        if features[52] <= -4868.4999999999991 then
                        begin
                            Result := 0.018442773262558537;
                        end
                        else
                        begin
                            Result := -0.0036768732410813374;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[127] <= 7.5000000000000009 then
                begin
                    if features[134] <= 4044.0000000000005 then
                    begin
                        Result := -0.029392842200298874;
                    end
                    else
                    begin
                        Result := 0.0019673468552687656;
                    end;
                end
                else
                begin
                    Result := 0.0087257417656698751;
                end;
            end;
        end
        else
        begin
            if features[12] <= 1150.5000000000002 then
            begin
                if features[141] <= 2.5000000000000004 then
                begin
                    Result := 0.0074714398379408268;
                end
                else
                begin
                    Result := -0.015103570903879397;
                end;
            end
            else
            begin
                Result := 0.0095299250519068762;
            end;
        end;
    end
    else
    begin
        if features[46] <= 4386.5000000000009 then
        begin
            if features[82] <= 5.5000000000000009 then
            begin
                Result := -0.018242559445146186;
            end
            else
            begin
                Result := 0.002807832039868668;
            end;
        end
        else
        begin
            Result := 0.010292987785062416;
        end;
    end;
end;

function exact_edge_auditor_tree_108(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[130] <= -5669.9999999999991 then
    begin
        Result := -0.012383930836393432;
    end
    else
    begin
        if features[51] <= -6448.4999999999991 then
        begin
            if features[137] <= 1.5000000000000002 then
            begin
                Result := -0.0028715307287764907;
            end
            else
            begin
                Result := 0.017407689989790264;
            end;
        end
        else
        begin
            if features[53] <= -6706.9999999999991 then
            begin
                if features[110] <= 3.5000000000000004 then
                begin
                    if features[34] <= 396.50000000000006 then
                    begin
                        if features[99] <= 230.50000000000003 then
                        begin
                            Result := -0.022084588624955794;
                        end
                        else
                        begin
                            Result := 0.0058297690570013874;
                        end;
                    end
                    else
                    begin
                        Result := 0.0037825113330812233;
                    end;
                end
                else
                begin
                    Result := 0.0019249947012334873;
                end;
            end
            else
            begin
                if features[32] <= 2.5000000000000004 then
                begin
                    if features[126] <= -1.0000000180025095E-35 then
                    begin
                        if features[46] <= 3778.5000000000005 then
                        begin
                            Result := 0.0067149358414179848;
                        end
                        else
                        begin
                            Result := -0.014040056537329149;
                        end;
                    end
                    else
                    begin
                        if features[124] <= 331.00000000000006 then
                        begin
                            Result := 0.021064824375947554;
                        end
                        else
                        begin
                            Result := -0.0019133513225210741;
                        end;
                    end;
                end
                else
                begin
                    if features[6] <= -5025.9999999999991 then
                    begin
                        if features[6] <= -5230.4999999999991 then
                        begin
                            Result := -0.00025722315941852076;
                        end
                        else
                        begin
                            Result := 0.014398690741863484;
                        end;
                    end
                    else
                    begin
                        if features[132] <= 3.5000000000000004 then
                        begin
                            Result := -0.0084713501457554484;
                        end
                        else
                        begin
                            Result := 0.01032130040015798;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_109(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[120] <= -1.4999999999999998 then
        begin
            if features[133] <= 9769.5000000000018 then
            begin
                if features[79] <= 552.50000000000011 then
                begin
                    if features[110] <= 13.500000000000002 then
                    begin
                        if features[51] <= -6448.4999999999991 then
                        begin
                            Result := 0.005883689969155231;
                        end
                        else
                        begin
                            Result := -0.019211642673019103;
                        end;
                    end
                    else
                    begin
                        Result := 0.006844855040275378;
                    end;
                end
                else
                begin
                    Result := 0.0015373708345736068;
                end;
            end
            else
            begin
                Result := 0.0075057384679318761;
            end;
        end
        else
        begin
            if features[66] <= 1.5000000000000002 then
            begin
                Result := 0.0082080203107447076;
            end
            else
            begin
                if features[96] <= 180.50000000000003 then
                begin
                    if features[106] <= 35.500000000000007 then
                    begin
                        if features[38] <= 23062.500000000004 then
                        begin
                            Result := -0.0006434307265386004;
                        end
                        else
                        begin
                            Result := -0.021593935500159211;
                        end;
                    end
                    else
                    begin
                        Result := 0.0069498971547312556;
                    end;
                end
                else
                begin
                    if features[120] <= 8.5000000000000018 then
                    begin
                        Result := 0.017537216859988308;
                    end
                    else
                    begin
                        Result := -0.010790535771443111;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        if features[42] <= 2.5000000000000004 then
        begin
            Result := -0.016951352162504027;
        end
        else
        begin
            if features[140] <= 3.5000000000000004 then
            begin
                Result := 0.010040879309302631;
            end
            else
            begin
                if features[52] <= -6528.4999999999991 then
                begin
                    Result := 0.0090532407405633907;
                end
                else
                begin
                    Result := -0.018670177280651568;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_110(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[98] <= -480.99999999999994 then
    begin
        Result := 0.0099448418305671631;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[38] <= 10875.000000000002 then
            begin
                Result := 0.00024775727369598632;
            end
            else
            begin
                Result := -0.016988408111248434;
            end;
        end
        else
        begin
            if features[95] <= -1.0000000180025095E-35 then
            begin
                if features[98] <= -113.99999999999999 then
                begin
                    Result := 0.010908290642339381;
                end
                else
                begin
                    if features[57] <= 1258.5000000000002 then
                    begin
                        if features[52] <= -6528.4999999999991 then
                        begin
                            Result := -0.01266802725958182;
                        end
                        else
                        begin
                            Result := 0.013909550129651197;
                        end;
                    end
                    else
                    begin
                        if features[75] <= 13.500000000000002 then
                        begin
                            Result := -0.026523093053794741;
                        end
                        else
                        begin
                            Result := 0.00045384961656079047;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[45] <= 2866.5000000000005 then
                begin
                    if features[83] <= 3450.0000000000005 then
                    begin
                        Result := -0.01292253759095595;
                    end
                    else
                    begin
                        if features[121] <= 64.500000000000014 then
                        begin
                            Result := 0.0093381356753496972;
                        end
                        else
                        begin
                            Result := -0.012506234716162383;
                        end;
                    end;
                end
                else
                begin
                    if features[58] <= 1060.5000000000002 then
                    begin
                        if features[133] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.001676491464579182;
                        end
                        else
                        begin
                            Result := 0.011377634981751164;
                        end;
                    end
                    else
                    begin
                        if features[128] <= 8875.0000000000018 then
                        begin
                            Result := -0.013297717907200317;
                        end
                        else
                        begin
                            Result := 0.0049317942459873258;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_111(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[92] <= 59467.000000000007 then
    begin
        if features[95] <= -1.0000000180025095E-35 then
        begin
            if features[53] <= -6370.9999999999991 then
            begin
                Result := -0.021101305220851584;
            end
            else
            begin
                if features[57] <= 1348.5000000000002 then
                begin
                    Result := 0.018886369489009333;
                end
                else
                begin
                    Result := -0.0085116257712083733;
                end;
            end;
        end
        else
        begin
            if features[97] <= 654.50000000000011 then
            begin
                if features[123] <= -18.499999999999996 then
                begin
                    if features[14] <= 1216.5000000000002 then
                    begin
                        if features[76] <= 927.50000000000011 then
                        begin
                            Result := -0.0098715225707925909;
                        end
                        else
                        begin
                            Result := 0.0068687915047494948;
                        end;
                    end
                    else
                    begin
                        if features[61] <= 345.00000000000006 then
                        begin
                            Result := -0.0031439588893931031;
                        end
                        else
                        begin
                            Result := 0.015966428717556776;
                        end;
                    end;
                end
                else
                begin
                    if features[9] <= 520.50000000000011 then
                    begin
                        if features[136] <= -2691.9999999999995 then
                        begin
                            Result := -0.01162359031506646;
                        end
                        else
                        begin
                            Result := 0.014008540897960281;
                        end;
                    end
                    else
                    begin
                        if features[76] <= 821.50000000000011 then
                        begin
                            Result := -0.012557918132631473;
                        end
                        else
                        begin
                            Result := 0.0091624138453150344;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.013546100036113822;
            end;
        end;
    end
    else
    begin
        if features[76] <= 870.50000000000011 then
        begin
            if features[123] <= 77.500000000000014 then
            begin
                Result := 0.0067588375048416348;
            end
            else
            begin
                Result := -0.0099783143220218504;
            end;
        end
        else
        begin
            Result := -0.019107107320071277;
        end;
    end;
end;

function exact_edge_auditor_tree_112(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[51] <= -6448.4999999999991 then
    begin
        if features[137] <= 1.5000000000000002 then
        begin
            Result := -0.0037535457960803263;
        end
        else
        begin
            if features[91] <= 3091.5000000000005 then
            begin
                Result := 0.020763930745424587;
            end
            else
            begin
                Result := -0.0062093091723990591;
            end;
        end;
    end
    else
    begin
        if features[52] <= -6706.9999999999991 then
        begin
            if features[110] <= 3.5000000000000004 then
            begin
                if features[49] <= 2.5000000000000004 then
                begin
                    if features[41] <= 5654.0000000000009 then
                    begin
                        if features[99] <= 313.00000000000006 then
                        begin
                            Result := -0.026390455583963048;
                        end
                        else
                        begin
                            Result := 0.0033724106825114885;
                        end;
                    end
                    else
                    begin
                        Result := 0.0069358603495768244;
                    end;
                end
                else
                begin
                    Result := 0.0014928717317664604;
                end;
            end
            else
            begin
                Result := 0.0013358174166129926;
            end;
        end
        else
        begin
            if features[32] <= 2.5000000000000004 then
            begin
                Result := 0.0069882254685066361;
            end
            else
            begin
                if features[76] <= 892.50000000000011 then
                begin
                    if features[3] <= 6.5000000000000009 then
                    begin
                        Result := -0.0045341577044010015;
                    end
                    else
                    begin
                        if features[105] <= -109.49999999999999 then
                        begin
                            Result := -0.0096935895065095729;
                        end
                        else
                        begin
                            Result := 0.013988285000679003;
                        end;
                    end;
                end
                else
                begin
                    if features[109] <= -3106.4999999999995 then
                    begin
                        if features[9] <= 508.50000000000006 then
                        begin
                            Result := -0.010020490579373108;
                        end
                        else
                        begin
                            Result := 0.007485954564695447;
                        end;
                    end
                    else
                    begin
                        Result := -0.019606601304760145;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_113(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.0096948234956377374;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[47] <= 52076.000000000007 then
            begin
                if features[34] <= 599.50000000000011 then
                begin
                    if features[111] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.029849427428878302;
                    end
                    else
                    begin
                        Result := 0.00026281472355306988;
                    end;
                end
                else
                begin
                    Result := 0.0051249174595228361;
                end;
            end
            else
            begin
                if features[47] <= 75419.500000000015 then
                begin
                    Result := 0.010337286512297324;
                end
                else
                begin
                    if features[43] <= 6938.5000000000009 then
                    begin
                        Result := 0.0074072985419233323;
                    end
                    else
                    begin
                        Result := -0.014969330349417109;
                    end;
                end;
            end;
        end
        else
        begin
            if features[34] <= 575.00000000000011 then
            begin
                if features[97] <= -161.49999999999997 then
                begin
                    if features[14] <= 1396.5000000000002 then
                    begin
                        Result := 0.01927117422223662;
                    end
                    else
                    begin
                        Result := -0.0061967419228335556;
                    end;
                end
                else
                begin
                    if features[14] <= 1330.5000000000002 then
                    begin
                        if features[64] <= 3931.0000000000005 then
                        begin
                            Result := 0.0054916958216826763;
                        end
                        else
                        begin
                            Result := -0.0050453768744657722;
                        end;
                    end
                    else
                    begin
                        if features[97] <= 48.000000000000007 then
                        begin
                            Result := -0.0044447487650158043;
                        end
                        else
                        begin
                            Result := 0.014807628264749472;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[96] <= -84.499999999999986 then
                begin
                    Result := 0.0059431450173393257;
                end
                else
                begin
                    Result := -0.014817358388720069;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_114(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[85] <= 5657.0000000000009 then
        begin
            if features[13] <= 1075.5000000000002 then
            begin
                if features[115] <= 1.5000000000000002 then
                begin
                    if features[81] <= 7.5000000000000009 then
                    begin
                        if features[12] <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.00039647494220451505;
                        end
                        else
                        begin
                            Result := 0.010806819099188915;
                        end;
                    end
                    else
                    begin
                        if features[38] <= 30062.500000000004 then
                        begin
                            Result := -0.012692577043714756;
                        end
                        else
                        begin
                            Result := 0.0072890853851767931;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.012337295057357573;
                end;
            end
            else
            begin
                if features[20] <= 5.5000000000000009 then
                begin
                    if features[141] <= 6.5000000000000009 then
                    begin
                        if features[83] <= 1646.0000000000002 then
                        begin
                            Result := -0.0010263477370596062;
                        end
                        else
                        begin
                            Result := -0.019787946908876652;
                        end;
                    end
                    else
                    begin
                        Result := 0.0078053206048541868;
                    end;
                end
                else
                begin
                    if features[57] <= 1558.5000000000002 then
                    begin
                        if features[76] <= 857.50000000000011 then
                        begin
                            Result := -0.017305139195936667;
                        end
                        else
                        begin
                            Result := 0.010520029521442322;
                        end;
                    end
                    else
                    begin
                        if features[76] <= 895.50000000000011 then
                        begin
                            Result := 0.016951244920988699;
                        end
                        else
                        begin
                            Result := -0.0072028735971974428;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[57] <= 1384.5000000000002 then
            begin
                Result := -0.0020077463897492961;
            end
            else
            begin
                Result := 0.018090244714018069;
            end;
        end;
    end
    else
    begin
        Result := -0.0083494572237096873;
    end;
end;

function exact_edge_auditor_tree_115(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[92] <= 59467.000000000007 then
    begin
        if features[128] <= -5937.4999999999991 then
        begin
            if features[13] <= 1191.0000000000002 then
            begin
                Result := 0.015601039793753199;
            end
            else
            begin
                Result := -0.01079923798353748;
            end;
        end
        else
        begin
            if features[14] <= 1246.5000000000002 then
            begin
                if features[79] <= 1.0000000180025095E-35 then
                begin
                    if features[30] <= 5.5000000000000009 then
                    begin
                        if features[128] <= 2062.5000000000005 then
                        begin
                            Result := -0.0080264780965025387;
                        end
                        else
                        begin
                            Result := 0.013632245892935499;
                        end;
                    end
                    else
                    begin
                        Result := -0.011602747205677326;
                    end;
                end
                else
                begin
                    if features[75] <= 15.500000000000002 then
                    begin
                        if features[32] <= 2.5000000000000004 then
                        begin
                            Result := 0.0024313989519816445;
                        end
                        else
                        begin
                            Result := -0.014121496122154506;
                        end;
                    end
                    else
                    begin
                        if features[141] <= 1.0000000180025095E-35 then
                        begin
                            Result := -0.0088610786951114091;
                        end
                        else
                        begin
                            Result := 0.010250813077267808;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[97] <= 121.50000000000001 then
                begin
                    if features[121] <= -61.499999999999993 then
                    begin
                        Result := 0.0065048336069919201;
                    end
                    else
                    begin
                        if features[28] <= 2797.5000000000005 then
                        begin
                            Result := 0.0086632288800567083;
                        end
                        else
                        begin
                            Result := -0.021010068541753857;
                        end;
                    end;
                end
                else
                begin
                    if features[28] <= 2830.5000000000005 then
                    begin
                        Result := -0.0015231270684736033;
                    end
                    else
                    begin
                        Result := 0.024712135839653333;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.0072318034065781533;
    end;
end;

function exact_edge_auditor_tree_116(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[130] <= -5669.9999999999991 then
    begin
        if features[125] <= -1.4999999999999998 then
        begin
            Result := 0.0065305083531033556;
        end
        else
        begin
            Result := -0.020897054065115304;
        end;
    end
    else
    begin
        if features[66] <= 1.5000000000000002 then
        begin
            if features[59] <= 1213.5000000000002 then
            begin
                if features[51] <= -6166.4999999999991 then
                begin
                    Result := 0.010791270520331391;
                end
                else
                begin
                    if features[51] <= -3457.9999999999995 then
                    begin
                        Result := -0.0044973519317429225;
                    end
                    else
                    begin
                        Result := 0.01322528807517712;
                    end;
                end;
            end
            else
            begin
                if features[54] <= 439.00000000000006 then
                begin
                    if features[120] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.016344389835156528;
                    end
                    else
                    begin
                        Result := 0.012049510103834085;
                    end;
                end
                else
                begin
                    Result := 0.01735008136318569;
                end;
            end;
        end
        else
        begin
            if features[141] <= 2.5000000000000004 then
            begin
                if features[58] <= 1378.5000000000002 then
                begin
                    Result := 0.009486478662589868;
                end
                else
                begin
                    Result := -0.0096908250274727256;
                end;
            end
            else
            begin
                if features[140] <= 3.5000000000000004 then
                begin
                    if features[31] <= 838.50000000000011 then
                    begin
                        Result := -0.008705155851150316;
                    end
                    else
                    begin
                        if features[14] <= 1405.5000000000002 then
                        begin
                            Result := 0.01717035955000653;
                        end
                        else
                        begin
                            Result := -0.0090391255886859544;
                        end;
                    end;
                end
                else
                begin
                    if features[96] <= 180.50000000000003 then
                    begin
                        Result := -0.023263739813025024;
                    end
                    else
                    begin
                        Result := 0.0063370092587106373;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_117(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[89] <= 1698.0000000000002 then
    begin
        if features[124] <= -554.49999999999989 then
        begin
            if features[44] <= 2084.5000000000005 then
            begin
                Result := 0.012053856480138665;
            end
            else
            begin
                if features[51] <= -5874.4999999999991 then
                begin
                    Result := 0.0098700182945587848;
                end
                else
                begin
                    Result := -0.014556295951885793;
                end;
            end;
        end
        else
        begin
            if features[6] <= -4043.4999999999995 then
            begin
                if features[124] <= -207.49999999999997 then
                begin
                    if features[132] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.018666211810103805;
                    end
                    else
                    begin
                        Result := 8.6760825686854341E-05;
                    end;
                end
                else
                begin
                    if features[45] <= 5702.0000000000009 then
                    begin
                        if features[20] <= 7.5000000000000009 then
                        begin
                            Result := -0.00031668426236158994;
                        end
                        else
                        begin
                            Result := 0.012032263660076358;
                        end;
                    end
                    else
                    begin
                        Result := -0.012087318917554386;
                    end;
                end;
            end
            else
            begin
                if features[34] <= 272.50000000000006 then
                begin
                    if features[109] <= -12332.999999999998 then
                    begin
                        Result := -0.0084034966722456323;
                    end
                    else
                    begin
                        Result := 0.018045687094770762;
                    end;
                end
                else
                begin
                    Result := -0.0058511502242791884;
                end;
            end;
        end;
    end
    else
    begin
        if features[32] <= 5.5000000000000009 then
        begin
            if features[44] <= 2084.5000000000005 then
            begin
                Result := -0.010529812778339642;
            end
            else
            begin
                Result := 0.012464909251897225;
            end;
        end
        else
        begin
            if features[82] <= 7.5000000000000009 then
            begin
                Result := -0.022957448430360267;
            end
            else
            begin
                Result := 0.00879052935731626;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_118(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[51] <= -6448.4999999999991 then
    begin
        if features[137] <= 1.5000000000000002 then
        begin
            Result := -0.0037457522291729347;
        end
        else
        begin
            if features[121] <= 50.500000000000007 then
            begin
                if features[88] <= 14378.500000000002 then
                begin
                    Result := 0.024903242990134591;
                end
                else
                begin
                    Result := -0.0045207881709801974;
                end;
            end
            else
            begin
                Result := -0.0048921943445822888;
            end;
        end;
    end
    else
    begin
        if features[52] <= -6706.9999999999991 then
        begin
            if features[110] <= 3.5000000000000004 then
            begin
                if features[34] <= 396.50000000000006 then
                begin
                    if features[99] <= 230.50000000000003 then
                    begin
                        Result := -0.021689047777279598;
                    end
                    else
                    begin
                        Result := 0.0056410933596415464;
                    end;
                end
                else
                begin
                    Result := 0.0038983942699744728;
                end;
            end
            else
            begin
                Result := 0.0013289964376500365;
            end;
        end
        else
        begin
            if features[77] <= 2.5000000000000004 then
            begin
                if features[41] <= 5686.5000000000009 then
                begin
                    Result := 0.0086032125569695892;
                end
                else
                begin
                    Result := -0.0085930846081936196;
                end;
            end
            else
            begin
                if features[76] <= 892.50000000000011 then
                begin
                    if features[3] <= 6.5000000000000009 then
                    begin
                        Result := -0.0042924568494941973;
                    end
                    else
                    begin
                        if features[106] <= -102.49999999999999 then
                        begin
                            Result := -0.0086271172055654467;
                        end
                        else
                        begin
                            Result := 0.013560989922349921;
                        end;
                    end;
                end
                else
                begin
                    if features[92] <= -140578.99999999997 then
                    begin
                        Result := 0.0093019029804441555;
                    end
                    else
                    begin
                        Result := -0.013314008913093398;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_119(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[124] <= 331.00000000000006 then
    begin
        if features[120] <= -1.4999999999999998 then
        begin
            if features[132] <= 3.5000000000000004 then
            begin
                if features[54] <= 646.50000000000011 then
                begin
                    if features[105] <= 218.50000000000003 then
                    begin
                        if features[118] <= -1435.4999999999998 then
                        begin
                            Result := 0.0075618233976124808;
                        end
                        else
                        begin
                            Result := -0.015174860527705442;
                        end;
                    end
                    else
                    begin
                        if features[52] <= -6087.4999999999991 then
                        begin
                            Result := 0.013787710008378017;
                        end
                        else
                        begin
                            Result := -0.0071253433218193647;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.0059053673280910933;
                end;
            end
            else
            begin
                Result := 0.010918964969201051;
            end;
        end
        else
        begin
            if features[136] <= 1993.0000000000002 then
            begin
                if features[133] <= -1235.4999999999998 then
                begin
                    Result := -0.0028038245999125436;
                end
                else
                begin
                    Result := 0.011105614853916049;
                end;
            end
            else
            begin
                if features[99] <= 107.50000000000001 then
                begin
                    if features[136] <= 2934.5000000000005 then
                    begin
                        Result := -0.021585588310836738;
                    end
                    else
                    begin
                        if features[96] <= -68.499999999999986 then
                        begin
                            Result := 0.013625361399917019;
                        end
                        else
                        begin
                            Result := -0.0064378541147754789;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.011822154597410577;
                end;
            end;
        end;
    end
    else
    begin
        if features[42] <= 2.5000000000000004 then
        begin
            Result := -0.016416631185042326;
        end
        else
        begin
            if features[60] <= 292.50000000000006 then
            begin
                Result := 0.011252390671659698;
            end
            else
            begin
                Result := -0.010561174927326236;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_120(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.0094329118568800448;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[140] <= 9.5000000000000018 then
            begin
                if features[34] <= 599.50000000000011 then
                begin
                    if features[125] <= -1.4999999999999998 then
                    begin
                        Result := -0.00014172421499889485;
                    end
                    else
                    begin
                        Result := -0.021259813856557546;
                    end;
                end
                else
                begin
                    Result := 0.00394752356329968;
                end;
            end
            else
            begin
                Result := 0.0071434862881836906;
            end;
        end
        else
        begin
            if features[95] <= -1.0000000180025095E-35 then
            begin
                if features[97] <= -113.99999999999999 then
                begin
                    Result := 0.010495232494008376;
                end
                else
                begin
                    if features[102] <= 1254.0000000000002 then
                    begin
                        Result := -0.016432728879195689;
                    end
                    else
                    begin
                        Result := 0.0070025694127801045;
                    end;
                end;
            end
            else
            begin
                if features[19] <= 3895.5000000000005 then
                begin
                    if features[13] <= 1075.5000000000002 then
                    begin
                        if features[60] <= 173.50000000000003 then
                        begin
                            Result := 0.0016793827074835705;
                        end
                        else
                        begin
                            Result := 0.013120088522916453;
                        end;
                    end
                    else
                    begin
                        if features[128] <= 7062.5000000000009 then
                        begin
                            Result := -0.013244144593770869;
                        end
                        else
                        begin
                            Result := 0.0030572809692231283;
                        end;
                    end;
                end
                else
                begin
                    if features[128] <= -60749.999999999993 then
                    begin
                        Result := 0.01361655268686676;
                    end
                    else
                    begin
                        if features[46] <= 3153.0000000000005 then
                        begin
                            Result := -0.011270238279534973;
                        end
                        else
                        begin
                            Result := 0.0042898901108755121;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_121(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[92] <= 59467.000000000007 then
    begin
        if features[133] <= 17639.500000000004 then
        begin
            if features[120] <= -1.0000000180025095E-35 then
            begin
                if features[73] <= 4050.0000000000005 then
                begin
                    if features[46] <= 3402.0000000000005 then
                    begin
                        if features[79] <= 565.50000000000011 then
                        begin
                            Result := -0.007334847974897119;
                        end
                        else
                        begin
                            Result := 0.0097266495661947634;
                        end;
                    end
                    else
                    begin
                        if features[7] <= -6543.9999999999991 then
                        begin
                            Result := 0.0021896274797654578;
                        end
                        else
                        begin
                            Result := -0.022415367424840911;
                        end;
                    end;
                end
                else
                begin
                    if features[42] <= 6.5000000000000009 then
                    begin
                        Result := 0.015843701708348878;
                    end
                    else
                    begin
                        Result := -0.010080843695008904;
                    end;
                end;
            end
            else
            begin
                if features[13] <= 1.0000000180025095E-35 then
                begin
                    if features[31] <= 740.50000000000011 then
                    begin
                        if features[45] <= 2924.5000000000005 then
                        begin
                            Result := -0.012850133975142968;
                        end
                        else
                        begin
                            Result := 0.0047954436503229621;
                        end;
                    end
                    else
                    begin
                        if features[53] <= -7054.4999999999991 then
                        begin
                            Result := -0.0066488316420287548;
                        end
                        else
                        begin
                            Result := 0.014445689492359323;
                        end;
                    end;
                end
                else
                begin
                    if features[128] <= 10125.000000000002 then
                    begin
                        Result := -0.012474131366555556;
                    end
                    else
                    begin
                        Result := 0.0030307599687866668;
                    end;
                end;
            end;
        end
        else
        begin
            if features[73] <= 5638.5000000000009 then
            begin
                Result := 0.016440722041972011;
            end
            else
            begin
                Result := -0.0092407086320640229;
            end;
        end;
    end
    else
    begin
        Result := -0.0069412845857317424;
    end;
end;

function exact_edge_auditor_tree_122(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[85] <= 5657.0000000000009 then
        begin
            if features[132] <= -1.0000000180025095E-35 then
            begin
                if features[100] <= 1.0000000180025095E-35 then
                begin
                    if features[7] <= -6635.9999999999991 then
                    begin
                        Result := 0.0070894326466049776;
                    end
                    else
                    begin
                        Result := -0.022135963954272368;
                    end;
                end
                else
                begin
                    if features[91] <= 2152.5000000000005 then
                    begin
                        Result := 0.011715341444611371;
                    end
                    else
                    begin
                        if features[52] <= -6087.4999999999991 then
                        begin
                            Result := -0.015043426701796219;
                        end
                        else
                        begin
                            Result := 0.0063540163257192481;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[13] <= 1303.5000000000002 then
                begin
                    if features[60] <= 558.50000000000011 then
                    begin
                        if features[45] <= 2924.5000000000005 then
                        begin
                            Result := -0.0032301847055653489;
                        end
                        else
                        begin
                            Result := 0.0074809390451948824;
                        end;
                    end
                    else
                    begin
                        if features[18] <= 1.5000000000000002 then
                        begin
                            Result := 0.0096572555457352591;
                        end
                        else
                        begin
                            Result := -0.018739797790903429;
                        end;
                    end;
                end
                else
                begin
                    if features[60] <= 577.00000000000011 then
                    begin
                        if features[30] <= 16.500000000000004 then
                        begin
                            Result := -0.013146213655010543;
                        end
                        else
                        begin
                            Result := 0.0080616505980863375;
                        end;
                    end
                    else
                    begin
                        Result := 0.0090267654063412167;
                    end;
                end;
            end;
        end
        else
        begin
            if features[57] <= 1384.5000000000002 then
            begin
                Result := -0.0017721979812884948;
            end
            else
            begin
                Result := 0.017667695030754143;
            end;
        end;
    end
    else
    begin
        Result := -0.0078407638077278123;
    end;
end;

function exact_edge_auditor_tree_123(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 4.5000000000000009 then
    begin
        if features[97] <= 134.50000000000003 then
        begin
            if features[105] <= -147.49999999999997 then
            begin
                Result := 0.010995269388720771;
            end
            else
            begin
                if features[97] <= -10.499999999999998 then
                begin
                    if features[44] <= -182.99999999999997 then
                    begin
                        if features[124] <= -554.49999999999989 then
                        begin
                            Result := 0.0090162053173730682;
                        end
                        else
                        begin
                            Result := -0.014189593113884789;
                        end;
                    end
                    else
                    begin
                        if features[109] <= 1624.5000000000002 then
                        begin
                            Result := 0.0085422239974544782;
                        end
                        else
                        begin
                            Result := -0.010454108084917936;
                        end;
                    end;
                end
                else
                begin
                    if features[106] <= 83.500000000000014 then
                    begin
                        Result := -0.015544317016544289;
                    end
                    else
                    begin
                        Result := 0.0025602474434619064;
                    end;
                end;
            end;
        end
        else
        begin
            if features[109] <= -5439.9999999999991 then
            begin
                if features[14] <= 1108.5000000000002 then
                begin
                    if features[2] <= 11507.000000000002 then
                    begin
                        Result := 0.010576260948345035;
                    end
                    else
                    begin
                        if features[97] <= 732.00000000000011 then
                        begin
                            Result := -0.020252162421563583;
                        end
                        else
                        begin
                            Result := 0.0039726250721657677;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.014480661440657825;
                end;
            end
            else
            begin
                if features[38] <= 16450.000000000004 then
                begin
                    Result := -0.0021958187701593091;
                end
                else
                begin
                    if features[37] <= 6.5000000000000009 then
                    begin
                        Result := -0.0085319377274246933;
                    end
                    else
                    begin
                        Result := 0.016800635692114513;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.0070914715627431492;
    end;
end;

function exact_edge_auditor_tree_124(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[51] <= -6448.4999999999991 then
    begin
        if features[89] <= 886.00000000000011 then
        begin
            if features[141] <= 6.5000000000000009 then
            begin
                if features[16] <= 278.50000000000006 then
                begin
                    Result := 0.023683589226036132;
                end
                else
                begin
                    Result := -0.0037204900508521236;
                end;
            end
            else
            begin
                if features[73] <= 1390.5000000000002 then
                begin
                    Result := -0.017496147018113039;
                end
                else
                begin
                    Result := 0.0098147581313385544;
                end;
            end;
        end
        else
        begin
            Result := -0.010754030363582688;
        end;
    end
    else
    begin
        if features[53] <= -6706.9999999999991 then
        begin
            Result := -0.008417277442431103;
        end
        else
        begin
            if features[32] <= 2.5000000000000004 then
            begin
                if features[41] <= 5686.5000000000009 then
                begin
                    if features[64] <= 3931.0000000000005 then
                    begin
                        Result := -0.0012367468387997536;
                    end
                    else
                    begin
                        Result := 0.012597507890394145;
                    end;
                end
                else
                begin
                    Result := -0.0085413826140137601;
                end;
            end
            else
            begin
                if features[76] <= 892.50000000000011 then
                begin
                    if features[3] <= 6.5000000000000009 then
                    begin
                        Result := -0.0041519224451760381;
                    end
                    else
                    begin
                        if features[106] <= -102.49999999999999 then
                        begin
                            Result := -0.0084109336369384124;
                        end
                        else
                        begin
                            Result := 0.013123282191660908;
                        end;
                    end;
                end
                else
                begin
                    if features[92] <= -140578.99999999997 then
                    begin
                        Result := 0.0091219817125105865;
                    end
                    else
                    begin
                        if features[64] <= 10319.500000000002 then
                        begin
                            Result := -0.019983464409302525;
                        end
                        else
                        begin
                            Result := -0.00095839536135765952;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_125(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.0092545870218269516;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[47] <= 52076.000000000007 then
            begin
                if features[34] <= 599.50000000000011 then
                begin
                    if features[111] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.028546871202803078;
                    end
                    else
                    begin
                        Result := 0.00037001837727844813;
                    end;
                end
                else
                begin
                    Result := 0.005076609513628723;
                end;
            end
            else
            begin
                Result := -0.0002851019416764972;
            end;
        end
        else
        begin
            if features[95] <= -1.0000000180025095E-35 then
            begin
                if features[97] <= -113.99999999999999 then
                begin
                    Result := 0.010256282795186493;
                end
                else
                begin
                    if features[102] <= 1254.0000000000002 then
                    begin
                        if features[2] <= 114269.00000000001 then
                        begin
                            Result := -0.020020207059430317;
                        end
                        else
                        begin
                            Result := 0.0027479933604570494;
                        end;
                    end
                    else
                    begin
                        Result := 0.0068576991786354034;
                    end;
                end;
            end
            else
            begin
                if features[2] <= 16994.500000000004 then
                begin
                    if features[58] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.014449234120306506;
                    end
                    else
                    begin
                        Result := -0.0077800389335847629;
                    end;
                end
                else
                begin
                    if features[35] <= 6.5000000000000009 then
                    begin
                        if features[65] <= 3.5000000000000004 then
                        begin
                            Result := -0.01419902757876716;
                        end
                        else
                        begin
                            Result := 0.0087190709836414051;
                        end;
                    end
                    else
                    begin
                        if features[88] <= 22559.000000000004 then
                        begin
                            Result := 0.0051675249894622098;
                        end
                        else
                        begin
                            Result := -0.01206345483374884;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_126(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[96] <= 804.50000000000011 then
    begin
        if features[119] <= -429.99999999999994 then
        begin
            if features[20] <= 3.5000000000000004 then
            begin
                Result := -0.0056311477510705985;
            end
            else
            begin
                Result := 0.01923303086680176;
            end;
        end
        else
        begin
            if features[78] <= 927.50000000000011 then
            begin
                if features[78] <= 875.50000000000011 then
                begin
                    if features[132] <= -1.0000000180025095E-35 then
                    begin
                        if features[79] <= 512.50000000000011 then
                        begin
                            Result := -0.014852584171160796;
                        end
                        else
                        begin
                            Result := 0.0080679391221495141;
                        end;
                    end
                    else
                    begin
                        if features[92] <= -35817.499999999993 then
                        begin
                            Result := -0.0077491256168554963;
                        end
                        else
                        begin
                            Result := 0.0042681663394947434;
                        end;
                    end;
                end
                else
                begin
                    if features[105] <= 35.500000000000007 then
                    begin
                        if features[44] <= 2645.5000000000005 then
                        begin
                            Result := -0.021701202926897905;
                        end
                        else
                        begin
                            Result := 0.0043889977129446343;
                        end;
                    end
                    else
                    begin
                        if features[89] <= 1570.0000000000002 then
                        begin
                            Result := 0.0061590738967930323;
                        end
                        else
                        begin
                            Result := -0.013628654116081976;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[105] <= 92.000000000000014 then
                begin
                    if features[44] <= 2875.5000000000005 then
                    begin
                        if features[89] <= 1479.0000000000002 then
                        begin
                            Result := 0.018833712664908287;
                        end
                        else
                        begin
                            Result := -0.0022937893786895529;
                        end;
                    end
                    else
                    begin
                        Result := -0.0055558772277035625;
                    end;
                end
                else
                begin
                    Result := -0.0057264484840802267;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.0082133337943763145;
    end;
end;

function exact_edge_auditor_tree_127(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[120] <= 8.5000000000000018 then
    begin
        if features[97] <= 732.00000000000011 then
        begin
            if features[31] <= 722.50000000000011 then
            begin
                if features[64] <= 5758.0000000000009 then
                begin
                    if features[96] <= 103.50000000000001 then
                    begin
                        if features[31] <= 692.50000000000011 then
                        begin
                            Result := 0.00067505940186835054;
                        end
                        else
                        begin
                            Result := -0.020256329535148315;
                        end;
                    end
                    else
                    begin
                        if features[38] <= 20583.500000000004 then
                        begin
                            Result := -0.0068979127763810176;
                        end
                        else
                        begin
                            Result := 0.014638131146547001;
                        end;
                    end;
                end
                else
                begin
                    if features[97] <= 81.500000000000014 then
                    begin
                        if features[7] <= -5960.9999999999991 then
                        begin
                            Result := -0.0077167748425258746;
                        end
                        else
                        begin
                            Result := 0.011616761917498273;
                        end;
                    end
                    else
                    begin
                        Result := -0.02224708394632588;
                    end;
                end;
            end
            else
            begin
                if features[2] <= 22123.000000000004 then
                begin
                    Result := 0.014687619874537851;
                end
                else
                begin
                    if features[43] <= 19815.000000000004 then
                    begin
                        if features[123] <= -125.49999999999999 then
                        begin
                            Result := 0.0093313218159072429;
                        end
                        else
                        begin
                            Result := -0.0051039931939023233;
                        end;
                    end
                    else
                    begin
                        Result := 0.0087935806545307044;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.010240113836248402;
        end;
    end
    else
    begin
        if features[127] <= -4.4999999999999991 then
        begin
            Result := 0.0033400873471666629;
        end
        else
        begin
            if features[134] <= 1581.0000000000002 then
            begin
                Result := -0.021987201193253217;
            end
            else
            begin
                Result := 0.0052076871390926505;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_128(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        if features[52] <= -6133.4999999999991 then
        begin
            Result := -0.0033515656762164369;
        end
        else
        begin
            Result := 0.016045295601173674;
        end;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[140] <= 9.5000000000000018 then
            begin
                if features[34] <= 599.50000000000011 then
                begin
                    Result := -0.015809820221298992;
                end
                else
                begin
                    Result := 0.0039253259680114881;
                end;
            end
            else
            begin
                Result := 0.0069833429028086638;
            end;
        end
        else
        begin
            if features[89] <= 1479.0000000000002 then
            begin
                if features[97] <= -161.49999999999997 then
                begin
                    Result := 0.014071518594347705;
                end
                else
                begin
                    if features[79] <= 650.50000000000011 then
                    begin
                        if features[6] <= -4043.4999999999995 then
                        begin
                            Result := -0.0035976283870104795;
                        end
                        else
                        begin
                            Result := 0.0082072232923092198;
                        end;
                    end
                    else
                    begin
                        if features[134] <= 3843.5000000000005 then
                        begin
                            Result := 0.012473311969176724;
                        end
                        else
                        begin
                            Result := -0.0075625813361852798;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[65] <= 2.5000000000000004 then
                begin
                    if features[60] <= 408.00000000000006 then
                    begin
                        if features[44] <= 2192.0000000000005 then
                        begin
                            Result := -0.026251136427373659;
                        end
                        else
                        begin
                            Result := -0.0023732194602055952;
                        end;
                    end
                    else
                    begin
                        Result := 0.0052358665969485935;
                    end;
                end
                else
                begin
                    if features[13] <= 1393.5000000000002 then
                    begin
                        Result := 0.012504772985909893;
                    end
                    else
                    begin
                        Result := -0.0080095828284845183;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_129(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[130] <= -5669.9999999999991 then
    begin
        if features[125] <= -1.4999999999999998 then
        begin
            Result := 0.0064915598067244243;
        end
        else
        begin
            Result := -0.020008135220956309;
        end;
    end
    else
    begin
        if features[119] <= -429.99999999999994 then
        begin
            if features[96] <= 481.50000000000006 then
            begin
                Result := 0.016687577314567045;
            end
            else
            begin
                Result := -0.0045983244035390902;
            end;
        end
        else
        begin
            if features[120] <= 8.5000000000000018 then
            begin
                if features[33] <= 838.50000000000011 then
                begin
                    if features[96] <= 804.50000000000011 then
                    begin
                        if features[109] <= -5439.9999999999991 then
                        begin
                            Result := -0.0092327230133998992;
                        end
                        else
                        begin
                            Result := 0.00061641932967495476;
                        end;
                    end
                    else
                    begin
                        if features[88] <= 11024.500000000002 then
                        begin
                            Result := 0.013686350558019349;
                        end
                        else
                        begin
                            Result := -0.0059943644478023545;
                        end;
                    end;
                end
                else
                begin
                    if features[75] <= 30.500000000000004 then
                    begin
                        if features[109] <= 2972.5000000000005 then
                        begin
                            Result := 0.011154389415994692;
                        end
                        else
                        begin
                            Result := -0.0032066228785613935;
                        end;
                    end
                    else
                    begin
                        Result := -0.012970241607716218;
                    end;
                end;
            end
            else
            begin
                if features[110] <= -2.4999999999999996 then
                begin
                    if features[105] <= -64.499999999999986 then
                    begin
                        Result := -0.0067861394050840402;
                    end
                    else
                    begin
                        Result := 0.013204220890378286;
                    end;
                end
                else
                begin
                    if features[44] <= 1503.0000000000002 then
                    begin
                        Result := -0.021791802638266862;
                    end
                    else
                    begin
                        Result := 0.0019661166012569968;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_130(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[51] <= -6448.4999999999991 then
    begin
        if features[91] <= 2982.0000000000005 then
        begin
            if features[121] <= 50.500000000000007 then
            begin
                Result := 0.015228220599935874;
            end
            else
            begin
                Result := -0.0048668630729400402;
            end;
        end
        else
        begin
            Result := -0.009112946561433112;
        end;
    end
    else
    begin
        if features[52] <= -6706.9999999999991 then
        begin
            Result := -0.0081274228764683584;
        end
        else
        begin
            if features[32] <= 2.5000000000000004 then
            begin
                if features[41] <= 5686.5000000000009 then
                begin
                    if features[64] <= 3931.0000000000005 then
                    begin
                        Result := -0.0012660444514427417;
                    end
                    else
                    begin
                        if features[8] <= -4239.4999999999991 then
                        begin
                            Result := 0.015068297288248262;
                        end
                        else
                        begin
                            Result := -0.010015615516880592;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.0084596703746432859;
                end;
            end
            else
            begin
                if features[6] <= -5025.9999999999991 then
                begin
                    if features[28] <= 1381.5000000000002 then
                    begin
                        if features[31] <= 740.50000000000011 then
                        begin
                            Result := -0.0065029154281915696;
                        end
                        else
                        begin
                            Result := 0.02373468970798397;
                        end;
                    end
                    else
                    begin
                        if features[38] <= 26083.500000000004 then
                        begin
                            Result := -0.010375748078359956;
                        end
                        else
                        begin
                            Result := 0.0071240612867064547;
                        end;
                    end;
                end
                else
                begin
                    if features[132] <= 3.5000000000000004 then
                    begin
                        if features[6] <= -4541.4999999999991 then
                        begin
                            Result := -0.019481834946276241;
                        end
                        else
                        begin
                            Result := -0.0019749938847746858;
                        end;
                    end
                    else
                    begin
                        Result := 0.0095589978186379383;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_131(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        if features[53] <= -6133.4999999999991 then
        begin
            Result := -0.003265377153134498;
        end
        else
        begin
            Result := 0.01572729754977344;
        end;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[47] <= 52076.000000000007 then
            begin
                if features[53] <= -6797.4999999999991 then
                begin
                    Result := 0.0020618178757382758;
                end
                else
                begin
                    if features[21] <= 2.5000000000000004 then
                    begin
                        Result := -0.027572675253843045;
                    end
                    else
                    begin
                        Result := 0.0018590503654956391;
                    end;
                end;
            end
            else
            begin
                Result := 0.00010651171801057904;
            end;
        end
        else
        begin
            if features[95] <= -1.0000000180025095E-35 then
            begin
                if features[57] <= 1258.5000000000002 then
                begin
                    if features[53] <= -6370.9999999999991 then
                    begin
                        Result := -0.011693321442478262;
                    end
                    else
                    begin
                        Result := 0.01706435742988615;
                    end;
                end
                else
                begin
                    Result := -0.015617765337925516;
                end;
            end
            else
            begin
                if features[2] <= 16994.500000000004 then
                begin
                    if features[58] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.014041591637854654;
                    end
                    else
                    begin
                        Result := -0.0077246859422693765;
                    end;
                end
                else
                begin
                    if features[35] <= 6.5000000000000009 then
                    begin
                        if features[65] <= 3.5000000000000004 then
                        begin
                            Result := -0.013834082039418886;
                        end
                        else
                        begin
                            Result := 0.0083492183139740363;
                        end;
                    end
                    else
                    begin
                        if features[88] <= 22559.000000000004 then
                        begin
                            Result := 0.0050197997462296182;
                        end
                        else
                        begin
                            Result := -0.011802860397146692;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_132(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[130] <= -5669.9999999999991 then
    begin
        if features[125] <= -1.4999999999999998 then
        begin
            Result := 0.0064739907459652832;
        end
        else
        begin
            Result := -0.019713985354205574;
        end;
    end
    else
    begin
        if features[66] <= 1.5000000000000002 then
        begin
            if features[120] <= -1.0000000180025095E-35 then
            begin
                Result := -0.0014085076431550202;
            end
            else
            begin
                Result := 0.00693156533925917;
            end;
        end
        else
        begin
            if features[28] <= 2572.5000000000005 then
            begin
                if features[42] <= 2.5000000000000004 then
                begin
                    if features[99] <= 1.0000000180025095E-35 then
                    begin
                        if features[6] <= -4293.9999999999991 then
                        begin
                            Result := -0.01751829773719956;
                        end
                        else
                        begin
                            Result := 0.0068369277760735436;
                        end;
                    end
                    else
                    begin
                        Result := 0.0087206653888698017;
                    end;
                end
                else
                begin
                    if features[37] <= 10.500000000000002 then
                    begin
                        if features[110] <= 6.5000000000000009 then
                        begin
                            Result := 0.01600763841077579;
                        end
                        else
                        begin
                            Result := -0.005424372328133995;
                        end;
                    end
                    else
                    begin
                        if features[96] <= 273.50000000000006 then
                        begin
                            Result := -0.016496735436620887;
                        end
                        else
                        begin
                            Result := 0.0098473936144601315;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[30] <= 1.0000000180025095E-35 then
                begin
                    Result := 0.0093159033995526951;
                end
                else
                begin
                    if features[141] <= 2.5000000000000004 then
                    begin
                        Result := 0.0018935315450640518;
                    end
                    else
                    begin
                        if features[9] <= 884.00000000000011 then
                        begin
                            Result := -0.021475471186072275;
                        end
                        else
                        begin
                            Result := 0.0059231869259733635;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_133(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 3.5000000000000004 then
    begin
        if features[52] <= -6370.9999999999991 then
        begin
            if features[109] <= -1456.4999999999998 then
            begin
                if features[105] <= 196.50000000000003 then
                begin
                    if features[140] <= 5.5000000000000009 then
                    begin
                        Result := -0.022441403874828385;
                    end
                    else
                    begin
                        Result := 0.0021819836741032951;
                    end;
                end
                else
                begin
                    Result := 0.004836520407394255;
                end;
            end
            else
            begin
                if features[2] <= 31282.000000000004 then
                begin
                    Result := 0.010739700351243079;
                end
                else
                begin
                    if features[4] <= 1.5000000000000002 then
                    begin
                        Result := 0.0082634356321320424;
                    end
                    else
                    begin
                        if features[30] <= 17.500000000000004 then
                        begin
                            Result := -0.019104390590771656;
                        end
                        else
                        begin
                            Result := 0.0069657637650926488;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[141] <= 11.500000000000002 then
            begin
                if features[13] <= 1480.5000000000002 then
                begin
                    if features[86] <= 4192.5000000000009 then
                    begin
                        if features[52] <= -4644.4999999999991 then
                        begin
                            Result := 0.011337874455324774;
                        end
                        else
                        begin
                            Result := -0.0079354380474992627;
                        end;
                    end
                    else
                    begin
                        if features[81] <= 9.5000000000000018 then
                        begin
                            Result := -0.011310245008770894;
                        end
                        else
                        begin
                            Result := 0.0096532391326944137;
                        end;
                    end;
                end
                else
                begin
                    if features[141] <= 4.5000000000000009 then
                    begin
                        Result := -0.015672381707534624;
                    end
                    else
                    begin
                        Result := 0.0077640419394734133;
                    end;
                end;
            end
            else
            begin
                Result := -0.014962951743565309;
            end;
        end;
    end
    else
    begin
        Result := 0.0032296141190258443;
    end;
end;

function exact_edge_auditor_tree_134(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.0086497885882934472;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[47] <= 52076.000000000007 then
            begin
                if features[34] <= 599.50000000000011 then
                begin
                    if features[111] <= 1.0000000180025095E-35 then
                    begin
                        Result := -0.027077419105156909;
                    end
                    else
                    begin
                        Result := 0.0004368234719408328;
                    end;
                end
                else
                begin
                    Result := 0.0050367146793042512;
                end;
            end
            else
            begin
                Result := 5.8333613630860024E-05;
            end;
        end
        else
        begin
            if features[95] <= -1.0000000180025095E-35 then
            begin
                if features[80] <= 11.500000000000002 then
                begin
                    if features[52] <= -6370.9999999999991 then
                    begin
                        Result := -0.022355389386138506;
                    end
                    else
                    begin
                        Result := -0.00024026209950673853;
                    end;
                end
                else
                begin
                    Result := 0.0060879407843133174;
                end;
            end
            else
            begin
                if features[19] <= 2450.5000000000005 then
                begin
                    if features[141] <= 1.5000000000000002 then
                    begin
                        Result := 0.017264540705115287;
                    end
                    else
                    begin
                        if features[136] <= 2157.5000000000005 then
                        begin
                            Result := 0.0083004248104012364;
                        end
                        else
                        begin
                            Result := -0.008626389209375052;
                        end;
                    end;
                end
                else
                begin
                    if features[9] <= 666.50000000000011 then
                    begin
                        if features[82] <= 6.5000000000000009 then
                        begin
                            Result := -0.0071137060439698981;
                        end
                        else
                        begin
                            Result := 0.0045114321394894149;
                        end;
                    end
                    else
                    begin
                        if features[136] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0061026424444739196;
                        end
                        else
                        begin
                            Result := 0.013007174747684596;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_135(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[51] <= -6448.4999999999991 then
    begin
        if features[137] <= 1.5000000000000002 then
        begin
            if features[51] <= -6887.4999999999991 then
            begin
                if features[18] <= 3.5000000000000004 then
                begin
                    Result := 0.0075021169155419388;
                end
                else
                begin
                    Result := -0.021031944417447691;
                end;
            end
            else
            begin
                Result := 0.0059364826967307546;
            end;
        end
        else
        begin
            Result := 0.015593244082096603;
        end;
    end
    else
    begin
        if features[53] <= -6706.9999999999991 then
        begin
            Result := -0.0078001880588140279;
        end
        else
        begin
            if features[34] <= 575.00000000000011 then
            begin
                if features[120] <= -1.4999999999999998 then
                begin
                    if features[54] <= 609.50000000000011 then
                    begin
                        if features[49] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.0091567401396488984;
                        end
                        else
                        begin
                            Result := -0.0092191327692965844;
                        end;
                    end
                    else
                    begin
                        Result := 0.0087355258887258126;
                    end;
                end
                else
                begin
                    if features[141] <= 3.5000000000000004 then
                    begin
                        if features[120] <= 12.500000000000002 then
                        begin
                            Result := 0.013792097102846349;
                        end
                        else
                        begin
                            Result := -0.0069293139616891349;
                        end;
                    end
                    else
                    begin
                        if features[97] <= 121.50000000000001 then
                        begin
                            Result := -0.0067409469834394248;
                        end
                        else
                        begin
                            Result := 0.0071899009257782301;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[60] <= 303.50000000000006 then
                begin
                    if features[96] <= -84.499999999999986 then
                    begin
                        Result := 0.013483589529532665;
                    end
                    else
                    begin
                        Result := -0.0095120857327014915;
                    end;
                end
                else
                begin
                    Result := -0.016836694764861986;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_136(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[110] <= 3.5000000000000004 then
    begin
        if features[52] <= -6370.9999999999991 then
        begin
            if features[88] <= 12078.000000000002 then
            begin
                if features[105] <= 172.50000000000003 then
                begin
                    if features[85] <= 2932.5000000000005 then
                    begin
                        Result := -0.0083477471656208252;
                    end
                    else
                    begin
                        Result := 0.012146340968538196;
                    end;
                end
                else
                begin
                    Result := 0.013764998807066168;
                end;
            end
            else
            begin
                if features[105] <= -128.99999999999997 then
                begin
                    Result := 0.0053222733147348378;
                end
                else
                begin
                    Result := -0.023844597638892028;
                end;
            end;
        end
        else
        begin
            if features[141] <= 11.500000000000002 then
            begin
                Result := 0.0029022292562627039;
            end
            else
            begin
                Result := -0.014670698547255407;
            end;
        end;
    end
    else
    begin
        if features[51] <= -5416.9999999999991 then
        begin
            if features[100] <= 1.0000000180025095E-35 then
            begin
                if features[66] <= 1.5000000000000002 then
                begin
                    Result := 0.018919395468104248;
                end
                else
                begin
                    if features[51] <= -5970.4999999999991 then
                    begin
                        Result := -0.011102002355534839;
                    end
                    else
                    begin
                        Result := 0.0160186984846729;
                    end;
                end;
            end
            else
            begin
                if features[134] <= 644.50000000000011 then
                begin
                    Result := -0.017155615688019387;
                end
                else
                begin
                    Result := 0.011794103985479613;
                end;
            end;
        end
        else
        begin
            if features[45] <= 4897.0000000000009 then
            begin
                if features[121] <= -47.499999999999993 then
                begin
                    Result := -0.014976011903871319;
                end
                else
                begin
                    Result := 0.0054767639448505987;
                end;
            end
            else
            begin
                Result := 0.0038465570835716141;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_137(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[89] <= 1698.0000000000002 then
    begin
        if features[47] <= 64908.000000000007 then
        begin
            if features[51] <= -6166.4999999999991 then
            begin
                if features[136] <= 3412.0000000000005 then
                begin
                    Result := 0.013363008443209362;
                end
                else
                begin
                    Result := -0.011689564478623198;
                end;
            end
            else
            begin
                if features[51] <= -5788.4999999999991 then
                begin
                    Result := -0.017502534321111572;
                end
                else
                begin
                    if features[78] <= 747.50000000000011 then
                    begin
                        if features[43] <= 4747.0000000000009 then
                        begin
                            Result := -0.0043911473878119811;
                        end
                        else
                        begin
                            Result := 0.015006600961094843;
                        end;
                    end
                    else
                    begin
                        if features[54] <= 391.50000000000006 then
                        begin
                            Result := 0.0012988075344711881;
                        end
                        else
                        begin
                            Result := -0.013182639578224816;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[45] <= 5660.0000000000009 then
            begin
                if features[6] <= -3553.9999999999995 then
                begin
                    if features[12] <= 1069.5000000000002 then
                    begin
                        Result := -0.0014076971843607964;
                    end
                    else
                    begin
                        Result := 0.014308956598291296;
                    end;
                end
                else
                begin
                    Result := -0.0077703128495583218;
                end;
            end
            else
            begin
                Result := -0.0020829043212697296;
            end;
        end;
    end
    else
    begin
        if features[77] <= 5.5000000000000009 then
        begin
            if features[44] <= 2084.5000000000005 then
            begin
                Result := -0.009953728929497075;
            end
            else
            begin
                Result := 0.012023597914465967;
            end;
        end
        else
        begin
            if features[82] <= 7.5000000000000009 then
            begin
                Result := -0.02149936153646469;
            end
            else
            begin
                Result := 0.008481992724562239;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_138(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[119] <= -429.99999999999994 then
    begin
        if features[20] <= 3.5000000000000004 then
        begin
            Result := -0.0063602487543582588;
        end
        else
        begin
            Result := 0.018638811635562236;
        end;
    end
    else
    begin
        if features[120] <= 8.5000000000000018 then
        begin
            if features[96] <= 180.50000000000003 then
            begin
                if features[125] <= -1.4999999999999998 then
                begin
                    Result := 0.0064520435798305197;
                end
                else
                begin
                    if features[123] <= -18.499999999999996 then
                    begin
                        Result := -0.0093659005942614195;
                    end
                    else
                    begin
                        if features[45] <= 5698.0000000000009 then
                        begin
                            Result := 0.0063491867157041528;
                        end
                        else
                        begin
                            Result := -0.016171395282972994;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[35] <= 6.5000000000000009 then
                begin
                    if features[136] <= 30.000000000000004 then
                    begin
                        if features[19] <= 3177.0000000000005 then
                        begin
                            Result := 0.014591116322229506;
                        end
                        else
                        begin
                            Result := -0.010640385268173087;
                        end;
                    end
                    else
                    begin
                        if features[90] <= 3267.5000000000005 then
                        begin
                            Result := 0.0017267198537530336;
                        end
                        else
                        begin
                            Result := -0.021072064537866805;
                        end;
                    end;
                end
                else
                begin
                    if features[94] <= 1.0000000180025095E-35 then
                    begin
                        if features[140] <= 2.5000000000000004 then
                        begin
                            Result := -0.0001381506593540657;
                        end
                        else
                        begin
                            Result := 0.02036219088229551;
                        end;
                    end
                    else
                    begin
                        Result := -0.0023625221790735747;
                    end;
                end;
            end;
        end
        else
        begin
            if features[110] <= -2.4999999999999996 then
            begin
                Result := 0.005065134068747903;
            end
            else
            begin
                Result := -0.017515903898614141;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_139(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[134] <= 1.0000000180025095E-35 then
    begin
        if features[13] <= 1417.5000000000002 then
        begin
            if features[46] <= 4308.5000000000009 then
            begin
                if features[44] <= -982.49999999999989 then
                begin
                    if features[29] <= 1.0000000180025095E-35 then
                    begin
                        if features[133] <= 10882.000000000002 then
                        begin
                            Result := 0.010396977060007924;
                        end
                        else
                        begin
                            Result := -0.011330525270128565;
                        end;
                    end
                    else
                    begin
                        Result := -0.0076680803219763638;
                    end;
                end
                else
                begin
                    if features[98] <= -97.499999999999986 then
                    begin
                        if features[134] <= -199.99999999999997 then
                        begin
                            Result := -0.0097750020175083954;
                        end
                        else
                        begin
                            Result := 0.012967843961915771;
                        end;
                    end
                    else
                    begin
                        Result := -0.0094750366048295155;
                    end;
                end;
            end
            else
            begin
                Result := 0.014858433282273474;
            end;
        end
        else
        begin
            if features[14] <= 1393.5000000000002 then
            begin
                Result := -0.018956244363347367;
            end
            else
            begin
                Result := 0.0044122651383040733;
            end;
        end;
    end
    else
    begin
        if features[37] <= 13.500000000000002 then
        begin
            if features[134] <= 644.50000000000011 then
            begin
                Result := 0.012241931179771846;
            end
            else
            begin
                if features[19] <= 2480.5000000000005 then
                begin
                    Result := 0.0044539665443704196;
                end
                else
                begin
                    if features[135] <= 5277.0000000000009 then
                    begin
                        if features[136] <= 2654.5000000000005 then
                        begin
                            Result := -0.0063585139406157308;
                        end
                        else
                        begin
                            Result := 0.015297793434149103;
                        end;
                    end
                    else
                    begin
                        Result := -0.017940956433857472;
                    end;
                end;
            end;
        end
        else
        begin
            Result := 0.016832991766759758;
        end;
    end;
end;

function exact_edge_auditor_tree_140(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[96] <= 804.50000000000011 then
    begin
        if features[20] <= 12.500000000000002 then
        begin
            if features[33] <= 838.50000000000011 then
            begin
                if features[33] <= 806.50000000000011 then
                begin
                    if features[33] <= 750.50000000000011 then
                    begin
                        if features[132] <= 2.5000000000000004 then
                        begin
                            Result := -0.0091008828611810338;
                        end
                        else
                        begin
                            Result := 0.0053181375634475244;
                        end;
                    end
                    else
                    begin
                        if features[118] <= 1390.5000000000002 then
                        begin
                            Result := 0.011708706354755028;
                        end
                        else
                        begin
                            Result := -0.010222641661277947;
                        end;
                    end;
                end
                else
                begin
                    if features[48] <= 4.5000000000000009 then
                    begin
                        Result := 0.0087048557322096237;
                    end
                    else
                    begin
                        Result := -0.019656144107447204;
                    end;
                end;
            end
            else
            begin
                if features[92] <= 45688.500000000007 then
                begin
                    if features[51] <= -4541.4999999999991 then
                    begin
                        Result := 0.0096285586589022719;
                    end
                    else
                    begin
                        Result := -0.0043240970040399184;
                    end;
                end
                else
                begin
                    if features[100] <= 1.0000000180025095E-35 then
                    begin
                        if features[51] <= -4422.4999999999991 then
                        begin
                            Result := -0.018400052890021525;
                        end
                        else
                        begin
                            Result := 0.0058098023502740521;
                        end;
                    end
                    else
                    begin
                        Result := 0.0052569785999444342;
                    end;
                end;
            end;
        end
        else
        begin
            if features[25] <= 2.5000000000000004 then
            begin
                Result := 0.014066673286458933;
            end
            else
            begin
                if features[100] <= -1.0000000180025095E-35 then
                begin
                    Result := 0.0092276246248172208;
                end
                else
                begin
                    Result := -0.010723207909457253;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.0076842269823974791;
    end;
end;

function exact_edge_auditor_tree_141(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[119] <= -429.99999999999994 then
    begin
        if features[20] <= 3.5000000000000004 then
        begin
            Result := -0.0061959064547964559;
        end
        else
        begin
            Result := 0.018405953100722884;
        end;
    end
    else
    begin
        if features[120] <= 8.5000000000000018 then
        begin
            if features[96] <= 180.50000000000003 then
            begin
                if features[125] <= -1.4999999999999998 then
                begin
                    if features[7] <= -6008.9999999999991 then
                    begin
                        Result := -0.002561806954039585;
                    end
                    else
                    begin
                        Result := 0.015045946634132281;
                    end;
                end
                else
                begin
                    if features[97] <= -10.499999999999998 then
                    begin
                        if features[44] <= -182.99999999999997 then
                        begin
                            Result := -0.012067602247166595;
                        end
                        else
                        begin
                            Result := 0.005683162948525387;
                        end;
                    end
                    else
                    begin
                        Result := -0.010540379724777924;
                    end;
                end;
            end
            else
            begin
                if features[137] <= 2.5000000000000004 then
                begin
                    if features[80] <= 6.5000000000000009 then
                    begin
                        Result := -0.0022885651980253468;
                    end
                    else
                    begin
                        Result := 0.010471226463539009;
                    end;
                end
                else
                begin
                    if features[51] <= -6519.4999999999991 then
                    begin
                        Result := 0.010166318038992728;
                    end
                    else
                    begin
                        if features[28] <= 2725.5000000000005 then
                        begin
                            Result := -0.024107542547576223;
                        end
                        else
                        begin
                            Result := 0.0055872353667600532;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[110] <= -2.4999999999999996 then
            begin
                Result := 0.0049804946172012339;
            end
            else
            begin
                if features[18] <= 6.5000000000000009 then
                begin
                    Result := -0.021884226784632109;
                end
                else
                begin
                    Result := 0.0043022265652005913;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_142(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[85] <= 5685.5000000000009 then
    begin
        if features[85] <= 5657.0000000000009 then
        begin
            if features[111] <= -3.4999999999999996 then
            begin
                Result := -0.012791726236818306;
            end
            else
            begin
                if features[51] <= -6448.4999999999991 then
                begin
                    if features[141] <= 6.5000000000000009 then
                    begin
                        if features[54] <= 520.50000000000011 then
                        begin
                            Result := 0.017715264710382452;
                        end
                        else
                        begin
                            Result := -0.0063297798285807403;
                        end;
                    end
                    else
                    begin
                        Result := -0.0040043331130656954;
                    end;
                end
                else
                begin
                    if features[7] <= -5960.9999999999991 then
                    begin
                        if features[124] <= -35.999999999999993 then
                        begin
                            Result := -0.0093573793079350688;
                        end
                        else
                        begin
                            Result := 0.0022307258101842233;
                        end;
                    end
                    else
                    begin
                        if features[115] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.0045049069808959039;
                        end
                        else
                        begin
                            Result := -0.0097450443099652909;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[57] <= 1384.5000000000002 then
            begin
                if features[140] <= 4.5000000000000009 then
                begin
                    Result := -0.011144769973886453;
                end
                else
                begin
                    Result := 0.0084859485843852382;
                end;
            end
            else
            begin
                Result := 0.017133129566598165;
            end;
        end;
    end
    else
    begin
        if features[91] <= 3558.5000000000005 then
        begin
            if features[133] <= 1907.0000000000002 then
            begin
                Result := -0.020564713578719078;
            end
            else
            begin
                Result := 0.0033988592116357469;
            end;
        end
        else
        begin
            if features[42] <= 4.5000000000000009 then
            begin
                Result := -0.0057674072643612772;
            end
            else
            begin
                Result := 0.011795971728755662;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_143(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[88] <= 21589.000000000004 then
    begin
        if features[51] <= -6448.4999999999991 then
        begin
            if features[141] <= 6.5000000000000009 then
            begin
                if features[121] <= 50.500000000000007 then
                begin
                    Result := 0.01998875032088741;
                end
                else
                begin
                    Result := -0.0050240269248046365;
                end;
            end
            else
            begin
                Result := -0.006566662360526416;
            end;
        end
        else
        begin
            if features[33] <= 740.50000000000011 then
            begin
                if features[28] <= 1561.5000000000002 then
                begin
                    if features[64] <= 5409.0000000000009 then
                    begin
                        if features[44] <= 426.00000000000006 then
                        begin
                            Result := -0.010822768848553294;
                        end
                        else
                        begin
                            Result := 0.012455944262975673;
                        end;
                    end
                    else
                    begin
                        if features[97] <= 938.50000000000011 then
                        begin
                            Result := -0.022012638021022529;
                        end
                        else
                        begin
                            Result := 0.0069891338735185767;
                        end;
                    end;
                end
                else
                begin
                    if features[128] <= 18145.500000000004 then
                    begin
                        Result := -0.0075002680409789312;
                    end
                    else
                    begin
                        Result := 0.012845467130481085;
                    end;
                end;
            end
            else
            begin
                if features[47] <= 64908.000000000007 then
                begin
                    if features[21] <= 3.5000000000000004 then
                    begin
                        if features[88] <= 9206.5000000000018 then
                        begin
                            Result := -0.011697335490016759;
                        end
                        else
                        begin
                            Result := 0.0038192994965644197;
                        end;
                    end
                    else
                    begin
                        Result := 0.011514584423714636;
                    end;
                end
                else
                begin
                    if features[58] <= 1345.5000000000002 then
                    begin
                        Result := 0.010690129533301581;
                    end
                    else
                    begin
                        Result := -0.0079469712070093061;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.0080762891090142633;
    end;
end;

function exact_edge_auditor_tree_144(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        if features[3] <= 4.5000000000000009 then
        begin
            Result := -0.0030169915238929075;
        end
        else
        begin
            Result := 0.015700564083617929;
        end;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[47] <= 52076.000000000007 then
            begin
                if features[34] <= 599.50000000000011 then
                begin
                    if features[21] <= 1.5000000000000002 then
                    begin
                        Result := -0.027174174751364053;
                    end
                    else
                    begin
                        Result := -0.00058967605490506869;
                    end;
                end
                else
                begin
                    Result := 0.0050942356081314991;
                end;
            end
            else
            begin
                if features[47] <= 75419.500000000015 then
                begin
                    Result := 0.010543261655044022;
                end
                else
                begin
                    Result := -0.0071904498734182377;
                end;
            end;
        end
        else
        begin
            if features[97] <= -161.49999999999997 then
            begin
                Result := 0.010270585144703873;
            end
            else
            begin
                if features[120] <= 8.5000000000000018 then
                begin
                    if features[37] <= 15.500000000000002 then
                    begin
                        if features[64] <= 3474.5000000000005 then
                        begin
                            Result := 0.0064620772958328401;
                        end
                        else
                        begin
                            Result := -0.0028964762594270617;
                        end;
                    end
                    else
                    begin
                        if features[0] <= 26.500000000000004 then
                        begin
                            Result := 0.015563882504961908;
                        end
                        else
                        begin
                            Result := -0.0080050218111534649;
                        end;
                    end;
                end
                else
                begin
                    if features[127] <= -10.499999999999998 then
                    begin
                        Result := 0.005127207209958966;
                    end
                    else
                    begin
                        if features[32] <= 6.5000000000000009 then
                        begin
                            Result := -0.00039344793067045385;
                        end
                        else
                        begin
                            Result := -0.022743663988254503;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_145(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[141] <= 1.5000000000000002 then
    begin
        if features[13] <= 1438.5000000000002 then
        begin
            if features[86] <= 5683.5000000000009 then
            begin
                if features[28] <= 2797.5000000000005 then
                begin
                    Result := 0.013327438496603689;
                end
                else
                begin
                    Result := -0.0042001959130695127;
                end;
            end
            else
            begin
                Result := -0.0098830803801044607;
            end;
        end
        else
        begin
            Result := -0.0095834326423045475;
        end;
    end
    else
    begin
        if features[9] <= 1.0000000180025095E-35 then
        begin
            if features[95] <= 1.5000000000000002 then
            begin
                Result := -0.010852841092681278;
            end
            else
            begin
                Result := 0.0096922059506697258;
            end;
        end
        else
        begin
            if features[66] <= 1.5000000000000002 then
            begin
                if features[130] <= -2809.9999999999995 then
                begin
                    Result := -0.0096159638438162599;
                end
                else
                begin
                    if features[113] <= 1.0000000180025095E-35 then
                    begin
                        if features[29] <= 1.0000000180025095E-35 then
                        begin
                            Result := 0.010176160053487069;
                        end
                        else
                        begin
                            Result := -0.0029734598056818675;
                        end;
                    end
                    else
                    begin
                        Result := -0.012142486318561957;
                    end;
                end;
            end
            else
            begin
                if features[28] <= 2572.5000000000005 then
                begin
                    if features[82] <= 6.5000000000000009 then
                    begin
                        Result := -0.0036032693517939144;
                    end
                    else
                    begin
                        Result := 0.012947928224307912;
                    end;
                end
                else
                begin
                    if features[128] <= 53625.000000000007 then
                    begin
                        if features[9] <= 884.00000000000011 then
                        begin
                            Result := -0.018577615308787741;
                        end
                        else
                        begin
                            Result := 0.0057303625851324175;
                        end;
                    end
                    else
                    begin
                        Result := 0.0091585921408661383;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_146(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[97] <= -480.99999999999994 then
    begin
        Result := 0.0082759585878059306;
    end
    else
    begin
        if features[96] <= -228.49999999999997 then
        begin
            if features[38] <= 10875.000000000002 then
            begin
                Result := 0.0013318331019344359;
            end
            else
            begin
                if features[118] <= 47.000000000000007 then
                begin
                    Result := -0.021170329324034259;
                end
                else
                begin
                    if features[92] <= -9036.4999999999982 then
                    begin
                        Result := 0.010291734914776505;
                    end
                    else
                    begin
                        Result := -0.011896904286531888;
                    end;
                end;
            end;
        end
        else
        begin
            if features[95] <= -1.0000000180025095E-35 then
            begin
                if features[57] <= 1258.5000000000002 then
                begin
                    if features[53] <= -6528.4999999999991 then
                    begin
                        Result := -0.01146264249049659;
                    end
                    else
                    begin
                        Result := 0.016067189412970893;
                    end;
                end
                else
                begin
                    Result := -0.014823497563906109;
                end;
            end
            else
            begin
                if features[2] <= 16994.500000000004 then
                begin
                    if features[58] <= 1060.5000000000002 then
                    begin
                        if features[81] <= 2.5000000000000004 then
                        begin
                            Result := -0.00081775120468027677;
                        end
                        else
                        begin
                            Result := 0.017685019442619236;
                        end;
                    end
                    else
                    begin
                        Result := -0.0083062264832948086;
                    end;
                end
                else
                begin
                    if features[57] <= 1537.5000000000002 then
                    begin
                        if features[83] <= 53833.500000000007 then
                        begin
                            Result := -0.0068673488681933416;
                        end
                        else
                        begin
                            Result := 0.010868040787276089;
                        end;
                    end
                    else
                    begin
                        if features[2] <= 41258.000000000007 then
                        begin
                            Result := 0.014395429090439655;
                        end
                        else
                        begin
                            Result := -0.00043588272161662275;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_147(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[119] <= -429.99999999999994 then
    begin
        if features[20] <= 3.5000000000000004 then
        begin
            Result := -0.0060752440423362478;
        end
        else
        begin
            Result := 0.018089903517020174;
        end;
    end
    else
    begin
        if features[120] <= 8.5000000000000018 then
        begin
            if features[96] <= 804.50000000000011 then
            begin
                if features[31] <= 750.50000000000011 then
                begin
                    if features[53] <= -7823.9999999999991 then
                    begin
                        Result := 0.012606990381251163;
                    end
                    else
                    begin
                        if features[65] <= 3.5000000000000004 then
                        begin
                            Result := -0.01048494120700629;
                        end
                        else
                        begin
                            Result := 0.0043145788974203918;
                        end;
                    end;
                end
                else
                begin
                    if features[2] <= 22123.000000000004 then
                    begin
                        if features[121] <= -143.99999999999997 then
                        begin
                            Result := -0.004255157188246486;
                        end
                        else
                        begin
                            Result := 0.020710204491673757;
                        end;
                    end
                    else
                    begin
                        if features[96] <= 180.50000000000003 then
                        begin
                            Result := -0.003836636067573793;
                        end
                        else
                        begin
                            Result := 0.006425821172329935;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[47] <= 168712.00000000003 then
                begin
                    Result := 0.012700384447499095;
                end
                else
                begin
                    Result := -0.0056998371710880831;
                end;
            end;
        end
        else
        begin
            if features[54] <= 450.50000000000006 then
            begin
                if features[57] <= 1240.5000000000002 then
                begin
                    Result := -0.0095110140391455478;
                end
                else
                begin
                    if features[40] <= 4793.5000000000009 then
                    begin
                        Result := 0.01517015710428991;
                    end
                    else
                    begin
                        Result := -0.0060368742453593034;
                    end;
                end;
            end
            else
            begin
                Result := -0.017243773928864357;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_148(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[71] <= 2.5000000000000004 then
    begin
        if features[83] <= 53833.500000000007 then
        begin
            if features[134] <= 1.0000000180025095E-35 then
            begin
                if features[46] <= 4605.5000000000009 then
                begin
                    if features[13] <= 1414.5000000000002 then
                    begin
                        if features[51] <= -4242.4999999999991 then
                        begin
                            Result := -0.0047147584291012653;
                        end
                        else
                        begin
                            Result := 0.0078171847388731532;
                        end;
                    end
                    else
                    begin
                        if features[118] <= 2785.5000000000005 then
                        begin
                            Result := -0.020759936618183518;
                        end
                        else
                        begin
                            Result := 0.0075778308529056756;
                        end;
                    end;
                end
                else
                begin
                    Result := 0.014006850351399812;
                end;
            end
            else
            begin
                if features[134] <= 644.50000000000011 then
                begin
                    Result := 0.014360724318211848;
                end
                else
                begin
                    if features[128] <= 44375.000000000007 then
                    begin
                        if features[137] <= 1.5000000000000002 then
                        begin
                            Result := -0.011231342868430126;
                        end
                        else
                        begin
                            Result := 0.0042526348882795263;
                        end;
                    end
                    else
                    begin
                        if features[137] <= 2.5000000000000004 then
                        begin
                            Result := 0.01778377248791764;
                        end
                        else
                        begin
                            Result := -0.0077620057376864005;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[128] <= -135374.99999999997 then
            begin
                Result := -0.011144920533217688;
            end
            else
            begin
                if features[73] <= 2695.5000000000005 then
                begin
                    if features[121] <= 77.500000000000014 then
                    begin
                        Result := 0.021916187176408173;
                    end
                    else
                    begin
                        Result := -0.0036412221703907765;
                    end;
                end
                else
                begin
                    Result := -0.0081412262992121391;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.013511649731162353;
    end;
end;

function exact_edge_auditor_tree_149(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 20.500000000000004 then
    begin
        if features[24] <= 1.0000000180025095E-35 then
        begin
            if features[13] <= 1191.0000000000002 then
            begin
                if features[132] <= -1.0000000180025095E-35 then
                begin
                    if features[14] <= 1236.0000000000002 then
                    begin
                        if features[135] <= -2793.9999999999995 then
                        begin
                            Result := 0.0029053131891269447;
                        end
                        else
                        begin
                            Result := -0.019755692764799229;
                        end;
                    end
                    else
                    begin
                        Result := 0.01049486264023293;
                    end;
                end
                else
                begin
                    if features[40] <= 5701.0000000000009 then
                    begin
                        Result := 0.005370308220659435;
                    end
                    else
                    begin
                        Result := -0.0073495179338742087;
                    end;
                end;
            end
            else
            begin
                if features[110] <= 1.5000000000000002 then
                begin
                    if features[140] <= 3.5000000000000004 then
                    begin
                        Result := 0.0066935865966870622;
                    end
                    else
                    begin
                        if features[76] <= 924.50000000000011 then
                        begin
                            Result := -0.021008098346074047;
                        end
                        else
                        begin
                            Result := 0.0032836273880643909;
                        end;
                    end;
                end
                else
                begin
                    if features[106] <= 187.50000000000003 then
                    begin
                        if features[37] <= 6.5000000000000009 then
                        begin
                            Result := -0.0092609263448990824;
                        end
                        else
                        begin
                            Result := 0.010560796700171586;
                        end;
                    end
                    else
                    begin
                        Result := -0.012393844306613605;
                    end;
                end;
            end;
        end
        else
        begin
            if features[32] <= 2.5000000000000004 then
            begin
                Result := 0.0076497702225327606;
            end
            else
            begin
                if features[86] <= 5654.0000000000009 then
                begin
                    Result := -0.020606144382360074;
                end
                else
                begin
                    Result := 0.0025619612806497996;
                end;
            end;
        end;
    end
    else
    begin
        Result := 0.011228671463847663;
    end;
end;

function exact_edge_auditor_tree_150(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[119] <= -429.99999999999994 then
    begin
        Result := 0.0099851570872271696;
    end
    else
    begin
        if features[120] <= 8.5000000000000018 then
        begin
            if features[96] <= 804.50000000000011 then
            begin
                if features[31] <= 750.50000000000011 then
                begin
                    if features[52] <= -7823.9999999999991 then
                    begin
                        Result := 0.012417036738607373;
                    end
                    else
                    begin
                        if features[37] <= 10.500000000000002 then
                        begin
                            Result := -0.010016116310519397;
                        end
                        else
                        begin
                            Result := 0.0040948573218854102;
                        end;
                    end;
                end
                else
                begin
                    if features[2] <= 22123.000000000004 then
                    begin
                        if features[121] <= -143.99999999999997 then
                        begin
                            Result := -0.0041398685407662726;
                        end
                        else
                        begin
                            Result := 0.020337986842772177;
                        end;
                    end
                    else
                    begin
                        if features[96] <= 180.50000000000003 then
                        begin
                            Result := -0.0036997051598353101;
                        end
                        else
                        begin
                            Result := 0.0062780559954824667;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[88] <= 11024.500000000002 then
                begin
                    if features[95] <= -1.0000000180025095E-35 then
                    begin
                        Result := -0.0037500062572095269;
                    end
                    else
                    begin
                        Result := 0.016595219878749304;
                    end;
                end
                else
                begin
                    Result := -0.0066691652240551532;
                end;
            end;
        end
        else
        begin
            if features[110] <= -2.4999999999999996 then
            begin
                if features[105] <= -64.499999999999986 then
                begin
                    Result := -0.0067663352833874516;
                end
                else
                begin
                    Result := 0.012666986700965679;
                end;
            end
            else
            begin
                if features[18] <= 6.5000000000000009 then
                begin
                    Result := -0.020946406474089418;
                end
                else
                begin
                    Result := 0.0042602297880828437;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_151(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[131] <= -5669.9999999999991 then
    begin
        Result := -0.010987490741344103;
    end
    else
    begin
        if features[71] <= 2.5000000000000004 then
        begin
            if features[66] <= 1.5000000000000002 then
            begin
                if features[59] <= 1213.5000000000002 then
                begin
                    if features[6] <= -5064.9999999999991 then
                    begin
                        if features[20] <= 4.5000000000000009 then
                        begin
                            Result := -0.0010560409049351158;
                        end
                        else
                        begin
                            Result := 0.012537775597525462;
                        end;
                    end
                    else
                    begin
                        if features[96] <= -359.49999999999994 then
                        begin
                            Result := 0.014015798555984393;
                        end
                        else
                        begin
                            Result := -0.0068724329785604553;
                        end;
                    end;
                end
                else
                begin
                    if features[2] <= 139906.50000000003 then
                    begin
                        if features[30] <= 3.5000000000000004 then
                        begin
                            Result := 0.0037752875267398982;
                        end
                        else
                        begin
                            Result := 0.023681299470203414;
                        end;
                    end
                    else
                    begin
                        Result := -0.006150693155893369;
                    end;
                end;
            end
            else
            begin
                if features[28] <= 2572.5000000000005 then
                begin
                    if features[81] <= 1.5000000000000002 then
                    begin
                        Result := -0.012826025385383487;
                    end
                    else
                    begin
                        if features[83] <= 3062.5000000000005 then
                        begin
                            Result := -0.008085706369327832;
                        end
                        else
                        begin
                            Result := 0.0079193517827075167;
                        end;
                    end;
                end
                else
                begin
                    if features[30] <= 1.0000000180025095E-35 then
                    begin
                        Result := 0.0081408569055149531;
                    end
                    else
                    begin
                        if features[134] <= 2738.5000000000005 then
                        begin
                            Result := -0.015583381114619274;
                        end
                        else
                        begin
                            Result := 0.0050505848830904188;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            Result := -0.013382299641081504;
        end;
    end;
end;

function exact_edge_auditor_tree_152(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[141] <= 1.5000000000000002 then
    begin
        if features[13] <= 1438.5000000000002 then
        begin
            if features[86] <= 5683.5000000000009 then
            begin
                Result := 0.009569240215595784;
            end
            else
            begin
                Result := -0.0095142948750594637;
            end;
        end
        else
        begin
            Result := -0.008973222595167394;
        end;
    end
    else
    begin
        if features[12] <= 1.0000000180025095E-35 then
        begin
            if features[2] <= 65646.000000000015 then
            begin
                if features[32] <= 2.5000000000000004 then
                begin
                    Result := -0.00024955540466543294;
                end
                else
                begin
                    if features[44] <= 3911.0000000000005 then
                    begin
                        Result := -0.021570321334647095;
                    end
                    else
                    begin
                        Result := 0.0068940304715272667;
                    end;
                end;
            end
            else
            begin
                Result := 0.0045452586026358361;
            end;
        end
        else
        begin
            if features[45] <= 5660.0000000000009 then
            begin
                if features[45] <= 5364.5000000000009 then
                begin
                    if features[64] <= 4846.5000000000009 then
                    begin
                        if features[47] <= 30867.500000000004 then
                        begin
                            Result := 0.0042798158995968911;
                        end
                        else
                        begin
                            Result := -0.016032660673051029;
                        end;
                    end
                    else
                    begin
                        Result := 0.0062038138518114936;
                    end;
                end
                else
                begin
                    if features[7] <= -5748.4999999999991 then
                    begin
                        Result := 0.024672728363320615;
                    end
                    else
                    begin
                        Result := -0.0011610013465739415;
                    end;
                end;
            end
            else
            begin
                if features[92] <= -124428.99999999999 then
                begin
                    Result := 0.011472705431895776;
                end
                else
                begin
                    if features[109] <= -5439.9999999999991 then
                    begin
                        Result := -0.020146602536391681;
                    end
                    else
                    begin
                        Result := -0.0015723507228108478;
                    end;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_153(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[89] <= 1698.0000000000002 then
    begin
        if features[47] <= 64908.000000000007 then
        begin
            if features[51] <= -6166.4999999999991 then
            begin
                if features[136] <= 3412.0000000000005 then
                begin
                    Result := 0.012697758961736746;
                end
                else
                begin
                    Result := -0.011637115861246316;
                end;
            end
            else
            begin
                if features[51] <= -5788.4999999999991 then
                begin
                    Result := -0.01685553655535323;
                end
                else
                begin
                    if features[76] <= 747.50000000000011 then
                    begin
                        Result := 0.0068222278950313487;
                    end
                    else
                    begin
                        if features[32] <= 1.5000000000000002 then
                        begin
                            Result := 0.0068527860803895653;
                        end
                        else
                        begin
                            Result := -0.0093200622658744445;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[18] <= 5.5000000000000009 then
            begin
                if features[120] <= -2.4999999999999996 then
                begin
                    if features[92] <= -92884.499999999985 then
                    begin
                        if features[124] <= -545.99999999999989 then
                        begin
                            Result := 0.0024359370518133331;
                        end
                        else
                        begin
                            Result := -0.020280320328586694;
                        end;
                    end
                    else
                    begin
                        Result := 0.0067951605537241548;
                    end;
                end
                else
                begin
                    Result := 0.011638805025846683;
                end;
            end
            else
            begin
                Result := -0.0062558227222126407;
            end;
        end;
    end
    else
    begin
        if features[46] <= 4386.5000000000009 then
        begin
            if features[65] <= 2.5000000000000004 then
            begin
                if features[97] <= -480.99999999999994 then
                begin
                    Result := 0.0054901971582685446;
                end
                else
                begin
                    Result := -0.020530929157280456;
                end;
            end
            else
            begin
                Result := 0.0011342964860574433;
            end;
        end
        else
        begin
            Result := 0.0094346515075753121;
        end;
    end;
end;

function exact_edge_auditor_tree_154(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[20] <= 20.500000000000004 then
    begin
        if features[134] <= 1.0000000180025095E-35 then
        begin
            if features[13] <= 1417.5000000000002 then
            begin
                if features[24] <= 1.0000000180025095E-35 then
                begin
                    if features[52] <= -6167.4999999999991 then
                    begin
                        if features[5] <= 3.5000000000000004 then
                        begin
                            Result := -0.007184692120627968;
                        end
                        else
                        begin
                            Result := 0.012864333035798004;
                        end;
                    end
                    else
                    begin
                        if features[36] <= 2.5000000000000004 then
                        begin
                            Result := -0.0070052495309159126;
                        end
                        else
                        begin
                            Result := 0.010212860271538121;
                        end;
                    end;
                end
                else
                begin
                    if features[32] <= 2.5000000000000004 then
                    begin
                        Result := 0.0048355464459787761;
                    end
                    else
                    begin
                        Result := -0.018374291419740289;
                    end;
                end;
            end
            else
            begin
                Result := -0.014093876919619412;
            end;
        end
        else
        begin
            if features[37] <= 13.500000000000002 then
            begin
                if features[45] <= 4989.0000000000009 then
                begin
                    if features[75] <= 23.500000000000004 then
                    begin
                        if features[90] <= 3671.0000000000005 then
                        begin
                            Result := 0.016402686172750262;
                        end
                        else
                        begin
                            Result := -0.0013609860964522622;
                        end;
                    end
                    else
                    begin
                        Result := -0.010403144066304494;
                    end;
                end
                else
                begin
                    if features[137] <= 1.5000000000000002 then
                    begin
                        Result := -0.010077405979752293;
                    end
                    else
                    begin
                        if features[73] <= 1390.5000000000002 then
                        begin
                            Result := -0.0096766999813217569;
                        end
                        else
                        begin
                            Result := 0.014979808223353474;
                        end;
                    end;
                end;
            end
            else
            begin
                Result := 0.015736584612871182;
            end;
        end;
    end
    else
    begin
        Result := 0.011051948862115912;
    end;
end;

function exact_edge_auditor_tree_155(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[71] <= 2.5000000000000004 then
    begin
        if features[72] <= -61.999999999999993 then
        begin
            if features[128] <= -97749.999999999985 then
            begin
                Result := -0.0041989844337205727;
            end
            else
            begin
                Result := 0.018136839088747247;
            end;
        end
        else
        begin
            if features[97] <= -480.99999999999994 then
            begin
                if features[53] <= -6133.4999999999991 then
                begin
                    if features[3] <= 4.5000000000000009 then
                    begin
                        Result := -0.011608012185247636;
                    end
                    else
                    begin
                        Result := 0.0058371880767132244;
                    end;
                end
                else
                begin
                    if features[30] <= 6.5000000000000009 then
                    begin
                        Result := 0.018626159147221013;
                    end
                    else
                    begin
                        Result := 0.0024250217998147915;
                    end;
                end;
            end
            else
            begin
                if features[96] <= -228.49999999999997 then
                begin
                    if features[47] <= 52076.000000000007 then
                    begin
                        if features[34] <= 599.50000000000011 then
                        begin
                            Result := -0.021265475102716567;
                        end
                        else
                        begin
                            Result := 0.004924283608804295;
                        end;
                    end
                    else
                    begin
                        if features[43] <= 6938.5000000000009 then
                        begin
                            Result := 0.01063650717900547;
                        end
                        else
                        begin
                            Result := -0.007181668767748622;
                        end;
                    end;
                end
                else
                begin
                    if features[45] <= 2866.5000000000005 then
                    begin
                        if features[80] <= 10.500000000000002 then
                        begin
                            Result := -0.0095939209863489631;
                        end
                        else
                        begin
                            Result := 0.003447879814444573;
                        end;
                    end
                    else
                    begin
                        if features[95] <= -1.0000000180025095E-35 then
                        begin
                            Result := -0.0086297972365285656;
                        end
                        else
                        begin
                            Result := 0.003924626841523165;
                        end;
                    end;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.013116294627087979;
    end;
end;

function exact_edge_auditor_tree_156(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[141] <= 1.5000000000000002 then
    begin
        if features[19] <= 2143.5000000000005 then
        begin
            Result := 0.014621084198249673;
        end
        else
        begin
            if features[140] <= 5.5000000000000009 then
            begin
                if features[20] <= 6.5000000000000009 then
                begin
                    Result := -0.013929197993470192;
                end
                else
                begin
                    Result := 0.0079666138200808825;
                end;
            end
            else
            begin
                Result := 0.0050148208165880807;
            end;
        end;
    end
    else
    begin
        if features[9] <= 1.0000000180025095E-35 then
        begin
            if features[95] <= 1.5000000000000002 then
            begin
                Result := -0.010188161109252752;
            end
            else
            begin
                Result := 0.0095787468987221323;
            end;
        end
        else
        begin
            if features[45] <= 5660.0000000000009 then
            begin
                if features[45] <= 5364.5000000000009 then
                begin
                    if features[64] <= 4846.5000000000009 then
                    begin
                        if features[47] <= 30867.500000000004 then
                        begin
                            Result := 0.0042041527172073951;
                        end
                        else
                        begin
                            Result := -0.015523096916624696;
                        end;
                    end
                    else
                    begin
                        Result := 0.0059443103616308446;
                    end;
                end
                else
                begin
                    if features[7] <= -5748.4999999999991 then
                    begin
                        Result := 0.024220650016389383;
                    end
                    else
                    begin
                        Result := -0.001153199954432189;
                    end;
                end;
            end
            else
            begin
                if features[47] <= 168712.00000000003 then
                begin
                    if features[47] <= 90843.500000000015 then
                    begin
                        if features[20] <= 7.5000000000000009 then
                        begin
                            Result := -0.0066559495611988326;
                        end
                        else
                        begin
                            Result := 0.012099503873754257;
                        end;
                    end
                    else
                    begin
                        Result := -0.017082593352237052;
                    end;
                end
                else
                begin
                    Result := 0.010559754459345696;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_157(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[88] <= 22559.000000000004 then
    begin
        if features[51] <= -6448.4999999999991 then
        begin
            if features[137] <= 1.5000000000000002 then
            begin
                if features[51] <= -6887.4999999999991 then
                begin
                    if features[18] <= 3.5000000000000004 then
                    begin
                        Result := 0.0074193325630125479;
                    end
                    else
                    begin
                        Result := -0.01937717275395013;
                    end;
                end
                else
                begin
                    Result := 0.0078532289373051886;
                end;
            end
            else
            begin
                if features[121] <= 50.500000000000007 then
                begin
                    Result := 0.021066599373371363;
                end
                else
                begin
                    Result := -0.0046257050135477228;
                end;
            end;
        end
        else
        begin
            if features[52] <= -6706.9999999999991 then
            begin
                if features[141] <= 1.5000000000000002 then
                begin
                    Result := 0.0020955256276384516;
                end
                else
                begin
                    if features[49] <= 2.5000000000000004 then
                    begin
                        Result := -0.015794507629372189;
                    end
                    else
                    begin
                        Result := 0.0036825808126311646;
                    end;
                end;
            end
            else
            begin
                if features[30] <= 27.500000000000004 then
                begin
                    if features[3] <= 6.5000000000000009 then
                    begin
                        if features[77] <= 2.5000000000000004 then
                        begin
                            Result := 0.0054001664794758163;
                        end
                        else
                        begin
                            Result := -0.0053074807191684876;
                        end;
                    end
                    else
                    begin
                        if features[121] <= 64.500000000000014 then
                        begin
                            Result := 0.010274643268809417;
                        end
                        else
                        begin
                            Result := -0.0078110563445148622;
                        end;
                    end;
                end
                else
                begin
                    Result := -0.013174094574698066;
                end;
            end;
        end;
    end
    else
    begin
        if features[9] <= 682.00000000000011 then
        begin
            Result := -0.014393264271389344;
        end
        else
        begin
            Result := 0.0051313151163938859;
        end;
    end;
end;

function exact_edge_auditor_tree_158(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[119] <= -429.99999999999994 then
    begin
        if features[20] <= 3.5000000000000004 then
        begin
            Result := -0.0059045288318941873;
        end
        else
        begin
            Result := 0.017563857089358773;
        end;
    end
    else
    begin
        if features[120] <= 8.5000000000000018 then
        begin
            if features[97] <= 732.00000000000011 then
            begin
                if features[105] <= -147.49999999999997 then
                begin
                    if features[102] <= -1157.9999999999998 then
                    begin
                        Result := -0.0073375399734023732;
                    end
                    else
                    begin
                        if features[52] <= -4952.9999999999991 then
                        begin
                            Result := 0.020989494562290906;
                        end
                        else
                        begin
                            Result := -0.0030153570047307247;
                        end;
                    end;
                end
                else
                begin
                    if features[133] <= -2272.4999999999995 then
                    begin
                        if features[52] <= -6133.4999999999991 then
                        begin
                            Result := -0.01676382685528641;
                        end
                        else
                        begin
                            Result := 0.0013015583743015257;
                        end;
                    end
                    else
                    begin
                        if features[51] <= -3457.9999999999995 then
                        begin
                            Result := -0.0015538089484984263;
                        end
                        else
                        begin
                            Result := 0.015216824733314396;
                        end;
                    end;
                end;
            end
            else
            begin
                if features[140] <= 3.5000000000000004 then
                begin
                    if features[52] <= -6455.4999999999991 then
                    begin
                        Result := -0.010487559046701404;
                    end
                    else
                    begin
                        Result := 0.0085437630834044112;
                    end;
                end
                else
                begin
                    Result := 0.017514912531450773;
                end;
            end;
        end
        else
        begin
            if features[110] <= -2.4999999999999996 then
            begin
                Result := 0.0052469770123075056;
            end
            else
            begin
                if features[18] <= 6.5000000000000009 then
                begin
                    Result := -0.020456657282945177;
                end
                else
                begin
                    Result := 0.0041244461217712297;
                end;
            end;
        end;
    end;
end;

function exact_edge_auditor_tree_159(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    if features[71] <= 2.5000000000000004 then
    begin
        if features[83] <= 53833.500000000007 then
        begin
            if features[134] <= 1.0000000180025095E-35 then
            begin
                if features[52] <= -6133.4999999999991 then
                begin
                    Result := -0.0076933755750393396;
                end
                else
                begin
                    if features[73] <= 1435.5000000000002 then
                    begin
                        if features[38] <= 22166.500000000004 then
                        begin
                            Result := 0.018772302420475791;
                        end
                        else
                        begin
                            Result := -0.0018591724834867043;
                        end;
                    end
                    else
                    begin
                        Result := -0.0035076829578067031;
                    end;
                end;
            end
            else
            begin
                if features[44] <= 1343.0000000000002 then
                begin
                    if features[133] <= 6079.5000000000009 then
                    begin
                        Result := 0.016643263915326632;
                    end
                    else
                    begin
                        if features[123] <= -65.499999999999986 then
                        begin
                            Result := -0.0090866839874848872;
                        end
                        else
                        begin
                            Result := 0.0091949957407147283;
                        end;
                    end;
                end
                else
                begin
                    if features[140] <= 1.5000000000000002 then
                    begin
                        Result := 0.0091011232643814482;
                    end
                    else
                    begin
                        if features[128] <= 26062.500000000004 then
                        begin
                            Result := -0.013737108058521028;
                        end
                        else
                        begin
                            Result := 0.004540762649414303;
                        end;
                    end;
                end;
            end;
        end
        else
        begin
            if features[128] <= -135374.99999999997 then
            begin
                Result := -0.011042074508612004;
            end
            else
            begin
                if features[73] <= 2695.5000000000005 then
                begin
                    if features[123] <= 77.500000000000014 then
                    begin
                        Result := 0.021377512727270107;
                    end
                    else
                    begin
                        Result := -0.0036824402155641095;
                    end;
                end
                else
                begin
                    Result := -0.0079466981256170171;
                end;
            end;
        end;
    end
    else
    begin
        Result := -0.012861256138062369;
    end;
end;
function long_exact_edge_auditor_score(
    const features: TncLongExactEdgeAuditorFeatures): Double;
begin
    Result := 0.0;
    Result := Result + exact_edge_auditor_tree_0(features);
    Result := Result + exact_edge_auditor_tree_1(features);
    Result := Result + exact_edge_auditor_tree_2(features);
    Result := Result + exact_edge_auditor_tree_3(features);
    Result := Result + exact_edge_auditor_tree_4(features);
    Result := Result + exact_edge_auditor_tree_5(features);
    Result := Result + exact_edge_auditor_tree_6(features);
    Result := Result + exact_edge_auditor_tree_7(features);
    Result := Result + exact_edge_auditor_tree_8(features);
    Result := Result + exact_edge_auditor_tree_9(features);
    Result := Result + exact_edge_auditor_tree_10(features);
    Result := Result + exact_edge_auditor_tree_11(features);
    Result := Result + exact_edge_auditor_tree_12(features);
    Result := Result + exact_edge_auditor_tree_13(features);
    Result := Result + exact_edge_auditor_tree_14(features);
    Result := Result + exact_edge_auditor_tree_15(features);
    Result := Result + exact_edge_auditor_tree_16(features);
    Result := Result + exact_edge_auditor_tree_17(features);
    Result := Result + exact_edge_auditor_tree_18(features);
    Result := Result + exact_edge_auditor_tree_19(features);
    Result := Result + exact_edge_auditor_tree_20(features);
    Result := Result + exact_edge_auditor_tree_21(features);
    Result := Result + exact_edge_auditor_tree_22(features);
    Result := Result + exact_edge_auditor_tree_23(features);
    Result := Result + exact_edge_auditor_tree_24(features);
    Result := Result + exact_edge_auditor_tree_25(features);
    Result := Result + exact_edge_auditor_tree_26(features);
    Result := Result + exact_edge_auditor_tree_27(features);
    Result := Result + exact_edge_auditor_tree_28(features);
    Result := Result + exact_edge_auditor_tree_29(features);
    Result := Result + exact_edge_auditor_tree_30(features);
    Result := Result + exact_edge_auditor_tree_31(features);
    Result := Result + exact_edge_auditor_tree_32(features);
    Result := Result + exact_edge_auditor_tree_33(features);
    Result := Result + exact_edge_auditor_tree_34(features);
    Result := Result + exact_edge_auditor_tree_35(features);
    Result := Result + exact_edge_auditor_tree_36(features);
    Result := Result + exact_edge_auditor_tree_37(features);
    Result := Result + exact_edge_auditor_tree_38(features);
    Result := Result + exact_edge_auditor_tree_39(features);
    Result := Result + exact_edge_auditor_tree_40(features);
    Result := Result + exact_edge_auditor_tree_41(features);
    Result := Result + exact_edge_auditor_tree_42(features);
    Result := Result + exact_edge_auditor_tree_43(features);
    Result := Result + exact_edge_auditor_tree_44(features);
    Result := Result + exact_edge_auditor_tree_45(features);
    Result := Result + exact_edge_auditor_tree_46(features);
    Result := Result + exact_edge_auditor_tree_47(features);
    Result := Result + exact_edge_auditor_tree_48(features);
    Result := Result + exact_edge_auditor_tree_49(features);
    Result := Result + exact_edge_auditor_tree_50(features);
    Result := Result + exact_edge_auditor_tree_51(features);
    Result := Result + exact_edge_auditor_tree_52(features);
    Result := Result + exact_edge_auditor_tree_53(features);
    Result := Result + exact_edge_auditor_tree_54(features);
    Result := Result + exact_edge_auditor_tree_55(features);
    Result := Result + exact_edge_auditor_tree_56(features);
    Result := Result + exact_edge_auditor_tree_57(features);
    Result := Result + exact_edge_auditor_tree_58(features);
    Result := Result + exact_edge_auditor_tree_59(features);
    Result := Result + exact_edge_auditor_tree_60(features);
    Result := Result + exact_edge_auditor_tree_61(features);
    Result := Result + exact_edge_auditor_tree_62(features);
    Result := Result + exact_edge_auditor_tree_63(features);
    Result := Result + exact_edge_auditor_tree_64(features);
    Result := Result + exact_edge_auditor_tree_65(features);
    Result := Result + exact_edge_auditor_tree_66(features);
    Result := Result + exact_edge_auditor_tree_67(features);
    Result := Result + exact_edge_auditor_tree_68(features);
    Result := Result + exact_edge_auditor_tree_69(features);
    Result := Result + exact_edge_auditor_tree_70(features);
    Result := Result + exact_edge_auditor_tree_71(features);
    Result := Result + exact_edge_auditor_tree_72(features);
    Result := Result + exact_edge_auditor_tree_73(features);
    Result := Result + exact_edge_auditor_tree_74(features);
    Result := Result + exact_edge_auditor_tree_75(features);
    Result := Result + exact_edge_auditor_tree_76(features);
    Result := Result + exact_edge_auditor_tree_77(features);
    Result := Result + exact_edge_auditor_tree_78(features);
    Result := Result + exact_edge_auditor_tree_79(features);
    Result := Result + exact_edge_auditor_tree_80(features);
    Result := Result + exact_edge_auditor_tree_81(features);
    Result := Result + exact_edge_auditor_tree_82(features);
    Result := Result + exact_edge_auditor_tree_83(features);
    Result := Result + exact_edge_auditor_tree_84(features);
    Result := Result + exact_edge_auditor_tree_85(features);
    Result := Result + exact_edge_auditor_tree_86(features);
    Result := Result + exact_edge_auditor_tree_87(features);
    Result := Result + exact_edge_auditor_tree_88(features);
    Result := Result + exact_edge_auditor_tree_89(features);
    Result := Result + exact_edge_auditor_tree_90(features);
    Result := Result + exact_edge_auditor_tree_91(features);
    Result := Result + exact_edge_auditor_tree_92(features);
    Result := Result + exact_edge_auditor_tree_93(features);
    Result := Result + exact_edge_auditor_tree_94(features);
    Result := Result + exact_edge_auditor_tree_95(features);
    Result := Result + exact_edge_auditor_tree_96(features);
    Result := Result + exact_edge_auditor_tree_97(features);
    Result := Result + exact_edge_auditor_tree_98(features);
    Result := Result + exact_edge_auditor_tree_99(features);
    Result := Result + exact_edge_auditor_tree_100(features);
    Result := Result + exact_edge_auditor_tree_101(features);
    Result := Result + exact_edge_auditor_tree_102(features);
    Result := Result + exact_edge_auditor_tree_103(features);
    Result := Result + exact_edge_auditor_tree_104(features);
    Result := Result + exact_edge_auditor_tree_105(features);
    Result := Result + exact_edge_auditor_tree_106(features);
    Result := Result + exact_edge_auditor_tree_107(features);
    Result := Result + exact_edge_auditor_tree_108(features);
    Result := Result + exact_edge_auditor_tree_109(features);
    Result := Result + exact_edge_auditor_tree_110(features);
    Result := Result + exact_edge_auditor_tree_111(features);
    Result := Result + exact_edge_auditor_tree_112(features);
    Result := Result + exact_edge_auditor_tree_113(features);
    Result := Result + exact_edge_auditor_tree_114(features);
    Result := Result + exact_edge_auditor_tree_115(features);
    Result := Result + exact_edge_auditor_tree_116(features);
    Result := Result + exact_edge_auditor_tree_117(features);
    Result := Result + exact_edge_auditor_tree_118(features);
    Result := Result + exact_edge_auditor_tree_119(features);
    Result := Result + exact_edge_auditor_tree_120(features);
    Result := Result + exact_edge_auditor_tree_121(features);
    Result := Result + exact_edge_auditor_tree_122(features);
    Result := Result + exact_edge_auditor_tree_123(features);
    Result := Result + exact_edge_auditor_tree_124(features);
    Result := Result + exact_edge_auditor_tree_125(features);
    Result := Result + exact_edge_auditor_tree_126(features);
    Result := Result + exact_edge_auditor_tree_127(features);
    Result := Result + exact_edge_auditor_tree_128(features);
    Result := Result + exact_edge_auditor_tree_129(features);
    Result := Result + exact_edge_auditor_tree_130(features);
    Result := Result + exact_edge_auditor_tree_131(features);
    Result := Result + exact_edge_auditor_tree_132(features);
    Result := Result + exact_edge_auditor_tree_133(features);
    Result := Result + exact_edge_auditor_tree_134(features);
    Result := Result + exact_edge_auditor_tree_135(features);
    Result := Result + exact_edge_auditor_tree_136(features);
    Result := Result + exact_edge_auditor_tree_137(features);
    Result := Result + exact_edge_auditor_tree_138(features);
    Result := Result + exact_edge_auditor_tree_139(features);
    Result := Result + exact_edge_auditor_tree_140(features);
    Result := Result + exact_edge_auditor_tree_141(features);
    Result := Result + exact_edge_auditor_tree_142(features);
    Result := Result + exact_edge_auditor_tree_143(features);
    Result := Result + exact_edge_auditor_tree_144(features);
    Result := Result + exact_edge_auditor_tree_145(features);
    Result := Result + exact_edge_auditor_tree_146(features);
    Result := Result + exact_edge_auditor_tree_147(features);
    Result := Result + exact_edge_auditor_tree_148(features);
    Result := Result + exact_edge_auditor_tree_149(features);
    Result := Result + exact_edge_auditor_tree_150(features);
    Result := Result + exact_edge_auditor_tree_151(features);
    Result := Result + exact_edge_auditor_tree_152(features);
    Result := Result + exact_edge_auditor_tree_153(features);
    Result := Result + exact_edge_auditor_tree_154(features);
    Result := Result + exact_edge_auditor_tree_155(features);
    Result := Result + exact_edge_auditor_tree_156(features);
    Result := Result + exact_edge_auditor_tree_157(features);
    Result := Result + exact_edge_auditor_tree_158(features);
    Result := Result + exact_edge_auditor_tree_159(features);
end;

function long_exact_edge_auditor_self_test: Boolean;
const
    c_tolerance = 1E-8;
var
    features: TncLongExactEdgeAuditorFeatures;
    idx: Integer;
begin
    features := Default(TncLongExactEdgeAuditorFeatures);
    if Abs(long_exact_edge_auditor_score(features) -
        0.54424026763767108) > c_tolerance then
    begin
        Exit(False);
    end;
    for idx := 0 to High(features) do
    begin
        features[idx] := -100.0;
    end;
    if Abs(long_exact_edge_auditor_score(features) -
        0.79551303251165995) > c_tolerance then
    begin
        Exit(False);
    end;
    for idx := 0 to High(features) do
    begin
        features[idx] := 100.0;
    end;
    if Abs(long_exact_edge_auditor_score(features) -
        0.3798784532207517) > c_tolerance then
    begin
        Exit(False);
    end;
    for idx := 0 to High(features) do
    begin
        if Odd(idx) then
        begin
            features[idx] := -(idx + 1);
        end
        else
        begin
            features[idx] := idx + 1;
        end;
    end;
    Result := Abs(long_exact_edge_auditor_score(features) -
        0.43648905721191883) <= c_tolerance;
end;

end.
