#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

iterations=1000
candidate_iterations=100
dictionary_path=''
skip_build=0

usage() {
    cat <<'EOF'
Usage: scripts/benchmark.sh [--iterations N] [--candidate-iterations N]
                            [--dictionary DB] [--skip-build]

Parser and all six shuangpin schemes are always benchmarked. Raw dictionary
and complete candidate-pipeline benchmarks run when --dictionary points to a
generated Cassotis database. The complete pipeline defaults to 100 iterations
because each sample replays every key of 12 representative queries.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --iterations)
            [[ $# -ge 2 ]] || cassotis_die "--iterations requires a value"
            iterations="$2"
            shift
            ;;
        --candidate-iterations)
            [[ $# -ge 2 ]] ||
                cassotis_die "--candidate-iterations requires a value"
            candidate_iterations="$2"
            shift
            ;;
        --dictionary)
            [[ $# -ge 2 ]] || cassotis_die "--dictionary requires a path"
            dictionary_path="$2"
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
            cassotis_die "unknown benchmark option: $1"
            ;;
    esac
    shift
done

[[ "$iterations" =~ ^[1-9][0-9]*$ ]] ||
    cassotis_die "iterations must be a positive integer"
[[ "$candidate_iterations" =~ ^[1-9][0-9]*$ ]] ||
    cassotis_die "candidate iterations must be a positive integer"
cassotis_require_linux

if [[ $skip_build -eq 0 ]]; then
    "$cassotis_root/scripts/build.sh"
fi

parser_benchmark="$cassotis_root/build/bin/cassotis-parser-benchmark"
shuangpin_benchmark="$cassotis_root/build/bin/cassotis-shuangpin-benchmark"
dictionary_benchmark="$cassotis_root/build/bin/cassotis-dictionary-benchmark"
candidate_benchmark="$cassotis_root/build/bin/cassotis-candidate-benchmark"
cassotis_require_executable "$parser_benchmark"
cassotis_require_executable "$shuangpin_benchmark"

printf '===== Pinyin parser =====\n'
"$parser_benchmark" "$iterations"
printf '===== Six shuangpin schemes =====\n'
"$shuangpin_benchmark" "$iterations"

if [[ -n "$dictionary_path" ]]; then
    [[ -r "$dictionary_path" ]] ||
        cassotis_die "dictionary is not readable: $dictionary_path"
    cassotis_require_executable "$dictionary_benchmark"
    cassotis_require_executable "$candidate_benchmark"
    printf '===== Exact dictionary lookup =====\n'
    "$dictionary_benchmark" "$dictionary_path" "$iterations"
    printf '===== Candidate pipeline =====\n'
    "$candidate_benchmark" "$dictionary_path" "$candidate_iterations"
fi
