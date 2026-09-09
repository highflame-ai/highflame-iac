terraform {
  required_version = ">=1.10"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.13.0"
    }
  }

# Comment this out when initialising the backend_resources first time.
# terraform init
# terraform apply
# uncomment the gcs backend
# terraform init -backend-config="backend.tfvars" -- It will ask you to push the statefile from local to gcs
  backend "gcs" {
    prefix         = "backend"
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