ARG BASE_APP_IMAGE
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

# Install AudioRelay tarball
RUN set -eux; \
    mkdir -p /opt/audiorelay; \
    curl -L "https://dl.audiorelay.net/setups/linux/audiorelay-0.27.5.tar.gz" \
      | tar -xz -C /opt/audiorelay --strip-components=1; \
    chmod +x /opt/audiorelay/bin/AudioRelay; \
    ln -sf /opt/audiorelay/bin/AudioRelay /usr/local/bin/audiorelay


COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh
