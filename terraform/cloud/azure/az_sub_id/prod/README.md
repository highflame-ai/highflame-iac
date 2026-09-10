# Terraform code specific to prod environment

_Note: `prod` is only an environment name. You can rename this folder to any appropriate name for your environment, and update the corresponding `.tf` file accordingly._

*Multiple terraform stacks with order of execution*

Terraform Dir | Description
--------------|--------------
backend | Backend storage class for storing the state file
infra-setup | Infrastructure Code
infra-addons | Infrastructure Addons
k8s-addons | Kubernetes Addons / Highflame Prerequisites

* [choose-az-regions] for supporting availability zone (https://learn.microsoft.com/en-us/azure/reliability/regions-list)

### Debug cert-manager

```code
export K8S_NAMESPACE=""
kubectl -n ${K8S_NAMESPACE} get certificate
kubectl -n ${K8S_NAMESPACE} get certificaterequest
kubectl -n ${K8S_NAMESPACE} describe certificaterequest X
kubectl -n ${K8S_NAMESPACE} get order
kubectl -n ${K8S_NAMESPACE} describe order X
kubectl -n ${K8S_NAMESPACE} get challenge
kubectl -n ${K8S_NAMESPACE} describe challenge X
```