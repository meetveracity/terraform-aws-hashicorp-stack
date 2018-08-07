data "aws_ami" "consul" {
  count       = "${length(var.consul_ami_id) >= 1 ? 0 : 1}"
  most_recent = true

  owners = ["${var.owner}"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["consul-amzn-linux-*"]
  }
}

data "aws_ami" "vault_consul" {
  count       = "${length(var.vault_ami_id) >= 1 ? 0 : 1}"
  most_recent = true

  owners = ["${var.owner}"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["vault-consul-amzn-linux-*"]
  }
}

data "aws_ami" "nomad_consul" {
  count       = "${length(var.nomad_ami_id) >= 1 ? 0 : 1}"
  most_recent = true

  filter {
    name   = "name"
    values = ["nomad-consul-amazon-linux-*"]
  }
}