# nomad-ami
Packer scripts for building a Nomad AMI for AWS

## Quick start

To build the Nomad AMI:

1. `git clone` this repo to your computer.
1. Install [Packer](https://www.packer.io/).
1. Configure your AWS credentials using one of the [options supported by the AWS 
   SDK](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html). Usually, the easiest option is to
   set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.
1. [Build the Consul AMI](https://github.com/jasonluck/consul-ami) which serves as the source AMI for this AMI.
1. Run `packer build -var 'aws_region=REGION' nomad.json`, where `REGION` is the aws region identifier (such as `us-east-1`).

When the build finishes, it will output the IDs of the new AMIs.

export NOMAD_CAPATH=/opt/nomad/tls/ca.crt.pem; export NOMAD_CLIENT_CERT=/opt/nomad/tls/nomad.crt.pem; export NOMAD_CLIENT_KEY=/opt/nomad/tls/nomad.key.pem; export NOMAD_ADDR='https://127.0.0.1:4646';

export CONSUL_CAPATH=/opt/nomad/tls/ca.crt.pem; export CONSUL_CLIENT_CERT=/opt/nomad/tls/nomad.crt.pem; export CONSUL_CLIENT_KEY=/opt/nomad/tls/nomad.key.pem; export CONSUL_HTTP_SSL=true