FROM ubuntu:22.04

# Install all packages needed for any scenario
RUN apt-get update && \
    apt-get install -y stunnel4 nginx iproute2 openssh-server openssh-client \
    curl iputils-ping iptables netcat-openbsd haproxy && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config

# Setup SSH keys directory
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Create stunnel directory
RUN mkdir -p /etc/stunnel

# Create common directories for volumes
RUN mkdir -p /data /config /shared /scripts

# Default CMD just keeps container running
# This will be overridden in docker-compose with mounted start scripts
CMD ["tail", "-f", "/dev/null"]