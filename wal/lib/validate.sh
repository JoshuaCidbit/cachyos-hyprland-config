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

validate_wal_bin() {
    if ! command -v "$WAL_BIN" &>/dev/null; then
        notify-send -u critical "wallpaper-picker" \
            "Binario de pywal16 no encontrado: $WAL_BIN" 2>/dev/null || true
        echo "Error: binario de pywal16 no encontrado: $WAL_BIN" >&2
        exit 1
    fi
}

check_dependencies() {
    local missing=0
    local dep

    # Dependencias obligatorias para el flujo principal
    for dep in rofi awww-daemon hyprctl; do
        if ! command -v "$dep" &>/dev/null; then
            notify-send -u critical "wallpaper-picker" \
                "Dependencia faltante: $dep" 2>/dev/null || true
            echo "Error: dependencia faltante: $dep" >&2
            missing=1
        fi
    done

    # Dependencias opcionales (solo se usan en flujos concretos)
    local optional_missing=()
    local opt
    for opt in mpvpaper ffmpeg magick convert notify-send kitty fastfetch jq socat; do
        if ! command -v "$opt" &>/dev/null; then
            optional_missing+=("$opt")
        fi
    done
    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        echo "Advertencias: dependencias no encontradas: ${optional_missing[*]}" >&2
    fi

    if [[ $missing -ne 0 ]]; then
        exit 1
    fi
}

validate_env() {
    validate_wall_dir
    validate_wal_bin
    check_dependencies
    mkdir -p "$FRAME_CACHE"
}

