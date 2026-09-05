#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

dictionary_path=''
traditional_dictionary_path=''
destdir=''
prefix='/usr'
libdir=''
skip_build=0

usage() {
    cat <<'EOF'
Usage: scripts/stage_release.sh --dictionary DB --destdir DIR [OPTIONS]

Options:
  --dictionary-traditional DB  Include the traditional dictionary.
  --prefix DIR                 Installation prefix (default: /usr).
  --libdir DIR                 Native library directory (auto-detected).
  --skip-build                 Reuse build/bin artifacts.

Creates one deterministic filesystem tree containing the shared engine,
settings, dictionaries, and both IBus and Fcitx 5 adapters. It never writes
outside DIR and does not modify the current desktop session.
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
        --destdir)
            [[ $# -ge 2 ]] || cassotis_die '--destdir requires a path'
            destdir="$2"
            shift
            ;;
        --prefix)
            [[ $# -ge 2 ]] || cassotis_die '--prefix requires a path'
            prefix="$2"
            shift
            ;;
        --libdir)
            [[ $# -ge 2 ]] || cassotis_die '--libdir requires a path'
            libdir="$2"
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
            cassotis_die "unknown staging option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
cassotis_require_command find
cassotis_require_command install
cassotis_require_command pkg-config
cassotis_require_command realpath
cassotis_require_command sed
cassotis_require_command sha256sum
[[ -n "$dictionary_path" ]] || cassotis_die '--dictionary is required'
[[ -r "$dictionary_path" ]] ||
    cassotis_die "dictionary is not readable: $dictionary_path"
[[ -n "$destdir" ]] || cassotis_die '--destdir is required'
if [[ -n "$traditional_dictionary_path" &&
      ! -r "$traditional_dictionary_path" ]]; then
    cassotis_die "traditional dictionary is not readable: $traditional_dictionary_path"
fi
[[ "$prefix" == /* && "$prefix" != '/' ]] ||
    cassotis_die '--prefix must be an absolute path below /'

resolved_destdir="$(realpath -m -- "$destdir")"
[[ "$resolved_destdir" != '/' && "$resolved_destdir" != "$cassotis_root" ]] ||
    cassotis_die "refusing unsafe staging directory: $resolved_destdir"

if [[ -z "$libdir" ]]; then
    pkg-config --exists Fcitx5Core ||
        cassotis_die 'Fcitx5Core is required to detect the native library directory'
    libdir="$(pkg-config --variable=libdir Fcitx5Core)"
fi
[[ "$libdir" == /* ]] || cassotis_die '--libdir must be absolute'

if [[ $skip_build -eq 0 ]]; then
    "$cassotis_root/scripts/build.sh"
fi

bin_dir="$cassotis_root/build/bin"
engine="$bin_dir/cassotis-engine"
control="$bin_dir/cassotis-control"
settings="$cassotis_root/adapters/ibus/cassotis_settings.py"
icon="$cassotis_root/cassotis_ime_yanquan_mark.png"
ibus_adapter="$bin_dir/ibus-engine-cassotis"
fcitx_addon="$bin_dir/libcassotis.so"
ibus_smoke="$bin_dir/cassotis-ibus-smoke"
fcitx_smoke="$bin_dir/cassotis-fcitx5-smoke"
neural_smoke="$bin_dir/cassotis-neural-runtime-smoke"
runtime_wrapper="$bin_dir/libcassotis_pinyin_transformer_ort.so"
runtime_library="$bin_dir/libonnxruntime.so.1.20.1"
runtime_provider="$bin_dir/libonnxruntime_providers_shared.so"
for binary in "$engine" "$control" "$ibus_adapter" "$ibus_smoke" \
              "$fcitx_smoke" "$neural_smoke"; do
    cassotis_require_executable "$binary"
done
for runtime_file in "$runtime_wrapper" "$runtime_library" \
                    "$runtime_provider"; do
    [[ -r "$runtime_file" ]] ||
        cassotis_die "neural runtime artifact not found: $runtime_file"
done
[[ -r "$settings" ]] || cassotis_die "settings source not found: $settings"
[[ -r "$icon" ]] || cassotis_die "application icon not found: $icon"
[[ -r "$fcitx_addon" ]] || cassotis_die "Fcitx addon not found: $fcitx_addon"

release_version="$(tr -d '\r\n' < "$cassotis_root/VERSION")"
[[ "$release_version" =~ ^[0-9]+([.][0-9]+){2}([.-][0-9A-Za-z.-]+)?$ ]] ||
    cassotis_die "invalid VERSION: $release_version"
engine_version="$("$engine" --version)"
[[ "$engine_version" == "$release_version" ]] ||
    cassotis_die "engine version $engine_version does not match VERSION $release_version"
fcitx_version="$(pkg-config --modversion Fcitx5Core)"

if [[ -e "$resolved_destdir" ]]; then
    [[ -d "$resolved_destdir" ]] ||
        cassotis_die "staging path is not a directory: $resolved_destdir"
    if find "$resolved_destdir" -mindepth 1 -print -quit | grep -q .; then
        cassotis_die "staging directory must be empty: $resolved_destdir"
    fi
else
    install -d -m 0755 "$resolved_destdir"
fi

stage_path() {
    printf '%s%s' "$resolved_destdir" "$1"
}

libexec_path="$prefix/libexec/cassotis-ime"
data_path="$prefix/share/cassotis-ime"
doc_path="$prefix/share/doc/cassotis-ime"
applications_path="$prefix/share/applications"
icon_path="$prefix/share/icons/hicolor/512x512/apps"
ibus_component_path="$prefix/share/ibus/component"
fcitx_addon_path="$prefix/share/fcitx5/addon"
fcitx_input_method_path="$prefix/share/fcitx5/inputmethod"
fcitx_library_path="$libdir/fcitx5"

install -d -m 0755 \
    "$(stage_path "$libexec_path")" \
    "$(stage_path "$data_path")" \
    "$(stage_path "$doc_path")" \
    "$(stage_path "$doc_path/docs")" \
    "$(stage_path "$doc_path/third-party/onnxruntime")" \
    "$(stage_path "$applications_path")" \
    "$(stage_path "$icon_path")" \
    "$(stage_path "$ibus_component_path")" \
    "$(stage_path "$fcitx_addon_path")" \
    "$(stage_path "$fcitx_input_method_path")" \
    "$(stage_path "$fcitx_library_path")"

install -m 0755 "$engine" "$(stage_path "$libexec_path/cassotis-engine")"
install -m 0755 "$control" "$(stage_path "$libexec_path/cassotis-control")"
install -m 0755 "$settings" "$(stage_path "$libexec_path/cassotis-settings")"
install -m 0755 \
    "$cassotis_root/packaging/session/cassotis-refresh-sessions" \
    "$(stage_path "$libexec_path/cassotis-refresh-sessions")"
install -m 0755 "$ibus_adapter" \
    "$(stage_path "$libexec_path/ibus-engine-cassotis")"
install -m 0755 "$ibus_smoke" \
    "$(stage_path "$libexec_path/cassotis-ibus-smoke")"
install -m 0755 "$fcitx_smoke" \
    "$(stage_path "$libexec_path/cassotis-fcitx5-smoke")"
install -m 0755 "$neural_smoke" \
    "$(stage_path "$libexec_path/cassotis-neural-runtime-smoke")"
install -m 0755 "$runtime_wrapper" \
    "$(stage_path "$libexec_path/libcassotis_pinyin_transformer_ort.so")"
install -m 0755 "$runtime_library" \
    "$(stage_path "$libexec_path/libonnxruntime.so.1.20.1")"
install -m 0755 "$runtime_provider" \
    "$(stage_path "$libexec_path/libonnxruntime_providers_shared.so")"
ln -s libonnxruntime.so.1.20.1 \
    "$(stage_path "$libexec_path/libonnxruntime.so.1")"
ln -s libonnxruntime.so.1 \
    "$(stage_path "$libexec_path/libonnxruntime.so")"
install -d -m 0755 \
    "$(stage_path "$libexec_path/pinyin_transformer")" \
    "$(stage_path "$libexec_path/local_completion")"
install -m 0644 "$bin_dir/pinyin_transformer/"* \
    "$(stage_path "$libexec_path/pinyin_transformer")/"
install -m 0644 "$bin_dir/local_completion/"* \
    "$(stage_path "$libexec_path/local_completion")/"
install -m 0755 "$fcitx_addon" \
    "$(stage_path "$fcitx_library_path/libcassotis.so")"
install -m 0644 "$icon" "$(stage_path "$icon_path/cassotis-ime.png")"
install -m 0644 "$dictionary_path" "$(stage_path "$data_path/dict_sc.db")"
if [[ -n "$traditional_dictionary_path" ]]; then
    install -m 0644 "$traditional_dictionary_path" \
        "$(stage_path "$data_path/dict_tc.db")"
fi

sed -e "s|@EXECUTABLE@|$libexec_path/ibus-engine-cassotis|g" \
    -e "s|@SETUP@|$libexec_path/cassotis-settings|g" \
    -e "s|@VERSION@|$release_version|g" \
    "$cassotis_root/adapters/ibus/cassotis.xml.in" \
    > "$(stage_path "$ibus_component_path/cassotis.xml")"

fcitx_library_stem="$fcitx_library_path/libcassotis"
sed -e "s|@FCITX_VERSION@|$fcitx_version|g" \
    -e "s|@LIBRARY@|$fcitx_library_stem|g" \
    -e "s|@VERSION@|$release_version|g" \
    "$cassotis_root/adapters/fcitx5/cassotis-addon.conf.in" \
    > "$(stage_path "$fcitx_addon_path/cassotis.conf")"
install -m 0644 "$cassotis_root/adapters/fcitx5/cassotis.conf" \
    "$(stage_path "$fcitx_input_method_path/cassotis.conf")"
sed "s|@SETUP@|$libexec_path/cassotis-settings|g" \
    "$cassotis_root/adapters/ibus/ibus-setup-cassotis.desktop.in" \
    > "$(stage_path "$applications_path/ibus-setup-cassotis.desktop")"

for document in README.md README.CN.md BUILD.md COMPATIBILITY.md \
                BENCHMARK.md BENCHMARK.CN.md CONFIGURATION.md \
                CONFIGURATION.CN.md \
                CHANGELOG.md LICENSE NOTICE.md; do
    if [[ -r "$cassotis_root/$document" ]]; then
        install -m 0644 "$cassotis_root/$document" \
            "$(stage_path "$doc_path/$document")"
    fi
done
install -m 0644 "$cassotis_root/snapshot.jpg" \
    "$(stage_path "$doc_path/snapshot.jpg")"
for document in DICTIONARY.md IPC.md LEXICON_ATTRIBUTION.md; do
    install -m 0644 "$cassotis_root/docs/$document" \
        "$(stage_path "$doc_path/docs/$document")"
done
install -m 0644 "$cassotis_root/third_party/onnxruntime/LICENSE" \
    "$(stage_path "$doc_path/third-party/onnxruntime/LICENSE")"
install -m 0644 \
    "$cassotis_root/third_party/onnxruntime/ThirdPartyNotices.txt" \
    "$(stage_path "$doc_path/third-party/onnxruntime/ThirdPartyNotices.txt")"

if grep -R -n -E '@(EXECUTABLE|SETUP|VERSION|FCITX_VERSION|LIBRARY)@' \
        "$resolved_destdir"; then
    cassotis_die 'unexpanded release metadata placeholder found'
fi

manifest="$(stage_path "$data_path/release-manifest.txt")"
(
    cd "$resolved_destdir"
    find . \( -type f -o -type l \) \
        ! -path ".${data_path}/release-manifest.txt" \
        -printf '%P\n' | LC_ALL=C sort
) > "$manifest"
(
    cd "$resolved_destdir"
    sha256sum $(sed 's|^|./|' "$manifest")
) > "$(stage_path "$data_path/release-sha256.txt")"

printf 'release.version=%s\n' "$release_version"
printf 'release.destdir=%s\n' "$resolved_destdir"
printf 'release.libdir=%s\n' "$libdir"
printf 'release.files=%s\n' "$(wc -l < "$manifest")"
