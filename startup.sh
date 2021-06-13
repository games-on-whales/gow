#!/bin/bash

RESOLUTION=${RESOLUTION:-1024x768x24}
LOG_LEVEL=${LOG_LEVEL:-INFO}
echo "Starting sunshine with RESOLUTION=${RESOLUTION} and LOG_LEVEL=${LOG_LEVEL}"

_kill_procs() {
  kill -TERM $sunshine
  wait $sunshine
  kill -TERM $xvfb
}

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

# Start Xvfb
Xvfb :99 -ac -screen 0 $RESOLUTION -nolisten tcp &
xvfb=$!
export DISPLAY=:99

# Start Sunshine
/sunshine/sunshine min_log_level=$LOG_LEVEL /sunshine/sunshine.conf
sunshine=$!

wait $sunshine
wait $xvfb