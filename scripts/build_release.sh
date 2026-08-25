#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

dictionary_path=''
traditional_dictionary_path=''
output_dir="$cassotis_root/build/release"
skip_build=0

usage() {
    cat <<'EOF'
Usage: scripts/build_release.sh --dictionary DB [OPTIONS]

Options:
  --dictionary-traditional DB  Include the traditional dictionary.
  --output DIR                 Artifact directory (default: build/release).
  --skip-build                 Reuse existing build/bin artifacts.

Creates a portable dual-framework bundle and a Debian package for the current
Linux architecture. RPM and Arch packages are intentionally not generated
from Debian-built binaries; those distributions must build from source.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dictionary)
            [[ $# -ge 2 ]] || cassotis_die '--dictionary requires a path'
            dictionary_path="$2"
            shift
            ;;
        --dictionary-traditional)
            [[ $# -ge 2 ]] ||
                cassotis_die '--dictionary-traditional requires a path'
            traditional_dictionary_path="$2"
            shift
            ;;
        --output)
            [[ $# -ge 2 ]] || cassotis_die '--output requires a path'
            output_dir="$2"
            shift
            ;;
        --skip-build)
            skip_build=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown release option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
cassotis_require_command dpkg-deb
cassotis_require_command install
cassotis_require_command realpath
cassotis_require_command sha256sum
cassotis_require_command tar
[[ -n "$dictionary_path" ]] || cassotis_die '--dictionary is required'
[[ -r "$dictionary_path" ]] ||
    cassotis_die "dictionary is not readable: $dictionary_path"

version="$(tr -d '\r\n' < "$cassotis_root/VERSION")"
machine="$(uname -m)"
case "$machine" in
    x86_64)
        release_arch='x86_64'
        deb_arch='amd64'
        ;;
    aarch64|arm64)
        release_arch='aarch64'
        deb_arch='arm64'
        ;;
    *)
        cassotis_die "unsupported release architecture: $machine"
        ;;
esac

resolved_output="$(realpath -m -- "$output_dir")"
[[ "$resolved_output" != '/' && "$resolved_output" != "$cassotis_root" ]] ||
    cassotis_die "refusing unsafe output directory: $resolved_output"
work_dir="$cassotis_root/build/release-work"
stage_root="$work_dir/root"
rm -rf -- "$work_dir"
install -d -m 0755 "$work_dir" "$resolved_output"

# The output path is user-controlled. Never recursively delete it: accept an
# empty directory or a directory containing only artifacts from an earlier
# Cassotis release, then remove those known top-level files one by one.
while IFS= read -r existing_path; do
    existing_name="$(basename -- "$existing_path")"
    if [[ ! -f "$existing_path" || -L "$existing_path" ]]; then
        cassotis_die "release output contains an unexpected entry: $existing_path"
    fi
    case "$existing_name" in
        cassotis-ime-linux-*.tar.gz|cassotis-ime_*.deb|SHA256SUMS)
            ;;
        *)
            cassotis_die "release output contains an unrelated file: $existing_path"
            ;;
    esac
done < <(find "$resolved_output" -mindepth 1 -maxdepth 1 -print)
find "$resolved_output" -maxdepth 1 -type f \
    \( -name 'cassotis-ime-linux-*.tar.gz' -o \
       -name 'cassotis-ime_*.deb' -o -name SHA256SUMS \) -delete

stage_args=(--dictionary "$dictionary_path" --destdir "$stage_root")
if [[ -n "$traditional_dictionary_path" ]]; then
    stage_args+=(--dictionary-traditional "$traditional_dictionary_path")
fi
if [[ $skip_build -eq 1 ]]; then
    stage_args+=(--skip-build)
fi
"$cassotis_root/scripts/stage_release.sh" "${stage_args[@]}"

source_date_epoch="${SOURCE_DATE_EPOCH:-$(git -C "$cassotis_root" \
    show -s --format=%ct HEAD 2>/dev/null || date +%s)}"
find "$stage_root" -exec touch -d "@$source_date_epoch" {} +

bundle_name="cassotis-ime-linux-$version-$release_arch"
bundle_dir="$work_dir/$bundle_name"
install -d -m 0755 "$bundle_dir/root"
cp -a "$stage_root/." "$bundle_dir/root/"
install -m 0755 "$cassotis_root/packaging/portable/install.sh" \
    "$bundle_dir/install.sh"
install -m 0755 "$cassotis_root/packaging/portable/uninstall.sh" \
    "$bundle_dir/uninstall.sh"
for document in README.md README.CN.md BUILD.md RELEASE.md COMPATIBILITY.md \
                BENCHMARK.md CONFIGURATION.md CONFIGURATION.CN.md \
                CHANGELOG.md LICENSE NOTICE.md; do
    [[ ! -r "$cassotis_root/$document" ]] ||
        install -m 0644 "$cassotis_root/$document" "$bundle_dir/$document"
done
install -d -m 0755 "$bundle_dir/docs"
install -m 0644 "$cassotis_root/docs/DICTIONARY.md" \
    "$bundle_dir/docs/DICTIONARY.md"
install -m 0644 "$cassotis_root/docs/IPC.md" \
    "$bundle_dir/docs/IPC.md"
install -m 0644 "$cassotis_root/docs/LEXICON_ATTRIBUTION.md" \
    "$bundle_dir/docs/LEXICON_ATTRIBUTION.md"
find "$bundle_dir" -exec touch -d "@$source_date_epoch" {} +
tar --sort=name --mtime="@$source_date_epoch" --owner=0 --group=0 \
    --numeric-owner -C "$work_dir" -czf \
    "$resolved_output/$bundle_name.tar.gz" "$bundle_name"

deb_root="$work_dir/deb-root"
cp -a "$stage_root" "$deb_root"
install -d -m 0755 "$deb_root/DEBIAN"
installed_size="$(du -sk "$deb_root/usr" | awk '{print $1}')"
cat > "$deb_root/DEBIAN/control" <<EOF
Package: cassotis-ime
Version: $version
Section: utils
Priority: optional
Architecture: $deb_arch
Maintainer: Shen Min <shenmin@gmail.com>
Installed-Size: $installed_size
Depends: libc6, libgcc-s1, libstdc++6, libsqlite3-0, libglib2.0-0t64 | libglib2.0-0, libibus-1.0-5, libfcitx5core7, libfcitx5utils2, python3, python3-gi, gir1.2-gtk-3.0
Recommends: ibus | fcitx5
Homepage: https://github.com/shenmin/cassotis-ime-linux
Description: Cassotis Chinese input method for IBus and Fcitx 5
 A native Linux release of Cassotis IME with a shared Free Pascal engine,
 IBus and Fcitx 5 adapters, settings UI, and simplified/traditional lexicons.
EOF
cat > "$deb_root/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi
if command -v ibus >/dev/null 2>&1; then
    ibus write-cache >/dev/null 2>&1 || true
fi
exit 0
EOF
chmod 0755 "$deb_root/DEBIAN/postinst"
cat > "$deb_root/DEBIAN/postrm" <<'EOF'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi
if command -v ibus >/dev/null 2>&1; then
    ibus write-cache >/dev/null 2>&1 || true
fi
exit 0
EOF
chmod 0755 "$deb_root/DEBIAN/postrm"
find "$deb_root" -exec touch -d "@$source_date_epoch" {} +
dpkg-deb --root-owner-group -Zzstd -z10 --build "$deb_root" \
    "$resolved_output/cassotis-ime_${version}_${deb_arch}.deb" >/dev/null
dpkg-deb --info "$resolved_output/cassotis-ime_${version}_${deb_arch}.deb" \
    >/dev/null

(
    cd "$resolved_output"
    find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%P\n' |
        LC_ALL=C sort | xargs sha256sum
) > "$resolved_output/SHA256SUMS"

printf 'Release artifacts: %s\n' "$resolved_output"
printf 'Version: %s\nArchitecture: %s\n' "$version" "$release_arch"
printf 'Portable and Debian artifacts were built.\n'
