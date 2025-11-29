module "cert" {
  source = "github.com/myoolala/terraform-aws//modules/cert?ref=main"

  domain      = var.dns.domain
  hosted_zone = var.dns.hosted_zone
  private     = false
}

resource "aws_route53_record" "cname" {
  zone_id = var.dns.hosted_zone
  name    = var.dns.domain
  type    = "CNAME"
  ttl     = 300
  records = [var.lb_dns_name]
}

resource "aws_lb_listener_certificate" "this" {
  listener_arn    = var.listener_arn
  certificate_arn = module.cert.arn
}

resource "aws_lb_target_group" "forwarder" {
  name        = "petergrasso-${var.group}"
  target_type = "lambda"
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forwarder.arn
  }

  condition {
    host_header {
      values = [var.dns.domain]
    }
  }

  depends_on = [
    module.cert,
    aws_route53_record.cname,
    aws_lb_listener_certificate.this
  ]
}

module "ui_lambda" {
  source = "github.com/myoolala/terraform-aws/modules//lambda-s3-ui?ref=main"

  lambda_name = "petergrasso-${var.group}-proxy"
  config = {
    log_level = "WARN"
    bucket     = var.code_bucket
    prefix     = "/${var.group}/"
    enable_spa = false
  }

  # sg_config = {
  #   create = true
  #   vpc_id = module.vpc.vpc_id
  # }
  # vpc_config = {
  #   subnets = module.vpc.compute_subnet_ids
  # }
  vpc_config = null
  alb_tg_arn = aws_lb_target_group.forwarder.arn
}