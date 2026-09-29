unit nc_model_assets;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Classes, fpjson;

function read_model_manifest(const path: string): TJSONObject;
function model_file_matches_hash(const path, expected: string): Boolean;
procedure validate_external_model_files(const folder: string;
    const manifest: TJSONObject; const model_names: array of string);

implementation

uses jsonparser, Process;

procedure validate_external_model_files(const folder: string;
    const manifest: TJSONObject; const model_names: array of string);
var
    value, hash: TJSONData;
    files: TJSONObject;
    index, pos: Integer;
    name, model_name, digest: string;
    allowed: Boolean;
begin
    value := manifest.Find('external_files');
    if (value = nil) and (manifest.Get('storage', '') = '') then Exit;
    if (manifest.Get('storage', '') <> 'onnx-external-v1') or
        not (value is TJSONObject) then
        raise Exception.Create('Invalid external model manifest');
    files := TJSONObject(value);
    if (files.Count = 0) or (files.Count > Length(model_names)) then
        raise Exception.Create('Invalid external model file count');
    for index := 0 to files.Count - 1 do
    begin
        name := UTF8Decode(files.Names[index]);
        allowed := False;
        for model_name in model_names do
            if (Copy(name, 1, Length(model_name) + 1) = model_name + '.') and
                (Length(name) = Length(model_name) + 1 + 64 + Length('.weights')) and
                (Copy(name, Length(name) - Length('.weights') + 1, MaxInt) = '.weights') then
            begin
                digest := Copy(name, Length(model_name) + 2, 64);
                allowed := True;
                for pos := 1 to Length(digest) do
                    if not CharInSet(digest[pos], ['0'..'9', 'a'..'f']) then allowed := False;
                Break;
            end;
        if not allowed then raise Exception.Create('Invalid external model filename');
        hash := files.Items[index];
        if not (hash is TJSONString) then
            raise Exception.Create('Missing external model asset hash');
        if not model_file_matches_hash(IncludeTrailingPathDelimiter(folder) + name,
            UTF8Decode(hash.AsString)) then
            raise Exception.Create(UTF8Encode('External model asset hash mismatch: ' + name));
    end;
end;

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
