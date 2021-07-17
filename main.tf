provider "random" {}
provider "template" {}
provider "null" {}
provider "tls" {}

resource "random_integer" "wg_port" {
  min = 20000
  max = 60000
}

locals {
  name    = "Wireguard"
  AZ      = "${var.aws_region}a"
  OS      = "ubuntu_20_04"
  Size    = "${var.instance_size}_2_0"
  KeySize = 4096
}
