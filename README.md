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
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   │   └── localhost.yml
│   ├── playbook/
│   │   ├── build_push_image.yml
│   │   ├── decom_gcp_resources.yml
│   │   ├── deploy.yml
│   │   ├── deploy_infra.yml
│   │   ├── deploy_jenkins.yml
│   │   └── setup_gcp_resources.yml
│   ├── roles/
│   └── templates/
│       └── .env.j2
├── docker/
│   ├── Dockerfile.ansible
│   ├── Dockerfile.jenkins
│   └── Dockerfile.ubuntu
├── env/
├── jenkins/
│   ├── Jenkinsfile.docker
│   └── Jenkinsfile.infra
├── scripts/
│   ├── delete_etl.sh
│   └── tasks.sh
└── terraform/
    ├── backend.tf
    ├── envs/
    │   ├── dev/
    │   ├── prod/
    │   ├── test/
    │   └── uat/
    └── modules/
        ├── artifact_registry/
        ├── compute_instance/
        └── network/

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

## Setup Instructions
    1. Configure Jenkins.
    2. Add your GCP Service Account JSON key as a Secret file credential in Jenkins with an ID (e.g., gcp-service-account-key).
    3. Create Jenkins pipeline jobs using the appropriate Jenkinsfiles:
    4. jenkins/Jenkinsfile.infra for infrastructure provisioning.
    5. jenkins/Jenkinsfile.docker for Docker image build and push.
    6. Set pipeline parameters (ENV, ACTION) on job trigger.

## Terraform
    1. Customize Terraform variables per environment under terraform/envs/<env>/.
    2. Terraform manages declarative provisioning and teardown of core infrastructure.

## Ansible
    1. Run setup_gcp_resources.yml to provision Artifact Registry, Service Accounts, IAM roles, and other resources.
    2. Run decom_gcp_resources.yml to decommission resources cleanly.
    3. Ansible runs inside the Docker container defined by docker/Dockerfile.ansible.

## Pipeline Actions

The pipeline consists of four main actions that work together to manage your GCP infrastructure lifecycle:

| ACTION             | Description                                                  |
|--------------------|--------------------------------------------------------------|
| terraform_apply    | Initialize and apply Terraform configurations to provision core GCP infrastructure resources (networks, compute instances, artifact registries, etc.). |
| setup_gcp          | Run Ansible playbooks to provision additional resources and perform orchestration tasks such as creating service accounts, assigning IAM roles, and managing secrets. |
| decom_gcp          | Run Ansible playbooks to decommission or clean up resources provisioned by Ansible, ensuring a safe teardown of service accounts, IAM roles, storage buckets, and other artifacts. |
| terraform_destroy  | Destroy all Terraform-managed infrastructure resources, cleaning up the core infrastructure created in the initial apply step. |

### How These Actions Work Together

1. **terraform_apply** runs first to create the base infrastructure required by your application.  
2. **setup_gcp** follows to configure and provision additional resources and secrets that Terraform does not manage.  
3. When decommissioning, **decom_gcp** runs first to safely remove resources managed by Ansible.  
4. Finally, **terraform_destroy** cleans up the remaining core infrastructure managed by Terraform.

This sequence ensures a clean, reliable, and automated lifecycle for your GCP infrastructure, with Terraform handling declarative resource provisioning and Ansible managing procedural orchestration and configuration.

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

