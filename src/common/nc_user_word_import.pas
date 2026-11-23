unit nc_user_word_import;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses SysUtils, Math, nc_types;

type
    TncUserWordImportEntry = record
        pinyin, text: string;
        count: Integer;
    end;
    TncUserWordImportEntries = TArray<TncUserWordImportEntry>;

function nc_parse_user_word_import(const content: string;
    out entries: TncUserWordImportEntries; out skipped: Integer): Boolean;
function nc_read_user_word_import_file(const path: string; out content: string): Boolean;
function nc_format_user_word_line(const entry: TncUserWordImportEntry; out line: string): Boolean;
function nc_write_user_word_export_file(const path: string; const entries: TncUserWordImportEntries;
    out written: Integer): Boolean;

implementation

uses Classes, nc_platform_compat {$ifdef UNIX}, BaseUnix{$endif};

const
    c_dash = #$2014;
    c_times = #$6B21;
    c_fullwidth_comma = #$FF0C;

function normalize_pinyin(const value: string; out pinyin: string): Boolean;
var ch: Char;
begin
    pinyin := '';
    for ch in LowerCase(Trim(value)) do
        if CharInSet(ch, ['a'..'z', '''']) then pinyin := pinyin + ch
        else if ch <> ' ' then Exit(False);
    while (pinyin <> '') and (pinyin[1] = '''') do Delete(pinyin, 1, 1);
    while (pinyin <> '') and (pinyin[Length(pinyin)] = '''') do
        Delete(pinyin, Length(pinyin), 1);
    Result := pinyin <> '';
end;

function parse_count(const value: string; out count: Integer): Boolean;
var digits: string;
begin
    digits := Trim(value);
    if (digits <> '') and (digits[Length(digits)] = c_times) then
        digits := Trim(Copy(digits, 1, Length(digits) - 1));
    Result := TryStrToInt(UTF8Encode(digits), count) and (count > 0);
end;

function has_latin_letter(const value: string): Boolean;
var ch: Char;
begin
    for ch in value do
        if CharInSet(ch, ['a'..'z', 'A'..'Z']) then Exit(True);
    Result := False;
end;

function strip_ordinal(const value: string): string;
var idx: Integer;
begin
    Result := Trim(value);
    idx := 1;
    while (idx <= Length(Result)) and CharInSet(Result[idx], ['0'..'9']) do Inc(idx);
    if (idx > 1) and (idx <= Length(Result)) and (Result[idx] = '.') then
        Result := Trim(Copy(Result, idx + 1, MaxInt));
end;

function parse_dashed(const line: string; out entry: TncUserWordImportEntry): Boolean;
var parts: TArray<string>;
begin
    Result := False;
    parts := line.Split([c_dash]);
    if Length(parts) <> 3 then Exit;
    entry.text := strip_ordinal(parts[0]);
    Result := (entry.text <> '') and (not has_latin_letter(entry.text)) and
        parse_count(parts[1], entry.count) and normalize_pinyin(parts[2], entry.pinyin);
end;

function parse_separated(const line: string; const separators: array of Char;
    out entry: TncUserWordImportEntry): Boolean;
var item, field, pinyin: string; count: Integer;
begin
    Result := False;
    entry := Default(TncUserWordImportEntry);
    for item in line.Split(separators) do
    begin
        field := Trim(item);
        if (Length(field) >= 2) and (field[1] = '"') and (field[Length(field)] = '"') then
            field := Trim(Copy(field, 2, Length(field) - 2));
        if field = '' then Continue;
        if (entry.count = 0) and parse_count(field, count) then entry.count := count
        else if (entry.pinyin = '') and has_latin_letter(field) and
            normalize_pinyin(field, pinyin) then entry.pinyin := pinyin
        else if (entry.text = '') and not has_latin_letter(field) then entry.text := field
        else Exit;
    end;
    if entry.count = 0 then entry.count := 1;
    Result := (entry.text <> '') and (entry.pinyin <> '');
end;

function nc_parse_user_word_import(const content: string;
    out entries: TncUserWordImportEntries; out skipped: Integer): Boolean;
var line, trimmed, normalized: string; entry: TncUserWordImportEntry; count: Integer; parsed: Boolean;
begin
    entries := nil;
    skipped := 0;
    count := 0;
    normalized := StringReplace(content, #13#10, #10, [rfReplaceAll]);
    normalized := StringReplace(normalized, #13, #10, [rfReplaceAll]);
    for line in normalized.Split([#10]) do
    begin
        trimmed := Trim(line);
        if (trimmed <> '') and (trimmed[1] = #$FEFF) then
            trimmed := Trim(Copy(trimmed, 2, MaxInt));
        if (trimmed = '') or (trimmed[1] = '#') then Continue;
        parsed := ((Pos(c_dash, trimmed) > 0) and parse_dashed(trimmed, entry)) or
            ((Pos(#9, trimmed) > 0) and parse_separated(trimmed, [#9], entry)) or
            ((Pos(#9, trimmed) = 0) and
            ((Pos(',', trimmed) > 0) or (Pos(c_fullwidth_comma, trimmed) > 0)) and
            parse_separated(trimmed, [',', c_fullwidth_comma], entry));
        if not parsed then
        begin
            Inc(skipped);
            Continue;
        end;
        if count = Length(entries) then SetLength(entries, Max(64, count * 2));
        entries[count] := entry;
        Inc(count);
    end;
    SetLength(entries, count);
    Result := count > 0;
end;

function nc_read_user_word_import_file(const path: string; out content: string): Boolean;
var
    stream: TFileStream;
    bytes, roundtrip: TBytes;
    encoding: TEncoding;
    offset: Integer;
    {$ifdef UNIX}info: Stat;{$endif}
begin
    Result := False;
    content := '';
    if (path = '') or (Pos(#0, path) > 0) then Exit;
    {$ifdef UNIX}
    // Never block the shared engine on a pipe or device supplied as a file.
    if (fpStat(UTF8Encode(path), info) <> 0) or not FPS_ISREG(info.st_mode) then Exit;
    {$endif}
    try
        stream := TFileStream.Create(UTF8Encode(path), fmOpenRead or fmShareDenyNone);
        try
            if (stream.Size <= 0) or (stream.Size > 16 * 1024 * 1024) then Exit;
            SetLength(bytes, stream.Size);
            stream.ReadBuffer(bytes[0], Length(bytes));
        finally
            stream.Free;
        end;
        encoding := nil;
        offset := TEncoding.GetBufferEncoding(bytes, encoding);
        if offset > 0 then
            content := encoding.GetString(bytes, offset, Length(bytes) - offset)
        else
        begin
            content := TEncoding.UTF8.GetString(bytes);
            roundtrip := TEncoding.UTF8.GetBytes(content);
            if (Length(roundtrip) <> Length(bytes)) or
                not CompareMem(@roundtrip[0], @bytes[0], Length(bytes)) then
            begin
                // Linux's locale is usually UTF-8, not the Windows export's GBK.
                encoding := TEncoding.GetEncoding(936);
                try
                    content := encoding.GetString(bytes);
                    roundtrip := encoding.GetBytes(content);
                    if (Length(roundtrip) <> Length(bytes)) or
                        not CompareMem(@roundtrip[0], @bytes[0], Length(bytes)) then Exit;
                finally
                    encoding.Free;
                end;
            end;
        end;
        Result := Pos(#0, content) = 0;
    except
        content := '';
    end;
end;

function nc_format_user_word_line(const entry: TncUserWordImportEntry; out line: string): Boolean;
var parsed: TncUserWordImportEntries; skipped: Integer;
begin
    line := '';
    if (entry.text = '') or (entry.pinyin = '') or (entry.count <= 0) then Exit(False);
    line := entry.text + ',' + entry.pinyin + ',' + IntToStr(entry.count);
    Result := nc_parse_user_word_import(line, parsed, skipped) and (Length(parsed) = 1) and
        (parsed[0].text = entry.text) and (parsed[0].pinyin = entry.pinyin) and
        (parsed[0].count = entry.count);
    if not Result then line := '';
end;

function nc_write_user_word_export_file(const path: string; const entries: TncUserWordImportEntries;
    out written: Integer): Boolean;
var
    dest, temp: UTF8String;
    guid: TGUID;
    entry: TncUserWordImportEntry;
    line, extension: string;
    stream: THandleStream;
    fd: THandle;
    count: Integer;
    {$ifdef UNIX}info: Stat;{$endif}
    procedure emit(const data: RawByteString);
    begin
        if stream.Position + Length(data) > 16 * 1024 * 1024 then
            raise EStreamError.Create('Export exceeds import size limit');
        if data <> '' then stream.WriteBuffer(data[1], Length(data));
    end;
begin
    Result := False;
    written := 0;
    if (path = '') or (Pos(#0, path) <> 0) or (CreateGUID(guid) <> 0) then Exit;
    extension := LowerCase(ExtractFileExt(path));
    if (extension <> '.csv') and (extension <> '.tsv') and (extension <> '.txt') then Exit;
    dest := UTF8Encode(path);
    {$ifdef UNIX}
    if (fpLStat(dest, info) = 0) and not FPS_ISREG(info.st_mode) then Exit;
    {$endif}
    temp := ExtractFilePath(dest) + '.cassotis-words-' + UTF8Encode(GUIDToString(guid));
    {$ifdef UNIX}
    fd := fpOpen(temp, O_WRONLY or O_CREAT or O_EXCL, &600);
    {$else}
    fd := FileCreate(temp);
    {$endif}
    if fd = THandle(-1) then Exit;
    try
        try
            stream := THandleStream.Create(fd);
            try
                emit(UTF8Encode(UnicodeString(#$FEFF)));
                emit(UTF8Encode('# Cassotis IME user words, ' + FormatDateTime('yyyy-mm-dd hh:nn', Now) +
                    ': text,pinyin,count' + #13#10));
                count := 0;
                for entry in entries do
                    if nc_format_user_word_line(entry, line) then
                    begin
                        emit(UTF8Encode(line + #13#10));
                        Inc(count);
                    end;
            finally
                stream.Free;
            end;
        finally
            FileClose(fd);
        end;
        Result := RenameFile(temp, dest);
        if Result then written := count;
    except
        Result := False;
    end;
    if not Result then DeleteFile(temp);
end;

end.
