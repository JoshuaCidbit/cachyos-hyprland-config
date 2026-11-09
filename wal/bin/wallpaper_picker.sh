#!/usr/bin/env bash
# bin/wallpaper_picker.sh — Punto de entrada principal
# ─────────────────────────────────────────────────────
#
# Flags:
#   (ninguno)   → grid picker con iconos, transición wipe
#   --preview   → abre imv después de aplicar (solo imágenes estáticas)
#   --simple    → picker de lista simple (sin iconos)
#   --no-wal    → omite pywal16
#   --kill      → mata mpvpaper (bind de fullscreen / Win+Shift+W)
#   --restore   → restaura el último wallpaper animado (al salir de fullscreen)
#   --dry-run   → modo prueba: muestra qué haría sin aplicar nada
#   --auto      → modo rotación automática (elige intervalo por rofi)

set -euo pipefail

# ─── Localizar directorio raíz del proyecto ───────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

# ─── Cargar módulos en orden de dependencia ───────────────────────────────────
# 1. Configuración base (variables globales)
# shellcheck source=../lib/config.sh
source "${LIB_DIR}/config.sh"

# 2. Parseo de flags (modifica DO_PREVIEW, SIMPLE_MODE, SKIP_WAL, KILL_MODE, RESTORE_MODE)
# shellcheck source=../lib/flags.sh
source "${LIB_DIR}/flags.sh"
parse_flags "$@"

# 3. Validación de entorno
# shellcheck source=../lib/validate.sh
source "${LIB_DIR}/validate.sh"
validate_env

# 4. Colores de pywal16 (expone color0..color15)
# shellcheck source=../lib/colors.sh
source "${LIB_DIR}/colors.sh"
load_wal_colors

# 5. Tema de rofi (usa color0..color7)
# shellcheck source=../lib/theme.sh
source "${LIB_DIR}/theme.sh"

# 6. Helpers de medios (get_type, get_or_create_frame, cleanup_frame_cache)
# shellcheck source=../lib/media.sh
source "${LIB_DIR}/media.sh"
cleanup_frame_cache

# 7. Gestión de backends (awww / mpvpaper)
# shellcheck source=../lib/backend.sh
source "${LIB_DIR}/backend.sh"

# 8. Picker con rofi (depende de theme + media + backend)
# shellcheck source=../lib/picker.sh
source "${LIB_DIR}/picker.sh"

# 9. Rotación automática de wallpapers (lib/auto.sh)
# shellcheck source=../lib/auto.sh
source "${LIB_DIR}/auto.sh"

# ─── Arrancar daemon de awww ──────────────────────────────────────────────────
ensure_awww_daemon

# ─── Modo kill (fullscreen activo / Win+Shift+W) ──────────────────────────────
# Solo mata mpvpaper; awww queda mostrando el último frame como imagen estática
if $KILL_MODE; then
    stop_video_backend
    exit 0
fi

# ─── Modo rotación automática ──────────────────────────────────────────────────
if $AUTO_MODE; then
    if [[ "${AUTO_ROTATE:-off}" == "off" ]]; then
        _pick_auto_interval
    fi
    run_auto_rotation
    exit 0
fi

# ─── Selección de wallpaper ───────────────────────────────────────────────────
TARGET_WALL=""

if $RESTORE_MODE; then
    # Restaura el último wallpaper desde el historial (video/gif) o no hace nada
    apply_last_wallpaper
    [[ -n "$TARGET_WALL" ]] || exit 0
else
    # Flujo normal del Picker
    SELECTED="$(pick_wallpaper)"
    [[ -z "$SELECTED" ]] && exit 0
    TARGET_WALL="${WALL_DIR}/${SELECTED}"
fi

# Validar que el archivo objetivo realmente exista
if [[ ! -f "$TARGET_WALL" ]]; then
    notify-send -u normal "wallpaper-picker" \
        "Archivo no encontrado: $(basename "$TARGET_WALL")" 2>/dev/null || true
    exit 1
fi

# ─── Aplicar según tipo ───────────────────────────────────────────────────────
TYPE="$(get_type "$TARGET_WALL")"
WAL_TARGET="$TARGET_WALL"

case "$TYPE" in
    image)
        apply_image "$TARGET_WALL"
        ;;
    gif|video)
        apply_video "$TARGET_WALL"
        WAL_TARGET="$(get_or_create_frame "$TARGET_WALL")"
        ;;
    *)
        notify-send -u normal "wallpaper-picker" \
            "Formato no soportado: $(basename "$TARGET_WALL")" 2>/dev/null || true
        exit 1
        ;;
esac

# ─── Pywal ────────────────────────────────────────────────────────────────────
apply_wal "$WAL_TARGET"

# ─── Preview opcional (solo imágenes estáticas) ───────────────────────────────
if ! $RESTORE_MODE && $DO_PREVIEW && [[ "$TYPE" == "image" ]] && command -v "$IMV_BIN" &>/dev/null; then
    "$IMV_BIN" -f -q "$TARGET_WALL" &
fi

