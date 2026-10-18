#!/bin/bash
set -euo pipefail

# First argument controls the app to build (ex: steam)
APP_NAME=${1:-"steam"}
# Fedora 44 is primary; Ubuntu is an explicit backup.
case "${2:-fedora44}" in
  fedora44|fedora|-fedora) IMAGE_VARIANT=-fedora ;;
  ubuntu) IMAGE_VARIANT= ;;
  *) echo "Usage: $0 [app] [fedora44|ubuntu]" >&2; exit 1 ;;
esac

echo "======================================"
echo "🔨 Building gow/base${IMAGE_VARIANT}..."
docker build -t gow/base${IMAGE_VARIANT} images/base/build${IMAGE_VARIANT} --progress=plain
echo "🌟 Built gow/base${IMAGE_VARIANT}"

echo "======================================"
echo "🔨 Building gow/base-app${IMAGE_VARIANT}..."
docker build --build-arg BASE_IMAGE=gow/base${IMAGE_VARIANT} -t gow/base-app${IMAGE_VARIANT} images/base-app/build${IMAGE_VARIANT} --progress=plain
echo "🌟 Built gow/base-app${IMAGE_VARIANT}"

echo "======================================"
echo "🔨 Building ${APP_NAME} image..."
docker build --build-arg BASE_APP_IMAGE=gow/base-app${IMAGE_VARIANT} -t gow/${APP_NAME}${IMAGE_VARIANT} apps/${APP_NAME}/build${IMAGE_VARIANT} --progress=plain
echo "🌟 Built gow/${APP_NAME}${IMAGE_VARIANT}"