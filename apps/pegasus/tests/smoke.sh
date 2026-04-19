#!/usr/bin/env bash
# Pegasus front-end. Installs libssl1.1 from the pool + a github 'continuous'
# build -- both external URLs that can disappear. This catches the image
# shipping without the binary when an upstream URL breaks.

source /smoke-common/lib.sh

assert_has pegasus-fe
assert_shared_ok "$(command -v pegasus-fe)"
assert_path /bin/pegasus.sh /media/iso_mount

# The Dockerfile pulls libssl1.1 because pegasus was built against it.
if ldconfig -p | grep -q 'libssl.so.1.1'; then
  ok "libssl1.1 is on the loader path"
else
  bad "libssl1.1 is on the loader path"
fi

smoke_report
