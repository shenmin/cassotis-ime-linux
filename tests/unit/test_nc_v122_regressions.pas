unit test_nc_v122_regressions;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses fpcunit, testregistry;

type
    TncV122RegressionTests = class(TTestCase)
    published
        procedure StaticCompletionCanBeChallengedWithoutFlicker;
    end;

implementation

uses SysUtils, nc_config, nc_types, nc_dictionary_intf, nc_engine_intf;

const
    c_we = #$6211#$4EEC;
    c_today = #$4ECA#$5929;
    c_eat = #$5403#$996D;
    c_sleep = #$7761#$89C9;
    c_go = #$53BB;

type
    TCompletionDictionary = class(TncDictionaryProvider)
    public
        function lookup(const pinyin: string;
            out results: TncCandidateList): Boolean; override;
        function is_base_entry(const pinyin: string;
            const text: string): Boolean; override;
        function get_exact_pair_path_evidence(const query_key: string;
            out results: TncPairPathEvidenceList): Boolean; override;
        function lookup_long_one_key_completions(const anchor_path: string;
            out results: TncLongOneKeyCompletionList): Boolean; override;
    end;

function TCompletionDictionary.lookup(const pinyin: string;
    out results: TncCandidateList): Boolean;
var text: string;
begin
    text := '';
    if pinyin = 'wo' then text := c_we[1];
    if pinyin = 'men' then text := c_we[2];
    if pinyin = 'women' then text := c_we;
    if pinyin = 'jin' then text := c_today[1];
    if pinyin = 'tian' then text := c_today[2];
    if pinyin = 'jintian' then text := c_today;
    if pinyin = 'chi' then text := c_eat[1];
    if pinyin = 'fan' then text := c_eat[2];
    if pinyin = 'chifan' then text := c_eat;
    if pinyin = 'shui' then text := c_sleep[1];
    if pinyin = 'jiao' then text := c_sleep[2];
    if pinyin = 'shuijiao' then text := c_sleep;
    if pinyin = 'qu' then text := c_go;
    results := nil;
    Result := text <> '';
    if not Result then Exit;
    SetLength(results, 1);
    results[0].text := text;
    results[0].source := cs_rule;
    results[0].score := 1000;
    results[0].dict_weight := 1000;
    results[0].has_dict_weight := True;
end;

function TCompletionDictionary.is_base_entry(const pinyin: string;
    const text: string): Boolean;
var candidates: TncCandidateList;
begin
    Result := lookup(pinyin, candidates) and (Length(candidates) > 0);
    if Result then Result := candidates[0].text = text;
end;

function TCompletionDictionary.get_exact_pair_path_evidence(
    const query_key: string; out results: TncPairPathEvidenceList): Boolean;
begin
    results := nil;
    Result := query_key = 'womenjintian';
    if not Result then Exit;
    SetLength(results, 1);
    results[0].encoded_path := c_we + #3 + c_today;
    results[0].lm_transition_weight := 800;
end;

function TCompletionDictionary.lookup_long_one_key_completions(
    const anchor_path: string; out results: TncLongOneKeyCompletionList): Boolean;
begin
    results := nil;
    Result := anchor_path = c_we + #3 + c_today;
    if not Result then Exit;
    SetLength(results, 1);
    results[0].anchor_path := anchor_path;
    results[0].anchor_text := c_we + c_today;
    results[0].suffix_pinyin := 'chifan';
    results[0].suffix_text := c_eat;
    results[0].suffix_path := c_eat;
    results[0].evidence := 800;
    results[0].source_count := 20;
end;

procedure TncV122RegressionTests.StaticCompletionCanBeChallengedWithoutFlicker;
var
    engine: TncEngine;
    request, saved_request: TncLongNeuralCompletionRequest;
    neural: TncLongNeuralCompletionResult;
    completion, original: TncOneKeyCompletion;
begin
    engine := TncEngine.Create(nc_default_engine_config);
    try
        engine.set_dictionary_provider(TCompletionDictionary.Create);
        engine.debug_set_search_budget_policy(sbm_deterministic, 100);
        engine.debug_set_composition_text('womenjintian');
        original := engine.get_one_key_completion;
        AssertEquals('static completion fixture', c_we + c_today + c_eat,
            original.text);
        AssertEquals(Ord(okcs_long_transition), Ord(original.source));
        AssertTrue('static transition must not suppress the background request',
            engine.get_long_neural_completion_request(request));
        saved_request := request;
        AssertFalse(request.phonetic_only);
        completion := engine.get_one_key_completion;
        AssertEquals('pending request must not hide the static result',
            original.text, completion.text);

        neural := Default(TncLongNeuralCompletionResult);
        neural.base_rank := 1;
        neural.suffix_text := c_sleep;
        neural.suffix_path := c_sleep;
        neural.suffix_pinyin_path := 'shuijiao';
        neural.confidence := -2.51;
        AssertFalse('weak challenge displaced the static result',
            engine.apply_long_neural_completion(request, neural));
        completion := engine.get_one_key_completion;
        AssertEquals(original.text, completion.text);

        neural.suffix_text := c_eat;
        neural.suffix_path := c_eat;
        neural.suffix_pinyin_path := 'chifan';
        neural.confidence := 1;
        AssertFalse('identical completion must not request a repaint',
            engine.apply_long_neural_completion(request, neural));
        completion := engine.get_one_key_completion;
        AssertEquals(Ord(okcs_long_transition), Ord(completion.source));
        AssertEquals(original.full_pinyin, completion.full_pinyin);

        neural.suffix_text := c_go;
        neural.suffix_path := c_go;
        neural.suffix_pinyin_path := 'qu';
        neural.confidence := -0.01;
        AssertFalse('single-character challenge requires nonnegative confidence',
            engine.apply_long_neural_completion(request, neural));

        neural.suffix_text := c_sleep;
        neural.suffix_path := c_sleep;
        neural.suffix_pinyin_path := 'shuijiao';
        neural.confidence := -2.5;
        AssertTrue('eligible multi-character challenge was rejected',
            engine.apply_long_neural_completion(request, neural));
        completion := engine.get_one_key_completion;
        AssertEquals(c_we + c_today + c_sleep, completion.text);
        AssertEquals(Ord(okcs_long_neural), Ord(completion.source));
        AssertFalse('accepted result must not be submitted again',
            engine.get_long_neural_completion_request(request));
        engine.reset;
        engine.debug_set_composition_text('women');
        AssertFalse('a stale result must not apply to a new query',
            engine.apply_long_neural_completion(saved_request, neural));
    finally
        engine.Free;
    end;
end;

initialization
    RegisterTest(TncV122RegressionTests);
end.
