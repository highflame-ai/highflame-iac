output "eks_managed_nodegroup_arn" {
  description = "EKS managed nodegroup arn"
  value       = var.enable_eks_managed_nodes ? module.eks_managed_nodes[0].eks_managed_nodegroup_arn : null
}

output "eks_managed_nodegroup_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_eks_managed_nodes ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> eks_managed_nodegroup" : null
}