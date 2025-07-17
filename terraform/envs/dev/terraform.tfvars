project_id     = "my-gcp-project-dev"
region         = "australia-southeast1"
zone           = "australia-southeast1-b"

network_name   = "data-network-dev"
subnet_name    = "data-subnet-dev"
cidr_range     = "10.10.0.0/16"

repo_name      = "etl-artifacts"
repo_format    = "DOCKER"

instance_name  = "etl-vm-dev"
machine_type   = "e2-medium"
boot_image     = "debian-cloud/debian-11"

service_account_id           = "etl-vm-sa"
service_account_display_name = "ETL VM Service Account"

startup_script = <<EOT
#!/bin/bash
apt-get update
apt-get install -y docker.io
EOT