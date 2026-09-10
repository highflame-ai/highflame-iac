# Terraform code specific to prod environment

_Note: `prod` is only an environment name. You can rename this folder to any appropriate name for your environment, and update the corresponding `.tf` file accordingly._

*Multiple terraform stacks with order of execution*

Terraform Dir | Description
--------------|--------------
backend | Backend storage class for storing the state file
infra-setup | Infrastructure Code
infra-addons | Infrastructure Addons
k8s-addons | Kubernetes Addons / Highflame Prerequisites