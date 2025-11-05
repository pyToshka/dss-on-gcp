variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
}

variable "region" {
  description = "The location (region or zone) in which the cluster master will be created, as well as the default node location. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well"
  type        = string
  default     = "europe-north1"
}

variable "cluster_name" {
  description = "The name of the cluster, unique within the project and location."
  type        = string
  default     = "dataiku-gke"
}

variable "network_name" {
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected. For Shared VPC, set this to the self link of the shared network."
  type        = string
  default     = "dataiku-vpc"
}

variable "subnet_name" {
  description = "The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched."
  type        = string
  default     = "dataiku-vpc-gke-subnet"
}

variable "pods_secondary_range_name" {
  description = "The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses. Alternatively, cluster_ipv4_cidr_block can be used to automatically create a GKE-managed on"
  type        = string
  default     = "pods"
}

variable "services_secondary_range_name" {
  description = "The name of the existing secondary range in the cluster's subnetwork to use for service ClusterIPs. Alternatively, services_ipv4_cidr_block can be used to automatically create a GKE-managed one."
  type        = string
  default     = "services"
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 50
}

variable "spark_initial_node_count" {
  description = "Initial number of nodes in spark pool"
  type        = number
  default     = 0
}

variable "spark_min_node_count" {
  description = "Minimum number of nodes in spark pool"
  type        = number
  default     = 0
}

variable "spark_max_node_count" {
  description = "Maximum number of nodes in spark pool"
  type        = number
  default     = 20
}

variable "spark_machine_type" {
  description = "Machine type for spark nodes"
  type        = string
  default     = "n2-standard-8"
}

variable "use_preemptible_nodes" {
  description = "Use preemptible nodes to reduce costs"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels for the cluster"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Whether Terraform will be prevented from destroying the cluster. Deleting this cluster via terraform destroy or terraform apply will only succeed if this field is false in the Terraform state"
  type        = bool
  default     = true
}
variable "cluster_autoscaling" {
  description = "Per-cluster configuration of Node Auto-Provisioning with Cluster Autoscaler to automatically adjust the size of the cluster and create/delete node pools based on the current needs of the cluster's workload."
  type = object({
    enabled = bool
    resource_limits = list(object({
      resource_type = string
      minimum       = number
      maximum       = number
    }))
  })
  default = {
    enabled = true
    resource_limits = [
      {
        resource_type = "cpu"
        minimum       = 1
        maximum       = 128
      },
      {
        resource_type = "memory"
        minimum       = 1
        maximum       = 512
      }
    ]
  }
}
variable "addons_config" {
  description = "The configuration for addons supported by GKE."
  type = object({
    http_load_balancing = optional(object({
      disabled = bool
    }), { disabled = false })
    horizontal_pod_autoscaling = optional(object({
      disabled = bool
    }), { disabled = false })
    network_policy_config = optional(object({
      disabled = bool
    }))
    gcp_filestore_csi_driver_config = optional(object({
      enabled = bool
    }))
    gcs_fuse_csi_driver_config = optional(object({
      enabled = bool
    }))
    dns_cache_config = optional(object({
      enabled = bool
    }))
    gce_persistent_disk_csi_driver_config = optional(object({
      enabled = bool
    }))
    gke_backup_agent_config = optional(object({
      enabled = bool
    }))
    config_connector_config = optional(object({
      enabled = bool
    }))
    parallelstore_csi_driver_config = optional(object({
      enabled = bool
    }))
  })
  default = {
    http_load_balancing = {
      disabled = false
    }
    horizontal_pod_autoscaling = {
      disabled = false
    }
    gcs_fuse_csi_driver_config = {
      enabled = true
    }
    gke_backup_agent_config = {
      enabled = true
    }
    parallelstore_csi_driver_config = {
      enabled = true
    }
  }
}
variable "environment" {
  description = "Environment"
  type        = string
  default     = "poc"
}
