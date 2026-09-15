unit nc_tab_repair_projection;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses nc_types, nc_local_repair_guard;

function nc_project_repaired_tab_prefix(const original_draft, compact_query, query_syllables: string;
    const repaired: TncValidatedRepairPath; const completion: TncOneKeyCompletion;
    out projected: TncOneKeyCompletion): Boolean;

implementation

uses SysUtils;

function nc_project_repaired_tab_prefix(const original_draft, compact_query, query_syllables: string;
    const repaired: TncValidatedRepairPath; const completion: TncOneKeyCompletion;
    out projected: TncOneKeyCompletion): Boolean;
var
    old_parts, new_parts, anchors, syllables: TArray<string>;
    prefix, suffix, suffix_path: string;
    i, units, prefix_count: Integer;
    has_lexical_change: Boolean;
begin
    Result := False;
    projected := completion;
    if not (completion.source in [okcs_long_transition, okcs_long_neural]) or
        (original_draft = '') or (completion.anchor_text <> original_draft) or
        not completion.prefix_anchored or not repaired.exact_path or
        (Length(repaired.text) < 6) or (Length(repaired.text) > 40) or
        (Length(completion.anchor_text) <> Length(repaired.text)) or
        (completion.anchor_text = repaired.text) or (completion.suffix_text = '') or
        (completion.text <> completion.anchor_text + completion.suffix_text) or
        (compact_query = '') or (query_syllables = '') or
        (repaired.aligned_pinyin <> query_syllables) or
        not completion.full_pinyin.StartsWith(compact_query) or
        (Length(completion.full_pinyin) <= Length(compact_query)) then Exit;

    // Do not refresh an existing hint solely to choose a gender for spoken "ta".
    has_lexical_change := False;
    for i := 1 to Length(repaired.text) do
        if (original_draft[i] <> repaired.text[i]) and not
            (((original_draft[i] = #$4ED6) and (repaired.text[i] = #$5979)) or
            ((original_draft[i] = #$5979) and (repaired.text[i] = #$4ED6))) then
        begin
            has_lexical_change := True;
            Break;
        end;
    if not has_lexical_change then Exit;

    syllables := query_syllables.Split([#3], TStringSplitOptions.ExcludeEmpty);
    if (Length(syllables) <> Length(repaired.text)) or
        (nc_join_strings('', syllables) <> compact_query) then Exit;
    new_parts := repaired.segment_path.Split([#3], TStringSplitOptions.ExcludeEmpty);
    if (Length(new_parts) = 0) or (nc_join_strings('', new_parts) <> repaired.text) then Exit;
    anchors := completion.anchor_path.Split([#3], TStringSplitOptions.ExcludeEmpty);
    if (Length(nc_join_strings('', anchors)) < 2) or (Length(anchors) > 3) or
        (Length(anchors) > Length(new_parts)) then Exit;
    for i := 0 to High(anchors) do
        if anchors[i] <> new_parts[Length(new_parts) - Length(anchors) + i] then Exit;

    old_parts := completion.path_text.Split([#3], TStringSplitOptions.ExcludeEmpty);
    prefix := ''; suffix := ''; suffix_path := ''; units := 0; prefix_count := 0;
    for i := 0 to High(old_parts) do
    begin
        if units < Length(repaired.text) then
        begin
            Inc(units, Length(old_parts[i]));
            if units > Length(repaired.text) then Exit;
            prefix := prefix + old_parts[i];
            Inc(prefix_count);
        end
        else
        begin
            suffix := suffix + old_parts[i];
            if suffix_path <> '' then suffix_path := suffix_path + #3;
            suffix_path := suffix_path + old_parts[i];
        end;
    end;
    if (prefix <> completion.anchor_text) or (suffix <> completion.suffix_text) or
        (suffix_path = '') or (prefix_count < Length(anchors)) then Exit;
    for i := 0 to High(anchors) do
        if anchors[i] <> old_parts[prefix_count - Length(anchors) + i] then Exit;

    // Project only the final display/commit value. Raw ranking, neural challenges,
    // suffix evidence and next-key hysteresis must continue to see the same hint.
    projected.anchor_text := repaired.text;
    projected.text := repaired.text + suffix;
    projected.path_text := repaired.segment_path + #3 + suffix_path;
    Result := True;
end;

end.
