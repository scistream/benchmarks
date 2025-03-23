#!/bin/bash
# Script to capture network traffic with tcpdump for a specific flow using nsenter

# Usage: ./capture_flows.sh <server> <port> <tls_server_port> [filesize]
# Example: ./capture_flows.sh tls-null 7001 8000 100MB

# Check if required arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <server> <port> <tls_server_port> [filesize]"
    echo "Example: $0 tls-null 7001 8000 100MB"
    echo "Filesize must be one of: 10MB, 100MB, 1GB (default: 10MB)"
    exit 1
fi

SERVER="$1"
PORT="$2"
TLS_SERVER_PORT="$3"
FILESIZE="${4:-10MB}"  # Default to 10MB if not provided

# Validate filesize
if [[ "$FILESIZE" != "10MB" && "$FILESIZE" != "100MB" && "$FILESIZE" != "1GB" ]]; then
    echo "Error: Filesize must be one of: 10MB, 100MB, 1GB"
    echo "Got: $FILESIZE"
    exit 1
fi

# Create directory for captures if it doesn't exist
mkdir -p /hdd/home/decasfl/dev/benchmarks/shared/captures

# Get container PIDs
TLS_SERVER_PID=$(docker inspect --format '{{ .State.Pid }}' tls-server)
SERVER_PID=$(docker inspect --format '{{ .State.Pid }}' "$SERVER")

# Start tcpdump for tls-server flow
echo "Starting tcpdump for tls-server:$TLS_SERVER_PORT flow..."
sudo nsenter -t $TLS_SERVER_PID -n tcpdump -i eth0 -s 0 -e -w /hdd/home/decasfl/dev/benchmarks/shared/captures/tls-server-"$TLS_SERVER_PORT".pcap "port $TLS_SERVER_PORT" &
TCPDUMP1_PID=$!

# Start tcpdump for the specified server and port
echo "Starting tcpdump for $SERVER:$PORT flow..."
sudo nsenter -t $SERVER_PID -n tcpdump -i eth0 -s 0 -e -w /hdd/home/decasfl/dev/benchmarks/shared/captures/"$SERVER"-"$PORT".pcap "port $PORT" &
TCPDUMP2_PID=$!

# Give tcpdump a moment to start
sleep 1

# Make the curl request
echo "Making curl request to http://localhost:$PORT/$FILESIZE.bin..."
time curl -s -o /dev/null http://localhost:$PORT/$FILESIZE.bin

# Wait a few more seconds to capture trailing packets
sleep 5

# Kill tcpdump processes
echo "Stopping tcpdump captures..."
kill $TCPDUMP1_PID
kill $TCPDUMP2_PID

echo "Packet captures complete."
echo "Capture files saved to:"
echo "  - /hdd/home/decasfl/dev/benchmarks/shared/captures/tls-server-$TLS_SERVER_PORT.pcap"
echo "  - /hdd/home/decasfl/dev/benchmarks/shared/captures/$SERVER-$PORT.pcap"