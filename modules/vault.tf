# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A VAULT CLUSTER IN AWS
# These templates show an example of how to use the vault-consul-cluster module to deploy Vault in AWS. We deploy two Auto
# Scaling Groups (ASGs): one with a small number of Consul server nodes and one with a larger number of Consul client
# nodes. Note that these templates assume that the AMI you provide via the ami_id input variable is built from
# the [consul-ami](https://github.com/jasonluck/consul-ami) Packer template.
# ---------------------------------------------------------------------------------------------------------------------

module "vault_cluster" {
  source = "github.com/hashicorp/terraform-aws-vault.git//modules/vault-cluster?ref=v0.9.1"

  cluster_name  = "vault-${var.name}"
  cluster_size  = "${var.vault_cluster_size}"
  instance_type = "${var.vault_instance_type}"

  ami_id    = "${var.vault_ami_id}"
  user_data = "${data.template_file.user_data_vault_cluster.rendered}"

  s3_bucket_name          = "${var.s3_bucket_name}"
  force_destroy_s3_bucket = "${var.force_destroy_s3_bucket}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["${var.subnet_ids}"]

  # Do NOT use the ELB for the ASG health check, or the ASG will assume all sealed instances are unhealthy and
  # repeatedly try to redeploy them.
  health_check_type = "EC2"

  allowed_ssh_cidr_blocks              = ["${var.allowed_ssh_cidr_blocks}"]
  allowed_inbound_cidr_blocks          = ["${var.allowed_inbound_cidr_blocks}"]
  allowed_inbound_security_group_ids   = ["${var.allowed_inbound_security_group_ids}"]
  allowed_inbound_security_group_count = "${length(var.allowed_inbound_security_group_ids)}"
  ssh_key_name                         = "${var.ssh_key_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our Vault servers to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.3.5"

  iam_role_id = "${module.vault_cluster.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH VAULT SERVER WHEN IT'S BOOTING
# This script will configure and start Vault
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/scripts/user-data-vault.sh")}"

  vars {
    aws_region               = "${var.aws_region}"
    s3_bucket_name           = "${var.s3_bucket_name}"
    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "consul-${var.name}"
    enable_gossip_encryption = "${var.consul_enable_gossip_encryption}"
    gossip_encryption_key = "${var.consul_gossip_encryption_key}"
    enable_rpc_encryption = "${var.consul_enable_rpc_encryption}"
  }
}
