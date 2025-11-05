/**
* # GCP Compute Instance Module
* This Terraform module creates a Google Compute Engine instance with the following components:
* - **Compute Instance**: Ubuntu 22.04 LTS VM with SSD boot disk and configurable machine type
* - **Static External IP**: Reserved IP address for consistent external access
* - **Firewall Rules**:
*   - HTTP/HTTPS access (ports 80, 443) from specified CIDR blocks
*   - GKE communication ports (8080, 8443, 50050, 50051) for cluster integration
* - **Startup Script**: Template-based initialization script for GKE cluster configuration
* - **SSH Configuration**: Custom SSH key with project-level SSH keys blocked for security
* - **Service Account**: Attached with full cloud platform scope for GCP resource access

*/
locals {
  name = "${random_pet.prefix.id}-${var.instance_name}"
}
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}
resource "random_pet" "prefix" {
  length = 1
}
resource "google_compute_instance" "this" {
  name         = local.name
  machine_type = var.machine_type
  zone         = "${var.region}-a"
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    subnetwork         = var.subnet_name
    subnetwork_project = var.project_id
    access_config {
      nat_ip = google_compute_address.this.address
    }
  }

  service_account {
    email = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata = {
    block-project-ssh-keys = true
    "ssh-keys"             = "${var.ssh_username}:${var.ssh_public_key}"

  }

  tags = var.tags

  labels = merge(
    {
      "environment" = var.environment
      "managed-by"  = "terraform"
    },
    var.labels
  )

  metadata_startup_script = base64encode(templatefile("${path.module}/templates/startup.tftpl", {
    gke_cluster_name = var.gke_cluster_name
    gke_region       = var.gke_region
    gke_project_id   = var.project_id
  }))

}

resource "google_compute_address" "this" {
  name    = "${local.name}-ip"
  region  = var.region
  project = var.project_id
}

resource "google_compute_firewall" "allow_http" {
  name    = "${local.name}-allow-http"
  network = var.network_name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = var.allowed_cidr_blocks
  target_tags   = ["http-server", "https-server"]
}

resource "google_compute_firewall" "allow_gke_communication" {
  name    = "${local.name}-allow-gke-communication"
  network = var.network_name
  project = var.project_id
  allow {
    protocol = "tcp"
    ports    = ["8080", "8443", "50050", "50051"]
  }

  target_tags = ["http-server", "https-server"]
  source_tags = ["gke"]
}
