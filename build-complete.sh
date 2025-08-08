#!/bin/bash

# 🚀 Complete XFCE Development Container Builder
# This script will build your enhanced XFCE container with Unity Hub, VS Code, Chrome, and Steam

set -e

echo "🎯 Building Enhanced XFCE Development Container..."
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install Docker first:${NC}"
    echo "  - Ubuntu/Debian: sudo apt install docker.io"
    echo "  - CentOS/RHEL: sudo yum install docker"
    echo "  - Arch Linux: sudo pacman -S docker"
    echo "  - Or visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker daemon is not running${NC}"
    echo -e "${YELLOW}Please start Docker:${NC}"
    echo "  sudo systemctl start docker"
    echo "  sudo systemctl enable docker"
    exit 1
fi

echo -e "${GREEN}✅ Docker is available and running${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if required files exist
DOCKERFILE="$PROJECT_ROOT/apps/xfce/build/Dockerfile"
STARTUP_SCRIPT="$PROJECT_ROOT/apps/xfce/build/scripts/startup-enhanced.sh"

if [[ ! -f "$DOCKERFILE" ]]; then
    echo -e "${RED}❌ Dockerfile not found at: $DOCKERFILE${NC}"
    exit 1
fi

if [[ ! -f "$STARTUP_SCRIPT" ]]; then
    echo -e "${RED}❌ Startup script not found at: $STARTUP_SCRIPT${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All required files found${NC}"

# Build the container
echo -e "${BLUE}🔨 Building enhanced XFCE development container...${NC}"
echo "This may take 10-15 minutes depending on your internet connection."

# Set build context and image name
BUILD_CONTEXT="$PROJECT_ROOT/apps/xfce/build"
IMAGE_NAME="ghcr.io/devilblader87/gow/xfce-dev:edge"
LOCAL_IMAGE_NAME="xfce-dev:latest"

# Build the container
echo -e "${YELLOW}📦 Building container: $IMAGE_NAME${NC}"
if docker build -t "$IMAGE_NAME" -t "$LOCAL_IMAGE_NAME" -f "$DOCKERFILE" "$BUILD_CONTEXT"; then
    echo -e "${GREEN}✅ Container built successfully!${NC}"
else
    echo -e "${RED}❌ Container build failed${NC}"
    exit 1
fi

# Show container size
echo -e "${BLUE}📊 Container Information:${NC}"
docker images | grep -E "(xfce-dev|devilblader87.*xfce)" | head -2

echo ""
echo -e "${GREEN}🎯 Build Complete!${NC}"
echo "=============================================="
echo -e "${YELLOW}Container Images Created:${NC}"
echo "  - $IMAGE_NAME (for Wolf)"
echo "  - $LOCAL_IMAGE_NAME (local testing)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Update your Wolf config.toml (backup provided)"
echo "2. Restart Wolf: sudo systemctl restart wolf"
echo "3. Connect via Moonlight and select 'Development Desktop (XFCE)'"
echo ""
echo -e "${YELLOW}What's Included:${NC}"
echo "  ✅ Unity Hub - Game development"
echo "  ✅ Visual Studio Code - Code editor"
echo "  ✅ Google Chrome - Web browser"
echo "  ✅ Steam - Gaming platform"
echo "  ✅ Full file manager rights"
echo "  ✅ Persistent storage for all data"
echo ""
echo -e "${GREEN}🚀 Your development environment is ready!${NC}"

# Optional: Test the container
echo ""
read -p "Would you like to test the container locally? (y/N): " test_container
if [[ $test_container =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🧪 Testing container locally...${NC}"
    echo "Starting container with VNC on port 5900..."
    echo "You can connect with a VNC viewer to localhost:5900"
    echo "Press Ctrl+C to stop the test"
    
    docker run --rm -it \
        --name xfce-dev-test \
        -p 5900:5900 \
        -e DISPLAY=:0 \
        "$LOCAL_IMAGE_NAME"
fi
