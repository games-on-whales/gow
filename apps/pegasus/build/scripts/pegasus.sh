#!/bin/bash

set -e

echo "Starting pegasus-fe"

# Seems to have issues with Wayland, let's fallback to X11
export XDG_SESSION_TYPE=x11
unset WAYLAND_DISPLAY
pegasus-fe