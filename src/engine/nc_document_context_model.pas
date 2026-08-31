unit nc_document_context_model;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    Math,
    Generics.Collections,
    nc_types;

type
    TncDocumentContextModel = class
    private
        m_document_key: string;
        m_snapshot: string;
        m_document_text: string;
        m_recent_tail: string;
        m_ngrams: TDictionary<string, Integer>;
        procedure add_ngram(const value: string);
        procedure add_incremental_ngrams(const value: string;
            const prefix_chars: Integer);
        function merge_snapshot(const value: string;
            out incremental_text: string; out incremental_prefix: Integer;
            out requires_rebuild: Boolean): Boolean;
        procedure rebuild;
        function ngram_count(const value: string): Integer;
    public
        constructor create;
        destructor Destroy; override;
        procedure clear;
        procedure set_snapshot(const document_key, text: string);
        function score_text(const text: string): Integer;
        function score_path(const encoded_path: string;
            const separator: Char): Integer;
        function has_context: Boolean;
        property document_key: string read m_document_key;
    end;

implementation

const
    c_max_snapshot_chars = 1024;
    c_max_document_chars = 4096;
    c_document_trim_trigger_chars = c_max_document_chars +
        c_max_snapshot_chars;
    c_recent_tail_chars = 160;
    c_min_ngram_chars = 2;
    c_max_ngram_chars = 12;
    c_min_snapshot_overlap = 16;
    c_text_score_cap = 720;
    c_path_score_cap = 860;

function is_text_character(const value: Char): Boolean;
var
    code: Integer;
begin
    code := Ord(value);
    Result := ((code >= $3400) and (code <= $9FFF)) or
        ((code >= $F900) and (code <= $FAFF)) or
        ((code >= Ord('0')) and (code <= Ord('9'))) or
        ((code >= Ord('A')) and (code <= Ord('Z'))) or
        ((code >= Ord('a')) and (code <= Ord('z')));
end;

function trim_tail(const value: string; const max_chars: Integer): string;
begin
    Result := Trim(value);
    if (max_chars > 0) and (Length(Result) > max_chars) then
    begin
        Result := Copy(Result, Length(Result) - max_chars + 1, max_chars);
    end;
end;

constructor TncDocumentContextModel.create;
begin
    inherited create;
    m_ngrams := TDictionary<string, Integer>.Create;
end;

destructor TncDocumentContextModel.Destroy;
begin
    m_ngrams.Free;
    inherited;
end;

procedure TncDocumentContextModel.clear;
begin
    m_document_key := '';
    m_snapshot := '';
    m_document_text := '';
    m_recent_tail := '';
    m_ngrams.Clear;
end;

procedure TncDocumentContextModel.add_ngram(const value: string);
var
    count: Integer;
begin
    if value = '' then
    begin
        Exit;
    end;
    count := 0;
    m_ngrams.TryGetValue(value, count);
    m_ngrams.AddOrSetValue(value, count + 1);
end;

procedure TncDocumentContextModel.add_incremental_ngrams(
    const value: string; const prefix_chars: Integer);
var
    width: Integer;
    start_idx: Integer;
    char_idx: Integer;
    valid: Boolean;
begin
    if value = '' then
    begin
        Exit;
    end;
    for width := c_min_ngram_chars to c_max_ngram_chars do
    begin
        if Length(value) < width then
        begin
            Break;
        end;
        for start_idx := 1 to Length(value) - width + 1 do
        begin
            // N-grams fully inside the retained bridge were already counted.
            if start_idx + width - 1 <= prefix_chars then
            begin
                Continue;
            end;
            valid := True;
            for char_idx := start_idx to start_idx + width - 1 do
            begin
                if not is_text_character(value[char_idx]) then
                begin
                    valid := False;
                    Break;
                end;
            end;
            if valid then
            begin
                add_ngram(Copy(value, start_idx, width));
            end;
        end;
    end;
end;

procedure TncDocumentContextModel.rebuild;
var
    run_text: string;
    idx: Integer;

    procedure add_run(const value: string);
    var
        local_width: Integer;
        local_start: Integer;
    begin
        for local_width := c_min_ngram_chars to c_max_ngram_chars do
        begin
            if Length(value) < local_width then
            begin
                Break;
            end;
            for local_start := 1 to Length(value) - local_width + 1 do
            begin
                add_ngram(Copy(value, local_start, local_width));
            end;
        end;
    end;

begin
    m_ngrams.Clear;
    run_text := '';
    for idx := 1 to Length(m_document_text) + 1 do
    begin
        if (idx <= Length(m_document_text)) and
            is_text_character(m_document_text[idx]) then
        begin
            run_text := run_text + m_document_text[idx];
            Continue;
        end;
        if run_text <> '' then
        begin
            add_run(run_text);
            run_text := '';
        end;
    end;

end;

function TncDocumentContextModel.merge_snapshot(const value: string;
    out incremental_text: string; out incremental_prefix: Integer;
    out requires_rebuild: Boolean): Boolean;
var
    overlap: Integer;
    max_overlap: Integer;
    appended: string;
    snapshot_position: Integer;
    bridge: string;
begin
    Result := False;
    incremental_text := '';
    incremental_prefix := 0;
    requires_rebuild := False;
    if value = '' then
    begin
        Exit;
    end;
    if m_document_text = '' then
    begin
        m_document_text := value;
        requires_rebuild := True;
        Result := True;
        Exit;
    end;

    // Moving the caret inside text that is already cached must not count the
    // same terms again. This also makes repeated TSF read-lock notifications
    // idempotent.
    if Pos(value, m_document_text) > 0 then
    begin
        Exit;
    end;

    // A short TSF range normally contains the complete text before the
    // caret. When it still contains the previous snapshot, treat it as a
    // refreshed full view rather than appending both copies. Sliding 1024
    // character windows are handled by the overlap path below.
    snapshot_position := Pos(m_snapshot, value);
    if (Length(value) < c_max_snapshot_chars) and
        (snapshot_position > 0) then
    begin
        m_document_text := value;
        requires_rebuild := True;
        Result := True;
        Exit;
    end;

    max_overlap := Min(Length(m_snapshot), Length(value));
    overlap := max_overlap;
    while overlap >= c_min_snapshot_overlap do
    begin
        if Copy(m_snapshot, Length(m_snapshot) - overlap + 1, overlap) =
            Copy(value, 1, overlap) then
        begin
            Break;
        end;
        Dec(overlap);
    end;
    if overlap < c_min_snapshot_overlap then
    begin
        overlap := 0;
    end;

    if overlap > 0 then
    begin
        appended := Copy(value, overlap + 1, MaxInt);
        bridge := Copy(m_document_text,
            Max(1, Length(m_document_text) - c_max_ngram_chars + 2),
            c_max_ngram_chars - 1);
        incremental_text := bridge + appended;
        incremental_prefix := Length(bridge);
    end
    else
    begin
        // A caret jump or an application-provided discontinuous range starts
        // a new run. The separator prevents false n-grams across the jump,
        // while terms from the same document remain available.
        appended := sLineBreak + value;
        incremental_text := value;
        incremental_prefix := 0;
    end;
    if appended = '' then
    begin
        Exit;
    end;
    m_document_text := m_document_text + appended;
    if Length(m_document_text) > c_document_trim_trigger_chars then
    begin
        m_document_text := Copy(m_document_text,
            Length(m_document_text) - c_max_document_chars + 1,
            c_max_document_chars);
        requires_rebuild := True;
    end;
    Result := True;
end;

procedure TncDocumentContextModel.set_snapshot(const document_key,
    text: string);
var
    next_key: string;
    next_snapshot: string;
    changed: Boolean;
    incremental_text: string;
    incremental_prefix: Integer;
    requires_rebuild: Boolean;
begin
    next_key := Trim(document_key);
    if next_key = '' then
    begin
        clear;
        Exit;
    end;
    next_snapshot := trim_tail(text, c_max_snapshot_chars);
    // Password and protected-input scopes publish an empty snapshot.  Do not
    // retain document-local terms from the previously focused editable range.
    if next_snapshot = '' then
    begin
        clear;
        m_document_key := next_key;
        Exit;
    end;
    if (m_document_key = next_key) and (m_snapshot = next_snapshot) then
    begin
        Exit;
    end;
    if m_document_key <> next_key then
    begin
        clear;
        m_document_key := next_key;
    end;
    changed := merge_snapshot(next_snapshot, incremental_text,
        incremental_prefix, requires_rebuild);
    m_snapshot := next_snapshot;
    m_recent_tail := trim_tail(next_snapshot, c_recent_tail_chars);
    if changed and requires_rebuild then
    begin
        rebuild;
    end;
    if changed and (not requires_rebuild) then
    begin
        add_incremental_ngrams(incremental_text, incremental_prefix);
    end;
end;

function TncDocumentContextModel.ngram_count(const value: string): Integer;
begin
    Result := 0;
    if (value <> '') and (m_ngrams <> nil) then
    begin
        m_ngrams.TryGetValue(value, Result);
    end;
end;

function TncDocumentContextModel.has_context: Boolean;
begin
    Result := (m_document_key <> '') and (m_document_text <> '');
end;

function TncDocumentContextModel.score_text(const text: string): Integer;
var
    value: string;
    width: Integer;
    start_idx: Integer;
    count: Integer;
    exact_count: Integer;
begin
    Result := 0;
    if not has_context then
    begin
        Exit;
    end;
    value := Trim(text);
    // A two-character term is useful only after it has repeated in the same
    // document. A single occurrence is too ambiguous to alter ranking.
    if Length(value) < 2 then
    begin
        Exit;
    end;

    if Length(value) <= c_max_ngram_chars then
    begin
        exact_count := ngram_count(value);
        if (exact_count > 0) and (Length(value) = 2) then
        begin
            // Reusing a two-character exact word later in the same document
            // is useful evidence even after its first occurrence. Frequency
            // and recency increase the support monotonically, while the
            // overall cap keeps document-local evidence bounded.
            Inc(Result, 280 + Min(240, (exact_count - 1) * 96));
            if Pos(value, m_recent_tail) > 0 then
            begin
                Inc(Result, 112);
            end;
        end
        else if (exact_count > 0) and (Length(value) >= 3) then
        begin
            Inc(Result, 80 + Min(96, (Length(value) - 2) * 16) +
                Min(240, (exact_count - 1) * 72));
            if Pos(value, m_recent_tail) > 0 then
            begin
                Inc(Result, 72);
            end;
        end;
    end;

    for width := 2 to Min(5, Length(value)) do
    begin
        for start_idx := 1 to Length(value) - width + 1 do
        begin
            count := ngram_count(Copy(value, start_idx, width));
            if count >= 2 then
            begin
                Inc(Result, 6 + (width - 2) * 5 +
                    Min(36, (count - 1) * 7));
            end;
        end;
    end;
    Result := Min(Result, c_text_score_cap);
end;

function TncDocumentContextModel.score_path(const encoded_path: string;
    const separator: Char): Integer;
var
    parts: TArray<string>;
    idx: Integer;
    segment: string;
    pair_text: string;
    count: Integer;
begin
    Result := 0;
    if not has_context then
    begin
        Exit;
    end;
    parts := encoded_path.Split([separator]);
    for idx := 0 to High(parts) do
    begin
        segment := Trim(parts[idx]);
        if (Length(segment) >= 2) and (Length(segment) <= c_max_ngram_chars) then
        begin
            count := ngram_count(segment);
            if (count > 0) and
                ((Length(segment) >= 3) or (count >= 2)) then
            begin
                Inc(Result, 44 + Min(72, (Length(segment) - 2) * 12) +
                    Min(144, (count - 1) * 48));
            end;
        end;
        if idx = 0 then
        begin
            Continue;
        end;
        pair_text := Trim(parts[idx - 1]) + segment;
        // A two-character 1+1 path is too ambiguous to promote from document
        // frequency alone (for example, "except"-style homophone pairs).
        if (Length(pair_text) >= 3) and (Length(pair_text) <= c_max_ngram_chars) then
        begin
            count := ngram_count(pair_text);
            if count > 0 then
            begin
                Inc(Result, 92 + Min(84, (Length(pair_text) - 3) * 14) +
                    Min(208, (count - 1) * 64));
            end;
        end;
    end;
    Result := Min(Result, c_path_score_cap);
end;

end.
