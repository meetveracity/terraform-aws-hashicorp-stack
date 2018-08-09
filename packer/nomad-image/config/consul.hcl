# Enable TLS for Consul communications
consul {
  ssl = true
  ca_file = "/opt/nomad/tls/ca.crt.pem"
  cert_file = "/opt/nomad/tls/nomad.crt.pem"
  key_file = "/opt/nomad/tls/nomad.key.pem"
}