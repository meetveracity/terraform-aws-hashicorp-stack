# terraform-aws-hashicorp-stack
Terraform module for provisioning the Hashicorp stack in AWS. The stack includes Consul, Vault and Nomad.

## Tools
To use this module you will need the following tool installed:
* [Packer](https://www.packer.io/intro/getting-started/install.html#precompiled-binaries)
* [Terraform](https://www.terraform.io/intro/getting-started/install.html)

## Building the Machine Images
To build the machine images, start off by creating TLS certificates to be used by the Hashistack services.
Follow the [instructions here](packer/tls/README.md) to generate your TLS certificates

To build the AMIs used by this module, set the following environment variables used by the [Amazon AMI Builder](https://www.packer.io/docs/builders/amazon.html) with valid values for your AWS account. Then simply execute the packer builds.
```bash
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-gov-west-1"
packer build packer/consul-image/consul.json
packer build packer/vault-image/vault.json
packer build packer/nomad-image/nomad.json
```

## Deploying the Stack

## Securing the Stack


