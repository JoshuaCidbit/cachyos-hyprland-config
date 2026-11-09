#!/usr/bin/env bash
# lib/picker.sh — Lógica de selección de wallpaper con rofi
# ───────────────────────────────────────────────────────────
#
# Requiere que build_grid_theme (lib/theme.sh) esté disponible.
#
# Funciones públicas:
#   pick_wallpaper   → imprime el nombre del archivo elegido, o vacío si cancela
#   is_favorite       → true si el nombre está en el archivo de favoritos
#   toggle_favorite  → alterna el favorito de un nombre
#
# Funciones privadas:
#   _build_prompt     → construye el prompt del picker ("select wallpaper...")
#   _pick_grid        → picker tipo grid con rofi (usa -mesg para el timer)

# Extensiones buscadas (usadas por ambos pickers)
_WALL_EXTS=( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png"
             -o -iname "*.webp" -o -iname "*.gif"
             -o -iname "*.mp4"  -o -iname "*.webm" )

# Acción ejecutada por la última selección de rofi:
#   "select" → se debe aplicar el wallpaper elegido
#   "toggle" → se debe alternar el favorito del wallpaper elegido
PICKER_ACTION="select"

# ─── Prompt del picker ────────────────────────────────────────────────────────

# Construye el prompt del picker: "select wallpaper..."
# El intervalo de rotación se muestra aparte, en la barra -mesg de rofi
# (solo cuando la rotación automática está activa).
_build_prompt() {
    printf "select wallpaper..."
}

# ─── Favoritos ───────────────────────────────────────────────────────────────

# Verifica si un wallpaper (nombre con extensión) está marcado como favorito
is_favorite() {
    local name="$1"
    if [[ ! -f "${FAVORITES_FILE:-}" ]]; then
        return 1
    fi
    grep -qxF "$name" "${FAVORITES_FILE:-}"
}

# Alterna el favorito de un wallpaper (agrega si no existe, elimina si existe)
toggle_favorite() {
    local name="$1"
    local file="${FAVORITES_FILE:-}"
    if [[ -z "$file" ]]; then
        return 0
    fi
    touch "$file"
    local tmp
    tmp="$(mktemp)"
    grep -vxF "$name" "$file" > "$tmp" 2>/dev/null || true
    if grep -qxF "$name" "$file"; then
        mv "$tmp" "$file"
    else
        cat "$tmp" > "$file"
        printf '%s\n' "$name" >> "$file"
    fi
}

# ─── Intervalo de rotación persistido ──────────────────────────────────────────
# Al iniciar el picker, recarga el intervalo guardado en $AUTO_ROTATE_FILE
# (escrito por _pick_auto_interval) si no hay uno configurado, para que el
# timer de rotación se muestre correctamente tras reabrir el picker.
_load_auto_rotate() {
    if [[ "${AUTO_ROTATE:-off}" == "off" && -f "${AUTO_ROTATE_FILE:-}" ]]; then
        AUTO_ROTATE="$(cat "${AUTO_ROTATE_FILE:-}")"
    fi
}

# ─── Picker tipo grid con iconos ──────────────────────────────────────────────
# Modos:
#   "todos"      → todos los wallpapers, con "*" delante de los favoritos
#   "favoritos"  → solo los wallpapers marcados como favoritos
# En ambos casos devuelve el nombre seleccionado (o vacío si cancela).
# Con la tecla custom "f" alterna favorito (sin aplicar el wallpaper;
# el wallpaper se aplica con Enter sobre el mismo ítem).
# Con la tecla custom "t" abre el selector de intervalo de rotación.
_pick_grid() {
    local mode="${1:-todos}"
    local grid_theme
    grid_theme="$(build_grid_theme)"
    local prompt
    prompt="$(_build_prompt)"

    # Cargar intervalo persistido (ej: recién elegido via 't') si está desactivado
    _load_auto_rotate

    # Pre-generar frames de animaciones en cache para no bloquear la UI de rofi
    local img type
    while IFS= read -r img; do
        type="$(get_type "$img")"
        if [[ "$type" == "gif" || "$type" == "video" ]]; then
            get_or_create_frame "$img" >/dev/null 2>&1 || true
        fi
    done < <(find "$WALL_DIR" -type f \( "${_WALL_EXTS[@]}" \) | sort)

    # Construir la lista de archivos segun el modo
    local -a files=()
    if [[ "$mode" == "favoritos" ]]; then
        if [[ -f "${FAVORITES_FILE:-}" ]]; then
            local fav
            while IFS= read -r fav; do
                [[ -n "${fav:-}" ]] || continue
                if [[ -f "$WALL_DIR/$fav" ]]; then
                    files+=( "$WALL_DIR/$fav" )
                fi
            done < "$FAVORITES_FILE"
        fi
    else
        # Recopilar todos los wallpapers (find recursivo) en un array
        local -a all_files=()
        while IFS= read -r f; do
            [[ -n "${f:-}" ]] || continue
            all_files+=( "$f" )
        done < <(find "$WALL_DIR" -type f \( "${_WALL_EXTS[@]}" \) | sort)

        # Ordenar: los favoritos van primero, luego el resto (manteniendo orden)
        local -a fav_files=()
        local -a other_files=()
        if [[ -f "${FAVORITES_FILE:-}" ]]; then
            local fav
            while IFS= read -r fav; do
                [[ -n "${fav:-}" ]] || continue
                if [[ -f "$WALL_DIR/$fav" ]]; then
                    fav_files+=( "$WALL_DIR/$fav" )
                fi
            done < "$FAVORITES_FILE"
        fi
        local f fav_path is_fav
        for f in "${all_files[@]}"; do
            is_fav=0
            for fav_path in "${fav_files[@]}"; do
                if [[ "$f" == "$fav_path" ]]; then
                    is_fav=1
                    break
                fi
            done
            if (( is_fav )); then
                continue
            fi
            other_files+=( "$f" )
        done
        files=("${fav_files[@]}" "${other_files[@]}")
    fi

    local rc=0
    local selected=""
    local rofi_args=(
        -dmenu
        -i
        -show-icons
        -theme-str "$grid_theme"
        -name "wallpaper-picker"
        -click-to-exit
        -me-select-entry ""
        -me-accept-entry "MousePrimary"
        -kb-custom-1 "f"
        -kb-custom-2 "t"
    )
    # Timer de rotación: se muestra en la barra -mesg solo si está activa
    if [[ "${AUTO_ROTATE:-off}" != "off" ]]; then
        rofi_args+=( -mesg "$(_timer_mesg)" )
    fi
    selected="$(for img in "${files[@]}"; do
        type="$(get_type "$img")"
        local icon
        if [[ "$type" == "gif" || "$type" == "video" ]]; then
            icon="$(get_or_create_frame "$img")"
            [[ -f "$icon" ]] || icon="video"
        else
            icon="$img"
        fi
        local label
        label="$(basename "$img")"
        if [[ "$mode" == "todos" ]] && is_favorite "$label"; then
            label="*${label}"
        fi
        printf "%s\0icon\x1f%s\n" "$label" "$icon"
    done | rofi "${rofi_args[@]}")" || rc=$?

    if (( rc >= 10 && rc <= 28 )); then
        # Aceptado mediante una tecla custom (f o t)
        if (( rc == 10 )); then
            # Tecla 'f' (kb-custom-1) → toggle favorito (sin aplicar el wallpaper;
            # el wallpaper se aplica con Enter sobre el mismo ítem)
            local name="${selected:-}"
            name="${name#\*}"
            if [[ -n "$name" ]]; then
                toggle_favorite "$name"
            fi
            # No cerrar el picker: avisar al dispatcher para que refresque la lista
            echo "__TOGGLE__"
            return 0
        fi
        # Tecla 't' (kb-custom-2) → selector de intervalo de rotación
        echo "__TIME__"
        return 0
    fi

    PICKER_ACTION="select"
    # Quitar el indicador "*" si el favorito fue seleccionado con Enter
    echo "${selected#\*}"
}

# ─── Picker tipo lista simple (fallback o --simple) ───────────────────────────
_pick_simple() {
    find "$WALL_DIR" -type f \( "${_WALL_EXTS[@]}" \) \
        -printf "%f\n" | sort | \
    rofi -dmenu -i \
        -p "Selecciona fondo:" \
        -click-to-exit \
        -me-select-entry "" \
        -me-accept-entry "MousePrimary"
    return 0
}

# ─── Dispatcher ───────────────────────────────────────────────────────────────
pick_wallpaper() {
    if $SIMPLE_MODE; then
        _pick_simple
    else
        # Picker con todos los wallpapers (favoritos primero, con "*")
        while true; do
            local result
            result="$(_pick_grid "todos")"
            if [[ "$result" == "__TIME__" ]]; then
                # Tecla 't' → se eligió un intervalo: reabrir el picker con el nuevo prompt
                _pick_auto_interval
                continue
            fi
            if [[ "$result" == "__TOGGLE__" ]]; then
                # Tecla 'f' → solo alternar favorito: refrescar el picker sin cerrarlo
                continue
            fi
            echo "$result"
            return
        done
    fi
}
