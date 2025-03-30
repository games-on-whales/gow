#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

function launcher() {
  export GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  export GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  export GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}

  if [ -n "$RUN_GAMESCOPE" ]; then
    gow_log "[Gamescope] - Starting: \`$@\`"

    GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
    /usr/games/gamescope "${GAMESCOPE_MODE}" -W "${GAMESCOPE_WIDTH}" -H "${GAMESCOPE_HEIGHT}" -r "${GAMESCOPE_REFRESH}" -- "$@"
  elif [ -n "$RUN_SWAY" ]; then
    gow_log "[Sway] - Starting: \`$@\`"

    export SWAY_STOP_ON_APP_EXIT=${SWAY_STOP_ON_APP_EXIT:-"yes"}
    export XDG_CURRENT_DESKTOP=sway # xdg-desktop-portal
    export XDG_SESSION_DESKTOP=sway # systemd
    export XDG_SESSION_TYPE=wayland # xdg/systemd

    # Only copy waybar default config if it doesn't exist
    mkdir -p $HOME/.config/waybar
    cp -u /cfg/waybar/* $HOME/.config/waybar/

    # Only copy mangohud default config if it doesn't exist
    mkdir -p $HOME/.config/MangoHud/
    cp -u /cfg/MangoHud/MangoHud.conf $HOME/.config/MangoHud/MangoHud.conf

    # Sway needs to be overridden since we are going to change the resolution and app start
    mkdir -p $HOME/.config/sway/
    cp /cfg/sway/config $HOME/.config/sway/config
    # Modify the config file for res and to launch the app at the end
    echo "output * resolution ${GAMESCOPE_WIDTH}x${GAMESCOPE_HEIGHT} position 0,0" >> $HOME/.config/sway/config
    echo -n "workspace main; exec $@" >> $HOME/.config/sway/config

    # if SWAY_STOP_ON_APP_EXIT == "yes" then kill sway when the app exits
    if [ "$SWAY_STOP_ON_APP_EXIT" == "yes" ]; then
      echo -n " && killall sway" >> $HOME/.config/sway/config
    fi

    # Start sway
    dbus-run-session -- sway --unsupported-gpu
  else
    gow_log "[exec] Starting: $@"

    exec $@
  fi
}
