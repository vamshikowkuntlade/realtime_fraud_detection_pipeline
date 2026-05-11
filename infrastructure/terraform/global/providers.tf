###############################################
# AWS Provider Configuration
###############################################
#
# The provider defines how Terraform connects
# to AWS APIs.
#
# Authentication is inherited from:
# - AWS CLI credentials
# - configured IAM identity
#
# This centralized provider configuration
# ensures consistent infrastructure deployment
# behavior across the platform.
#
###############################################

provider "aws" {

  #############################################
  # Primary AWS Region
  #############################################

  region = var.aws_region

  #############################################
  # Default Tags
  #
  # Automatically applied to all supported
  # AWS resources created by Terraform.
  #
  # This improves:
  # - governance
  # - operational visibility
  # - cost allocation
  # - infrastructure discoverability
  #
  #############################################

  default_tags {

    tags = local.common_tags
  }
}