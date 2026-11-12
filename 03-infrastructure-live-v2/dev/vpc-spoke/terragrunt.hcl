terraform {
  source = "../../../modules/01-spoke-vpc"
}

include "root" {
    path = find_in_parent_folders("root.hcl")
}

inputs = {
  env = "dev"
  azs    = ["eu-central-1a", "eu-central-1b"]
  
  pri_subnets  = ["20.0.1.0/24", "20.0.2.0/24"]
  tgw_subnets = ["20.0.10.0/24", "20.0.11.0/24"]
}

