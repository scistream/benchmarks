#!/bin/bash
# Build Docker image, tag based on commit info, and run version test
set -e

# Get latest commit hash and message for tagging
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B | head -n1 | sed 's/[^a-zA-Z0-9]/-/g' | cut -c1-20)
DATE=$(date +%Y%m%d)

# Image name
IMAGE_NAME="benchmarks"
TAG="${DATE}-${COMMIT_HASH}"

echo "Building Docker image: ${IMAGE_NAME}:${TAG}"
echo "Based on commit: ${COMMIT_MSG}"

# Build the Docker image
docker build -t ${IMAGE_NAME}:${TAG} .
docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest

echo "Image built successfully!"
echo "Tag: ${IMAGE_NAME}:${TAG}"

# Run the container with version script to test
echo "Running version check..."
docker run --rm ${IMAGE_NAME}:${TAG} bash -c "cd /app && ./version.sh"

echo "Build completed successfully!"
echo "Run with: docker run -it ${IMAGE_NAME}:${TAG}"