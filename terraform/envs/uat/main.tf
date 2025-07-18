provider "google" {
  project = var.project_id
  region  = var.region
}

module "artifact_registry" {
  source    = "../../modules/artifact_registry"
  region    = var.region
  repo_name = var.repo_name
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