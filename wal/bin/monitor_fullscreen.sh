#!/usr/bin/env bash
FULLSCREEN_LOCK="/tmp/hypr-fullscreen.lock"
ARBITER="$HOME/.config/wal/bin/wallpaper_arbiter.sh"

while ! hyprctl version &>/dev/null; do sleep 0.5; done

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
while [ ! -S "$SOCKET" ]; do sleep 0.5; done

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        "fullscreen>>1")
            touch "$FULLSCREEN_LOCK"
            "$ARBITER"
            ;;
        "fullscreen>>0")
            rm -f "$FULLSCREEN_LOCK"
            sleep 0.5
            "$ARBITER"
            ;;
    esac
done