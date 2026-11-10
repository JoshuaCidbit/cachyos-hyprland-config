#!/usr/bin/env bash
# Shared wallpaper/GameMode locks and Caelestia IPC sync.

GAMEMODE_LOCK="${GAMEMODE_LOCK:-/tmp/hypr-gamemode.lock}"
FULLSCREEN_LOCK="${FULLSCREEN_LOCK:-/tmp/hypr-fullscreen.lock}"
WALLPAPER_LOCK="${WALLPAPER_LOCK:-/tmp/hypr-wallpaper.lock}"

# 0 = enabled, 1 = disabled, 2 = unknown.
gamemode_ipc_enabled() {
    local out
    if ! out="$(timeout 2 caelestia shell gameMode isEnabled 2>/dev/null)"; then
        return 2
    fi
    case "${out,,}" in
        true|1)  return 0 ;;
        false|0) return 1 ;;
        *)       return 2 ;;
    esac
}

sync_gamemode_lock() {
    local rc=0
    gamemode_ipc_enabled || rc=$?
    case "$rc" in
        0) touch "$GAMEMODE_LOCK" ;;
        1) rm -f "$GAMEMODE_LOCK" ;;
        *) : ;;
    esac
    return 0
}

gamemode_active() {
    local rc=0
    gamemode_ipc_enabled || rc=$?
    case "$rc" in
        0) return 0 ;;
        1) return 1 ;;
        *) [[ -f "$GAMEMODE_LOCK" ]] ;;
    esac
}

fullscreen_active() {
    [[ -f "$FULLSCREEN_LOCK" ]]
}

wallpaper_locked() {
    gamemode_active || fullscreen_active
}

refresh_fullscreen_lock() {
    local json count
    json="$(hyprctl clients -j 2>/dev/null)" || return 0
    count="$(jq '[.[] | select(.fullscreen > 0)] | length' <<<"$json" 2>/dev/null)" || return 0
    [[ "$count" =~ ^[0-9]+$ ]] || return 0

    if (( count > 0 )); then
        touch "$FULLSCREEN_LOCK"
    else
        rm -f "$FULLSCREEN_LOCK"
    fi
    return 0
}
