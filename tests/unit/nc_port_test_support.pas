unit nc_port_test_support;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, fpcunit, nc_io_compat;

type
    // Keep upstream regression assertions unchanged across Delphi and FPC.
    Assert = class
        class procedure IsTrue(value: Boolean; const message: string = ''); static;
        class procedure IsFalse(value: Boolean; const message: string = ''); static;
        class procedure AreEqual(expected, actual: Int64; const message: string = ''); overload; static;
        class procedure AreEqual(const expected, actual: string; const message: string = ''); overload; static;
        class procedure AreNotEqual(expected, actual: Int64; const message: string = ''); overload; static;
        class procedure AreNotEqual(const expected, actual: string; const message: string = ''); overload; static;
        class procedure Fail(const message: string); static;
    end;
    TPath = class
        class function Combine(const base, name: string): string; static;
        class function GetTempPath: string; static;
        class function GetRandomFileName: string; static;
        class function GetFullPath(const path: string): string; static;
    end;
    TFile = class(TncFile)
        class function Exists(const path: string): Boolean; static;
    end;
    TDirectory = class
        class function Exists(const path: string): Boolean; static;
        class procedure Delete(const path: string; recursive: Boolean); static;
    end;

implementation

class procedure Assert.IsTrue(value: Boolean; const message: string);
begin
    fpcunit.TAssert.AssertTrue(UTF8Encode(message), value);
end;

class procedure Assert.IsFalse(value: Boolean; const message: string);
begin
    IsTrue(not value, message);
end;

class procedure Assert.AreEqual(expected, actual: Int64; const message: string);
begin
    fpcunit.TAssert.AssertEquals(UTF8Encode(message), expected, actual);
end;

class procedure Assert.AreEqual(const expected, actual: string; const message: string);
begin
    fpcunit.TAssert.AssertEquals(UTF8Encode(message), UTF8Encode(expected), UTF8Encode(actual));
end;

class procedure Assert.AreNotEqual(expected, actual: Int64; const message: string);
begin
    IsTrue(expected <> actual, message);
end;

class procedure Assert.AreNotEqual(const expected, actual: string; const message: string);
begin
    IsTrue(expected <> actual, message);
end;

class procedure Assert.Fail(const message: string);
begin
    fpcunit.TAssert.Fail(UTF8Encode(message));
end;

class function TPath.Combine(const base, name: string): string;
begin
    Result := IncludeTrailingPathDelimiter(base) + name;
end;

class function TPath.GetTempPath: string;
begin
    Result := UTF8Decode(GetTempDir(False));
end;

class function TPath.GetRandomFileName: string;
var guid: TGUID;
begin
    CreateGUID(guid);
    Result := GUIDToString(guid);
end;

class function TPath.GetFullPath(const path: string): string;
begin
    Result := ExpandFileName(path);
end;

class function TFile.Exists(const path: string): Boolean;
begin
    Result := FileExists(path);
end;

class function TDirectory.Exists(const path: string): Boolean;
begin
    Result := DirectoryExists(path);
end;

class procedure TDirectory.Delete(const path: string; recursive: Boolean);
var root, target: string;
    entry: TSearchRec;
begin
    root := IncludeTrailingPathDelimiter(ExpandFileName(TPath.GetTempPath));
    target := ExcludeTrailingPathDelimiter(ExpandFileName(path));
    if (Copy(target, 1, Length(root)) <> root) or
        (Pos('cassotis_', ExtractFileName(target)) <> 1) then
        raise Exception.Create('Unsafe regression fixture directory');
    // These fixtures contain only SQLite files. Never traverse unexpected dirs.
    if FindFirst(target + DirectorySeparator + '*', faAnyFile, entry) = 0 then
    try
        repeat
            if (entry.Name = '.') or (entry.Name = '..') then Continue;
            if (entry.Attr and faDirectory) <> 0 then
                raise Exception.Create('Unexpected fixture subdirectory');
            if not DeleteFile(target + DirectorySeparator + entry.Name) then
                raise Exception.Create('Cannot remove regression fixture file');
        until FindNext(entry) <> 0;
    finally
        FindClose(entry);
    end;
    if not RemoveDir(target) then
        raise Exception.Create('Cannot remove regression fixture directory');
end;

end.
