#!/bin/sh
set -eu

fail() {
  echo "$1" >&2
  exit 1
}

for module in nvidia nvidia_uvm nvidia_drm; do
  if [ ! -d "/sys/module/${module}" ]; then
    fail "Module '${module}' is not loaded! See the 'Nvidia (Manual)' section in the docs how to enable and load it."
  fi
done

read -r modeset < /sys/module/nvidia_drm/parameters/modeset
if [ "${modeset}" != 'Y' ]; then
  fail "Module 'nvidia_drm' has no modeset enabled! See the 'Nvidia (Manual)' section in the docs how to enable it."
fi

read -r host_version < /sys/module/nvidia/version
if [ ! -e "/usr/nvidia/lib/libnvidia-glcore.so.${host_version}" ]; then
  fail "The driver volume mounted at /usr/nvidia does not contain the host driver version ${host_version}! The volume has to be re-created after a driver update; see the 'Nvidia (Auto)' section in the Wolf docs."
fi

echo "Nvidia driver volume matches the host driver ${host_version}" >&2
