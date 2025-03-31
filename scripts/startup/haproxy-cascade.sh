#!/bin/bash
# HAProxy cascade proxy startup script

# Initialize tc interface
tc qdisc del dev eth0 root 2>/dev/null || true

# Start HAProxy
haproxy -f /usr/local/etc/haproxy/haproxy.cfg

# Keep container running and capture logs
tail -f /dev/null