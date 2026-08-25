#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

dictionary_path="${XDG_DATA_HOME:-$HOME/.local/share}/cassotis-ime/dict_sc.db"
skip_build=0

usage() {
    cat <<'EOF'
Usage: scripts/stress_ibus.sh [--dictionary DB] [--skip-build]

Runs the private-socket IBus transport, context, restart, latency, malformed-
input, and memory-growth stress test without modifying the desktop user data.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
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
            cassotis_die "unknown stress-test option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
[[ -r "$dictionary_path" ]] ||
    cassotis_die "dictionary is not readable: $dictionary_path"
if [[ $skip_build -eq 0 ]]; then
    "$cassotis_root/scripts/build.sh"
fi

adapter="$cassotis_root/build/bin/ibus-engine-cassotis"
cassotis_require_executable "$adapter"
temporary_directory="$(mktemp -d)"
trap 'rm -rf -- "$temporary_directory"' EXIT

CASSOTIS_DICTIONARY="$dictionary_path" \
CASSOTIS_USER_DICTIONARY="$temporary_directory/user_dict.db" \
    "$adapter" --multi-client-test
CASSOTIS_DICTIONARY="$dictionary_path" \
CASSOTIS_USER_DICTIONARY="$temporary_directory/user_dict.db" \
    "$adapter" --stress-test
