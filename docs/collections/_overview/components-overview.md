---
layout: default
title: Components
nav_order: 2
---
# Components Overview
{: .no_toc }

Make sure to read first the [overview](/overview/overview/) section to get a grasp on what's the idea behind GOW.

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

<p align="center">
  <img width="500" src="/assets/img/gow-diagram.svg">
</p>

GOW is a composition of Docker containers that enable users to stream graphical applications to Moonlight clients.

We wrapped each individual software with the necessary dependencies into a single Docker image and we use [`docker-compose`](https://docs.docker.com/compose/) in order to manage the composition.

## Sunshine

[Sunshine](https://github.com/loki-47-6F-64/sunshine) is the heart of this system: it's the streaming host and it's in charge of:
 - Encoding the graphical environment (`Xorg`) and audio (`PulseAudio`) into a video that will be streamed to [Moonlight](https://moonlight-stream.org/) clients
    - This process can be HW accelerated using [`VAAPI`](https://en.wikipedia.org/wiki/Video_Acceleration_API) on compatible HW
 - Translating remote inputs into local input devices (aka: keyboards, mouse, joypad)
    - This is achieved by using the [`uinput`](https://www.kernel.org/doc/html/v4.12/input/uinput.html) kernel module

### uinput

Uinput makes possible to emulate virtual devices. It's required by Sunshine and it's the one and only real requirement that we need in the host machine kernel.

Most Linux distributions already ships it and you'll find it already there if you use Ubuntu or Debian for example.

If it's not there already, since it's part of the Linux kernel, it might be difficult to compile it from scratch. We try to add support for platforms who don't have it, for example, [we are working on a plugin for Unraid](https://github.com/games-on-whales/unraid-plugin).

If you have issues with inputs (mouse, joypad) while streaming using GOW, it's very likely that something is wrong with `uinput`


## Xorg + PulseAudio

This two components are in charge respectively of *Display* and *Audio*. 

- If your OS comes with a [desktop environment](https://en.wikipedia.org/wiki/Desktop_environment) already, you can use that instead of running it over Docker.
- If you are running a [headless](https://en.wikipedia.org/wiki/Headless_computer) system you'll need to run them in order to run graphical applications, you can use our Docker images for that.

While PulseAudio runs just fine without a real sound device, Xorg can (and should) be HW accelerated using a GPU. That's the main reason why we choose Xorg over [`Xvfb`](https://en.wikipedia.org/wiki/Xvfb), while it's more complicated to run the full Xorg server the benefits of having HW acceleration are too big to be dismissed.

## GUIs

Graphical applications can run easily on top of Xorg and PulseAudio, that's how most desktop environment works!

<p align="center">
  <img width="300" src="/assets/img/gui-overview.svg">
</p>

Sharing [sockets](https://en.wikipedia.org/wiki/Unix_domain_socket) between containers is the mechanism that enables us to have proper isolation. Instead of having a big single Docker image which installs and runs all these softwares together we can decouple them and share only a communication channel.

This means that it's very simple to make a Docker container of any given GUI application and that same container will work both on **GOW** or on a normal *Desktop Environment*, enabling users to have a high degree of freedom on how to use them.

## GPU

A GPU is not required to run any of this, but it's highly recommended.

Sharing a GPU across Docker containers is possible and it's generally done by sharing the [DRM devices (`/dev/dri/cardX`)](https://en.wikipedia.org/wiki/Direct_Rendering_Manager). As always there are exceptions and we have specific instructions for [Nvidia cards](/configuration/nvidia/).