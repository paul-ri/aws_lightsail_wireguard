resource "aws_lightsail_instance" "wireguard" {
  name              = local.name
  availability_zone = local.AZ
  blueprint_id      = local.OS
  bundle_id         = local.Size
  key_pair_name     = aws_lightsail_key_pair.key.name
  depends_on        = [aws_lightsail_key_pair.key]
  user_data         = templatefile(
  "${path.module}/source_files/config.sh",
  {
    WG_PKEY                      = var.SERVER_PRIVATEKEY
    SERVER_LINK_IPADDRESS        = local.server_ip
    LINK_NETMASK                 = "24"
    NET_PORT                     = local.wg_port
    PEER_MDULAPTOP_KEY           = var.MDULAPTOP_PUBLICKEY
    PEER_MDULAPTOP_ALLOWED_IPS   = "${local.client_mdulaptop_ip}/32"
    PEER_FAIRPHONE_KEY           = var.FAIRPHONE_PUBLICKEY
    PEER_FAIRPHONE_ALLOWED_IPS   = "${local.client_fairphone_ip}/32"
    PEER_OPTIPLEX_KEY            = var.OPTIPLEX_PUBLICKEY
    PEER_OPTIPLEX_ALLOWED_IPS    = "${local.client_optiplex_ip}/32"
    PEER_CHROMEBOOK_KEY          = var.CHROMEBOOK_PUBLICKEY
    PEER_CHROMEBOOK_ALLOWED_IPS  = "${local.client_chromebook_ip}/32"
    WG_NETWORK                   = local.server_network
  })
}

resource "aws_lightsail_static_ip_attachment" "static_ip_attachment" {
  static_ip_name = var.static_ip_name
  instance_name  = aws_lightsail_instance.wireguard.id
}

resource "aws_lightsail_instance_public_ports" "wireguard" {
  instance_name = aws_lightsail_instance.wireguard.name

  # Wireguard
  port_info {
    protocol  = "udp"
    from_port = local.wg_port
    to_port   = local.wg_port
  }
  # SSH
  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }
}
