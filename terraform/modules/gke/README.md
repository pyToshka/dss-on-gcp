<!-- BEGIN_TF_DOCS -->
# GKE Cluster Module
This Terraform module creates a Google Kubernetes Engine (GKE) cluster optimized for Spark workloads with the following components:
- **GKE Cluster**: Regional cluster with workload identity, network policy, and configurable cluster autoscaling
- **Spark Node Pool**: Dedicated node pool with taints for Spark workloads, supporting preemptible nodes and autoscaling
- **Service Account**: GKE service account with IAM permissions for:
  - Cloud Storage (Object Admin)
 - Cloud Logging (Log Writer)
  - Cloud Monitoring (Metric Writer)
- **Addons**: Configurable support for HTTP load balancing, HPA, and various CSI drivers (GCS Fuse, Filestore, Persistent Disk, Parallelstore)
- **Maintenance**: Daily maintenance window at 03:00 UTC

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.8 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 7.8 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.8.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.docker_repo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.docker_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_artifact_registry_repository_iam_member.docker_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_container_cluster.gke_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.spark_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.gke_sa_gcs_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_sa_logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_sa_monitoring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.project_artifact_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.containerregistry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.gke_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [random_string.id](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addons_config"></a> [addons\_config](#input\_addons\_config) | The configuration for addons supported by GKE. | <pre>object({<br/>    http_load_balancing = optional(object({<br/>      disabled = bool<br/>    }), { disabled = false })<br/>    horizontal_pod_autoscaling = optional(object({<br/>      disabled = bool<br/>    }), { disabled = false })<br/>    network_policy_config = optional(object({<br/>      disabled = bool<br/>    }))<br/>    gcp_filestore_csi_driver_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>    gcs_fuse_csi_driver_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>    dns_cache_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>    gce_persistent_disk_csi_driver_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>    gke_backup_agent_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>    config_connector_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>    parallelstore_csi_driver_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>  })</pre> | <pre>{<br/>  "gcs_fuse_csi_driver_config": {<br/>    "enabled": true<br/>  },<br/>  "gke_backup_agent_config": {<br/>    "enabled": true<br/>  },<br/>  "horizontal_pod_autoscaling": {<br/>    "disabled": false<br/>  },<br/>  "http_load_balancing": {<br/>    "disabled": false<br/>  },<br/>  "parallelstore_csi_driver_config": {<br/>    "enabled": true<br/>  }<br/>}</pre> | no |
| <a name="input_cluster_autoscaling"></a> [cluster\_autoscaling](#input\_cluster\_autoscaling) | Per-cluster configuration of Node Auto-Provisioning with Cluster Autoscaler to automatically adjust the size of the cluster and create/delete node pools based on the current needs of the cluster's workload. | <pre>object({<br/>    enabled = bool<br/>    resource_limits = list(object({<br/>      resource_type = string<br/>      minimum       = number<br/>      maximum       = number<br/>    }))<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "resource_limits": [<br/>    {<br/>      "maximum": 128,<br/>      "minimum": 1,<br/>      "resource_type": "cpu"<br/>    },<br/>    {<br/>      "maximum": 512,<br/>      "minimum": 1,<br/>      "resource_type": "memory"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster, unique within the project and location. | `string` | `"dataiku-gke"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether Terraform will be prevented from destroying the cluster. Deleting this cluster via terraform destroy or terraform apply will only succeed if this field is false in the Terraform state | `bool` | `true` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Disk size in GB | `number` | `50` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | `"poc"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels for the cluster | `map(string)` | `{}` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name or self\_link of the Google Compute Engine network to which the cluster is connected. For Shared VPC, set this to the self link of the shared network. | `string` | `"dataiku-vpc"` | no |
| <a name="input_pods_secondary_range_name"></a> [pods\_secondary\_range\_name](#input\_pods\_secondary\_range\_name) | The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses. Alternatively, cluster\_ipv4\_cidr\_block can be used to automatically create a GKE-managed on | `string` | `"pods"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The location (region or zone) in which the cluster master will be created, as well as the default node location. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well | `string` | `"europe-north1"` | no |
| <a name="input_services_secondary_range_name"></a> [services\_secondary\_range\_name](#input\_services\_secondary\_range\_name) | The name of the existing secondary range in the cluster's subnetwork to use for service ClusterIPs. Alternatively, services\_ipv4\_cidr\_block can be used to automatically create a GKE-managed one. | `string` | `"services"` | no |
| <a name="input_spark_initial_node_count"></a> [spark\_initial\_node\_count](#input\_spark\_initial\_node\_count) | Initial number of nodes in spark pool | `number` | `0` | no |
| <a name="input_spark_machine_type"></a> [spark\_machine\_type](#input\_spark\_machine\_type) | Machine type for spark nodes | `string` | `"n2-standard-8"` | no |
| <a name="input_spark_max_node_count"></a> [spark\_max\_node\_count](#input\_spark\_max\_node\_count) | Maximum number of nodes in spark pool | `number` | `20` | no |
| <a name="input_spark_min_node_count"></a> [spark\_min\_node\_count](#input\_spark\_min\_node\_count) | Minimum number of nodes in spark pool | `number` | `0` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name or self\_link of the Google Compute Engine subnetwork in which the cluster's instances are launched. | `string` | `"dataiku-vpc-gke-subnet"` | no |
| <a name="input_use_preemptible_nodes"></a> [use\_preemptible\_nodes](#input\_use\_preemptible\_nodes) | Use preemptible nodes to reduce costs | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Cluster CA certificate |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | GKE cluster endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | GKE cluster name |
| <a name="output_gke_service_account_email"></a> [gke\_service\_account\_email](#output\_gke\_service\_account\_email) | GKE Service Account email |
| <a name="output_gke_service_account_name"></a> [gke\_service\_account\_name](#output\_gke\_service\_account\_name) | GKE Service Account name |
| <a name="output_kubernetes_cluster_host"></a> [kubernetes\_cluster\_host](#output\_kubernetes\_cluster\_host) | GKE Cluster Host |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | GKE Cluster Name |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCP Project ID |
| <a name="output_region"></a> [region](#output\_region) | GKE region |
<!-- END_TF_DOCS -->
