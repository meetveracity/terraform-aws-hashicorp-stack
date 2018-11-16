# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A CONSUL CLUSTER IN AWS
# These templates show an example of how to use the consul-cluster module to deploy Consul in AWS. We deploy two Auto
# Scaling Groups (ASGs): one with a small number of Consul server nodes and one with a larger number of Consul client
# nodes. Note that these templates assume that the AMI you provide via the ami_id input variable is built from
# the [consul-image](https://github.com/meetveracity/consul-image) Packer template.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_cluster" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.3.5"

  vpc_id        = "${var.vpc_id}"
  subnet_ids    = ["${var.subnet_ids}"]
  ssh_key_name  = "${var.ssh_key_name}"
  ami_id        = "${var.consul_ami_id}"
  instance_type = "${var.consul_instance_type}"

  allowed_inbound_cidr_blocks        = ["${var.allowed_inbound_cidr_blocks}"]
  allowed_inbound_security_group_ids = ["${var.allowed_inbound_security_group_ids}"]
  allowed_ssh_cidr_blocks            = ["${var.allowed_ssh_cidr_blocks}"]

  cluster_name      = "consul-${var.name}"
  cluster_tag_key   = "${var.consul_cluster_tag_key}"
  cluster_tag_value = "consul-${var.name}"
  cluster_size      = "${var.consul_cluster_size}"

  user_data = "${data.template_file.user_data_consul.rendered}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER WHEN IT'S BOOTING
# This script will configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_consul" {
  template = "${file("${path.module}/scripts/user-data-consul.sh")}"

  vars {
    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "consul-${var.name}"
    enable_gossip_encryption = "${var.consul_enable_gossip_encryption}"
    gossip_encryption_key = "${var.consul_gossip_encryption_key}"
    enable_rpc_encryption = "${var.consul_enable_rpc_encryption}"
  }
}
