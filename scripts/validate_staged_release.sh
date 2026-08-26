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
cassotis_require_command python3
cassotis_require_command realpath
cassotis_require_command sha256sum
[[ -n "$release_root" ]] || cassotis_die '--root is required'
release_root="$(realpath -m -- "$release_root")"
[[ -d "$release_root/usr" ]] ||
    cassotis_die "invalid staged release root: $release_root"

libexec="$release_root/usr/libexec/cassotis-ime"
data="$release_root/usr/share/cassotis-ime"
icon="$release_root/usr/share/icons/hicolor/512x512/apps/cassotis-ime.png"
engine="$libexec/cassotis-engine"
control="$libexec/cassotis-control"
settings="$libexec/cassotis-settings"
session_refresh="$libexec/cassotis-refresh-sessions"
ibus_adapter="$libexec/ibus-engine-cassotis"
fcitx_addon="$(find "$release_root/usr" -type f \
    -path '*/fcitx5/libcassotis.so' -print -quit)"
required_files=(
    "$engine"
    "$control"
    "$settings"
    "$session_refresh"
    "$ibus_adapter"
    "$libexec/cassotis-ibus-smoke"
    "$libexec/cassotis-fcitx5-smoke"
    "$fcitx_addon"
    "$icon"
    "$data/dict_sc.db"
    "$data/release-manifest.txt"
    "$data/release-sha256.txt"
    "$release_root/usr/share/ibus/component/cassotis.xml"
    "$release_root/usr/share/fcitx5/addon/cassotis.conf"
    "$release_root/usr/share/fcitx5/inputmethod/cassotis.conf"
    "$release_root/usr/share/applications/ibus-setup-cassotis.desktop"
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

ibus_component="$release_root/usr/share/ibus/component/cassotis.xml"
installed_ibus_adapter="${ibus_adapter#"$release_root"}"
installed_settings="${settings#"$release_root"}"
python3 - "$ibus_component" "$installed_ibus_adapter" \
    "$installed_settings" <<'PY'
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

component_path = Path(sys.argv[1])
expected_executable = sys.argv[2]
expected_setup = sys.argv[3]
component = ET.parse(component_path).getroot()
engine = component.find("./engines/engine")
if engine is None:
    raise SystemExit("IBus component does not contain an engine")

expected_values = {
    "name": "cassotis",
    "longname": "Cassotis 言泉拼音输入法",
    "language": "zh_CN",
    "icon": "cassotis-ime",
    "setup": expected_setup,
}
for tag, expected in expected_values.items():
    actual = engine.findtext(tag)
    if actual != expected:
        raise SystemExit(
            f"unexpected IBus {tag}: expected {expected!r}, got {actual!r}"
        )

component_exec = component.findtext("exec")
if component_exec != f"{expected_executable} --ibus":
    raise SystemExit(
        "unexpected IBus executable: "
        f"expected {expected_executable!r} with --ibus, got {component_exec!r}"
    )

try:
    rank = int(engine.findtext("rank", "0"))
except ValueError as error:
    raise SystemExit("IBus engine rank is not an integer") from error
if rank <= 0:
    raise SystemExit("IBus engine rank must be positive for desktop discovery")
PY

desktop_file="$release_root/usr/share/applications/ibus-setup-cassotis.desktop"
legacy_desktop_file="$release_root/usr/share/applications/org.cassotis.ime.Settings.desktop"
if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "$desktop_file"
fi
grep -Fqx "Exec=$installed_settings" "$desktop_file" ||
    cassotis_die 'GNOME IBus settings launcher has an invalid Exec entry'
grep -Fqx 'Icon=cassotis-ime' "$desktop_file" ||
    cassotis_die 'GNOME IBus settings launcher has an invalid Icon entry'
[[ ! -e "$legacy_desktop_file" ]] ||
    cassotis_die 'legacy settings launcher name must not be shipped'
fcitx_input_method="$release_root/usr/share/fcitx5/inputmethod/cassotis.conf"
grep -Fqx 'Icon=cassotis-ime' "$fcitx_input_method" ||
    cassotis_die 'Fcitx input-method metadata has an invalid Icon entry'
python3 - "$icon" <<'PY'
from pathlib import Path
import struct
import sys

icon_path = Path(sys.argv[1])
data = icon_path.read_bytes()
if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n":
    raise SystemExit(f"application icon is not a PNG: {icon_path}")
if data[12:16] != b"IHDR":
    raise SystemExit(f"application icon has no PNG IHDR: {icon_path}")
width, height = struct.unpack(">II", data[16:24])
if (width, height) != (512, 512):
    raise SystemExit(
        f"unexpected application icon size: expected 512x512, got {width}x{height}"
    )
PY
for path in "$engine" "$control" "$settings" "$session_refresh" \
            "$ibus_adapter" \
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

if command -v ibus >/dev/null 2>&1; then
    registry_cache="$temporary_dir/ibus-registry"
    IBUS_COMPONENT_PATH="$(dirname "$ibus_component")" \
        ibus write-cache --file "$registry_cache"
    registry_output="$(ibus read-cache --file "$registry_cache")"
    grep -q '<name>org.freedesktop.IBus.Cassotis</name>' \
        <<<"$registry_output" ||
        cassotis_die 'IBus registry did not discover the Cassotis component'
    grep -q '<name>cassotis</name>' <<<"$registry_output" ||
        cassotis_die 'IBus registry did not discover the Cassotis engine'
fi

"$engine" --self-test
NO_AT_BRIDGE=1 "$settings" --check-ui
CASSOTIS_USER_DICTIONARY="$temporary_dir/ibus-user.db" \
CASSOTIS_ENGINE_PATH="$engine" \
CASSOTIS_ENGINE_SOCKET="$socket_path" \
XDG_RUNTIME_DIR="$runtime_dir" \
    "$ibus_adapter" --self-test
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
