FROM nginx:1.22

# Install additional tools
RUN apt-get update && \
    apt-get install -y iproute2 iputils-ping curl iptables netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Create directories for volumes
RUN mkdir -p /config /shared

# Copy configuration and startup script
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose proxy port
EXPOSE 7200

# Start Nginx
CMD ["/start.sh"]