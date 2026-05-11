/*
===============================================================================
Terraform Version Constraints
===============================================================================

This file defines:

1. Required Terraform version
2. Required provider versions

Why this matters:
-----------------
In production environments, version pinning is critical.

Without version pinning:
- different engineers may use different Terraform versions
- provider behavior may change unexpectedly
- CI/CD pipelines may behave differently
- infrastructure drift can occur

Enterprise IaC systems ALWAYS pin versions.
===============================================================================
*/

terraform {

  /*
  Restrict Terraform CLI version.

  "~> 1.14.0" means:
  - allow patch upgrades
  - block major/minor breaking upgrades

  Allowed:
  - 1.14.1
  - 1.14.5

  Blocked:
  - 1.15.x
  - 2.x.x
  */
  required_version = "~> 1.14.0"

  required_providers {

    /*
    AWS provider plugin.

    Terraform downloads this provider from HashiCorp Registry.
    */
    aws = {

      /*
      Official provider source.
      */
      source = "hashicorp/aws"

      /*
      Lock AWS provider major version.

      Important because:
      - provider schemas change
      - deprecated resources appear
      - behavior changes between major versions
      */
      version = "~> 6.0"
    }
  }
}