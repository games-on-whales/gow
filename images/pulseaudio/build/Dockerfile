ARG BASE_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ARG REQUIRED_PACKAGES=" \
    alsa-utils \
    libasound2t64 \
    libasound2-plugins \
    pulseaudio \
    "

# Run the daemon as the 'pulse' system user, not root.
# - pulseaudio won't start unless its user owns $HOME.
# - XDG_RUNTIME_DIR matches the socket directory in default.pa. When the
#   container starts as root, 10-setup_user.sh gives it to 'pulse', even if
#   it's a mounted host directory.
# - To drop all capabilities, start the container with `--user pulse`.
ENV \
    UNAME="pulse" \
    HOME="/var/lib/pulse" \
    XDG_RUNTIME_DIR="/tmp/pulse"

# Taken from https://github.com/jessfraz/dockerfiles/blob/master/pulseaudio/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# The pulseaudio package usually creates 'pulse'. Create it if it's missing,
# and give it a home directory it owns.
RUN if ! id -u pulse >/dev/null 2>&1; then \
        useradd --system --user-group --no-create-home --shell /usr/sbin/nologin pulse; \
    fi && \
    usermod --home "$HOME" pulse && \
    install -d -o pulse -g pulse -m 0700 "$HOME" && \
    install -d -o pulse -g pulse -m 0755 "$XDG_RUNTIME_DIR"

COPY configs/default.pa /etc/pulse/default.pa
COPY configs/client.conf /etc/pulse/client.conf
COPY configs/daemon.conf /etc/pulse/daemon.conf

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

EXPOSE 4713

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
