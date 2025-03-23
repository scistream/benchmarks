#!/bin/bash
# Pure iptables NAT implementation without a proxy server

# Enable IP forwarding (required for NAT)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Initialize tc interface (no changes by default)
tc qdisc del dev eth0 root 2>/dev/null || true

# Clear any existing iptables rules
iptables -F
iptables -t nat -F

# Set up NAT for port 7400 to tls-server:8000
# This redirects all traffic coming to port 7400 to tls-server port 8000
iptables -t nat -A PREROUTING -p tcp --dport 7400 -j DNAT --to-destination 172.18.0.2:8000
iptables -t nat -A POSTROUTING -j MASQUERADE

echo "Pure iptables NAT started on port 7400 -> tls-server:8000"
echo "No proxy server is running - this is direct NAT using iptables"

# Keep container running
tail -f /dev/null
