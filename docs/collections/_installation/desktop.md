---
layout: default
title: Desktop environment
has_children: true
nav_order: 2
---

# Desktop environments

When you already have a desktop environment running you'll have to disable some of the containers that are part of GOW. 

Generally, instead of running `Xorg` and `PulseAudio` from inside Docker, you can use your current desktop and audio system and just pass the required sockets in order for GUI containers to use your desktop and audio.

There are still some benefits of *containerizing* GUI applications and run them over Docker:
- It's easy to control how much CPU and Memory to allocate to each app that runs via Docker.
- You don't have to manage installation scripts, dependencies conflicts and updates. We'll do that for you.
- You can easily delete all files created by the application by removing the docker container.
- It's easier to backup configuration files and state.

You should also checkout [x11docker](https://github.com/mviereck/x11docker): a project focused on running GUI apps on top of your existing Desktop environment