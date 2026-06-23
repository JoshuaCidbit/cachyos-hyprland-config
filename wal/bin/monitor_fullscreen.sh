#!/usr/bin/env bash
FULLSCREEN_LOCK="/tmp/hypr-fullscreen.lock"
ARBITER="$HOME/.config/wal/bin/wallpaper_arbiter.sh"

while ! hyprctl version &>/dev/null; do sleep 0.5; done

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
while [ ! -S "$SOCKET" ]; do sleep 0.5; done

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        "fullscreen>>1"|"fullscreen>>0")
            # Contar ventanas fullscreen activas en este momento
            COUNT=$(hyprctl clients -j | \
                    python3 -c "import sys,json; print(sum(1 for w in json.load(sys.stdin) if w.get('fullscreen',0) > 0))")

            if [[ "$COUNT" -gt 0 ]]; then
                touch "$FULLSCREEN_LOCK"
            else
                rm -f "$FULLSCREEN_LOCK"
            fi

            sleep 0.5
            "$ARBITER"
            ;;
    esac
done