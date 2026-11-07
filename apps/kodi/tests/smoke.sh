#!/usr/bin/env bash
source /smoke-common/lib.sh

assert_has kodi dbus-daemon python3
assert_shared_ok /usr/lib/x86_64-linux-gnu/kodi/kodi.bin
assert_version kodi --version
assert_version python3 --version

smoke_report
