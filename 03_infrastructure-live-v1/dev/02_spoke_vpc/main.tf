provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "local" {
    path = "vpc/terraform.tfstate"
  }
}

module "vpc-spoke-01" {
  source = "../../../06_modules/02_spoke_vpc"

  vpc_cidr_block     = "20.0.0.0/16"
  env            = "dev"
}