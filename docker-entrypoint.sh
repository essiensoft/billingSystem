#!/bin/bash
set -e

# Wait for MySQL to be ready with timeout
echo "Waiting for MySQL to be ready..."
echo "Database Host: ${DB_HOST}"
echo "Database Port: ${DB_PORT}"
echo "Database Name: ${DB_NAME}"
echo "Database User: ${DB_USER}"

MAX_RETRIES=30
RETRY_COUNT=0

until php -r "new PDO('mysql:host=${DB_HOST};port=${DB_PORT}', '${DB_USER}', '${DB_PASS}');" 2>/dev/null; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "❌ ERROR: MySQL did not become available after ${MAX_RETRIES} attempts (60 seconds)"
        echo ""
        echo "Troubleshooting steps:"
        echo "1. Check if MySQL container is running: docker ps"
        echo "2. Check MySQL logs for errors"
        echo "3. Verify environment variables match between phpnuxbill and mysql services"
        echo "4. Ensure DB_PASS matches MYSQL_PASSWORD"
        echo "5. Ensure MYSQL_ROOT_PASSWORD is set"
        echo ""
        echo "Current configuration:"
        echo "  DB_HOST=${DB_HOST}"
        echo "  DB_PORT=${DB_PORT}"
        echo "  DB_NAME=${DB_NAME}"
        echo "  DB_USER=${DB_USER}"
        echo ""
        exit 1
    fi
    
    echo "MySQL is unavailable - sleeping (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

echo "✅ MySQL is ready!"

# Create config.php if it doesn't exist
if [ ! -f /var/www/html/config.php ]; then
    echo "Creating config.php..."
    cat > /var/www/html/config.php <<EOF
<?php
/**
 * PHPNuxBill - Docker Auto-Generated Configuration
 */

\$db_host = '${DB_HOST}';
\$db_port = '${DB_PORT}';
\$db_user = '${DB_USER}';
\$db_password = '${DB_PASS}';
\$db_name = '${DB_NAME}';

// Database connection
\$db_dsn = "mysql:host=\$db_host;port=\$db_port;dbname=\$db_name;charset=utf8mb4";

try {
    \$db = new PDO(\$db_dsn, \$db_user, \$db_password);
    \$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException \$e) {
    die("Database connection failed: " . \$e->getMessage());
}

// Application URL
\$app_url = '${APP_URL}';
define('APP_URL', '${APP_URL}');

// Timezone
date_default_timezone_set('${TZ}');
EOF

    chown www-data:www-data /var/www/html/config.php
    chmod 644 /var/www/html/config.php
    echo "config.php created successfully!"
fi

# Initialize guest purchase configuration settings (only if tables exist)
echo "Checking guest purchase configuration..."
php -r "
try {
    \$db = new PDO('mysql:host=${DB_HOST};port=${DB_PORT};dbname=${DB_NAME};charset=utf8mb4', '${DB_USER}', '${DB_PASS}');
    \$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Check if tbl_app_config table exists
    \$tables = \$db->query('SHOW TABLES LIKE \"tbl_app_config\"')->fetchAll();
    
    if (count(\$tables) > 0) {
        // Table exists, check if guest purchase settings exist
        \$stmt = \$db->prepare('SELECT COUNT(*) FROM tbl_app_config WHERE setting = ?');
        \$stmt->execute(['guest_auto_activate']);
        \$exists = \$stmt->fetchColumn();
        
        if (\$exists == 0) {
            echo \"Installing guest purchase configuration...\n\";
            
            // Insert guest purchase settings
            \$settings = [
                ['guest_auto_activate', 'yes'],
                ['guest_allowed_plan_types', 'Hotspot'],
                ['guest_transaction_expiry_hours', '6'],
                ['guest_transaction_cleanup_days', '30']
            ];
            
            \$stmt = \$db->prepare('INSERT INTO tbl_app_config (setting, value) VALUES (?, ?) ON DUPLICATE KEY UPDATE value=VALUES(value)');
            
            foreach (\$settings as \$setting) {
                \$stmt->execute(\$setting);
                echo \"  ✓ Added: {\$setting[0]} = {\$setting[1]}\n\";
            }
            
            echo \"Guest purchase configuration installed successfully!\n\";
        } else {
            echo \"Guest purchase configuration already exists.\n\";
        }
    } else {
        echo \"PHPNuxBill not installed yet. Please complete installation via web interface.\n\";
        echo \"Visit http://your-domain:8080/install to set up the database.\n\";
    }
} catch (PDOException \$e) {
    echo \"Note: Database not initialized yet. Please run PHPNuxBill installer.\n\";
}
"

# Initialize RADIUS tables if they don't exist
echo "Initializing RADIUS tables..."
if [ -f /var/www/html/scripts/init-radius-db.sh ]; then
    bash /var/www/html/scripts/init-radius-db.sh || echo "Note: RADIUS tables initialization skipped (database may not be ready yet)"
else
    echo "Warning: RADIUS initialization script not found"
fi

# Fix MySQL TIMESTAMP errors (invalid '0' values)
echo "Checking for TIMESTAMP errors..."
if [ -f /var/www/html/scripts/fix-timestamp-errors.sh ]; then
    bash /var/www/html/scripts/fix-timestamp-errors.sh || echo "Note: TIMESTAMP fix skipped (database may not be ready yet)"
else
    echo "Note: TIMESTAMP fix script not found"
fi


# Copy default upload files if they don't exist (fixes Docker volume override)
echo "Checking default upload files..."

# Check if the backup directory exists
if [ -d /var/www/html_backup/system/uploads ]; then
    echo "Backup directory found at /var/www/html_backup/system/uploads"
    
    # List what's in the backup
    echo "Files in backup:"
    ls -la /var/www/html_backup/system/uploads/ | head -20
    
    # Copy all files from backup to uploads directory
    echo "Copying default upload files to volume..."
    cp -rv /var/www/html_backup/system/uploads/* /var/www/html/system/uploads/ 2>&1 || echo "Some files may already exist"
    
    # Set permissions
    chown -R www-data:www-data /var/www/html/system/uploads/
    chmod -R 755 /var/www/html/system/uploads/
    
    echo "✅ Default upload files copied successfully!"
    
    # Verify critical files
    echo "Verifying critical files:"
    for file in admin.default.png notifications.default.json logo.default.png; do
        if [ -f "/var/www/html/system/uploads/$file" ]; then
            echo "  ✓ $file exists"
        else
            echo "  ✗ $file MISSING!"
        fi
    done
else
    echo "⚠️  Backup directory not found at /var/www/html_backup/system/uploads"
    echo "Checking if files already exist in volume..."
    
    if [ -f /var/www/html/system/uploads/notifications.default.json ]; then
        echo "✓ Upload files already exist in volume"
    else
        echo "❌ ERROR: Upload files missing and no backup available!"
        echo "This may cause issues with the application."
    fi
fi

# Execute the main command
# Note: Cron jobs are handled by the external cron container in docker-compose
exec "$@"
