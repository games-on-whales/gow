#!/bin/bash
# Script to make building images easier
docker build -t gow/nvidia-driver:latest --no-cache --build-arg="NV_VERSION=$(cat /sys/module/nvidia/version)"  .

# TODO: Need to add something here to first find containers still using the volume and auto-remove them first
docker volume rm nvidia-driver-vol
docker run --name nvidia-driver-container --rm --mount source=nvidia-driver-vol,destination=/usr/nvidia gow/nvidia-driver:latest sh
