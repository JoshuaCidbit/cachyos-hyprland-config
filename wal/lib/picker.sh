#!/usr/bin/env bash
# lib/picker.sh — Lógica de selección de wallpaper con rofi
# ───────────────────────────────────────────────────────────
#
# Requiere que build_grid_theme (lib/theme.sh) esté disponible.
#
# Funciones públicas:
#   pick_wallpaper   → imprime el nombre del archivo elegido, o vacío si cancela

# Extensiones buscadas (usadas por ambos pickers)
_WALL_EXTS=( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png"
             -o -iname "*.webp" -o -iname "*.gif"
             -o -iname "*.mp4"  -o -iname "*.webm" )

# ─── Picker tipo grid con iconos ──────────────────────────────────────────────
_pick_grid() {
    local grid_theme
    grid_theme="$(build_grid_theme)"

    find "$WALL_DIR" -maxdepth 1 -type f \( "${_WALL_EXTS[@]}" \) | sort | \
    while IFS= read -r img; do
        local type icon
        type="$(get_type "$img")"
        if [[ "$type" == "gif" || "$type" == "video" ]]; then
            icon="$(get_or_create_frame "$img")"
            [[ -f "$icon" ]] || icon="video"
        else
            icon="$img"
        fi
        printf "%s\0icon\x1f%s\n" "$(basename "$img")" "$icon"
    done | rofi \
        -dmenu -i -show-icons \
        -theme-str "$grid_theme" \
        -p "" \
        -name "wallpaper-picker" \
        -click-to-exit \
        -me-select-entry "" \
        -me-accept-entry "MousePrimary"
}

# ─── Picker tipo lista simple (fallback o --simple) ───────────────────────────
_pick_simple() {
    find "$WALL_DIR" -maxdepth 1 -type f \( "${_WALL_EXTS[@]}" \) \
        -printf "%f\n" | sort | \
    rofi -dmenu -i \
        -p "Selecciona fondo:" \
        -click-to-exit \
        -me-select-entry "" \
        -me-accept-entry "MousePrimary"
}

# ─── Dispatcher ───────────────────────────────────────────────────────────────
pick_wallpaper() {
    if $SIMPLE_MODE; then
        _pick_simple
    else
        _pick_grid
    fi
}

