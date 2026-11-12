terraform {
  source = "../../../modules/02-tgw"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "mock-vpc-id-12345"
    tgw_subnet_id = ["mock-subnet-1", "mock-subnet-2"] # Add mock list here
  }
}

inputs = {
  env = "dev"
  vpc_id = dependency.vpc.outputs.vpc_id
  tgw_subnet_id = dependency.vpc.outputs.tgw_subnet_id
}

