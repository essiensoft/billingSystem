#!/bin/bash

# SSL Certificate Renewal Script for PHPNuxBill
# This script renews Let's Encrypt certificates and updates the Docker container

set -e

echo "========================================="
echo "SSL Certificate Renewal"
echo "Date: $(date)"
echo "========================================="

# Stop container to free port 80
echo "Stopping PHPNuxBill container..."
docker stop phpnuxbill-app

# Renew certificate
echo "Renewing SSL certificate..."
certbot renew --quiet

# Check if renewal was successful
if [ $? -eq 0 ]; then
    echo "✓ Certificate renewed successfully"
    
    # Ensure SSL directory exists
    echo "Ensuring SSL directory exists..."
    mkdir -p /opt/mulanet/billingSystem/ssl
    
    # Copy new certificates
    echo "Copying certificates..."
    if cp /etc/letsencrypt/live/mulanet.cloud/fullchain.pem /opt/mulanet/billingSystem/ssl/ && \
       cp /etc/letsencrypt/live/mulanet.cloud/privkey.pem /opt/mulanet/billingSystem/ssl/; then
        chmod 644 /opt/mulanet/billingSystem/ssl/*.pem
        chown root:root /opt/mulanet/billingSystem/ssl/*.pem
        echo "✓ Certificates copied"
    else
        echo "✗ Failed to copy certificates"
        exit 1
    fi
else
    echo "✗ Certificate renewal failed"
fi

# Restart container
echo "Starting PHPNuxBill container..."
docker start phpnuxbill-app

# Wait for container to be healthy
sleep 10

# Check if container is running
if docker ps | grep -q phpnuxbill-app; then
    echo "✓ Container started successfully"
else
    echo "✗ Container failed to start"
    exit 1
fi

echo "========================================="
echo "SSL renewal completed successfully"
echo "========================================="
