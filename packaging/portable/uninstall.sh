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

mapfile -t release_paths < "$manifest"
for relative_path in "${release_paths[@]}"; do
    [[ -n "$relative_path" && "$relative_path" != /* &&
       "$relative_path" != *'..'* ]] || {
        printf 'Error: unsafe release path: %s\n' "$relative_path" >&2
        exit 1
    }
done

declare -A directories=(
    [usr/share/cassotis-ime]=1
    [usr/share/doc/cassotis-ime]=1
    [usr/libexec/cassotis-ime]=1
)
for relative_path in "${release_paths[@]}"; do
    rm -f -- "$destdir/$relative_path"
    directory="${relative_path%/*}"
    while :; do
        case "$directory" in
            usr/share/cassotis-ime|usr/share/cassotis-ime/*|\
            usr/share/doc/cassotis-ime|usr/share/doc/cassotis-ime/*|\
            usr/libexec/cassotis-ime|usr/libexec/cassotis-ime/*)
                directories["$directory"]=1
                directory="${directory%/*}"
                ;;
            *) break ;;
        esac
    done
done
rm -f -- \
    "$destdir/usr/share/cassotis-ime/release-manifest.txt" \
    "$destdir/usr/share/cassotis-ime/release-sha256.txt"

# Remove children before parents, only within dedicated package directories.
# Nonempty directories containing unlisted files are deliberately retained.
while IFS= read -r directory; do
    rmdir --ignore-fail-on-non-empty "$destdir/$directory" 2>/dev/null || true
done < <(printf '%s\n' "${!directories[@]}" | LC_ALL=C sort -r)

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
