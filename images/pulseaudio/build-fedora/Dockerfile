ARG BASE_IMAGE=ghcr.io/games-on-whales/base:fedora

# hadolint ignore=DL3006
FROM ${BASE_IMAGE}

ARG REQUIRED_PACKAGES=" \
    alsa-utils \
    alsa-lib \
    alsa-plugins-pulseaudio \
    pulseaudio \
    "

# Configure container to run process as root user
# Note:
#   The PulseAudio daemon will refuse to start if the $HOME directory is not
#   owned by the user who launched it, _EVEN IF THAT USER IS root_.  So we need
#   to override $HOME to _not_ be /home/retro.  This isn't a big deal because
#   this dir is entirely inside the container anyway (it's not mounted into
#   $local_state) so its name is essentially irrelevant.
ENV \
    UNAME="root" \
    HOME="/root"

RUN dnf install -y $REQUIRED_PACKAGES && \
    dnf clean all

COPY configs/default.pa /etc/pulse/default.pa
COPY configs/client.conf /etc/pulse/client.conf
COPY configs/daemon.conf /etc/pulse/daemon.conf

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

EXPOSE 4713

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
