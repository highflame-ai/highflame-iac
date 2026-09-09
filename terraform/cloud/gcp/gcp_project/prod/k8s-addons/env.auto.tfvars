## Terraform Backend Variables
bucket                            = "highflame-tfstate-prod"
## Enable required services
enable_storageclass               = true
enable_namespace                  = true
enable_docker_secret              = true
## Resource Variables
gcp_project                       = "highflame-prod"
region                            = "us-central1"
default_zone                      = "us-central1-b"
project_name                      = "highflame"
project_env                       = "prod"
service_namespace                 = "highflame-prod"
### WARNING : Don't save this
registry_password                 = ""