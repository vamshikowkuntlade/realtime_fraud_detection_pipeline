# DynamoDB Operational Fraud Store

# Real-Time Fraud Detection Platform

---

# Objective

The objective of this phase was to establish the low-latency operational fraud-serving layer of the platform using Amazon DynamoDB and Terraform.

This phase introduced:

- DynamoDB operational architecture
- partition-key engineering
- sort-key strategy
- operational vs analytical storage separation
- TTL lifecycle management
- SSE-KMS encryption integration
- point-in-time recovery
- reusable Terraform module architecture
- and production-grade NoSQL infrastructure engineering

This implementation intentionally mirrors how enterprise financial platforms engineer operational serving systems for fraud detection and event-driven workloads.

---

# Why DynamoDB Was Introduced

The platform architecture intentionally separates:

| Workload Type | Storage Layer |
|---|---|
| Real-time operational access | DynamoDB |
| Historical analytics & reporting | S3 + Athena |

This distinction is one of the most important modern data-platform architecture principles.

The fraud detection platform now maintains:

```text
Operational Serving Layer
            +
Historical Analytical Layer
```

---

# Why S3 Alone Was NOT Enough

Amazon S3 is optimized for:

- historical storage
- large-scale analytics
- Athena querying
- audit retention
- and batch analytical workloads

However, fraud systems require:

- millisecond lookups
- operational alert retrieval
- real-time serving
- event-based access
- and highly scalable transactional access patterns

DynamoDB solves these operational requirements.

---

# Final Operational Architecture

```text
Transaction Producer
        ↓
Amazon Kinesis Data Stream
        ↓
Lambda Fraud Processor
       ├── DynamoDB Fraud Store
       └── S3 Historical Archive
```

---

# Important Architectural Principle Learned

This phase introduced one of the most important enterprise data engineering concepts:

# Operational Storage vs Analytical Storage

| Operational Systems | Analytical Systems |
|---|---|
| DynamoDB | S3 + Athena |
| Millisecond lookups | Large-scale scans |
| Real-time serving | Historical analytics |
| Point retrieval | Aggregations |
| Transaction-oriented | Reporting-oriented |

This architectural separation mirrors real-world banking and fraud platforms.

---

# Repository Structure

## Reusable Module Layer

```text
infrastructure/
└── terraform/
    └── modules/
        └── dynamodb/
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

- DynamoDB table architecture
- partition-key engineering
- sort-key strategy
- NoSQL access-pattern design
- high-cardinality partitioning
- hot partition avoidance
- TTL lifecycle engineering
- point-in-time recovery
- operational serving architecture
- Terraform module composition
- centralized encryption governance
- environment-layer orchestration

---

# Important NoSQL Design Principle

Unlike relational databases:

```text
DynamoDB tables are designed around access patterns,
NOT normalization.
```

The first design question becomes:

```text
How will the application retrieve data?
```

---

# Fraud Alert Access Pattern

The operational workload requirement was:

```text
Retrieve fraud alerts for a specific transaction
```

This directly influenced the DynamoDB schema design.

---

# Final Table Schema

| Key Type | Attribute |
|---|---|
| Partition Key | transaction_id |
| Sort Key | timestamp |

---

# Why transaction_id Was Chosen

The partition key:

```text
transaction_id
```

provides:

- extremely high cardinality
- evenly distributed hashing
- scalable write distribution
- efficient operational retrieval
- hot partition avoidance

---

# Important DynamoDB Scaling Concept Learned

High cardinality means:

```text
large number of unique partition-key values
```

Example:

| Good Partition Key | Why |
|---|---|
| transaction_id | Millions of unique values |

| Bad Partition Key | Why |
|---|---|
| fraud_status | Only few repeating values |

Low-cardinality partition keys create:

# HOT PARTITIONS

where traffic becomes concentrated into a small number of physical partitions.

---

# Important DynamoDB Internal Architecture Learned

A very important concept clarified during this phase:

```text
1 partition key ≠ 1 physical partition
```

DynamoDB internally:

```text
partition key
      ↓
hash function
      ↓
mapped into AWS-managed physical partitions
```

Multiple partition-key values can live inside the same physical partition.

DynamoDB scaling depends on:

```text
traffic distribution
```

not:

```text
number of unique keys
```

---

# Why timestamp Was Chosen As Sort Key

The sort key:

```text
timestamp
```

enables:

- chronological ordering
- fraud-event timelines
- future workflow evolution
- replay visibility
- and multiple operational lifecycle states

Future fraud workflows may later evolve into:

| transaction_id | timestamp | status |
|---|---|---|
| tx123 | 10:01 | DETECTED |
| tx123 | 10:05 | ESCALATED |
| tx123 | 10:10 | RESOLVED |

This is why a composite-key design was intentionally selected.

---

# DynamoDB Capacity Mode Decision

DynamoDB supports:

| Mode | Behavior |
|---|---|
| PROVISIONED | Manual throughput engineering |
| PAY_PER_REQUEST | AWS-managed autoscaling |

The platform intentionally selected:

# PAY_PER_REQUEST

---

# Why PAY_PER_REQUEST Was Chosen

Fraud systems experience unpredictable and bursty workloads.

Example:

```text
Normal traffic:
50 alerts/minute

Fraud spike:
20,000 alerts/minute
```

On-demand mode automatically scales:

- reads
- writes
- throughput allocation

without manual capacity engineering.

This is operationally appropriate for fraud detection workloads.

---

# TTL Lifecycle Engineering

This phase introduced:

# DynamoDB Time To Live (TTL)

The table automatically expires operational fraud alerts after a configured retention period.

TTL attribute configured:

```text
expiry_time
```

---

# Important TTL Understanding Learned

TTL does NOT automatically mean:

```text
Delete records after 90 days
```

Instead:

DynamoDB requires:

```text
an attribute containing future expiration timestamp
```

The Lambda fraud processor dynamically enriches the event before storage:

```python
data['expiry_time'] = int(
    (datetime.utcnow() + timedelta(days=90)).timestamp()
)
```

This creates a future UNIX timestamp used by DynamoDB TTL processing.

---

# Event Enrichment Concept Learned

The Lambda processor progressively enriches streaming events before storage.

Example:

## Original Event

```json
{
  "transaction_id": "tx123",
  "amount": 4200,
  "location": "Mumbai"
}
```

---

## Enriched Event

```json
{
  "transaction_id": "tx123",
  "amount": 4200,
  "location": "Mumbai",
  "fraud_flag": true,
  "processed_at": "2026-05-18T10:00:00",
  "expiry_time": 1780000000
}
```

This introduced one of the most important streaming-system concepts:

# Event Enrichment

Pipeline stages progressively attach operational metadata over time.

---

# DynamoDB Terraform Module Implementation

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

Version pinning guarantees:

- deterministic infrastructure behavior
- stable CI/CD execution
- reproducible deployments
- provider consistency
- reduced deployment drift

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

variable "table_name_suffix" {

  description = "Business-purpose suffix for DynamoDB table naming"

  type = string

  default = "fraud-alerts-ddb"
}

variable "billing_mode" {

  description = "DynamoDB billing mode"

  type = string

  default = "PAY_PER_REQUEST"
}

variable "hash_key" {

  description = "Partition key for the DynamoDB table"

  type = string

  default = "transaction_id"
}

variable "range_key" {

  description = "Sort key for the DynamoDB table"

  type = string

  default = "timestamp"
}

variable "ttl_attribute_name" {

  description = "TTL attribute name for automatic item expiration"

  type = string

  default = "expiry_time"
}

variable "kms_key_arn" {

  description = "KMS key ARN used for DynamoDB encryption"

  type = string
}

variable "tags" {

  description = "Common governance tags"

  type = map(string)

  default = {}
}
```

---

# Why Variables Matter

The module was intentionally engineered to remain reusable across:

- dev
- stage
- prod

without hardcoded infrastructure assumptions.

This enables:

- scalable Terraform architecture
- reusable infrastructure composition
- environment-specific deployments
- operational flexibility

---

# main.tf

```hcl
locals {

  table_name = "${var.project_name}-${var.environment}-${var.table_name_suffix}"
}

resource "aws_dynamodb_table" "this" {

  name = local.table_name

  billing_mode = var.billing_mode

  hash_key  = var.hash_key

  range_key = var.range_key

  attribute {

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
```

---

# Resource Architecture Explanation

---

# Table Naming Logic

```hcl
locals {

  table_name = "${var.project_name}-${var.environment}-${var.table_name_suffix}"
}
```

Final table name:

```text
rtfd-dev-fraud-alerts-ddb
```

This maintains:

- governance consistency
- environment isolation
- operational readability
- enterprise naming standards

---

# DynamoDB Attributes Clarified

An important DynamoDB concept learned during this phase:

```text
attribute = field inside an item
```

Example:

```json
{
  "transaction_id": "tx123",
  "amount": 4200
}
```

Attributes:

- transaction_id
- amount

Unlike relational databases:

```text
DynamoDB does NOT require predefined columns
```

Only:

- partition key
- and sort key

must be declared in the schema.

Everything else remains schema-flexible.

---

# Why attribute {} Exists In Terraform

Example:

```hcl
attribute {

  name = var.hash_key

  type = "S"
}
```

This does NOT create a traditional relational column.

Instead it tells DynamoDB:

```text
"This attribute participates in table indexing/key structure."
```

---

# SSE-KMS Encryption

The table uses:

# SSE-KMS Encryption

with the previously provisioned centralized KMS key.

This aligns with:

- enterprise encryption governance
- PCI-style security practices
- centralized auditability
- and governance-first architecture

---

# Point-In-Time Recovery (PITR)

Point-in-time recovery was enabled:

```hcl
point_in_time_recovery {

  enabled = true
}
```

This provides:

- operational resilience
- accidental deletion recovery
- rollback capability
- and enterprise-grade disaster recovery protection

This is commonly enabled in production financial workloads.

---

# Terraform Dependency Graph Chaining

The environment layer integrates the module using:

```hcl
kms_key_arn = module.kms.kms_key_arn
```

This creates:

```text
KMS Module
      ↓
Exports KMS ARN
      ↓
DynamoDB Module Consumes ARN
```

Terraform automatically understands deployment ordering without manual orchestration.

---

# outputs.tf

```hcl
output "table_name" {

  description = "Name of the DynamoDB fraud alerts table"

  value = aws_dynamodb_table.this.name
}

output "table_arn" {

  description = "ARN of the DynamoDB fraud alerts table"

  value = aws_dynamodb_table.this.arn
}
```

---

# Why Outputs Matter

Outputs expose infrastructure values for:

- Lambda integration
- IAM policies
- CI/CD systems
- operational tooling
- downstream Terraform modules

This transforms Terraform modules into reusable infrastructure components.

---

# Environment Layer Integration

## environments/dev/main.tf

```hcl
module "dynamodb" {

  source = "../../modules/dynamodb"

  project_name = var.project_name

  environment = var.environment

  kms_key_arn = module.kms.kms_key_arn

  tags = local.common_tags
}
```

---

# Environment Outputs

## environments/dev/outputs.tf

```hcl
output "fraud_alerts_table_name" {

  description = "Name of the DynamoDB fraud alerts table"

  value = module.dynamodb.table_name
}

output "fraud_alerts_table_arn" {

  description = "ARN of the DynamoDB fraud alerts table"

  value = module.dynamodb.table_arn
}
```

---

# Terraform Commands Executed

```bash
terraform fmt -recursive

terraform init

terraform validate

terraform plan

terraform apply
```

---

# Successfully Created Infrastructure

Terraform successfully provisioned:

```text
module.dynamodb.aws_dynamodb_table.this
```

---

# Final Infrastructure Outputs

## DynamoDB Table Name

```text
rtfd-dev-fraud-alerts-ddb
```

---

# Engineering Challenges & Concepts Clarified

---

# 1. High Cardinality Misunderstanding

Initial confusion:

```text
Does every unique partition key create a new physical partition?
```

Clarification learned:

```text
NO.
```

DynamoDB internally hashes partition keys across AWS-managed physical partitions.

Multiple partition-key values can live inside the same physical partition.

---

# 2. Attribute Definition Misunderstanding

Initial confusion:

```text
Does attribute {} create relational columns?
```

Clarification learned:

```text
NO.
```

The attribute block only defines key/index-related attributes.

DynamoDB remains schema-flexible for non-key fields.

---

# 3. TTL Attribute Confusion

Initial confusion:

```text
Where does expiry_time come from?
```

Clarification learned:

The Lambda fraud processor dynamically enriches the event:

```python
data['expiry_time']
```

before writing to DynamoDB.

DynamoDB TTL then monitors this attribute for expiration.

---

# Kinesis vs DynamoDB Partitioning Clarification

An important distributed-systems distinction was reinforced during this phase.

Kinesis partition keys:

```python
PartitionKey=txn['card_number']
```

are used for:

- stream distribution
- ordering guarantees
- shard balancing

DynamoDB partition keys:

```text
transaction_id
```

are used for:

- operational retrieval
- scalable data distribution
- low-latency serving access

These are completely different architectural responsibilities.

---

# Engineering Outcome Of This Phase

At the completion of this phase:

✅ DynamoDB operational fraud store exists  
✅ Operational vs analytical separation is established  
✅ TTL lifecycle management is operational  
✅ PAY_PER_REQUEST autoscaling is active  
✅ SSE-KMS encryption is enforced  
✅ Point-in-time recovery is enabled  
✅ NoSQL access-pattern engineering was introduced  
✅ High-cardinality partitioning concepts were learned  
✅ Hot partition avoidance concepts were learned  
✅ Terraform module composition remains production-grade  

The platform now officially supports:

- real-time ingestion
- operational fraud serving
- historical analytics
- centralized governance
- and scalable event-driven architecture.

---

# Next Phase

# Phase 4 — Real-Time Transaction Producer

This phase will introduce:

- continuous streaming event generation
- Python producer engineering
- Kinesis producer integration
- partition-key strategy
- event schema design
- producer throughput concepts
- structured application design
- and live streaming architecture activation.

The platform will officially become:

# LIVE