#!/usr/bin/env bash
# lib/backend.sh — Gestión de daemons: awww y mpvpaper
# ──────────────────────────────────────────────────────
#
# Funciones públicas:
#   ensure_awww_daemon          → arranca awww-daemon si no está corriendo
#   stop_video_backend          → mata mpvpaper y procesos mpv huérfanos
#   apply_image <path>          → establece wallpaper estático con awww
#   apply_video <path>          → establece wallpaper animado con mpvpaper
#                                 (con transición visual mediante frame puente)

ensure_awww_daemon() {
    if ! pidof awww-daemon >/dev/null 2>&1; then
        awww-daemon &
        local waited=0
        while (( waited < 50 )); do
            if pidof awww-daemon >/dev/null 2>&1; then
                return 0
            fi
            sleep 0.1
            waited=$(( waited + 1 ))
        done
    fi
}

stop_video_backend() {
    local mpvpaper_pid child

    mpvpaper_pid="$(pgrep -x mpvpaper 2>/dev/null | head -n1 || true)"

    if [[ -n "$mpvpaper_pid" ]]; then
        # 1. Matar primero los hijos mpv (proceso del wallpaper) y luego el padre,
        #    para no dejar procesos huérfanos.
        while read -r child; do
            kill -9 "$child" 2>/dev/null || true
        done < <(pgrep -P "$mpvpaper_pid" 2>/dev/null || true)

        # 2. Matar el daemon mpvpaper.
        kill -9 "$mpvpaper_pid" 2>/dev/null || true
        sleep 0.2
    fi
}

apply_image() {
    local path="$1"
    if $DRY_RUN; then
        echo "[dry-run] apply_image: $path"
        return 0
    fi

    stop_video_backend

    "$AWW_BIN" img "$path" \
        --transition-type "$TRANSITION" \
	--transition-duration "$TRANSITION_DUR" 2>/dev/null

}

apply_video() {
    local path="$1"
    if $DRY_RUN; then
        echo "[dry-run] apply_video: $path"
        return 0
    fi

    local frame
    frame="$(get_or_create_frame "$path")"

    # Mostrar frame como puente visual antes de matar mpvpaper
    if [[ -f "$frame" ]]; then
        "$AWW_BIN" img "$frame" \
            --transition-type fade \
            --transition-duration 0.4 2>/dev/null || true
        sleep 0.3
    fi

    stop_video_backend

    # Lanzar video con fade-in para suavizar el corte

    # quitar comentario y comentar el de abajo para volver a poner fade (no recomiendo, quita el efecto loop)
    #mpvpaper -o "loop --no-audio --vf=lavfi=[fade=in:0:25]" "$MONITOR" "$path" &

    #este es el sin fade
    mpvpaper -o "no-audio --hwdec=vaapi --loop-file=inf" "$MONITOR" "$path" &
}

# Aplica un wallpaper (imagen o video) completo: backend + tema de pywal16
apply_wallpaper() {
    local path="$1"
    local type
    type="$(get_type "$path")"
    WAL_TARGET="$path"

    case "$type" in
        image)
            apply_image "$path"
            ;;
        gif|video)
            apply_video "$path"
            WAL_TARGET="$(get_or_create_frame "$path")"
            ;;
        *)
            return 1
            ;;
    esac

    apply_wal "$WAL_TARGET"
}

apply_last_wallpaper() {
    # Restaura el último wallpaper desde el historial (video/gif) o no hace nada
    # (si el último era una imagen estática, awww ya la tiene aplicada)
    TARGET_WALL=""

    if [[ ! -f "$WAL_HISTORY" ]]; then
        return 0
    fi

    local last_used base_name file_no_ext original_media
    last_used="$(cat "$WAL_HISTORY")"
    base_name="$(basename "$last_used")"
    file_no_ext="${base_name%.*}"

    original_media="$(find "$WALL_DIR" -maxdepth 1 -type f \( \
        -iname "${file_no_ext}.mp4"  -o \
        -iname "${file_no_ext}.webm" -o \
        -iname "${file_no_ext}.mkv"  -o \
        -iname "${file_no_ext}.gif"  \
    \) -print -quit)"

    if [[ -n "$original_media" ]]; then
        # Solo relanzar si mpvpaper no está corriendo
        if ! pgrep -x mpvpaper >/dev/null 2>&1; then
            TARGET_WALL="$original_media"
        fi
    fi
}

