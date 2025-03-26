# SciStream Benchmark Commands

## Quick Start
```bash
# Build image and start environment in one command
cd .. && ./run_benchmark.sh
```

## Building the Docker Image
```bash
# Build the unified scistream-benchmark image
./scripts/build_unified_image.sh
```

## Starting the Environment
```bash
# Start all containers
docker-compose up -d

# Or start specific containers
docker-compose up -d tls-server tls-client
```

## Running Tests
```bash
# Run all tests with the shell script
cd tests
./run_tests.sh

# Or run tests with pytest
cd tests
source venv/bin/activate
pytest -v test_tunnels.py
```

## Cleaning Up
```bash
# Stop all containers
docker-compose down

# Remove the Docker image (optional)
docker rmi scistream-benchmark:latest
```

## Checking Container Status
```bash
# View running containers
docker-compose ps

# Check logs of a specific container
docker-compose logs tls-server
```

## Applying Network Conditions
```bash
# Add network latency to server
docker exec --privileged tls-server tc qdisc add dev eth0 root netem delay 10ms rate 1gbit

# Reset network conditions
docker exec --privileged tls-server tc qdisc del dev eth0 root
```