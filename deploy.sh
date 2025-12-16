#!/bin/bash

# PHPNuxBill Production Deployment Script
# This script automates the deployment process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKER_IMAGE="scorpionkingca/phpnuxbill"
VERSION="1.0.0"
COMPOSE_FILE="docker-compose.production.yml"

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_requirements() {
    print_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    print_success "Docker installed"
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    print_success "Docker Compose installed"
    
    if [ ! -f ".env" ]; then
        print_error ".env file not found. Copy .env.production.example to .env and configure it"
        exit 1
    fi
    print_success ".env file exists"
}

build_image() {
    print_info "Building Docker image..."
    docker build -t ${DOCKER_IMAGE}:${VERSION} -t ${DOCKER_IMAGE}:latest .
    print_success "Docker image built successfully"
}

push_image() {
    read -p "Do you want to push the image to Docker Hub? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Pushing image to Docker Hub..."
        docker push ${DOCKER_IMAGE}:${VERSION}
        docker push ${DOCKER_IMAGE}:latest
        print_success "Image pushed successfully"
    else
        print_warning "Skipping image push"
    fi
}

backup_database() {
    if docker ps | grep -q phpnuxbill-mysql; then
        print_info "Creating database backup..."
        BACKUP_DIR="./backups"
        mkdir -p ${BACKUP_DIR}
        BACKUP_FILE="${BACKUP_DIR}/db_backup_$(date +%Y%m%d_%H%M%S).sql"
        
        docker exec phpnuxbill-mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} phpnuxbill_prod > ${BACKUP_FILE}
        print_success "Database backed up to ${BACKUP_FILE}"
    else
        print_warning "No existing database to backup"
    fi
}

deploy_services() {
    print_info "Deploying services..."
    docker-compose -f ${COMPOSE_FILE} down
    docker-compose -f ${COMPOSE_FILE} up -d
    print_success "Services deployed"
}

wait_for_services() {
    print_info "Waiting for services to be healthy..."
    sleep 10
    
    # Check if containers are running
    if docker-compose -f ${COMPOSE_FILE} ps | grep -q "Up"; then
        print_success "Services are running"
    else
        print_error "Services failed to start. Check logs with: docker-compose -f ${COMPOSE_FILE} logs"
        exit 1
    fi
}

copy_uploads() {
    print_info "Copying upload files..."
    docker cp system/uploads/. phpnuxbill-app:/var/www/html/system/uploads/
    docker exec phpnuxbill-app chown -R www-data:www-data /var/www/html/system/uploads/
    print_success "Upload files copied"
}

run_migrations() {
    read -p "Do you want to run migration scripts? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Running migrations..."
        
        # Router password migration
        docker exec phpnuxbill-app php migrate_router_passwords.php
        print_success "Router passwords migrated"
        
        # Widget migration
        docker exec phpnuxbill-app php migrate_widgets.php
        print_success "Widgets migrated"
    else
        print_warning "Skipping migrations"
    fi
}

show_status() {
    echo ""
    print_info "Deployment Status:"
    docker-compose -f ${COMPOSE_FILE} ps
    
    echo ""
    print_info "Application URL: $(grep APP_URL .env | cut -d '=' -f2)"
    print_info "phpMyAdmin: http://localhost:$(grep PHPMYADMIN_PORT .env | cut -d '=' -f2)"
}

# Main deployment flow
main() {
    echo "========================================="
    echo "PHPNuxBill Production Deployment"
    echo "Version: ${VERSION}"
    echo "========================================="
    echo ""
    
    check_requirements
    
    read -p "Do you want to build a new Docker image? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        build_image
        push_image
    fi
    
    backup_database
    deploy_services
    wait_for_services
    copy_uploads
    run_migrations
    show_status
    
    echo ""
    print_success "Deployment completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Navigate to your application URL"
    echo "  2. Complete installation if first deployment"
    echo "  3. Verify all features are working"
    echo "  4. Monitor logs: docker-compose -f ${COMPOSE_FILE} logs -f"
    echo ""
}

# Run main function
main
