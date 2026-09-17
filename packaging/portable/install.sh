#!/usr/bin/env bash

set -euo pipefail

bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source_root="$bundle_dir/root"
destdir="${DESTDIR:-/}"

usage() {
    cat <<'EOF'
Usage: ./install.sh [--system]
       ./install.sh --user [--framework auto|ibus|fcitx5|both] [--check] [--no-refresh]

--system installs into /usr and requires sudo (the historical default).
--user installs into ~/.local and XDG directories; do NOT use sudo.
--check validates user-install compatibility without changing files or settings.
DESTDIR is for staging a system filesystem tree, not for user installation.
EOF
}

case "${1:-}" in
    --user)
        shift
        command -v python3 >/dev/null 2>&1 || {
            printf 'Error: Python 3 is required for user installation.\n' >&2
            exit 1
        }
        exec python3 "$bundle_dir/install-support/user_install.py" install \
            --bundle "$bundle_dir" "$@"
        ;;
    --help|-h) usage; exit 0 ;;
    --system) shift ;;
esac
[[ $# -eq 0 ]] || { usage >&2; exit 2; }

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
    printf 'Error: use ./install.sh --user without sudo, or sudo ./install.sh --system.\n' >&2
    exit 1
fi

# Check before copying, so immutable systems do not get a partial installation.
for directory in "$destdir" "$destdir/usr" "$destdir/usr/lib" \
                 "$destdir/usr/libexec" "$destdir/usr/share"; do
    parent="$directory"
    while [[ ! -e "$parent" ]]; do parent="$(dirname -- "$parent")"; done
    if [[ ! -d "$parent" || ! -w "$parent" ]]; then
        printf 'Error: system destination is read-only or not writable: %s\n' "$parent" >&2
        printf 'Use ./install.sh --user WITHOUT sudo; keep filesystem protection enabled.\n' >&2
        exit 1
    fi
done

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
