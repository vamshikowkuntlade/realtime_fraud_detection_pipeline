terraform {

  backend "s3" {

    bucket = "rtfd-tf-state-us-east-1-519697923626"

    key = "dev/terraform.tfstate"

    region = "us-east-1"

    dynamodb_table = "rtfd-terraform-locks"

    encrypt = true
  }
}