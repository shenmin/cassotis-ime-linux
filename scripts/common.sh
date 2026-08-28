#!/usr/bin/env bash

if [[ -n "${CASSOTIS_BUILD_COMMON_LOADED:-}" ]]; then
    return 0
fi
readonly CASSOTIS_BUILD_COMMON_LOADED=1

readonly cassotis_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

cassotis_die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

cassotis_require_command() {
    local command_name="$1"
    command -v "$command_name" >/dev/null 2>&1 ||
        cassotis_die "required command not found: $command_name"
}

cassotis_require_linux() {
    cassotis_require_command uname
    local host_os
    host_os="$(uname -s)"
    [[ "$host_os" == "Linux" ]] ||
        cassotis_die "this script must run on Linux (detected: $host_os)"
}

cassotis_resolve_fpc() {
    local requested="${FPC:-fpc}"
    local compiler_path

    if [[ "$requested" == */* ]]; then
        [[ -x "$requested" ]] ||
            cassotis_die "FPC compiler is not executable: $requested"
        compiler_path="$(cd "$(dirname "$requested")" && pwd -P)/$(basename "$requested")"
    else
        compiler_path="$(command -v "$requested" 2>/dev/null || true)"
        [[ -n "$compiler_path" ]] ||
            cassotis_die "FPC compiler not found; install FPC or set FPC"
    fi

    local target_os
    target_os="$($compiler_path -iTO 2>/dev/null | tr -d '\r[:space:]' | tr '[:upper:]' '[:lower:]')"
    [[ "$target_os" == "linux" ]] ||
        cassotis_die "FPC must target Linux (detected: ${target_os:-unknown})"

    CASSOTIS_FPC_BIN="$compiler_path"
    export CASSOTIS_FPC_BIN
}

cassotis_safe_clean_build() {
    cassotis_require_command realpath
    local resolved_root
    local resolved_build
    resolved_root="$(realpath -m -- "$cassotis_root")"
    resolved_build="$(realpath -m -- "$cassotis_root/build")"
    [[ "$resolved_build" == "$resolved_root/build" ]] ||
        cassotis_die "refusing to clean unexpected path: $resolved_build"
    rm -rf -- "$resolved_build"
}

cassotis_require_executable() {
    local path="$1"
    [[ -x "$path" ]] || cassotis_die "executable not found: $path"
}

cassotis_process_uses_executable() {
    local process_id="$1"
    local target_path="$2"
    local executable_path

    executable_path="$(readlink "/proc/$process_id/exe" 2>/dev/null || true)"
    [[ "$executable_path" == "$target_path" ||
       "$executable_path" == "$target_path (deleted)" ]]
}

cassotis_stop_executable_by_path() {
    local target_path="$1"
    local executable_link
    local process_id
    local attempt
    local any_running
    local -a process_ids=()

    [[ "$target_path" == /* ]] ||
        cassotis_die "executable stop path must be absolute: $target_path"
    for executable_link in /proc/[0-9]*/exe; do
        process_id="${executable_link#/proc/}"
        process_id="${process_id%/exe}"
        if cassotis_process_uses_executable "$process_id" "$target_path"; then
            process_ids+=("$process_id")
        fi
    done
    [[ ${#process_ids[@]} -gt 0 ]] || return 0

    kill -TERM "${process_ids[@]}" 2>/dev/null || true
    for ((attempt = 0; attempt < 40; attempt += 1)); do
        any_running=0
        for process_id in "${process_ids[@]}"; do
            if cassotis_process_uses_executable "$process_id" "$target_path"; then
                any_running=1
                break
            fi
        done
        [[ $any_running -eq 0 ]] && return 0
        sleep 0.05
    done

    for process_id in "${process_ids[@]}"; do
        if cassotis_process_uses_executable "$process_id" "$target_path"; then
            kill -KILL "$process_id" 2>/dev/null || true
        fi
    done
    for ((attempt = 0; attempt < 20; attempt += 1)); do
        any_running=0
        for process_id in "${process_ids[@]}"; do
            if cassotis_process_uses_executable "$process_id" "$target_path"; then
                any_running=1
                break
            fi
        done
        [[ $any_running -eq 0 ]] && return 0
        sleep 0.05
    done
    return 1
}

cassotis_ibus_system_component_dir() {
    if command -v pkg-config >/dev/null 2>&1 &&
       pkg-config --exists ibus-1.0 2>/dev/null; then
        pkg-config --variable=datadir ibus-1.0 | sed 's|/*$|/ibus/component|'
        return
    fi
    if [[ -d /usr/share/ibus/component ]]; then
        printf '%s\n' /usr/share/ibus/component
    elif [[ -d /usr/local/share/ibus/component ]]; then
        printf '%s\n' /usr/local/share/ibus/component
    else
        printf '%s\n' /usr/share/ibus/component
    fi
}

cassotis_prepare_ibus_environment() {
    local user_id="${UID:-$(id -u)}"
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$user_id}"
    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    local bus_dir="$config_home/ibus/bus"
    local bus_file
    local daemon_pid
    local address
    local -a bus_files=()

    if [[ -z "${XDG_RUNTIME_DIR:-}" && -d "$runtime_dir" ]]; then
        XDG_RUNTIME_DIR="$runtime_dir"
        export XDG_RUNTIME_DIR
    fi
    if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" &&
          -S "$runtime_dir/bus" ]]; then
        DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime_dir/bus"
        export DBUS_SESSION_BUS_ADDRESS
    fi
    if [[ -n "${IBUS_ADDRESS:-}" ]]; then
        return 0
    fi
    [[ -d "$bus_dir" ]] || return 1

    shopt -s nullglob
    bus_files=("$bus_dir"/*)
    shopt -u nullglob
    for bus_file in "${bus_files[@]}"; do
        daemon_pid="$(sed -n 's/^IBUS_DAEMON_PID=//p' "$bus_file")"
        address="$(sed -n 's/^IBUS_ADDRESS=//p' "$bus_file")"
        if [[ "$daemon_pid" =~ ^[0-9]+$ && -n "$address" &&
              -r "/proc/$daemon_pid/comm" &&
              "$(<"/proc/$daemon_pid/comm")" == ibus-daemon ]]; then
            IBUS_ADDRESS="$address"
            export IBUS_ADDRESS
            return 0
        fi
    done
    return 1
}

cassotis_prepare_desktop_session_environment() {
    local user_id="${UID:-$(id -u)}"
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$user_id}"
    local variable_name
    local variable_value

    if [[ -z "${XDG_RUNTIME_DIR:-}" && -d "$runtime_dir" ]]; then
        XDG_RUNTIME_DIR="$runtime_dir"
        export XDG_RUNTIME_DIR
    fi
    if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" &&
          -S "$runtime_dir/bus" ]]; then
        DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime_dir/bus"
        export DBUS_SESSION_BUS_ADDRESS
    fi
    [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]] || return 1

    if command -v systemctl >/dev/null 2>&1 &&
       systemctl --user show-environment >/dev/null 2>&1; then
        while IFS='=' read -r variable_name variable_value; do
            case "$variable_name" in
                DISPLAY|WAYLAND_DISPLAY|XAUTHORITY|XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE)
                    printf -v "$variable_name" '%s' "$variable_value"
                    export "$variable_name"
                    ;;
            esac
        done < <(systemctl --user show-environment)
    fi
    return 0
}

cassotis_gnome_input_sources_capture() {
    local schema='org.gnome.desktop.input-sources'

    CASSOTIS_GNOME_INPUT_SOURCES_CAPTURED=0
    CASSOTIS_GNOME_INPUT_SOURCES_MRU_CAPTURED=0
    CASSOTIS_GNOME_INPUT_SOURCES_CURRENT_CAPTURED=0
    CASSOTIS_GNOME_INPUT_SOURCES_VALUE=''
    CASSOTIS_GNOME_INPUT_SOURCES_MRU_VALUE=''
    CASSOTIS_GNOME_INPUT_SOURCES_CURRENT_VALUE=''

    command -v gsettings >/dev/null 2>&1 || return 1
    [[ "$(gsettings writable "$schema" sources 2>/dev/null || true)" == \
       'true' ]] || return 1
    CASSOTIS_GNOME_INPUT_SOURCES_VALUE="$(
        gsettings get "$schema" sources
    )" || return 1
    CASSOTIS_GNOME_INPUT_SOURCES_CAPTURED=1

    if [[ "$(gsettings writable "$schema" mru-sources \
                2>/dev/null || true)" == 'true' ]] &&
       CASSOTIS_GNOME_INPUT_SOURCES_MRU_VALUE="$(
           gsettings get "$schema" mru-sources 2>/dev/null
       )"; then
        CASSOTIS_GNOME_INPUT_SOURCES_MRU_CAPTURED=1
    fi
    if [[ "$(gsettings writable "$schema" current \
                2>/dev/null || true)" == 'true' ]] &&
       CASSOTIS_GNOME_INPUT_SOURCES_CURRENT_VALUE="$(
           gsettings get "$schema" current 2>/dev/null
       )"; then
        CASSOTIS_GNOME_INPUT_SOURCES_CURRENT_CAPTURED=1
    fi
    return 0
}

cassotis_gnome_input_sources_restore() {
    local schema='org.gnome.desktop.input-sources'
    local restored

    [[ "${CASSOTIS_GNOME_INPUT_SOURCES_CAPTURED:-0}" == 1 ]] || return 0
    gsettings set "$schema" sources \
        "$CASSOTIS_GNOME_INPUT_SOURCES_VALUE" || return 1
    if [[ "${CASSOTIS_GNOME_INPUT_SOURCES_MRU_CAPTURED:-0}" == 1 ]]; then
        gsettings set "$schema" mru-sources \
            "$CASSOTIS_GNOME_INPUT_SOURCES_MRU_VALUE" || return 1
    fi
    if [[ "${CASSOTIS_GNOME_INPUT_SOURCES_CURRENT_CAPTURED:-0}" == 1 ]]; then
        gsettings set "$schema" current \
            "$CASSOTIS_GNOME_INPUT_SOURCES_CURRENT_VALUE" || return 1
    fi

    restored="$(gsettings get "$schema" sources)" || return 1
    [[ "$restored" == "$CASSOTIS_GNOME_INPUT_SOURCES_VALUE" ]] || return 1
    if [[ "${CASSOTIS_GNOME_INPUT_SOURCES_MRU_CAPTURED:-0}" == 1 ]]; then
        restored="$(gsettings get "$schema" mru-sources)" || return 1
        [[ "$restored" == "$CASSOTIS_GNOME_INPUT_SOURCES_MRU_VALUE" ]] ||
            return 1
    fi
    if [[ "${CASSOTIS_GNOME_INPUT_SOURCES_CURRENT_CAPTURED:-0}" == 1 ]]; then
        restored="$(gsettings get "$schema" current)" || return 1
        [[ "$restored" == "$CASSOTIS_GNOME_INPUT_SOURCES_CURRENT_VALUE" ]] ||
            return 1
    fi
}

cassotis_gnome_input_source_add() {
    local source_type="$1"
    local source_name="$2"
    local schema='org.gnome.desktop.input-sources'
    local source="('$source_type', '$source_name')"
    local sources
    local mru_sources

    command -v gsettings >/dev/null 2>&1 || return 1
    [[ "$(gsettings writable "$schema" sources 2>/dev/null || true)" == \
       'true' ]] || return 1
    sources="$(gsettings get "$schema" sources)" || return 1
    if [[ "$sources" != *"$source"* ]]; then
        if [[ "$sources" == '@a(ss) []' || "$sources" == '[]' ]]; then
            sources="[$source]"
        else
            sources="${sources%]}"
            sources="$sources, $source]"
        fi
        gsettings set "$schema" sources "$sources" || return 1
    fi

    mru_sources="$(gsettings get "$schema" mru-sources 2>/dev/null || true)"
    if [[ -n "$mru_sources" && "$mru_sources" != *"$source"* ]]; then
        if [[ "$mru_sources" == '@a(ss) []' || "$mru_sources" == '[]' ]]; then
            mru_sources="[$source]"
        else
            mru_sources="${mru_sources#\[}"
            mru_sources="[$source, $mru_sources"
        fi
        gsettings set "$schema" mru-sources "$mru_sources" || return 1
    fi
}

cassotis_gnome_input_source_select() {
    local source_type="$1"
    local source_name="$2"
    local schema='org.gnome.desktop.input-sources'
    local source="('$source_type', '$source_name')"
    local sources
    local source_prefix
    local closing_parentheses
    local source_index

    command -v gsettings >/dev/null 2>&1 || return 1
    sources="$(gsettings get "$schema" sources)" || return 1
    [[ "$sources" == *"$source"* ]] || return 1
    source_prefix="${sources%%"$source"*}"
    closing_parentheses="${source_prefix//[!)]/}"
    source_index="${#closing_parentheses}"
    gsettings set "$schema" current "uint32 $source_index" || return 1
    [[ "$(gsettings get "$schema" current)" == "uint32 $source_index" ]]
}

cassotis_gnome_input_source_remove() {
    local source_type="$1"
    local source_name="$2"
    local schema='org.gnome.desktop.input-sources'
    local source="('$source_type', '$source_name')"
    local sources
    local source_prefix
    local source_count
    local source_index
    local closing_parentheses
    local mru_sources
    local current_value
    local current_index
    local next_current

    command -v gsettings >/dev/null 2>&1 || return 1
    [[ "$(gsettings writable "$schema" sources 2>/dev/null || true)" == \
       'true' ]] || return 1
    sources="$(gsettings get "$schema" sources)" || return 1
    if [[ "$sources" == *"$source"* ]]; then
        source_prefix="${sources%%"$source"*}"
        closing_parentheses="${source_prefix//[!)]/}"
        source_index="${#closing_parentheses}"
        current_value="$(gsettings get "$schema" current 2>/dev/null || true)"
        sources="${sources/", $source"/}"
        sources="${sources/"$source, "/}"
        sources="${sources/"$source"/}"
        [[ "$sources" != '[]' ]] || sources='@a(ss) []'
        gsettings set "$schema" sources "$sources" || return 1

        if [[ "$sources" == '@a(ss) []' || "$sources" == '[]' ]]; then
            source_count=0
        else
            closing_parentheses="${sources//[!)]/}"
            source_count="${#closing_parentheses}"
        fi
        if [[ "$current_value" =~ ^uint32[[:space:]]+([0-9]+)$ ]]; then
            current_index="${BASH_REMATCH[1]}"
            next_current="$current_index"
            if ((current_index > source_index)); then
                next_current=$((current_index - 1))
            elif ((current_index == source_index &&
                    current_index >= source_count)); then
                if ((source_count > 0)); then
                    next_current=$((source_count - 1))
                else
                    next_current=0
                fi
            fi
            if [[ "$next_current" != "$current_index" ]]; then
                gsettings set "$schema" current \
                    "uint32 $next_current" || return 1
            fi
        fi
    fi

    mru_sources="$(gsettings get "$schema" mru-sources 2>/dev/null || true)"
    if [[ "$mru_sources" == *"$source"* ]]; then
        mru_sources="${mru_sources/", $source"/}"
        mru_sources="${mru_sources/"$source, "/}"
        mru_sources="${mru_sources/"$source"/}"
        [[ "$mru_sources" != '[]' ]] || mru_sources='@a(ss) []'
        gsettings set "$schema" mru-sources "$mru_sources" || return 1
    fi
}

cassotis_atomic_install() {
    local source_path="$1"
    local destination_path="$2"
    local mode="$3"
    local destination_dir
    local temporary_path

    destination_dir="$(dirname "$destination_path")"
    temporary_path="$(mktemp "$destination_dir/.cassotis-install.XXXXXX")"
    if ! install -m "$mode" "$source_path" "$temporary_path"; then
        rm -f -- "$temporary_path"
        return 1
    fi
    if ! mv -f -- "$temporary_path" "$destination_path"; then
        rm -f -- "$temporary_path"
        return 1
    fi
}

cassotis_stage_neural_runtime() {
    local source_dir="$1"
    local destination_dir="$2"
    local file_name

    install -d -m 0755 "$destination_dir/pinyin_transformer" \
        "$destination_dir/local_completion"
    for file_name in libcassotis_pinyin_transformer_ort.so \
                     libonnxruntime.so.1.20.1 \
                     libonnxruntime_providers_shared.so; do
        [[ -r "$source_dir/$file_name" ]] ||
            cassotis_die "neural runtime artifact not found: $source_dir/$file_name"
        install -m 0755 "$source_dir/$file_name" \
            "$destination_dir/$file_name"
    done
    ln -sfn libonnxruntime.so.1.20.1 \
        "$destination_dir/libonnxruntime.so.1"
    ln -sfn libonnxruntime.so.1 "$destination_dir/libonnxruntime.so"
    for file_name in pinyin_difference_reranker_int8.onnx vocab.json; do
        install -m 0644 "$source_dir/pinyin_transformer/$file_name" \
            "$destination_dir/pinyin_transformer/$file_name"
    done
    for file_name in local_completion_path_ranker_int8.onnx \
                     local_completion_index.bin model_manifest.json; do
        install -m 0644 "$source_dir/local_completion/$file_name" \
            "$destination_dir/local_completion/$file_name"
    done
}

cassotis_atomic_install_neural_runtime() {
    local source_dir="$1"
    local destination_dir="$2"
    local file_name

    install -d -m 0700 "$destination_dir" \
        "$destination_dir/pinyin_transformer" \
        "$destination_dir/local_completion"
    for file_name in libcassotis_pinyin_transformer_ort.so \
                     libonnxruntime.so.1.20.1 \
                     libonnxruntime_providers_shared.so; do
        cassotis_atomic_install "$source_dir/$file_name" \
            "$destination_dir/$file_name" 0755
    done
    ln -sfn libonnxruntime.so.1.20.1 \
        "$destination_dir/libonnxruntime.so.1"
    ln -sfn libonnxruntime.so.1 "$destination_dir/libonnxruntime.so"
    for file_name in pinyin_difference_reranker_int8.onnx vocab.json; do
        cassotis_atomic_install \
            "$source_dir/pinyin_transformer/$file_name" \
            "$destination_dir/pinyin_transformer/$file_name" 0644
    done
    for file_name in local_completion_path_ranker_int8.onnx \
                     local_completion_index.bin model_manifest.json; do
        cassotis_atomic_install "$source_dir/local_completion/$file_name" \
            "$destination_dir/local_completion/$file_name" 0644
    done
}

cassotis_remove_neural_runtime() {
    local destination_dir="$1"

    rm -f -- \
        "$destination_dir/cassotis-neural-runtime-smoke" \
        "$destination_dir/libcassotis_pinyin_transformer_ort.so" \
        "$destination_dir/libonnxruntime.so" \
        "$destination_dir/libonnxruntime.so.1" \
        "$destination_dir/libonnxruntime.so.1.20.1" \
        "$destination_dir/libonnxruntime_providers_shared.so" \
        "$destination_dir/pinyin_transformer/pinyin_difference_reranker_int8.onnx" \
        "$destination_dir/pinyin_transformer/vocab.json" \
        "$destination_dir/local_completion/local_completion_path_ranker_int8.onnx" \
        "$destination_dir/local_completion/local_completion_index.bin" \
        "$destination_dir/local_completion/model_manifest.json"
    rmdir -- "$destination_dir/pinyin_transformer" \
        "$destination_dir/local_completion" 2>/dev/null || true
}
