#!/bin/bash

# ETL Project Task Runner for GCP
# Usage: ./deploy_images.sh [task] [options]
# Handles Docker image build, test, push, and cleanup for GCP ETL pipeline.

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project config
PROJECT_NAME="etl-project"
DOCKER_REGISTRY="gcr.io/$(gcloud config get-value project)"
UBUNTU_IMAGE="ubuntu-etl"
TERRAFORM_IMAGE="terraform-etl"
ANSIBLE_IMAGE="ansible-etl"

# Status printers
print_status()   { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success()  { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning()  { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()    { echo -e "${RED}[ERROR]${NC} $1"; }

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_prerequisites() {
    print_status "Checking prerequisites..."
    if ! command_exists docker; then
        print_error "Docker not found"; exit 1; fi
    if ! command_exists gcloud; then
        print_error "gcloud not found"; exit 1; fi
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "gcloud not authenticated"; exit 1; fi
    print_success "All prerequisites satisfied"
}

build_images() {
    print_status "Building Docker images..."
    docker build -f docker/Dockerfile.ubuntu -t ${UBUNTU_IMAGE}:latest .
    docker build -f docker/Dockerfile.terraform -t ${TERRAFORM_IMAGE}:latest .
    docker build -f docker/Dockerfile.ansible -t ${ANSIBLE_IMAGE}:latest .
    print_success "Docker images built successfully"
}

test_images() {
    print_status "Testing Docker images..."
    for IMAGE in ${UBUNTU_IMAGE} ${TERRAFORM_IMAGE} ${ANSIBLE_IMAGE}; do
        if docker image inspect ${IMAGE}:latest >/dev/null 2>&1; then
            print_success "${IMAGE} passed inspection"
        else
            print_error "${IMAGE} missing or broken"
            exit 1
        fi
    done
}

deploy_to_gcp() {
    local tag="${1:-latest}"
    print_status "Deploying images with tag: $tag"
    gcloud auth configure-docker --quiet

    push_image_if_exists() {
        local local_image="$1"
        local remote_image="$2"
        if docker image inspect ${local_image} >/dev/null 2>&1; then
            docker tag ${local_image} ${remote_image}
            docker push ${remote_image}
            print_success "Pushed: ${remote_image}"
        else
            print_warning "Image ${local_image} not found, skipping..."
        fi
    }

    push_image_if_exists "${UBUNTU_IMAGE}:${tag}" "${DOCKER_REGISTRY}/${UBUNTU_IMAGE}:${tag}"
    push_image_if_exists "${TERRAFORM_IMAGE}:${tag}" "${DOCKER_REGISTRY}/${TERRAFORM_IMAGE}:${tag}"
    push_image_if_exists "${ANSIBLE_IMAGE}:${tag}" "${DOCKER_REGISTRY}/${ANSIBLE_IMAGE}:${tag}"
    print_success "All images deployed"
}

cleanup() {
    print_status "Cleaning up local environment..."
    docker image prune -f
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    print_success "Cleanup done"
}

show_help() {
    echo "ETL Docker Task Runner"
    echo ""
    echo "Usage: ./deploy_images.sh [TASK] [OPTIONAL_TAG]"
    echo ""
    echo "Tasks:"
    echo "  build            Build Docker images"
    echo "  test             Inspect Docker images"
    echo "  deploy [tag]     Push images to GCP (default tag: latest)"
    echo "  all [tag]        Run full pipeline: build -> test -> deploy"
    echo "  cleanup          Remove unused images and pycache"
    echo "  help             Show this help message"
}

# Command handler
case "${1:-help}" in
    build)
        check_prerequisites
        build_images
        ;;
    test)
        test_images
        ;;
    deploy)
        check_prerequisites
        deploy_to_gcp "$2"
        ;;
    all)
        check_prerequisites
        build_images
        test_images
        deploy_to_gcp "$2"
        ;;
    cleanup)
        cleanup
        ;;
    help|*)
        show_help
        exit 0
        ;;
esac
