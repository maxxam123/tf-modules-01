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

variable "privat_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private-subnets_tags" {
  type = map(all)
}

variable "public_subnets_tags" {
  type = map(all)
}
