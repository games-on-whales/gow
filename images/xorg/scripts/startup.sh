#!/bin/bash
set -e 

# If the host is using the proprietary Nvidia driver, make sure the
# corresponding xorg driver is installed
if [ -f /proc/driver/nvidia/version ]; then
    echo "Detected Nvidia drivers, installing them..."
    bash /ensure-nvidia-xorg-driver.sh
fi


# Cleaning up /tmp/ otherwise Xorg will error out if you stop and restart the container
DISPLAY_FILE=/tmp/.X11-unix/X${DISPLAY:1}
if [ -S ${DISPLAY_FILE} ]; then
  echo "Removing ${DISPLAY_FILE} before starting"
  rm -f /tmp/.X0-lock
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

wait $xorg
wait $jwm