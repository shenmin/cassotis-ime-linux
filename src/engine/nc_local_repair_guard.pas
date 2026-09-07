unit nc_local_repair_guard;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses nc_dictionary_intf;

function guard_local_repair_words(const dictionary: TncDictionaryProvider;
    const draft, proposal, encoded_path, aligned_pinyin: string;
    const minimum_word_ratio: Double): string;

implementation

uses SysUtils, Math, nc_types;

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
