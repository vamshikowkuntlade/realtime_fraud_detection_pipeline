#  Kinesis Streaming Infrastructure

# Real-Time Fraud Detection Platform

---

# Objective

The objective of this phase was to establish the real-time streaming ingestion backbone of the platform using Amazon Kinesis Data Streams and Terraform.

This phase introduced:

- reusable Terraform Kinesis module architecture
- governed streaming infrastructure
- shard-based throughput engineering
- centralized SSE-KMS encryption
- retention and replay configuration
- shard-level observability metrics
- environment-layer orchestration
- Terraform dependency graph chaining
- production-style streaming architecture practices

This implementation intentionally mirrors how enterprise cloud platform teams engineer scalable and governed event-streaming systems.

---

# Why Kinesis Was Introduced At This Stage

The platform architecture intentionally follows dependency-first infrastructure sequencing.

Before introducing streaming infrastructure, the platform already established:

| Component | Purpose |
|---|---|
| Terraform Remote Backend | Safe Infrastructure-as-Code operations |
| KMS Governance | Centralized encryption |
| IAM Foundation | Least-privilege access control |
| Governed S3 Data Lake | Historical archive foundation |

Only after governance foundations existed was the streaming layer introduced.

This mirrors real enterprise cloud engineering practices because streaming infrastructure depends heavily on:

- encryption governance
- IAM permissions
- observability foundations
- tagging standards
- environment isolation
- and operational consistency

---

# Final Streaming Architecture

```text
Transaction Producer
        ↓
Amazon Kinesis Data Stream
        ↓
Future Lambda Fraud Processor
```

The Kinesis stream now acts as the:

- ingestion backbone
- event buffering layer
- replay layer
- scaling layer
- and durable streaming transport system

for all future transaction events.

---

# Important Distributed Systems Concept

Kinesis Data Streams is NOT:

- a database
- a queue
- or analytical storage

Kinesis acts as:

# A Distributed Append-Only Event Stream

Its responsibility is to:

```text
ingest → retain → distribute events
```

Event processing itself will later occur inside AWS Lambda.

This architectural separation is one of the most important streaming-system principles.

---

# Why Kinesis Was Chosen Instead Of SQS

The fraud detection platform is fundamentally:

# A Real-Time Streaming System

Kinesis was selected because the architecture requires:

- ordered event ingestion
- replay capability
- multiple downstream consumers
- stream retention
- and continuous event processing

Comparison:

| Amazon SQS | Amazon Kinesis |
|---|---|
| Message queue | Distributed event stream |
| Usually single-consumer | Multi-consumer streaming |
| Limited replay | Strong replay capability |
| Task execution workloads | Streaming analytics workloads |
| Queue semantics | Ordered stream semantics |

Fraud detection systems require event chronology and replay capability, making Kinesis architecturally correct for this workload.

---

# Repository Structure

## Reusable Module Layer

```text
infrastructure/
└── terraform/
    └── modules/
        └── kinesis/
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

This phase introduced several critical production-grade streaming and Infrastructure-as-Code concepts:

- distributed streaming architecture
- shard-based throughput engineering
- replay-capable event ingestion
- partition-key architecture
- Terraform module abstraction
- Terraform dependency graph chaining
- centralized encryption governance
- environment-layer orchestration
- streaming observability
- stream retention strategy
- operational scaling principles

---

# Kinesis Architecture Decisions

---

# 1. Stream Mode Decision

Kinesis supports two stream modes:

| Mode | Behavior |
|---|---|
| Provisioned | Manual shard management |
| On-Demand | AWS-managed autoscaling |

The platform intentionally selected:

# PROVISIONED Mode

---

# Why Provisioned Mode Was Chosen

Although On-Demand mode simplifies operations, this project intentionally uses Provisioned mode to expose core streaming-engineering concepts such as:

- shard throughput planning
- scaling strategy
- hot partition behavior
- throughput bottlenecks
- and operational shard management

This provides deeper architectural understanding aligned with real-world streaming engineering.

---

# 2. Initial Shard Count Decision

Initial shard count:

```text
1
```

---

# Why Only One Shard Was Used

The current simulated producer workload is intentionally small.

Expected initial throughput:

```text
~10 transactions per second
```

Each Kinesis shard supports:

| Capability | Limit |
|---|---|
| Write throughput | 1 MB/sec |
| Write records | 1000 records/sec |
| Read throughput | 2 MB/sec |

A single shard is therefore more than sufficient for the current workload.

This reinforces an important production principle:

# Infrastructure should scale based on measured workload, not hypothetical future scale.

---

# 3. Retention Strategy

Retention period configured:

```text
24 hours
```

---

# Why Retention Matters

Kinesis retention enables:

- replay capability
- consumer recovery
- operational debugging
- event reprocessing
- and failure recovery

Example scenario:

```text
Lambda consumer outage for 2 hours
```

Events remain retained inside the stream and can later be reprocessed safely.

Without retention, events would be permanently lost during downstream failures.

---

# 4. Centralized SSE-KMS Encryption

The stream uses:

# SSE-KMS Encryption

with the previously provisioned centralized KMS key.

This aligns with:

- governance-first engineering
- PCI-style encryption practices
- enterprise security architecture
- centralized key management
- and auditability requirements

---

# Why Centralized KMS Governance Matters

The Kinesis stream does NOT create independent encryption.

Instead:

```text
Kinesis Module
      ↓
Consumes Existing KMS Infrastructure
```

This prevents:

- fragmented encryption governance
- inconsistent IAM permissions
- decentralized key management
- and operational complexity

This dependency-first encryption architecture mirrors real enterprise cloud platforms.

---

# 5. Streaming Observability

Shard-level metrics were intentionally enabled during infrastructure creation.

Metrics enabled:

```text
IncomingBytes
IncomingRecords
OutgoingBytes
OutgoingRecords
WriteProvisionedThroughputExceeded
ReadProvisionedThroughputExceeded
IteratorAgeMilliseconds
```

---

# Why Observability Matters

Production streaming systems must always remain observable.

Without observability:

- throughput bottlenecks become invisible
- consumer lag becomes invisible
- throttling becomes invisible
- and operational scaling issues become difficult to diagnose

Observability was intentionally introduced early instead of retrofitted later.

---

# Kinesis Terraform Module Implementation

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

Version pinning prevents:

- provider incompatibilities
- deployment drift
- inconsistent engineer environments
- CI/CD instability
- and unexpected Terraform behavior

This guarantees reproducible infrastructure deployments.

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

variable "stream_name_suffix" {

  description = "Business-purpose suffix for Kinesis stream naming"

  type = string

  default = "transaction-ingestion-kds"
}

variable "shard_count" {

  description = "Number of shards for the Kinesis stream"

  type = number

  default = 1
}

variable "retention_period_hours" {

  description = "Kinesis stream retention period in hours"

  type = number

  default = 24
}

variable "kms_key_arn" {

  description = "KMS key ARN for stream encryption"

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

Terraform modules should remain reusable across:

- dev
- stage
- prod

without hardcoded deployment assumptions.

Variables allow the environment layer to inject:

- deployment context
- scaling decisions
- governance metadata
- encryption references
- and operational policies

This enables scalable Infrastructure-as-Code architecture.

---

# main.tf

```hcl
locals {

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
```

---

# Resource Architecture Explanation

---

# Local Naming Logic

```hcl
locals {
  stream_name = "${var.project_name}-${var.environment}-${var.stream_name_suffix}"
}
```

This dynamically generates standardized enterprise resource names.

Final stream name:

```text
rtfd-dev-transaction-ingestion-kds
```

This naming structure improves:

- operational readability
- governance consistency
- environment awareness
- and infrastructure discoverability

---

# aws_kinesis_stream

This resource provisions the distributed streaming backbone of the platform.

---

# shard_count

Controls stream throughput capacity.

Important concept:

# A Shard Is A Throughput Unit

Each shard acts like:

```text
a parallel throughput lane
```

More shards provide:

- more throughput
- more parallelism
- more scaling capacity

Poor partitioning can create:

```text
hot shard bottlenecks
```

which is one of the most important real-world streaming engineering concerns.

---

# retention_period

Controls:

```text
how long events remain replayable
```

Retention directly impacts:

- replay capability
- recovery windows
- operational resilience
- and debugging capability

---

# encryption_type = "KMS"

Enables SSE-KMS encryption at rest.

This ensures the stream follows:

- centralized governance
- enterprise encryption standards
- and regulated-environment practices

---

# kms_key_id

```hcl
kms_key_id = var.kms_key_arn
```

This creates:

# Terraform Dependency Graph Chaining

Meaning:

```text
KMS Module
      ↓
Exports KMS ARN
      ↓
Kinesis Module Consumes ARN
```

Terraform automatically understands:

```text
KMS infrastructure must exist before stream creation
```

without manual sequencing.

This is one of Terraform’s most powerful orchestration concepts.

---

# stream_mode_details

```hcl
stream_mode = "PROVISIONED"
```

This intentionally exposes shard engineering concepts instead of abstracting them away through autoscaling.

---

# shard_level_metrics

This enables operational observability for:

- ingestion throughput
- consumer throughput
- throttling
- and consumer lag

Critical metric example:

```text
IteratorAgeMilliseconds
```

This measures:

```text
consumer lag
```

and becomes extremely important for future Lambda stream processing monitoring.

---

# outputs.tf

```hcl
output "stream_name" {

  description = "Name of the Kinesis stream"

  value = aws_kinesis_stream.this.name
}

output "stream_arn" {

  description = "ARN of the Kinesis stream"

  value = aws_kinesis_stream.this.arn
}
```

---

# Why Outputs Matter

Terraform modules are isolation boundaries.

Outputs expose infrastructure values for:

- downstream Terraform composition
- Lambda integrations
- IAM permissions
- monitoring systems
- and CI/CD tooling

This transforms modules into reusable infrastructure components.

---

# Environment Layer Integration

## environments/dev/main.tf

```hcl
module "kinesis" {

  source = "../../modules/kinesis"

  project_name = var.project_name

  environment = var.environment

  shard_count = 1

  retention_period_hours = 24

  kms_key_arn = module.kms.kms_key_arn

  tags = local.common_tags
}
```

---

# Why Environment Layer Composition Matters

This phase reinforced one of the most important Terraform architecture principles:

| Layer | Responsibility |
|---|---|
| Modules | Reusable infrastructure logic |
| Environments | Deployment orchestration |

The environment layer injects:

- scaling decisions
- governance context
- encryption references
- and deployment policies

into reusable modules.

This enables scalable multi-environment infrastructure engineering.

---

# Dependency Graph Chaining

This line introduced implicit Terraform dependency resolution:

```hcl
kms_key_arn = module.kms.kms_key_arn
```

Terraform automatically constructs:

```text
KMS Infrastructure
        ↓
Kinesis Stream Deployment
```

This removes the need for manual deployment sequencing.

---

# Environment Outputs

## environments/dev/outputs.tf

```hcl
output "kinesis_stream_name" {

  description = "Name of the Kinesis transaction ingestion stream"

  value = module.kinesis.stream_name
}

output "kinesis_stream_arn" {

  description = "ARN of the Kinesis transaction ingestion stream"

  value = module.kinesis.stream_arn
}
```

---

# Why Environment Outputs Matter

Environment outputs expose infrastructure to the external operational world.

Examples:

- CI/CD pipelines
- deployment tooling
- monitoring systems
- operational engineers
- application configuration

This establishes the environment layer as the deployment boundary of the platform.

---

# Terraform Commands Executed

```bash
terraform init

terraform fmt -recursive

terraform validate

terraform plan

terraform apply
```

---

# Successfully Created Infrastructure

Terraform successfully provisioned:

```text
module.kinesis.aws_kinesis_stream.this
```

---

# Final Infrastructure Outputs

## Kinesis Stream Name

```text
rtfd-dev-transaction-ingestion-kds
```

---

## Kinesis Stream ARN

```text
arn:aws:kinesis:us-east-1:519697923626:stream/rtfd-dev-transaction-ingestion-kds
```

---

# Engineering Outcome Of This Phase

At the completion of this phase:

✅ Governed Kinesis streaming infrastructure exists  
✅ SSE-KMS stream encryption is active  
✅ Replay-capable ingestion architecture exists  
✅ Shard-based throughput engineering is operational  
✅ Streaming observability metrics are enabled  
✅ Terraform dependency graph chaining is functioning  
✅ Environment-layer orchestration is operational  
✅ Production-style streaming infrastructure architecture is established  

The platform now has a real-time distributed ingestion backbone prepared for:

- continuous transaction producers
- Lambda stream processing
- operational fraud detection
- replay and recovery workflows
- and scalable event-driven architecture.

---

# Next Phase

# Phase 3E — DynamoDB Operational Fraud Store

This phase will introduce:

- DynamoDB table architecture
- partition-key design
- sort-key strategy
- operational low-latency storage
- TTL expiration
- fraud alert schema design
- DynamoDB encryption
- and operational workload engineering.

This phase introduces one of the most important modern data-platform concepts:

# Operational Storage vs Analytical Storage Separation