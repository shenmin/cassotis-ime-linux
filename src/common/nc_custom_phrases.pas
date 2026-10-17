unit nc_custom_phrases;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses nc_types;

const
    c_custom_phrase_max_count = 1024;
    c_custom_phrase_max_shortcut = 32;
    c_custom_phrase_max_text = 4096;
    c_custom_phrase_max_json_bytes = 16 * 1024 * 1024 - 1024;

function nc_custom_phrase_key(const value: string): string;
function nc_custom_phrase_text_valid(const value: string): Boolean;
function nc_custom_phrases_equal(const left, right: TncCustomPhraseList): Boolean;
function nc_custom_phrases_to_json(const phrases: TncCustomPhraseList): string;
function nc_parse_custom_phrases(const value: string;
    out phrases: TncCustomPhraseList): Boolean;
function nc_custom_phrase_preview(const value: string): string;

implementation

uses SysUtils, fpjson, jsonparser, jsonscanner;

function nc_custom_phrase_key(const value: string): string;
var ch: Char;
begin
    Result := LowerCase(Trim(value));
    if (Length(Result) = 0) or (Length(Result) > c_custom_phrase_max_shortcut) then
        Exit('');
    for ch in Result do
        if (ch < 'a') or (ch > 'z') then Exit('');
end;

function nc_custom_phrase_text_valid(const value: string): Boolean;
var ch: Char;
begin
    Result := (Trim(value) <> '') and (Length(value) <= c_custom_phrase_max_text);
    if not Result then Exit;
    for ch in value do
        if (Ord(ch) < 32) and not (Ord(ch) in [9, 10, 13]) then Exit(False);
end;

function nc_custom_phrases_equal(const left, right: TncCustomPhraseList): Boolean;
var i: Integer;
begin
    Result := Length(left) = Length(right);
    if not Result then Exit;
    for i := 0 to High(left) do
        if (left[i].shortcut <> right[i].shortcut) or
            (left[i].text <> right[i].text) then Exit(False);
end;

function nc_custom_phrases_to_json(const phrases: TncCustomPhraseList): string;
var root, row: TJSONArray; phrase: TncCustomPhrase;
begin
    root := TJSONArray.Create;
    try
        for phrase in phrases do
        begin
            row := TJSONArray.Create;
            root.Add(row);
            row.Add(UTF8Encode(phrase.shortcut));
            row.Add(UTF8Encode(phrase.text));
        end;
        Result := UTF8Decode(root.AsJSON);
    finally
        root.Free;
    end;
end;

function normalize_json_unicode(const value: string; out normalized: string): Boolean;
var i, written, j, digit, code, low_code: Integer; ch: Char; quoted: Boolean;

    function read_hex(const start: Integer; out number: Integer): Boolean;
    var k: Integer; c: Char;
    begin
        number := 0;
        Result := start + 3 <= Length(value);
        if not Result then Exit;
        for k := start to start + 3 do
        begin
            c := value[k];
            case c of
                '0'..'9': digit := Ord(c) - Ord('0');
                'a'..'f': digit := Ord(c) - Ord('a') + 10;
                'A'..'F': digit := Ord(c) - Ord('A') + 10;
            else
                Exit(False);
            end;
            number := number * 16 + digit;
        end;
    end;

    procedure append(const c: Char);
    begin
        Inc(written);
        normalized[written] := c;
    end;

begin
    // FPC 3.2.2 uses a four-byte buffer for two consecutive Unicode escapes.
    // Decode printable escapes before it can truncate two three-byte characters.
    Result := False;
    SetLength(normalized, Length(value));
    written := 0;
    i := 1;
    quoted := False;
    while i <= Length(value) do
    begin
        ch := value[i];
        if quoted and (ch = '\') then
        begin
            if i = Length(value) then Exit;
            if value[i + 1] = 'u' then
            begin
                if not read_hex(i + 2, code) then Exit;
                if (code >= $D800) and (code <= $DBFF) then
                begin
                    if (i + 11 > Length(value)) or (value[i + 6] <> '\') or
                        (value[i + 7] <> 'u') then Exit;
                    if not read_hex(i + 8, low_code) or
                        (low_code < $DC00) or (low_code > $DFFF) then Exit;
                    append(Char(code));
                    append(Char(low_code));
                    Inc(i, 12);
                end
                else
                begin
                    if (code >= $DC00) and (code <= $DFFF) then Exit;
                    if (code < 32) or (code = Ord('"')) or (code = Ord('\')) then
                        for j := i to i + 5 do append(value[j])
                    else
                        append(Char(code));
                    Inc(i, 6);
                end;
            end
            else
            begin
                append(ch);
                append(value[i + 1]);
                Inc(i, 2);
            end;
        end
        else
        begin
            if ch = '"' then quoted := not quoted;
            append(ch);
            Inc(i);
        end;
    end;
    SetLength(normalized, written);
    Result := True;
end;

function nc_parse_custom_phrases(const value: string;
    out phrases: TncCustomPhraseList): Boolean;
var root, row: TJSONData; parsed: TncCustomPhraseList; i: Integer;
    parser: TJSONParser;
    ch: Char; depth: Integer; quoted, escaped: Boolean;
    normalized: string;
begin
    phrases := nil;
    Result := False;
    if Trim(value) = '' then Exit(True);
    if Length(UTF8Encode(value)) > c_custom_phrase_max_json_bytes then Exit;
    // Only two array levels are meaningful; bound parser recursion on imports.
    depth := 0;
    quoted := False;
    escaped := False;
    for ch in value do
    begin
        if quoted then
        begin
            if escaped then escaped := False
            else if ch = '\' then escaped := True
            else if ch = '"' then quoted := False;
        end
        else case ch of
            '"': quoted := True;
            '[': begin Inc(depth); if depth > 2 then Exit; end;
            ']': begin Dec(depth); if depth < 0 then Exit; end;
            '{', '}': Exit;
        end;
    end;
    if not normalize_json_unicode(value, normalized) then Exit;
    root := nil;
    try
        try
            parser := TJSONParser.Create(UTF8Encode(normalized), [joUTF8, joStrict]);
            try
                root := parser.Parse;
            finally
                parser.Free;
            end;
            if (root = nil) or (root.JSONType <> jtArray) or
                (root.Count > c_custom_phrase_max_count) then Exit;
            SetLength(parsed, root.Count);
            for i := 0 to root.Count - 1 do
            begin
                row := root.Items[i];
                if (row.JSONType <> jtArray) or (row.Count <> 2) then Exit;
                if (row.Items[0].JSONType <> jtString) or
                    (row.Items[1].JSONType <> jtString) then Exit;
                parsed[i].shortcut := nc_custom_phrase_key(row.Items[0].AsUnicodeString);
                parsed[i].text := row.Items[1].AsUnicodeString;
                if (parsed[i].shortcut = '') or
                    not nc_custom_phrase_text_valid(parsed[i].text) then Exit;
            end;
            phrases := parsed;
            Result := True;
        except
            on E: EJSONParser do Result := False;
            on E: EScannerError do Result := False;
        end;
    finally
        root.Free;
    end;
end;

function nc_custom_phrase_preview(const value: string): string;
var count: Integer;
begin
    count := Length(value);
    if count > 120 then count := 120;
    if (count > 0) and (Ord(value[count]) >= $D800) and
        (Ord(value[count]) <= $DBFF) then Dec(count);
    Result := Copy(value, 1, count);
    Result := StringReplace(Result, #9, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
    if count < Length(value) then Result := Result + '...';
end;

end.
