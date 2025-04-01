# Distributed TLS Tunnel Performance Testing

This directory contains configurations for running benchmarks in distributed environments.

## 3-Tier Architecture
1. **Producer**: Nginx file server (port 8000)
2. **Tunnel Server**: TLS/SSH servers + HAProxy forwarding to Producer
3. **Tunnel Client**: Client-side tunnels + HAProxy clients

## Quick Setup

We use a single Docker Compose file with profiles to deploy different tiers:

```bash
# On producer machine (file server)
docker-compose --profile producer up -d

# On tunnel server machine (middle tier)
docker-compose --profile tunnel-server up -d

# On tunnel client machine (tunnel clients)
docker-compose --profile tunnel-client up -d
```

## Configuration Requirements

Before deployment, you need to update configuration files with the correct IP addresses:

1. **Update HAProxy server → Producer connection**:
   - Edit `../config/haproxy/haproxy-server.cfg` to point to the Producer IP

2. **Update Clients → Tunnel Server connections**:
   - Edit `../config/stunnel-client.conf` and `../config/stunnel-client-null.conf`
   - Edit `../config/haproxy/haproxy.cfg` and `../config/haproxy/haproxy-cascade.cfg`
   - Edit SSH configs in `../config/ssh/ssh_config`

3. **Add DNS entries to client containers**:
   ```bash
   # Run this after starting the client containers
   docker exec tls-client bash -c "echo 'TUNNEL_SERVER_IP tunnel-server' >> /etc/hosts"
   docker exec tls-null bash -c "echo 'TUNNEL_SERVER_IP tunnel-server' >> /etc/hosts"
   docker exec ssh bash -c "echo 'TUNNEL_SERVER_IP tunnel-server' >> /etc/hosts"
   docker exec haproxy bash -c "echo 'TUNNEL_SERVER_IP tunnel-server' >> /etc/hosts"
   docker exec iptables-nat bash -c "echo 'TUNNEL_SERVER_IP tunnel-server' >> /etc/hosts"
   ```

## Testing
```bash
time curl -s -o /dev/null http://localhost:9000/100MB.bin  # TLS 1.3
time curl -s -o /dev/null http://localhost:9001/100MB.bin  # TLS 1.2 NULL
time curl -s -o /dev/null http://localhost:7000/100MB.bin  # SSH
time curl -s -o /dev/null http://localhost:7100/100MB.bin  # HAProxy
time curl -s -o /dev/null http://localhost:7300/100MB.bin  # HAProxy cascade
```

## Network Conditions
```bash
docker exec --privileged <container> tc qdisc add dev eth0 root netem delay 10ms rate 1gbit
```

## Troubleshooting
- Ensure ports are open on server machines: `sudo netstat -tulpn | grep 8000`
- Check container logs: `docker logs tunnel-server`
- Verify network connectivity: `docker exec tls-client ping tunnel-server`

**IMPORTANT**: 
- `/data` directory with test files must exist on all machines
- Synchronize configuration files between machines for consistent setup