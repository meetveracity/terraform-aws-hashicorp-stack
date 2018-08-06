# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
    description = "Unique identifier for this instace of the stack"
}

variable "vpc_id" {
  description = "ID for the VPC"
}

variable "subnet_ids" {
  description = "List of IDs for the subnets to deploy instances into. These subnets should be spread across multiple availability zones."
  type        = "list"
}

variable "owner" {
  description = "AMI Owner"
}

variable "ssh_key_name" {
  description = "Desired name of AWS key pair to use for SSH authentication"
}

variable "s3_bucket_name" {
  description = "The name of an S3 bucket to create and use as a storage backend for Vault. Note: S3 bucket names must be *globally* unique."
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks to allow SSH access to the Consul, Vault and Nomad instances."
  type = "list"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "allowed_inbound_cidr_blocks" {
  description = "List of CIDR blocks to allow access to the Consul, Vault and Nomad instances."
  type = "list"
  default = []
}

variable "allowed_inbound_security_group_ids" {
  description = "List of security groups to allow access to the Consul, Vault and Nomad instances."
  type = "list"
  default = []
}

variable "consul_ami_id" {
  description = "Id of the consul AMI to use. If left blank, default to the latest AMI named consul-amzn-linux-*"
  default     = ""
}

variable "vault_ami_id" {
  description = "Id of the vault AMI to use. If left blank, default to the latest AMI named vault-consul-amzn-linux-*"
  default     = ""
}

variable "nomad_ami_id" {
  description = "Id of the Nomad AMI to use. If left blank, default to the latest AMI named nomad-consul-amazon-linux-*"
  default     = ""
}

variable "nomad_server_size" {
  description = "The number of Nomad server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "nomad_client_size" {
  description = "The number of Nomad client nodes to deploy."
  default     = 4
}

variable "vault_cluster_size" {
  description = "The number of Vault server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "consul_cluster_size" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "vault_instance_type" {
  description = "The type of EC2 Instance to run in the Vault ASG"
  default     = "t2.micro"
}

variable "consul_instance_type" {
  description = "The type of EC2 Instance to run in the Consul ASG"
  default     = "t2.micro"
}

variable "nomad_server_instance_type" {
  description = "The type of EC2 Instance to run in the Nomad Server ASG"
  default     = "t2.micro"
}

variable "nomad_client_instance_type" {
  description = "The type of EC2 Instance to run in the Nomad Client ASG"
  default     = "t2.micro"
}

variable "consul_cluster_name" {
  description = "Name of the consul cluster. This should be unique."
  default     = "consul-${var.name}"
}

variable "consul_cluster_tag_key" {
  description = "The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster."
  default     = "consul-servers"
}

variable "force_destroy_s3_bucket" {
  description = "If you set this to true, when you run terraform destroy, this tells Terraform to delete all the objects in the S3 bucket used for backend storage. You should NOT set this to true in production or you risk losing all your data! This property is only here so automated tests of this module can clean up after themselves."
  default     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# SUB-MODULE VERSION PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "consul_module_version" {
  description = "Version of the Consul AWS Terraform module to use"
  default     = "v0.3.5"
}

variable "vault_module_version" {
  description = "Version of the Vault AWS Terraform module to use"
  default     = "v0.8.0"
}

variable "nomad_module_version" {
  description = "Version of the Nomad AWS Terraform module to use"
  default     = "v0.4.2"
}