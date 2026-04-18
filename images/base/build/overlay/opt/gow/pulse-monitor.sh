#!/usr/bin/env bash
# PulseAudio sink monitor for Wolf sessions
# Automatically moves audio streams from wrong sink to correct session-specific sink
#
# Problem: Some audio libraries (e.g., FMOD used by Dwarf Fortress) ignore the
# PULSE_SINK environment variable and connect to PulseAudio's server-side default
# sink instead of the session-specific sink. This causes no audio in Moonlight.
#
# Solution: Continuously monitor PulseAudio sink inputs and automatically move any
# streams that are on the wrong sink to the correct session-specific sink.
#
# This is a per-client workaround that doesn't change the server-side default sink,
# making it safe for multi-user environments where multiple sessions share one
# PulseAudio server.

set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Starting PulseAudio sink monitor"
gow_log "Target sink: ${PULSE_SINK}"

# Wait for PulseAudio to be ready
for i in {1..10}; do
  if pactl info >/dev/null 2>&1; then
    gow_log "PulseAudio is ready"
    break
  fi
  gow_log "Waiting for PulseAudio... ($i/10)"
  sleep 1
done

# Verify PulseAudio is accessible
if ! pactl info >/dev/null 2>&1; then
  gow_log "ERROR: PulseAudio not accessible after 10 attempts"
  exit 1
fi

# Get the correct sink ID for this session
CORRECT_SINK="${PULSE_SINK}"

if [ -z "${CORRECT_SINK}" ]; then
  gow_log "ERROR: PULSE_SINK environment variable not set"
  exit 1
fi

gow_log "Monitoring started, checking every 2 seconds"

# Monitor and move streams continuously
while true; do
  # Get all sink inputs and check if they're on the wrong sink
  pactl list sink-inputs short 2>/dev/null | while read -r input_id sink_id rest; do
    # Skip if no inputs
    [ -z "$input_id" ] && continue

    # Get the sink name for this input
    current_sink=$(pactl list sinks short 2>/dev/null | awk -v id="$sink_id" '$1 == id {print $2}')

    # If it's not our session-specific sink, move it
    if [ "$current_sink" != "$CORRECT_SINK" ] && [ -n "$current_sink" ]; then
      gow_log "Moving sink-input #${input_id} from ${current_sink} to ${CORRECT_SINK}"
      pactl move-sink-input "$input_id" "$CORRECT_SINK" 2>/dev/null || {
        gow_log "WARNING: Failed to move sink-input #${input_id}"
      }
    fi
  done

  # Check every 2 seconds
  sleep 2
done
