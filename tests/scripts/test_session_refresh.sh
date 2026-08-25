#!/usr/bin/env bash

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
refresh="$root/packaging/session/cassotis-refresh-sessions"
temporary_dir="$(mktemp -d)"
trap 'rm -rf -- "$temporary_dir"' EXIT

mock_bin="$temporary_dir/bin"
state="$temporary_dir/state"
mkdir -p "$mock_bin" "$state"

cat > "$mock_bin/systemctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$*" in
    '--user show-environment')
        printf 'XDG_CURRENT_DESKTOP=GNOME\nXDG_SESSION_TYPE=wayland\n'
        ;;
    '--user is-active --quiet org.freedesktop.IBus.session.GNOME.service')
        [[ "${MOCK_MODE:-ibus}" == ibus ]]
        ;;
    '--user restart org.freedesktop.IBus.session.GNOME.service')
        : > "$MOCK_STATE/ibus-restarted"
        ;;
    '--user cat fcitx5.service')
        exit 1
        ;;
    *)
        exit 1
        ;;
esac
EOF

cat > "$mock_bin/gsettings" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
operation="$1"
key="$3"
case "$operation" in
    writable)
        printf 'true\n'
        ;;
    get)
        cat "$MOCK_STATE/$key"
        ;;
    set)
        printf '%s\n' "$4" > "$MOCK_STATE/$key"
        ;;
    *)
        exit 2
        ;;
esac
EOF

cat > "$mock_bin/ibus" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
    list-engine)
        [[ -f "$MOCK_STATE/ibus-restarted" ]] || exit 0
        printf '  cassotis - Cassotis IME\n'
        ;;
    address)
        [[ "${MOCK_MODE:-ibus}" == ibus ]] || exit 1
        printf 'unix:path=/tmp/mock-ibus\n'
        ;;
    *)
        exit 0
        ;;
esac
EOF

cat > "$mock_bin/fcitx5-remote" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ "${MOCK_MODE:-ibus}" == fcitx ]] || exit 1
case "${1:-}" in
    --check)
        [[ ! -f "$MOCK_STATE/fcitx-stopped" ]]
        ;;
    -e)
        : > "$MOCK_STATE/fcitx-stopped"
        ;;
    *)
        exit 0
        ;;
esac
EOF

cat > "$mock_bin/fcitx5" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ "${1:-}" == -d ]]
rm -f -- "$MOCK_STATE/fcitx-stopped"
: > "$MOCK_STATE/fcitx-restarted"
EOF

cat > "$mock_bin/sleep" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

chmod +x "$mock_bin"/* "$refresh"
printf "[('xkb', 'us'), ('ibus', 'libpinyin')]\n" > "$state/sources"
printf "[('ibus', 'libpinyin'), ('xkb', 'us')]\n" > "$state/mru-sources"
printf 'uint32 1\n' > "$state/current"

MOCK_STATE="$state" \
PATH="$mock_bin:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$temporary_dir/runtime" \
DBUS_SESSION_BUS_ADDRESS='unix:path=/tmp/mock-session' \
    "$refresh" --enable-ibus-source --quiet

[[ -f "$state/ibus-restarted" ]]
[[ "$(<"$state/sources")" == \
   "[('xkb', 'us'), ('ibus', 'libpinyin'), ('ibus', 'cassotis')]" ]]
[[ "$(<"$state/mru-sources")" == \
   "[('ibus', 'cassotis'), ('ibus', 'libpinyin'), ('xkb', 'us')]" ]]
[[ "$(<"$state/current")" == 'uint32 1' ]]

rm -f -- "$state/ibus-restarted"
MOCK_MODE=fcitx \
MOCK_STATE="$state" \
PATH="$mock_bin:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$temporary_dir/runtime" \
DBUS_SESSION_BUS_ADDRESS='unix:path=/tmp/mock-session' \
    "$refresh" --quiet

[[ -f "$state/fcitx-restarted" ]]
[[ ! -f "$state/fcitx-stopped" ]]

printf 'session_refresh=ok\n'
