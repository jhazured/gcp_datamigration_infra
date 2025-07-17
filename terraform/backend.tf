terraform {
  backend "gcs" {
    bucket = "tf-state-bucket"
    prefix = "gcp_datamigration/${var.env}"
    # Add these for better state management
    encryption_key = "your-kms-key-id"  # Optional but recommended
  }
  
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}