output "kms_key_arn" {

  description = "ARN of deployed KMS key"

  value = module.kms.kms_key_arn
}

output "kms_alias_name" {

  description = "KMS alias name"

  value = module.kms.kms_alias_name
}




/*
===============================================================================
IAM Infrastructure Outputs
===============================================================================

These outputs expose deployed IAM infrastructure values
from the dev environment layer.

This allows:

- downstream infrastructure composition
- operational visibility
- Terraform output inspection
- future Lambda deployment integration

The execution role outputs will later be consumed by:
- Lambda functions
- EventBridge integrations
- Step Functions workflows

===============================================================================
*/

output "fraud_processor_role_name" {

  description = "Name of deployed fraud processor execution role"

  value = module.iam.fraud_processor_role_name
}

output "fraud_processor_role_arn" {

  description = "ARN of deployed fraud processor execution role"

  value = module.iam.fraud_processor_role_arn
}



output "raw_archive_bucket_name" {

  description = "Name of the raw archive S3 bucket"

  value = module.s3.bucket_name
}

output "raw_archive_bucket_arn" {

  description = "ARN of the raw archive S3 bucket"

  value = module.s3.bucket_arn
}