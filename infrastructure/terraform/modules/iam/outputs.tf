/*
===============================================================================
IAM Module Outputs
===============================================================================

Outputs expose important infrastructure values from this module.

Terraform modules should behave like reusable infrastructure components.

This means downstream infrastructure should consume exposed outputs
instead of hardcoding resource names or ARNs.

These outputs will later be consumed by:

- Lambda deployment modules
- EventBridge workflows
- Step Functions orchestration
- Monitoring integrations
- Future CI/CD pipelines

This supports:

- module composition
- reusable Infrastructure as Code
- maintainability
- environment portability
- scalable Terraform architecture

===============================================================================
*/

output "fraud_processor_role_name" {

  description = "Name of the fraud processor Lambda execution role"

  value = aws_iam_role.fraud_processor_role.name
}

output "fraud_processor_role_arn" {

  description = "ARN of the fraud processor Lambda execution role"

  value = aws_iam_role.fraud_processor_role.arn
}