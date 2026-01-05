include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../..//terraform/modules/shared"
}

locals {
    region = "us-east-1"
    secrets = yamldecode(sops_decrypt_file("secrets.yml"))
}

# Indicate the input values to use for the variables of the module.
inputs = {
    hosted_zone = local.secrets.hosted_zone
    domain = local.secrets.domain
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "state.petergrasso.com"
    key    = "shared.state"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-state-lock"
  }
}