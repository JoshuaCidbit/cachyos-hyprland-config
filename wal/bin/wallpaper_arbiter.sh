#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

source "${LIB_DIR}/config.sh"
source "${LIB_DIR}/locks.sh"
source "${LIB_DIR}/media.sh"
source "${LIB_DIR}/backend.sh"

exec 9>"$WALLPAPER_LOCK"
flock -w 10 9 || exit 0

refresh_fullscreen_lock
sync_gamemode_lock

if wallpaper_locked; then
    stop_video_backend
    show_cached_frame
else
    restore_last_media
fi
