#!/bin/bash
set -e

source /opt/gow/launch-comp.sh
launcher /usr/bin/heroic ${HEROIC_STARTUP_FLAGS} --no-sandbox
