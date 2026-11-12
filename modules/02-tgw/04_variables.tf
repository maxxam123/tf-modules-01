variable "env" {
  type = string
}

variable "vpc_id" {
    type = string
}

variable "tgw_subnet_id" {
    type = list(string)
}

variable "default_route_table_propagation" {
  type = string
  default = "disable"
}

variable "default_route_table_association" {
  type = string
  default = "disable"
}