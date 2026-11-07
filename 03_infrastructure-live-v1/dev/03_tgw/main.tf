provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "local" {
    path = "dev/tgw/terraform.tfstate"
  }
}

module "tgw" {
  source = "../../../03_modules/03_tgw"

  env             = "dev"
}