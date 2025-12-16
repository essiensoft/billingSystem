#!/bin/bash

# PHPNuxBill - Push to Docker Hub Script
# This script builds and pushes the Docker image to Docker Hub

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PHPNuxBill - Docker Hub Push Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    exit 1
fi

# Get Docker Hub username
read -p "Enter your Docker Hub username: " DOCKER_USERNAME

if [ -z "$DOCKER_USERNAME" ]; then
    echo -e "${RED}Error: Docker Hub username is required${NC}"
    exit 1
fi

# Get image name (default: phpnuxbill)
read -p "Enter image name [phpnuxbill]: " IMAGE_NAME
IMAGE_NAME=${IMAGE_NAME:-phpnuxbill}

# Get version tag (default: latest)
read -p "Enter version tag [latest]: " VERSION_TAG
VERSION_TAG=${VERSION_TAG:-latest}

# Full image name
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION_TAG}"

echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Docker Hub Username: $DOCKER_USERNAME"
echo "  Image Name: $IMAGE_NAME"
echo "  Version Tag: $VERSION_TAG"
echo "  Full Image: $FULL_IMAGE_NAME"
echo ""

# Confirm
read -p "Continue with this configuration? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${YELLOW}Aborted by user${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Step 1: Logging into Docker Hub...${NC}"
docker login

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Docker Hub login failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Step 2: Setting up Docker buildx for multi-platform builds...${NC}"
# Create a new builder instance if it doesn't exist
if ! docker buildx inspect phpnuxbill-builder > /dev/null 2>&1; then
    echo "  Creating new buildx builder..."
    docker buildx create --name phpnuxbill-builder --use
else
    echo "  Using existing buildx builder..."
    docker buildx use phpnuxbill-builder
fi

# Bootstrap the builder
docker buildx inspect --bootstrap

echo ""
echo -e "${GREEN}Step 3: Building multi-platform Docker image...${NC}"
echo "  Building for: linux/amd64, linux/arm64"
echo "  This may take several minutes..."

# Build and push for multiple platforms
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t $FULL_IMAGE_NAME \
    -f Dockerfile \
    --push \
    .

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Docker build failed${NC}"
    exit 1
fi

# Also push as latest if version is not latest
if [ "$VERSION_TAG" != "latest" ]; then
    echo ""
    echo -e "${GREEN}Step 4: Pushing 'latest' tag to Docker Hub...${NC}"
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t ${DOCKER_USERNAME}/${IMAGE_NAME}:latest \
        -f Dockerfile \
        --push \
        .
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Docker push for 'latest' tag failed${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Successfully pushed to Docker Hub!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Image available at:"
echo "  docker pull $FULL_IMAGE_NAME"
if [ "$VERSION_TAG" != "latest" ]; then
    echo "  docker pull ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
fi
echo ""
echo "Docker Hub URL:"
echo "  https://hub.docker.com/r/${DOCKER_USERNAME}/${IMAGE_NAME}"
echo ""
