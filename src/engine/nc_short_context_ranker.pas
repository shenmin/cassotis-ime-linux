unit nc_short_context_ranker;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Math, nc_types, nc_dictionary_intf;

type
    TncShortContextRequest = record
        context, query, first, second: string;
        // Dictionary weights, current visible scores, continuation LM scores.
        values: array[0..5] of Integer;
    end;

    IncShortContextReranker = interface
        ['{E5C61421-2065-477D-9AE7-3A8DE3690BEF}']
        function short_context_ready: Boolean;
        function try_switch_short_context(const request: TncShortContextRequest): Boolean;
    end;

function nc_rerank_short_context(const model: IncShortContextReranker;
    const dictionary: TncDictionaryProvider; const context, query: string;
    var candidates: TncCandidateList; var source_indices: TArray<Integer>): Boolean;

implementation

function nc_rerank_short_context(const model: IncShortContextReranker;
    const dictionary: TncDictionaryProvider; const context, query: string;
    var candidates: TncCandidateList; var source_indices: TArray<Integer>): Boolean;
var
    request: TncShortContextRequest;
    scores: TArray<Integer>;
    texts: TArray<string>;
    candidate: TncCandidate;
    i, source: Integer;
    ch: Char;
begin
    Result := False;
    if (model = nil) or (dictionary = nil) or (Trim(context) = '') or
        (Pos(#0, context) > 0) or
        (query = '') or (Length(query) > 32) or (Length(candidates) < 2) or
        (Length(source_indices) <> Length(candidates)) then Exit;
    // Only full-pinyin, final base exact pairs. No fuzzy/abbreviation fallback.
    for ch in query do if not CharInSet(ch, ['a'..'z']) then Exit;
    for i := 0 to 1 do
        if (candidates[i].source = cs_user) or (Pos(#0, candidates[i].text) > 0) or
            (candidates[i].comment <> '') or (candidates[i].fuzzy_cost <> 0) or
            (not candidates[i].has_dict_weight) or
            (Length(candidates[i].text) < 2) or (Length(candidates[i].text) > 4) then Exit;
    if (candidates[0].text = candidates[1].text) or
        (UnicodeStringReplace(candidates[0].text, #$5979, #$4ED6, [rfReplaceAll]) =
         UnicodeStringReplace(candidates[1].text, #$5979, #$4ED6, [rfReplaceAll])) then Exit;
    if not model.short_context_ready then Exit;
    for i := 0 to 1 do
    begin
        if not dictionary.is_base_entry(query, candidates[i].text) then Exit;
        // Explicit local choices, including learned base words, remain protected.
        if (dictionary.get_query_choice_bonus(query, candidates[i].text) > 0) or
            (dictionary.get_context_query_choice_bonus(context, query, candidates[i].text) > 0) then Exit;
    end;
    texts := TArray<string>.Create(candidates[0].text, candidates[1].text);
    if not dictionary.get_char_lm_continuation_scores(context, texts, scores) or
        (Length(scores) <> 2) then Exit;
    request.context := Copy(context, Max(1, Length(context) - 47), 48);
    request.query := query;
    request.first := texts[0]; request.second := texts[1];
    for i := 0 to 1 do
    begin
        request.values[i] := candidates[i].dict_weight;
        request.values[2+i] := candidates[i].score;
        request.values[4+i] := scores[i];
    end;
    if not model.try_switch_short_context(request) then Exit;
    candidate := candidates[0]; candidates[0] := candidates[1]; candidates[1] := candidate;
    source := source_indices[0]; source_indices[0] := source_indices[1]; source_indices[1] := source;
    Result := True;
end;

end.
