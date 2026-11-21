#!/bin/bash

# Counterpart of cont-init.d/30-nvidia.sh for containers started as a non-root
# user, where that one is skipped. Without root it can't run ldconfig or write into /usr, so it
# points the loaders at the driver with env vars instead. Each config dir is
# merged with the driver's files into a private dir (driver files winning),
# which is what the root script's cp does.

set -e

source /opt/gow/bash-lib/utils.sh

# Debian multiarch library dir (the base image is also built for arm64)
LIBDIR="/usr/lib/$(uname -m)-linux-gnu"
NV_DIR="${GOW_NVIDIA_DIR:-/tmp/gow-nvidia}"

# nv_merge <name> <dir>...: link the files of each dir into $NV_DIR/<name>,
# later dirs win
nv_merge() {
  local out="$NV_DIR/$1"
  shift
  mkdir -p "$out"
  for dir in "$@"; do
    for f in "$dir"/*; do
      if [ -e "$f" ]; then
        ln -sfn "$f" "$out/"
      fi
    done
  done
}

# Check if our custom volume is mounted
if [ -d /usr/nvidia ]; then
  gow_log "Nvidia driver volume detected"
  for lib in /usr/nvidia/lib32 /usr/nvidia/lib; do
    if [ -d "$lib" ]; then
      export LD_LIBRARY_PATH="$lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    fi
  done

  if [ -d /usr/nvidia/share/vulkan/icd.d ]; then
    gow_log "[nvidia] Add Vulkan ICD"
    nv_merge vulkan /etc/vulkan/icd.d /usr/share/vulkan/icd.d /usr/nvidia/share/vulkan/icd.d
    VK_DRIVER_FILES=$(join_by : "$NV_DIR"/vulkan/*.json)
    export VK_DRIVER_FILES
  fi

  if [ -d /usr/nvidia/share/egl/egl_external_platform.d ]; then
    gow_log "[nvidia] Add EGL external platform"
    nv_merge egl_external_platform /etc/egl/egl_external_platform.d /usr/share/egl/egl_external_platform.d \
      /usr/nvidia/share/egl/egl_external_platform.d
    export __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS="$NV_DIR/egl_external_platform"
  fi

  if [ -d /usr/nvidia/share/glvnd/egl_vendor.d ]; then
    gow_log "[nvidia] Add egl-vendor"
    nv_merge egl_vendor /etc/glvnd/egl_vendor.d /usr/share/glvnd/egl_vendor.d /usr/nvidia/share/glvnd/egl_vendor.d
    export __EGL_VENDOR_LIBRARY_DIRS="$NV_DIR/egl_vendor"
  fi

  if [ -d /usr/nvidia/lib/gbm ]; then
    gow_log "[nvidia] Add gbm backend"
    nv_merge gbm "$LIBDIR/gbm" /usr/nvidia/lib/gbm
    export GBM_BACKENDS_PATH="$NV_DIR/gbm"
  fi
# Check if there's libnvidia-allocator.so.1
elif [ -e "$LIBDIR/libnvidia-allocator.so.1" ]; then
  gow_log "Nvidia driver detected, assuming nvidia container toolkit is installed"

  # Add a nvidia-drm_gbm.so link (if not present)
  if [ ! -e "$LIBDIR/gbm/nvidia-drm_gbm.so" ]; then
    gow_log "Adding gbm backend nvidia-drm_gbm.so"
    nv_merge gbm "$LIBDIR/gbm"
    ln -sfn "$LIBDIR/libnvidia-allocator.so.1" "$NV_DIR/gbm/nvidia-drm_gbm.so"
    export GBM_BACKENDS_PATH="$NV_DIR/gbm"
  fi

  # Create json config files (if not present)
  if [ ! -f /usr/share/glvnd/egl_vendor.d/10_nvidia.json ]; then
    gow_log "Creating json 10_nvidia.json file"
    nv_merge egl_vendor /etc/glvnd/egl_vendor.d /usr/share/glvnd/egl_vendor.d
    echo '{
      "file_format_version" : "1.0.0",
      "ICD": {
        "library_path": "libEGL_nvidia.so.0"
      }
    }' > "$NV_DIR/egl_vendor/10_nvidia.json"
    export __EGL_VENDOR_LIBRARY_DIRS="$NV_DIR/egl_vendor"
  fi

  if [ ! -f /usr/share/vulkan/icd.d/nvidia_icd.json ]; then
    gow_log "Creating json nvidia_icd.json file"
    nv_merge vulkan /etc/vulkan/icd.d /usr/share/vulkan/icd.d
    echo '{
      "file_format_version" : "1.0.0",
      "ICD": {
        "library_path": "libGLX_nvidia.so.0",
        "api_version" : "1.3.242"
      }
    }' > "$NV_DIR/vulkan/nvidia_icd.json"
    VK_DRIVER_FILES=$(join_by : "$NV_DIR"/vulkan/*.json)
    export VK_DRIVER_FILES
  fi

  if [ ! -f /usr/share/egl/egl_external_platform.d/15_nvidia_gbm.json ]; then
    gow_log "Creating json 15_nvidia_gbm.json file"
    nv_merge egl_external_platform /etc/egl/egl_external_platform.d /usr/share/egl/egl_external_platform.d
    echo '{
      "file_format_version" : "1.0.0",
      "ICD": {
        "library_path": "libnvidia-egl-gbm.so.1"
      }
    }' > "$NV_DIR/egl_external_platform/15_nvidia_gbm.json"
    export __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS="$NV_DIR/egl_external_platform"
  fi

  if [ ! -f /usr/share/egl/egl_external_platform.d/10_nvidia_wayland.json ]; then
    gow_log "Creating json 10_nvidia_wayland.json file"
    nv_merge egl_external_platform /etc/egl/egl_external_platform.d /usr/share/egl/egl_external_platform.d
    echo '{
      "file_format_version" : "1.0.0",
      "ICD": {
        "library_path": "libnvidia-egl-wayland.so.1"
      }
    }' > "$NV_DIR/egl_external_platform/10_nvidia_wayland.json"
    export __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS="$NV_DIR/egl_external_platform"
  fi

  # See cont-init.d/30-nvidia.sh: prefer the toolkit's newer libnvrtc over the
  # baked-in CUDA 11.0 one, through LD_LIBRARY_PATH instead of a symlink in /usr
  _host_nvrtc=$(ldconfig -p 2>/dev/null \
    | awk '/libnvrtc\.so[^.0-9]/{print $NF}' \
    | grep -v '/usr/local/nvidia/lib' \
    | head -1 || true)
  if [ -n "$_host_nvrtc" ]; then
    gow_log "Preferring host nvrtc over baked-in: $_host_nvrtc"
    mkdir -p "$NV_DIR/lib"
    ln -sfn "$_host_nvrtc" "$NV_DIR/lib/libnvrtc.so"
    export LD_LIBRARY_PATH="$NV_DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  fi
fi
