# Kinesis Terraform Module

## Purpose

Provision governed Amazon Kinesis Data Streams infrastructure
for the Real-Time Fraud Detection Platform.

## Features

- SSE-KMS encryption
- Provisioned shard architecture
- Stream retention configuration
- Shard-level monitoring metrics
- Governance tagging
- Environment-aware naming

## Inputs

| Variable | Purpose |
|---|---|
| project_name | Project identifier |
| environment | Deployment environment |
| shard_count | Number of Kinesis shards |
| retention_period_hours | Event retention duration |
| kms_key_arn | KMS encryption key |
| tags | Governance tags |

## Outputs

| Output | Purpose |
|---|---|
| stream_name | Kinesis stream name |
| stream_arn | Kinesis stream ARN |