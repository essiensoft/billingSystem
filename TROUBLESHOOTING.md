# PHPNuxBill Deployment Troubleshooting

## Issue: "MySQL is unavailable - sleeping" Loop

### Root Cause
The MySQL healthcheck was failing, preventing the phpnuxbill container from starting.

### Fixes Applied

1. **Fixed MySQL Healthcheck**
   - Changed from hardcoded password to using environment variable
   - Increased `start_period` from 30s to 60s (MySQL needs time to initialize on first run)
   - Increased `retries` from 5 to 10

2. **Improved Security**
   - Commented out MySQL port 3306 exposure (containers communicate internally)
   - Only ports 8080 and 8443 are exposed to the host

### What to Do Now

#### Option 1: Redeploy in Portainer (Recommended)

1. **In Portainer:**
   - Go to your stack
   - Click "Update the stack"
   - Or delete and recreate the stack

2. **Ensure Environment Variables are Set:**
   ```env
   DB_NAME=phpnuxbill
   DB_USER=phpnuxbill_user
   DB_PASS=YourSecurePassword123!
   MYSQL_ROOT_PASSWORD=YourSecureRootPassword456!
   APP_URL=http://mulanet.cloud
   TZ=Africa/Johannesburg
   ```

3. **Wait for MySQL to Initialize:**
   - First-time MySQL initialization can take 30-60 seconds
   - Watch the logs - you should see MySQL become healthy
   - Then phpnuxbill will connect and start

#### Option 2: Check MySQL Logs

If MySQL still won't start, check its logs in Portainer:

**Common MySQL Issues:**

1. **Insufficient Memory**
   - MySQL 8.0 needs at least 1GB RAM
   - Check your VPS resources

2. **Volume Permission Issues**
   - The `mysql-data` volume might have wrong permissions
   - Solution: Delete the volume and recreate it

3. **Corrupted Data**
   - If redeploying after a crash
   - Solution: Delete the `mysql-data` volume

**To Delete MySQL Volume:**
```bash
# In Portainer or via SSH
docker volume rm <stack-name>_mysql-data
```

Then redeploy the stack.

### Verification Steps

After deployment, verify each step:

1. **Check MySQL Container Status**
   - Should show as "healthy" (green)
   - If "starting" for more than 60 seconds, check logs

2. **Check PHPNuxBill Container Status**
   - Should show as "running"
   - Logs should show: "MySQL is ready!"

3. **Access the Application**
   - Visit: `http://mulanet.cloud:8080`
   - Or: `http://YOUR_VPS_IP:8080`
   - Should see PHPNuxBill installer

### Expected Logs (Success)

**MySQL Container:**
```
[System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections.
```

**PHPNuxBill Container:**
```
Waiting for MySQL to be ready...
MySQL is ready!
Creating config.php...
config.php created successfully!
PHPNuxBill not installed yet. Please complete installation via web interface.
Visit http://your-domain:8080/install to set up the database.
Default upload files already exist or backup not available, skipping copy.
Starting cron service for guest purchase cleanup...
AH00558: apache2: Could not reliably determine the server's fully qualified domain name
```

### Still Having Issues?

1. **Check Network Connectivity**
   ```bash
   # From phpnuxbill container, try to ping mysql
   docker exec phpnuxbill-app ping mysql
   ```

2. **Verify Environment Variables**
   - In Portainer, check the stack's environment variables
   - Ensure `DB_PASS` matches `MYSQL_PASSWORD`
   - Ensure `MYSQL_ROOT_PASSWORD` is set

3. **Check Docker Network**
   ```bash
   docker network inspect <stack-name>_phpnuxbill-network
   ```
   Both containers should be listed

4. **Test MySQL Connection Manually**
   ```bash
   docker exec -it phpnuxbill-mysql mysql -u root -p
   # Enter the MYSQL_ROOT_PASSWORD
   ```

### Clean Slate Deployment

If all else fails, start fresh:

1. **Stop and remove the stack** in Portainer
2. **Delete all volumes:**
   - `mysql-data`
   - `phpnuxbill-ui-compiled`
   - `phpnuxbill-ui-cache`
   - `phpnuxbill-uploads`
3. **Recreate the stack** with correct environment variables
4. **Wait 60-90 seconds** for MySQL to initialize
5. **Check logs** to verify both containers are healthy

### Production Recommendations

Once working:

1. **Set up a reverse proxy** (Nginx/Traefik) for:
   - SSL/TLS certificates
   - Access without port numbers
   - Better security

2. **Regular backups:**
   ```bash
   # Backup database
   docker exec phpnuxbill-mysql mysqldump -u root -p phpnuxbill > backup.sql
   
   # Backup volumes
   docker run --rm -v mysql-data:/data -v $(pwd):/backup alpine tar czf /backup/mysql-backup.tar.gz /data
   ```

3. **Monitor resources:**
   - MySQL needs adequate RAM
   - Monitor disk space for volumes
   - Set up log rotation

4. **Security:**
   - Change default passwords
   - Keep MySQL port unexposed
   - Use firewall rules
   - Enable SSL/TLS
