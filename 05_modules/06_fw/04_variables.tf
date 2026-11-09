variable "env" {
  type = string
}

variable "fw_id" {
  type        = list(string)
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}