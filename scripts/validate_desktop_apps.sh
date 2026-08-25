#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

interactive=0
gtk_versions=both
focus_timeout=30

usage() {
    cat <<'EOF'
Usage: scripts/validate_desktop_apps.sh [OPTIONS]

Runs the automatic installed IBus-daemon matrix. With --interactive, it also
opens real GTK input fields and waits for desktop focus before injecting input.

Options:
  --interactive          Run the real GTK application checks.
  --gtk 3|4|both         GTK versions to check (default: both).
  --focus-timeout SEC    Per-window focus timeout (default: 30).
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --interactive)
            interactive=1
            ;;
        --gtk)
            [[ $# -ge 2 ]] || cassotis_die "--gtk requires a value"
            gtk_versions="$2"
            shift
            ;;
        --focus-timeout)
            [[ $# -ge 2 ]] || cassotis_die "--focus-timeout requires a value"
            focus_timeout="$2"
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown desktop validation option: $1"
            ;;
    esac
    shift
done

[[ "$gtk_versions" == 3 || "$gtk_versions" == 4 ||
   "$gtk_versions" == both ]] ||
    cassotis_die "--gtk must be 3, 4, or both"
[[ "$focus_timeout" =~ ^[0-9]+([.][0-9]+)?$ ]] ||
    cassotis_die "--focus-timeout must be a positive number"
[[ "$focus_timeout" != 0 && "$focus_timeout" != 0.0 ]] ||
    cassotis_die "--focus-timeout must be greater than zero"

cassotis_require_linux
"$cassotis_root/scripts/verify_ibus.sh"

if [[ $interactive -eq 0 ]]; then
    printf 'desktop_application_matrix=automatic-only\n'
    exit 0
fi

cassotis_require_command python3
cassotis_prepare_ibus_environment ||
    cassotis_die "no active desktop IBus daemon was found"
[[ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]] ||
    cassotis_die "interactive checks require a graphical desktop session"

active_engine="$(ibus engine 2>/dev/null || true)"
[[ "$active_engine" == cassotis ]] ||
    cassotis_die "select Cassotis before interactive validation (active: ${active_engine:-none})"

run_gtk_check() {
    local version="$1"
    python3 -c "import gi; gi.require_version('Gtk', '$version.0'); gi.require_version('Atspi', '2.0')"
    python3 "$cassotis_root/tools/integration/cassotis_gtk_smoke.py" \
        --gtk "$version" --focus-timeout "$focus_timeout"
}

if [[ "$gtk_versions" == 3 || "$gtk_versions" == both ]]; then
    run_gtk_check 3
fi
if [[ "$gtk_versions" == 4 || "$gtk_versions" == both ]]; then
    run_gtk_check 4
fi

printf 'desktop_application_matrix=ok\n'
