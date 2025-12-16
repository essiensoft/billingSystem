# PHPNuxBill - First Time Setup on Portainer

## Current Status

✅ **Fixed Issues:**
- Multi-platform Docker image (supports both AMD64 and ARM64)
- Removed problematic file bind mounts
- Container won't restart in a loop anymore
- Graceful handling of fresh database installation

## After Deployment

### 1. Access PHPNuxBill Installation

Once the containers are running, visit:
```
http://mulanet.cloud:8080/install
```
or
```
http://YOUR_VPS_IP:8080/install
```

### 2. Complete Web Installation

The PHPNuxBill web installer will:
- Create all database tables
- Set up the admin account
- Configure initial settings

**Database Connection Details** (use these during installation):
- **Database Host:** `mysql` (the service name in docker-compose)
- **Database Port:** `3306`
- **Database Name:** Value of `DB_NAME` env var (default: `phpnuxbill`)
- **Database User:** Value of `DB_USER` env var (default: `phpnuxbill_user`)
- **Database Password:** Value of `DB_PASS` env var (default: `ChangeThisPassword`)

### 3. Environment Variables to Set in Portainer

When deploying the stack, make sure to set these environment variables:

```env
# Database Configuration
DB_NAME=phpnuxbill
DB_USER=phpnuxbill_user
DB_PASS=YourSecurePassword123!
MYSQL_ROOT_PASSWORD=YourRootPassword456!

# Application Configuration
APP_URL=http://mulanet.cloud
TZ=Africa/Johannesburg
```

**Important:** Replace the passwords with strong, secure passwords!

### 4. Port Configuration

The application exposes:
- **Port 8080:** HTTP access (main application)
- **Port 8443:** HTTPS access (if SSL is configured)
- **Port 3306:** MySQL (exposed for debugging, can be removed in production)

### 5. Network Configuration

If the container has no network/IP:
1. In Portainer, check that the stack is using the correct network
2. The `phpnuxbill-network` should be created automatically
3. Both containers should be on the same network

### 6. Accessing via Domain (mulanet.cloud)

To access via your domain:

**Option A: Direct Port Access**
```
http://mulanet.cloud:8080
```

**Option B: Reverse Proxy (Recommended for Production)**

Set up Nginx or Apache as a reverse proxy on your VPS:

```nginx
server {
    listen 80;
    server_name mulanet.cloud;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Then you can access without the port:
```
http://mulanet.cloud
```

### 7. Troubleshooting

**Container keeps restarting:**
- Check logs in Portainer
- Verify MySQL is healthy (green status)
- Ensure environment variables are set correctly

**Can't access the application:**
- Verify ports 8080/8443 are open in your VPS firewall
- Check if the container has an IP: `docker inspect phpnuxbill-app`
- Ensure the container is on the correct network

**Database connection errors:**
- Wait for MySQL to be fully ready (check healthcheck status)
- Verify DB credentials match between phpnuxbill and mysql services
- Check MySQL logs for any errors

### 8. Post-Installation

After completing the web installation:

1. **Login** with your admin credentials
2. **Configure guest purchase settings** (if not auto-configured)
3. **Set up your payment gateways**
4. **Configure hotspot/router settings**
5. **Test the guest purchase flow**

### 9. Data Persistence

Your data is stored in Docker volumes:
- `mysql-data` - Database
- `phpnuxbill-ui-compiled` - Compiled UI templates
- `phpnuxbill-ui-cache` - UI cache
- `phpnuxbill-uploads` - Uploaded files

These volumes persist even if you remove the containers.

### 10. Backup

To backup your data:

```bash
# Backup database
docker exec phpnuxbill-mysql mysqldump -u root -p phpnuxbill > backup.sql

# Backup volumes
docker run --rm -v phpnuxbill-uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads-backup.tar.gz /data
```

## Need Help?

If you encounter issues:
1. Check container logs in Portainer
2. Verify all environment variables are set
3. Ensure MySQL healthcheck is passing
4. Check VPS firewall settings
5. Verify DNS is pointing to your VPS IP
