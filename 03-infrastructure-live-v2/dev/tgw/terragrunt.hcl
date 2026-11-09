terraform {
  source = "../../../modules-tgw/vpc"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "mock-vpc-id-12345"
  }
}

inputs = {
  env = "dev"
  vpc_id = dependency.vpc.outputs.vpc_id
}

