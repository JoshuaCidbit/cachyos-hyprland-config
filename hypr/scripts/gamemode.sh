#!/usr/bin/env bash
set -euo pipefail

WAL_LIB="${HOME}/.config/wal/lib"
ARBITER="${HOME}/.config/wal/bin/wallpaper_arbiter.sh"

source "${WAL_LIB}/locks.sh"

notify() {
    notify-send "Gamemode" "$1" 2>/dev/null || true
}

enable_caelestia() {
    caelestia shell gameMode enable >/dev/null 2>&1
}

disable_caelestia() {
    caelestia shell gameMode disable >/dev/null 2>&1
}

enable_hyprland_fallback() {
    hyprctl eval 'hl.config({
        general = {
            gaps_in = 0,
            gaps_out = 0,
            border_size = 1,
            allow_tearing = true,
        },
        animations = { enabled = false },
        decoration = {
            shadow = { enabled = false },
            blur = { enabled = false },
            rounding = 0,
        },
    })' >/dev/null 2>&1
}

sync_gamemode_lock

if gamemode_active; then
    if disable_caelestia; then
        rm -f "$GAMEMODE_LOCK"
    else
        rm -f "$GAMEMODE_LOCK"
        hyprctl reload >/dev/null 2>&1 || true
        notify "OFF (fallback)"
    fi
else
    if enable_caelestia; then
        touch "$GAMEMODE_LOCK"
    else
        touch "$GAMEMODE_LOCK"
        if enable_hyprland_fallback; then
            notify "ON (fallback)"
        else
            notify "ON (fallback failed)"
        fi
    fi
fi

"$ARBITER" >/dev/null 2>&1 || true
