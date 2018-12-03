# nomad-ami
Packer scripts for building Consul Server and Consul Client AMIs for AWS

## Quick start

To build the Nomad AMI:

1. `git clone` this repo to your computer.
1. Install [Packer](https://www.packer.io/).
1. Configure your AWS credentials using one of the [options supported by the AWS 
   SDK](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html). Usually, the easiest option is to
   set the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_DEFAULT_REGION` environment variables.
1. Run `packer build consul.json`

When the build finishes, it will output the IDs of the new AMIs.