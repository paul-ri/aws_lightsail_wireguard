variable "SERVER_PRIVATEKEY" {}
variable "SERVER_PUBLICKEY" {}
variable "CLIENT_PRIVATEKEY" {}
variable "CLIENT_PUBLICKEY" {}

variable "aws_profile_name" {
  description = "AWS profile to use"
  type        = string
  default     = "default"
}

variable "aws_region" {}
