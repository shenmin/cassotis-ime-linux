#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

usage() {
    cat <<'EOF'
Usage: scripts/uninstall_fcitx5.sh

Removes the current user's Cassotis Fcitx 5 addon. Shared runtime files and
user data are retained when the IBus adapter is still installed.
EOF
}

if [[ $# -gt 0 ]]; then
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown uninstall option: $1"
            ;;
    esac
fi

cassotis_require_linux
cassotis_require_command python3
cassotis_require_command readlink
[[ $EUID -ne 0 ]] ||
    cassotis_die "run this uninstaller as the desktop user, not through sudo"

profile_tool="$cassotis_root/scripts/fcitx5_profile.py"
[[ -r "$profile_tool" ]] ||
    cassotis_die "Fcitx profile helper is not readable: $profile_tool"

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
data_dir="$data_home/cassotis-ime"
fcitx_data_dir="$data_home/fcitx5"
addon_metadata_dir="$fcitx_data_dir/addon"
input_method_dir="$fcitx_data_dir/inputmethod"
addon_metadata="$addon_metadata_dir/cassotis.conf"
input_method_metadata="$input_method_dir/cassotis.conf"
addon_dir="$HOME/.local/lib/fcitx5"
installed_addon="$addon_dir/libcassotis.so"
libexec_dir="$HOME/.local/libexec/cassotis-ime"
installed_engine="$libexec_dir/cassotis-engine"
installed_control="$libexec_dir/cassotis-control"
installed_smoke="$libexec_dir/cassotis-fcitx5-smoke"
installed_settings="$libexec_dir/cassotis-settings"
applications_dir="$data_home/applications"
desktop_file="$applications_dir/ibus-setup-cassotis.desktop"
legacy_desktop_file="$applications_dir/org.cassotis.ime.Settings.desktop"
icon_theme_dir="$data_home/icons/hicolor"
installed_icon="$icon_theme_dir/512x512/apps/cassotis-ime.png"
ibus_component="$data_home/ibus/component/cassotis.xml"
ibus_adapter="$libexec_dir/ibus-engine-cassotis"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
profile_file="$config_home/fcitx5/profile"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/${UID:-$(id -u)}}"
engine_socket="$runtime_dir/cassotis-ime/engine.sock"
fcitx_was_active=0

stop_installed_engine_by_path() {
    local executable_link
    local executable_path
    local process_id
    local attempt
    local any_running
    local -a process_ids=()

    for executable_link in /proc/[0-9]*/exe; do
        executable_path="$(readlink "$executable_link" 2>/dev/null || true)"
        if [[ "$executable_path" == "$installed_engine" ||
              "$executable_path" == "$installed_engine (deleted)" ]]; then
            process_id="${executable_link#/proc/}"
            process_id="${process_id%/exe}"
            process_ids+=("$process_id")
        fi
    done
    [[ ${#process_ids[@]} -gt 0 ]] || return 0
    kill -TERM "${process_ids[@]}" 2>/dev/null || true
    for ((attempt = 0; attempt < 40; attempt += 1)); do
        any_running=0
        for process_id in "${process_ids[@]}"; do
            if kill -0 "$process_id" 2>/dev/null; then
                any_running=1
                break
            fi
        done
        [[ $any_running -eq 0 ]] && return 0
        sleep 0.05
    done
    kill -KILL "${process_ids[@]}" 2>/dev/null || true
}

if cassotis_prepare_desktop_session_environment &&
   command -v fcitx5-remote >/dev/null 2>&1 &&
   fcitx5-remote --check >/dev/null 2>&1; then
    fcitx_was_active=1
    fcitx5-remote -e >/dev/null 2>&1 || true
    for ((attempt = 0; attempt < 50; attempt += 1)); do
        if ! fcitx5-remote --check >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done
fi

profile_status='profile does not exist'
if [[ -f "$profile_file" ]]; then
    profile_status="$(python3 "$profile_tool" remove "$profile_file")"
fi

rm -f -- "$installed_addon" "$addon_metadata" \
    "$input_method_metadata" "$installed_smoke"
rmdir -- "$addon_dir" "$addon_metadata_dir" "$input_method_dir" \
    2>/dev/null || true

shared_runtime='retained for the installed IBus adapter'
if [[ ! -f "$ibus_component" && ! -f "$ibus_adapter" ]]; then
    if [[ -S "$engine_socket" && -x "$installed_control" ]]; then
        CASSOTIS_ENGINE_SOCKET="$engine_socket" \
            "$installed_control" shutdown >/dev/null 2>&1 || true
        for ((attempt = 0; attempt < 40; attempt += 1)); do
            [[ ! -S "$engine_socket" ]] && break
            sleep 0.05
        done
    fi
    stop_installed_engine_by_path
    rm -f -- "$engine_socket" "$installed_engine" "$installed_control" \
        "$installed_settings" "$desktop_file" "$legacy_desktop_file" \
        "$installed_icon"
    rmdir -- "$libexec_dir" 2>/dev/null || true
    shared_runtime='removed; no IBus adapter is installed'
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir" >/dev/null 2>&1 || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q -t "$icon_theme_dir" >/dev/null 2>&1 || true
fi
if [[ $fcitx_was_active -eq 1 ]]; then
    fcitx5 -d >/dev/null 2>&1
fi

printf 'Removed the Cassotis user Fcitx 5 addon.\n'
printf 'Fcitx profile: %s\n' "$profile_status"
printf 'Shared runtime: %s\n' "$shared_runtime"
printf 'Dictionary and user data under %s were retained.\n' "$data_dir"
