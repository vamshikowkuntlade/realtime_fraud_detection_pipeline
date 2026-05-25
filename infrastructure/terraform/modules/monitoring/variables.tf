variable "project_name"{
    description = "short project identifier used in resource naming"
    type = string
}
variable "environment"{
    description = "deployment environment (e.g. dev, staging, prod)"
    type = string
}
variable "alert_email"{

    description = "emailid subscribed to receive monitoring alerts"
    type = string
}
variable "tags" {
  description = "common governance tags"
  type = map(string)
  default = {}
}
