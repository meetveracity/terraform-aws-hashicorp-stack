# ---------------------------------------------------------------------------------------------------------------------
# HASHICORP STACK
# This environment consists of:
# - Consul Cluster (Handles service discovery, health check, DNS and HA backend for Vault)
# - Vault Cluster  (Secret Storage)
# - Nomad Cluster  (Task Scheduler with Docker worker nodes for executing containers)
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {}

terraform {
  required_version = ">= 0.11.0"
}