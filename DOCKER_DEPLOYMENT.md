# Docker Deployment Guide for PHPNuxBill

## Quick Start

### 1. Build and Run with Docker Compose
```bash
cd /Applications/MAMP/htdocs/phpnuxbill

# Build and start all services
docker-compose -f docker-compose.production.yml up -d

# View logs
docker-compose -f docker-compose.production.yml logs -f
```

### 2. Build Docker Image Only
```bash
# Build the image
docker build -t phpnuxbill:latest .

# Tag for Docker Hub
docker tag phpnuxbill:latest yourusername/phpnuxbill:latest
docker tag phpnuxbill:latest yourusername/phpnuxbill:1.0-secure

# Push to Docker Hub
docker push yourusername/phpnuxbill:latest
docker push yourusername/phpnuxbill:1.0-secure
```

---

## Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
# Database Configuration
DB_HOST=mysql
DB_PORT=3306
DB_NAME=phpnuxbill
DB_USER=phpnuxbill_user
DB_PASS=your_secure_password_here

# MySQL Root Password
MYSQL_ROOT_PASSWORD=your_root_password_here

# Application Configuration
APP_URL=http://your-domain.com
TZ=UTC

# Ports
APP_PORT=8080
APP_SSL_PORT=8443
MYSQL_PORT=3306
PHPMYADMIN_PORT=8081
```

### Update docker-compose.production.yml

Replace hardcoded passwords with environment variables:

```yaml
environment:
  - DB_PASS=${DB_PASS}
  - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
```

---

## Security Considerations

### 1. Change Default Passwords
```bash
# Generate secure passwords
openssl rand -base64 32

# Update in .env file
DB_PASS=<generated_password>
MYSQL_ROOT_PASSWORD=<generated_password>
```

### 2. SSL/TLS Configuration
For production, use SSL certificates:

```yaml
volumes:
  - ./docker/ssl/cert.pem:/etc/ssl/certs/cert.pem:ro
  - ./docker/ssl/key.pem:/etc/ssl/private/key.pem:ro
```

### 3. Firewall Rules
```bash
# Allow only necessary ports
ufw allow 80/tcp
ufw allow 443/tcp
ufw deny 3306/tcp  # Block external MySQL access
```

---

## Docker Hub Deployment

### 1. Login to Docker Hub
```bash
docker login
# Enter your Docker Hub credentials
```

### 2. Build Multi-Platform Image
```bash
# Enable buildx
docker buildx create --use

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t yourusername/phpnuxbill:latest \
  -t yourusername/phpnuxbill:1.0-secure \
  --push .
```

### 3. Pull and Run from Docker Hub
```bash
# On any server
docker pull yourusername/phpnuxbill:latest

# Run with docker-compose
docker-compose -f docker-compose.production.yml up -d
```

---

## Production Deployment

### 1. Server Setup
```bash
# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Deploy Application
```bash
# Clone repository or copy files
git clone https://github.com/yourusername/phpnuxbill.git
cd phpnuxbill

# Configure environment
cp .env.example .env
nano .env  # Edit configuration

# Run migration scripts
docker-compose -f docker-compose.production.yml run --rm phpnuxbill php migrate_router_passwords.php
docker-compose -f docker-compose.production.yml run --rm phpnuxbill php migrate_widgets.php

# Start services
docker-compose -f docker-compose.production.yml up -d
```

### 3. Verify Deployment
```bash
# Check container status
docker-compose -f docker-compose.production.yml ps

# Check logs
docker-compose -f docker-compose.production.yml logs phpnuxbill

# Test application
curl http://localhost:8080
```

---

## Maintenance

### Backup Database
```bash
# Backup
docker exec phpnuxbill-mysql mysqldump -u root -p phpnuxbill > backup_$(date +%Y%m%d).sql

# Restore
docker exec -i phpnuxbill-mysql mysql -u root -p phpnuxbill < backup_20231212.sql
```

### Update Application
```bash
# Pull latest image
docker pull yourusername/phpnuxbill:latest

# Restart services
docker-compose -f docker-compose.production.yml down
docker-compose -f docker-compose.production.yml up -d
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.production.yml logs -f

# Specific service
docker-compose -f docker-compose.production.yml logs -f phpnuxbill
```

---

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker logs phpnuxbill-app

# Check permissions
docker exec phpnuxbill-app ls -la /var/www/html
```

### Database Connection Issues
```bash
# Test MySQL connection
docker exec phpnuxbill-mysql mysql -u root -p -e "SHOW DATABASES;"

# Check network
docker network inspect phpnuxbill-network
```

### Permission Issues
```bash
# Fix permissions
docker exec phpnuxbill-app chown -R www-data:www-data /var/www/html
docker exec phpnuxbill-app chmod -R 755 /var/www/html
```

---

## Docker Image Details

### Image Specifications
- **Base Image**: php:8.2-apache
- **PHP Version**: 8.2
- **Web Server**: Apache 2.4
- **Database**: MySQL 8.0
- **Size**: ~500MB (compressed)

### Included Security Features
- ✅ All 7 critical vulnerabilities fixed
- ✅ Secure PHP configuration
- ✅ Security headers enabled
- ✅ Session security configured
- ✅ File permissions hardened
- ✅ Sensitive files protected
- ✅ Health checks enabled

### Exposed Ports
- **80**: HTTP
- **443**: HTTPS
- **3306**: MySQL (internal only)
- **8081**: phpMyAdmin (optional)

---

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags: |
            yourusername/phpnuxbill:latest
            yourusername/phpnuxbill:${{ github.sha }}
```

---

## Support

For issues or questions:
1. Check Docker logs
2. Review configuration
3. Consult main documentation
4. Contact support team

---

**Last Updated**: 2025-12-12  
**Docker Version**: 1.0-secure  
**Compatible with**: PHPNuxBill Security Fixes v1.0
