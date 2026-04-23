# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    libpci3 \
    firefox \
    libavcodec-extra \
    ubuntu-restricted-extras \
"

# Install firefox from Mozilla's official apt repo rather than the Ubuntu
# archive (which ships a snap shim that will not run in a container) or
# ppa:mozillateam/ppa (which dropped plucky support -- the PPA advertises
# the suite but publishes an empty Packages index). Same approach as the
# xfce image.
RUN <<_INSTALL_PACKAGES
set -e
apt-get update
apt-get install -y --no-install-recommends wget ca-certificates
install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg \
     -O /etc/apt/keyrings/packages.mozilla.org.asc
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
     > /etc/apt/sources.list.d/mozilla.list
printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
     > /etc/apt/preferences.d/mozilla
apt-get update
apt-get install -y --no-install-recommends $REQUIRED_PACKAGES
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
_INSTALL_PACKAGES

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

# See the full list of supported options at: https://mozilla.github.io/policy-templates/
COPY <<_PREFS /etc/firefox/policies/policies.json
{
  "policies": {
    "AppAutoUpdate": false,
    "OverrideFirstRunPage": "",
    "OverridePostUpdatePage": "",
    "FirefoxHome": {
      "Search": true,
      "TopSites": true,
      "SponsoredTopSites": false,
      "Highlights": true,
      "Pocket": false,
      "SponsoredPocket": false,
      "Snippets": false,
      "Locked": false
    },
    "Preferences": {
        "browser.policies.loglevel": {
            "Value": "debug",
            "Status": "default"
        },
        "gfx.webrender.all": {
            "Value": true,
            "Status": "default"
        },
        "webgl.force-enabled": {
            "Value": true,
            "Status": "default"
        }
    }
  }
}
_PREFS

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
