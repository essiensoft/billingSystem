#!/bin/bash
# Fix MySQL TIMESTAMP '0' errors in PHPNuxBill database
# This script updates invalid TIMESTAMP values to NULL

set -e

echo "Fixing MySQL TIMESTAMP errors..."
echo "================================"

# Database connection details from environment
DB_HOST="${DB_HOST:-mysql}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-phpnuxbill_user}"
DB_PASS="${DB_PASS:-ChangeThisPassword}"
DB_NAME="${DB_NAME:-phpnuxbill}"

echo "Connecting to database: $DB_NAME@$DB_HOST:$DB_PORT"

# Fix invalid TIMESTAMP values in common tables
mysql --ssl-mode=DISABLED -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF

-- Disable strict mode temporarily
SET SESSION sql_mode = 'NO_ENGINE_SUBSTITUTION';

-- Update invalid TIMESTAMP values to NULL in all tables
-- Common PHPNuxBill tables that might have TIMESTAMP issues

UPDATE tbl_plans SET created_at = NULL WHERE created_at = '0000-00-00 00:00:00' OR created_at = '0';
UPDATE tbl_plans SET updated_at = NULL WHERE updated_at = '0000-00-00 00:00:00' OR updated_at = '0';

UPDATE tbl_customers SET created_at = NULL WHERE created_at = '0000-00-00 00:00:00' OR created_at = '0';
UPDATE tbl_customers SET updated_at = NULL WHERE updated_at = '0000-00-00 00:00:00' OR updated_at = '0';

UPDATE tbl_user_recharges SET recharged_on = NULL WHERE recharged_on = '0000-00-00 00:00:00' OR recharged_on = '0';

UPDATE tbl_transactions SET created_at = NULL WHERE created_at = '0000-00-00 00:00:00' OR created_at = '0';

UPDATE tbl_bandwidth_management SET created_at = NULL WHERE created_at = '0000-00-00 00:00:00' OR created_at = '0';

-- Re-enable strict mode
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';

SELECT 'TIMESTAMP fix completed successfully!' as Status;

EOF

echo ""
echo "✅ TIMESTAMP errors fixed!"
echo "You can now access the application without TIMESTAMP errors."
