#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
component_file="$data_home/ibus/component/cassotis.xml"
smoke_binary="$HOME/.local/libexec/cassotis-ime/cassotis-ibus-smoke"
settings_binary="$HOME/.local/libexec/cassotis-ime/cassotis-settings"
desktop_file="$data_home/applications/ibus-setup-cassotis.desktop"
icon_file="$data_home/icons/hicolor/512x512/apps/cassotis-ime.png"
control_binary=''

usage() {
    cat <<'EOF'
Usage: scripts/verify_ibus.sh [--binary PATH] [--component PATH]
                              [--settings PATH] [--desktop PATH]
                              [--icon PATH]

Checks the installed static component and runs an isolated input context
through the active desktop IBus daemon. The test does not commit into an
application or select a learned candidate.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --binary)
            [[ $# -ge 2 ]] || cassotis_die "--binary requires a path"
            smoke_binary="$2"
            shift
            ;;
        --component)
            [[ $# -ge 2 ]] || cassotis_die "--component requires a path"
            component_file="$2"
            shift
            ;;
        --settings)
            [[ $# -ge 2 ]] || cassotis_die "--settings requires a path"
            settings_binary="$2"
            shift
            ;;
        --desktop)
            [[ $# -ge 2 ]] || cassotis_die "--desktop requires a path"
            desktop_file="$2"
            shift
            ;;
        --icon)
            [[ $# -ge 2 ]] || cassotis_die "--icon requires a path"
            icon_file="$2"
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown verification option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
cassotis_require_executable "$smoke_binary"
cassotis_require_executable "$settings_binary"
control_binary="$(dirname "$smoke_binary")/cassotis-control"
cassotis_require_executable "$control_binary"
[[ -r "$component_file" ]] ||
    cassotis_die "IBus component is not readable: $component_file"
[[ -r "$icon_file" ]] ||
    cassotis_die "Cassotis application icon is not readable: $icon_file"
grep -q '<name>cassotis</name>' "$component_file" ||
    cassotis_die "IBus component does not declare the cassotis engine"
grep -q '<icon>cassotis-ime</icon>' "$component_file" ||
    cassotis_die "IBus component does not use the Cassotis application icon"
grep -q "<setup>$settings_binary</setup>" "$component_file" ||
    cassotis_die "IBus component does not declare the installed settings entry"
[[ "$(basename -- "$desktop_file")" == 'ibus-setup-cassotis.desktop' ]] ||
    cassotis_die "GNOME requires the settings launcher name ibus-setup-cassotis.desktop"
[[ -r "$desktop_file" ]] ||
    cassotis_die "IBus settings launcher is not readable: $desktop_file"
grep -Fqx "Exec=$settings_binary" "$desktop_file" ||
    cassotis_die "IBus settings launcher does not execute the installed settings program"
grep -Fqx 'Icon=cassotis-ime' "$desktop_file" ||
    cassotis_die "IBus settings launcher does not use the Cassotis application icon"
cassotis_prepare_ibus_environment ||
    cassotis_die "no active desktop IBus daemon was found"

restore_gnome_sources=0
restore_engine_state=0
original_engine_state=()
cleanup() {
    local status=$?

    if [[ $restore_engine_state -eq 1 ]]; then
        if [[ $status -ne 0 ]]; then
            printf 'Cassotis state at validation failure:\n' >&2
            "$control_binary" get-state >&2 || true
        fi
        if ! "$control_binary" set-state "${original_engine_state[@]}" \
            >/dev/null; then
            printf 'Error: could not restore Cassotis engine state\n' >&2
            [[ $status -ne 0 ]] || status=1
        fi
    fi
    if [[ $restore_gnome_sources -eq 1 ]]; then
        if ! cassotis_gnome_input_sources_restore; then
            printf 'Error: could not restore GNOME input sources\n' >&2
            [[ $status -ne 0 ]] || status=1
        fi
    fi
    trap - EXIT
    exit "$status"
}
trap cleanup EXIT

cassotis_prepare_desktop_session_environment || true
if [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]]; then
    cassotis_gnome_input_sources_capture ||
        cassotis_die "could not snapshot GNOME input sources"
    restore_gnome_sources=1
    cassotis_gnome_input_source_add ibus cassotis ||
        cassotis_die "could not stage the Cassotis GNOME input source"
    cassotis_gnome_input_source_select ibus cassotis ||
        cassotis_die "could not select Cassotis for IBus verification"
    # GNOME publishes the IBus bus address before the selected engine has
    # completed focus and property restoration. Let that asynchronous startup
    # settle before imposing a temporary deterministic Cassotis state.
    sleep 1
fi

NO_AT_BRIDGE=1 "$settings_binary" --check
mapfile -t original_engine_state < <(
    "$control_binary" get-state | sed -n 's/^[^=]*=//p'
)
[[ ${#original_engine_state[@]} -eq 21 ]] ||
    cassotis_die "could not capture the complete Cassotis engine state"
restore_engine_state=1
"$control_binary" set-state \
    0 0 0 0 0 0 1 0 0 9 0 \
    16 0 190 2 84 3 32 1 121 3 >/dev/null
"$smoke_binary"
"$control_binary" set-state \
    0 0 0 0 0 0 1 0 0 9 1 \
    16 0 190 2 84 3 32 1 121 3 >/dev/null
"$smoke_binary" --debug-weight
"$control_binary" set-state "${original_engine_state[@]}" >/dev/null
restore_engine_state=0
if [[ $restore_gnome_sources -eq 1 ]]; then
    cassotis_gnome_input_sources_restore ||
        cassotis_die "could not restore GNOME input sources"
    restore_gnome_sources=0
fi
printf 'settings_entry=ok\n'
printf 'component=%s\n' "$component_file"
printf 'desktop_ibus_smoke=ok\n'
