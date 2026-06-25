#!/usr/bin/env bash
# lib/media.sh — Detección de tipo de archivo y extracción de frames
# ──────────────────────────────────────────────────────────────────
#
# Funciones públicas:
#   get_type <file>               → imprime "image" | "gif" | "video" | "unknown"
#   get_or_create_frame <file>    → imprime la ruta del frame PNG (crea si no existe)

# Devuelve la categoría del archivo según su extensión
get_type() {
    local file="$1"
    case "${file,,}" in
        *.jpg|*.jpeg|*.png|*.webp) echo "image" ;;
        *.gif)                     echo "gif"   ;;
        *.mp4|*.webm|*.mkv)        echo "video" ;;
        *)                         echo "unknown" ;;
    esac
}

# Obtiene (o genera con ffmpeg) el primer frame de un gif/video
# como PNG para usarlo como icono en rofi y como entrada de pywal
get_or_create_frame() {
    local src="$1"
    local name
    name="$(basename "$src")"
    local frame="$FRAME_CACHE/${name%.*}.png"

    if [[ ! -f "$frame" ]] && command -v ffmpeg &>/dev/null; then
        ffmpeg -y -i "$src" -vframes 1 -q:v 2 "$frame" -loglevel quiet 2>/dev/null || true
    fi

    echo "$frame"
}

