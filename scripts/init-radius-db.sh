#!/bin/bash
# Initialize RADIUS tables in PHPNuxBill database
# This script is called automatically by docker-entrypoint.sh

set -e

echo "Checking RADIUS tables..."

# Check if RADIUS tables exist
TABLES_EXIST=$(mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -N -e "
    SELECT COUNT(*) 
    FROM information_schema.tables 
    WHERE table_schema = '${DB_NAME}' 
    AND table_name IN ('nas', 'radcheck', 'radreply', 'radusergroup', 'radgroupcheck', 'radgroupreply', 'radacct', 'radpostauth')
" 2>/dev/null || echo "0")

if [ "$TABLES_EXIST" -eq 8 ]; then
    echo "✓ All RADIUS tables already exist (found $TABLES_EXIST/8)"
    exit 0
fi

echo "RADIUS tables missing or incomplete (found $TABLES_EXIST/8)"
echo "Installing RADIUS tables from install/radius.sql..."

# Import RADIUS tables
if [ -f /var/www/html/install/radius.sql ]; then
    mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < /var/www/html/install/radius.sql
    
    # Verify installation
    TABLES_EXIST=$(mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -N -e "
        SELECT COUNT(*) 
        FROM information_schema.tables 
        WHERE table_schema = '${DB_NAME}' 
        AND table_name IN ('nas', 'radcheck', 'radreply', 'radusergroup', 'radgroupcheck', 'radgroupreply', 'radacct', 'radpostauth')
    ")
    
    if [ "$TABLES_EXIST" -eq 8 ]; then
        echo "✓ RADIUS tables installed successfully!"
        echo "  Tables: nas, radcheck, radreply, radusergroup, radgroupcheck, radgroupreply, radacct, radpostauth"
    else
        echo "⚠ Warning: Expected 8 RADIUS tables but found $TABLES_EXIST"
        exit 1
    fi
else
    echo "✗ Error: install/radius.sql not found!"
    exit 1
fi
