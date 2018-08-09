#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and the run-nomad script to configure and start Nomad
# in client mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/nomad-consul-ami/nomad-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Configure Gossip Encryption for Nomad
cat > "/opt/nomad/config/encryption.hcl" <<EOF
server {
  encrypt = "${nomad_gossip_encryption_key}"
}
EOF
chown nomad:nomad "/opt/nomad/config/encryption.hcl"

# These variables are passed in via Terraform template interplation
/opt/consul/bin/run-consul --client --cluster-tag-key "${consul_cluster_tag_key}" \
    --cluster-tag-value "${consul_cluster_tag_value}" \
    --enable-gossip-encryption \
    --gossip-encryption-key "${consul_gossip_encryption_key}" \
    --enable-rpc-encryption \
    --ca-path "/opt/consul/tls/ca/ca.crt.pem" \
    --cert-file-path "/opt/consul/tls/consul.crt.pem" \
    --key-file-path "/opt/consul/tls/consul.key.pem"
/opt/nomad/bin/run-nomad --client