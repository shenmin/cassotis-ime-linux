unit nc_exact_component_sort;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses Generics.Collections, nc_types;

procedure nc_sort_exact_components(const items: TList<TncCandidate>);

implementation

uses SysUtils, Generics.Defaults;

function compare_components(constref a, b: TncCandidate): Integer;
begin
    if a.score > b.score then Exit(-1);
    if a.score < b.score then Exit(1);
    if (a.source = cs_user) and (b.source <> cs_user) then Exit(-1);
    if (b.source = cs_user) and (a.source <> cs_user) then Exit(1);
    Result := UnicodeCompareText(a.text, b.text);
end;

procedure nc_sort_exact_components(const items: TList<TncCandidate>);
var
    sorted: TArray<TncCandidate>;
    comparer: IComparer<TncCandidate>;
    i, j: Integer;
    item: TncCandidate;
    ordered: Boolean;
begin
    if items.Count < 2 then Exit;
    ordered := True;
    for i := 1 to items.Count - 1 do
    begin
        if compare_components(items[i-1], items[i]) > 0 then
        begin ordered := False; Break; end;
    end;
    if ordered then Exit;
    sorted := items.ToArray;
    comparer := TComparer<TncCandidate>.Construct(compare_components);
    TArrayHelper<TncCandidate>.Sort(sorted, comparer);
    ordered := True;
    for i := 1 to High(sorted) do
        if comparer.Compare(sorted[i-1], sorted[i]) = 0 then
        begin ordered := False; Break; end;
    if ordered then
    begin
        for i := 0 to High(sorted) do items[i] := sorted[i];
        Exit;
    end;
    // Preserve the legacy order of collation-equivalent texts. Normal exact
    // queries have distinct keys.
    for i := 0 to items.Count - 2 do
        for j := i + 1 to items.Count - 1 do
            if compare_components(items[j], items[i]) < 0 then
            begin
                item := items[i]; items[i] := items[j]; items[j] := item;
            end;
end;

end.
