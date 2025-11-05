variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-north1"
}
variable "network_name" {
  type    = string
  default = "default"
}
variable "gke_subnet_cidr" {
  type    = string
  default = "10.215.0.0/20"
}

variable "pods_cidr" {
  type    = string
  default = "10.216.0.0/16"
}

variable "services_cidr" {
  type    = string
  default = "10.217.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.218.0.0/24"
}
variable "allowed_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidr" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "gke_cluster_name" {
  type    = string
  default = "poc"
}
variable "spark_min_node_count" {
  type    = number
  default = 0
}

variable "spark_initial_node_count" {
  type    = number
  default = 0
}
variable "spark_max_node_count" {
  type    = number
  default = 20
}

variable "spark_machine_type" {
  type    = string
  default = "n2-standard-8"
}

variable "use_preemptible_nodes" {
  type    = bool
  default = true
}
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "poc"
}
variable "bucket_name" {
  type    = string
  default = "datasets"
}
variable "machine_type" {
  type    = string
  default = "c2-standard-8"
}
variable "labels" {
  type = map(string)
  default = {
    "role" = "dataiku"
  }
}
