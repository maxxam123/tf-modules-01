provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "local" {
    path = "dev/tgw/terraform.tfstate"
  }
}

module "alb" {
  source = "../../../03_modules/04_alb"

  name            = "dev-alb"
  env             = "dev"
}