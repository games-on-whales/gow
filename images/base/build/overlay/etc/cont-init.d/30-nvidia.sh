#!/bin/bash

# TODO: check whether we need this before actually doing it

set -e

source /opt/gow/bash-lib/utils.sh

# Debian multiarch library dir, e.g. /usr/lib/x86_64-linux-gnu or
# /usr/lib/aarch64-linux-gnu (the base image is also built for arm64).
_nv_libdir="/usr/lib/$(uname -m)-linux-gnu"

# Check if our custom volume is mounted
if [ -d /usr/nvidia ]; then
  gow_log "Nvidia driver volume detected"
  ldconfig

  if [ -d /usr/nvidia/share/vulkan/icd.d ]; then
    gow_log "[nvidia] Add Vulkan ICD"
    mkdir -p /usr/share/vulkan/icd.d/
    cp /usr/nvidia/share/vulkan/icd.d/* /usr/share/vulkan/icd.d/
  fi

  if [ -d /usr/nvidia/share/egl/egl_external_platform.d ]; then
    gow_log "[nvidia] Add EGL external platform"
    mkdir -p /usr/share/egl/egl_external_platform.d/
    cp /usr/nvidia/share/egl/egl_external_platform.d/* /usr/share/egl/egl_external_platform.d/
  fi

  if [ -d /usr/nvidia/share/glvnd/egl_vendor.d ]; then
    gow_log "[nvidia] Add egl-vendor"
    mkdir -p /usr/share/glvnd/egl_vendor.d/
    cp /usr/nvidia/share/glvnd/egl_vendor.d/* /usr/share/glvnd/egl_vendor.d/

  fi

  if [ -d /usr/nvidia/lib/gbm ]; then
    gow_log "[nvidia] Add gbm backend"
    mkdir -p "${_nv_libdir}/gbm/"
    cp /usr/nvidia/lib/gbm/* "${_nv_libdir}/gbm/"
  fi
# Check if there's libnvidia-allocator.so.1
elif [ -e "${_nv_libdir}/libnvidia-allocator.so.1" ]; then
  gow_log "Nvidia driver detected, assuming nvidia container toolkit is installed"
  ldconfig

  # Create a symlink to the nvidia-drm_gbm.so (if not present)
  if [ ! -e "${_nv_libdir}/gbm/nvidia-drm_gbm.so" ]; then
    gow_log "Creating symlink to nvidia-drm_gbm.so"
    mkdir -p "${_nv_libdir}/gbm"
    ln -sv ../libnvidia-allocator.so.1 "${_nv_libdir}/gbm/nvidia-drm_gbm.so"
  fi

  # Create json config files
  if [ ! -f /usr/share/glvnd/egl_vendor.d/10_nvidia.json ]; then
    gow_log "Creating json 10_nvidia.json file"
    mkdir -p /usr/share/glvnd/egl_vendor.d/
    echo '{
      "file_format_version" : "1.0.0",
      "ICD": {
        "library_path": "libEGL_nvidia.so.0"
      }
    }' > /usr/share/glvnd/egl_vendor.d/10_nvidia.json
  fi

  if [ ! -f /usr/share/vulkan/icd.d/nvidia_icd.json ]; then
      gow_log "Creating json nvidia_icd.json file"
      mkdir -p /usr/share/vulkan/icd.d/
      echo '{
        "file_format_version" : "1.0.0",
        "ICD": {
          "library_path": "libGLX_nvidia.so.0",
          "api_version" : "1.3.242"
        }
      }' > /usr/share/vulkan/icd.d/nvidia_icd.json
  fi

  if [ ! -f /usr/share/egl/egl_external_platform.d/15_nvidia_gbm.json ]; then
    gow_log "Creating json 15_nvidia_gbm.json file"
    mkdir -p /usr/share/egl/egl_external_platform.d/
    echo '{
      "file_format_version" : "1.0.0",
      "ICD": {
        "library_path": "libnvidia-egl-gbm.so.1"
      }
    }' > /usr/share/egl/egl_external_platform.d/15_nvidia_gbm.json
  fi

  if [ ! -f /usr/share/egl/egl_external_platform.d/10_nvidia_wayland.json ]; then
    gow_log "Creating json 10_nvidia_wayland.json file"
    mkdir -p /usr/share/egl/egl_external_platform.d/
    echo '{
      "file_format_version" : "1.0.0",
      "ICD": {
        "library_path": "libnvidia-egl-wayland.so.1"
      }
    }' > /usr/share/egl/egl_external_platform.d/10_nvidia_wayland.json
  fi
fi
