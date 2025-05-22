#!/bin/bash
# Display versions of all installed dependencies
set -e

echo "=== Benchmark Dependencies Versions ==="
echo

echo "=== System ==="
uname -a
echo

echo "=== Docker ==="
docker --version
docker-compose --version
echo

echo "=== Network Tools ==="
echo "stunnel: $(stunnel -version 2>&1 | head -n 1)"
echo "nginx: $(nginx -v 2>&1)"
echo "iproute2: $(ip -V)"
echo "openssh: $(ssh -V 2>&1)"
echo "curl: $(curl --version | head -n 1)"
echo "ping: $(ping -V | head -n 1)"
echo "iptables: $(iptables --version)"
echo "netcat: $(nc -h 2>&1 | head -n 1 || echo 'netcat-openbsd installed')"
echo "haproxy: $(haproxy -v | head -n 1)"
echo

echo "=== Versions Check Complete ==="