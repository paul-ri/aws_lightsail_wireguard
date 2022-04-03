provider "random" {}
provider "template" {}
provider "null" {}
provider "tls" {}

locals {
  name                  = "Wireguard"
  AZ                    = "${var.aws_region}a"
  OS                    = "ubuntu_20_04"
  Size                  = "${var.instance_size}_2_0"
  KeySize               = 4096
  wg_port               = 55380
  server_network        = "10.1.2.0"
  server_ip             = "10.1.2.1"
  client_mdulaptop_ip   = "10.1.2.2"
  client_fairphone_ip   = "10.1.2.3"
  client_optiplex_ip    = "10.1.2.4"
  client_chromebook_ip  = "10.1.2.6"
}
