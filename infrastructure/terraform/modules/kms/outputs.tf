/*
===============================================================================
Outputs
===============================================================================

Outputs expose values from this module to downstream modules.

Without outputs:
- other modules cannot reference this infrastructure cleanly

This is how Terraform modules communicate with each other.
===============================================================================
*/

output "kms_key_arn" {

  description = "ARN of the KMS key"

  value = aws_kms_key.this.arn
}

/*
Why ARN matters:
----------------
Most AWS services require full ARN references for encryption.

Examples:
- Kinesis encryption
- S3 bucket encryption
- DynamoDB SSE-KMS
*/
output "kms_key_id" {

  description = "Unique KMS key ID"

  value = aws_kms_key.this.key_id
}

/*
Useful for:
- debugging
- AWS CLI operations
- governance tooling
*/
output "kms_alias_name" {

  description = "Friendly alias name"

  value = aws_kms_alias.this.name
}