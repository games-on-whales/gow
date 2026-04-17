#!/bin/bash

set -e

GAMESCOPE_BIN=$(command -v gamescope || true)
if [ -n "$GAMESCOPE_BIN" ]; then
    chown "${UNAME}":"${UNAME}" "$GAMESCOPE_BIN"
fi