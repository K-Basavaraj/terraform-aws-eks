terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }

  backend "s3" {
    bucket = "remotestate-s301"
    key    = "k8-ecr"
    region = "us-east-1"
    dynamodb_table = "eks-locking1"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}