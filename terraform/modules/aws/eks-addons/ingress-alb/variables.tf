variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment stage"
  type        = string
}

variable "helm_version" {
  type        = string
  default     = "1.7.2"
  description = "ALB Ingress Helm chart version."
}

variable "namespace" {
  type        = string
  default     = "ingress-alb"
  description = "Kubernetes namespace to deploy ALB Ingress Helm chart."
}

variable "k8s_service_account" {
  description = "ALB Ingress Controller Service Account"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "k8s_cluster_name" {
  type        = string
  description = "K8s Cluster Name"
}

variable "eks_cluster_oidc_provider_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account."
}

variable "ingress_replicas" {
  description = "Number of Replica for Ingress"
  type        = number
}

variable "mod_dependency" {
  default     = null
  description = "Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable."
}

variable "highflame_ingress_helm_version" {
  description = "Helm Chart Version for highflame-ingress"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet ids"
  type         = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM certificate arn"
  type        = string
}

variable "alb_security_group_ids" {
  description = "ALB Security Group IDs"
  type        = string
}