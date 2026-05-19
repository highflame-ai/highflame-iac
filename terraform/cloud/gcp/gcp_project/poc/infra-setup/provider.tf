terraform {
  required_version = ">=1.10"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.13.0"
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

  backend "gcs" {
    prefix         = "infrasetup"
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