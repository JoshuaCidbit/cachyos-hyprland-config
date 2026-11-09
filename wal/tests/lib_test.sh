#!/usr/bin/env bash
# tests/lib_test.sh — Tests unitarios de las librerías de wal (bash, sin deps)
# ─────────────────────────────────────────────────────────────────────────────
# Uso: source lib/... y llamar a las funciones _test_* / check_* al final.
# Salida: exit 0 si todos pasan, 1 si hay fallas.

source /home/joshua/.config/wal/lib/config.sh
source /home/joshua/.config/wal/lib/auto.sh
source /home/joshua/.config/wal/lib/picker.sh
source /home/joshua/.config/wal/lib/theme.sh
source /home/joshua/.config/wal/lib/media.sh

export FAVORITES_FILE=/tmp/opencode/wal-tests/favorites
export WALL_DIR=/tmp/opencode/wal-tests/wall
SIMPLE_MODE=false

mkdir -p /tmp/opencode/wal-tests
touch "${FAVORITES_FILE}"

PASS=0; FAIL=0
check() { # check <nombre> <esperado> <actual>
    if [[ "$2" == "$3" ]]; then
        echo "PASS: $1"; PASS=$((PASS+1))
    else
        echo "FAIL: $1 | esperado=[${2}] actual=[${3}]"; FAIL=$((FAIL+1))
    fi
}

echo "== T1: _build_prompt (prompt limpio) =="
check "prompt limpio" "select wallpaper..." "$(_build_prompt)"

echo "== T2: get_auto_interval (off / intervalos) =="
AUTO_ROTATE=off;        check "intervalo off -> 0" "0" "$(get_auto_interval)"
AUTO_ROTATE=30min;      check "intervalo 30min -> 1800" "1800" "$(get_auto_interval)"
AUTO_ROTATE=1h;          check "intervalo 1h -> 3600" "3600" "$(get_auto_interval)"
AUTO_ROTATE=2h;          check "intervalo 2h -> 7200" "7200" "$(get_auto_interval)"
AUTO_ROTATE=24h;         check "intervalo 24h -> 86400" "86400" "$(get_auto_interval)"
AUTO_ROTATE="garbage";  check "intervalo desconocido -> 0" "0" "$(get_auto_interval)"

echo "== T3: _auto_interval_label =="
AUTO_ROTATE=off;         check "label off" "off" "$(_auto_interval_label)"
AUTO_ROTATE=30min;       check "label 30min" "30 min" "$(_auto_interval_label)"
AUTO_ROTATE=1h;          check "label 1h" "1 h" "$(_auto_interval_label)"
AUTO_ROTATE=2h;          check "label 2h" "2 h" "$(_auto_interval_label)"
AUTO_ROTATE=24h;         check "label 24h" "24 h" "$(_auto_interval_label)"

echo "== T4: _timer_mesg (formato de minutos / horas) =="
AUTO_ROTATE=off;         check "timer off -> vacio" "" "$(_timer_mesg)"
AUTO_ROTATE=30min;       check "timer 30min -> minutos" "⏱ 30 min" "$(_timer_mesg)"
AUTO_ROTATE=1h;          check "timer 1h -> HH:MM" "⏱ $(date -d "+3600 seconds" +%H:%M)" "$(_timer_mesg)"
AUTO_ROTATE=24h;         check "timer 24h -> HH:MM" "⏱ $(date -d "+86400 seconds" +%H:%M)" "$(_timer_mesg)"

echo "== T5: _load_auto_rotate (recarga desde archivo persistido) =="
AUTO_ROTATE=off
rm -f "${AUTO_ROTATE_FILE:-/tmp/opencode/nope}"
check "load: sin archivo -> off" "off" "$(_load_auto_rotate; echo "${AUTO_ROTATE:-off}")"
echo "30min" > "${AUTO_ROTATE_FILE:-/tmp/opencode/nope}"
AUTO_ROTATE=off
check "load: archivo 30min -> 30min" "30min" "$(_load_auto_rotate; echo "${AUTO_ROTATE:-off}")"
AUTO_ROTATE=30min
echo "24h" > "${AUTO_ROTATE_FILE:-/tmp/opencode/nope}"
check "load: ya activado -> conserva 30min" "30min" "$(_load_auto_rotate; echo "${AUTO_ROTATE:-off}")"
rm -f "${AUTO_ROTATE_FILE:-/tmp/opencode/nope}"

echo "== T6: favoritos (is_favorite / toggle_favorite) =="
AUTO_ROTATE=off
rm -f "${FAVORITES_FILE:-/tmp/opencode/wal-tests/favorites}"
check "is_favorite: sin archivo -> false" "false" "$(is_favorite "Alpha.jpg" && echo true || echo false)"
toggle_favorite "Alpha.jpg"
check "toggle: agrega favorito" "true" "$(is_favorite "Alpha.jpg" && echo true || echo false)"
toggle_favorite "Alpha.jpg"
check "toggle: quita favorito" "false" "$(is_favorite "Alpha.jpg" && echo true || echo false)"

echo "== RESULT: lib_test pass=${PASS} fail=${FAIL}"
[[ $FAIL -eq 0 ]]
