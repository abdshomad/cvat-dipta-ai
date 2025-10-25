#!/bin/bash
# Script to add CVAT hostname to /etc/hosts
# Run with: sudo bash add-host.sh

HOSTNAME="dipta-ai-cvat.demoin.id"

# Check if entry already exists
if grep -q "$HOSTNAME" /etc/hosts; then
    echo "Entry for $HOSTNAME already exists in /etc/hosts"
else
    echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
    echo "Successfully added $HOSTNAME to /etc/hosts"
fi

