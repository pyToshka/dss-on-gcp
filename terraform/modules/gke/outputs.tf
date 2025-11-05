output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.gke_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "region" {
  description = "GKE region"
  value       = var.region
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "kubernetes_cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.gke_cluster.name
}

output "kubernetes_cluster_host" {
  description = "GKE Cluster Host"
  value       = "https://${google_container_cluster.gke_cluster.endpoint}"
  sensitive   = true
}

output "gke_service_account_email" {
  description = "GKE Service Account email"
  value       = google_service_account.gke_sa.email
}

output "gke_service_account_name" {
  description = "GKE Service Account name"
  value       = google_service_account.gke_sa.account_id
}
