terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
  backend "s3" {
    bucket         = "remotestate-s302"
    key            = "expense-eks"
    region         = "us-east-1"
    dynamodb_table = "expense-eks-dev"
  }
}

provider "aws" {
  region = "us-east-1"
}