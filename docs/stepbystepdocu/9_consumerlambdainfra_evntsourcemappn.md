# Lambda Infrastructure & Event-Driven Stream Processing


---

# Objective

The objective of this phase was to establish the serverless compute layer of the platform using AWS Lambda, Amazon Kinesis Data Streams, and Terraform.

This phase officially transformed the platform from:

```text
Streaming Infrastructure
```

into:

```text
Real-Time Event-Driven Fraud Processing Architecture
```

This implementation introduced:

* reusable Terraform Lambda module architecture
* event-driven serverless compute
* Kinesis Event Source Mapping
* CloudWatch operational logging foundations
* Lambda runtime configuration
* deployment artifact packaging
* managed stream consumption
* environment-based infrastructure orchestration
* and production-style stream-processing infrastructure engineering

This implementation intentionally mirrors how enterprise financial platforms engineer scalable real-time fraud-processing systems using serverless event-driven architecture.

---

# Final Architecture After This Phase

```text
Python Transaction Producer
        ↓
Amazon Kinesis Data Stream
        ↓
Kinesis Event Source Mapping
        ↓
AWS Lambda Fraud Processor
       ├── DynamoDB Fraud Store
       └── S3 Historical Archive
```

At this stage, the platform officially supports:

* real-time streaming ingestion
* managed batch stream processing
* serverless event-driven compute
* operational observability
* and scalable fraud-processing infrastructure.

---

# Why Lambda Was Introduced

The platform already contained:

| Component           | Purpose                           |
| ------------------- | --------------------------------- |
| Kinesis Data Stream | Distributed ingestion backbone    |
| DynamoDB            | Operational fraud-serving layer   |
| S3                  | Historical analytical archive     |
| IAM                 | Least-privilege security model    |
| KMS                 | Centralized encryption governance |

However:

```text
No processing engine existed yet.
```

Events were entering the stream continuously, but no system was consuming, validating, enriching, or routing them.

AWS Lambda was introduced as the:

* stream consumer
* fraud-processing engine
* event enrichment layer
* operational routing component
* and real-time compute layer

for the fraud detection platform.

---

# Important Architecture Principle

The Lambda processor is intentionally engineered as:

# A Stream Processor

NOT:

* a workflow orchestrator
* an analytics engine
* a batch ETL platform
* or a long-running application server.

Its responsibility is intentionally narrow:

```text
ingest → process → enrich → route
```

This separation of responsibilities mirrors real enterprise streaming architectures.

---

# Repository Structure

## Reusable Terraform Module Layer

```text
infrastructure/
└── terraform/
    └── modules/
        └── lambda/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── versions.tf
```

---

## Lambda Application Layer

```text
applications/
└── fraud_processor_lambda/
    ├── handler.py
    └── lambda_function.zip
```

---

# Engineering Concepts Introduced

This phase introduced several critical production-grade serverless engineering concepts:

* AWS Lambda infrastructure provisioning
* event-driven compute architecture
* Kinesis Event Source Mapping
* managed stream polling
* Lambda deployment artifacts
* CloudWatch operational logging
* runtime environment configuration
* Terraform dependency graph chaining
* Lambda deployment lifecycle management
* batch stream processing
* serverless observability foundations
* infrastructure vs application separation
* and immutable deployment packaging.

---

# Important Serverless Architecture Principle

This phase intentionally separated:

| Layer                | Responsibility                     |
| -------------------- | ---------------------------------- |
| Infrastructure Layer | Lambda infrastructure provisioning |
| Application Layer    | Fraud-processing business logic    |

This distinction is extremely important.

Terraform provisions:

* Lambda compute infrastructure
* event source mapping
* runtime configuration
* logging infrastructure
* IAM integration
* operational settings

The application code itself evolves independently later.

This mirrors real CI/CD-oriented enterprise deployments.

---

# Why Lambda Deployment Artifacts Were Required

One of the most important concepts introduced during this phase was:

# Lambda Deployment Artifacts

AWS Lambda cannot be created without executable application code.

Terraform therefore requires:

```text
an existing deployment package
```

before the Lambda resource can be provisioned.

---

# What Is A Deployment Artifact?

A deployment artifact is:

# The packaged executable application uploaded to AWS Lambda

For Python Lambda functions, this artifact is typically:

```text
lambda_function.zip
```

The ZIP package contains:

* handler code
* application modules
* dependencies
* configuration assets
* and executable runtime files.

Example:

```text
lambda_function.zip
    ├── handler.py
    ├── fraud_rules.py
    ├── validators.py
    └── dependencies
```

---

# Why Placeholder Code Was Used

At this stage, the platform infrastructure was being provisioned before the full fraud-processing logic existed.

However, AWS Lambda still requires:

```text
some executable deployment package
```

Therefore a minimal placeholder handler was temporarily created.

---

# Temporary Bootstrap Handler

## handler.py

```python

def lambda_handler(event, context):

    return {
        "statusCode": 200,
        "body": "Fraud processor initialized"
    }
```

---

# Why This Bootstrap Pattern Matters

This mirrors real enterprise deployment sequencing.

Typical production flow:

```text
Step 1:
Provision infrastructure

Step 2:
Deploy initial artifact

Step 3:
CI/CD pipelines continuously update artifacts later
```

Infrastructure and application logic evolve independently.

---

# Lambda Deployment Package Creation

The deployment artifact was packaged using:

```bash
cd applications/fraud_processor_lambda

zip lambda_function.zip handler.py
```

---

# Why ZIP Packaging Matters

The ZIP artifact becomes:

# An Immutable Deployment Package

Meaning:

AWS executes exactly what was uploaded.

This enables:

* deterministic deployments
* reproducibility
* rollback capability
* CI/CD compatibility
* versioned deployments
* and operational consistency.

---

# Lambda Terraform Module Implementation

---

# versions.tf

```hcl
terraform {

  required_version = "~> 1.14.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

---

# Why Version Pinning Matters

Infrastructure-as-Code requires deterministic deployments.

Version pinning guarantees:

* provider consistency
* stable CI/CD execution
* reproducible deployments
* and reduced infrastructure drift.

---

# variables.tf

```hcl
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
```

---

# Why Variables Matter

The Lambda module was intentionally designed to remain reusable across:

* dev
* stage
* prod

without hardcoded deployment assumptions.

The environment layer dynamically injects:

* IAM identity
* stream references
* storage destinations
* operational tuning
* governance tags
* and runtime settings.

This mirrors scalable enterprise Terraform architecture.

---

# main.tf

---

# Local Naming Logic

```hcl
locals {

  lambda_function_name = "${var.project_name}-${var.environment}-${var.lambda_function_name_suffix}"
}
```

Final Lambda function name:

```text
rtfd-dev-fraud-processor-lambda
```

---

# Why Naming Standards Matter

Consistent naming improves:

* operational readability
* governance
* environment isolation
* observability
* and infrastructure discoverability.

This mirrors real enterprise cloud naming strategies.

---

# CloudWatch Log Group

```hcl
resource "aws_cloudwatch_log_group" "this" {

  name = "/aws/lambda/${local.lambda_function_name}"

  retention_in_days = 14

  tags = var.tags
}
```

---

# Why CloudWatch Log Groups Matter

AWS Lambda is fully serverless.

Operators cannot SSH into Lambda environments or inspect local filesystems.

Instead, Lambda automatically forwards:

* stdout
* stderr
* logger output
* print statements
* and exceptions

into:

# Amazon CloudWatch Logs

The log group therefore becomes:

```text
centralized operational visibility for Lambda execution
```

---

# Why Explicit Log Groups Were Created

AWS can auto-create Lambda log groups.

However, enterprise environments intentionally provision them explicitly because teams require:

* retention management
* governance control
* predictable naming
* operational consistency
* future encryption support
* and lifecycle management.

---

# Why Log Retention Was Configured

```hcl
retention_in_days = 14
```

Without retention management:

```text
logs may accumulate indefinitely
```

which can create:

* unnecessary storage costs
* governance issues
* noisy environments
* and operational clutter.

---

# Lambda Function Resource

```hcl
resource "aws_lambda_function" "this" {

  function_name = local.lambda_function_name

  role = var.lambda_role_arn

  runtime = "python3.12"

  handler = "handler.lambda_handler"

  filename = "../../../../applications/fraud_processor_lambda/lambda_function.zip"

  source_code_hash = filebase64sha256(
    "../../../../applications/fraud_processor_lambda/lambda_function.zip"
  )

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
```

---

# Resource Architecture Explanation

---

# runtime = "python3.12"

This configures the Lambda execution runtime.

AWS Lambda supports multiple runtimes including:

* Python
* Node.js
* Java
* Go
* .NET
* and custom runtimes.

Python 3.12 was intentionally selected because it aligns with:

* modern Python support
* production compatibility
* current AWS runtime standards
* and the local development environment.

---

# handler = "handler.lambda_handler"

This tells AWS Lambda:

```text
which Python function acts as the Lambda entrypoint
```

Breakdown:

| Component      | Meaning              |
| -------------- | -------------------- |
| handler        | Python file          |
| lambda_handler | Function inside file |

Meaning:

```text
handler.py
        ↓
lambda_handler()
```

---

# filename

```hcl
filename = "../../../../applications/fraud_processor_lambda/lambda_function.zip"
```

This points Terraform to the deployment artifact.

Terraform uploads this package directly into AWS Lambda during provisioning.

---

# source_code_hash

```hcl
source_code_hash = filebase64sha256(...)
```

This is one of the most important real-world Lambda deployment concepts.

Terraform uses this hash to detect:

```text
application artifact changes
```

Without this hash:

Terraform may fail to redeploy updated Lambda packages.

This ensures:

* deployment consistency
* artifact version tracking
* CI/CD correctness
* and deterministic updates.

---

# timeout

```hcl
timeout = 60
```

This controls:

```text
maximum Lambda execution duration
```

The fraud processor may later perform:

* batch processing
* DynamoDB writes
* S3 archival
* payload validation
* and fraud scoring.

60 seconds provides safe operational headroom for future batch workloads.

---

# memory_size

```hcl
memory_size = 512
```

Lambda memory directly impacts:

* CPU allocation
* processing throughput
* execution performance
* and runtime efficiency.

512 MB provides reasonable operational capacity for the current workload while remaining cost-efficient.

---

# Runtime Environment Variables

```hcl
environment {

  variables = {

    DYNAMODB_TABLE_NAME = var.dynamodb_table_name

    S3_ARCHIVE_BUCKET = var.s3_bucket_name
  }
}
```

---

# Why Runtime Configuration Matters

Production systems should NEVER hardcode:

* table names
* bucket names
* deployment values
* environment-specific configuration
* or infrastructure references.

Instead:

Terraform injects configuration dynamically into the runtime environment.

This enables:

* portability
* multi-environment deployments
* CI/CD compatibility
* operational flexibility
* and reusable application code.

---

# depends_on

```hcl
depends_on = [
  aws_cloudwatch_log_group.this
]
```

This ensures:

```text
CloudWatch logging infrastructure exists before Lambda deployment
```

This avoids race conditions during initial Lambda startup.

---

# Event Source Mapping

```hcl
resource "aws_lambda_event_source_mapping" "kinesis_trigger" {

  event_source_arn = var.kinesis_stream_arn

  function_name = aws_lambda_function.this.arn

  starting_position = "LATEST"

  batch_size = 100

  maximum_batching_window_in_seconds = 5

  enabled = true
}
```

---

# Most Important Concept Introduced

This resource introduced one of the most powerful AWS serverless streaming abstractions:

# Event Source Mapping

Event Source Mapping creates:

```text
managed stream consumption
```

between:

```text
Kinesis Stream
        ↓
Lambda Consumer
```

WITHOUT writing custom polling infrastructure.

---

# What AWS Automatically Manages

Once Event Source Mapping exists, AWS automatically handles:

* shard polling
* batch retrieval
* checkpoint tracking
* retries
* scaling
* consumer coordination
* invocation management
* and stream consumption lifecycle.

This is one of the most important abstractions in serverless streaming systems.

---

# starting_position = "LATEST"

Meaning:

```text
process only NEW incoming events
```

Historical retained records are ignored during initial deployment.

This is operationally appropriate for:

* first-time deployment
* avoiding historical replay
* controlled environment activation
* and clean stream onboarding.

---

# batch_size = 100

Lambda retrieves:

```text
up to 100 records per invocation
```

This improves:

* throughput efficiency
* cost optimization
* batch processing performance
* and invocation scalability.

Without batching:

```text
1 Lambda invocation per record
```

would create excessive invocation overhead.

---

# maximum_batching_window_in_seconds

```hcl
maximum_batching_window_in_seconds = 5
```

This allows Lambda to wait briefly while accumulating stream records into batches.

This improves:

* processing efficiency
* batching throughput
* and operational cost optimization.

---

# outputs.tf

```hcl
output "lambda_function_name" {

  description = "Fraud processor Lambda function name"

  value = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {

  description = "Fraud processor Lambda ARN"

  value = aws_lambda_function.this.arn
}
```

---

# Why Outputs Matter

Outputs expose infrastructure values for:

* CI/CD pipelines
* operational tooling
* monitoring systems
* future integrations
* and downstream Terraform modules.

This transforms the Lambda module into a reusable infrastructure component.

---

# Environment Layer Integration

## environments/dev/main.tf

```hcl
module "lambda" {

  source = "../../modules/lambda"

  project_name = var.project_name

  environment = var.environment

  lambda_role_arn = module.iam.fraud_processor_role_arn

  kinesis_stream_arn = module.kinesis.stream_arn

  s3_bucket_name = module.s3.bucket_name

  dynamodb_table_name = module.dynamodb.table_name

  tags = local.common_tags
}
```

---

# Terraform Dependency Graph Chaining

This phase reinforced one of the most important Terraform concepts:

# Infrastructure Dependency Graphs

The Lambda module now consumes outputs from:

```text
IAM Module
      ↓
Kinesis Module
      ↓
S3 Module
      ↓
DynamoDB Module
```

Terraform automatically understands:

```text
all upstream infrastructure must exist before Lambda deployment
```

without manual orchestration.

This is one of Terraform’s most powerful capabilities.

---

# Terraform Plan Validation

Terraform successfully planned creation of:

```text
module.lambda.aws_cloudwatch_log_group.this
module.lambda.aws_lambda_function.this
module.lambda.aws_lambda_event_source_mapping.kinesis_trigger
```

This confirmed:

* correct dependency resolution
* valid deployment artifact packaging
* successful IAM integration
* proper Kinesis linkage
* and production-correct infrastructure orchestration.

---

# Operational Validation Achieved

The infrastructure now supports:

✅ Managed Kinesis stream polling
✅ Serverless event-driven compute
✅ CloudWatch operational logging
✅ Runtime configuration injection
✅ Deployment artifact management
✅ Batch stream processing
✅ Environment-aware deployment architecture
✅ Production-style serverless observability foundations

---

# Engineering Concepts Learned During This Phase

This phase introduced several critical production-grade serverless engineering concepts:

* Lambda deployment artifacts
* immutable deployment packaging
* event-driven compute architecture
* Kinesis Event Source Mapping
* managed stream polling
* CloudWatch operational logging
* runtime environment configuration
* Lambda batch processing
* Terraform dependency orchestration
* deployment hash tracking
* and infrastructure/application separation.

---

# Engineering Outcome Of This Phase

At the completion of this phase:

✅ Lambda infrastructure exists
✅ Event Source Mapping is operational
✅ CloudWatch logging infrastructure exists
✅ Runtime configuration injection is functioning
✅ Managed stream consumption is enabled
✅ Lambda deployment packaging is operational
✅ Batch processing infrastructure exists
✅ Production-style serverless architecture is established

The platform now officially supports:

* real-time stream consumption
* event-driven compute
* scalable batch processing
* operational observability
* and managed serverless fraud-processing infrastructure.

---

# Next Phase

# Phase 5C — Real Fraud Processing Logic

This phase will introduce:

* Kinesis record decoding
* payload validation
* fraud rule evaluation
* event enrichment
* DynamoDB fraud writes
* S3 archival writes
* structured JSON logging
* batch processing logic
* retry behavior
* partial failure handling
* and real-time fraud scoring workflows.

The platform will officially evolve from:

```text
Serverless Stream Infrastructure
```

into:

# A Real-Time Fraud Detection Engine
