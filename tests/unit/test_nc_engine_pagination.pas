unit test_nc_engine_pagination;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry;

type
    TncEnginePaginationTests = class(TTestCase)
    published
        procedure PreservesDisplacedFirstSyllableCandidateAcrossPages;
    end;

implementation

uses
    SysUtils,
    Generics.Collections,
    nc_types,
    nc_config,
    nc_dictionary_intf,
    nc_engine_intf;

type
    TncPaginationTestDictionary = class(TncDictionaryProvider)
    public
        function lookup(const pinyin: string;
            out results: TncCandidateList): Boolean; override;
    end;

function TextFromCodepoints(const values: array of Word): string;
var
    index: Integer;
begin
    Result := '';
    for index := Low(values) to High(values) do
        Result := Result + WideChar(values[index]);
end;

procedure SetCandidate(out candidate: TncCandidate; const text: string;
    const score: Integer);
begin
    candidate := Default(TncCandidate);
    candidate.text := text;
    candidate.score := score;
    candidate.source := cs_rule;
    candidate.has_dict_weight := True;
    candidate.dict_weight := score;
end;

function TncPaginationTestDictionary.lookup(const pinyin: string;
    out results: TncCandidateList): Boolean;
var
    key: string;
begin
    SetLength(results, 0);
    key := LowerCase(Trim(pinyin));
    if key = 'jiuweile' then
    begin
        SetLength(results, 5);
        SetCandidate(results[0], TextFromCodepoints([$4E45, $8FDD, $4E86]), 900);
        SetCandidate(results[1], TextFromCodepoints([$4E5D, $5C3E, $4E86]), 800);
        SetCandidate(results[2], TextFromCodepoints([$9152, $5473, $4E86]), 700);
        SetCandidate(results[3], TextFromCodepoints([$4E45, $672A, $4E86]), 600);
        SetCandidate(results[4], TextFromCodepoints([$5C31, $4E3A, $4E86]), 500);
        Exit(True);
    end;
    if key = 'jiuwei' then
    begin
        SetLength(results, 4);
        SetCandidate(results[0], TextFromCodepoints([$4E45, $8FDD]), 900);
        SetCandidate(results[1], TextFromCodepoints([$4E5D, $5C3E]), 800);
        SetCandidate(results[2], TextFromCodepoints([$9152, $5473]), 700);
        SetCandidate(results[3], TextFromCodepoints([$4E45, $672A]), 600);
        Exit(True);
    end;
    if key = 'jiu' then
    begin
        SetLength(results, 4);
        SetCandidate(results[0], TextFromCodepoints([$5C31]), 1000);
        SetCandidate(results[1], TextFromCodepoints([$4E5D]), 800);
        SetCandidate(results[2], TextFromCodepoints([$7A76]), 700);
        SetCandidate(results[3], TextFromCodepoints([$4E45]), 600);
        Exit(True);
    end;
    if key = 'wei' then
    begin
        SetLength(results, 2);
        SetCandidate(results[0], TextFromCodepoints([$4E3A]), 1000);
        SetCandidate(results[1], TextFromCodepoints([$672A]), 700);
        Exit(True);
    end;
    if key = 'le' then
    begin
        SetLength(results, 1);
        SetCandidate(results[0], TextFromCodepoints([$4E86]), 1000);
        Exit(True);
    end;
    Result := False;
end;

function BuildConfig: TncEngineConfig;
begin
    Result := Default(TncEngineConfig);
    Result.input_mode := im_chinese;
    Result.pinyin_input_scheme := pis_full_pinyin;
    Result.max_candidates := 9;
    Result.enable_segment_candidates := True;
    Result.segment_head_only_multi_syllable := True;
    Result.candidate_page_size := c_default_candidate_page_size;
    Result.candidate_page_key_scheme := cpks_minus_plus;
    Result.one_key_completion_key := ock_tab;
    Result.dictionary_variant := dv_simplified;
end;

function FeedText(const engine: TncEngine; const text: string): Boolean;
var
    index: Integer;
    key_state: TncKeyState;
begin
    Result := True;
    key_state := Default(TncKeyState);
    for index := 1 to Length(text) do
        if not engine.process_key(Ord(UpCase(text[index])), key_state) then
            Exit(False);
end;

procedure TncEnginePaginationTests.PreservesDisplacedFirstSyllableCandidateAcrossPages;
var
    engine: TncEngine;
    candidates: TncCandidateList;
    first_page_candidates: TncCandidateList;
    seen_candidates: TDictionary<string, Boolean>;
    candidate_key: string;
    target_text: string;
    candidate_index: Integer;
    page_index: Integer;
    target_count: Integer;
    target_page: Integer;
    target_index: Integer;
    key_state: TncKeyState;
begin
    engine := TncEngine.Create(BuildConfig);
    seen_candidates := TDictionary<string, Boolean>.Create;
    try
        engine.set_dictionary_provider(TncPaginationTestDictionary.Create);
        AssertTrue(FeedText(engine, 'jiuweile'));
        target_text := TextFromCodepoints([$5C31]);
        target_count := 0;
        target_page := -1;
        target_index := -1;
        page_index := 0;
        repeat
            candidates := engine.get_candidates;
            if page_index = 0 then
                first_page_candidates := Copy(candidates, 0, Length(candidates));
            for candidate_index := 0 to High(candidates) do
            begin
                candidate_key := LowerCase(Trim(candidates[candidate_index].text)) +
                    #1 + LowerCase(Trim(candidates[candidate_index].comment));
                AssertFalse('candidate repeated across pages',
                    seen_candidates.ContainsKey(candidate_key));
                seen_candidates.Add(candidate_key, True);
                if (LowerCase(Trim(candidates[candidate_index].text)) =
                    LowerCase(target_text)) and
                    (LowerCase(Trim(candidates[candidate_index].comment)) = 'weile') then
                begin
                    Inc(target_count);
                    target_page := page_index;
                    target_index := candidate_index;
                end;
            end;
            Inc(page_index);
        until not engine.next_page;

        AssertEquals('the displaced first-syllable candidate must remain ' +
            'visible exactly once', 1, target_count);
        while engine.prev_page do
        begin
        end;
        candidates := engine.get_candidates;
        AssertEquals(Length(first_page_candidates), Length(candidates));
        for candidate_index := 0 to High(first_page_candidates) do
        begin
            AssertEquals(first_page_candidates[candidate_index].text,
                candidates[candidate_index].text);
            AssertEquals(first_page_candidates[candidate_index].comment,
                candidates[candidate_index].comment);
        end;
        for page_index := 1 to target_page do
            AssertTrue(engine.next_page);
        candidates := engine.get_candidates;
        AssertTrue((target_index >= 0) and
            (target_index < Length(candidates)));
        key_state := Default(TncKeyState);
        AssertTrue(engine.process_key(Ord('1') + target_index, key_state));
        AssertEquals(1, engine.get_confirmed_length);
        AssertEquals('weile', engine.get_last_lookup_key);
    finally
        seen_candidates.Free;
        engine.Free;
    end;
end;

initialization
    RegisterTest(TncEnginePaginationTests);

end.
