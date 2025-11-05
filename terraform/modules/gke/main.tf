/**
* # GKE Cluster Module
* This Terraform module creates a Google Kubernetes Engine (GKE) cluster optimized for Spark workloads with the following components:
* - **GKE Cluster**: Regional cluster with workload identity, network policy, and configurable cluster autoscaling
* - **Spark Node Pool**: Dedicated node pool with taints for Spark workloads, supporting preemptible nodes and autoscaling
* - **Service Account**: GKE service account with IAM permissions for:
*   - Cloud Storage (Object Admin)
*  - Cloud Logging (Log Writer)
*   - Cloud Monitoring (Metric Writer)
* - **Addons**: Configurable support for HTTP load balancing, HPA, and various CSI drivers (GCS Fuse, Filestore, Persistent Disk, Parallelstore)
* - **Maintenance**: Daily maintenance window at 03:00 UTC

*/
locals {
  name = "${random_string.id.result}-${var.cluster_name}"
}
resource "random_string" "id" {
  length  = 3
  special = false
  upper   = false
}
resource "google_container_cluster" "gke_cluster" {
  name                     = local.name
  location                 = var.region
  initial_node_count       = 1
  project                  = var.project_id
  remove_default_node_pool = true
  deletion_protection      = var.deletion_protection
  network                  = var.network_name
  subnetwork               = var.subnet_name
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }
  cluster_autoscaling {
    enabled = var.cluster_autoscaling.enabled

    dynamic "resource_limits" {
      for_each = var.cluster_autoscaling.resource_limits
      content {
        resource_type = resource_limits.value.resource_type
        minimum       = resource_limits.value.minimum
        maximum       = resource_limits.value.maximum
      }
    }
  }

  addons_config {
    http_load_balancing {
      disabled = var.addons_config.http_load_balancing.disabled
    }

    horizontal_pod_autoscaling {
      disabled = var.addons_config.horizontal_pod_autoscaling.disabled
    }

    dynamic "network_policy_config" {
      for_each = var.addons_config.network_policy_config != null ? [1] : []
      content {
        disabled = var.addons_config.network_policy_config.disabled
      }
    }

    dynamic "gcp_filestore_csi_driver_config" {
      for_each = var.addons_config.gcp_filestore_csi_driver_config != null ? [1] : []
      content {
        enabled = var.addons_config.gcp_filestore_csi_driver_config.enabled
      }
    }

    dynamic "gcs_fuse_csi_driver_config" {
      for_each = var.addons_config.gcs_fuse_csi_driver_config != null ? [1] : []
      content {
        enabled = var.addons_config.gcs_fuse_csi_driver_config.enabled
      }
    }

    dynamic "dns_cache_config" {
      for_each = var.addons_config.dns_cache_config != null ? [1] : []
      content {
        enabled = var.addons_config.dns_cache_config.enabled
      }
    }

    dynamic "gce_persistent_disk_csi_driver_config" {
      for_each = var.addons_config.gce_persistent_disk_csi_driver_config != null ? [1] : []
      content {
        enabled = var.addons_config.gce_persistent_disk_csi_driver_config.enabled
      }
    }

    dynamic "gke_backup_agent_config" {
      for_each = var.addons_config.gke_backup_agent_config != null ? [1] : []
      content {
        enabled = var.addons_config.gke_backup_agent_config.enabled
      }
    }

    dynamic "config_connector_config" {
      for_each = var.addons_config.config_connector_config != null ? [1] : []
      content {
        enabled = var.addons_config.config_connector_config.enabled
      }
    }
    dynamic "parallelstore_csi_driver_config" {
      for_each = var.addons_config.parallelstore_csi_driver_config != null ? [1] : []
      content {
        enabled = var.addons_config.parallelstore_csi_driver_config.enabled
      }
    }
  }


  network_policy {
    enabled = true
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }


  resource_labels = merge(
    {
      "environment" = var.environment
      "managed-by"  = "terraform"
    },
    var.labels
  )
}

resource "google_container_node_pool" "spark_nodes" {
  name       = "${local.name}-spark-pool"
  cluster    = google_container_cluster.gke_cluster.name
  location   = var.region
  project    = var.project_id
  node_count = var.spark_initial_node_count
  autoscaling {
    min_node_count = var.spark_min_node_count
    max_node_count = var.spark_max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.use_preemptible_nodes
    machine_type = var.spark_machine_type
    disk_size_gb = var.disk_size_gb

    labels = merge(
      {
        "environment"   = var.environment
        "managed-by"    = "terraform"
        "workload-type" = "spark"
      },
      var.labels
    )

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    tags = ["gke", "spark", "http-server", "https-server"]
    taint {
      key    = "workload-type"
      value  = "spark"
      effect = "NO_SCHEDULE"
    }
  }

}

resource "google_service_account" "gke_sa" {
  account_id   = "${local.name}-sa"
  display_name = "Service Account for ${var.cluster_name}"
  project      = var.project_id
}

resource "google_project_iam_member" "gke_sa_gcs_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  project       = var.project_id
  repository_id = "${local.name}-docker-images"
  description   = "Docker container images repository"
  format        = "DOCKER"
}
resource "google_project_service" "containerregistry" {
  project            = var.project_id
  service            = "containerregistry.googleapis.com"
  disable_on_destroy = false
}
resource "google_artifact_registry_repository_iam_member" "docker_writer" {
  project    = google_artifact_registry_repository.docker_repo.project
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.gke_sa.email}"
}
resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  project    = google_artifact_registry_repository.docker_repo.project
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke_sa.email}"
}
resource "google_project_iam_member" "project_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}
