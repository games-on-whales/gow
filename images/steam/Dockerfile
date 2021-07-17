FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ="Europe/London"

ENV UNAME retro
ENV HOME /home/$UNAME

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends software-properties-common sudo && \
    # \
    # Install steam (Steam is 32-bit only) \
    dpkg --add-architecture i386 && \
    add-apt-repository multiverse && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends steam \
    # Adding Vulkan
    libvulkan1 libvulkan1:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
    # Add libdbus to fix webui black screen (https://github.com/ValveSoftware/steam-for-linux/issues/7058)
    libdbus-1-3 \
    # Libraries needed to play games
    libgtk-3-0 libegl1 libsdl2-2.0-0 \
    # Install xdpyinfo so that we can wait for X11 on startup
    x11-utils \
    && \
    # \
    # Cleanup \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Common scripts
COPY --chmod=777 common/* /bin/
# Seems that nvidia-docker is taking care of passing:
# /usr/lib/x86_64-linux-gnu/libnvidia-glvkspirv.so.460.80
# /usr/lib/i386-linux-gnu/libnvidia-glvkspirv.so.460.80
# But it's missing the following json file
COPY steam/configs/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
# Set up the user
RUN setup-retro-user


WORKDIR $HOME
USER ${UNAME}

COPY steam/scripts/startup.sh /startup.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

CMD /bin/bash /startup.sh
