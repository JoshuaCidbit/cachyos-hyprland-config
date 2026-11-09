#!/usr/bin/env bash
# tests/run_tests.sh — Runner de la suite de tests de wal
# ─────────────────────────────────────────────────────────────────────────────
# Tests incluidos:
#   tests/lib_test.sh       → tests unitarios de librerías (sin deps externas)
#   tests/picker_flow_test.sh → integración del picker con fake rofi
#
# Uso:
#   bash tests/run_tests.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/lib_test.sh"
rc1=$?

bash "${SCRIPT_DIR}/picker_flow_test.sh"
rc2=$?

echo "== RESULT: lib=${rc1} picker_flow=${rc2}"
[[ $rc1 -eq 0 && $rc2 -eq 0 ]]
