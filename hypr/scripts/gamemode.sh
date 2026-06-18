#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="/tmp/hypr-gamemode.lock"
WALLPAPER_SCRIPT="$HOME/.config/wal/bin/wallpaper_picker.sh"

if [[ -f "$STATE_FILE" ]]; then
    # ---- SALIR de gamemode ----
    hyprctl reload
    "$WALLPAPER_SCRIPT" --restore
    notify-send "Gamemode" "OFF"
    rm -f "$STATE_FILE"
else
    # ---- ENTRAR a gamemode ----
    hyprctl eval 'hl.config({
        general = { gaps_in = 0, gaps_out = 0 },
        animations = { enabled = false },
        decoration = {
            shadow = { enabled = false },
            blur = { enabled = false },
            rounding = 0,
        },
    })'
    "$WALLPAPER_SCRIPT" --kill
    notify-send "Gamemode" "ON — VRAM liberada"
    touch "$STATE_FILE"
fi
