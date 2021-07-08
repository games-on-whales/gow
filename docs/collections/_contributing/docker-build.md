---
layout: default
title: Docker Build
nav_order: 2
---
# Docker build

So you don't trust downloading Docker images from the web eh? You are right! No one should trust *the internet*!

Our images are built and pushed using Github Actions, you can manually check if the images are being tampered by doing the followings:

- Head over to the [`Actions`](https://github.com/games-on-whales/gow/runs/) section on Github and open up the build that you want to check
- For each generated Docker image there's a step called `Image digest` here's the sha checksum of the image generated on Github
- Head over to the [Docker hub](https://hub.docker.com/layers/gameonwhales/xorg/sha-98e5080/images/sha256-6b8555260ed07c7ed466e0b821922a3cedf4ee27b9d6b8fea9d6aa2995b75f61?context=repo) and check that the sha for the image and the sha for the commit are the same as it's displayed in Github

### Example

Here's an example from the commit [`98e5080`](https://github.com/games-on-whales/gow/commit/98e508019247f8aecd82db9ffb4320f00de4e1dc)
The associated [Github Action](https://github.com/games-on-whales/gow/runs/2945887498#step:7:1) for the `xorg` image reports: 

```
xorg > sha256:6b8555260ed07c7ed466e0b821922a3cedf4ee27b9d6b8fea9d6aa2995b75f61
```

The [image layer details](https://hub.docker.com/layers/gameonwhales/xorg/sha-98e5080/images/sha256-6b8555260ed07c7ed466e0b821922a3cedf4ee27b9d6b8fea9d6aa2995b75f61?context=repo) on the Docker Hub reports:

```
gameonwhales/xorg:sha-98e5080
Digest:sha256:6b8555260ed07c7ed466e0b821922a3cedf4ee27b9d6b8fea9d6aa2995b75f61
```


## I don't trust you let me build the images myself

You sure can! We use docker buildkit, make sure it's installed in your environment.
In order to build it locally run:

```
sudo COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build
```
