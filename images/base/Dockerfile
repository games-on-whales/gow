FROM ubuntu:23.04

ENV \
    TZ="Europe/London" \
    UNAME=retro \
    PUID=1000 \
    PGID=1000

# These depend on values defined in the previous set, so they (sadly) must be
# in their own layer.
ENV HOME=/home/$UNAME

# Set up the user
RUN --mount=type=bind,source=build/setup-retro-user,target=/setup-retro-user /setup-retro-user

# use ARG instead of ENV because we only need it at runtime
ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES="\
    sudo \
    fuse \
    libnss3 \
    "

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    $REQUIRED_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

WORKDIR $HOME

COPY --chmod=777 scripts/bootstrap.sh /opt/gow/bootstrap.sh
COPY --chmod=777 scripts/ensure-groups /opt/gow/ensure-groups
COPY scripts/lib/ /opt/gow/bash-lib/

CMD [ "/opt/gow/bootstrap.sh" ]

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
