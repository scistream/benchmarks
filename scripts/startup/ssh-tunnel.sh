#!/bin/bash
# SSH container startup script

# Start SSH server
/usr/sbin/sshd

# Set up SSH keys and config with proper permissions
mkdir -p /root/.ssh
if [ -f /config/ssh/id_rsa ]; then
    cp /config/ssh/id_rsa /root/.ssh/id_rsa
    cp /config/ssh/id_rsa.pub /root/.ssh/id_rsa.pub
    cat /config/ssh/id_rsa.pub > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/id_rsa
    chmod 600 /root/.ssh/authorized_keys
fi

# Copy SSH config from the temporary location and set proper permissions
cp /tmp/ssh_config /root/.ssh/config
chmod 600 /root/.ssh/config
chown root:root /root/.ssh/config

# Initialize tc interface
tc qdisc del dev eth0 root 2>/dev/null || true

# Wait for tls-server to be ready
sleep 5

# Set up SSH tunnel
ssh -f -N -L 0.0.0.0:7000:tls-server:8000 root@tls-server -o StrictHostKeyChecking=no &

# Keep container running
tail -f /dev/null