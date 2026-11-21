#!/usr/bin/env bash

set -e

gow_log "**** Check user ****"

# The user was created at build time; to use a different uid start the
# container with --user (and map it, e.g. rootless Podman's --userns keep-id)
# Same as 10-setup_user.sh: system users (such as 'pulse') keep the default
if [ "$(id -u)" -ge 1000 ]; then
    UMASK="${UMASK:-000}"
    gow_log "Setting umask to ${UMASK}"
    umask "${UMASK}"
fi

if ! id -un &>/dev/null; then
    gow_log "WARNING: uid $(id -u) has no passwd entry, some apps need one. Start as '${UNAME}' (uid $(id -u "${UNAME}" 2>/dev/null || echo '?')) instead"
fi

if [ ! -w "${HOME}" ]; then
    gow_log "WARNING: HOME (${HOME}) isn't writable by uid $(id -u). Mount it owned by this user (rootless Podman: --userns keep-id:uid=$(id -u),gid=$(id -g))"
fi

if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    mkdir -p "${XDG_RUNTIME_DIR}" 2>/dev/null || true
    if [ ! -w "${XDG_RUNTIME_DIR}" ]; then
        gow_log "WARNING: XDG_RUNTIME_DIR (${XDG_RUNTIME_DIR}) isn't writable by uid $(id -u)"
    fi
fi

gow_log "DONE"
