#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

cassotis_require_linux
cassotis_require_command awk
cassotis_require_command sha256sum
cassotis_require_command sed

baseline_path="$cassotis_root/porting/windows-baseline.txt"
[[ -r "$baseline_path" ]] ||
    cassotis_die "runtime baseline is missing: $baseline_path"

baseline_value() {
    local key="$1"
    local value

    value="$(sed -n "s/^${key}=//p" "$baseline_path")"
    [[ -n "$value" && "$value" != *$'\n'* ]] ||
        cassotis_die "runtime baseline key is missing or duplicated: $key"
    printf '%s\n' "$value"
}

case "$(uname -m)" in
    x86_64)
        runtime_arch='linux-x86_64'
        runtime_hash="$(baseline_value onnxruntime_linux_x86_64_sha256)"
        provider_hash="$(baseline_value onnxruntime_provider_linux_x86_64_sha256)"
        ;;
    aarch64|arm64)
        runtime_arch='linux-aarch64'
        runtime_hash="$(baseline_value onnxruntime_linux_aarch64_sha256)"
        provider_hash="$(baseline_value onnxruntime_provider_linux_aarch64_sha256)"
        ;;
    *)
        cassotis_die "unsupported ONNX Runtime architecture: $(uname -m)"
        ;;
esac

verify_asset() {
    local relative_path="$1"
    local expected_hash="$2"
    local asset_path="$cassotis_root/$relative_path"
    local actual_hash

    [[ -r "$asset_path" ]] || cassotis_die "runtime asset is missing: $relative_path"
    actual_hash="$(sha256sum "$asset_path" | awk '{print $1}')"
    [[ "$actual_hash" == "$expected_hash" ]] ||
        cassotis_die "runtime asset checksum mismatch: $relative_path"
}

verify_asset \
    'data/models/pinyin_transformer/pinyin_conditional_scorer_int8.onnx' \
    "$(baseline_value pinyin_transformer_model_sha256)"
verify_asset 'data/models/pinyin_transformer/vocab.json' \
    "$(baseline_value pinyin_transformer_vocab_sha256)"
verify_asset \
    'data/models/local_completion/local_completion_path_ranker_int8.onnx' \
    "$(baseline_value local_completion_model_sha256)"
verify_asset 'data/models/local_completion/local_completion_index.bin' \
    "$(baseline_value local_completion_index_sha256)"
verify_asset 'data/models/local_completion/model_manifest.json' \
    "$(baseline_value local_completion_manifest_sha256)"
verify_asset \
    "third_party/onnxruntime/$runtime_arch/libonnxruntime.so.1.20.1" \
    "$runtime_hash"
verify_asset \
    "third_party/onnxruntime/$runtime_arch/libonnxruntime_providers_shared.so" \
    "$provider_hash"

printf 'runtime_assets.arch=%s\n' "$runtime_arch"
printf 'runtime_assets.validation=passed\n'
