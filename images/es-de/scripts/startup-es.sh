#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Launching EmulationStation-DE"

if [ -n "$RUN_GAMESCOPE" ]; then
  GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
  GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
  GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}
  GAMESCOPE_MODE=${GAMESCOPE_MODE:-"-b"}
  /usr/games/gamescope ${GAMESCOPE_MODE} -W ${GAMESCOPE_WIDTH} -H ${GAMESCOPE_HEIGHT} -r ${GAMESCOPE_REFRESH} -- /Applications/esde.AppImage --appimage-extract-and-run --no-update-check
else
 exec /Applications/esde.AppImage --appimage-extract-and-run --no-update-check
fi