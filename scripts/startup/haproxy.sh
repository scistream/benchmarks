#!/bin/bash
# HAProxy startup script

# Initialize tc interface (no changes by default)
tc qdisc del dev eth0 root 2>/dev/null || true

# Start HAProxy
echo "Starting HAProxy TCP proxy on port 7100..."
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg -W -db