#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting Steam with DISPLAY=${DISPLAY}"

# Recursively creating Steam necessary folders (https://github.com/ValveSoftware/steam-for-linux/issues/6492)
mkdir -p "$HOME/.steam/ubuntu12_32/steam-runtime"

STEAM_STARTUP_FLAGS=${STEAM_STARTUP_FLAGS:-"-oldbigpicture -bigpicture"}

dbus-daemon --session --fork

if [ -n "$RUN_GAMESCOPE" ]; then
  GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
  GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
  # shellcheck disable=SC2086
  /usr/games/gamescope "${GAMESCOPE_MODE}" -W "${GAMESCOPE_WIDTH}" -H "${GAMESCOPE_HEIGHT}" -r "${GAMESCOPE_REFRESH}" -- /usr/games/steam ${STEAM_STARTUP_FLAGS}
else
  # shellcheck disable=SC2086
  exec /usr/games/steam ${STEAM_STARTUP_FLAGS}
fi
