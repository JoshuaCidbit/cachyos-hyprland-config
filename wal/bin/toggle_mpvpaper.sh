#!/usr/bin/env bash
SCRIPT="$(dirname "${BASH_SOURCE[0]}")/wallpaper_picker.sh"

if pgrep -x mpvpaper >/dev/null 2>&1; then
    exec "$SCRIPT" --kill
else
    exec "$SCRIPT" --restore
fi

