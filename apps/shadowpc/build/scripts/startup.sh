#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "ShadowPC startup.sh"

# Launch ShadowPC through the compositor
source /opt/gow/launch-comp.sh
launcher /usr/bin/shadow-prod
