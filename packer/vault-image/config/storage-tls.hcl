
storage "consul" {
    scheme = "https"
    tls_ca_file = "/opt/vault/tls/ca.crt.pem"
    tls_cert_file = "/opt/vault/tls/vault.crt.pem"
    tls_key_file = "/opt/vault/tls/vault.key.pem"
}