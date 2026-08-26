#!/usr/bin/env bash

set -euo pipefail

bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source_root="$bundle_dir/root"
destdir="${DESTDIR:-/}"
manifest="$source_root/usr/share/cassotis-ime/release-manifest.txt"

run_bounded() {
    local duration="$1"

    shift
    timeout --kill-after=1s "$duration" "$@"
}

[[ -r "$manifest" ]] || {
    printf 'Error: release manifest is missing: %s\n' "$manifest" >&2
    exit 1
}
if [[ "$destdir" == / && $EUID -ne 0 ]]; then
    printf 'Error: run with sudo, or set DESTDIR for a staged uninstall.\n' >&2
    exit 1
fi

while IFS= read -r relative_path; do
    [[ -n "$relative_path" && "$relative_path" != /* &&
       "$relative_path" != *'..'* ]] || {
        printf 'Error: unsafe release path: %s\n' "$relative_path" >&2
        exit 1
    }
    rm -f -- "$destdir/$relative_path"
done < "$manifest"
rm -f -- \
    "$destdir/usr/share/cassotis-ime/release-manifest.txt" \
    "$destdir/usr/share/cassotis-ime/release-sha256.txt"

for directory in \
    "$destdir/usr/share/cassotis-ime" \
    "$destdir/usr/share/doc/cassotis-ime/docs" \
    "$destdir/usr/share/doc/cassotis-ime" \
    "$destdir/usr/libexec/cassotis-ime"; do
    rmdir --ignore-fail-on-non-empty "$directory" 2>/dev/null || true
done

if [[ "$destdir" == / ]]; then
    command -v update-desktop-database >/dev/null 2>&1 &&
        run_bounded 2s update-desktop-database \
            /usr/share/applications >/dev/null 2>&1 || true
    command -v gtk-update-icon-cache >/dev/null 2>&1 &&
        run_bounded 2s gtk-update-icon-cache -q -t \
            /usr/share/icons/hicolor >/dev/null 2>&1 || true
    command -v ibus >/dev/null 2>&1 &&
        run_bounded 4s ibus write-cache --system >/dev/null 2>&1 || true
fi

printf 'Cassotis IME portable files were removed from %s.\n' "$destdir"
printf 'User settings and learned words were not removed.\n'
