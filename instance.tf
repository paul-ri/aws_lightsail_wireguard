resource "aws_lightsail_instance" "wireguard" {
  name              = local.name
  availability_zone = local.AZ
  blueprint_id      = local.OS
  bundle_id         = local.Size
  key_pair_name     = aws_lightsail_key_pair.key.name
  depends_on        = [aws_lightsail_key_pair.key]
  user_data         = data.template_file.cloud_init.rendered
}

resource "aws_lightsail_instance_public_ports" "wireguard" {
  instance_name = aws_lightsail_instance.wireguard.name

  # Wireguard
  port_info {
    protocol  = "udp"
    from_port = random_integer.wg_port.result
    to_port   = random_integer.wg_port.result
  }
  # SSH
  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }
  # DNS
  port_info {
    protocol  = "tcp"
    from_port = 53
    to_port   = 53
  }
  port_info {
    protocol  = "udp"
    from_port = 53
    to_port   = 53
  }
}
