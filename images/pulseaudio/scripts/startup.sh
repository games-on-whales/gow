#!/bin/bash
set -e

function LOG {
    echo $(date -R): $0: $*
}

LOG "Starting pulseaudio"
pulseaudio # --log-level=4 --log-target=stderr -v
