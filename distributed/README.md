# Distributed TLS Tunnel Performance Testing

This directory contains configurations for running benchmarks in distributed environments.

## 3-Tier Architecture
1. **Producer**: Nginx file server (port 8000)
2. **Tunnel Server**: TLS/SSH servers + HAProxy forwarding to Producer
3. **Tunnel Client**: Client-side tunnels + HAProxy clients

### Docker Compose Files
- `docker-compose-producer.yml`: Nginx file server
- `docker-compose-tunnel-server.yml`: TLS/SSH servers and HAProxy
- `docker-compose-tunnel-client.yml`: Client-side tunnels

### Quick Setup
```bash
# On producer machine
docker-compose -f docker-compose-producer.yml up -d

# On tunnel server machine
docker-compose -f docker-compose-tunnel-server.yml up -d

# On tunnel client machine
docker-compose -f docker-compose-tunnel-client.yml up -d
```

### Configuration Tips
- HAProxy server → Producer: Update IP in haproxy-server.cfg
- Clients → Tunnel Server: Update IPs in stunnel configs, SSH and HAProxy configs

## 2-Tier Architecture
1. **Server**: Combined Nginx + TLS/SSH servers
2. **Clients**: All client-side tunnels

### Quick Setup
```bash
# On server machine
docker-compose -f docker-compose-server.yml up -d

# On client machine
./setup_distributed.sh -s <SERVER_IP>
docker-compose -f docker-compose-clients.yml up -d
./update_dns.sh
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
Ensure ports are open on server machines: `sudo netstat -tulpn | grep 8000`

**IMPORTANT**: `/data` directory with test files must exist on all machines.