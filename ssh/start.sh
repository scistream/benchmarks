#!/bin/bash
# SSH container startup script

# Start SSH server
/usr/sbin/sshd

# Generate SSH key pair for external connections if not exist
if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# Set up trust with tls-server
echo "Setting up SSH trust with tls-server..."
# Wait for tls-server to be ready
sleep 5
# Copy SSH key to tls-server - tls-server might not be set up for SSH, this is just for demonstration
ssh-copy-id -o StrictHostKeyChecking=no root@tls-server 2>/dev/null || 
  echo "Note: SSH key setup with tls-server failed. This is OK if tls-server doesn't run SSH."

# Initialize tc interface (no changes by default)
tc qdisc del dev eth0 root 2>/dev/null || true

# Set up SSH tunnel
echo "Setting up SSH port forwarding tunnel..."

# Forward from port 7000 to tls-server:8000 (direct access to nginx)
ssh -f -N -L 0.0.0.0:7000:tls-server:8000 root@tls-server &
echo "SSH tunnel established: localhost:7000 -> tls-server:8000 (nginx)"

# Enable SSH tunnel from outside the container to tls-server:8000 on port 7500
echo "To establish an SSH tunnel from your host system to tls-server, use:"
echo "ssh -L 7500:tls-server:8000 root@localhost -p 2222"
echo "This will forward localhost:7500 -> tls-server:8000 (nginx)"

# To tunnel via tls-server from outside, use:
echo "For tunneling via tls-server from your host system, use:"
echo "ssh -J root@localhost:2222 -L 7600:localhost:8000 root@tls-server"
echo "This will forward localhost:7600 -> tls-server:8000 (nginx) via SSH jump host"

# Output status
echo "SSH port forwarding container started"
echo "- Access to web server via SSH tunnel: port 7000"
echo "  (This provides an SSH tunnel alternative to the stunnel TLS tunnel)"
echo "Traffic Control (tc) available for network simulation"

# Keep container running
tail -f /dev/null