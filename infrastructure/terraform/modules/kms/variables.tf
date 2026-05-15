/*
===============================================================================
Input Variables
===============================================================================

Variables make Terraform modules reusable.

Instead of hardcoding:
- environment names
- regions
- project identifiers

we inject values dynamically from:
- dev
- stage
- prod

This is foundational to reusable Infrastructure as Code.
===============================================================================
*/

variable "project_name" {

  description = "Short project identifier used in resource naming"

  type = string
}

/*
Example:
rtfd

From:
Real-Time Fraud Detection
*/
variable "environment" {

  description = "Deployment environment"

  type = string
}

/*
Examples:
- dev
- stage
- prod

Why environment awareness matters:
----------------------------------
Production systems must isolate environments.

We NEVER want:
- dev resources colliding with prod
- shared accidental infrastructure
- ambiguous naming
*/
variable "kms_key_description" {

  description = "Human-readable description for the KMS key"

  type = string
}

/*
This improves:
- operational clarity
- AWS Console readability
- governance audits 

*/
variable "deletion_window_in_days" {

  description = "Waiting period before KMS key deletion"

  type = number

  default = 30
}

/*
Why this exists:
----------------
KMS deletion is dangerous.

If a KMS key is deleted:
- encrypted S3 objects become unreadable
- DynamoDB encrypted tables break
- Kinesis encrypted streams fail
- data becomes unrecoverable

AWS therefore enforces delayed deletion.

30 days is a common enterprise-safe default.
*/
variable "tags" {

  description = "Common resource tags"

  type = map(string)

  default = {}
}

/*
Centralized tagging strategy supports:
- cost tracking
- governance
- FinOps
- operational filtering
- audit reporting

Tagging is NOT optional in enterprise environments.
*/