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
TF_VAR_SERVER_PRIVATEKEY=$(cat server_privatekey)
TF_VAR_SERVER_PUBLICKEY=$(cat server_publickey)
TF_VAR_CLIENT_PRIVATEKEY=$(cat client_privatekey)
TF_VAR_CLIENT_PUBLICKEY=$(cat client_publickey)
export TF_VAR_SERVER_PRIVATEKEY
export TF_VAR_SERVER_PUBLICKEY
export TF_VAR_CLIENT_PRIVATEKEY
export TF_VAR_CLIENT_PUBLICKEY

# Deploy infrastructure
terraform init
terraform apply -auto-approve
terraform output --raw private_key > id_rsa
chmod u+x id_rsa
chmod 600 id_rsa
terraform output --raw client_config > wg0-client.conf

