#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "Starting Anki"

source /opt/gow/launch-comp.sh

export ANKI_WAYLAND=1
export LC_ALL=C.UTF-8
launcher /usr/local/share/anki/anki