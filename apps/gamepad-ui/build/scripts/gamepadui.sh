#!/bin/bash

set -e

echo "Starting Gamepad UI"

# Enable standalone UI behavior by default in container deployments.
export STANDALONE_SESSION=${STANDALONE_SESSION:-1}

# Seems to have issues with Wayland, let's fallback to X11
export XDG_SESSION_TYPE=x11
unset WAYLAND_DISPLAY
/opt/gow/app/AppRun