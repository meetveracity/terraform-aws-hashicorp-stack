# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "ca" {
  algorithm   = "${var.private_key_algorithm}"
  ecdsa_curve = "${var.private_key_ecdsa_curve}"
  rsa_bits    = "${var.private_key_rsa_bits}"

  # Store the CA private key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_private_key.ca.private_key_pem}' > '${var.ca_private_key_file_path}' && chmod ${var.permissions} '${var.ca_private_key_file_path}'"
  }
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = "${tls_private_key.ca.algorithm}"
  private_key_pem   = "${tls_private_key.ca.private_key_pem}"
  is_ca_certificate = true

  validity_period_hours = "${var.validity_period_hours}"
  allowed_uses          = ["${var.ca_allowed_uses}"]

  subject {
    common_name  = "${var.ca_common_name}"
    organization = "${var.organization_name}"
  }

  # Store the CA public key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_self_signed_cert.ca.cert_pem}' > '${var.ca_public_key_file_path}' && chmod ${var.permissions} '${var.ca_public_key_file_path}'"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE TLS CERTIFICATES SIGNED USING THE CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

################### CONSUL ########################
resource "tls_private_key" "consul" {
  algorithm   = "${var.private_key_algorithm}"
  ecdsa_curve = "${var.private_key_ecdsa_curve}"
  rsa_bits    = "${var.private_key_rsa_bits}"

  # Store the certificate's private key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_private_key.consul.private_key_pem}' > '${var.private_key_folder}/consul.key.pem' && chmod ${var.permissions} '${var.private_key_folder}/consul.key.pem'"
  }
}

resource "tls_cert_request" "consul" {
  key_algorithm   = "${tls_private_key.consul.algorithm}"
  private_key_pem = "${tls_private_key.consul.private_key_pem}"

  dns_names    = ["consul.service.consul"]
  ip_addresses = ["127.0.0.1"]

  subject {
    common_name  = "consul.${var.organization_name}"
    organization = "${var.organization_name}"
  }
}

resource "tls_locally_signed_cert" "consul" {
  cert_request_pem = "${tls_cert_request.consul.cert_request_pem}"

  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = "${var.validity_period_hours}"
  allowed_uses          = ["${var.allowed_uses}"]

  # Store the certificate's public key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_locally_signed_cert.consul.cert_pem}' > '${var.public_key_folder}/consul.crt.pem' && chmod ${var.permissions} '${var.public_key_folder}/consul.crt.pem'"
  }
}

################### VAULT ########################
resource "tls_private_key" "vault" {
  algorithm   = "${var.private_key_algorithm}"
  ecdsa_curve = "${var.private_key_ecdsa_curve}"
  rsa_bits    = "${var.private_key_rsa_bits}"

  # Store the certificate's private key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_private_key.vault.private_key_pem}' > '${var.private_key_folder}/vault.key.pem' && chmod ${var.permissions} '${var.private_key_folder}/vault.key.pem'"
  }
}

resource "tls_cert_request" "vault" {
  key_algorithm   = "${tls_private_key.vault.algorithm}"
  private_key_pem = "${tls_private_key.vault.private_key_pem}"

  dns_names    = ["vault.service.consul"]
  ip_addresses = ["127.0.0.1"]

  subject {
    common_name  = "vault.${var.organization_name}"
    organization = "${var.organization_name}"
  }
}

resource "tls_locally_signed_cert" "vault" {
  cert_request_pem = "${tls_cert_request.vault.cert_request_pem}"

  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = "${var.validity_period_hours}"
  allowed_uses          = ["${var.allowed_uses}"]

  # Store the certificate's public key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_locally_signed_cert.vault.cert_pem}' > '${var.public_key_folder}/vault.crt.pem' && chmod ${var.permissions} '${var.public_key_folder}/vault.crt.pem'"
  }
}

################### NOMAD ########################
resource "tls_private_key" "nomad" {
  algorithm   = "${var.private_key_algorithm}"
  ecdsa_curve = "${var.private_key_ecdsa_curve}"
  rsa_bits    = "${var.private_key_rsa_bits}"

  # Store the certificate's private key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_private_key.nomad.private_key_pem}' > '${var.private_key_folder}/nomad.key.pem' && chmod ${var.permissions} '${var.private_key_folder}/nomad.key.pem'"
  }
}

resource "tls_cert_request" "nomad" {
  key_algorithm   = "${tls_private_key.nomad.algorithm}"
  private_key_pem = "${tls_private_key.nomad.private_key_pem}"

  dns_names    = ["nomad.service.consul"]
  ip_addresses = ["127.0.0.1"]

  subject {
    common_name  = "nomad.${var.organization_name}"
    organization = "${var.organization_name}"
  }
}

resource "tls_locally_signed_cert" "nomad" {
  cert_request_pem = "${tls_cert_request.nomad.cert_request_pem}"

  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = "${var.validity_period_hours}"
  allowed_uses          = ["${var.allowed_uses}"]

  # Store the certificate's public key in a file.
  provisioner "local-exec" {
    command = "echo '${tls_locally_signed_cert.nomad.cert_pem}' > '${var.public_key_folder}/nomad.crt.pem' && chmod ${var.permissions} '${var.public_key_folder}/nomad.crt.pem'"
  }
}