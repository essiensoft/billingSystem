# SSL/TLS Setup for PHPNuxBill

## Overview

This guide will help you set up SSL/TLS certificates for `mulanet.cloud` using Let's Encrypt and configure Apache inside the Docker container to serve HTTPS traffic.

## Prerequisites

- ✅ PHPNuxBill running on HTTP (port 80)
- ✅ Domain `mulanet.cloud` pointing to your VPS IP
- ✅ Ports 80 and 443 open in firewall
- ✅ SSH access to your Hostinger VPS

---

## Step 1: Install Certbot on VPS

SSH into your Hostinger VPS and install Certbot:

```bash
# Update package list
sudo apt update

# Install Certbot
sudo apt install certbot -y
```

---

## Step 2: Stop PHPNuxBill Container Temporarily

Certbot needs port 80 to verify domain ownership:

```bash
# In Portainer: Stop the phpnuxbill-app container
# OR via SSH:
docker stop phpnuxbill-app
```

---

## Step 3: Obtain SSL Certificate

Run Certbot in standalone mode:

```bash
sudo certbot certonly --standalone -d mulanet.cloud -d www.mulanet.cloud
```

**Follow the prompts:**
- Enter your email address
- Agree to Terms of Service
- Choose whether to share email with EFF

**Certificates will be saved to:**
```
/etc/letsencrypt/live/mulanet.cloud/fullchain.pem
/etc/letsencrypt/live/mulanet.cloud/privkey.pem
```

---

## Step 4: Copy Certificates to Project Directory

Create a directory for SSL certificates:

```bash
# On your VPS
sudo mkdir -p /opt/phpnuxbill/ssl
sudo cp /etc/letsencrypt/live/mulanet.cloud/fullchain.pem /opt/phpnuxbill/ssl/
sudo cp /etc/letsencrypt/live/mulanet.cloud/privkey.pem /opt/phpnuxbill/ssl/
sudo chmod 644 /opt/phpnuxbill/ssl/*.pem
```

---

## Step 5: Update docker-compose.production.yml

Add SSL certificate volume mounts:

```yaml
services:
  phpnuxbill:
    image: scorpionkingca/phpnuxbill:latest
    container_name: phpnuxbill-app
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    environment:
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_NAME=${DB_NAME:-phpnuxbill}
      - DB_USER=${DB_USER:-phpnuxbill_user}
      - DB_PASS=${DB_PASS:-ChangeThisPassword}
      - APP_URL=${APP_URL:-https://mulanet.cloud}  # Change to HTTPS
      - TZ=${TZ:-UTC}
      - SERVER_NAME=mulanet.cloud  # Add this
    volumes:
      - phpnuxbill-ui-compiled:/var/www/html/ui/compiled
      - phpnuxbill-ui-cache:/var/www/html/ui/cache
      - phpnuxbill-uploads:/var/www/html/system/uploads
      # Add SSL certificates
      - /opt/phpnuxbill/ssl/fullchain.pem:/etc/ssl/certs/mulanet.cloud.crt:ro
      - /opt/phpnuxbill/ssl/privkey.pem:/etc/ssl/private/mulanet.cloud.key:ro
    depends_on:
      - mysql
    networks:
      - phpnuxbill-network
```

---

## Step 6: Create Apache SSL Configuration

Create a file `apache-ssl.conf`:

```apache
<VirtualHost *:443>
    ServerName mulanet.cloud
    ServerAlias www.mulanet.cloud
    
    DocumentRoot /var/www/html
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/mulanet.cloud.crt
    SSLCertificateKeyFile /etc/ssl/private/mulanet.cloud.key
    
    # Modern SSL Configuration
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off
    
    # Security Headers
    Header always set Strict-Transport-Security "max-age=63072000"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

# Redirect HTTP to HTTPS
<VirtualHost *:80>
    ServerName mulanet.cloud
    ServerAlias www.mulanet.cloud
    
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>
```

---

## Step 7: Update Dockerfile to Include SSL Config

Add to your Dockerfile (before the ENTRYPOINT):

```dockerfile
# Copy Apache SSL configuration
COPY apache-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Enable SSL site and modules
RUN a2ensite default-ssl \
    && a2enmod ssl \
    && a2enmod rewrite \
    && a2enmod headers
```

---

## Step 8: Rebuild and Deploy

### Option A: Using Portainer (Easier)

1. **Update your stack in Portainer:**
   - Paste the updated `docker-compose.production.yml`
   - Update environment variables (change APP_URL to https)
   - Deploy

2. **The container will:**
   - Mount SSL certificates from VPS
   - Enable SSL in Apache
   - Redirect HTTP to HTTPS

### Option B: Rebuild Docker Image

```bash
# On your local machine
./push-to-dockerhub.sh

# Then in Portainer
# Pull latest image and recreate container
```

---

## Step 9: Test SSL Configuration

1. **Visit:** `https://mulanet.cloud`
2. **Check certificate:** Click the padlock icon in browser
3. **Test SSL:** https://www.ssllabs.com/ssltest/analyze.html?d=mulanet.cloud

---

## Step 10: Set Up Auto-Renewal

Let's Encrypt certificates expire every 90 days. Set up auto-renewal:

```bash
# On your VPS, create a renewal script
sudo nano /opt/phpnuxbill/renew-ssl.sh
```

Add this content:

```bash
#!/bin/bash

# Stop container to free port 80
docker stop phpnuxbill-app

# Renew certificate
certbot renew --quiet

# Copy new certificates
cp /etc/letsencrypt/live/mulanet.cloud/fullchain.pem /opt/phpnuxbill/ssl/
cp /etc/letsencrypt/live/mulanet.cloud/privkey.pem /opt/phpnuxbill/ssl/
chmod 644 /opt/phpnuxbill/ssl/*.pem

# Restart container
docker start phpnuxbill-app

echo "SSL certificates renewed successfully"
```

Make it executable:

```bash
sudo chmod +x /opt/phpnuxbill/renew-ssl.sh
```

Add to crontab (runs monthly):

```bash
sudo crontab -e
```

Add this line:

```
0 3 1 * * /opt/phpnuxbill/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1
```

---

## Troubleshooting

### Certificate Verification Failed

**Problem:** Certbot can't verify domain ownership

**Solution:**
- Ensure DNS points to your VPS IP
- Check firewall allows port 80
- Stop any service using port 80

### SSL Certificate Not Found

**Problem:** Container can't find certificates

**Solution:**
- Verify certificates exist on VPS: `ls -la /opt/phpnuxbill/ssl/`
- Check volume mounts in docker-compose.yml
- Ensure file permissions are correct (644)

### Mixed Content Warnings

**Problem:** Some resources load over HTTP

**Solution:**
- Update `APP_URL` to `https://mulanet.cloud`
- Clear browser cache
- Check for hardcoded HTTP URLs in templates

### Certificate Expired

**Problem:** Certificate shows as expired

**Solution:**
- Run renewal script manually: `sudo /opt/phpnuxbill/renew-ssl.sh`
- Check cron job is set up correctly
- Verify certbot renewal: `sudo certbot renew --dry-run`

---

## Quick Reference

### Important Files

- **Certificates:** `/etc/letsencrypt/live/mulanet.cloud/`
- **SSL Config:** `/opt/phpnuxbill/ssl/`
- **Apache Config:** `apache-ssl.conf`
- **Renewal Script:** `/opt/phpnuxbill/renew-ssl.sh`

### Useful Commands

```bash
# Check certificate expiry
sudo certbot certificates

# Test renewal
sudo certbot renew --dry-run

# View Apache SSL config
docker exec phpnuxbill-app cat /etc/apache2/sites-available/default-ssl.conf

# Check SSL is enabled
docker exec phpnuxbill-app apache2ctl -M | grep ssl

# Restart container
docker restart phpnuxbill-app
```

---

## Security Best Practices

1. ✅ **Use strong SSL protocols** (TLS 1.2+)
2. ✅ **Enable HSTS** (HTTP Strict Transport Security)
3. ✅ **Redirect HTTP to HTTPS** (force secure connections)
4. ✅ **Set security headers** (X-Frame-Options, CSP, etc.)
5. ✅ **Auto-renew certificates** (prevent expiration)
6. ✅ **Monitor certificate expiry** (set up alerts)

---

## Next Steps

After SSL is working:

1. Update all internal links to use HTTPS
2. Configure Content Security Policy (CSP)
3. Set up monitoring for certificate expiry
4. Consider using Cloudflare for additional security
5. Enable HTTP/2 for better performance

---

**Your site will be accessible at:** `https://mulanet.cloud` 🔒
