unit nc_io_compat;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses
    Classes,
    SysUtils;

type
    TncFile = class
    public
        class function GetLastWriteTime(const path: string): TDateTime;
            static;
        class function ReadAllText(const path: string;
            const encoding: TEncoding): string; static;
    end;

implementation

class function TncFile.GetLastWriteTime(const path: string): TDateTime;
var
    age: LongInt;
begin
    age := FileAge(path);
    if age < 0 then
        Exit(0);
    Result := FileDateToDateTime(age);
end;

class function TncFile.ReadAllText(const path: string;
    const encoding: TEncoding): string;
var
    stream: TFileStream;
    bytes: TBytes;
begin
    stream := TFileStream.Create(path, fmOpenRead or fmShareDenyNone);
    try
        SetLength(bytes, stream.Size);
        if Length(bytes) > 0 then
            stream.ReadBuffer(bytes[0], Length(bytes));
        Result := encoding.GetString(bytes);
    finally
        stream.Free;
    end;
end;

end.
