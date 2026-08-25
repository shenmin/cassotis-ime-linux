unit nc_dictionary_reader;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    nc_sqlite;

const
    c_minimum_dictionary_schema_version = 18;

type
    TncRawDictionaryEntry = record
        pinyin: string;
        text: string;
        comment: string;
        weight: Integer;
    end;
    TncRawDictionaryEntries = array of TncRawDictionaryEntry;
    TncDictionaryTexts = array of string;
    TncDictionaryScores = array of Integer;

    TncDictionaryReader = class
    private
        FConnection: TncSqliteConnection;
        FSchemaVersion: Integer;
        FOpened: Boolean;
        FErrorMessage: string;
        FCharLmAvailable: Integer;
        function ReadSchemaVersion(out version: Integer): Boolean;
        function EnsureCharLmAvailable: Boolean;
    public
        constructor Create(const db_path: string;
            const sqlite_library_override: string = '');
        destructor Destroy; override;
        function Open: Boolean;
        procedure Close;
        function QueryExact(const pinyin: string; const maximum_count: Integer;
            out entries: TncRawDictionaryEntries): Boolean;
        function QueryAlias(const compact_pinyin: string;
            const maximum_count: Integer;
            out entries: TncRawDictionaryEntries): Boolean;
        function QueryJianpin(const jianpin: string;
            const maximum_count: Integer;
            out entries: TncRawDictionaryEntries): Boolean;
        function QueryPath(const query_pinyin: string;
            const maximum_count: Integer;
            out entries: TncRawDictionaryEntries): Boolean;
        function QueryPrefix(const pinyin_prefix: string;
            const text_character_count: Integer;
            const maximum_count: Integer;
            out entries: TncRawDictionaryEntries): Boolean;
        function QueryCompletions(const typed_prefix: string;
            const maximum_count: Integer;
            out entries: TncRawDictionaryEntries): Boolean;
        function QueryCharLmTextScores(const texts: TncDictionaryTexts;
            out scores: TncDictionaryScores): Boolean;
        property Opened: Boolean read FOpened;
        property SchemaVersion: Integer read FSchemaVersion;
        property ErrorMessage: string read FErrorMessage;
    end;

implementation

uses
    SysUtils;

constructor TncDictionaryReader.Create(const db_path: string;
    const sqlite_library_override: string);
begin
    inherited Create;
    FConnection := TncSqliteConnection.Create(db_path,
        sqlite_library_override);
    FSchemaVersion := 0;
    FOpened := False;
    FErrorMessage := '';
    FCharLmAvailable := -1;
end;

function TncDictionaryReader.EnsureCharLmAvailable: Boolean;
const
    c_query = 'SELECT 1 FROM sqlite_master WHERE type = ''table'' ' +
        'AND name = ''dict_base_char_lm'' LIMIT 1;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    saved_error: string;
begin
    if FCharLmAvailable >= 0 then
        Exit(FCharLmAvailable = 1);
    if not FOpened then
        Exit(False);
    saved_error := FErrorMessage;
    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FCharLmAvailable := 0;
        FErrorMessage := saved_error;
        Exit(False);
    end;
    try
        step_result := FConnection.Step(statement);
        if step_result = SQLITE_ROW then
            FCharLmAvailable := 1
        else
            FCharLmAvailable := 0;
    finally
        FConnection.Finalize(statement);
    end;
    FErrorMessage := saved_error;
    Result := FCharLmAvailable = 1;
end;

function TncDictionaryReader.QueryAlias(const compact_pinyin: string;
    const maximum_count: Integer; out entries: TncRawDictionaryEntries): Boolean;
const
    c_query = 'SELECT b.pinyin, b.text, b.comment, b.weight ' +
        'FROM dict_base_pinyin_alias a ' +
        'INNER JOIN dict_base b ON b.id = a.word_id ' +
        'WHERE a.compact_pinyin = ?1 ' +
        'ORDER BY b.weight DESC, b.text ASC LIMIT ?2;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    entry_count: Integer;
begin
    entries := nil;
    if not FOpened then
    begin
        FErrorMessage := 'dictionary is not open';
        Exit(False);
    end;
    if maximum_count <= 0 then
    begin
        FErrorMessage := 'maximum candidate count must be positive';
        Exit(False);
    end;

    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if (not FConnection.BindText(statement, 1,
            LowerCase(Trim(compact_pinyin)))) or
            (not FConnection.BindInt(statement, 2, maximum_count)) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;
        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            entry_count := Length(entries);
            SetLength(entries, entry_count + 1);
            entries[entry_count].pinyin := FConnection.ColumnText(statement, 0);
            entries[entry_count].text := FConnection.ColumnText(statement, 1);
            entries[entry_count].comment := FConnection.ColumnText(statement, 2);
            entries[entry_count].weight := FConnection.ColumnInt(statement, 3);
        end;
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncDictionaryReader.QueryJianpin(const jianpin: string;
    const maximum_count: Integer; out entries: TncRawDictionaryEntries): Boolean;
const
    c_query = 'SELECT b.pinyin, b.text, b.comment, j.weight ' +
        'FROM (SELECT word_id, weight FROM dict_jianpin ' +
        'WHERE jianpin = ?1 ORDER BY weight DESC, word_id ASC LIMIT ?2) j ' +
        'INNER JOIN dict_base b ON b.id = j.word_id ' +
        'ORDER BY j.weight DESC, b.weight DESC, b.text ASC LIMIT ?2;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    entry_count: Integer;
begin
    entries := nil;
    if not FOpened then
    begin
        FErrorMessage := 'dictionary is not open';
        Exit(False);
    end;
    if maximum_count <= 0 then
    begin
        FErrorMessage := 'maximum candidate count must be positive';
        Exit(False);
    end;

    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if (not FConnection.BindText(statement, 1, LowerCase(Trim(jianpin)))) or
            (not FConnection.BindInt(statement, 2, maximum_count)) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;
        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            entry_count := Length(entries);
            SetLength(entries, entry_count + 1);
            entries[entry_count].pinyin := FConnection.ColumnText(statement, 0);
            entries[entry_count].text := FConnection.ColumnText(statement, 1);
            entries[entry_count].comment := FConnection.ColumnText(statement, 2);
            entries[entry_count].weight := FConnection.ColumnInt(statement, 3);
        end;
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncDictionaryReader.QueryPath(const query_pinyin: string;
    const maximum_count: Integer; out entries: TncRawDictionaryEntries): Boolean;
const
    c_query = 'SELECT REPLACE(path_text, char(3), ''''), ' +
        'MAX(weight) AS best_weight FROM (' +
        'SELECT path_text, weight FROM dict_base_lm_transition ' +
        'WHERE query_pinyin = ?1 UNION ALL ' +
        'SELECT path_text, weight FROM dict_base_query_path ' +
        'WHERE query_pinyin = ?1) ' +
        'GROUP BY REPLACE(path_text, char(3), '''') ' +
        'ORDER BY best_weight DESC, REPLACE(path_text, char(3), '''') ASC ' +
        'LIMIT ?2;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    entry_count: Integer;
    normalized_query: string;
begin
    entries := nil;
    if not FOpened then
    begin
        FErrorMessage := 'dictionary is not open';
        Exit(False);
    end;
    if maximum_count <= 0 then
    begin
        FErrorMessage := 'maximum candidate count must be positive';
        Exit(False);
    end;
    normalized_query := LowerCase(Trim(query_pinyin));
    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if (not FConnection.BindText(statement, 1, normalized_query)) or
            (not FConnection.BindInt(statement, 2, maximum_count)) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;
        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            entry_count := Length(entries);
            SetLength(entries, entry_count + 1);
            entries[entry_count].pinyin := normalized_query;
            entries[entry_count].text := FConnection.ColumnText(statement, 0);
            entries[entry_count].comment := '';
            entries[entry_count].weight := FConnection.ColumnInt(statement, 1);
        end;
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

destructor TncDictionaryReader.Destroy;
begin
    Close;
    FConnection.Free;
    inherited Destroy;
end;

function TncDictionaryReader.ReadSchemaVersion(out version: Integer): Boolean;
const
    c_query = 'SELECT value FROM meta WHERE key = ''schema_version'' LIMIT 1;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    value: string;
    parse_error: Integer;
begin
    version := 0;
    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        step_result := FConnection.Step(statement);
        if step_result <> SQLITE_ROW then
        begin
            if step_result = SQLITE_DONE then
                FErrorMessage := 'dictionary schema version is missing'
            else
                FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;
        value := FConnection.ColumnText(statement, 0);
        Val(value, version, parse_error);
        if parse_error <> 0 then
            version := 0;
        if version <= 0 then
        begin
            FErrorMessage := 'dictionary schema version is invalid: ' + value;
            Exit(False);
        end;
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncDictionaryReader.Open: Boolean;
begin
    if FOpened then
        Exit(True);
    FErrorMessage := '';
    FSchemaVersion := 0;
    if not FConnection.Open(SQLITE_OPEN_READONLY) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    if not ReadSchemaVersion(FSchemaVersion) then
    begin
        FConnection.Close;
        Exit(False);
    end;
    if FSchemaVersion < c_minimum_dictionary_schema_version then
    begin
        FErrorMessage := 'dictionary schema version ' +
            UnicodeString(IntToStr(FSchemaVersion)) + ' is older than required ' +
            UnicodeString(IntToStr(c_minimum_dictionary_schema_version));
        FConnection.Close;
        Exit(False);
    end;
    FOpened := True;
    Result := True;
end;

procedure TncDictionaryReader.Close;
begin
    FConnection.Close;
    FOpened := False;
    FCharLmAvailable := -1;
end;

function TncDictionaryReader.QueryCharLmTextScores(
    const texts: TncDictionaryTexts; out scores: TncDictionaryScores): Boolean;
const
    c_begin_marker = #2;
    c_end_marker = #3;
    c_unknown_score = -30000;
    c_query_chunk_size = 400;
type
    TncTextUnits = array of string;
    TncPreparedTextUnits = array of TncTextUnits;
    TncCharLmValue = record
        ngram: string;
        score: Integer;
        backoff: Integer;
        found: Boolean;
    end;
    TncCharLmValues = array of TncCharLmValue;
var
    values: TncCharLmValues;
    prepared_units: TncPreparedTextUnits;
    text_units: TncTextUnits;
    padded_units: TncTextUnits;
    saved_error: string;
    text_index: Integer;
    unit_index: Integer;
    padded_index: Integer;
    predicted: Integer;
    current_score: Integer;
    entry_score: Integer;
    entry_backoff: Integer;
    total_score: Int64;
    unigram: string;
    bigram: string;
    trigram: string;
    trigram_context: string;
    fourgram: string;
    fourgram_context: string;

    function SplitTextUnits(const value: string): TncTextUnits;
    var
        source_index: Integer;
        unit_count: Integer;
        first_value: Word;
        second_value: Word;
    begin
        Result := nil;
        source_index := 1;
        while source_index <= Length(value) do
        begin
            unit_count := Length(Result);
            SetLength(Result, unit_count + 1);
            first_value := Ord(value[source_index]);
            if (first_value >= $D800) and (first_value <= $DBFF) and
                (source_index < Length(value)) then
            begin
                second_value := Ord(value[source_index + 1]);
                if (second_value >= $DC00) and (second_value <= $DFFF) then
                begin
                    Result[unit_count] := Copy(value, source_index, 2);
                    Inc(source_index, 2);
                    Continue;
                end;
            end;
            Result[unit_count] := value[source_index];
            Inc(source_index);
        end;
    end;

    procedure AddWanted(const ngram: string);
    var
        index: Integer;
    begin
        if ngram = '' then
            Exit;
        for index := 0 to High(values) do
            if values[index].ngram = ngram then
                Exit;
        SetLength(values, Length(values) + 1);
        values[High(values)].ngram := ngram;
        values[High(values)].score := 0;
        values[High(values)].backoff := 0;
        values[High(values)].found := False;
    end;

    procedure SortValues;
    var
        index: Integer;
        scan_index: Integer;
        current_value: TncCharLmValue;
    begin
        for index := 1 to High(values) do
        begin
            current_value := values[index];
            scan_index := index - 1;
            while (scan_index >= 0) and
                (current_value.ngram < values[scan_index].ngram) do
            begin
                values[scan_index + 1] := values[scan_index];
                Dec(scan_index);
            end;
            values[scan_index + 1] := current_value;
        end;
    end;

    function FindValue(const ngram: string): Integer;
    var
        lower_bound: Integer;
        upper_bound: Integer;
        middle: Integer;
    begin
        lower_bound := 0;
        upper_bound := High(values);
        while lower_bound <= upper_bound do
        begin
            middle := lower_bound + (upper_bound - lower_bound) div 2;
            if values[middle].ngram = ngram then
                Exit(middle);
            if values[middle].ngram < ngram then
                lower_bound := middle + 1
            else
                upper_bound := middle - 1;
        end;
        Result := -1;
    end;

    function TryGetValue(const ngram: string; out score: Integer;
        out backoff: Integer): Boolean;
    var
        value_index: Integer;
    begin
        score := 0;
        backoff := 0;
        value_index := FindValue(ngram);
        Result := (value_index >= 0) and values[value_index].found;
        if Result then
        begin
            score := values[value_index].score;
            backoff := values[value_index].backoff;
        end;
    end;

    function LoadValues: Boolean;
    var
        sql: string;
        statement: Psqlite3_stmt;
        chunk_start: Integer;
        chunk_count: Integer;
        chunk_index: Integer;
        step_result: Integer;
        row_ngram: string;
        value_index: Integer;
    begin
        chunk_start := 0;
        while chunk_start < Length(values) do
        begin
            chunk_count := Length(values) - chunk_start;
            if chunk_count > c_query_chunk_size then
                chunk_count := c_query_chunk_size;
            sql := 'SELECT ngram, score, backoff FROM dict_base_char_lm ' +
                'WHERE ngram IN (';
            for chunk_index := 1 to chunk_count do
            begin
                if chunk_index > 1 then
                    sql := sql + ',';
                sql := sql + '?' + UnicodeString(IntToStr(chunk_index));
            end;
            sql := sql + ');';
            statement := nil;
            if not FConnection.Prepare(sql, statement) then
                Exit(False);
            try
                for chunk_index := 0 to chunk_count - 1 do
                    if not FConnection.BindText(statement, chunk_index + 1,
                        values[chunk_start + chunk_index].ngram) then
                        Exit(False);
                while True do
                begin
                    step_result := FConnection.Step(statement);
                    if step_result = SQLITE_DONE then
                        Break;
                    if step_result <> SQLITE_ROW then
                        Exit(False);
                    row_ngram := FConnection.ColumnText(statement, 0);
                    value_index := FindValue(row_ngram);
                    if value_index >= 0 then
                    begin
                        values[value_index].score :=
                            FConnection.ColumnInt(statement, 1);
                        values[value_index].backoff :=
                            FConnection.ColumnInt(statement, 2);
                        values[value_index].found := True;
                    end;
                end;
            finally
                FConnection.Finalize(statement);
            end;
            Inc(chunk_start, chunk_count);
        end;
        Result := True;
    end;

begin
    scores := nil;
    prepared_units := nil;
    padded_units := nil;
    if Length(texts) = 0 then
        Exit(True);
    saved_error := FErrorMessage;
    if (not FOpened) or (not EnsureCharLmAvailable) then
    begin
        FErrorMessage := saved_error;
        Exit(False);
    end;

    values := nil;
    SetLength(prepared_units, Length(texts));
    for text_index := 0 to High(texts) do
    begin
        text_units := SplitTextUnits(Trim(texts[text_index]));
        if Length(text_units) = 0 then
            Continue;
        SetLength(padded_units, Length(text_units) + 4);
        padded_units[0] := c_begin_marker;
        padded_units[1] := c_begin_marker;
        padded_units[2] := c_begin_marker;
        for unit_index := 0 to High(text_units) do
            padded_units[unit_index + 3] := text_units[unit_index];
        padded_units[High(padded_units)] := c_end_marker;
        prepared_units[text_index] := padded_units;

        AddWanted(c_begin_marker);
        AddWanted(c_begin_marker + c_begin_marker);
        AddWanted(c_begin_marker + c_begin_marker + c_begin_marker);
        for padded_index := 3 to High(padded_units) do
        begin
            unigram := padded_units[padded_index];
            bigram := padded_units[padded_index - 1] + unigram;
            trigram_context := padded_units[padded_index - 2] +
                padded_units[padded_index - 1];
            trigram := trigram_context + unigram;
            fourgram_context := padded_units[padded_index - 3] +
                padded_units[padded_index - 2] +
                padded_units[padded_index - 1];
            fourgram := fourgram_context + unigram;
            AddWanted(unigram);
            AddWanted(bigram);
            AddWanted(padded_units[padded_index - 1]);
            AddWanted(trigram);
            AddWanted(trigram_context);
            AddWanted(fourgram);
            AddWanted(fourgram_context);
        end;
    end;

    SortValues;
    if (Length(values) = 0) or (not LoadValues) then
    begin
        FErrorMessage := saved_error;
        Exit(False);
    end;

    SetLength(scores, Length(texts));
    for text_index := 0 to High(texts) do
    begin
        padded_units := prepared_units[text_index];
        if Length(padded_units) = 0 then
        begin
            scores[text_index] := c_unknown_score;
            Continue;
        end;
        total_score := 0;
        predicted := 0;
        for padded_index := 3 to High(padded_units) do
        begin
            unigram := padded_units[padded_index];
            bigram := padded_units[padded_index - 1] + unigram;
            trigram_context := padded_units[padded_index - 2] +
                padded_units[padded_index - 1];
            trigram := trigram_context + unigram;
            fourgram_context := padded_units[padded_index - 3] +
                padded_units[padded_index - 2] +
                padded_units[padded_index - 1];
            fourgram := fourgram_context + unigram;
            if TryGetValue(fourgram, entry_score, entry_backoff) then
                current_score := entry_score
            else
            begin
                if TryGetValue(trigram, entry_score, entry_backoff) then
                    current_score := entry_score
                else
                begin
                    if TryGetValue(bigram, entry_score, entry_backoff) then
                        current_score := entry_score
                    else
                    begin
                        if TryGetValue(unigram, entry_score,
                            entry_backoff) then
                            current_score := entry_score
                        else
                            current_score := c_unknown_score;
                        if TryGetValue(padded_units[padded_index - 1],
                            entry_score, entry_backoff) then
                            Inc(current_score, entry_backoff);
                    end;
                    if TryGetValue(trigram_context, entry_score,
                        entry_backoff) then
                        Inc(current_score, entry_backoff);
                end;
                if TryGetValue(fourgram_context, entry_score,
                    entry_backoff) then
                    Inc(current_score, entry_backoff);
            end;
            Inc(total_score, current_score);
            Inc(predicted);
        end;
        if predicted <= 0 then
            scores[text_index] := c_unknown_score
        else if total_score >= 0 then
            scores[text_index] := total_score div predicted
        else
            scores[text_index] :=
                -((-total_score + predicted - 1) div predicted);
    end;
    FErrorMessage := saved_error;
    Result := True;
end;

function TncDictionaryReader.QueryExact(const pinyin: string;
    const maximum_count: Integer; out entries: TncRawDictionaryEntries): Boolean;
const
    c_query = 'SELECT pinyin, text, comment, weight FROM dict_base ' +
        'WHERE pinyin = ?1 ORDER BY weight DESC, text ASC LIMIT ?2;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    entry_count: Integer;
begin
    entries := nil;
    if not FOpened then
    begin
        FErrorMessage := 'dictionary is not open';
        Exit(False);
    end;
    if maximum_count <= 0 then
    begin
        FErrorMessage := 'maximum candidate count must be positive';
        Exit(False);
    end;

    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if (not FConnection.BindText(statement, 1, LowerCase(Trim(pinyin)))) or
            (not FConnection.BindInt(statement, 2, maximum_count)) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;

        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            entry_count := Length(entries);
            SetLength(entries, entry_count + 1);
            entries[entry_count].pinyin := FConnection.ColumnText(statement, 0);
            entries[entry_count].text := FConnection.ColumnText(statement, 1);
            entries[entry_count].comment := FConnection.ColumnText(statement, 2);
            entries[entry_count].weight := FConnection.ColumnInt(statement, 3);
        end;
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncDictionaryReader.QueryCompletions(const typed_prefix: string;
    const maximum_count: Integer;
    out entries: TncRawDictionaryEntries): Boolean;
const
    c_query = 'SELECT full_pinyin, text, '''', weight ' +
        'FROM dict_base_completion_lookup ' +
        'WHERE typed_prefix = ?1 AND length(full_pinyin) > length(?1) ' +
        'AND text <> '''' ORDER BY rank_order ASC, weight DESC, text ASC ' +
        'LIMIT ?2;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    entry_count: Integer;
    normalized_prefix: string;
begin
    entries := nil;
    if not FOpened then
    begin
        FErrorMessage := 'dictionary is not open';
        Exit(False);
    end;
    normalized_prefix := LowerCase(Trim(typed_prefix));
    if normalized_prefix = '' then
    begin
        FErrorMessage := 'completion prefix must not be empty';
        Exit(False);
    end;
    if maximum_count <= 0 then
    begin
        FErrorMessage := 'maximum completion count must be positive';
        Exit(False);
    end;

    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if (not FConnection.BindText(statement, 1, normalized_prefix)) or
            (not FConnection.BindInt(statement, 2, maximum_count)) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;
        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            entry_count := Length(entries);
            SetLength(entries, entry_count + 1);
            entries[entry_count].pinyin := FConnection.ColumnText(statement, 0);
            entries[entry_count].text := FConnection.ColumnText(statement, 1);
            entries[entry_count].comment := '';
            entries[entry_count].weight := FConnection.ColumnInt(statement, 3);
        end;
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

function TncDictionaryReader.QueryPrefix(const pinyin_prefix: string;
    const text_character_count: Integer; const maximum_count: Integer;
    out entries: TncRawDictionaryEntries): Boolean;
const
    c_query = 'SELECT pinyin, text, comment, weight FROM dict_base ' +
        'WHERE pinyin >= ?1 AND pinyin < ?2 AND length(text) = ?3 ' +
        'ORDER BY weight DESC, text ASC LIMIT ?4;';
var
    statement: Psqlite3_stmt;
    step_result: Integer;
    entry_count: Integer;
    normalized_prefix: string;
    upper_bound: string;
begin
    entries := nil;
    if not FOpened then
    begin
        FErrorMessage := 'dictionary is not open';
        Exit(False);
    end;
    normalized_prefix := LowerCase(Trim(pinyin_prefix));
    if normalized_prefix = '' then
    begin
        FErrorMessage := 'pinyin prefix must not be empty';
        Exit(False);
    end;
    if text_character_count <= 0 then
    begin
        FErrorMessage := 'text character count must be positive';
        Exit(False);
    end;
    if maximum_count <= 0 then
    begin
        FErrorMessage := 'maximum candidate count must be positive';
        Exit(False);
    end;

    // Dictionary pinyin keys are lowercase ASCII. "{" is the first ASCII
    // character after "z", so this range remains indexable without LIKE.
    upper_bound := normalized_prefix + '{';
    statement := nil;
    if not FConnection.Prepare(c_query, statement) then
    begin
        FErrorMessage := FConnection.Errmsg;
        Exit(False);
    end;
    try
        if (not FConnection.BindText(statement, 1, normalized_prefix)) or
            (not FConnection.BindText(statement, 2, upper_bound)) or
            (not FConnection.BindInt(statement, 3, text_character_count)) or
            (not FConnection.BindInt(statement, 4, maximum_count)) then
        begin
            FErrorMessage := FConnection.Errmsg;
            Exit(False);
        end;

        while True do
        begin
            step_result := FConnection.Step(statement);
            if step_result = SQLITE_DONE then
                Break;
            if step_result <> SQLITE_ROW then
            begin
                FErrorMessage := FConnection.Errmsg;
                Exit(False);
            end;
            entry_count := Length(entries);
            SetLength(entries, entry_count + 1);
            entries[entry_count].pinyin := FConnection.ColumnText(statement, 0);
            entries[entry_count].text := FConnection.ColumnText(statement, 1);
            entries[entry_count].comment := FConnection.ColumnText(statement, 2);
            entries[entry_count].weight := FConnection.ColumnInt(statement, 3);
        end;
        FErrorMessage := '';
        Result := True;
    finally
        FConnection.Finalize(statement);
    end;
end;

end.
