terraform {
    required_version = "~> 1.14.0"


    required_providers {
      
      
      aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
      }
    }
}


/* 
Why This Exists

Version pinning guarantees:

reproducible deployments
provider consistency
stable CI/CD behavior
deterministic infrastructure operations

Without version pinning:

Terraform behavior may differ between engineers
provider updates may unexpectedly break infrastructure

This is standard production Infrastructure-as-Code discipline. */