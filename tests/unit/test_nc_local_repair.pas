unit test_nc_local_repair;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses fpcunit, testregistry;

type
    TncLocalRepairTests = class(TTestCase)
    published
        procedure UnsupportedWordPreservesIndependentEdit;
        procedure WordRatioAndUserWordAreProtected;
        procedure InvalidAlignmentAndExcessSpansAreRejected;
        procedure MissingAndMalformedModelFailClosed;
    end;

implementation

uses SysUtils, Classes, Math, nc_types, nc_dictionary_intf,
    nc_local_repair_guard, nc_local_repair_host;

type
    TGuardDictionary = class(TncDictionaryProvider)
    public
        user_word, replacement_exists: Boolean;
        replacement_weight: Integer;
        function lookup(const pinyin: string; out results: TncCandidateList): Boolean; override;
        function lookup_isolated_exact_component(const pinyin: string;
            out results: TncCandidateList): Boolean; override;
    end;

function TGuardDictionary.lookup(const pinyin: string; out results: TncCandidateList): Boolean;
begin
    results := nil;
    Result := False;
end;

function TGuardDictionary.lookup_isolated_exact_component(const pinyin: string;
    out results: TncCandidateList): Boolean;
begin
    results := nil;
    SetLength(results, 1 + Ord(replacement_exists));
    results[0].text := 'AB';
    results[0].has_dict_weight := True;
    results[0].dict_weight := 1000;
    if user_word then results[0].source := cs_user;
    if replacement_exists then
    begin
        results[1].text := 'XY';
        results[1].has_dict_weight := True;
        results[1].dict_weight := replacement_weight;
    end;
    Result := True;
end;

const
    syllables = 'a'#3'b'#3'c'#3'd'#3'e'#3'f';
    original_path = 'AB'#3'C'#3'D'#3'E'#3'F';

procedure TncLocalRepairTests.UnsupportedWordPreservesIndependentEdit;
var dictionary: TGuardDictionary;
begin
    dictionary := TGuardDictionary.Create;
    try
        AssertEquals('ABCDQF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XYCDQF', original_path, syllables, 0.01));
        AssertEquals('XBCYEF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XBCYEF', '', syllables, 0.01));
    finally
        dictionary.Free;
    end;
end;

procedure TncLocalRepairTests.WordRatioAndUserWordAreProtected;
var dictionary: TGuardDictionary;
begin
    dictionary := TGuardDictionary.Create;
    try
        dictionary.replacement_exists := True;
        dictionary.replacement_weight := 9;
        AssertEquals('ABCDQF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XYCDQF', original_path, syllables, 0.01));
        dictionary.replacement_weight := 10;
        AssertEquals('XYCDQF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XYCDQF', original_path, syllables, 0.01));
        dictionary.user_word := True;
        AssertEquals('ABCDQF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XYCDQF', original_path, syllables, 0.01));
    finally
        dictionary.Free;
    end;
end;

procedure TncLocalRepairTests.InvalidAlignmentAndExcessSpansAreRejected;
var dictionary: TGuardDictionary;
begin
    dictionary := TGuardDictionary.Create;
    try
        AssertEquals('ABCDEF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XYCDQF', original_path, 'a'#3'b', 0.01));
        AssertEquals('ABCDEF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XYZ', original_path, syllables, 0.01));
        AssertEquals('ABCDEF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XYCDQF', original_path, syllables, NaN));
        dictionary.replacement_exists := True;
        dictionary.replacement_weight := 10;
        AssertEquals('ABCDEF', guard_local_repair_words(dictionary,
            'ABCDEF', 'XYCZEX', original_path, syllables, 0.01));
    finally
        dictionary.Free;
    end;
end;

procedure TncLocalRepairTests.MissingAndMalformedModelFailClosed;
var
    root, path, repaired, aligned: string;
    ratio: Double;
    model: TncLocalRepairHost;
    guid: TGUID;
    stream: TFileStream;
    content: UTF8String;
begin
    CreateGUID(guid);
    root := UTF8Decode(IncludeTrailingPathDelimiter(GetTempDir)) +
        'cassotis-repair-' + UnicodeString(GUIDToString(guid)) + '-' + #$8A00#$6CC9;
    path := root + '/local_repair/runtime_manifest.json';
    ForceDirectories(UTF8Encode(ExtractFileDir(path)));
    try
        model := TncLocalRepairHost.Create(root, 30);
        try
            AssertTrue(model.wait_until_ready(5000));
            AssertFalse(model.ready);
            AssertEquals('', model.last_error);
            AssertFalse(model.try_repair('womenjintianfaxian',
                #$6211#$4EEC#$4ECA#$5929#$53D1#$73B0, '', '', repaired, aligned, ratio));
        finally
            model.Free;
        end;
        content := '{"enabled":true,"format":999}';
        stream := TFileStream.Create(UTF8Encode(path), fmCreate);
        try
            stream.WriteBuffer(content[1], Length(content));
        finally
            stream.Free;
        end;
        model := TncLocalRepairHost.Create(root, 30);
        try
            AssertTrue(model.wait_until_ready(5000));
            AssertFalse(model.ready);
            AssertEquals('Unsupported local repair model format', model.last_error);
            model.set_document_context('doc-a', 'Previous sentence.');
            AssertFalse(model.try_repair('womenjintianfaxian',
                #$6211#$4EEC#$4ECA#$5929#$53D1#$73B0, 'doc-a', 'Previous sentence.',
                repaired, aligned, ratio));
        finally
            model.Free;
        end;
    finally
        DeleteFile(UTF8Encode(path));
        RemoveDir(UTF8Encode(ExtractFileDir(path)));
        RemoveDir(UTF8Encode(root));
    end;
end;

initialization
    RegisterTest(TncLocalRepairTests);
end.
