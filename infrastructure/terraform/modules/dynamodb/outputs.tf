output "table_name" {

  description = "Name of the DynamoDB fraud alerts table"

  value = aws_dynamodb_table.this.name
}

output "table_arn" {

  description = "ARN of the DynamoDB fraud alerts table"

  value = aws_dynamodb_table.this.arn
}