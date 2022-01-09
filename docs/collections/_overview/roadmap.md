---
layout: default
title: Roadmap
nav_order: 4
---
# Roadmap

We are in a proof of concept phase right now. So far we have achieved the following:
 - We know *it's possible* to run HW accelerated games on Docker
 - We have working environments in both `Debian` and `Unraid`, with and without a GPU


We would like to achieve the following:
 - Make a general set of Docker containers that can run any GUI app (as long as it can run on Docker)
 - Make a *"launcher app"* that will let users start/stop other GUI containers *easily*
   - This will be possible by passing the Docker socket
 - Create a list of curated docker containers for popular GUI applications like: Firefox, Steam, RetroArch, etc.
 - Support as many platforms as we can
 - Create great documentation so that anybody can understand and learn from this project

Do you want to [contribute]({{ site.baseurl }}{% link _contributing/contributing.md %}) to this project?
