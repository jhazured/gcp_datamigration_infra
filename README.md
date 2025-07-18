# gcp_datamigration_infra

Infrastructure automation project for provisioning and managing Google Cloud Platform (GCP) resources needed by an ETL data migration pipeline. This project leverages **Terraform**, **Ansible**, and **Jenkins** to automate infrastructure lifecycle management in a reproducible and secure manner.

---

## Features

- Declarative infrastructure provisioning using Terraform modules.
- Automated resource setup and teardown via Ansible playbooks.
- Dockerized Ansible environment for consistent automation runs.
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
│   │   ├── decom_gcp_resources.yml
│   │   └── setup_gcp_resources.yml
│   ├── requirements.yml
│   ├── roles
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
│   ├── delete_etl.sh
│   └── run_tasks.sh
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

## Jenkins Pipelines

There is one Jenkinsfile used for both infrastructure and Docker image workflows:

Jenkinsfile:

Handles the following actions:

     1. terraform_apply – Create core infrastructure (networks, VMs, artifact registry, etc.)
     2. setup_gcp – Run Ansible to set up service accounts, secrets, and IAM roles.
     3. build_and_deploy_images – Build and push Docker images (Ansible, Terraform, Ubuntu).
     4. decom_gcp – Run Ansible to safely decommission GCP resources created by Ansible.
     5. terraform_destroy – Destroy all Terraform-managed infrastructure.
     6. delete_images – Remove local Docker images from the Jenkins agent.

## Setup Instructions

    1. Configure Jenkins and set up pipelines from jenkins/Jenkinsfile.*
    2. Add your GCP Service Account JSON key as a Secret file credential in Jenkins with an ID (e.g., gcp-service-account-key).
    3. Build and push Docker images using build_and_deploy_images
    4. Provision infrastructure using terraform_apply
    5. Set up GCP resources using setup_gcp
    6. Run your ETL pipeline: 
        - Set pipeline parameters (ENV, ACTION) on job trigger.
    7. Tear down resources in this order:
        - decom_gcp (Ansible cleanup)
        - terraform_destroy (Terraform teardown)
        - delete_images (Ubuntu local cleanup)

## Terraform
    1. Customize Terraform variables per environment under terraform/envs/<env>/.
    2. Terraform manages declarative provisioning and teardown of core infrastructure.

## Ansible
    1. Run setup_gcp_resources.yml to provision Artifact Registry, Service Accounts, IAM roles, and other resources.
    2. Run decom_gcp_resources.yml to decommission resources cleanly.
    3. Ansible runs inside the Docker container defined by docker/Dockerfile.ansible.

## Pipeline Actions

The pipeline consists of four main actions that work together to manage your GCP infrastructure lifecycle:

| ACTION                    | Description                                                  |
|---------------------------|--------------------------------------------------------------|
| terraform_apply           | Initialize and apply Terraform configurations to provision core GCP infrastructure resources (networks, compute instances, artifact registries, etc.). |
| setup_gcp                 | Run Ansible playbooks to provision additional resources and perform orchestration tasks such as creating service accounts, assigning IAM roles, and managing secrets. |
| decom_gcp                 | Run Ansible playbooks to decommission or clean up resources provisioned by Ansible, ensuring a safe teardown of service accounts, IAM roles, storage buckets, and other artifacts. |
| terraform_destroy         | Destroy all Terraform-managed infrastructure resources, cleaning up the core infrastructure created in the initial apply step. |
| build_and_deploy_images	| Build Docker images for ETL runners and automation tools and push them to the Artifact Registry.
| delete_images	            | Delete local Docker images from Jenkins agents

These actions are triggered by Jenkins with parameters:

    - ENV: Target environment (dev, test, uat, prod)
    - ACTION: Desired action from the table above

### How These Actions Work Together

1. **terraform_apply** runs first to create the base infrastructure required by your application.  
2. **setup_gcp** follows to configure and provision additional resources and secrets that Terraform does not manage.  
3. When decommissioning, **decom_gcp** runs first to safely remove resources managed by Ansible.  
4. Finally, **terraform_destroy** cleans up the remaining core infrastructure managed by Terraform.

This sequence ensures a clean, reliable, and automated lifecycle for your GCP infrastructure, with Terraform handling declarative resource provisioning and Ansible managing procedural orchestration and configuration.

## Docker Images

The following images are built and managed:

    1. ubuntu-etl:latest    – Runtime for ETL execution
    2. ansible-etl:latest   – Ansible automation runner
    3. terraform:latest     – Terraform automation runner

They are built from docker/Dockerfile.* files and tagged/pushed to: gcr.io/<your-gcp-project-id>/<repo-name>

## Secrets & Credentials

    - Secrets are stored in GCP Secret Manager
    - Service account keys are injected into Jenkins via withCredentials
    - Ansible reads environment variables from .env.j2 templates

✅ Best Practices

    - Use environment-specific .tfvars and .env files to separate config.
    - Always run decom_gcp before terraform_destroy to clean up dependent resources.
    - Keep Jenkins credentials tightly scoped.
    - Use Dockerized runners for consistency.
    - Store Terraform state remotely (see backend.tf).

## Best Practices
    Secure .env and credential files; avoid committing sensitive data.
    Use remote state backend for Terraform (configured in backend.tf).
    Modularize Ansible playbooks into roles for scalability.
    Regularly rotate service account keys and secrets.
    Monitor Jenkins logs for pipeline execution details.

## Troubleshooting
    Verify GCP permissions and enabled APIs.
    Test Ansible playbooks locally by running the Docker image interactively.
    Check Jenkins credential configuration.
    Confirm Terraform state file consistency.

## Contribution
    Feel free to open issues or submit pull requests to improve this project.

