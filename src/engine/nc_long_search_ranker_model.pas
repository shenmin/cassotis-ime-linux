unit nc_long_search_ranker_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

function long_search_ranker_score(const char_lm_score: Integer;
    const original_rank: Integer; const base_score: Integer;
    const word_lm_head_bonus: Integer; const word_lm_full_bonus: Integer;
    const word_lm_boundary_count: Integer; const word_lm_min_bonus: Integer;
    const word_lm_max_bonus: Integer; const word_lm_first_bonus: Integer;
    const word_lm_last_bonus: Integer; const word_lm_supported_count: Integer;
    const word_lm_strong_count: Integer; const word_lm_trigram_count: Integer;
    const word_lm_zero_count: Integer;
    const segments: Integer; const single_segments: Integer;
    const first_chunk_units: Integer; const anchor_units: Integer;
    const has_anchor: Boolean): Int64;

implementation

function long_search_ranker_score(const char_lm_score: Integer;
    const original_rank: Integer; const base_score: Integer;
    const word_lm_head_bonus: Integer; const word_lm_full_bonus: Integer;
    const word_lm_boundary_count: Integer; const word_lm_min_bonus: Integer;
    const word_lm_max_bonus: Integer; const word_lm_first_bonus: Integer;
    const word_lm_last_bonus: Integer; const word_lm_supported_count: Integer;
    const word_lm_strong_count: Integer; const word_lm_trigram_count: Integer;
    const word_lm_zero_count: Integer;
    const segments: Integer; const single_segments: Integer;
    const first_chunk_units: Integer; const anchor_units: Integer;
    const has_anchor: Boolean): Int64;
begin
    // Joint pairwise model trained on independent long-sentence corpora.
    // Model report SHA-256: DC1BAE315FA3787B466283BF862ED030DB727902155578484ED9AFB7D91AC676
    Result := Int64(char_lm_score) * 31
        - Int64(original_rank) * 437
        + Int64(base_score) * 0
        + Int64(word_lm_head_bonus) * 4
        + Int64(word_lm_full_bonus) * 7
        - Int64(segments) * 10000
        - Int64(single_segments) * 2842
        - Int64(first_chunk_units) * 4723
        + Int64(anchor_units) * 4387
        + Int64(Ord(has_anchor)) * 715;
end;

end.
