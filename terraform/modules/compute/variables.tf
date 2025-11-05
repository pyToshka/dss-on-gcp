variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
}

variable "region" {
  description = "The location (region or zone) in which the cluster master will be created, as well as the default node location. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well"
  type        = string
  default     = "europe-north1"
}

variable "instance_name" {
  description = "A unique name for the resource, required by GCE. Changing this forces a new resource to be created."
  type        = string
  default     = "compute"
}

variable "machine_type" {
  description = "The machine type to create."
  type        = string
  default     = "n2-standard-8"
}

variable "boot_disk_size" {
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  type        = number
  default     = 100
}
variable "boot_disk_type" {
  description = "The GCE disk type. Such as pd-standard, pd-balanced or pd-ssd."
  type        = string
  default     = "pd-ssd"
}
variable "subnet_name" {
  description = "The name or self_link of the subnetwork to attach this interface to. Either network or subnetwork must be provided. If network isn't provided it will be inferred from the subnetwork. The subnetwork must exist in the same region this instance will be created in. If the network resource is in legacy mode, do not specify this field. If the network is in auto subnet mode, specifying the subnetwork is optional. If the network is in custom subnet mode, specifying the subnetwork is required."
  type        = string
}

variable "network_name" {
  description = "The name or self_link of the network to attach this firewall to."
  type        = string
}

variable "service_account_email" {
  description = "The service account e-mail address. Note: allow_stopping_for_update must be set to true or your instance must have a desired_status of TERMINATED in order to update this field."
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "poc"
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "gke_region" {
  description = "GKE cluster region"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "If source ranges are specified, the firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format. One or both of sourceRanges and sourceTags may be set. If both properties are set, the firewall will apply to traffic that has source IP address within sourceRanges OR the source IP that belongs to a tag listed in the sourceTags property. The connection does not need to match both properties for the firewall to apply. IPv4 or IPv6 ranges are supported. For INGRESS traffic, one of source_ranges, source_tags or source_service_accounts is required."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "ssh_username" {
  description = "Username for SSH connection"
  type        = string
  default     = "ubuntu"
}
variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}
variable "labels" {
  description = "Additional labels to apply to the instance"
  type        = map(string)
  default     = {}
}
variable "tags" {
  description = "Network tags to apply to the instance"
  type        = list(string)
  default     = ["http-server", "https-server", "ssh-enabled"]
}
