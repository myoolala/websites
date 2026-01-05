

# Indicate what region to deploy the resources into
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region              = "us-east-1"
  default_tags {
    tags = {
      Environment = "Personal"
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