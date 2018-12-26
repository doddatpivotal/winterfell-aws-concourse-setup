variable "env_name" {}
variable "access_key" {}

variable "secret_key" {}

variable "region" {}

variable "availability_zones" {
  type = "list"
}
variable "vpc_cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Key/value tags to assign to all AWS resources"
}

locals {
  public_cidr         = "${cidrsubnet(var.vpc_cidr, 8, 0)}"
  private_cidr         = "${cidrsubnet(var.vpc_cidr, 8, 1)}"
}
