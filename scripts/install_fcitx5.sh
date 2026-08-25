#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

dictionary_path=''
traditional_dictionary_path=''
skip_build=0
enable_profile=1

usage() {
    cat <<'EOF'
Usage: scripts/install_fcitx5.sh --dictionary DB
    [--dictionary-traditional DB] [--skip-build] [--no-enable]

Stages and verifies the native Fcitx 5 addon before atomically installing it
for the current user. No root privileges are required. By default Cassotis is
also added to the current Fcitx input-method group.
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
            enable_profile=0
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
cassotis_require_command fcitx5
cassotis_require_command fcitx5-remote
cassotis_require_command mktemp
cassotis_require_command mv
cassotis_require_command pkg-config
cassotis_require_command python3
cassotis_require_command readlink
cassotis_require_command sed
[[ $EUID -ne 0 ]] ||
    cassotis_die "run this installer as the desktop user, not through sudo"
[[ -n "$dictionary_path" ]] || cassotis_die "--dictionary is required"
[[ -r "$dictionary_path" ]] ||
    cassotis_die "dictionary is not readable: $dictionary_path"
if [[ -z "$traditional_dictionary_path" ]]; then
    sibling_traditional_dictionary="$(dirname "$dictionary_path")/dict_tc.db"
    if [[ -r "$sibling_traditional_dictionary" ]]; then
        traditional_dictionary_path="$sibling_traditional_dictionary"
    fi
elif [[ ! -r "$traditional_dictionary_path" ]]; then
    cassotis_die "traditional dictionary is not readable: $traditional_dictionary_path"
fi
pkg-config --exists Fcitx5Core ||
    cassotis_die "Fcitx 5 development package Fcitx5Core was not found"

if [[ $skip_build -eq 0 ]]; then
    "$cassotis_root/scripts/build.sh"
fi

engine_binary="$cassotis_root/build/bin/cassotis-engine"
addon_binary="$cassotis_root/build/bin/libcassotis.so"
smoke_binary="$cassotis_root/build/bin/cassotis-fcitx5-smoke"
control_binary="$cassotis_root/build/bin/cassotis-control"
settings_source="$cassotis_root/adapters/ibus/cassotis_settings.py"
release_version="$(tr -d '\r\n' < "$cassotis_root/VERSION")"
profile_tool="$cassotis_root/scripts/fcitx5_profile.py"
cassotis_require_executable "$engine_binary"
[[ -r "$addon_binary" ]] || cassotis_die "Fcitx addon was not built"
cassotis_require_executable "$smoke_binary"
cassotis_require_executable "$control_binary"
[[ -r "$settings_source" ]] ||
    cassotis_die "settings program is not readable: $settings_source"
[[ -r "$profile_tool" ]] ||
    cassotis_die "Fcitx profile helper is not readable: $profile_tool"

"$cassotis_root/scripts/verify_fcitx5.sh" \
    --dictionary "$dictionary_path"
python3 "$profile_tool" self-test

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
data_dir="$data_home/cassotis-ime"
fcitx_data_dir="$data_home/fcitx5"
addon_metadata_dir="$fcitx_data_dir/addon"
input_method_dir="$fcitx_data_dir/inputmethod"
addon_metadata="$addon_metadata_dir/cassotis.conf"
input_method_metadata="$input_method_dir/cassotis.conf"
addon_dir="$HOME/.local/lib/fcitx5"
installed_addon="$addon_dir/libcassotis.so"
installed_addon_stem="${installed_addon%.so}"
libexec_dir="$HOME/.local/libexec/cassotis-ime"
installed_engine="$libexec_dir/cassotis-engine"
installed_control="$libexec_dir/cassotis-control"
installed_smoke="$libexec_dir/cassotis-fcitx5-smoke"
installed_settings="$libexec_dir/cassotis-settings"
applications_dir="$data_home/applications"
desktop_file="$applications_dir/org.cassotis.ime.Settings.desktop"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
profile_file="$config_home/fcitx5/profile"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/${UID:-$(id -u)}}"
engine_socket="$runtime_dir/cassotis-ime/engine.sock"

staging_dir="$(mktemp -d)"
temporary_user_dir="$(mktemp -d)"
fcitx_was_active=0
fcitx_restarted=0

cleanup() {
    local status=$?
    rm -rf -- "$staging_dir" "$temporary_user_dir"
    if [[ $status -ne 0 && $fcitx_was_active -eq 1 &&
          $fcitx_restarted -eq 0 ]]; then
        fcitx5 -d >/dev/null 2>&1 || true
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

stage_libexec="$staging_dir/libexec"
stage_data="$staging_dir/data"
stage_addon="$staging_dir/libcassotis.so"
stage_addon_metadata="$staging_dir/cassotis-addon.conf"
stage_input_method="$staging_dir/cassotis-inputmethod.conf"
stage_desktop="$staging_dir/org.cassotis.ime.Settings.desktop"
install -d -m 0700 "$stage_libexec" "$stage_data"
install -m 0644 "$dictionary_path" "$stage_data/dict_sc.db"
if [[ -n "$traditional_dictionary_path" ]]; then
    install -m 0644 "$traditional_dictionary_path" "$stage_data/dict_tc.db"
fi
install -m 0755 "$engine_binary" "$stage_libexec/cassotis-engine"
install -m 0755 "$control_binary" "$stage_libexec/cassotis-control"
install -m 0755 "$smoke_binary" \
    "$stage_libexec/cassotis-fcitx5-smoke"
install -m 0755 "$settings_source" "$stage_libexec/cassotis-settings"
install -m 0755 "$addon_binary" "$stage_addon"

fcitx_version="$(pkg-config --modversion Fcitx5Core)"
escaped_addon_stem="${installed_addon_stem//&/\\&}"
sed -e "s|@FCITX_VERSION@|$fcitx_version|g" \
    -e "s|@LIBRARY@|$escaped_addon_stem|g" \
    -e "s|@VERSION@|$release_version|g" \
    "$cassotis_root/adapters/fcitx5/cassotis-addon.conf.in" \
    > "$stage_addon_metadata"
install -m 0644 "$cassotis_root/adapters/fcitx5/cassotis.conf" \
    "$stage_input_method"
sed "s|@SETUP@|$installed_settings|g" \
    "$cassotis_root/adapters/ibus/org.cassotis.ime.Settings.desktop.in" \
    > "$stage_desktop"

NO_AT_BRIDGE=1 "$stage_libexec/cassotis-settings" --check-ui

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

if [[ -S "$engine_socket" ]]; then
    CASSOTIS_ENGINE_SOCKET="$engine_socket" \
        "$stage_libexec/cassotis-control" shutdown >/dev/null 2>&1 || true
    for ((attempt = 0; attempt < 40; attempt += 1)); do
        [[ ! -S "$engine_socket" ]] && break
        sleep 0.05
    done
fi
stop_installed_engine_by_path
rm -f -- "$engine_socket"

install -d -m 0700 "$data_dir" "$addon_dir" "$libexec_dir"
install -d -m 0755 "$addon_metadata_dir" "$input_method_dir" \
    "$applications_dir"
cassotis_atomic_install "$stage_data/dict_sc.db" \
    "$data_dir/dict_sc.db" 0644
if [[ -n "$traditional_dictionary_path" ]]; then
    cassotis_atomic_install "$stage_data/dict_tc.db" \
        "$data_dir/dict_tc.db" 0644
fi
cassotis_atomic_install "$stage_libexec/cassotis-engine" \
    "$installed_engine" 0755
cassotis_atomic_install "$stage_libexec/cassotis-control" \
    "$installed_control" 0755
cassotis_atomic_install "$stage_libexec/cassotis-fcitx5-smoke" \
    "$installed_smoke" 0755
cassotis_atomic_install "$stage_libexec/cassotis-settings" \
    "$installed_settings" 0755
cassotis_atomic_install "$stage_addon" "$installed_addon" 0755
cassotis_atomic_install "$stage_addon_metadata" "$addon_metadata" 0644
cassotis_atomic_install "$stage_input_method" \
    "$input_method_metadata" 0644
cassotis_atomic_install "$stage_desktop" "$desktop_file" 0644

"$cassotis_root/scripts/verify_fcitx5.sh" --installed \
    --dictionary "$data_dir/dict_sc.db"

profile_status='not changed (--no-enable)'
if [[ $enable_profile -eq 1 ]]; then
    profile_status="$(python3 "$profile_tool" add "$profile_file")"
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir" >/dev/null 2>&1 || true
fi

desktop_verification='not run; Fcitx was not active'
if [[ $fcitx_was_active -eq 1 ]]; then
    fcitx5 -d >/dev/null 2>&1
    fcitx_restarted=1
    for ((attempt = 0; attempt < 50; attempt += 1)); do
        if fcitx5-remote --check >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done
    addon_name="$(fcitx5-remote -m cassotis 2>/dev/null || true)"
    [[ "$addon_name" == 'cassotis' ]] ||
        cassotis_die "restarted Fcitx did not discover the Cassotis addon"
    desktop_verification='passed; Fcitx restarted and addon discovered'
fi

printf 'Installed the Cassotis user Fcitx 5 addon for %s.\n' "$USER"
printf 'Native addon: %s\n' "$installed_addon"
printf 'Dictionary: %s\n' "$data_dir/dict_sc.db"
if [[ -n "$traditional_dictionary_path" ]]; then
    printf 'Traditional dictionary: %s\n' "$data_dir/dict_tc.db"
fi
printf 'User dictionary retained at: %s\n' "$data_dir/user_dict.db"
printf 'Fcitx profile: %s (%s)\n' "$profile_file" "$profile_status"
printf 'Desktop verification: %s\n' "$desktop_verification"
printf 'Settings: %s\n' "$installed_settings"
printf 'Select Fcitx 5 as the desktop input framework, then choose '
printf 'Cassotis 言泉拼音输入法.\n'
