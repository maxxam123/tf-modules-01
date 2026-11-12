variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
    type = string
}

variable "pub_subnet_id" {
    type = list(string)
}

variable "spoke_alb_arn" {
    type = string
}