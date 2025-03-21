#!/bin/bash
# Server startup script

# Copy stunnel configurations
cp /config/stunnel-server.conf /etc/stunnel/stunnel.conf
cp /config/stunnel-server-null.conf /etc/stunnel/stunnel-null.conf
cp /config/stunnel.pem /etc/stunnel/
chmod 600 /etc/stunnel/stunnel.pem

# Setup nginx with the provided config
ln -sf /config/nginx-server.conf /etc/nginx/sites-available/fileserver
ln -sf /etc/nginx/sites-available/fileserver /etc/nginx/sites-enabled/default

# Initialize tc interface (no changes by default)
tc qdisc del dev eth0 root 2>/dev/null || true

# Setup authorized_keys file for SSH access
mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Start services
service nginx start
stunnel4 # Start standard stunnel
stunnel4 /etc/stunnel/stunnel-null.conf # Start stunnel with NULL cipher
/usr/sbin/sshd # Start SSH server

# Output status
echo "Nginx started. Serving files from /data on port 8000"
echo "Stunnel started. Forwarding from port 8443 to 8000"
echo "Traffic Control (tc) available for network simulation"

# Keep container running and monitor logs
tail -f /var/log/nginx/access.log /var/log/nginx/error.log /shared/stunnel-server.log