# `Phase3A_KMS_Module_Environment_Deployment_README.md`

````md id="v6f4tw"
# Phase 3 — Governed Core Infrastructure
# KMS Module & Environment Deployment

# Real-Time Fraud Detection Platform

---

# Objective

The objective of this phase was to establish the centralized encryption
foundation for the platform using AWS KMS and Terraform.

This phase introduced:

- reusable Terraform module architecture
- environment-based infrastructure deployment
- Customer Managed KMS governance
- Terraform module composition
- remote backend consumption
- centralized tagging standards
- production-grade encryption practices

This implementation intentionally mirrors how enterprise cloud platform
teams engineer governed Infrastructure as Code systems.

---

# Why KMS Was Built First

The platform follows a governance-first architecture.

Encryption dependencies must exist before downstream infrastructure is created.

Several future AWS services depend on KMS encryption:

| Service | Encryption Usage |
|---|---|
| Amazon Kinesis | Stream encryption |
| Amazon S3 | SSE-KMS object encryption |
| Amazon DynamoDB | Table encryption |
| CloudWatch Logs | Log encryption |
| AWS Lambda | Environment variable encryption |

Building KMS first prevents:

- infrastructure refactoring later
- encryption retrofitting
- policy complexity
- operational inconsistency

This mirrors real enterprise dependency ordering.

---

# Architecture Introduced In This Phase

```text
Terraform Environment Layer
            ↓
Reusable Terraform Module
            ↓
AWS KMS Infrastructure
            ↓
Remote Terraform State Tracking
````

---

# Engineering Concepts Introduced

This phase introduced several critical production-grade Infrastructure as Code concepts:

* Terraform reusable modules
* environment layering
* remote Terraform backend usage
* Terraform state management
* centralized encryption governance
* module abstraction
* Terraform outputs
* shared tagging standards
* Infrastructure as Code scalability

---

# Repository Structure

## Reusable Module Layer

```text
infrastructure/
└── terraform/
    └── modules/
        └── kms/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            ├── versions.tf
            └── README.md
```

---

## Deployable Environment Layer

```text
infrastructure/
└── terraform/
    └── environments/
        └── dev/
            ├── backend.tf
            ├── providers.tf
            ├── versions.tf
            ├── variables.tf
            ├── terraform.tfvars
            ├── locals.tf
            ├── main.tf
            └── outputs.tf
```

---

# Important Terraform Architecture Principle

This phase introduced one of the most important Terraform engineering concepts:

| Layer         | Responsibility                          |
| ------------- | --------------------------------------- |
| modules/      | reusable infrastructure building blocks |
| environments/ | actual deployable infrastructure        |

Terraform modules are NOT deployed directly.

Instead:

```text
Environment Layer
        ↓
Calls Reusable Modules
        ↓
Modules Provision AWS Resources
```

This architecture enables:

* multi-environment deployments
* reusable infrastructure
* CI/CD scalability
* governance standardization

This is how enterprise Terraform systems are structured.

---

# KMS Module Implementation

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

Production Infrastructure as Code requires deterministic behavior.

Without version pinning:

* provider behavior may change
* Terraform execution may differ between engineers
* CI/CD deployments may become unstable
* infrastructure drift risks increase

Version pinning guarantees reproducible deployments.

---

# variables.tf

```hcl
variable "project_name" {

  description = "Short project identifier used in resource naming"

  type = string
}

variable "environment" {

  description = "Deployment environment"

  type = string
}

variable "kms_key_description" {

  description = "Human-readable description for the KMS key"

  type = string
}

variable "deletion_window_in_days" {

  description = "Waiting period before KMS key deletion"

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

# Why Variables Matter

Variables make Terraform modules reusable.

Instead of hardcoding values:

* project identifiers
* environments
* descriptions
* governance tags

the environment layer dynamically injects values into the module.

This enables:

* dev deployments
* stage deployments
* prod deployments

using the same reusable infrastructure module.

---

# main.tf

```hcl
resource "aws_kms_key" "this" {

  description = var.kms_key_description

  enable_key_rotation = true

  deletion_window_in_days = var.deletion_window_in_days

  tags = var.tags
}

resource "aws_kms_alias" "this" {

  name = "alias/${var.project_name}-${var.environment}-core-kms"

  target_key_id = aws_kms_key.this.key_id
}
```

---

# Resource Explanation

---

## aws_kms_key

This resource provisions the Customer Managed KMS Key.

### Why Customer Managed Keys Were Chosen

The project intentionally uses:

# Customer Managed Keys (CMKs)

instead of default AWS-managed encryption.

This aligns with:

* enterprise banking systems
* PCI-style governance
* centralized security management
* auditability requirements

---

## enable_key_rotation

```hcl
enable_key_rotation = true
```

### Why Rotation Matters

Long-lived encryption keys increase security exposure.

Automatic rotation reduces risk if:

* credentials leak
* insider threats occur
* encryption material becomes compromised

This is considered a production-grade security best practice.

---

## deletion_window_in_days

```hcl
deletion_window_in_days = 30
```

### Why Delayed Deletion Matters

Deleting KMS keys is extremely dangerous.

If a KMS key is deleted:

* encrypted S3 objects become unreadable
* encrypted DynamoDB tables fail
* encrypted Kinesis streams break
* historical data may become unrecoverable

AWS therefore enforces delayed deletion windows.

30 days is a common enterprise-safe configuration.

---

## aws_kms_alias

This resource creates a readable operational alias.

Example:

```text
alias/rtfd-dev-core-kms
```

---

# Why Aliases Matter

KMS keys internally use UUIDs.

Example:

```text
63d9106a-a649-43e1-b9aa-b1a170ea5f79
```

Humans cannot efficiently operate infrastructure using UUIDs.

Aliases improve:

* debugging
* operational readability
* infrastructure management
* service integration clarity

---

# Environment Deployment Layer

The reusable module was deployed using the:

```text
environments/dev
```

root deployment layer.

---

# backend.tf

```hcl
terraform {

  backend "s3" {

    bucket = "rtfd-tf-state-us-east-1-519697923626"

    key = "dev/terraform.tfstate"

    region = "us-east-1"

    dynamodb_table = "rtfd-terraform-locks"

    encrypt = true
  }
}
```

---

# Why Remote Backend Was Required

Remote backend provides:

* centralized Terraform state
* distributed locking
* CI/CD compatibility
* collaboration safety
* state durability

This backend infrastructure was created during earlier Terraform bootstrap phases.

---

# providers.tf

```hcl
provider "aws" {

  region = var.aws_region

  default_tags {

    tags = local.common_tags
  }
}
```

---

# Why default_tags Matter

Enterprise infrastructure requires standardized tagging.

Terraform automatically injects governance tags into resources.

This improves:

* billing visibility
* governance
* operational filtering
* compliance reporting
* FinOps tracking

---

# locals.tf

```hcl
locals {

  common_tags = {

    Project = "Real-Time Fraud Detection"

    Environment = var.environment

    ManagedBy = "Terraform"

    Owner = var.owner

    CostCenter = "Fraud-Platform"

    Repository = "realtime_fraud_detection_platform"
  }
}
```

---

# Why Centralized Tags Matter

Centralized tagging ensures:

* governance consistency
* operational standardization
* maintainability
* resource discoverability

This is standard practice in enterprise cloud environments.

---

# Environment Module Deployment

## main.tf

```hcl
module "kms" {

  source = "../../modules/kms"

  project_name = var.project_name

  environment = var.environment

  kms_key_description = "Core encryption key for RTFD dev environment"

  tags = local.common_tags
}
```

---

# Why Module Composition Matters

This phase introduced:

# Terraform Module Composition

Meaning:

```text
Environment Layer
        ↓
Calls Module
        ↓
Module Creates AWS Resources
```

This enables:

* reusable infrastructure
* scalable environments
* cleaner IaC architecture
* standardized deployments

---

# outputs.tf

```hcl
output "kms_key_arn" {

  description = "ARN of deployed KMS key"

  value = module.kms.kms_key_arn
}

output "kms_alias_name" {

  description = "KMS alias name"

  value = module.kms.kms_alias_name
}
```

---

# Why Outputs Matter

Outputs expose infrastructure values for downstream infrastructure consumption.

Future services will consume:

* KMS ARN
* alias names
* encryption references

without hardcoded infrastructure dependencies.

---

# Terraform Commands Executed

```bash
terraform init

terraform fmt -recursive

terraform validate

terraform plan

terraform apply

terraform state list
```

---

# Successfully Created Infrastructure

Terraform successfully provisioned:

```text
module.kms.aws_kms_alias.this
module.kms.aws_kms_key.this
```

---

# Final Infrastructure Outputs

## KMS Alias

```text
alias/rtfd-dev-core-kms
```

---

## KMS ARN

```text
arn:aws:kms:us-east-1:519697923626:key/63d9106a-a649-43e1-b9aa-b1a170ea5f79
```

---

# Engineering Outcome Of This Phase

At the completion of this phase:

✅ Reusable Terraform module architecture exists
✅ Environment deployment layering exists
✅ Centralized KMS governance exists
✅ Remote backend consumption is operational
✅ Terraform module composition is functional
✅ Encryption-first infrastructure foundation exists
✅ Production-style Infrastructure as Code standards are established

The platform is now prepared for downstream encrypted infrastructure deployment.

---



# Next phase

# IAM Module & Least-Privilege Access Control

This phase will introduce:

* Lambda execution roles
* trust relationships
* IAM policy architecture
* least-privilege permissions
* Kinesis access permissions
* DynamoDB write permissions
* S3 archive permissions
* CloudWatch logging access

This is where enterprise AWS security engineering begins.


