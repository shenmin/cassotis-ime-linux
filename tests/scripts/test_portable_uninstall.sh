#!/usr/bin/env bash

set -euo pipefail

source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
temporary_dir="$(mktemp -d)"
trap 'rm -rf -- "$temporary_dir"' EXIT
bundle="$temporary_dir/bundle"
destdir="$temporary_dir/staged install"
manifest_relative=usr/share/cassotis-ime/release-manifest.txt
manifest="$bundle/root/$manifest_relative"
mkdir -p "$(dirname "$manifest")"
cp -- "$source_root/packaging/portable/uninstall.sh" "$bundle/uninstall.sh"

paths=(
    usr/share/cassotis-ime/dict_sc.db
    usr/share/doc/cassotis-ime/third-party/macbert/LICENSE
    usr/share/doc/cassotis-ime/third-party/onnxruntime/LICENSE
    usr/share/doc/cassotis-ime/docs/IPC.md
    usr/libexec/cassotis-ime/local_repair/query.onnx
    'usr/libexec/cassotis-ime/future model/nested/weights.bin'
    usr/share/ibus/component/cassotis.xml
)
printf '%s\n' "${paths[@]}" > "$manifest"

stage_fixture() {
    local path
    for path in "${paths[@]}"; do
        mkdir -p "$destdir/$(dirname "$path")"
        printf 'packaged\n' > "$destdir/$path"
    done
    cp -- "$manifest" "$destdir/$manifest_relative"
    printf 'checksums\n' > "$destdir/usr/share/cassotis-ime/release-sha256.txt"
}

uninstall() {
    DESTDIR="$destdir" bash "$bundle/uninstall.sh" > "$temporary_dir/uninstall.log"
}

stage_fixture
uninstall
for directory in usr/share/cassotis-ime usr/share/doc/cassotis-ime \
                 usr/libexec/cassotis-ime; do
    [[ ! -e "$destdir/$directory" ]]
done
[[ -d "$destdir/usr/share/ibus/component" ]]
[[ -d "$destdir/usr/share/doc" ]]
[[ -z "$(find "$destdir" -type f -print -quit)" ]]
uninstall

stage_fixture
unmanaged="$destdir/usr/libexec/cassotis-ime/local_repair/user-file.txt"
printf 'keep me\n' > "$unmanaged"
user_data="$temporary_dir/home/.local/share/cassotis-ime/user_dict.db"
mkdir -p "$(dirname "$user_data")"
printf 'learned words\n' > "$user_data"
uninstall
[[ "$(cat "$unmanaged")" == 'keep me' ]]
[[ "$(cat "$user_data")" == 'learned words' ]]
for path in "${paths[@]}" "$manifest_relative" \
            usr/share/cassotis-ime/release-sha256.txt; do
    [[ ! -e "$destdir/$path" ]]
done

# Invalid manifests must fail before removing even the valid leading entry.
for invalid_path in '../outside' '/absolute' 'usr/../outside' ''; do
    stage_fixture
    printf '%s\n' "${paths[0]}" "$invalid_path" > "$manifest"
    if uninstall 2> "$temporary_dir/error.log"; then
        printf 'Error: accepted unsafe manifest entry: %s\n' "$invalid_path" >&2
        exit 1
    fi
    grep -q 'unsafe release path' "$temporary_dir/error.log"
    [[ -f "$destdir/${paths[0]}" ]]
done

printf 'portable_uninstall=ok\n'
