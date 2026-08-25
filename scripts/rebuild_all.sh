#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

usage() {
    cat <<'EOF'
Usage: rebuild_all.sh

Performs a native Linux environment check, safely removes build/, rebuilds all
runtime targets.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
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

elapsed_seconds=$(( $(date +%s) - started_at ))
printf 'Rebuild completed in %ss.\n' "$elapsed_seconds"
