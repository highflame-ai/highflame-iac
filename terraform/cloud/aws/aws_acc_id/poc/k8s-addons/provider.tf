terraform {
  required_version = ">=1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.55.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }

  backend "s3" {
    use_lockfile   = true
    encrypt        = true
    key            = "k8saddons/k8saddons.tfstate"
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

## Deploying into the existing EKS
provider "kubernetes" {
  # config_path    = var.local_kube_config
  # config_context = "context"
  host                   = data.terraform_remote_state.infra_setup_tf.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    # config_path    = var.local_kube_config
    # config_context = "context"
    host                   = data.terraform_remote_state.infra_setup_tf.outputs.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
  burst_limit = 3600
  debug       = true
  # experiments {
  #   manifest = true
  # }
}