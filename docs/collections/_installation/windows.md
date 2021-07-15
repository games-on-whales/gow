---
layout: default
title: Windows
parent: Desktop environment
nav_order: 2
---

# Windows

On Windows your best bet is to just install the application like you'll normally do without using Docker. 

It should be possible to run GOW on Windows but there are a few issues that we still haven't figured out:

 - WSL2 is missing the uinput kernel module
    - we have built it from scratch by compiling the kernel, even with that, Xorg still fails to start.

[You can follow the progress here](https://github.com/games-on-whales/gow/issues/13)

