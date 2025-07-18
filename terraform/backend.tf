terraform {
  backend "gcs" {
    bucket = "my-gcp-project-dev-terraform-state"
    prefix = "terraform/state"
  }
}

resource "google_storage_bucket" "tf_state" {
  name     = "my-gcp-project-dev-terraform-state"
  location = "US"
}