locals {

  lambda_function_name = "${var.project_name}-${var.environment}-${var.lambda_function_name_suffix}"
}


/*Why Explicit Log Groups Matter

AWS can auto-create log groups.

BUT enterprise environments explicitly manage them because we need:

retention control
governance
lifecycle management
encryption later
observability standardization*/

resource "aws_cloudwatch_log_group" "this" {

  name = "/aws/lambda/${local.lambda_function_name}"

  retention_in_days = 14

  tags = var.tags
}



resource "aws_lambda_function" "this" {

  function_name = local.lambda_function_name

  role = var.lambda_role_arn

  runtime = "python3.12"

  handler = "handler.lambda_handler"

  filename = "../../../../applications/fraud_processor_lambda/lambda_function.zip"

  
  #terraform uses code_hash to determine if the function code has changed and needs to be redeployed.
  source_code_hash = filebase64sha256("../../../../applications/fraud_processor_lambda/lambda_function.zip")

  timeout = var.lambda_timeout

  memory_size = var.lambda_memory_size

  environment {

    variables = {

      DYNAMODB_TABLE_NAME = var.dynamodb_table_name

      S3_ARCHIVE_BUCKET = var.s3_bucket_name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.this
  ]

  tags = var.tags
}




#Event Source Mapping

resource "aws_lambda_event_source_mapping" "kinesis_trigger" {

  event_source_arn = var.kinesis_stream_arn

  function_name = aws_lambda_function.this.arn

  starting_position = "LATEST"

  batch_size = 100

  maximum_batching_window_in_seconds = 5

  enabled = true
}