provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "local" {
    path = "dev/vpc/terraform.tfstate"
  }
}

module "vpc" {
  source = "../../../03_modules/02_vpc"

  env                   = "dev"
  azs                   = ["us-east-1a", "us-east-1b"]
  public_subnets        = ["10.0.1.0/24", "10.0.2.0/24"]
  firewall_subnets      = ["10.0.11.0/24", "10.0.12.0/24"]
  tgw_subnet            = ["10.0.21.0/24", "10.0.22.0/24"]
}