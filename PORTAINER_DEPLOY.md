# Quick Deployment Guide for Portainer

## IMPORTANT: Copy the docker-compose.yml below into Portainer

The issue is that Portainer needs the UPDATED docker-compose.yml file. Copy the entire content below into your Portainer stack editor.

## Step-by-Step Instructions

### 1. In Portainer:
- Go to **Stacks**
- Either **Edit** your existing stack OR **Delete and Add new stack**

### 2. Paste This docker-compose.yml:

```yaml
version: '3.8'

services:
  # PHPNuxBill Application
  phpnuxbill:
    image: scorpionkingca/phpnuxbill:latest
    container_name: phpnuxbill-app
    restart: unless-stopped
    ports:
      - "8080:80"
      - "8443:443"
    environment:
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_NAME=${DB_NAME:-phpnuxbill}
      - DB_USER=${DB_USER:-phpnuxbill_user}
      - DB_PASS=${DB_PASS:-ChangeThisPassword}
      - APP_URL=${APP_URL:-http://yourdomain.com}
      - TZ=${TZ:-UTC}
    volumes:
      - phpnuxbill-ui-compiled:/var/www/html/ui/compiled
      - phpnuxbill-ui-cache:/var/www/html/ui/cache
      - phpnuxbill-uploads:/var/www/html/system/uploads
    depends_on:
      - mysql
    networks:
      - phpnuxbill-network
    healthcheck:
      test: [ "CMD", "curl", "-f", "http://localhost/" ]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # MySQL Database
  mysql:
    image: mysql:8.0
    container_name: phpnuxbill-mysql
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-ChangeThisRootPassword}
      - MYSQL_DATABASE=${DB_NAME:-phpnuxbill}
      - MYSQL_USER=${DB_USER:-phpnuxbill_user}
      - MYSQL_PASSWORD=${DB_PASS:-ChangeThisPassword}
      - TZ=${TZ:-UTC}
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - phpnuxbill-network
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -u root -p$$MYSQL_ROOT_PASSWORD || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 60s
    command: --default-authentication-plugin=mysql_native_password

volumes:
  mysql-data:
    driver: local
  phpnuxbill-ui-compiled:
    driver: local
  phpnuxbill-ui-cache:
    driver: local
  phpnuxbill-uploads:
    driver: local

networks:
  phpnuxbill-network:
    driver: bridge
```

### 3. Set Environment Variables

In Portainer, add these environment variables (click "Add environment variable"):

```
DB_NAME=phpnuxbill
DB_USER=phpnuxbill_user
DB_PASS=SecurePassword123!
MYSQL_ROOT_PASSWORD=SecureRootPassword456!
APP_URL=http://mulanet.cloud
TZ=Africa/Johannesburg
```

**⚠️ CRITICAL:** Make sure:
- `DB_PASS` and `MYSQL_PASSWORD` are THE SAME
- `MYSQL_ROOT_PASSWORD` is set
- Use STRONG passwords (not the examples above)

### 4. Deploy the Stack

Click **"Deploy the stack"** or **"Update the stack"**

### 5. Monitor the Logs

Watch both container logs:

**MySQL Container:**
- Should show: `[Server] /usr/sbin/mysqld: ready for connections`
- This can take 30-60 seconds on first run

**PHPNuxBill Container:**
- Should show: `✅ MySQL is ready!`
- If it shows errors after 30 attempts, check MySQL logs

### 6. Access the Application

Once both containers are running:
```
http://mulanet.cloud:8080/install
```

## Troubleshooting

### If MySQL won't start:

1. **Check MySQL logs** in Portainer
2. **Common issues:**
   - Insufficient memory (needs 1GB+)
   - Corrupted volume data
   - Wrong permissions

3. **Solution:** Delete the `mysql-data` volume and redeploy:
   ```bash
   docker volume rm <stack-name>_mysql-data
   ```

### If PHPNuxBill shows "MySQL unavailable" for 30+ attempts:

1. **Verify environment variables match:**
   - `DB_PASS` = `MYSQL_PASSWORD`
   - Both services use same `DB_NAME`, `DB_USER`

2. **Check MySQL container status:**
   - Should be "running" or "healthy"
   - Check logs for errors

3. **Check network:**
   - Both containers should be on `phpnuxbill-network`

### If you see "attempt 30/30" and container exits:

The new entrypoint will show you exactly what's wrong:
- Database credentials
- Connection details
- Troubleshooting steps

Check the logs for the error message and follow the instructions.

## Expected Success Logs

**MySQL:**
```
[System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections.
```

**PHPNuxBill:**
```
Waiting for MySQL to be ready...
Database Host: mysql
Database Port: 3306
Database Name: phpnuxbill
Database User: phpnuxbill_user
MySQL is unavailable - sleeping (attempt 1/30)
MySQL is unavailable - sleeping (attempt 2/30)
...
✅ MySQL is ready!
Creating config.php...
config.php created successfully!
```

## Next Steps After Successful Deployment

1. Visit `http://mulanet.cloud:8080/install`
2. Complete the web installer
3. Use the database credentials you set in environment variables
4. Database Host: `mysql` (not localhost!)

---

**Need to rebuild the Docker image?** Run `./push-to-dockerhub.sh` to push the latest changes to Docker Hub, then pull the latest image in Portainer.
