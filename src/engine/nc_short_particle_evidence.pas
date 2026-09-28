unit nc_short_particle_evidence;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses nc_types, nc_dictionary_intf;

function nc_recover_attested_particle_phrase(const dictionary: TncDictionaryProvider;
    const syllables: TArray<string>; const particle, left_context: string;
    const existing: TncCandidateList; out text, path: string;
    out evidence_score: Integer): Boolean;

implementation

uses SysUtils, Math, Generics.Collections;

function nc_recover_attested_particle_phrase(const dictionary: TncDictionaryProvider;
    const syllables: TArray<string>; const particle, left_context: string;
    const existing: TncCandidateList; out text, path: string;
    out evidence_score: Integer): Boolean;
const
    c_head_limit = 8;
    c_single_limit = 4;
    c_existing_limit = 16;
    c_min_weight = 80;
    c_min_trigram = -3072;
    c_min_head_bigram = -6144;
    c_min_margin = 1024;
var
    heads, singles, exact: TncCandidateList;
    texts, paths, grams: TList<string>;
    seen: TDictionary<string, Boolean>;
    observed, scores, contextual: TArray<Integer>;
    head, single, item: TncCandidate;
    key, value: string;
    i, best, next_score, head_count, single_count, recalled, competitors: Integer;
    attested: Boolean;

    function weight(const candidate: TncCandidate): Integer;
    begin
        if candidate.has_dict_weight then Result := candidate.dict_weight
        else Result := candidate.score;
    end;

    procedure add(const value, encoded_path: string);
    begin
        if seen.ContainsKey(value) then Exit;
        seen.Add(value, True);
        texts.Add(value);
        paths.Add(encoded_path);
    end;

begin
    Result := False;
    text := '';
    path := '';
    evidence_score := 0;
    if (dictionary = nil) or (Length(syllables) <> 4) or
        (Length(particle) <> 1) then Exit;
    for item in existing do
        if (item.source = cs_user) and (item.comment = '') then Exit;
    key := nc_join_strings('', syllables);
    // This evidence channel never competes with an actual whole-query entry.
    if dictionary.lookup_isolated_exact_component(key, exact) then
        for item in exact do
            if (item.comment = '') and (Length(item.text) = 4) then Exit;
    if not dictionary.single_char_matches_pinyin(syllables[3], particle) or
        not dictionary.lookup_isolated_exact_component(syllables[0] + syllables[1], heads) or
        not dictionary.lookup_isolated_exact_component(syllables[2], singles) then Exit;

    texts := TList<string>.Create;
    paths := TList<string>.Create;
    grams := TList<string>.Create;
    seen := TDictionary<string, Boolean>.Create;
    try
        head_count := 0;
        for head in heads do
        begin
            if (head.comment <> '') or (Length(head.text) <> 2) then Continue;
            if head.source = cs_user then Exit;
            Inc(head_count);
            if head_count > c_head_limit then Break;
            if weight(head) < c_min_weight then Continue;
            single_count := 0;
            for single in singles do
            begin
                if (single.comment <> '') or (Length(single.text) <> 1) then Continue;
                if single.source = cs_user then Exit;
                Inc(single_count);
                if single_count > c_single_limit then Break;
                if weight(single) < c_min_weight then Continue;
                value := head.text + single.text + particle;
                add(value, head.text + #3 + single.text + #3 + particle);
            end;
        end;
        recalled := texts.Count;
        if recalled < 2 then Exit;
        for i := 0 to recalled - 1 do
        begin
            grams.Add(Copy(texts[i], 2, 3));
            grams.Add(Copy(texts[i], 1, 2));
        end;
        // An observed crossing trigram is mandatory; backoff guesses do not
        // establish that the last two single characters form a useful phrase.
        if not dictionary.get_char_lm_attested_scores(grams.ToArray, observed) or
            (Length(observed) <> grams.Count) then Exit;
        attested := False;
        for i := 0 to recalled - 1 do
            attested := attested or ((observed[i * 2] >= c_min_trigram) and
                (observed[i * 2 + 1] >= c_min_head_bigram));
        if not attested then Exit;

        competitors := 0;
        for item in existing do
            if (item.comment = '') and (Length(item.text) = 4) then
            begin
                Inc(competitors);
                if competitors > c_existing_limit then Exit;
                add(item.text, '');
            end;
        if not dictionary.get_char_lm_continuation_scores('', texts.ToArray, scores) or
            (Length(scores) <> texts.Count) then Exit;
        best := -1;
        next_score := Low(Integer);
        for i := 0 to High(scores) do
        begin
            if scores[i] = Low(Integer) then Exit;
            if (best < 0) or (scores[i] > scores[best]) then
            begin
                if best >= 0 then next_score := Max(next_score, scores[best]);
                best := i;
            end
            else next_score := Max(next_score, scores[i]);
        end;
        if (best < 0) or (best >= recalled) or
            (observed[best * 2] < c_min_trigram) or
            (observed[best * 2 + 1] < c_min_head_bigram) or
            (4 * (Int64(scores[best]) - next_score) < c_min_margin) then Exit;
        if left_context <> '' then
        begin
            if not dictionary.get_char_lm_continuation_scores(left_context,
                texts.ToArray, contextual) or (Length(contextual) <> texts.Count) then Exit;
            for i := 0 to High(contextual) do
                if (contextual[i] = Low(Integer)) or ((i <> best) and
                    (4 * (Int64(contextual[best]) - contextual[i]) < c_min_margin)) then Exit;
        end;
        text := texts[best];
        path := paths[best];
        evidence_score := Min(1560, Int64(scores[best]) - next_score);
        Result := True;
    finally
        seen.Free;
        grams.Free;
        paths.Free;
        texts.Free;
    end;
end;

end.
