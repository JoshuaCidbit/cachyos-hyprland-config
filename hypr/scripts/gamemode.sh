#!/usr/bin/env bash
set -euo pipefail
STATE_FILE="/tmp/hypr-gamemode.lock"
ARBITER="$HOME/.config/wal/bin/wallpaper_arbiter.sh"

if [[ -f "$STATE_FILE" ]]; then
    rm -f "$STATE_FILE"
    hyprctl reload
    "$ARBITER"
    notify-send "Gamemode" "OFF"
else
    touch "$STATE_FILE"
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    "$ARBITER"
    notify-send "Gamemode" "ON — VRAM liberada"
fi