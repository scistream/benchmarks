FROM ubuntu:22.04

# Install required packages
RUN apt-get update && \
    apt-get install -y stunnel4 curl iputils-ping iproute2 netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Create stunnel directory
RUN mkdir -p /etc/stunnel

# Create directories for volumes
RUN mkdir -p /config /shared

# Start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port
EXPOSE 9001

# Start stunnel
CMD ["/start.sh"]