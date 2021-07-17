#!/bin/bash
set -e 
function LOG {
    echo $(date -R): $0: $*
}

ensure-groups ${GOW_REQUIRED_DEVICES:-/dev/uinput /dev/input/event*}

# If the host is using the proprietary Nvidia driver, make sure the
# corresponding xorg driver is installed
if [ -f /proc/driver/nvidia/version ]; then
    LOG "Detected Nvidia drivers, installing them..."
    bash /ensure-nvidia-xorg-driver.sh
fi

# Cleaning up /tmp/ otherwise Xorg will error out if you stop and restart the container
DISPLAY_NUMBER=${DISPLAY:1}
DISPLAY_FILE=/tmp/.X11-unix/X${DISPLAY_NUMBER}
if [ -S ${DISPLAY_FILE} ]; then
  LOG "Removing ${DISPLAY_FILE} before starting"
  rm -f /tmp/.X${DISPLAY_NUMBER}-lock
  rm ${DISPLAY_FILE}
fi

_kill_procs() {
  kill -TERM $xorg
  wait $xorg
  kill -TERM $jwm
  wait $jwm
}

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

# Start Xorg
# TODO: set $RESOLUTION
echo "Starting Xorg (${DISPLAY})"
Xorg -ac -noreset +extension GLX +extension RANDR +extension RENDER vt1 ${DISPLAY} &
xorg=$!

jwm &
jwm=$!

# Setting up resolution
RESOLUTION=${RESOLUTION:-1920x1080}
REFRESH_RATE=${REFRESH_RATE:-60}
wait-x11

CURRENT_OUTPUT=$(xrandr --current | awk 'FNR==2{print $1;}')
xrandr --addmode ${CURRENT_OUTPUT} ${RESOLUTION} 
xrandr --output ${CURRENT_OUTPUT} --mode ${RESOLUTION} --rate ${REFRESH_RATE}

wait $xorg
wait $jwm
