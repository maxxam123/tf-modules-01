terraform {
  required_version = "1.17.1"

  required_providers {
    aws = {
        version = "6.72"
        source = "hashicorp/aws"
    }
  }
}