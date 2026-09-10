# ################################################## EKS_sg
output "eks_sg_cluster_sg_id" {
  description = "EKS Cluster Security Group ID"
  value       = var.enable_eks ? module.eks_sg[0].eks_cluster_sg_id : null
}

output "eks_sg_cluster_sg_name" {
  description = "EKS Cluster Security Group Name"
  value       = var.enable_eks ? module.eks_sg[0].eks_cluster_sg_name : null
}

output "eks_sg_cluster_sg_arn" {
  description = "EKS Cluster Security Group arn"
  value       = var.enable_eks ? module.eks_sg[0].eks_cluster_sg_arn : null
}

output "eks_sg_nodegroup_sg_id" {
  description = "EKS NodeGroup Security Group ID"
  value       = var.enable_eks ? module.eks_sg[0].eks_nodegroup_sg_id : null
}

output "eks_sg_nodegroup_sg_name" {
  description = "EKS NodeGroup Security Group Name"
  value       = var.enable_eks ? module.eks_sg[0].eks_nodegroup_sg_name : null
}

output "eks_sg_nodegroup_sg_arn" {
  description = "EKS NodeGroup Security Group arn"
  value       = var.enable_eks ? module.eks_sg[0].eks_nodegroup_sg_arn : null
}

output "eks_sg_nodegroup_sg_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_eks ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> eks_sg" : null
}