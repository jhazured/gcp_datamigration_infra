variable "region" {
  description = "Region for the artifact registry"
  type        = string
}

variable "repo_name" {
  description = "Name of the artifact registry"
  type        = string
}

variable "repo_format" {
  description = "Repository format (DOCKER, MAVEN, etc.)"
  type        = string
  default     = "DOCKER"
}