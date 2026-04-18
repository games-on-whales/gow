#!/bin/bash
set -euo pipefail

# First argument controls the app to build (ex: steam)
APP_NAME=${1:-"steam"}
# Second argument controls the variant of the image (ex: -fedora)
IMAGE_VARIANT=${2:-"-fedora"}

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