#!/usr/bin/env bash
# tests/picker_flow_test.sh — Tests de integración del picker con fake rofi
# ─────────────────────────────────────────────────────────────────────────────
# Escenarios:
#   F1: flujo completo de rotación (t -> submenu 30min -> picker final con -mesg)
#   F2: picker carga intervalo persistido desde AUTO_ROTATE_FILE
#   F3: sin intervalo activo -> picker sin -mesg
#   F4: tecla f -> __TOGGLE__ -> refrescar -> Enter aplica

source /home/joshua/.config/wal/lib/config.sh
source /home/joshua/.config/wal/lib/colors.sh
source /home/joshua/.config/wal/lib/media.sh
source /home/joshua/.config/wal/lib/picker.sh
source /home/joshua/.config/wal/lib/auto.sh
source /home/joshua/.config/wal/lib/theme.sh

export PATH="/home/joshua/.config/wal/tests/fixtures:$PATH"
export FAVORITES_FILE=/tmp/opencode/wal-tests/favorites
export WALL_DIR=/tmp/opencode/wal-tests/wall
export FAKE_ROFI_RC=0
SIMPLE_MODE=false

PASS=0; FAIL=0
check() {
    if [[ "$2" == "$3" ]]; then echo "PASS: $1"; PASS=$((PASS+1));
    else echo "FAIL: $1 | esperado=[${2}] actual=[${3}]"; FAIL=$((FAIL+1)); fi
}
has_mgrep() { grep -q -- -mesg "$1" 2>/dev/null && echo yes || echo no; }

reset_all() {
    rm -f /tmp/opencode/rofi-call-count /tmp/opencode/rofi-args-log.txt /tmp/opencode/rofi-selected.txt /tmp/opencode/dispatch-out.txt
    echo "Alpha.jpg" > /tmp/opencode/rofi-selected.txt
    rm -f "${AUTO_ROTATE_FILE:-/tmp/opencode/nope}"
}

echo "== F1: flujo completo de rotacion (t -> submenu 30min -> picker final con -mesg) =="
reset_all
export FAKE_MODE=time
AUTO_ROTATE=off
pick_wallpaper > /tmp/opencode/dispatch-out.txt
check "F1 out (timer->submenu->aplica)" "Alpha.jpg" "$(cat /tmp/opencode/dispatch-out.txt)"
check "F1 archivo persiste intervalo" "30min" "$(cat "${AUTO_ROTATE_FILE:-/tmp/opencode/nope}")"
check "F1 -mesg en picker final (rotacion activa)" "yes" "$(has_mgrep /tmp/opencode/rofi-args-log.txt)"

echo "== F2: picker carga intervalo persistido desde archivo =="
reset_all
export FAKE_MODE=""
AUTO_ROTATE=off
echo "30min" > "${AUTO_ROTATE_FILE:-/tmp/opencode/nope}"
rm -f /tmp/opencode/rofi-args-log.txt
out2="$(_pick_grid "todos")"
check "F2 out (seleccion desde picker)" "Alpha.jpg" "$out2"
check "F2 -mesg presente (timer cargado desde archivo)" "yes" "$(has_mgrep /tmp/opencode/rofi-args-log.txt)"

echo "== F3: sin intervalo activo -> picker sin -mesg =="
reset_all
export FAKE_MODE=""
AUTO_ROTATE=off
rm -f /tmp/opencode/rofi-args-log.txt
out3="$(_pick_grid "todos")"
check "F3 out" "Alpha.jpg" "$out3"
check "F3 -mesg ausente (rotacion off)" "no" "$(has_mgrep /tmp/opencode/rofi-args-log.txt)"

echo "== F4: flujo f -> __TOGGLE__ -> refrescar -> Enter aplica =="
reset_all
export FAKE_MODE=f
AUTO_ROTATE=off
echo "Beta.jpg" > /tmp/opencode/favs
echo "Beta.jpg" > /tmp/opencode/rofi-selected.txt
out4="$(pick_wallpaper)"
check "F4 out (f->toggle->refresh->aplica Beta)" "Beta.jpg" "$out4"

echo "== RESULT: picker_flow pass=${PASS} fail=${FAIL}"
[[ $FAIL -eq 0 ]]
