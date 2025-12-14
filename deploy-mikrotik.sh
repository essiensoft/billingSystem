#!/bin/bash

# PHPNuxBill MikroTik Container Deployment Preparation Script
# This script prepares the Docker image for MikroTik deployment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="phpnuxbill"
VERSION="1.0.0"
OUTPUT_DIR="./mikrotik-deploy"

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
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    echo ""
    echo "========================================="
    echo "$1"
    echo "========================================="
    echo ""
}

check_requirements() {
    print_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    print_success "Docker installed"
}

build_image() {
    print_header "Building Docker Image"
    
    print_info "Building ${IMAGE_NAME}:${VERSION}..."
    docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .
    
    print_success "Docker image built successfully"
}

save_image() {
    print_header "Saving Docker Image"
    
    # Create output directory
    mkdir -p ${OUTPUT_DIR}
    
    print_info "Saving image to tar file..."
    docker save ${IMAGE_NAME}:latest -o ${OUTPUT_DIR}/${IMAGE_NAME}.tar
    
    print_success "Image saved to ${OUTPUT_DIR}/${IMAGE_NAME}.tar"
    
    # Get file size
    SIZE=$(du -h ${OUTPUT_DIR}/${IMAGE_NAME}.tar | cut -f1)
    print_info "File size: ${SIZE}"
}

compress_image() {
    print_header "Compressing Image"
    
    print_info "Compressing tar file..."
    gzip -f ${OUTPUT_DIR}/${IMAGE_NAME}.tar
    
    print_success "Image compressed to ${OUTPUT_DIR}/${IMAGE_NAME}.tar.gz"
    
    # Get compressed size
    SIZE=$(du -h ${OUTPUT_DIR}/${IMAGE_NAME}.tar.gz | cut -f1)
    print_info "Compressed size: ${SIZE}"
}

create_env_template() {
    print_header "Creating Environment Template"
    
    cat > ${OUTPUT_DIR}/phpnuxbill.env <<'EOF'
# PHPNuxBill MikroTik Container Environment Variables
# Edit these values for your deployment

# Application URL (use your router's IP or domain)
APP_URL=http://192.168.88.1:8080

# Timezone
TZ=Africa/Lagos

# Database Configuration
DB_HOST=mysql
DB_PORT=3306
DB_NAME=phpnuxbill
DB_USER=phpnuxbill_user
DB_PASS=ChangeThisPassword123!

# Encryption Key (CRITICAL - Generate with: openssl rand -base64 32)
ENCRYPTION_KEY=GENERATE_UNIQUE_32_CHAR_KEY_HERE
EOF
    
    print_success "Environment template created: ${OUTPUT_DIR}/phpnuxbill.env"
    print_warning "IMPORTANT: Edit phpnuxbill.env with your actual values before deployment!"
}

create_setup_script() {
    print_header "Creating MikroTik Setup Script"
    
    cat > ${OUTPUT_DIR}/setup-mikrotik.rsc <<'EOF'
# PHPNuxBill MikroTik Container Setup Script
# Run this on your MikroTik router via Terminal or SSH

# STEP 1: Import the Docker image
# First, upload phpnuxbill.tar.gz to your MikroTik router via FTP/SFTP/WebFig
:log info "Importing PHPNuxBill container image..."
/container/import file=phpnuxbill.tar.gz

# STEP 2: Create veth interface for container
:log info "Creating veth interface..."
/interface/veth add name=veth-phpnuxbill address=172.17.0.2/24 gateway=172.17.0.1

# STEP 3: Create bridge for container network
:log info "Setting up container network..."
/interface/bridge add name=containers comment="Container Bridge"
/ip/address add address=172.17.0.1/24 interface=containers
/interface/bridge/port add bridge=containers interface=veth-phpnuxbill

# STEP 4: Create environment file
# Upload phpnuxbill.env to your MikroTik router first
:log info "Environment file should be uploaded as phpnuxbill.env"

# STEP 5: Create and configure the container
:log info "Creating PHPNuxBill container..."
/container/add \
  remote-image=phpnuxbill:latest \
  interface=veth-phpnuxbill \
  envlist=phpnuxbill.env \
  root-dir=disk1/phpnuxbill \
  start-on-boot=yes \
  comment="PHPNuxBill Billing System"

# STEP 6: Set up port forwarding (NAT)
:log info "Configuring port forwarding..."
/ip/firewall/nat add \
  chain=dstnat \
  dst-port=8080 \
  action=dst-nat \
  to-addresses=172.17.0.2 \
  to-ports=80 \
  protocol=tcp \
  comment="PHPNuxBill HTTP"

# Optional: HTTPS port forwarding
# /ip/firewall/nat add \
#   chain=dstnat \
#   dst-port=8443 \
#   action=dst-nat \
#   to-addresses=172.17.0.2 \
#   to-ports=443 \
#   protocol=tcp \
#   comment="PHPNuxBill HTTPS"

# STEP 7: Allow container traffic in firewall
:log info "Configuring firewall rules..."
/ip/firewall/filter add \
  chain=forward \
  dst-address=172.17.0.0/24 \
  action=accept \
  comment="Allow traffic to containers"

/ip/firewall/filter add \
  chain=forward \
  src-address=172.17.0.0/24 \
  action=accept \
  comment="Allow traffic from containers"

# STEP 8: Start the container
:log info "Starting PHPNuxBill container..."
/container/start 0

:log info "PHPNuxBill setup complete!"
:log info "Access your application at: http://YOUR_ROUTER_IP:8080"
EOF
    
    print_success "MikroTik setup script created: ${OUTPUT_DIR}/setup-mikrotik.rsc"
}

create_deployment_guide() {
    print_header "Creating Deployment Instructions"
    
    cat > ${OUTPUT_DIR}/DEPLOY_TO_MIKROTIK.md <<'EOF'
# Deploy PHPNuxBill to MikroTik Router

## Prerequisites

- MikroTik router with RouterOS v7.4 or higher
- Container package installed on MikroTik
- External storage (USB/microSD) recommended for container data
- At least 512MB RAM available for container

## Files in This Directory

- `phpnuxbill.tar.gz` - Docker image (compressed)
- `phpnuxbill.env` - Environment variables template
- `setup-mikrotik.rsc` - Automated setup script
- `DEPLOY_TO_MIKROTIK.md` - This file

## Deployment Steps

### Step 1: Configure Environment Variables

Edit `phpnuxbill.env` and set your values:

```bash
# Required changes:
APP_URL=http://YOUR_ROUTER_IP:8080
DB_PASS=YourStrongPassword123!
ENCRYPTION_KEY=<generate with: openssl rand -base64 32>
```

### Step 2: Upload Files to MikroTik

**Option A: Via SFTP/SCP**
```bash
scp phpnuxbill.tar.gz admin@192.168.88.1:/
scp phpnuxbill.env admin@192.168.88.1:/
scp setup-mikrotik.rsc admin@192.168.88.1:/
```

**Option B: Via WinBox/WebFig**
1. Open WinBox and connect to your router
2. Go to Files
3. Drag and drop the files

### Step 3: Prepare External Storage (Recommended)

```bash
# SSH to your MikroTik
ssh admin@192.168.88.1

# Format USB/SD card if needed
/disk/format-drive usb1

# Create directory for container
/file/print file=disk1/phpnuxbill
```

### Step 4: Run Setup Script

**Option A: Automated (Recommended)**
```bash
# SSH to MikroTik
ssh admin@192.168.88.1

# Import and run the script
/import setup-mikrotik.rsc
```

**Option B: Manual**
Copy and paste commands from `setup-mikrotik.rsc` one by one in the terminal.

### Step 5: Verify Deployment

```bash
# Check container status
/container/print

# View container logs
/log/print where topics~"container"

# Check if container is running
/container/print detail
```

### Step 6: Access Application

1. Open browser and navigate to: `http://YOUR_ROUTER_IP:8080`
2. Complete PHPNuxBill installation wizard
3. Create admin account

## Database Setup

### Option 1: External MySQL (Recommended)

Set up MySQL on a separate server and configure `DB_HOST` in `phpnuxbill.env`

### Option 2: MySQL Container on MikroTik

You can run MySQL in another container:

```bash
# Import MySQL image
/container/import file=mysql.tar.gz

# Create MySQL container
/container/add \
  remote-image=mysql:8.0 \
  interface=veth-mysql \
  envlist=mysql.env \
  start-on-boot=yes
```

## Troubleshooting

### Container won't start

```bash
# Check logs
/log/print where topics~"container"

# Check container status
/container/print detail

# Restart container
/container/stop 0
/container/start 0
```

### Can't access application

```bash
# Verify NAT rule
/ip/firewall/nat/print

# Check firewall rules
/ip/firewall/filter/print

# Test container network
/ping 172.17.0.2
```

### Out of memory

```bash
# Check memory usage
/system/resource/print

# Reduce container resources or upgrade router RAM
```

## Updating PHPNuxBill

1. Build new image with updated code
2. Save and compress new image
3. Upload to MikroTik
4. Stop old container: `/container/stop 0`
5. Remove old container: `/container/remove 0`
6. Import new image
7. Create new container with same configuration
8. Start new container

## Backup & Restore

### Backup

```bash
# Backup container data
/file/copy disk1/phpnuxbill disk1/phpnuxbill-backup

# Export container configuration
/container/export file=phpnuxbill-config
```

### Restore

```bash
# Restore container data
/file/copy disk1/phpnuxbill-backup disk1/phpnuxbill

# Import container configuration
/import phpnuxbill-config.rsc
```

## Performance Optimization

1. Use external storage (USB 3.0 or SSD)
2. Allocate sufficient RAM (512MB minimum, 1GB recommended)
3. Use MikroTik with ARM64 or x86 CPU for better performance
4. Consider external database for better performance

## Security Recommendations

1. Change default admin password immediately
2. Use strong database passwords
3. Enable HTTPS (configure SSL certificates)
4. Restrict access via firewall rules
5. Keep RouterOS updated
6. Regular backups

## Support

For issues specific to:
- **PHPNuxBill**: Check main documentation
- **MikroTik Containers**: See MikroTik wiki
- **This deployment**: Review MIKROTIK_DEPLOYMENT.md

## Quick Reference

```bash
# Container commands
/container/print                    # List containers
/container/start 0                  # Start container
/container/stop 0                   # Stop container
/container/remove 0                 # Remove container
/log/print where topics~"container" # View logs

# Network commands
/interface/veth/print              # List veth interfaces
/ip/firewall/nat/print             # List NAT rules
/ip/firewall/filter/print          # List firewall rules
```

## Next Steps

After successful deployment:

1. Complete PHPNuxBill installation
2. Configure routers and plans
3. Test billing functionality
4. Set up automated backups
5. Monitor performance
6. Review security settings

---

**Deployment Version**: 1.0.0  
**Last Updated**: 2025-12-14
EOF
    
    print_success "Deployment guide created: ${OUTPUT_DIR}/DEPLOY_TO_MIKROTIK.md"
}

create_readme() {
    print_header "Creating README"
    
    cat > ${OUTPUT_DIR}/README.txt <<EOF
PHPNuxBill MikroTik Container Deployment Package
================================================

This package contains everything you need to deploy PHPNuxBill
on a MikroTik router using containers.

FILES:
------
1. phpnuxbill.tar.gz      - Docker image (compressed)
2. phpnuxbill.env         - Environment variables (EDIT THIS!)
3. setup-mikrotik.rsc     - Automated setup script
4. DEPLOY_TO_MIKROTIK.md  - Detailed deployment guide
5. README.txt             - This file

QUICK START:
-----------
1. Edit phpnuxbill.env with your settings
2. Upload all files to your MikroTik router
3. SSH to router: ssh admin@192.168.88.1
4. Run: /import setup-mikrotik.rsc
5. Access: http://YOUR_ROUTER_IP:8080

IMPORTANT:
----------
- Generate encryption key: openssl rand -base64 32
- Use strong database passwords
- External storage recommended
- Minimum 512MB RAM required

For detailed instructions, see DEPLOY_TO_MIKROTIK.md

Version: ${VERSION}
Generated: $(date)
EOF
    
    print_success "README created: ${OUTPUT_DIR}/README.txt"
}

show_summary() {
    print_header "Deployment Package Ready!"
    
    echo "📦 Package Location: ${OUTPUT_DIR}/"
    echo ""
    echo "📁 Files created:"
    ls -lh ${OUTPUT_DIR}/ | tail -n +2 | awk '{print "   " $9 " (" $5 ")"}'
    echo ""
    
    print_info "Next Steps:"
    echo "  1. Edit ${OUTPUT_DIR}/phpnuxbill.env with your settings"
    echo "  2. Generate encryption key: openssl rand -base64 32"
    echo "  3. Upload files to your MikroTik router"
    echo "  4. Follow instructions in ${OUTPUT_DIR}/DEPLOY_TO_MIKROTIK.md"
    echo ""
    
    print_warning "IMPORTANT:"
    echo "  - Edit phpnuxbill.env before deployment"
    echo "  - Use strong passwords"
    echo "  - External storage recommended for production"
    echo ""
    
    print_success "MikroTik deployment package created successfully!"
}

# Main execution
main() {
    print_header "PHPNuxBill MikroTik Deployment Preparation"
    
    check_requirements
    build_image
    save_image
    compress_image
    create_env_template
    create_setup_script
    create_deployment_guide
    create_readme
    show_summary
}

# Run main function
main
