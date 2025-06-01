terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.85.0"
    }
  }
  backend "s3" {
    bucket         = "remotestate-s302"
    key            = "expense-bastion"
    region         = "us-east-1"
    dynamodb_table = "expense-eks-dev"
  }
}

provider "aws" {
  region = "us-east-1"
}