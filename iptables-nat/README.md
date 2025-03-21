# Pure iptables NAT

## Comparison with Nginx NAT

Pure iptables NAT vs Nginx+iptables:
- No application layer involved - all forwarding happens at kernel level
- Lower CPU usage for high volume traffic
- Potentially higher throughput
- Cannot manipulate the traffic content
- No application-level logs