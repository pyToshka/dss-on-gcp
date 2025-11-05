<!-- BEGIN_TF_DOCS -->
# GCP Network Module
This Terraform module creates a Google Cloud Platform VPC network infrastructure with the following components:
- **VPC Network**: Regional custom mode network with no auto-created subnetworks
- **GKE Subnet**: Dedicated subnet for GKE cluster with secondary IP ranges for pods and services
- **General Subnet**: Additional subnet for non-GKE workloads
- **Firewall Rules**:
  - Internal traffic between subnets (all TCP/UDP ports)
  - HTTPS/HTTP access to  resources
  - SSH access to resources
- **Flow Logs**: Enabled on all subnets with 10-minute aggregation intervals
- **Private Google Access**: Enabled on all subnets for accessing Google APIs

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
| [google_compute_firewall.allow_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.gke_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access HTTPS | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowed_ssh_cidr"></a> [allowed\_ssh\_cidr](#input\_allowed\_ssh\_cidr) | CIDR blocks allowed for SSH access | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_gke_subnet_cidr"></a> [gke\_subnet\_cidr](#input\_gke\_subnet\_cidr) | GKE subnet CIDR | `string` | `"10.0.0.0/20"` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the resource, provided by the client when initially creating the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash. | `string` | `"dataiku-vpc"` | no |
| <a name="input_pods_cidr"></a> [pods\_cidr](#input\_pods\_cidr) | Pods secondary CIDR | `string` | `"10.1.0.0/16"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The location (region or zone) in which the cluster master will be created, as well as the default node location. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well | `string` | `"europe-north1"` | no |
| <a name="input_services_cidr"></a> [services\_cidr](#input\_services\_cidr) | Services secondary CIDR | `string` | `"10.2.0.0/16"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | Compute instance subnet CIDR | `string` | `"10.3.0.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gke_subnet_id"></a> [gke\_subnet\_id](#output\_gke\_subnet\_id) | GKE subnet ID |
| <a name="output_gke_subnet_name"></a> [gke\_subnet\_name](#output\_gke\_subnet\_name) | GKE subnet name |
| <a name="output_pods_secondary_range_name"></a> [pods\_secondary\_range\_name](#output\_pods\_secondary\_range\_name) | Secondary range name for pods |
| <a name="output_services_secondary_range_name"></a> [services\_secondary\_range\_name](#output\_services\_secondary\_range\_name) | Secondary range name for services |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | An identifier for the resource with format projects/{{project}}/regions/{{region}}/subnetworks/{{name}} |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | The name of the resource, provided by the client when initially creating the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC network ID |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC network name |
<!-- END_TF_DOCS -->
