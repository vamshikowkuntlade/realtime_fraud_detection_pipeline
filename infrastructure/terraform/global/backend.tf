###############################################
# Remote Backend Configuration
###############################################
#
# Terraform state is stored remotely in S3
# instead of local terraform.tfstate files.
#
# Benefits:
# - centralized state management
# - CI/CD compatibility
# - safer collaboration
# - state durability
#
# DynamoDB provides distributed state locking
# to prevent concurrent Terraform operations
# from corrupting state.
#
###############################################

terraform {

  backend "s3" {

    #########################################
    # Remote State Bucket
    #########################################

    bucket = "rtfd-tf-state-us-east-1-519697923626"

    #########################################
    # State File Location
    #########################################

    key = "global/terraform.tfstate"

    #########################################
    # AWS Region
    #########################################

    region = "us-east-1"

    #########################################
    # DynamoDB State Locking
    #########################################

    dynamodb_table = "rtfd-terraform-locks"

    #########################################
    # Encrypt State At Rest
    #########################################

    encrypt = true
  }
}