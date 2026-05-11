###############################################
# Shared Local Values
###############################################
#
# Locals centralize reusable computed values.
#
# This improves:
# - consistency
# - maintainability
# - naming standardization
# - governance alignment
#
###############################################

locals {

  #############################################
  # Common Resource Tags
  #############################################

  common_tags = {

    #########################################
    # Business Context
    #########################################

    Project = "Real-Time Fraud Detection"

    #########################################
    # Environment Context
    #########################################

    Environment = var.environment

    #########################################
    # Infrastructure Ownership
    #########################################

    ManagedBy = "Terraform"

    #########################################
    # Repository Context
    #########################################

    Repository = "realtime_fraud_detection_platform"

    #########################################
    # Platform Ownership
    #########################################

    Owner = "Vamshi"
  }
}