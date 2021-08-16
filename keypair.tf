resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = local.KeySize
}

resource "aws_lightsail_key_pair" "key" {
  name       = "${local.name}-key"
  public_key = tls_private_key.key.public_key_openssh
  depends_on = [tls_private_key.key]
}

resource "local_file" "pem_file" {
  filename = pathexpand("keys/${aws_lightsail_key_pair.key.name}.pem")
  file_permission = "400"
  directory_permission = "700"
  sensitive_content = tls_private_key.key.private_key_pem
}

resource "local_file" "public_key" {
  filename = pathexpand("keys/${aws_lightsail_key_pair.key.name}.pub")
  file_permission = "400"
  directory_permission = "700"
  sensitive_content = aws_lightsail_key_pair.key.public_key
}