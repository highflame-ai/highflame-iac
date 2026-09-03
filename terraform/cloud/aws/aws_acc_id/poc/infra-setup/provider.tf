terraform {
  required_version = ">=1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.55.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.6.0"
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

provider "aws" {
  alias  = "ha_pair"
  region = var.ha_region
  default_tags {
    tags = local.tags
  }
}