terraform {
  required_version = ">=1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }

  backend "s3" {
    use_lockfile   = true
    encrypt        = true
    key            = "infraaddons/infraaddons.tfstate"
  }
}

# Calling infra-setup terraform state to fetch data
data "terraform_remote_state" "infra_setup_tf" {
  backend = "s3"
  config = {
    key            = "infrasetup/infrasetup.tfstate"
    use_lockfile   = true
    region         = var.region
    bucket         = var.bucket
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

provider "postgresql" {
  host            = data.terraform_remote_state.infra_setup_tf.outputs.aurora_postgres_primary_host
  port            = data.terraform_remote_state.infra_setup_tf.outputs.aurora_postgres_primary_port
  database        = data.terraform_remote_state.infra_setup_tf.outputs.aurora_postgres_primary_db_name
  username        = data.terraform_remote_state.infra_setup_tf.outputs.aurora_postgres_primary_db_user
  password        = data.terraform_remote_state.infra_setup_tf.outputs.aurora_postgres_primary_db_pass
  sslmode         = "require"
}