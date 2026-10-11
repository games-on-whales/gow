#!/usr/bin/env bash
# Optional per-user WoW data. When a folder is mounted at /userdata (override with
# BNET_USERDATA), every installed WoW flavor gets that user's own WTF and
# Interface/AddOns bind-mounted over the shared game folder, inside this container
# only. The game files stay shared; settings, addons and saved variables do not.
# Installs are found by their .flavor.info marker, so the install location does not
# matter. Nothing is copied: a new user starts with empty folders.
# BNET_USERDATA_DRYRUN=1 only prints what would be mounted.
USERDATA="${BNET_USERDATA:-/userdata}"
[ -d "$USERDATA" ] || exit 0

PERSIST="${PERSIST_DIR:-/home/retro-persist}"
UID_="${PUID:-1000}"
GID_="${PGID:-1000}"
log() { if declare -F gow_log >/dev/null; then gow_log "$*"; else echo "$*"; fi; }

# Search the games dir and every drive Wine knows (C: lives in the prefix).
roots=()
[ -d /games ] && roots+=(/games)
[ -d "$PERSIST/drive_c" ] && roots+=("$PERSIST/drive_c")
for link in "$PERSIST"/dosdevices/*:; do
    [ -e "$link" ] || continue
    target=$(readlink -f "$link")
    [ -d "$target" ] && roots+=("$target")
done
[ "${#roots[@]}" -gt 0 ] || exit 0

declare -A seen
while IFS= read -r marker; do
    dir=$(dirname "$marker")
    flavor=$(basename "$dir")
    case "$flavor" in _*_) ;; *) continue ;; esac
    real=$(readlink -f "$dir")
    [ -n "${seen[$real]}" ] && continue
    seen[$real]=1

    for pair in "WTF:WTF" "AddOns:Interface/AddOns"; do
        name="${pair%%:*}"
        rel="${pair#*:}"
        src="$USERDATA/wow/$flavor/$name"
        dst="$dir/$rel"
        if [ -n "$BNET_USERDATA_DRYRUN" ]; then
            echo "would mount $src -> $dst"
            continue
        fi
        mkdir -p "$src" "$dst" 2>/dev/null
        chown "$UID_:$GID_" "$USERDATA/wow" "$USERDATA/wow/$flavor" "$src" 2>/dev/null
        if mountpoint -q "$dst"; then
            continue
        fi
        if mount --bind "$src" "$dst"; then
            log "WoW $flavor: $name from $src"
        else
            log "WoW $flavor: could not bind-mount $src over $dst"
        fi
    done
done < <(find "${roots[@]}" -maxdepth 6 -name .flavor.info 2>/dev/null)

exit 0
