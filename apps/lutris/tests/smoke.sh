#!/usr/bin/env bash
source /smoke-common/lib.sh

assert_has lutris bwrap
assert_version lutris --version

# Custom bwrap (same story as steam -- built from source with the
# ignore_capabilities patch).
assert_shared_ok /usr/bin/bwrap

# Lutris config files the image bakes in.
assert_path /opt/gow/lutris-system.yml /opt/gow/lutris-lutris.conf
assert_path /var/lutris

smoke_report
