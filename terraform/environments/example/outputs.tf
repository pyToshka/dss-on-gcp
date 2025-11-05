output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "instance_ip" {
  value = module.compute.instance_external_ip
}

output "bucket_url" {
  value = module.gcs.bucket_url
}

output "bucket_name" {
  value = module.gcs.bucket_name
}
