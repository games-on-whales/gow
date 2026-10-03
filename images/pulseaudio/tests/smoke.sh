#!/usr/bin/env bash
# Smoke test for the pulseaudio sidecar image. It ships only the pa daemon
# and ALSA utils. The daemon runs as the 'pulse' system user.

source /smoke-common/lib.sh

assert_has pulseaudio pactl pacmd aplay amixer

# Config files the container bakes in for its pa instance.
assert_path /etc/pulse/default.pa /etc/pulse/client.conf /etc/pulse/daemon.conf

assert_version pulseaudio --version
assert_shared_ok "$(command -v pulseaudio)"

# pulseaudio won't start unless 'pulse' owns $HOME.
if id pulse >/dev/null 2>&1 && [ "$(stat -c %U /var/lib/pulse)" = pulse ]; then
  ok "system user 'pulse' exists and owns /var/lib/pulse"
else
  bad "system user 'pulse' exists and owns /var/lib/pulse"
fi

smoke_report
