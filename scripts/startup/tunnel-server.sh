#!/bin/bash
# Tunnel server startup script

# Copy stunnel configurations
cp /config/stunnel-server.conf /etc/stunnel/stunnel.conf
cp /config/stunnel-server-null.conf /etc/stunnel/stunnel-null.conf
cp /config/stunnel.pem /etc/stunnel/
chmod 600 /etc/stunnel/stunnel.pem

# Initialize tc interface
tc qdisc del dev eth0 root 2>/dev/null || true

# Setup SSH keys from config directory
mkdir -p /root/.ssh
if [ -f /config/ssh/id_rsa.pub ]; then
    cat /config/ssh/id_rsa.pub > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# Start services
stunnel4 # Start standard stunnel
stunnel4 /etc/stunnel/stunnel-null.conf # Start stunnel with NULL cipher
/usr/sbin/sshd # Start SSH server

# Keep container running and monitor logs
tail -f /shared/stunnel-server.log /shared/stunnel-server-null.log