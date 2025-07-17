variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "cidr_range" {
  description = "CIDR range of the subnet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "GCP region"
  type        = string
}