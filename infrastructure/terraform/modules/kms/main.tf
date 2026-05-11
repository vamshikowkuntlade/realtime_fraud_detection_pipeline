/*
===============================================================================
KMS Module
===============================================================================

This module provisions:

1. Customer Managed KMS Key
2. KMS Alias

This key will later encrypt:
- Kinesis streams
- S3 buckets
- DynamoDB tables
- CloudWatch log groups

Why Customer Managed Keys (CMKs)?
---------------------------------
We intentionally avoid AWS-managed default encryption because:

CMKs provide:
- fine-grained IAM control
- auditability
- rotation management
- centralized governance
- enterprise security posture

This aligns with:
- PCI-DSS principles
- financial-services governance
- regulated cloud environments

===============================================================================
*/

resource "aws_kms_key" "this" {

  /*
  Human-readable explanation of the key purpose.
  */
  description = var.kms_key_description

  /*
  Enables automatic annual key rotation.

  Why this matters:
  -----------------
  Long-lived encryption keys increase security risk.

  Rotation reduces exposure window if:
  - key material is compromised
  - credentials leak
  - insider threats occur

  Automatic rotation is considered a security best practice.
  */
  enable_key_rotation = true

  /*
  Prevent immediate accidental deletion.

  IMPORTANT:
  -----------
  Deleting KMS keys is extremely dangerous.

  If deleted:
  - encrypted S3 data becomes unreadable
  - encrypted DynamoDB records break
  - encrypted Kinesis streams fail

  AWS enforces a waiting period intentionally.
  */
  deletion_window_in_days = var.deletion_window_in_days

  /*
  Resource tags.

  These are inherited from environment-level configuration.

  Tags support:
  - governance
  - billing
  - compliance
  - resource discovery
  */
  tags = var.tags
}

/*
===============================================================================
KMS Alias
===============================================================================

KMS keys internally use UUIDs.

Example:
--------
1234abcd-5678-90ef-ghij-klmnopqrst

Humans cannot operationally manage infrastructure efficiently using UUIDs.

Aliases provide stable readable identifiers.

Example:
--------
alias/rtfd-dev-core-kms

This becomes extremely important when:
- referencing keys in other Terraform modules
- debugging encryption issues
- operational troubleshooting
===============================================================================
*/

resource "aws_kms_alias" "this" {

  /*
  Alias naming convention.

  Enterprise naming strategy:
  <project>-<environment>-<purpose>-kms
  */
  name = "alias/${var.project_name}-${var.environment}-core-kms"

  /*
  Connect alias to the actual KMS key.
  */
  target_key_id = aws_kms_key.this.key_id
}