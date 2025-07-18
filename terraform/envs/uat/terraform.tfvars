# =============================================================================
# TERRAFORM VARIABLES - DEVELOPMENT ENVIRONMENT
# Always Free Tier Configuration for Personal Project
# =============================================================================

# Project Configuration
project_id = "my-gcp-project-dev"
region     = "us-central1"        # Always Free tier region
zone       = "us-central1-a"      # Always Free tier zone

# Environment Configuration
env_suffix = "dev"
environment = "development"

# Network Configuration
network_name = "data-network-dev"
subnet_name  = "data-subnet-dev"
cidr_range   = "10.10.0.0/16"

# Enable Private Google Access for cost savings
enable_private_google_access = true
enable_flow_logs = false  # Disable for cost savings in dev

# Artifact Registry Configuration
repo_name   = "etl-artifacts"
repo_format = "DOCKER"
repo_location = "us-central1"

# Compute Instance Configuration (Always Free Tier)
instance_name = "etl-vm-dev"
machine_type  = "e2-micro"        # Always Free tier eligible
boot_image    = "debian-cloud/debian-11"
disk_size     = 30                # GB - Always Free tier limit
disk_type     = "pd-standard"     # Standard persistent disk (cheaper)

# Service Account Configuration
service_account_id           = "etl-vm-sa"
service_account_display_name = "ETL VM Service Account"

# IAM Roles for Service Account
service_account_roles = [
  "roles/storage.objectAdmin",
  "roles/artifactregistry.reader",
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter"
]

# Storage Configuration
gcs_bucket_name     = "etl-gcs-bucket-dev"
gcs_bucket_location = "us-central1"
gcs_storage_class   = "STANDARD"    # Free tier eligible

# Startup Script Configuration
docker_packages = [
  "docker.io",
  "docker-compose"
]

additional_packages = [
  "curl",
  "wget",
  "git",
  "python3",
  "python3-pip"
]

# Startup script template path
startup_script_template = "scripts/startup.sh.tpl"

# Security Configuration
allow_ssh_from_internet = true    # For dev environment
ssh_source_ranges = ["0.0.0.0/0"] # Restrict this for production

# Firewall rules
firewall_rules = [
  {
    name        = "allow-ssh-dev"
    direction   = "INGRESS"
    priority    = 1000
    ports       = ["22"]
    protocol    = "tcp"
    source_tags = []
    target_tags = ["ssh-allowed"]
  },
  {
    name        = "allow-http-dev"
    direction   = "INGRESS"
    priority    = 1000
    ports       = ["80", "8080"]
    protocol    = "tcp"
    source_tags = []
    target_tags = ["http-allowed"]
  }
]

# Instance Tags
instance_tags = ["ssh-allowed", "http-allowed", "dev-environment"]

# Labels for resource organization
common_labels = {
  environment = "dev"
  project     = "data-migration"
  managed_by  = "terraform"
  cost_center = "personal"
  owner       = "jhazured"
}

# Monitoring and Logging (minimal for cost savings)
enable_monitoring = true
enable_logging    = true
log_retention_days = 7  # Short retention for dev

# Secret Manager Configuration (optional)
create_secrets = false  # Set to true if you need secret management

# Backup Configuration (minimal for dev)
enable_backups = false
backup_schedule = "0 2 * * *"  # Daily at 2 AM if enabled

# Auto-scaling Configuration (disabled for free tier)
enable_autoscaling = false
min_replicas = 1
max_replicas = 1

# Cost Optimization Settings
preemptible = false  # Set to true for even more cost savings (but instances can be terminated)
automatic_restart = true
on_host_maintenance = "MIGRATE"

# Development-specific settings
enable_serial_console = true
enable_display = false
enable_ip_forwarding = false

# Metadata
metadata = {
  enable-oslogin = "TRUE"
  startup-script-url = ""  # Will be populated by template
  ssh-keys = ""  # Add your SSH public key here if needed
}

# Data Migration Specific Configuration
etl_image_name = "etl_image"
etl_image_tag  = "latest"

# Database Configuration (if needed)
# Uncomment and configure if you need Cloud SQL
# enable_cloud_sql = false
# db_instance_name = "etl-db-dev"
# db_version = "POSTGRES_13"
# db_tier = "db-f1-micro"  # Always Free tier eligible

# Pub/Sub Configuration (if needed)
# enable_pubsub = false
# pubsub_topics = ["etl-events", "etl-errors"]

# BigQuery Configuration (if needed)
# enable_bigquery = false
# bq_dataset_name = "etl_dataset_dev"
# bq_location = "us-central1"

# Scheduler Configuration (if needed)
# enable_scheduler = false
# scheduler_jobs = []

# Notification Configuration
# notification_email = "your-email@example.com"
# enable_alerts = false