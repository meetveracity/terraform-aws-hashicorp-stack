# Private TLS Cert

This module can be used to generate a Certificate Authority (CA) public key and the public and private keys of a 
TLS certificate signed by this CA. This certificate is meant to be used with **private** services, such as a Vault 
cluster accessed solely within your AWS account. For publicly-accessible services, especially services you access 
through a web browser, you should NOT use this module, and instead get certificates from a commercial Certificate 
Authority, such as [Let's Encrypt](https://letsencrypt.org/).

## Quick start

1. Copy this module to your computer.

1. Open `variables.tf` and fill in the variables that do not have a default.

1. DO NOT configure Terraform remote state storage for this code. You do NOT want to store the state files as they 
   will contain the private keys for the certificates.

1. Run `terraform apply`. The output will show you the paths to the generated files:

    ```
    Outputs:
    
    ca_public_key_file_path = ca.key.pem
    private_key_file_path = vault.key.pem
    public_key_file_path = vault.crt.pem
    ```
    
1. Delete your local Terraform state:

    ```
    rm -rf terraform.tfstate*
    ```

   The Terraform state will contain the private keys for the certificates, so it's important to clean it up!

1. To inspect a certificate, you can use OpenSSL:

    ```
    openssl x509 -inform pem -noout -text -in vault.crt.pem
    ```