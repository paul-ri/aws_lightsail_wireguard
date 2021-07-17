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

variable "instance_size" {
  description = "Size of the instance"
  type        = string
  # nano micro small medium large xlarge 2xlarge
  default     = "micro"
}
