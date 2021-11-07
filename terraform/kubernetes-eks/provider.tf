terraform {
  backend "s3" {
    bucket = "choshsh-remote-state"
    key    = "global/terraform.state"
    region = "ap-northeast-2"
  }

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

  default_tags {
    tags = {
      Workspace = terraform.workspace
      Owner     = "choshsh"
    }
  }
}
