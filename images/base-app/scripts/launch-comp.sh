#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

function launcher() {
  APP_TO_LAUNCH=$1
  export GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  export GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  export GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}

  if [ -n "$RUN_GAMESCOPE" ]; then
    gow_log "[Gamescope] - Starting: ${APP_TO_LAUNCH}"

    GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
    /usr/games/gamescope "${GAMESCOPE_MODE}" -W "${GAMESCOPE_WIDTH}" -H "${GAMESCOPE_HEIGHT}" -r "${GAMESCOPE_REFRESH}" -- ${APP_TO_LAUNCH}
  elif [ -n "$RUN_SWAY" ]; then
    gow_log "[Sway] - Starting: ${APP_TO_LAUNCH}"

    export XDG_SESSION_TYPE=wayland
    mkdir -p $HOME/.config/sway/
    cp /cfg/sway/config $HOME/.config/sway/config
    # Modify the config file for res and to launch the ${APP_TO_LAUNCH} at the end
    echo "output * resolution ${GAMESCOPE_WIDTH}x${GAMESCOPE_HEIGHT} position 0,0" >> $HOME/.config/sway/config
    echo "workspace main; exec ${APP_TO_LAUNCH}" >> $HOME/.config/sway/config

    # Start sway
    dbus-run-session -- sway --unsupported-gpu
  else
    gow_log "[exec] Starting: ${APP_TO_LAUNCH}"

    exec ${APP_TO_LAUNCH}
  fi
}