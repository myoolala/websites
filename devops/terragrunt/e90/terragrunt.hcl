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
  priority = 101
  group = "e90"
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
    key    = "e90.state"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-state-lock"
  }
}

# Indicate what region to deploy the resources into
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region              = "us-east-1"
  default_tags {
    tags = {
      Environment = "peter"
    }
  }
}

terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
      version = "2.7.1"
   }
   aws = {
      source = "hashicorp/aws"
      version = ">=6.0.0"
   }
  }
}
EOF
}