#!/bin/bash
# Copyright (C) CVAT.ai Corporation
#
# SPDX-License-Identifier: MIT
#
# CVAT Start Script
# This script starts CVAT services using Docker Compose

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

print_info "Starting CVAT services..."
print_info "CVAT_HOST: $CVAT_HOST"
print_info "CVAT_VERSION: $CVAT_VERSION"
echo ""

# Check if services are already running
if docker compose ps | grep -q "Up"; then
    print_warn "CVAT services are already running."
    docker compose ps
    exit 0
fi

# Start services
export CVAT_HOST
export CVAT_VERSION
docker compose up -d

# Wait a moment for services to start
sleep 3

# Show status
print_info "CVAT services started. Status:"
echo ""
docker compose ps

echo ""
print_info "CVAT is accessible at: http://$CVAT_HOST:8081"
print_info "Or locally at: http://localhost:8081"
print_info "To view logs: docker compose logs -f"
print_info "To monitor: ./monitor.sh"

