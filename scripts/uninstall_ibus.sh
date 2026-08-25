#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

usage() {
    cat <<'EOF'
Usage: scripts/uninstall_ibus.sh

Removes the current user's Cassotis IBus component. Shared runtime files and
user data are retained when the Fcitx 5 adapter is still installed.
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
cassotis_require_command readlink
[[ $EUID -ne 0 ]] ||
    cassotis_die "run this uninstaller as the desktop user, not through sudo"

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
data_dir="$data_home/cassotis-ime"
component_dir="$data_home/ibus/component"
component_file="$component_dir/cassotis.xml"
libexec_dir="$HOME/.local/libexec/cassotis-ime"
applications_dir="$data_home/applications"
desktop_file="$applications_dir/org.cassotis.ime.Settings.desktop"
adapter_path="$libexec_dir/ibus-engine-cassotis"
installed_engine_path="$libexec_dir/cassotis-engine"
installed_control_path="$libexec_dir/cassotis-control"
installed_settings_path="$libexec_dir/cassotis-settings"
installed_smoke_path="$libexec_dir/cassotis-ibus-smoke"
fcitx_addon_metadata="$data_home/fcitx5/addon/cassotis.conf"
fcitx_addon="$HOME/.local/lib/fcitx5/libcassotis.so"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
environment_file="$config_dir/environment.d/80-cassotis-ibus.conf"
systemd_dir="$config_dir/systemd/user"
ibus_dropin_dir="$systemd_dir/org.freedesktop.IBus.session.GNOME.service.d"
ibus_dropin_file="$ibus_dropin_dir/80-cassotis-component-path.conf"
legacy_service_file="$systemd_dir/cassotis-ibus.service"
legacy_autostart_file="$config_dir/autostart/cassotis-ibus.desktop"
system_component_dir="$(cassotis_ibus_system_component_dir)"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/${UID:-$(id -u)}}"
engine_socket="$runtime_dir/cassotis-ime/engine.sock"
gnome_ibus_was_active=0
ibus_service_stopped=0
ibus_restart_expected=0

cleanup() {
    local status=$?
    local attempt

    if [[ $status -ne 0 && $ibus_service_stopped -eq 1 ]]; then
        systemctl --user start org.freedesktop.IBus.session.GNOME.service \
            >/dev/null 2>&1 || true
        unset IBUS_ADDRESS
        for ((attempt = 0; attempt < 50; attempt += 1)); do
            if cassotis_prepare_ibus_environment; then
                break
            fi
            sleep 0.1
        done
        cassotis_gnome_input_sources_restore >/dev/null 2>&1 || true
    fi
    trap - EXIT
    exit "$status"
}
trap cleanup EXIT

stop_installed_engine_by_path() {
    local executable_link
    local executable_path
    local process_id
    local attempt
    local any_running
    local -a process_ids=()

    for executable_link in /proc/[0-9]*/exe; do
        executable_path="$(readlink "$executable_link" 2>/dev/null || true)"
        if [[ "$executable_path" == "$installed_engine_path" ||
              "$executable_path" == "$installed_engine_path (deleted)" ]]; then
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

cassotis_gnome_input_sources_capture || true
if command -v systemctl >/dev/null 2>&1 &&
   systemctl --user is-active --quiet org.freedesktop.IBus.session.GNOME.service; then
    [[ "${CASSOTIS_GNOME_INPUT_SOURCES_CAPTURED:-0}" == 1 ]] ||
        cassotis_die "could not snapshot GNOME input sources"
    gnome_ibus_was_active=1
    systemctl --user stop org.freedesktop.IBus.session.GNOME.service
    ibus_service_stopped=1
fi

fcitx_installed=0
if [[ -f "$fcitx_addon_metadata" || -f "$fcitx_addon" ]]; then
    fcitx_installed=1
fi

if [[ $fcitx_installed -eq 0 && -S "$engine_socket" &&
      -x "$adapter_path" ]]; then
    XDG_RUNTIME_DIR="$runtime_dir" "$adapter_path" --shutdown-engine \
        >/dev/null 2>&1 || true
    for ((attempt = 0; attempt < 40; attempt += 1)); do
        [[ ! -S "$engine_socket" ]] && break
        sleep 0.05
    done
fi
if [[ $fcitx_installed -eq 0 ]]; then
    stop_installed_engine_by_path
    rm -f -- "$engine_socket"
fi

if command -v systemctl >/dev/null 2>&1 &&
   systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user disable --now cassotis-ibus.service >/dev/null 2>&1 || true
fi

rm -f -- "$component_file" "$environment_file" "$ibus_dropin_file" \
    "$legacy_service_file" "$legacy_autostart_file" "$adapter_path" \
    "$installed_smoke_path"
shared_runtime='retained for the installed Fcitx 5 addon'
if [[ $fcitx_installed -eq 0 ]]; then
    rm -f -- "$desktop_file" "$installed_engine_path" \
        "$installed_control_path" "$installed_settings_path"
    rmdir -- "$libexec_dir" 2>/dev/null || true
    shared_runtime='removed; no Fcitx 5 addon is installed'
fi
rmdir -- "$component_dir" "$ibus_dropin_dir" 2>/dev/null || true

if command -v systemctl >/dev/null 2>&1 &&
   systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user daemon-reload
fi

if command -v ibus >/dev/null 2>&1; then
    IBUS_COMPONENT_PATH="$system_component_dir" ibus write-cache >/dev/null 2>&1
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir" >/dev/null 2>&1 || true
fi
if [[ $gnome_ibus_was_active -eq 1 ]]; then
    systemctl --user start org.freedesktop.IBus.session.GNOME.service
    ibus_restart_expected=1
    unset IBUS_ADDRESS
elif command -v ibus >/dev/null 2>&1 &&
     cassotis_prepare_ibus_environment; then
    IBUS_COMPONENT_PATH="$system_component_dir" ibus restart
    ibus_restart_expected=1
    unset IBUS_ADDRESS
fi

ibus_ready=0
if [[ $ibus_restart_expected -eq 1 ]]; then
    for ((attempt = 0; attempt < 50; attempt += 1)); do
        if cassotis_prepare_ibus_environment; then
            ibus_ready=1
            break
        fi
        sleep 0.1
    done
    [[ $ibus_ready -eq 1 ]] ||
        cassotis_die "restarted IBus daemon did not become ready"
fi
cassotis_gnome_input_sources_restore ||
    cassotis_die "could not restore the GNOME input-source list"
if command -v gsettings >/dev/null 2>&1; then
    cassotis_gnome_input_source_remove ibus cassotis ||
        cassotis_die "could not remove Cassotis from the GNOME input-source list"
fi
ibus_service_stopped=0

printf 'Removed the Cassotis user IBus component.\n'
printf 'Shared runtime: %s\n' "$shared_runtime"
printf 'Dictionary and user data under %s were retained.\n' "$data_dir"
