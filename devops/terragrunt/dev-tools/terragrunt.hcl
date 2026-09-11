include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../..//terraform/modules/dev-tools"
}

locals {
  region = "us-east-1"
  secrets = yamldecode(sops_decrypt_file("secrets.yml"))
}

dependency "shared" {
  config_path = "../shared"
}

inputs = {
  listener_arn = dependency.shared.outputs.listener_arn
  code_bucket = dependency.shared.outputs.code_bucket
  lb_dns_name = dependency.shared.outputs.lb_dns_name
  priority = 103
  group = "dev-tools"
  dns = {
    hosted_zone = local.secrets.hosted_zone
    domain = local.secrets.domain
  }
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region              = "us-east-1"
  default_tags {
    tags = {
      Environment = "Personal"
      Project = "Personal"
      Billing = "dev-tools"
    }
  }
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "state.petergrasso.com"
    key    = "dev-tools.state"
    region = "us-east-1"
    encrypt = true
  }
}
