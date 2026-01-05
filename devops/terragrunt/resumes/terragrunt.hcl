include "providers" {
  path = find_in_parent_folders("providers.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../..//terraform/modules/website"
}

locals {
    region = "us-east-1"
    secrets = yamldecode(sops_decrypt_file("secrets.yml"))
}

dependency "shared" {
  config_path = "../shared"
}

# Indicate the input values to use for the variables of the module.
inputs = {
  listener_arn = dependency.shared.outputs.listener_arn
  code_bucket = dependency.shared.outputs.code_bucket
  lb_dns_name = dependency.shared.outputs.lb_dns_name
  group = "resume"
  dns = {
      hosted_zone = local.secrets.hosted_zone
      domain = local.secrets.domain
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "state.petergrasso.com"
    key    = "resume.state"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-state-lock"
  }
}