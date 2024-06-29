#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

LUTRIS=/usr/games/lutris

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "[start] Starting Lutris"

source /opt/gow/launch-comp.sh
launcher "${LUTRIS}" "${LUTRIS_ARGS[@]}"
