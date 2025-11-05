/**
* # GCP Network Module
* This Terraform module creates a Google Cloud Platform VPC network infrastructure with the following components:
* - **VPC Network**: Regional custom mode network with no auto-created subnetworks
* - **GKE Subnet**: Dedicated subnet for GKE cluster with secondary IP ranges for pods and services
* - **General Subnet**: Additional subnet for non-GKE workloads
* - **Firewall Rules**:
*   - Internal traffic between subnets (all TCP/UDP ports)
*   - HTTPS/HTTP access to  resources
*   - SSH access to resources
* - **Flow Logs**: Enabled on all subnets with 10-minute aggregation intervals
* - **Private Google Access**: Enabled on all subnets for accessing Google APIs

*/
locals {
  name = "${random_pet.prefix.id}-${var.network_name}"
}
resource "random_pet" "prefix" {
  length = 1
}
resource "google_compute_network" "this" {
  name                    = local.name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${local.name}-gke-subnet"
  ip_cidr_range = var.gke_subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
  project       = var.project_id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "this" {
  name          = "${local.name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
  project       = var.project_id

  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${local.name}-allow-internal"
  network = google_compute_network.this.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    var.gke_subnet_cidr,
    var.subnet_cidr,
    var.pods_cidr,
    var.services_cidr
  ]
}

resource "google_compute_firewall" "allow_https" {
  name    = "${local.name}-allow-dss-https"
  network = google_compute_network.this.name
  project = var.project_id
  #checkov:skip=CKV_GCP_106: "Need for letsencrypt"
  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }

  source_ranges = var.allowed_cidr_blocks
  target_tags   = ["http-server", "https-server"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${local.name}-allow-ssh"
  network = google_compute_network.this.name
  project = var.project_id
  #checkov:skip=CKV_GCP_2: "POC ssh need to have"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidr
  target_tags   = ["ssh-enabled"]
}
