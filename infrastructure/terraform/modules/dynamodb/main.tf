locals {
    table_name = "${var.project_name}-${var.environment}-${var.table_name_suffix}"
}


resource "aws_dynamodb_table" "this"{
  name = local.table_name
  billing_mode = var.billing_mode
  hash_key = var.hash_key
  range_key = var.range_key

  attribute  {
    name = var.hash_key
    type = "S"
  }

  attribute {
    name = var.range_key
    type = "S"
  }


  ttl {

    attribute_name = var.ttl_attribute_name

    enabled = true
  }


  server_side_encryption {
    
    enabled = true

    kms_key_arn = var.kms_key_arn
  }
  
  point_in_time_recovery {
    enabled = true
  }

  tags = var.tags

}