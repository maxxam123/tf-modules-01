provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "local" {
    path = "alb/terraform.tfstate"
  }
}

module "alb" {
  source = "../../../06_modules/04_alb"

  env            = "dev"
  name = "hub-alb"
}