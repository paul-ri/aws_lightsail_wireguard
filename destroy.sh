#!/bin/bash
set -euxo pipefail

. tf_config.sh

# Destroy Infrastructure
terraform destroy -auto-approve
rm -rf wg_client_configs
