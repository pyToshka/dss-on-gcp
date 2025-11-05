output "instance_name" {
  description = "Name of gcp instance"
  value       = google_compute_instance.this.name
}

output "instance_external_ip" {
  description = "Public IP address"
  value       = google_compute_address.this.address
}

output "instance_internal_ip" {
  description = "Private IP address"
  value       = google_compute_instance.this.network_interface[0].network_ip
}
