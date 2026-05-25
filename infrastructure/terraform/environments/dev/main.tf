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

  source = "../../modules/iam"

  project_name = var.project_name

  environment = var.environment

  kms_key_arn = module.kms.kms_key_arn

  kinesis_stream_arn = module.kinesis.stream_arn

  dynamodb_table_arn = module.dynamodb.table_arn

  s3_bucket_arn = module.s3.bucket_arn

  tags = local.common_tags
}





module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  environment  = var.environment
  account_id   = var.account_id
  kms_key_arn  = module.kms.kms_key_arn
  tags         = local.common_tags

}


module "kinesis" {
  source                 = "../../modules/kinesis"
  project_name           = var.project_name
  environment            = var.environment
  shard_count            = 1
  retention_period_hours = 24
  kms_key_arn            = module.kms.kms_key_arn
  tags                   = local.common_tags
}



module "dynamodb" {

  source = "../../modules/dynamodb"

  project_name = var.project_name

  environment = var.environment

  kms_key_arn = module.kms.kms_key_arn

  tags = local.common_tags
}





module "lambda" {

  source = "../../modules/lambda"

  project_name = var.project_name

  environment = var.environment

  lambda_role_arn = module.iam.fraud_processor_role_arn

  kinesis_stream_arn = module.kinesis.stream_arn

  s3_bucket_name = module.s3.bucket_name

  dynamodb_table_name = module.dynamodb.table_name

  tags = local.common_tags
}




module "monitoring" {

  source = "../../modules/monitoring"

  project_name = var.project_name

  environment = var.environment

  alert_email = var.alert_email

  tags = local.common_tags
}