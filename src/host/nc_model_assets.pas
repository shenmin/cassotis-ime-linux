unit nc_model_assets;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Classes, fpjson;

function read_model_manifest(const path: string): TJSONObject;
function model_file_matches_hash(const path, expected: string): Boolean;

implementation

uses jsonparser, Process;

function read_model_manifest(const path: string): TJSONObject;
var stream: TFileStream; value: TJSONData;
begin
    stream := TFileStream.Create(UTF8Encode(path), fmOpenRead or fmShareDenyWrite);
    try
        value := GetJSON(stream);
    finally stream.Free; end;
    if not (value is TJSONObject) then
    begin
        value.Free;
        raise Exception.Create('Invalid model manifest');
    end;
    Result := TJSONObject(value);
end;

function model_file_matches_hash(const path, expected: string): Boolean;
var output: AnsiString; idx: Integer;
begin
    Result := False;
    if (Length(expected) <> 64) or not FileExists(path) then Exit;
    for idx := 1 to Length(expected) do
        if not CharInSet(expected[idx], ['0'..'9', 'a'..'f', 'A'..'F']) then Exit;
    // Verification runs only on the optional loader thread, never per key.
    // RunCommand drains its pipes while the child is running and checks status.
    if not RunCommand('/usr/bin/sha256sum', ['--', UTF8Encode(path)], output,
        [poNoConsole]) then Exit;
    Result := SameText(Copy(output, 1, 64), UTF8Encode(expected));
end;

end.
