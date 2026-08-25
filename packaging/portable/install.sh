#!/usr/bin/env bash

set -euo pipefail

bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source_root="$bundle_dir/root"
destdir="${DESTDIR:-/}"

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
        update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
    command -v ibus >/dev/null 2>&1 && ibus write-cache >/dev/null 2>&1 || true
fi

printf 'Cassotis IME was installed under %s.\n' "$destdir"
printf 'Log out and back in, then enable Cassotis in IBus or Fcitx 5.\n'
