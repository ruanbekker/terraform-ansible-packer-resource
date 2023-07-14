terraform {
  required_providers {
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
