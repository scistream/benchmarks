FROM ubuntu:22.04

# Install required packages
RUN apt-get update && \
    apt-get install -y stunnel4 nginx iproute2 openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Setup SSH keys directory
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Create stunnel directory
RUN mkdir -p /etc/stunnel

# Create directories for volumes
RUN mkdir -p /data /config /shared

# Start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose ports
EXPOSE 8000 8443 22

# Start stunnel and nginx
CMD ["/start.sh"]