variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "zone" {
  description = "The GCP zone"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "cidr_range" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "repo_name" {
  description = "Name of the Artifact Registry repository"
  type        = string
}

variable "repo_format" {
  description = "Format of the Artifact Registry repository"
  type        = string
  default     = "DOCKER"
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
  default     = "e2-micro"  # Cost-optimized default
}

variable "boot_image" {
  description = "Boot image for the compute instance"
  type        = string
}

variable "startup_script" {
  description = "Startup script for the compute instance"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID"
  type        = string
}

variable "service_account_display_name" {
  description = "Service account display name"
  type        = string
}