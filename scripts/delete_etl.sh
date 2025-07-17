#!/bin/bash

set -e

ENV=$1
REMOTE_DELETE=$2  # Pass 'remote' to delete from Artifact Registry
PROJECT_ID="${GCP_PROJECT_ID:-your-gcp-project-id}"
REGION="${GCP_REGION:-us-central1}"
REPO_NAME="${GCP_ARTIFACT_REPO:-my-etl-repo}"
IMAGE_NAME="my_etl_image:${ENV}"

# Print usage
if [[ -z "$ENV" ]]; then
  echo "Usage: ./scripts/delete_etl.sh <env> [remote]"
  echo "Example: ./scripts/delete_etl.sh dev"
  echo "         ./scripts/delete_etl.sh dev remote"
  exit 1
fi

echo "Deleting ETL image for environment: $ENV"

if [[ "$REMOTE_DELETE" == "remote" ]]; then
  echo "Deleting image from Artifact Registry..."
  gcloud artifacts docker images delete \
    "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/my_etl_image:${ENV}" \
    --quiet || echo "Remote image not found or already deleted."
else
  echo "Deleting local Docker image..."
  docker rmi "${IMAGE_NAME}" || echo "Local image not found or already deleted."
fi

echo "Image deletion completed for environment: $ENV"
