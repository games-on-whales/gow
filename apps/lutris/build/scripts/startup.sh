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

if [ ${WOLF_LUTRIS_GAMEPAD_UI_ENABLE:-1} -eq 1 ]; then
    if [ -z "$RUN_GAMESCOPE" ] && [ -z "$RUN_SWAY" ]; then
        export RUN_GAMESCOPE=1
    fi
    export STANDALONE_SESSION=${STANDALONE_SESSION:-1}
    export LUTRIS_GAMEPAD_UI_ENABLE_SDL_INPUT=${LUTRIS_GAMEPAD_UI_ENABLE_SDL_INPUT:-1}
    export LUTRIS_GAMEPAD_UI_DISABLE_AUDIO_SETTINGS=${LUTRIS_GAMEPAD_UI_DISABLE_AUDIO_SETTINGS:-1}
    export LUTRIS_GAMEPAD_UI_DISABLE_DISPLAY_SETTINGS=${LUTRIS_GAMEPAD_UI_DISABLE_DISPLAY_SETTINGS:-1}
    export LUTRIS_GAMEPAD_UI_DISABLE_BLUETOOTH_SETTINGS=${LUTRIS_GAMEPAD_UI_DISABLE_BLUETOOTH_SETTINGS:-1}
    export LUTRIS_GAMEPAD_UI_DISABLE_REBOOT_SYSTEM=${LUTRIS_GAMEPAD_UI_DISABLE_REBOOT_SYSTEM:-1}
    export LUTRIS_GAMEPAD_UI_DISABLE_POWER_OFF_SYSTEM=${LUTRIS_GAMEPAD_UI_DISABLE_POWER_OFF_SYSTEM:-1}
    launcher /opt/gow/app/AppRun
else
    launcher "${LUTRIS}" "${LUTRIS_ARGS[@]}"
fi
