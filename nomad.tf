# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------
data "aws_ami" "nomad_consul" {
  count       = "${length(var.nomad_ami_id) >= 1 ? 0 : 1}"
  most_recent = true

  filter {
    name   = "name"
    values = ["nomad-consul-amazon-linux-*"]
  }
}

module "nomad_servers" {
  source = "github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=${var.nomad_module_version}"

  cluster_name  = "${var.nomad_cluster_name}-server"
  instance_type = "${var.nomad_server_instance_type}"

  # You should typically use a fixed size of 3 or 5 for your Nomad server cluster
  min_size         = "${var.nomad_server_size}"
  max_size         = "${var.nomad_server_size}"
  desired_capacity = "${var.nomad_server_size}"

  ami_id    = "${var.nomad_ami_id == "" ? data.aws_ami.nomad_consul.image_id : var.nomad_ami_id}"
  user_data = "${data.template_file.user_data_nomad_server.rendered}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["${var.subnet_ids}"]
  allowed_ssh_cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]
  allowed_inbound_cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]
  ssh_key_name                = "${aws_key_pair.auth.key_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our server Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_nomad_servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v${var.consul_module_version}"

  iam_role_id = "${module.nomad_servers.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH NOMAD SERVER NODE WHEN IT'S BOOTING
# This script will configure and start Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_nomad_server" {
  template = "${file("${path.module}/scripts/user-data-nomad-server.sh")}"

  vars {
    num_servers       = "${var.nomad_server_size}"
    cluster_tag_key   = "${module.consul_cluster.cluster_tag_key}"
    cluster_tag_value = "${module.consul_cluster.cluster_tag_value}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD CLIENT NODES
# ---------------------------------------------------------------------------------------------------------------------

module "nomad_clients" {
  source = "github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=${var.nomad_module_version}"

  cluster_name  = "${var.nomad_cluster_name}-client"
  instance_type = "${var.nomad_client_instance_type}"

  # Give the clients a different tag so they don't try to join the server cluster
  cluster_tag_key   = "nomad-clients"
  cluster_tag_value = "${var.nomad_cluster_name}"

  min_size         = "${var.nomad_client_size}"
  max_size         = "${var.nomad_client_size}"
  desired_capacity = "${var.nomad_client_size}"
  ami_id    = "${var.nomad_ami_id == "" ? data.aws_ami.nomad_consul.image_id : var.nomad_ami_id}"
  user_data = "${data.template_file.user_data_nomad_client.rendered}"
  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["${var.subnet_ids}"]
  allowed_ssh_cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]
  allowed_inbound_cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]
  ssh_key_name                = "${aws_key_pair.auth.key_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_nomad_clients" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=${var.consul_module_version}"

  iam_role_id = "${module.nomad_clients.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CLIENT NODE WHEN IT'S BOOTING
# This script will configure and start Consul and Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_nomad_client" {
  template = "${file("${path.module}/scripts/user-data-nomad-client.sh")}"

  vars {
    cluster_tag_key   = "${module.consul_cluster.cluster_tag_key}"
    cluster_tag_value = "${module.consul_cluster.cluster_tag_value}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# NOMAD SERVER ELB
# Provide an endpoint for users to connect to the Nomad UI interface
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elb" "nomad" {
  name = "${var.nomad_cluster_name}"

  internal                    = "true"
  cross_zone_load_balancing   = "true"
  idle_timeout                = "60"
  connection_draining         = "true"
  connection_draining_timeout = "300"

  security_groups = ["${aws_security_group.nomad_elb.id}"]
  subnets         = ["${var.subnet_ids}"]

  # Run the ELB in TCP passthrough mode
  listener {
    lb_port           = "80"
    lb_protocol       = "TCP"
    instance_port     = "4646"
    instance_protocol = "TCP"
  }

  health_check {
    target              = "HTTP:4646/ui/"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags {
    Name = "${var.nomad_cluster_name}"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_nomad_elb" {
  autoscaling_group_name = "${module.nomad_servers.asg_name}"
  elb                    = "${aws_elb.nomad.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW ELB ACCESS TO NOMAD SERVERS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_inbound_from_elb" {
  type                     = "ingress"
  from_port                = "4646"
  to_port                  = "4646"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.nomad_elb.id}"

  security_group_id = "${module.nomad_servers.security_group_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN GO IN AND OUT OF THE ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "nomad_elb" {
  name        = "nomad-elb"
  description = "Security group for the nomad ELB"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_inbound_http" {
  type        = "ingress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"