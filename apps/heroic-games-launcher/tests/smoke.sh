#!/usr/bin/env bash
# heroic is fetched as a GitHub release .deb at build time -- catches the
# "github API 404 silently, container ships without the binary" case.

source /smoke-common/lib.sh

assert_has heroic
assert_shared_ok "$(command -v heroic)"
assert_version heroic --version

smoke_report
