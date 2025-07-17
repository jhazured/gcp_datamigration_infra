#!/bin/bash

# ETL Project Task Runner for GCP (Simplified)
# Usage: ./run_tasks.sh [task] [options]
# Primarily handles pushing local images and cleanup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="etl-project"
DOCKER_REGISTRY="gcr.io/$(gcloud config get-value project)"  # Auto-detect GCP project ID via gcloud
UBUNTU_IMAGE="ubuntu-etl"
JENKINS_IMAGE="jenkins-etl"
ANSIBLE_IMAGE="ansible-etl"

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites function
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! command_exists gcloud; then
        print_error "gcloud CLI is not installed or not in PATH"
        exit 1
    fi
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "Not authenticated with gcloud. Run 'gcloud auth login'"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Deploy Docker images (optionally with full tag)
deploy_to_gcp() {
    local image_tag="${1:-latest}"
    print_status "Deploying images to GCP Container Registry with tag: $image_tag"
    
    gcloud auth configure-docker --quiet
    
    # Helper to tag and push an image if it exists
    push_image_if_exists() {
        local local_image="$1"
        local full_image="$2"
        
        if docker image inspect ${local_image} >/dev/null 2>&1; then
            docker tag ${local_image} ${full_image}
            docker push ${full_image}
            print_success "Pushed image: ${full_image}"
        else
            print_warning "Skipping push: image ${local_image} not found"
        fi
    }
    
    push_image_if_exists "${UBUNTU_IMAGE}:${image_tag}" "${DOCKER_REGISTRY}/${UBUNTU_IMAGE}:${image_tag}"
    push_image_if_exists "${JENKINS_IMAGE}:${image_tag}" "${DOCKER_REGISTRY}/${JENKINS_IMAGE}:${image_tag}"
    push_image_if_exists "${ANSIBLE_IMAGE}:${image_tag}" "${DOCKER_REGISTRY}/${ANSIBLE_IMAGE}:${image_tag}"
    
    print_success "All images deployed to GCP with tag: $image_tag"
}

# Clean up function (remove dangling images, pycache)
cleanup() {
    print_status "Cleaning up..."
    
    docker image prune -f
    
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    
    print_success "Cleanup completed"
}

# Help message
show_help() {
    echo "ETL Project Task Runner (Simplified)"
    echo ""
    echo "Usage: ./run_tasks.sh [TASK] [OPTIONAL_IMAGE_TAG]"
    echo ""
    echo "Tasks:"
    echo "  deploy [tag]      Push Docker images with optional tag (default: latest)"
    echo "  cleanup           Cleanup dangling images and python caches"
    echo "  help              Show this help message"
    echo ""
    echo "Example:"
    echo "  ./run_tasks.sh deploy prod-42"
}

# Main logic
case "${1:-help}" in
    deploy)
        check_prerequisites
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
