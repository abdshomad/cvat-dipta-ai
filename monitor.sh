#!/bin/bash
# Copyright (C) CVAT.ai Corporation
#
# SPDX-License-Identifier: MIT
#
# CVAT Monitor Script
# This script monitors CVAT services status, health, and logs

set -e

# Source .env file if it exists
[ -f .env ] && source .env

# Set CVAT_HOST from .env or use default
CVAT_HOST=${CVAT_HOST:-dipta-ai-cvat.demoin.id}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Check if running from correct directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found. Please run this script from the CVAT root directory."
    exit 1
fi

# Function to show service status
show_status() {
    print_header "Service Status"
    docker compose ps
    echo ""
}

# Function to show resource usage
show_resources() {
    print_header "Resource Usage"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" $(docker compose ps -q)
    echo ""
}

# Function to check health
check_health() {
    print_header "Health Check"

    # Check if server is responding
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8081/api/server/health" | grep -q "200"; then
        print_info "CVAT server is healthy (HTTP 200)"
    else
        print_warn "CVAT server health check failed or server is not ready"
    fi
    echo ""
}

# Function to show logs
show_logs() {
    print_header "Recent Logs (last 50 lines)"
    docker compose logs --tail=50
    echo ""
}

# Main menu
while true; do
    clear
    print_header "CVAT Service Monitor"
    echo "CVAT_HOST: $CVAT_HOST"
    echo ""

    show_status

    echo "Options:"
    echo "  1) Show detailed status"
    echo "  2) Show resource usage"
    echo "  3) Check health"
    echo "  4) View logs (last 50 lines)"
    echo "  5) Follow logs (live, Ctrl+C to exit)"
    echo "  6) Show logs for specific service"
    echo "  7) Refresh"
    echo "  8) Exit"
    echo ""
    read -p "Select an option [1-8]: " choice

    case $choice in
        1)
            clear
            show_status
            docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        2)
            clear
            show_resources
            read -p "Press Enter to continue..."
            ;;
        3)
            clear
            check_health
            read -p "Press Enter to continue..."
            ;;
        4)
            clear
            show_logs
            read -p "Press Enter to continue..."
            ;;
        5)
            clear
            print_header "Following Logs (Ctrl+C to exit)"
            docker compose logs -f
            ;;
        6)
            clear
            print_header "Available Services"
            docker compose ps --format "{{.Name}}"
            echo ""
            read -p "Enter service name: " service_name
            if [ -n "$service_name" ]; then
                clear
                print_header "Logs for $service_name (last 100 lines)"
                docker compose logs --tail=100 "$service_name"
                echo ""
                read -p "Press Enter to continue..."
            fi
            ;;
        7)
            continue
            ;;
        8)
            print_info "Exiting monitor..."
            exit 0
            ;;
        *)
            print_warn "Invalid option. Please try again."
            sleep 1
            ;;
    esac
done

