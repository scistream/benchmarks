# Distributed TLS Tunnel Performance Testing

This directory contains configuration files and scripts for running the TLS benchmarks in a distributed environment, with the server and clients on separate physical machines.

## Prerequisites

- Two or more machines with Docker and Docker Compose installed
- Network connectivity between the machines
- Shared storage for test data files (optional but recommended)

## Setup Process

### 1. Clone the repository on both machines

```bash
git clone https://github.com/scistream/benchmarks.git
cd benchmarks
```

### 2. Server Machine Setup

```bash
cd distributed
docker-compose -f docker-compose-server.yml up -d
```

This will start the tls-server container with all required services (nginx, stunnel, SSH).

### 3. Client Machine Setup

1. First, run the setup script with the server IP address:

```bash
cd distributed
./setup_distributed.sh -s <SERVER_IP>
```

Replace `<SERVER_IP>` with the actual IP address of your server machine.

2. Start the client containers:

```bash
docker-compose -f docker-compose-clients.yml up -d
```

3. Update DNS entries in all client containers:

```bash
./update_dns.sh
```

## Testing

Run tests just like in the single-machine setup, but from the client machine:

```bash
# Test TLS 1.3 tunnel
time curl -s -o /dev/null http://localhost:9000/100MB.bin

# Test TLS 1.2 NULL cipher
time curl -s -o /dev/null http://localhost:9001/100MB.bin

# Test SSH port forwarding
time curl -s -o /dev/null http://localhost:7000/100MB.bin
```

## Network Conditions

You can apply network conditions to containers on either machine:

```bash
# On the server
docker exec --privileged tls-server tc qdisc add dev eth0 root netem delay 10ms rate 1gbit

# On the client
docker exec --privileged tls-client tc qdisc add dev eth0 root netem delay 10ms rate 1gbit
```

## Data Synchronization

For best results, ensure that both machines have identical test files in their `data/` directories.

You can use rsync to copy files from the server to the client:

```bash
rsync -avz user@server_ip:/path/to/benchmarks/data/ /path/to/benchmarks/data/
```

## Packet Captures

The `capture_flows.sh` script works in the distributed environment too:

```bash
./scripts/capture_flows.sh tls-client 9000 8443
```

Note that packet captures are saved on the client machine only.

## Troubleshooting

If you encounter connection issues between clients and the server:

1. Verify network connectivity: 
   ```bash
   docker exec tls-client ping tls-server
   ```

2. Check DNS resolution:
   ```bash
   docker exec tls-client getent hosts tls-server
   ```

3. Ensure ports are open on the server machine:
   ```bash
   sudo netstat -tulpn | grep 8000
   ```