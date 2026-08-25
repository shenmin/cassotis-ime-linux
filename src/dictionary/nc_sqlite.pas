unit nc_sqlite;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    SysUtils,
    Dynlibs;

type
    Psqlite3 = Pointer;
    Psqlite3_stmt = Pointer;
    TncSqliteStringArray = array of string;

    Tsqlite3_open_v2 = function(filename: PAnsiChar; out db: Psqlite3;
        flags: Integer; vfs: PAnsiChar): Integer; cdecl;
    Tsqlite3_close = function(db: Psqlite3): Integer; cdecl;
    Tsqlite3_prepare_v2 = function(db: Psqlite3; sql: PAnsiChar;
        nbyte: Integer; out stmt: Psqlite3_stmt; tail: PPAnsiChar): Integer; cdecl;
    Tsqlite3_step = function(stmt: Psqlite3_stmt): Integer; cdecl;
    Tsqlite3_finalize = function(stmt: Psqlite3_stmt): Integer; cdecl;
    Tsqlite3_bind_text = function(stmt: Psqlite3_stmt; idx: Integer;
        text: PAnsiChar; n: Integer; destructor_callback: Pointer): Integer; cdecl;
    Tsqlite3_bind_int = function(stmt: Psqlite3_stmt; idx: Integer;
        value: Integer): Integer; cdecl;
    Tsqlite3_bind_int64 = function(stmt: Psqlite3_stmt; idx: Integer;
        value: Int64): Integer; cdecl;
    Tsqlite3_column_text = function(stmt: Psqlite3_stmt;
        idx: Integer): PAnsiChar; cdecl;
    Tsqlite3_column_int = function(stmt: Psqlite3_stmt;
        idx: Integer): Integer; cdecl;
    Tsqlite3_column_int64 = function(stmt: Psqlite3_stmt;
        idx: Integer): Int64; cdecl;
    Tsqlite3_reset = function(stmt: Psqlite3_stmt): Integer; cdecl;
    Tsqlite3_clear_bindings = function(stmt: Psqlite3_stmt): Integer; cdecl;
    Tsqlite3_errmsg = function(db: Psqlite3): PAnsiChar; cdecl;
    Tsqlite3_exec = function(db: Psqlite3; sql: PAnsiChar;
        callback: Pointer; argument: Pointer; error_message: PPAnsiChar): Integer; cdecl;

    TncSqliteLib = class
    private
        FLibraryHandle: TLibHandle;
        FLoaded: Boolean;
        FLoadedPath: string;
        FOpenV2: Tsqlite3_open_v2;
        FClose: Tsqlite3_close;
        FPrepareV2: Tsqlite3_prepare_v2;
        FStep: Tsqlite3_step;
        FFinalize: Tsqlite3_finalize;
        FBindText: Tsqlite3_bind_text;
        FBindInt: Tsqlite3_bind_int;
        FBindInt64: Tsqlite3_bind_int64;
        FColumnText: Tsqlite3_column_text;
        FColumnInt: Tsqlite3_column_int;
        FColumnInt64: Tsqlite3_column_int64;
        FReset: Tsqlite3_reset;
        FClearBindings: Tsqlite3_clear_bindings;
        FErrmsg: Tsqlite3_errmsg;
        FExec: Tsqlite3_exec;
        function LoadProc(const name: AnsiString): Pointer;
        procedure ResetProcs;
    public
        constructor Create;
        destructor Destroy; override;
        function Load(const library_name: string): Boolean;
        procedure Unload;
        function Open(const file_path: string; out db: Psqlite3;
            const flags: Integer): Integer;
        function Close(const db: Psqlite3): Integer;
        function Prepare(const db: Psqlite3; const sql: string;
            out stmt: Psqlite3_stmt): Integer;
        function Step(const stmt: Psqlite3_stmt): Integer;
        function Finalize(const stmt: Psqlite3_stmt): Integer;
        function BindText(const stmt: Psqlite3_stmt; const index: Integer;
            const text: string): Integer;
        function BindInt(const stmt: Psqlite3_stmt; const index: Integer;
            const value: Integer): Integer;
        function BindInt64(const stmt: Psqlite3_stmt; const index: Integer;
            const value: Int64): Integer;
        function ColumnText(const stmt: Psqlite3_stmt;
            const index: Integer): string;
        function ColumnInt(const stmt: Psqlite3_stmt;
            const index: Integer): Integer;
        function ColumnInt64(const stmt: Psqlite3_stmt;
            const index: Integer): Int64;
        function Reset(const stmt: Psqlite3_stmt): Integer;
        function ClearBindings(const stmt: Psqlite3_stmt): Integer;
        function Errmsg(const db: Psqlite3): string;
        function Exec(const db: Psqlite3; const sql: string): Integer;
        property Loaded: Boolean read FLoaded;
        property LoadedPath: string read FLoadedPath;
    end;

    TncSqliteConnection = class
    private
        FLib: TncSqliteLib;
        FDb: Psqlite3;
        FDbPath: string;
        FLibraryOverride: string;
        FOpened: Boolean;
        FLastError: string;
        function EnsureOpened: Boolean;
        function GetLoadedLibraryPath: string;
        procedure SetResultError(const result_code: Integer);
    public
        constructor Create(const db_path: string;
            const library_override: string = '');
        destructor Destroy; override;
        function Open: Boolean; overload;
        function Open(const flags: Integer): Boolean; overload;
        procedure Close;
        function Prepare(const sql: string; out stmt: Psqlite3_stmt): Boolean;
        function Step(const stmt: Psqlite3_stmt): Integer;
        function Finalize(const stmt: Psqlite3_stmt): Boolean;
        function BindText(const stmt: Psqlite3_stmt; const index: Integer;
            const text: string): Boolean;
        function BindInt(const stmt: Psqlite3_stmt; const index: Integer;
            const value: Integer): Boolean;
        function BindInt64(const stmt: Psqlite3_stmt; const index: Integer;
            const value: Int64): Boolean;
        function ColumnText(const stmt: Psqlite3_stmt;
            const index: Integer): string;
        function ColumnInt(const stmt: Psqlite3_stmt;
            const index: Integer): Integer;
        function ColumnInt64(const stmt: Psqlite3_stmt;
            const index: Integer): Int64;
        function Reset(const stmt: Psqlite3_stmt): Boolean;
        function ClearBindings(const stmt: Psqlite3_stmt): Boolean;
        function clear_bindings(const stmt: Psqlite3_stmt): Boolean;
        function Errmsg: string;
        function Exec(const sql: string): Boolean;
        property DbPath: string read FDbPath;
        property Opened: Boolean read FOpened;
        property LoadedLibraryPath: string read GetLoadedLibraryPath;
    end;

const
    SQLITE_OK = 0;
    SQLITE_ERROR = 1;
    SQLITE_ROW = 100;
    SQLITE_DONE = 101;
    SQLITE_OPEN_READONLY = $00000001;
    SQLITE_OPEN_READWRITE = $00000002;
    SQLITE_OPEN_CREATE = $00000004;
    SQLITE_OPEN_URI = $00000040;
    SQLITE_TRANSIENT = Pointer(-1);

implementation

function GetModuleDirectory: string;
begin
    Result := ExtractFileDir(ExpandFileName(ParamStr(0)));
end;

function GetSqliteLibraryCandidates(const preferred_path: string):
    TncSqliteStringArray;
var
    module_directory: string;
    environment_path: string;

    procedure AddCandidate(const candidate: string);
    var
        index: Integer;
        count: Integer;
    begin
        if candidate = '' then
            Exit;
        for index := 0 to High(Result) do
            if LowerCase(Result[index]) = LowerCase(candidate) then
                Exit;
        count := Length(Result);
        SetLength(Result, count + 1);
        Result[count] := candidate;
    end;

begin
    Result := nil;
    AddCandidate(preferred_path);
    environment_path := GetEnvironmentVariable('CASSOTIS_SQLITE_LIBRARY');
    AddCandidate(environment_path);
    module_directory := GetModuleDirectory;

    {$IFDEF WINDOWS}
    AddCandidate(IncludeTrailingPathDelimiter(module_directory) + 'sqlite3.dll');
    AddCandidate(IncludeTrailingPathDelimiter(module_directory) +
        'sqlite3_64.dll');
    AddCandidate('sqlite3.dll');
    {$ELSE}
    AddCandidate(IncludeTrailingPathDelimiter(module_directory) +
        'libsqlite3.so.0');
    AddCandidate(IncludeTrailingPathDelimiter(module_directory) +
        'libsqlite3.so');
    AddCandidate('libsqlite3.so.0');
    AddCandidate('libsqlite3.so');
    {$ENDIF}
end;

constructor TncSqliteLib.Create;
begin
    inherited Create;
    FLibraryHandle := NilHandle;
    FLoaded := False;
    FLoadedPath := '';
    ResetProcs;
end;

destructor TncSqliteLib.Destroy;
begin
    Unload;
    inherited Destroy;
end;

procedure TncSqliteLib.ResetProcs;
begin
    FOpenV2 := nil;
    FClose := nil;
    FPrepareV2 := nil;
    FStep := nil;
    FFinalize := nil;
    FBindText := nil;
    FBindInt := nil;
    FBindInt64 := nil;
    FColumnText := nil;
    FColumnInt := nil;
    FColumnInt64 := nil;
    FReset := nil;
    FClearBindings := nil;
    FErrmsg := nil;
    FExec := nil;
end;

function TncSqliteLib.LoadProc(const name: AnsiString): Pointer;
begin
    Result := GetProcedureAddress(FLibraryHandle, name);
end;

function TncSqliteLib.Load(const library_name: string): Boolean;
begin
    if FLoaded then
        Exit(True);
    FLibraryHandle := LoadLibrary(library_name);
    if FLibraryHandle = NilHandle then
        Exit(False);

    FOpenV2 := Tsqlite3_open_v2(LoadProc('sqlite3_open_v2'));
    FClose := Tsqlite3_close(LoadProc('sqlite3_close'));
    FPrepareV2 := Tsqlite3_prepare_v2(LoadProc('sqlite3_prepare_v2'));
    FStep := Tsqlite3_step(LoadProc('sqlite3_step'));
    FFinalize := Tsqlite3_finalize(LoadProc('sqlite3_finalize'));
    FBindText := Tsqlite3_bind_text(LoadProc('sqlite3_bind_text'));
    FBindInt := Tsqlite3_bind_int(LoadProc('sqlite3_bind_int'));
    FBindInt64 := Tsqlite3_bind_int64(LoadProc('sqlite3_bind_int64'));
    FColumnText := Tsqlite3_column_text(LoadProc('sqlite3_column_text'));
    FColumnInt := Tsqlite3_column_int(LoadProc('sqlite3_column_int'));
    FColumnInt64 := Tsqlite3_column_int64(LoadProc('sqlite3_column_int64'));
    FReset := Tsqlite3_reset(LoadProc('sqlite3_reset'));
    FClearBindings := Tsqlite3_clear_bindings(
        LoadProc('sqlite3_clear_bindings'));
    FErrmsg := Tsqlite3_errmsg(LoadProc('sqlite3_errmsg'));
    FExec := Tsqlite3_exec(LoadProc('sqlite3_exec'));

    if (not Assigned(FOpenV2)) or (not Assigned(FClose)) or
        (not Assigned(FPrepareV2)) or (not Assigned(FStep)) or
        (not Assigned(FFinalize)) or (not Assigned(FBindText)) or
        (not Assigned(FBindInt)) or (not Assigned(FBindInt64)) or
        (not Assigned(FColumnText)) or (not Assigned(FColumnInt)) or
        (not Assigned(FColumnInt64)) or (not Assigned(FReset)) or
        (not Assigned(FClearBindings)) or (not Assigned(FErrmsg)) or
        (not Assigned(FExec)) then
    begin
        Unload;
        Exit(False);
    end;

    FLoaded := True;
    FLoadedPath := library_name;
    Result := True;
end;

procedure TncSqliteLib.Unload;
begin
    if FLibraryHandle <> NilHandle then
        UnloadLibrary(FLibraryHandle);
    FLibraryHandle := NilHandle;
    FLoaded := False;
    FLoadedPath := '';
    ResetProcs;
end;

function TncSqliteLib.Open(const file_path: string; out db: Psqlite3;
    const flags: Integer): Integer;
var
    utf8_value: UTF8String;
begin
    db := nil;
    if not FLoaded then
        Exit(SQLITE_ERROR);
    utf8_value := UTF8Encode(file_path);
    Result := FOpenV2(PAnsiChar(utf8_value), db, flags, nil);
end;

function TncSqliteLib.Close(const db: Psqlite3): Integer;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    Result := FClose(db);
end;

function TncSqliteLib.Prepare(const db: Psqlite3; const sql: string;
    out stmt: Psqlite3_stmt): Integer;
var
    utf8_value: UTF8String;
begin
    stmt := nil;
    if not FLoaded then
        Exit(SQLITE_ERROR);
    utf8_value := UTF8Encode(sql);
    Result := FPrepareV2(db, PAnsiChar(utf8_value), Length(utf8_value), stmt,
        nil);
end;

function TncSqliteLib.Step(const stmt: Psqlite3_stmt): Integer;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    Result := FStep(stmt);
end;

function TncSqliteLib.Finalize(const stmt: Psqlite3_stmt): Integer;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    Result := FFinalize(stmt);
end;

function TncSqliteLib.BindText(const stmt: Psqlite3_stmt;
    const index: Integer; const text: string): Integer;
var
    utf8_value: UTF8String;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    utf8_value := UTF8Encode(text);
    Result := FBindText(stmt, index, PAnsiChar(utf8_value),
        Length(utf8_value), SQLITE_TRANSIENT);
end;

function TncSqliteLib.BindInt(const stmt: Psqlite3_stmt;
    const index: Integer; const value: Integer): Integer;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    Result := FBindInt(stmt, index, value);
end;

function TncSqliteLib.BindInt64(const stmt: Psqlite3_stmt;
    const index: Integer; const value: Int64): Integer;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    Result := FBindInt64(stmt, index, value);
end;

function TncSqliteLib.ColumnText(const stmt: Psqlite3_stmt;
    const index: Integer): string;
var
    value: PAnsiChar;
begin
    Result := '';
    if not FLoaded then
        Exit;
    value := FColumnText(stmt, index);
    if value <> nil then
        Result := UTF8Decode(AnsiString(value));
end;

function TncSqliteLib.ColumnInt(const stmt: Psqlite3_stmt;
    const index: Integer): Integer;
begin
    if not FLoaded then
        Exit(0);
    Result := FColumnInt(stmt, index);
end;

function TncSqliteLib.ColumnInt64(const stmt: Psqlite3_stmt;
    const index: Integer): Int64;
begin
    if not FLoaded then
        Exit(0);
    Result := FColumnInt64(stmt, index);
end;

function TncSqliteLib.Reset(const stmt: Psqlite3_stmt): Integer;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    Result := FReset(stmt);
end;

function TncSqliteLib.ClearBindings(const stmt: Psqlite3_stmt): Integer;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    Result := FClearBindings(stmt);
end;

function TncSqliteLib.Errmsg(const db: Psqlite3): string;
var
    value: PAnsiChar;
begin
    Result := '';
    if (not FLoaded) or (db = nil) then
        Exit;
    value := FErrmsg(db);
    if value <> nil then
        Result := UTF8Decode(AnsiString(value));
end;

function TncSqliteLib.Exec(const db: Psqlite3; const sql: string): Integer;
var
    utf8_value: UTF8String;
begin
    if not FLoaded then
        Exit(SQLITE_ERROR);
    utf8_value := UTF8Encode(sql);
    Result := FExec(db, PAnsiChar(utf8_value), nil, nil, nil);
end;

constructor TncSqliteConnection.Create(const db_path: string;
    const library_override: string);
begin
    inherited Create;
    FDbPath := db_path;
    FLibraryOverride := library_override;
    FDb := nil;
    FOpened := False;
    FLastError := '';
    FLib := TncSqliteLib.Create;
end;

destructor TncSqliteConnection.Destroy;
begin
    Close;
    FLib.Free;
    inherited Destroy;
end;

function TncSqliteConnection.EnsureOpened: Boolean;
begin
    if FOpened then
        Exit(True);
    Result := Open;
end;

function TncSqliteConnection.GetLoadedLibraryPath: string;
begin
    Result := FLib.LoadedPath;
end;

procedure TncSqliteConnection.SetResultError(const result_code: Integer);
begin
    if result_code = SQLITE_OK then
    begin
        FLastError := '';
        Exit;
    end;
    FLastError := FLib.Errmsg(FDb);
    if FLastError = '' then
        FLastError := 'sqlite error ' + UnicodeString(IntToStr(result_code));
end;

function TncSqliteConnection.Open: Boolean;
begin
    Result := Open(SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE);
end;

function TncSqliteConnection.Open(const flags: Integer): Boolean;
var
    candidates: TncSqliteStringArray;
    candidate: string;
    result_code: Integer;
begin
    if FOpened then
        Exit(True);
    if FDbPath = '' then
    begin
        FLastError := 'database path is empty';
        Exit(False);
    end;

    candidates := GetSqliteLibraryCandidates(FLibraryOverride);
    for candidate in candidates do
        if FLib.Load(candidate) then
            Break;
    if not FLib.Loaded then
    begin
        FLastError := 'unable to load SQLite library';
        Exit(False);
    end;

    result_code := FLib.Open(FDbPath, FDb, flags);
    if result_code <> SQLITE_OK then
    begin
        FLastError := FLib.Errmsg(FDb);
        if FDb <> nil then
            FLib.Close(FDb);
        FDb := nil;
        if FLastError = '' then
            FLastError := 'sqlite open error ' +
                UnicodeString(IntToStr(result_code));
        Exit(False);
    end;

    FOpened := True;
    FLastError := '';
    Result := True;
end;

procedure TncSqliteConnection.Close;
begin
    if FOpened and (FDb <> nil) then
        FLib.Close(FDb);
    FDb := nil;
    FOpened := False;
end;

function TncSqliteConnection.Prepare(const sql: string;
    out stmt: Psqlite3_stmt): Boolean;
var
    result_code: Integer;
begin
    stmt := nil;
    if not EnsureOpened then
        Exit(False);
    result_code := FLib.Prepare(FDb, sql, stmt);
    SetResultError(result_code);
    Result := result_code = SQLITE_OK;
end;

function TncSqliteConnection.Step(const stmt: Psqlite3_stmt): Integer;
begin
    if not FOpened then
        Exit(SQLITE_ERROR);
    Result := FLib.Step(stmt);
    if not (Result in [SQLITE_ROW, SQLITE_DONE]) then
        SetResultError(Result);
end;

function TncSqliteConnection.Finalize(const stmt: Psqlite3_stmt): Boolean;
var
    result_code: Integer;
begin
    if not FOpened then
        Exit(False);
    result_code := FLib.Finalize(stmt);
    SetResultError(result_code);
    Result := result_code = SQLITE_OK;
end;

function TncSqliteConnection.BindText(const stmt: Psqlite3_stmt;
    const index: Integer; const text: string): Boolean;
var
    result_code: Integer;
begin
    if not FOpened then
        Exit(False);
    result_code := FLib.BindText(stmt, index, text);
    SetResultError(result_code);
    Result := result_code = SQLITE_OK;
end;

function TncSqliteConnection.BindInt(const stmt: Psqlite3_stmt;
    const index: Integer; const value: Integer): Boolean;
var
    result_code: Integer;
begin
    if not FOpened then
        Exit(False);
    result_code := FLib.BindInt(stmt, index, value);
    SetResultError(result_code);
    Result := result_code = SQLITE_OK;
end;

function TncSqliteConnection.BindInt64(const stmt: Psqlite3_stmt;
    const index: Integer; const value: Int64): Boolean;
var
    result_code: Integer;
begin
    if not FOpened then
        Exit(False);
    result_code := FLib.BindInt64(stmt, index, value);
    SetResultError(result_code);
    Result := result_code = SQLITE_OK;
end;

function TncSqliteConnection.ColumnText(const stmt: Psqlite3_stmt;
    const index: Integer): string;
begin
    if not FOpened then
        Exit('');
    Result := FLib.ColumnText(stmt, index);
end;

function TncSqliteConnection.ColumnInt(const stmt: Psqlite3_stmt;
    const index: Integer): Integer;
begin
    if not FOpened then
        Exit(0);
    Result := FLib.ColumnInt(stmt, index);
end;

function TncSqliteConnection.ColumnInt64(const stmt: Psqlite3_stmt;
    const index: Integer): Int64;
begin
    if not FOpened then
        Exit(0);
    Result := FLib.ColumnInt64(stmt, index);
end;

function TncSqliteConnection.Reset(const stmt: Psqlite3_stmt): Boolean;
var
    result_code: Integer;
begin
    if not FOpened then
        Exit(False);
    result_code := FLib.Reset(stmt);
    SetResultError(result_code);
    Result := result_code = SQLITE_OK;
end;

function TncSqliteConnection.ClearBindings(const stmt: Psqlite3_stmt): Boolean;
var
    result_code: Integer;
begin
    if not FOpened then
        Exit(False);
    result_code := FLib.ClearBindings(stmt);
    SetResultError(result_code);
    Result := result_code = SQLITE_OK;
end;

function TncSqliteConnection.clear_bindings(
    const stmt: Psqlite3_stmt): Boolean;
begin
    Result := ClearBindings(stmt);
end;

function TncSqliteConnection.Errmsg: string;
begin
    if FLastError <> '' then
        Exit(FLastError);
    if FOpened then
        Exit(FLib.Errmsg(FDb));
    Result := 'sqlite not open';
end;

function TncSqliteConnection.Exec(const sql: string): Boolean;
var
    result_code: Integer;
begin
    if not EnsureOpened then
        Exit(False);
    result_code := FLib.Exec(FDb, sql);
    SetResultError(result_code);
    Result := result_code = SQLITE_OK;
end;

end.
