/*
===============================================================================
KMS Module Deployment
===============================================================================

This environment layer deploys the reusable KMS module.

The KMS module provisions:
- Customer Managed Key
- KMS Alias
- Encryption governance foundation

This key will later encrypt:
- Kinesis streams
- S3 buckets
- DynamoDB tables
- CloudWatch Logs

===============================================================================
*/

module "kms" {

  /*
  Relative path to reusable module.
  */
  source = "../../modules/kms"

  /*
  Project short-name.

  Used in naming convention.
  */
  project_name = var.project_name

  /*
  Environment identifier.

  Used for:
  - environment isolation
  - naming clarity
  - governance
  */
  environment = var.environment

  /*
  Human-readable KMS description.
  */
  kms_key_description = "Core encryption key for RTFD dev environment"

  /*
  Common governance tags.
  */
  tags = local.common_tags
}