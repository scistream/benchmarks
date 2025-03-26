#!/bin/bash
# Setup script for distributed TLS benchmark environment

# Default server IP (can be overridden with -s flag)
SERVER_IP="10.0.0.2"  # Default value, replace with actual server IP

# Parse command line arguments
while getopts "s:" opt; do
  case $opt in
    s) SERVER_IP="$OPTARG"
       ;;
    *) echo "Usage: $0 [-s server_ip]"
       exit 1
       ;;
  esac
done

echo "Setting up distributed benchmark environment with tls-server at $SERVER_IP"

# Create required directories in distributed context
mkdir -p ../shared ../config 2>/dev/null
mkdir -p ../data 2>/dev/null

# Update client configs to use the remote server IP

# 1. Update stunnel client configs
echo "Updating stunnel client configurations..."
sed -i "s/connect = tls-server:8443/connect = $SERVER_IP:8443/" ../config/stunnel-client.conf
sed -i "s/connect = tls-server:8444/connect = $SERVER_IP:8444/" ../config/stunnel-client-null.conf

# 2. Update HAProxy config
echo "Updating HAProxy configuration..."
sed -i "s/server tls-server tls-server:8000/server tls-server $SERVER_IP:8000/" ../haproxy/haproxy.cfg

# 3. Nginx proxy removed from configuration

# 4. Update iptables-nat config in start.sh
echo "Updating iptables-nat configuration..."
sed -i "s/tls-server/$SERVER_IP/" ../iptables-nat/start.sh

# 5. Add DNS entry to /etc/hosts in all client containers
echo "Creating DNS update script for client containers..."
cat > update_dns.sh << EOF
#!/bin/bash
# This script will be run after the client containers are started
# to update their /etc/hosts files

# Add tls-server to /etc/hosts in all client containers
docker exec tls-client bash -c "echo '$SERVER_IP tls-server' >> /etc/hosts"
docker exec tls-null bash -c "echo '$SERVER_IP tls-server' >> /etc/hosts"
docker exec ssh bash -c "echo '$SERVER_IP tls-server' >> /etc/hosts"
docker exec haproxy bash -c "echo '$SERVER_IP tls-server' >> /etc/hosts"
docker exec iptables-nat bash -c "echo '$SERVER_IP tls-server' >> /etc/hosts"

echo "DNS entries added to all client containers."
EOF

chmod +x update_dns.sh

# 6. Update SSH config
echo "Updating SSH configuration..."
sed -i "s/root@tls-server/root@$SERVER_IP/" ../ssh/start.sh

echo "Configuration updates complete."
echo ""
echo "To deploy the distributed environment:"
echo ""
echo "1. On the server machine:"
echo "   cd /path/to/benchmarks/distributed"
echo "   docker-compose -f docker-compose-server.yml up -d"
echo ""
echo "2. On the client machine:"
echo "   cd /path/to/benchmarks/distributed"
echo "   docker-compose -f docker-compose-clients.yml up -d"
echo "   ./update_dns.sh"
echo ""
echo "Remember to share the data/ directory across both machines"
echo "to ensure the same test files are available."
echo ""
echo "For best results, synchronize configuration files between machines."