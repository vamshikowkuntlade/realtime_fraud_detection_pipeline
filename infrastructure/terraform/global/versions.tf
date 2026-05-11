###############################################
# Terraform Version Configuration
###############################################
#
# This file controls:
# - Terraform CLI version compatibility
# - Provider version consistency
#
# Version pinning prevents:
# - unexpected provider upgrades
# - CI/CD inconsistencies
# - breaking infrastructure changes
#
###############################################

terraform {

  #############################################
  # Terraform CLI Version
  #############################################

  required_version = "~> 1.14.0"

  #############################################
  # Required Providers
  #############################################

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}