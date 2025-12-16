# FreeRADIUS Quick Start Guide

This guide shows you how to deploy PHPNuxBill with FreeRADIUS using your existing `.env` file.

## Prerequisites

- Docker and Docker Compose installed
- `.env` file configured with database credentials

## Automatic Setup (Recommended)

Everything is now automated! The system will:
1. ✅ Read database credentials from `.env`
2. ✅ Auto-create RADIUS tables on first run
3. ✅ Configure FreeRADIUS with your DB credentials
4. ✅ Enable SQL and SQLCounter modules

### Step 1: Verify Your .env File

Check that your `.env` has these variables:

```bash
cat .env
```

Required variables:
```bash
DB_NAME=phpnuxbill
DB_USER=phpnuxbill_user
DB_PASS=your_secure_password
MYSQL_ROOT_PASSWORD=your_root_password
```

### Step 2: Deploy the Stack

```bash
# Build the image (includes freeradius-utils)
docker build -t scorpionkingca/phpnuxbill:latest .

# Start all services
docker-compose -f docker-compose.production.yml up -d
```

### Step 3: Verify RADIUS Tables

Check that RADIUS tables were created:

```bash
docker exec phpnuxbill-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} -e \
  "USE ${DB_NAME}; SHOW TABLES LIKE 'rad%';"
```

Expected output:
```
radacct
radcheck
radgroupcheck
radgroupreply
radpostauth
radreply
radusergroup
nas
```

### Step 4: Test FreeRADIUS

```bash
# Check FreeRADIUS logs
docker logs phpnuxbill-freeradius 2>&1 | tail -20

# Test authentication (after creating a user in PHPNuxBill)
docker exec phpnuxbill-freeradius \
  radtest testuser testpass 127.0.0.1 0 testing123
```

## What Happens Automatically

### On Container Startup

**PHPNuxBill Container:**
1. Waits for MySQL to be ready
2. Creates `config.php` with DB credentials
3. **Runs `scripts/init-radius-db.sh`** - Creates RADIUS tables if missing
4. Initializes guest purchase settings
5. Copies default upload files

**FreeRADIUS Container:**
1. **Runs `configure-freeradius.sh`** - Substitutes DB credentials in SQL config
2. Enables SQL and SQLCounter modules
3. Starts FreeRADIUS in debug mode

## Configuration Files

All configuration is automatic, but you can customize:

| File | Purpose | Auto-Configured |
|------|---------|-----------------|
| `freeradius/mods-available/sql` | DB connection | ✅ Yes (from .env) |
| `freeradius/clients.conf` | NAS clients | ⚠️ Manual (add your routers) |
| `freeradius/sites-available/default` | Auth/Acct rules | ✅ Yes |
| `scripts/init-radius-db.sh` | DB initialization | ✅ Auto-runs |

## Adding NAS Clients (MikroTik Routers)

### Option 1: Via PHPNuxBill Admin (Recommended)
1. Login to PHPNuxBill admin panel
2. Go to **Network → Routers**
3. Add router with type **Radius**
4. Entries are stored in the `nas` table

### Option 2: Edit clients.conf
Edit `freeradius/clients.conf`:

```text
client mikrotik-main {
    ipaddr = 192.168.1.1
    secret = YourRadiusSecret
    shortname = mikrotik-main
    nas_type = mikrotik
}
```

Then restart FreeRADIUS:
```bash
docker-compose -f docker-compose.production.yml restart freeradius
```

## Firewall Configuration

Open UDP ports on your server:

```bash
# UFW (Ubuntu)
sudo ufw allow 1812/udp
sudo ufw allow 1813/udp
sudo ufw allow 3799/udp

# firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-port=1812/udp
sudo firewall-cmd --permanent --add-port=1813/udp
sudo firewall-cmd --permanent --add-port=3799/udp
sudo firewall-cmd --reload
```

## Troubleshooting

### RADIUS tables not created
```bash
# Manually run the initialization script
docker exec phpnuxbill-app bash /var/www/html/scripts/init-radius-db.sh
```

### FreeRADIUS can't connect to MySQL
```bash
# Check environment variables
docker exec phpnuxbill-freeradius env | grep DB_

# Check SQL config
docker exec phpnuxbill-freeradius cat /etc/freeradius/3.0/mods-available/sql | grep -A3 "Connection info"
```

### View FreeRADIUS debug logs
```bash
docker logs -f phpnuxbill-freeradius
```

## Production Mode

To reduce logging, edit `docker-compose.production.yml`:

```yaml
command: ["freeradius"]  # Remove -X flag
```

Then restart:
```bash
docker-compose -f docker-compose.production.yml restart freeradius
```

## Summary

✅ **No manual configuration needed!**
- Database credentials: Auto-configured from `.env`
- RADIUS tables: Auto-created on first run
- FreeRADIUS SQL: Auto-configured with your DB settings

Just deploy and go! 🚀
