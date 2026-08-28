#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)/scripts/common.sh"

temporary_dir="$(mktemp -d)"
process_ids=()
cleanup() {
    local process_id

    for process_id in "${process_ids[@]}"; do
        kill -KILL "$process_id" 2>/dev/null || true
    done
    rm -rf -- "$temporary_dir"
}
trap cleanup EXIT

start_test_process() {
    local executable_path="$1"
    local attempt

    "$executable_path" -c 'import time; time.sleep(60)' &
    started_pid=$!
    process_ids+=("$started_pid")
    for ((attempt = 0; attempt < 20; attempt += 1)); do
        cassotis_process_uses_executable "$started_pid" "$executable_path" &&
            return 0
        sleep 0.05
    done
    return 1
}

python_binary="$(readlink -f "$(command -v python3)")"
target="$temporary_dir/cassotis target"
unrelated="$temporary_dir/unrelated"
cp -- "$python_binary" "$target"
cp -- "$python_binary" "$unrelated"
chmod +x "$target" "$unrelated"

started_pid=''
start_test_process "$target"
target_pid="$started_pid"
start_test_process "$unrelated"
unrelated_pid="$started_pid"
cassotis_stop_executable_by_path "$target"
! cassotis_process_uses_executable "$target_pid" "$target"
cassotis_process_uses_executable "$unrelated_pid" "$unrelated"

cp -- "$python_binary" "$target"
chmod +x "$target"
start_test_process "$target"
deleted_pid="$started_pid"
rm -f -- "$target"
cassotis_process_uses_executable "$deleted_pid" "$target"
cassotis_stop_executable_by_path "$target"
! cassotis_process_uses_executable "$deleted_pid" "$target"
cassotis_process_uses_executable "$unrelated_pid" "$unrelated"

printf 'process_stop=ok\n'
