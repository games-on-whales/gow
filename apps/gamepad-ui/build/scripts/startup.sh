#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "[start] Starting LUTRIS-GAMEPAD-UI"

source /opt/gow/launch-comp.sh

# Use gamescope by default unless an explicit compositor mode is provided.
if [ -z "$RUN_GAMESCOPE" ] && [ -z "$RUN_SWAY" ]; then
    export RUN_GAMESCOPE=1
fi

launcher /bin/gamepadui.sh
