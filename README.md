# TLS Tunnel Performance Testing with Docker

This project provides a Docker-based environment to test and compare performance of various secure tunneling methods, including TLS tunnels, SSH tunnels, and TCP proxies. Uses a unified base Docker image for all test scenarios except HAProxy.

## Quick Start

```bash
# Clone repository
git clone git@github.com:scistream/benchmarks.git
cd benchmarks

# Setup environment, build and start containers
./scripts/dependencies.sh
./scripts/setup.sh
./scripts/install.sh
./scripts/build.sh  # Build Docker image with dependencies
./scripts/build_unified_image.sh  # Build the unified Docker image
docker-compose up -d

# Run test examples
time curl -s -o /dev/null http://localhost:9000/100MB.bin  # TLS 1.3
time curl -s -o /dev/null http://localhost:8000/100MB.bin  # Direct (no tunnel)
```

## Container Architecture & Tunneling Methods

| Method | Port | Description | Container | Status |
|--------|------|-------------|-----------|--------|
| Direct | 8000 | No tunnel, direct nginx access | tls-server | ok |
| TLS 1.3 | 9000 | Strong encryption | tls-client → tls-server | ok |
| TLS 1.2 NULL | 9001 | Authentication only, no encryption | tls-null → tls-server | ok |
| SSH | 7000 | SSH port forwarding | ssh → tls-server | ok |
| HAProxy | 7100 | TCP proxy with HAProxy | haproxy → tls-server | ok |
| Pure NAT | 7400 | Kernel-level NAT using iptables | iptables-nat → tls-server | ok |

## Testing & Analysis Tools

### Packet Capture

Capture packets from both the tls-server and tunneling container simultaneously:

```bash
# Usage: ./scripts/capture_flows.sh <server> <port> <tls_server_port> [filesize]
# Where filesize is: 10MB (default), 100MB, or 1GB

# Examples for common tunneling methods:
./scripts/capture_flows.sh tls-client 9000 8443    # TLS 1.3
./scripts/capture_flows.sh tls-null 9001 8444      # TLS 1.2 NULL cipher
./scripts/capture_flows.sh ssh 7000 8000           # SSH forwarding
./scripts/capture_flows.sh haproxy 7100 8000       # HAProxy
```

The script captures packets using nsenter and saves files to shared/captures.

### Network Condition Simulation

Apply different network conditions using traffic control (tc):

```bash
# Apply conditions to any container (add one of these):
#   tls-server, tls-client, tls-null, ssh, haproxy, iptables-nat

# Scenario A: Low latency (10ms), 1Gbps
docker exec --privileged tls-server tc qdisc add dev eth0 root netem delay 10ms rate 1gbit

# Scenario B: High latency (100ms), 1Gbps
docker exec --privileged tls-server tc qdisc add dev eth0 root netem delay 100ms rate 1gbit

# Reset network conditions
docker exec --privileged tls-server tc qdisc del dev eth0 root
```

### External SSH Tunnels

Create your own SSH tunnels from your host machine:

```bash
# Basic tunnel through the SSH container
ssh -L 7500:tls-server:8000 root@localhost -p 2222
curl http://localhost:7500/100MB.bin

# Advanced tunnel via jump host
ssh -J root@localhost:2222 -L 7600:localhost:8000 root@tls-server
curl http://localhost:7600/100MB.bin
```

## Testing Methodology

1. **File sizes**: 10MB, 100MB, or 1GB test files
2. **Network conditions**: Low (10ms), Medium (30ms), or High (100ms) latency at 1Gbps
3. **Metrics**:
   - Transfer duration: `time curl -s -o /dev/null http://localhost:PORT/SIZE.bin`
   - Throughput: `echo "scale=2; $file_size * 8 / 1000000 / $transfer_time" | bc`

## Useful Commands

```bash
# Container access
docker exec -it tls-server bash

# Rebuild and restart
docker-compose down && docker-compose build && docker-compose up -d

# Diagnostics
docker exec tls-server ps aux | grep stunnel
docker exec haproxy haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg
cat shared/stunnel-server.log
docker exec tls-client ping -c 4 tls-server

# Generate test file
dd if=/dev/urandom of=data/100MB.bin bs=1M count=100
```

## Future Work

### Performance Improvements
- eBPF-based NAT using XDP or Cilium for kernel-bypass packet processing
- Potentially 10-20x improvement over iptables NAT with reduced CPU usage

### Alternative Measurement Methods
- Raw TCP benchmarks (iperf3), UDP performance (netperf)
- Connection establishment rate testing

### Additional Technologies
- WireGuard VPN, QUIC protocol tunneling, UDT for high-latency networks
