unit nc_memory_allocator;

{$mode delphiunicode}
{$H+}

interface

implementation

{$IFDEF LINUX}
const
    M_MMAP_THRESHOLD = -3;
    M_ARENA_MAX = -8;

function libc_mallopt(const parameter, value: LongInt): LongInt; cdecl;
    external 'c' name 'mallopt';
function libc_getenv(const name: PAnsiChar): PAnsiChar; cdecl;
    external 'c' name 'getenv';

procedure configure_heap;
begin
    // Run before worker creation. Bound per-thread heap fragmentation and keep
    // large inference scratch buffers individually releasable after use.
    // Explicit administrator allocator tuning takes precedence.
    if libc_getenv('GLIBC_TUNABLES') <> nil then Exit;
    if libc_getenv('MALLOC_ARENA_MAX') = nil then
        libc_mallopt(M_ARENA_MAX, 2);
    if libc_getenv('MALLOC_MMAP_THRESHOLD_') = nil then
        libc_mallopt(M_MMAP_THRESHOLD, 128 * 1024);
end;

initialization
    configure_heap;
{$ENDIF}

end.
