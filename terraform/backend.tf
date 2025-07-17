terraform {
  backend "gcs" {
    bucket = "tf-state-bucket"
    prefix = "gcp_datamigration/${var.env}"
  }
}