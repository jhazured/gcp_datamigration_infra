resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  
  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  boot_disk {
    initialize_params {
      image = var.boot_image
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    access_config {}
  }

  metadata_startup_script = var.startup_script
}

resource "google_service_account" "vm_service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}