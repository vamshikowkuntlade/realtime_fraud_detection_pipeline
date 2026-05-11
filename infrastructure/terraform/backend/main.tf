###############################################
# AWS Provider Configuration
###############################################
#
# The provider block defines which cloud
# platform Terraform will interact with.
#
# In this project:
# - Terraform authenticates using AWS CLI credentials
# - Infrastructure is provisioned in us-east-1
# - All downstream AWS resources inherit this provider
#
# This creates the connection layer between:
# Terraform → AWS APIs
#
###############################################

provider "aws" {
  region = var.aws_region
}

###############################################
# Local Variables
###############################################
#
# Locals centralize reusable computed values.
#
# This improves:
# - consistency
# - maintainability
# - operational readability
# - naming standardization
#
# These locals are reused across multiple resources.
#
###############################################

locals {

  #############################################
  # Terraform Remote State Bucket Name
  #############################################
  #
  # S3 bucket names must be globally unique.
  #
  # This bucket stores Terraform state files,
  # which act as the source of truth for
  # deployed infrastructure.
  #
  # Naming includes:
  # - project identifier
  # - resource purpose
  # - AWS account ID
  #
  #############################################

  terraform_state_bucket = "${var.project_name}-tf-state-${var.aws_region}-${var.account_id}"

  #############################################
  # Terraform State Lock Table
  #############################################
  #
  # DynamoDB is used for distributed state locking.
  #
  # This prevents concurrent Terraform operations
  # from corrupting infrastructure state.
  #
  # Example:
  # - CI/CD pipeline running terraform apply
  # - engineer running terraform apply locally
  #
  # Without locking:
  # Terraform state corruption can occur.
  #
  #############################################

  terraform_lock_table = "${var.project_name}-terraform-locks"

  #############################################
  # Common Resource Tags
  #############################################
  #
  # Tags improve:
  # - governance
  # - operational visibility
  # - cost tracking
  # - resource discovery
  # - auditability
  #
  # Enterprise environments heavily rely on tags.
  #
  #############################################

  common_tags = {
    Project     = "Real-Time Fraud Detection"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Vamshi"
  }
}


###############################################
# KMS Key — Terraform Backend Encryption
###############################################
#
# This KMS key is responsible for encrypting
# Terraform state stored inside the backend
# S3 bucket.
#
# Terraform state may contain:
# - infrastructure metadata
# - resource identifiers
# - ARNs
# - dependency mappings
# - sensitive configuration outputs
#
# Using a customer-managed KMS key provides:
# - centralized encryption governance
# - auditability
# - controlled key access
# - future key rotation capability
#
# This aligns with:
# - governance-first engineering
# - PCI-style security principles
# - enterprise cloud security standards
#
###############################################

resource "aws_kms_key" "terraform_backend_kms" {

  #############################################
  # Human-readable operational description
  #############################################

  description = "KMS key for Terraform backend encryption"

  #############################################
  # AWS prevents immediate deletion of KMS keys
  # because encrypted data may become
  # permanently unrecoverable.
  #
  # This creates a recovery safety window.
  #############################################

  deletion_window_in_days = 30

  tags = local.common_tags
}

###############################################
# KMS Alias — Human-Friendly Key Reference
###############################################
#
# KMS keys internally use long UUIDs which are
# difficult to manage operationally.
#
# Aliases provide:
# - readable naming
# - easier operations
# - simpler IAM policy references
# - governance clarity
#
# The alias points to the actual KMS key
# created above.
#
###############################################

resource "aws_kms_alias" "terraform_backend_kms_alias" {

  #############################################
  # alias/ prefix is required by AWS KMS
  #############################################

  name = "alias/${var.project_name}-terraform-backend-kms"

  #############################################
  # Reference to the actual KMS key
  #############################################

  target_key_id = aws_kms_key.terraform_backend_kms.key_id
}

###############################################
# S3 Bucket — Terraform Remote State Storage
###############################################
#
# This bucket stores Terraform state remotely.
#
# Terraform state contains:
# - deployed resource metadata
# - infrastructure mappings
# - dependency relationships
# - output values
#
# Remote state is required for:
# - team collaboration
# - CI/CD deployments
# - state consistency
# - production-grade infrastructure management
#
# Local state files are unsafe for enterprise systems.
#
###############################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.terraform_state_bucket

  tags = local.common_tags
}

###############################################
# S3 Bucket Versioning
###############################################
#
# Versioning protects Terraform state history.
#
# This enables:
# - rollback capability
# - accidental deletion recovery
# - state corruption recovery
# - infrastructure auditability
#
# Terraform state is critical infrastructure metadata.
#
###############################################

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Server-Side Encryption
###############################################
#
# This configuration enforces encryption
# for all Terraform state objects stored
# inside the backend bucket.
#
# Instead of AWS-managed AES256 encryption,
# this project uses a customer-managed
# KMS key to align with:
#
# - governance-first engineering
# - PCI-style security principles
# - centralized key management
# - auditability requirements
#
# The KMS key is created earlier in this file
# and referenced here directly.
#
###############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {

      #########################################
      # Customer-managed KMS encryption
      #########################################

      kms_master_key_id = aws_kms_key.terraform_backend_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

##############################################

###############################################
# S3 Public Access Block
###############################################
#
# Prevents accidental public exposure
# of Terraform state files.
#
# This is a foundational governance control.
#
# Public Terraform state exposure is a
# severe operational and security risk.
#
###############################################

resource "aws_s3_bucket_public_access_block" "terraform_state_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


###############################################

resource "aws_dynamodb_table" "terraform_locks" {
  name         = local.terraform_lock_table
  billing_mode = "PAY_PER_REQUEST"

  #############################################
  # LockID acts as the unique lock identifier
  # for Terraform operations.
  #############################################

  hash_key = "LockID"

  #############################################
  # DynamoDB Table Schema
  #
  # Terraform requires a single partition key
  # named LockID for state locking.
  #
  #############################################

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.common_tags
}