#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)/scripts/common.sh"

temporary_dir="$(mktemp -d)"
cleanup() {
    rm -rf -- "$temporary_dir"
}
trap cleanup EXIT

state_dir="$temporary_dir/state"
mock_bin="$temporary_dir/bin"
mkdir -p "$state_dir" "$mock_bin"

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
        cat "$MOCK_GSETTINGS_STATE/$key"
        ;;
    set)
        printf '%s\n' "$4" > "$MOCK_GSETTINGS_STATE/$key"
        ;;
    *)
        exit 2
        ;;
esac
EOF
chmod +x "$mock_bin/gsettings"

original_sources="[('xkb', 'us'), ('ibus', 'libpinyin')]"
original_mru="[('ibus', 'libpinyin'), ('xkb', 'us')]"
printf '%s\n' "$original_sources" > "$state_dir/sources"
printf '%s\n' "$original_mru" > "$state_dir/mru-sources"
printf 'uint32 1\n' > "$state_dir/current"

export MOCK_GSETTINGS_STATE="$state_dir"
PATH="$mock_bin:$PATH"
export PATH

cassotis_gnome_input_sources_capture
printf "[('xkb', 'us')]\n" > "$state_dir/sources"
printf "[('xkb', 'us')]\n" > "$state_dir/mru-sources"
printf 'uint32 0\n' > "$state_dir/current"
cassotis_gnome_input_sources_restore

[[ "$(<"$state_dir/sources")" == "$original_sources" ]]
[[ "$(<"$state_dir/mru-sources")" == "$original_mru" ]]
[[ "$(<"$state_dir/current")" == 'uint32 1' ]]

cassotis_gnome_input_source_add ibus cassotis
cassotis_gnome_input_source_add ibus cassotis
[[ "$(<"$state_dir/sources")" == \
   "[('xkb', 'us'), ('ibus', 'libpinyin'), ('ibus', 'cassotis')]" ]]
[[ "$(<"$state_dir/mru-sources")" == \
   "[('ibus', 'cassotis'), ('ibus', 'libpinyin'), ('xkb', 'us')]" ]]

cassotis_gnome_input_source_select ibus cassotis
[[ "$(<"$state_dir/current")" == 'uint32 2' ]]
cassotis_gnome_input_source_remove ibus cassotis
[[ "$(<"$state_dir/sources")" == "$original_sources" ]]
[[ "$(<"$state_dir/mru-sources")" == "$original_mru" ]]
[[ "$(<"$state_dir/current")" == 'uint32 1' ]]

printf 'gnome_input_sources=ok\n'
