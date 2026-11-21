#!/usr/bin/env bash

set -e

gow_log "**** Configure default user ****"

if [[ "${UNAME}" != "root" ]] && id -u "${UNAME}" &>/dev/null && [ "$(id -u "${UNAME}")" -lt 1000 ]; then
    # System user from the image (such as 'pulse'): keep it as it is.
    # Don't recreate it with PUID and PGID.
    gow_log "Using existing system user $(id "${UNAME}")"

    if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
        gow_log "Ensure XDG_RUNTIME_DIR is writable"
        mkdir -p "${XDG_RUNTIME_DIR}"
        chown -R "${UNAME}:" "${XDG_RUNTIME_DIR}"
    fi
elif [[ "${UNAME}" != "root" ]]; then
    PUID="${PUID:-1000}"
    PGID="${PGID:-1000}"
    UMASK="${UMASK:-000}"

    gow_log "Setting default user uid=${PUID}(${UNAME}) gid=${PGID}(${UNAME})"
    if id -u "${PUID}" &>/dev/null && [ "$(id -nu "${PUID}")" != "${UNAME}" ]; then
        # Another user has $PUID: delete it, then give $UNAME that UID
        oldname=$(id -nu "${PUID}")
        userdel -r "${oldname}"
    fi

    if id -u "${UNAME}" &>/dev/null; then
        # Created at build time with 1000:1000. Change the IDs in place: userdel
        # -r would wipe $HOME, which is usually a mounted volume.
        if [ "$(getent group "${UNAME}" | cut -d: -f3)" != "${PGID}" ]; then
            groupmod -o -g "${PGID}" "${UNAME}"
        fi
        if [ "$(id -u "${UNAME}")" != "${PUID}" ] || [ "$(id -g "${UNAME}")" != "${PGID}" ]; then
            usermod -o -u "${PUID}" -g "${PGID}" "${UNAME}"
        fi
    else
        groupadd -f -g "${PGID}" ${UNAME}
        useradd -m -d ${HOME} -u "${PUID}" -g "${PGID}" -s /bin/bash ${UNAME}
    fi

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
