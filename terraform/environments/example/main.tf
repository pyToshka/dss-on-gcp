
module "network" {
  source              = "../../modules/vpc"
  project_id          = var.project_id
  region              = var.region
  network_name        = "${var.project_id}-${var.network_name}"
  gke_subnet_cidr     = var.gke_subnet_cidr
  pods_cidr           = var.pods_cidr
  services_cidr       = var.services_cidr
  subnet_cidr         = var.subnet_cidr
  allowed_cidr_blocks = var.allowed_cidr_blocks
  allowed_ssh_cidr    = var.allowed_ssh_cidr
}

module "gke" {
  source                        = "../../modules/gke"
  project_id                    = var.project_id
  region                        = var.region
  cluster_name                  = "${var.project_id}-${var.gke_cluster_name}"
  network_name                  = module.network.vpc_name
  subnet_name                   = module.network.gke_subnet_name
  pods_secondary_range_name     = module.network.pods_secondary_range_name
  services_secondary_range_name = module.network.services_secondary_range_name
  spark_initial_node_count      = var.spark_initial_node_count
  spark_min_node_count          = var.spark_min_node_count
  spark_max_node_count          = var.spark_max_node_count
  spark_machine_type            = var.spark_machine_type
  use_preemptible_nodes         = var.use_preemptible_nodes
  deletion_protection           = false
}
module "gcs" {
  source                 = "../../modules/gcs"
  project_id             = var.project_id
  region                 = var.region
  environment            = var.environment
  bucket_name            = "${var.project_id}-${var.bucket_name}"
  service_account_member = "serviceAccount:${module.gke.gke_service_account_email}"
  enable_versioning      = true
  force_destroy          = true
  labels                 = var.labels
}
module "compute" {
  source = "../../modules/compute"

  project_id            = var.project_id
  region                = var.region
  machine_type          = var.machine_type
  subnet_name           = module.network.subnet_name
  network_name          = module.network.vpc_name
  service_account_email = module.gcs.service_account_email
  environment           = var.environment
  gke_cluster_name      = module.gke.cluster_name
  gke_region            = var.region
  ssh_public_key        = file("~/.ssh/id_ed25519.pub")
  labels                = var.labels
}
