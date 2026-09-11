# Auto‑zip Lambda source

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/source"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_route53_record" "cname" {
  zone_id = var.dns.hosted_zone
  name    = var.dns.domain
  type    = "CNAME"
  ttl     = 300
  records = [var.lb_dns_name]
}

# ---- Target group for the lambda ----
resource "aws_lb_target_group" "devtools" {
  name        = "petergrasso-${var.group}-devtools"
  target_type = "lambda"
}

# ---- Lambda function module ----
module "lambda" {
  source = "github.com/myoolala/terraform-aws//modules/lambda?ref=main"

  function_name = "petergrasso-${var.group}-devtools"
  file_path     = data.archive_file.lambda.output_path
  code_hash256 = data.archive_file.lambda.output_base64sha256
  handler       = "lambda.handler"
  runtime       = "nodejs26.x"
  tg_arns      = [aws_lb_target_group.devtools.arn]
}

# ---- Listener rule ----
resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devtools.arn
  }

  condition {
    host_header {
      values = [var.dns.domain]
    }
  }

  depends_on = [
    aws_route53_record.cname,
    module.lambda,  # ensure lambda is created before rule
  ]
}
