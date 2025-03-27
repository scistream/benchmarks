#!/bin/bash
# Build the unified Docker image for all test scenarios

set -e

# Navigate to project root
cd "$(dirname "$0")/.." || exit 1

echo "Building unified Docker image for benchmarks..."
docker build -t scistream-benchmark:latest .

echo "Image built successfully as scistream-benchmark:latest"
echo "Use 'docker-compose up -d' to run the benchmark environment"
echo "The same image is now used for all services (except HAProxy)"