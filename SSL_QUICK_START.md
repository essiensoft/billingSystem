# SSL Setup - Quick Start Guide

## 🚀 Quick Steps (Copy & Paste)

### 1. SSH to Your Hostinger VPS

```bash
ssh your-username@your-vps-ip
```

### 2. Install Certbot

```bash
sudo apt update && sudo apt install certbot -y
```

### 3. Stop PHPNuxBill Container

```bash
docker stop phpnuxbill-app
```

### 4. Get SSL Certificate

```bash
sudo certbot certonly --standalone \
  -d mulanet.cloud \
  -d www.mulanet.cloud \
  --email your-email@example.com \
  --agree-tos \
  --non-interactive
```

**Replace `your-email@example.com` with your actual email!**

### 5. Create SSL Directory & Copy Certificates

```bash
sudo mkdir -p /opt/mulanet/billingSystem/ssl
sudo cp /etc/letsencrypt/live/mulanet.cloud/fullchain.pem /opt/mulanet/billingSystem/ssl/
sudo cp /etc/letsencrypt/live/mulanet.cloud/privkey.pem /opt/mulanet/billingSystem/ssl/
sudo chmod 644 /opt/mulanet/billingSystem/ssl/*.pem
```

### 6. Verify Certificates Exist

```bash
ls -la /opt/mulanet/billingSystem/ssl/
```

**Expected output:**
```
-rw-r--r-- 1 root root 3586 Dec 16 14:00 fullchain.pem
-rw-r--r-- 1 root root 1704 Dec 16 14:00 privkey.pem
```

---

## 🔄 Update Portainer Stack

### 7. In Portainer Web UI:

1. Go to **Stacks** → Your PHPNuxBill stack
2. Click **Editor**
3. Update the `docker-compose.yml` with the new version from your local machine
4. **OR** just add these lines to the `phpnuxbill` service:

```yaml
environment:
  - APP_URL=https://mulanet.cloud  # Change from http to https
  - SERVER_NAME=mulanet.cloud      # Add this line

volumes:
  # Add these two lines after the existing volumes
  - /opt/mulanet/billingSystem/ssl/fullchain.pem:/etc/ssl/certs/mulanet.cloud.crt:ro
  - /opt/mulanet/billingSystem/ssl/privkey.pem:/etc/ssl/private/mulanet.cloud.key:ro
```

5. Click **Update the stack**

---

## 🏗️ Rebuild Docker Image (Optional but Recommended)

### 8. On Your Local Machine:

```bash
cd /Applications/MAMP/htdocs/phpnuxbill
./push-to-dockerhub.sh
```

### 9. In Portainer:

1. Go to **Containers** → `phpnuxbill-app`
2. Click **Recreate**
3. ✅ Check **"Pull latest image"**
4. Click **Recreate container**

---

## ✅ Verify SSL is Working

### 10. Test HTTPS Access

Open browser and visit:
- `https://mulanet.cloud` ← Should work with green padlock!
- `http://mulanet.cloud` ← Should redirect to HTTPS

### 11. Check Certificate

Click the padlock icon in browser → View certificate
- **Issued by:** Let's Encrypt
- **Valid for:** mulanet.cloud, www.mulanet.cloud
- **Expires:** ~90 days from now

---

## 🔄 Set Up Auto-Renewal

### 12. Copy Renewal Script to VPS

On your VPS:

```bash
# Create the renewal script
sudo nano /opt/phpnuxbill/renew-ssl.sh
```

Paste the content from `renew-ssl.sh` file, then:

```bash
# Make it executable
sudo chmod +x /opt/phpnuxbill/renew-ssl.sh

# Test it
sudo /opt/phpnuxbill/renew-ssl.sh
```

### 13. Add to Crontab (Monthly Renewal)

```bash
sudo crontab -e
```

Add this line:

```
0 3 1 * * /opt/phpnuxbill/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1
```

Save and exit.

---

## 🎉 Done!

Your site should now be accessible at:
- ✅ `https://mulanet.cloud` (secure)
- ✅ `http://mulanet.cloud` (redirects to HTTPS)

---

## 🆘 Troubleshooting

### Certificate Not Found Error

```bash
# Check if certificates exist
ls -la /opt/phpnuxbill/ssl/

# If missing, copy again
sudo cp /etc/letsencrypt/live/mulanet.cloud/*.pem /opt/phpnuxbill/ssl/
sudo chmod 644 /opt/phpnuxbill/ssl/*.pem
```

### Container Won't Start

```bash
# Check container logs
docker logs phpnuxbill-app

# Check if certificates are mounted
docker exec phpnuxbill-app ls -la /etc/ssl/certs/mulanet.cloud.crt
docker exec phpnuxbill-app ls -la /etc/ssl/private/mulanet.cloud.key
```

### SSL Not Working

```bash
# Check Apache SSL is enabled
docker exec phpnuxbill-app apache2ctl -M | grep ssl

# Expected output: ssl_module (shared)
```

### Rollback to HTTP

If you need to revert:

1. In Portainer, remove the SSL volume mounts
2. Change `APP_URL` back to `http://mulanet.cloud`
3. Update stack
4. Container will work on HTTP only

---

## 📚 Full Documentation

For detailed information, see:
- `SSL_SETUP_GUIDE.md` - Complete guide
- `implementation_plan.md` - Implementation details
- `apache-ssl.conf` - Apache SSL configuration

---

**Estimated Time:** 15-20 minutes
**Difficulty:** Intermediate
**Downtime:** 1-2 minutes during certificate acquisition
