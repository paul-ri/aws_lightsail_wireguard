#!/bin/bash
set -euxo pipefail

# Clean up and set vars for destroy
TF_VAR_SERVER_PRIVATEKEY=$(cat server_privatekey)
TF_VAR_SERVER_PUBLICKEY=$(cat server_publickey)
TF_VAR_CLIENT_PRIVATEKEY=$(cat client_privatekey)
TF_VAR_CLIENT_PUBLICKEY=$(cat client_publickey)
export TF_VAR_SERVER_PRIVATEKEY
export TF_VAR_SERVER_PUBLICKEY
export TF_VAR_CLIENT_PRIVATEKEY
export TF_VAR_CLIENT_PUBLICKEY

# Destroy Infrastructure
terraform destroy -auto-approve
rm -rf server_privatekey client_privatekey server_publickey client_publickey id_rsa
