#!/bin/bash

# TODO: check whether we need this before actually doing it

set -e

source /opt/gow/bash-lib/utils.sh

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
    mkdir -p /usr/lib/x86_64-linux-gnu/gbm/
    cp /usr/nvidia/lib/gbm/* /usr/lib/x86_64-linux-gnu/gbm/
  fi
else
  # The container toolkit injects the driver libraries at host-specific paths
  # (e.g. /usr/lib on Arch, /usr/lib/x86_64-linux-gnu on Ubuntu, /usr/lib64 on
  # Fedora), so we can't rely on a fixed path here: resolve it via the linker
  # cache, falling back to the usual locations.
  _nvidia_allocator=$(ldconfig -p 2>/dev/null \
    | awk '/libnvidia-allocator\.so\.1$/{print $NF; exit}')
  if [ -z "${_nvidia_allocator}" ]; then
    for _p in /usr/lib64 /usr/lib/x86_64-linux-gnu /usr/lib; do
      if [ -e "${_p}/libnvidia-allocator.so.1" ]; then
        _nvidia_allocator="${_p}/libnvidia-allocator.so.1"
        break
      fi
    done
  fi

  if [ -n "${_nvidia_allocator}" ]; then
    gow_log "Nvidia driver detected (${_nvidia_allocator}), assuming nvidia container toolkit is installed"
    ldconfig

    # Create a symlink to the nvidia-drm_gbm.so (if not present)
    if [ ! -e /usr/lib/x86_64-linux-gnu/gbm/nvidia-drm_gbm.so ]; then
      gow_log "Creating symlink to nvidia-drm_gbm.so"
      mkdir -p /usr/lib/x86_64-linux-gnu/gbm
      ln -sv "${_nvidia_allocator}" /usr/lib/x86_64-linux-gnu/gbm/nvidia-drm_gbm.so
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

    # gst-cuda loads "libnvrtc.so" via ldconfig. The image ships libnvrtc.so.11.0
    # (CUDA 11.0) as a fallback, but nvrtcGetCUBIN* were added in CUDA 11.1.
    # If the toolkit has injected a newer libnvrtc from the host at a standard
    # system path, symlink it over the baked-in version so ldconfig finds it first.
    _host_nvrtc=$(ldconfig -p 2>/dev/null \
      | awk '/libnvrtc\.so[^.0-9]/{print $NF}' \
      | grep -v '/usr/local/nvidia/lib' \
      | head -1)
    if [ -n "$_host_nvrtc" ]; then
      gow_log "Preferring host nvrtc over baked-in: $_host_nvrtc"
      ln -sf "$_host_nvrtc" /usr/local/nvidia/lib/libnvrtc.so
      ldconfig
    fi
  fi
fi
