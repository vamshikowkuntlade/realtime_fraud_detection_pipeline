###############################################
# Shared Terraform Variables
###############################################
#
# Variables allow Terraform configurations
# to remain reusable and environment-aware.
#
# Instead of hardcoding values directly,
# variables provide:
# - flexibility
# - consistency
# - CI/CD compatibility
# - safer configuration management
#
###############################################

variable "aws_region" {
  description = "Primary AWS region"
  type        = string
}

variable "project_name" {
  description = "Project short identifier"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}