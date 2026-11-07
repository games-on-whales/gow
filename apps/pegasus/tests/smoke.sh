#!/usr/bin/env bash
# Pegasus front-end. Installs libssl1.1 from the pool + a github 'continuous'
# build -- both external URLs that can disappear. This catches the image
# shipping without the binary when an upstream URL breaks.

source /smoke-common/lib.sh

assert_has pegasus-fe
# ldd clean catches the real "pegasus was built against libssl1.1 and we
# forgot to pull the .deb" regression that the image was guarding against.
# A separate ldconfig check for libssl.so.1.1 was unreliable (the version
# suffix changes between ubuntu .debs), so lean on the authoritative
# ldd-against-the-actual-binary signal instead.
assert_shared_ok "$(command -v pegasus-fe)"
assert_path /bin/pegasus.sh /media/iso_mount

smoke_report
