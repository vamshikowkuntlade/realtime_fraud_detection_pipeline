locals {

  common_tags = {

    Project = "Real-Time Fraud Detection"

    Environment = var.environment

    ManagedBy = "Terraform"

    Owner = var.owner

    CostCenter = "Fraud-Platform"

    Repository = "realtime_fraud_detection_platform"
  }
}