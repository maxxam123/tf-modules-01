terraform {
  source = "../../../modules/04-nlb"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "mock-vpc-id-12345"
    pub_subnet_id = ["mock-subnet-1", "mock-subnet-2"]
  }
}

dependency "vpc_spoke" {
  config_path = "../vpc-spoke"

  mock_outputs = {
    vpc_id = "mock-vpc-id-12345"
    alb_subnet_id = ["mock-subnet-1", "mock-subnet-2"] # Add mock list here
  }
}


dependency "spoke_alb_arn" {
  config_path = "../alb-spoke"

  mock_outputs = {
    spoke_alb_arn = "arn:aws:elasticloadbalancing:eu-central-1:123456789012:loadbalancer/app/mock-spoke-alb/1234567890abcdef"
  }
}

inputs = {
  env = "dev"
  vpc_id = dependency.vpc.outputs.vpc_id
  alb_subnet_id = dependency.vpc.outputs.alb_subnet_id
  spoke_alb_arn = dependency.spoke_alb_arn.outputs.spoke_alb_arn
}

