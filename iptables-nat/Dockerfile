FROM ubuntu:22.04

# Install required packages
RUN apt-get update && \
    apt-get install -y iptables iproute2 iputils-ping curl && \
    rm -rf /var/lib/apt/lists/*

# Create directories for volumes
RUN mkdir -p /shared

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose proxy port
EXPOSE 7400

# Start services
CMD ["/start.sh"]