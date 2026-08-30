#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

clean_build=0
force_build=0

usage() {
    cat <<'EOF'
Usage: scripts/build.sh [--clean] [--force]

  --clean  Safely remove build/ before compiling; implies --force.
  --force  Ask FPC to rebuild every referenced unit.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean)
            clean_build=1
            force_build=1
            ;;
        --force)
            force_build=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown build option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
cassotis_resolve_fpc

if [[ $clean_build -eq 1 ]]; then
    cassotis_safe_clean_build
fi

build_dir="$cassotis_root/build"
bin_dir="$build_dir/bin"
unit_dir="$build_dir/units"
mkdir -p "$bin_dir" "$unit_dir"

cassotis_require_command c++
cassotis_require_command install
cassotis_require_command ln
"$cassotis_root/scripts/validate_runtime_assets.sh"

case "$(uname -m)" in
    x86_64) ort_arch='linux-x86_64' ;;
    aarch64|arm64) ort_arch='linux-aarch64' ;;
    *) cassotis_die "unsupported ONNX Runtime architecture: $(uname -m)" ;;
esac
ort_root="$cassotis_root/third_party/onnxruntime"
ort_arch_dir="$ort_root/$ort_arch"
ort_versioned_library="$ort_arch_dir/libonnxruntime.so.1.20.1"

printf '[build] libcassotis_pinyin_transformer_ort.so\n'
c++ -std=c++20 -O2 -g -Wall -Wextra -Werror -fPIC -shared -pthread \
    -I"$ort_root/include" \
    "$cassotis_root/src/host/native/nc_pinyin_transformer_ort.cpp" \
    "$ort_versioned_library" \
    -Wl,-rpath,'$ORIGIN' \
    -o "$bin_dir/libcassotis_pinyin_transformer_ort.so"
install -m 0755 "$ort_versioned_library" \
    "$bin_dir/libonnxruntime.so.1.20.1"
install -m 0755 "$ort_arch_dir/libonnxruntime_providers_shared.so" \
    "$bin_dir/libonnxruntime_providers_shared.so"
ln -sfn libonnxruntime.so.1.20.1 "$bin_dir/libonnxruntime.so.1"
ln -sfn libonnxruntime.so.1 "$bin_dir/libonnxruntime.so"
install -d -m 0755 "$bin_dir/pinyin_transformer" \
    "$bin_dir/local_completion"
install -m 0644 \
    "$cassotis_root/data/models/pinyin_transformer/pinyin_conditional_scorer_int8.onnx" \
    "$cassotis_root/data/models/pinyin_transformer/vocab.json" \
    "$bin_dir/pinyin_transformer/"
rm -f -- \
    "$bin_dir/pinyin_transformer/pinyin_difference_reranker_int8.onnx"
install -m 0644 \
    "$cassotis_root/data/models/local_completion/local_completion_path_ranker_int8.onnx" \
    "$cassotis_root/data/models/local_completion/local_completion_index.bin" \
    "$cassotis_root/data/models/local_completion/model_manifest.json" \
    "$bin_dir/local_completion/"

common_args=(
    -Mdelphiunicode
    -FcUTF8
    -vm2091
    -vm4110
    -O2
    -g
    -gl
    -Si
    -vewnhibq
    "-FE$bin_dir"
    "-FU$unit_dir"
    "-Fu$cassotis_root/src/common"
    "-Fu$cassotis_root/src/engine"
    "-Fu$cassotis_root/src/dictionary"
    "-Fu$cassotis_root/src/ipc"
    "-Fu$cassotis_root/src/service"
    "-Fu$cassotis_root/src/host"
    "-Fu$cassotis_root/tests/unit"
)
force_pending=$force_build

compile_target() {
    local source_path="$1"
    local output_name="$2"
    local -a target_args=("${common_args[@]}")
    if [[ $force_pending -eq 1 ]]; then
        target_args=(-B "${target_args[@]}")
        force_pending=0
    fi
    printf '[build] %s\n' "$output_name"
    "$CASSOTIS_FPC_BIN" "${target_args[@]}" "-o$output_name" "$source_path"
    cassotis_require_executable "$bin_dir/$output_name"
}

compile_target "$cassotis_root/src/service/cassotis_engine.lpr" \
    cassotis-engine
compile_target "$cassotis_root/tests/unit/cassotis_core_tests.lpr" \
    cassotis-core-tests
compile_target "$cassotis_root/tools/benchmark/cassotis_parser_benchmark.lpr" \
    cassotis-parser-benchmark
compile_target "$cassotis_root/tools/benchmark/cassotis_shuangpin_benchmark.lpr" \
    cassotis-shuangpin-benchmark
compile_target "$cassotis_root/tools/benchmark/cassotis_dictionary_benchmark.lpr" \
    cassotis-dictionary-benchmark
compile_target "$cassotis_root/tools/benchmark/cassotis_candidate_benchmark.lpr" \
    cassotis-candidate-benchmark
compile_target "$cassotis_root/tools/benchmark/cassotis_quality_benchmark.lpr" \
    cassotis-quality-benchmark
compile_target "$cassotis_root/tools/regression/cassotis_candidate_regression.lpr" \
    cassotis-candidate-regression
compile_target "$cassotis_root/tools/integration/cassotis_neural_runtime_smoke.lpr" \
    cassotis-neural-runtime-smoke
compile_target "$cassotis_root/tools/integration/cassotis_neural_engine_smoke.lpr" \
    cassotis-neural-engine-smoke
compile_target "$cassotis_root/tools/benchmark/cassotis_completion_benchmark.lpr" \
    cassotis-completion-benchmark

cassotis_require_command cc
cassotis_require_command pkg-config
pkg-config --exists ibus-1.0 ||
    cassotis_die "IBus development package ibus-1.0 was not found"
pkg-config --exists Fcitx5Core ||
    cassotis_die "Fcitx 5 development package Fcitx5Core was not found"
pkg-config --exists Fcitx5Config ||
    cassotis_die "Fcitx 5 development package Fcitx5Config was not found"
printf '[build] ibus-engine-cassotis\n'
# Current IBus headers use GNU variadic macros, so use GNU C11 while keeping
# warnings in Cassotis sources fatal.
cc -std=gnu11 -O2 -g -Wall -Wextra -Werror \
    -I"$cassotis_root/adapters/common" \
    -I"$cassotis_root/adapters/ibus" \
    $(pkg-config --cflags ibus-1.0) \
    "$cassotis_root/adapters/ibus/cassotis_protocol.c" \
    "$cassotis_root/adapters/ibus/cassotis_client.c" \
    "$cassotis_root/adapters/ibus/ibus_engine_cassotis.c" \
    -o "$bin_dir/ibus-engine-cassotis" \
    $(pkg-config --libs ibus-1.0)
cassotis_require_executable "$bin_dir/ibus-engine-cassotis"

printf '[build] cassotis-control\n'
cc -std=gnu11 -O2 -g -Wall -Wextra -Werror \
    -I"$cassotis_root/adapters/ibus" \
    $(pkg-config --cflags glib-2.0) \
    "$cassotis_root/adapters/ibus/cassotis_protocol.c" \
    "$cassotis_root/adapters/ibus/cassotis_client.c" \
    "$cassotis_root/tools/control/cassotis_control.c" \
    -o "$bin_dir/cassotis-control" \
    $(pkg-config --libs glib-2.0)
cassotis_require_executable "$bin_dir/cassotis-control"

printf '[build] libcassotis.so (Fcitx 5)\n'
fcitx_compat_flags=()
if pkg-config --atleast-version=5.1.9 Fcitx5Core; then
    fcitx_compat_flags+=(
        -DCASSOTIS_FCITX_HAS_CANDIDATE_COMMENT=1
        -DCASSOTIS_FCITX_HAS_BULK_CURSOR=1
    )
fi
cc -std=gnu11 -O2 -g -Wall -Wextra -Werror -fPIC \
    -I"$cassotis_root/adapters/ibus" \
    $(pkg-config --cflags glib-2.0) \
    -c "$cassotis_root/adapters/ibus/cassotis_protocol.c" \
    -o "$unit_dir/cassotis_protocol_fcitx5.o"
cc -std=gnu11 -O2 -g -Wall -Wextra -Werror -fPIC \
    -I"$cassotis_root/adapters/ibus" \
    $(pkg-config --cflags glib-2.0) \
    -c "$cassotis_root/adapters/ibus/cassotis_client.c" \
    -o "$unit_dir/cassotis_client_fcitx5.o"
c++ -std=c++20 -O2 -g -Wall -Wextra -Werror -fPIC -shared \
    -I"$cassotis_root/adapters/common" \
    -I"$cassotis_root/adapters/ibus" \
    "${fcitx_compat_flags[@]}" \
    $(pkg-config --cflags Fcitx5Core Fcitx5Config glib-2.0) \
    "$cassotis_root/adapters/fcitx5/fcitx5_engine_cassotis.cpp" \
    "$unit_dir/cassotis_protocol_fcitx5.o" \
    "$unit_dir/cassotis_client_fcitx5.o" \
    -o "$bin_dir/libcassotis.so" \
    $(pkg-config --libs Fcitx5Core Fcitx5Config glib-2.0)
[[ -r "$bin_dir/libcassotis.so" ]] ||
    cassotis_die "Fcitx 5 addon was not produced"

printf '[build] cassotis-fcitx5-smoke\n'
c++ -std=c++20 -O2 -g -Wall -Wextra -Werror \
    "${fcitx_compat_flags[@]}" \
    $(pkg-config --cflags Fcitx5Core Fcitx5Config glib-2.0) \
    "$cassotis_root/tools/integration/cassotis_fcitx5_smoke.cpp" \
    -o "$bin_dir/cassotis-fcitx5-smoke" \
    $(pkg-config --libs Fcitx5Core Fcitx5Config glib-2.0)
cassotis_require_executable "$bin_dir/cassotis-fcitx5-smoke"

printf '[build] cassotis-ibus-smoke\n'
cc -std=gnu11 -O2 -g -Wall -Wextra -Werror \
    $(pkg-config --cflags ibus-1.0) \
    "$cassotis_root/tools/integration/cassotis_ibus_smoke.c" \
    -o "$bin_dir/cassotis-ibus-smoke" \
    $(pkg-config --libs ibus-1.0)
cassotis_require_executable "$bin_dir/cassotis-ibus-smoke"

printf '[build] cassotis-candidate-layout-tests\n'
cc -std=gnu11 -O2 -g -Wall -Wextra -Werror \
    -I"$cassotis_root/adapters/common" \
    -I"$cassotis_root/adapters/ibus" \
    $(pkg-config --cflags glib-2.0) \
    "$cassotis_root/tests/native/test_candidate_layout.c" \
    -o "$bin_dir/cassotis-candidate-layout-tests" \
    $(pkg-config --libs glib-2.0)
cassotis_require_executable "$bin_dir/cassotis-candidate-layout-tests"

printf '[build] cassotis-shortcut-match-tests\n'
cc -std=gnu11 -O2 -g -Wall -Wextra -Werror \
    -I"$cassotis_root/adapters/common" \
    -I"$cassotis_root/adapters/ibus" \
    $(pkg-config --cflags glib-2.0) \
    "$cassotis_root/tests/native/test_shortcut_match.c" \
    -o "$bin_dir/cassotis-shortcut-match-tests" \
    $(pkg-config --libs glib-2.0)
cassotis_require_executable "$bin_dir/cassotis-shortcut-match-tests"

cassotis_require_command python3
python3 -c 'import pathlib, sys; path = pathlib.Path(sys.argv[1]); compile(path.read_text(encoding="utf-8"), str(path), "exec")' \
    "$cassotis_root/adapters/ibus/cassotis_settings.py"

printf 'Build completed: %s\n' "$bin_dir"
