#!/bin/bash

set -e

ENV_OR_TAG=$1
REMOTE_DELETE=$2  # Pass 'remote' to delete from Artifact Registry
PROJECT_ID="${GCP_PROJECT_ID:-your-gcp-project-id}"
REGION="${GCP_REGION:-us-central1}"
REPO_NAME="${GCP_ARTIFACT_REPO:-my-etl-repo}"
IMAGE_NAME="my_etl_image"

# Print usage
if [[ -z "$ENV_OR_TAG" ]]; then
  echo "Usage: ./scripts/delete_etl.sh <env_or_tag> [remote]"
  echo "Example: ./scripts/delete_etl.sh dev"
  echo "         ./scripts/delete_etl.sh prod-42 remote"
  exit 1
fi

TAG=$ENV_OR_TAG

echo "Deleting ETL image with tag: $TAG"

if [[ "$REMOTE_DELETE" == "remote" ]]; then
  echo "Deleting image from Artifact Registry..."
  gcloud artifacts docker images delete \
    "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${TAG}" \
    --quiet || echo "Remote image not found or already deleted."
else
  echo "Deleting local Docker image..."
  docker rmi "${IMAGE_NAME}:${TAG}" || echo "Local image not found or already deleted."
fi

echo "Image deletion completed for tag: $TAG"
