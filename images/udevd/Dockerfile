FROM ubuntu:21.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    udev \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=777 common/* /bin/
COPY udevd/scripts/startup.sh /startup.sh

CMD /bin/bash /startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
