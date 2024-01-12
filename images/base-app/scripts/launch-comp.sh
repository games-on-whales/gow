#!/bin/bash

function launcher() {
  APP_TO_LAUNCH=$1

  if [ -n "$RUN_GAMESCOPE" ]; then
    echo "Gamescope - Starting Pegasus"
    export GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
    export GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
    export GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
    export GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
    /usr/games/gamescope "${GAMESCOPE_MODE}" -W "${GAMESCOPE_WIDTH}" -H "${GAMESCOPE_HEIGHT}" -r "${GAMESCOPE_REFRESH}" -- ${APP_TO_LAUNCH}
  else
    echo "Sway - Starting Application: ${APP_TO_LAUNCH}"
    export XDG_SESSION_TYPE=wayland
    mkdir -p $HOME/.config/sway/
    cp /cfg/sway/config $HOME/.config/sway/config
    # Modify the config file to launch the ${APP_TO_LAUNCH} at the end
    echo "workspace main; exec ${APP_TO_LAUNCH}" >> $HOME/.config/sway/config
    # Start sway
    exec sway --unsupported-gpu
  fi
}