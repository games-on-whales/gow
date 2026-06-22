#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh
gow_log "AudioRelay startup.sh"

id="${AUDIORELAY_ID:-default}"

sink="audiorelay-virtual-mic-sink-${id}"
src="audiorelay-virtual-mic${id}"

if ! pactl list short sinks 2>/dev/null | awk '{print $2}' | grep -qx "$sink"; then
  pactl load-module module-null-sink \
    sink_name="$sink" \
    sink_properties="device.description=AudioRelay-Virtual-Mic-Sink-${id}"
fi

if ! pactl list short sources 2>/dev/null | awk '{print $2}' | grep -qx "$src"; then
  pactl load-module module-remap-source \
    master="${sink}.monitor" \
    source_name="$src" \
    source_properties="device.description=AudioRelay-Virtual-Mic-${id}"
fi

source /opt/gow/launch-comp.sh
launcher /opt/audiorelay/bin/AudioRelay
