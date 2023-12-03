#!/bin/bash
sudo docker build -t gow/pegasus:latest --build-arg="BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge" .

# sudo docker build -t gow/pegasus:latest --build-arg="BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:sha-b979a7c" .