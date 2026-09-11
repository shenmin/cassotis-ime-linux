unit nc_prefix_completion_policy;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses Math, nc_types;

const
    c_short_prefix_completion_limit = 6;
    c_short_long_prefix_completion_limit = 2;

// Applies only to unfinished dictionary words, never exacts or consumed prefixes.
function nc_prefix_completion_rank(const evidence: TncOneKeyCompletion;
    const typed_units, word_units: Integer; const anchored, distant: Boolean;
    out rank: Int64): Boolean;

implementation

function nc_prefix_completion_rank(const evidence: TncOneKeyCompletion;
    const typed_units, word_units: Integer; const anchored, distant: Boolean;
    out rank: Int64): Boolean;
var
    attested, transition, near_complete: Boolean;
begin
    Result := False;
    rank := 0;
    if (evidence.source <> okcs_base_exact) or (evidence.text = '') or
        (typed_units < 2) or (word_units < typed_units) then Exit;
    attested := evidence.corpus_score >= 40;
    transition := (evidence.path_score >= 120) and (evidence.source_count >= 2);
    // Completing letters inside the final syllable is not guessing extra words.
    near_complete := (word_units = typed_units) and
        (evidence.popularity_prior >= 480) and (evidence.source_count >= 2) and
        (evidence.vertical_layer_kind = 0);
    if distant then
    begin
        if not evidence.has_popularity_prior then Exit;
        if not (attested or transition) then Exit;
        if evidence.vertical_layer_kind = 0 then
        begin
            if evidence.popularity_prior < 120 then Exit;
        end
        else if (evidence.popularity_prior < 480) or
            (evidence.source_count < 2) then Exit;
    end
    else if evidence.has_popularity_prior then
    begin
        // Source/document counts also include catalogued names. Without an
        // exact text anchor, they are not proof of ordinary language usage.
        if not (attested or transition or near_complete) and
            (not anchored or (evidence.vertical_layer_kind <> 0)) then Exit;
    end;
    rank := Int64(Max(0, evidence.weight)) +
        EnsureRange(evidence.popularity_prior, 0, 1000) +
        EnsureRange(evidence.corpus_score, 0, 400) +
        EnsureRange(evidence.path_score, 0, 400) -
        Int64(Max(0, word_units - typed_units)) * 24;
    if anchored then Inc(rank, 400);
    if distant then
        rank := Int64(evidence.popularity_prior) * 100000 + rank;
    Result := True;
end;

end.
