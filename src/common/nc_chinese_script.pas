unit nc_chinese_script;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

uses nc_types;

function nc_convert_chinese_script(const text: string;
    const variant: TncDictionaryVariant): string;

implementation

uses SysUtils, Dynlibs, SyncObjs;

type
    TOpen = function(config: PAnsiChar): Pointer; cdecl;
    TClose = function(handle: Pointer): Integer; cdecl;
    TConvert = function(handle: Pointer; text: PAnsiChar;
        length: SizeUInt): PAnsiChar; cdecl;
    TRelease = procedure(text: PAnsiChar); cdecl;

var
    g_lock: TCriticalSection;
    g_library: TLibHandle;
    g_attempted: Boolean;
    g_handles: array[TncDictionaryVariant] of Pointer;
    g_open: TOpen;
    g_close: TClose;
    g_convert: TConvert;
    g_release: TRelease;

procedure initialize_converter;
const
    libraries: array[0..2] of AnsiString =
        ('libopencc.so.1.1', 'libopencc.so.2', 'libopencc.so.1');
var
    name: AnsiString;
begin
    if g_attempted then Exit;
    g_attempted := True;
    for name in libraries do
    begin
        g_library := LoadLibrary(name);
        if g_library <> NilHandle then Break;
    end;
    if g_library = NilHandle then Exit;
    g_open := TOpen(GetProcAddress(g_library, 'opencc_open'));
    g_close := TClose(GetProcAddress(g_library, 'opencc_close'));
    g_convert := TConvert(GetProcAddress(g_library, 'opencc_convert_utf8'));
    g_release := TRelease(GetProcAddress(g_library, 'opencc_convert_utf8_free'));
    if not Assigned(g_open) or not Assigned(g_close) or
        not Assigned(g_convert) or not Assigned(g_release) then Exit;
    g_handles[dv_simplified] := g_open('t2s.json');
    g_handles[dv_traditional] := g_open('s2t.json');
end;

function nc_convert_chinese_script(const text: string;
    const variant: TncDictionaryVariant): string;
var
    input: UTF8String;
    output: PAnsiChar;
    handle: Pointer;
begin
    Result := text;
    if text = '' then Exit;
    g_lock.Acquire;
    try
        initialize_converter;
        handle := g_handles[variant];
        // An unavailable converter must never invalidate or rewrite user data.
        if (handle = nil) or (handle = Pointer(PtrUInt(-1))) then Exit;
        input := UTF8Encode(text);
        output := g_convert(handle, PAnsiChar(input), Length(input));
        if output = nil then Exit;
        try
            Result := UTF8Decode(UTF8String(output));
        finally
            g_release(output);
        end;
    finally
        g_lock.Release;
    end;
end;

procedure close_converter;
var
    handle: Pointer;
begin
    for handle in g_handles do
        if (handle <> nil) and (handle <> Pointer(PtrUInt(-1))) and
            Assigned(g_close) then g_close(handle);
    if g_library <> NilHandle then UnloadLibrary(g_library);
    g_lock.Free;
end;

initialization
    g_lock := TCriticalSection.Create;
finalization
    close_converter;
end.
