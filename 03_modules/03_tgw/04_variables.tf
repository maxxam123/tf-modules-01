variable "env" {
  type = string
}

variable "default_route_table_propagation" {
  type = string
  default = "disabled"
}

variable "default_route_table_association" {
  type = string
  default = "disabled"
}