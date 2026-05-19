/*
===============================================================================
IAM Module Input Variables
===============================================================================

Variables make Terraform modules reusable.

Instead of hardcoding:

- project names
- environment names
- resource ARNs
- tagging standards

the environment layer dynamically injects values into the module.

This enables:

- dev deployments
- stage deployments
- prod deployments

using the same reusable IAM module.

===============================================================================
*/

variable "project_name" {

  description = "Short project identifier used in resource naming"

  type = string
}

variable "environment" {

  description = "Deployment environment"

  type = string
}

variable "kinesis_stream_arn" {

  description = "ARN of the Kinesis transaction ingestion stream"

  type = string
}

variable "dynamodb_table_arn" {

  description = "ARN of the DynamoDB fraud alerts table"

  type = string
}

variable "s3_bucket_arn" {

  description = "ARN of the S3 raw archive bucket"

  type = string
}

variable "kms_key_arn" {

  description = "ARN of the KMS key used for encryption"

  type = string
}

variable "tags" {

  description = "Common governance tags"

  type = map(string)

  default = {}
}




