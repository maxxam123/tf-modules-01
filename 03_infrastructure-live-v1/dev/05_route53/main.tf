provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "local" {
    path = "dev/tgw/terraform.tfstate"
  }
}

module "route53" {
  source = "../../../03_modules/05_route53"

  env             = "dev"
}