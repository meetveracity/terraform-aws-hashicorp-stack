# Nomad instances should leave the cluster gracefully on interuption or termination.
# This keeps instances that have been terminated from sticking around as dead cluster members
leave_on_interrupt  = true
leave_on_terminate = true


tls {
  # Enable encryption on incoming HTTP and RPC endpoints
  http = true
  rpc  = true
  
  # Verify server hostname for outgoing TLS connections
  # Unlike traditional HTTPS browser validation, all servers must have a certificate valid for 
  # server.<region>.nomad or the client will reject the handshake.
  verify_server_hostname = true

  # Specify the CA and signing key paths
  ca_file   = "/opt/nomad/tls/ca.crt.pem"
  cert_file = "/opt/nomad/tls/nomad.crt.pem"
  key_file  = "/opt/nomad/tls/nomad.key.pem"
}