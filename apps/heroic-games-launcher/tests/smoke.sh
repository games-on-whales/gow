#!/usr/bin/env bash
# heroic is fetched as a GitHub release .deb at build time -- catches the
# "github API 404 silently, container ships without the binary" case.
#
# Skip assert_shared_ok: heroic is an Electron app that ships its own
# libffmpeg.so inside /opt/Heroic/ and finds it via rpath/LD_LIBRARY_PATH
# at runtime. A bare `ldd /usr/bin/heroic` reports it as "not found",
# which is a false positive. The assert_version below still confirms
# the binary loads and starts its process (electron prints a sandbox
# error when invoked as root but still exits 0).

source /smoke-common/lib.sh

assert_has heroic
assert_version heroic --version

smoke_report
