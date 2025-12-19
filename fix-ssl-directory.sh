#!/bin/bash

# Quick Fix for SSL Directory Error
# Run this on your VPS to immediately fix the "No such file or directory" error

set -e

echo "========================================="
echo "SSL Directory Quick Fix"
echo "========================================="
echo ""

# Create SSL directory
echo "Creating SSL directory..."
sudo mkdir -p /opt/mulanet/billingSystem/ssl
echo "✓ Directory created"

# Check if Let's Encrypt certificates exist
if [ -d "/etc/letsencrypt/live/mulanet.cloud" ]; then
    echo ""
    echo "Found existing Let's Encrypt certificates"
    echo "Copying certificates..."
    
    sudo cp /etc/letsencrypt/live/mulanet.cloud/fullchain.pem /opt/mulanet/billingSystem/ssl/
    sudo cp /etc/letsencrypt/live/mulanet.cloud/privkey.pem /opt/mulanet/billingSystem/ssl/
    sudo chmod 644 /opt/mulanet/billingSystem/ssl/*.pem
    sudo chown root:root /opt/mulanet/billingSystem/ssl/*.pem
    
    echo "✓ Certificates copied"
else
    echo ""
    echo "⚠ No Let's Encrypt certificates found"
    echo "You need to obtain SSL certificates first."
    echo ""
    echo "Run one of these commands:"
    echo "  1. sudo bash /opt/mulanet/billingSystem/setup-ssl.sh"
    echo "  2. Or manually: sudo certbot certonly --standalone -d mulanet.cloud -d www.mulanet.cloud"
fi

# Verify
echo ""
echo "Verifying..."
ls -la /opt/mulanet/billingSystem/ssl/

echo ""
echo "========================================="
echo "✅ Fix Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. If you don't have certificates yet, run: sudo bash setup-ssl.sh"
echo "  2. Restart your Docker containers"
echo "  3. Test HTTPS: https://mulanet.cloud"
echo ""
