unit test_nc_shuangpin_decoder;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    fpcunit,
    testregistry,
    nc_types,
    nc_shuangpin_decoder;

type
    TncTestAssert = class
    private
        class procedure RaiseFailure(const message_text: string); static;
    public
        class procedure AreEqual(const expected_value: string;
            const actual_value: string; const message_text: string = ''); static; overload;
        class procedure AreEqual(const expected_value: NativeInt;
            const actual_value: NativeInt; const message_text: string = ''); static; overload;
        class procedure IsTrue(const condition: Boolean;
            const message_text: string = ''); static;
        class procedure IsFalse(const condition: Boolean;
            const message_text: string = ''); static;
    end;

    TncShuangpinDecoderTests = class(TTestCase)
    private
        procedure assert_decode(const scheme: TncPinyinInputScheme;
            const raw_text: string; const expected_pinyin: string;
            const expected_units: Integer);
        procedure assert_inventory_round_trip(const scheme: TncPinyinInputScheme);
        procedure assert_code(const scheme: TncPinyinInputScheme;
            const syllable: string; const expected_code: string);
    published
        procedure microsoft_known_mappings;
        procedure xiaohe_known_mappings;
        procedure ziranma_known_mappings;
        procedure sogou_known_mappings;
        procedure ziguang_known_mappings;
        procedure pinyinjiajia_known_mappings;
        procedure microsoft_zero_initial_aliases;
        procedure xiaohe_zero_initial_aliases;
        procedure xiaohe_d_remains_a_pending_initial;
        procedure ziranma_zero_initial_aliases;
        procedure sogou_zero_initial_aliases;
        procedure ziguang_zero_initial_codes;
        procedure pinyinjiajia_zero_initial_aliases;
        procedure preserves_ambiguous_syllable_boundaries;
        procedure exposes_raw_prefix_and_suffix_by_syllable;
        procedure decodes_pending_initial_without_rejecting_input;
        procedure semicolon_only_completes_second_key_for_supported_schemes;
        procedure microsoft_inventory_round_trip;
        procedure xiaohe_inventory_round_trip;
        procedure ziranma_inventory_round_trip;
        procedure sogou_inventory_round_trip;
        procedure ziguang_inventory_round_trip;
        procedure pinyinjiajia_inventory_round_trip;
        procedure microsoft_standard_key_layout;
        procedure xiaohe_standard_key_layout;
        procedure ziranma_standard_key_layout;
        procedure sogou_standard_key_layout;
        procedure ziguang_standard_key_layout;
        procedure pinyinjiajia_standard_key_layout;
    end;

implementation

function nc_test_int_to_string(const value: NativeInt): string;
begin
    Result := UTF8Decode(IntToStr(value));
end;

function nc_test_same_text(const left_value: string;
    const right_value: string): Boolean;
begin
    Result := LowerCase(left_value) = LowerCase(right_value);
end;

class procedure TncTestAssert.RaiseFailure(const message_text: string);
begin
    if message_text = '' then
        raise EAssertionFailedError.Create('Assertion failed')
    else
        raise EAssertionFailedError.Create(UTF8Encode(message_text));
end;

class procedure TncTestAssert.AreEqual(const expected_value: string;
    const actual_value: string; const message_text: string);
begin
    if expected_value <> actual_value then
        RaiseFailure(message_text + ' expected=' + expected_value +
            ' actual=' + actual_value);
end;

class procedure TncTestAssert.AreEqual(const expected_value: NativeInt;
    const actual_value: NativeInt; const message_text: string);
begin
    if expected_value <> actual_value then
        RaiseFailure(message_text + ' expected=' +
            nc_test_int_to_string(expected_value) + ' actual=' +
            nc_test_int_to_string(actual_value));
end;

class procedure TncTestAssert.IsTrue(const condition: Boolean;
    const message_text: string);
begin
    if not condition then
        RaiseFailure(message_text);
end;

class procedure TncTestAssert.IsFalse(const condition: Boolean;
    const message_text: string);
begin
    if condition then
        RaiseFailure(message_text);
end;


procedure TncShuangpinDecoderTests.assert_decode(
    const scheme: TncPinyinInputScheme; const raw_text: string;
    const expected_pinyin: string; const expected_units: Integer);
var
    decoded: TncShuangpinDecodeResult;
    decoded_unit: TncShuangpinDecodedUnit;
begin
    decoded := nc_decode_shuangpin(scheme, raw_text);
    TncTestAssert.AreEqual(expected_pinyin, decoded.canonical_text, raw_text);
    TncTestAssert.AreEqual(expected_units, Length(decoded.units), raw_text);
    TncTestAssert.IsTrue(decoded.valid, raw_text + ' must be a valid scheme code');
    for decoded_unit in decoded.units do
    begin
        TncTestAssert.IsTrue(decoded_unit.complete,
            raw_text + ' must decode through the scheme map');
    end;
end;

procedure TncShuangpinDecoderTests.assert_inventory_round_trip(
    const scheme: TncPinyinInputScheme);
var
    syllables: TncShuangpinStringArray;
    codes: TncShuangpinStringArray;
    syllable: string;
    expected: string;
    code: string;
    decoded: TncShuangpinDecodeResult;
begin
    syllables := nc_get_shuangpin_syllables;
    TncTestAssert.IsTrue(Length(syllables) >= 400);
    for syllable in syllables do
    begin
        codes := nc_get_shuangpin_codes(scheme, syllable);
        TncTestAssert.IsTrue(Length(codes) > 0, syllable);
        for code in codes do
        begin
            TncTestAssert.IsTrue((Length(code) >= 1) and (Length(code) <= 2),
                syllable + '=' + code);
            expected := syllable;
            if nc_test_same_text(code, 'lo') then
            begin
                expected := 'luo';
            end
            else if nc_test_same_text(code, 'ng') then
            begin
                case scheme of
                    pis_ziguang_shuangpin:
                        expected := 'niang';
                    pis_pinyinjiajia_shuangpin:
                        expected := 'nang';
                else
                    expected := 'neng';
                end;
            end
            else if (scheme = pis_ziguang_shuangpin) and
                nc_test_same_text(code, 'hm') then
            begin
                expected := 'hun';
            end;
            decoded := nc_decode_shuangpin(scheme, code);
            TncTestAssert.IsTrue(decoded.valid, syllable + '=' + code);
            TncTestAssert.AreEqual(expected, decoded.compact_pinyin,
                syllable + '=' + code);
            TncTestAssert.AreEqual(1, Length(decoded.units),
                syllable + '=' + code);
            TncTestAssert.IsTrue(decoded.units[0].complete,
                syllable + '=' + code);
        end;
    end;
end;

procedure TncShuangpinDecoderTests.assert_code(
    const scheme: TncPinyinInputScheme; const syllable: string;
    const expected_code: string);
var
    codes: TncShuangpinStringArray;
    code: string;
    found: Boolean;
    decoded: TncShuangpinDecodeResult;
begin
    found := False;
    codes := nc_get_shuangpin_codes(scheme, syllable);
    for code in codes do
    begin
        if nc_test_same_text(code, expected_code) then
        begin
            found := True;
            Break;
        end;
    end;
    TncTestAssert.IsTrue(found, syllable + '=' + expected_code);
    decoded := nc_decode_shuangpin(scheme, expected_code);
    TncTestAssert.AreEqual(syllable, decoded.compact_pinyin,
        syllable + '=' + expected_code);
end;

procedure TncShuangpinDecoderTests.microsoft_known_mappings;
begin
    assert_decode(pis_microsoft_shuangpin, 'nihk', 'nihao', 2);
    assert_decode(pis_microsoft_shuangpin, 'vs', 'zhong', 1);
    assert_decode(pis_microsoft_shuangpin, 'q;', 'qing', 1);
    assert_decode(pis_microsoft_shuangpin, 'womf', 'women', 2);
end;

procedure TncShuangpinDecoderTests.xiaohe_known_mappings;
begin
    assert_decode(pis_xiaohe_shuangpin, 'nihc', 'nihao', 2);
    assert_decode(pis_xiaohe_shuangpin, 'vs', 'zhong', 1);
    assert_decode(pis_xiaohe_shuangpin, 'qkssuuru', 'qingsongshuru', 4);
end;

procedure TncShuangpinDecoderTests.ziranma_known_mappings;
begin
    assert_decode(pis_ziranma_shuangpin, 'nihk', 'nihao', 2);
    assert_decode(pis_ziranma_shuangpin, 'vs', 'zhong', 1);
    assert_decode(pis_ziranma_shuangpin, 'qyssuuru', 'qingsongshuru', 4);
    assert_decode(pis_ziranma_shuangpin, 'womf', 'women', 2);
end;

procedure TncShuangpinDecoderTests.sogou_known_mappings;
begin
    assert_decode(pis_sogou_shuangpin, 'nihk', 'nihao', 2);
    assert_decode(pis_sogou_shuangpin, 'id', 'chuang', 1);
    assert_decode(pis_sogou_shuangpin, 'q;', 'qing', 1);
    assert_decode(pis_sogou_shuangpin, 'womf', 'women', 2);
end;

procedure TncShuangpinDecoderTests.ziguang_known_mappings;
begin
    assert_decode(pis_ziguang_shuangpin, 'nihq', 'nihao', 2);
    assert_decode(pis_ziguang_shuangpin, 'uh', 'zhong', 1);
    assert_decode(pis_ziguang_shuangpin, 'q;', 'qing', 1);
    assert_decode(pis_ziguang_shuangpin, 'womw', 'women', 2);
end;

procedure TncShuangpinDecoderTests.pinyinjiajia_known_mappings;
begin
    assert_decode(pis_pinyinjiajia_shuangpin, 'nihd', 'nihao', 2);
    assert_decode(pis_pinyinjiajia_shuangpin, 'vy', 'zhong', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'qq', 'qing', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'womr', 'women', 2);
end;

procedure TncShuangpinDecoderTests.microsoft_zero_initial_aliases;
begin
    assert_decode(pis_microsoft_shuangpin, 'aa', 'a', 1);
    assert_decode(pis_microsoft_shuangpin, 'oa', 'a', 1);
    assert_decode(pis_microsoft_shuangpin, 'al', 'ai', 1);
    assert_decode(pis_microsoft_shuangpin, 'ol', 'ai', 1);
    assert_decode(pis_microsoft_shuangpin, 'ou', 'ou', 1);
    assert_decode(pis_microsoft_shuangpin, 'ob', 'ou', 1);
end;

procedure TncShuangpinDecoderTests.xiaohe_zero_initial_aliases;
begin
    assert_decode(pis_xiaohe_shuangpin, 'aa', 'a', 1);
    assert_decode(pis_xiaohe_shuangpin, 'ai', 'ai', 1);
    assert_decode(pis_xiaohe_shuangpin, 'ad', 'ai', 1);
    assert_decode(pis_xiaohe_shuangpin, 'eg', 'eng', 1);
    assert_decode(pis_xiaohe_shuangpin, 'oo', 'o', 1);
end;

procedure TncShuangpinDecoderTests.xiaohe_d_remains_a_pending_initial;
var
    codes: TncShuangpinStringArray;
    code: string;
    has_ai_code: Boolean;
    has_ad_code: Boolean;
    has_bare_d_code: Boolean;
    decoded: TncShuangpinDecodeResult;
begin
    has_ai_code := False;
    has_ad_code := False;
    has_bare_d_code := False;
    codes := nc_get_shuangpin_codes(pis_xiaohe_shuangpin, 'ai');
    for code in codes do
    begin
        has_ai_code := has_ai_code or nc_test_same_text(code, 'ai');
        has_ad_code := has_ad_code or nc_test_same_text(code, 'ad');
        has_bare_d_code := has_bare_d_code or nc_test_same_text(code, 'd');
    end;
    TncTestAssert.IsTrue(has_ai_code, 'ai must retain its zero-initial code');
    TncTestAssert.IsTrue(has_ad_code, 'ai must retain its derived zero-initial alias');
    TncTestAssert.IsFalse(has_bare_d_code, 'ai must not capture the d initial');

    decoded := nc_decode_shuangpin(pis_xiaohe_shuangpin, 'd');
    TncTestAssert.AreEqual('d', decoded.canonical_text);
    TncTestAssert.IsTrue(decoded.valid);
    TncTestAssert.IsTrue(decoded.has_pending_key);
    TncTestAssert.AreEqual(1, Length(decoded.units));
    TncTestAssert.IsFalse(decoded.units[0].complete);
end;

procedure TncShuangpinDecoderTests.ziranma_zero_initial_aliases;
begin
    assert_decode(pis_ziranma_shuangpin, 'aa', 'a', 1);
    assert_decode(pis_ziranma_shuangpin, 'ai', 'ai', 1);
    assert_decode(pis_ziranma_shuangpin, 'al', 'ai', 1);
    assert_decode(pis_ziranma_shuangpin, 'eg', 'eng', 1);
    assert_decode(pis_ziranma_shuangpin, 'er', 'er', 1);
    assert_decode(pis_ziranma_shuangpin, 'ou', 'ou', 1);
    assert_decode(pis_ziranma_shuangpin, 'ob', 'ou', 1);
end;

procedure TncShuangpinDecoderTests.sogou_zero_initial_aliases;
begin
    assert_decode(pis_sogou_shuangpin, 'aa', 'a', 1);
    assert_decode(pis_sogou_shuangpin, 'oa', 'a', 1);
    assert_decode(pis_sogou_shuangpin, 'al', 'ai', 1);
    assert_decode(pis_sogou_shuangpin, 'ol', 'ai', 1);
    assert_decode(pis_sogou_shuangpin, 'ee', 'e', 1);
    assert_decode(pis_sogou_shuangpin, 'oe', 'e', 1);
    assert_decode(pis_sogou_shuangpin, 'oo', 'o', 1);
    assert_decode(pis_sogou_shuangpin, 'or', 'er', 1);
end;

procedure TncShuangpinDecoderTests.ziguang_zero_initial_codes;
begin
    assert_decode(pis_ziguang_shuangpin, 'oa', 'a', 1);
    assert_decode(pis_ziguang_shuangpin, 'op', 'ai', 1);
    assert_decode(pis_ziguang_shuangpin, 'or', 'an', 1);
    assert_decode(pis_ziguang_shuangpin, 'os', 'ang', 1);
    assert_decode(pis_ziguang_shuangpin, 'oq', 'ao', 1);
    assert_decode(pis_ziguang_shuangpin, 'oe', 'e', 1);
    assert_decode(pis_ziguang_shuangpin, 'oj', 'er', 1);
    assert_decode(pis_ziguang_shuangpin, 'oo', 'o', 1);
end;

procedure TncShuangpinDecoderTests.pinyinjiajia_zero_initial_aliases;
begin
    assert_decode(pis_pinyinjiajia_shuangpin, 'aa', 'a', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'oa', 'a', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'as', 'ai', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'os', 'ai', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'ag', 'ang', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'og', 'ang', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'eq', 'er', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'oq', 'er', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'o', 'o', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'oo', 'o', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'ou', 'ou', 1);
    assert_decode(pis_pinyinjiajia_shuangpin, 'op', 'ou', 1);
end;

procedure TncShuangpinDecoderTests.preserves_ambiguous_syllable_boundaries;
begin
    assert_decode(pis_microsoft_shuangpin, 'xiaj', 'xi''an', 2);
    assert_decode(pis_xiaohe_shuangpin, 'xiaj', 'xi''an', 2);
    assert_decode(pis_ziranma_shuangpin, 'xian', 'xi''an', 2);
end;

procedure TncShuangpinDecoderTests.exposes_raw_prefix_and_suffix_by_syllable;
var
    decoded: TncShuangpinDecodeResult;
begin
    decoded := nc_decode_shuangpin(pis_xiaohe_shuangpin, 'qkssuuru');
    TncTestAssert.AreEqual('qkss', nc_shuangpin_raw_prefix_for_units(decoded, 2));
    TncTestAssert.AreEqual('uuru', nc_shuangpin_raw_suffix_after_units(decoded, 2));
    TncTestAssert.AreEqual('', nc_shuangpin_raw_suffix_after_units(decoded, 4));
end;

procedure TncShuangpinDecoderTests.decodes_pending_initial_without_rejecting_input;
var
    decoded: TncShuangpinDecodeResult;
begin
    decoded := nc_decode_shuangpin(pis_xiaohe_shuangpin, 'v');
    TncTestAssert.AreEqual('zh', decoded.canonical_text);
    TncTestAssert.IsTrue(decoded.has_pending_key);
    TncTestAssert.IsTrue(decoded.valid);
end;

procedure TncShuangpinDecoderTests.semicolon_only_completes_second_key_for_supported_schemes;
begin
    TncTestAssert.IsFalse(nc_shuangpin_accepts_semicolon(pis_microsoft_shuangpin, ''));
    TncTestAssert.IsTrue(nc_shuangpin_accepts_semicolon(pis_microsoft_shuangpin, 'q'));
    TncTestAssert.IsFalse(nc_shuangpin_accepts_semicolon(pis_microsoft_shuangpin, 'q;'));
    TncTestAssert.IsTrue(nc_shuangpin_accepts_semicolon(pis_microsoft_shuangpin, 'q;d'));
    TncTestAssert.IsTrue(nc_shuangpin_accepts_semicolon(pis_microsoft_shuangpin, 'q;''d'));
    TncTestAssert.IsTrue(nc_shuangpin_accepts_semicolon(pis_sogou_shuangpin, 'q'));
    TncTestAssert.IsFalse(nc_shuangpin_accepts_semicolon(pis_sogou_shuangpin, 'q;'));
    TncTestAssert.IsTrue(nc_shuangpin_accepts_semicolon(pis_ziguang_shuangpin, 'q'));
    TncTestAssert.IsFalse(nc_shuangpin_accepts_semicolon(pis_ziguang_shuangpin, 'q;'));
    TncTestAssert.IsFalse(nc_shuangpin_accepts_semicolon(pis_xiaohe_shuangpin, 'q'));
    TncTestAssert.IsFalse(nc_shuangpin_accepts_semicolon(pis_ziranma_shuangpin, 'q'));
    TncTestAssert.IsFalse(nc_shuangpin_accepts_semicolon(
        pis_pinyinjiajia_shuangpin, 'q'));
end;

procedure TncShuangpinDecoderTests.microsoft_inventory_round_trip;
begin
    assert_inventory_round_trip(pis_microsoft_shuangpin);
end;

procedure TncShuangpinDecoderTests.xiaohe_inventory_round_trip;
begin
    assert_inventory_round_trip(pis_xiaohe_shuangpin);
end;

procedure TncShuangpinDecoderTests.ziranma_inventory_round_trip;
begin
    assert_inventory_round_trip(pis_ziranma_shuangpin);
end;

procedure TncShuangpinDecoderTests.sogou_inventory_round_trip;
begin
    assert_inventory_round_trip(pis_sogou_shuangpin);
end;

procedure TncShuangpinDecoderTests.ziguang_inventory_round_trip;
begin
    assert_inventory_round_trip(pis_ziguang_shuangpin);
end;

procedure TncShuangpinDecoderTests.pinyinjiajia_inventory_round_trip;
begin
    assert_inventory_round_trip(pis_pinyinjiajia_shuangpin);
end;

procedure TncShuangpinDecoderTests.microsoft_standard_key_layout;
begin
    assert_code(pis_microsoft_shuangpin, 'jiu', 'jq');
    assert_code(pis_microsoft_shuangpin, 'jia', 'jw');
    assert_code(pis_microsoft_shuangpin, 'gua', 'gw');
    assert_code(pis_microsoft_shuangpin, 'er', 'or');
    assert_code(pis_microsoft_shuangpin, 'yuan', 'yr');
    assert_code(pis_microsoft_shuangpin, 'jue', 'jt');
    assert_code(pis_microsoft_shuangpin, 'nv', 'ny');
    assert_code(pis_microsoft_shuangpin, 'kuai', 'ky');
    assert_code(pis_microsoft_shuangpin, 'shi', 'ui');
    assert_code(pis_microsoft_shuangpin, 'luo', 'lo');
    assert_code(pis_microsoft_shuangpin, 'lun', 'lp');
    assert_code(pis_microsoft_shuangpin, 'jiong', 'js');
    assert_code(pis_microsoft_shuangpin, 'liang', 'ld');
    assert_code(pis_microsoft_shuangpin, 'fen', 'ff');
    assert_code(pis_microsoft_shuangpin, 'feng', 'fg');
    assert_code(pis_microsoft_shuangpin, 'zhang', 'vh');
    assert_code(pis_microsoft_shuangpin, 'jian', 'jm');
    assert_code(pis_microsoft_shuangpin, 'ban', 'bj');
    assert_code(pis_microsoft_shuangpin, 'xiao', 'xc');
    assert_code(pis_microsoft_shuangpin, 'bao', 'bk');
    assert_code(pis_microsoft_shuangpin, 'lai', 'll');
    assert_code(pis_microsoft_shuangpin, 'fei', 'fz');
    assert_code(pis_microsoft_shuangpin, 'xie', 'xx');
    assert_code(pis_microsoft_shuangpin, 'hui', 'hv');
    assert_code(pis_microsoft_shuangpin, 'dou', 'db');
    assert_code(pis_microsoft_shuangpin, 'qin', 'qn');
    assert_code(pis_microsoft_shuangpin, 'qing', 'q;');
end;

procedure TncShuangpinDecoderTests.xiaohe_standard_key_layout;
begin
    assert_code(pis_xiaohe_shuangpin, 'jiu', 'jq');
    assert_code(pis_xiaohe_shuangpin, 'fei', 'fw');
    assert_code(pis_xiaohe_shuangpin, 'yuan', 'yr');
    assert_code(pis_xiaohe_shuangpin, 'jue', 'jt');
    assert_code(pis_xiaohe_shuangpin, 'lun', 'ly');
    assert_code(pis_xiaohe_shuangpin, 'shi', 'ui');
    assert_code(pis_xiaohe_shuangpin, 'luo', 'lo');
    assert_code(pis_xiaohe_shuangpin, 'xie', 'xp');
    assert_code(pis_xiaohe_shuangpin, 'jiong', 'js');
    assert_code(pis_xiaohe_shuangpin, 'kuai', 'kk');
    assert_code(pis_xiaohe_shuangpin, 'qing', 'qk');
    assert_code(pis_xiaohe_shuangpin, 'lai', 'ld');
    assert_code(pis_xiaohe_shuangpin, 'fen', 'ff');
    assert_code(pis_xiaohe_shuangpin, 'feng', 'fg');
    assert_code(pis_xiaohe_shuangpin, 'liang', 'll');
    assert_code(pis_xiaohe_shuangpin, 'zhang', 'vh');
    assert_code(pis_xiaohe_shuangpin, 'jian', 'jm');
    assert_code(pis_xiaohe_shuangpin, 'ban', 'bj');
    assert_code(pis_xiaohe_shuangpin, 'dou', 'dz');
    assert_code(pis_xiaohe_shuangpin, 'jia', 'jx');
    assert_code(pis_xiaohe_shuangpin, 'xiao', 'xn');
    assert_code(pis_xiaohe_shuangpin, 'bao', 'bc');
    assert_code(pis_xiaohe_shuangpin, 'hui', 'hv');
    assert_code(pis_xiaohe_shuangpin, 'qin', 'qb');
end;

procedure TncShuangpinDecoderTests.ziranma_standard_key_layout;
begin
    assert_code(pis_ziranma_shuangpin, 'jiu', 'jq');
    assert_code(pis_ziranma_shuangpin, 'jia', 'jw');
    assert_code(pis_ziranma_shuangpin, 'gua', 'gw');
    assert_code(pis_ziranma_shuangpin, 'er', 'er');
    assert_code(pis_ziranma_shuangpin, 'yuan', 'yr');
    assert_code(pis_ziranma_shuangpin, 'jue', 'jt');
    assert_code(pis_ziranma_shuangpin, 'nv', 'nv');
    assert_code(pis_ziranma_shuangpin, 'kuai', 'ky');
    assert_code(pis_ziranma_shuangpin, 'shi', 'ui');
    assert_code(pis_ziranma_shuangpin, 'luo', 'lo');
    assert_code(pis_ziranma_shuangpin, 'lun', 'lp');
    assert_code(pis_ziranma_shuangpin, 'jiong', 'js');
    assert_code(pis_ziranma_shuangpin, 'liang', 'ld');
    assert_code(pis_ziranma_shuangpin, 'fen', 'ff');
    assert_code(pis_ziranma_shuangpin, 'feng', 'fg');
    assert_code(pis_ziranma_shuangpin, 'zhang', 'vh');
    assert_code(pis_ziranma_shuangpin, 'jian', 'jm');
    assert_code(pis_ziranma_shuangpin, 'ban', 'bj');
    assert_code(pis_ziranma_shuangpin, 'xiao', 'xc');
    assert_code(pis_ziranma_shuangpin, 'bao', 'bk');
    assert_code(pis_ziranma_shuangpin, 'lai', 'll');
    assert_code(pis_ziranma_shuangpin, 'fei', 'fz');
    assert_code(pis_ziranma_shuangpin, 'xie', 'xx');
    assert_code(pis_ziranma_shuangpin, 'hui', 'hv');
    assert_code(pis_ziranma_shuangpin, 'dou', 'db');
    assert_code(pis_ziranma_shuangpin, 'qin', 'qn');
    assert_code(pis_ziranma_shuangpin, 'qing', 'qy');
end;

procedure TncShuangpinDecoderTests.sogou_standard_key_layout;
begin
    assert_code(pis_sogou_shuangpin, 'jiu', 'jq');
    assert_code(pis_sogou_shuangpin, 'jia', 'jw');
    assert_code(pis_sogou_shuangpin, 'gua', 'gw');
    assert_code(pis_sogou_shuangpin, 'er', 'or');
    assert_code(pis_sogou_shuangpin, 'yuan', 'yr');
    assert_code(pis_sogou_shuangpin, 'jue', 'jt');
    assert_code(pis_sogou_shuangpin, 'nv', 'ny');
    assert_code(pis_sogou_shuangpin, 'kuai', 'ky');
    assert_code(pis_sogou_shuangpin, 'shi', 'ui');
    assert_code(pis_sogou_shuangpin, 'chuang', 'id');
    assert_code(pis_sogou_shuangpin, 'luo', 'lo');
    assert_code(pis_sogou_shuangpin, 'lun', 'lp');
    assert_code(pis_sogou_shuangpin, 'jiong', 'js');
    assert_code(pis_sogou_shuangpin, 'liang', 'ld');
    assert_code(pis_sogou_shuangpin, 'fen', 'ff');
    assert_code(pis_sogou_shuangpin, 'feng', 'fg');
    assert_code(pis_sogou_shuangpin, 'zhang', 'vh');
    assert_code(pis_sogou_shuangpin, 'jian', 'jm');
    assert_code(pis_sogou_shuangpin, 'ban', 'bj');
    assert_code(pis_sogou_shuangpin, 'xiao', 'xc');
    assert_code(pis_sogou_shuangpin, 'bao', 'bk');
    assert_code(pis_sogou_shuangpin, 'lai', 'll');
    assert_code(pis_sogou_shuangpin, 'fei', 'fz');
    assert_code(pis_sogou_shuangpin, 'xie', 'xx');
    assert_code(pis_sogou_shuangpin, 'hui', 'hv');
    assert_code(pis_sogou_shuangpin, 'dou', 'db');
    assert_code(pis_sogou_shuangpin, 'qin', 'qn');
    assert_code(pis_sogou_shuangpin, 'qing', 'q;');
    assert_code(pis_sogou_shuangpin, 'ai', 'ol');
end;

procedure TncShuangpinDecoderTests.ziguang_standard_key_layout;
begin
    assert_code(pis_ziguang_shuangpin, 'jiu', 'jj');
    assert_code(pis_ziguang_shuangpin, 'jia', 'jx');
    assert_code(pis_ziguang_shuangpin, 'gua', 'gx');
    assert_code(pis_ziguang_shuangpin, 'er', 'oj');
    assert_code(pis_ziguang_shuangpin, 'yuan', 'yl');
    assert_code(pis_ziguang_shuangpin, 'jue', 'jn');
    assert_code(pis_ziguang_shuangpin, 'nv', 'nv');
    assert_code(pis_ziguang_shuangpin, 'kuai', 'ky');
    assert_code(pis_ziguang_shuangpin, 'shi', 'ii');
    assert_code(pis_ziguang_shuangpin, 'chuan', 'al');
    assert_code(pis_ziguang_shuangpin, 'luo', 'lo');
    assert_code(pis_ziguang_shuangpin, 'lun', 'lm');
    assert_code(pis_ziguang_shuangpin, 'jiong', 'jh');
    assert_code(pis_ziguang_shuangpin, 'liang', 'lg');
    assert_code(pis_ziguang_shuangpin, 'fen', 'fw');
    assert_code(pis_ziguang_shuangpin, 'feng', 'ft');
    assert_code(pis_ziguang_shuangpin, 'zhang', 'us');
    assert_code(pis_ziguang_shuangpin, 'jian', 'jf');
    assert_code(pis_ziguang_shuangpin, 'ban', 'br');
    assert_code(pis_ziguang_shuangpin, 'xiao', 'xb');
    assert_code(pis_ziguang_shuangpin, 'bao', 'bq');
    assert_code(pis_ziguang_shuangpin, 'lai', 'lp');
    assert_code(pis_ziguang_shuangpin, 'fei', 'fk');
    assert_code(pis_ziguang_shuangpin, 'xie', 'xd');
    assert_code(pis_ziguang_shuangpin, 'hui', 'hn');
    assert_code(pis_ziguang_shuangpin, 'dou', 'dz');
    assert_code(pis_ziguang_shuangpin, 'qin', 'qy');
    assert_code(pis_ziguang_shuangpin, 'qing', 'q;');
end;

procedure TncShuangpinDecoderTests.pinyinjiajia_standard_key_layout;
begin
    assert_code(pis_pinyinjiajia_shuangpin, 'jiu', 'jn');
    assert_code(pis_pinyinjiajia_shuangpin, 'jia', 'jb');
    assert_code(pis_pinyinjiajia_shuangpin, 'gua', 'gb');
    assert_code(pis_pinyinjiajia_shuangpin, 'er', 'eq');
    assert_code(pis_pinyinjiajia_shuangpin, 'yuan', 'yc');
    assert_code(pis_pinyinjiajia_shuangpin, 'jue', 'jx');
    assert_code(pis_pinyinjiajia_shuangpin, 'nv', 'nv');
    assert_code(pis_pinyinjiajia_shuangpin, 'kuai', 'kx');
    assert_code(pis_pinyinjiajia_shuangpin, 'shi', 'ii');
    assert_code(pis_pinyinjiajia_shuangpin, 'chuan', 'uc');
    assert_code(pis_pinyinjiajia_shuangpin, 'luo', 'lo');
    assert_code(pis_pinyinjiajia_shuangpin, 'lun', 'lz');
    assert_code(pis_pinyinjiajia_shuangpin, 'jiong', 'jy');
    assert_code(pis_pinyinjiajia_shuangpin, 'liang', 'lh');
    assert_code(pis_pinyinjiajia_shuangpin, 'fen', 'fr');
    assert_code(pis_pinyinjiajia_shuangpin, 'feng', 'ft');
    assert_code(pis_pinyinjiajia_shuangpin, 'zhang', 'vg');
    assert_code(pis_pinyinjiajia_shuangpin, 'jian', 'jj');
    assert_code(pis_pinyinjiajia_shuangpin, 'ban', 'bf');
    assert_code(pis_pinyinjiajia_shuangpin, 'xiao', 'xk');
    assert_code(pis_pinyinjiajia_shuangpin, 'bao', 'bd');
    assert_code(pis_pinyinjiajia_shuangpin, 'lai', 'ls');
    assert_code(pis_pinyinjiajia_shuangpin, 'fei', 'fw');
    assert_code(pis_pinyinjiajia_shuangpin, 'xie', 'xm');
    assert_code(pis_pinyinjiajia_shuangpin, 'hui', 'hv');
    assert_code(pis_pinyinjiajia_shuangpin, 'dou', 'dp');
    assert_code(pis_pinyinjiajia_shuangpin, 'qin', 'ql');
    assert_code(pis_pinyinjiajia_shuangpin, 'qing', 'qq');
end;

initialization
    RegisterTest(TncShuangpinDecoderTests);

end.
