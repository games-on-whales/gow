#!/usr/bin/env bash
# Smoke test for the `base` image -- the common ancestor of every GOW image.
# Everything we assert here gets inherited by every downstream image, so keep
# it lean: just the invariants the whole stack relies on.

source /smoke-common/lib.sh

# Core tools every downstream Dockerfile + cont-init script uses.
assert_has gosu curl wget jq fusermount

# gosu has to actually work -- the base Dockerfile already runs
# `gosu nobody true` at build time; repeat it here to catch runtime-only
# breakage (e.g. capability stripping by a future base-image rebase).
assert_version gosu nobody true

# The retro user is baked in at build time (1000:1000) and owns its home, so
# the container can also start directly as it (`--user retro`).
assert_path /home/retro
if [[ "$(id -u retro 2>/dev/null):$(id -g retro 2>/dev/null)" == 1000:1000 ]]; then
  ok "user 'retro' exists as 1000:1000"
else
  bad "user 'retro' exists as 1000:1000 (got $(id retro 2>&1))"
fi
if [[ "$(stat -c %U /home/retro)" == retro ]]; then
  ok "/home/retro owned by retro"
else
  bad "/home/retro owned by retro"
fi

# The entrypoint + bash-lib that every derived image sources, and the init
# scripts for containers started as the user.
assert_path /entrypoint.sh /opt/gow/startup.sh /opt/gow/bash-lib/utils.sh
assert_path /opt/gow/init.d/10-check_user.sh /opt/gow/init.d/15-check_devices.sh /opt/gow/init.d/30-nvidia.sh

smoke_report
