output "vpc_id" {
  description = "VPC network ID"
  value       = google_compute_network.this.id
}

output "vpc_name" {
  description = "VPC network name"
  value       = google_compute_network.this.name
}

output "gke_subnet_id" {
  description = "GKE subnet ID"
  value       = google_compute_subnetwork.gke_subnet.id
}

output "gke_subnet_name" {
  description = "GKE subnet name"
  value       = google_compute_subnetwork.gke_subnet.name
}

output "subnet_id" {
  description = "An identifier for the resource with format projects/{{project}}/regions/{{region}}/subnetworks/{{name}}"
  value       = google_compute_subnetwork.this.id
}

output "subnet_name" {
  description = "The name of the resource, provided by the client when initially creating the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash."
  value       = google_compute_subnetwork.this.name
}

output "pods_secondary_range_name" {
  description = "Secondary range name for pods"
  value       = "pods"
}

output "services_secondary_range_name" {
  description = "Secondary range name for services"
  value       = "services"
}
