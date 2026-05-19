terraform {
  required_version = ">=1.10"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.13.0"
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
    signoz = {
      source  = "Signoz/signoz"
      version = "0.0.9"
    }
  }

# Comment this out when initialising the backend_resources first time.
# terraform init
# terraform apply
# uncomment the gcs backend
# terraform init -backend-config="backend.tfvars" -- It will ask you to push the statefile from local to gcs
  backend "gcs" {
    prefix         = "k8saddons"
  }
}

# Calling infra-setup terraform state to fetch data
data "terraform_remote_state" "infra_setup_tf" {
  backend = "gcs"
  config = {
    bucket  = var.bucket
    prefix  = "infrasetup"
  }
}

provider "google" {
  project        = var.gcp_project
  region         = var.region
  zone           = var.default_zone
  default_labels = {
    managedby    = "terraform"
    environment  = var.project_env
    project      = var.project_name
  }
}

## Deploying into the existing EKS
provider "kubernetes" {
  # config_path    = var.local_kube_config
  # config_context = "context"
  host                   = "https://${data.terraform_remote_state.infra_setup_tf.outputs.gke_cluster_endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.gke_cluster_master_auth.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    # config_path    = var.local_kube_config
    # config_context = "context"
    host                   = "https://${data.terraform_remote_state.infra_setup_tf.outputs.gke_cluster_endpoint}"
    token                  = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.gke_cluster_master_auth.cluster_ca_certificate)
  }
  burst_limit = 3600
  debug       = true
  # experiments {
  #   manifest = true
  # }
}

provider "kubectl" {
  host                   = "https://${data.terraform_remote_state.infra_setup_tf.outputs.gke_cluster_endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_setup_tf.outputs.gke_cluster_master_auth.cluster_ca_certificate)
  load_config_file       = false
}

provider "signoz" {
 endpoint     = module.signoz[0].signoz_url
 access_token = local.terraform_secret["signoz_api_key"]
}