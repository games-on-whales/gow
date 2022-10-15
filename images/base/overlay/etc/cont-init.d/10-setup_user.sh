#!/usr/bin/env bash

set -e

gow_log "**** Configure default user ****"

if [[ "${UNAME}" != "root" ]]; then
    PUID=${PUID:-1000}
    PGID=${PGID:-1000}
    UMASK=${UMASK:-000}
    USER_PASSWORD=${USER_PASSWORD:-password}

    gow_log "Setting default user uid=${PUID}(${UNAME}) gid=${PGID}(${UNAME})"
    usermod -o -u "${PUID}" ${UNAME}
    groupmod -o -g "${PGID}" ${UNAME}

    gow_log "Setting umask to ${UMASK}";
    umask ${UMASK}

    gow_log "Setting user password"
    echo "${UNAME}:${USER_PASSWORD}" | chpasswd
else
    gow_log "Container running as root. Nothing to do."
fi

gow_log "DONE"
