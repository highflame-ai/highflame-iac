## Terraform Backend Variables
bucket                            = "highflame-tfstate-prod"
## Resource Variables
common_tags                       = {
                                        ManagedBy   = "Terraform"
                                    }
region                            = "us-east-1"
project_name                      = "highflame"
project_env                       = "prod"