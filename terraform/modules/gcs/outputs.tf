output "bucket_name" {
  description = "Name of the dataset bucket"
  value       = google_storage_bucket.this.name
}

output "bucket_url" {
  description = "URL of the data bucket"
  value       = "gs://${google_storage_bucket.this.name}"
}

output "service_account_email" {
  description = "Dataiku service account email"
  value       = google_service_account.this.email
}

output "service_account_key" {
  description = "Dataiku service account private key"
  value       = base64decode(google_service_account_key.this.private_key)
  sensitive   = true
}
