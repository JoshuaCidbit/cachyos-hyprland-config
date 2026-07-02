#!/usr/bin/env bash
# lib/colors.sh — Carga de colores de pywal con fallback Catppuccin
# ─────────────────────────────────────────────────────────────────
#
# Uso:
#   source lib/colors.sh
#   load_wal_colors     # expone color0..color7 al entorno actual

#!/usr/bin/env bash
# lib/colors.sh — Carga y aplicación de colores de pywal
# ───────────────────────────────────────────────────────

SDDM_CACHE_BG="${HOME}/.cache/wal/sddm_background.jpg"
SDDM_CACHE_CONF="${HOME}/.cache/wal/sddm_theme.conf"
SDDM_TPL="${HOME}/.config/wal/templates/sddm_theme.conf.tpl"
SDDM_SYNC_BIN="/usr/local/bin/sddm-pixie-sync.sh"

load_wal_colors() {
    if [[ -f "$WAL_COLORS" ]]; then
        set +u
        # shellcheck disable=SC1090
        source "$WAL_COLORS"
        set -u
    else
        # Fallback: paleta Catppuccin Mocha
        color0="#11111b"
        color1="#89b4fa"
        color2="#cdd6f4"
        color3="#f9e2af"
        color4="#89b4fa"
        color5="#cba6f7"
        color7="#cdd6f4"
    fi
}

# ─── Aplicadores individuales ─────────────────────────────────────────────────

_apply_hyprland() {
    local lua_dir="${HOME}/.config/hypr/scheme"
    mkdir -p "$lua_dir"
    if [[ -f "${HOME}/.cache/wal/colors.lua" ]]; then
        cp "${HOME}/.cache/wal/colors.lua" "${lua_dir}/colors.lua" || true
    fi
    python3 ~/.config/wal/scripts/wal-to-caelestia.py || true
    hyprctl reload || true
}

_apply_fastfetch() {
    ~/.config/fastfetch/gen_fastfetch.sh && fastfetch || true
}

_apply_kitty() {
    command -v kitty &>/dev/null || return 0
    [[ -S /tmp/kitty ]] || return 0
    kitty @ --to unix:/tmp/kitty set-colors -a ~/.cache/wal/colors-kitty.conf
}

_apply_btop() {
    local src="${HOME}/.cache/wal/colors-btop.theme"
    local dst="${HOME}/.config/btop/themes/pywal.theme"
    [[ -f "$src" ]] || return 0
    ln -sf "$src" "$dst"
    pkill -SIGUSR2 btop || true
}

_apply_cava() {
    local src="${HOME}/.cache/wal/colors-cava.ini"
    [[ -f "$src" ]] || return 0
    cp "$src" "${HOME}/.config/cava/config"
    pkill -SIGUSR1 cava || true
}

_apply_sddm() {
    local img="$1"

    [[ -f "$img" ]] || return 0
    [[ -f "$SDDM_TPL" ]] || return 0

    # 1. Copiar wallpaper a cache como background.jpg
    if command -v magick &>/dev/null; then
        magick "$img" -quality 90 "$SDDM_CACHE_BG" 2>/dev/null || cp -f "$img" "$SDDM_CACHE_BG"
    elif command -v convert &>/dev/null; then
        convert "$img" -quality 90 "$SDDM_CACHE_BG" 2>/dev/null || cp -f "$img" "$SDDM_CACHE_BG"
    else
        cp -f "$img" "$SDDM_CACHE_BG"
    fi

    # 2. Generar theme.conf desde la plantilla con colores de pywal
    sed \
        -e "s/%PRIMARY%/${color4}/" \
        -e "s/%ACCENT%/${color6}/" \
        -e "s/%BACKGROUND%/${background}/" \
        -e "s/%TEXT%/${foreground}/" \
        "$SDDM_TPL" > "$SDDM_CACHE_CONF"

    # 3. Sincronizar al theme real (root, sin password)
    sudo -n "$SDDM_SYNC_BIN" 2>/dev/null || true
}

# ─── Orquestador ─────────────────────────────────────────────────────────────

apply_wal() {
    local target="$1"
    $SKIP_WAL && return 0
    command -v "$WAL_BIN" &>/dev/null || return 0
    [[ -f "$target" ]] || return 0

    "$WAL_BIN" -i "$target" -q || true

    _apply_hyprland
    _apply_fastfetch
    _apply_kitty
    _apply_btop
    _apply_cava
    _apply_sddm "$target"
}
