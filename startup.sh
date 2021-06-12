#!/bin/bash

RESOLUTION=${RESOLUTION:-1024x768x24}
LOG_LEVEL=${LOG_LEVEL:-INFO}

echo "Starting sunshine with RESOLUTION=${RESOLUTION} and LOG_LEVEL=${LOG_LEVEL}"

xvfb-run --server-args="-screen 0 ${RESOLUTION}" /sunshine/sunshine min_log_level=$LOG_LEVEL /sunshine/sunshine.conf