variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
}

variable "region" {
  description = "The location (region or zone) in which the cluster master will be created, as well as the default node location. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well"
  type        = string
  default     = "EU"
}
variable "bucket_name" {
  description = "The name of the bucket."
  type        = string
  default     = "dss-datasets"
}
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "enable_versioning" {
  description = "Enable versioning for buckets"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to destroy non-empty buckets"
  type        = bool
  default     = false
}

variable "service_account_member" {
  description = "Service account member to grant access"
  type        = string
  default     = ""
}
variable "labels" {
  description = "Additional labels to apply to bucket"
  type        = map(string)
  default     = {}
}
