#!/bin/bash
set -euxo pipefail

# Setup vars for Terraform interpolation
TF_VAR_SERVER_PRIVATEKEY=$(cat keys/server_privatekey)
TF_VAR_SERVER_PUBLICKEY=$(cat keys/server_publickey)
TF_VAR_MDULAPTOP_PRIVATEKEY=$(cat keys/mdulaptop_privatekey)
TF_VAR_MDULAPTOP_PUBLICKEY=$(cat keys/mdulaptop_publickey)
TF_VAR_FAIRPHONE_PRIVATEKEY=$(cat keys/fairphone_privatekey)
TF_VAR_FAIRPHONE_PUBLICKEY=$(cat keys/fairphone_publickey)
TF_VAR_OPTIPLEX_PRIVATEKEY=$(cat keys/optiplex_privatekey)
TF_VAR_OPTIPLEX_PUBLICKEY=$(cat keys/optiplex_publickey)
TF_VAR_CHROMEBOOK_PRIVATEKEY=$(cat keys/chromebook_privatekey)
TF_VAR_CHROMEBOOK_PUBLICKEY=$(cat keys/chromebook_publickey)
export TF_VAR_SERVER_PRIVATEKEY
export TF_VAR_SERVER_PUBLICKEY
export TF_VAR_MDULAPTOP_PRIVATEKEY
export TF_VAR_MDULAPTOP_PUBLICKEY
export TF_VAR_FAIRPHONE_PRIVATEKEY
export TF_VAR_FAIRPHONE_PUBLICKEY
export TF_VAR_OPTIPLEX_PRIVATEKEY
export TF_VAR_OPTIPLEX_PUBLICKEY
export TF_VAR_CHROMEBOOK_PRIVATEKEY
export TF_VAR_CHROMEBOOK_PUBLICKEY