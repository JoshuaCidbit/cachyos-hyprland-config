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
        sleep 0.5
    fi
}

stop_video_backend() {
    if pgrep -x mpvpaper >/dev/null 2>&1; then
        pkill -x mpvpaper 2>/dev/null || true
        sleep 0.2
    fi
    # Limpiar instancias mpv huérfanas que mpvpaper haya dejado
    pkill -9 -f "mpv" 2>/dev/null || true
    sleep 0.2
}

apply_image() {
    local path="$1"
    stop_video_backend
    
    # Debug: Esto imprimirá el valor en tu terminal si ejecutas el script manualmente
    echo "DEBUG: Usando transición: $TRANSITION"
    
    "$AWW_BIN" img "$path" \
        --transition-type "$TRANSITION" \
	--transition-duration "$TRANSITION_DUR" 2>/dev/null

}

apply_video() {
    local path="$1"
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

