#!/usr/bin/env bash
# The base image ships files under $HOME owned by uid 1000. When Wolf runs the
# container with another run_uid/run_gid, 10-setup_user.sh only re-owns $HOME
# itself, so the startup scripts fail to overwrite e.g. ~/.config/sway/config.
gow_log "Ensure files in the retro home directory are owned by ${PUID:-1000}:${PGID:-1000}"
# The default Battle.net prefix (~/.bnet) is created by the app user and is large: skip it.
find "${HOME}" -path "${HOME}/.bnet" -prune -o -exec chown -h "${PUID:-1000}:${PGID:-1000}" {} +
