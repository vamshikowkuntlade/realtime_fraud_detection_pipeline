variable "aws_region" {
  description = "AWS region for backend infrastructure"
  type        = string
}

variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}