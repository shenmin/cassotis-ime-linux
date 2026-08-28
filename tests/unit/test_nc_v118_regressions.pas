unit test_nc_v118_regressions;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry;

type
    TncV118RegressionTests = class(TTestCase)
    private
        FDatabasePath: string;
        procedure DeleteDatabaseFiles;
    protected
        procedure SetUp; override;
        procedure TearDown; override;
    published
        procedure GeneratedCompletionModelsPassEmbeddedSelfTests;
        procedure UpgradesSchema22To24WithoutDroppingUserData;
    end;

implementation

uses
    SysUtils,
    nc_sqlite,
    nc_dictionary_sqlite,
    nc_one_key_completion_ncgpt_model,
    nc_one_key_completion_ncgpt_sparse_audit_model;

procedure TncV118RegressionTests.DeleteDatabaseFiles;
begin
    if FileExists(FDatabasePath) then
        DeleteFile(FDatabasePath);
    if FileExists(FDatabasePath + '-wal') then
        DeleteFile(FDatabasePath + '-wal');
    if FileExists(FDatabasePath + '-shm') then
        DeleteFile(FDatabasePath + '-shm');
end;

procedure TncV118RegressionTests.SetUp;
begin
    inherited SetUp;
    FDatabasePath := IncludeTrailingPathDelimiter(
        UTF8Decode(GetTempDir(False))) + 'cassotis-v118-' +
        UnicodeString(IntToStr(GetTickCount64)) + '-' +
        UnicodeString(IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2)) + '.db';
    DeleteDatabaseFiles;
end;

procedure TncV118RegressionTests.TearDown;
begin
    DeleteDatabaseFiles;
    inherited TearDown;
end;

procedure TncV118RegressionTests.GeneratedCompletionModelsPassEmbeddedSelfTests;
begin
    AssertTrue('completion ranking model self-test failed',
        one_key_completion_ncgpt_self_test);
    AssertTrue('completion sparse-audit model self-test failed',
        one_key_completion_ncgpt_sparse_audit_self_test);
end;

procedure TncV118RegressionTests.UpgradesSchema22To24WithoutDroppingUserData;
var
    connection: TncSqliteConnection;
    dictionary: TncSqliteDictionary;
    statement: Psqlite3_stmt;
    step_result: Integer;
    schema_version: string;
    has_popularity_column: Boolean;
    has_completion_lookup: Boolean;
    has_completion_competition: Boolean;
    has_completion_pair_audit: Boolean;
    preserved_user_rows: Int64;
begin
    connection := TncSqliteConnection.Create(FDatabasePath);
    try
        AssertTrue(connection.Open);
        AssertTrue(connection.Exec(
            'CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);' +
            'INSERT INTO meta(key, value) VALUES(''schema_version'', ''22'');' +
            'CREATE TABLE dict_base (' +
            'id INTEGER PRIMARY KEY AUTOINCREMENT, pinyin TEXT NOT NULL, ' +
            'text TEXT NOT NULL, weight INTEGER DEFAULT 0, comment TEXT DEFAULT '''');' +
            'CREATE TABLE dict_user (' +
            'id INTEGER PRIMARY KEY AUTOINCREMENT, pinyin TEXT NOT NULL, ' +
            'text TEXT NOT NULL, weight INTEGER DEFAULT 0, last_used INTEGER DEFAULT 0, ' +
            'UNIQUE(pinyin, text));' +
            'INSERT INTO dict_user(pinyin, text, weight, last_used) ' +
            'VALUES(''ceshi'', ''fixture'', 7, 123);'));
    finally
        connection.Free;
    end;

    dictionary := TncSqliteDictionary.Create('', FDatabasePath, False);
    try
        AssertTrue('schema migration failed', dictionary.Open);
        AssertTrue(dictionary.user_ready);
    finally
        dictionary.Free;
    end;

    schema_version := '';
    has_popularity_column := False;
    has_completion_lookup := False;
    has_completion_competition := False;
    has_completion_pair_audit := False;
    preserved_user_rows := -1;
    connection := TncSqliteConnection.Create(FDatabasePath);
    try
        AssertTrue(connection.Open(SQLITE_OPEN_READONLY));

        statement := nil;
        AssertTrue(connection.Prepare(
            'SELECT value FROM meta WHERE key = ''schema_version'';', statement));
        try
            AssertEquals(SQLITE_ROW, connection.Step(statement));
            schema_version := connection.ColumnText(statement, 0);
        finally
            connection.Finalize(statement);
        end;

        statement := nil;
        AssertTrue(connection.Prepare('PRAGMA table_info(dict_base);', statement));
        try
            step_result := connection.Step(statement);
            while step_result = SQLITE_ROW do
            begin
                if connection.ColumnText(statement, 1) =
                    'contains_popularity_eligible' then
                    has_popularity_column := True;
                step_result := connection.Step(statement);
            end;
        finally
            connection.Finalize(statement);
        end;

        statement := nil;
        AssertTrue(connection.Prepare(
            'SELECT name FROM sqlite_master WHERE type = ''table'' AND name IN (' +
            '''dict_base_completion_lookup'', ' +
            '''dict_base_completion_competition'', ' +
            '''dict_base_completion_pair_audit'');', statement));
        try
            step_result := connection.Step(statement);
            while step_result = SQLITE_ROW do
            begin
                if connection.ColumnText(statement, 0) =
                    'dict_base_completion_lookup' then
                    has_completion_lookup := True
                else if connection.ColumnText(statement, 0) =
                    'dict_base_completion_competition' then
                    has_completion_competition := True
                else if connection.ColumnText(statement, 0) =
                    'dict_base_completion_pair_audit' then
                    has_completion_pair_audit := True;
                step_result := connection.Step(statement);
            end;
        finally
            connection.Finalize(statement);
        end;

        statement := nil;
        AssertTrue(connection.Prepare(
            'SELECT COUNT(*) FROM dict_user WHERE pinyin = ''ceshi'' ' +
            'AND text = ''fixture'' AND weight = 7 AND last_used = 123;', statement));
        try
            AssertEquals(SQLITE_ROW, connection.Step(statement));
            preserved_user_rows := connection.ColumnInt64(statement, 0);
        finally
            connection.Finalize(statement);
        end;
    finally
        connection.Free;
    end;

    AssertEquals('24', schema_version);
    AssertTrue('v1.18 popularity column was not added', has_popularity_column);
    AssertTrue('completion lookup table was not created', has_completion_lookup);
    AssertTrue('completion competition table was not created',
        has_completion_competition);
    AssertTrue('completion pair-audit table was not created',
        has_completion_pair_audit);
    AssertEquals(Int64(1), preserved_user_rows);
end;

initialization
    RegisterTest(TncV118RegressionTests);

end.
