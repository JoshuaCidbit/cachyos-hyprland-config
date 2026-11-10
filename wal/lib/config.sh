#!/usr/bin/env bash
# lib/config.sh — Variables de configuración y flags globales
# ─────────────────────────────────────────────────────────────

# ─── Archivo de configuración opcional ────────────────────────────────────────
# Se lee ~/.config/wal/wal.conf (o la ruta indicada en $WAL_CONF).
# Prioridad: variables de entorno > archivo de configuración > valores por defecto.

WAL_CONF="${WAL_CONF:-$HOME/.config/wal/wal.conf}"
if [[ -f "$WAL_CONF" ]]; then
    while IFS= read -r _raw || [[ -n "$_raw" ]]; do
        _line="${_raw%%$'\r'}"
        _line="${_line%%#*}"
        # Ignorar líneas vacías o sin separador de clave=valor
        [[ "$_line" == *=* ]] || continue
        _key="${_line%%=*}"
        _val="${_line#*=}"
        _key="${_key//[[:space:]]/}"
        _val="${_val//[[:space:]]/}"
        # Quitar comillas simples o dobles del valor
        _val="${_val//\"/}"
        _val="${_val/\'/}"
        case "$_key" in
            WALL_DIR)
                [[ -n "${WALL_DIR:-}" ]] || WALL_DIR="$_val"
                ;;
            WALL_TRANSITION)
                [[ -n "${WALL_TRANSITION:-}" ]] || WALL_TRANSITION="$_val"
                ;;
            WALL_TRANSITION_DUR)
                [[ -n "${WALL_TRANSITION_DUR:-}" ]] || WALL_TRANSITION_DUR="$_val"
                ;;
            WALL_TRANSITION_ANGLE)
                [[ -n "${WALL_TRANSITION_ANGLE:-}" ]] || WALL_TRANSITION_ANGLE="$_val"
                ;;
            WALL_TRANSITION_STEP)
                [[ -n "${WALL_TRANSITION_STEP:-}" ]] || WALL_TRANSITION_STEP="$_val"
                ;;
            WALL_TRANSITION_FPS)
                [[ -n "${WALL_TRANSITION_FPS:-}" ]] || WALL_TRANSITION_FPS="$_val"
                ;;
            MONITOR)
                [[ -n "${MONITOR:-}" ]] || MONITOR="$_val"
                ;;
            SIMPLE_MODE)
                [[ -n "${SIMPLE_MODE:-}" ]] || SIMPLE_MODE="$_val"
                ;;
            WALL_AUTO_ROTATE)
                [[ -n "${AUTO_ROTATE:-}" ]] || AUTO_ROTATE="$_val"
                ;;
        esac
    done < "$WAL_CONF"
fi

# ─── Rutas y herramientas ─────────────────────────────────────────────────────
WALL_DIR="${WALL_DIR:-${WALLPAPER_DIR:-$HOME/Pictures/wallpapers/1080p}}"
WAL_BIN="${WAL_BIN:-/usr/bin/wal}"
AWW_BIN="${AWW_BIN:-/usr/bin/awww}"
IMV_BIN="${IMV_BIN:-imv}"
KITTY_CONF="${KITTY_CONF:-$HOME/.cache/wal/colors-kitty.conf}"
WAL_COLORS="${HOME}/.cache/wal/colors.sh"
FRAME_CACHE="${HOME}/.cache/wallpaper_frames"
FAVORITES_FILE="${HOME}/.cache/wal/favorites"

# ─── Transición ───────────────────────────────────────────────────────────────
TRANSITION="${WALL_TRANSITION:-wipe}"
TRANSITION_DUR="${WALL_TRANSITION_DUR:-1}"
TRANSITION_ANGLE="${WALL_TRANSITION_ANGLE:-45}"
TRANSITION_STEP="${WALL_TRANSITION_STEP:-255}"
TRANSITION_FPS="${WALL_TRANSITION_FPS:-120}"
MONITOR="${MONITOR:-*}"

# ─── Historial de pywal16 ─────────────────────────────────────────────────────
WAL_HISTORY="${HOME}/.cache/wal/wal"

# ─── Estado de wallpaper / GameMode ───────────────────────────────────────────
LAST_MEDIA_FILE="${LAST_MEDIA_FILE:-$HOME/.cache/wal/last-media}"
GAMEMODE_LOCK="${GAMEMODE_LOCK:-/tmp/hypr-gamemode.lock}"
FULLSCREEN_LOCK="${FULLSCREEN_LOCK:-/tmp/hypr-fullscreen.lock}"
WALLPAPER_LOCK="${WALLPAPER_LOCK:-/tmp/hypr-wallpaper.lock}"

# ─── Flags (sobreescritos por parse_flags en flags.sh) ────────────────────────
DO_PREVIEW="${DO_PREVIEW:-false}"
SIMPLE_MODE="${SIMPLE_MODE:-false}"
SKIP_WAL="${SKIP_WAL:-false}"
KILL_MODE="${KILL_MODE:-false}"
RESTORE_MODE="${RESTORE_MODE:-false}"
DRY_RUN="${DRY_RUN:-false}"
AUTO_MODE="${AUTO_MODE:-false}"
AUTO_ROTATE="${WALL_AUTO_ROTATE:-off}"
AUTO_ROTATE_FILE="${HOME}/.cache/wal/auto-rotate.conf"

