#!/bin/bash
# Copyright (C) CVAT.ai Corporation
#
# SPDX-License-Identifier: MIT
#
# CVAT Installation Script
# This script installs and sets up CVAT with Docker Compose

set -e

# Source .env file if it exists
[ -f .env ] && source .env

# Set CVAT_HOST from .env or use default
CVAT_HOST=${CVAT_HOST:-dipta-ai-cvat.demoin.id}
CVAT_VERSION=${CVAT_VERSION:-dev}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running from correct directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found. Please run this script from the CVAT root directory."
    exit 1
fi

print_info "CVAT Installation Script"
print_info "CVAT_HOST: $CVAT_HOST"
print_info "CVAT_VERSION: $CVAT_VERSION"
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_info "Docker found: $(docker --version)"

# Check for Docker Compose
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed or not available. Please install Docker Compose."
    exit 1
fi
print_info "Docker Compose found: $(docker compose version)"
echo ""

# Check if CVAT is already running
if docker compose ps | grep -q "Up"; then
    print_warn "CVAT services are already running."
    read -p "Do you want to continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled."
        exit 0
    fi
fi

# Pull Docker images
print_info "Pulling Docker images..."
export CVAT_HOST
export CVAT_VERSION
docker compose pull

# Start services
print_info "Starting CVAT services..."
docker compose up -d

# Wait for services to be ready
print_info "Waiting for services to be ready..."
sleep 5

# Check service status
print_info "Checking service status..."
docker compose ps

# Add hostname to /etc/hosts if not already present
if ! grep -q "$CVAT_HOST" /etc/hosts 2>/dev/null; then
    print_info "Hostname $CVAT_HOST not found in /etc/hosts"
    read -p "Do you want to add it to /etc/hosts? (requires sudo) (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if sudo bash -c "echo '127.0.0.1 $CVAT_HOST' >> /etc/hosts"; then
            print_info "Successfully added $CVAT_HOST to /etc/hosts"
        else
            print_warn "Failed to add hostname to /etc/hosts. You may need to add it manually."
        fi
    else
        print_warn "Skipping /etc/hosts update. You may need to add it manually:"
        print_info "  echo '127.0.0.1 $CVAT_HOST' | sudo tee -a /etc/hosts"
    fi
else
    print_info "Hostname $CVAT_HOST already exists in /etc/hosts"
fi

echo ""
print_info "Installation completed successfully!"
print_info "CVAT is accessible at: http://$CVAT_HOST:8081"
print_info "Or locally at: http://localhost:8081"
echo ""
print_info "To view logs: docker compose logs -f"
print_info "To check status: docker compose ps"
print_info "To stop CVAT: ./stop.sh"

