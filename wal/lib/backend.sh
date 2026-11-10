#!/usr/bin/env bash
# awww (static/frame bridge) and mpvpaper (video) backends.

_BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_BACKEND_DIR}/locks.sh"
source "${_BACKEND_DIR}/media.sh"

if ! declare -F apply_wal >/dev/null 2>&1; then
    source "${_BACKEND_DIR}/colors.sh"
fi

AWWW_DAEMON_BIN="${AWWW_DAEMON_BIN:-awww-daemon}"
AWWW_DAEMON_NAME="${AWWW_DAEMON_NAME:-awww-daemon}"
MPVPAPER_BIN="${MPVPAPER_BIN:-mpvpaper}"
LAST_MEDIA_FILE="${LAST_MEDIA_FILE:-${HOME}/.cache/wal/last-media}"
MPVPAPER_LOG="${MPVPAPER_LOG:-${HOME}/.cache/wal/mpvpaper.log}"

: "${TRANSITION:=wipe}"
: "${TRANSITION_DUR:=1}"
: "${TRANSITION_ANGLE:=45}"
: "${TRANSITION_STEP:=255}"
: "${MONITOR:=*}"
: "${AWW_BIN:=awww}"

ensure_awww_daemon() {
    if pgrep -x "$AWWW_DAEMON_NAME" >/dev/null 2>&1; then
        return 0
    fi

    mkdir -p "$(dirname "$LAST_MEDIA_FILE")"
    setsid -f "$AWWW_DAEMON_BIN" >/dev/null 2>&1 8>&- 9>&- || true

    local waited=0
    while (( waited < 50 )); do
        if pgrep -x "$AWWW_DAEMON_NAME" >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
        waited=$(( waited + 1 ))
    done
    return 1
}

stop_video_backend() {
    local pid
    while read -r pid; do
        [[ -n "$pid" ]] || continue
        pkill -TERM -P "$pid" 2>/dev/null || true
        kill -TERM "$pid" 2>/dev/null || true
    done < <(pgrep -x mpvpaper 2>/dev/null || true)

    sleep 0.3

    while read -r pid; do
        [[ -n "$pid" ]] || continue
        pkill -KILL -P "$pid" 2>/dev/null || true
        kill -KILL "$pid" 2>/dev/null || true
    done < <(pgrep -x mpvpaper 2>/dev/null || true)
}

show_cached_frame() {
    local path="" frame=""
    [[ -f "$LAST_MEDIA_FILE" ]] || return 0
    IFS= read -r path < "$LAST_MEDIA_FILE" || true
    [[ -n "$path" && -f "$path" ]] || return 0

    case "$(get_type "$path")" in
        image) frame="$path" ;;
        gif|video) frame="$(get_or_create_frame "$path" 2>/dev/null || true)" ;;
        *) return 0 ;;
    esac
    [[ -n "$frame" && -f "$frame" ]] || return 0

    ensure_awww_daemon || return 0
    "$AWW_BIN" img "$frame" --transition-type none 2>/dev/null || true
}

apply_image() {
    local path="$1"
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo "[dry-run] apply_image: $path"
        return 0
    fi
    [[ -f "$path" ]] || return 1

    stop_video_backend
    ensure_awww_daemon || return 1

    local -a targs=(
        img "$path"
        --transition-type "$TRANSITION"
        --transition-duration "$TRANSITION_DUR"
    )
    if [[ "$TRANSITION" == "wipe" || "$TRANSITION" == "wave" ]]; then
        targs+=(--transition-angle "$TRANSITION_ANGLE")
    fi
    targs+=(--transition-step "$TRANSITION_STEP")
    "$AWW_BIN" "${targs[@]}" 2>/dev/null
}

apply_video() {
    local path="$1"
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo "[dry-run] apply_video: $path"
        return 0
    fi
    [[ -f "$path" ]] || return 1

    local frame
    frame="$(get_or_create_frame "$path" 2>/dev/null || true)"
    if [[ -n "$frame" && -f "$frame" ]]; then
        ensure_awww_daemon || true
        "$AWW_BIN" img "$frame" \
            --transition-type fade --transition-duration 0.4 2>/dev/null || true
        sleep 0.1
    fi

    if wallpaper_locked; then
        return 0
    fi

    stop_video_backend
    mkdir -p "$(dirname "$MPVPAPER_LOG")"
    setsid -f "$MPVPAPER_BIN" -o "no-audio --hwdec=vaapi --loop-file=inf" \
        "$MONITOR" "$path" >"$MPVPAPER_LOG" 2>&1 8>&- 9>&-

    local waited=0
    while (( waited < 30 )); do
        if pgrep -x mpvpaper >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
        waited=$(( waited + 1 ))
    done
    return 1
}

apply_wallpaper() {
    local path="$1"
    local type
    [[ -f "$path" ]] || return 1
    type="$(get_type "$path")"
    [[ -n "$type" && "$type" != "unknown" ]] || return 1

    exec 8>"$WALLPAPER_LOCK"
    flock -w 30 8 || { exec 8>&-; return 1; }

    local rc=0
    case "$type" in
        image) apply_image "$path" || rc=1 ;;
        gif|video) apply_video "$path" || rc=1 ;;
    esac

    if (( rc == 0 )) && [[ "${DRY_RUN:-false}" != "true" ]]; then
        mkdir -p "$(dirname "$LAST_MEDIA_FILE")"
        printf '%s\n' "$path" > "${LAST_MEDIA_FILE}.$$"
        mv -f "${LAST_MEDIA_FILE}.$$" "$LAST_MEDIA_FILE"
    fi

    if (( rc == 0 )); then
        if [[ "$type" == "image" ]]; then
            apply_wal "$path" || true
        else
            local wal_target
            wal_target="$(get_or_create_frame "$path" 2>/dev/null || true)"
            [[ -n "$wal_target" && -f "$wal_target" ]] || wal_target="$path"
            apply_wal "$wal_target" || true
        fi
    fi

    exec 8>&-
    return "$rc"
}

restore_last_media() {
    local path="" last="" base="" stem="" candidate=""
    local wal_history="${WAL_HISTORY:-${HOME}/.cache/wal/wal}"
    local wall_dir="${WALL_DIR:-${HOME}/Pictures/wallpapers/1080p}"

    if [[ -f "$LAST_MEDIA_FILE" ]]; then
        IFS= read -r path < "$LAST_MEDIA_FILE" || true
    fi

    if [[ -z "$path" || ! -f "$path" ]]; then
        if [[ -f "$wal_history" ]]; then
            last="$(cat "$wal_history" 2>/dev/null || true)"
            base="$(basename "$last")"
            stem="${base%.*}"
            candidate="$(find "$wall_dir" -maxdepth 1 -type f \( \
                -iname "${stem}.mp4" -o -iname "${stem}.webm" -o \
                -iname "${stem}.mkv" -o -iname "${stem}.gif" \
            \) -print -quit 2>/dev/null || true)"
            [[ -n "$candidate" ]] && path="$candidate"
        fi
    fi

    [[ -n "$path" && -f "$path" ]] || return 0

    case "$(get_type "$path")" in
        image)
            ensure_awww_daemon || true
            "$AWW_BIN" img "$path" --transition-type none 2>/dev/null || true
            ;;
        gif|video)
            pgrep -x mpvpaper >/dev/null 2>&1 || apply_video "$path"
            ;;
    esac
}

apply_last_wallpaper() {
    restore_last_media
}
