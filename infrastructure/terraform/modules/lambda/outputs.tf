output "lambda_function_name" {

  description = "Fraud processor Lambda function name"

  value = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {

  description = "Fraud processor Lambda ARN"

  value = aws_lambda_function.this.arn
}