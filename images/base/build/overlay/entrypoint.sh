#!/usr/bin/env bash

set -e

# Source functions from GOW utils
source /opt/gow/bash-lib/utils.sh

# Execute all container init scripts. Only run this if the container is started as the root user
if [ "$(id -u)" = "0" ]; then
    for init_script in /etc/cont-init.d/*.sh ; do
        gow_log
        gow_log "[ ${init_script}: executing... ]"
        #sed -i 's/\r$//' "${init_script}" # Remove Windows line endings
        # shellcheck source=/dev/null
        source "${init_script}"
    done
fi

# If a command was passed, run that instead of the usual init startup script
# shellcheck disable=SC2198
if [ -n "${@:-}" ]; then
    /bin/bash -c "$@"
    exit $?
fi

# Launch startup script as 'UNAME' user (some services will run as root)
gow_log "Launching the container's startup script as user '${UNAME}'"
[ -x /opt/gow/startup.sh ] || chmod +x /opt/gow/startup.sh

# gosu needs CAP_SETUID and CAP_SETGID, even if the user doesn't change.
# Skip it when already running as UNAME, so all capabilities can be dropped.
if [ "$(id -u)" = "$(id -u "${UNAME}" 2>/dev/null)" ]; then
    exec /opt/gow/startup.sh
fi
# Only root can switch users, so stay as the current user.
if [ "$(id -u)" != "0" ]; then
    gow_log "Not running as root, staying uid $(id -u) instead of switching to '${UNAME}'"
    exec /opt/gow/startup.sh
fi
exec gosu "${UNAME}" /opt/gow/startup.sh
