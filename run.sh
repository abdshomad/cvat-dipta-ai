#!/bin/bash
# Copyright (C) CVAT.ai Corporation
#
# SPDX-License-Identifier: MIT
#
# CVAT Run Script
# This script runs CVAT in foreground mode with live logs

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

# Trap Ctrl+C to stop services gracefully
cleanup() {
    echo ""
    print_warn "Received interrupt signal. Stopping services..."
    docker compose down
    print_info "Services stopped."
    exit 0
}

trap cleanup INT TERM

print_info "Running CVAT in foreground mode..."
print_info "CVAT_HOST: $CVAT_HOST"
print_info "CVAT_VERSION: $CVAT_VERSION"
print_info "Press Ctrl+C to stop services"
echo ""

# Check if services are already running
if docker compose ps | grep -q "Up"; then
    print_warn "CVAT services are already running. Stopping them first..."
    docker compose down
    sleep 2
fi

# Start services in foreground mode (without -d flag)
export CVAT_HOST
export CVAT_VERSION
print_info "Starting CVAT services and streaming logs..."
echo ""

# Run in foreground and follow logs
docker compose up --follow

