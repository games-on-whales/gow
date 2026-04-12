#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "[start] Starting Gamepad-UI"

source /opt/gow/launch-comp.sh

# Use gamescope by default unless an explicit compositor mode is provided.
if [ -z "$RUN_GAMESCOPE" ] && [ -z "$RUN_SWAY" ]; then
    export RUN_GAMESCOPE=1
fi
# Enable standalone UI behavior by default in container deployments.
export STANDALONE_SESSION=${STANDALONE_SESSION:-1}
# Workaround:
# Enable SDL support cuz Electron Gamepad-API does not work
# see https://github.com/games-on-whales/gow/pull/293#issuecomment-4150484665
# This could lead to wrong button mapping for Dualsense controllers,
# see https://github.com/games-on-whales/gow/pull/293#issuecomment-4169381777
export LUTRIS_GAMEPAD_UI_ENABLE_SDL_INPUT=${LUTRIS_GAMEPAD_UI_ENABLE_SDL_INPUT:-1}

launcher /opt/gow/app/AppRun
