#!/usr/bin/env bash
set -euo pipefail

FULLSCREEN_LOCK="/tmp/hypr-fullscreen.lock"
ARBITER="$HOME/.config/wal/bin/wallpaper_arbiter.sh"

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

    "$ARBITER"
}

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        "fullscreen>>1"|"fullscreen>>0")
            sleep 0.3
            update_state
            ;;
    esac
done