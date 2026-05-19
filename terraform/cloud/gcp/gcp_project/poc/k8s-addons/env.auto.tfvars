## Terraform Backend Variables
bucket                            = "highflame-tfstate-poc"
## Enable required services
enable_storageclass               = true
enable_namespace                  = true
enable_docker_secret              = true
## Resource Variables
gcp_project                       = "highflame-poc"
region                            = "us-central1"
default_zone                      = "us-central1-b"
project_name                      = "highflame"
project_env                       = "poc"
service_namespace                 = "highflame-poc"
### WARNING : Don't save this
registry_password                 = ""