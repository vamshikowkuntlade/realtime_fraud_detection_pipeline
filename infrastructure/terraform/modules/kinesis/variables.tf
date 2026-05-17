
variable "project_name" {
    description = "Short project identifier used in resource naming"
    type        = string

}

variable "environment" {
    description = "Deployment environment (e.g., dev, staging, prod)"
    type        = string
}

variable "stream_name_suffix" {

  description = "Business-purpose suffix for Kinesis stream naming"

  type = string

  default = "transaction-ingestion-kds"
}

variable "shard_count" {

  description = "Number of shards for the Kinesis stream"

  type = number

  default = 1
}


variable "retention_period_hours" {

  description = "Kinesis stream retention period in hours"

  type = number

  default = 24
}


variable "kms_key_arn" {

  description = "KMS key ARN for stream encryption"

  type = string
}


variable "tags" {

  description = "Common governance tags"

  type = map(string)

  default = {}
}