variable "SERVER_PRIVATEKEY" {}
variable "SERVER_PUBLICKEY" {}
variable "MDULAPTOP_PRIVATEKEY" {}
variable "MDULAPTOP_PUBLICKEY" {}
variable "FAIRPHONE_PRIVATEKEY" {}
variable "FAIRPHONE_PUBLICKEY" {}
variable "OPTIPLEX_PRIVATEKEY" {}
variable "OPTIPLEX_PUBLICKEY" {}
variable "CHROMEBOOK_PRIVATEKEY" {}
variable "CHROMEBOOK_PUBLICKEY" {}

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
  default     = "nano"
}
