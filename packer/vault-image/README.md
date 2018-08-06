# Vault and Consul AMI

This folder shows an example of how to use the [install-vault module](https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/install-vault) from this Module and 
the [install-consul](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/install-consul)
and [install-dnsmasq](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/install-dnsmasq) modules
from the Consul AWS Module with [Packer](https://www.packer.io/) to create [Amazon Machine Images 
(AMIs)](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) that have Vault and Consul installed on top of:

* Amazon Linux

You can use this AMI to deploy a [Vault cluster](https://www.vaultproject.io/) by using the [vault-cluster
module](https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/vault-cluster). This Vault cluster will use Consul as its storage backend, so you can also use the 
same AMI to deploy a separate [Consul server cluster](https://www.consul.io/) by using the [consul-cluster 
module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/consul-cluster).

## Quick start

To build the Vault and Consul AMI:

1. `git clone` this repo to your computer.

1. Install [Packer](https://www.packer.io/).

1. Configure your AWS credentials using one of the [options supported by the AWS 
   SDK](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html). Usually, the easiest option is to
   set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

1. Use the [private-tls-cert module](https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/private-tls-cert) to generate a CA cert and public and private keys for a 
   TLS cert: 
   
    1. Set the `dns_names` parameter to `vault.service.consul`. If you're using the [vault-cluster-public
       example](https://github.com/hashicorp/terraform-aws-vault/tree/master/examples/vault-cluster-public) and want a public domain name (e.g. `vault.example.com`), add that 
       domain name here too.
    1. Set the `ip_addresses` to `127.0.0.1`. 
    1. For production usage, you should take care to protect the private key by encrypting it (see [Using TLS 
       certs](https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/private-tls-cert#using-tls-certs) for more info). 

1. Update the `variables` section of the `vault-consul.json` Packer template to specify the AWS region, Vault 
   version, Consul version, and the paths to the TLS cert files you just generated. 

1. Run `packer build -var 'aws_region=REGION' vault-consul.json`, where `REGION` is the aws region identifier (such as `us-east-1`).

When the build finishes, it will output the IDs of the new AMIs. 