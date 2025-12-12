#!/usr/bin/env bash

set -e

gow_log "**** Setup PulseAudio sink monitoring ****"

# Only set up monitoring if PULSE_SINK is defined
if [ -z "${PULSE_SINK}" ]; then
    gow_log "PULSE_SINK not set, skipping PulseAudio monitoring"
    gow_log "DONE"
    exit 0
fi

gow_log "Target sink: ${PULSE_SINK}"

# Start the monitoring script in the background
nohup /opt/gow/pulse-monitor.sh > /var/log/pulse-monitor.log 2>&1 &

gow_log "PulseAudio sink monitor started (PID: $!)"
gow_log "DONE"
