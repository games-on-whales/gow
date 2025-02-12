ARG BASE_APP_IMAGE

######################################
# Build Stage: bubblewrap builder
# This stage builds a custom version of bubblewrap that can work without privileged mode
######################################
FROM ubuntu:24.10 AS bwrap-builder

ENV DEBIAN_FRONTEND=non-interactive
WORKDIR /root
COPY ignore_capabilities.patch /root/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends git meson ca-certificates dpkg-dev && \
    git clone https://github.com/containers/bubblewrap && \
    cd bubblewrap && \
    ./ci/builddeps.sh && \
    patch -p1 < ../ignore_capabilities.patch && \
    meson _builddir && \
    meson compile -C _builddir

######################################
# Main Application Stage
# Base image for running GUI applications with necessary system utilities
######################################
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

######################################
# Custom Repository Configuration
# Add repository URLs or PPAs here
######################################

# List of custom repositories to add
# Format: "ppa:user/repo-name" or "deb [arch=amd64] http://url.com/repo distribution component"
# Note: software-properties-common will be temporarily installed to support add-apt-repository command for PPAs
ARG CUSTOM_REPOSITORIES=" \
    # ppa:example/ppa \
    # deb [arch=amd64] https://example.com/ubuntu focal main \
"

# Add custom repositories if any are specified
RUN if [ ! -z "$CUSTOM_REPOSITORIES" ]; then \
        apt-get update && \
        # Install software-properties-common for add-apt-repository command \
        apt-get install -y software-properties-common && \
        for repo in $CUSTOM_REPOSITORIES; do \
            if [ "${repo:0:1}" != "#" ]; then \
                if [ "${repo:0:4}" = "ppa:" ]; then \
                    add-apt-repository -y "$repo"; \
                else \
                    echo "$repo" | tee -a /etc/apt/sources.list.d/custom.list; \
                fi; \
            fi; \
        done && \
        # Remove software-properties-common as it's no longer needed \
        apt-get remove -y software-properties-common && \
        apt-get autoremove -y && \
        apt-get update; \
    fi

# List of required packages
# Add packages from custom repositories here as well
ARG REQUIRED_PACKAGES=" \
    dbus-daemon \
    dbus-system-bus-common \
    dbus-session-bus-common \
    network-manager \
    ibus \
    curl \
    pkexec \
    xz-utils \
    zenity \
    file \
    xdg-user-dirs \
    xdg-utils \
    pciutils \
    lsb-release \
    mesa-utils \
    libfontconfig1 \
    libfreetype6 \
"

ARG AVOID_PACKAGES=" \
    nvidia-driver-libs-    # Prevent NVIDIA driver conflicts \
    nvidia-vulkan-icd-     # Prevent Vulkan ICD conflicts \
"

# Install required packages
RUN apt-get update -y && \
    apt-get install -y python3-six software-properties-common && \
    apt-get update -y && \
    apt-get install -y $REQUIRED_PACKAGES

# Additional build steps can go here
# Example:
# RUN make my-custom-tool && \
#     make install

# Final cleanup
RUN apt-get remove -y python3-six software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# System configurations:
# - Create empty config for NetworkManager device detection
# - Replace zenity with /bin/true to skip dialogs
# - Update font cache
RUN touch /etc/NetworkManager/conf.d/10-globally-managed-devices.conf && \
    rm /usr/bin/zenity && ln -s /usr/bin/true /usr/bin/zenity && \
    fc-cache -f -v

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
COPY --chmod=777 scripts/system-services.sh /etc/cont-init.d/system-services.sh
COPY --from=bwrap-builder --chmod=755 /root/bubblewrap/_builddir/bwrap /usr/bin/bwrap

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
