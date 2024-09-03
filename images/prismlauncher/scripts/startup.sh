#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

PrismLauncher=prismlauncher

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "[start] Starting PrismLauncher"

source /opt/gow/launch-comp.sh
launcher "${PrismLauncher}"
