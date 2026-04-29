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

# User setup (10-setup_user.sh) should have created the retro user.
assert_path /home/retro
if id retro >/dev/null 2>&1; then
  ok "user 'retro' exists"
else
  bad "user 'retro' exists"
fi

# The entrypoint + bash-lib that every derived image sources.
assert_path /entrypoint.sh /opt/gow/startup.sh /opt/gow/bash-lib/utils.sh

smoke_report
