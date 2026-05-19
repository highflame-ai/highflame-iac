output "kms_default_keyring_name" {
  description = "Default keyring name for encryption"
  value       = google_kms_key_ring.kms_keyring.name
}

output "kms_default_key_name" {
  description = "Default key name for encryption"
  value       = google_kms_crypto_key.kms_key.name
}

output "kms_default_key_id" {
  description = "Default key id for encryption"
  value       = google_kms_crypto_key.kms_key.id
}