variable "hosted_zone" {
  type = string
  description = "Hosted Zone ID to route traffic with"
}

module "vpc" {
  source = "github.com/myoolala/terraform-aws/modules//vpc?ref=main"

  name      = "opensource-repo"
  public    = true
  ipv4_cidr = "172.31.0.0/16"
  # ipv6_cidr = "2001:db8:1234:1a00::/56"
  ingress_subnets = [{
    ipv4_cidr = "172.31.0.0/27"
    az        = "us-east-1a"
    nat       = true
    },
    {
      ipv4_cidr = "172.31.0.32/27"
      az        = "us-east-1b"
      nat       = true
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

  domain      = "www.petergrasso.com"
  hosted_zone = var.hosted_zone
  private     = false
}

resource "aws_route53_record" "cname" {
  zone_id = var.hosted_zone
  name    = "www.petergrasso.com"
  type    = "CNAME"
  ttl     = 300
  records = [module.ingress.dns_name]
}

module "ingress" {
  source = "github.com/myoolala/terraform-aws/modules//load-balancer?ref=main"

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