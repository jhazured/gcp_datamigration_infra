variable "instance_name" {
  type        = string
  description = "Name of the VM"
}

variable "machine_type" {
  type        = string
  description = "Machine type (e.g. e2-medium)"
}

variable "zone" {
  type        = string
  description = "Zone where VM is deployed"
}

variable "boot_image" {
  type        = string
  description = "OS image to use for boot disk"
  default     = "debian-cloud/debian-11"
}

variable "network_name" {
  type        = string
  description = "Name of the VPC network"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnetwork"
}

variable "service_account_id" {
  description = "The ID of the service account to create"
  type        = string
}

variable "service_account_display_name" {
  description = "Display name of the service account"
  type        = string
}

variable "startup_script" {
  type        = string
  description = "Startup script for VM initialization"
  default     = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
  EOT
}
