provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "local" {
    path = "vpc/terraform.tfstate"
  }
}

module "vpc-hub" {
  source = "../../../06_modules/01_hub_vpc"

  vpc_cidr_block = "10.0.0.0/16"
  env            = "dev"
  azs            = ["eu-central-1a", "eu-central-1b"]
  pub_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  tgw_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
}