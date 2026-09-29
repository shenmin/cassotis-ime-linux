unit nc_idle_memory;

{$mode delphiunicode}
{$H+}

interface

const
    c_idle_memory_delay_ms = 5000;

type
    TncIdleMemory = record
    private
        FPending: Boolean;
        FLastActivity: QWord;
    public
        procedure NoteActivity(const now_ms: QWord);
        function DelayMs(const now_ms: QWord): LongInt;
        function TakeDue(const now_ms: QWord): Boolean;
    end;

procedure nc_release_unused_heap_pages;

implementation

{$IFDEF LINUX}
function libc_malloc_trim(const padding: SizeUInt): LongInt; cdecl;
    external 'c' name 'malloc_trim';
{$ENDIF}

procedure TncIdleMemory.NoteActivity(const now_ms: QWord);
begin
    FLastActivity := now_ms;
    FPending := True;
end;

function TncIdleMemory.DelayMs(const now_ms: QWord): LongInt;
var
    elapsed: QWord;
begin
    if not FPending then
        Exit(-1);
    if now_ms < FLastActivity then
        Exit(c_idle_memory_delay_ms);
    elapsed := now_ms - FLastActivity;
    if elapsed >= c_idle_memory_delay_ms then
        Exit(0);
    Result := c_idle_memory_delay_ms - LongInt(elapsed);
end;

function TncIdleMemory.TakeDue(const now_ms: QWord): Boolean;
begin
    Result := DelayMs(now_ms) = 0;
    if Result then
        FPending := False;
end;

procedure nc_release_unused_heap_pages;
begin
{$IFDEF LINUX}
    // Only free allocator pages are returned. Live models and cached data stay
    // allocated; this is not working-set eviction or a model reload policy.
    libc_malloc_trim(0);
{$ENDIF}
end;

end.
