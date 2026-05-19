variable "project_name" {
  description = "Project name"
  type        = string
}

variable "project_env" {
  description = "Environment stage"
  type        = string
}

variable "eks_cluster_oidc_provider_arn" {
  description = "EKS cluster oidc provider arn"
  type        = string
}

variable "eks_cluster_oidc_provider" {
  description = "EKS cluster oidc provider"
  type        = string
}

variable "svc_iam_policy_list" {
  description = "List of IAM Policies for Service"
  type        = list(string)
}

variable "svc_bucket_list" {
  description = "svc bucket list"
  type        = list(string)
}