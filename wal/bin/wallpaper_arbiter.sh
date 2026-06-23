#!/usr/bin/env bash
# Árbitro: decide el estado de mpvpaper según todas las flags activas
GAMEMODE_LOCK="/tmp/hypr-gamemode.lock"
FULLSCREEN_LOCK="/tmp/hypr-fullscreen.lock"
WALLPAPER_SCRIPT="$HOME/.config/wal/bin/wallpaper_picker.sh"

if [[ -f "$GAMEMODE_LOCK" || -f "$FULLSCREEN_LOCK" ]]; then
    "$WALLPAPER_SCRIPT" --kill
else
    "$WALLPAPER_SCRIPT" --restore
fi