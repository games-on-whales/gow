#!/bin/bash
set -e 

# If the host is using the proprietary Nvidia driver, make sure the
# corresponding xorg driver is installed
if [ -f /proc/driver/nvidia/version ]; then
    bash /ensure-nvidia-xorg-driver.sh
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