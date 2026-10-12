#!/usr/bin/env bash

set -e

gow_log "**** Configure default user ****"

if [[ "${UNAME}" != "root" ]]; then
    PUID="${PUID:-1000}"
    PGID="${PGID:-1000}"
    UMASK="${UMASK:-000}"

    gow_log "Setting default user uid=${PUID}(${UNAME}) gid=${PGID}(${UNAME})"
    if id -u "${PUID}" &>/dev/null; then
        # need to delete the old user $PUID then change $UNAME's UID
        # default ubuntu image comes with user `ubuntu` and UID 1000
        oldname=$(id -nu "${PUID}")
        userdel -r "${oldname}"
    fi

    groupadd -f -g "${PGID}" "${UNAME}"
    useradd -m -d "${HOME}" -u "${PUID}" -g "${PGID}" -s /bin/bash "${UNAME}"

    gow_log "Setting umask to ${UMASK}"
    umask "${UMASK}"

    gow_log "Ensure retro home directory is writable"
    chown "${PUID}:${PGID}" "${HOME}"
    # Root build steps run with HOME set to this dir and leave root-owned files
    # in it (Fedora's wget2 HSTS cache, add-apt-repository's launchpadlib
    # cache). Hand those over, unless HOME is a mounted volume, which hides the
    # image's copy anyway. -xdev keeps find out of volumes mounted below HOME,
    # and the device check skips their mount points, which find still lists.
    root_dev=$(stat -c %d /)
    if [ "$(stat -c %d "${HOME}")" = "${root_dev}" ]; then
        while IFS= read -r -d '' entry; do
            if [ "${entry%% *}" = "${root_dev}" ]; then
                chown -h "${PUID}:${PGID}" "${entry#* }"
            fi
        done < <(find "${HOME}" -xdev -user 0 -printf '%D %p\0')
    fi

    # Wolf always passes an existing XDG_RUNTIME_DIR; plain docker run and
    # compose may not set it, or point it at a dir that doesn't exist yet.
    if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
        gow_log "Ensure XDG_RUNTIME_DIR is writable"
        if [ ! -d "${XDG_RUNTIME_DIR}" ]; then
            mkdir -p "$(dirname "${XDG_RUNTIME_DIR}")"
            mkdir -m 700 "${XDG_RUNTIME_DIR}"
        fi
        chown -R "${PUID}:${PGID}" "${XDG_RUNTIME_DIR}"
    fi
else
    gow_log "Container running as root. Nothing to do."
fi

gow_log "DONE"
