variable "project_name" {

  description = "Short project identifier"

  type = string
}

variable "environment" {

  description = "Deployment environment"

  type = string
}

variable "lambda_function_name_suffix" {

  description = "Business-purpose suffix for Lambda naming"

  type = string

  default = "fraud-processor-lambda"
}

variable "lambda_role_arn" {

  description = "IAM role ARN for Lambda execution"

  type = string
}

variable "kinesis_stream_arn" {

  description = "Kinesis stream ARN for event source mapping"

  type = string
}

variable "s3_bucket_name" {

  description = "Archive bucket name"

  type = string
}

variable "dynamodb_table_name" {

  description = "Fraud alerts DynamoDB table name"

  type = string
}

variable "lambda_timeout" {

  description = "Lambda timeout in seconds"

  type = number

  default = 60
}

variable "lambda_memory_size" {

  description = "Lambda memory size"

  type = number

  default = 512
}

variable "tags" {

  description = "Common governance tags"

  type = map(string)

  default = {}
}