ARG BUILD_OWNER
ARG BUILD_TAG
FROM ghcr.io/${BUILD_OWNER}/base:${BUILD_TAG}

ARG DEBIAN_FRONTEND=noninteractive

ARG REQUIRED_PACKAGES=" \
    alsa-utils \
    libasound2 \
    libasound2-plugins \
    pulseaudio \
    "

# Taken from https://github.com/jessfraz/dockerfiles/blob/master/pulseaudio/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

COPY configs/default.pa /etc/pulse/default.pa
COPY configs/client.conf /etc/pulse/client.conf
COPY configs/daemon.conf /etc/pulse/daemon.conf

COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh

# the PulseAudio daemon will refuse to start if the $HOME directory is not
# owned by the user who launched it, _EVEN IF THAT USER IS root_.  So we need
# to override $HOME to _not_ be /home/retro.  This isn't a big deal because
# this dir is entirely inside the container anyway (it's not mounted into
# $local_state) so its name is essentially irrelevant.
ENV HOME=/root

EXPOSE 4713

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
