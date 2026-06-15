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
    local lua_dir="${HOME}/.config/hypr/schemes"
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

# ─── Orquestador ─────────────────────────────────────────────────────────────

apply_wal() {
    local target="$1"
    $SKIP_WAL && return 0
    command -v "$WAL_BIN" &>/dev/null || return 0
    [[ -f "$target" ]] || return 0

    "$WAL_BIN" -i "$target" -q || true

    _apply_hyprland
    _apply_fastfetch
    _apply_btop
    _apply_cava
}
