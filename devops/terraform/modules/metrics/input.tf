########################################################################
#############                   Required                   #############
########################################################################

variable "namespace" {
  type = string
  description = "Namespace to query cloudwatch with"
}

variable "domains" {
  type = list(string)
  description = "List of all domains there can be metrics for"
}

########################################################################
#############                   Optional                   #############
########################################################################