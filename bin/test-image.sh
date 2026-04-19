#!/usr/bin/env bash
# Smoke-test a built GOW image.
#
# Usage: bin/test-image.sh <image-name> <image-tag> [--docker-path images|apps]
#
# Runs three layers of validation against the already-built image:
#
#   1. Structural  -- docker inspect, entrypoint present, image.source label set.
#   2. Init smoke  -- `docker run --rm <tag> <sentinel>` exercises every
#                     /etc/cont-init.d/*.sh script as root, then exits.
#                     Catches regressions in user/device/nvidia setup.
#   3. Image smoke -- runs <image-path>/tests/smoke.sh inside the container
#                     (bind-mounted at /tests), with a 120s timeout. This is
#                     where per-image assertions live (binary versions,
#                     shared-lib resolution, etc.). Skipped with a warning
#                     if the image has no tests/smoke.sh.
#
# The harness sets XDG_RUNTIME_DIR and HOME to match what Wolf passes at
# runtime -- without these the base entrypoint chown's a non-existent path
# and exits, which is documented upstream behaviour rather than a bug.

set -euo pipefail

usage() {
  cat >&2 <<EOF
Usage: $0 <image-name> <image-tag> [--docker-path images|apps] [--keep-logs]

Examples:
  $0 base    ghcr.io/games-on-whales/base:edge
  $0 firefox localhost:5000/firefox:pr-42 --docker-path apps
EOF
  exit 64
}

[[ $# -ge 2 ]] || usage
IMAGE_NAME="$1"
IMAGE_TAG="$2"
shift 2

DOCKER_PATH=""
KEEP_LOGS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --docker-path) DOCKER_PATH="$2"; shift 2;;
    --keep-logs)   KEEP_LOGS=1;      shift;;
    -h|--help)     usage;;
    *) echo "!! unknown argument: $1" >&2; usage;;
  esac
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---- locate the image source directory ------------------------------------
if [[ -z "$DOCKER_PATH" ]]; then
  if   [[ -d "$REPO_ROOT/images/$IMAGE_NAME" ]]; then DOCKER_PATH=images
  elif [[ -d "$REPO_ROOT/apps/$IMAGE_NAME"   ]]; then DOCKER_PATH=apps
  else
    echo "!! could not locate '$IMAGE_NAME' under images/ or apps/; pass --docker-path" >&2
    exit 2
  fi
fi
IMG_DIR="$REPO_ROOT/$DOCKER_PATH/$IMAGE_NAME"
[[ -d "$IMG_DIR" ]] || { echo "!! $IMG_DIR does not exist" >&2; exit 2; }

# ---- output helpers -------------------------------------------------------
TOTAL=0; FAIL=0
step() { printf '\n==> %s\n' "$*"; }
pass() { TOTAL=$((TOTAL+1)); printf '   ok   %s\n' "$*"; }
fail() { TOTAL=$((TOTAL+1)); FAIL=$((FAIL+1)); printf '   FAIL %s\n' "$*" >&2; }
dump() { sed 's/^/   | /' "$1" >&2; }

# Runtime env mirroring what Wolf sets for these containers. Keeps the
# harness from tripping on assumptions the app code legitimately makes.
COMMON_ENV=(
  -e "XDG_RUNTIME_DIR=/tmp"
  -e "HOME=/home/retro"
)

INIT_LOG=$(mktemp)
SMOKE_LOG=$(mktemp)
cleanup() {
  if [[ -n "$KEEP_LOGS" ]]; then
    echo "   (logs kept: $INIT_LOG $SMOKE_LOG)" >&2
  else
    rm -f "$INIT_LOG" "$SMOKE_LOG"
  fi
}
trap cleanup EXIT

# ---- layer 1: structural --------------------------------------------------
step "Layer 1 -- structural checks ($IMAGE_NAME)"

if ! docker image inspect "$IMAGE_TAG" >/dev/null 2>&1; then
  fail "image present ($IMAGE_TAG)"
  exit 1
fi
pass "image present ($IMAGE_TAG)"

EP=$(docker image inspect --format '{{json .Config.Entrypoint}}' "$IMAGE_TAG")
if [[ "$EP" == *"/entrypoint.sh"* ]]; then
  pass "entrypoint is /entrypoint.sh ($EP)"
else
  fail "entrypoint is /entrypoint.sh (got $EP)"
fi

SRC_LABEL=$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.source"}}' "$IMAGE_TAG" 2>/dev/null || true)
if [[ -n "$SRC_LABEL" ]]; then
  pass "has org.opencontainers.image.source label ($SRC_LABEL)"
else
  fail "has org.opencontainers.image.source label"
fi

# ---- layer 2: init smoke --------------------------------------------------
# Pass a sentinel echo as CMD. The base entrypoint detects any positional
# args and runs them via `bash -c "$@"`, so all /etc/cont-init.d/*.sh scripts
# execute as root, then the sentinel prints, then the container exits 0.
step "Layer 2 -- init smoke (/etc/cont-init.d scripts run clean)"

SENTINEL="__gow_init_ok_$$__"
if timeout 60 docker run --rm \
      --name "test-${IMAGE_NAME}-init-$$" \
      "${COMMON_ENV[@]}" \
      "$IMAGE_TAG" \
      "echo $SENTINEL" \
      >"$INIT_LOG" 2>&1; then
  if grep -q "$SENTINEL" "$INIT_LOG"; then
    pass "cont-init.d scripts exit clean"
  else
    fail "cont-init.d scripts exit clean (sentinel missing; see log)"
    dump "$INIT_LOG"
  fi
else
  fail "cont-init.d scripts exit clean (run failed, see log)"
  dump "$INIT_LOG"
fi

# Even with a zero exit, catch latent dynamic-linker / missing-binary chatter.
FATAL_PATTERNS='error while loading shared libraries|cannot open shared object|segmentation fault|command not found'
if grep -Eiq "$FATAL_PATTERNS" "$INIT_LOG"; then
  fail "cont-init.d output is free of fatal-looking errors"
  grep -Eni "$FATAL_PATTERNS" "$INIT_LOG" | sed 's/^/   | /' >&2
else
  pass "cont-init.d output is free of fatal-looking errors"
fi

# ---- layer 3: per-image smoke --------------------------------------------
SMOKE="$IMG_DIR/tests/smoke.sh"
if [[ -f "$SMOKE" ]]; then
  step "Layer 3 -- image smoke ($DOCKER_PATH/$IMAGE_NAME/tests/smoke.sh)"

  # smoke.sh and the shared lib.sh are bind-mounted read-only; image stays
  # untouched. The entrypoint still runs cont-init.d before handing control
  # to the script, so smoke assertions see the same runtime state as a
  # production container.
  if timeout 180 docker run --rm \
        --name "test-${IMAGE_NAME}-smoke-$$" \
        "${COMMON_ENV[@]}" \
        -v "$REPO_ROOT/bin/tests:/smoke-common:ro" \
        -v "$IMG_DIR/tests:/smoke:ro" \
        "$IMAGE_TAG" \
        '/smoke/smoke.sh' \
        >"$SMOKE_LOG" 2>&1; then
    pass "image smoke exits clean"
    dump "$SMOKE_LOG"
  else
    rc=$?
    fail "image smoke exits clean (exit $rc)"
    dump "$SMOKE_LOG"
  fi
else
  step "Layer 3 -- SKIPPED (no $DOCKER_PATH/$IMAGE_NAME/tests/smoke.sh)"
  printf '   |  add one to exercise image-specific binaries + shared libs\n'
fi

# ---- result --------------------------------------------------------------
echo
if [[ "$FAIL" -eq 0 ]]; then
  printf '== PASS == %d/%d checks passed for %s (%s)\n' "$TOTAL" "$TOTAL" "$IMAGE_NAME" "$IMAGE_TAG"
  exit 0
else
  printf '== FAIL == %d/%d checks failed for %s (%s)\n' "$FAIL" "$TOTAL" "$IMAGE_NAME" "$IMAGE_TAG" >&2
  exit 1
fi
