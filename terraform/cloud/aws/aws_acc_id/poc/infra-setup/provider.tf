terraform {
  required_version = ">=1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.7"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }

  backend "s3" {
    use_lockfile   = true
    encrypt        = true
    key            = "infrasetup/infrasetup.tfstate"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}