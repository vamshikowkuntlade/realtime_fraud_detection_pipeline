variable "aws_region" {

  description = "AWS deployment region"

  type = string
}

variable "project_name" {

  description = "Project short name"

  type = string
}

variable "environment" {

  description = "Deployment environment"

  type = string
}

variable "owner" {

  description = "Infrastructure owner"

  type = string
}

variable "account_id" {

  description = "AWS account ID"

  type = string
}