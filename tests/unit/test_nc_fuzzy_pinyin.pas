unit test_nc_fuzzy_pinyin;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry,
    nc_fuzzy_pinyin,
    nc_types;

type
    TncFuzzyPinyinTests = class(TTestCase)
    published
        procedure EveryRuleExpandsInBothDirections;
        procedure QueryVariantsPreserveExplicitApostropheBoundaries;
        procedure PartialOrJianpinInputIsNotResegmented;
        procedure QueryExpansionRespectsCostAndCountLimits;
        procedure RuleNamesRoundTrip;
    end;

implementation

type
    TncFuzzyRuleTestCase = record
        source_text: string;
        target_text: string;
        rule: TncFuzzyPinyinRule;
    end;

const
    c_rule_test_cases: array[0..21] of TncFuzzyRuleTestCase = (
        (source_text: 'zan'; target_text: 'zhan'; rule: fpr_z_zh),
        (source_text: 'zhan'; target_text: 'zan'; rule: fpr_z_zh),
        (source_text: 'cang'; target_text: 'chang'; rule: fpr_c_ch),
        (source_text: 'chang'; target_text: 'cang'; rule: fpr_c_ch),
        (source_text: 'san'; target_text: 'shan'; rule: fpr_s_sh),
        (source_text: 'shan'; target_text: 'san'; rule: fpr_s_sh),
        (source_text: 'lan'; target_text: 'nan'; rule: fpr_l_n),
        (source_text: 'nan'; target_text: 'lan'; rule: fpr_l_n),
        (source_text: 'fa'; target_text: 'ha'; rule: fpr_f_h),
        (source_text: 'ha'; target_text: 'fa'; rule: fpr_f_h),
        (source_text: 'ran'; target_text: 'lan'; rule: fpr_r_l),
        (source_text: 'lan'; target_text: 'ran'; rule: fpr_r_l),
        (source_text: 'ban'; target_text: 'bang'; rule: fpr_an_ang),
        (source_text: 'bang'; target_text: 'ban'; rule: fpr_an_ang),
        (source_text: 'ben'; target_text: 'beng'; rule: fpr_en_eng),
        (source_text: 'beng'; target_text: 'ben'; rule: fpr_en_eng),
        (source_text: 'bin'; target_text: 'bing'; rule: fpr_in_ing),
        (source_text: 'bing'; target_text: 'bin'; rule: fpr_in_ing),
        (source_text: 'lian'; target_text: 'liang'; rule: fpr_ian_iang),
        (source_text: 'liang'; target_text: 'lian'; rule: fpr_ian_iang),
        (source_text: 'guan'; target_text: 'guang'; rule: fpr_uan_uang),
        (source_text: 'guang'; target_text: 'guan'; rule: fpr_uan_uang)
    );

procedure TncFuzzyPinyinTests.EveryRuleExpandsInBothDirections;
var
    test_case: TncFuzzyRuleTestCase;
    variants: TncFuzzyPinyinSyllableVariants;
    variant: TncFuzzyPinyinSyllableVariant;
    found: Boolean;
begin
    for test_case in c_rule_test_cases do
    begin
        variants := nc_build_fuzzy_syllable_variants(test_case.source_text,
            [test_case.rule]);
        found := False;
        for variant in variants do
            if variant.text = test_case.target_text then
            begin
                found := True;
                AssertEquals(test_case.source_text, variant.original_text);
                AssertEquals(1, variant.cost);
                AssertTrue(variant.rules = [test_case.rule]);
                Break;
            end;
        AssertTrue(found);
    end;
end;

procedure TncFuzzyPinyinTests.QueryVariantsPreserveExplicitApostropheBoundaries;
var
    variants: TncFuzzyPinyinQueryVariants;
    variant: TncFuzzyPinyinQueryVariant;
    found: Boolean;
begin
    variants := nc_build_fuzzy_query_variants('hen''e', [fpr_en_eng]);
    found := False;
    for variant in variants do
    begin
        AssertEquals('hen''e', variant.original_text);
        AssertTrue(Pos('''', variant.text) > 0);
        AssertFalse(Pos('he''n', variant.text) > 0);
        if variant.text = 'heng''e' then
        begin
            found := True;
            AssertEquals(1, variant.cost);
            AssertTrue(variant.rules = [fpr_en_eng]);
        end;
    end;
    AssertTrue(found);
end;

procedure TncFuzzyPinyinTests.PartialOrJianpinInputIsNotResegmented;
var
    variants: TncFuzzyPinyinQueryVariants;
begin
    variants := nc_build_fuzzy_query_variants('zn',
        nc_all_fuzzy_pinyin_rules);
    AssertEquals(0, Length(variants));

    variants := nc_build_fuzzy_query_variants('sheng''',
        nc_all_fuzzy_pinyin_rules);
    AssertEquals(0, Length(variants));
end;

procedure TncFuzzyPinyinTests.QueryExpansionRespectsCostAndCountLimits;
var
    variants: TncFuzzyPinyinQueryVariants;
    variant: TncFuzzyPinyinQueryVariant;
begin
    variants := nc_build_fuzzy_query_variants(
        'shangshangshangshang', [fpr_s_sh, fpr_an_ang], 3, 12, 4);
    AssertTrue(Length(variants) > 0);
    AssertTrue(Length(variants) <= 12);
    for variant in variants do
    begin
        AssertTrue(variant.cost > 0);
        AssertTrue(variant.cost <= 3);
    end;

    variants := nc_build_fuzzy_query_variants(
        'shangshangshangshangshang', [fpr_s_sh, fpr_an_ang], 4, 16, 4);
    AssertEquals(0, Length(variants));
end;

procedure TncFuzzyPinyinTests.RuleNamesRoundTrip;
var
    rule: TncFuzzyPinyinRule;
    parsed_rule: TncFuzzyPinyinRule;
begin
    for rule := Low(TncFuzzyPinyinRule) to High(TncFuzzyPinyinRule) do
    begin
        AssertTrue(nc_try_parse_fuzzy_pinyin_rule_name(
            nc_fuzzy_pinyin_rule_name(rule), parsed_rule));
        AssertTrue(parsed_rule = rule);
    end;
    AssertFalse(nc_try_parse_fuzzy_pinyin_rule_name('unknown', parsed_rule));
end;

initialization
    RegisterTest(TncFuzzyPinyinTests);

end.
