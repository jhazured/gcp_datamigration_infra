# gcp_datamigration_infra

Infrastructure automation project for provisioning and managing Google Cloud Platform (GCP) resources needed by an ETL data migration pipeline. This project leverages **Terraform**, **Ansible**, and **Jenkins** to automate infrastructure lifecycle management in a reproducible and secure manner.

---

## Features

- Declarative infrastructure provisioning using Terraform modules.
- Automated resource setup and teardown via Ansible playbooks.
- Dockerized environments for ETL, Ansible, and Terraform.
- Ansible orchestrates the deployment, management, and cleanup of Docker containers.
- Jenkins pipeline integration for CI/CD of infrastructure and deployments.
- Support for multiple environments (dev, test, uat, prod).
- Secure handling of GCP credentials and secrets using Secret Manager.

---

## Project Structure

```plaintext
gcp_datamigration_infra/
├── README.md
├── ansible
│   ├── ansible.cfg
│   ├── group_vars
│   │   └── all.yml
│   ├── inventory
│   │   └── localhost.yml
│   ├── playbook
│   │   ├── init.yml
│   │   ├── build_and_deploy_images.yml
│   │   └── delete_images.yml
│   ├── requirements.yml
│   ├── roles
│   │   ├── docker_management
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── env_variables
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── secrets_manager
│   │       └── tasks
│   │           └── main.yml
│   └── templates
├── config
│   ├── log4j.properties
│   └── spark-defaults.conf
├── docker
│   ├── Dockerfile.ansible
│   ├── Dockerfile.terraform
│   └── Dockerfile.ubuntu
├── docker-compose.yml
├── env
├── jenkins
│   └── Jenkinsfile
├── makefile
├── requirements
│   ├── dev.txt
│   ├── prod.txt
│   ├── test.txt
│   └── uat.txt
├── scripts
│   ├── remove_images.sh
│   └── deploy_images.sh
└── terraform
    ├── backend.tf
    ├── envs
    │   ├── dev
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   ├── prod
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   ├── test
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   └── uat
    │       ├── main.tf
    │       ├── terraform.tfvars
    │       └── variables.tf
    └── modules
        ├── artifact_registry
        │   ├── main.tf
        │   └── variables.tf
        ├── compute_instance
        │   ├── iam.tf
        │   ├── main.tf
        │   └── variables.tf
        └── network
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
├── makefile
├── .gitignore

## Prerequisites
    - Jenkins with Docker and GCP CLI installed.
    - Google Cloud project with necessary APIs enabled:
        - Artifact Registry
        - Secret Manager
        - IAM
        - Storage
    - A Google Cloud Service Account with the following roles:
        - Artifact Registry Writer
        - Storage Admin
        - Secret Manager Accessor
        - Compute Admin (if managing compute resources)
    - Jenkins credentials configured to securely store the Service Account JSON key.

## Scripts

The scripts/ directory includes helper scripts used during local development or Jenkins pipeline runs:

        1. deploy_images.sh	
                - Wrapper script to invoke Ansible playbooks inside a Docker container. 
                - Supports dynamic environment (ENV) and action (ACTION) parameters for modular task execution. Useful for triggering builds, deploys, or configuration tasks.
        2. remove_images.sh	
                - Deletes built Docker images both locally and from GCP Artifact Registry. 
                - Useful for cleanup operations before destroying infrastructure or to free up storage in CI environments.

These scripts are primarily used by Jenkins or local developers to trigger automated steps consistently without needing to manually execute Docker or Ansible commands.

## Jenkins Pipelines

There is one Jenkinsfile used for both infrastructure and Docker image workflows:

Jenkinsfile:

A unified Jenkins pipeline for both infrastructure and Docker image management:

     1. init – Initialization stage that retrieves secrets and generates environment-specific `.env` files using Ansible. This ensures Docker and runtime containers are correctly configured.
     2. terraform_apply – Create core infrastructure (networks, VMs, artifact registry, service accounts, IAM roles, GCS bucket etc.)
     3. build_and_deploy_images – Build and push Docker images (Ansible, Terraform, Ubuntu).
     4. delete_images – Remove local Docker images created by Ansible.
     5. terraform_destroy – Destroy all Terraform-managed infrastructure.


## Setup Instructions

     1. Configure Jenkins and load the pipeline from jenkins/Jenkinsfile.
     2. Add your GCP Service Account JSON key as a Secret file credential in Jenkins with an ID (e.g., gcp-service-account-key).
     3. Run the following pipeline steps in order:
            - init
            - terraform_apply
            - build_and_deploy_images
            Teardown:
            - delete_images
            - terraform_destroy

## Pipeline Actions

The pipeline consists of four main actions that work together to manage your GCP infrastructure lifecycle:

| ACTION                    | Description                                                  |
|---------------------------|--------------------------------------------------------------|
| terraform_apply           | Initialize and apply Terraform configurations to provision core GCP infrastructure resources (networks, VMs, artifact registry, service accounts, IAM roles, GCS bucket etc). |
| terraform_destroy         | Destroy all Terraform-managed infrastructure resources, cleaning up the core infrastructure created in the initial apply step. |
| build_and_deploy_images	| Use Ansible to build Docker images for ETL runners and automation tools and push them to the Artifact Registry.
| delete_images	            | Use Ansible to delete Docker images.

These actions are triggered by Jenkins with parameters:

    - ENV: Target environment (dev, test, uat, prod)
    - ACTION: Desired action from the table above

### How These Actions Work Together

1. **init** retrieves secrets from GCP Secret Manager and generates your `.env` file using Ansible.
2. **terraform_apply** runs first to create the base infrastructure required by your application.  
3. **build_and_deploy_images** follows to configure and deploy docker images to run ETL jobs. 
4. **delete_images**  to safely remove docker containers managed by Ansible.  
5. **terraform_destroy** cleans up the remaining core infrastructure managed by Terraform.

This sequence ensures a clean, reliable, and automated lifecycle for your GCP infrastructure, with Terraform handling declarative resource provisioning and Ansible managing procedural orchestration and configuration.

## Terraform

Terraform is responsible for provisioning and managing core GCP infrastructure resources in a declarative manner. This includes:

    - Network: Create VPCs, subnets, firewalls.
    - Compute Instances: Create virtual machines (VMs) for running workloads.
    - Artifact Registry: Create repositories for storing Docker images and other artifacts.
    - GCS Buckets: Create Google Cloud Storage buckets for storing data.
    - IAM Roles and Policies: Define and assign IAM roles to service accounts.
    - Service Accounts: Create and manage service accounts for secure authentication.
    - Other GCP Resources: Any core infrastructure required for the pipeline.

Customize Terraform variables per environment under terraform/envs/<env>/.

## Ansible

Ansible is responsible for the configuration management and procedural setup of resources that require more orchestration and custom steps. This includes:

    - Configuring Secrets: Store and manage credentials in GCP Secret Manager
    - Environment Variables: Managing environment-specific configurations and credentials using templates (e.g., .env.j2).
    - Docker Image Management: Version control and pushing Docker images for ETL and automation tools.

Ansible runs inside the Docker container defined by docker/Dockerfile.ansible.

## Docker Images

The following images are built and managed:

    1. ubuntu-etl:latest    – Runtime for ETL execution
    2. ansible-etl:latest   – Ansible automation runner
    3. terraform:latest     – Terraform automation runner

They are built from docker/Dockerfile.* files and tagged/pushed to: gcr.io/<your-gcp-project-id>/<repo-name>

## Secrets & Credentials

    - Secrets are stored in GCP Secret Manager
    - Service account keys are injected into Jenkins via withCredentials
    - .env files generated using Ansible and templates/.env.j2

✅ Best Practices

    - Use environment-specific .tfvars and .env files to separate config.
    - Always run decom_gcp before terraform_destroy to clean up dependent resources.
    - Keep Jenkins credentials tightly scoped.
    - Use Dockerized runners for consistency.
    - Store Terraform state remotely (see backend.tf).

## Best Practices

    - Use .tfvars and .env files per environment
    - Run delete_images before terraform_destroy
    - Keep Jenkins credentials scoped and secure
    - Dockerize your toolchain for consistency
    - Store Terraform state remotely (see backend.tf)
    - Use Ansible roles for maintainable playbooks
    - Rotate secrets and credentials regularly

## Troubleshooting
    - Check GCP IAM permissions and APIs
    - Run Ansible tasks interactively in the container
    - Validate Jenkins credentials and log output
    - Ensure Terraform state file is not corrupted

## Contribution
    Feel free to open issues or submit pull requests to improve this project.

