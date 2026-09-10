# Terraform Scripts

_Note: `prod` is only an environment name. You can rename this folder to any appropriate name for your environment, and update the corresponding `.tf` file accordingly._

*Multiple terraform stacks with order of execution*

Terraform Dir | Description
--------------|--------------
backend | Backend for statefile
infra-setup | Infrastructure Code
infra-addons | Infrastructure resources depends on `infra-setup`
k8s-addons | Kubernetes Addons / Javelin Prerequisites