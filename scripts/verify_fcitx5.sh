#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

dictionary_path=''
verify_installed=0
verify_desktop=0
staged_root=''

usage() {
    cat <<'EOF'
Usage: scripts/verify_fcitx5.sh --dictionary DB
       [--installed | --root DIR] [--desktop]

Runs the native Fcitx 5 addon through Fcitx's isolated test frontend. The
desktop configuration and persistent Cassotis user dictionary are untouched.
With --installed, the copied user addon and executables are verified instead
of build/bin. With --root, a staged system installation is verified without
installing it. With --desktop, the installed addon is also discovered and
reloaded through the real graphical-session Fcitx daemon. If GNOME IBus is
active, it is restored before the script exits.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dictionary)
            [[ $# -ge 2 ]] || cassotis_die "--dictionary requires a path"
            dictionary_path="$2"
            shift
            ;;
        --installed)
            verify_installed=1
            ;;
        --root)
            [[ $# -ge 2 ]] || cassotis_die "--root requires a path"
            staged_root="$2"
            shift
            ;;
        --desktop)
            verify_desktop=1
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
cassotis_require_command pkg-config
cassotis_require_command realpath
cassotis_require_command sed
cassotis_require_command sqlite3
[[ -n "$dictionary_path" ]] || cassotis_die "--dictionary is required"
[[ -r "$dictionary_path" ]] ||
    cassotis_die "dictionary is not readable: $dictionary_path"
pkg-config --exists Fcitx5Core ||
    cassotis_die "Fcitx 5 development package Fcitx5Core was not found"
pkg-config --exists Fcitx5Config ||
    cassotis_die "Fcitx 5 development package Fcitx5Config was not found"
if [[ $verify_installed -eq 1 && -n "$staged_root" ]]; then
    cassotis_die "--installed and --root are mutually exclusive"
fi
if [[ $verify_desktop -eq 1 && $verify_installed -eq 0 ]]; then
    cassotis_die "--desktop requires --installed"
fi
if [[ -n "$staged_root" ]]; then
    staged_root="$(realpath -m -- "$staged_root")"
    [[ -d "$staged_root/usr" ]] ||
        cassotis_die "staged release root is invalid: $staged_root"
fi

if [[ -n "$staged_root" ]]; then
    engine="$staged_root/usr/libexec/cassotis-ime/cassotis-engine"
    addon="$(find "$staged_root/usr" -type f \
        -path '*/fcitx5/libcassotis.so' -print -quit)"
    control="$staged_root/usr/libexec/cassotis-ime/cassotis-control"
    smoke="$staged_root/usr/libexec/cassotis-ime/cassotis-fcitx5-smoke"
    settings="$staged_root/usr/libexec/cassotis-ime/cassotis-settings"
    icon="$staged_root/usr/share/icons/hicolor/512x512/apps/cassotis-ime.png"
    addon_metadata_source="$staged_root/usr/share/fcitx5/addon/cassotis.conf"
    input_method_source="$staged_root/usr/share/fcitx5/inputmethod/cassotis.conf"
elif [[ $verify_installed -eq 1 ]]; then
    data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    engine="$HOME/.local/libexec/cassotis-ime/cassotis-engine"
    addon="$HOME/.local/lib/fcitx5/libcassotis.so"
    control="$HOME/.local/libexec/cassotis-ime/cassotis-control"
    smoke="$HOME/.local/libexec/cassotis-ime/cassotis-fcitx5-smoke"
    settings="$HOME/.local/libexec/cassotis-ime/cassotis-settings"
    icon="$data_home/icons/hicolor/512x512/apps/cassotis-ime.png"
    addon_metadata_source="$data_home/fcitx5/addon/cassotis.conf"
    input_method_source="$data_home/fcitx5/inputmethod/cassotis.conf"
else
    engine="$cassotis_root/build/bin/cassotis-engine"
    addon="$cassotis_root/build/bin/libcassotis.so"
    control="$cassotis_root/build/bin/cassotis-control"
    smoke="$cassotis_root/build/bin/cassotis-fcitx5-smoke"
    settings="$cassotis_root/adapters/ibus/cassotis_settings.py"
    icon="$cassotis_root/cassotis_ime_yanquan_mark.png"
    addon_metadata_source=''
    input_method_source="$cassotis_root/adapters/fcitx5/cassotis.conf"
fi
cassotis_require_executable "$engine"
cassotis_require_executable "$control"
cassotis_require_executable "$smoke"
if [[ $verify_installed -eq 1 || -n "$staged_root" ]]; then
    cassotis_require_executable "$settings"
else
    [[ -r "$settings" ]] ||
        cassotis_die "settings program is not readable: $settings"
fi
[[ -r "$addon" ]] || cassotis_die "Fcitx addon is not readable: $addon"
[[ -r "$icon" ]] || cassotis_die "Cassotis application icon is not readable: $icon"
if [[ $verify_installed -eq 1 || -n "$staged_root" ]]; then
    [[ -r "$addon_metadata_source" ]] ||
        cassotis_die "installed addon metadata is not readable"
    [[ -r "$input_method_source" ]] ||
        cassotis_die "installed input-method metadata is not readable"
fi
if [[ -n "$addon_metadata_source" ]]; then
    grep -Fqx 'Configurable=True' "$addon_metadata_source" ||
        cassotis_die "Cassotis addon does not expose Fcitx configuration"
else
    grep -Fqx 'Configurable=True' \
        "$cassotis_root/adapters/fcitx5/cassotis-addon.conf.in" ||
        cassotis_die "Cassotis addon does not expose Fcitx configuration"
fi
grep -Fqx 'Configurable=True' "$input_method_source" ||
    cassotis_die "Cassotis input method does not expose Fcitx configuration"
grep -Fqx 'Icon=cassotis-ime' "$input_method_source" ||
    cassotis_die "Cassotis input method does not use its application icon"

system_addon_dir="$(pkg-config --variable=libdir Fcitx5Core)/fcitx5"
system_data_dir="$(pkg-config --variable=datadir Fcitx5Core)/fcitx5"
testing_data_dir='/usr/share/fcitx5/testing'
[[ -r "$system_addon_dir/libtestfrontend.so" ]] ||
    cassotis_die "Fcitx testfrontend library was not found"
[[ -r "$testing_data_dir/addon/testfrontend.conf" ]] ||
    cassotis_die "Fcitx testfrontend metadata was not found"

temporary_dir="$(mktemp -d)"
runtime_dir="$temporary_dir/runtime"
data_root="$temporary_dir/share/fcitx5"
socket_path="$runtime_dir/cassotis-ime/engine.sock"
cleanup() {
    if [[ -S "$socket_path" ]]; then
        CASSOTIS_ENGINE_SOCKET="$socket_path" "$control" shutdown \
            >/dev/null 2>&1 || true
    fi
    rm -rf -- "$temporary_dir"
}
trap cleanup EXIT

mkdir -p "$runtime_dir" "$data_root/addon" "$data_root/inputmethod" \
    "$temporary_dir/config/fcitx5" "$temporary_dir/cache" \
    "$temporary_dir/data"
chmod 0700 "$runtime_dir"

# Adapter deletion must be tested against a deterministic user-only entry.
# Selection-driven learning is covered by the Pascal service tests; seeding
# this isolated database keeps the native Fcitx test independent of changes
# to dynamic path recall in the production engine.
sqlite3 "$temporary_dir/user_dict.db" <<'SQL'
CREATE TABLE dict_user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pinyin TEXT NOT NULL,
    text TEXT NOT NULL,
    weight INTEGER DEFAULT 0,
    last_used INTEGER DEFAULT 0,
    UNIQUE(pinyin, text)
);
CREATE INDEX idx_dict_user_pinyin ON dict_user(pinyin);
INSERT INTO dict_user(pinyin, text, weight, last_used)
VALUES ('gengfu', '更父', 1000, CAST(strftime('%s', 'now') AS INTEGER));
SQL

if [[ $verify_installed -eq 1 || -n "$staged_root" ]]; then
    sed -E "s|^Library=.*|Library=${addon%.so}|" \
        "$addon_metadata_source" > "$data_root/addon/cassotis.conf"
    addon_dirs="$(dirname "$addon"):$system_addon_dir"
else
    fcitx_version="$(pkg-config --modversion Fcitx5Core)"
    sed -e "s|@FCITX_VERSION@|$fcitx_version|g" \
        -e "s|@LIBRARY@|libcassotis|g" \
        "$cassotis_root/adapters/fcitx5/cassotis-addon.conf.in" \
        > "$data_root/addon/cassotis.conf"
    addon_dirs="$cassotis_root/build/bin:$system_addon_dir"
fi
install -m 0644 "$input_method_source" \
    "$data_root/inputmethod/cassotis.conf"
install -m 0644 "$testing_data_dir/addon/testfrontend.conf" \
    "$data_root/addon/testfrontend.conf"
cat > "$temporary_dir/config/fcitx5/profile" <<'EOF'
[Groups/0]
Name=CassotisTest
Default Layout=us
DefaultIM=cassotis

[Groups/0/Items/0]
Name=cassotis
Layout=

[GroupOrder]
0=CassotisTest
EOF

XDG_RUNTIME_DIR="$runtime_dir" \
XDG_CONFIG_HOME="$temporary_dir/config" \
XDG_CACHE_HOME="$temporary_dir/cache" \
XDG_DATA_HOME="$temporary_dir/data" \
FCITX_DATA_DIRS="$data_root:$system_data_dir" \
FCITX_ADDON_DIRS="$addon_dirs" \
CASSOTIS_DICTIONARY="$dictionary_path" \
CASSOTIS_USER_DICTIONARY="$temporary_dir/user_dict.db" \
CASSOTIS_ENGINE_SOCKET="$socket_path" \
CASSOTIS_ENGINE_PATH="$engine" \
CASSOTIS_CONTROL_PATH="$control" \
CASSOTIS_SETTINGS_PATH="$settings" \
    "$smoke"

printf 'fcitx5_addon=%s\n' "$addon"
if [[ -n "$staged_root" ]]; then
    verification_mode=staged
elif [[ $verify_installed -eq 1 ]]; then
    verification_mode=installed
else
    verification_mode=build
fi
printf 'fcitx5_verification_mode=%s\n' "$verification_mode"
printf 'fcitx5_isolated_verification=passed\n'

if [[ $verify_desktop -eq 1 ]]; then
    cassotis_require_command fcitx5
    cassotis_require_command fcitx5-remote
    cassotis_require_command systemctl
    cassotis_prepare_desktop_session_environment ||
        cassotis_die "no graphical desktop session bus was found"

    fcitx_was_active=0
    fcitx_started_by_test=0
    ibus_stopped_by_test=0
    previous_fcitx_group=''
    previous_fcitx_input_method=''
    previous_fcitx_state=''
    desktop_cleanup() {
        local status=$?
        local attempt
        local ibus_ready=0
        local restore_failed=0

        if [[ $fcitx_was_active -eq 1 ]] &&
           fcitx5-remote --check >/dev/null 2>&1; then
            if [[ -n "$previous_fcitx_group" ]]; then
                fcitx5-remote -g "$previous_fcitx_group" \
                    >/dev/null 2>&1 || true
            fi
            if [[ -n "$previous_fcitx_input_method" ]]; then
                fcitx5-remote -s "$previous_fcitx_input_method" \
                    >/dev/null 2>&1 || true
            fi
            case "$previous_fcitx_state" in
                2) fcitx5-remote -o >/dev/null 2>&1 || true ;;
                0|1) fcitx5-remote -c >/dev/null 2>&1 || true ;;
            esac
        fi
        if [[ $fcitx_started_by_test -eq 1 ]] &&
           fcitx5-remote --check >/dev/null 2>&1; then
            fcitx5-remote -e >/dev/null 2>&1 || true
            for ((attempt = 0; attempt < 50; attempt += 1)); do
                if ! fcitx5-remote --check >/dev/null 2>&1; then
                    break
                fi
                sleep 0.1
            done
        fi
        if [[ $ibus_stopped_by_test -eq 1 ]]; then
            unset IBUS_ADDRESS
            if ! systemctl --user start \
                    org.freedesktop.IBus.session.GNOME.service \
                    >/dev/null 2>&1; then
                restore_failed=1
            fi
            for ((attempt = 0; attempt < 50; attempt += 1)); do
                if systemctl --user is-active --quiet \
                       org.freedesktop.IBus.session.GNOME.service &&
                   cassotis_prepare_ibus_environment; then
                    ibus_ready=1
                    break
                fi
                sleep 0.1
            done
            if [[ $ibus_ready -eq 0 ]] ||
               ! cassotis_gnome_input_sources_restore; then
                restore_failed=1
            fi
        fi
        if [[ $restore_failed -ne 0 ]]; then
            printf 'Error: could not restore GNOME IBus input sources\n' >&2
            [[ $status -ne 0 ]] || status=1
        fi
        cleanup
        trap - EXIT
        exit "$status"
    }
    trap desktop_cleanup EXIT

    if fcitx5-remote --check >/dev/null 2>&1; then
        fcitx_was_active=1
        previous_fcitx_group="$(fcitx5-remote -q 2>/dev/null || true)"
        previous_fcitx_input_method="$(fcitx5-remote -n 2>/dev/null || true)"
        previous_fcitx_state="$(fcitx5-remote 2>/dev/null || true)"
    else
        if systemctl --user is-active --quiet \
               org.freedesktop.IBus.session.GNOME.service; then
            cassotis_gnome_input_sources_capture ||
                cassotis_die "could not snapshot GNOME input sources"
            systemctl --user stop \
                org.freedesktop.IBus.session.GNOME.service
            ibus_stopped_by_test=1
            unset IBUS_ADDRESS
        fi
        fcitx5 -d >/dev/null 2>&1
        fcitx_started_by_test=1
    fi

    for ((attempt = 0; attempt < 50; attempt += 1)); do
        if fcitx5-remote --check >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done
    fcitx5-remote --check >/dev/null 2>&1 ||
        cassotis_die "desktop Fcitx daemon did not become ready"

    addon_name="$(fcitx5-remote -m cassotis 2>/dev/null || true)"
    [[ "$addon_name" == 'cassotis' ]] ||
        cassotis_die "desktop Fcitx did not discover the Cassotis addon"
    fcitx5-remote -r >/dev/null
    for ((attempt = 0; attempt < 50; attempt += 1)); do
        addon_name="$(fcitx5-remote -m cassotis 2>/dev/null || true)"
        [[ "$addon_name" == 'cassotis' ]] && break
        sleep 0.1
    done
    [[ "$addon_name" == 'cassotis' ]] ||
        cassotis_die "reloaded desktop Fcitx lost the Cassotis addon"
    desktop_fcitx_state="$(fcitx5-remote 2>/dev/null || printf unknown)"
    desktop_selection='not run; no focused Fcitx input context'
    if [[ "$desktop_fcitx_state" == '1' ||
          "$desktop_fcitx_state" == '2' ]]; then
        fcitx5-remote -o >/dev/null
        fcitx5-remote -s cassotis >/dev/null
        current_input_method="$(fcitx5-remote -n 2>/dev/null || true)"
        [[ "$current_input_method" == 'cassotis' ]] ||
            cassotis_die "desktop Fcitx could not select Cassotis "\
"(current: ${current_input_method:-none})"
        desktop_selection='passed'
    fi

    printf 'fcitx5_desktop_daemon=%s\n' \
        "$([[ $fcitx_was_active -eq 1 ]] && printf existing || printf temporary)"
    printf 'fcitx5_desktop_discovery=passed\n'
    printf 'fcitx5_desktop_selection=%s\n' "$desktop_selection"
    desktop_cleanup
fi
