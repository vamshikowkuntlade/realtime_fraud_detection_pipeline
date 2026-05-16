variable "project_name" {
  description = "The name of the project. This will be used as a prefix for all resources created by this module."
  type        = string
}
variable "environment" {
  description = "The environment for which the resources will be created (e.g., dev, staging, prod). This will be used as a suffix for all resources created by this module."
  type        = string
}

variable "account_id" {
  description = "The AWS account ID where the S3 bucket will be created."
  type        = string
}

variable "kms_key_arn" {

  description = "KMS key ARN used for bucket encryption"

  type = string
}

variable "lifecycle_transition_days" {

  description = "Days before transitioning objects to Intelligent-Tiering"

  type = number

  default = 30
}

variable "tags" {

  description = "Common resource tags"

  type = map(string)

  default = {}
}