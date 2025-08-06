#!/bin/bash
# ALVR Server launcher script

source /opt/gow/bash-lib/utils.sh

gow_log "Starting ALVR Server..."

# Set up environment
export DISPLAY=${DISPLAY:-:0}
export ALVR_SERVER_HOST=${ALVR_SERVER_HOST:-0.0.0.0}
export ALVR_WEB_PORT=${ALVR_WEB_PORT:-8082}

# Navigate to ALVR directory
cd /opt/alvr

# Start ALVR with web interface accessible from outside container
gow_log "ALVR Server starting on $ALVR_SERVER_HOST:$ALVR_WEB_PORT"
gow_log "Connect your Quest 3 to the same network and visit http://YOUR_SERVER_IP:8082"

# Run ALVR launcher
exec ./alvr_launcher
