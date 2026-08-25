#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

skip_tests=0
run_benchmarks=0
dictionary_path=''

usage() {
    cat <<'EOF'
Usage: rebuild_all.sh [--skip-tests] [--benchmarks] [--dictionary DB]

Performs a native Linux environment check, safely removes build/, rebuilds all
current targets, and runs smoke plus FPCUnit tests. Benchmarks are opt-in.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-tests)
            skip_tests=1
            ;;
        --benchmarks)
            run_benchmarks=1
            ;;
        --dictionary)
            [[ $# -ge 2 ]] || cassotis_die "--dictionary requires a path"
            dictionary_path="$2"
            run_benchmarks=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown rebuild option: $1"
            ;;
    esac
    shift
done

started_at="$(date +%s)"
"$cassotis_root/scripts/check_environment.sh"
"$cassotis_root/scripts/clean.sh"
"$cassotis_root/scripts/build.sh" --force

if [[ $skip_tests -eq 0 ]]; then
    "$cassotis_root/scripts/test.sh" --skip-build
fi

if [[ $run_benchmarks -eq 1 ]]; then
    benchmark_args=(--skip-build)
    if [[ -n "$dictionary_path" ]]; then
        benchmark_args+=(--dictionary "$dictionary_path")
    fi
    "$cassotis_root/scripts/benchmark.sh" "${benchmark_args[@]}"
fi

elapsed_seconds=$(( $(date +%s) - started_at ))
printf 'Rebuild completed in %ss.\n' "$elapsed_seconds"
