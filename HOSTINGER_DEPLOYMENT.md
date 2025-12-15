# PHPNuxBill Deployment on Hostinger VPS with Portainer

## 🎯 Overview

Hostinger VPS with pre-installed Portainer is **perfect** for deploying PHPNuxBill! You have two deployment options:

1. **Command Line** - Use `deploy.sh` (Recommended for automation)
2. **Portainer UI** - Visual deployment through web interface

---

## ✅ Why Hostinger VPS Works Great

- ✅ Docker pre-installed
- ✅ Portainer for easy management
- ✅ Full root access
- ✅ Good performance
- ✅ Affordable pricing
- ✅ `deploy.sh` fully compatible

---

## 🚀 Method 1: Command Line Deployment (Recommended)

### Step 1: Connect to Your VPS

```bash
# SSH to your Hostinger VPS
ssh root@your-vps-ip
# Or use the hostname
ssh root@your-vps-hostname.hostinger.com
```

### Step 2: Upload Your Project

**Option A: Using Git (Recommended)**
```bash
# Clone your repository
git clone https://github.com/yourusername/phpnuxbill.git
cd phpnuxbill
```

**Option B: Using SCP**
```bash
# From your local machine
scp -r /Applications/MAMP/htdocs/phpnuxbill root@your-vps-ip:/root/
```

### Step 3: Configure Environment

```bash
# Create .env file
cp .env.production.example .env

# Edit with your settings
nano .env
```

**Important settings for Hostinger**:
```bash
APP_URL=http://your-vps-ip:8080
# Or use your domain if you have one
APP_URL=https://yourdomain.com

DB_NAME=phpnuxbill_prod
DB_USER=phpnuxbill_user
DB_PASS=<generate strong password>
MYSQL_ROOT_PASSWORD=<generate strong password>
ENCRYPTION_KEY=<generate with: openssl rand -base64 32>
```

### Step 4: Run Deployment

```bash
# Make script executable (if needed)
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

**The script will**:
- ✅ Check Docker/Docker Compose
- ✅ Build or pull the image
- ✅ Deploy all services
- ✅ Set up database
- ✅ Show deployment status

### Step 5: Access Your Application

```bash
# Get your VPS IP
curl ifconfig.me

# Access PHPNuxBill
http://YOUR_VPS_IP:8080
```

---

## 🖥️ Method 2: Portainer UI Deployment

Portainer provides a visual interface for managing Docker containers.

### Step 1: Access Portainer

```
https://your-vps-ip:9443
# Or
http://your-vps-ip:9000
```

Login with your Portainer credentials.

### Step 2: Create Stack

1. Go to **Stacks** → **Add Stack**
2. Name: `phpnuxbill`
3. Build method: **Upload** or **Git Repository**

### Step 3: Upload Docker Compose

**Option A: Copy/Paste**

Copy the contents of `docker-compose.production.yml` and paste into the web editor.

**Option B: Git Repository**

- Repository URL: `https://github.com/yourusername/phpnuxbill`
- Compose path: `docker-compose.production.yml`

### Step 4: Set Environment Variables

In Portainer, add environment variables:

```
APP_URL=http://your-vps-ip:8080
DB_NAME=phpnuxbill_prod
DB_USER=phpnuxbill_user
DB_PASS=YourStrongPassword123
MYSQL_ROOT_PASSWORD=YourRootPassword456
ENCRYPTION_KEY=<your-32-char-key>
TZ=Africa/Lagos
```

### Step 5: Deploy Stack

Click **Deploy the stack**

Portainer will:
- Pull the image from Docker Hub
- Create containers
- Set up networking
- Start services

### Step 6: Monitor Deployment

In Portainer:
- **Containers** → View running containers
- **Logs** → Check application logs
- **Console** → Access container terminal

---

## 🔧 Hostinger-Specific Configuration

### 1. Firewall Configuration

Hostinger VPS usually has a firewall. Open required ports:

```bash
# Using UFW (Ubuntu Firewall)
sudo ufw allow 8080/tcp   # PHPNuxBill HTTP
sudo ufw allow 8443/tcp   # PHPNuxBill HTTPS
sudo ufw allow 22/tcp     # SSH (keep this!)
sudo ufw enable
```

**Or via Hostinger Control Panel**:
- Go to VPS → Firewall
- Add rules for ports 8080, 8443

### 2. Domain Configuration (Optional)

If you have a domain:

**A. Point Domain to VPS**
- In your domain registrar, create A record
- Point to your VPS IP

**B. Update .env**
```bash
APP_URL=https://yourdomain.com
```

**C. Set up Reverse Proxy (Nginx)**

```bash
# Install Nginx
sudo apt-get update
sudo apt-get install nginx

# Create config
sudo nano /etc/nginx/sites-available/phpnuxbill
```

Add:
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/phpnuxbill /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 3. SSL/TLS with Let's Encrypt

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal is set up automatically
```

---

## 📊 Monitoring with Portainer

### View Container Status
1. Go to **Containers**
2. See all running containers
3. Check resource usage (CPU, RAM)

### View Logs
1. Click on container name
2. Go to **Logs** tab
3. Real-time log streaming

### Access Container Terminal
1. Click on container
2. Go to **Console** tab
3. Connect to `/bin/bash`

### Restart Containers
1. Select container
2. Click **Restart** or **Stop/Start**

---

## 🔄 Updates & Maintenance

### Update via Command Line

```bash
# SSH to VPS
ssh root@your-vps-ip

# Navigate to project
cd phpnuxbill

# Pull latest changes
git pull

# Rebuild and redeploy
./deploy.sh
```

### Update via Portainer

1. Go to **Stacks** → **phpnuxbill**
2. Click **Editor**
3. Update image version if needed
4. Click **Update the stack**

---

## 💾 Backups on Hostinger

### Automated Backup Script

```bash
# Create backup script
cat > /root/backup-phpnuxbill.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/root/backups/phpnuxbill"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup database
docker exec phpnuxbill-mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD phpnuxbill_prod > $BACKUP_DIR/db_$DATE.sql

# Backup uploads
docker cp phpnuxbill-app:/var/www/html/system/uploads $BACKUP_DIR/uploads_$DATE

# Compress
tar -czf $BACKUP_DIR/backup_$DATE.tar.gz $BACKUP_DIR/db_$DATE.sql $BACKUP_DIR/uploads_$DATE
rm -rf $BACKUP_DIR/db_$DATE.sql $BACKUP_DIR/uploads_$DATE

# Keep last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
EOF

chmod +x /root/backup-phpnuxbill.sh

# Schedule daily backups
crontab -e
# Add: 0 2 * * * /root/backup-phpnuxbill.sh
```

---

## 🚨 Troubleshooting

### Issue: Can't access on port 8080

**Solution**:
```bash
# Check if firewall is blocking
sudo ufw status

# Allow port
sudo ufw allow 8080/tcp

# Check if container is running
docker ps | grep phpnuxbill
```

### Issue: Portainer not accessible

**Solution**:
```bash
# Check Portainer status
docker ps | grep portainer

# Restart Portainer
docker restart portainer
```

### Issue: Out of disk space

**Solution**:
```bash
# Check disk usage
df -h

# Clean Docker
docker system prune -a

# Remove old images
docker image prune -a
```

---

## ✅ Hostinger VPS Deployment Checklist

### Pre-Deployment
- [ ] VPS provisioned with Docker + Portainer
- [ ] SSH access configured
- [ ] Firewall rules set (ports 8080, 8443)
- [ ] Domain pointed to VPS (optional)
- [ ] SSL certificate obtained (optional)

### Deployment
- [ ] Project uploaded to VPS
- [ ] `.env` file configured
- [ ] `deploy.sh` executed successfully
- [ ] All containers running
- [ ] Application accessible

### Post-Deployment
- [ ] Installation wizard completed
- [ ] Admin account created
- [ ] Backups configured
- [ ] Monitoring set up in Portainer
- [ ] SSL/TLS configured (if using domain)

---

## 🎯 Recommended Setup for Hostinger

**Best Practice**:
1. Use `deploy.sh` for initial deployment
2. Use Portainer for monitoring and management
3. Set up automated backups
4. Configure domain + SSL for production
5. Monitor resources in Portainer

**Resource Allocation**:
- **Minimum VPS**: 2GB RAM, 2 CPU cores, 40GB storage
- **Recommended**: 4GB RAM, 2 CPU cores, 80GB storage
- **Production**: 8GB RAM, 4 CPU cores, 160GB storage

---

## 📞 Quick Commands Reference

```bash
# SSH to VPS
ssh root@your-vps-ip

# Check containers
docker ps

# View logs
docker-compose -f docker-compose.production.yml logs -f

# Restart services
docker-compose -f docker-compose.production.yml restart

# Stop all
docker-compose -f docker-compose.production.yml down

# Start all
docker-compose -f docker-compose.production.yml up -d

# Access Portainer
https://your-vps-ip:9443
```

---

## 🎉 Summary

**Hostinger VPS + Portainer = Perfect Match!**

✅ `deploy.sh` works perfectly  
✅ Portainer provides easy management  
✅ Full Docker support  
✅ Great performance  
✅ Easy monitoring and updates  

Your Hostinger VPS is **ideal** for PHPNuxBill deployment!
