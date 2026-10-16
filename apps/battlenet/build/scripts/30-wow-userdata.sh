#!/usr/bin/env bash
# Per-user WoW data. The folder is /userdata when mounted (override with BNET_USERDATA),
# otherwise ~/userdata in Wolf's per-profile home, so new profiles need no setup. Every
# installed WoW flavor gets that user's own WTF and Interface/AddOns bind-mounted over the
# shared game folder, inside this container only. The game files stay shared; settings,
# addons and saved variables do not. Nothing is copied: a new user starts with empty folders.
#
# A flavor counts as installed when its folder has the .flavor.info marker and a Wow*.exe
# (found on /games and every Wine drive, so the install location does not matter). It is
# checked at start and then every BNET_USERDATA_INTERVAL seconds (default 5), so a game
# installed during the session is picked up before its first launch. Disable the watcher
# with BNET_USERDATA_WATCH=0, and the whole feature with BNET_USERDATA_DISABLE=1. BNET_USERDATA_DRYRUN=1 only prints what would be mounted.
#
# NOTE: entrypoint.sh SOURCES this file under `set -e`: never `exit`, and never let a
# command fail unhandled. Everything lives in functions that always return 0.

_bnet_wow_userdata_pass() {
    local userdata="${BNET_USERDATA:-/userdata}"
    # An explicit mount at /userdata wins; otherwise use a folder in Wolf's per-profile home.
    if ! mountpoint -q "$userdata" 2>/dev/null; then
        [ -n "${BNET_USERDATA:-}" ] && [ -d "$userdata" ] || userdata="${HOME}/userdata"
    fi
    mkdir -p "$userdata" 2>/dev/null || return 0

    local persist="${PERSIST_DIR:-}"
    if [ -z "$persist" ]; then
        if mountpoint -q /home/retro-persist 2>/dev/null; then persist=/home/retro-persist; else persist="${HOME}/.bnet"; fi
    fi
    local run_uid="${PUID:-1000}" run_gid="${PGID:-1000}"

    # Search the games dir and every drive Wine knows (C: lives in the prefix).
    local roots=() link target
    [ -d /games ] && roots+=(/games)
    [ -d "$persist/drive_c" ] && roots+=("$persist/drive_c")
    for link in "$persist"/dosdevices/*:; do
        [ -e "$link" ] || continue
        target=$(readlink -f "$link") || continue
        [ "$target" = "/" ] && continue          # z: maps to the whole filesystem
        [ -d "$target" ] && roots+=("$target")
    done
    [ "${#roots[@]}" -gt 0 ] || return 0

    local -A seen=()
    local marker dir flavor real pair name rel src dst
    while IFS= read -r marker; do
        dir=$(dirname "$marker")
        flavor=$(basename "$dir")
        case "$flavor" in _*_) ;; *) continue ;; esac
        compgen -G "$dir/Wow*.exe" >/dev/null || continue   # install not finished yet
        real=$(readlink -f "$dir") || continue
        if [ -n "${seen[$real]:-}" ]; then continue; fi
        seen[$real]=1

        for pair in "WTF:WTF" "AddOns:Interface/AddOns"; do
            name="${pair%%:*}"
            rel="${pair#*:}"
            src="$userdata/wow/$flavor/$name"
            dst="$dir/$rel"
            if [ -n "${BNET_USERDATA_DRYRUN:-}" ]; then
                echo "would mount $src -> $dst"
                continue
            fi
            if mountpoint -q "$dst" 2>/dev/null; then continue; fi
            mkdir -p "$src" "$dst" 2>/dev/null || { _bnet_log "WoW $flavor: cannot create $src or $dst"; continue; }
            chown "$run_uid:$run_gid" "$userdata" "$userdata/wow" "$userdata/wow/$flavor" "$src" 2>/dev/null || true
            if mount --bind "$src" "$dst"; then
                _bnet_log "WoW $flavor: $name from $src"
            else
                _bnet_log "WoW $flavor: could not bind-mount $src over $dst"
            fi
        done
    done < <(find "${roots[@]}" -maxdepth 5 -name .flavor.info 2>/dev/null)
    return 0
}

_bnet_log() {
    if declare -F gow_log >/dev/null; then gow_log "$*"; else echo "$*"; fi
}

# BNET_USERDATA_DISABLE=1 (environment variable of the app) turns the whole feature off.
if [ "${BNET_USERDATA_DISABLE:-0}" != "1" ]; then
    _bnet_wow_userdata_pass || true

    if [ -z "${BNET_USERDATA_DRYRUN:-}" ] && [ "${BNET_USERDATA_WATCH:-1}" != "0" ]; then
        (
            set +e
            exec >>/tmp/bnet-userdata.log 2>&1
            while sleep "${BNET_USERDATA_INTERVAL:-5}"; do
                _bnet_wow_userdata_pass
            done
        ) &
        disown 2>/dev/null || true
    fi
fi
