#!/bin/bash
set -e

source /opt/gow/launch-comp.sh
# HEROIC_STARTUP_FLAGS holds several flags, so let it split
# shellcheck disable=SC2086
launcher /usr/bin/heroic ${HEROIC_STARTUP_FLAGS} --no-sandbox
