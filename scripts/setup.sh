#!/bin/bash
# setup.sh - Prepares the environment for Docker-based stunnel testing

# Create necessary directories
mkdir -p config data results scripts shared

# Generate test data files
echo "Generating test data files..."
dd if=/dev/urandom of=data/10MB.bin bs=1M count=10 status=progress
dd if=/dev/urandom of=data/100MB.bin bs=1M count=100 status=progress
dd if=/dev/urandom of=data/1GB.bin bs=1M count=1000 status=progress
echo "Test data files generated."

# Generate TLS certificate
echo "Generating self-signed certificate for stunnel..."
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout config/stunnel.key -out config/stunnel.crt \
  -subj "/CN=localhost" \
  -addext "subjectAltName = DNS:localhost,DNS:tls-server"
cat config/stunnel.key config/stunnel.crt > config/stunnel.pem
chmod 600 config/stunnel.pem
echo "Certificate generated."

# Create stunnel server configuration
cat > config/stunnel-server.conf << EOF
; stunnel server configuration
foreground = yes
pid = /tmp/stunnel-server.pid
debug = 4
output = /shared/stunnel-server.log

[tls-server]
accept = 0.0.0.0:8443
connect = 127.0.0.1:8000
cert = /etc/stunnel/stunnel.pem
ciphers = ECDHE-RSA-AES256-GCM-SHA384
sslVersion = TLSv1.3
EOF

# Create stunnel client configuration
cat > config/stunnel-client.conf << EOF
; stunnel client configuration
foreground = yes
pid = /tmp/stunnel-client.pid
debug = 4
output = /shared/stunnel-client.log

[tls-client]
client = yes
accept = 0.0.0.0:9000
connect = tls-server:8443
ciphers = ECDHE-RSA-AES256-GCM-SHA384
sslVersion = TLSv1.3
EOF

# Create throughput test script
cat > scripts/run_throughput_test.sh << 'EOF'
#!/bin/bash
# Bulk data throughput test script

# Test parameters
FILE_SIZES=("10MB.bin" "100MB.bin" "1GB.bin")
ITERATIONS=3
NETWORK_CONDITIONS=("A" "B" "C")
RESULTS_FILE="/results/throughput_results.csv"

# Create results file with header
echo "network_condition,file_size,iteration,bytes,seconds,mbps" > $RESULTS_FILE

# Apply network condition using tc
apply_network_condition() {
    local condition=$1
    
    # Reset existing rules
    tc qdisc del dev eth0 root 2>/dev/null || true
    
    case $condition in
        "A")
            # Condition A: Low Latency/High Bandwidth
            tc qdisc add dev eth0 root netem delay 10ms rate 1000mbit
            echo "Applied network condition A: 10ms delay, 1Gbps bandwidth"
            ;;
        "B")
            # Condition B: High Latency/Packet Loss
            tc qdisc add dev eth0 root netem delay 100ms 10ms loss 1% rate 100mbit
            echo "Applied network condition B: 100ms delay, 100Mbps bandwidth, 1% loss"
            ;;
        "C")
            # Condition C: Medium Latency
            # For simplicity, we'll use a fixed middle value rather than oscillating
            tc qdisc add dev eth0 root netem delay 30ms rate 250mbit
            echo "Applied network condition C: 30ms delay, 250Mbps bandwidth"
            ;;
    esac
}

# Run throughput test
run_test() {
    local condition=$1
    local file=$2
    local iteration=$3
    local file_path="/data/$file"
    
    # Get file size in bytes
    local file_bytes=$(stat -c%s "$file_path")
    
    echo "Starting test - Condition: $condition, File: $file, Iteration: $iteration"
    
    # Start netcat server on tls-server to serve the file
    # We need to execute this on the server container
    docker exec tls-server bash -c "nc -l -p 8000 < /data/$file" &
    nc_pid=$!
    
    # Wait for netcat to be ready
    sleep 2
    
    # Get start time
    start_time=$(date +%s.%N)
    
    # Download the file via the stunnel tunnel
    curl -s -o /dev/null http://tls-client:9000
    
    # Get end time
    end_time=$(date +%s.%N)
    
    # Calculate elapsed time and throughput
    elapsed=$(echo "$end_time - $start_time" | bc)
    mbps=$(echo "scale=2; $file_bytes * 8 / 1000000 / $elapsed" | bc)
    
    # Store results
    echo "$condition,$file,$iteration,$file_bytes,$elapsed,$mbps" >> $RESULTS_FILE
    
    echo "Test completed - Duration: $elapsed seconds, Throughput: $mbps Mbps"
    
    # Wait before next test
    sleep 2
}

# Main test loop
echo "Starting throughput tests..."

for condition in "${NETWORK_CONDITIONS[@]}"; do
    echo "Setting up network condition $condition"
    apply_network_condition "$condition"
    
    for file in "${FILE_SIZES[@]}"; do
        for (( i=1; i<=$ITERATIONS; i++ )); do
            run_test "$condition" "$file" "$i"
        done
    done
done

echo "All tests completed. Results saved to $RESULTS_FILE"

# Basic analysis of the results
echo -e "\nResults Summary:"
echo "===================="

# Average throughput per file size and network condition
echo -e "\nAverage Throughput (Mbps):"
for condition in "${NETWORK_CONDITIONS[@]}"; do
    echo "Network Condition $condition:"
    for file in "${FILE_SIZES[@]}"; do
        avg=$(grep "$condition,$file" $RESULTS_FILE | awk -F, '{sum+=$6; count++} END {print sum/count}')
        echo "  $file: $avg Mbps"
    done
done

echo -e "\nThroughput test complete!"
EOF

# Make scripts executable
chmod +x scripts/run_throughput_test.sh

echo "Setup complete! You can now run: docker-compose up"
