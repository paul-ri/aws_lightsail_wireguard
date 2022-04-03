#!/usr/bin/env fish

# Setup vars for Terraform interpolation
set -x TF_VAR_SERVER_PRIVATEKEY (cat keys/server_privatekey)
set -x TF_VAR_SERVER_PUBLICKEY (cat keys/server_publickey)
set -x TF_VAR_MUDLAPTOP_PRIVATEKEY (cat keys/mdulaptop_privatekey)
set -x TF_VAR_MUDLAPTOP_PUBLICKEY (cat keys/mdulaptop_publickey)
set -x TF_VAR_FAIRPHONE_PRIVATEKEY (cat keys/fairphone_privatekey)
set -x TF_VAR_FAIRPHONE_PUBLICKEY (cat keys/fairphone_publickey)
set -x TF_VAR_OPTIPLEX_PRIVATEKEY (cat keys/optiplex_privatekey)
set -x TF_VAR_OPTIPLEX_PUBLICKEY (cat keys/optiplex_publickey)
set -x TF_VAR_CHROMEBOOK_PRIVATEKEY (cat keys/chromebook_privatekey)
set -x TF_VAR_CHROMEBOOK_PUBLICKEY (cat keys/chromebook_publickey)