# Governed S3 Data Lake Infrastructure


---

# Objective

The objective of this phase was to establish the governed historical archive layer of the platform using Amazon S3 and Terraform.

This phase introduced:

* reusable Terraform S3 module architecture
* governed S3 bucket provisioning
* SSE-KMS encryption integration
* bucket policy enforcement
* lifecycle management
* analytical partition strategy
* environment-layer module composition
* production-grade S3 governance practices

This implementation intentionally mirrors how enterprise cloud platform teams engineer secure and governed data lake foundations.

---

# Why S3 Was Introduced At This Stage

The platform architecture separates:

* operational processing
* analytical storage
* governance controls
* and downstream analytics

Amazon S3 acts as the:

* historical fraud archive
* audit retention layer
* analytical data lake
* Athena source
* Glue catalog source
* and long-term transaction storage layer

Future Lambda fraud processors will continuously archive processed transactions into S3.

Architecture flow:

```text
Producer
    ↓
Kinesis Stream
    ↓
Lambda Fraud Processor
       ├── DynamoDB (Operational Fraud Store)
       └── S3 Archive (Historical Data Lake)
```

This sequencing was intentionally chosen because:

* Lambda archival logic depends on S3 existing first
* IAM least-privilege policies require real bucket ARNs
* analytical partition structure must be designed early
* governance controls should exist before ingestion begins

This mirrors real enterprise infrastructure dependency ordering.

---

# Repository Structure

## Reusable Module Layer

```text
infrastructure/
└── terraform/
    └── modules/
        └── s3/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            ├── versions.tf
            └── README.md
```

---

## Environment Deployment Layer

```text
infrastructure/
└── terraform/
    └── environments/
        └── dev/
            ├── main.tf
            ├── outputs.tf
            ├── variables.tf
            └── terraform.tfvars
```

---

# Engineering Concepts Introduced

This phase introduced several critical production-grade cloud engineering concepts:

* governed S3 architecture
* Terraform module composition
* analytical data lake design
* bucket policy architecture
* SSE-KMS enforcement
* lifecycle optimization
* resource-based security
* Terraform dependency chaining
* environment-layer orchestration
* partition-aware data lake planning

---

# S3 Module Implementation

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

Production Infrastructure as Code requires deterministic deployments.

Version pinning prevents:

* inconsistent provider behavior
* CI/CD instability
* Terraform drift
* deployment incompatibilities

This ensures all engineers and pipelines execute infrastructure consistently.

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

variable "account_id" {

  description = "AWS account ID for globally unique bucket naming"

  type = string
}

variable "kms_key_arn" {

  description = "KMS key ARN used for bucket encryption"

  type = string
}

variable "lifecycle_transition_days" {

  description = "Days before transitioning objects to Intelligent-Tiering"

  type = number

  default = 30
}

variable "tags" {

  description = "Common resource tags"

  type = map(string)

  default = {}
}
```

---

# Why These Variables Matter

The module was intentionally designed to remain reusable across:

* dev
* stage
* prod

without hardcoded values.

The `account_id` variable is especially important because:

* S3 bucket names are globally unique
* enterprise naming standards require predictable structure

Example final naming convention:

```text
rtfd-dev-raw-archive-519697923626
```

---

# main.tf

```hcl
locals {

  bucket_name = "${var.project_name}-${var.environment}-raw-archive-${var.account_id}"
}

resource "aws_s3_bucket" "this" {

  bucket = local.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {

  bucket = aws_s3_bucket.this.id

  rule {

    apply_server_side_encryption_by_default {

      kms_master_key_id = var.kms_key_arn

      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {

  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {

  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {

  bucket = aws_s3_bucket.this.id

  rule {

    id = "archive-transition-rule"

    status = "Enabled"

    transition {

      days = var.lifecycle_transition_days

      storage_class = "INTELLIGENT_TIERING"
    }

    filter {
      prefix = ""
    }
  }
}
```

---

# Resource Architecture Explanation

## S3 Bucket

The bucket acts as the platform’s governed historical archive layer.

Future workloads include:

* fraud investigations
* Athena analytical queries
* Glue catalog integration
* audit retention
* historical replay scenarios

---

## SSE-KMS Encryption

The bucket uses:

```text
aws:kms
```

with the previously provisioned centralized KMS key.

This ensures:

* centralized encryption governance
* auditability
* controlled access
* PCI-style security posture

The bucket dynamically consumes the KMS ARN from the KMS module output.

---

## Versioning

Bucket versioning was enabled to protect against:

* accidental overwrites
* object corruption
* malicious deletion
* operational mistakes

This is a common enterprise-grade data protection mechanism.

---

## Public Access Block

All public access vectors were explicitly disabled.

This prevents:

* accidental exposure
* public ACL usage
* insecure bucket policies
* governance violations

This is considered foundational cloud security hygiene.

---

## Ownership Controls

The bucket enforces:

```text
BucketOwnerEnforced
```

This disables legacy ACL complexity and aligns with modern AWS best practices.

---

## Lifecycle Management

Objects transition to:

```text
INTELLIGENT_TIERING
```

after 30 days.

This introduces early FinOps practices by reducing long-term storage costs while preserving accessibility for fraud investigations and analytical workloads.

---

# Enterprise Bucket Policy Architecture

One of the most important governance implementations in this phase was resource-based policy enforcement.

Terraform-native policy documents were intentionally used instead of raw JSON.

---

# Bucket Policy Document

```hcl
data "aws_iam_policy_document" "bucket_policy" {

  statement {

    sid = "DenyInsecureTransport"

    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]

    condition {

      test = "Bool"

      variable = "aws:SecureTransport"

      values = ["false"]
    }
  }

  statement {

    sid = "DenyUnencryptedObjectUploads"

    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    condition {

      test = "StringNotEquals"

      variable = "s3:x-amz-server-side-encryption"

      values = ["aws:kms"]
    }
  }
}
```

---

# Governance Concepts Learned

## TLS Enforcement

The policy explicitly denies:

```text
non-HTTPS traffic
```

using:

```text
aws:SecureTransport = false
```

This ensures all access occurs over encrypted transport.

---

## Deny Unencrypted Uploads

The bucket rejects uploads unless:

```text
x-amz-server-side-encryption = aws:kms
```

This prevents accidental plaintext object uploads.

This is extremely important in regulated environments.

---

# Important IAM Concept Learned

This phase reinforced one of the most important AWS security principles:

# Explicit DENY Always Wins

Even if an IAM user or role has:

```text
s3:PutObject
```

the bucket policy still blocks insecure uploads.

This demonstrates the difference between:

| Security Layer  | Purpose              |
| --------------- | -------------------- |
| IAM Policies    | Identity permissions |
| Bucket Policies | Resource governance  |

---

# Module Outputs

## outputs.tf

```hcl
output "bucket_name" {

  description = "Name of the archive bucket"

  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {

  description = "ARN of the archive bucket"

  value = aws_s3_bucket.this.arn
}
```

---

# Why Module Outputs Matter

Terraform modules are isolated abstraction layers.

Outputs expose infrastructure values from:

```text
module internals
        ↓
environment orchestration layer
```

This enables:

* module composition
* infrastructure dependency chaining
* reusable architecture
* cross-module integration

---

# Environment Layer Integration

## main.tf

```hcl
module "s3" {

  source = "../../modules/s3"

  project_name = var.project_name

  environment = var.environment

  account_id = var.account_id

  kms_key_arn = module.kms.kms_key_arn

  tags = local.common_tags
}
```

---

# Terraform Dependency Chaining

One of the most important concepts learned in this phase:

```hcl
kms_key_arn = module.kms.kms_key_arn
```

This creates an implicit Terraform dependency graph:

```text
KMS Module
      ↓
S3 Module
      ↓
S3 Encryption Configuration
```

Terraform automatically understands deployment ordering without manual sequencing.

---

# Environment Outputs

```hcl
output "raw_archive_bucket_name" {

  description = "Name of the raw archive S3 bucket"

  value = module.s3.bucket_name
}

output "raw_archive_bucket_arn" {

  description = "ARN of the raw archive S3 bucket"

  value = module.s3.bucket_arn
}
```

---

# Why Environment Outputs Matter

Environment outputs expose deployed infrastructure to:

* operators
* CI/CD pipelines
* GitHub Actions
* deployment tooling
* downstream infrastructure

This establishes the environment layer as the operational deployment boundary.

---

# Important Architectural Understanding Achieved

A critical Terraform architecture distinction was learned during this phase:

| Layer        | Responsibility                   |
| ------------ | -------------------------------- |
| Modules      | Reusable infrastructure logic    |
| Environments | Actual infrastructure deployment |

Modules expose outputs to:

```text
other Terraform layers
```

Environment outputs expose infrastructure to:

```text
the external world
```

This reinforces enterprise Infrastructure-as-Code layering principles.

---

# Challenges Faced During This Phase

## 1. Terraform Variable Scope

Issue encountered:

```text
No declaration found for var.account_id
```

Root cause:

The environment layer attempted to pass:

```hcl
var.account_id
```

to the module without declaring the variable locally.

Resolution:

* variable added to `environments/dev/variables.tf`
* value added to `terraform.tfvars`

Concept learned:

```text
Terraform modules do NOT inherit variables automatically
```

Every Terraform layer must explicitly declare its own inputs.

---

## 2. Terraform Module Initialization

Issue encountered:

```text
Module not installed
```

Root cause:

A new module block was added after the previous Terraform initialization.

Resolution:

```bash
terraform init
```

was rerun to install and register the new module.

Concept learned:

Terraform must reinitialize whenever:

* modules change
* providers change
* backend configuration changes

---

# Terraform Commands Executed

```bash
terraform fmt -recursive infrastructure/

terraform init

terraform validate

terraform plan

terraform apply
```

---

# Successfully Created Infrastructure

Terraform successfully provisioned:

```text
aws_s3_bucket.this
aws_s3_bucket_versioning.this
aws_s3_bucket_server_side_encryption_configuration.this
aws_s3_bucket_public_access_block.this
aws_s3_bucket_ownership_controls.this
aws_s3_bucket_lifecycle_configuration.this
aws_s3_bucket_policy.this
```

---

# Final Infrastructure Outputs

## Archive Bucket Name

```text
rtfd-dev-raw-archive-519697923626
```

---

## Archive Bucket ARN

```text
arn:aws:s3:::rtfd-dev-raw-archive-519697923626
```

---

# Engineering Outcome Of This Phase

At the completion of this phase:

✅ Governed S3 data lake infrastructure exists
✅ SSE-KMS encryption is enforced
✅ TLS-only access enforcement exists
✅ Unencrypted uploads are blocked
✅ Lifecycle optimization is active
✅ Versioning protection is enabled
✅ Terraform module composition is operational
✅ Environment-layer orchestration is functioning
✅ Production-style S3 governance architecture is established

The platform now has a governed historical archive foundation prepared for:

* Kinesis ingestion
* Lambda archival writes
* Athena analytics
* Glue catalog integration
* and future governed analytical workloads.

---

# Next Phase

# Phase 3D — Kinesis Streaming Infrastructure

This phase will introduce:

* Amazon Kinesis Data Streams
* shard configuration
* stream encryption
* retention settings
* stream scalability concepts
* partition-key architecture
* producer integration preparation
* and real-time ingestion infrastructure.
