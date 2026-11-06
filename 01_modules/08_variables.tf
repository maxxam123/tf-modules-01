variable "env" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "private_subnets_tags" {
  type = map(any)
}

