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

# Execute the main command
exec "$@"
