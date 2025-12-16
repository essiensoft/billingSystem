#!/bin/bash

# SSL Certificate Setup Script for PHPNuxBill
# Run this ONCE on your VPS to set up SSL certificates
# After this, renewal is automatic via cron

set -e

echo "========================================="
echo "PHPNuxBill SSL Certificate Setup"
echo "========================================="
echo ""

# Configuration
DOMAIN="mulanet.cloud"
EMAIL=""
SSL_DIR="/opt/mulanet/billingSystem/ssl"
CONTAINER_NAME="phpnuxbill-app"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Get email if not provided
if [ -z "$EMAIL" ]; then
    read -p "Enter your email for Let's Encrypt notifications: " EMAIL
fi

echo "Configuration:"
echo "  Domain: $DOMAIN"
echo "  Email: $EMAIL"
echo "  SSL Directory: $SSL_DIR"
echo ""

read -p "Continue with SSL setup? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 0
fi

# Step 1: Install Certbot
echo ""
echo "Step 1: Installing Certbot..."
if command -v certbot &> /dev/null; then
    echo "✓ Certbot already installed"
else
    apt update
    apt install certbot -y
    echo "✓ Certbot installed"
fi

# Step 2: Stop container
echo ""
echo "Step 2: Stopping PHPNuxBill container..."
if docker ps | grep -q $CONTAINER_NAME; then
    docker stop $CONTAINER_NAME
    echo "✓ Container stopped"
else
    echo "⚠ Container not running"
fi

# Step 3: Obtain certificate
echo ""
echo "Step 3: Obtaining SSL certificate from Let's Encrypt..."
certbot certonly --standalone \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --email $EMAIL \
    --agree-tos \
    --non-interactive \
    --preferred-challenges http

if [ $? -eq 0 ]; then
    echo "✓ Certificate obtained successfully"
else
    echo "❌ Failed to obtain certificate"
    echo "Starting container..."
    docker start $CONTAINER_NAME
    exit 1
fi

# Step 4: Create SSL directory and copy certificates
echo ""
echo "Step 4: Copying certificates..."
mkdir -p $SSL_DIR
cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem $SSL_DIR/
cp /etc/letsencrypt/live/$DOMAIN/privkey.pem $SSL_DIR/
chmod 644 $SSL_DIR/*.pem
echo "✓ Certificates copied to $SSL_DIR"

# Step 5: Verify certificates
echo ""
echo "Step 5: Verifying certificates..."
if [ -f "$SSL_DIR/fullchain.pem" ] && [ -f "$SSL_DIR/privkey.pem" ]; then
    echo "✓ Certificates verified:"
    ls -lh $SSL_DIR/
else
    echo "❌ Certificate files not found"
    exit 1
fi

# Step 6: Start container
echo ""
echo "Step 6: Starting PHPNuxBill container..."
docker start $CONTAINER_NAME

# Wait for container to be healthy
sleep 5

if docker ps | grep -q $CONTAINER_NAME; then
    echo "✓ Container started successfully"
else
    echo "❌ Container failed to start"
    echo "Check logs: docker logs $CONTAINER_NAME"
    exit 1
fi

# Step 7: Set up auto-renewal
echo ""
echo "Step 7: Setting up automatic renewal..."

# Create renewal script
cat > /opt/mulanet/billingSystem/renew-ssl.sh << 'EOF'
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
    
    # Copy new certificates
    echo "Copying certificates..."
    cp /etc/letsencrypt/live/mulanet.cloud/fullchain.pem /opt/mulanet/billingSystem/ssl/
    cp /etc/letsencrypt/live/mulanet.cloud/privkey.pem /opt/mulanet/billingSystem/ssl/
    chmod 644 /opt/mulanet/billingSystem/ssl/*.pem
    
    echo "✓ Certificates copied"
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
EOF

chmod +x /opt/mulanet/billingSystem/renew-ssl.sh
echo "✓ Renewal script created"

# Add to crontab
CRON_JOB="0 3 1 * * /opt/mulanet/billingSystem/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1"
(crontab -l 2>/dev/null | grep -v "renew-ssl.sh"; echo "$CRON_JOB") | crontab -
echo "✓ Cron job added (runs monthly on the 1st at 3 AM)"

# Step 8: Test SSL
echo ""
echo "Step 8: Testing SSL configuration..."
sleep 5

if curl -k -s https://$DOMAIN > /dev/null 2>&1; then
    echo "✓ HTTPS is working!"
else
    echo "⚠ HTTPS test failed (this is normal if you haven't updated docker-compose yet)"
fi

# Final summary
echo ""
echo "========================================="
echo "✅ SSL Setup Complete!"
echo "========================================="
echo ""
echo "Certificates installed:"
echo "  - Fullchain: $SSL_DIR/fullchain.pem"
echo "  - Private Key: $SSL_DIR/privkey.pem"
echo ""
echo "Auto-renewal configured:"
echo "  - Script: /opt/mulanet/billingSystem/renew-ssl.sh"
echo "  - Schedule: Monthly on the 1st at 3 AM"
echo "  - Logs: /var/log/ssl-renewal.log"
echo ""
echo "Next steps:"
echo "  1. Update your Portainer stack with SSL volume mounts"
echo "  2. Rebuild Docker image with SSL support"
echo "  3. Test HTTPS: https://$DOMAIN"
echo ""
echo "Certificate expires in 90 days and will auto-renew."
echo ""
