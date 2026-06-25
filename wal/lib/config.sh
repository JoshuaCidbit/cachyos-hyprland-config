#!/usr/bin/env bash
# lib/config.sh — Variables de configuración y flags globales
# ─────────────────────────────────────────────────────────────

# ─── Rutas y herramientas ─────────────────────────────────────────────────────
WALL_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers/1080p}"
WAL_BIN="${WAL_BIN:-/usr/bin/wal}"
AWW_BIN="${AWW_BIN:-/usr/bin/awww}"
IMV_BIN="${IMV_BIN:-imv}"
KITTY_CONF="${KITTY_CONF:-$HOME/.cache/wal/colors-kitty.conf}"
WAL_COLORS="${HOME}/.cache/wal/colors.sh"
FRAME_CACHE="${HOME}/.cache/wallpaper_frames"

# ─── Transición ───────────────────────────────────────────────────────────────
TRANSITION="${WALL_TRANSITION:-wipe}"
TRANSITION_DUR="${WALL_TRANSITION_DUR:-1}"
MONITOR="${MONITOR:-*}"

# ─── Historial de pywal ───────────────────────────────────────────────────────
WAL_HISTORY="${HOME}/.cache/wal/wal"

# ─── Flags (sobreescritos por parse_flags en flags.sh) ────────────────────────
DO_PREVIEW=false
SIMPLE_MODE=false
SKIP_WAL=false
KILL_MODE=false
RESTORE_MODE=false

