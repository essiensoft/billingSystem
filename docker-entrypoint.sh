#!/bin/bash
set -e

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
until php -r "new PDO('mysql:host=${DB_HOST};port=${DB_PORT}', '${DB_USER}', '${DB_PASS}');" 2>/dev/null; do
    echo "MySQL is unavailable - sleeping"
    sleep 2
done
echo "MySQL is ready!"

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

# Initialize guest purchase configuration settings
echo "Checking guest purchase configuration..."
php -r "
try {
    \$db = new PDO('mysql:host=${DB_HOST};port=${DB_PORT};dbname=${DB_NAME};charset=utf8mb4', '${DB_USER}', '${DB_PASS}');
    \$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Check if guest purchase settings exist
    \$stmt = \$db->prepare('SELECT COUNT(*) FROM tbl_app_config WHERE setting = ?');
    \$stmt->execute(['guest_auto_activate']);
    \$exists = \$stmt->fetchColumn();
    
    if (\$exists == 0) {
        echo \"Installing guest purchase configuration...\\n\";
        
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
            echo \"  ✓ Added: {\$setting[0]} = {\$setting[1]}\\n\";
        }
        
        echo \"Guest purchase configuration installed successfully!\\n\";
    } else {
        echo \"Guest purchase configuration already exists.\\n\";
    }
} catch (PDOException \$e) {
    echo \"Warning: Could not initialize guest purchase config: \" . \$e->getMessage() . \"\\n\";
    echo \"You may need to run install/guest_purchase_config.sql manually.\\n\";
}
"




# Copy default upload files if they don't exist (fixes Docker volume override)
echo "Checking default upload files..."
if [ ! -f /var/www/html/system/uploads/admin.default.png ]; then
    echo "Copying default upload files to volume..."
    
    # Create temporary backup location
    TEMP_UPLOADS="/tmp/uploads_backup"
    mkdir -p $TEMP_UPLOADS
    
    # Copy from image to temp (these were copied during Docker build)
    if [ -d /var/www/html_backup/system/uploads ]; then
        cp -r /var/www/html_backup/system/uploads/* $TEMP_UPLOADS/
    fi
    
    # Copy to actual uploads directory (mounted volume)
    cp -rn $TEMP_UPLOADS/* /var/www/html/system/uploads/ 2>/dev/null || true
    
    # Set permissions
    chown -R www-data:www-data /var/www/html/system/uploads/
    
    echo "Default upload files copied successfully!"
else
    echo "Default upload files already exist, skipping copy."
fi

# Start cron service for automated cleanup
echo "Starting cron service for guest purchase cleanup..."
service cron start

# Execute the main command
exec "$@"
