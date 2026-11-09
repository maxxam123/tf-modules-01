# test

remote_state {
  backend = "local" 
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents  = <<EOF
provider "aws" {
  region = "eu-central-1"
}
EOF
}