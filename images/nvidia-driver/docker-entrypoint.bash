#!/bin/bash
set -e

readonly NV_SOURCE_DIR="${NV_SOURCE_DIR:-/usr/nvidia/}"
readonly NV_TARGET_DIR="${NV_TARGET_DIR:-/usr/nvidia.init/}"

echo 'Checking environment requirements...' >&2
for module in nvidia nvidia_uvm; do
  if ! grep -q "$module " /proc/modules; then
    echo "Module '$module' is not loaded! See the 'Nvidia (Manual)' section in the docs how to enable and load it."
    exit 1
  fi
done
if [[ $(</sys/module/nvidia_drm/parameters/modeset) != 'Y' ]]; then
  echo "Module 'nvidia_drm' has no modeset enabled! See the 'Nvidia (Manual)' section in the docs how to enable it."
  exit 1
fi

echo "Cleaning '${NV_TARGET_DIR}' for fresh drivers install..." >&2
rm -rf "${NV_TARGET_DIR}/"*
echo "Copying new version of drivers from '${NV_SOURCE_DIR}' to '${NV_TARGET_DIR}'..." >&2
cp -a "${NV_SOURCE_DIR}/." "${NV_TARGET_DIR}"

exec "$@"
