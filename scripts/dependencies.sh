#!/bin/bash
# Install Docker and Docker Compose on Ubuntu
set -e

# Install Docker and Docker Compose
apt-get update
apt-get install -y docker.io docker-compose

# Add current user to docker group
usermod -aG docker ${USER}

echo "Installation complete! Log out and log back in for group changes to take effect."