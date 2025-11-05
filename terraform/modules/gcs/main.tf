/**
* # GCS Storage & Dataiku Service Account Module

* This Terraform module creates Google Cloud Storage infrastructure and service accounts for Dataiku deployments:

* - **GCS Bucket**: Storage bucket with uniform bucket-level access, optional versioning, and environment labels
* - **Dataiku Service Account**: Dedicated service account with IAM roles for:
*  - Storage Admin (full GCS access)
*  - Compute Admin (VM and compute resource management)
*  - Container Developer (GKE cluster access)
* - **Service Account Key**: X.509 PEM key for external authentication
* - **Bucket IAM**: Configurable Object Admin access for additional service accounts

*/
locals {
  name = "${random_pet.prefix.id}-${var.bucket_name}"
}
resource "random_pet" "prefix" {
  length = 1
}
resource "google_storage_bucket" "this" {
  name                        = local.name
  location                    = var.region
  project                     = var.project_id
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true

  versioning {
    enabled = var.enable_versioning
  }

  labels = merge(
    {
      "environment" = var.environment
      "managed-by"  = "terraform"
    },
    var.labels
  )
}

resource "google_storage_bucket_iam_member" "dataiku_artifacts_access" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectAdmin"
  member = var.service_account_member
}

resource "google_service_account" "this" {
  account_id   = "${random_pet.prefix.id}-dss-sa"
  display_name = "Dataiku Service Account"
  project      = var.project_id
}

resource "google_service_account_key" "this" {
  service_account_id = google_service_account.this.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "this" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.this.email}"
}

resource "google_project_iam_member" "dataiku_sa_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.this.email}"
}

resource "google_project_iam_member" "dataiku_sa_container_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.this.email}"
}
resource "google_project_iam_member" "dataiku_sa_registry_read" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.this.email}"
}
resource "google_project_iam_member" "dataiku_sa_registry_write" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.this.email}"
}
