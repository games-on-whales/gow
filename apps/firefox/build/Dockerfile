# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    firefox \
"

RUN dnf install -y $REQUIRED_PACKAGES && \
    dnf clean all

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
