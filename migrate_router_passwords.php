<?php
/**
 * Router Password Encryption Migration Script
 * 
 * This script migrates existing plaintext router passwords to encrypted format
 * 
 * IMPORTANT: 
 * - Backup database before running
 * - Test in staging environment first
 * - Run only once
 * 
 * Usage: php migrate_router_passwords.php
 */

// Load PHPNuxBill
require_once __DIR__ . '/init.php';

echo "========================================\n";
echo "Router Password Encryption Migration\n";
echo "========================================\n\n";

// Check if Crypto class exists
if (!class_exists('Crypto')) {
    die("ERROR: Crypto class not found. Please ensure Crypto.php is in system/autoload/\n");
}

// Get all routers
$routers = ORM::for_table('tbl_routers')->find_many();
$total = count($routers);

if ($total == 0) {
    echo "No routers found in database.\n";
    exit(0);
}

echo "Found {$total} routers to process.\n\n";

// Confirm before proceeding
echo "This will encrypt all plaintext router passwords.\n";
echo "Have you backed up the database? (yes/no): ";
$handle = fopen("php://stdin", "r");
$confirmation = trim(fgets($handle));
fclose($handle);

if (strtolower($confirmation) !== 'yes') {
    echo "Migration cancelled.\n";
    exit(0);
}

echo "\nStarting migration...\n\n";

$encrypted_count = 0;
$already_encrypted_count = 0;
$error_count = 0;
$errors = [];

foreach ($routers as $router) {
    $router_id = $router->id;
    $router_name = $router->name;
    $password = $router->password;
    
    echo "Processing router #{$router_id}: {$router_name}... ";
    
    // Skip if password is empty
    if (empty($password)) {
        echo "SKIPPED (empty password)\n";
        continue;
    }
    
    // Check if already encrypted
    if (Crypto::isEncrypted($password)) {
        echo "SKIPPED (already encrypted)\n";
        $already_encrypted_count++;
        continue;
    }
    
    // Encrypt the password
    try {
        $encrypted = Crypto::encrypt($password);
        $router->password = $encrypted;
        $router->save();
        
        echo "SUCCESS\n";
        $encrypted_count++;
        
        // Log the migration
        _log(
            "Router password encrypted for router: {$router_name} (ID: {$router_id})",
            'Migration',
            0
        );
        
    } catch (Exception $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
        $error_count++;
        $errors[] = [
            'router_id' => $router_id,
            'router_name' => $router_name,
            'error' => $e->getMessage()
        ];
        
        _log(
            "Router password encryption FAILED for router: {$router_name} (ID: {$router_id}) - " . $e->getMessage(),
            'Migration',
            0
        );
    }
}

echo "\n========================================\n";
echo "Migration Complete\n";
echo "========================================\n";
echo "Total routers: {$total}\n";
echo "Encrypted: {$encrypted_count}\n";
echo "Already encrypted: {$already_encrypted_count}\n";
echo "Errors: {$error_count}\n";

if ($error_count > 0) {
    echo "\nErrors encountered:\n";
    foreach ($errors as $error) {
        echo "  - Router #{$error['router_id']} ({$error['router_name']}): {$error['error']}\n";
    }
    echo "\nPlease review errors and retry failed routers manually.\n";
}

echo "\nMigration log saved to database (tbl_logs).\n";

// Verify encryption by testing decryption on a sample
if ($encrypted_count > 0) {
    echo "\nVerifying encryption...\n";
    $sample_router = ORM::for_table('tbl_routers')->find_one();
    
    if ($sample_router && !empty($sample_router->password)) {
        try {
            $decrypted = Crypto::decrypt($sample_router->password);
            echo "Verification SUCCESS: Encryption/decryption working correctly.\n";
        } catch (Exception $e) {
            echo "Verification FAILED: " . $e->getMessage() . "\n";
            echo "WARNING: Encrypted passwords may not be decryptable. Check encryption key configuration.\n";
        }
    }
}

echo "\n========================================\n";
echo "IMPORTANT: Test router connectivity before deploying to production!\n";
echo "========================================\n";
