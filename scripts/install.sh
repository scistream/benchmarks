#!/bin/bash
# Install dependencies for the unified image
set -e

# Update package repositories
apt-get update

# Install all required packages
apt-get install -y \
  stunnel4 \
  nginx \
  iproute2 \
  openssh-server \
  openssh-client \
  curl \
  iputils-ping \
  iptables \
  netcat-openbsd \
  haproxy

# Configure SSH
mkdir -p /var/run/sshd
echo 'root:password' | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config

# Setup SSH keys directory
mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Create stunnel directory
mkdir -p /etc/stunnel

# Create common directories
mkdir -p /data /config /shared /scripts

echo "Installation of unified image dependencies complete!"