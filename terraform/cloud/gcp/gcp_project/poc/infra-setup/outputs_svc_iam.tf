output "javelin_svc_iam_email" {
  description = "Javelin Service SA email"
  value       = var.enable_svc_iam ? module.svc_iam[0].iam_email : null
}

output "javelin_svc_iam_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_svc_iam ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> javelin_svc_iam" : null
}