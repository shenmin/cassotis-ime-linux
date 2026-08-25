#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

artifact_dir="$cassotis_root/build/release"
dictionary_path=''
traditional_dictionary_path=''

usage() {
    cat <<'EOF'
Usage: scripts/validate_release_artifacts.sh [OPTIONS]

Options:
  --artifacts DIR              Artifact directory.
  --dictionary DB              Expected simplified dictionary payload.
  --dictionary-traditional DB  Expected traditional dictionary payload.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --artifacts)
            [[ $# -ge 2 ]] || cassotis_die '--artifacts requires a path'
            artifact_dir="$2"
            shift
            ;;
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
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown artifact-validation option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
cassotis_require_command awk
cassotis_require_command diff
cassotis_require_command dpkg-deb
cassotis_require_command realpath
cassotis_require_command sha256sum
cassotis_require_command tar
release_version="$(tr -d '\r\n' < "$cassotis_root/VERSION")"
case "$(uname -m)" in
    x86_64) expected_deb_arch=amd64 ;;
    aarch64|arm64) expected_deb_arch=arm64 ;;
    *) cassotis_die 'unsupported validation architecture' ;;
esac
artifact_dir="$(realpath -m -- "$artifact_dir")"
[[ -d "$artifact_dir" ]] ||
    cassotis_die "artifact directory does not exist: $artifact_dir"
[[ -r "$artifact_dir/SHA256SUMS" ]] ||
    cassotis_die 'SHA256SUMS is missing'
(
    cd "$artifact_dir"
    sha256sum --check SHA256SUMS
) >/dev/null

mapfile -t portable_archives < <(
    find "$artifact_dir" -maxdepth 1 -type f \
        -name 'cassotis-ime-linux-*.tar.gz' -print
)
mapfile -t deb_packages < <(
    find "$artifact_dir" -maxdepth 1 -type f \
        -name 'cassotis-ime_*.deb' -print
)
[[ ${#portable_archives[@]} -eq 1 ]] ||
    cassotis_die 'expected exactly one portable archive'
[[ ${#deb_packages[@]} -eq 1 ]] ||
    cassotis_die 'expected exactly one Debian package'

temporary_dir="$(mktemp -d)"
trap 'rm -rf -- "$temporary_dir"' EXIT
portable_extract="$temporary_dir/portable"
deb_extract="$temporary_dir/deb"
deb_control="$temporary_dir/deb-control"
portable_install="$temporary_dir/portable-install"
mkdir -p "$portable_extract" "$deb_extract" "$deb_control" \
    "$portable_install"
tar -xzf "${portable_archives[0]}" -C "$portable_extract"
mapfile -t bundle_dirs < <(
    find "$portable_extract" -mindepth 1 -maxdepth 1 -type d -print
)
[[ ${#bundle_dirs[@]} -eq 1 ]] ||
    cassotis_die 'portable archive must contain exactly one root directory'
bundle_dir="${bundle_dirs[0]}"
[[ -x "$bundle_dir/install.sh" && -x "$bundle_dir/uninstall.sh" ]] ||
    cassotis_die 'portable install or uninstall entry point is missing'
grep -q 'cassotis-refresh-sessions' "$bundle_dir/install.sh" ||
    cassotis_die 'portable installer does not refresh active user sessions'
grep -q -- '--no-block' "$bundle_dir/install.sh" ||
    cassotis_die 'portable installer does not detach the session refresh'
for portable_script in install.sh uninstall.sh; do
    grep -Eq 'ibus write-cache --system([[:space:]]|$)' \
        "$bundle_dir/$portable_script" ||
        cassotis_die \
            "Portable $portable_script does not refresh the system IBus registry"
    grep -q 'run_bounded' "$bundle_dir/$portable_script" ||
        cassotis_die \
            "Portable $portable_script does not bound lifecycle commands"
done
[[ -r "$bundle_dir/root/usr/share/cassotis-ime/dict_tc.db" ]] ||
    cassotis_die 'portable release is missing the traditional dictionary'
for document in README.md README.CN.md BUILD.md RELEASE.md COMPATIBILITY.md \
                BENCHMARK.md CONFIGURATION.md CONFIGURATION.CN.md \
                CHANGELOG.md LICENSE NOTICE.md docs/DICTIONARY.md docs/IPC.md \
                docs/LEXICON_ATTRIBUTION.md; do
    [[ -r "$bundle_dir/$document" ]] ||
        cassotis_die "portable documentation is missing: $document"
done

dpkg-deb --info "${deb_packages[0]}" >/dev/null
[[ "$(dpkg-deb --field "${deb_packages[0]}" Package)" == cassotis-ime ]] ||
    cassotis_die 'unexpected Debian package name'
[[ "$(dpkg-deb --field "${deb_packages[0]}" Version)" == "$release_version" ]] ||
    cassotis_die 'Debian package version does not match VERSION'
[[ "$(dpkg-deb --field "${deb_packages[0]}" Architecture)" == \
   "$expected_deb_arch" ]] ||
    cassotis_die 'Debian package architecture does not match the build host'
deb_dependencies="$(dpkg-deb --field "${deb_packages[0]}" Depends)"
for dependency in libgcc-s1 libstdc++6 libsqlite3-0 libibus-1.0-5 \
                  libfcitx5core7 libfcitx5utils2 python3-gi; do
    grep -qw "$dependency" <<<"$deb_dependencies" ||
        cassotis_die "Debian runtime dependency is missing: $dependency"
done
[[ "$(dpkg-deb --field "${deb_packages[0]}" Recommends)" == \
   'ibus | fcitx5' ]] ||
    cassotis_die 'Debian package must recommend either IBus or Fcitx 5'
dpkg-deb --extract "${deb_packages[0]}" "$deb_extract"
dpkg-deb --control "${deb_packages[0]}" "$deb_control"
[[ -x "$deb_control/postinst" ]] ||
    cassotis_die 'Debian post-install script is missing or not executable'
[[ -x "$deb_control/postrm" ]] ||
    cassotis_die 'Debian post-remove script is missing or not executable'
sh -n "$deb_control/postinst"
sh -n "$deb_control/postrm"
for maintainer_script in postinst postrm; do
    grep -Eq 'ibus write-cache --system([[:space:]]|$)' \
        "$deb_control/$maintainer_script" ||
        cassotis_die \
            "Debian $maintainer_script does not refresh the system IBus registry"
    grep -q 'run_bounded' "$deb_control/$maintainer_script" ||
        cassotis_die \
            "Debian $maintainer_script does not bound lifecycle commands"
done
grep -q 'cassotis-refresh-sessions' "$deb_control/postinst" ||
    cassotis_die 'Debian post-install script does not refresh user sessions'
grep -q -- '--no-block' "$deb_control/postinst" ||
    cassotis_die 'Debian post-install script does not detach session refresh'
[[ -r "$deb_extract/usr/share/cassotis-ime/dict_tc.db" ]] ||
    cassotis_die 'Debian release is missing the traditional dictionary'

validate_dictionary_payload() {
    local expected_path="$1"
    local relative_path="$2"
    local expected_sha
    local portable_sha
    local deb_sha
    [[ -r "$expected_path" ]] ||
        cassotis_die "expected dictionary is not readable: $expected_path"
    expected_sha="$(sha256sum "$expected_path" | awk '{print $1}')"
    portable_sha="$(sha256sum "$bundle_dir/root/$relative_path" | awk '{print $1}')"
    deb_sha="$(sha256sum "$deb_extract/$relative_path" | awk '{print $1}')"
    [[ "$portable_sha" == "$expected_sha" ]] ||
        cassotis_die "portable dictionary hash differs: $relative_path"
    [[ "$deb_sha" == "$expected_sha" ]] ||
        cassotis_die "Debian dictionary hash differs: $relative_path"
}

if [[ -n "$dictionary_path" ]]; then
    validate_dictionary_payload "$dictionary_path" \
        usr/share/cassotis-ime/dict_sc.db
fi
if [[ -n "$traditional_dictionary_path" ]]; then
    validate_dictionary_payload "$traditional_dictionary_path" \
        usr/share/cassotis-ime/dict_tc.db
fi
"$cassotis_root/scripts/validate_staged_release.sh" \
    --root "$bundle_dir/root"
"$cassotis_root/scripts/validate_staged_release.sh" \
    --root "$deb_extract"
diff -qr "$bundle_dir/root" "$deb_extract" >/dev/null ||
    cassotis_die 'portable and Debian payloads differ'

DESTDIR="$portable_install" "$bundle_dir/install.sh" >/dev/null
diff -qr "$bundle_dir/root" "$portable_install" >/dev/null ||
    cassotis_die 'portable installer changed the staged payload'
DESTDIR="$portable_install" "$bundle_dir/uninstall.sh" >/dev/null
if find "$portable_install" -type f -print -quit | grep -q .; then
    cassotis_die 'portable uninstaller left release files behind'
fi
for unique_directory in usr/share/cassotis-ime usr/share/doc/cassotis-ime \
                        usr/libexec/cassotis-ime; do
    [[ ! -e "$portable_install/$unique_directory" ]] ||
        cassotis_die "portable uninstaller left directory: $unique_directory"
done

printf 'release_artifacts.directory=%s\n' "$artifact_dir"
printf 'release_artifacts.portable=%s\n' "${portable_archives[0]}"
printf 'release_artifacts.debian=%s\n' "${deb_packages[0]}"
printf 'release_artifacts.validation=passed\n'
