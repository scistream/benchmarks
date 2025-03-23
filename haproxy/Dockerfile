FROM haproxy:2.6

# Install additional tools
RUN apt-get update && \
    apt-get install -y iproute2 iputils-ping curl netcat-openbsd && \
    rm -rf /var/lib/apt/lists/* || true

# Create directories for volumes
RUN mkdir -p /config /shared

# Copy configuration and startup script
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose proxy port
EXPOSE 7100

# Start HAProxy
CMD ["/start.sh"]