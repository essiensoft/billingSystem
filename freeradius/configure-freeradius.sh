#!/bin/bash
# Substitute environment variables in FreeRADIUS configuration files
# This script runs in the FreeRADIUS container at startup

set -e

echo "Configuring FreeRADIUS with environment variables..."

# Get database credentials from environment or use defaults
DB_USER="${DB_USER:-phpnuxbill_user}"
DB_PASS="${DB_PASS:-ChangeThisPassword}"
DB_NAME="${DB_NAME:-phpnuxbill}"

# Get RADIUS configuration from environment or use defaults
RADIUS_SECRET="${RADIUS_SECRET:-pnb123}"
RADIUS_CLIENT="${RADIUS_CLIENT:-0.0.0.0/0}"
RADIUS_LOG_AUTH="${RADIUS_LOG_AUTH:-no}"

# Substitute in SQL module config
if [ -f /etc/freeradius/3.0/mods-available/sql ]; then
    sed -i "s/ENV_DB_USER/$DB_USER/g" /etc/freeradius/3.0/mods-available/sql
    sed -i "s/ENV_DB_PASS/$DB_PASS/g" /etc/freeradius/3.0/mods-available/sql
    sed -i "s/ENV_DB_NAME/$DB_NAME/g" /etc/freeradius/3.0/mods-available/sql
    echo "✓ Database credentials configured in SQL module"
else
    echo "⚠ Warning: SQL module config not found"
fi

# Substitute in clients.conf
if [ -f /etc/freeradius/3.0/clients.conf ]; then
    sed -i "s|ENV_RADIUS_SECRET|$RADIUS_SECRET|g" /etc/freeradius/3.0/clients.conf
    sed -i "s|ENV_RADIUS_CLIENT|$RADIUS_CLIENT|g" /etc/freeradius/3.0/clients.conf
    echo "✓ RADIUS client configuration updated (secret: *****, client: $RADIUS_CLIENT)"
else
    echo "⚠ Warning: clients.conf not found"
fi

# Enable SQL module if not already enabled
if [ ! -L /etc/freeradius/3.0/mods-enabled/sql ]; then
    ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql
    echo "✓ SQL module enabled"
fi

# Enable sqlcounter module if not already enabled
if [ ! -L /etc/freeradius/3.0/mods-enabled/sqlcounter ]; then
    ln -s /etc/freeradius/3.0/mods-available/sqlcounter /etc/freeradius/3.0/mods-enabled/sqlcounter
    echo "✓ SQL Counter module enabled"
fi

echo "FreeRADIUS configuration complete!"
