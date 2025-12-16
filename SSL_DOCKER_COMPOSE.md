# SSL Setup with Docker Compose - Complete Guide

## 🎯 Overview

Your `docker-compose.production.yml` now includes a **Certbot container** that automatically renews SSL certificates. However, you still need to run `setup-ssl.sh` **once** to obtain the initial certificates.

## 📋 How It Works

### **Initial Setup (One-Time):**
1. Run `setup-ssl.sh` on your VPS
2. Script obtains SSL certificate from Let's Encrypt
3. Certificates saved to `/opt/mulanet/billingSystem/ssl/`
4. Deploy docker-compose stack

### **Automatic Renewal (Forever):**
1. Certbot container runs continuously
2. Checks for renewal every 12 hours
3. Renews certificates when needed (30 days before expiry)
4. Copies renewed certificates to SSL directory
5. PHPNuxBill automatically uses new certificates

## 🚀 Step-by-Step Setup

### **Step 1: Run Initial SSL Setup**

```bash
# Copy setup script to VPS
scp setup-ssl.sh root@your-vps:/root/

# SSH to VPS
ssh root@your-vps

# Run setup script
bash /root/setup-ssl.sh
```

This will:
- Install Certbot
- Obtain SSL certificate
- Copy to `/opt/mulanet/billingSystem/ssl/`
- Set up initial configuration

### **Step 2: Deploy Docker Compose Stack**

In Portainer:
1. Go to **Stacks** → **Add stack**
2. Name: `phpnuxbill`
3. Paste your `docker-compose.production.yml`
4. Add environment variables:
   ```
   DB_NAME=phpnuxbill
   DB_USER=phpnuxbill_user
   DB_PASS=@Essiensoft@30!
   MYSQL_PASSWORD=@Essiensoft@30!
   MYSQL_ROOT_PASSWORD=@Essiensoft@30!
   APP_URL=https://mulanet.cloud
   TZ=Africa/Johannesburg
   ```
5. Click **Deploy the stack**

### **Step 3: Verify SSL is Working**

```bash
# Check HTTPS
curl -I https://mulanet.cloud

# Check Certbot container
docker logs phpnuxbill-certbot

# Check certificates
ls -la /opt/mulanet/billingSystem/ssl/
```

## 🔄 What the Certbot Container Does

The Certbot container:
- **Runs continuously** in the background
- **Checks for renewal** every 12 hours
- **Renews certificates** automatically when they're 30 days from expiry
- **Copies certificates** to `/opt/mulanet/billingSystem/ssl/`
- **Sets permissions** correctly (644)
- **No manual intervention** required

## 📊 Container Architecture

```
┌─────────────────────────────────────────┐
│  phpnuxbill-app (Apache + PHP)          │
│  - Serves HTTPS on port 443             │
│  - Reads certs from /etc/ssl/certs/     │
│  - Mounts: /opt/.../ssl/*.pem           │
└─────────────────────────────────────────┘
                    ↑
                    │ reads certificates
                    │
┌─────────────────────────────────────────┐
│  /opt/mulanet/billingSystem/ssl/        │
│  - fullchain.pem                        │
│  - privkey.pem                          │
└─────────────────────────────────────────┘
                    ↑
                    │ writes certificates
                    │
┌─────────────────────────────────────────┐
│  phpnuxbill-certbot                     │
│  - Renews every 12 hours                │
│  - Copies to SSL directory              │
│  - Mounts: /etc/letsencrypt/            │
└─────────────────────────────────────────┘
```

## ⚙️ Configuration

### **Certbot Container Settings:**

- **Image:** `certbot/certbot:latest`
- **Restart:** `unless-stopped`
- **Check interval:** Every 12 hours
- **Renewal trigger:** 30 days before expiry
- **Volumes:**
  - `/etc/letsencrypt` - Certificate storage
  - `/var/lib/letsencrypt` - Certbot data
  - `/opt/mulanet/billingSystem/ssl` - Your SSL directory

### **PHPNuxBill Container Settings:**

- **SSL Certificates:**
  - Fullchain: `/etc/ssl/certs/mulanet.cloud.crt`
  - Private Key: `/etc/ssl/private/mulanet.cloud.key`
- **Mounted from:** `/opt/mulanet/billingSystem/ssl/`
- **Read-only:** Yes (`:ro` flag)

## 🔍 Monitoring

### **Check Certbot Logs:**
```bash
docker logs phpnuxbill-certbot
```

### **Check Certificate Expiry:**
```bash
docker exec phpnuxbill-certbot certbot certificates
```

### **Manual Renewal Test:**
```bash
docker exec phpnuxbill-certbot certbot renew --dry-run
```

### **Check SSL Directory:**
```bash
ls -la /opt/mulanet/billingSystem/ssl/
```

## 🆘 Troubleshooting

### **Certbot container not running:**
```bash
# Check container status
docker ps -a | grep certbot

# View logs
docker logs phpnuxbill-certbot

# Restart container
docker restart phpnuxbill-certbot
```

### **Certificates not renewing:**
```bash
# Check Certbot logs
docker logs phpnuxbill-certbot --tail 100

# Manual renewal
docker exec phpnuxbill-certbot certbot renew --force-renewal

# Copy certificates manually
docker exec phpnuxbill-certbot sh -c "cp /etc/letsencrypt/live/mulanet.cloud/*.pem /opt/mulanet/billingSystem/ssl/ && chmod 644 /opt/mulanet/billingSystem/ssl/*.pem"
```

### **HTTPS not working after renewal:**
```bash
# Restart PHPNuxBill container to reload certificates
docker restart phpnuxbill-app

# Check if certificates are mounted
docker exec phpnuxbill-app ls -la /etc/ssl/certs/mulanet.cloud.crt
docker exec phpnuxbill-app ls -la /etc/ssl/private/mulanet.cloud.key
```

## ✅ Benefits of This Approach

1. **Automatic Renewal** - No manual intervention needed
2. **Container-Based** - Managed via Docker Compose
3. **Persistent** - Certificates survive container restarts
4. **Monitored** - Easy to check logs and status
5. **Reliable** - Runs every 12 hours, catches any issues

## 📅 Maintenance Schedule

- **Automatic checks:** Every 12 hours
- **Certificate renewal:** Automatic (30 days before expiry)
- **Manual checks:** Optional, once per month
- **Your involvement:** None required!

## 🎉 Summary

**One-Time Setup:**
1. Run `setup-ssl.sh` on VPS (5 minutes)
2. Deploy docker-compose stack (2 minutes)
3. Verify HTTPS works (1 minute)

**Ongoing Maintenance:**
- **None!** Certbot handles everything automatically

**Total Time Investment:**
- Initial: 10 minutes
- Ongoing: 0 minutes

Your SSL certificates will renew automatically forever! 🚀
