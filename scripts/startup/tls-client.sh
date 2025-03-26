#!/bin/bash
# Client startup script

# Copy stunnel configuration
cp /config/stunnel-client.conf /etc/stunnel/stunnel.conf

# Initialize tc interface (no changes by default)
tc qdisc del dev eth0 root 2>/dev/null || true

# Start stunnel
stunnel4

# Output status
echo "Stunnel client started. Forwarding from port 9000 to tls-server:8443"
echo "Traffic Control (tc) available for network simulation"

# Keep container running
tail -f /shared/stunnel-client.log