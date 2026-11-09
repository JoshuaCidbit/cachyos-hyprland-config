#!/usr/bin/env bash
# lib/flags.sh — Parseo de argumentos de línea de comandos
# ─────────────────────────────────────────────────────────────
#
# Uso:
#   source lib/flags.sh
#   parse_flags "$@"
#
# Flags disponibles:
#   --preview   Abre imv tras aplicar (solo imágenes estáticas)
#   --simple    Picker de lista simple en lugar de grid con iconos
#   --no-wal    Omite la ejecución de pywal16
#   --kill      Mata mpvpaper (usar al entrar a fullscreen)
#   --restore   Restaura el último wallpaper animado
#   --dry-run   Modo prueba: muestra qué haría sin aplicar nada
#   --auto      → modo rotación automática (elige intervalo por rofi)

parse_flags() {
    for arg in "$@"; do
        case "$arg" in
            --preview) DO_PREVIEW=true    ;;
            --simple)  SIMPLE_MODE=true  ;;
            --no-wal)  SKIP_WAL=true      ;;
            --kill)    KILL_MODE=true     ;;
            --restore) RESTORE_MODE=true ;;
            --dry-run) DRY_RUN=true       ;;
            --auto)    AUTO_MODE=true     ;;
        esac
    done
}
