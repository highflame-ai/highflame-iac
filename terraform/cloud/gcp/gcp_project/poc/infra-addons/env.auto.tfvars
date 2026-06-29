## Terraform Backend Variables
bucket                                 = "highflame-tfstate-poc"
## Enable required services
enable_psql_seeding                    = false
## Resource Variables
gcp_project                            = "highflame-poc"
region                                 = "us-central1"
default_zone                           = "us-central1-b"
project_name                           = "highflame"
project_env                            = "poc"
pg_db_list                             = [
                                            "javelin_redteam",
                                            "highflame_guardian",
                                            "highflame_authn",
                                            "highflame_discovery"
                                          ]
pg_extensions                          = [
                                          {
                                            name     = "vector"
                                            database = "javelin_redteam"
                                          }
                                        ]