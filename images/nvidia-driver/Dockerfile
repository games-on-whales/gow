# All stages share a single base image, so no additional images are pulled.
FROM ubuntu:22.04 AS base-image


# Provides the version of the host's Nvidia kernel module. Replace this stage with
# `--build-context=nvidia-module=/sys/module/nvidia/` to read the version from the
# running host; otherwise, pass it explicitly with `--build-arg=NV_VERSION=<version>`.
FROM base-image AS nvidia-module

ARG NV_VERSION
RUN echo "${NV_VERSION}" > /version


FROM base-image AS nvidia-installer

COPY --from=nvidia-module /version /nvidia-version
RUN NV_VERSION="$(cat /nvidia-version)" && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends curl ca-certificates kmod pkg-config libglvnd-dev vulkan-tools && \
    curl -LO https://download.nvidia.com/XFree86/Linux-x86_64/$NV_VERSION/NVIDIA-Linux-x86_64-$NV_VERSION.run && \
    chmod +x NVIDIA-Linux-x86_64-$NV_VERSION.run && mkdir -p /usr/nvidia && \
    ./NVIDIA-Linux-x86_64-$NV_VERSION.run --silent -z --skip-depmod --skip-module-unload --no-nvidia-modprobe --no-kernel-modules --no-kernel-module-source --opengl-prefix=/usr/nvidia --wine-prefix=/usr/nvidia --utility-prefix=/usr/nvidia --utility-libdir=lib --compat32-prefix=/usr/nvidia --compat32-libdir=lib32 --egl-external-platform-config-path=/usr/nvidia/share/egl/egl_external_platform.d --glvnd-egl-config-path=/usr/nvidia/share/glvnd/egl_vendor.d --no-distro-scripts && \
    rm ./NVIDIA-Linux-x86_64-$NV_VERSION.run

# shellcheck disable=SC3037
RUN echo -e "/usr/nvidia/lib\n/usr/nvidia/lib32" > /etc/ld.so.conf.d/nvidia.conf && ldconfig


################
FROM base-image

COPY --from=nvidia-installer /usr/nvidia/ /usr/nvidia
COPY --from=nvidia-installer /etc/vulkan/icd.d/nvidia_icd.json /usr/nvidia/share/vulkan/icd.d/
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
