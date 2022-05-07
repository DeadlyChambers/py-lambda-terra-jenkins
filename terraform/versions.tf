terraform {
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
