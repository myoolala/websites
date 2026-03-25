# Indicate what region to deploy the resources into
generate "terraform" {
  path      = "terraform.tf"
  if_exists = "overwrite"
  contents = <<EOF
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