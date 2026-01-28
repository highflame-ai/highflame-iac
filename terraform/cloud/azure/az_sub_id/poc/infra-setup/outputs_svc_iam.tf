output "highflame_svc_iam_client_id" {
  description = "App uami client id"
  value       = var.enable_svc_iam ? module.svc_iam[0].app_uami_client_id : null
}

output "highflame_svc_iam_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_svc_iam ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> highflame_svc_iam" : null
}