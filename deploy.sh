#!/bin/bash
set -euxo pipefail

# Create keys
umask 077
if [ ! -f "server_publickey" ]; then
  wg genkey | tee server_privatekey | wg pubkey > server_publickey
fi
if [ ! -f "client_publickey" ]; then
  wg genkey | tee client_privatekey | wg pubkey > client_publickey
fi

# Setup vars for Terraform interpolation
unset TF_VAR_SERVER_PRIVATEKEY
unset TF_VAR_SERVER_PUBLICKEY
unset TF_VAR_CLIENT_PRIVATEKEY
unset TF_VAR_CLIENT_PUBLICKEY
export TF_VAR_SERVER_PRIVATEKEY=$(cat server_privatekey)
export TF_VAR_SERVER_PUBLICKEY=$(cat server_publickey)
export TF_VAR_CLIENT_PRIVATEKEY=$(cat client_privatekey)
export TF_VAR_CLIENT_PUBLICKEY=$(cat client_publickey)

# Deploy infrastructure
terraform init
terraform apply -auto-approve
terraform output private_key > id_rsa
chmod u+x id_rsa
chmod 600 id_rsa
terraform output client_config > wg0-client.conf

