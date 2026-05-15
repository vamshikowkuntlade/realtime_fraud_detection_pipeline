



---
 IAM Foundation & Least-Privilege Access Control

## 🎯 Objective

To build a foundational IAM architecture for the **Real-Time Fraud Detection Platform** using production-style Terraform module composition. This phase ensures that governance and security identities are established before any compute or data resources are deployed.

---

## 🏗 Repository Structure

```text
infrastructure/
└── terraform/
    ├── modules/
    │   └── iam/               # Logic: Trust policies, roles, and permissions
    └── environments/
        └── dev/               # Implementation: Context and environment values

```

---

## 🔑 Core IAM Implementation

### 1. Lambda Trust Relationship

To allow AWS Lambda to assume the execution role, a **Trust Policy** (AssumeRole) was implemented. This allows the service to obtain temporary security credentials via AWS STS.

```hcl
data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

```

### 2. Execution Role Resource

The role is named dynamically based on the project and environment, ensuring isolation between stacks.

```hcl
resource "aws_iam_role" "fraud_processor_role" {
  name               = "${var.project_name}-${var.environment}-fraud-processor-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
  tags               = var.tags
}

```

### 3. Least-Privilege Permissions

Two specific policy documents were engineered to support the platform's initial requirements:

* **CloudWatch Logs:** Enables observability and debugging.
* **KMS Access:** Specifically allows `kms:Decrypt` and `kms:GenerateDataKey` for the ARN passed in from the KMS module.

```hcl
data "aws_iam_policy_document" "kms_access_policy" {
  statement {
    sid       = "KMSUsageAccess"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [var.kms_key_arn]
  }
}

```

---

## 🛰 Module Composition & Integration

The deployment integrates the IAM module by consuming outputs from the existing KMS module. This creates an **implicit dependency**—Terraform knows it cannot create these IAM policies until the KMS key exists.

**In `environments/dev/main.tf`:**

```hcl
module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment
  kms_key_arn  = module.kms.kms_key_arn  # Composition: Passing output to input
  tags         = local.common_tags
}

```

---

## 🛡 Security Design Decisions

### Why Standalone Policies?

Instead of huge inline policies, we used **Standalone Policies + Role Attachments**. This approach is:

* **Reusable:** Policies can be attached to multiple roles if needed.
* **Auditable:** Easier to review in the AWS Console and via security scanners.
* **Scalable:** Follows enterprise-level governance standards.

### Deferred Permissions

Permissions for **Kinesis, S3, and DynamoDB** were intentionally excluded in this phase.

* **Violation Prevention:** Using wildcards (`"*"`) for resources that don't exist yet violates the principle of Least Privilege.
* **Strict Ordering:** These will be added as those resources are created, ensuring every permission is mapped to a specific, real ARN.

---

## ✅ Platform State

| Component | Status |
| --- | --- |
| **KMS Governance** | Completed |
| **IAM Foundation** | **Completed** |
| **S3 Data Lake** | Pending |
| **Kinesis Streaming** | Pending |
| **Lambda Processor** | Pending |

---

### Final Outputs

The module exports the following for downstream use in the Lambda phase:

* `fraud_processor_role_arn`: The unique identifier for the processor identity.





Right now:

CloudWatch IAM permissions → implemented ✅
KMS IAM permissions → implemented ✅

But:

S3 IAM permissions → pending
Kinesis IAM permissions → pending
DynamoDB IAM permissions → pending