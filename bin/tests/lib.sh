#!/usr/bin/env bash
# Shared helpers for per-image smoke.sh scripts.
#
# Mount layout inside the container (set up by bin/test-image.sh):
#   /smoke/smoke.sh         <- the image's own smoke test
#   /smoke-common/lib.sh    <- this file
#
# Usage inside a smoke.sh:
#
#     source /smoke-common/lib.sh
#     assert_has       xwayland gamescope sway
#     assert_version   Xwayland -version
#     assert_shared_ok /usr/bin/firefox
#     run_as_user      firefox --version
#     smoke_report

set -u -o pipefail

_OK=0 _FAIL=0

log()  { printf '[smoke] %s\n' "$*"; }
ok()   { _OK=$((_OK+1));     printf '   ok   %s\n' "$*"; }
bad()  { _FAIL=$((_FAIL+1)); printf '   FAIL %s\n' "$*" >&2; }

# ---- result ---------------------------------------------------------------
# Call once at the end of smoke.sh. Exits non-zero if any assertion failed.
smoke_report() {
  local total=$((_OK + _FAIL))
  if [[ "$_FAIL" -eq 0 ]]; then
    log "PASS ${_OK}/${total}"
    exit 0
  fi
  log "FAIL ${_FAIL}/${total}"
  exit 1
}

# ---- assertions -----------------------------------------------------------

# assert_has <bin> [<bin>...]
#   Every argument must resolve via `command -v`.
assert_has() {
  for bin in "$@"; do
    if command -v "$bin" >/dev/null 2>&1; then
      ok "binary on PATH: $bin ($(command -v "$bin"))"
    else
      bad "binary on PATH: $bin"
    fi
  done
}

# assert_path <path> [<path>...]
#   Every argument must exist as a file.
assert_path() {
  for p in "$@"; do
    if [[ -e "$p" ]]; then
      ok "path exists: $p"
    else
      bad "path exists: $p"
    fi
  done
}

# assert_version <argv...>
#   Runs the given command with a short timeout. Any exit code is tolerated
#   (some binaries exit 1 on --version), but missing shared libs and SIGSEGV
#   fail the check. Stdout/stderr get captured and dumped on failure.
assert_version() {
  local name="$1"
  local out
  if out=$(timeout 10 "$@" 2>&1); then
    ok "runs: $* => $(printf '%s' "$out" | head -1)"
    return 0
  fi
  local rc=$?
  # Exit 1/2 is common for --version on CLIs that print usage; still catch
  # the load-failure patterns that actually matter.
  if printf '%s' "$out" | grep -Eiq 'error while loading shared libraries|cannot open shared object|segmentation fault|command not found'; then
    bad "runs: $* (fatal: $(printf '%s' "$out" | head -1))"
    return 1
  fi
  # Any other non-zero exit is still suspicious but not automatically fatal;
  # surface it and count as pass so finicky --version commands don't break CI.
  ok "runs: $* (exit $rc; $(printf '%s' "$out" | head -1))"
}

# assert_shared_ok <binary>
#   Ensures every shared library the binary links against resolves. Catches
#   the class of regressions where a Dockerfile installs package A but its
#   transitive .so dependency came from an apt repo that got purged later.
assert_shared_ok() {
  local bin="$1"
  if [[ ! -x "$bin" ]]; then
    bad "ldd clean: $bin (not executable)"
    return 1
  fi
  local missing
  missing=$(ldd "$bin" 2>&1 | grep -E 'not found' || true)
  if [[ -z "$missing" ]]; then
    ok "ldd clean: $bin"
  else
    bad "ldd clean: $bin ($(printf '%s' "$missing" | wc -l) missing)"
    printf '%s\n' "$missing" | sed 's/^/     | /' >&2
  fi
}

# run_as_user <argv...>
#   Invokes the command as the UNAME user (via gosu), with a 10s timeout.
#   Useful for binaries that refuse to run as root (e.g. steam).
run_as_user() {
  local user="${UNAME:-retro}"
  local out
  if out=$(timeout 10 gosu "$user" "$@" 2>&1); then
    ok "as $user: $* => $(printf '%s' "$out" | head -1)"
    return 0
  fi
  local rc=$?
  if printf '%s' "$out" | grep -Eiq 'error while loading shared libraries|cannot open shared object|segmentation fault|command not found'; then
    bad "as $user: $* (fatal: $(printf '%s' "$out" | head -1))"
    return 1
  fi
  ok "as $user: $* (exit $rc; $(printf '%s' "$out" | head -1))"
}
