provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "local" {
    path = "tgw/terraform.tfstate"
  }
}

module "tgw" {
  source = "../../../06_modules/02_tgw"

  env            = "dev"
}