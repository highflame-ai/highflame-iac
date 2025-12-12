## Enable required services
enable_psql_seeding                      = false
## Terraform Backend Variables
bucket                                   = "javelin-tfstate-poc"
## Resource Variables
common_tags                              = {
                                                ManagedBy   = "Terraform"
                                            }
region                                   = "us-east-1"
project_name                             = "javelin"
project_env                              = "poc"
pg_db_list                               = [ "javelin_redteam" ]
pg_extensions                            = [
                                                {
                                                    name     = "vector"
                                                    database = "javelin_redteam"
                                                }
                                            ]