terraform {
  required_version = ">=1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }

# terraform init -backend-config="backend.tfvars" -- It will ask you to push the statefile from local to azure storage
  backend "azurerm" {
    container_name        = "terraform-state"
    key                   = "k8saddons/k8saddons.tfstate"
  }
}

# Calling infra-setup terraform state to fetch data
data "terraform_remote_state" "infra_setup_tf" {
  backend = "azurerm"
  config = {
    resource_group_name   = var.resource_group_name
    storage_account_name  = var.storage_account_name
    container_name        = "terraform-state"
    key                   = "infrasetup/infrasetup.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.az_subscription_id
}

## Deploying into the existing EKS
provider "kubernetes" {
  # config_path    = var.local_kube_config
  # config_context = "context"
  host                   = data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.host
  client_certificate     = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.cluster_ca_certificate)
}

provider "kubectl" {
  # load_config_file  = true
  # config_path       = var.local_kube_config
  host                   = data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.host
  client_certificate     = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    # config_path    = var.local_kube_config
    # config_context = "context"
    host                   = data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.host
    client_certificate     = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.aks_cluster_kubeconfig.cluster_ca_certificate)
  }
  burst_limit = 3600
  debug       = true
  # experiments {
  #   manifest = true
  # }
}