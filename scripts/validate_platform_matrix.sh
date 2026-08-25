#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

dictionary_path=''
traditional_dictionary_path=''
report_dir="$cassotis_root/build/platform-matrix"
skip_build=0
skip_install=0
skip_desktop=0

usage() {
    cat <<'EOF'
Usage: scripts/validate_platform_matrix.sh --dictionary DB [OPTIONS]

Options:
  --dictionary-traditional DB  Install the traditional dictionary too.
  --report-dir DIR              Report directory.
  --skip-build                  Reuse build/bin.
  --skip-install                Reuse the current per-user installation.
  --skip-desktop                Skip real desktop-daemon discovery/reload.
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
        --report-dir)
            [[ $# -ge 2 ]] || cassotis_die '--report-dir requires a path'
            report_dir="$2"
            shift
            ;;
        --skip-build) skip_build=1 ;;
        --skip-install) skip_install=1 ;;
        --skip-desktop) skip_desktop=1 ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown platform-matrix option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux
cassotis_require_command python3
cassotis_require_command realpath
[[ -n "$dictionary_path" ]] || cassotis_die '--dictionary is required'
[[ -r "$dictionary_path" ]] ||
    cassotis_die "dictionary is not readable: $dictionary_path"
report_dir="$(realpath -m -- "$report_dir")"
mkdir -p "$report_dir/logs"
matrix_tsv="$report_dir/platform-matrix.tsv"
matrix_md="$report_dir/platform-matrix.md"
printf 'framework\tstage\tresult\tlog\n' > "$matrix_tsv"

failures=0
run_stage() {
    local framework="$1"
    local stage="$2"
    shift 2
    local log="$report_dir/logs/${framework}-${stage}.log"
    local status

    set +e
    "$@" >"$log" 2>&1
    status=$?
    set -e
    if [[ $status -eq 0 ]]; then
        result=passed
    else
        result=failed
        failures=$((failures + 1))
    fi
    printf '%s\t%s\t%s\t%s\n' "$framework" "$stage" "$result" \
        "${log#"$report_dir/"}" >> "$matrix_tsv"
    printf '[matrix] %-7s %-24s %s\n' "$framework" "$stage" "$result"
}

if [[ $skip_build -eq 0 ]]; then
    run_stage common build "$cassotis_root/scripts/build.sh"
fi

dictionary_args=(--dictionary "$dictionary_path" --skip-build --no-enable)
if [[ -n "$traditional_dictionary_path" ]]; then
    dictionary_args+=(--dictionary-traditional "$traditional_dictionary_path")
fi
if [[ $skip_install -eq 0 ]]; then
    run_stage ibus install \
        "$cassotis_root/scripts/install_ibus.sh" "${dictionary_args[@]}"
    run_stage fcitx5 install \
        "$cassotis_root/scripts/install_fcitx5.sh" "${dictionary_args[@]}"
fi

run_stage ibus desktop-daemon \
    "$cassotis_root/scripts/verify_ibus.sh"
run_stage fcitx5 isolated-native \
    "$cassotis_root/scripts/verify_fcitx5.sh" \
        --dictionary "$dictionary_path" --installed
if [[ $skip_desktop -eq 0 ]]; then
    run_stage fcitx5 desktop-discovery \
        "$cassotis_root/scripts/verify_fcitx5.sh" \
            --dictionary "$dictionary_path" --installed --desktop
fi

distro='unknown'
if [[ -r /etc/os-release ]]; then
    distro="$(. /etc/os-release; printf '%s' "${PRETTY_NAME:-unknown}")"
fi
desktop="${XDG_CURRENT_DESKTOP:-unknown}"
session_type="${XDG_SESSION_TYPE:-unknown}"
if cassotis_prepare_desktop_session_environment; then
    desktop="${XDG_CURRENT_DESKTOP:-$desktop}"
    session_type="${XDG_SESSION_TYPE:-$session_type}"
fi
{
    printf '# Cassotis IME platform matrix\n\n'
    printf -- '- Distribution: `%s`\n' "$distro"
    printf -- '- Architecture: `%s`\n' "$(uname -m)"
    printf -- '- Desktop: `%s`\n' "$desktop"
    printf -- '- Session: `%s`\n\n' "$session_type"
    printf '| Framework | Stage | Result | Log |\n'
    printf '| --- | --- | --- | --- |\n'
    tail -n +2 "$matrix_tsv" | while IFS=$'\t' read -r framework stage result log; do
        printf '| %s | %s | %s | `%s` |\n' \
            "$framework" "$stage" "$result" "$log"
    done
    printf '\nIBus uses a real desktop-daemon input context. Fcitx 5 uses its '
    printf 'official native test frontend and, unless skipped, real desktop '
    printf 'daemon discovery/reload. Application focus and visual appearance '
    printf 'remain manual release checks.\n'
} > "$matrix_md"

printf 'platform_matrix.report=%s\n' "$matrix_md"
[[ $failures -eq 0 ]] || cassotis_die "$failures platform-matrix stage(s) failed"
printf 'platform_matrix.validation=passed\n'
