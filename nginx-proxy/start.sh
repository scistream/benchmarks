#!/bin/bash
# Nginx TCP proxy startup script

# Initialize tc interface (no changes by default)
tc qdisc del dev eth0 root 2>/dev/null || true

# Enable IP forwarding for NAT
echo 1 > /proc/sys/net/ipv4/ip_forward

# Set up iptables for NAT only for port 7300 traffic
iptables -t nat -A PREROUTING -p tcp --dport 7300 -j DNAT --to-destination tls-server:8000 2>/dev/null || echo "Warning: Could not setup DNAT rule (missing capabilities)"
iptables -t nat -A POSTROUTING -p tcp --dport 8000 -d tls-server -j MASQUERADE 2>/dev/null || echo "Warning: Could not setup MASQUERADE rule (missing capabilities)"

# Enable transparent proxy mode for Nginx
sysctl -w net.ipv4.ip_nonlocal_bind=1 2>/dev/null || echo "Warning: Could not enable nonlocal_bind (missing capabilities)"

# Start Nginx
echo "Starting Nginx TCP stream proxy on ports 7200 and 7300 (NAT)..."
exec nginx -g "daemon off;"