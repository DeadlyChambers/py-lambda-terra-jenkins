terraform {
  backend "s3" {
    # This is an s3bucket you will need to create in your aws 
    # space
    bucket = "soinshane-terraform-state"

    # The key should be unique to each stack, because we want to
    # have multiple enviornments alongside each other we set
    # this dynamically in the bitbucket-pipelines.yml with the
    # -backend-config param
    key = "labmda/sns"

    region = "us-east-1"

    # This is a DynamoDB table with the Primary Key set to LockID
    #    dynamodb_table = "terraform-db-name"

    #Enable server side encryption on your terraform state
    #   encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.1"
    }
  }
  required_version = ">= 0.14.10"
}
