output "public_ip" {
  value = aws_lightsail_instance.wireguard.*.public_ip_address
}

output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}

output "username" {
  value = aws_lightsail_instance.wireguard.*.username
}

output "port" {
  value = local.wg_port
}

output "mdulaptop_config" {
  value = templatefile(
  "${path.module}/source_files/wg0-mdulaptop.conf",
  {
    WG_MDULAPTOP_PRIVATE_KEY   = var.MDULAPTOP_PRIVATEKEY
    WG_SERVER_PUBLIC_KEY       = var.SERVER_PUBLICKEY
    SERVER_IP                  = aws_lightsail_static_ip.static_ip.ip_address
    SERVER_PORT                = local.wg_port
    PEER_MDULAPTOP_ALLOWED_IPS = "${local.client_mdulaptop_ip}/32"
    WG_IP                      = local.server_ip
  })
}

output "fairphone_config" {
  value = templatefile(
  "${path.module}/source_files/wg0-fairphone.conf",
  {
    WG_FAIRPHONE_PRIVATE_KEY   = var.FAIRPHONE_PRIVATEKEY
    WG_SERVER_PUBLIC_KEY       = var.SERVER_PUBLICKEY
    SERVER_IP                  = aws_lightsail_static_ip.static_ip.ip_address
    SERVER_PORT                = local.wg_port
    PEER_FAIRPHONE_ALLOWED_IPS = "${local.client_fairphone_ip}/32"
    WG_IP                      = local.server_ip
  })
}

output "optiplex_config" {
  value = templatefile(
  "${path.module}/source_files/wg0-optiplex.conf",
  {
    WG_OPTIPLEX_PRIVATE_KEY   = var.OPTIPLEX_PRIVATEKEY
    WG_SERVER_PUBLIC_KEY      = var.SERVER_PUBLICKEY
    SERVER_IP                 = aws_lightsail_static_ip.static_ip.ip_address
    SERVER_PORT               = local.wg_port
    PEER_OPTIPLEX_ALLOWED_IPS = "${local.client_optiplex_ip}/32"
    WG_IP                     = local.server_ip
    WG_NETWORK                = local.server_network
  })
}

output "chromebook_config" {
  value = templatefile(
  "${path.module}/source_files/wg0-chromebook.conf",
  {
    WG_CHROMEBOOK_PRIVATE_KEY    = var.CHROMEBOOK_PRIVATEKEY
    WG_SERVER_PUBLIC_KEY         = var.SERVER_PUBLICKEY
    SERVER_IP                    = aws_lightsail_static_ip.static_ip.ip_address
    SERVER_PORT                  = local.wg_port
    PEER_CHROMEBOOK_ALLOWED_IPS  = "${local.client_chromebook_ip}/32"
    WG_IP                        = local.server_ip
    WG_NETWORK                   = local.server_network
  })
}