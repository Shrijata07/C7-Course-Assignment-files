terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.62.0"
    }
  }
}

backend "s3" {
        bucket = "tbd-c40"
        key = "keys/terraform.tfstate"
        region = "us-east-1"
}


provider "aws" {
  # Configuration options
        region = "us-east-1"
}
