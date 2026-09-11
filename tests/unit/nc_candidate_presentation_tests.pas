unit nc_candidate_presentation_tests;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, fpcunit, testregistry, nc_port_test_support, nc_types, nc_candidate_presentation;

type
    TncCandidatePresentationTests = class(TTestCase)
    published
        procedure prefix_order_is_stable_and_metadata_moves_together;
        procedure complete_slots_and_snapshot_ownership_are_preserved;
        procedure paging_is_lossless_for_all_supported_sizes;
        procedure page_limits_are_safe;
        procedure identity_keeps_distinct_remaining_input;
        procedure malformed_metadata_is_rejected;
        procedure multi_word_prefixes_compete_by_existing_weight;
        procedure prefix_score_ties_prefer_longer_matches;
        procedure uncalibrated_path_scores_do_not_override_prefix_lengths;
    end;

implementation

procedure TncCandidatePresentationTests.multi_word_prefixes_compete_by_existing_weight;
const
    lengths: array[0..6] of Integer = (3, 3, 2, 2, 2, 1, 0);
    scores: array[0..6] of Integer = (1744, 1499, 3956, 3236, 1880, MaxInt, 0);
    weights: array[0..6] of Integer = (1000, 1, 2680, 1960, 604, MaxInt, 0);
    expected: array[0..6] of Integer = (2, 3, 0, 4, 1, 5, 6);
var pool: TncCandidateList; sources, units: TArray<Integer>; idx: Integer;
begin
    SetLength(pool, Length(lengths));
    SetLength(sources, Length(lengths));
    SetLength(units, Length(lengths));
    for idx := 0 to High(lengths) do
    begin
        pool[idx].text := IntToStr(idx);
        pool[idx].score := scores[idx];
        pool[idx].has_dict_weight := True;
        pool[idx].dict_weight := weights[idx];
        sources[idx] := idx + 10;
        units[idx] := lengths[idx];
    end;
    nc_order_candidate_prefix_tiers(pool, sources, units, 3);
    for idx := 0 to High(expected) do
    begin
        Assert.AreEqual(IntToStr(expected[idx]), pool[idx].text);
        Assert.AreEqual(expected[idx] + 10, sources[idx]);
        Assert.AreEqual(scores[expected[idx]], pool[idx].score);
    end;
end;

procedure TncCandidatePresentationTests.prefix_score_ties_prefer_longer_matches;
var pool: TncCandidateList; sources, units: TArray<Integer>;
begin
    SetLength(pool, 2);
    pool[0].text := 'short';
    pool[0].score := 1000;
    pool[0].has_dict_weight := True;
    pool[0].dict_weight := 1750;
    pool[1].text := 'long';
    pool[1].score := 1000;
    pool[1].has_dict_weight := True;
    pool[1].dict_weight := 1000;
    sources := TArray<Integer>.Create(0, 1);
    units := TArray<Integer>.Create(2, 3);
    nc_order_candidate_prefix_tiers(pool, sources, units, 3);
    Assert.AreEqual('long', pool[0].text);
    Assert.AreEqual('short', pool[1].text);
end;

procedure TncCandidatePresentationTests.uncalibrated_path_scores_do_not_override_prefix_lengths;
var pool: TncCandidateList; sources, units: TArray<Integer>;
begin
    SetLength(pool, 2);
    pool[0].text := 'word';
    pool[0].score := MaxInt;
    pool[0].has_dict_weight := True;
    pool[0].dict_weight := 3000;
    pool[1].text := 'generated';
    pool[1].score := Low(Integer);
    pool[1].has_dict_weight := False;
    sources := TArray<Integer>.Create(0, 1);
    units := TArray<Integer>.Create(2, 3);
    nc_order_candidate_prefix_tiers(pool, sources, units, 3);
    Assert.AreEqual('generated', pool[0].text);
    Assert.AreEqual('word', pool[1].text);
end;

procedure make_pool(const count: Integer; out pool: TncCandidateList;
    out sources: TArray<Integer>; out units: TArray<Integer>);
var idx: Integer;
begin
    SetLength(pool, count);
    SetLength(sources, count);
    SetLength(units, count);
    for idx := 0 to count - 1 do
    begin
        pool[idx] := Default(TncCandidate);
        pool[idx].text := IntToStr(idx);
        pool[idx].comment := 'tail' + IntToStr(idx);
        pool[idx].score := idx * 11;
        pool[idx].dict_weight := idx * 7;
        pool[idx].has_dict_weight := (idx mod 2) = 0;
        pool[idx].source := TncCandidateSource(idx mod 2);
        pool[idx].display_kind := TncCandidateDisplayKind(idx mod 2);
        pool[idx].fuzzy_cost := idx mod 3;
        sources[idx] := idx - 1;
        units[idx] := (idx * 7 + idx div 5) mod 4;
        if units[idx] = 0 then pool[idx].comment := '';
    end;
end;

procedure TncCandidatePresentationTests.prefix_order_is_stable_and_metadata_moves_together;
var pool: TncCandidateList; sources, units: TArray<Integer>;
    count, idx, original: Integer;
    last_indices: array[1..3] of Integer;
    seen: TArray<Boolean>;
    saw_single: Boolean;
begin
    for count := 0 to 128 do
    begin
        make_pool(count, pool, sources, units);
        nc_order_candidate_prefix_tiers(pool, sources, units, 3);
        SetLength(seen, count);
        for idx := 0 to High(seen) do seen[idx] := False;
        saw_single := False;
        for idx := 1 to 3 do last_indices[idx] := -1;
        for idx := 0 to High(pool) do
        begin
            original := StrToInt(pool[idx].text);
            Assert.IsFalse(seen[original]);
            Assert.AreEqual(original - 1, sources[idx]);
            Assert.AreEqual(original * 11, pool[idx].score);
            Assert.AreEqual(original * 7, pool[idx].dict_weight);
            Assert.AreEqual(original mod 2, Integer(Ord(pool[idx].source)));
            Assert.AreEqual(original mod 2, Integer(Ord(pool[idx].display_kind)));
            Assert.AreEqual(original mod 3, pool[idx].fuzzy_cost);
            if units[idx] = 0 then Assert.AreEqual(idx, original)
            else
            begin
                if units[original] = 1 then saw_single := True
                else Assert.IsFalse(saw_single, 'Word prefix after a single');
                Assert.IsTrue(original > last_indices[units[original]]);
                last_indices[units[original]] := original;
            end;
            seen[original] := True;
        end;
    end;
end;

procedure TncCandidatePresentationTests.complete_slots_and_snapshot_ownership_are_preserved;
var pool, retained, ordered: TncCandidateList; sources, retained_sources, units: TArray<Integer>;
    idx: Integer;
begin
    make_pool(41, pool, sources, units);
    retained := pool;
    retained_sources := sources;
    nc_order_candidate_prefix_tiers(pool, sources, units, 3);
    for idx := 0 to High(retained) do
    begin
        Assert.AreEqual(IntToStr(idx), retained[idx].text);
        Assert.AreEqual(idx - 1, retained_sources[idx]);
        if units[idx] = 0 then Assert.AreEqual(retained[idx].text, pool[idx].text);
    end;
    // Recompute markers from the ordered records, not from their old positions.
    for idx := 0 to High(pool) do
    begin
        units[idx] := (StrToInt(pool[idx].text) * 7 + StrToInt(pool[idx].text) div 5) mod 4;
    end;
    ordered := Copy(pool);
    nc_order_candidate_prefix_tiers(pool, sources, units, 3);
    for idx := 0 to High(pool) do Assert.AreEqual(ordered[idx].text, pool[idx].text);
end;

procedure TncCandidatePresentationTests.paging_is_lossless_for_all_supported_sizes;
var pool, page: TncCandidateList; sources, units, page_sources: TArray<Integer>;
    count, size, page_index, idx, seen: Integer;
begin
    for count := 0 to 80 do
    begin
        make_pool(count, pool, sources, units);
        for size := c_min_candidate_page_size to c_max_candidate_page_size do
        begin
            seen := 0;
            for page_index := 0 to nc_candidate_page_count(count, size) - 1 do
            begin
                nc_copy_candidate_page(pool, sources, page_index, size, page, page_sources);
                Assert.IsTrue(Length(page) > 0);
                Assert.IsTrue(Length(page) <= size);
                for idx := 0 to High(page) do
                begin
                    Assert.AreEqual(IntToStr(seen), page[idx].text);
                    Assert.AreEqual(seen - 1, page_sources[idx]);
                    Inc(seen);
                end;
                if Length(page) > 0 then page[0].text := 'caller mutation';
            end;
            Assert.AreEqual(count, seen);
        end;
    end;
end;

procedure TncCandidatePresentationTests.page_limits_are_safe;
begin
    Assert.AreEqual(0, nc_candidate_page_count(0, 9));
    Assert.AreEqual(0, nc_candidate_page_count(-1, 9));
    Assert.AreEqual(0, nc_candidate_page_count(1, 0));
    Assert.AreEqual(MaxInt, nc_candidate_page_count(MaxInt, 1));
    Assert.AreEqual(0, nc_candidate_page_items(10, MaxInt, 9));
    Assert.AreEqual(0, nc_candidate_page_items(10, -1, 9));
    Assert.AreEqual(0, nc_candidate_page_items(10, 0, 0));
    Assert.AreEqual(1, nc_candidate_page_items(10, 1, 9));
end;

procedure TncCandidatePresentationTests.identity_keeps_distinct_remaining_input;
var candidate: TncCandidate;
begin
    candidate := Default(TncCandidate);
    candidate.text := 'Word';
    Assert.AreEqual('word' + #0 + 'tail', nc_visible_candidate_key(candidate, 'TAIL'));
    Assert.AreNotEqual(nc_visible_candidate_key(candidate, ''),
        nc_visible_candidate_key(candidate, 'tail'));
    candidate.text := ' word ';
    Assert.AreEqual('word' + #0, nc_visible_candidate_key(candidate, ''));
end;

procedure TncCandidatePresentationTests.malformed_metadata_is_rejected;
var pool, page: TncCandidateList; sources, units, page_sources: TArray<Integer>;
    rejected: Boolean;
begin
    make_pool(4, pool, sources, units);
    SetLength(sources, 3);
    rejected := False;
    try
        nc_copy_candidate_page(pool, sources, 0, 9, page, page_sources);
    except
        on EArgumentException do rejected := True;
    end;
    Assert.IsTrue(rejected, 'Paging must reject mismatched selection sources');
    rejected := False;
    try
        nc_order_candidate_prefix_tiers(pool, sources, units, 3);
    except
        on EArgumentException do rejected := True;
    end;
    Assert.IsTrue(rejected, 'Prefix ordering must reject mismatched metadata');
end;


initialization
    RegisterTest(TncCandidatePresentationTests);
end.
