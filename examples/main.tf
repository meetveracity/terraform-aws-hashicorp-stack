data "aws_ami" "consul" {
  most_recent = true
  owners      = ["${var.owner}"]

  filter {
    name   = "name"
    values = ["consul-amzn-linux-*"]
  }
}

data "aws_ami" "vault_consul" {
  most_recent = true
  owners      = ["${var.owner}"]

  filter {
    name   = "name"
    values = ["vault-consul-amzn-linux-*"]
  }
}

data "aws_ami" "nomad_consul" {
  most_recent = true
  owners      = ["${var.owner}"]

  filter {
    name   = "name"
    values = ["nomad-consul-amazon-linux-*"]
  }
}

data "aws_region" "current" {}

module "hashistack" {
    source = "../modules"

    name = "hashistack"
    vpc_id = "${var.vpc_id}"
    subnet_ids = "${var.subnet_ids}"
    owner = "self"
    ssh_key_name = "${var.ssh_key_name}"
    s3_bucket_name = "hashistack-vault-backend"
    allowed_ssh_cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]
    allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
    aws_region = "${data.aws_region.current.name}"

    consul_ami_id = "${data.aws_ami.consul.id}"
    vault_ami_id = "${data.aws_ami.vault_consul.id}"
    nomad_ami_id = "${data.aws_ami.nomad_consul.id}"

    consul_enable_gossip_encryption = true
    consul_gossip_encryption_key = "${var.consul_gossip_encryption_key}"
}
