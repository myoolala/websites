variable "hosted_zone" {
  type = string
  description = "Hosted Zone ID to route traffic with"
}

variable "domain" {
  type = string
  description = "Default domain to deploy to"
}

module "vpc" {
  source = "github.com/myoolala/terraform-aws/modules//vpc?ref=main"

  name      = "opensource-repo"
  public    = true
  ipv4_cidr = "172.31.0.0/16"
  ipv6_conf = {
    border_group = "us-east-1"
  }
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az        = "us-east-1a"
    nat       = false
    },
    {
      ipv4_cidr = "172.31.0.32/27"
      az        = "us-east-1b"
      nat       = false
  }]
  compute_subnets = [{
      ipv4_cidr = "172.31.1.0/25"
      az        = "us-east-1a"
    },
    {
      ipv4_cidr = "172.31.1.128/25"
      az        = "us-east-1b"
  }]
}

module "code_bucket" {
  source = "github.com/myoolala/terraform-aws/modules//s3-bucket?ref=main"

  name               = "petergrasso-code-bucket"
  versioning_enabled = false
}

module "cert" {
  source = "github.com/myoolala/terraform-aws//modules/cert?ref=main"

  domain      = "${var.domain}"
  hosted_zone = var.hosted_zone
  private     = false
}

resource "aws_route53_record" "cname" {
  zone_id = var.hosted_zone
  name    = "${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [module.ingress.dns_name]
}

module "ingress" {
  source = "github.com/myoolala/terraform-aws/modules//load-balancer?ref=b829bc36105759d2df8f364c2fb7006a2e81f90e"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.ingress_subnet_ids
  ingress_cidrs = [
    "0.0.0.0/0"
  ]
  # egress_cidrs        = module.vpc.ipv4_cidrs
  name                = "opensource-repos"
  type                = "application"
  internal            = false
  deletion_protection = false
  port_mappings = [{
    listen_port  = 443
    forward_port = null
    cert         = module.cert.arn
    target_type  = "lambda"
  }]

  access_logs = {}
}

module "athena_table" {
  source = "github.com/myoolala/terraform-aws/modules//alb-logs-athena-table?ref=b829bc36105759d2df8f364c2fb7006a2e81f90e"

  name                  = "test-alb-log-table"
  alb_logs_bucket       = module.ingress.logs_bucket_name
  alb_logs_prefix       = ""
}


module "ui_lambda" {
  source = "github.com/myoolala/terraform-aws/modules//lambda-s3-ui?ref=273ea67fc8c49fa3a9f308d6a18de001ee661295"

  lambda_name = "petergrasso-personal-proxy"
  config = {
    log_level = "WARN"
    bucket     = module.code_bucket.id
    prefix     = "/personal/"
    enable_spa = false
  }
  metrics_config = {
    enabled = true
    namespace = "personal-sites"
  }

  # sg_config = {
  #   create = true
  #   vpc_id = module.vpc.vpc_id
  # }
  # vpc_config = {
  #   subnets = module.vpc.compute_subnet_ids
  # }
  vpc_config = null
  alb_tg_arn = module.ingress.tg_arns[0]
}

output "domain" {
  value = var.domain
}

output "namespace" {
  value = "personal-sites"
}

output "lb_dns_name" {
  value = module.ingress.dns_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_arn" {
  value = module.ingress.lb_arn
}

output "listener_arn" {
  value = module.ingress.listener_arn[0]
}

output "default_tg_arn" {
  value = module.ingress.tg_arns[0]
}

output "code_bucket" {
  value = module.code_bucket.id
}