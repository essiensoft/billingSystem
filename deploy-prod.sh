#!/bin/bash
set -e

# PHPNuxBill Production Deployment Script
# This script automates the deployment process

echo "========================================="
echo "PHPNuxBill Production Deployment"
echo "========================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "Please copy .env.example to .env and configure it"
    echo ""
    echo "  cp .env.example .env"
    echo "  nano .env"
    echo ""
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
if [ -z "$DB_PASS" ] || [ "$DB_PASS" == "change_this_db_password_now" ]; then
    echo "❌ Error: Please set DB_PASS in .env file"
    exit 1
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ "$MYSQL_ROOT_PASSWORD" == "change_this_root_password_now" ]; then
    echo "❌ Error: Please set MYSQL_ROOT_PASSWORD in .env file"
    exit 1
fi

if [ -z "$APP_URL" ] || [ "$APP_URL" == "http://your-domain.com" ]; then
    echo "❌ Error: Please set APP_URL in .env file"
    exit 1
fi

echo "✅ Environment configuration validated"
echo ""

# Build Docker images
echo "🔨 Building Docker images..."
docker-compose -f docker-compose.prod.yml build

echo ""
echo "✅ Docker images built successfully"
echo ""

# Start services
echo "🚀 Starting services..."
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check health
echo ""
echo "🏥 Checking service health..."
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "========================================="
echo "✅ Deployment Complete!"
echo "========================================="
echo ""
echo "Application URL: $APP_URL"
echo ""
echo "📋 Next Steps:"
echo "  1. Visit $APP_URL to complete setup"
echo "  2. Check logs: docker-compose -f docker-compose.prod.yml logs -f"
echo "  3. Monitor health: docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "🔧 Useful Commands:"
echo "  - View logs: docker-compose -f docker-compose.prod.yml logs -f app"
echo "  - Restart: docker-compose -f docker-compose.prod.yml restart"
echo "  - Stop: docker-compose -f docker-compose.prod.yml down"
echo "  - Backup DB: docker exec phpnuxbill-mysql mysqldump -u root -p\$MYSQL_ROOT_PASSWORD phpnuxbill > backup.sql"
echo ""
