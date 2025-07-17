resource "google_artifact_registry_repository" "default" {
  provider     = google
  location     = var.region
  repository_id = var.repo_name
  format       = "DOCKER"
  description  = "Artifact Registry for Docker images"
}