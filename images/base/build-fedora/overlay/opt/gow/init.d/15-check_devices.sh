#!/usr/bin/env bash

set -e

gow_log "**** Check devices ****"

# Without root, ensure-groups can't add the user to the device groups or chmod
# the nodes. The runtime has to pass the groups in; only check and say so.
# Relying on word splitting and globbing, same as 15-setup_devices.sh
# shellcheck disable=SC2086
for dev in ${GOW_REQUIRED_DEVICES:-/dev/uinput /dev/input/event*}; do
    if [ ! -e "$dev" ]; then
        gow_log "Path '$dev' is not present."
    elif [ ! -c "$dev" ]; then
        continue
    elif [ ! -r "$dev" ] || [ ! -w "$dev" ]; then
        gow_log "WARNING: no read/write access to $dev ($(stat -c '%U:%G %a' "$dev")). Pass its group in: --group-add keep-groups (rootless Podman) or --group-add $(stat -c %g "$dev")"
    fi
done

gow_log "DONE"
