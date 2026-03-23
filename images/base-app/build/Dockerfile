ARG BASE_IMAGE=ghcr.io/games-on-whales/base:edge
#################################
FROM ${BASE_IMAGE} AS sdl-jstest-builder

WORKDIR /

ARG SDL_JS_TEST_VERSION=8a84a47209f96eb3994cf9f906ae072e828886bb
ENV SDL_JS_TEST_VERSION=${SDL_JS_TEST_VERSION}
RUN <<_BUILD_SDL_JSTEST
    set -e 

    dnf -y install \
      automake \
      gcc \
      gcc-c++ \
      cmake \
      sdl2-compat-devel \
      ncurses-devel \
      git 

    git clone https://github.com/games-on-whales/sdl-jstest
    cd sdl-jstest
    git checkout ${SDL_JS_TEST_VERSION}
    git submodule init
    git submodule update
    mkdir build
    cd build
    cmake .. -DBUILD_SDL_JSTEST=OFF -DBUILD_SDL2_JSTEST=ON
    make

_BUILD_SDL_JSTEST

#################################
FROM ${BASE_IMAGE}

ARG GAMESCOPE_VERSION="3.15.14"
ENV GAMESCOPE_VERSION=$GAMESCOPE_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_ARCHITECTURE=amd64
ENV DEB_BUILD_OPTIONS=noddebs

ARG PKGS_ROOT=/opt/gow

ARG REQUIRED_PACKAGES="\
    mesa-dri-drivers mesa-vulkan-drivers mesa-va-drivers mesa-libgbm mesa-libGL mesa-libEGL \
    egl-gbm  \
    gamescope \
    sway \
    xorg-x11-server-Xwayland kitty nano \
    waybar default-fonts xdg-desktop-portal xdg-desktop-portal-gtk psmisc \
    mangohud \
    sdl2-compat ncurses \
    dbus-daemon \
    "

RUN dnf install -y $REQUIRED_PACKAGES && \
    dnf clean all

COPY configs /cfg

COPY --chmod=777 scripts/init-gamescope.sh /etc/cont-init.d/init-gamescope.sh
COPY --chmod=777 scripts/launch-comp.sh /opt/gow/launch-comp.sh
COPY --chmod=777 scripts/startup.sh /opt/gow/startup.sh
COPY --from=sdl-jstest-builder /sdl-jstest/build/sdl2-jstest /usr/local/bin/sdl2-jstest

# Fix Sway cap_sys_nice=ep
RUN setcap -r /usr/sbin/sway

# Add /usr/games/ to $PATH in order to be able to run gamescope
ENV PATH="/usr/games/:${PATH}"

# Configure the default directory to be the 'retro' users home directory
WORKDIR ${HOME}
