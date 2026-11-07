#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

# The portable Qt6 build treats its install dir (/opt/prismlauncher) as the
# data folder, which isn't writable by the runtime user and wouldn't persist
# across container restarts. Point it at $HOME/.local/share/PrismLauncher so
# instances/logs live with the rest of the user's persistent state.
PRISM_DATA_DIR="${HOME}/.local/share/PrismLauncher"
mkdir -p "${PRISM_DATA_DIR}"

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "[start] Starting PrismLauncher"

source /opt/gow/launch-comp.sh
launcher prismlauncher -d "${PRISM_DATA_DIR}"
