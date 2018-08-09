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

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks to allow SSH access to the Consul, Vault and Nomad instances."
  type        = "list"
}

variable "consul_gossip_encryption_key" {
  description = "Gossip encryption key for Consul"
}

variable "nomad_gossip_encryption_key" {
  description = "Gossip encryption key for Nomad"
}