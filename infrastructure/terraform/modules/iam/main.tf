/*
===============================================================================
IAM Trust Policy Document
===============================================================================

This policy defines:

WHO is allowed to assume the IAM role.

Important distinction:
-------------------------------------------------------------------------------

Trust policies DO NOT define permissions.

They define:

"Which AWS service or identity can use this role?"

This is fundamentally different from:

"What actions is the role allowed to perform?"

In our architecture:

AWS Lambda must dynamically assume this role at runtime.

Without this trust relationship:

- the role would exist
- but Lambda could NOT use it

This is one of the most important AWS IAM concepts.

===============================================================================
*/

data "aws_iam_policy_document" "lambda_trust_policy" {

  statement {

    sid = "LambdaAssumeRole"

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {

      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

/*
===============================================================================
Lambda Execution Role
===============================================================================

This resource creates the runtime IAM identity used by the
fraud-processing Lambda function.

This role will eventually allow Lambda to:

- read transaction records from Kinesis
- write fraud alerts into DynamoDB
- archive records into S3
- write logs into CloudWatch
- interact with KMS encrypted resources

IMPORTANT:
-------------------------------------------------------------------------------

This role itself does NOT yet define permissions.

At this stage:

- we are only creating the identity
- and attaching the trust relationship

Permissions will be attached separately afterward.

This separation is intentional and mirrors enterprise IAM design.

===============================================================================
*/

resource "aws_iam_role" "fraud_processor_role" {

  name = "${var.project_name}-${var.environment}-fraud-processor-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json

  tags = var.tags
}



/*
===============================================================================
Kinesis Read Permissions
===============================================================================

The fraud-processing Lambda consumes records from
Amazon Kinesis Data Streams.

To consume records, Lambda requires permissions to:

- read stream records
- retrieve shard iterators
- inspect shard metadata

These permissions are intentionally scoped ONLY to the
specific transaction ingestion stream.

This follows least-privilege principles.

===============================================================================
*/

/* removing temporarily
data "aws_iam_policy_document" "kinesis_access_policy" {

  statement {

    sid = "KinesisReadAccess"

    effect = "Allow"

    actions = [

      "kinesis:GetRecords",

      "kinesis:GetShardIterator",

      "kinesis:DescribeStream",

      "kinesis:DescribeStreamSummary",

      "kinesis:ListShards"
    ]

    resources = [
      var.kinesis_stream_arn
    ]
  }
}


*/


/*
===============================================================================
DynamoDB Write Permissions
===============================================================================

Fraudulent transactions are written into DynamoDB for
operational fraud investigation workflows.

The Lambda processor only requires write access.

It does NOT require:

- table deletion
- schema modification
- table administration
- full database access

Permissions are intentionally restricted to the specific
fraud alerts table.

===============================================================================
*/

/*removing temporarily
data "aws_iam_policy_document" "dynamodb_access_policy" {

  statement {

    sid = "DynamoDBWriteAccess"

    effect = "Allow"

    actions = [

      "dynamodb:PutItem"
    ]

    resources = [
      var.dynamodb_table_arn
    ]
  }
}

*/



/*
===============================================================================
S3 Archive Permissions
===============================================================================

All processed transaction records are archived into
the raw S3 data lake.

The Lambda processor only requires permission to:

- upload objects into the archive bucket

The role does NOT require:

- bucket deletion
- lifecycle modification
- bucket policy changes
- full S3 administrative access

===============================================================================
*/
/*removing temporarily
data "aws_iam_policy_document" "s3_access_policy" {

  statement {

    sid = "S3ArchiveWriteAccess"

    effect = "Allow"

    actions = [

      "s3:PutObject"
    ]

    resources = [
      "${var.s3_bucket_arn}/*"
    ]
  }
}

*/










/*
===============================================================================
CloudWatch Logging Permissions
===============================================================================

Lambda automatically emits execution logs into CloudWatch Logs.

Without these permissions:

- Lambda logs would fail
- operational debugging becomes impossible
- observability disappears

Logging permissions are foundational operational requirements
for production serverless systems.

===============================================================================
*/

data "aws_iam_policy_document" "cloudwatch_logs_policy" {

  statement {

    sid = "CloudWatchLogsAccess"

    effect = "Allow"

    actions = [

      "logs:CreateLogGroup",

      "logs:CreateLogStream",

      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}









/*
===============================================================================
KMS Permissions
===============================================================================

Several platform services use SSE-KMS encryption:

- S3 object encryption
- Kinesis stream encryption
- DynamoDB encryption

Although Lambda may not directly invoke KMS APIs itself,
AWS managed services internally call KMS during encrypted
operations.

Important example:

S3 PutObject with SSE-KMS:
        ↓
S3 internally calls:
kms:GenerateDataKey

Without these permissions:

- encrypted writes fail
- encrypted reads fail
- downstream services break

===============================================================================
*/

data "aws_iam_policy_document" "kms_access_policy" {

  statement {

    sid = "KMSUsageAccess"

    effect = "Allow"

    actions = [

      "kms:Decrypt",

      "kms:GenerateDataKey"
    ]

    resources = [
      var.kms_key_arn
    ]
  }
}



/* Up until now:

the role exists
the policy documents exist

BUT:
the role still has no effective permissions.
IAM policies only become active after attachment.

*/
/*
===============================================================================
Kinesis IAM Policy Resource
===============================================================================

This resource converts the Terraform-generated policy document
into an actual AWS IAM policy object.

The policy grants least-privilege read access to the
transaction ingestion Kinesis stream.

===============================================================================
*/

/*removing temporarily
resource "aws_iam_policy" "kinesis_access_policy" {

  name = "${var.project_name}-${var.environment}-kinesis-access-policy"

  description = "Least-privilege Kinesis access policy for fraud processor Lambda"

  policy = data.aws_iam_policy_document.kinesis_access_policy.json

  tags = var.tags
}

*/

/*
===============================================================================
DynamoDB IAM Policy Resource
===============================================================================

This policy grants the Lambda fraud processor permission
to insert fraud alert records into DynamoDB.

Permissions are intentionally restricted to PutItem only.

===============================================================================
*/
/*remove temporarily
resource "aws_iam_policy" "dynamodb_access_policy" {

  name = "${var.project_name}-${var.environment}-dynamodb-access-policy"

  description = "Least-privilege DynamoDB write policy for fraud processor Lambda"

  policy = data.aws_iam_policy_document.dynamodb_access_policy.json

  tags = var.tags
}

*/


/*
===============================================================================
S3 IAM Policy Resource
===============================================================================

This policy grants the Lambda fraud processor permission
to archive processed transaction records into the S3 data lake.

Access is restricted to object uploads only.

===============================================================================
*/
/*remove temporarily
resource "aws_iam_policy" "s3_access_policy" {

  name = "${var.project_name}-${var.environment}-s3-access-policy"

  description = "Least-privilege S3 archive write policy for fraud processor Lambda"

  policy = data.aws_iam_policy_document.s3_access_policy.json

  tags = var.tags
}

*/

/*
===============================================================================
CloudWatch IAM Policy Resource
===============================================================================

This policy grants Lambda permission to emit execution logs
into Amazon CloudWatch Logs.

Operational observability depends on these permissions.

===============================================================================
*/

resource "aws_iam_policy" "cloudwatch_logs_policy" {

  name = "${var.project_name}-${var.environment}-cloudwatch-logs-policy"

  description = "CloudWatch logging policy for fraud processor Lambda"

  policy = data.aws_iam_policy_document.cloudwatch_logs_policy.json

  tags = var.tags
}



/*
===============================================================================
KMS IAM Policy Resource
===============================================================================

This policy grants Lambda permission to interact with
KMS-protected AWS resources.

This is required for SSE-KMS encrypted operations involving:

- S3
- Kinesis
- DynamoDB

===============================================================================
*/

resource "aws_iam_policy" "kms_access_policy" {

  name = "${var.project_name}-${var.environment}-kms-access-policy"

  description = "KMS usage policy for fraud processor Lambda"

  policy = data.aws_iam_policy_document.kms_access_policy.json

  tags = var.tags
}







/*
===============================================================================
Attach Kinesis Access Policy To Lambda Role
===============================================================================

This attachment activates the Kinesis read permissions
for the Lambda execution role.

Without this attachment:

- the policy exists
- the role exists
- but the role receives NO permissions

IAM permissions only become effective after attachment.

===============================================================================
*/

/*remove temporarily
resource "aws_iam_role_policy_attachment" "kinesis_policy_attachment" {

  role = aws_iam_role.fraud_processor_role.name

  policy_arn = aws_iam_policy.kinesis_access_policy.arn
}

*/

/*
===============================================================================
Attach DynamoDB Access Policy To Lambda Role
===============================================================================
*/

/*remove temporarily

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {

  role = aws_iam_role.fraud_processor_role.name

  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

*/

/*
===============================================================================
Attach S3 Access Policy To Lambda Role
===============================================================================
*/

/*remove temporarily
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {

  role = aws_iam_role.fraud_processor_role.name

  policy_arn = aws_iam_policy.s3_access_policy.arn
}

*/


/*
===============================================================================
Attach CloudWatch Logs Policy To Lambda Role
===============================================================================
*/

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {

  role = aws_iam_role.fraud_processor_role.name

  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}



/*
===============================================================================
Attach KMS Access Policy To Lambda Role
===============================================================================
*/

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {

  role = aws_iam_role.fraud_processor_role.name

  policy_arn = aws_iam_policy.kms_access_policy.arn
}

