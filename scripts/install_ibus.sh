#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

dictionary_path=''
traditional_dictionary_path=''
skip_build=0
enable_source=1

usage() {
    cat <<'EOF'
Usage: scripts/install_ibus.sh --dictionary DB
    [--dictionary-traditional DB] [--skip-build] [--no-enable]

Stages and verifies the current IBus integration before atomically installing
it for the current desktop user. No root privileges are required. On GNOME,
the installer also adds Cassotis to the input-source list unless --no-enable
is specified.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dictionary)
            [[ $# -ge 2 ]] || cassotis_die "--dictionary requires a path"
            dictionary_path="$2"
            shift
            ;;
        --dictionary-traditional)
            [[ $# -ge 2 ]] ||
                cassotis_die "--dictionary-traditional requires a path"
            traditional_dictionary_path="$2"
            shift
            ;;
        --skip-build)
            skip_build=1
            ;;
        --no-enable)
            enable_source=0
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown install option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
cassotis_require_command install
cassotis_require_command mktemp
cassotis_require_command mv
cassotis_require_command readlink
cassotis_require_command sed
cassotis_require_command python3
[[ $EUID -ne 0 ]] ||
    cassotis_die "run this installer as the desktop user, not through sudo"
[[ -n "$dictionary_path" ]] || cassotis_die "--dictionary is required"
[[ -r "$dictionary_path" ]] || cassotis_die "dictionary is not readable: $dictionary_path"
if [[ -z "$traditional_dictionary_path" ]]; then
    sibling_traditional_dictionary="$(dirname "$dictionary_path")/dict_tc.db"
    if [[ -r "$sibling_traditional_dictionary" ]]; then
        traditional_dictionary_path="$sibling_traditional_dictionary"
    fi
elif [[ ! -r "$traditional_dictionary_path" ]]; then
    cassotis_die "traditional dictionary is not readable: $traditional_dictionary_path"
fi

if [[ $skip_build -eq 0 ]]; then
    "$cassotis_root/scripts/build.sh"
fi

engine_binary="$cassotis_root/build/bin/cassotis-engine"
adapter_binary="$cassotis_root/build/bin/ibus-engine-cassotis"
smoke_binary="$cassotis_root/build/bin/cassotis-ibus-smoke"
control_binary="$cassotis_root/build/bin/cassotis-control"
settings_source="$cassotis_root/adapters/ibus/cassotis_settings.py"
release_version="$(tr -d '\r\n' < "$cassotis_root/VERSION")"
cassotis_require_executable "$engine_binary"
cassotis_require_executable "$adapter_binary"
cassotis_require_executable "$smoke_binary"
cassotis_require_executable "$control_binary"
[[ -r "$settings_source" ]] ||
    cassotis_die "settings program is not readable: $settings_source"

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
data_dir="$data_home/cassotis-ime"
component_dir="$data_home/ibus/component"
component_file="$component_dir/cassotis.xml"
libexec_dir="$HOME/.local/libexec/cassotis-ime"
applications_dir="$data_home/applications"
desktop_file="$applications_dir/ibus-setup-cassotis.desktop"
legacy_desktop_file="$applications_dir/org.cassotis.ime.Settings.desktop"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
environment_dir="$config_dir/environment.d"
environment_file="$environment_dir/80-cassotis-ibus.conf"
systemd_dir="$config_dir/systemd/user"
ibus_dropin_dir="$systemd_dir/org.freedesktop.IBus.session.GNOME.service.d"
ibus_dropin_file="$ibus_dropin_dir/80-cassotis-component-path.conf"
legacy_service_file="$systemd_dir/cassotis-ibus.service"
legacy_autostart_file="$config_dir/autostart/cassotis-ibus.desktop"
system_component_dir="$(cassotis_ibus_system_component_dir)"
component_path="$system_component_dir:$component_dir"
adapter_path="$libexec_dir/ibus-engine-cassotis"
installed_engine_path="$libexec_dir/cassotis-engine"
installed_smoke_path="$libexec_dir/cassotis-ibus-smoke"
installed_control_path="$libexec_dir/cassotis-control"
installed_settings_path="$libexec_dir/cassotis-settings"
component_template="$cassotis_root/adapters/ibus/cassotis.xml.in"
desktop_template="$cassotis_root/adapters/ibus/ibus-setup-cassotis.desktop.in"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/${UID:-$(id -u)}}"
engine_socket="$runtime_dir/cassotis-ime/engine.sock"
staging_dir="$(mktemp -d)"
temporary_user_dir="$(mktemp -d)"
control_test_socket="$temporary_user_dir/control.sock"
ibus_service_stopped=0

cleanup() {
    local status=$?
    local attempt

    if [[ -x "$staging_dir/libexec/cassotis-control" &&
          -S "$control_test_socket" ]]; then
        CASSOTIS_ENGINE_SOCKET="$control_test_socket" \
            "$staging_dir/libexec/cassotis-control" shutdown \
            >/dev/null 2>&1 || true
    fi
    rm -rf -- "$staging_dir" "$temporary_user_dir"
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

stage_libexec="$staging_dir/libexec"
stage_data="$staging_dir/data"
stage_component="$staging_dir/cassotis.xml"
stage_desktop="$staging_dir/ibus-setup-cassotis.desktop"
stage_environment="$staging_dir/80-cassotis-ibus.conf"
stage_dropin="$staging_dir/80-cassotis-component-path.conf"
install -d -m 0700 "$stage_libexec" "$stage_data"
install -m 0644 "$dictionary_path" "$stage_data/dict_sc.db"
if [[ -n "$traditional_dictionary_path" ]]; then
    install -m 0644 "$traditional_dictionary_path" "$stage_data/dict_tc.db"
fi
install -m 0755 "$engine_binary" "$stage_libexec/cassotis-engine"
install -m 0755 "$adapter_binary" "$stage_libexec/ibus-engine-cassotis"
install -m 0755 "$smoke_binary" "$stage_libexec/cassotis-ibus-smoke"
install -m 0755 "$control_binary" "$stage_libexec/cassotis-control"
install -m 0755 "$settings_source" "$stage_libexec/cassotis-settings"
sed -e "s|@EXECUTABLE@|$adapter_path|g" \
    -e "s|@SETUP@|$installed_settings_path|g" \
    -e "s|@VERSION@|$release_version|g" \
    "$component_template" > "$stage_component"
sed "s|@SETUP@|$installed_settings_path|g" \
    "$desktop_template" > "$stage_desktop"
cat > "$stage_environment" <<EOF
IBUS_COMPONENT_PATH=$component_path
EOF
cat > "$stage_dropin" <<EOF
[Service]
Environment="IBUS_COMPONENT_PATH=$component_path"
EOF

CASSOTIS_DICTIONARY="$stage_data/dict_sc.db" \
CASSOTIS_USER_DICTIONARY="$temporary_user_dir/user_dict.db" \
    "$stage_libexec/ibus-engine-cassotis" --self-test

NO_AT_BRIDGE=1 "$stage_libexec/cassotis-settings" --check-ui
CASSOTIS_DICTIONARY="$stage_data/dict_sc.db" \
CASSOTIS_USER_DICTIONARY="$temporary_user_dir/control_user_dict.db" \
CASSOTIS_ENGINE_SOCKET="$control_test_socket" \
CASSOTIS_ENGINE_PATH="$stage_libexec/cassotis-engine" \
    "$stage_libexec/cassotis-control" get-state >/dev/null
CASSOTIS_DICTIONARY="$stage_data/dict_sc.db" \
CASSOTIS_USER_DICTIONARY="$temporary_user_dir/control_user_dict.db" \
CASSOTIS_ENGINE_SOCKET="$control_test_socket" \
CASSOTIS_ENGINE_PATH="$stage_libexec/cassotis-engine" \
    "$stage_libexec/cassotis-control" set-state 0 0 0 0 0 0 1 >/dev/null
CASSOTIS_DICTIONARY="$stage_data/dict_sc.db" \
CASSOTIS_USER_DICTIONARY="$temporary_user_dir/control_user_dict.db" \
CASSOTIS_ENGINE_SOCKET="$control_test_socket" \
CASSOTIS_ENGINE_PATH="$stage_libexec/cassotis-engine" \
    "$stage_libexec/cassotis-control" clear-user-dictionary >/dev/null
CASSOTIS_ENGINE_SOCKET="$control_test_socket" \
    "$stage_libexec/cassotis-control" shutdown >/dev/null

cassotis_gnome_input_sources_capture || true
gnome_ibus_was_active=0
if command -v systemctl >/dev/null 2>&1 &&
   systemctl --user is-active --quiet org.freedesktop.IBus.session.GNOME.service; then
    [[ "${CASSOTIS_GNOME_INPUT_SOURCES_CAPTURED:-0}" == 1 ]] ||
        cassotis_die "could not snapshot GNOME input sources"
    gnome_ibus_was_active=1
    systemctl --user stop org.freedesktop.IBus.session.GNOME.service
    ibus_service_stopped=1
fi

if [[ -S "$engine_socket" ]]; then
    XDG_RUNTIME_DIR="$runtime_dir" \
        "$stage_libexec/ibus-engine-cassotis" --shutdown-engine \
        >/dev/null 2>&1 || true
    for ((attempt = 0; attempt < 40; attempt += 1)); do
        [[ ! -S "$engine_socket" ]] && break
        sleep 0.05
    done
fi
stop_installed_engine_by_path
rm -f -- "$engine_socket"

install -d -m 0700 "$data_dir" "$component_dir" "$libexec_dir" \
    "$environment_dir" "$ibus_dropin_dir"
install -d -m 0755 "$applications_dir"
cassotis_atomic_install "$stage_data/dict_sc.db" "$data_dir/dict_sc.db" 0644
if [[ -n "$traditional_dictionary_path" ]]; then
    cassotis_atomic_install "$stage_data/dict_tc.db" "$data_dir/dict_tc.db" 0644
fi
cassotis_atomic_install "$stage_libexec/cassotis-engine" \
    "$installed_engine_path" 0755
cassotis_atomic_install "$stage_libexec/ibus-engine-cassotis" \
    "$adapter_path" 0755
cassotis_atomic_install "$stage_libexec/cassotis-ibus-smoke" \
    "$installed_smoke_path" 0755
cassotis_atomic_install "$stage_libexec/cassotis-control" \
    "$installed_control_path" 0755
cassotis_atomic_install "$stage_libexec/cassotis-settings" \
    "$installed_settings_path" 0755
cassotis_atomic_install "$stage_component" "$component_file" 0644
cassotis_atomic_install "$stage_desktop" "$desktop_file" 0644
rm -f -- "$legacy_desktop_file"
cassotis_atomic_install "$stage_environment" "$environment_file" 0600
cassotis_atomic_install "$stage_dropin" "$ibus_dropin_file" 0600

if command -v systemctl >/dev/null 2>&1 &&
   systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user disable --now cassotis-ibus.service >/dev/null 2>&1 || true
    rm -f -- "$legacy_service_file" "$legacy_autostart_file"
    systemctl --user daemon-reload
fi

if command -v ibus >/dev/null 2>&1; then
    IBUS_COMPONENT_PATH="$component_path" ibus write-cache >/dev/null 2>&1
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir" >/dev/null 2>&1 || true
fi

refresh_mode='next desktop login'
if [[ $gnome_ibus_was_active -eq 1 ]]; then
    systemctl --user start org.freedesktop.IBus.session.GNOME.service
    refresh_mode='restarted GNOME IBus service'
elif command -v ibus >/dev/null 2>&1 &&
     cassotis_prepare_ibus_environment; then
    IBUS_COMPONENT_PATH="$component_path" ibus restart
    unset IBUS_ADDRESS
    refresh_mode='restarted IBus daemon'
fi

ibus_ready=0
for ((attempt = 0; attempt < 50; attempt += 1)); do
    if cassotis_prepare_ibus_environment; then
        ibus_ready=1
        break
    fi
    sleep 0.1
done
if [[ $gnome_ibus_was_active -eq 1 && $ibus_ready -eq 0 ]]; then
    cassotis_die "restarted GNOME IBus daemon did not become ready"
fi
cassotis_gnome_input_sources_restore ||
    cassotis_die "could not restore the GNOME input-source list"
if [[ $enable_source -eq 1 ]] && command -v gsettings >/dev/null 2>&1; then
    cassotis_gnome_input_source_add ibus cassotis ||
        cassotis_die "could not add Cassotis to the GNOME input-source list"
fi
ibus_service_stopped=0

desktop_verification='not run; no active desktop IBus daemon'
if [[ $gnome_ibus_was_active -eq 1 ]]; then
    "$cassotis_root/scripts/verify_ibus.sh" \
        --binary "$installed_smoke_path" --component "$component_file"
    desktop_verification='passed'
fi

printf 'Installed the Cassotis user IBus component for %s.\n' "$USER"
printf 'IBus registry: %s\n' "$refresh_mode"
printf 'Desktop verification: %s\n' "$desktop_verification"
printf 'Dictionary: %s\n' "$data_dir/dict_sc.db"
if [[ -n "$traditional_dictionary_path" ]]; then
    printf 'Traditional dictionary: %s\n' "$data_dir/dict_tc.db"
fi
printf 'User dictionary retained at: %s\n' "$data_dir/user_dict.db"
printf 'Settings: %s\n' "$installed_settings_path"
printf 'Use Super+Space to switch to Cassotis IME.\n'
