"""
===============================================================================
Runtime Configuration Layer
===============================================================================

This file centralizes all runtime configuration required by the Lambda function.

Production systems should NEVER hardcode:
- regions
- table names
- bucket names
- environment-specific infrastructure

Instead:
Terraform injects configuration dynamically into Lambda environment variables.

This improves:
- portability
- multi-environment deployments
- CI/CD compatibility
- operational flexibility
"""

import os


# Reads AWS region from Lambda environment variables.
# If missing, defaults safely to us-east-1.
AWS_REGION = os.getenv(
    "AWS_REGION",
    "us-east-1"
)


# DynamoDB table name injected by Terraform.
# No default intentionally:
# if missing, deployment should fail loudly.
DYNAMODB_TABLE_NAME = os.getenv(
    "DYNAMODB_TABLE_NAME"
)


# S3 archive bucket injected dynamically by Terraform.
# Again, no fallback because infrastructure references
# should never silently default.
S3_ARCHIVE_BUCKET = os.getenv(
    "S3_ARCHIVE_BUCKET"
)