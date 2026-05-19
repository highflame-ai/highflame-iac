# Terraform Scripts

*Multiple terraform stacks with order of execution*

Terraform Dir | Description
--------------|--------------
backend | Backend for statefile
infra-setup | Infrastructure Code
infra-addons | Infrastructure resources depends on `infra-setup`
k8s-addons | Kubernetes Addons / Javelin Prerequisites