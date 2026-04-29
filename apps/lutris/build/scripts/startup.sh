#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

LUTRIS=$(which lutris)

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "[start] Starting Lutris"

source /opt/gow/launch-comp.sh

if [ ${WOLF_LUTRIS_GAMEPAD_UI_ENABLE:-1} -eq 1 ]; then
    if [ -z "$RUN_GAMESCOPE" ] && [ -z "$RUN_SWAY" ]; then
        export RUN_GAMESCOPE=1
    fi
    launcher /opt/gow/app/AppRun
else
    if [ -z "$RUN_GAMESCOPE" ] && [ -z "$RUN_SWAY" ]; then
        export RUN_SWaY=1
    fi
    launcher "${LUTRIS}" "${LUTRIS_ARGS[@]}"
fi
