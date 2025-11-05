<!-- BEGIN_TF_DOCS -->
# GCP Compute Instance Module
This Terraform module creates a Google Compute Engine instance with the following components:
- **Compute Instance**: Ubuntu 22.04 LTS VM with SSD boot disk and configurable machine type
- **Static External IP**: Reserved IP address for consistent external access
- **Firewall Rules**:
  - HTTP/HTTPS access (ports 80, 443) from specified CIDR blocks
  - GKE communication ports (8080, 8443, 50050, 50051) for cluster integration
- **Startup Script**: Template-based initialization script for GKE cluster configuration
- **SSH Configuration**: Custom SSH key with project-level SSH keys blocked for security
- **Service Account**: Attached with full cloud platform scope for GCP resource access

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
| [google_compute_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow_gke_communication](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [random_pet.prefix](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/pet) | resource |
| [google_compute_image.ubuntu](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | If source ranges are specified, the firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format. One or both of sourceRanges and sourceTags may be set. If both properties are set, the firewall will apply to traffic that has source IP address within sourceRanges OR the source IP that belongs to a tag listed in the sourceTags property. The connection does not need to match both properties for the firewall to apply. IPv4 or IPv6 ranges are supported. For INGRESS traffic, one of source\_ranges, source\_tags or source\_service\_accounts is required. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_boot_disk_size"></a> [boot\_disk\_size](#input\_boot\_disk\_size) | The size of the image in gigabytes. If not specified, it will inherit the size of its base image. | `number` | `100` | no |
| <a name="input_boot_disk_type"></a> [boot\_disk\_type](#input\_boot\_disk\_type) | The GCE disk type. Such as pd-standard, pd-balanced or pd-ssd. | `string` | `"pd-ssd"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | `"poc"` | no |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | GKE cluster name | `string` | n/a | yes |
| <a name="input_gke_region"></a> [gke\_region](#input\_gke\_region) | GKE cluster region | `string` | n/a | yes |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | A unique name for the resource, required by GCE. Changing this forces a new resource to be created. | `string` | `"compute"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Additional labels to apply to the instance | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to create. | `string` | `"n2-standard-8"` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name or self\_link of the network to attach this firewall to. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The location (region or zone) in which the cluster master will be created, as well as the default node location. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region, and with default node locations in those zones as well | `string` | `"europe-north1"` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | The service account e-mail address. Note: allow\_stopping\_for\_update must be set to true or your instance must have a desired\_status of TERMINATED in order to update this field. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key | `string` | n/a | yes |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Username for SSH connection | `string` | `"ubuntu"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name or self\_link of the subnetwork to attach this interface to. Either network or subnetwork must be provided. If network isn't provided it will be inferred from the subnetwork. The subnetwork must exist in the same region this instance will be created in. If the network resource is in legacy mode, do not specify this field. If the network is in auto subnet mode, specifying the subnetwork is optional. If the network is in custom subnet mode, specifying the subnetwork is required. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Network tags to apply to the instance | `list(string)` | <pre>[<br/>  "http-server",<br/>  "https-server",<br/>  "ssh-enabled"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_external_ip"></a> [instance\_external\_ip](#output\_instance\_external\_ip) | Public IP address |
| <a name="output_instance_internal_ip"></a> [instance\_internal\_ip](#output\_instance\_internal\_ip) | Private IP address |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | Name of gcp instance |
<!-- END_TF_DOCS -->
