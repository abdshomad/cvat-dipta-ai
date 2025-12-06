#!/bin/bash
# Copyright (C) CVAT.ai Corporation
#
# SPDX-License-Identifier: MIT
#
# CVAT Stop Script
# This script stops CVAT services using Docker Compose

set -e

# Source .env file if it exists
[ -f .env ] && source .env

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

print_info "Stopping CVAT services..."
echo ""

# Check if services are running
if ! docker compose ps | grep -q "Up"; then
    print_warn "CVAT services are not running."
    exit 0
fi

# Show current status
print_info "Current service status:"
docker compose ps
echo ""

# Ask about removing volumes
read -p "Do you want to remove volumes? This will delete all data! (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_warn "Stopping services and removing volumes..."
    docker compose down -v
    print_info "CVAT services stopped and volumes removed."
else
    print_info "Stopping services (keeping volumes)..."
    docker compose down
    print_info "CVAT services stopped. Volumes preserved."
fi

echo ""
print_info "To start CVAT again: ./start.sh"

