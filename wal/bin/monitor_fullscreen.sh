#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

source "${LIB_DIR}/config.sh"
source "${LIB_DIR}/backend.sh"
source "${LIB_DIR}/media.sh"

GAMEMODE_LOCK="/tmp/hypr-gamemode.lock"
FULLSCREEN_LOCK="/tmp/hypr-fullscreen.lock"

while ! hyprctl version &>/dev/null; do sleep 0.5; done

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
while [ ! -S "$SOCKET" ]; do sleep 0.5; done

update_state() {
    local count
    count=$(hyprctl clients -j | jq '[.[] | select(.fullscreen > 0)] | length')

    if [[ "$count" -gt 0 ]]; then
        touch "$FULLSCREEN_LOCK"
    else
        rm -f "$FULLSCREEN_LOCK"
    fi

    # Aplicar estado directamente con los helpers de backend,
    # sin recargar todo el stack de librerías
    if [[ -f "$GAMEMODE_LOCK" || -f "$FULLSCREEN_LOCK" ]]; then
        stop_video_backend
    else
        apply_last_wallpaper
    fi
}

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        "fullscreen>>1"|"fullscreen>>0")
            sleep 0.3
            update_state
            ;;
    esac
done
