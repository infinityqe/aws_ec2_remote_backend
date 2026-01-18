terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "mlelievre-website20260118144420821700000001"
    region = "us-east-1"
  }
}