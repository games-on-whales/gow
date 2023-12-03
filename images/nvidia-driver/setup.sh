#!/bin/bash

docker build -t gow/nvidia-driver:latest --no-cache --build-arg="NV_VERSION=$(cat /sys/module/nvidia/version)"  .

docker volume rm nvidia-driver-vol
docker run --name nvidia-driver-container --rm --mount source=nvidia-driver-vol,destination=/usr/nvidia gow/nvidia-driver:latest sh
