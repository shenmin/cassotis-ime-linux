unit nc_platform_compat;

{$codepage utf8}
{$mode delphiunicode}
{$H+}

interface

const
    VK_BACK = $08;
    VK_TAB = $09;
    VK_RETURN = $0D;
    VK_SHIFT = $10;
    VK_CONTROL = $11;
    VK_MENU = $12;
    VK_ESCAPE = $1B;
    VK_SPACE = $20;
    VK_PRIOR = $21;
    VK_NEXT = $22;
    VK_END = $23;
    VK_HOME = $24;
    VK_LEFT = $25;
    VK_UP = $26;
    VK_RIGHT = $27;
    VK_DOWN = $28;
    VK_INSERT = $2D;
    VK_DELETE = $2E;
    VK_NUMPAD0 = $60;
    VK_NUMPAD1 = $61;
    VK_NUMPAD2 = $62;
    VK_NUMPAD3 = $63;
    VK_NUMPAD4 = $64;
    VK_NUMPAD5 = $65;
    VK_NUMPAD6 = $66;
    VK_NUMPAD7 = $67;
    VK_NUMPAD8 = $68;
    VK_NUMPAD9 = $69;
    VK_MULTIPLY = $6A;
    VK_ADD = $6B;
    VK_SUBTRACT = $6D;
    VK_DECIMAL = $6E;
    VK_DIVIDE = $6F;
    VK_F1 = $70;
    VK_F10 = $79;
    VK_F24 = $87;
    VK_LWIN = $5B;
    VK_LSHIFT = $A0;
    VK_RSHIFT = $A1;
    VK_LCONTROL = $A2;
    VK_RCONTROL = $A3;
    VK_LMENU = $A4;
    VK_RMENU = $A5;
    VK_OEM_1 = $BA;
    VK_OEM_PLUS = $BB;
    VK_OEM_COMMA = $BC;
    VK_OEM_MINUS = $BD;
    VK_OEM_PERIOD = $BE;
    VK_OEM_2 = $BF;
    VK_OEM_3 = $C0;
    VK_OEM_4 = $DB;
    VK_OEM_5 = $DC;
    VK_OEM_6 = $DD;
    VK_OEM_7 = $DE;

function nc_monotonic_tick_ms: QWord;
function QueryPerformanceCounter(out value: Int64): Boolean;
function QueryPerformanceFrequency(out value: Int64): Boolean;
function nc_quantize_single(const value: Double): Double;
function nc_available_cpu_count: Integer;

implementation

uses
    SysUtils, Classes;

{$IFDEF LINUX}
function linux_online_cpu_count: LongInt; cdecl; external 'c' name 'get_nprocs';
function linux_get_affinity(pid: LongInt; mask_size: SizeUInt; mask: Pointer): LongInt;
    cdecl; external 'c' name 'sched_getaffinity';
{$ENDIF}

function nc_available_cpu_count: Integer;
{$IFDEF LINUX}
var
    mask: array[0..127] of Byte;
    affinity_count, i: Integer;
    bits: Byte;
{$ENDIF}
begin
{$IFDEF LINUX}
    // FPC 3.2.2 reports one CPU on Unix; query the OS and honor task affinity.
    Result := linux_online_cpu_count;
    FillChar(mask, SizeOf(mask), 0);
    if linux_get_affinity(0, SizeOf(mask), @mask[0]) = 0 then
    begin
        affinity_count := 0;
        for i := Low(mask) to High(mask) do
        begin
            bits := mask[i];
            while bits <> 0 do
            begin
                Inc(affinity_count);
                bits := bits and (bits - 1);
            end;
        end;
        if (affinity_count > 0) and
            ((Result < 1) or (affinity_count < Result)) then
            Result := affinity_count;
    end;
{$ELSE}
    Result := TThread.ProcessorCount;
{$ENDIF}
    if Result < 1 then Result := 1;
end;

function nc_monotonic_tick_ms: QWord;
begin
    Result := SysUtils.GetTickCount64;
end;

function QueryPerformanceCounter(out value: Int64): Boolean;
begin
    value := Int64(SysUtils.GetTickCount64);
    Result := True;
end;

function QueryPerformanceFrequency(out value: Int64): Boolean;
begin
    value := 1000;
    Result := True;
end;

function nc_quantize_single(const value: Double): Double;
var
    quantized: Single;
begin
    quantized := value;
    Result := quantized;
end;

end.
