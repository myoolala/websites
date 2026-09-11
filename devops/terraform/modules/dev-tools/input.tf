########## inputs for dev-tools module ##########

variable "code_bucket" {
  type        = string
  description = "ID of the code bucket to store the lambda zip"
}

variable "listener_arn" {
  type        = string
  description = "ARN for the HTTPS listener"
}

variable "lb_dns_name" {
  type        = string
  description = "CNAME to forward traffic to"
}

variable "priority" {
  type        = number
  description = "Listener rule priority number"
  default     = 100
}

variable "group" {
  type        = string
  description = "Group name for the function naming"
}

variable "dns" {
  type = object({
    hosted_zone = optional(string, null)
    cert        = optional(string, null)
    domain      = optional(string, null)
    private     = optional(bool, false)
  })
  description = "Any and all dns related configurations including public certificates"
}
