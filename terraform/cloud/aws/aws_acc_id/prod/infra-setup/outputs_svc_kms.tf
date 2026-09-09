output "highflame_svc_kms_key_arn" {
  description = "KMS Key ARN"
  value       = var.enable_svc_kms ? module.svc_kms[0].svc_kms_key_arn : null
}

output "highflame_svc_kms_zzzzzz" {
  description = "Separation in the output"
  value       = var.enable_svc_kms ? ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> highflame_svc_kms" : null
}