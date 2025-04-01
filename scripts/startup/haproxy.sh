#!/bin/bash
# HAProxy startup script

# Initialize tc interface (no changes by default)
tc qdisc del dev eth0 root 2>/dev/null || true

# Ensure HAProxy config directory exists
mkdir -p /usr/local/etc/haproxy

# Ensure proper permissions
if [ -f /usr/local/etc/haproxy/haproxy.cfg ]; then
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg
fi

# Start HAProxy
echo "Starting HAProxy TCP proxy on port 7100..."
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg -W -db