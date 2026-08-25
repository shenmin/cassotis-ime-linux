#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

usage() {
    cat <<'EOF'
Usage: scripts/validate_candidates.sh --dictionary FILE [--cases FILE]

Runs the frozen Windows v1.17.0 candidate-parity set without loading a user
dictionary. Pass --cases tests/cases/candidate_quality_targets.tsv to inspect
the separate, non-gating upstream quality backlog.
EOF
}

dictionary_path=''
case_path="$cassotis_root/tests/cases/candidate_quality.tsv"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dictionary)
            [[ $# -ge 2 ]] || cassotis_die '--dictionary requires a path'
            dictionary_path="$2"
            shift
            ;;
        --cases)
            [[ $# -ge 2 ]] || cassotis_die '--cases requires a path'
            case_path="$2"
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown candidate validation option: $1"
            ;;
    esac
    shift
done

[[ -n "$dictionary_path" ]] || {
    usage >&2
    cassotis_die '--dictionary is required'
}
[[ -f "$dictionary_path" ]] ||
    cassotis_die "dictionary does not exist: $dictionary_path"
[[ -f "$case_path" ]] ||
    cassotis_die "case file does not exist: $case_path"
runner="$cassotis_root/build/bin/cassotis-candidate-regression"
cassotis_require_executable "$runner"

"$runner" "$dictionary_path" "$case_path"
