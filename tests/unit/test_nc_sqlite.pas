unit test_nc_sqlite;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    fpcunit,
    testregistry,
    nc_sqlite;

type
    TncSqliteTests = class(TTestCase)
    private
        FDatabasePath: string;
    protected
        procedure SetUp; override;
        procedure TearDown; override;
    published
        procedure CreatesQueriesAndBindsUnicode;
        procedure RejectsMissingReadonlyDatabase;
        procedure ReportsSqlErrors;
    end;

implementation

uses
    SysUtils;

procedure TncSqliteTests.SetUp;
begin
    inherited SetUp;
    FDatabasePath := IncludeTrailingPathDelimiter(
        UTF8Decode(GetTempDir(False))) + 'cassotis-sqlite-' +
        UnicodeString(IntToStr(GetTickCount64)) + '-' +
        UnicodeString(IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2)) + '.db';
    if FileExists(FDatabasePath) then
        DeleteFile(FDatabasePath);
end;

procedure TncSqliteTests.TearDown;
begin
    if FileExists(FDatabasePath) then
        DeleteFile(FDatabasePath);
    inherited TearDown;
end;

procedure TncSqliteTests.CreatesQueriesAndBindsUnicode;
var
    connection: TncSqliteConnection;
    statement: Psqlite3_stmt;
begin
    connection := TncSqliteConnection.Create(FDatabasePath);
    try
        AssertTrue(connection.Open);
        AssertTrue(connection.LoadedLibraryPath <> '');
        AssertTrue(connection.Exec('CREATE TABLE sample (' +
            'pinyin TEXT NOT NULL, text TEXT NOT NULL, weight INTEGER);'));

        statement := nil;
        AssertTrue(connection.Prepare('INSERT INTO sample ' +
            '(pinyin, text, weight) VALUES (?, ?, ?);', statement));
        try
            AssertTrue(connection.BindText(statement, 1, 'yanquan'));
            AssertTrue(connection.BindText(statement, 2, '言泉输入法'));
            AssertTrue(connection.BindInt64(statement, 3, 2147483648));
            AssertEquals(SQLITE_DONE, connection.Step(statement));
        finally
            AssertTrue(connection.Finalize(statement));
        end;

        statement := nil;
        AssertTrue(connection.Prepare('SELECT text, weight FROM sample ' +
            'WHERE pinyin = ?;', statement));
        try
            AssertTrue(connection.BindText(statement, 1, 'yanquan'));
            AssertEquals(SQLITE_ROW, connection.Step(statement));
            AssertEquals('言泉输入法', connection.ColumnText(statement, 0));
            AssertEquals(Int64(2147483648),
                connection.ColumnInt64(statement, 1));
            AssertEquals(SQLITE_DONE, connection.Step(statement));
        finally
            AssertTrue(connection.Finalize(statement));
        end;
    finally
        connection.Free;
    end;
end;

procedure TncSqliteTests.RejectsMissingReadonlyDatabase;
var
    connection: TncSqliteConnection;
begin
    connection := TncSqliteConnection.Create(FDatabasePath);
    try
        AssertFalse(connection.Open(SQLITE_OPEN_READONLY));
        AssertTrue(connection.Errmsg <> '');
        AssertFalse(FileExists(FDatabasePath));
    finally
        connection.Free;
    end;
end;

procedure TncSqliteTests.ReportsSqlErrors;
var
    connection: TncSqliteConnection;
begin
    connection := TncSqliteConnection.Create(FDatabasePath);
    try
        AssertTrue(connection.Open);
        AssertFalse(connection.Exec('this is not valid sql'));
        AssertTrue(connection.Errmsg <> '');
    finally
        connection.Free;
    end;
end;

initialization
    RegisterTest(TncSqliteTests);

end.
