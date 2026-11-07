#!/usr/bin/env bash
# Firefox is pinned to the Mozilla PPA (the snap'd version that ships in
# ubuntu archives refuses to run in a container). If the PPA pinning ever
# regresses, `firefox --version` prints a snap shim message instead of the
# real version -- catch that here.

source /smoke-common/lib.sh

assert_has firefox
assert_shared_ok /usr/bin/firefox

# The real binary reports "Mozilla Firefox <N>.<N>". The snap shim reports
# a different banner -- fail if we see the wrong one.
out=$(timeout 10 firefox --version 2>&1 || true)
if printf '%s' "$out" | grep -Eq '^Mozilla Firefox [0-9]+'; then
  ok "firefox --version reports Mozilla Firefox ($out)"
else
  bad "firefox --version reports Mozilla Firefox (got: $out)"
fi

# Enterprise policy baked into the image -- missing it means Firefox will
# show first-run/post-update pages and leak network traffic to Mozilla.
assert_path /etc/firefox/policies/policies.json

smoke_report
