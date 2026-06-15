#!/usr/bin/env bash
# lib/validate.sh — Validaciones de entorno y directorios
# ─────────────────────────────────────────────────────────────
#
# Uso:
#   source lib/validate.sh
#   validate_env     # valida todo el entorno antes de arrancar

validate_wall_dir() {
    if [[ ! -d "$WALL_DIR" ]]; then
        notify-send -u critical "wallpaper-picker" \
            "Directorio no encontrado: $WALL_DIR" 2>/dev/null || true
        echo "Error: WALL_DIR '$WALL_DIR' no existe." >&2
        exit 1
    fi
}

validate_env() {
    validate_wall_dir
    mkdir -p "$FRAME_CACHE"
}

