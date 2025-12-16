# SSL Setup - Complete Solution

## 🎯 **Automated SSL Setup (Recommended)**

I've created `setup-ssl.sh` - a **one-time setup script** that automates everything:

### **How to Use:**

1. **Copy the script to your VPS:**
   ```bash
   # From your local machine
   scp setup-ssl.sh your-user@your-vps-ip:/tmp/
   ```

2. **SSH to your VPS and run it:**
   ```bash
   ssh your-user@your-vps-ip
   sudo bash /tmp/setup-ssl.sh
   ```

3. **The script will:**
   - ✅ Install Certbot
   - ✅ Stop the container temporarily
   - ✅ Obtain SSL certificate from Let's Encrypt
   - ✅ Copy certificates to `/opt/mulanet/billingSystem/ssl/`
   - ✅ Restart the container
   - ✅ Set up automatic monthly renewal via cron
   - ✅ Test the SSL configuration

4. **After the script completes:**
   - Update your Portainer stack (add SSL volume mounts)
   - Rebuild Docker image (already configured for SSL)
   - Access your site via HTTPS

---

## 📋 **What Gets Automated:**

### ✅ **Fully Automated:**
- Certbot installation
- Certificate acquisition
- Certificate installation
- Auto-renewal setup (cron job)
- Container restart

### ⚠️ **One-Time Manual Steps:**
- Running the setup script on VPS (once)
- Updating Portainer stack configuration (once)
- Rebuilding Docker image (optional, once)

### 🔄 **Automatic Forever:**
- Certificate renewal (every 90 days)
- Container restart after renewal
- Certificate copy to SSL directory

---

## 🚀 **Quick Start:**

```bash
# 1. Copy script to VPS
scp setup-ssl.sh root@your-vps:/root/

# 2. Run it
ssh root@your-vps
bash /root/setup-ssl.sh

# 3. Follow the prompts
# Enter your email when asked

# 4. Done! SSL is configured and will auto-renew
```

---

## 📁 **Files Created:**

1. **`setup-ssl.sh`** - One-time SSL setup script (run on VPS)
2. **`renew-ssl.sh`** - Auto-renewal script (created by setup-ssl.sh)
3. **`apache-ssl.conf`** - Apache SSL configuration (in Docker image)
4. **`docker-compose.production.yml`** - Updated with SSL mounts

---

## 🔍 **Why Not Fully Automated in Container?**

SSL certificate acquisition **cannot** be done inside the Docker container because:

1. **Port 80 must be free** - Certbot needs exclusive access for domain verification
2. **Requires stopping Apache** - Can't verify domain while web server is running
3. **Needs root access** - Certificate files require elevated permissions
4. **One-time setup** - Certificates last 90 days, only needs to be done once

**Solution:** Run setup script **once** on VPS, then renewal is fully automatic via cron.

---

## ✅ **Verification:**

After running `setup-ssl.sh`, verify:

```bash
# Check certificates exist
ls -la /opt/mulanet/billingSystem/ssl/

# Check cron job
crontab -l | grep renew-ssl

# Test HTTPS
curl -I https://mulanet.cloud

# Check container logs
docker logs phpnuxbill-app
```

---

## 🆘 **Troubleshooting:**

### Script fails with "Port 80 already in use"
```bash
# Stop the container first
docker stop phpnuxbill-app
# Run script again
sudo bash setup-ssl.sh
```

### Certificate not found after setup
```bash
# Check Let's Encrypt directory
ls -la /etc/letsencrypt/live/mulanet.cloud/

# Manually copy if needed
sudo cp /etc/letsencrypt/live/mulanet.cloud/*.pem /opt/mulanet/billingSystem/ssl/
```

### HTTPS still not working
```bash
# Rebuild Docker image with SSL support
./push-to-dockerhub.sh

# Update Portainer stack with SSL volume mounts
# Then recreate container with "Pull latest image"
```

---

## 📅 **Maintenance:**

- **Automatic renewal:** 1st of every month at 3 AM
- **Manual renewal test:** `sudo /opt/mulanet/billingSystem/renew-ssl.sh`
- **Check expiry:** `sudo certbot certificates`
- **Renewal logs:** `/var/log/ssl-renewal.log`

---

## 🎉 **Benefits:**

- ✅ **One-time setup** - Run script once, forget about it
- ✅ **Auto-renewal** - Certificates renew automatically
- ✅ **No downtime** - Only 1-2 minutes during initial setup
- ✅ **Free SSL** - Let's Encrypt certificates at no cost
- ✅ **Production-ready** - Modern SSL/TLS configuration

---

**Total setup time:** 5-10 minutes
**Maintenance required:** None (fully automatic)
