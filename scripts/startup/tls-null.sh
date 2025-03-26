#!/bin/bash
# TLS NULL cipher client startup script

# Copy stunnel configuration
cp /config/stunnel-null-client.conf /etc/stunnel/stunnel.conf

# Initialize tc interface (no changes by default)
tc qdisc del dev eth0 root 2>/dev/null || true

# Start stunnel
stunnel4

# Output status
echo "Stunnel TLS 1.2 with NULL cipher started. Forwarding from port 9001 to tls-server:8444"
echo "Traffic Control (tc) available for network simulation"

# Keep container running
tail -f /shared/stunnel-null-client.log