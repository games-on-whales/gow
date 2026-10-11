#!/usr/bin/env bash
# Optional per-user WoW data. When a folder is mounted at /userdata (override with
# BNET_USERDATA), every installed WoW flavor gets that user's own WTF and
# Interface/AddOns bind-mounted over the shared game folder, inside this container
# only. The game files stay shared; settings, addons and saved variables do not.
# Installs are found by their .flavor.info marker, so the install location does not
# matter. Nothing is copied: a new user starts with empty folders.
# BNET_USERDATA_DRYRUN=1 only prints what would be mounted.
#
# NOTE: entrypoint.sh SOURCES this file under `set -e`: never `exit`, and never let a
# command fail unhandled. Everything lives in a function that always returns 0.
_bnet_wow_userdata() {
    local userdata="${BNET_USERDATA:-/userdata}"
    [ -d "$userdata" ] || return 0

    local persist="${PERSIST_DIR:-/home/retro-persist}"
    local run_uid="${PUID:-1000}" run_gid="${PGID:-1000}"
    _bnet_log() { if declare -F gow_log >/dev/null; then gow_log "$*"; else echo "$*"; fi; }

    # Search the games dir and every drive Wine knows (C: lives in the prefix).
    local roots=() link target
    [ -d /games ] && roots+=(/games)
    [ -d "$persist/drive_c" ] && roots+=("$persist/drive_c")
    for link in "$persist"/dosdevices/*:; do
        [ -e "$link" ] || continue
        target=$(readlink -f "$link") || continue
        [ -d "$target" ] && roots+=("$target")
    done
    [ "${#roots[@]}" -gt 0 ] || return 0

    local -A seen=()
    local marker dir flavor real pair name rel src dst
    while IFS= read -r marker; do
        dir=$(dirname "$marker")
        flavor=$(basename "$dir")
        case "$flavor" in _*_) ;; *) continue ;; esac
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
            mkdir -p "$src" "$dst" 2>/dev/null || { _bnet_log "WoW $flavor: cannot create $src or $dst"; continue; }
            chown "$run_uid:$run_gid" "$userdata/wow" "$userdata/wow/$flavor" "$src" 2>/dev/null || true
            if mountpoint -q "$dst"; then continue; fi
            if mount --bind "$src" "$dst"; then
                _bnet_log "WoW $flavor: $name from $src"
            else
                _bnet_log "WoW $flavor: could not bind-mount $src over $dst"
            fi
        done
    done < <(find "${roots[@]}" -maxdepth 6 -name .flavor.info 2>/dev/null)
    return 0
}

_bnet_wow_userdata || true
unset -f _bnet_wow_userdata _bnet_log 2>/dev/null || true
