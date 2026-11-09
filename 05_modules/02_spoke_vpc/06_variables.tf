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

variable "pri_subnets" {
  type = list(string)
}

variable "tgw_subnets" {
  type = list(string)
}