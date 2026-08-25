#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

if [[ $# -gt 0 ]]; then
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        printf 'Usage: %s\n' "${0##*/}"
        exit 0
    fi
    cassotis_die "Unknown argument: $1"
fi

cassotis_require_linux
cassotis_safe_clean_build
printf 'Clean completed: %s\n' "$cassotis_root/build"
