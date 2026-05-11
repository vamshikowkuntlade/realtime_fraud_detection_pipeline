output "kms_key_arn" {

  description = "ARN of deployed KMS key"

  value = module.kms.kms_key_arn
}

output "kms_alias_name" {

  description = "KMS alias name"

  value = module.kms.kms_alias_name
}