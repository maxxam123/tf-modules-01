variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
    type = string
}

variable "tgw_subnet_id" {
    type = list(string)
}