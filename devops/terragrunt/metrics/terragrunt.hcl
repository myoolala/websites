include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../..//terraform/modules/metrics"
}

locals {
    region = "us-east-1"
}

dependency "shared" {
  config_path = "../shared"
}

dependency "e90" {
  config_path = "../e90"
}

dependency "resumes" {
  config_path = "../resumes"
}

# Indicate the input values to use for the variables of the module.
inputs = {
  namespace = dependency.shared.outputs.namespace
  domains = [
    dependency.shared.outputs.domain,
    dependency.resumes.outputs.domain,
    dependency.e90.outputs.domain
  ]
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "state.petergrasso.com"
    key    = "metrics.state"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-state-lock"
  }
}