########################################################################
#############                   Required                   #############
########################################################################

variable "code_bucket" {
  type        = string
  description = "ID of the code bucket to serve files from"
}

variable "listener_arn" {
  type = string
  description = "ARN for the HTTPS listener"
}

variable "lb_dns_name" {
  type = string
  description = "CNAME to forward traffic to"
}

variable "group" {
  type = string
  description = "Group part of the deployment to use"
}

########################################################################
#############                   Optional                   #############
########################################################################

variable "dns" {
  type = object({
    hosted_zone = optional(string, null)
    cert        = optional(string, null)
    domain      = optional(string, null)
    private     = optional(bool, false)
  })
  description = "Any and all dns related configurations including public certificates"
}

variable "region" {
  type        = string
  description = "Region being deployed in AWS"
  default     = "us-east-1"
}