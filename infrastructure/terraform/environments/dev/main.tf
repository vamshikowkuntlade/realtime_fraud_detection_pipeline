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




/*
===============================================================================
IAM Module Deployment
===============================================================================

This environment layer deploys the reusable IAM module.

The IAM module provisions:

- Lambda execution role
- IAM trust relationship
- CloudWatch logging permissions
- KMS usage permissions

This establishes the foundational execution identity
required for future Lambda-based fraud processing.

The execution role will later be extended with:
- Kinesis permissions
- DynamoDB permissions
- S3 archive permissions

after those infrastructure resources are provisioned.

===============================================================================
*/

module "iam" {

  /*
  Relative path to reusable IAM module.
  */
  source = "../../modules/iam"

  /*
  Project naming identifier.

  Used for:
  - IAM role naming
  - policy naming
  - governance consistency
  */
  project_name = var.project_name

  /*
  Deployment environment identifier.

  Supports:
  - environment isolation
  - operational clarity
  - multi-environment deployments
  */
  environment = var.environment

  /*
  KMS ARN exposed from the KMS module.

  This demonstrates Terraform module composition.

  The IAM module consumes the KMS module output
  instead of hardcoding infrastructure values.
  */
  kms_key_arn = module.kms.kms_key_arn

  /*
  Centralized governance tags.
  */
  tags = local.common_tags
}


