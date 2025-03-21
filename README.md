# TLS Tunnel Performance Testing with Docker

This project provides a Docker-based environment to test and compare performance of various secure tunneling methods, including TLS tunnels, SSH tunnels, and TCP proxies.

## Quick Start

```bash
# Clone repository
git clone git@github.com:scistream/benchmarks.git
cd benchmarks

# Setup environment, build and start containers
./scripts/setup.sh
docker-compose build
docker-compose up -d

# Run tests (examples)
time curl -s -o /dev/null http://localhost:9000/100MB.bin  # TLS 1.3
time curl -s -o /dev/null http://localhost:8000/100MB.bin  # Direct (no tunnel)
```

## Available Tunneling Methods

| Method | Port | Description | Command | Status |
|--------|------|-------------|---------|--------|
| Direct | 8000 | No tunnel, direct nginx access | `curl http://localhost:8000/100MB.bin` | ok |
| TLS 1.3 | 9000 | Strong encryption | `curl http://localhost:9000/100MB.bin` | ok |
| TLS 1.2 NULL | 9001 | Authentication only, no encryption | `curl http://localhost:9001/100MB.bin` | wip |
| SSH | 7000 | Basic SSH port forwarding | `curl http://localhost:7000/100MB.bin` | ok |
| HAProxy | 7100 | TCP proxy with HAProxy | `curl http://localhost:7100/100MB.bin` | ok |
| Nginx TCP | 7200 | TCP proxy with Nginx | `curl http://localhost:7200/100MB.bin` | ok |
| Nginx NAT | 7300 | NAT implementation with Nginx | `curl http://localhost:7300/100MB.bin` | wip |
| Pure NAT | 7400 | Kernel-level NAT using iptables only | `curl http://localhost:7400/100MB.bin` | wip |

## External SSH Tunnels

You can also create your own SSH tunnels from your host machine:

```bash
# Basic tunnel through the SSH container
ssh -L 7500:tls-server:8000 root@localhost -p 2222
curl http://localhost:7500/100MB.bin

# Advanced tunnel via tls-server (using jump host)
ssh -J root@localhost:2222 -L 7600:localhost:8000 root@tls-server
curl http://localhost:7600/100MB.bin
```

## Network Conditions

Simulate different network conditions using traffic control (tc):

```bash
# Apply low latency (10ms)
docker exec --privileged tls-server tc qdisc add dev eth0 root netem delay 10ms rate 1gbit

# Apply high latency (100ms)
docker exec --privileged tls-server tc qdisc add dev eth0 root netem delay 100ms rate 1gbit

# Reset network conditions
docker exec --privileged tls-server tc qdisc del dev eth0 root
```

You can apply conditions to any container (tls-server, tls-client, tls-null, ssh, haproxy, nginx-proxy).

## Testing Methodology

1. **File sizes**: Use 10MB, 100MB, or 1GB test files in the `data/` directory
2. **Network conditions**: 
   - A: Low latency (10ms), 1Gbps
   - B: High latency (100ms), 1Gbps  
   - C: Medium latency (30ms), 1Gbps
3. **Metrics**:
   - Transfer duration: Measured with `time` command
   - Throughput (Mbps): Calculate with `echo "scale=2; $file_size * 8 / 1000000 / $transfer_time" | bc`

## Container Options

- **tls-server**: Nginx web server with stunnel and SSH server
- **tls-client**: Stunnel client with TLS 1.3 encryption
- **tls-null**: Stunnel client with TLS 1.2 NULL cipher (authentication only)
- **ssh**: SSH tunneling with port forwarding capabilities and external access
- **haproxy**: TCP proxy using official HAProxy LTS image
- **nginx-proxy**: TCP proxy using Nginx stream module with both standard proxy and NAT implementation
- **iptables-nat**: Pure kernel-level NAT implementation using only iptables (no proxy server)

## Useful Commands

```bash
# Get terminal
docker exec it tls-server bash

# start ssh
docker exec tls-server /usr/sbin/sshd

# Rebuild and restart
docker-compose down && docker-compose build && docker-compose up -d

# Check status
docker exec tls-server ps aux | grep stunnel
docker exec haproxy haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

# Check logs
cat shared/stunnel-server.log
docker exec tls-server cat /var/log/nginx/error.log

# Verify connectivity
docker exec tls-client ping -c 4 tls-server
curl -v http://localhost:9000

# Generate test files if needed
dd if=/dev/urandom of=data/100MB.bin bs=1M count=100
```

## Future Work

### Performance Improvements
- Implement eBPF-based NAT for higher performance:
  - Use XDP (eXpress Data Path) or Cilium for kernel-bypass packet processing
  - Potentially 10-20x performance improvement over iptables NAT
  - Reduced CPU utilization and lower latency

### Alternative Measurement Methods
- Add non-HTTP benchmarking tools:
  - Raw TCP benchmarks using iperf3
  - UDP performance using netperf
  - Custom protocol testing for specialized workloads
  - Connection establishment rate testing

### Additional Tunneling Technologies
- WireGuard VPN (modern, high-performance VPN)
- QUIC protocol tunneling
- UDT (UDP-based Data Transfer Protocol) for high-latency networks
