unit test_nc_dictionary_reader;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry;

type
    TncDictionaryReaderTests = class(TTestCase)
    private
        FDatabasePath: string;
        procedure CreateFixture(const schema_version: Integer);
    protected
        procedure SetUp; override;
        procedure TearDown; override;
    published
        procedure QueriesExactCandidatesInStableWeightOrder;
        procedure QueriesAliasesJianpinAndSentencePaths;
        procedure QueriesIndexedPrefixesWithCharacterConstraint;
        procedure QueriesPrecomputedCompletionsInRankOrder;
        procedure ScoresTextWithCharacterLanguageModel;
        procedure AppliesResultLimitAndReturnsEmptyMatches;
        procedure RejectsOutdatedSchema;
    end;

implementation

uses
    SysUtils,
    nc_sqlite,
    nc_dictionary_reader;

procedure TncDictionaryReaderTests.SetUp;
begin
    inherited SetUp;
    FDatabasePath := IncludeTrailingPathDelimiter(
        UTF8Decode(GetTempDir(False))) + 'cassotis-dictionary-' +
        UnicodeString(IntToStr(GetTickCount64)) + '-' +
        UnicodeString(IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2)) + '.db';
    if FileExists(FDatabasePath) then
        DeleteFile(FDatabasePath);
end;

procedure TncDictionaryReaderTests.TearDown;
begin
    if FileExists(FDatabasePath) then
        DeleteFile(FDatabasePath);
    inherited TearDown;
end;

procedure TncDictionaryReaderTests.CreateFixture(const schema_version: Integer);
var
    connection: TncSqliteConnection;
begin
    connection := TncSqliteConnection.Create(FDatabasePath);
    try
        AssertTrue(connection.Open);
        AssertTrue(connection.Exec('CREATE TABLE meta (' +
            'key TEXT PRIMARY KEY, value TEXT NOT NULL);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base (' +
            'id INTEGER PRIMARY KEY AUTOINCREMENT, pinyin TEXT NOT NULL, ' +
            'text TEXT NOT NULL, weight INTEGER DEFAULT 0, ' +
            'comment TEXT DEFAULT '''');'));
        AssertTrue(connection.Exec('CREATE INDEX idx_dict_base_pinyin_weight ' +
            'ON dict_base(pinyin, weight);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_pinyin_alias (' +
            'id INTEGER PRIMARY KEY AUTOINCREMENT, compact_pinyin TEXT NOT NULL, ' +
            'word_id INTEGER NOT NULL);'));
        AssertTrue(connection.Exec('CREATE INDEX idx_alias_compact ON ' +
            'dict_base_pinyin_alias(compact_pinyin);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_jianpin (' +
            'id INTEGER PRIMARY KEY AUTOINCREMENT, word_id INTEGER NOT NULL, ' +
            'jianpin TEXT NOT NULL, weight INTEGER DEFAULT 0);'));
        AssertTrue(connection.Exec('CREATE INDEX idx_jianpin_key_weight ON ' +
            'dict_jianpin(jianpin, weight DESC, word_id);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_query_path (' +
            'query_pinyin TEXT NOT NULL, path_text TEXT NOT NULL, ' +
            'weight INTEGER DEFAULT 0);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_lm_transition (' +
            'query_pinyin TEXT NOT NULL, path_text TEXT NOT NULL, ' +
            'weight INTEGER DEFAULT 0);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_completion_lookup (' +
            'typed_prefix TEXT NOT NULL, full_pinyin TEXT NOT NULL, ' +
            'text TEXT NOT NULL, weight INTEGER NOT NULL DEFAULT 0, ' +
            'rank_order INTEGER NOT NULL DEFAULT 0);'));
        AssertTrue(connection.Exec('CREATE INDEX idx_completion_prefix ON ' +
            'dict_base_completion_lookup(typed_prefix, rank_order);'));
        AssertTrue(connection.Exec('CREATE TABLE dict_base_char_lm (' +
            'ngram TEXT NOT NULL PRIMARY KEY, score INTEGER NOT NULL DEFAULT 0, ' +
            'backoff INTEGER NOT NULL DEFAULT 0) WITHOUT ROWID;'));
        AssertTrue(connection.Exec('INSERT INTO meta(key, value) VALUES (' +
            '''schema_version'', ''' +
            UnicodeString(IntToStr(schema_version)) + ''');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base ' +
            '(pinyin, text, weight, comment) VALUES ' +
            '(''shijie'', char(19990, 30028), 900, ''''), ' +
            '(''shijie'', char(24072, 22992), 500, ''''), ' +
            '(''shijie'', char(30707, 38454), 300, ''test'');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base ' +
            '(pinyin, text, weight, comment) VALUES ' +
            '(''wo'', char(25105), 950, ''''), ' +
            '(''wei'', char(20026), 800, ''''), ' +
            '(''nihao'', char(20320, 22909), 900, ''''), ' +
            '(''nihai'', char(20320, 36824), 700, ''''), ' +
            '(''nihaoma'', char(20320, 22909, 21527), 1000, '''');'));
        AssertTrue(connection.Exec('INSERT INTO dict_base_pinyin_alias ' +
            '(compact_pinyin, word_id) SELECT ''shij'', id FROM dict_base ' +
            'WHERE pinyin = ''shijie'' AND text = char(19990, 30028);'));
        AssertTrue(connection.Exec('INSERT INTO dict_jianpin ' +
            '(word_id, jianpin, weight) SELECT id, ''sj'', 850 FROM dict_base ' +
            'WHERE pinyin = ''shijie'' AND text = char(19990, 30028);'));
        AssertTrue(connection.Exec('INSERT INTO dict_base_query_path ' +
            '(query_pinyin, path_text, weight) VALUES ' +
            '(''youxiangdizhi'', char(37038, 31665, 22320, 22336), 440);'));
        AssertTrue(connection.Exec('INSERT INTO dict_base_lm_transition ' +
            '(query_pinyin, path_text, weight) VALUES ' +
            '(''youxiangdizhi'', char(37038, 31665, 3, 22320, 22336), 520);'));
        AssertTrue(connection.Exec('INSERT INTO dict_base_completion_lookup ' +
            '(typed_prefix, full_pinyin, text, weight, rank_order) VALUES ' +
            '(''pianruo'', ''pianruojinghong'', ' +
            'char(32745, 33509, 24778, 40511), 619, 0), ' +
            '(''pianruo'', ''pianruofuchen'', ' +
            'char(32745, 33509, 28014, 23576), 580, 1);'));
        AssertTrue(connection.Exec('INSERT INTO dict_base_char_lm ' +
            '(ngram, score, backoff) VALUES ' +
            '(char(2, 2, 2, 30002), -100, 0), ' +
            '(char(2, 2, 30002, 3), -200, 0);'));
    finally
        connection.Free;
    end;
end;

procedure TncDictionaryReaderTests.ScoresTextWithCharacterLanguageModel;
var
    reader: TncDictionaryReader;
    texts: TncDictionaryTexts;
    scores: TncDictionaryScores;
begin
    CreateFixture(c_minimum_dictionary_schema_version);
    reader := TncDictionaryReader.Create(FDatabasePath);
    try
        AssertTrue(reader.Open);
        texts := nil;
        SetLength(texts, 2);
        texts[0] := UnicodeString(WideChar(30002));
        texts[1] := UnicodeString(WideChar(20057));
        AssertTrue(reader.QueryCharLmTextScores(texts, scores));
        AssertEquals(2, Length(scores));
        AssertEquals(-150, scores[0]);
        AssertEquals(-30000, scores[1]);
    finally
        reader.Free;
    end;
end;

procedure TncDictionaryReaderTests.QueriesPrecomputedCompletionsInRankOrder;
var
    reader: TncDictionaryReader;
    entries: TncRawDictionaryEntries;
begin
    CreateFixture(c_minimum_dictionary_schema_version);
    reader := TncDictionaryReader.Create(FDatabasePath);
    try
        AssertTrue(reader.Open);
        AssertTrue(reader.QueryCompletions('PIANRUO', 10, entries));
        AssertEquals(2, Length(entries));
        AssertEquals('pianruojinghong', entries[0].pinyin);
        AssertEquals(UnicodeString(WideChar(32745)) + WideChar(33509) +
            WideChar(24778) + WideChar(40511), entries[0].text);
        AssertTrue(reader.QueryCompletions('missing', 10, entries));
        AssertEquals(0, Length(entries));
    finally
        reader.Free;
    end;
end;

procedure TncDictionaryReaderTests.QueriesAliasesJianpinAndSentencePaths;
var
    reader: TncDictionaryReader;
    entries: TncRawDictionaryEntries;
begin
    CreateFixture(c_minimum_dictionary_schema_version);
    reader := TncDictionaryReader.Create(FDatabasePath);
    try
        AssertTrue(reader.Open);
        AssertTrue(reader.QueryAlias('SHIJ', 10, entries));
        AssertEquals(1, Length(entries));
        AssertEquals(UnicodeString(WideChar($4E16)) + WideChar($754C),
            entries[0].text);

        AssertTrue(reader.QueryJianpin('SJ', 10, entries));
        AssertEquals(1, Length(entries));
        AssertEquals(850, entries[0].weight);

        AssertTrue(reader.QueryPath('YOUXIANGDIZHI', 10, entries));
        AssertEquals(1, Length(entries));
        AssertEquals(UnicodeString(WideChar($90AE)) + WideChar($7BB1) +
            WideChar($5730) + WideChar($5740), entries[0].text);
        AssertEquals(520, entries[0].weight);
    finally
        reader.Free;
    end;
end;

procedure TncDictionaryReaderTests.QueriesIndexedPrefixesWithCharacterConstraint;
var
    reader: TncDictionaryReader;
    entries: TncRawDictionaryEntries;
begin
    CreateFixture(c_minimum_dictionary_schema_version);
    reader := TncDictionaryReader.Create(FDatabasePath);
    try
        AssertTrue(reader.Open);
        AssertTrue(reader.QueryPrefix('W', 1, 10, entries));
        AssertEquals(2, Length(entries));
        AssertEquals(UnicodeString(WideChar($6211)), entries[0].text);
        AssertEquals(UnicodeString(WideChar($4E3A)), entries[1].text);

        AssertTrue(reader.QueryPrefix('nih', 2, 10, entries));
        AssertEquals(2, Length(entries));
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($597D),
            entries[0].text);
        AssertEquals(UnicodeString(WideChar($4F60)) + WideChar($8FD8),
            entries[1].text);
    finally
        reader.Free;
    end;
end;

procedure TncDictionaryReaderTests.QueriesExactCandidatesInStableWeightOrder;
var
    reader: TncDictionaryReader;
    entries: TncRawDictionaryEntries;
begin
    CreateFixture(c_minimum_dictionary_schema_version);
    reader := TncDictionaryReader.Create(FDatabasePath);
    try
        AssertTrue(reader.Open);
        AssertEquals(c_minimum_dictionary_schema_version,
            reader.SchemaVersion);
        AssertTrue(reader.QueryExact('SHIJIE', 10, entries));
        AssertEquals(3, Length(entries));
        AssertEquals(UnicodeString(WideChar($4E16)) + WideChar($754C),
            entries[0].text);
        AssertEquals(900, entries[0].weight);
        AssertEquals(UnicodeString(WideChar($5E08)) + WideChar($59D0),
            entries[1].text);
        AssertEquals(UnicodeString(WideChar($77F3)) + WideChar($9636),
            entries[2].text);
        AssertEquals('test', entries[2].comment);
    finally
        reader.Free;
    end;
end;

procedure TncDictionaryReaderTests.AppliesResultLimitAndReturnsEmptyMatches;
var
    reader: TncDictionaryReader;
    entries: TncRawDictionaryEntries;
begin
    CreateFixture(c_minimum_dictionary_schema_version);
    reader := TncDictionaryReader.Create(FDatabasePath);
    try
        AssertTrue(reader.Open);
        AssertTrue(reader.QueryExact('shijie', 2, entries));
        AssertEquals(2, Length(entries));
        AssertTrue(reader.QueryExact('missing', 10, entries));
        AssertEquals(0, Length(entries));
    finally
        reader.Free;
    end;
end;

procedure TncDictionaryReaderTests.RejectsOutdatedSchema;
var
    reader: TncDictionaryReader;
begin
    CreateFixture(c_minimum_dictionary_schema_version - 1);
    reader := TncDictionaryReader.Create(FDatabasePath);
    try
        AssertFalse(reader.Open);
        AssertTrue(Pos('older than required', reader.ErrorMessage) > 0);
    finally
        reader.Free;
    end;
end;

initialization
    RegisterTest(TncDictionaryReaderTests);

end.
