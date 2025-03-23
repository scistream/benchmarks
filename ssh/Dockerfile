FROM ubuntu:22.04

# Install required packages
RUN apt-get update && \
    apt-get install -y openssh-server openssh-client curl iputils-ping iproute2 netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config

# Setup SSH keys
RUN mkdir -p /root/.ssh
COPY ssh_config /root/.ssh/config

# Create directories for volumes
RUN mkdir -p /config /shared

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose SSH port and tunnel ports
EXPOSE 22 7000 7443

# Start SSH server and tunnels
CMD ["/start.sh"]