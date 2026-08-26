#!/usr/bin/env bash

set -euo pipefail

bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source_root="$bundle_dir/root"
destdir="${DESTDIR:-/}"

run_bounded() {
    local duration="$1"

    shift
    timeout --kill-after=1s "$duration" "$@"
}

start_session_refresh() {
    local refresh="$1"

    if command -v systemd-run >/dev/null 2>&1 &&
       run_bounded 2s systemd-run --quiet --collect --no-block \
           --unit="cassotis-ime-session-refresh-$$" \
           --property=RuntimeMaxSec=15s \
           "$refresh" --enable-ibus-source --quiet; then
        return 0
    fi
    run_bounded 10s "$refresh" --enable-ibus-source --quiet || true
}

[[ -d "$source_root/usr" ]] || {
    printf 'Error: release root is missing: %s\n' "$source_root" >&2
    exit 1
}
(
    cd "$source_root"
    sha256sum --check ./usr/share/cassotis-ime/release-sha256.txt
) >/dev/null
if [[ "$destdir" == / && $EUID -ne 0 ]]; then
    printf 'Error: run with sudo, or set DESTDIR for a staged install.\n' >&2
    exit 1
fi

install -d -m 0755 "$destdir"
cp -a "$source_root/." "$destdir/"

if [[ "$destdir" == / ]]; then
    command -v update-desktop-database >/dev/null 2>&1 &&
        run_bounded 2s update-desktop-database \
            /usr/share/applications >/dev/null 2>&1 || true
    command -v gtk-update-icon-cache >/dev/null 2>&1 &&
        run_bounded 2s gtk-update-icon-cache -q -t \
            /usr/share/icons/hicolor >/dev/null 2>&1 || true
    command -v ibus >/dev/null 2>&1 &&
        run_bounded 4s ibus write-cache --system >/dev/null 2>&1 || true
    start_session_refresh \
        "$destdir/usr/libexec/cassotis-ime/cassotis-refresh-sessions"
fi

printf 'Cassotis IME was installed under %s.\n' "$destdir"
printf 'Active desktop input-method sessions were scheduled for refresh.\n'
