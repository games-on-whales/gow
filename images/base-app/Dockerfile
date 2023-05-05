ARG BASE_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# TODO: should we include any drivers or anything here? The GL stuff that the
# sunshine container has, or the intel drivers, etc?  AMD drivers?
#
# x11-utils: contains xdpyinfo, which we use to know whether Xorg has started yet
# pulseaudio-utils: some apps can't play sound unless this package is installed
ARG REQUIRED_PACKAGES="\
    x11-utils \
    pulseaudio-utils \
    libcap2-bin \
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Add Gamescope
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ar-lex/gamescope && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends gamescope && \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=777 scripts/init-gamescope.sh /etc/cont-init.d/20-gamescope.sh
COPY --chmod=777 scripts/wait-x11 /opt/gow/wait-x11
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

# In order to use Vulkan with NVIDIA GPUs, the ICD file must be present (so
# Vulkan knows how to find the driver libraries).  Although the nvidia runtime
# _does_ handle making the actual drivers available, it doesn't install the ICD
# JSON.  So we provide one ourselves.  This is harmless on non-NVIDIA systems,
# so we just do it unconditionally.
# NOTE: as of nvidia-container-toolkit v1.12, this is no longer necessary. once
# that version is sufficiently widely available, we may want to make it a
# requirement and stop doing this manually
#COPY configs/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
#COPY configs/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# Configure the default directory to be the 'retro' users home directory
WORKDIR ${HOME}
