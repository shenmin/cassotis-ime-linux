#!/usr/bin/env bash

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
engine="$root/build/bin/cassotis-engine"
control="$root/build/bin/cassotis-control"
dictionary="${1:-}"

[[ -x "$engine" && -x "$control" ]]
[[ -f "$dictionary" ]]

test_dir="$(mktemp -d "${TMPDIR:-/tmp}/cassotis-singleton.XXXXXX")"
socket_path="$test_dir/engine.sock"
first_pid=''
declare -a contender_pids=()

cleanup() {
    if [[ -n "$first_pid" ]] && kill -0 "$first_pid" 2>/dev/null; then
        kill -TERM "$first_pid" 2>/dev/null || true
        wait "$first_pid" 2>/dev/null || true
    fi
    for process_id in "${contender_pids[@]}"; do
        if kill -0 "$process_id" 2>/dev/null; then
            kill -TERM "$process_id" 2>/dev/null || true
            wait "$process_id" 2>/dev/null || true
        fi
    done
    rm -rf -- "$test_dir"
}
trap cleanup EXIT

CASSOTIS_DICTIONARY="$dictionary" \
CASSOTIS_USER_DICTIONARY="$test_dir/first-user.db" \
    "$engine" --serve --socket "$socket_path" \
    >"$test_dir/first.log" 2>&1 &
first_pid=$!

for _ in {1..1200}; do
    [[ -S "$socket_path" ]] && break
    kill -0 "$first_pid" 2>/dev/null || {
        cat "$test_dir/first.log" >&2
        exit 1
    }
    sleep 0.025
done
[[ -S "$socket_path" ]] || {
    printf 'first engine did not create its socket\n' >&2
    exit 1
}

if CASSOTIS_DICTIONARY="$dictionary" \
   CASSOTIS_USER_DICTIONARY="$test_dir/second-user.db" \
       "$engine" --serve --socket "$socket_path" \
       >"$test_dir/second.log" 2>&1; then
    printf 'second engine unexpectedly acquired the same socket\n' >&2
    exit 1
fi

[[ -S "$socket_path" ]] || {
    printf 'second engine removed the first engine socket\n' >&2
    cat "$test_dir/second.log" >&2
    exit 1
}
CASSOTIS_ENGINE_SOCKET="$socket_path" \
CASSOTIS_ENGINE_PATH="$engine" \
    "$control" ping >/dev/null
CASSOTIS_ENGINE_SOCKET="$socket_path" \
    "$control" shutdown >/dev/null
wait "$first_pid"
first_pid=''

# Exercise the cold-start race hit when two framework adapters discover the
# shared engine at the same time. Exactly one contender must stay reachable.
rm -f -- "$socket_path"
for contender in {1..8}; do
    CASSOTIS_DICTIONARY="$dictionary" \
    CASSOTIS_USER_DICTIONARY="$test_dir/concurrent-$contender-user.db" \
        "$engine" --serve --socket "$socket_path" \
        >"$test_dir/concurrent-$contender.log" 2>&1 &
    contender_pids+=("$!")
done

for _ in {1..1200}; do
    running_count=0
    for process_id in "${contender_pids[@]}"; do
        if kill -0 "$process_id" 2>/dev/null; then
            running_count=$((running_count + 1))
        fi
    done
    [[ -S "$socket_path" && $running_count -eq 1 ]] && break
    sleep 0.025
done

running_count=0
for process_id in "${contender_pids[@]}"; do
    if kill -0 "$process_id" 2>/dev/null; then
        running_count=$((running_count + 1))
        first_pid="$process_id"
    fi
done
[[ -S "$socket_path" && $running_count -eq 1 ]] || {
    printf 'concurrent startup left %d engine processes\n' "$running_count" >&2
    for log_file in "$test_dir"/concurrent-*.log; do
        printf '%s:\n' "$log_file" >&2
        cat "$log_file" >&2
    done
    exit 1
}
CASSOTIS_ENGINE_SOCKET="$socket_path" \
CASSOTIS_ENGINE_PATH="$engine" \
    "$control" ping >/dev/null
CASSOTIS_ENGINE_SOCKET="$socket_path" \
    "$control" shutdown >/dev/null
wait "$first_pid"
first_pid=''
for process_id in "${contender_pids[@]}"; do
    wait "$process_id" 2>/dev/null || true
done
contender_pids=()
printf 'engine_singleton_socket=ok\n'
