unit test_nc_pinyin_parser;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    fpcunit,
    testregistry,
    nc_pinyin_parser;

type
    TncPinyinParserTests = class(TTestCase)
    private
        procedure AssertSyllables(const input_text: string;
            const expected: array of string);
    published
        procedure ParseSingle;
        procedure ParseMulti;
        procedure ParseWithApostrophe;
        procedure ParseMixedPrefixInitials;
        procedure ParseMixedJianpinUnits;
        procedure ParseBueAsBuEBoundary;
        procedure ParseJueKeepsMedialUFinal;
        procedure ParseYianAsYiAnBoundary;
        procedure ParseWuanAsWuAnBoundary;
        procedure ParseYuaiAsYuAiBoundary;
        procedure ParseWuaiAsWuAiBoundary;
        procedure ParseStandardYWSyllablesWithoutSplitting;
        procedure ParseSheiAsSingleSyllable;
        procedure ParseErAfterNFinal;
        procedure ParseErAfterNgFinal;
        procedure ParseErhuaRAsBoundaryMarker;
        procedure ParseDianGengWithoutApostrophe;
        procedure ParseQuangaoAsQuanGao;
        procedure ParseEmptyInput;
        procedure ParseNormalizesUppercase;
        procedure ParseExplicitBoundaryOffsets;
        procedure ParseExplicitBoundaryExcludesCompetingSplit;
        procedure ParseMalformedCharactersWithoutDroppingInput;
        procedure ParseLongMalformedInput;
        procedure ValidateCanonicalSyllableHelpers;
    end;

implementation

procedure TncPinyinParserTests.AssertSyllables(const input_text: string;
    const expected: array of string);
var
    parser: TncPinyinParser;
    result_data: TncPinyinParseResult;
    index: Integer;
begin
    parser := TncPinyinParser.Create;
    try
        result_data := parser.Parse(input_text);
        AssertEquals(Length(expected), Length(result_data));
        for index := 0 to High(expected) do
            AssertEquals(expected[index], result_data[index].text);
    finally
        parser.Free;
    end;
end;

procedure TncPinyinParserTests.ParseSingle;
var
    parser: TncPinyinParser;
    result_data: TncPinyinParseResult;
begin
    parser := TncPinyinParser.Create;
    try
        result_data := parser.Parse('ni');
        AssertEquals(1, Length(result_data));
        AssertEquals('ni', result_data[0].text);
        AssertEquals(0, result_data[0].start_index);
        AssertEquals(2, result_data[0].length);
    finally
        parser.Free;
    end;
end;

procedure TncPinyinParserTests.ParseMulti;
begin
    AssertSyllables('nihao', ['ni', 'hao']);
end;

procedure TncPinyinParserTests.ParseWithApostrophe;
begin
    AssertSyllables('xi''an', ['xi', 'an']);
end;

procedure TncPinyinParserTests.ParseMixedPrefixInitials;
begin
    AssertSyllables('pas', ['pa', 's']);
end;

procedure TncPinyinParserTests.ParseMixedJianpinUnits;
begin
    AssertSyllables('hha', ['h', 'ha']);
    AssertSyllables('elm', ['e', 'l', 'm']);
    AssertSyllables('zhha', ['z', 'h', 'ha']);
end;

procedure TncPinyinParserTests.ParseBueAsBuEBoundary;
begin
    AssertSyllables('bue', ['bu', 'e']);
end;

procedure TncPinyinParserTests.ParseJueKeepsMedialUFinal;
begin
    AssertSyllables('jue', ['jue']);
end;

procedure TncPinyinParserTests.ParseYianAsYiAnBoundary;
begin
    AssertSyllables('zhuyianquan', ['zhu', 'yi', 'an', 'quan']);
end;

procedure TncPinyinParserTests.ParseWuanAsWuAnBoundary;
begin
    AssertSyllables('wuan', ['wu', 'an']);
end;

procedure TncPinyinParserTests.ParseYuaiAsYuAiBoundary;
begin
    AssertSyllables('youyayuailisidedaodexiansuo',
        ['you', 'ya', 'yu', 'ai', 'li', 'si', 'de', 'dao', 'de', 'xian', 'suo']);
end;

procedure TncPinyinParserTests.ParseWuaiAsWuAiBoundary;
begin
    AssertSyllables('wuai', ['wu', 'ai']);
end;

procedure TncPinyinParserTests.ParseStandardYWSyllablesWithoutSplitting;
begin
    AssertSyllables('yuanxianwaiwen', ['yuan', 'xian', 'wai', 'wen']);
end;

procedure TncPinyinParserTests.ParseSheiAsSingleSyllable;
begin
    AssertSyllables('shei', ['shei']);
end;

procedure TncPinyinParserTests.ParseErAfterNFinal;
begin
    AssertSyllables('pingweneryueer', ['ping', 'wen', 'er', 'yue', 'er']);
end;

procedure TncPinyinParserTests.ParseErAfterNgFinal;
begin
    AssertSyllables('anjingerxianghe', ['an', 'jing', 'er', 'xiang', 'he']);
end;

procedure TncPinyinParserTests.ParseErhuaRAsBoundaryMarker;
begin
    AssertSyllables('tanarhuoqu', ['ta', 'na', 'r', 'huo', 'qu']);
end;

procedure TncPinyinParserTests.ParseDianGengWithoutApostrophe;
begin
    AssertSyllables('youdiangenggengyuhuai',
        ['you', 'dian', 'geng', 'geng', 'yu', 'huai']);
end;

procedure TncPinyinParserTests.ParseQuangaoAsQuanGao;
begin
    AssertSyllables('quangao', ['quan', 'gao']);
end;

procedure TncPinyinParserTests.ParseEmptyInput;
begin
    AssertSyllables('', []);
end;

procedure TncPinyinParserTests.ParseNormalizesUppercase;
begin
    AssertSyllables('NiHao', ['ni', 'hao']);
end;

procedure TncPinyinParserTests.ParseExplicitBoundaryOffsets;
var
    parser: TncPinyinParser;
    result_data: TncPinyinParseResult;
begin
    parser := TncPinyinParser.Create;
    try
        result_data := parser.Parse('xi''an');
        AssertEquals(2, Length(result_data));
        AssertEquals(0, result_data[0].start_index);
        AssertEquals(2, result_data[0].length);
        AssertEquals(3, result_data[1].start_index);
        AssertEquals(2, result_data[1].length);
    finally
        parser.Free;
    end;
end;

procedure TncPinyinParserTests.ParseExplicitBoundaryExcludesCompetingSplit;
begin
    AssertSyllables('hen''e', ['hen', 'e']);
    AssertSyllables('feichang''e', ['fei', 'chang', 'e']);
end;

procedure TncPinyinParserTests.ParseMalformedCharactersWithoutDroppingInput;
begin
    AssertSyllables('ni#hao', ['ni', '#', 'hao']);
end;

procedure TncPinyinParserTests.ParseLongMalformedInput;
var
    parser: TncPinyinParser;
    result_data: TncPinyinParseResult;
    long_input: string;
    index: Integer;
begin
    parser := TncPinyinParser.Create;
    try
        long_input := '';
        SetLength(long_input, 256);
        for index := 1 to Length(long_input) do
            long_input[index] := '#';
        result_data := parser.Parse(long_input);
        AssertEquals(256, Length(result_data));
        AssertEquals(255, result_data[255].start_index);
        AssertTrue(result_data[255].text = '#');
    finally
        parser.Free;
    end;
end;

procedure TncPinyinParserTests.ValidateCanonicalSyllableHelpers;
begin
    AssertTrue(nc_is_canonical_pinyin_syllable('shei'));
    AssertTrue(nc_is_canonical_pinyin_syllable('jue'));
    AssertFalse(nc_is_canonical_pinyin_syllable('bue'));
    AssertTrue(nc_is_pinyin_spelling_helper_compatible('j', 'ue'));
    AssertFalse(nc_is_pinyin_spelling_helper_compatible('y', 'ia'));
end;

initialization
    RegisterTest(TncPinyinParserTests);

end.
