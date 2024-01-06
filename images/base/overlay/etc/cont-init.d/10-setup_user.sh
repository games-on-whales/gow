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
        oldname=$(id -nu "${PUID}")
        userdel -r "${oldname}"
    fi

    usermod -u "${PUID}" "${UNAME}"
    groupmod -o -g "${PGID}" "${UNAME}"

    gow_log "Setting umask to ${UMASK}"
    umask "${UMASK}"

    gow_log "Ensure retro home directory is writable"
    chown "${PUID}:${PGID}" "${HOME}"

    gow_log "Ensure XDG_RUNTIME_DIR is writable"
    chown -R "${PUID}:${PGID}" "${XDG_RUNTIME_DIR}"
else
    gow_log "Container running as root. Nothing to do."
fi

gow_log "DONE"
