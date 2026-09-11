unit nc_local_repair_guard;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses nc_dictionary_intf;

type
    TncValidatedRepairPath = record
        text, aligned_pinyin, segment_path: string;
        // Lexical/alignment validity, not a guarantee of sentence correctness.
        exact_path, boundary_repaired: Boolean;
        lm_gain: Integer;
    end;

function guard_local_repair_words(const dictionary: TncDictionaryProvider;
    const draft, proposal, encoded_path, aligned_pinyin: string;
    const minimum_word_ratio: Double): string;

function valid_local_repair_refinement(const original, first, proposal: string): Boolean;

function validate_local_repair_path(const dictionary: TncDictionaryProvider;
    const draft, proposal, encoded_path, aligned_pinyin: string;
    const minimum_word_ratio: Double; const allow_resegmentation: Boolean): TncValidatedRepairPath;

implementation

uses SysUtils, Math, Generics.Collections, nc_types;

function validate_local_repair_path(const dictionary: TncDictionaryProvider;
    const draft, proposal, encoded_path, aligned_pinyin: string;
    const minimum_word_ratio: Double; const allow_resegmentation: Boolean): TncValidatedRepairPath;
type
    TWord = record
        first, finish, weight: Integer;
        text: string;
        found, user: Boolean;
    end;
    TWindow = record
        left, right: Integer;
    end;
    TState = record
        valid: Boolean;
        score: Int64;
        parts: TArray<TWord>;
    end;
var
    syllables, parts, lm_texts: TArray<string>;
    words: TArray<TWord>;
    windows: TArray<TWindow>;
    replacements: TArray<string>;
    consumed: TArray<Boolean>;
    cache: TDictionary<string, TncCandidateList>;
    plan: TArray<TWord>;
    scores: TArray<Integer>;
    word, changed_word: TWord;
    window: TWindow;
    guarded, candidate_text, query_key, path: string;
    i, j, k, offset, left, right, count, lo, hi: Integer;
    old_multi, new_multi, min_weight, old_weight, coverage_gain: Integer;
    touched, blocked, witnessed: Boolean;

    function query(const first, finish: Integer): string;
    var unit_idx: Integer;
    begin
        Result := '';
        for unit_idx := first to finish - 1 do Result := Result + syllables[unit_idx];
    end;

    function entry(const first, finish: Integer; const text: string): TWord;
    var key: string;
        items: TncCandidateList;
        item: TncCandidate;
        weight: Integer;
    begin
        Result := Default(TWord);
        Result.first := first;
        Result.finish := finish;
        Result.text := text;
        Result.weight := Low(Integer);
        key := query(first, finish);
        if not cache.TryGetValue(key, items) then
        begin
            dictionary.lookup_isolated_exact_component(key, items);
            cache.Add(key, items);
        end;
        for item in items do
            if (item.text = text) and (item.comment = '') then
            begin
                Result.found := True;
                Result.user := Result.user or (item.source = cs_user);
                weight := item.score;
                if item.has_dict_weight then weight := item.dict_weight;
                Result.weight := Max(Result.weight, weight);
            end;
    end;

    function segment(const text: string; const first: Integer;
        out result_parts: TArray<TWord>): Boolean;
    var states: TArray<TState>;
        start_idx, end_idx, part_idx: Integer;
        component: TWord;
        score: Int64;
    begin
        result_parts := nil;
        SetLength(states, Length(text) + 1);
        states[0].valid := True;
        for end_idx := 1 to Length(text) do
            for start_idx := Max(0, end_idx - 4) to end_idx - 1 do
            begin
                if not states[start_idx].valid then Continue;
                component := entry(first + start_idx, first + end_idx,
                    Copy(text, start_idx + 1, end_idx - start_idx));
                if not component.found or component.user then Continue;
                score := states[start_idx].score + (end_idx - start_idx - 1) * 10000 +
                    Min(9999, Max(0, component.weight));
                if states[end_idx].valid and (score <= states[end_idx].score) then Continue;
                states[end_idx].valid := True;
                states[end_idx].score := score;
                states[end_idx].parts := Copy(states[start_idx].parts);
                part_idx := Length(states[end_idx].parts);
                SetLength(states[end_idx].parts, part_idx + 1);
                states[end_idx].parts[part_idx] := component;
            end;
        Result := states[Length(text)].valid;
        if Result then result_parts := states[Length(text)].parts;
    end;

    function encoded(const local_parts: TArray<TWord>): string;
    var item: TWord;
    begin
        Result := '';
        for item in local_parts do
        begin
            if Result <> '' then Result := Result + #3;
            Result := Result + item.text;
        end;
    end;

begin
    Result := Default(TncValidatedRepairPath);
    Result.text := guard_local_repair_words(dictionary, draft, proposal,
        encoded_path, aligned_pinyin, minimum_word_ratio);
    guarded := Result.text;
    syllables := aligned_pinyin.Split([#3], TStringSplitOptions.ExcludeEmpty);
    if (dictionary = nil) or (Length(draft) <> Length(proposal)) or
        IsNan(minimum_word_ratio) or IsInfinite(minimum_word_ratio) or
        (minimum_word_ratio < 0) or (minimum_word_ratio > 1) or
        (Length(syllables) <> Length(draft)) or (Length(draft) < 6) or
        (Length(draft) > 40) or (encoded_path = '') or
        (StringReplace(encoded_path, #3, '', [rfReplaceAll]) <> draft) or
        not valid_local_repair_refinement(draft, draft, proposal) then Exit;
    parts := encoded_path.Split([#3], TStringSplitOptions.ExcludeEmpty);
    SetLength(words, Length(parts));
    SetLength(replacements, Length(parts));
    SetLength(consumed, Length(parts));
    cache := TDictionary<string, TncCandidateList>.Create;
    try
        offset := 0;
        for i := 0 to High(parts) do
        begin
            words[i] := entry(offset, offset + Length(parts[i]), parts[i]);
            Inc(offset, Length(parts[i]));
        end;
        if allow_resegmentation and (guarded <> proposal) then
            for i := 0 to High(words) do
            begin
                word := words[i];
                if not word.found or word.user or
                    (Copy(guarded, word.first + 1, Length(word.text)) =
                     Copy(proposal, word.first + 1, Length(word.text))) then Continue;
                changed_word := entry(word.first, word.finish,
                    Copy(proposal, word.first + 1, Length(word.text)));
                // A low-weight replacement at the same boundary is still blocked.
                if changed_word.found then Continue;
                left := i;
                right := i;
                if (i > 0) and (Length(words[i-1].text) <= 4) then Dec(left);
                if (i < High(words)) and (Length(words[i+1].text) <= 4) then Inc(right);
                if words[right].finish - words[left].first > 12 then Continue;
                count := Length(windows);
                if (count > 0) and (left <= windows[count-1].right) then
                begin
                    if words[right].finish - words[windows[count-1].left].first <= 12 then
                        windows[count-1].right := Max(right, windows[count-1].right);
                end
                else if count < 2 then
                begin
                    SetLength(windows, count + 1);
                    windows[count].left := left;
                    windows[count].right := right;
                end;
            end;
        for window in windows do
        begin
            left := words[window.left].first;
            right := words[window.right].finish;
            blocked := False;
            old_multi := 0;
            old_weight := 1;
            for i := window.left to window.right do
            begin
                blocked := blocked or words[i].user;
                if Length(words[i].text) > 1 then Inc(old_multi, Length(words[i].text));
                if Copy(guarded, words[i].first + 1, Length(words[i].text)) <>
                    Copy(proposal, words[i].first + 1, Length(words[i].text)) then
                begin
                    old_weight := Max(old_weight, words[i].weight);
                    changed_word := entry(words[i].first, words[i].finish,
                        Copy(proposal, words[i].first+1, Length(words[i].text)));
                    if words[i].found and changed_word.found and
                        (changed_word.weight < Max(1, words[i].weight) * minimum_word_ratio) then
                        blocked := True;
                end;
            end;
            for j := left to right - 1 do
                if not dictionary.single_char_matches_pinyin(syllables[j], proposal[j+1]) then
                    blocked := True;
            if blocked or not segment(Copy(proposal, left + 1, right - left), left, plan) then Continue;
            new_multi := 0;
            min_weight := High(Integer);
            for changed_word in plan do
            begin
                if Length(changed_word.text) > 1 then Inc(new_multi, Length(changed_word.text));
                touched := False;
                for j := changed_word.first to changed_word.finish - 1 do
                    touched := touched or (guarded[j+1] <> proposal[j+1]);
                if touched then min_weight := Min(min_weight, changed_word.weight);
            end;
            coverage_gain := new_multi - old_multi;
            // Every restored edit needs a changed exact word crossing an old
            // boundary. Unchanged neighbors cannot justify splitting a name
            // or another intact dictionary word into individual characters.
            for j := left to right - 1 do
            begin
                if guarded[j+1] = proposal[j+1] then Continue;
                witnessed := False;
                for changed_word in plan do
                    if (changed_word.first <= j) and (j < changed_word.finish) then
                        for k := window.left to window.right - 1 do
                            if (changed_word.first < words[k].finish) and
                                (words[k].finish < changed_word.finish) then witnessed := True;
                if not witnessed then blocked := True;
            end;
            if blocked then Continue;
            if (new_multi = 0) or (coverage_gain < -4) or (min_weight < 10) or
                (min_weight < old_weight * minimum_word_ratio) then Continue;
            candidate_text := Copy(guarded, 1, left) + Copy(proposal, left+1, right-left) +
                Copy(guarded, right+1, MaxInt);
            lo := Max(0, left - 3);
            hi := Min(Length(draft), right + 3);
            lm_texts := TArray<string>.Create(Copy(guarded, lo+1, hi-lo),
                Copy(candidate_text, lo+1, hi-lo));
            if not dictionary.get_char_lm_continuation_scores('', lm_texts, scores) or
                (Length(scores) <> 2) or (scores[1] < scores[0]) then Continue;
            for j := left+1 to right do Result.text[j] := proposal[j];
            Result.boundary_repaired := True;
        end;
        if not valid_local_repair_refinement(draft, draft, Result.text) then
        begin
            Result.text := guarded;
            Result.boundary_repaired := False;
        end;

        // Rebuild only changed neighborhoods; untouched exact words retain their
        // original boundaries. The path and text are validated as one result.
        windows := nil;
        for i := 0 to High(words) do
        begin
            word := words[i];
            if Copy(Result.text, word.first + 1, Length(word.text)) = word.text then Continue;
            if word.user then Exit;
            if Length(word.text) > 4 then
            begin
                changed_word := entry(word.first, word.finish,
                    Copy(Result.text, word.first+1, Length(word.text)));
                if changed_word.found and not changed_word.user then
                begin
                    replacements[i] := changed_word.text;
                    Continue;
                end;
            end;
            left := i;
            right := i;
            if (i > 0) and (Length(words[i-1].text) <= 4) and not words[i-1].user then Dec(left);
            if (i < High(words)) and (Length(words[i+1].text) <= 4) and not words[i+1].user then Inc(right);
            if words[right].finish - words[left].first > 12 then
            begin left := i; right := i; end;
            count := Length(windows);
            if (count > 0) and (left <= windows[count-1].right) then
            begin
                if words[right].finish - words[windows[count-1].left].first > 12 then Exit;
                windows[count-1].right := Max(right, windows[count-1].right);
            end
            else
            begin
                SetLength(windows, count + 1);
                windows[count].left := left;
                windows[count].right := right;
            end;
        end;
        for window in windows do
        begin
            left := words[window.left].first;
            right := words[window.right].finish;
            if not segment(Copy(Result.text, left+1, right-left), left, plan) then Exit;
            replacements[window.left] := encoded(plan);
            for j := window.left+1 to window.right do consumed[j] := True;
        end;
        path := '';
        for i := 0 to High(words) do
        begin
            if consumed[i] then Continue;
            if replacements[i] <> '' then query_key := replacements[i]
            else
            begin
                word := words[i];
                if not word.found or word.user then Exit;
                query_key := word.text;
            end;
            if path <> '' then path := path + #3;
            path := path + query_key;
        end;
        if StringReplace(path, #3, '', [rfReplaceAll]) <> Result.text then Exit;
        // Compact-key dictionary lookup must not change explicit syllable boundaries.
        for k := 0 to High(syllables) do
            if not dictionary.single_char_matches_pinyin(syllables[k], Result.text[k+1]) then Exit;
        Result.segment_path := path;
        Result.aligned_pinyin := aligned_pinyin;
        Result.exact_path := True;
        if Result.text <> draft then
        begin
            lm_texts := TArray<string>.Create(draft, Result.text);
            if dictionary.get_char_lm_continuation_scores('', lm_texts, scores) and (Length(scores) = 2) then
                Result.lm_gain := scores[1] - scores[0]
            else Result.lm_gain := Low(Integer);
        end;
    finally
        cache.Free;
    end;
end;

function valid_local_repair_refinement(const original, first, proposal: string): Boolean;
var
    index, edits, spans: Integer;
    changed, previous_changed: Boolean;
begin
    Result := False;
    if (original = '') or (Length(original) <> Length(first)) or
        (Length(original) <> Length(proposal)) then Exit;
    edits := 0;
    spans := 0;
    previous_changed := False;
    for index := 1 to Length(original) do
    begin
        if (original[index] <> first[index]) and
            (first[index] <> proposal[index]) then Exit;
        changed := original[index] <> proposal[index];
        if changed then
        begin
            Inc(edits);
            if not previous_changed then Inc(spans);
        end;
        if (edits > 4) or (spans > 2) then Exit;
        previous_changed := changed;
    end;
    Result := True;
end;

function guard_local_repair_words(const dictionary: TncDictionaryProvider;
    const draft, proposal, encoded_path, aligned_pinyin: string;
    const minimum_word_ratio: Double): string;
var
    words, syllables: TArray<string>;
    word, replacement, query: string;
    items: TncCandidateList;
    item: TncCandidate;
    position, index, old_weight, new_weight, weight, spans: Integer;
    old_found, new_found, user_word, changed, previous_changed: Boolean;
begin
    Result := draft;
    if (dictionary = nil) or (Length(draft) <> Length(proposal)) or
        IsNan(minimum_word_ratio) or IsInfinite(minimum_word_ratio) or
        (minimum_word_ratio < 0) or (minimum_word_ratio > 1) then Exit;
    syllables := aligned_pinyin.Split([#3], TStringSplitOptions.ExcludeEmpty);
    if Length(syllables) <> Length(draft) then Exit;
    Result := proposal;
    if (encoded_path = '') or
        (StringReplace(encoded_path, #3, '', [rfReplaceAll]) <> draft) then Exit;
    words := encoded_path.Split([#3], TStringSplitOptions.ExcludeEmpty);
    position := 1;
    for word in words do
    begin
        replacement := Copy(Result, position, Length(word));
        if (Length(word) >= 2) and (replacement <> word) then
        begin
            query := '';
            for index := position to position + Length(word) - 1 do
                query := query + syllables[index - 1];
            old_found := False;
            new_found := False;
            user_word := False;
            old_weight := 0;
            new_weight := Low(Integer);
            dictionary.lookup_isolated_exact_component(query, items);
            for item in items do
            begin
                if item.comment <> '' then Continue;
                weight := item.score;
                if item.has_dict_weight then weight := item.dict_weight;
                if item.text = word then
                begin
                    old_found := True;
                    old_weight := Max(old_weight, weight);
                    user_word := user_word or (item.source = cs_user);
                end;
                if item.text = replacement then
                begin
                    new_found := True;
                    new_weight := Max(new_weight, weight);
                end;
            end;
            // An existing exact word is an anchor, not a bag of homophones.
            // Preserve only the unsupported span; other validated edits survive.
            if old_found and (user_word or (not new_found) or
                (new_weight < Max(1, old_weight) * minimum_word_ratio)) then
                for index := position to position + Length(word) - 1 do
                    Result[index] := draft[index];
        end;
        Inc(position, Length(word));
    end;
    spans := 0;
    previous_changed := False;
    for index := 1 to Length(draft) do
    begin
        changed := Result[index] <> draft[index];
        if changed and not previous_changed then Inc(spans);
        previous_changed := changed;
    end;
    if spans > 2 then Result := draft;
end;

end.
