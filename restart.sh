#!/bin/bash
# Copyright (C) CVAT.ai Corporation
#
# SPDX-License-Identifier: MIT
#
# CVAT Restart Script
# This script restarts CVAT services (stop then start)

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

print_info "Restarting CVAT services..."
echo ""

# Stop services
print_info "Stopping CVAT services..."
if docker compose ps | grep -q "Up"; then
    docker compose down
    print_info "Services stopped."
else
    print_warn "Services were not running."
fi

# Wait a moment
sleep 2

# Start services
print_info "Starting CVAT services..."

# Set CVAT_HOST from .env or use default
CVAT_HOST=${CVAT_HOST:-dipta-ai-cvat.demoin.id}
CVAT_VERSION=${CVAT_VERSION:-dev}

export CVAT_HOST
export CVAT_VERSION
docker compose up -d

# Wait a moment for services to start
sleep 3

# Show status
print_info "CVAT services restarted. Status:"
echo ""
docker compose ps

echo ""
print_info "CVAT is accessible at: http://$CVAT_HOST:8081"
print_info "Or locally at: http://localhost:8081"

