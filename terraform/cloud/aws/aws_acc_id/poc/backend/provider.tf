terraform {
  required_version = ">=1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
  }

# Comment this out when initialising the backend_resources first time.
# terraform init
# terraform apply
# uncomment the s3 backend
# terraform init -- It will ask you to push the statefile from local to s3
  backend "s3" {
    use_lockfile   = true
    encrypt        = true
    key            = "backend/backend.tfstate"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}