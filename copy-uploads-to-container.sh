#!/bin/bash

# Script to copy upload files to the running PHPNuxBill container
# Run this anytime the files are missing after a restart/redeploy

set -e

echo "========================================="
echo "Copying Upload Files to Container"
echo "========================================="
echo ""

# Check if container is running
if ! docker ps | grep -q phpnuxbill-app; then
    echo "❌ Error: phpnuxbill-app container is not running"
    echo "Please start the container first"
    exit 1
fi

echo "✓ Container is running"
echo ""

# Copy files
echo "Copying files from local system to container..."
docker cp ./system/uploads/. phpnuxbill-app:/var/www/html/system/uploads/

if [ $? -eq 0 ]; then
    echo "✓ Files copied successfully"
else
    echo "❌ Error copying files"
    exit 1
fi

echo ""
echo "Setting correct permissions..."
docker exec phpnuxbill-app chown -R www-data:www-data /var/www/html/system/uploads/
docker exec phpnuxbill-app chmod -R 755 /var/www/html/system/uploads/

echo "✓ Permissions set"
echo ""

# Verify files
echo "Verifying critical files..."
docker exec phpnuxbill-app bash -c '
for file in admin.default.png notifications.default.json logo.default.png favicon.default.png; do
    if [ -f "/var/www/html/system/uploads/$file" ]; then
        echo "  ✓ $file exists"
    else
        echo "  ✗ $file MISSING!"
    fi
done
'

echo ""
echo "========================================="
echo "✅ Upload files copied successfully!"
echo "========================================="
echo ""
echo "Files are now in the container and will persist"
echo "unless you delete the phpnuxbill-uploads volume."
echo ""
