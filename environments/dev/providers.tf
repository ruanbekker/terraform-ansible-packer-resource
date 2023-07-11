terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 2.51.0"
    }
    packer = {
      source = "toowoxx/packer"
      version = "0.14.0"
    }
  }
}

provider "aws" {
  shared_credentials_file  = "~/.aws/credentials"
  profile                  = "test"
  region                   = var.region
}

provider "packer" {}
