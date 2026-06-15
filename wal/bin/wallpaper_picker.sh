#!/usr/bin/env bash
# bin/wallpaper_picker.sh — Punto de entrada principal
# ─────────────────────────────────────────────────────
#
# Flags:
#   (ninguno)   → grid picker con iconos, transición wipe
#   --preview   → abre imv después de aplicar (solo imágenes estáticas)
#   --simple    → picker de lista simple (sin iconos)
#   --no-wal    → omite pywal
#   --kill      → mata mpvpaper (bind de fullscreen / Win+Shift+W)
#   --restore   → restaura el último wallpaper animado (al salir de fullscreen)

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

# 4. Colores de pywal (expone color0..color7)
# shellcheck source=../lib/colors.sh
source "${LIB_DIR}/colors.sh"
load_wal_colors

# 5. Tema de rofi (usa color0..color7)
# shellcheck source=../lib/theme.sh
source "${LIB_DIR}/theme.sh"

# 6. Helpers de medios (get_type, get_or_create_frame)
# shellcheck source=../lib/media.sh
source "${LIB_DIR}/media.sh"

# 7. Gestión de backends (awww / mpvpaper)
# shellcheck source=../lib/backend.sh
source "${LIB_DIR}/backend.sh"

# 8. Picker con rofi (depende de theme + media + backend)
# shellcheck source=../lib/picker.sh
source "${LIB_DIR}/picker.sh"

# ─── Arrancar daemon de awww ──────────────────────────────────────────────────
ensure_awww_daemon

# ─── Modo kill (fullscreen activo / Win+Shift+W) ──────────────────────────────
# Solo mata mpvpaper; awww queda mostrando el último frame como imagen estática
if $KILL_MODE; then
    stop_video_backend
    exit 0
fi

# ─── Selección de wallpaper ───────────────────────────────────────────────────
TARGET_WALL=""

if $RESTORE_MODE; then
    if [[ -f "$WAL_HISTORY" ]]; then
        # Busca el archivo sin tomar en cuenta la extension
        LAST_USED="$(cat "$WAL_HISTORY")"
        BASE_NAME="$(basename "$LAST_USED")"
        FILE_NO_EXT="${BASE_NAME%.*}"

        # Busca el archivo con la extension original
        ORIGINAL_MEDIA=$(find "$WALL_DIR" -maxdepth 1 -type f \( \
            -iname "${FILE_NO_EXT}.mp4"  -o \
            -iname "${FILE_NO_EXT}.webm" -o \
            -iname "${FILE_NO_EXT}.mkv"  -o \
            -iname "${FILE_NO_EXT}.gif"  \
        \) -print -quit)

        # Validamos si find tuvo éxito (era un video/gif)
        if [[ -n "$ORIGINAL_MEDIA" ]]; then
            # Solo relanzar si mpvpaper no está ya corriendo
            if pgrep -x mpvpaper >/dev/null 2>&1; then
                exit 0
            fi
            TARGET_WALL="$ORIGINAL_MEDIA"

        else
            # Era imagen estática: awww ya la tiene, nada que hacer
            exit 0
        fi
    else
        exit 0
    fi
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

