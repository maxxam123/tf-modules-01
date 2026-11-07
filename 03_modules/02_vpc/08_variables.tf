variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "env" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "firewall_subnets" {
  type = list(string)
}

variable "tgw_subnet" {
  type = list(string)
}