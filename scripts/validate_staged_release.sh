#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

release_root=''

usage() {
    printf 'Usage: scripts/validate_staged_release.sh --root DIR\n'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --root)
            [[ $# -ge 2 ]] || cassotis_die '--root requires a path'
            release_root="$2"
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown staged-release option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
cassotis_require_command ldd
cassotis_require_command realpath
cassotis_require_command sha256sum
[[ -n "$release_root" ]] || cassotis_die '--root is required'
release_root="$(realpath -m -- "$release_root")"
[[ -d "$release_root/usr" ]] ||
    cassotis_die "invalid staged release root: $release_root"

libexec="$release_root/usr/libexec/cassotis-ime"
data="$release_root/usr/share/cassotis-ime"
engine="$libexec/cassotis-engine"
control="$libexec/cassotis-control"
settings="$libexec/cassotis-settings"
ibus_adapter="$libexec/ibus-engine-cassotis"
fcitx_addon="$(find "$release_root/usr" -type f \
    -path '*/fcitx5/libcassotis.so' -print -quit)"
required_files=(
    "$engine"
    "$control"
    "$settings"
    "$ibus_adapter"
    "$libexec/cassotis-ibus-smoke"
    "$libexec/cassotis-fcitx5-smoke"
    "$fcitx_addon"
    "$data/dict_sc.db"
    "$data/release-manifest.txt"
    "$data/release-sha256.txt"
    "$release_root/usr/share/ibus/component/cassotis.xml"
    "$release_root/usr/share/fcitx5/addon/cassotis.conf"
    "$release_root/usr/share/fcitx5/inputmethod/cassotis.conf"
    "$release_root/usr/share/applications/org.cassotis.ime.Settings.desktop"
    "$release_root/usr/share/doc/cassotis-ime/README.md"
    "$release_root/usr/share/doc/cassotis-ime/README.CN.md"
    "$release_root/usr/share/doc/cassotis-ime/BUILD.md"
    "$release_root/usr/share/doc/cassotis-ime/RELEASE.md"
    "$release_root/usr/share/doc/cassotis-ime/COMPATIBILITY.md"
    "$release_root/usr/share/doc/cassotis-ime/BENCHMARK.md"
    "$release_root/usr/share/doc/cassotis-ime/CONFIGURATION.md"
    "$release_root/usr/share/doc/cassotis-ime/CONFIGURATION.CN.md"
    "$release_root/usr/share/doc/cassotis-ime/CHANGELOG.md"
    "$release_root/usr/share/doc/cassotis-ime/LICENSE"
    "$release_root/usr/share/doc/cassotis-ime/NOTICE.md"
    "$release_root/usr/share/doc/cassotis-ime/docs/DICTIONARY.md"
    "$release_root/usr/share/doc/cassotis-ime/docs/IPC.md"
    "$release_root/usr/share/doc/cassotis-ime/docs/LEXICON_ATTRIBUTION.md"
)
for path in "${required_files[@]}"; do
    [[ -n "$path" && -r "$path" ]] ||
        cassotis_die "required release file is missing: $path"
done

desktop_file="$release_root/usr/share/applications/org.cassotis.ime.Settings.desktop"
if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "$desktop_file"
fi
for path in "$engine" "$control" "$settings" "$ibus_adapter" \
            "$libexec/cassotis-ibus-smoke" \
            "$libexec/cassotis-fcitx5-smoke"; do
    cassotis_require_executable "$path"
done

if grep -R -n -E '@(EXECUTABLE|SETUP|VERSION|FCITX_VERSION|LIBRARY)@' \
        "$release_root"; then
    cassotis_die 'unexpanded release metadata placeholder found'
fi
(
    cd "$release_root"
    sha256sum --check "./usr/share/cassotis-ime/release-sha256.txt"
) >/dev/null

for binary in "$engine" "$control" "$ibus_adapter" \
              "$libexec/cassotis-ibus-smoke" \
              "$libexec/cassotis-fcitx5-smoke" "$fcitx_addon"; do
    dependencies="$(ldd "$binary" 2>&1 || true)"
    if grep -q 'not found' <<<"$dependencies"; then
        printf '%s\n' "$dependencies" >&2
        cassotis_die "unresolved shared library in $binary"
    fi
done

temporary_dir="$(mktemp -d)"
runtime_dir="$temporary_dir/runtime"
socket_path="$runtime_dir/cassotis-ime/engine.sock"
cleanup() {
    if [[ -S "$socket_path" ]]; then
        CASSOTIS_ENGINE_SOCKET="$socket_path" "$control" shutdown \
            >/dev/null 2>&1 || true
    fi
    rm -rf -- "$temporary_dir"
}
trap cleanup EXIT
mkdir -p "$runtime_dir"
chmod 0700 "$runtime_dir"

"$engine" --self-test
NO_AT_BRIDGE=1 "$settings" --check-ui
CASSOTIS_DICTIONARY="$data/dict_sc.db" \
CASSOTIS_USER_DICTIONARY="$temporary_dir/ibus-user.db" \
CASSOTIS_ENGINE_PATH="$engine" \
CASSOTIS_ENGINE_SOCKET="$socket_path" \
XDG_RUNTIME_DIR="$runtime_dir" \
    "$ibus_adapter" --self-test
CASSOTIS_DICTIONARY="$data/dict_sc.db" \
CASSOTIS_USER_DICTIONARY="$temporary_dir/control-user.db" \
CASSOTIS_ENGINE_PATH="$engine" \
CASSOTIS_ENGINE_SOCKET="$socket_path" \
XDG_RUNTIME_DIR="$runtime_dir" \
    "$control" get-state >/dev/null
CASSOTIS_ENGINE_SOCKET="$socket_path" "$control" shutdown >/dev/null

"$cassotis_root/scripts/verify_fcitx5.sh" \
    --dictionary "$data/dict_sc.db" --root "$release_root"

printf 'staged_release.root=%s\n' "$release_root"
printf 'staged_release.validation=passed\n'
