ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:fedora

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

# Fedora 44 replaced java-21-openjdk with the Temurin repository.
# Keep Java 21 available for Minecraft versions that require it.
# PrismLauncher is available in Fedora repos via COPR
RUN dnf install -y \
    adoptium-temurin-java-repository \
    wget \
    && dnf --enablerepo=adoptium-temurin-java-repository install -y temurin-21-jdk \
    && dnf copr enable -y g3tchoo/prismlauncher \
    && dnf install -y prismlauncher \
    && dnf clean all

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
