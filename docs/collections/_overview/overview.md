---
layout: default
title: Overview
nav_order: 1
---
# Overview

<img width="100" src="/assets/img/gow-logo.png">
{: .float-left .p-3}

**Games on Whales (GOW)** let's you stream games (and GUI) running on Docker with HW acceleration and low latency.

The basic idea is that a [server](https://en.wikipedia.org/wiki/Server_(computing)) can stream games to clients the same way you will play a video on Youtube. There are lots of supported clients already like: your phone, your laptop, or even a Nintendo Switch! 

A server is not necessary a [gigantic beast of a machine](https://upload.wikimedia.org/wikipedia/commons/6/69/Wikimedia_Foundation_Servers-8055_35.jpg), it can be: a laptop, a normal desktop machine, or even something smaller and compact like a Raspberry PI ([in theory](https://github.com/games-on-whales/gow/issues/20)). Generally, you should be able to pick any OS that supports [Docker](https://en.wikipedia.org/wiki/Docker_(software)) and start using GOW!

## How does it work?

We bring together a few different components in order to achieve that:

 - [Moonlight](https://moonlight-stream.org/): an open source implementation of NVIDIA's GameStream protocol. You can stream your collection of PC games from your GameStream-compatible PC to any supported device and play them remotely.

 - [Sunshine](https://github.com/loki-47-6F-64/sunshine): an opensource Gamestream host for Moonlight. This gives us the ability to stream from a Linux box since it's not tied to the proprietary Nvidia GameStream (Windows only and not opensource).

 - [Docker](https://en.wikipedia.org/wiki/Docker_(software)): the platform that we use in order to deliver software packages (called containers) that you can easily run without having to manually install and configure everything.

 - [Xorg](https://en.wikipedia.org/wiki/X.Org_Server): The window system that we use in order to manage and display graphical applications ([GUI](https://en.wikipedia.org/wiki/Graphical_user_interface))

 - [PulseAudio](https://en.wikipedia.org/wiki/PulseAudio): The software that will manage audio for our GUIs

 - [RetroArch](https://en.wikipedia.org/wiki/RetroArch): An open source, crossplatform frontend for emulators, game engines and much more!

<p align="center">
  <img width="300" src="/assets/img/gow-diagram.svg">
</p>

 Head over to the [components overview](/overview/components-overview/) if you are interested in how these bunch of softwares are tied together by GOW

