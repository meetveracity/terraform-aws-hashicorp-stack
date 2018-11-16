provider "vault" {
  # VAULT_ADDR and VAULT_TOKEN must be set in the environment
}

################# Nomad Configuration ################
resource "vault_policy" "nomad-server" {
  name = "nomad-cluster"

  policy = "${file("${path.module}/policies/nomad.hcl")}"
}

resource "vault_token_auth_backend_role" "nomad-cluster" {
  role_name           = "nomad-cluster"
  disallowed_policies = ["nomad-server"]
  orphan              = true
  period              = "259200"
  renewable           = true
}