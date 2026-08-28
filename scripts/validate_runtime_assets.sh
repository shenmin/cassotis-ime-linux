#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"
cassotis_require_linux
cassotis_require_command sha256sum
manifest="$cassotis_root/data/runtime-assets.sha256"
[[ -r "$manifest" ]] || cassotis_die "runtime checksum manifest is missing"
(
    cd "$cassotis_root"
    sha256sum --check --strict "$manifest"
)
printf 'runtime_assets.validation=passed\n'
