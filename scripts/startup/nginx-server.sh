#!/bin/bash
# Nginx server startup script

# Setup nginx with the provided config
ln -sf /config/nginx-server.conf /etc/nginx/sites-available/fileserver
ln -sf /etc/nginx/sites-available/fileserver /etc/nginx/sites-enabled/default

# Initialize tc interface
tc qdisc del dev eth0 root 2>/dev/null || true

# Start services
service nginx start

# Keep container running and monitor logs
tail -f /var/log/nginx/access.log /var/log/nginx/error.log