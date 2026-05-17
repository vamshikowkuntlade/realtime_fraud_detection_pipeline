locals  {
    stream_name = "${var.project_name}-${var.environment}-${var.stream_name_suffix}"
}



resource "aws_kinesis_stream" "this" {
  
  name = local.stream_name

  shard_count = var.shard_count

  retention_period = var.retention_period_hours

  encryption_type = "KMS"

  kms_key_id = var.kms_key_arn

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  shard_level_metrics = [
    "IncomingBytes",
    "IncomingRecords",
    "OutgoingBytes",
    "OutgoingRecords",
    "WriteProvisionedThroughputExceeded",
    "ReadProvisionedThroughputExceeded",
    "IteratorAgeMilliseconds"
  ]


  tags = var.tags

}


