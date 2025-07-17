resource "google_artifact_registry_repository" "repo" {
  provider      = google
  location      = var.region
  repository_id = var.repo_name
  format        = var.repo_format
  description   = "Artifact Registry repo for Docker images"
}