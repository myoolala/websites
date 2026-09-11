output "function_name" {
  value = module.lambda.function_name
}

output "lambda_role_arn" {
  value = module.lambda.role
}

output "target_group_arn" {
  value = aws_lb_target_group.devtools.arn
}

output "domain" {
  value = var.dns.domain
}
