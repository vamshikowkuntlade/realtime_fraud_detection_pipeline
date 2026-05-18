variable "project_name" {

  description = "Short project identifier used in resource naming"

  type = string
}

variable "environment" {

  description = "Deployment environment"

  type = string
}

variable "table_name_suffix" {

  description = "Business-purpose suffix for DynamoDB table naming"

  type = string

  default = "fraud-alerts-ddb"
}

variable "billing_mode" {

  description = "DynamoDB billing mode"

  type = string

  default = "PAY_PER_REQUEST"
}

variable "hash_key" {

  description = "Partition key for the DynamoDB table"

  type = string

  default = "transaction_id"
}

variable "range_key" {

  description = "Sort key for the DynamoDB table"

  type = string

  default = "timestamp"
}

variable "ttl_attribute_name" {

  description = "TTL attribute name for automatic item expiration"

  type = string

  default = "expiry_time"
}

variable "kms_key_arn" {

  description = "KMS key ARN used for DynamoDB encryption"

  type = string
}

variable "tags" {

  description = "Common governance tags"

  type = map(string)

  default = {}
}