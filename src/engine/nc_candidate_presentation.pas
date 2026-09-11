unit nc_candidate_presentation;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils, nc_types;

// Presentation only: no dictionary queries, learning, LM scoring or truncation.
function nc_visible_candidate_key(const candidate: TncCandidate;
    const normalized_tail: string): string;
function nc_candidate_page_count(const total, page_size: Integer): Integer;
function nc_candidate_page_items(const total, page_index, page_size: Integer): Integer;
procedure nc_copy_candidate_page(const candidates: TncCandidateList;
    const sources: TArray<Integer>; const page_index, page_size: Integer;
    out page: TncCandidateList; out page_sources: TArray<Integer>);
procedure nc_order_candidate_prefix_tiers(var candidates: TncCandidateList;
    var sources: TArray<Integer>; const prefix_units: TArray<Integer>;
    const max_prefix_units: Integer);

implementation

function nc_visible_candidate_key(const candidate: TncCandidate;
    const normalized_tail: string): string;
begin
    Result := LowerCase(Trim(candidate.text)) + #0 + LowerCase(normalized_tail);
end;

function nc_candidate_page_count(const total, page_size: Integer): Integer;
begin
    if (total <= 0) or (page_size <= 0) then Exit(0);
    Result := 1 + (total - 1) div page_size;
end;

function nc_candidate_page_items(const total, page_index, page_size: Integer): Integer;
var offset: Int64;
begin
    Result := 0;
    if (total <= 0) or (page_index < 0) or (page_size <= 0) then Exit;
    offset := Int64(page_index) * page_size;
    if offset >= total then Exit;
    Result := total - Integer(offset);
    if Result > page_size then Result := page_size;
end;

procedure nc_copy_candidate_page(const candidates: TncCandidateList;
    const sources: TArray<Integer>; const page_index, page_size: Integer;
    out page: TncCandidateList; out page_sources: TArray<Integer>);
var count, offset: Integer;
begin
    if Length(candidates) <> Length(sources) then
        raise EArgumentException.Create('Candidate/source count mismatch');
    count := nc_candidate_page_items(Length(candidates), page_index, page_size);
    offset := 0;
    if count > 0 then offset := Integer(Int64(page_index) * page_size);
    page := Copy(candidates, offset, count);
    page_sources := Copy(sources, offset, count);
end;

procedure nc_order_candidate_prefix_tiers(var candidates: TncCandidateList;
    var sources: TArray<Integer>; const prefix_units: TArray<Integer>;
    const max_prefix_units: Integer);
var
    original: TncCandidateList;
    original_sources: TArray<Integer>;
    heads, tails, next_indices, ordered_indices: TArray<Integer>;
    idx, units, highest_units, picked_units, picked_idx, probe_idx: Integer;
    needs_order: Boolean;

    function weight_priority(const candidate_idx, matched_units: Integer): Int64;
    begin
        // Each extra matched syllable adds 75% of this word's weight,
        // not a flat bonus that could turn a weight-1 term into a common word.
        Result := candidates[candidate_idx].dict_weight;
        if Result < 0 then Result := 0;
        Result := Result * (4 + Int64(matched_units - 2) * 3);
    end;

    function comparable_dictionary_prefix(const candidate_idx: Integer): Boolean;
    begin
        Result := candidates[candidate_idx].has_dict_weight and
            (candidates[candidate_idx].display_kind = cdk_default);
    end;
begin
    if (Length(candidates) <> Length(sources)) or
        (Length(candidates) <> Length(prefix_units)) then
        raise EArgumentException.Create('Candidate/prefix/source count mismatch');
    highest_units := 0;
    for idx := 0 to High(prefix_units) do
    begin
        units := prefix_units[idx];
        if (units < 0) or (units > max_prefix_units) then
            raise EArgumentException.Create('Invalid candidate prefix length');
        if units > highest_units then highest_units := units;
    end;
    if highest_units < 2 then Exit;

    SetLength(heads, highest_units + 1);
    SetLength(tails, highest_units + 1);
    for units := 0 to highest_units do
    begin
        heads[units] := -1;
        tails[units] := -1;
    end;
    SetLength(next_indices, Length(candidates));
    for idx := 0 to High(prefix_units) do
    begin
        units := prefix_units[idx];
        if units = 0 then Continue;
        next_indices[idx] := -1;
        if heads[units] < 0 then heads[units] := idx
        else next_indices[tails[units]] := idx;
        tails[units] := idx;
    end;

    // Raw path scores use different scales. Compare only dictionary-backed
    // prefixes using their existing effective word weight and a finite relative
    // length bonus. Preserve each group's user/context order and keep singles last.
    needs_order := False;
    SetLength(ordered_indices, Length(candidates));
    for idx := 0 to High(prefix_units) do
    begin
        ordered_indices[idx] := idx;
        if prefix_units[idx] = 0 then Continue;
        picked_idx := -1;
        picked_units := 1;
        for units := highest_units downto 2 do
        begin
            probe_idx := heads[units];
            if probe_idx < 0 then Continue;
            if (picked_idx < 0) or
                (comparable_dictionary_prefix(probe_idx) and
                comparable_dictionary_prefix(picked_idx) and
                (weight_priority(probe_idx, units) >
                weight_priority(picked_idx, picked_units))) then
            begin
                picked_idx := probe_idx;
                picked_units := units;
            end;
        end;
        if picked_idx < 0 then picked_idx := heads[1];
        heads[picked_units] := next_indices[picked_idx];
        ordered_indices[idx] := picked_idx;
        needs_order := needs_order or (picked_idx <> idx);
    end;
    if not needs_order then Exit;

    // Zero marks a protected slot (complete, predictive, or non-prefix).
    // Move candidate and selection source together, owning the new snapshots.
    original := candidates;
    original_sources := sources;
    candidates := Copy(candidates);
    sources := Copy(sources);
    for idx := 0 to High(ordered_indices) do
    begin
        candidates[idx] := original[ordered_indices[idx]];
        sources[idx] := original_sources[ordered_indices[idx]];
    end;
end;

end.
