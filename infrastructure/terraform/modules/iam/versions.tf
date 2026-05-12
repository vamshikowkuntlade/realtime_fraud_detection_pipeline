/*
===============================================================================
Terraform & Provider Version Constraints
===============================================================================

This file defines:

1. Required Terraform version
2. Required provider versions

Why this matters:
-------------------------------------------------------------------------------

Production Infrastructure as Code must be deterministic.

Without version pinning:

- Terraform behavior may change unexpectedly
- AWS provider behavior may differ between environments
- CI/CD deployments may become unstable
- Infrastructure drift risks increase

Version pinning guarantees reproducible infrastructure deployments.
===============================================================================
*/

terraform {

  required_version = "~> 1.14.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}