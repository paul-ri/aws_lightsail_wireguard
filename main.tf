provider "random" {}
provider "template" {}
provider "null" {}
provider "tls" {}

provider "aws" {
  profile = var.aws_profile_name
  region = var.aws_region
}

resource "random_integer" "wg_port" {
  min = 20000
  max = 60000
}

locals {
  name    = "Wireguard"
  AZ      = "${var.aws_region}a"
  OS      = "ubuntu_20_04"
  Size    = "micro_2_0"
  KeySize = 4096
}
