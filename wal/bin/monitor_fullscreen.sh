#!/usr/bin/env bash

# Esperar a que hyprctl esté disponible
while ! hyprctl version &>/dev/null; do
    sleep 0.5
done

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Esperar a que el socket exista
while [ ! -S "$SOCKET" ]; do
    sleep 0.5
done

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        "fullscreen>>1")
            ~/.config/wal/bin/toggle_mpvpaper.sh --kill
            ;;
        "fullscreen>>0")
            sleep 0.5
            ~/.config/wal/bin/toggle_mpvpaper.sh --restore
            ;;
    esac
done
