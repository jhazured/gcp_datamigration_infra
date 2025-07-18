terraform {
  backend "gcs" {
    bucket = "my-gcp-project-dev-terraform-state"
    prefix = "terraform/state"
  }
}