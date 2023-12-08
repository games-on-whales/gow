#!/bin/bash
# sudo docker build -t gow/pegasus:latest --build-arg="BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge" .

sudo docker build -t gow/pegasus:sha-b979a7c --build-arg="BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:sha-b979a7c" .

# sudo docker build -t gow/pegasus:sha-0b348a5 --build-arg="BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:sha-0b348a5" .