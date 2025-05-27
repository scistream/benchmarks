#!/bin/bash
# Globus Connect Server setup script for Docker containers
set -e

echo "Setting up Globus Connect Server..."

# Configure etcd users and permissions
echo "Configuring etcd..."
etcdctl user add root --new-user-password=globus
etcdctl role add root
etcdctl role grant-permission root --prefix=true readwrite /
etcdctl user grant-role root root

etcdctl user add ubuntu --new-user-password=awai
etcdctl role add client
etcdctl role grant-permission client --prefix=true readwrite /ubuntu
etcdctl user grant-role ubuntu client

etcdctl auth enable

# Start etcd manually (systemd not available in containers)
etcd --listen-client-urls=http://0.0.0.0:2379 --advertise-client-urls=http://0.0.0.0:2379 --data-dir=/var/lib/etcd &
sleep 5  # Wait for etcd to start

# Create Globus identity mapping file
mkdir -p /etc/globus
cat > /etc/globus/map.json << 'EOF'
{
  "DATA_TYPE": "expression_identity_mapping#1.0.0",
  "mappings": [
        {
          "source": "{username}",
          "match": "(.*)@globus\\.org",
          "output": "ubuntu"
        },
        {
          "source": "{username}",
          "match": "(.*)@clients\\.auth\\.globus\\.org",
          "output": "ubuntu"
        }
  ]
}
EOF

# Create Globus GridFTP configuration template
cat > /etc/globus-gridftp-server-awai.conf.template << 'EOF'
{
   "registry_url": "http://${REGISTRY_IP}:2379",
   "advertised_hostname": "${EXTERNAL_IP}",
   "registry_username": "root",
   "registry_password": "globus",
   "use_challenge": 0
}
EOF

echo "Globus setup complete!"
echo ""
echo "Next steps:"
echo "1. Set REGISTRY_IP and EXTERNAL_IP environment variables"
echo "2. Generate actual config: envsubst < /etc/globus-gridftp-server-awai.conf.template > /etc/globus-gridftp-server-awai.conf"
echo "3. Setup endpoint: globus-connect-server endpoint setup 'Your Endpoint Name' --organization 'Your Org' --owner your@email.com --contact-email your@email.com"
echo "4. Setup node: globus-connect-server node setup --ip-address YOUR_IP"
echo "5. Create storage gateway and collection as needed"