#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

source "${LIB_DIR}/config.sh"
source "${LIB_DIR}/locks.sh"
source "${LIB_DIR}/media.sh"

ARBITER="${SCRIPT_DIR}/wallpaper_arbiter.sh"

for dep in socat jq hyprctl; do
    command -v "$dep" >/dev/null 2>&1 || {
        echo "monitor_fullscreen: missing dependency: $dep" >&2
        exit 1
    }
done

request_arbiter() {
    setsid -f "$ARBITER" >/dev/null 2>&1 || true
}

update_fullscreen() {
    local before=0 after=0
    [[ -f "$FULLSCREEN_LOCK" ]] && before=1
    refresh_fullscreen_lock
    [[ -f "$FULLSCREEN_LOCK" ]] && after=1
    if [[ "$before" != "$after" ]]; then
        request_arbiter
    fi
}

poll_gamemode() {
    local before=0 after=0
    while true; do
        before=0
        [[ -f "$GAMEMODE_LOCK" ]] && before=1
        sync_gamemode_lock
        after=0
        [[ -f "$GAMEMODE_LOCK" ]] && after=1
        if [[ "$before" != "$after" ]]; then
            request_arbiter
        fi
        sleep 2
    done
}

wait_for_hyprland() {
    local i
    for ((i = 0; i < 120; i++)); do
        hyprctl version >/dev/null 2>&1 && return 0
        sleep 0.5
    done
    return 1
}

wait_for_socket() {
    local i socket="$1"
    for ((i = 0; i < 120; i++)); do
        [[ -S "$socket" ]] && return 0
        sleep 0.5
    done
    return 1
}

wait_for_hyprland || exit 1

SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket2.sock"
wait_for_socket "$SOCKET" || exit 1

sync_gamemode_lock
update_fullscreen
request_arbiter

poll_gamemode &
POLL_PID=$!
trap 'kill "$POLL_PID" 2>/dev/null || true' EXIT

while true; do
    socat -u UNIX-CONNECT:"$SOCKET" - 2>/dev/null | while IFS= read -r line; do
        case "$line" in
            fullscreen\>\>*|openwindow\>\>*|closewindow\>\>*|movewindow\>\>*)
                sleep 0.25
                update_fullscreen
                ;;
        esac
    done
    sleep 1
done
