provider "google" {
  project = var.project_id
  region  = var.region
}

# === Network Creation ===
module "network" {
  source       = "../../modules/network"
  network_name = var.network_name
  subnet_name  = var.subnet_name
  region       = var.region
  cidr_range   = var.cidr_range
}

# === Artifact Registry Creation ===
resource "google_artifact_registry_repository" "repo" {
  name     = var.repo_name
  format   = var.repo_format
  location = var.gcp_region
  project  = var.gcp_project_id
}

# === GCS Bucket Creation ===
resource "google_storage_bucket" "bucket" {
  name     = var.gcs_bucket_name
  location = var.gcp_region
  project  = var.gcp_project_id
}

# === Service Account Creation ===
resource "google_service_account" "et_service_account" {
  account_id   = var.service_account_name
  display_name = "ETL Service Account"
  project      = var.gcp_project_id
}

# === IAM Role Bindings for Service Account ===
resource "google_project_iam_binding" "artifact_registry_writer" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.writer"

  members = [
    "serviceAccount:${google_service_account.et_service_account.email}",
  ]
}

resource "google_project_iam_binding" "storage_object_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.et_service_account.email}",
  ]
}

resource "google_project_iam_binding" "secret_manager_admin" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.admin"

  members = [
    "serviceAccount:${google_service_account.et_service_account.email}",
  ]
}

# === Secret Manager for Environment Variables ===
resource "google_secret_manager_secret" "env_secret" {
  secret_id = var.gcp_credentials_secret_name
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "env_secret_version" {
  secret = google_secret_manager_secret.env_secret.id
  secret_data = file("./env/.env")
}

# === Compute Instance Creation ===
module "compute_instance" {
  source                  = "../../modules/compute_instance"
  instance_name           = var.instance_name
  machine_type            = var.machine_type
  zone                    = var.zone
  boot_image              = var.boot_image
  network_name            = module.network.network_name
  subnet_name             = module.network.subnet_name
  service_account_email   = google_service_account.et_service_account.email
  startup_script          = var.startup_script
}

# === Outputs ===
output "network_name" {
  value       = module.network.network_name
  description = "The name of the VPC network created."
}

output "artifact_registry_url" {
  value       = google_artifact_registry_repository.repo.url
  description = "The URL of the created Artifact Registry."
}

output "gcs_bucket_url" {
  value       = google_storage_bucket.bucket.url
  description = "The URL of the created GCS Bucket."
}

output "service_account_email" {
  value       = google_service_account.et_service_account.email
  description = "The email address of the created Service Account."
}

output "instance_ip" {
  value       = module.compute_instance.instance_ip
  description = "The external IP address of the created compute instance."
}
