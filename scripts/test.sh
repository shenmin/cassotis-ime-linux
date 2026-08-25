#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

skip_build=0

usage() {
    printf 'Usage: scripts/test.sh [--skip-build]\n'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-build)
            skip_build=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            cassotis_die "unknown test option: $1"
            ;;
    esac
    shift
done

cassotis_require_linux

if [[ $skip_build -eq 0 ]]; then
    "$cassotis_root/scripts/build.sh"
fi

engine="$cassotis_root/build/bin/cassotis-engine"
tests="$cassotis_root/build/bin/cassotis-core-tests"
ibus_adapter="$cassotis_root/build/bin/ibus-engine-cassotis"
installed_dictionary="${CASSOTIS_DICTIONARY:-${XDG_DATA_HOME:-$HOME/.local/share}/cassotis-ime/dict_sc.db}"
cassotis_require_executable "$engine"
cassotis_require_executable "$tests"
cassotis_require_command python3

python3 "$cassotis_root/tools/parity/validate_docs.py"
python3 "$cassotis_root/scripts/fcitx5_profile.py" self-test
bash "$cassotis_root/tests/scripts/test_gnome_input_sources.sh"
bash "$cassotis_root/tests/scripts/test_session_refresh.sh"

"$engine" --self-test

if [[ -x "$ibus_adapter" && -f "$installed_dictionary" ]]; then
    adapter_test_dir="$(mktemp -d "${TMPDIR:-/tmp}/cassotis-adapter-test.XXXXXX")"
    trap 'rm -rf -- "$adapter_test_dir"' EXIT
    CASSOTIS_DICTIONARY="$installed_dictionary" \
    CASSOTIS_USER_DICTIONARY="$adapter_test_dir/user_dict.db" \
        "$ibus_adapter" --self-test
    bash "$cassotis_root/tests/scripts/test_engine_singleton_socket.sh" \
        "$installed_dictionary"
    rm -rf -- "$adapter_test_dir"
    trap - EXIT
else
    printf '[test] IBus adapter self-test skipped (dictionary unavailable)\n'
fi

parse_output="$("$engine" --parse "xi'an")"
if [[ "$parse_output" != $'0:2:xi\n3:2:an' ]]; then
    cassotis_die "engine parser CLI smoke test failed"
fi

schemes=(microsoft xiaohe ziranma sogou ziguang pinyinjiajia)
codes=(nihk nihc nihk nihk nihq nihd)
for index in "${!schemes[@]}"; do
    shuangpin_output="$("$engine" --decode-shuangpin \
        "${schemes[$index]}" "${codes[$index]}")"
    if ! grep -qx 'canonical=nihao' <<<"$shuangpin_output" ||
        ! grep -qx 'valid=1' <<<"$shuangpin_output"; then
        cassotis_die "${schemes[$index]} shuangpin CLI smoke test failed"
    fi
done

fuzzy_output="$("$engine" --fuzzy zonghe)"
if ! grep -Eq ':zhonghe:.*z-zh' <<<"$fuzzy_output"; then
    cassotis_die "engine fuzzy-pinyin CLI smoke test failed"
fi

"$tests" --all --format=plain
"$cassotis_root/build/bin/cassotis-candidate-layout-tests"
"$cassotis_root/build/bin/cassotis-shortcut-match-tests"
