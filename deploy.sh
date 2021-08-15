#!/bin/bash
set -euxo pipefail

clients=(
"fairphone"
"mdulaptop"
"optiplex"
"raspberrypi"
"chromebook"
"server"
)

# Create keys
umask 077
mkdir -p keys

keyGen(){
    client="$1"
    echo "### Generating Wireguard keys for ${client}"
    wg genkey | tee "keys/${client}_privatekey" | wg pubkey > "keys/${client}_publickey"
}

for client in "${clients[@]}"; do
  if [ ! -f "keys/${client}_publickey" ]; then
    keyGen "$client"
  fi
done

. tf_config.sh

# Deploy infrastructure
terraform init
terraform apply
terraform output --raw private_key > keys/id_rsa
chmod u+x keys/id_rsa
chmod 600 keys/id_rsa
mkdir -p wg_client_configs
terraform output --raw mdulaptop_config > wg_client_configs/wg0-mdulaptop.conf
terraform output --raw fairphone_config > wg_client_configs/wg0-fairphone.conf
terraform output --raw optiplex_config > wg_client_configs/wg0-optiplex.conf
terraform output --raw raspberrypi_config > wg_client_configs/wg0-raspberrypi.conf
terraform output --raw chromebook_config > wg_client_configs/wg0-chromebook.conf

qrencode -o wg_client_configs/wg0-fairphone.png -t png < wg_client_configs/wg0-fairphone.conf;
xdg-open wg_client_configs/wg0-fairphone.png
