#!/usr/bin/env bash
# Smoke test for the pulseaudio sidecar image. This one runs as root (the
# pa daemon refuses to start unless $HOME is owned by the caller), and
# ships a tiny set of binaries: pa daemon + ALSA utils.

source /smoke-common/lib.sh

assert_has pulseaudio pactl pacmd aplay amixer

# Config files the container bakes in for its pa instance.
assert_path /etc/pulse/default.pa /etc/pulse/client.conf /etc/pulse/daemon.conf

assert_version pulseaudio --version
assert_shared_ok "$(command -v pulseaudio)"

smoke_report
