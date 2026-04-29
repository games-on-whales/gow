#!/usr/bin/env bash
source /smoke-common/lib.sh

assert_has retroarch
assert_shared_ok "$(command -v retroarch)"
assert_version retroarch --version

# The default config shipped with the image.
assert_path /cfg/retroarch.cfg

smoke_report
