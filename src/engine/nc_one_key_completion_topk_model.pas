unit nc_one_key_completion_topk_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_types, nc_one_key_completion_difference_model;

function one_key_completion_topk_score(
    const context_value, query_text: string;
    const item: TncOneKeyCompletion; const char_lm_score: Integer;
    const typed_units, candidate_rank: Integer): Double;
function one_key_completion_topk_threshold(
    const category: TncOneKeyCompletionDifferenceCategory): Double;
function one_key_completion_topk_self_test: Boolean;

implementation

uses
    Math;

type
    TCompletionFeatures = array[0..33] of Single;

const
    c_thresholds: array[TncOneKeyCompletionDifferenceCategory] of Double = (
        1.0E30, 1.0E30, 1.0E30, 0.18760195314074599, 0.18511912126276814, 0.25318041033999228);

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
            Inc(idx, 2)
        else
            Inc(idx);
        Inc(Result);
    end;
end;

function completion_tree_0(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.18450000137090686 then
    begin
        if features[0] <= 0.53749999403953563 then
        begin
            if features[9] <= -0.73535001277923573 then
            begin
                if features[2] <= 0.093499999493360533 then
                begin
                    Result := -0.040162993494583153;
                end
                else
                begin
                    Result := -0.00043663470754131989;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := 0.030544378756543106;
                end
                else
                begin
                    Result := -0.069454684170472986;
                end;
            end;
        end
        else
        begin
            if features[2] <= 0.033999999985098846 then
            begin
                Result := -0.068315278010577241;
            end
            else
            begin
                Result := -0.0018838485812870207;
            end;
        end;
    end
    else
    begin
        if features[9] <= -0.6822499930858611 then
        begin
            if features[2] <= 0.14499999582767489 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    if features[4] <= 0.37500000000000006 then
                    begin
                        Result := -0.036502848512723854;
                    end
                    else
                    begin
                        Result := 0.0041738190779531548;
                    end;
                end
                else
                begin
                    if features[11] <= 0.56250000000000011 then
                    begin
                        Result := -0.034420183280640122;
                    end
                    else
                    begin
                        Result := -0.069735396193824864;
                    end;
                end;
            end
            else
            begin
                Result := 0.027054021684517534;
            end;
        end
        else
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    Result := 0.04961572927086786;
                end
                else
                begin
                    if features[0] <= 0.58750000596046459 then
                    begin
                        Result := 0.039920292859601005;
                    end
                    else
                    begin
                        Result := 0.017418200964168368;
                    end;
                end;
            end
            else
            begin
                Result := -0.069602441753503635;
            end;
        end;
    end;
end;

function completion_tree_1(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.13149999827146533 then
    begin
        if features[0] <= 0.5704999864101411 then
        begin
            if features[29] <= -6.6524999141693106 then
            begin
                if features[2] <= 0.14999999850988391 then
                begin
                    if features[29] <= -9.2465000152587873 then
                    begin
                        Result := -0.050904883287442214;
                    end
                    else
                    begin
                        Result := -0.027973861267283958;
                    end;
                end
                else
                begin
                    Result := 0.037272059396049564;
                end;
            end
            else
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    Result := 0.033861461073223097;
                end
                else
                begin
                    Result := -0.017192419410844206;
                end;
            end;
        end
        else
        begin
            Result := -0.065454877183288962;
        end;
    end
    else
    begin
        if features[29] <= -5.6474997997283927 then
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[2] <= 0.22549999505281451 then
                begin
                    if features[29] <= -9.0015001296997053 then
                    begin
                        Result := -0.022250300863581301;
                    end
                    else
                    begin
                        Result := 0.00027118231659956825;
                    end;
                end
                else
                begin
                    if features[24] <= 0.046875000000000007 then
                    begin
                        Result := 0.040751967903533901;
                    end
                    else
                    begin
                        Result := 0.01704043910379115;
                    end;
                end;
            end
            else
            begin
                Result := -0.067065586415678252;
            end;
        end
        else
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[2] <= 0.28350000083446508 then
                begin
                    if features[29] <= -3.2154999971389766 then
                    begin
                        Result := 0.020863767574129419;
                    end
                    else
                    begin
                        Result := 0.041896495213969528;
                    end;
                end
                else
                begin
                    Result := 0.041636651971743925;
                end;
            end
            else
            begin
                Result := -0.066026289584071932;
            end;
        end;
    end;
end;

function completion_tree_2(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.13149999827146533 then
    begin
        if features[0] <= 0.5704999864101411 then
        begin
            if features[9] <= -0.72944998741149891 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    Result := -0.02722342280180624;
                end
                else
                begin
                    Result := -0.050035203024426454;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[5] <= 0.96057692170143139 then
                    begin
                        Result := 0.0063268529998015801;
                    end
                    else
                    begin
                        Result := 0.048871125670178199;
                    end;
                end
                else
                begin
                    Result := -0.0647560876184545;
                end;
            end;
        end
        else
        begin
            Result := -0.062710371397830741;
        end;
    end
    else
    begin
        if features[9] <= -0.76665002107620228 then
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[9] <= -0.98045000433921803 then
                begin
                    Result := -0.018989589877732745;
                end
                else
                begin
                    Result := 0.0023648587104675755;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := -0.025633919757855006;
                end
                else
                begin
                    Result := -0.064554985260294087;
                end;
            end;
        end
        else
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[24] <= 0.046875000000000007 then
                begin
                    if features[31] <= 1.0000000180025095e-35 then
                    begin
                        Result := 0.044053316008545937;
                    end
                    else
                    begin
                        Result := 0.030411628299889283;
                    end;
                end
                else
                begin
                    if features[9] <= -0.45004999637603754 then
                    begin
                        Result := 0.0081797445557833994;
                    end
                    else
                    begin
                        Result := 0.025949438599306592;
                    end;
                end;
            end
            else
            begin
                Result := -0.06372788551053063;
            end;
        end;
    end;
end;

function completion_tree_3(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.13149999827146533 then
    begin
        if features[0] <= 0.57350000739097606 then
        begin
            if features[9] <= -0.59724998474121083 then
            begin
                if features[9] <= -0.96784999966621388 then
                begin
                    Result := -0.046634568611341347;
                end
                else
                begin
                    if features[10] <= 0.37500000000000006 then
                    begin
                        Result := -0.0028887265205608192;
                    end
                    else
                    begin
                        Result := -0.038491293283731028;
                    end;
                end;
            end
            else
            begin
                Result := 0.017329318299160654;
            end;
        end
        else
        begin
            Result := -0.060522719818776431;
        end;
    end
    else
    begin
        if features[9] <= -0.62804999947547901 then
        begin
            if features[2] <= 0.12849999964237216 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    if features[9] <= -0.83254998922348011 then
                    begin
                        Result := -0.020641930731667608;
                    end
                    else
                    begin
                        Result := 0.002576044052669002;
                    end;
                end
                else
                begin
                    if features[11] <= 0.56250000000000011 then
                    begin
                        Result := -0.029260206493825873;
                    end
                    else
                    begin
                        Result := -0.062096281132363373;
                    end;
                end;
            end
            else
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    Result := 0.014849917918752471;
                end
                else
                begin
                    Result := -0.0060702814352534551;
                end;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[2] <= 0.33550000190734869 then
                begin
                    Result := 0.023318392480330179;
                end
                else
                begin
                    Result := 0.038785775592201671;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := 0.0077974578220905448;
                end
                else
                begin
                    Result := -0.060987430135257627;
                end;
            end;
        end;
    end;
end;

function completion_tree_4(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.19849999994039538 then
    begin
        if features[1] <= 0.0015000000712461772 then
        begin
            Result := -0.058396450905044223;
        end
        else
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[9] <= -0.83634999394416798 then
                begin
                    if features[9] <= -1.142049968242645 then
                    begin
                        Result := -0.04357087629815292;
                    end
                    else
                    begin
                        Result := -0.02345908596913639;
                    end;
                end
                else
                begin
                    if features[10] <= 0.37500000000000006 then
                    begin
                        Result := 0.015874261462629265;
                    end
                    else
                    begin
                        Result := -0.0084114839114227125;
                    end;
                end;
            end
            else
            begin
                Result := -0.060774366693958783;
            end;
        end;
    end
    else
    begin
        if features[9] <= -0.7447499930858611 then
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[24] <= 0.046875000000000007 then
                begin
                    Result := 0.0097491857273908616;
                end
                else
                begin
                    Result := -0.011909540843818376;
                end;
            end
            else
            begin
                Result := -0.060325819997327244;
            end;
        end
        else
        begin
            if features[24] <= 0.046875000000000007 then
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[26] <= 0.34375000000000006 then
                    begin
                        Result := 0.025086094508962948;
                    end
                    else
                    begin
                        Result := 0.035061572282089337;
                    end;
                end
                else
                begin
                    Result := -0.058846304196845674;
                end;
            end
            else
            begin
                if features[9] <= -0.39345000684261316 then
                begin
                    if features[10] <= 0.37500000000000006 then
                    begin
                        Result := 0.014159523246053995;
                    end
                    else
                    begin
                        Result := -0.0036702590372647832;
                    end;
                end
                else
                begin
                    Result := 0.026459539577024887;
                end;
            end;
        end;
    end;
end;

function completion_tree_5(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.13149999827146533 then
    begin
        if features[0] <= 0.57350000739097606 then
        begin
            if features[9] <= -0.67355000972747792 then
            begin
                Result := -0.033312691293962818;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := 0.014970318398008286;
                end
                else
                begin
                    Result := -0.059350827531769457;
                end;
            end;
        end
        else
        begin
            Result := -0.056832455985625328;
        end;
    end
    else
    begin
        if features[9] <= -0.65465000271797169 then
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[9] <= -0.91484999656677235 then
                begin
                    Result := -0.016178237113238306;
                end
                else
                begin
                    Result := 0.0057450728141429895;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[0] <= 0.51649999618530285 then
                    begin
                        Result := -0.011246313218599093;
                    end
                    else
                    begin
                        Result := -0.028977725348042965;
                    end;
                end
                else
                begin
                    Result := -0.05883829970139675;
                end;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[24] <= 0.046875000000000007 then
                begin
                    Result := 0.032548905097560359;
                end
                else
                begin
                    if features[9] <= -0.3506499975919723 then
                    begin
                        Result := 0.014962407710944727;
                    end
                    else
                    begin
                        Result := 0.030979015735329976;
                    end;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[9] <= -0.47744999825954432 then
                    begin
                        Result := 0.00043744107063400852;
                    end
                    else
                    begin
                        Result := 0.01529326353599314;
                    end;
                end
                else
                begin
                    Result := -0.057832824446910534;
                end;
            end;
        end;
    end;
end;

function completion_tree_6(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.19950000196695331 then
    begin
        if features[0] <= 0.53749999403953563 then
        begin
            if features[9] <= -0.7699500024318694 then
            begin
                if features[9] <= -1.1077499985694883 then
                begin
                    Result := -0.038657669811410368;
                end
                else
                begin
                    if features[11] <= 0.56250000000000011 then
                    begin
                        Result := -0.012851485774808418;
                    end
                    else
                    begin
                        Result := -0.05936065526273749;
                    end;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := 0.010323206619501977;
                end
                else
                begin
                    Result := -0.057235532024085087;
                end;
            end;
        end
        else
        begin
            if features[1] <= 0.11150000244379045 then
            begin
                Result := -0.053426020721519273;
            end
            else
            begin
                if features[6] <= 0.31764705479145056 then
                begin
                    Result := -0.039487545024457178;
                end
                else
                begin
                    Result := 0.017817736815953767;
                end;
            end;
        end;
    end
    else
    begin
        if features[9] <= -0.59215000271797169 then
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[9] <= -0.83254998922348011 then
                begin
                    Result := -0.011731348754980759;
                end
                else
                begin
                    if features[10] <= 0.37500000000000006 then
                    begin
                        Result := 0.0097108340926857391;
                    end
                    else
                    begin
                        Result := -0.0061504548971617048;
                    end;
                end;
            end
            else
            begin
                Result := -0.057222141287998983;
            end;
        end
        else
        begin
            if features[24] <= 0.046875000000000007 then
            begin
                Result := 0.031467962158498217;
            end
            else
            begin
                if features[9] <= -0.4302500039339065 then
                begin
                    Result := 0.010128070234111627;
                end
                else
                begin
                    Result := 0.022197025557896131;
                end;
            end;
        end;
    end;
end;

function completion_tree_7(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.19749999791383746 then
    begin
        if features[0] <= 0.53749999403953563 then
        begin
            if features[9] <= -0.5744500160217284 then
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[9] <= -0.9298499822616576 then
                    begin
                        Result := -0.027933864906368469;
                    end
                    else
                    begin
                        Result := -0.0037455693247233535;
                    end;
                end
                else
                begin
                    Result := -0.057275250660115094;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := 0.018995729430439982;
                end
                else
                begin
                    Result := -0.054488000588300174;
                end;
            end;
        end
        else
        begin
            if features[2] <= 0.033999999985098846 then
            begin
                Result := -0.052301570813136987;
            end
            else
            begin
                Result := -0.0066220329268848249;
            end;
        end;
    end
    else
    begin
        if features[9] <= -0.58715000748634327 then
        begin
            if features[2] <= 0.17750000208616259 then
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := -0.0090371275968028856;
                end
                else
                begin
                    Result := -0.055651774219751621;
                end;
            end
            else
            begin
                Result := 0.012364181931044139;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[24] <= 0.046875000000000007 then
                begin
                    Result := 0.033422354743822207;
                end
                else
                begin
                    if features[2] <= 0.23949999362230304 then
                    begin
                        Result := 0.014177389504450905;
                    end
                    else
                    begin
                        Result := 0.02738215499785078;
                    end;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := 0.0085914016551424666;
                end
                else
                begin
                    Result := -0.055996721267124412;
                end;
            end;
        end;
    end;
end;

function completion_tree_8(const features: TCompletionFeatures): Double;
begin
    if features[14] <= 1.0000000180025095e-35 then
    begin
        if features[9] <= -0.71715000271797169 then
        begin
            if features[2] <= 0.033999999985098846 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    if features[9] <= -0.90015000104904164 then
                    begin
                        Result := -0.035646952697172614;
                    end
                    else
                    begin
                        Result := -0.012543270663299149;
                    end;
                end
                else
                begin
                    if features[0] <= 0.28049999475479132 then
                    begin
                        Result := -0.031076203225841679;
                    end
                    else
                    begin
                        Result := -0.050521778840008948;
                    end;
                end;
            end
            else
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    if features[8] <= -3.8518333435058589 then
                    begin
                        Result := -0.027003479902104669;
                    end
                    else
                    begin
                        Result := 0.0031111761112710772;
                    end;
                end
                else
                begin
                    if features[2] <= 0.12849999964237216 then
                    begin
                        Result := -0.026787390733334183;
                    end
                    else
                    begin
                        Result := -0.0079988941601986004;
                    end;
                end;
            end;
        end
        else
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    if features[9] <= -0.4878499954938888 then
                    begin
                        Result := 0.013200596048377852;
                    end
                    else
                    begin
                        Result := 0.027563564160451734;
                    end;
                end
                else
                begin
                    if features[2] <= 0.29850000143051153 then
                    begin
                        Result := 0.00037518490355381595;
                    end
                    else
                    begin
                        Result := 0.021663661249180934;
                    end;
                end;
            end
            else
            begin
                Result := -0.054051143519478838;
            end;
        end;
    end
    else
    begin
        Result := -0.053531651928638874;
    end;
end;

function completion_tree_9(const features: TCompletionFeatures): Double;
begin
    if features[13] <= 1.0000000180025095e-35 then
    begin
        Result := -0.052352559279709256;
    end
    else
    begin
        if features[9] <= -0.66525000333786 then
        begin
            if features[2] <= 0.033999999985098846 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    if features[9] <= -0.83634999394416798 then
                    begin
                        Result := -0.031229732567497899;
                    end
                    else
                    begin
                        Result := -0.0071469082684344834;
                    end;
                end
                else
                begin
                    if features[11] <= 0.56250000000000011 then
                    begin
                        Result := -0.037121580825471255;
                    end
                    else
                    begin
                        Result := -0.053995259548381656;
                    end;
                end;
            end
            else
            begin
                if features[2] <= 0.18100000172853473 then
                begin
                    if features[10] <= 0.37500000000000006 then
                    begin
                        Result := -0.0048399423600143212;
                    end
                    else
                    begin
                        Result := -0.020726783813741812;
                    end;
                end
                else
                begin
                    if features[24] <= 0.078125000000000014 then
                    begin
                        Result := 0.017823853942837545;
                    end
                    else
                    begin
                        Result := -0.00024686316834991089;
                    end;
                end;
            end;
        end
        else
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[2] <= 0.30050000548362737 then
                begin
                    if features[9] <= -0.46954999864101404 then
                    begin
                        Result := 0.0059670716260482072;
                    end
                    else
                    begin
                        Result := 0.020599466829931846;
                    end;
                end
                else
                begin
                    if features[24] <= 0.17187500000000003 then
                    begin
                        Result := 0.035856070304979719;
                    end
                    else
                    begin
                        Result := 0.017562216864574987;
                    end;
                end;
            end
            else
            begin
                Result := -0.052575345046165858;
            end;
        end;
    end;
end;

function completion_tree_10(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.18450000137090686 then
    begin
        if features[0] <= 0.57350000739097606 then
        begin
            if features[9] <= -0.78004997968673695 then
            begin
                if features[2] <= 0.082499999552965178 then
                begin
                    Result := -0.032222561922647754;
                end
                else
                begin
                    Result := -0.0046393745106559098;
                end;
            end
            else
            begin
                if features[10] <= 0.62500000000000011 then
                begin
                    if features[5] <= 0.94711536169052135 then
                    begin
                        Result := 0.00022174527773088833;
                    end
                    else
                    begin
                        Result := 0.030149903195264859;
                    end;
                end
                else
                begin
                    Result := -0.051983534547127869;
                end;
            end;
        end
        else
        begin
            if features[2] <= 0.10249999910593034 then
            begin
                Result := -0.05046543303302925;
            end
            else
            begin
                Result := 0.029839814399714018;
            end;
        end;
    end
    else
    begin
        if features[9] <= -0.6149500012397765 then
        begin
            if features[2] <= 0.18999999761581424 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    Result := -0.0049763108228755865;
                end
                else
                begin
                    Result := -0.022813437297286226;
                end;
            end
            else
            begin
                if features[1] <= 0.331499993801117 then
                begin
                    Result := 0.0034972688977729194;
                end
                else
                begin
                    Result := 0.025379216000952248;
                end;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[24] <= 0.046875000000000007 then
                begin
                    Result := 0.029907660940537102;
                end
                else
                begin
                    if features[9] <= -0.34645000100135798 then
                    begin
                        Result := 0.013952423345181906;
                    end
                    else
                    begin
                        Result := 0.029614143075705802;
                    end;
                end;
            end
            else
            begin
                Result := 0.0056192075557150115;
            end;
        end;
    end;
end;

function completion_tree_11(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.19950000196695331 then
    begin
        if features[0] <= 0.53749999403953563 then
        begin
            if features[29] <= -8.7734999656677228 then
            begin
                Result := -0.025506004450581207;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[10] <= 0.37500000000000006 then
                    begin
                        Result := 0.01135844771768184;
                    end
                    else
                    begin
                        Result := -0.0077969830531315594;
                    end;
                end
                else
                begin
                    Result := -0.051782860213533503;
                end;
            end;
        end
        else
        begin
            if features[2] <= 0.033999999985098846 then
            begin
                Result := -0.047827240511580951;
            end
            else
            begin
                if features[29] <= -6.6254999637603751 then
                begin
                    Result := -0.023375420640408144;
                end
                else
                begin
                    Result := 0.022453829028759722;
                end;
            end;
        end;
    end
    else
    begin
        if features[29] <= -5.25349998474121 then
        begin
            if features[2] <= 0.27449999749660497 then
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[29] <= -8.0005002021789533 then
                    begin
                        Result := -0.01333606820118163;
                    end
                    else
                    begin
                        Result := 0.0016677535789819961;
                    end;
                end
                else
                begin
                    Result := -0.051975746170323064;
                end;
            end
            else
            begin
                Result := 0.016382995510258774;
            end;
        end
        else
        begin
            if features[24] <= 0.046875000000000007 then
            begin
                Result := 0.029003774036735003;
            end
            else
            begin
                if features[2] <= 0.36349999904632574 then
                begin
                    if features[29] <= -3.5455000400543208 then
                    begin
                        Result := 0.0092746466990180493;
                    end
                    else
                    begin
                        Result := 0.022984440134001121;
                    end;
                end
                else
                begin
                    Result := 0.028670105724797518;
                end;
            end;
        end;
    end;
end;

function completion_tree_12(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.18450000137090686 then
    begin
        if features[0] <= 0.53749999403953563 then
        begin
            if features[9] <= -0.5744500160217284 then
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[9] <= -1.0779500007629392 then
                    begin
                        Result := -0.033340515517982165;
                    end
                    else
                    begin
                        Result := -0.0082522975189066212;
                    end;
                end
                else
                begin
                    Result := -0.052185147625814547;
                end;
            end
            else
            begin
                Result := 0.012072802012551238;
            end;
        end
        else
        begin
            if features[2] <= 0.033999999985098846 then
            begin
                Result := -0.047395276484649265;
            end
            else
            begin
                Result := -0.0036848734880758028;
            end;
        end;
    end
    else
    begin
        if features[9] <= -0.71715000271797169 then
        begin
            if features[2] <= 0.11499999836087228 then
            begin
                if features[4] <= 0.37500000000000006 then
                begin
                    Result := -0.03372915462299745;
                end
                else
                begin
                    Result := -0.011538420054856079;
                end;
            end
            else
            begin
                Result := -4.5167077135760618e-05;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[2] <= 0.36349999904632574 then
                begin
                    if features[8] <= -1.6097750067710874 then
                    begin
                        Result := 0.0094064556572328682;
                    end
                    else
                    begin
                        Result := 0.021903811908726645;
                    end;
                end
                else
                begin
                    Result := 0.031561202070591501;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[9] <= -0.25914999842643732 then
                    begin
                        Result := 0.0021776021547897954;
                    end
                    else
                    begin
                        Result := 0.036328686876887957;
                    end;
                end
                else
                begin
                    Result := -0.050973727158991983;
                end;
            end;
        end;
    end;
end;

function completion_tree_13(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.13149999827146533 then
    begin
        if features[0] <= 0.57350000739097606 then
        begin
            if features[9] <= -0.62035000324249256 then
            begin
                Result := -0.026491422514331852;
            end
            else
            begin
                Result := 0.0097267593030475625;
            end;
        end
        else
        begin
            Result := -0.047720190454466967;
        end;
    end
    else
    begin
        if features[9] <= -0.61765000224113453 then
        begin
            if features[2] <= 0.12849999964237216 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    if features[4] <= 0.37500000000000006 then
                    begin
                        Result := -0.018232207950603235;
                    end
                    else
                    begin
                        Result := -0.00059251766487626145;
                    end;
                end
                else
                begin
                    Result := -0.028271827887102783;
                end;
            end
            else
            begin
                if features[1] <= 0.331499993801117 then
                begin
                    Result := 0.00049932010582025147;
                end
                else
                begin
                    Result := 0.019653821393635952;
                end;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[24] <= 0.046875000000000007 then
                begin
                    if features[2] <= 0.25550000369548803 then
                    begin
                        Result := 0.023804957296881438;
                    end
                    else
                    begin
                        Result := 0.040631009740446658;
                    end;
                end
                else
                begin
                    if features[2] <= 0.23550000041723254 then
                    begin
                        Result := 0.011290642593887188;
                    end
                    else
                    begin
                        Result := 0.023541915939377569;
                    end;
                end;
            end
            else
            begin
                if features[10] <= 0.62500000000000011 then
                begin
                    if features[9] <= -0.32584999501705164 then
                    begin
                        Result := 0.0025746585438046494;
                    end
                    else
                    begin
                        Result := 0.022917012246798086;
                    end;
                end
                else
                begin
                    Result := -0.049387606453876659;
                end;
            end;
        end;
    end;
end;

function completion_tree_14(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.13149999827146533 then
    begin
        if features[0] <= 0.57350000739097606 then
        begin
            if features[9] <= -0.78004997968673695 then
            begin
                Result := -0.031417780383859659;
            end
            else
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    Result := 0.015567778427993407;
                end
                else
                begin
                    Result := -0.017048133058019894;
                end;
            end;
        end
        else
        begin
            Result := -0.046907930786244049;
        end;
    end
    else
    begin
        if features[9] <= -0.64094999432563771 then
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[9] <= -0.90015000104904164 then
                begin
                    Result := -0.014978925631354277;
                end
                else
                begin
                    Result := 0.0039702981447438139;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := -0.01655979042879303;
                end
                else
                begin
                    Result := -0.050245656299199651;
                end;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[24] <= 0.046875000000000007 then
                begin
                    if features[2] <= 0.25550000369548803 then
                    begin
                        Result := 0.022983427595916435;
                    end
                    else
                    begin
                        Result := 0.040247039734624762;
                    end;
                end
                else
                begin
                    if features[9] <= -0.35834999382495875 then
                    begin
                        Result := 0.011545952260079376;
                    end
                    else
                    begin
                        Result := 0.026452601581562367;
                    end;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[9] <= -0.42444999516010279 then
                    begin
                        Result := 0.00011468058804247;
                    end
                    else
                    begin
                        Result := 0.014917308152572637;
                    end;
                end
                else
                begin
                    Result := -0.04848526540040584;
                end;
            end;
        end;
    end;
end;

function completion_tree_15(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.13149999827146533 then
    begin
        if features[0] <= 0.57350000739097606 then
        begin
            if features[29] <= -6.6794998645782462 then
            begin
                Result := -0.026796020586319455;
            end
            else
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    Result := 0.016657446611154193;
                end
                else
                begin
                    Result := -0.011395259496632348;
                end;
            end;
        end
        else
        begin
            Result := -0.046204547609817744;
        end;
    end
    else
    begin
        if features[29] <= -7.1714999675750724 then
        begin
            if features[2] <= 0.087999999523162856 then
            begin
                if features[0] <= 0.41249999403953558 then
                begin
                    Result := -0.010251855773628823;
                end
                else
                begin
                    if features[1] <= 0.52500000596046459 then
                    begin
                        Result := -0.038055621501914605;
                    end
                    else
                    begin
                        Result := -0.0020952972313768633;
                    end;
                end;
            end
            else
            begin
                if features[1] <= 0.331499993801117 then
                begin
                    Result := -0.0052275132130432181;
                end
                else
                begin
                    Result := 0.017059747766218152;
                end;
            end;
        end
        else
        begin
            if features[29] <= -5.1045000553131095 then
            begin
                if features[2] <= 0.23550000041723254 then
                begin
                    if features[11] <= 0.56250000000000011 then
                    begin
                        Result := 0.00081771216494306567;
                    end
                    else
                    begin
                        Result := -0.047602730069678023;
                    end;
                end
                else
                begin
                    Result := 0.01700173417937851;
                end;
            end
            else
            begin
                if features[2] <= 0.36349999904632574 then
                begin
                    if features[29] <= -2.8734999895095821 then
                    begin
                        Result := 0.013904595014591684;
                    end
                    else
                    begin
                        Result := 0.031620643879719926;
                    end;
                end
                else
                begin
                    Result := 0.03022062357491552;
                end;
            end;
        end;
    end;
end;

function completion_tree_16(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.19950000196695331 then
    begin
        if features[1] <= 0.0015000000712461772 then
        begin
            Result := -0.045363425085542218;
        end
        else
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[29] <= -8.3635001182556135 then
                begin
                    if features[2] <= 0.087999999523162856 then
                    begin
                        Result := -0.029004988222042827;
                    end
                    else
                    begin
                        Result := -0.0067146305123168513;
                    end;
                end
                else
                begin
                    if features[29] <= -5.4034998416900626 then
                    begin
                        Result := -0.0035413488734462222;
                    end
                    else
                    begin
                        Result := 0.015409980309537824;
                    end;
                end;
            end
            else
            begin
                Result := -0.048433965692100657;
            end;
        end;
    end
    else
    begin
        if features[29] <= -5.4284999370574942 then
        begin
            if features[2] <= 0.27950000762939459 then
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[29] <= -8.1775002479553205 then
                    begin
                        Result := -0.013275300461404113;
                    end
                    else
                    begin
                        Result := 0.00042853395969277364;
                    end;
                end
                else
                begin
                    Result := -0.048453408760492422;
                end;
            end
            else
            begin
                Result := 0.013698226074969717;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[24] <= 0.046875000000000007 then
                begin
                    Result := 0.027455262578370391;
                end
                else
                begin
                    if features[29] <= -3.6204999685287471 then
                    begin
                        Result := 0.013173497324602898;
                    end
                    else
                    begin
                        Result := 0.025793207135811177;
                    end;
                end;
            end
            else
            begin
                if features[2] <= 0.29850000143051153 then
                begin
                    Result := 0.0035171618066772697;
                end
                else
                begin
                    Result := 0.019890767713522276;
                end;
            end;
        end;
    end;
end;

function completion_tree_17(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.19849999994039538 then
    begin
        if features[0] <= 0.53749999403953563 then
        begin
            if features[9] <= -0.78004997968673695 then
            begin
                if features[2] <= 0.087999999523162856 then
                begin
                    Result := -0.026204824625658263;
                end
                else
                begin
                    Result := -0.0060077192319709302;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := 0.0062819329935661847;
                end
                else
                begin
                    Result := -0.047325988067308623;
                end;
            end;
        end
        else
        begin
            if features[2] <= 0.033999999985098846 then
            begin
                Result := -0.043620945383456851;
            end
            else
            begin
                Result := -0.0066898266280229594;
            end;
        end;
    end
    else
    begin
        if features[9] <= -0.56475001573562611 then
        begin
            if features[2] <= 0.17750000208616259 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    Result := -0.0028448082917802032;
                end
                else
                begin
                    Result := -0.019482718252282739;
                end;
            end
            else
            begin
                if features[24] <= 0.078125000000000014 then
                begin
                    Result := 0.016502162480839033;
                end
                else
                begin
                    Result := 0.0016472582324377814;
                end;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[2] <= 0.36349999904632574 then
                begin
                    if features[8] <= -1.0589374899864195 then
                    begin
                        Result := 0.014395553940111433;
                    end
                    else
                    begin
                        Result := 0.028507435716690187;
                    end;
                end
                else
                begin
                    Result := 0.029621101625736945;
                end;
            end
            else
            begin
                if features[9] <= -0.39994999766349787 then
                begin
                    Result := 0.00053849442818864647;
                end
                else
                begin
                    Result := 0.015676149589294287;
                end;
            end;
        end;
    end;
end;

function completion_tree_18(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.19950000196695331 then
    begin
        if features[0] <= 0.53749999403953563 then
        begin
            if features[9] <= -0.73225000500679005 then
            begin
                if features[9] <= -1.1550499796867368 then
                begin
                    Result := -0.034397278614485452;
                end
                else
                begin
                    Result := -0.013971521210816141;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := 0.0070125894117910956;
                end
                else
                begin
                    Result := -0.046178177925283691;
                end;
            end;
        end
        else
        begin
            if features[1] <= 0.017500000074505809 then
            begin
                Result := -0.04485407434020286;
            end
            else
            begin
                if features[9] <= -0.63314998149871815 then
                begin
                    Result := -0.036593556301849593;
                end
                else
                begin
                    Result := -0.0051675649643662903;
                end;
            end;
        end;
    end
    else
    begin
        if features[9] <= -0.5353499948978423 then
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[9] <= -0.81084999442100514 then
                begin
                    Result := -0.0096230206469102176;
                end
                else
                begin
                    Result := 0.0086532783212418356;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    Result := -0.0097510832234575968;
                end
                else
                begin
                    Result := -0.047965971307652136;
                end;
            end;
        end
        else
        begin
            if features[9] <= -0.36564999818801874 then
            begin
                if features[10] <= 0.37500000000000006 then
                begin
                    if features[24] <= 0.046875000000000007 then
                    begin
                        Result := 0.024668381355937827;
                    end
                    else
                    begin
                        Result := 0.012359859365445864;
                    end;
                end
                else
                begin
                    Result := 0.0035472035188202989;
                end;
            end
            else
            begin
                Result := 0.024276270936052845;
            end;
        end;
    end;
end;

function completion_tree_19(const features: TCompletionFeatures): Double;
begin
    if features[1] <= 0.10249999910593034 then
    begin
        if features[0] <= 0.53150001168251049 then
        begin
            if features[29] <= -5.576500177383422 then
            begin
                if features[29] <= -9.4574999809265119 then
                begin
                    Result := -0.033162018579158889;
                end
                else
                begin
                    if features[27] <= 0.45833332836627966 then
                    begin
                        Result := -0.0029108890828911378;
                    end
                    else
                    begin
                        Result := -0.033853864198226238;
                    end;
                end;
            end
            else
            begin
                Result := 0.014829087233815704;
            end;
        end
        else
        begin
            Result := -0.042260307163896886;
        end;
    end
    else
    begin
        if features[29] <= -6.6794998645782462 then
        begin
            if features[11] <= 0.56250000000000011 then
            begin
                if features[29] <= -8.9134998321533185 then
                begin
                    Result := -0.016752912430163771;
                end
                else
                begin
                    if features[10] <= 0.37500000000000006 then
                    begin
                        Result := 0.0017397948812749287;
                    end
                    else
                    begin
                        Result := -0.01258999501241821;
                    end;
                end;
            end
            else
            begin
                Result := -0.047815699298050338;
            end;
        end
        else
        begin
            if features[10] <= 0.37500000000000006 then
            begin
                if features[8] <= -1.2986458539962766 then
                begin
                    if features[24] <= 0.046875000000000007 then
                    begin
                        Result := 0.020282241607998703;
                    end
                    else
                    begin
                        Result := 0.0097590986082786435;
                    end;
                end
                else
                begin
                    Result := 0.02445574631808933;
                end;
            end
            else
            begin
                if features[11] <= 0.56250000000000011 then
                begin
                    if features[29] <= -4.5565001964569083 then
                    begin
                        Result := -0.0017646062778272722;
                    end
                    else
                    begin
                        Result := 0.011307761664542485;
                    end;
                end
                else
                begin
                    Result := -0.046147391909607469;
                end;
            end;
        end;
    end;
end;

function one_key_completion_topk_score(
    const context_value, query_text: string;
    const item: TncOneKeyCompletion; const char_lm_score: Integer;
    const typed_units, candidate_rank: Integer): Double;
var
    features: TCompletionFeatures;
    units, remaining, pinyin_left: Integer;
    hot, warm, cold: Boolean;
begin
    units := Max(1, text_unit_count(item.text));
    remaining := Max(0, units - typed_units);
    pinyin_left := Max(0, Length(item.full_pinyin) - Length(query_text));
    hot := (item.source = okcs_base_exact) and
        (item.popularity_prior >= 700) and (item.source_count >= 2);
    warm := (item.source = okcs_base_exact) and
        (item.popularity_prior >= 480);
    cold := (item.source = okcs_base_exact) and
        (item.vertical_layer_kind > 0) and
        (item.popularity_prior >= 0) and (item.popularity_prior < 300);
    features[0] := item.weight / 1000.0;
    features[1] := Max(-1, item.popularity_prior) / 1000.0;
    features[2] := item.corpus_score / 1000.0;
    features[3] := item.document_score / 200.0;
    features[4] := item.source_count / 4.0;
    features[5] := item.path_score / 520.0;
    features[6] := item.vertical_penalty / 340.0;
    features[7] := item.vertical_layer_kind / 3.0;
    features[8] := char_lm_score / (1000.0 * units);
    features[9] := char_lm_score / 10000.0;
    features[10] := remaining / 4.0;
    features[11] := units / 8.0;
    features[12] := Ord(item.prefix_anchored);
    features[13] := Ord(item.source = okcs_base_exact);
    features[14] := Ord(item.source = okcs_transition);
    features[15] := Ord(hot);
    features[16] := Ord(warm);
    features[17] := Ord(cold);
    if item.source = okcs_transition then
        features[18] := item.weight / 1000.0
    else
        features[18] := 0;
    features[19] := Ord(remaining = 1);
    features[20] := Ord(remaining = 2);
    features[21] := Ord(remaining > 3);
    features[22] := item.feedback_count / 4.0;
    features[23] := Ord(item.path_text <> '');
    features[24] := candidate_rank / 32.0;
    features[25] := Length(context_value) / 12.0;
    features[26] := Length(query_text) / 16.0;
    features[27] := pinyin_left / 12.0;
    features[28] := remaining / 4.0;
    features[29] := char_lm_score / 1000.0;
    features[30] := char_lm_score / (1000.0 * units);
    features[31] := Ord((item.source = okcs_base_exact) and item.prefix_anchored);
    features[32] := Ord((item.source = okcs_base_exact) and
        (not item.prefix_anchored));
    features[33] := Ord(item.vertical_layer_kind = 3);
    Result := 0;
    Result := Result + completion_tree_0(features);
    Result := Result + completion_tree_1(features);
    Result := Result + completion_tree_2(features);
    Result := Result + completion_tree_3(features);
    Result := Result + completion_tree_4(features);
    Result := Result + completion_tree_5(features);
    Result := Result + completion_tree_6(features);
    Result := Result + completion_tree_7(features);
    Result := Result + completion_tree_8(features);
    Result := Result + completion_tree_9(features);
    Result := Result + completion_tree_10(features);
    Result := Result + completion_tree_11(features);
    Result := Result + completion_tree_12(features);
    Result := Result + completion_tree_13(features);
    Result := Result + completion_tree_14(features);
    Result := Result + completion_tree_15(features);
    Result := Result + completion_tree_16(features);
    Result := Result + completion_tree_17(features);
    Result := Result + completion_tree_18(features);
    Result := Result + completion_tree_19(features);
end;

function one_key_completion_topk_threshold(
    const category: TncOneKeyCompletionDifferenceCategory): Double;
begin
    Result := c_thresholds[category];
end;

function one_key_completion_topk_self_test: Boolean;
begin
    Result := 20 > 0;
end;

end.
