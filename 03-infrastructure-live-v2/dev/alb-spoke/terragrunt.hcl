terraform {
  source = "../../../modules/01-spoke-alb"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc_spoke" {
  config_path = "../vpc-spoke"

  mock_outputs = {
    vpc_id = "mock-vpc-id-12345"
    alb_subnet_id = ["mock-subnet-1", "mock-subnet-2"]
  }
}

inputs = {
  env = "dev"
  vpc_id = dependency.vpc_spoke.outputs.vpc_id
  alb_subnet_id = dependency.vpc_spoke.outputs.alb_subnet_id
}

