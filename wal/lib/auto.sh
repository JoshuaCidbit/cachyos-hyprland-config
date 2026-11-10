#!/usr/bin/env bash
# lib/auto.sh — Rotación automática de wallpapers
# ───────────────────────────────────────────────────────────
#
# Funciones públicas:
#   get_auto_interval   → imprime el intervalo en segundos (0 = desactivado)
#   _pick_auto_interval → abre rofi para elegir el intervalo de rotación
#   _timer_mesg         → imprime el texto del timer para el picker ("" si off)
#   run_auto_rotation   → bucle que rota el wallpaper cada N segundos

# Último instante (epoch) en que se aplicó un wallpaper por la rotación
LAST_ROTATION_EPOCH=""
# Archivo donde se persiste el epoch (para que el timer sea persistente
# y calcule "desde ahora" solo en la primera ejecución)
LAST_ROTATION_EPOCH_FILE="${HOME}/.cache/wal/last-rotation-epoch"
if [[ -z "${LAST_ROTATION_EPOCH:-}" && -f "${LAST_ROTATION_EPOCH_FILE}" ]]; then
    LAST_ROTATION_EPOCH="$(cat "${LAST_ROTATION_EPOCH_FILE}" 2>/dev/null || true)"
fi

# Intervalos disponibles (en segundos)
#   off     → desactivado
#   30min   → 1800
#   1hora   → 3600
#   2horas  → 7200
#   24horas → 86400

# Si se usa standalone, asegurar que locks.sh esté disponible
if ! declare -F wallpaper_locked >/dev/null 2>&1; then
    source "$(dirname "${BASH_SOURCE[0]}")/locks.sh"
fi

get_auto_interval() {
    case "${AUTO_ROTATE:-off}" in
        off|"")        echo 0 ;;
        30min|30)      echo 1800 ;;
        1h|1|60)       echo 3600 ;;
        2h|2|120)      echo 7200 ;;
        24h|24|1440)   echo 86400 ;;
        *)             echo 0 ;;
    esac
}

# Devuelve la etiqueta legible del intervalo actual
_auto_interval_label() {
    case "${AUTO_ROTATE:-off}" in
        30min)  echo "30 min" ;;
        1h)     echo "1 h" ;;
        2h)     echo "2 h" ;;
        24h)    echo "24 h" ;;
        *)      echo "off" ;;
    esac
}

# Devuelve el texto del timer para el picker (barra -mesg de rofi):
#   - ""              → rotación desactivada (no se muestra)
#   - "⏱ HH:MM"      → falta >= 1 hora para el próximo cambio (formato 24h)
#   - "⏱ N min"      → falta < 1 hora (se muestra en minutos)
_timer_mesg() {
    local interval
    interval="$(get_auto_interval)"
    if (( interval <= 0 )); then
        printf ""
        return 0
    fi
    local last_epoch next_epoch next_h next_m
    last_epoch="${LAST_ROTATION_EPOCH:-$(date +%s)}"
    next_epoch=$(( last_epoch + interval ))
    if (( interval >= 3600 )); then
        next_h="$(date -d "@${next_epoch}" +%H)"
        next_m="$(date -d "@${next_epoch}" +%M)"
        printf "⏱ %02d:%02d" "$next_h" "$next_m"
    else
        printf "⏱ %d min" "$(( interval / 60 ))"
    fi
}

# Abre rofi para elegir el intervalo de rotación
_pick_auto_interval() {
    local choice
    choice="$(printf 'No cambiar\n30 min\n1 hora\n2 horas\n24 horas\n' | \
        rofi -dmenu -i -p "Intervalo de rotacion:" -theme-str "$(build_grid_theme)" -click-to-exit \
        -me-select-entry "" -me-accept-entry "MousePrimary" 2>/dev/null || true)"
    case "$choice" in
        "30 min")    AUTO_ROTATE="30min" ;;
        "1 hora")    AUTO_ROTATE="1h" ;;
        "2 horas")   AUTO_ROTATE="2h" ;;
        "24 horas")  AUTO_ROTATE="24h" ;;
        *)           AUTO_ROTATE="off" ;;
    esac
    # Persistir el intervalo elegido para que el timer lo muestre en el picker
    if [[ -n "${AUTO_ROTATE_FILE:-}" ]]; then
        mkdir -p "$(dirname "$AUTO_ROTATE_FILE")" 2>/dev/null || true
        printf '%s\n' "$AUTO_ROTATE" > "$AUTO_ROTATE_FILE"
    fi
    return 0
}

# Elige un wallpaper aleatorio (evita repetir el ultimo elegido)
pick_random_wallpaper() {
    local -a candidates=()
    local f
    while IFS= read -r f; do
        [[ -n "${f:-}" ]] || continue
        candidates+=( "$f" )
    done < <(find "$WALL_DIR" -type f \( "${_WALL_EXTS[@]}" \) | sort)

    if [[ ${#candidates[@]} -eq 0 ]]; then
        return 1
    fi

    local pick=""
    local last_used=""
    if [[ -f "${WAL_HISTORY:-}" ]]; then
        last_used="$(cat "${WAL_HISTORY:-}" 2>/dev/null || true)"
    fi

    local i
    for ((i = 0; i < 20; i++)); do
        pick="${candidates[$((RANDOM % ${#candidates[@]}))]}"
        if [[ "$pick" != "$last_used" ]]; then
            break
        fi
    done

    basename "$pick"
}

# Bucle principal de rotacion: aplica un wallpaper aleatorio cada N segundos
run_auto_rotation() {
    local interval
    interval="$(get_auto_interval)"
    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    if (( interval <= 0 )); then
        return 0
    fi

    while true; do
        sleep "$interval"

        if wallpaper_locked; then
            continue
        fi

        local name
        name="$(pick_random_wallpaper)" || name=""
        if [[ -z "$name" ]]; then
            continue
        fi
        local path="${WALL_DIR}/${name}"
        if [[ ! -f "$path" ]]; then
            continue
        fi
        apply_wallpaper "$path"
        LAST_ROTATION_EPOCH="$(date +%s)"
        printf '%s\n' "$LAST_ROTATION_EPOCH" > "$LAST_ROTATION_EPOCH_FILE"
    done
}
