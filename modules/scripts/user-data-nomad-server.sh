#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and then the run-nomad script to configure and start
# Nomad in server mode. Note that this script assumes it's running in an AMI built from the Packer template in
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

if [ "${vault_token}" != "" ]; then
cat > '/opt/nomad/config/vault.hcl' <<EOF
# In order to for Vault integration to be complete,
# the VAULT_TOKEN environment variable needs to be set on
# the Nomad server instances. The token is not needed on clients.

vault {
  enabled = true
  address = "https://vault.service.consul:8200"

  ca_file   = "/opt/nomad/tls/ca.crt.pem"
  cert_file = "/opt/nomad/tls/nomad.crt.pem"
  key_file  = "/opt/nomad/tls/nomad.key.pem"

  # Setting the create_from_role option causes Nomad to create tokens for tasks
  # via the provided role. This allows the role to manage what policies are
  # allowed and disallowed for use by tasks.
  create_from_role = "${vault_role}"
}
EOF

ENV_VARS="--environment VAULT_TOKEN=${vault_token}"
fi

/opt/consul/bin/run-consul --client --cluster-tag-key "${consul_cluster_tag_key}" \
    --cluster-tag-value "${consul_cluster_tag_value}" \
    --enable-gossip-encryption \
    --gossip-encryption-key "${consul_gossip_encryption_key}" \
    --enable-rpc-encryption \
    --ca-path "/opt/consul/tls/ca/ca.crt.pem" \
    --cert-file-path "/opt/consul/tls/consul.crt.pem" \
    --key-file-path "/opt/consul/tls/consul.key.pem"
/opt/nomad/bin/run-nomad --server --num-servers "${num_servers}" $$ENV_VARS