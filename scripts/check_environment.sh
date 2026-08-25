#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

cassotis_require_linux
cassotis_require_command bash
cassotis_require_command realpath
cassotis_resolve_fpc

fpc_version="$($CASSOTIS_FPC_BIN -iV | tr -d '\r[:space:]')"
fpc_target="$($CASSOTIS_FPC_BIN -iTP | tr -d '\r[:space:]')-linux"

printf 'host_os=Linux\n'
printf 'host_arch=%s\n' "$(uname -m)"
printf 'fpc=%s\n' "$CASSOTIS_FPC_BIN"
printf 'fpc_version=%s\n' "$fpc_version"
printf 'fpc_target=%s\n' "$fpc_target"

if [[ "$fpc_version" != "3.2.2" ]]; then
    printf 'Warning: validated FPC baseline is 3.2.2; detected %s\n' "$fpc_version" >&2
fi

sqlite_library="${CASSOTIS_SQLITE_LIBRARY:-}"
sqlite_cache=''
if command -v ldconfig >/dev/null 2>&1; then
    sqlite_cache="$(ldconfig -p 2>/dev/null || true)"
fi

if [[ -n "$sqlite_library" ]]; then
    [[ -r "$sqlite_library" ]] ||
        cassotis_die "CASSOTIS_SQLITE_LIBRARY is not readable: $sqlite_library"
    printf 'sqlite_runtime=%s\n' "$sqlite_library"
elif [[ "$sqlite_cache" == *libsqlite3.so* ]]; then
    printf 'sqlite_runtime=system\n'
else
    cassotis_die "SQLite runtime library libsqlite3.so.0 was not found"
fi

if command -v cmake >/dev/null 2>&1; then
    printf 'cmake=%s\n' "$(command -v cmake)"
else
    printf 'cmake=not-installed (optional)\n'
fi

cassotis_require_command pkg-config
cassotis_require_command cc
cassotis_require_command c++
cassotis_require_command python3
pkg-config --exists ibus-1.0 ||
    cassotis_die "IBus development package ibus-1.0 was not found"
pkg-config --exists Fcitx5Core ||
    cassotis_die "Fcitx 5 development package Fcitx5Core was not found"
printf 'pkg-config=%s\n' "$(command -v pkg-config)"
printf 'cc=%s\n' "$(command -v cc)"
printf 'c++=%s\n' "$(command -v c++)"
printf 'ibus_development=%s\n' "$(pkg-config --modversion ibus-1.0)"
printf 'fcitx5_development=%s\n' "$(pkg-config --modversion Fcitx5Core)"
python3 -c 'import gi; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk' \
    >/dev/null 2>&1 ||
    cassotis_die "Python GI with GTK 3 introspection data was not found"
printf 'settings_runtime=python3-gi+gtk3\n'

if command -v pkg-config >/dev/null 2>&1; then
    fcitx_modules="$(pkg-config --list-all 2>/dev/null |
        awk 'tolower($1) ~ /^fcitx5/ { print $1 }' | sort -u | paste -sd, -)"
    if [[ -n "$fcitx_modules" ]]; then
        printf 'fcitx5_pkgconfig=%s\n' "$fcitx_modules"
    else
        printf 'fcitx5_pkgconfig=not-detected\n'
    fi
fi
