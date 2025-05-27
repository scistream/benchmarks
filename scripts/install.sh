#!/bin/bash
# Install dependencies for the unified image
set -e

# Update package repositories
apt-get update

# Install curl first
apt-get install -y curl

# Install Globus repository
curl -LOs https://downloads.globus.org/globus-connect-server/stable/installers/repo/deb/globus-repo_latest_all.deb
dpkg -i globus-repo_latest_all.deb

# Add Globus development repository
echo 'deb [signed-by=/usr/share/globus-repo/GPG-KEY-Globus.gpg,/usr/share/globus-repo/GPG-KEY-Globus-2024.gpg] https://downloads.globus.org/development/epic/41627/deb noble contrib' > /etc/apt/sources.list.d/tunnels.list

# Update package repositories again after adding Globus repo
apt-get update

# Install all required packages including Globus
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
  haproxy \
  iperf3 \
  netperf \
  nuttcp \
  iperf \
  globus-connect-server54 \
  etcd-client \
  etcd-server

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