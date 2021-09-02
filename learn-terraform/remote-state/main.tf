terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}

resource "aws_s3_bucket" "choshsh-remote-state" {
  bucket = "choshsh-remote-state"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Service     = "terraform"
  }
}
