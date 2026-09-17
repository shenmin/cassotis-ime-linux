unit nc_tab_exact_fallback;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_types, nc_dictionary_intf;

function nc_try_exact_tail_completion(const dictionary: TncDictionaryProvider;
    const query: string; const visible: TncCandidateList;
    out completion: TncOneKeyCompletion): Boolean;

implementation

uses
    SysUtils, Math, nc_pinyin_parser;

function nc_try_exact_tail_completion(const dictionary: TncDictionaryProvider;
    const query: string; const visible: TncCandidateList;
    out completion: TncOneKeyCompletion): Boolean;
const
    c_max_word_units = 4;
    c_max_exact_options = 64;
    c_repeated_choice_floor = 320;
var
    raw, compact, tail_key, head_key, head_raw, tail_raw: string;
    heads, tails: TncCandidateList;
    head_syllables, tail_syllables: TncPinyinParseResult;
    parser: TncPinyinParser;
    idx, split_at, head_letters, letters_seen, best, score, best_score, bonus: Integer;
    head_found: Boolean;
    item: TncCandidate;

    function compact_key(const value: string): string;
    var ch: Char;
    begin
        Result := '';
        for ch in LowerCase(value) do
            if ch <> #39 then
            begin
                if not CharInSet(ch, ['a'..'z']) then Exit('');
                Result := Result + ch;
            end;
    end;

    function parse_complete_word(const value: string;
        out syllables: TncPinyinParseResult): Boolean;
    var syllable: TncPinyinSyllable; reconstructed: string;
    begin
        Result := False;
        if (value = '') or (value[1] = #39) or
            (value[Length(value)] = #39) or (Pos(#39#39, value) > 0) then Exit;
        syllables := parser.parse(value);
        if (Length(syllables) < 1) or (Length(syllables) > c_max_word_units) then Exit;
        reconstructed := '';
        for syllable in syllables do
        begin
            if not nc_is_canonical_pinyin_syllable(syllable.text) then Exit;
            reconstructed := reconstructed + syllable.text;
        end;
        Result := reconstructed = compact_key(value);
    end;

    function aligned_exact(const value: TncCandidate;
        const syllables: TncPinyinParseResult): Boolean;
    var unit_idx: Integer;
    begin
        Result := False;
        if (value.comment <> '') or (value.fuzzy_cost <> 0) or
            (not value.has_dict_weight) or
            (Length(value.text) <> Length(syllables)) then Exit;
        // Compact lookups can contain a different segmentation (he/ne vs hen/e).
        // Validate the fixed input boundaries instead of silently resegmenting.
        for unit_idx := 0 to High(syllables) do
            if not dictionary.single_char_matches_pinyin(
                syllables[unit_idx].text, value.text[unit_idx + 1]) then Exit;
        Result := True;
    end;
begin
    Result := False;
    completion := Default(TncOneKeyCompletion);
    if (dictionary = nil) or (Length(visible) = 0) or
        (visible[0].text = '') or (visible[0].comment = '') or
        (visible[0].fuzzy_cost <> 0) then Exit;
    raw := LowerCase(Trim(query));
    compact := compact_key(raw);
    tail_key := compact_key(visible[0].comment);
    if (compact = '') or (Length(compact) > 48) or (tail_key = '') or
        (Length(tail_key) >= Length(compact)) or
        (Copy(compact, Length(compact) - Length(tail_key) + 1, MaxInt) <> tail_key) then Exit;
    head_letters := Length(compact) - Length(tail_key);
    head_key := Copy(compact, 1, head_letters);
    split_at := 0;
    letters_seen := 0;
    for idx := 1 to Length(raw) do
        if raw[idx] <> #39 then
        begin
            Inc(letters_seen);
            if letters_seen = head_letters then
            begin
                split_at := idx;
                Break;
            end;
        end;
    head_raw := Copy(raw, 1, split_at);
    tail_raw := Copy(raw, split_at + 1, MaxInt);
    if (tail_raw <> '') and (tail_raw[1] = #39) then Delete(tail_raw, 1, 1);
    parser := TncPinyinParser.create;
    try
        if (not parse_complete_word(head_raw, head_syllables)) or
            (not parse_complete_word(tail_raw, tail_syllables)) then Exit;
        if not dictionary.lookup_isolated_exact_component(head_key, heads) then Exit;
        head_found := False;
        for item in heads do
            if (item.text = visible[0].text) and aligned_exact(item, head_syllables) then
            begin
                head_found := True;
                Break;
            end;
        if not head_found then Exit;
        if not dictionary.lookup_isolated_exact_component(tail_key, tails) then Exit;
        best := -1;
        best_score := Low(Integer);
        for idx := 0 to Min(High(tails), c_max_exact_options - 1) do
        begin
            if (tails[idx].comment <> '') or (tails[idx].fuzzy_cost <> 0) or
                (not tails[idx].has_dict_weight) then Continue;
            score := tails[idx].dict_weight;
            if tails[idx].source <> cs_user then
            begin
                bonus := dictionary.get_query_choice_bonus(tail_key, tails[idx].text);
                if bonus >= c_repeated_choice_floor then Inc(score, bonus);
            end;
            if (best >= 0) and (tails[best].source = cs_user) and
                (tails[idx].source <> cs_user) then Continue;
            if (best < 0) or ((tails[idx].source = cs_user) and
                (tails[best].source <> cs_user)) or (score > best_score) then
            begin
                if not aligned_exact(tails[idx], tail_syllables) then Continue;
                best := idx;
                best_score := score;
            end;
        end;
        if best < 0 then Exit;
        for item in visible do
            if (item.comment = '') and (item.text = visible[0].text + tails[best].text) then Exit;
        completion.text := visible[0].text + tails[best].text;
        completion.full_pinyin := head_raw + #39 + tail_raw;
        completion.path_text := visible[0].text + #3 + tails[best].text;
        completion.prefix_anchored := True;
        completion.source := okcs_exact_tail_fallback;
        Result := True;
    finally
        parser.Free;
    end;
end;

end.
