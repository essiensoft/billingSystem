#!/bin/bash

# Script to fix all "new Exception" bugs to "throw new Exception"
# This fixes the silent failure bug across all PHPNuxBill files

echo "=== Fixing Exception Handling Bugs ==="
echo ""

# Array of files to fix
files=(
    "system/controllers/plan.php"
    "system/controllers/customers.php"
    "system/controllers/accounts.php"
    "system/controllers/home.php"
    "system/controllers/login.php"
    "system/controllers/services.php"
)

total_fixed=0

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        
        # Count occurrences before fix
        before=$(grep -c "new Exception(Lang::T(\"Devices Not Found\"));" "$file" 2>/dev/null || echo "0")
        
        if [ "$before" -gt 0 ]; then
            # Create backup
            cp "$file" "$file.backup"
            
            # Fix the bug: replace "new Exception" with "throw new Exception"
            sed -i '' 's/new Exception(Lang::T("Devices Not Found"));/throw new Exception(Lang::T("Devices Not Found"));/g' "$file"
            
            # Count after fix
            after=$(grep -c "throw new Exception(Lang::T(\"Devices Not Found\"));" "$file" 2>/dev/null || echo "0")
            
            echo "  ✅ Fixed $before occurrences"
            total_fixed=$((total_fixed + before))
        else
            echo "  ℹ️  No bugs found"
        fi
    else
        echo "  ❌ File not found: $file"
    fi
    echo ""
done

echo "=== Summary ==="
echo "Total bugs fixed: $total_fixed"
echo ""
echo "Backups created with .backup extension"
echo "To restore backups: for f in system/**/*.backup; do mv \"\$f\" \"\${f%.backup}\"; done"
