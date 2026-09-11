unit nc_local_repair_boundary_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses fpcunit, testregistry;

type
    TncLocalRepairBoundaryTests = class(TTestCase)
    published
        procedure TestBoundaries;
    end;

implementation

uses SysUtils, Math, Generics.Collections,
    nc_dictionary_intf, nc_types, nc_local_repair_guard;

type
    TBoundaryDictionary = class(TncDictionaryProvider)
    private
        entries: TDictionary<string, TncCandidate>;
    public
        lm_gain, calls: Integer;
        lm_available, reading_valid: Boolean;
        constructor Create;
        destructor Destroy; override;
        procedure add(const pinyin, text: string; const weight: Integer;
            const user: Boolean = False);
        function lookup(const pinyin: string; out results: TncCandidateList): Boolean; override;
        function single_char_matches_pinyin(const pinyin, text_unit: string): Boolean; override;
        function get_char_lm_continuation_scores(const left_context: string;
            const texts: TArray<string>; out scores: TArray<Integer>): Boolean; override;
    end;

constructor TBoundaryDictionary.Create;
begin
    inherited;
    entries := TDictionary<string, TncCandidate>.Create;
    lm_available := True;
    reading_valid := True;
    lm_gain := 100;
end;

destructor TBoundaryDictionary.Destroy;
begin entries.Free; inherited; end;

procedure TBoundaryDictionary.add(const pinyin, text: string; const weight: Integer; const user: Boolean);
var item: TncCandidate;
begin
    item := Default(TncCandidate);
    item.text := text;
    item.has_dict_weight := True;
    item.dict_weight := weight;
    if user then item.source := cs_user;
    entries.AddOrSetValue(pinyin + #0 + text, item);
end;

function TBoundaryDictionary.lookup(const pinyin: string; out results: TncCandidateList): Boolean;
var pair: TPair<string, TncCandidate>;
begin
    Inc(calls);
    results := nil;
    for pair in entries do
        if pair.Key.StartsWith(pinyin + #0) then
        begin
            SetLength(results, Length(results) + 1);
            results[High(results)] := pair.Value;
        end;
    Result := Length(results) > 0;
end;

function TBoundaryDictionary.single_char_matches_pinyin(const pinyin, text_unit: string): Boolean;
begin Result := reading_valid and entries.ContainsKey(pinyin + #0 + text_unit); end;

function TBoundaryDictionary.get_char_lm_continuation_scores(const left_context: string;
    const texts: TArray<string>; out scores: TArray<Integer>): Boolean;
begin
    scores := TArray<Integer>.Create(-1000, -1000 + lm_gain);
    Result := lm_available;
end;

procedure TncLocalRepairBoundaryTests.TestBoundaries;
const
    draft = 'ABCDEF';
    proposal = 'ABCXEF';
    path = 'AB'#3'C'#3'DE'#3'F';
    py = 'a'#3'b'#3'c'#3'd'#3'e'#3'f';
var dictionary: TBoundaryDictionary;
    value: TncValidatedRepairPath;
    i: Integer;
    procedure check(const expected: string; const name: string);
    begin
        value := validate_local_repair_path(dictionary, draft, proposal, path, py, 0.01, True);
        if value.text <> expected then raise Exception.Create('Boundary contract: ' + name);
        if value.exact_path and
            ((StringReplace(value.segment_path, #3, '', [rfReplaceAll]) <> value.text) or
             (value.aligned_pinyin <> py)) then
            raise Exception.Create('Boundary contract: mismatched trusted path metadata');
    end;
begin
    dictionary := TBoundaryDictionary.Create;
    try
        for i := 1 to Length(draft) do
            dictionary.add(LowerCase(draft[i]), draft[i], 1000);
        dictionary.add('d', 'X', 1000);
        dictionary.add('ab', 'AB', 100);
        dictionary.add('de', 'DE', 100);
        dictionary.add('cd', 'CX', 100);
        check(proposal, 'crossing old boundary');
        if not value.exact_path or not value.boundary_repaired or
            (value.segment_path <> 'AB'#3'CX'#3'E'#3'F') then
            raise Exception.Create('Boundary contract: whole validated path');
        if dictionary.calls > 35 then raise Exception.Create('Unbounded component queries');
        value := validate_local_repair_path(dictionary, draft, proposal, path, py, 0.01, False);
        if value.text <> draft then raise Exception.Create('Disabled boundary guard changed text');
        dictionary.lm_gain := -1;
        check(draft, 'negative LM support');
        dictionary.lm_gain := 100;
        dictionary.lm_available := False;
        check(draft, 'missing LM');
        dictionary.lm_available := True;
        dictionary.reading_valid := False;
        check(draft, 'invalid per-syllable reading');
        dictionary.reading_valid := True;
        dictionary.add('de', 'XE', 0);
        check(draft, 'same-boundary low weight is not bypassed');
        dictionary.add('de', 'DE', 100, True);
        check(draft, 'user word remains immutable');
        if value.exact_path then
            raise Exception.Create('A user-containing path was marked reusable for Tab');
        value := validate_local_repair_path(dictionary, draft, proposal, path, py, NaN, True);
        if value.text <> draft then raise Exception.Create('Non-finite ratio accepted');
        value := validate_local_repair_path(dictionary, draft, proposal, path, 'a'#3'b', 0.01, True);
        if value.text <> draft then raise Exception.Create('Mismatched pinyin accepted');
        if value.exact_path then raise Exception.Create('Mismatched pinyin marked trusted');
        value := validate_local_repair_path(dictionary, draft, proposal, 'AB'#3'CF', py, 0.01, True);
        if value.exact_path then raise Exception.Create('Incomplete original path marked trusted');
        dictionary.add('de', 'DE', 100);
        dictionary.add('cd', 'CD', 100);
        dictionary.add('ef', 'EF', 100);
        dictionary.add('c', 'X', 1000);
        dictionary.add('d', 'Y', 1000);
        value := validate_local_repair_path(dictionary, draft, 'ABXYEF',
            'AB'#3'CD'#3'EF', py, 0.01, True);
        if value.text <> draft then
            raise Exception.Create('An unchanged neighbor licensed singleton word destruction');
        WriteLn('Boundary resegmentation contracts: PASS');
    finally
        dictionary.Free;
    end;
end;

initialization
    RegisterTest(TncLocalRepairBoundaryTests);
end.
