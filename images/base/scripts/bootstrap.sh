#!/bin/bash

# if there are any errors, exit
set -e

source /opt/gow/bash-lib/utils.sh

# make sure we're in the right groups to use all the required devices
# we're actually relying on word splitting for this call, so disable the
# warning from shellcheck
# shellcheck disable=SC2086
/opt/gow/ensure-groups ${GOW_REQUIRED_DEVICES:-/dev/uinput /dev/input/event*}

gow_log "Launching the container's startup script"

# launch the container's startup script. use sudo to force group memberships to
# be reloaded, since they may have been changed by ensure-groups
exec sudo -u "$(whoami)" -E /opt/gow/startup.sh
