provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source       = "../../modules/network"
  network_name = var.network_name
  subnet_name  = var.subnet_name
  region       = var.region
  cidr_range   = var.cidr_range
}

module "artifact_registry" {
  source       = "../../modules/artifact_registry"
  region       = var.region
  repo_name    = var.repo_name
  repo_format  = var.repo_format
}

module "compute_instance" {
  source                  = "../../modules/compute_instance"
  instance_name           = var.instance_name
  machine_type            = var.machine_type
  zone                    = var.zone
  boot_image              = var.boot_image
  network_name            = module.network.network_name
  subnet_name             = module.network.subnet_name
  startup_script          = var.startup_script
  service_account_id      = var.service_account_id
  service_account_display_name = var.service_account_display_name
}

output "network_name" {
  value = module.network.network_name
  description = "The name of the VPC network created."
}

output "artifact_registry_url" {
  value = module.artifact_registry.repo_url
  description = "The URL of the created Artifact Registry."
}

output "instance_ip" {
  value = module.compute_instance.instance_ip
  description = "The external IP address of the created compute instance."
}