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
    hyprctl eval 'hl.config({
        general = { gaps_in = 0, gaps_out = 0 },
        animations = { enabled = false },
        decoration = {
            shadow = { enabled = false },
            blur = { enabled = false },
            rounding = 0,
        },
    })'
    "$ARBITER"
    notify-send "Gamemode" "ON — VRAM liberada"
fi