# Nginx TCP Proxy with NAT

## Standard TCP Proxy (Port 7200)
Simple TCP forwarding where the upstream server sees the proxy's IP as the source.

## NAT Implementation (Port 7300)

```nginx
server {
    listen 7300;
    proxy_pass tls-server:8000;
    proxy_connect_timeout 1s;
    proxy_timeout 3s;
    proxy_bind $remote_addr transparent; # NAT implementation
}
```

### Configuration Explained:

- `listen 7300` - Port for incoming connections
- `proxy_pass tls-server:8000` - Destination server/port
- `proxy_bind $remote_addr transparent` - The NAT functionality:
  - Uses client's IP as source when connecting to upstream
  - Creates a transparent proxy where original client IP is preserved
  - Requires proper iptables configuration (see start.sh)

The upstream server sees connections from the original client IP, not the proxy's IP.