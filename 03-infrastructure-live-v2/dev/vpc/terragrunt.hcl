terraform {
  source = "../../../modules/01-hub-vpc"
}

include "root" {
  # path = find_in_parent_folders("terragrunt.hcl")
    path = find_in_parent_folders("root.hcl")
}

inputs = {
  env = "dev"
  azs    = ["eu-central-1a", "eu-central-1b"]
  
  pub_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  tgw_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
}

